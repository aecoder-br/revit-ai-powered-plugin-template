using System;
using System.IO;
using System.IO.Pipes;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using RevitAiTemplate.RevitBridge;

namespace RevitAiTemplate.Mcp.Server.Bridge;

public sealed class NamedPipeRevitBridgeClient : IRevitBridgeClient
{
    private const string PipeName = "RevitAiTemplate.Bridge";

    public async Task<BridgeResponse> SendAsync(BridgeRequest request, CancellationToken cancellationToken)
    {
        using var pipe = new NamedPipeClientStream(".", PipeName, PipeDirection.InOut, PipeOptions.Asynchronous);
        await pipe.ConnectAsync(5000, cancellationToken).ConfigureAwait(false);

        using var reader = new StreamReader(pipe, Encoding.UTF8);
        using var writer = new StreamWriter(pipe, Encoding.UTF8) { AutoFlush = true };

        await writer.WriteLineAsync(BridgeSerializer.Serialize(request)).ConfigureAwait(false);
        var responseLine = await reader.ReadLineAsync().ConfigureAwait(false);
        if (string.IsNullOrWhiteSpace(responseLine))
        {
            return BridgeSerializer.Fail("No response from Revit bridge.");
        }

        return BridgeSerializer.Deserialize<BridgeResponse>(responseLine) ?? BridgeSerializer.Fail("Invalid response from Revit bridge.");
    }
}
