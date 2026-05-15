using System;
using Autodesk.Revit.DB;

namespace RevitAiTemplate.Revit.Services;

public static class RevitTransactionRunner
{
    public static T Run<T>(Document document, string transactionName, Func<T> action)
    {
        using var transaction = new Transaction(document, transactionName);
        transaction.Start();

        try
        {
            var result = action();
            transaction.Commit();
            return result;
        }
        catch
        {
            if (transaction.HasStarted())
            {
                transaction.RollBack();
            }

            throw;
        }
    }
}
