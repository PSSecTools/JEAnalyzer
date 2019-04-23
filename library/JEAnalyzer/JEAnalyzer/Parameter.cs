using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

using PSFramework.Localization;

namespace JEAnalyzer
{
    /// <summary>
    /// Represents a parameter constraint on a JEA capability's command
    /// </summary>
    [Serializable]
    public class Parameter
    {
        /// <summary>
        /// The name of the parameter to permit.
        /// </summary>
        public string Name;

        /// <summary>
        /// The set of valid values for the parameter.
        /// </summary>
        public string[] ValidateSet;

        /// <summary>
        /// A pattern input to this parameter must match.
        /// </summary>
        public string ValidatePattern;

        /// <summary>
        /// Creates an empty parameter (used for serialization)
        /// </summary>
        public Parameter()
        {

        }

        /// <summary>
        /// Creates a parameter without value constraints
        /// </summary>
        /// <param name="Name">Name of the parameter</param>
        public Parameter(string Name)
        {
            this.Name = Name;
        }

        /// <summary>
        /// Creates a parameter with value constraints
        /// </summary>
        /// <param name="Name">Name of the parameter</param>
        /// <param name="ValidateSet">A set of legal values for the parameter</param>
        /// <param name="ValidatePattern">A regex pattern input must match.</param>
        public Parameter(string Name, string[] ValidateSet, string ValidatePattern)
        {
            this.Name = Name;
            this.ValidateSet = ValidateSet;
            this.ValidatePattern = ValidatePattern;
        }

        /// <summary>
        /// Parses out a parameter from an input hashtable
        /// </summary>
        /// <param name="Table">The hashtable to interpret as parameter</param>
        public Parameter(Hashtable Table)
        {
            if (!Table.ContainsKey("Name") || Table["Name"] == null)
                throw new ArgumentException(LocalizationHost.Read("JEAnalyzer.Assembly.Parameter.MissingName"));

            Name = (string)Table["Name"].ToString();

            if (Table.ContainsKey("ValidateSet"))
                ValidateSet = ((object[])Table["ValidateSet"]).Cast<string>().ToArray();
            if (Table.ContainsKey("ValidatePattern"))
                ValidatePattern = (string)Table["ValidatePattern"];
        }

        /// <summary>
        /// Returns the hashtable needed for the role capability file
        /// </summary>
        /// <returns>A hashtable</returns>
        public Hashtable ToHashtable()
        {
            Hashtable result = new Hashtable(StringComparer.InvariantCultureIgnoreCase);

            result["Name"] = Name;
            if (!String.IsNullOrEmpty(ValidatePattern))
                result["ValidatePattern"] = ValidatePattern;
            else if (ValidateSet != null)
                result["ValidateSet"] = ValidateSet;

            return result;
        }
    }
}
