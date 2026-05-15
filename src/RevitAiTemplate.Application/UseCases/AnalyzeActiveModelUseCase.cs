using System;
using System.Threading;
using System.Threading.Tasks;
using RevitAiTemplate.Core.Domain;
using RevitAiTemplate.Core.Ports;

namespace RevitAiTemplate.Application.UseCases;

public sealed class AnalyzeActiveModelUseCase
{
    private readonly IModelContextReader _modelContextReader;
    private readonly IAssistantService _assistantService;

    public AnalyzeActiveModelUseCase(IModelContextReader modelContextReader, IAssistantService assistantService)
    {
        _modelContextReader = modelContextReader ?? throw new ArgumentNullException(nameof(modelContextReader));
        _assistantService = assistantService ?? throw new ArgumentNullException(nameof(assistantService));
    }

    public async Task<ModelAnalysisResult> ExecuteAsync(string userPrompt, CancellationToken cancellationToken)
    {
        var summary = await _modelContextReader.ReadActiveModelSummaryAsync(cancellationToken).ConfigureAwait(false);
        var response = await _assistantService.AnalyzeModelAsync(summary, userPrompt, cancellationToken).ConfigureAwait(false);
        return new ModelAnalysisResult(summary, response);
    }
}
