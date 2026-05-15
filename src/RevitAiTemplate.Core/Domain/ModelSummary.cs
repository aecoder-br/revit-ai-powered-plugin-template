using System.Collections.Generic;

namespace RevitAiTemplate.Core.Domain;

public sealed class ModelSummary
{
    public ModelSummary(
        string title,
        string? pathName,
        string revitVersion,
        int totalElementCount,
        IReadOnlyList<ElementCategoryCount> categoryCounts)
    {
        Title = title;
        PathName = pathName;
        RevitVersion = revitVersion;
        TotalElementCount = totalElementCount;
        CategoryCounts = categoryCounts;
    }

    public string Title { get; }

    public string? PathName { get; }

    public string RevitVersion { get; }

    public int TotalElementCount { get; }

    public IReadOnlyList<ElementCategoryCount> CategoryCounts { get; }
}
