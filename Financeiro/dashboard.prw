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
    Local oFWChart 
    Local aRand := {} 
    Local nVenc  := 0
    Local nAVenc := 0
    Local cAlias := Alias()
    Local nPosRec := (cAlias)->(RecNo())
    Local nTotal := 0
    
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
    
    If nTotal == 0
        MsgInfo("Nenhum titulo encontrado para gerar o grafico.", "Dashboard Financeiro")
        Return Nil
    EndIf

    DEFINE MSDIALOG oDlg TITLE "DASHBOARD - Gráfico Financeiro" FROM 0,0 TO 400,600 PIXEL
        
        oFWChart := FWChartFactory():New()
        oFWChart := oFWChart:getInstance(BARCHART) 
        
        oFWChart:Init(oDlg, .T., .T. )
        oFWChart:SetTitle("Títulos: Vencidos x A Vencer", CONTROL_ALIGN_CENTER)
        
        oFWChart:addSerie("Vencidos", nVenc)
        oFWChart:addSerie("A Vencer", nAVenc)
        
        oFWChart:setLegend( CONTROL_ALIGN_LEFT )
        oFWChart:cPicture := "@E 999,999,999.99"
        
        aAdd(aRand, {"200,050,050", "150,000,000"}) // Tom avermelhado
        aAdd(aRand, {"050,200,050", "000,150,000"}) // Tom esverdeado
        
        oFWChart:oFWChartColor:aRandom := aRand
        oFWChart:oFWChartColor:SetColor("Random")
        
        oFWChart:Build()

    ACTIVATE MSDIALOG oDlg CENTERED

Return Nil
