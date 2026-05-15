using System.Threading;
using System.Threading.Tasks;
using RevitAiTemplate.Core.Domain;
using RevitAiTemplate.Core.Ports;
using RevitAiTemplate.Revit.ExternalEvents;

namespace RevitAiTemplate.Revit.Services;

public sealed class ExternalEventModelContextReader : IModelContextReader
{
    private readonly RevitRequestQueue _queue;

    public ExternalEventModelContextReader(RevitRequestQueue queue)
    {
        _queue = queue;
    }

    public Task<ModelSummary> ReadActiveModelSummaryAsync(CancellationToken cancellationToken)
    {
        return _queue.EnqueueAsync(uiapp => new RevitModelQueryService(uiapp).ReadActiveModelSummary(), cancellationToken);
    }
}
