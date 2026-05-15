using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using RevitAiTemplate.Core.Domain;
using RevitAiTemplate.Core.Ports;

namespace RevitAiTemplate.Infrastructure.Ai;

public sealed class HttpAiAssistantService : IAssistantService, IDisposable
{
    private readonly AiGatewayOptions _options;
    private readonly HttpClient _httpClient;
    private readonly bool _ownsClient;

    public HttpAiAssistantService(AiGatewayOptions options)
        : this(options, new HttpClient(), ownsClient: true)
    {
    }

    public HttpAiAssistantService(AiGatewayOptions options, HttpClient httpClient, bool ownsClient = false)
    {
        _options = options ?? throw new ArgumentNullException(nameof(options));
        _httpClient = httpClient ?? throw new ArgumentNullException(nameof(httpClient));
        _ownsClient = ownsClient;
    }

    public async Task<string> AnalyzeModelAsync(ModelSummary summary, string userPrompt, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(_options.BaseUrl))
        {
            return BuildOfflineResponse(summary, userPrompt);
        }

        var payload = new
        {
            prompt = userPrompt,
            modelSummary = summary
        };

        var json = JsonSerializer.Serialize(payload);
        using var content = new StringContent(json, Encoding.UTF8, "application/json");
        using var response = await _httpClient.PostAsync(new Uri(new Uri(_options.BaseUrl), "/v1/analyze-model"), content, cancellationToken).ConfigureAwait(false);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadAsStringAsync().ConfigureAwait(false);
    }

    public void Dispose()
    {
        if (_ownsClient)
        {
            _httpClient.Dispose();
        }
    }

    private static string BuildOfflineResponse(ModelSummary summary, string userPrompt)
    {
        var builder = new StringBuilder();
        builder.AppendLine("AI Gateway is not configured. Returning deterministic local summary.");
        builder.AppendLine();
        builder.AppendLine($"Prompt: {userPrompt}");
        builder.AppendLine($"Model: {summary.Title}");
        builder.AppendLine($"Revit: {summary.RevitVersion}");
        builder.AppendLine($"Total elements: {summary.TotalElementCount}");
        builder.AppendLine("Top categories:");

        foreach (var item in summary.CategoryCounts)
        {
            builder.AppendLine($"- {item.CategoryName}: {item.Count}");
        }

        return builder.ToString();
    }
}
