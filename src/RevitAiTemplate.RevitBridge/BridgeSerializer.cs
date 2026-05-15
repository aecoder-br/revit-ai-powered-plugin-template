using System.Text.Json;

namespace RevitAiTemplate.RevitBridge;

public static class BridgeSerializer
{
    private static readonly JsonSerializerOptions Options = new JsonSerializerOptions
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        WriteIndented = false
    };

    public static string Serialize<T>(T value)
    {
        return JsonSerializer.Serialize(value, Options);
    }

    public static T? Deserialize<T>(string json)
    {
        return JsonSerializer.Deserialize<T>(json, Options);
    }

    public static BridgeResponse Ok<T>(T payload)
    {
        return new BridgeResponse
        {
            Success = true,
            PayloadJson = Serialize(payload)
        };
    }

    public static BridgeResponse Fail(string error)
    {
        return new BridgeResponse
        {
            Success = false,
            Error = error,
            PayloadJson = "{}"
        };
    }
}
