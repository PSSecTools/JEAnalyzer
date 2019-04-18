using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace JEAnalyzer
{
    /// <summary>
    /// A role in a JEA Module
    /// </summary>
    [Serializable]
    public class Role
    {
        /// <summary>
        /// The name of the role
        /// </summary>
        public string Name;

        /// <summary>
        /// The identity (user/group) being granted permission to the role.
        /// </summary>
        public string Identity;

        /// <summary>
        /// List of command capabilities
        /// </summary>
        public Dictionary<string, Capability> CommandCapability = new Dictionary<string, Capability>(StringComparer.InvariantCultureIgnoreCase);

        /// <summary>
        /// Creates an empty role. Used for serialization.
        /// </summary>
        public Role()
        {

        }

        /// <summary>
        /// Create a role pre-seeded with name and identity
        /// </summary>
        /// <param name="Name">The name of the role</param>
        /// <param name="Identity">The Identity to be granted access to the role.</param>
        public Role(string Name, string Identity)
        {
            this.Name = Name;
            this.Identity = Identity;
        }

        /// <summary>
        /// The list of Cmdlets that are part of the role.
        /// </summary>
        /// <returns></returns>
        public object[] VisibleCmdlets()
        {
            List<object> results = new List<object>();

            foreach (Capability cap in CommandCapability.Values)
                if ((cap.Type == CapabilityType.Command) && (((CapabilityCommand)cap).CommandType == System.Management.Automation.CommandTypes.Cmdlet))
                    results.Add(ConvertHashtable(cap.ToHashtable("")));

            return results.ToArray();
        }

        /// <summary>
        /// The list of Functions that are part of the role.
        /// </summary>
        /// <returns></returns>
        public object[] VisibleFunctions(string ModuleName)
        {
            List<object> results = new List<object>();

            foreach (Capability cap in CommandCapability.Values)
                if (((cap.Type == CapabilityType.Command) && (((CapabilityCommand)cap).CommandType == System.Management.Automation.CommandTypes.Function) || (cap.Type == CapabilityType.Script)))
                    results.Add(ConvertHashtable(cap.ToHashtable(ModuleName)));

            return results.ToArray();
        }

        /// <summary>
        /// Transcribes all function definitions to the specified module object.
        /// </summary>
        /// <param name="ModuleObject">The object to receive the function definitions</param>
        public void CopyFunctionDefinitions(Module ModuleObject)
        {
            foreach (Capability cap in CommandCapability.Values.Where(o => o.Type == CapabilityType.Script))
                ModuleObject.PublicFunctions[((CapabilityScript)cap).Content.Name] = ((CapabilityScript)cap).Content;
        }

        private object ConvertHashtable(Hashtable Table)
        {
            if (!Table.ContainsKey("Parameters"))
                return Table["Name"];
            return Table;
        }
    }
}
