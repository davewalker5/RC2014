using SerialSender.Entities.Configuration;
using SerialSender.Entities.Exceptions;

namespace SerialSender.Logic.Configuration
{
    public class CommandLineParser
    {
        private readonly List<CommandLineOption> _options = new List<CommandLineOption>();
        private readonly Dictionary<CommandLineOptionType, CommandLineOptionValue> _values = new Dictionary<CommandLineOptionType, CommandLineOptionValue>();

        /// <summary>
        /// Add an option to the available command line options
        /// </summary>
        /// <param name="optionType"></param>
        /// <param name="isOperation"></param>
        /// <param name="name"></param>
        /// <param name="shortName"></param>
        /// <param name="description"></param>
        /// <param name="minimumNumberOfValues"></param>
        /// <param name="maximumNumberOfValues"></param>
        public void Add(CommandLineOptionType optionType, bool isOperation, string name, string shortName, string description, int minimumNumberOfValues, int maximumNumberOfValues)
        {
            // Check the option's not a duplicate
            if (_options.Select(x => x.OptionType).Contains(optionType))
            {
                throw new DuplicateOptionException($"Duplicate option: {optionType.ToString()}");
            }

            // Check the option name's not a duplicate
            if (_options.Select(x => x.Name).Contains(name))
            {
                throw new DuplicateOptionException($"Duplicate option name: {name}");
            }

            // Check the option short name's not a duplicate
            if (_options.Select(x => x.ShortName).Contains(shortName))
            {
                throw new DuplicateOptionException($"Duplicate option short name: {shortName}");
            }

            // Add the new option
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
        /// Parse a command line supplied as an enumerable list of strings
        /// </summary>
        /// <param name="args"></param>
        /// <exception cref="MalformedCommandLineException"></exception>
        public void Parse(IEnumerable<string> args)
        {
            // Perform the intial parsing of the command line
            BuildValueList(args);

            // Check that all arguments have the required number of values
            CheckForMinimumValues();

            // Check that there's only one argument that defines an operation. For example,
            // looking up an album's details is one operation, importing a CSV file is another.
            // Both can't be supplied at the same time
            CheckForSingleOperation();
        }

        /// <summary>
        /// Check if the specified option type is present on the command line
        /// </summary>
        /// <param name="optionType"></param>
        /// <returns></returns>
        public bool IsPresent(CommandLineOptionType optionType)
        {
            return _values.ContainsKey(optionType);
        }

        /// <summary>
        /// Return the valus for the specified option type
        /// </summary>
        /// <param name="optionType"></param>
        /// <returns></returns>
        public List<string> GetValues(CommandLineOptionType optionType)
        {
            List<string> values = null;

            if (_values.ContainsKey(optionType))
            {
                values = _values[optionType].Values;
            }

            return values;
        }

        /// <summary>
        /// Check that each supplied option has sufficient values with it
        /// </summary>
        /// <exception cref="TooFewValuesException"></exception>
        private void CheckForMinimumValues()
        {
            foreach (var value in _values.Values)
            {
                if (value.Values.Count < value.Option?.MinimumNumberOfValues)
                {
                    var message = $"Too few values supplied for '{value.Option.Name}': Expected {value.Option.MinimumNumberOfValues}, got {value.Values.Count}";
                    throw new TooFewValuesException(message);
                }
            }
        }

        /// <summary>
        /// Check there's only one operation specified on the command line
        /// </summary>
        private void CheckForSingleOperation()
        {
            IEnumerable<CommandLineOption> options = _options.Where(x => _values!.ContainsKey(x.OptionType) && x.IsOperation);
            if (options!.Count() > 1)
            {
                var message = $"Command line specifies multiple operations: {string.Join(", ", options.Select(x => x.ToString()))}";
                throw new MultipleOperationsException(message);
            }
        }

        /// <summary>
        /// Build the value list from the command line
        /// </summary>
        /// <param name="args"></param>
        /// <exception cref="TooManyValuesException"></exception>
        /// <exception cref="MalformedCommandLineException"></exception>
        private void BuildValueList(IEnumerable<string> args)
        {
            CommandLineOptionValue current = null;

            // Iterate over the command line arguments extracting options and associated values
            foreach (string arg in args)
            {
                if (!string.IsNullOrEmpty(arg))
                {
                    if (arg.StartsWith("--"))
                    {
                        // Starts with "--" so this is the full name of an option. Create a new value
                        current = AddOptionValue(arg, true);
                    }
                    else if (arg.StartsWith('-'))
                    {
                        // Starts with "-" so this is the short name of an option. Create a new value
                        current = AddOptionValue(arg, false);
                    }
                    else if (current != null)
                    {
                        // No prefix but we have a current option so add this to the values for it, check that
                        // this doesn't exceed the maximum number of values for that option and raise an exception
                        // if it does
                        current.Values.Add(arg);
                        if (current.Values.Count > current.Option?.MaximumNumberOfValues)
                        {
                            var message = $"Too many values for '{current.Option.Name}' at '{arg}'";
                            throw new TooManyValuesException(message);
                        }
                    }
                    else
                    {
                        // Doesn't start with a prefix indicating this is the start of a new option and
                        // we don't have a current option - malformed command line
                        var message = $"Malformed command line at '{arg}'";
                        throw new MalformedCommandLineException(message);
                    }
                }
            }
        }

        /// <summary>
        /// Find an argument by name or short name
        /// </summary>
        /// <param name="option"></param>
        /// <param name="byName"></param>
        /// <returns></returns>
        private CommandLineOption FindOption(string argument, bool byName)
        {
            // Look for the argument in the available options and, if found, return it
            foreach (var option in _options)
            {
                if (byName && option.Name.Equals(argument) || !byName && option.ShortName.Equals(argument))
                {
                    return option;
                }
            }

            // Not found, so raise an exception
            var message = $"Unrecognised command line option {argument}";
            throw new UnrecognisedCommandLineOptionException(message);
        }

        /// <summary>
        /// Find an option by name or short name and add a value for it to the collection
        /// </summary>
        /// <param name="optionName"></param>
        /// <param name="byName"></param>
        /// <returns></returns>
        private CommandLineOptionValue AddOptionValue(string optionName, bool byName)
        {
            // Find the option definition and see if the value already exists
            var option = FindOption(optionName, byName);
            var value = _values.ContainsKey(option.OptionType) ? _values[option.OptionType] : null;
            if (value == null)
            {
                // Value doesn't exist, so add it
                value = new CommandLineOptionValue
                {
                    Option = option
                };
                _values.Add(option.OptionType, value);
            }

            return value;
        }
    }
}
