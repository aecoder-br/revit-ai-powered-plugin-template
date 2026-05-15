namespace RevitAiTemplate.Core.Domain;

public sealed class ElementCategoryCount
{
    public ElementCategoryCount(string categoryName, int count)
    {
        CategoryName = categoryName;
        Count = count;
    }

    public string CategoryName { get; }

    public int Count { get; }
}
