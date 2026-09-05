using Moq;
using SerialSender.Entities.Interfaces;
using SerialSender.Entities.Reader;
using SerialSender.Logic.Reader;
using System.IO;

namespace SerialSender.Tests
{
    [TestClass]
    public class SourceFileReaderTest
    {
        [TestMethod]
        public void CanIdentifyBasicFileTest()
        {
            var mockFileWrapper = new Mock<IFileWrapper>();
            mockFileWrapper.Setup(f => f.ReadAllLines(It.IsAny<string>())).Returns(Array.Empty<string>());
            var reader = new SourceFileReader(mockFileWrapper.Object);
            reader.Read("basicprogram.bas");
            Assert.AreEqual(SourceFileType.Basic, reader.FileType);
        }

        [TestMethod]
        public void CanIdentifyAssemblyFileTest()
        {
            var mockFileWrapper = new Mock<IFileWrapper>();
            mockFileWrapper.Setup(f => f.ReadAllLines(It.IsAny<string>())).Returns(Array.Empty<string>());
            var reader = new SourceFileReader(mockFileWrapper.Object);
            reader.Read("assemblyprogram.asm");
            Assert.AreEqual(SourceFileType.Assembly, reader.FileType);
        }

        [TestMethod]
        public void CannotIdentifyOtherFileTypesTest()
        {
            var mockFileWrapper = new Mock<IFileWrapper>();
            mockFileWrapper.Setup(f => f.ReadAllLines(It.IsAny<string>())).Returns(Array.Empty<string>());
            var reader = new SourceFileReader(mockFileWrapper.Object);
            reader.Read("textfile.txt");
            Assert.AreEqual(SourceFileType.Unknown, reader.FileType);
        }

        [TestMethod]
        public void CanReadFileTest()
        {
            var reader = new SourceFileReader(new FileWrapper());
            reader.Read("HelloWorld.bas");
            
            var lines = File.ReadAllLines("HelloWorld.bas").ToList();
            Assert.AreEqual(lines.Count, reader.Lines.Count());

            var actualLines = reader.Lines.ToList();
            for (int i = 0; i < lines.Count; i++)
            {
                Assert.AreEqual(lines[i], actualLines[i]);
            }
        }

        [TestMethod]
        public void MissingFileThrowsExceptionTest()
        {
            var reader = new SourceFileReader(new FileWrapper());
            Assert.ThrowsExactly<FileNotFoundException>(() => reader.Read("NotThere.bas"));
        }

        [TestMethod]
        [DataRow("program.asm")]
        [DataRow("program.ASM")]
        public void AssemblyCommentAndBlankLinesAreOmittedTest(string path)
        {
            var mockFileWrapper = new Mock<IFileWrapper>();
            mockFileWrapper.Setup(f => f.ReadAllLines(path)).Returns(new[]
            {
                "; Instructions", " \t; Indented comment", ";", "A 8000",
                "LD C,6", "", "  ", "\t", " \t ", "\"Hello; Z80!", "RET ; inline", "<ESC>"
            });
            var reader = new SourceFileReader(mockFileWrapper.Object);

            reader.Read(path);

            CollectionAssert.AreEqual(new[]
            {
                "A 8000", "LD C,6", "\"Hello; Z80!", "RET ; inline", "\x1B"
            }, reader.Lines.ToArray());
        }

        [TestMethod]
        [DataRow("program.bas")]
        [DataRow("program.scm")]
        [DataRow("program.txt")]
        public void OtherFileTypesRetainCommentAndBlankLinesTest(string path)
        {
            var lines = new[] { "; Keep this", " \t; Keep this too", "", "  ", "\t", " \t " };
            var mockFileWrapper = new Mock<IFileWrapper>();
            mockFileWrapper.Setup(f => f.ReadAllLines(path)).Returns(lines);
            var reader = new SourceFileReader(mockFileWrapper.Object);

            reader.Read(path);

            CollectionAssert.AreEqual(lines, reader.Lines.ToArray());
        }

        [TestMethod]
        public void EscapePlaceHolderIsReplacedTest()
        {
            var mockFileWrapper = new Mock<IFileWrapper>();
            mockFileWrapper.Setup(f => f.ReadAllLines(It.IsAny<string>())).Returns(new string[] { "Hello<ESC>World" });
            var reader = new SourceFileReader(mockFileWrapper.Object);
            reader.Read("FileContainingEscapePlaceholder.scm");
            Assert.AreEqual("Hello\x1BWorld", reader.Lines.First());
        }
    }
}
