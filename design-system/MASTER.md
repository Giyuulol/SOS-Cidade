# SOS Cidade Design System

## Entendimento

Este documento registra as regras UI/UX aplicadas manualmente a partir da skill `ui-ux-pro-max` para orientar a funcionalidade de login/autenticacao e as proximas telas do app.

## Principios

- Acessibilidade primeiro: contraste minimo AA, labels visiveis, estados de foco e suporte a leitores de tela.
- Interface mobile-first: componentes tocaveis com area minima proxima de 44x44px.
- Consistencia visual: cores e tipografia devem sair de tokens centralizados, nao de valores soltos em widgets.
- Feedback claro: acoes de login devem ter loading, erro proximo ao campo e mensagens objetivas.

## Tokens

| Papel | Hex | Uso |
| --- | --- | --- |
| Primary | `#0891B2` | AppBar, botoes primarios, foco |
| On Primary | `#FFFFFF` | Texto/icone sobre primary |
| Secondary | `#22D3EE` | Destaques secundarios |
| Accent | `#059669` | CTA positivo e confirmacoes |
| Background | `#ECFEFF` | Fundo principal claro |
| Foreground | `#164E63` | Texto principal |
| Muted | `#E8F1F6` | Superficies discretas |
| Border | `#A5F3FC` | Bordas e divisores |
| Destructive | `#DC2626` | Erros e acoes destrutivas |

## Tipografia

- Fonte base: `Inter` quando a fonte for adicionada ao projeto.
- Fallback atual: fonte padrao do Flutter/Material.
- Corpo: minimo 16px para leitura confortavel.
- Labels de formulario: sempre visiveis, nunca apenas placeholder.

## Login/Autenticacao

### Casos de uso esperados

- Usuario informa email e senha.
- Sistema valida campos obrigatorios antes de chamar autenticacao.
- Sistema exibe loading enquanto autentica.
- Sistema mostra erro proximo ao contexto da acao quando credenciais falham.
- Sistema permite navegacao por teclado e leitores de tela.

### Anti-patterns

- Usar placeholder como unico label.
- Informar erro apenas por cor.
- Desabilitar focus ring ou feedback visual.
- Usar valores de cor hardcoded dentro das telas.
- Criar botoes menores que a area minima de toque.

## Checklist

- [ ] Contraste minimo 4.5:1 para textos comuns.
- [ ] Componentes interativos com estado disabled, loading e focus.
- [ ] Inputs com label, helper/error text e validacao local.
- [ ] Layout responsivo para larguras pequenas.
- [ ] Cores e estilos vindos do tema central.
