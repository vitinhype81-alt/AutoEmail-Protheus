#Include 'totvs.ch'

User Function DASHBOARD()

    Local oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('SE1') 
    oBrowse:SetDescription('Dashboard Financeiro')
    oBrowse:Activate()

Return



Static Function MenuDef()

    Local aRotina := {}
    aAdd(aRotina, { 'Visualizar', 'VIEWDEF.DASHBOARD', 0, 2, 0, Nil })

Return aRotina


Static Function ModelDef()

    Local oModel 
    Local oStruct := FWFormStruct(1, 'SE1')

    oModel := MPFormModel():New('MD_DASH')
    oModel:AddFields('MASTER_SE1', Nil, oStruct)


Return oModel


Static Function ViewDef()

    Local oView
    Local oModel  := FWLoadModel('DASHBOARD')
    Local oStruct := FWFormStruct(2, 'SE1') 

    oView := FWFormView():New()
    oView:SetModel(oModel)
    
    oView:CreateHorizontalLayer('CAMADA_DADOS', 100)
    oView:AddField('VIEW_SE1', oStruct, 'MASTER_SE1')
    oView:SetOwnerView('VIEW_SE1', 'CAMADA_DADOS')

    oView:SetAfterViewCode( { || ExibeGraf() } )
Return oView

Static Function ExibeGraf()
    Local oDlg
    Local nVenc  := 0
    Local nAVenc := 0
    Local cAlias := Alias()
    Local nPosRec := (cAlias)->(RecNo())
    Local nTotal := 0
    Local nAltV  := 0
    Local nAltA  := 0
    Local nI     := 0
    
    (cAlias)->(DbGoTop())

    While (cAlias)->(!Eof())

        If (cAlias)->E1_VALOR > 0 .And. !(cAlias)->(Deleted())

            If (cAlias)->E1_VENCTO < dDataBase
                nVenc += (cAlias)->E1_VALOR
            Else
                nAVenc += (cAlias)->E1_VALOR
            EndIF

        EndIF

        (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbGoTo(nPosRec))

    nTotal := nVenc + nAVenc
  
    nAltV := If(nTotal > 0, Int((nVenc / nTotal) * 15), 0)
    nAltA := If(nTotal > 0, Int((nAVenc / nTotal) * 15), 0)

    DEFINE MSDIALOG oDlg TITLE "DASHBOARD - Gráfico" FROM 0,0 TO 400,600 PIXEL
        
        @ 010, 115 SAY "Gráfico Financeiro " FONT TFont():New("Arial",,-18,.T.) PIXEL OF oDlg
        
        // VENCIDOS
        For nI := 1 To nAltV

            @ 150-(nI*8), 060 SAY "||||||||||" FONT TFont():New("Arial",,-16,.T.) PIXEL OF oDlg COLORS CLR_RED

        Next

        @ 165, 055 SAY "VENCIDOS" PIXEL OF oDlg COLORS CLR_RED
        @ 180, 045 SAY "R$ " + Transform(nVenc, "@E 999,999.92") PIXEL OF oDlg COLORS CLR_RED

        // A VENCER
        For nI := 1 To nAltA

            @ 150-(nI*8), 130 SAY "||||||||||" FONT TFont():New("Arial",,-16,.T.) PIXEL OF oDlg COLORS CLR_GREEN

        Next

        @ 165, 125 SAY "A VENCER" PIXEL OF oDlg COLORS CLR_GREEN
        @ 180, 115 SAY "R$ " + Transform(nAVenc, "@E 999,999.92") PIXEL OF oDlg COLORS CLR_GREEN

        @ 180, 250 BUTTON "Fechar" SIZE 050, 015 ACTION oDlg:End() PIXEL OF oDlg

    ACTIVATE MSDIALOG oDlg CENTERED

Return Nil
