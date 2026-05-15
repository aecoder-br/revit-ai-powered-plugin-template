using System.Windows;

namespace RevitAiTemplate.Ui.Wpf;

public partial class MainWindow : Window
{
    public MainWindow(object viewModel)
    {
        InitializeComponent();
        DataContext = viewModel;
    }
}
