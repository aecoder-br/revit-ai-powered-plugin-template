using System;
using System.Collections.Concurrent;
using System.Threading;
using System.Threading.Tasks;
using Autodesk.Revit.UI;

namespace RevitAiTemplate.Revit.ExternalEvents;

public sealed class RevitRequestQueue : IExternalEventHandler, IDisposable
{
    private readonly ConcurrentQueue<IRevitRequest> _requests = new ConcurrentQueue<IRevitRequest>();
    private ExternalEvent? _externalEvent;
    private bool _disposed;

    private RevitRequestQueue()
    {
    }

    public static RevitRequestQueue Create()
    {
        var queue = new RevitRequestQueue();
        queue._externalEvent = ExternalEvent.Create(queue);
        return queue;
    }

    public Task<T> EnqueueAsync<T>(Func<UIApplication, T> action, CancellationToken cancellationToken)
    {
        if (_disposed)
        {
            throw new ObjectDisposedException(nameof(RevitRequestQueue));
        }

        var request = new RevitRequest<T>(action, cancellationToken);
        _requests.Enqueue(request);
        _externalEvent?.Raise();
        return request.Task;
    }

    public void Execute(UIApplication app)
    {
        while (_requests.TryDequeue(out var request))
        {
            request.Execute(app);
        }
    }

    public string GetName()
    {
        return "Revit AI Template External Event Queue";
    }

    public void Dispose()
    {
        _disposed = true;
        _externalEvent?.Dispose();
        _externalEvent = null;
    }

    private interface IRevitRequest
    {
        void Execute(UIApplication app);
    }

    private sealed class RevitRequest<T> : IRevitRequest
    {
        private readonly Func<UIApplication, T> _action;
        private readonly CancellationToken _cancellationToken;
        private readonly TaskCompletionSource<T> _taskCompletionSource = new TaskCompletionSource<T>();

        public RevitRequest(Func<UIApplication, T> action, CancellationToken cancellationToken)
        {
            _action = action;
            _cancellationToken = cancellationToken;
        }

        public Task<T> Task => _taskCompletionSource.Task;

        public void Execute(UIApplication app)
        {
            if (_cancellationToken.IsCancellationRequested)
            {
                _taskCompletionSource.TrySetCanceled();
                return;
            }

            try
            {
                _taskCompletionSource.TrySetResult(_action(app));
            }
            catch (Exception ex)
            {
                _taskCompletionSource.TrySetException(ex);
            }
        }
    }
}
