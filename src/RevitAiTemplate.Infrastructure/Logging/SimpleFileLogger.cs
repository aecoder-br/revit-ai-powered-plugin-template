using System;
using System.IO;

namespace RevitAiTemplate.Infrastructure.Logging;

public sealed class SimpleFileLogger
{
    private readonly string _logFilePath;

    public SimpleFileLogger(string logFilePath)
    {
        _logFilePath = logFilePath;
    }

    public void Info(string message)
    {
        Write("INFO", message);
    }

    public void Error(string message, Exception? exception = null)
    {
        Write("ERROR", exception == null ? message : message + Environment.NewLine + exception);
    }

    private void Write(string level, string message)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(_logFilePath)!);
        File.AppendAllText(_logFilePath, $"{DateTimeOffset.Now:u} [{level}] {message}{Environment.NewLine}");
    }
}
