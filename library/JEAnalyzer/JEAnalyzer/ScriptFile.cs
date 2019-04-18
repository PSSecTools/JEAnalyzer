using System;
using System.Collections.Generic;
using System.Linq;
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
    }
}
