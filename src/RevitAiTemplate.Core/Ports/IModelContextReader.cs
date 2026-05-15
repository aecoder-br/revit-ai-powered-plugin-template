using System.Threading;
using System.Threading.Tasks;
using RevitAiTemplate.Core.Domain;

namespace RevitAiTemplate.Core.Ports;

public interface IModelContextReader
{
    Task<ModelSummary> ReadActiveModelSummaryAsync(CancellationToken cancellationToken);
}
