using Microsoft.Extensions.Configuration;
using MIDIConverter.Entities.Interfaces;

namespace MIDIConverter.Logic.Configuration
{
    public sealed class ConfigReader<T> : IConfigReader<T> where T : class
    {
        /// <summary>
        /// Load and return the application settings from the named JSON-format application settings file
        /// </summary>
        /// <returns></returns>
        public T Read(string jsonFileName)
        {
            // Set up the configuration reader
            IConfiguration configuration = new ConfigurationBuilder()
                .AddJsonFile(jsonFileName)
                .Build();

            // Read the application settings section
            IConfigurationSection section = configuration.GetSection("ApplicationSettings");
            return section.Get<T>() ?? throw new InvalidDataException(
                $"The ApplicationSettings section is missing or invalid in '{jsonFileName}'.");
        }
    }
}
