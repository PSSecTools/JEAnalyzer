using System;
using System.Collections;
using System.Collections.Generic;
using System.Management.Automation;

namespace JEAnalyzer
{
    /// <summary>
    /// A command to allow to the user
    /// </summary>
    [Serializable]
    public class CapabilityCommand : Capability
    {
        /// <summary>
        /// The type of the capability
        /// </summary>
        public override CapabilityType Type
        {
            get { return CapabilityType.Command; }
            set { }
        }

        /// <summary>
        /// The kind of command this is.
        /// </summary>
        public CommandTypes CommandType;

        /// <summary>
        /// Parameter constraints to apply to the command.
        /// </summary>
        public Dictionary<string, Parameter> Parameters = new Dictionary<string, Parameter>(StringComparer.InvariantCultureIgnoreCase);

        /// <summary>
        /// Converts this capability into a hashtable needed for the export to a role capability file.
        /// </summary>
        /// <param name="ModuleName"></param>
        /// <returns></returns>
        public override Hashtable ToHashtable(string ModuleName)
        {
            Hashtable result = new Hashtable(StringComparer.InvariantCultureIgnoreCase);

            result["Name"] = Name;
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
