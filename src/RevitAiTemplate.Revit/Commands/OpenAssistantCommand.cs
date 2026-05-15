using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using RevitAiTemplate.Revit.Bootstrap;

namespace RevitAiTemplate.Revit.Commands;

[Transaction(TransactionMode.Manual)]
public sealed class OpenAssistantCommand : IExternalCommand
{
    public Result Execute(ExternalCommandData commandData, ref string message, ElementSet elements)
    {
        RevitServiceLocator.ShowAssistant(commandData.Application);
        return Result.Succeeded;
    }
}
