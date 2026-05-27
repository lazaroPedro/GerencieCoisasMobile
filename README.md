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