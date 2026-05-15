var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/health", () => Results.Ok(new { status = "ok" }));

app.MapPost("/v1/analyze-model", async (HttpRequest request) =>
{
    // Production implementation belongs here:
    // - authenticate caller;
    // - authorize tenant/user/project;
    // - redact sensitive model data;
    // - route to OpenAI/Azure OpenAI/Anthropic/local model;
    // - audit policy decision, token usage and cost;
    // - never log raw secrets or sensitive model payloads.
    using var reader = new StreamReader(request.Body);
    var body = await reader.ReadToEndAsync();

    return Results.Text("AI Gateway stub response. Received structured model context with " + body.Length + " characters.");
});

app.Run();
