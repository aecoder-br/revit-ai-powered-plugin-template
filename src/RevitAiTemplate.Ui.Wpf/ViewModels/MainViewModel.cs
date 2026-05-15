using System;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Input;
using RevitAiTemplate.Application.UseCases;

namespace RevitAiTemplate.Ui.Wpf.ViewModels;

public sealed class MainViewModel : ObservableObject
{
    private readonly AnalyzeActiveModelUseCase _analyzeActiveModelUseCase;
    private string _prompt = "Summarize the active model and suggest safe next checks.";
    private string _result = string.Empty;
    private string _status = "Ready";
    private bool _isBusy;

    public MainViewModel(AnalyzeActiveModelUseCase analyzeActiveModelUseCase)
    {
        _analyzeActiveModelUseCase = analyzeActiveModelUseCase ?? throw new ArgumentNullException(nameof(analyzeActiveModelUseCase));
        AnalyzeCommand = new RelayCommand(() => _ = AnalyzeAsync(), () => !IsBusy);
    }

    public string Prompt
    {
        get => _prompt;
        set => SetProperty(ref _prompt, value);
    }

    public string Result
    {
        get => _result;
        private set => SetProperty(ref _result, value);
    }

    public string Status
    {
        get => _status;
        private set => SetProperty(ref _status, value);
    }

    public bool IsBusy
    {
        get => _isBusy;
        private set
        {
            if (SetProperty(ref _isBusy, value) && AnalyzeCommand is RelayCommand relayCommand)
            {
                relayCommand.RaiseCanExecuteChanged();
            }
        }
    }

    public ICommand AnalyzeCommand { get; }

    private async Task AnalyzeAsync()
    {
        try
        {
            IsBusy = true;
            Status = "Analyzing...";
            var analysis = await _analyzeActiveModelUseCase.ExecuteAsync(Prompt, CancellationToken.None).ConfigureAwait(true);
            Result = analysis.AssistantResponse;
            Status = "Done";
        }
        catch (Exception ex)
        {
            Result = ex.ToString();
            Status = "Error";
        }
        finally
        {
            IsBusy = false;
        }
    }
}
