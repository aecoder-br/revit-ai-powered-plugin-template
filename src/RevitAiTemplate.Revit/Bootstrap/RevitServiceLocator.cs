using System;
using Autodesk.Revit.UI;
using RevitAiTemplate.Application.UseCases;
using RevitAiTemplate.Infrastructure.Ai;
using RevitAiTemplate.Revit.ExternalEvents;
using RevitAiTemplate.Revit.Services;
using RevitAiTemplate.Ui.Wpf;
using RevitAiTemplate.Ui.Wpf.ViewModels;

namespace RevitAiTemplate.Revit.Bootstrap;

public static class RevitServiceLocator
{
    private static MainWindow? _assistantWindow;

    public static RevitRequestQueue RequestQueue { get; private set; } = null!;

    public static void Initialize()
    {
        RequestQueue = RevitRequestQueue.Create();
    }

    public static void Shutdown()
    {
        _assistantWindow?.Close();
        _assistantWindow = null;
        RequestQueue.Dispose();
    }

    public static void ShowAssistant(UIApplication uiApplication)
    {
        if (_assistantWindow != null)
        {
            _assistantWindow.Activate();
            return;
        }

        var modelReader = new ExternalEventModelContextReader(RequestQueue);
        var assistant = new HttpAiAssistantService(AiGatewayOptions.FromEnvironment());
        var useCase = new AnalyzeActiveModelUseCase(modelReader, assistant);
        var viewModel = new MainViewModel(useCase);
        _assistantWindow = new MainWindow(viewModel);
        _assistantWindow.Closed += (_, _) => _assistantWindow = null;
        _assistantWindow.Show();
    }
}
