using MIDIConverter.Entities.Configuration;
using MIDIConverter.Entities.Exceptions;

namespace MIDIConverter.Logic.Configuration
{
    /// <summary>
    /// Parses the option/value command-line grammar shared with SerialSender.
    /// </summary>
    public sealed class CommandLineParser
    {
        private readonly List<CommandLineOption> _options = [];
        private readonly Dictionary<CommandLineOptionType, CommandLineOptionValue> _values = [];

        /// <summary>
        /// Adds an available command-line option.
        /// </summary>
        public void Add(
            CommandLineOptionType optionType,
            bool isOperation,
            string name,
            string shortName,
            string description,
            int minimumNumberOfValues,
            int maximumNumberOfValues)
        {
            if (_options.Any(x => x.OptionType == optionType))
            {
                throw new DuplicateOptionException($"Duplicate option: {optionType}");
            }

            if (_options.Any(x => string.Equals(x.Name, name, StringComparison.OrdinalIgnoreCase)))
            {
                throw new DuplicateOptionException($"Duplicate option name: {name}");
            }

            if (_options.Any(x => string.Equals(x.ShortName, shortName, StringComparison.OrdinalIgnoreCase)))
            {
                throw new DuplicateOptionException($"Duplicate option short name: {shortName}");
            }

            _options.Add(new CommandLineOption
            {
                OptionType = optionType,
                IsOperation = isOperation,
                Name = name,
                ShortName = shortName,
                Description = description,
                MinimumNumberOfValues = minimumNumberOfValues,
                MaximumNumberOfValues = maximumNumberOfValues
            });
        }

        /// <summary>
        /// Parses an enumerable sequence of command-line arguments.
        /// </summary>
        public void Parse(IEnumerable<string> args)
        {
            ArgumentNullException.ThrowIfNull(args);
            _values.Clear();
            BuildValueList(args);
            CheckForMinimumValues();
            CheckForSingleOperation();
        }

        /// <summary>
        /// Determines whether an option was supplied.
        /// </summary>
        public bool IsPresent(CommandLineOptionType optionType)
            => _values.ContainsKey(optionType);

        /// <summary>
        /// Returns the values supplied for an option, or null when it was absent.
        /// </summary>
        public IReadOnlyList<string>? GetValues(CommandLineOptionType optionType)
            => _values.TryGetValue(optionType, out var value) ? value.Values : null;

        private void CheckForMinimumValues()
        {
            foreach (var value in _values.Values)
            {
                if (value.Values.Count < value.Option.MinimumNumberOfValues)
                {
                    throw new TooFewValuesException(
                        $"Too few values supplied for '{value.Option.Name}': " +
                        $"Expected {value.Option.MinimumNumberOfValues}, got {value.Values.Count}");
                }
            }
        }

        private void CheckForSingleOperation()
        {
            var operations = _options.Where(x => _values.ContainsKey(x.OptionType) && x.IsOperation).ToList();
            if (operations.Count > 1)
            {
                throw new MultipleOperationsException(
                    $"Command line specifies multiple operations: {string.Join(", ", operations.Select(x => x.Name))}");
            }
        }

        private void BuildValueList(IEnumerable<string> args)
        {
            CommandLineOptionValue? current = null;

            foreach (var argument in args.Where(x => !string.IsNullOrEmpty(x)))
            {
                if (argument.StartsWith("--", StringComparison.Ordinal))
                {
                    current = AddOptionValue(argument, true);
                }
                else if (argument.StartsWith("-", StringComparison.Ordinal))
                {
                    current = AddOptionValue(argument, false);
                }
                else if (current is not null)
                {
                    current.Values.Add(argument);
                    if (current.Values.Count > current.Option.MaximumNumberOfValues)
                    {
                        throw new TooManyValuesException(
                            $"Too many values for '{current.Option.Name}' at '{argument}'");
                    }
                }
                else
                {
                    throw new MalformedCommandLineException($"Malformed command line at '{argument}'");
                }
            }
        }

        private CommandLineOption FindOption(string argument, bool byName)
        {
            var option = _options.FirstOrDefault(x => string.Equals(
                byName ? x.Name : x.ShortName,
                argument,
                StringComparison.OrdinalIgnoreCase));

            return option ?? throw new UnrecognisedCommandLineOptionException(
                $"Unrecognised command line option {argument}");
        }

        private CommandLineOptionValue AddOptionValue(string optionName, bool byName)
        {
            var option = FindOption(optionName, byName);
            if (_values.TryGetValue(option.OptionType, out var existing))
            {
                throw new DuplicateOptionException($"Duplicate option: {optionName}");
            }

            var value = new CommandLineOptionValue { Option = option };
            _values.Add(option.OptionType, value);
            return value;
        }
    }
}
