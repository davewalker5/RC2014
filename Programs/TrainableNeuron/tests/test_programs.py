"""Execute the BASIC programs with cbmbasic; capture OUT as port writes.

This exercises a related Microsoft BASIC, not the RC2014 ROM or real hardware.
Only OUT statements are replaced; training and display logic run unchanged.
"""

import math
import re
import shutil
import subprocess
import tempfile
import unittest
from collections.abc import Sequence
from pathlib import Path

PROGRAM_DIRECTORY = Path(__file__).resolve().parents[1]
PROGRAM_PATHS = tuple(sorted(PROGRAM_DIRECTORY.glob("*.bas")))
BASIC_EXECUTABLE = shutil.which("cbmbasic")
EXECUTION_TIMEOUT_SECONDS = 20
MAXIMUM_BASIC_LINE_LENGTH = 72
DIGITAL_IO_PORT = 1
LCD_COMMAND_PORT = 218
LCD_DATA_PORT = 219
LCD_ROW_LENGTH = 16

NUMBER_PATTERN = r"[-+]?(?:\d*\.\d+|\d+\.?\d*)(?:E[-+]?\d+)?"


def _reported_value(output: str, label: str) -> float:
    """
    Extract the first numeric value following a label in BASIC output.

    :param output: Captured terminal output from a BASIC program.
    :param label: Literal label immediately preceding the required number.
    :return: Parsed numeric value.
    :raises AssertionError: If the label has no following numeric value.
    """
    match = re.search(
        re.escape(label) + r"\s*(" + NUMBER_PATTERN + ")", output
    )
    if match is None:
        raise AssertionError(
            f"No numeric value found after {label!r} in BASIC output"
        )
    return float(match[1])


def _mean_loss(
    weight: float,
    bias: float,
    inputs: Sequence[float],
    targets: Sequence[int],
) -> float:
    """
    Calculate an independent reference mean binary cross-entropy.

    Inputs must be a non-empty sequence paired with an equally sized sequence
    of binary targets. Inputs, logits and parameters are dimensionless; tests
    use finite values within the range supported by Python's arithmetic.

    :param weight: Weight shared by all examples.
    :param bias: Bias shared by all examples.
    :param inputs: Numeric input values for the batch.
    :param targets: Corresponding target labels, each zero or one.
    :return: Mean sample loss calculated from logits without rounding probabilities.
    """
    losses = []
    # The logit-based form avoids LOG of a rounded probability; log1p
    # retains small corrections that LOG(1 + q) can lose.
    for x, target in zip(inputs, targets):
        z = weight * x + bias
        signed_logit = -z if target else z
        losses.append(max(0, signed_logit) + math.log1p(math.exp(-abs(z))))
    return sum(losses) / len(losses)


class SourceTests(unittest.TestCase):
    """Validate BASIC source constraints without requiring an interpreter."""

    def test_loadable_lines_and_branch_targets(self) -> None:
        """Check all variants have loadable lines and existing branch targets."""
        self.assertEqual(len(PROGRAM_PATHS), 3)
        for path in PROGRAM_PATHS:
            lines = path.read_text().splitlines()
            numbers = [int(line.split()[0]) for line in lines]
            self.assertEqual(numbers, sorted(set(numbers)), path.name)
            for line in lines:
                self.assertLessEqual(
                    len(line), MAXIMUM_BASIC_LINE_LENGTH, line
                )
                for target in re.findall(r"\b(?:GOTO|GOSUB) (\d+)", line):
                    self.assertIn(int(target), numbers, line)


@unittest.skipUnless(
    BASIC_EXECUTABLE, "Install cbmbasic to run the BASIC execution checks"
)
class ExecutionTests(unittest.TestCase):
    """Exercise learning and simulated I/O using the host BASIC interpreter."""

    def _run_program(
        self,
        path: Path,
        edits: dict[int, str] | None = None,
        answers: str | None = None,
    ) -> str:
        """
        Run a temporary BASIC program with simulated hardware output.

        Only the temporary copy is edited. OUT statements are replaced with
        marked PRINT statements because cbmbasic cannot access RC2014 hardware.
        By default, answers advance the six hardware result pauses and exit
        without interactive predictions.

        :param path: Source BASIC program to execute.
        :param edits: Optional BASIC line numbers mapped to replacement statements,
            without their line numbers; missing lines are inserted.
        :param answers: Terminal input, or None to use the default exit responses.
        :return: Captured terminal output with cbmbasic cursor controls removed.
        :raises AssertionError: If execution fails, reports a BASIC error, or
            does not reach normal or validated-error cleanup.
        :raises subprocess.TimeoutExpired: If execution exceeds the time limit.
        """
        if BASIC_EXECUTABLE is None:
            raise AssertionError("cbmbasic is required for execution checks")
        lines = {
            int(line.split()[0]): line
            for line in path.read_text().splitlines()
        }
        for number, statement in (edits or {}).items():
            lines[number] = f"{number} {statement}"
        source = (
            "\n".join(lines[line_number] for line_number in sorted(lines))
            + "\n"
        )
        # Preserve evaluated port writes so tests can inspect hardware intent.
        source = re.sub(
            r"\bOUT ([A-Z]+), ([^:\n]+)", r'PRINT "@PORT";\1;",";\2', source
        )
        if answers is None:
            answers = ("\n" * 6 if "_io" in path.stem else "") + "n\n"
        with tempfile.TemporaryDirectory() as directory:
            candidate = Path(directory) / path.name
            candidate.write_text(source)
            result = subprocess.run(
                [BASIC_EXECUTABLE, str(candidate)],
                input=answers,
                text=True,
                capture_output=True,
                timeout=EXECUTION_TIMEOUT_SECONDS,
            )
        self.assertEqual(result.returncode, 0, result.stderr)
        # cbmbasic inserts a cursor-right control between printed numeric fields.
        output = result.stdout.replace("\x1d", "")
        self.assertNotRegex(
            output.upper(), r"\?(?:SYNTAX|OUT OF DATA|OVERFLOW|.*ERROR)"
        )
        self.assertIn("Finished.", output)
        return output

    def _ports(self, output: str) -> list[tuple[int, int]]:
        """
        Decode simulated OUT writes in their original execution order.

        :param output: Captured BASIC output containing marked port writes.
        :return: Integer (port, data) pairs; an empty list when no writes occurred.
        """
        return [
            (int(float(port)), int(float(data)))
            for port, data in re.findall(
                r"@PORT\s*("
                + NUMBER_PATTERN
                + r")\s*,\s*("
                + NUMBER_PATTERN
                + ")",
                output,
            )
        ]

    def test_default_learning_in_all_variants(self) -> None:
        """Check default learning results, checkpoint losses and hardware cleanup."""
        for path in PROGRAM_PATHS:
            with self.subTest(program=path.name):
                output = self._run_program(path)
                self.assertAlmostEqual(
                    _reported_value(output, "Initial loss:"),
                    math.log(2),
                    places=6,
                )
                self.assertAlmostEqual(
                    _reported_value(output, "Final loss:"),
                    0.184100254,
                    places=6,
                )
                self.assertAlmostEqual(
                    _reported_value(output, "Learned weight:"),
                    1.00639356,
                    places=5,
                )
                self.assertAlmostEqual(
                    _reported_value(output, "Bias:"), -2.39341756, places=5
                )
                self.assertAlmostEqual(
                    _reported_value(output, "Learned threshold (-B/W):"),
                    2.37821232,
                    places=5,
                )
                self.assertEqual(
                    re.findall(r"Predicted class:\s*(\d)", output),
                    list("000111"),
                )
                losses = [
                    float(number)
                    for number in re.findall(
                        r"  Loss:\s*(" + NUMBER_PATTERN + ")", output
                    )
                ]
                self.assertEqual(len(losses), 11)
                self.assertTrue(
                    all(
                        current < previous
                        for previous, current in zip(losses, losses[1:])
                    )
                )
                writes = self._ports(output)
                if "_io" in path.stem:
                    self.assertEqual(
                        [
                            data
                            for port, data in writes
                            if port == DIGITAL_IO_PORT
                        ],
                        [0, 0, 0, 0, 1, 1, 1, 0],
                    )
                else:
                    self.assertEqual(writes, [])
                if "lcd" in path.stem:
                    rows: list[str] = []
                    row: list[str] = []
                    for port, data in writes:
                        if port == LCD_COMMAND_PORT and data in (128, 192):
                            row = []
                        if port == LCD_DATA_PORT:
                            row.append(chr(data))
                            if len(row) == LCD_ROW_LENGTH:
                                rows.append("".join(row))
                    self.assertIn("UPDATE 200      ", rows)
                    self.assertIn("CLASS: 0        ", rows)
                    self.assertIn("CLASS: 1        ", rows)
                    self.assertEqual(writes[-1], (LCD_COMMAND_PORT, 1))

    def test_original_python_comparison_settings(self) -> None:
        """Check all variants reproduce the original 2,000-update reference results."""
        for path in PROGRAM_PATHS:
            output = self._run_program(
                path, {30: "LET RA = .1 : LET NE = 2000 : LET NF = 200"}
            )
            self.assertAlmostEqual(
                _reported_value(output, "Final loss:"), 0.035554936, places=6
            )
            self.assertAlmostEqual(
                _reported_value(output, "Learned weight:"), 2.3567447, places=5
            )
            self.assertAlmostEqual(
                _reported_value(output, "Bias:"), -6.6923707, places=5
            )
            self.assertAlmostEqual(
                _reported_value(output, "Learned threshold (-B/W):"),
                2.8396672,
                places=5,
            )

    def test_loss_only_at_checkpoints_and_progress_each_update(self) -> None:
        """Check selective loss reporting and one progress dot per completed update."""
        for epochs, interval in [(200, 20), (23, 7), (4, 20), (0, 20)]:
            output = self._run_program(
                PROGRAM_PATHS[0],
                {
                    5: "LET ZC = 0",
                    30: f"LET RA = .1 : LET NE = {epochs} : LET NF = {interval}",
                    1405: "LET ZC = ZC + 1",
                    835: 'PRINT "Loss evaluations:"; ZC',
                },
            )
            # Update 1 reuses initial loss; later checkpoints and final state need batches.
            batches = 1 + epochs // interval + int(epochs > 0)
            self.assertEqual(
                _reported_value(output, "Loss evaluations:"), 6 * batches
            )
            dots = re.findall(r"^\.+$", output, re.MULTILINE)
            self.assertEqual(sum(map(len, dots)), epochs)
            # An independent Python loop checks both timing and values of reports.
            # Capture loss before updating either parameter, matching checkpoint semantics.
            weight, bias = 0.0, 0.0
            inputs, targets = [0, 1, 2, 4, 5, 6], [0, 0, 0, 1, 1, 1]
            expected_losses = []
            for epoch in range(1, epochs + 1):
                if epoch == 1 or epoch % interval == 0:
                    expected_losses.append(
                        _mean_loss(weight, bias, inputs, targets)
                    )
                # Both gradients must use predictions from the same pre-update state.
                errors = [
                    1 / (1 + math.exp(-(weight * x + bias))) - target
                    for x, target in zip(inputs, targets)
                ]
                weight -= (
                    0.1
                    * sum(error * x for error, x in zip(errors, inputs))
                    / 6
                )
                bias -= 0.1 * sum(errors) / 6
            actual_losses = [
                float(number)
                for number in re.findall(
                    r"  Loss:\s*(" + NUMBER_PATTERN + ")", output
                )
            ]
            self.assertEqual(len(actual_losses), len(expected_losses))
            for actual, expected in zip(actual_losses, expected_losses):
                self.assertAlmostEqual(actual, expected, places=6)
            self.assertAlmostEqual(
                _reported_value(output, "Final loss:"),
                _mean_loss(weight, bias, inputs, targets),
                places=6,
            )

    def test_hand_calculated_update(self) -> None:
        """Check one full-batch update against a two-example hand calculation."""
        output = self._run_program(
            PROGRAM_PATHS[0],
            {
                30: "LET RA = .2 : LET NE = 1 : LET NF = 1",
                40: "LET N = 2",
                5000: "DATA 0,0,2,1",
            },
        )
        # At p=0.5, weight contributions are 0 and -1; bias contributions cancel.
        self.assertEqual(_reported_value(output, "DW:"), -0.5)
        self.assertEqual(_reported_value(output, "DB:"), 0)
        self.assertAlmostEqual(_reported_value(output, "Learned weight:"), 0.1)
        self.assertEqual(_reported_value(output, "Bias:"), 0)
        self.assertAlmostEqual(
            _reported_value(output, "Final loss:"),
            _mean_loss(0.1, 0, [0, 2], [0, 1]),
            places=6,
        )

    def test_zero_updates_and_probability_tie(self) -> None:
        """Check zero updates preserve initial parameters and classify ties as zero."""
        for path in PROGRAM_PATHS:
            output = self._run_program(
                path, {30: "LET RA = .1 : LET NE = 0 : LET NF = 200"}
            )
            self.assertEqual(_reported_value(output, "Learned weight:"), 0)
            self.assertEqual(_reported_value(output, "Bias:"), 0)
            self.assertIn("No input-dependent threshold", output)
            self.assertNotIn("Update:", output)
            self.assertEqual(
                re.findall(r"Predicted class:\s*(\d)", output), list("000000")
            )

    def test_reversed_labels_learn_negative_weight(self) -> None:
        """Check reversing the labels learns the opposite classification direction."""
        output = self._run_program(
            PROGRAM_PATHS[0], {5000: "DATA 0,1,1,1,2,1,4,0,5,0,6,0"}
        )
        self.assertLess(_reported_value(output, "Learned weight:"), 0)
        self.assertEqual(
            re.findall(r"Predicted class:\s*(\d)", output), list("111000")
        )

    def test_extreme_wrong_predictions_have_finite_loss(self) -> None:
        """Check saturated wrong predictions retain finite logit-based loss."""
        output = self._run_program(
            PROGRAM_PATHS[0],
            {
                20: "LET W = 1000 : LET B = 0",
                30: "LET RA = .1 : LET NE = 1 : LET NF = 1",
                40: "LET N = 2",
                5000: "DATA -1,1,1,0",
            },
        )
        # Rounded probabilities are 0 and 1, but each wrong logit still costs 1000.
        self.assertEqual(_reported_value(output, "Initial loss:"), 1000)
        self.assertEqual(_reported_value(output, "DW:"), 1)
        self.assertEqual(_reported_value(output, "DB:"), 0)
        self.assertAlmostEqual(
            _reported_value(output, "Final loss:"), 999.9, places=4
        )

    def test_gradients_against_independent_finite_differences(self) -> None:
        """Check analytic gradients against numerical derivatives of reference loss."""
        inputs, targets = [-2, 0.5, 3], [1, 0, 1]
        for weight, bias in [(0, 0), (0.7, -0.4), (-1.2, 0.8), (10, 0)]:
            output = self._run_program(
                PROGRAM_PATHS[0],
                {
                    20: f"LET W = {weight} : LET B = {bias}",
                    30: "LET RA = .1 : LET NE = 1 : LET NF = 1",
                    40: "LET N = 3",
                    5000: "DATA -2,1,.5,0,3,1",
                },
            )
            # Central differences check the loss derivative independently of p - t.
            # This step balances truncation error against floating-point cancellation.
            difference_step = 1e-5
            weight_gradient = (
                _mean_loss(weight + difference_step, bias, inputs, targets)
                - _mean_loss(weight - difference_step, bias, inputs, targets)
            ) / (2 * difference_step)
            bias_gradient = (
                _mean_loss(weight, bias + difference_step, inputs, targets)
                - _mean_loss(weight, bias - difference_step, inputs, targets)
            ) / (2 * difference_step)
            self.assertAlmostEqual(
                _reported_value(output, "DW:"), weight_gradient, places=6
            )
            self.assertAlmostEqual(
                _reported_value(output, "DB:"), bias_gradient, places=6
            )
            self.assertAlmostEqual(
                _reported_value(output, "Initial loss:"),
                _mean_loss(weight, bias, inputs, targets),
                places=6,
            )

    def test_invalid_settings_and_labels_clear_hardware(self) -> None:
        """Check invalid settings and training data exit through hardware cleanup."""
        bad_settings = [
            {40: "LET N = 0"},
            {40: "LET N = 101"},
            {30: "LET RA = 0 : LET NE = 1 : LET NF = 1"},
            {30: "LET RA = .1 : LET NE = -1 : LET NF = 1"},
            {30: "LET RA = .1 : LET NE = .5 : LET NF = 1"},
            {30: "LET RA = .1 : LET NE = 1 : LET NF = 0"},
            {5000: "DATA 0,2,1,0,2,0,4,1,5,1,6,1"},
            {5000: "DATA 1001,0,1,0,2,0,4,1,5,1,6,1"},
        ]
        for path in PROGRAM_PATHS:
            for edits in bad_settings:
                output = self._run_program(path, edits, answers="")
                self.assertIn("Invalid settings", output)
                self.assertNotIn("TRAINING COMPLETE", output)
                if "_io" in path.stem:
                    self.assertEqual(
                        [
                            data
                            for port, data in self._ports(output)
                            if port == DIGITAL_IO_PORT
                        ],
                        [0, 0],
                    )
                if "lcd" in path.stem:
                    self.assertEqual(
                        self._ports(output)[-1], (LCD_COMMAND_PORT, 1)
                    )

    def test_interactive_validation_and_predictions_do_not_retrain(
        self,
    ) -> None:
        """Check interactive validation and predictions leave learned parameters fixed."""
        for path in PROGRAM_PATHS:
            pauses = "\n" * 6 if "_io" in path.stem else ""
            output = self._run_program(
                path, answers=pauses + "bad\ny\n1001\n2\nY\n4\nn\n"
            )
            self.assertIn("Enter Y or N", output)
            self.assertIn("Use -1000 to 1000.", output)
            self.assertEqual(
                re.findall(r"Predicted class:\s*(\d)", output),
                list("00011101"),
            )
            self.assertEqual(output.count("TRAINING COMPLETE"), 1)
            biases = re.findall(r"Bias B:\s*(" + NUMBER_PATTERN + ")", output)
            self.assertEqual(len(set(biases)), 1)


if __name__ == "__main__":
    unittest.main()
