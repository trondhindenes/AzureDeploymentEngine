function Write-enhancedVerbose
{
    Param (
    [int]$MinimumVerboseLevel,

    [Parameter(Position=0)]
    [string]$Message

    )
    
    if ($verboselevel -ge $MinimumVerboseLevel)
    {
        Write-verbose -Message $Message
    }

}
