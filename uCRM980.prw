#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} CRMA980
Ponto de entrada utilizado para customização da barra de botões
da rotina de cadastro de clientes do módulo SIGAFAT.

@type user function
@author Maurício Rufino
@since 16/09/2026
@return xRet Array com as definições dos botões no contexto BUTTONBAR
        ou .T. nos demais contextos.
@see https://centraldeatendimento.totvs.com/hc/pt-br/articles/360000146128-Cross-Segmento-TOTVS-Backoffice-Linha-Protheus-ADVPL-Ponto-de-entrada-MVC-CRMA980
/*/

User Function CRMA980()

    Local aParam := ParamIxb
    Local xRet   := .T.
    
    // Valida se ParamIxb é um array com pelo menos dois elementos
    // e se o segundo elemento é "BUTTONBAR".
    If ValType(aParam) == "A" .And. Len(aParam) >= 2 .And. ;
        aParam[2] == "BUTTONBAR"

        xRet := {}

        // Array com a seguinte estrutura: {Título, Bitmap, CodeBlock, Tooltip (opcional)}
        aAdd(xRet, {"* Nº Endereço", "", {|| U_Exec1()}, "Nº Endereço"})

    EndIf

// Quando o segundo elemento de ParamIxb é "BUTTONBAR",
// retorna o array com as definições dos botões customizados.
// O terceiro elemento de cada subarray é o CodeBlock executado
// quando o respectivo botão é acionado. O CodeBlock permite que
// U_Exec1() seja executada somente após a interação do usuário.
// Nos demais contextos, mantém o retorno padrão .T.
Return xRet

User Function Exec1()

    // Obtém o Model e a View atualmente ativos na rotina MVC.
    Local oModel        := FWModelActive()
    Local oView         := FWViewActive()
    
    Local cNum          := ""
    Local cEndereco     := ""
    Local lProcessar    := .T.
        
    cNum := AllTrim(FWInputBox("Informe o número do endereço:"))

    If Empty(cNum)
        ApMsgAlert("Número do endereço não informado.")
        lProcessar := .F.
    EndIf

    If lProcessar
        // Valida o formato do número informado e seus possíveis complementos.
        If !fValidaNum(cNum)
            ApMsgAlert("Informe um número de endereço válido")
            lProcessar := .F.
        EndIf
    EndIf

    If lProcessar

        // Obtém o valor atual de A1_END para verificar se já existe
        // um número ao final do endereço.
        cEndereco := AllTrim(M->A1_END)

        // Remove o número existente no final do endereço, quando houver.
        cEndereco := fRemoveNum(cEndereco)

        // Monta o novo conteúdo de A1_END, adicionando o número informado
        // ao valor atual do campo.
        If !Empty(cEndereco)
            cEndereco += ", "
        EndIf

        cEndereco += cNum
        
        // Atualiza o campo A1_END no submodelo SA1MASTER do Model ativo.
        oModel:SetValue("SA1MASTER", "A1_END", cEndereco)

        // Atualiza a View para refletir a alteração.
        oView:Refresh()
    EndIf

Return

/*/{Protheus.doc} fValidaNum
Valida o formato do número do endereço.

Aceita valores iniciados por número, podendo possuir
complementos alfanuméricos e os separadores "-" e "/".
Também aceita os valores especiais "S/N" e "SN".

Exemplos válidos:
100
100-A
100/102
100-102
100 A
100 A/B
S/N
SN

@type static function
@param cValor, Número do endereço a ser validado
@return lRet, .T. quando o formato é válido
/*/
Static Function fValidaNum(cValor)

    Local cValorAux := ""
    Local cChar     := ""
    Local lRet      := .T.
    Local nI

    cValorAux := Upper(AllTrim(cValor))

    //==========================================================
    //Etapa 1: valida o formato inicial da informação.
    //==========================================================

    If Empty(cValorAux)

        lRet := .F.

    // Permite "S/N" e "SN" como exceção à regra de início numérico.
    ElseIf cValorAux == "S/N" .Or. cValorAux == "SN"

        lRet := .T.

    // Valida se o dado fornecido pelo usuário começa com número.
    ElseIf !(Left(cValorAux, 1) >= "0" .And. ;
             Left(cValorAux, 1) <= "9")

        lRet := .F.

    EndIf

    //==========================================================
    //Etapa 2: valida os caracteres do restante da informação.
    //==========================================================

    If lRet .And. ;
        cValorAux != "S/N" .And. ;
        cValorAux != "SN"

        For nI := 2 To Len(cValorAux)

            cChar := SubStr(cValorAux, nI, 1)

            // Aceita caracteres numéricos.
            If cChar >= "0" .And. cChar <= "9"

                // Não necessita de tratamento adicional.

            // Aceita letras para complementos do endereço.
            ElseIf cChar >= "A" .And. cChar <= "Z"

                // Não necessita de tratamento adicional.

            // Aceita hífen, barra e espaço.
            ElseIf cChar == "-" .Or. ;
                   cChar == "/" .Or. ;
                   cChar == " "

                // Não necessita de tratamento adicional.

            // Rejeita qualquer outro caractere.
            Else

                lRet := .F.
                Exit

            EndIf

        Next

    EndIf

    // Não permite terminar com hífen, barra ou espaço.
    If lRet .And. Len(cValorAux) > 0

        cChar := Right(cValorAux, 1)

        If cChar == "-" .Or. ;
           cChar == "/" .Or. ;
           cChar == " "

            lRet := .F.

        EndIf

    EndIf

Return lRet

/*/{Protheus.doc} fRemoveNum
Remove o número do final do endereço quando o último trecho,
após a última vírgula, corresponde a um formato de número de endereço.

@type static function
@param cEndereco, Endereço a ser analisado
@return cRet, Endereço sem o número final, quando identificado
/*/
Static Function fRemoveNum(cEndereco)

    Local cRet       := cEndereco
    Local cFinal     := ""
    Local nPosVirg   := Rat(",", cEndereco)

    If nPosVirg > 0

        cFinal := AllTrim(SubStr(cEndereco, nPosVirg + 1))

        If !Empty(cFinal) .And. fValidaNum(cFinal)
            cRet := AllTrim(SubStr(cEndereco, 1, nPosVirg - 1))
        EndIf

    EndIf

Return cRet
