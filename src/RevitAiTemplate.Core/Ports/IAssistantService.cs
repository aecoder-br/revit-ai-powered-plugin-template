using System.Threading;
using System.Threading.Tasks;
using RevitAiTemplate.Core.Domain;

namespace RevitAiTemplate.Core.Ports;

public interface IAssistantService
{
    Task<string> AnalyzeModelAsync(ModelSummary summary, string userPrompt, CancellationToken cancellationToken);
}
