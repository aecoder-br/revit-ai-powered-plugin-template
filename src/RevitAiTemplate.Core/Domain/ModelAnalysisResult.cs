namespace RevitAiTemplate.Core.Domain;

public sealed class ModelAnalysisResult
{
    public ModelAnalysisResult(ModelSummary summary, string assistantResponse)
    {
        Summary = summary;
        AssistantResponse = assistantResponse;
    }

    public ModelSummary Summary { get; }

    public string AssistantResponse { get; }
}
