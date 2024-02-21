using Renumber.Entities.Configuration;
using Renumber.Entities.Interfaces;
using System.IO.Ports;

namespace Renumber.Logic.Configuration
{
    public class RenumberSettingsBuilder
    {
        public IRenumberAppSettings Settings {get; private set;}
        public string FileName {get; private set;}

        /// <summary>
        /// Build the settings for the application from the configuration file, that provides the
        /// default values, and the command line options, that provide the overrides.
        /// </summary>
        /// <param name="args"></param>
        /// <param name="configJsonPath"></param>
        public void BuildSettings(IEnumerable<string> args, string configJsonPath)
        {
            // Read the default settings from the configuration file
            Settings = new ConfigReader<RenumberAppSettings>().Read(configJsonPath);

            // Parse the command line
            CommandLineParser parser = new();
            parser.Add(CommandLineOptionType.Renumber, true, "--renumber", "-r", "Path to the file to renumber", 1, 1);
            parser.Add(CommandLineOptionType.InPlace, false, "--inplace", "-i", "Do not create a backup file - renumber in-place", 1, 1);
            parser.Add(CommandLineOptionType.StartAt, false, "--start", "-s", "Starting line number", 1, 1);
            parser.Add(CommandLineOptionType.IncrementBy, false, "--increment", "-in", "Increment in line number for each successive line", 1, 1);
            parser.Parse(args);

            // Capture the file name to renumber
            var values = parser.GetValues(CommandLineOptionType.Renumber);
            if (values != null) FileName = values[0];

            // Apply the command line values over the defaults
            values = parser.GetValues(CommandLineOptionType.InPlace);
            if (values != null) Settings.InPlace = bool.Parse(values[0]);

            values = parser.GetValues(CommandLineOptionType.StartAt);
            if (values != null) Settings.StartAt = int.Parse(values[0]);

            values = parser.GetValues(CommandLineOptionType.IncrementBy);
            if (values != null) Settings.IncrementBy = int.Parse(values[0]);
        }
    }
}