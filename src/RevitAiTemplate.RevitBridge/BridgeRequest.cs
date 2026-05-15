namespace RevitAiTemplate.RevitBridge;

public sealed class BridgeRequest
{
    public string ToolName { get; set; } = string.Empty;

    public string ArgumentsJson { get; set; } = "{}";
}
