using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using RevitAiTemplate.Mcp.Server.Bridge;
using RevitAiTemplate.RevitBridge;

namespace RevitAiTemplate.Mcp.Server.Tools;

[McpServerToolType]
public sealed class RevitReadTools
{
    private readonly IRevitBridgeClient _bridgeClient;

    public RevitReadTools(IRevitBridgeClient bridgeClient)
    {
        _bridgeClient = bridgeClient;
    }

    [McpServerTool]
    [Description("Read-only. Returns a summary of the active Revit document through the local Revit add-in bridge. Requires Revit to be running with the add-in loaded.")]
    public async Task<string> GetActiveModelSummary(CancellationToken cancellationToken = default)
    {
        var response = await _bridgeClient.SendAsync(new BridgeRequest
        {
            ToolName = BridgeToolNames.GetActiveModelSummary,
            ArgumentsJson = "{}"
        }, cancellationToken).ConfigureAwait(false);

        if (!response.Success)
        {
            return "Revit bridge error: " + response.Error;
        }

        using var document = JsonDocument.Parse(response.PayloadJson);
        return JsonSerializer.Serialize(document.RootElement, new JsonSerializerOptions { WriteIndented = true });
    }
}
