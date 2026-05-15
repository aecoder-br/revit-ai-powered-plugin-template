using System;
using System.IO;
using System.IO.Pipes;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using RevitAiTemplate.Revit.ExternalEvents;
using RevitAiTemplate.Revit.Services;
using RevitAiTemplate.RevitBridge;

namespace RevitAiTemplate.Revit;

public sealed class NamedPipeBridgeServer : IDisposable
{
    public const string PipeName = "RevitAiTemplate.Bridge";

    private readonly RevitRequestQueue _requestQueue;
    private readonly CancellationTokenSource _cancellationTokenSource = new CancellationTokenSource();
    private Task? _serverTask;

    public NamedPipeBridgeServer(RevitRequestQueue requestQueue)
    {
        _requestQueue = requestQueue;
    }

    public void Start()
    {
        _serverTask = Task.Run(ServerLoop);
    }

    public void Dispose()
    {
        _cancellationTokenSource.Cancel();
        TryUnblockPipe();
        try { _serverTask?.Wait(TimeSpan.FromSeconds(2)); } catch { }
        _cancellationTokenSource.Dispose();
    }

    private void ServerLoop()
    {
        while (!_cancellationTokenSource.IsCancellationRequested)
        {
            try
            {
                using var pipe = new NamedPipeServerStream(PipeName, PipeDirection.InOut, 1, PipeTransmissionMode.Byte, PipeOptions.None);
                pipe.WaitForConnection();

                using var reader = new StreamReader(pipe, Encoding.UTF8);
                using var writer = new StreamWriter(pipe, Encoding.UTF8) { AutoFlush = true };

                var line = reader.ReadLine();
                if (string.IsNullOrWhiteSpace(line))
                {
                    continue;
                }

                var response = Handle(line);
                writer.WriteLine(BridgeSerializer.Serialize(response));
            }
            catch (Exception ex)
            {
                if (!_cancellationTokenSource.IsCancellationRequested)
                {
                    // Avoid writing to stdout/stderr from Revit. Add real logging in production.
                    _ = ex;
                }
            }
        }
    }

    private BridgeResponse Handle(string json)
    {
        var request = BridgeSerializer.Deserialize<BridgeRequest>(json);
        if (request == null || string.IsNullOrWhiteSpace(request.ToolName))
        {
            return BridgeSerializer.Fail("Invalid bridge request.");
        }

        if (request.ToolName == BridgeToolNames.GetActiveModelSummary)
        {
            var summary = _requestQueue
                .EnqueueAsync(uiapp => new RevitModelQueryService(uiapp).ReadActiveModelSummary(), CancellationToken.None)
                .GetAwaiter()
                .GetResult();

            return BridgeSerializer.Ok(summary);
        }

        return BridgeSerializer.Fail($"Unknown tool: {request.ToolName}");
    }

    private static void TryUnblockPipe()
    {
        try
        {
            using var client = new NamedPipeClientStream(".", PipeName, PipeDirection.InOut);
            client.Connect(100);
        }
        catch
        {
            // ignored
        }
    }
}
