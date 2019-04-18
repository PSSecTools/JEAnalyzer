using System;
using System.Collections;
using System.Collections.Generic;
using System.Management.Automation;

namespace JEAnalyzer
{
    /// <summary>
    /// A capability born of a script file.
    /// The file is stored as a function.
    /// </summary>
    [Serializable]
    public class CapabilityScript : Capability
    {
        /// <summary>
        /// The type of the capability
        /// </summary>
        public override CapabilityType Type
        {
            get { return CapabilityType.Script; }
            set { }
        }

        /// <summary>
        /// The actual function Definition
        /// </summary>
        public FunctionInfo Content;

        /// <summary>
        /// Parameter constraints to apply to the command.
        /// </summary>
        public Dictionary<string, Parameter> Parameters = new Dictionary<string, Parameter>(StringComparer.InvariantCultureIgnoreCase);

        /// <summary>
        /// Converts this capability into a hashtable needed for the export to a role capability file.
        /// </summary>
        /// <returns></returns>
        public override Hashtable ToHashtable(string ModuleName)
        {
            Hashtable result = new Hashtable(StringComparer.InvariantCultureIgnoreCase);

            result["Name"] = String.Format("{0}\\{1}", ModuleName, Name);
            if (Parameters.Count == 0)
                return result;
            List<Hashtable> parameters = new List<Hashtable>();
            foreach (Parameter param in Parameters.Values)
                parameters.Add(param.ToHashtable());
            result["Parameters"] = parameters.ToArray();

            return result;
        }
    }
}
