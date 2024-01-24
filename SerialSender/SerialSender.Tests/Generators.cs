namespace SerialSender.Tests
{
    internal static class Generators
    {
        /// <summary>
        /// Generate a random alphanumeric string of the specified length
        /// </summary>
        /// <param name="length"></param>
        /// <returns></returns>
        public static string GenerateRandomAlphanumericString(int length)
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            var random = new Random();
            return new string(Enumerable.Repeat(chars, length).Select(s => s[random.Next(s.Length)]).ToArray());
        }

        /// <summary>
        /// Generate a list of random alphanumeric strings of the specified length
        /// </summary>
        /// <param name="count"></param>
        /// <param name="length"></param>
        /// <returns></returns>
        public static List<string> GenerateRandomAlphanumericStrings(int count, int length)
        {
            var strings = new List<string>();

            for (var i = 0; i < count; i++)
            {
                strings.Add(GenerateRandomAlphanumericString(length));
            }

            return strings;
        }
    }
}
