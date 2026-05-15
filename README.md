# Revit AI-Powered Plugin Template

Template profissional para plugins Revit multi-versão, com arquitetura limpa, WPF, ponte local MCP, gateway de IA e documentação agent-ready.

## Objetivo

Este template foi desenhado para ser um ponto de partida seguro para add-ins profissionais do Revit 2024, 2025, 2026 e 2027.

Ele separa:

- domínio e casos de uso sem dependência de Revit API;
- camada Revit API versionada;
- UI WPF/WebView2 desacoplada;
- bridge local para MCP;
- gateway de IA fora do processo do Revit;
- documentação e instruções para agentes de IA.

## Estratégia multi-versão

| Revit | Runtime recomendado | Build do add-in |
|---|---:|---|
| 2024 | .NET Framework 4.8 | `-p:RevitVersion=2024` |
| 2025 | .NET 8 Windows | `-p:RevitVersion=2025` |
| 2026 | .NET 8 Windows | `-p:RevitVersion=2026` |
| 2027 | .NET 10 Windows | `-p:RevitVersion=2027` |

Não use um único binário para todas as versões. Gere um binário por versão e mantenha domínio, application services, DTOs e contratos compartilhados.

## Requisitos

- Windows 10/11.
- Visual Studio 2022 ou superior, com workload .NET desktop.
- Revit instalado para cada versão que você deseja compilar/testar.
- .NET SDK 8 para Revit 2025/2026.
- .NET SDK 10 para Revit 2027, MCP server e AI Gateway.
- .NET Framework 4.8 Developer Pack para Revit 2024.

## Build

```powershell
# Build de uma versão específica
./scripts/build.ps1 -RevitVersion 2024
./scripts/build.ps1 -RevitVersion 2025
./scripts/build.ps1 -RevitVersion 2026
./scripts/build.ps1 -RevitVersion 2027

# Build de todas as versões instaladas
./scripts/build.ps1 -RevitVersion all
```

## Instalação em modo desenvolvimento

```powershell
./scripts/dev-install.ps1 -RevitVersion 2026
```

Esse script compila a versão escolhida e grava um `.addin` em:

```txt
%APPDATA%\Autodesk\Revit\Addins\<ano>
```

## Abrindo o plugin

1. Instale em modo desenvolvimento.
2. Abra o Revit da versão correspondente.
3. Procure a aba `AI Template`.
4. Clique em `Assistant`.

## MCP local

Este template inclui um MCP server externo em:

```txt
src/RevitAiTemplate.Mcp.Server
```

Fluxo:

```txt
Claude/Cursor/Copilot Agent
        ↓ MCP stdio
RevitAiTemplate.Mcp.Server
        ↓ named pipe local
RevitAiTemplate.Revit add-in
        ↓ ExternalEvent
Revit API válida no thread/contexto do Revit
```

O MCP server só deve executar ferramentas que você declarou e testou. Comece com ferramentas read-only.

## IA em runtime

O add-in não chama OpenAI/Anthropic/Azure diretamente por padrão. Ele chama um AI Gateway local/remoto:

```txt
src/RevitAiTemplate.AiGateway
```

Motivos:

- evita chaves de API dentro do Revit;
- reduz conflitos de dependência no processo do Revit;
- permite rate limit, auditoria, policy e fallback;
- facilita trocar provedores de IA.

Configure:

```powershell
$env:REVIT_AI_GATEWAY_URL = "http://localhost:5088"
```

Rode:

```powershell
dotnet run --project src/RevitAiTemplate.AiGateway/RevitAiTemplate.AiGateway.csproj
```

## Estrutura

```txt
src/
  RevitAiTemplate.Core/              Domínio, DTOs e portas
  RevitAiTemplate.Application/       Casos de uso
  RevitAiTemplate.Infrastructure/    AI Gateway client, logging, configurações
  RevitAiTemplate.Ui.Wpf/            UI WPF/MVVM sem Revit API
  RevitAiTemplate.Revit/             Host Revit, ExternalApplication, ExternalCommand, adapters
  RevitAiTemplate.RevitBridge/       Contratos da ponte local entre MCP e Revit
  RevitAiTemplate.Mcp.Server/        MCP server local via stdio
  RevitAiTemplate.AiGateway/         Gateway de IA opcional

tests/
  RevitAiTemplate.Application.Tests/

docs/
  architecture/
  adr/
  ai/
  domain/
  security/
  testing/
```

## Próximos passos para transformar em produto

1. Troque nomes, GUIDs, VendorId e namespaces.
2. Defina ferramentas MCP read-only e write separadamente.
3. Adicione testes com fixtures reais.
4. Crie instalador por versão.
5. Assine binários.
6. Habilite CI, secret scanning, dependency scanning e branch protection.
7. Publique documentação de suporte, versão, changelog e política de dados/IA.
