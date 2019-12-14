namespace JEAnalyzer
{
    /// <summary>
    /// List of supported capability types
    /// </summary>
    public enum CapabilityType
    {
        /// <summary>
        /// A cmdlet or function
        /// </summary>
        Command,

        /// <summary>
        /// An input script that should be deployed as part of the module.
        /// </summary>
        Script
    }
}
