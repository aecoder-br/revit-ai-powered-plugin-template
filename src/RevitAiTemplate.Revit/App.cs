using Autodesk.Revit.UI;
using RevitAiTemplate.Revit.Bootstrap;
using RevitAiTemplate.Revit.Commands;

namespace RevitAiTemplate.Revit;

public sealed class App : IExternalApplication
{
    private const string TabName = "AI Template";
    private NamedPipeBridgeServer? _bridgeServer;

    public Result OnStartup(UIControlledApplication application)
    {
        RevitServiceLocator.Initialize();
        CreateRibbon(application);

        _bridgeServer = new NamedPipeBridgeServer(RevitServiceLocator.RequestQueue);
        _bridgeServer.Start();

        return Result.Succeeded;
    }

    public Result OnShutdown(UIControlledApplication application)
    {
        _bridgeServer?.Dispose();
        RevitServiceLocator.Shutdown();
        return Result.Succeeded;
    }

    private static void CreateRibbon(UIControlledApplication application)
    {
        try
        {
            application.CreateRibbonTab(TabName);
        }
        catch
        {
            // Tab already exists.
        }

        var panel = application.CreateRibbonPanel(TabName, "Assistant");
        var assemblyPath = typeof(App).Assembly.Location;
        var buttonData = new PushButtonData(
            "RevitAiTemplate.OpenAssistant",
            "Assistant",
            assemblyPath,
            typeof(OpenAssistantCommand).FullName);

        buttonData.ToolTip = "Open the AI-powered Revit assistant.";
        panel.AddItem(buttonData);
    }
}
