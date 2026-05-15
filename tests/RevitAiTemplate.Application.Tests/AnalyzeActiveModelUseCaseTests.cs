using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using RevitAiTemplate.Application.UseCases;
using RevitAiTemplate.Core.Domain;
using RevitAiTemplate.Core.Ports;
using Xunit;

namespace RevitAiTemplate.Application.Tests;

public sealed class AnalyzeActiveModelUseCaseTests
{
    [Fact]
    public async Task ExecuteAsync_ReturnsAssistantResponse()
    {
        var summary = new ModelSummary(
            "Sample",
            null,
            "2027",
            10,
            new List<ElementCategoryCount> { new ElementCategoryCount("Walls", 4) });

        var useCase = new AnalyzeActiveModelUseCase(new FakeReader(summary), new FakeAssistant());
        var result = await useCase.ExecuteAsync("Check model", CancellationToken.None);

        Assert.Equal(summary, result.Summary);
        Assert.Contains("Sample", result.AssistantResponse);
    }

    private sealed class FakeReader : IModelContextReader
    {
        private readonly ModelSummary _summary;

        public FakeReader(ModelSummary summary)
        {
            _summary = summary;
        }

        public Task<ModelSummary> ReadActiveModelSummaryAsync(CancellationToken cancellationToken)
        {
            return Task.FromResult(_summary);
        }
    }

    private sealed class FakeAssistant : IAssistantService
    {
        public Task<string> AnalyzeModelAsync(ModelSummary summary, string userPrompt, CancellationToken cancellationToken)
        {
            return Task.FromResult($"Analyzed {summary.Title}: {userPrompt}");
        }
    }
}
