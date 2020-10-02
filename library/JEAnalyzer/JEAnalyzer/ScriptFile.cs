using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Threading.Tasks;

namespace JEAnalyzer
{
    /// <summary>
    /// A scriptfile deployed with the JEA module
    /// </summary>
    [Serializable]
    public class ScriptFile
    {
        /// <summary>
        /// Name of the file
        /// </summary>
        public string Name;

        /// <summary>
        /// Content of the file
        /// </summary>
        public string Text;

        /// <summary>
        /// Create an empty file object
        /// </summary>
        public ScriptFile()
        {

        }

        /// <summary>
        /// Create a file object based on an existing file
        /// </summary>
        /// <param name="Path">Path to the file to load</param>
        public ScriptFile(string Path)
        {
            string resolvedPath = (new SessionState()).Path.GetResolvedPSPathFromPSPath(Path)[0].Path;
            Text = File.ReadAllText(resolvedPath);
            FileInfo tempInfo = new FileInfo(resolvedPath);
            Name = tempInfo.Name.Substring(0, tempInfo.Name.Length - tempInfo.Extension.Length);
        }

        /// <summary>
        /// Create a file object from provided values
        /// </summary>
        /// <param name="Name">Name of the file (should not include an extension)</param>
        /// <param name="Text">The text content of the file</param>
        public ScriptFile(string Name, string Text)
        {
            this.Name = Name;
            this.Text = Text;
        }
    }
}
