#include "protheus.ch"
#include "topconn.ch"

/*/
??????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o    ?EQ?Autor ?Rodrigo Sousa 		?Data ?10.11.14 ??
???????????????????????????????????????
??escri?o ?  ??
??		 ?															  ??
??		 ?															  ??
???????????????????????????????????????
??Uso      ?Especifico                                    ??
???????????????????????????????????????
???????????????????????????????????????
??????????????????????????????????????
/*/
User Function EQLstRNC()

Local oReport

Private cPerg	:= "EQLSRN"

ValidPerg()

oReport := ReportDef()
oReport:PrintDialog()

Return

/*/
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o    ?ReportDef?Autor ?Rodrigo Sousa         ?Data ? ??
???????????????????????????????????????
??escri?o ?Definicao do layout do Relatorio							  ??
???????????????????????????????????????
??Uso      ?Especifico 	 	 		  	                               ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
Static Function ReportDef()

Local oReport  
Local oSection1
Local cPictVal
Local nTamFil,nTamCod,nTamDesc,nTamQtde

oReport := TReport():New("EQLstRNC","Rela��o RNC",cPerg,{|oReport| ReportPrint(oReport)},"Imprime relat�rio de RNC de acordo com os par�metros.")

oReport:SetLandScap(.T.)
oReport:SetTotalInLine(.F.) 

Pergunte(cPerg,.F.)

//???????????????????????????????
//?Inicia Se?o                							  ?
//???????????????????????????????
oSection1 := TRSection():New(oReport,"Registros de N�o Conformidade",{"SUI","SUJ"},{""})

//???????????????????????????????
//?Define c?ulas                							  ?
//???????????????????????????????
TRCell():New(oSection1,"UI_CODIGO"	,		,"RNC"			,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"UI_EMISSAO"	,		,"Emiss�o"		,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"UI_CODCLI"	,		,"Cod.Cliente"	,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"UI_LOJA"	,		,"Loja"			,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"UI_NOMECLI"	,		,"Nome"			,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"UI_SNOTA"	,		,"NF"			,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"UJ_PRODUTO"	,		,"Produto"		,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"UJ_ITEM"	,		,"Item"			,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"UJ_LOTE"	,		,"Lote"			,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"UJ_VLDLOTE"	,		,"Validade"		,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"UJ_QTDE"	,		,"Quantidade"	,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"B1_PESO"	,		,"Peso"			,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"UJ_PRECO"	,		,"Pre�o"		,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"UJ_TOTAL"	,		,"Total"		,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"UI_MOTDEVO"	,		,"Motivo"		,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"UI_NCONFOR"	,		,"Observa��o"	,	,	,.F.	,,,,,,,.F.) 

TRCell():New(oSection1,"UI_ANALISE"	,		,"Analise �.Cof",	,	,.F.	,,,,,,,.F.) 
TRCell():New(oSection1,"UI_CAUSA"	,		,"Causa Raiz"	,	,	,.F.	,,,,,,,.F.) 
TRCell():New(oSection1,"UI_PLANO"	,		,"Plano de Acao",	,   ,.F.	,,,,,,,.F.) 
TRCell():New(oSection1,"UI_DETIMPL"	,		,"Detalhamento"	,	,	,.F.	,,,,,,,.F.) 
TRCell():New(oSection1,"UI_DETEFIC"	,		,"Deta. Efic"	,	,	,.F.	,,,,,,,.F.) 


oSection1:SetColSpace(0)

Return oReport

/*
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?eportPrint?Autor ?odrigo Sousa          ?Data ?5.08.12  ??
???????????????????????????????????????
??escri?o ? funcao estatica ReportDef devera ser criada para todos os  ??
??         ?elatorios que poderao ser agendados pelo usuario.           ??
???????????????????????????????????????
??etorno   ?enhum                                                       ??
???????????????????????????????????????
??arametros?xpO1: Objeto Report do Relat?io                            ??
???????????????????????????????????????
??  DATA   ?Programador   ?anutencao efetuada                          ??
???????????????????????????????????????
??         ?              ?                                            ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
Static Function ReportPrint(oReport)

Local oBreak
Local oSection1  	:= oReport:Section(1)

Local nOrdem 		:= oSection1:GetOrder()
Local nSeek			:= 0

Local cFilterUser	
Local cRepTit		:= oReport:Title()
Local cDescrMot		:= ""
Local cNomFil		:= ""

//Local aDados[16]
Local aDados[21]// Alterado por Fabio Batista 26/11/2020

Private cAlias		:= GetNextAlias()
Private aSx3Box      := RetSx3Box(Posicione('SX3',2,'UI_MOTDEVO','X3CBox()'),,,1)

//???????????????????????????????
//?Define bloco de c?igo na impress? das c?ulas		  	  ?
//???????????????????????????????
oSection1:Cell("UI_CODIGO" 	):SetBlock( { || aDados[01]})
oSection1:Cell("UI_EMISSAO" ):SetBlock( { || aDados[02]})
oSection1:Cell("UI_CODCLI" 	):SetBlock( { || aDados[03]})
oSection1:Cell("UI_LOJA"  	):SetBlock( { || aDados[04]})
oSection1:Cell("UI_NOMECLI" ):SetBlock( { || aDados[05]})
oSection1:Cell("UI_SNOTA" 	):SetBlock( { || aDados[06]})
oSection1:Cell("UJ_PRODUTO" ):SetBlock( { || aDados[07]})
oSection1:Cell("UJ_ITEM"  	):SetBlock( { || aDados[08]})
oSection1:Cell("UJ_LOTE"  	):SetBlock( { || aDados[09]})
oSection1:Cell("UJ_VLDLOTE" ):SetBlock( { || aDados[10]})
oSection1:Cell("UJ_QTDE" 	):SetBlock( { || aDados[11]})
oSection1:Cell("B1_PESO" 	):SetBlock( { || aDados[12]})
oSection1:Cell("UJ_PRECO"	):SetBlock( { || aDados[13]})
oSection1:Cell("UJ_TOTAL"	):SetBlock( { || aDados[14]})
oSection1:Cell("UI_MOTDEVO"	):SetBlock( { || aDados[15]})
oSection1:Cell("UI_NCONFOR"	):SetBlock( { || aDados[16]})

//Alterado por Fabio Batista 26/11/2020
oSection1:Cell("UI_ANALISE"	):SetBlock( { || aDados[17]})
oSection1:Cell("UI_CAUSA"	):SetBlock( { || aDados[18]})
oSection1:Cell("UI_PLANO"	):SetBlock( { || aDados[19]})
oSection1:Cell("UI_DETIMPL"	):SetBlock( { || aDados[20]})
oSection1:Cell("UI_DETEFIC"	):SetBlock( { || aDados[21]})

oReport:NoUserFilter()

oSection1:Init()

aFill(aDados,nil)

cTitulo := "Relat�rio Registros de N�o Conformidade"

cQuery	:= "SELECT UI_CODIGO, UI_EMISSAO, UI_CODCLI, UI_LOJA, UI_NOMECLI, UI_SNOTA, "+CRLF
cQuery	+= "ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), UI_ANALISE)),'-') AS UI_ANALISE,"+CRLF//Alterado por Fabio Batista 26/11/2020
cQuery	+= "ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), UI_CAUSA)),'-') AS UI_CAUSA,"+CRLF//Alterado por Fabio Batista 26/11/2020
cQuery	+= "ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), UI_PLANO)),'-') AS UI_PLANO,"+CRLF//Alterado por Fabio Batista 26/11/2020
cQuery	+= "ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), UI_DETIMPL)),'-') AS UI_DETIMPL,"+CRLF//Alterado por Fabio Batista 26/11/2020
cQuery	+= "ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), UI_DETEFIC)),'-') AS UI_DETEFIC,"+CRLF//Alterado por Fabio Batista 26/11/2020
cQuery	+= "UJ_PRODUTO,"+CRLF
cQuery	+= "UJ_ITEM, UJ_LOTE, UJ_VLDLOTE, UJ_QTDE, UJ_PRECO, UJ_TOTAL, UI_MOTDEVO,UI_EMISSAO, "+CRLF 
cQuery	+= "(UJ_QTDE * B1_PESO) AS B1_PESO,"+CRLF 
cQuery	+= "ISNULL(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),UI_NCONFOR)), '') AS UI_NCONFOR"+CRLF
cQuery	+= "FROM "+RetSqlName("SUI")+" SUI"+CRLF
cQuery	+= "INNER JOIN "+RetSqlName("SUJ")+" SUJ "+CRLF
cQuery	+= "	ON UJ_FILIAL = UI_FILIAL "+CRLF
cQuery	+= "	AND UJ_CODIGO = UI_CODIGO "+CRLF
cQuery	+= "	AND UJ_ENTIDA = 'SUI' "+CRLF
cQuery	+= "	AND SUJ.D_E_L_E_T_ = ''"+CRLF
cQuery	+= "INNER JOIN " + RetSqlName("SB1") +" AS SB1"+CRLF
cQuery	+= "	ON B1_FILIAL = ''"+CRLF
cQuery	+= "	AND B1_COD = UJ_PRODUTO"+CRLF
cQuery	+= "	AND SB1.D_E_L_E_T_ = ''"+CRLF
cQuery	+= "WHERE UI_FILIAL = '"+xFilial("SUI")+"'"+CRLF
cQuery	+= "AND UI_EMISSAO BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"'"+CRLF
cQuery	+= "AND UI_CODCLI BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR07+"'"+CRLF
cQuery	+= "AND UI_LOJA BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR08+"'"+CRLF
cQuery	+= "AND UJ_PRODUTO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"+CRLF
cQuery	+= "AND SUI.D_E_L_E_T_ = ''"+CRLF
cQuery	+= "ORDER BY UI_CODIGO, UJ_ITEM"+CRLF

TCQuery cQuery New Alias (cAlias)
TcSetField((cAlias),"UI_EMISSAO","D")
TcSetField((cAlias),"UJ_VLDLOTE","D")

nTotsRec := (cAlias)->(RecCount())
oReport:SetMeter(nTotsRec)

While !(cAlias)->(Eof()) 

	oReport:IncMeter()

	If oReport:Cancel()
		Exit
	EndIf

	cDescrMot := ""
  	If (nSeek := Ascan(aSx3Box, { |x| x[ 2 ] == (cAlias)->UI_MOTDEVO })) > 0
   		cDescrMot := AllTrim( aSx3Box[ nSeek, 3 ] )
  	Endif

	aDados[1]	:= (cAlias)->UI_CODIGO
	aDados[2]	:= (cAlias)->UI_EMISSAO
	aDados[3]	:= (cAlias)->UI_CODCLI
	aDados[4]	:= (cAlias)->UI_LOJA
	aDados[5]	:= (cAlias)->UI_NOMECLI
	aDados[6]	:= (cAlias)->UI_SNOTA
	aDados[7]	:= (cAlias)->UJ_PRODUTO
	aDados[8]	:= (cAlias)->UJ_ITEM
	aDados[9]	:= (cAlias)->UJ_LOTE
	aDados[10]	:= (cAlias)->UJ_VLDLOTE
	aDados[11]	:= (cAlias)->UJ_QTDE
	aDados[12]	:= (cAlias)->B1_PESO
	aDados[13]	:= (cAlias)->UJ_PRECO
	aDados[14]	:= (cAlias)->UJ_TOTAL
	aDados[15]	:= cDescrMot 
	aDados[16]	:= (cAlias)->UI_NCONFOR
	
	//Alterado Fabio Batista 26/11/2020
	aDados[17]	:= (cAlias)->UI_ANALISE
	aDados[18]	:= (cAlias)->UI_CAUSA
	aDados[19]	:= (cAlias)->UI_PLANO
	aDados[20]	:= (cAlias)->UI_DETIMPL
	aDados[21]	:= (cAlias)->UI_DETEFIC


	//???????????????????????????????
	//?Imprime Linha 	 		 								  ?
	//???????????????????????????????
	oSection1:PrintLine()
	aFill(aDados,nil)

	(cAlias)->(dbSkip())

EndDo

oSection1:Finish()

If Select((cAlias)) <> 0
	(cAlias)->( dbCloseArea() )
EndIf

Return
/*
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o    ?alidPerg ?Autor ?Rodrigo Sousa  		?Data ?15.08.12  ??
???????????????????????????????????????
??escri?o ?Parametros da rotina.                					   ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
*/
Static Function ValidPerg()

Local aArea := GetArea()
Local aPerg := {}

cPerg := cPerg + Space(4)

Aadd(aPerg, {cPerg, "01", "Do Produto      		?", "MV_CH1" , 	"C", 06	, 0	, "G"	, "MV_PAR01", "SB1"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "02", "At?o Produto    	?", "MV_CH2" , 	"C", 06	, 0	, "G"	, "MV_PAR02", "SB1"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "03", "Da Emiss?         	?", "MV_CH3" , 	"D", 08	, 0	, "G"	, "MV_PAR03", ""	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "04", "At?a Emiss?      	?", "MV_CH4" , 	"D", 08	, 0	, "G"	, "MV_PAR04", ""	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "05", "Do Cliente       	?", "MV_CH5" , 	"C", 06	, 0	, "G"	, "MV_PAR05", "SA1"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "06", "Da Loja 	        	?", "MV_CH6" , 	"C", 02	, 0	, "G"	, "MV_PAR06", ""	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "07", "At?o Cliente    	?", "MV_CH7" , 	"C", 06	, 0	, "G"	, "MV_PAR07", "SA1"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "08", "At?a Loja      		?", "MV_CH8" , 	"C", 02	, 0	, "G"	, "MV_PAR08", ""	,""		,""				,""				,"",""})

DbSelectArea("SX1")
DbSetOrder(1)

For i := 1 To Len(aPerg)
	IF  !DbSeek(aPerg[i,1]+aPerg[i,2])
		RecLock("SX1",.T.)
	Else
		RecLock("SX1",.F.)
	EndIF
	Replace X1_GRUPO   with aPerg[i,01]
	Replace X1_ORDEM   with aPerg[i,02]
	Replace X1_PERGUNT with aPerg[i,03]
	Replace X1_VARIAVL with aPerg[i,04]
	Replace X1_TIPO	   with aPerg[i,05]
	Replace X1_TAMANHO with aPerg[i,06]
	Replace X1_PRESEL  with aPerg[i,07]
	Replace X1_GSC	   with aPerg[i,08]
	Replace X1_VAR01   with aPerg[i,09]
	Replace X1_F3	   with aPerg[i,10]
	Replace X1_DEF01   with aPerg[i,11]
	Replace X1_DEF02   with aPerg[i,12]
	Replace X1_DEF03   with aPerg[i,13]
	Replace X1_DEF04   with aPerg[i,14]
	Replace X1_DEF05   with aPerg[i,15]
	MsUnlock()
Next i

RestArea(aArea)

Return(.T.)
