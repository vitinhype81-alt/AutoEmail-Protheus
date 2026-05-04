#include 'totvs.ch'
#include 'restful.ch'

User Function CEPCONS()

    Local cCep := M->A1_CEP
    Local oRest := FWRest():New("https://viacep.com.br")
    Local cResource := "/ws/" + cCep + "/json/"
    Local cResult := ""
    Local oJson := JsonObject():New()

    cCep := StrTran(cCep, "-", "")
    cCep := AllTrim(cCep)

    IF Len(cCep) <> 8
        Return .T. 
    EndIF

    oRest:SetPath(cResource)

    IF oRest:Get()
        cResult := oRest:GetResult()

        oJson:FromJson(cResult)

        IF oJson['erro'] != Nil
            IF ( ValType(oJson['erro']) == "L" .And. oJson['erro'] ) .Or. ;
               ( ValType(oJson['erro']) == "C" .And. AllTrim(Lower(oJson['erro'])) == "true" )

                MsgStop("CEP não encontrado!", "Atenção")

                M->A1_END    := Space(40)
                M->A1_BAIRRO := Space(20)
                M->A1_MUN    := Space(20)
                M->A1_EST    := Space(2)

            Return .T.
            EndIF
        EndIF

        M->A1_END    := oJson['logradouro']
        M->A1_BAIRRO := oJson['bairro']
        M->A1_MUN    := oJson['localidade']
        M->A1_EST    := oJson['uf']


    Else
        MsgStop("Erro na conexão com o serviço", "Erro")
    EndIF

Return .T.
