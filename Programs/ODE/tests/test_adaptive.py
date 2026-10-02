"""Run the actual solver listings with cbmbasic (a related Microsoft BASIC)."""
import math
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASIC = shutil.which('cbmbasic')
NUMBER = r'[-+]?(?:\d*\.\d+|\d+\.?\d*)(?:E[-+]?\d+)?'


@unittest.skipUnless(BASIC, 'cbmbasic is required')
class AdaptiveTests(unittest.TestCase):
    def execute(self, source, answers=''):
        # Commodore reserves ST for I/O status and has no CLEAR n command.
        # Adapt those dialect differences only; preserve numerical statements.
        source = re.sub(r'\bST\b', 'HS', source)
        source = source.replace('40 CLEAR 2000', '40 REM CLEAR 2000')
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'test.bas'
            path.write_text(source)
            result = subprocess.run([BASIC, str(path)], input=answers,
                                    text=True, capture_output=True, timeout=20)
        self.assertEqual(result.returncode, 0, result.stderr)
        output = result.stdout.replace('\x1d', '')
        self.assertNotIn('ERROR', output.upper(), output)
        return output

    def test_trial_state_and_rejection(self):
        # A time-dependent derivative exposes incorrect midpoint times as well
        # as stale derivatives. Exact solution from (2, 3): 6*exp(t-2)-t-1.
        def step(method, t, y, h):
            f = lambda t, y: t + y
            k1 = f(t, y)
            if method == 'E':
                return y + h*k1
            if method == 'P':
                return y + h*(k1 + f(t+h, y+h*k1))/2
            k2 = f(t+h/2, y+h*k1/2)
            k3 = f(t+h/2, y+h*k2/2)
            k4 = f(t+h, y+h*k3)
            return y + h*(k1+2*k2+2*k3+k4)/6

        components = '\n'.join((ROOT/'Components'/f'{name}.bas').read_text()
                               for name in ('integrators', 'adaptive'))
        for method in 'EPR':
            for tolerance in (1, .00001):
                with self.subTest(method=method, tolerance=tolerance):
                    h = .5
                    while True:
                        full = step(method, 2, 3, h)
                        mid = step(method, 2, 3, h/2)
                        end = step(method, 2+h/2, mid, h/2)
                        if abs(end-full) <= tolerance:
                            break
                        h /= 2
                    source = f'''10 DIM Y(10), T(10)
20 I=1 : Y(1)=3 : T(1)=2 : T(2)=99
30 ST=.5 : DL={tolerance:.8f} : MT$="{method}" : F=-999
40 GOSUB 3400
50 PRINT "RESULT";I;T(1);Y(1);T(2);Y(2);ST
60 END
2000 F=T(I)+Y(I) : RETURN
{components}
'''
                    output = self.execute(source)
                    values = [float(x) for x in re.findall(NUMBER, output.split('RESULT', 1)[1])]
                    expected = [2, 2, 3, 2+h, end, h]
                    self.assertEqual(len(values), len(expected), output)
                    for actual, wanted in zip(values, expected):
                        self.assertAlmostEqual(actual, wanted, delta=2e-6)

    def test_complete_solver(self):
        source = (ROOT/'adaptive_step_solver.bas').read_text()
        for method in 'EPR':
            for mode in 'AF':
                with self.subTest(method=method, mode=mode):
                    answers = f'{method}\n{mode}\n'
                    if mode == 'A':
                        answers += '.00001\n'
                    answers += '1\n1\n.5\nT\n1\n'
                    output = self.execute(source, answers)
                    rows = [tuple(map(float, row)) for row in re.findall(
                        rf'^\s*(\d+)\s+({NUMBER})\s+({NUMBER})\s*$', output, re.M)]
                    self.assertGreaterEqual(len(rows), 3, output)
                    self.assertAlmostEqual(rows[0][1], 0)
                    self.assertAlmostEqual(rows[-1][1], 1)
                    for previous, current in zip(rows, rows[1:]):
                        self.assertGreater(current[1], previous[1])
                    if mode == 'A':
                        for _, t, y in rows:
                            self.assertAlmostEqual(y, math.exp(t), delta=.01)

    def test_point_limit_stops_cleanly(self):
        source = (ROOT/'adaptive_step_solver.bas').read_text()
        source = source.replace('MS = 1000', 'MS = 5')
        output = self.execute(source, 'E\nA\n.00001\n1\n1\n.5\nT\n1\n')
        self.assertIn('Point limit reached', output)
        self.assertIn('Step', output)

    def test_unrepresentable_half_step_stops(self):
        components = '\n'.join((ROOT/'Components'/f'{name}.bas').read_text()
                               for name in ('integrators', 'adaptive'))
        source = f'''10 DIM Y(10), T(10)
20 I=1 : Y(1)=3 : T(1)=1E20
30 ST=1 : DL=.00001 : MT$="E"
40 GOSUB 3400
50 END
2000 F=Y(I) : RETURN
{components}
'''
        self.assertIn('Step size too small', self.execute(source))

    def test_assembled_listing_matches_components(self):
        names = ('core', 'initialise', 'function', 'integrators',
                 'adaptive', 'tabulate', 'chart')
        expected = ''.join((ROOT/'Components'/f'{name}.bas').read_text().rstrip()+'\n'
                           for name in names)
        self.assertEqual((ROOT/'adaptive_step_solver.bas').read_text(), expected)


if __name__ == '__main__':
    unittest.main()
