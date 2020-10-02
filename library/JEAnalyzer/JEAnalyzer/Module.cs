using System;
using System.Collections.Generic;
using System.Management.Automation;

namespace JEAnalyzer
{
    /// <summary>
    /// A Jea Module package, to be export as powershell module and packaged to the target system.
    /// </summary>
    [Serializable]
    public class Module
    {
        /// <summary>
        /// The name of the module
        /// </summary>
        public string Name;

        /// <summary>
        /// A suitable description
        /// </summary>
        public string Description;

        /// <summary>
        /// THe version of the module
        /// </summary>
        public Version Version;

        /// <summary>
        /// The author of the module
        /// </summary>
        public string Author;

        /// <summary>
        /// The company the module is deployed by
        /// </summary>
        public string Company;

        /// <summary>
        /// Modules required for this module
        /// </summary>
        public object RequiredModules;

        /// <summary>
        /// The roles contained in the module
        /// </summary>
        public Dictionary<string, Role> Roles = new Dictionary<string, Role>(StringComparer.InvariantCultureIgnoreCase);

        /// <summary>
        /// Script code the module will execute before loading functions
        /// </summary>
        public Dictionary<string, ScriptFile> PreimportScripts = new Dictionary<string, ScriptFile>(StringComparer.InvariantCultureIgnoreCase);

        /// <summary>
        /// Script code the module will execute after loading functions
        /// </summary>
        public Dictionary<string, ScriptFile> PostimportScripts = new Dictionary<string, ScriptFile>(StringComparer.InvariantCultureIgnoreCase);

        /// <summary>
        /// Functions the module contains but are not published
        /// </summary>
        public Dictionary<string, FunctionInfo> PrivateFunctions = new Dictionary<string, FunctionInfo>(StringComparer.InvariantCultureIgnoreCase);

        /// <summary>
        /// Functions the module contains and publishes.
        /// </summary>
        public Dictionary<string, FunctionInfo> PublicFunctions = new Dictionary<string, FunctionInfo>(StringComparer.InvariantCultureIgnoreCase);
    }
}
