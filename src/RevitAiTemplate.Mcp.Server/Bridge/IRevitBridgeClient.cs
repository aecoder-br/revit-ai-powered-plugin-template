using System.Threading;
using System.Threading.Tasks;
using RevitAiTemplate.RevitBridge;

namespace RevitAiTemplate.Mcp.Server.Bridge;

public interface IRevitBridgeClient
{
    Task<BridgeResponse> SendAsync(BridgeRequest request, CancellationToken cancellationToken);
}
