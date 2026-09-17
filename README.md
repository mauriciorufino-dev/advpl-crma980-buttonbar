# Customização ADVPL — CRMA980 ButtonBar

Customização desenvolvida em **ADVPL/TOTVS Protheus** para adicionar um botão personalizado à barra de ações da rotina de cadastro de clientes.

## Objetivo

Demonstrar a utilização de **ponto de entrada MVC**, manipulação do Model/View ativos e criação de uma ação personalizada na `BUTTONBAR` da rotina `CRMA980`.

A funcionalidade permite informar o número do endereço e atualizar o campo `A1_END`, mantendo o logradouro e substituindo um número previamente informado ao final do endereço.

## Funcionalidades

* Inclusão de botão personalizado na `BUTTONBAR` da rotina `CRMA980`.
* Entrada do número do endereço por meio de `FWInputBox()`.
* Validação do formato do número informado.
* Suporte a números com complementos, como:

  * `100`
  * `100-A`
  * `100/102`
  * `100 A`
  * `100 A/B`
  * `S/N`
  * `SN`
* Remoção do número existente ao final do endereço antes da inclusão do novo número.
* Atualização do campo `A1_END` por meio do Model MVC ativo.
* Atualização da View após a alteração.

## Estrutura

```text
uCRM980.prw
```

O arquivo contém:

* `CRMA980()` — ponto de entrada responsável pela customização da `BUTTONBAR`.
* `Exec1()` — execução da rotina de atualização do endereço.
* `fValidaNum()` — validação do número do endereço.
* `fRemoveNum()` — identificação e remoção do número existente ao final do endereço.

## Conceitos demonstrados

* ADVPL
* TOTVS Protheus
* MVC
* Ponto de entrada
* `ParamIxb`
* `BUTTONBAR`
* `FWModelActive()`
* `FWViewActive()`
* `FWInputBox()`
* Manipulação de arrays
* `CodeBlock`
* Validação de strings
* Funções `Static`
* Atualização de campos através do Model

## Ambiente

Desenvolvido para ambiente **TOTVS Protheus**, utilizando ADVPL e arquitetura MVC.

## Referência

Documentação TOTVS sobre o ponto de entrada `CRMA980`:

https://centraldeatendimento.totvs.com/hc/pt-br/articles/360000146128-Cross-Segmento-TOTVS-Backoffice-Linha-Protheus-ADVPL-Ponto-de-entrada-MVC-CRMA980
