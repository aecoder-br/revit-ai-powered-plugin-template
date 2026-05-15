using System.Collections.Generic;
using System.Linq;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using RevitAiTemplate.Core.Domain;

namespace RevitAiTemplate.Revit.Services;

public sealed class RevitModelQueryService
{
    private readonly UIApplication _uiApplication;

    public RevitModelQueryService(UIApplication uiApplication)
    {
        _uiApplication = uiApplication;
    }

    public ModelSummary ReadActiveModelSummary()
    {
        var document = _uiApplication.ActiveUIDocument?.Document;
        if (document == null)
        {
            return new ModelSummary("No active document", null, _uiApplication.Application.VersionNumber, 0, new List<ElementCategoryCount>());
        }

        var elements = new FilteredElementCollector(document)
            .WhereElementIsNotElementType()
            .ToElements();

        var categoryCounts = elements
            .Where(element => element.Category != null)
            .GroupBy(element => element.Category.Name)
            .OrderByDescending(group => group.Count())
            .ThenBy(group => group.Key)
            .Take(20)
            .Select(group => new ElementCategoryCount(group.Key, group.Count()))
            .ToList();

        return new ModelSummary(
            document.Title,
            string.IsNullOrWhiteSpace(document.PathName) ? null : document.PathName,
            _uiApplication.Application.VersionNumber,
            elements.Count,
            categoryCounts);
    }
}
