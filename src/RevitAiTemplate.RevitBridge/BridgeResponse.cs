namespace RevitAiTemplate.RevitBridge;

public sealed class BridgeResponse
{
    public bool Success { get; set; }

    public string? Error { get; set; }

    public string PayloadJson { get; set; } = "{}";
}
