namespace RevitAiTemplate.Infrastructure.Ai;

public sealed class AiGatewayOptions
{
    public string? BaseUrl { get; set; }

    public static AiGatewayOptions FromEnvironment()
    {
        return new AiGatewayOptions
        {
            BaseUrl = System.Environment.GetEnvironmentVariable("REVIT_AI_GATEWAY_URL")
        };
    }
}
