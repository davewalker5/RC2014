
using Renumber.Entities.Configuration;
using Renumber.Entities.Events;
using Renumber.Entities.Renumberer;
using Renumber.Logic.Configuration;
using Renumber.Logic.Renumberer;
using System;
using System.Diagnostics;
using System.Reflection;

namespace Renumber
{
    public class Program
    {
        private static int _linesRead = 0;
        private static int _linesRenumbered = 0;
        private static int _linesWritten = 0;

        public static void Main(string[] args)
        {
            // Read the application settings
            var settings = new ConfigReader<RenumberAppSettings>().Read("appsettings.json");

            // Get the version number and application title
            Assembly assembly = Assembly.GetExecutingAssembly();
            FileVersionInfo info = FileVersionInfo.GetVersionInfo(assembly.Location);
            var title = $"BASIC Renumbering Tool v{info.FileVersion}";

            // Log the startup messages
            Console.WriteLine($"{title}\n");
            Console.WriteLine($"In-place renumbering: {settings.InPlace}");
            Console.WriteLine($"Initial line number: {settings.StartAt}");
            Console.WriteLine($"Line number increment: {settings.IncrementBy}");
            
            // Check the user's provided the name of a file to renumber
            if (args.Length != 1)
            {
                Console.WriteLine("\nWarning: No file name provided\n");
                Console.WriteLine($"Usage: {AppDomain.CurrentDomain.FriendlyName} <filename>");
                return;
            }

            Console.WriteLine($"Input file: {args[0]}\n");

            try
            {
                // Read the program
                var reader = new ProgramReader<ProgramLine>();
                reader.LineRead += OnLineRead;
                Console.Write("Reading file: ");
                reader.ReadLines(args[0]);
                Console.WriteLine($"\n{_linesRead} lines read");

                // Renumber it
                var renumberer = new Renumberer<ProgramLine>(settings, reader.Lines);
                renumberer.LineRenumbered += OnLineRenumbered;
                Console.Write("\nRenumbering lines: ");
                renumberer.Renumber();
                Console.WriteLine($"\n{_linesRenumbered} lines renumbered");
        
                // Write the renumbered program
                var writer = new ProgramWriter<ProgramLine>(settings);
                writer.LineWritten += OnLineWritten;
                Console.Write("\nWriting file: ");
                writer.WriteLines(renumberer.Lines, args[0]);
                Console.WriteLine($"\n{_linesWritten} lines written");
            }
            catch (Exception ex)
            {      
                Console.WriteLine($"\nError: {ex.Message}");
            }
        }
        
        /// <summary>
        /// Handler for the "line read" event
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private static void OnLineRead(object sender, LineReadEventArgs e)
        {
            _linesRead = e.Count;
            Console.Write(".");
        }
 
        /// <summary>
        /// Handler for the "line renumbered" event
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private static void OnLineRenumbered(object sender, LineRenumberedEventArgs e)
        {
            _linesRenumbered = e.Count;
            Console.Write(".");
        }

        /// <summary>
        /// Handler for the "line written" event
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private static void OnLineWritten(object sender, LineWrittenEventArgs e)
        {
            _linesWritten = e.Count;
            Console.Write(".");
        }
    }
}
