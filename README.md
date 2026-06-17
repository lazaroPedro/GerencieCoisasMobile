# 🎨 Design Tokens e Tematização

Este projeto utiliza um sistema centralizado de **Design Tokens** para garantir consistência visual em toda a interface do aplicativo, suportando nativamente **Modo Claro** e **Modo Escuro**. 

Nossa estrutura divide os tokens primitivos de cor em duas classes (`AppColors` e `DarkAppColors`) e aplica a semântica através do `AppTheme`.

## 1. Paleta de Cores (Tokens Primitivos)

**Sempre utilize estas variáveis** em vez de colocar as cores diretamente (hardcode) no código. 

### Modo Claro (`AppColors`)
Localizado em: `lib/core/theme/app_colors.dart`

| Token (Variável) | Cor (Hex) | Aplicação |
| :--- | :--- | :--- |
| `primary` | `#FF9F43` | Cor principal (CTAs, botões). |
| `bodyBg` | `#F8F9FA` | Fundo principal do app. |
| `surface` | `#FFFFFF` | Fundo de cartões e modais. |
| `textPrimary` | `#333333` | Títulos principais. |
| `textSecondary`| `#555555` | Textos de corpo padrão. |
| `border` | `#EEEEEE` | Bordas e divisores. |
| `danger` | `#EA5455` | Erros e ações destrutivas. |

### Modo Escuro (`DarkAppColors`)
Localizado em: `lib/core/theme/dark_app_colors.dart`
No modo escuro, as cores de fundo e texto são invertidas 

| Token (Variável) | Cor (Hex) | Aplicação |
| :--- | :--- | :--- |
| `primary` | `#FF9F43` | Mantém a identidade da marca. |
| `bodyBg` | `#333333` | Fundo escuro principal. |
| `surface` | `#555555` | Fundo escuro de cartões e elementos elevados. |
| `textPrimary` | `#F8F9FA` | Títulos claros (contraste com fundo escuro). |
| `textSecondary`| `#FFFFFF` | Textos de corpo. |

---

## 2. Tema Base (`AppTheme`)
Localizado em: `lib/core/theme/app_theme.dart`

O `AppTheme` gerencia a transição entre os modos mapeando os tokens do `AppColors` e `DarkAppColors` para os componentes padrão do Flutter (Material 3).

**Como o Flutter sabe qual usar?**
Configuramos dois temas distintos no `AppTheme`:
*   `AppTheme.lightTheme`: Mapeia a classe `AppColors`.
*   `AppTheme.darkTheme`: Mapeia a classe `DarkAppColors`.

Na raiz do aplicativo (`MaterialApp`), basta passar essas configurações para que o app alterne automaticamente com base na preferência do sistema do usuário:

```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme, 
  themeMode: ThemeMode.system,
)
```

---

## 3. Relatório de Acessibilidade

O aplicativo implementa recursos de acessibilidade para melhorar o uso com leitores de tela, contraste visual e navegação assistida.

Recursos implementados:
* **TalkBack/leitores de tela:** uso de `Semantics`, `semanticLabel` e `liveRegion` em carregamento, listas, cards, detalhes, categorias, movimentações, produtos e leitor de código de barras.
* **Anúncios acessíveis:** mensagens de sucesso, erro e validação no login, cadastro e obtenção de localização com `SemanticsService.sendAnnouncement`.
* **Formulários acessíveis:** campos com `label` e `hint` em login, cadastro, produtos e movimentações.
* **Botões e ações:** `tooltip` em botões de ícone, como editar, excluir, limpar busca, filtros, câmera, lanterna e leitura de código de barras.
* **Navegação:** abas principais identificadas por rótulos: Produtos, Categorias, Movimentações e Configurações.
* **Acessibilidade visual:** suporte a modo claro e escuro, tokens de cor centralizados e cores semânticas para texto, ações, erros e status.
* **Recursos de autenticação:** suporte a biometria e validação por localização, com feedback visual e acessível.

Recomendação: manter novos componentes usando `AppTheme`, `AppColors` e `DarkAppColors`, evitando cores fixas no código.
