using System;
using System.Collections.Generic;
using System.Management.Automation;

namespace JEAnalyzer
{
    /// <summary>
    /// Information on a given PowerShell command
    /// </summary>
    [Serializable]
    public class CommandInfo
    {
        /// <summary>
        /// The name of the command
        /// </summary>
        public string CommandName;

        /// <summary>
        /// The full command object
        /// </summary>
        public System.Management.Automation.CommandInfo CommandObject;

        /// <summary>
        /// The file the command invocation was read from
        /// </summary>
        public string File;

        /// <summary>
        /// Whether the command is an alias
        /// </summary>
        public bool IsAlias
        {
            get { return CommandObject.CommandType == CommandTypes.Alias; }
            set { }
        }

        /// <summary>
        /// The name of the module the command comes from
        /// </summary>
        public string ModuleName
        {
            get { return CommandObject.ModuleName; }
            set { }
        }
    }
}
