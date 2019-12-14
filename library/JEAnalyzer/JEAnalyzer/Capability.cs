using System;
using System.Collections;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace JEAnalyzer
{
    /// <summary>
    /// Base class for capabilities
    /// </summary>
    [Serializable]
    public abstract class Capability
    {
        /// <summary>
        /// The type of the capability. The set should do nothing, the get always return a static return.
        /// </summary>
        public abstract CapabilityType Type { get; set; }

        /// <summary>
        /// The name of the capability
        /// </summary>
        public string Name;

        /// <summary>
        /// Return a hashtable representation for use in a Role Capability File
        /// </summary>
        /// <param name="ModuleName"></param>
        /// <returns></returns>
        public abstract Hashtable ToHashtable(string ModuleName);
    }
}
