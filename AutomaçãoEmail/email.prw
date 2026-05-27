#Include 'totvs.ch'

User Function EMAIL()

    Local cCorpo := ""
    Local cEmailDest := "email"
    Local nTitulo := 0
    Local cAssunto := ""
    Local cNomeCli := ""

    rpcSetType(3)
    rpcSetEnv('99','01')

    dbSelectArea('SE1')

    SE1->(dbSetOrder(6)) 

    IF SE1->(dbSeek("01" + dtos(dDataBase)))

        cCorpo := "Olá equipe financeira!" + CRLF 
        cCorpo += "Segue a lista dos títulos que vencem hoje (" + dtoc(dDataBase) + "):" + CRLF

        While !SE1->(eof()) .and. SE1->E1_VENCTO == dDataBase

            nTitulo++

            cNomeCli := Posicione("SA1", 1, "01" + SE1->E1_CLIENTE + SE1->E1_LOJA, "A1_NOME")

            IF Empty(cNomeCli)

                cNomeCli := SE1->E1_CLIENTE

            EndIF

            cCorpo += "Cliente: " + AllTrim(cNomeCli) + " | Valor R$ " + transform(SE1->E1_VALOR, "@E 999,999.92") + CRLF
            SE1->(dbSkip())

        EndDo

       cAssunto := "Financeiro - Vencimento (" + cValToChar(nTitulo) + " titulos)"
        U_SendMyMail(cEmailDest, cAssunto, cCorpo)
    
    Else

        cAssunto := "Financeiro - [Aviso] Sem títulos para hoje"
        cCorpo := "Não existem registros de títulos vencendo em " + dtoc(dDataBase)
        U_SendMyMail(cEmailDest, cAssunto, cCorpo)

    EndIF

    rpcClearEnv()

Return Nil


Static Function U_SendMyMail(cPara, cAssunto, cMensagem)
    Local cCmd     := ""
    Local cUser    := "email"
    Local cPass    := "senha GOOGLE"
    
    cMensagem := StrTran(cMensagem, CRLF, " ") 
    cMensagem := StrTran(cMensagem, "'", "") 

    cCmd := "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "
    cCmd += "$p = ConvertTo-SecureString '" + cPass + "' -AsPlainText -Force; "
    cCmd += "$c = New-Object System.Management.Automation.PSCredential ('" + cUser + "', $p); "
    cCmd += "Send-MailMessage -From '" + cUser + "' -To '" + cPara + "' -Subject '" + cAssunto + "' "
    cCmd += "-Body '" + cMensagem + "' -SmtpServer 'smtp.gmail.com' -Port 587 -UseSsl -Credential $c -Encoding utf8"

    WaitRun(cCmd, 0)
    
Return
