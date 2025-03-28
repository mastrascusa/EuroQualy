
/*/{Protheus.doc} CodBar
///--------------------------------------------------------------------------\
//| Fun��o: CODBAR     														 |
//|--------------------------------------------------------------------------|
//| Essa Fun��o foi desenvolvida com base no Manual do Bco. Ita� e no RDMAKE:|
//|--------------------------------------------------------------------------|
//| Descri��o: Fun��o para Valida��o de C�digo de Barras (CB) e Representa��o|
//|            Num�rica do C�digo de Barras - Linha Digit�vel (LD).    	     |
//|                                                                          |
//|            A LD de Bloquetos possui tr�s Digitos Verificadores (DV) que  |
//|	       s�o consistidos pelo M�dulo 10, al�m do D�gito Verificador    |
//|		eral (DVG) que � consistido pelo M�dulo 11. Essa LD t�m 47   |
//|            D�gitos.                                                      |
//|                                                                          |
//|            A LD de T�tulos de Concessin�rias do Servi�o P�blico e IPTU   |
//|		ossui quatro Digitos Verificadores (DV) que s�o consistidos  |
//|            pelo M�dulo 10, al�m do Digito Verificador Geral (DVG) que    |
//|            tamb�m � consistido pelo M�dulo 10. Essa LD t�m 48 D�gitos.   |
//|                                                                          |
//|            O CB de Bloquetos e de T�tulos de Concession�rias do Servi�o  |
//|            P�blico e IPTU possui apenas o D�gito Verificador Geral (DVG) |
//|            sendo que a �nica diferen�a � que o CB de Bloquetos �         |
//|            consistido pelo M�dulo 11 enquanto que o CB de T�tulos de     |
//|            Concession�rias � consistido pelo M�dulo 10. Todos os CB�s    |
//|            t�m 44 D�gitos.                                               |
//|                                                                          |
//|            Para utiliza��o dessa Fun��o, deve-se criar o campo E2_CODBAR,|
//|            Tipo Caracter, Tamanho 48 e colocar na Valida��o do Usu�rio:  |
//|            EXECBLOCK("CODBAR",.T.).                                      |
//|                                                                          |
//|            Utilize tamb�m o gatilho com a Fun��o CONVLD() para converter |
//|            a LD em CB.																     |
//\--------------------------------------------------------------------------/
@type function Processamento
@version   1.00
@author mario.antonaccio
@since 11/08/2021
@return Logical, Calculo correto ou nao
/*/
USER FUNCTION CodBar()

	Local i
	SETPRVT("cStr,lRet,cTipo,nConta,nMult,nVal,nDV,cCampo,i,nMod,nDVCalc")

	//If inclui==.T.
	// Retorna .T. se o Campo estiver em Branco.
	IF VALTYPE(M->E2_CODBAR) == NIL .OR. EMPTY(M->E2_CODBAR)
		RETURN(.T.)
	ENDIF

	cStr := LTRIM(RTRIM(M->E2_CODBAR))
	/*
Else
	// Retorna .T. se o Campo estiver em Branco.
	IF VALTYPE(SE2->E2_CODBAR) == NIL .OR. EMPTY(SE2->E2_CODBAR)
		RETURN(.T.)
	ENDIF

	cStr := LTRIM(RTRIM(SE2->E2_CODBAR))
Endif
	*/
	// Se o Tamanho do String for 45 ou 46 est� errado! Retornar� .F.
	lRet := IF(LEN(cStr)==45 .OR. LEN(cStr)==46,.F.,.T.)

	// Se o Tamanho do String for menor que 44, completa com zeros at� 47 d�gitos. Isso �
	// necess�rio para Bloquetos que N�O t�m o vencimento e/ou o valor informados na LD.
	cStr := IF(LEN(cStr)<44,cStr+REPL("0",47-LEN(cStr)),cStr)

	// Verifica se a LD � de (B)loquetos ou (C)oncession�rias/IPTU. Se for CB retorna (I)ndefinido.
	cTipo := IF(LEN(cStr)==47,"B",IF(LEN(cStr)==48,"C","I"))

	// Verifica se todos os d�gitos s�o num�rios.
	FOR i := LEN(cStr) TO 1 STEP -1
		lRet := IF(SUBSTR(cStr,i,1) $ "0123456789",lRet,.F.)
	NEXT

	IF LEN(cStr) == 47 .AND. lRet
		// Consiste os tr�s DV�s de Bloquetos pelo M�dulo 10.
		nConta  := 1
		WHILE nConta <= 3
			nMult  := 2
			nVal   := 0
			nDV    := VAL(SUBSTR(cStr,IF(nConta==1,10,IF(nConta==2,21,32)),1))
			cCampo := SUBSTR(cStr,IF(nConta==1,1,IF(nConta==2,11,22)),IF(nConta==1,9,10))
			FOR i := LEN(cCampo) TO 1 STEP -1
				nMod  := VAL(SUBSTR(cCampo,i,1)) * nMult
				nVal  := nVal + IF(nMod>9,1,0) + (nMod-IF(nMod>9,10,0))
				nMult := IF(nMult==2,1,2)
			NEXT
			nDVCalc := 10-MOD(nVal,10)
			// Se o DV Calculado for 10 � assumido 0 (Zero).
			nDVCalc := IF(nDVCalc==10,0,nDVCalc)
			lRet    := IF(lRet,(nDVCalc==nDV),.F.)
			nConta  := nConta + 1
		ENDDO
		// Se os DV�s foram consistidos com sucesso (lRet=.T.), converte o n�mero para CB para consistir o DVG.
		cStr := IF(lRet,SUBSTR(cStr,1,4)+SUBSTR(cStr,33,15)+SUBSTR(cStr,5,5)+SUBSTR(cStr,11,10)+SUBSTR(cStr,22,10),cStr)
	ENDIF

	IF LEN(cStr) == 48 .AND. lRet
		// Consiste os quatro DV�s de T�tulos de Concession�rias de Servi�o P�blico e IPTU pelo M�dulo 10.
		nConta  := 1
		WHILE nConta <= 4
			nMult  := 2
			nVal   := 0
			nDV    := VAL(SUBSTR(cStr,IF(nConta==1,12,IF(nConta==2,24,IF(nConta==3,36,48))),1))
			cCampo := SUBSTR(cStr,IF(nConta==1,1,IF(nConta==2,13,IF(nConta==3,25,37))),11)
			FOR i := 11 TO 1 STEP -1
				nMod  := VAL(SUBSTR(cCampo,i,1)) * nMult
				nVal  := nVal + IF(nMod>9,1,0) + (nMod-IF(nMod>9,10,0))
				nMult := IF(nMult==2,1,2)
			NEXT
			nDVCalc := 10-MOD(nVal,10)
			// Se o DV Calculado for 10 � assumido 0 (Zero).
			nDVCalc := IF(nDVCalc==10,0,nDVCalc)
			lRet    := IF(lRet,(nDVCalc==nDV),.F.)
			nConta  := nConta + 1
		ENDDO
		// Se os DV�s foram consistidos com sucesso (lRet=.T.), converte o n�mero para CB para consistir o DVG.
		cStr := IF(lRet,SUBSTR(cStr,1,11)+SUBSTR(cStr,13,11)+SUBSTR(cStr,25,11)+SUBSTR(cStr,37,11),cStr)
	ENDIF

	IF LEN(cStr) == 44 .AND. lRet
		IF cTipo $ "BI"
			// Consiste o DVG do CB de Bloquetos pelo M�dulo 11.
			nMult  := 2
			nVal   := 0
			nDV    := VAL(SUBSTR(cStr,5,1))
			cCampo := SUBSTR(cStr,1,4)+SUBSTR(cStr,6,39)
			FOR i := 43 TO 1 STEP -1
				nMod  := VAL(SUBSTR(cCampo,i,1)) * nMult
				nVal  := nVal + nMod
				nMult := IF(nMult==9,2,nMult+1)
			NEXT
			nDVCalc := 11-MOD(nVal,11)
			// Se o DV Calculado for 0,10 ou 11 � assumido 1 (Um).
			nDVCalc := IF(nDVCalc==0 .OR. nDVCalc==10 .OR. nDVCalc==11,1,nDVCalc)
			lRet    := IF(lRet,(nDVCalc==nDV),.F.)
			// Se o Tipo � (I)ndefinido E o DVG N�O foi consistido com sucesso (lRet=.F.), tentar�
			// consistir como CB de T�tulo de Concession�rias/IPTU no IF abaixo.
		ENDIF
		IF cTipo == "C" .OR. (cTipo == "I" .AND. !lRet)
			// Consiste o DVG do CB de T�tulos de Concession�rias pelo M�dulo 10.
			lRet   := .T.
			nMult  := 2
			nVal   := 0
			nDV    := VAL(SUBSTR(cStr,4,1))
			cCampo := SUBSTR(cStr,1,3)+SUBSTR(cStr,5,40)
			FOR i := 43 TO 1 STEP -1
				nMod  := VAL(SUBSTR(cCampo,i,1)) * nMult
				nVal  := nVal + IF(nMod>9,1,0) + (nMod-IF(nMod>9,10,0))
				nMult := IF(nMult==2,1,2)
			NEXT
			nDVCalc := 10-MOD(nVal,10)
			// Se o DV Calculado for 10 � assumido 0 (Zero).
			nDVCalc := IF(nDVCalc==10,0,nDVCalc)
			lRet    := IF(lRet,(nDVCalc==nDV),.F.)
		ENDIF
	ENDIF

	IF !lRet
		HELP(" ",1,"ONLYNUM")
	ENDIF

RETURN(lRet)

/*/{Protheus.doc} CONVLD
///--------------------------------------------------------------------------\
//| Fun��o: CONVLD		            										 |
//|--------------------------------------------------------------------------|
//| Descri��o: Fun��o para Convers�o da Representa��o Num�rica do C�digo de  |
//|            Barras - Linha Digit�vel (LD) em C�digo de Barras (CB).       |
//|                                                                          |
//|            Para utiliza��o dessa Fun��o, deve-se criar um Gatilho para o |
//|            campo E2_CODBAR, Conta Dom�nio: E2_CODBAR, Tipo: Prim�rio,    |
//|            Regra: EXECBLOCK("CONVLD",.T.), Posiciona: N�o.               |
//|                                                                          |
//|            Utilize tamb�m a Valida��o do Usu�rio para o Campo E2_CODBAR  |
//|            EXECBLOCK("CODBAR",.T.) para Validar a LD ou o CB.            |
//\--------------------------------------------------------------------------/
@type function processamento
@version  1.00
@author mario.antonaccio
@since 11/08/2021
@return Character, String formatada da Linah Digital
/*/
User function CONVLD()

	SETPRVT("cStr","cStr1","cStr2","cStr3")

	//If inclui==.T.
	cStr3 := SUBSTR(M->E2_LINDIG,1,60)   // pega o numero completo com todos os espa�os se houver
	cStr1 := ALLTRIM(M->E2_LINDIG)       // pega e tira os espa�os do come�o e do fim....
	cStr2 := STRTRAN(M->E2_LINDIG," ","",1) // transforma o espa�o em vazio
	cStr  := SUBSTR(cStr2,1,48)     //tem que trazer o numero sem nenhum espa�o
	cStr := STRTRAN(M->E2_LINDIG," ")
	IF VALTYPE(M->E2_LINDIG) == NIL .OR. EMPTY(M->E2_LINDIG)
		// Se o Campo est� em Branco n�o Converte nada.
		cStr := ""
		//	ELSEIF SE2->E2_LINDIG>48
		//   cStr :=ALLTRIM(SE2->(E2_LINDIG, 1,11)+(E2_LINDIG,13,1)+(E2_LINDIG,15,11)+(E2_LINDIG,27,1)+(E2_LINDIG,29,11)+(E2_LINDIG,41,1)+(E2_LINDIG,43,11)+(E2_LINDIG,55,1))

	ELSE
		// Se o Tamanho do String for menor que 44, completa com zeros at� 47 d�gitos. Isso �
		// necess�rio para Bloquetos que N�O t�m o vencimento e/ou o valor informados na LD.
		cStr := IF(LEN(cStr)<44,cStr+REPL("0",47-LEN(cStr)),cStr)
	ENDIF
	/*
Else
	cStr := ALLTRIM(SE2->E2_LINDIG)
	IF VALTYPE(SE2->E2_LINDIG) == NIL .OR. EMPTY(SE2->E2_LINDIG)
		// Se o Campo est� em Branco n�o Converte nada.
		cStr := ""
	ELSE
		// Se o Tamanho do String for menor que 44, completa com zeros at� 47 d�gitos. Isso �
		// necess�rio para Bloquetos que N�O t�m o vencimento e/ou o valor informados na LD.
		cStr := IF(LEN(cStr)<44,cStr+REPL("0",47-LEN(cStr)),cStr)
	ENDIF
Endif
	*/
	DO CASE
		CASE LEN(cStr) == 47
			cStr := SUBSTR(cStr,1,4)+SUBSTR(cStr,33,15)+SUBSTR(cStr,5,5)+SUBSTR(cStr,11,10)+SUBSTR(cStr,22,10)
		CASE LEN(cStr) == 48
			cStr := SUBSTR(cStr,1,11)+SUBSTR(cStr,13,11)+SUBSTR(cStr,25,11)+SUBSTR(cStr,37,11)
		OTHERWISE
			cStr := cStr+SPACE(48-LEN(cStr))
	ENDCASE

RETURN(cStr)

/*/{Protheus.doc} ItauAgc
Retorna o numero da agencia formatado para o CNAB/SISPAG
@type function  Processamento
@version  1.00
@author mario.antonaccio
@since 11/08/2021
@return Character, Numero agencia formatado
/*/
User Function ItauAgc()
	Local cAgencia	:= ""

	If Alltrim(SA2->A2_BANCO)$"341/409"
		cAgencia:="0"+PADL(ALLTRIM(STRTRAN(SA2->A2_AGENCIA,"-","")),4,"0")+" "+"000000"+PADL(ALLTRIM(STRTRAN(SA2->A2_NUMCON,"-","")),6,"0")+" "+PADL(RIGHT(TRIM(SA2->A2_DVCTA),1),1,"0")
	Else
		cAgencia:=PADL(ALLTRIM(STRTRAN(SA2->A2_AGENCIA,"-","")),5,"0")+" "+PADL(ALLTRIM(STRTRAN(SA2->A2_NUMCON,"-","")),12,"0")+" "+PADL(RIGHT(TRIM(SA2->A2_DVCTA),1),1,"0")
	Endif

Return(cAgencia)


/*/{Protheus.doc} ItauTrib
Formata��o de dados no SIAPG/CNAB de tributos
@type function Processamento
@version   1.00
@author mario.antonaccio
@since 11/08/2021
@return Character, String com o retorno confomre os dados
/*/
User Function ItauTrib()

	Local _cRet		:=""
	Local _cCodUF	:=""
	Local _cCodMun	:=""
	Local _cCodPla	:=""

	If SEA->EA_MODELO$"17" //Pagamento GPS
		_cRet:="01"																//Codigo do tributo / pos. 018-019
		_cRet+=Substr(SE2->E2_CODRET ,1,4)										//Codigo do pagamento / pos. 020-023
		_cRet+=STRZERO(MONTH(SE2->E2_XCOMPET),2)+STR(YEAR(SE2->E2_XCOMPET),4)	//Competencia / pos. 024-029
		_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identifica��o do Contribuinte - CNPJ/CGC/CPF / 030-043
		_cRet+=STRZERO(SE2->E2_SALDO*100,14)									//Valor de pagamento do INSS / 044-057
		_cRet+=STRZERO(SE2->E2_ACRESC*100,14)									//Valor somado ao valor do documento / 058-071
		_cRet+=REPL("0",14)														//Atualiza��o monetaria /	072-085
		_cRet+=STRZERO((SE2->E2_SALDO+SE2->E2_ACRESC)*100,14)					//Valor total arrecadado / 086-099
		_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data da arrecada��o / 100-107
		_cRet+=Space(08)														//Brancos / 108-115
		_cRet+=Space(50)														//Uso da empresa / 116-165
		_cRet+=Substr(SM0->M0_NOMECOM,1,30)										//Nome do Contribuinte / 166-195

	Elseif SEA->EA_MODELO$"16" //Pagamento de Darf Normal
		_cRet:="02"																//Codigo do tributo / pos. 018-019
		_cRet+=Substr(SE2->E2_CODRET ,1,4)										//Codigo do pagamento / pos. 020-023
		_cRet+="2"																//Tipo de Inscr. Contribuinte / pos. 024-024
		_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identifica��o do Contribuinte - CNPJ/CGC/CPF / 025-038
		_cRet+=STRZERO(DAY(SE2->E2_XCOMPET),2)+STRZERO(MONTH(SE2->E2_XCOMPET),2)+STR(YEAR(SE2->E2_XCOMPET),4) //Competencia / 039-046
		_cRet+=IIF(EMPTY(SE2->E2_IDDARF),STRZERO(0,17),STRZERO(VAL(SUBSTR(SE2->E2_IDDARF,1,17)),17))   //Numero de referencia / 047-063
		_cRet+=STRZERO(SE2->E2_SALDO*100,14)									//Valor Principal / 064-077
		_cRet+=STRZERO(SE2->E2_MULTA*100,14)									//Valor da Multa / 078-091
		_cRet+=STRZERO(SE2->E2_JUROS+SE2->E2_ACRESC*100,14)						//Valor de Juros+Encargos / 092-105
		_cRet+=STRZERO((SE2->E2_SALDO+SE2->E2_MULTA+SE2->E2_JUROS+SE2->E2_ACRESC)*100,14)//Valor total arrecadado / 106-119
		_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de Vencimento / 120-127
		_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de pagamento  / 128-135
		_cRet+=space(30)		                              					// Brancos / 136-165
		_cRet+=Substr(SM0->M0_NOMECOM,1,30)										//Nome do Contribuinte / 166-195

	Elseif SEA->EA_MODELO$"18"//Pagamento de Darf Simples
		_cRet:="03"																//Codigo do tributo / pos. 018-019
		_cRet+="2100" //Substr(SE2->E2_ESCRT  ,1,4)										//Codigo do pagamento / pos. 020-023
		_cRet+="2"																//Tipo de Inscr. Contribuinte / pos. 024-024
		_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identifica��o do Contribuinte - CNPJ/CGC/CPF / 025-038
		_cRet+=StrZero(Day(SE2->E2_EMISSAO),2)+STRZERO(MONTH(SE2->E2_EMISSAO),2)+STR(YEAR(SE2->E2_EMISSAO),4) //Competencia / 039-046
		//_cRet+=STRZERO(SE2->E2_ESVRBA*100,9)									//Valor da receita bruta acumulada / 047-055
		_cRet+=STRZERO(SE2->E2_VALOR*100,9)									//Valor da receita bruta acumulada / 047-055
		//_cRet+=STRZERO(SE2->E2_ESPRB,4)											//Percentual da receita Bruta / 056-059
		_cRet+=STRZERO(100,4)											//Percentual da receita Bruta / 056-059
		_cRet+=Space(04)														//Brancos / 060-063
		_cRet+=STRZERO(SE2->E2_SALDO*100,14)									//Valor Principal / 064-077
		_cRet+=STRZERO(SE2->E2_MULTA*100,14)									//Valor da Multa / 078-091
		_cRet+=STRZERO(SE2->E2_JUROS+SE2->E2_ACRESC*100,14)						//Valor de Juros+Encargos / 092-105
		_cRet+=STRZERO(SE2->E2_SALDO+SE2->E2_MULTA+SE2->E2_JUROS+SE2->E2_ACRESC*100,14)	//Valor total arrecadado / 106-119
		_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de Vencimento / 120-127
		_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de pagamento  / 128-135
		_cRet+=space(30)		                              					// Brancos / 136-165
		_cRet+=Substr(sm0->m0_nomecom,1,30)										//Nome do Contribuinte / 166-195

	Elseif SEA->EA_MODELO$"21" // Pagamento de DARJ
		_cRet:="03"																//Codigo do tributo / pos. 018-019
		_cRet+="2100" //Substr(SE2->E2_ESCRT  ,1,4)										//Codigo do pagamento / pos. 020-023
		_cRet+="2"																//Tipo de Inscr. Contribuinte / pos. 024-024
		_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identifica��o do Contribuinte - CNPJ/CGC/CPF / 025-038
		_cRet+=PADL(ALLTRIM(SM0->M0_INSC),8,"0")								//Identifica��o do Contribuinte - IE / 039-046
		_cRet+=STRZERO(SE2->E2_NUM,16)   //STRZERO(SE2->E2_ESNORIG,16)	    	//Numero do documento de origem / 047-062
		_cRet+=Space(01)														//Branco / 063-063
		_cRet+=STRZERO(SE2->E2_SALDO*100,14)									//Valor de pagamento do INSS / 064-077
		_cRet+=STRZERO(SE2->E2_ACRESC*100,14)									//Valor somado ao valor do documento / 078-091
		_cRet+=STRZERO(SE2->E2_JUROS*100,14)									//Valor de Juros+Encargos / 092-105
		_cRet+=STRZERO(SE2->E2_MULTA*100,14)									//Valor da Multa / 106-119
		_cRet+=STRZERO(SE2->E2_SALDO+SE2->E2_MULTA+SE2->E2_JUROS+SE2->E2_ACRESC*100,14)	//Valor total arrecadado / 120-133
		_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de Vencimento / 134-141
		_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de pagamento  / 142-149
		_cRet+=STRZERO(MONTH(SE2->E2_EMISSAO),2)+STR(YEAR(SE2->E2_EMISSAO),4)	//Competencia / pos. 150-155
		_cRet+=space(10)		                              					// Brancos / 156-165
		_cRet+=Substr(SM0->M0_NOMECOM,1,30)										//Nome do Contribuinte / 166-195

	Elseif SEA->EA_MODELO$"22" //Pagamento de Gare-SP (ICMS/DR/ITCMD)
		_cRet:="04"																//Codigo do tributo / pos. 018-019
		_cRet+=Substr(SE2->E2_CODRET  ,1,4)										//Codigo do pagamento / pos. 020-023
		_cRet+="2"																//Tipo de Inscr. Contribuinte / pos. 024-024
		_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identifica��o do Contribuinte - CNPJ/CGC/CPF / 025-038
		_cRet+=PADL(ALLTRIM(SM0->M0_INSC),12,"0")								//Identifica��o do Contribuinte - IE / 039-050
		_cRet+=STRZERO(0,13)													//Numero da divida ativa / 051-063
		_cRet+=STRZERO(MONTH(SE2->E2_EMISSAO),2)+STR(YEAR(SE2->E2_EMISSAO),4)	//Competencia / pos. 064-069
		_cRet+=STRZERO(0,13)													//Numero da parcela / 070-082
		_cRet+=STRZERO(SE2->E2_SALDO*100,14)									//Valor de pagamento / 083-091
		_cRet+=STRZERO((SE2->E2_JUROS+SE2->E2_ACRESC)*100,14)					//Valor de Juros+Encargos / 092-096
		_cRet+=STRZERO(SE2->E2_MULTA*100,14)									//Valor da Multa / 097-110
		_cRet+=STRZERO(SE2->E2_SALDO+SE2->E2_MULTA+SE2->E2_JUROS+SE2->E2_ACRESC*100,14)	//Valor total arrecadado / 111-124
		_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de Vencimento / 139-146
		_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de pagamento  / 147-154
		_cRet+=space(11)		                              					// Brancos / 155-165
		_cRet+=Substr(sm0->m0_nomecom,1,30)										//Nome do Contribuinte / 166-195

	Elseif SEA->EA_MODELO$"25" //Pagamentto de IPVA
		_cRet:="07"																//Codigo do tributo / pos. 018-019
		_cRet+=Space(04)														//Brancos			 / pos. 020-023
		_cRet+="2"																//Tipo de Inscr. Contribuinte / pos. 024-024
		_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identifica��o do Contribuinte - CNPJ/CGC/CPF / 025-038
		_cRet+=STR(YEAR(SE2->E2_EMISSAO),4)										//Competencia / pos. 039-042
		_cCodRen:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_ESCODVE,"DA3_RENAVA")
		_cRet+=PADL(ALLTRIM(_cCodRen),9,"0")									//Codigo do Renavan / 043-051
		_cCodUF:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_ESCODVE,"DA3_ESTPLA")
		_cRet+=_cCodUF															//UF do estado do veiculo / 052-053
		_cCodMun:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_ESCODVE,"DA3_CODMUN")
		_cRet+=PADL(ALLTRIM(_cCodMun),9,"0")									//Codigo do Municipio / 054-058
		_cCodPla:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_ESCODVE,"DA3_PLACA")
		_cRet+=_cCodPla                                                         //Placa do Veiculo / 059-065
		_cRet+=Alltrim(If(FieldPos("E2_ESOPIP")>0,SE2->E2_ESOPIP," "))			//Codigo da cond. de pgto / 066-066
		_cRet+=STRZERO(SE2->E2_SALDO*100,14)									//Valor de pagamento / 067-080
		_cRet+=STRZERO(SE2->E2_DESCONT*100,14)									//Valor de desconto / 081-094
		_cRet+=STRZERO((SE2->E2_SALDO-SE2->E2_DESCONT)*100,14)					//Valor de pagamento / 095-108
		_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de pagamento  / 109-116
		_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de pagamento  / 117-124
		_cRet+=space(41)		                              					// Brancos / 125-165
		_cRet+=Substr(sm0->m0_nomecom,1,30)										//Nome do Contribuinte / 166-195

	Elseif SEA->EA_MODELO$"27" //Pagamento DPVAT
		_cRet:="08"																//Codigo do tributo / pos. 018-019
		_cRet+=Space(04)														//Brancos			 / pos. 020-023
		_cRet+="2"																//Tipo de Inscr. Contribuinte / pos. 024-024
		_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identifica��o do Contribuinte - CNPJ/CGC/CPF / 025-038
		_cRet+=STR(YEAR(SE2->E2_EMISSAO),4)										//Competencia / pos. 039-042
		_cCodRen:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_ESCODVE,"DA3_RENAVA")
		_cRet+=PADL(ALLTRIM(_cCodRen),9,"0")									//Codigo do Renavan / 043-051
		_cCodUF:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_ESCODVE,"DA3_ESTPLA")
		_cRet+=_cCodUF															//UF do estado do veiculo / 052-053
		_cCodMun:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_ESCODVE,"DA3_CODMUN")
		_cRet+=PADL(ALLTRIM(_cCodMun),9,"0")									//Codigo do Municipio / 054-058
		_cCodPla:=Posicione("DA3",1,xFilial("DA3")+SE2->E2_ESCODVE,"DA3_PLACA")
		_cRet+=_cCodPla                                                         //Placa do Veiculo / 059-065
		_cRet+=Alltrim(SE2->E2_ESOPIP)											//Codigo da cond. de pgto / 066-066
		_cRet+=STRZERO(SE2->E2_SALDO*100,14)									//Valor de pagamento / 067-080
		_cRet+=STRZERO(SE2->E2_DESCONT*100,14)									//Valor de desconto / 081-094
		_cRet+=STRZERO((SE2->E2_SALDO-SE2->E2_DESCONT)*100,14)					//Valor de pagamento / 095-108
		_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de pagamento  / 109-116
		_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de pagamento  / 117-124
		_cRet+=space(41)		                              					// Brancos / 125-165
		_cRet+=Substr(sm0->m0_nomecom,1,30)										//Nome do Contribuinte / 166-195

	Elseif SEA->EA_MODELO$"35" // Pagamento de FGTS c/ Codigo de Barras
		_cRet:="11"																//Codigo do tributo / pos. 018-019
		_cRet+="2100" //Substr(SE2->E2_ESCRT  ,1,4)										//Codigo do pagamento / pos. 020-023
		_cRet+="2"																//Tipo de Inscr. Contribuinte / pos. 024-024
		_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identifica��o do Contribuinte - CNPJ/CGC/CPF / 025-038
		_cRet+=SUBSTR(SE2->E2_CODBAR,1,48)										//Codigo de Barras / 039-086
		_cRet+=STRZERO(If(FieldPos("E2_ESNFGTS")>0,SE2->E2_ESNFGTS,0),16)										//Ident. do FGTS / 087-102
		_cRet+=STRZERO(If(FieldPos("E2_ESLACRE")>0,SE2->E2_ESLACRE,0),09)										//Lacre do FGTS / 103-111
		_cRet+=STRZERO(If(FieldPos("E2_ESDGLAC")>0,SE2->E2_ESDGLAC,0),02)										//DG Lacre do FGTS / 112-113
		_cRet+=Substr(sm0->m0_nomecom,1,30)										//Nome do Contribuinte / 114-143
		_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de pagamento  / 144-151
		_cRet+=STRZERO(SE2->E2_SALDO*100,14)									//Valor de pagamento / 152-165
		_cRet+=space(30)		                              					// Brancos / 166-195
	Endif

Return(_cRet)

/*/{Protheus.doc} Totent
Fonte criado para tratar as Posi��es do Cnab 038 a 051. Valores Outras Entidades Guia da GPS - INSS  (SISPAG) 
@type function Processamento
@version   1.00
@author mario.antonaccio
@since 11/08/2021
@return Numeric, Valor do acrescimo se houver como caracter
/*/
User Function Totent()

	Local _area   := GetArea()
	Local _Ret := 0
	_Acres:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_ACRESC")
	_Ret := StrZero(_Acres * 100,14)
	RestArea(_area)

Return _Ret

/*/{Protheus.doc} Totpag
Retorna valor de juros, multa e abatimento (decrescimo)
@type function Processamento
@version   1.00
@author mario.antonaccio
@since 11/08/2021
@return Character, Valor da Soma de juros e multa convertido em Caracter
/*/
User Function Totpag()

	Local _area   := GetArea()
	//Local _Soma   := SOMAVALOR()
	local _Soma1  := 0
	Local _Desc   := 0

	_Desc := SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_DECRESC")
	_Juros:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_JUROS")
	_Multa:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_MULTA")
	//_Acres:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_ACRESC")

	_DESC := VAL(STR(_Desc*100))
	_Soma1:= (((_Juros+_Multa)*100) - _Desc)
	_SOMA1:= STR(_SOMA1)
	_SOMA1:= STRZERO(VAL(_SOMA1),14)

	RestArea(_area)

Return(_Soma1)

User Function Totpag1()

	Local _area   := GetArea()
	Local _Soma   := SOMAVALOR()
	local _Soma1  := 0
	Local _Desc   := 0

	_Desc := SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_DECRESC")
	_Juros:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_JUROS")
	_Multa:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_MULTA")
	//_Acres:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_ACRESC")

	_DESC := VAL(STR(_Desc*100))
	_Soma1:= (((_Soma+(_Juros+_Multa)*100) - _Desc))
	//_Soma1:= ((_Soma+(_Juros+_Multa)*100)-(_Acres+_Desc))
	_SOMA1:= STR(_SOMA1)
	_SOMA1:= STRZERO(VAL(_SOMA1),18)

	RestArea(_area)

Return(_Soma1)

User Function Totpag2()

	Local _area   := GetArea()
	Local _Soma   := SOMAVALOR()
	local _Soma1  := 0
	Local _Desc   := 0

	_Desc := SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_DECRESC")
	_Juros:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_JUROS")
	_Multa:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_MULTA")
	//_Acres:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_ACRESC")

	_DESC := VAL(STR(_Desc*100))
	_Soma1:= (((_Soma+(_Juros+_Multa)*100) - _Desc))
	//_Soma1:= ((_Soma+(_Juros+_Multa)*100)-(_Acres+_Desc))
	_SOMA1:= STR(_SOMA1)
	_SOMA1:= STRZERO(VAL(_SOMA1),14)

	RestArea(_area)

Return(_Soma1)






User Function Totpag3()

	Local _area   := GetArea()
	Local _Soma   := SOMAVALOR()
	local _Soma1  := 0
	Local _Desc   := 0

	_Desc := SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_DECRESC")
	_Juros:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_JUROS")
	_Multa:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_MULTA")
	_Acres:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_ACRESC")

	_DESC := VAL(STR(_Desc*100))
	_Soma1:= ((_Soma-(_Acres)*100))
	_SOMA1:= STR(_SOMA1)
	_SOMA1:= STRZERO(VAL(_SOMA1),14)

	RestArea(_area)

Return(_Soma1)





User Function Totpag4()

	Local _area   := GetArea()
	Local _Soma   := SOMAVALOR()
	local _Soma1  := 0
	Local _Desc   := 0

	_Desc := SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_DECRESC")
	_Juros:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_JUROS")
	_Multa:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_MULTA")
	//_Acres:= SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_ACRESC")

	_DESC := VAL(STR(_Desc*100))
	_Soma1:= (((_Soma+(_Juros+_Multa)*100) - _Desc))
	//_Soma1:= ((_Soma+(_Juros+_Multa)*100)-(_Acres+_Desc))
	_SOMA1:= STR(_SOMA1)
	_SOMA1:= STRZERO(VAL(_SOMA1),18)

	RestArea(_area)

Return(_Soma1)






/*���������������������������������������������������������������������������
���Programa  �TRLARQ     												  ���
�������������������������������������������������������������������������͹��
���Desc.     �PROGRAMA PARA TRATAMENTO DO TRAILLER DO ARQUIVO DE CNAB DE  ���
���          �TODOS OS SEGMENTOS REFERENTE A QUANTIDADE DE REGISTROS.     ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
���������������������������������������������������������������������������*/

User Function TRLARQ()

	cRet := ""
	//TRATAMENTO PARA O TRAILLER DO ARQUIVO DOS SEGMENTOS J / N / O / W /D
	If SEA->EA_MODELO$"11/13/30/31/16/17/18/19/20/21/22/23/24/25/26/27/33/35" .AND. SEA->EA_PORTADO $ "001/341/237/033/041/104"
		cRet := STRZERO(M->NSEQ+4,6)
		//ElseIf SEA->EA_MODELO$"11/13/30/31/16/17/18/19/20/21/22/23/24/25/26/27/33/35".AND. SEA->EA_PORTADO == "041" //TRATAMENTO PARA O TRAILLER DO ARQUIVO DOS SEGMENTOS J / N / O / W / D
		//	cRet := STRZERO(M->NSEQ+3,6)
	ElseIf SEA->EA_MODELO$"01/02/03/04/05/10/41/43/50" .AND. SEA->EA_PORTADO == "033"	//TRATAMENTO PARA O TRAILLER DO ARQUIVO DOS SEGMENTOS A / B
		cRet := STRZERO(M->NSEQ+4,6)
	ElseIf SEA->EA_MODELO$"01/02/03/04/05/10/41/43/50" .AND. SEA->EA_PORTADO $ "001/341/237/104"	//TRATAMENTO PARA O TRAILLER DO ARQUIVO DOS SEGMENTOS A / B
		cRet := STRZERO((NSEQ+1)*2,6)
	ElseIf SEA->EA_MODELO$"01/02/03/04/05/10/41/43/50" .AND. SEA->EA_PORTADO == "041"	//TRATAMENTO PARA O TRAILLER DO ARQUIVO DOS SEGMENTOS A / B
		cRet := STRZERO(NSEQ+4,6)
	Else
		cRet := STRZERO(0,6)
	EndIf

Return (cRet)





User Function ValTot()

	Local _area   := GetArea()
	Local _Soma   := SOMAVALOR()
	local _Soma1  := 0
	Local _Desc   := 0

	_Desc := SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_DECRESC")
	_DESC := VAL(STR(_Desc*100))
	_Soma1 := ((_Soma - _Desc))
	_SOMA1 := STR(_SOMA1)
	_SOMA1 := STRZERO(VAL(_SOMA1),17)

	RestArea(_area)

Return(_Soma1)







User Function ValTot1()

	Local _area   := GetArea()
	Local _Soma   := SOMAVALOR()
	local _Soma1  := 0
	Local _Desc   := 0

	//_Desc := SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_DECRESC")
	_Desc := SOMAR("SE2","E2_NUMBOR=SEA->EA_NUMBOR ","E2_DECRESC")

	//_DESC := VAL(STR(_Desc*100))
	_DESC := VAL(STR(_Desc*100))

	//_Soma1 := ((_Soma - _Desc))
	_Soma1 := ((_Soma))

	//_SOMA1 := STR(_SOMA1)
	_SOMA1 := STR(_SOMA1)

	//_SOMA1 := STRZERO(VAL(_SOMA1),17)
	_SOMA1 := STRZERO(VAL(_SOMA1),17)

	RestArea(_area)

Return(_Soma1)






User Function MORA()

	Local _nMora 	:= 0
	Local _cBanco	:= SEE->EE_CODIGO //"341"
	Local _cAgencia	:= SEE->EE_AGENCIA //"4807 "
	Local _cConta	:= SEE->EE_CONTA //"092293    "

	DbSelectArea("SEE")
	Dbsetorder(1)
	Dbseek(xfilial("SEE")+_cBanco+_cAgencia+_cConta+"R")

	If _cBanco=="341"
		_nMora := Padl( Alltrim(StrTran(Transform(((SE1->E1_VALOR*SEE->EE_JUROS)/100)/30,"@E 99,999,999.99"),",","")), 13, "0" )
	Elseif _cBanco=="001" .OR. _cBanco=="399"
		_nMora := Padl( Alltrim(StrTran(Transform(((SEE->EE_JUROS)/100)/30,"@E 99,999,999.9999"),",","")), 15, "0" )
	Else
		_nMora := Padl( Alltrim(StrTran(Transform(((SE1->E1_VALOR*SEE->EE_JUROS)/100)/30,"@E 99,999,999.99"),",","")), 13, "0" )
	Endif
Return _nMora







User Function MULTAK()

	Local _nMulta 	:= 0
	Local _cBanco	:= SEE->EE_CODIGO //
	Local _cAgencia	:= SEE->EE_AGENCIA //
	Local _cConta	:= SEE->EE_CONTA //

	DbSelectArea("SEE")
	Dbsetorder(1)
	Dbseek(xfilial("SEE")+_cBanco+_cAgencia+_cConta+"R")

	If _cBanco=="237"
		_nMulta := Padl( Alltrim(StrTran(Transform((SEE->EE_PERCMUL),"@E 99.99"),",","")), 4, "0" )
	Else
		_nMulta := Padl( Alltrim(StrTran(Transform(((SE1->E1_VALOR*SEE->EE_MULTA)/100),"@E 99,999,999.99"),",","")), 13, "0" )
	Endif
Return _nMulta






User Function PAGACRE()

	//SetPrvt("_VENC")

	Local _ACRE  :=  ""


	IF Empty(_ACRE)

		If  !EMPTY(SE2->E2_ACRESC) .AND. SE2->E2_AJUSTE == "DB"

			_ACRE := STRZERO(SE2->E2_ACRESC*100,15)

		ElseIf  !EMPTY(SE2->E2_DECRESC) .AND. SE2->E2_AJUSTE == "AI"

			_ACRE  :=  STRZERO(0,15)


		ElseIf  EMPTY(SE2->E2_ACRESC)

			_ACRE :=  STRZERO(0,15)

		Endif

	ENDIF

Return(_ACRE)





User Function PAGDEC()

	//SetPrvt("_VENC")

	Local _DEC  :=  ""


	IF Empty(_DEC)

		If  !EMPTY(SE2->E2_DECRESC) .AND. SE2->E2_AJUSTE == "DB"

			_DEC := STRZERO(SE2->E2_DECRESC*100,15)

		ElseIf  !EMPTY(SE2->E2_DECRESC) .AND. SE2->E2_AJUSTE == "AI"

			_DEC  :=  STRZERO(0,15)


		ElseIf  EMPTY(SE2->E2_DECRESC)

			_DEC  :=  STRZERO(0,15)

		Endif

	ENDIF

Return(_DEC)








User Function PAGVENC1()

	SetPrvt("_VENCVAL")

	// VERIFICACAO DO VENCIMENTO DO CODIGO DE BARRAS

	_VENCVAL  :=  ""

	IF !Empty(SE2->E2_CODBAR)

		_VENCVAL := PADL(SUBSTR(SE2->E2_CODBAR,6,14),14,"0")

	EndIf

	IF Empty(_VENCVAL)
		If !EMPTY(SE2->E2_ACRESC) .OR. !EMPTY(SE2->E2_DECRESC)

			_VENCVAL := STRZERO(SE2->(E2_SALDO)*100,14)

		ElseIf EMPTY(SE2->E2_ACRESC) .OR. EMPTY(SE2->E2_DECRESC)

			_VENCVAL  :=  "00000000000000"

		Endif

	ENDIF

Return(_VENCVAL)







User Function PAGVENC2()

	SetPrvt("_VENC")

	_VENC  :=  ""

	IF Empty(_VENC)
		If  !EMPTY(SE2->E2_DECRESC)

			_VENC := DTOS(SE2->E2_VENCREA)

		ElseIf  EMPTY(SE2->E2_DECRESC)

			_VENCVAL  :=  "00000000"

		Endif

	ENDIF

Return(_VENC)






User Function PAGVENC3()

	//SetPrvt("_VENC")

	Local _VENC  :=  ""


	IF Empty(_VENC)

		If  !EMPTY(SE2->E2_DECRESC) .AND. SE2->E2_AJUSTE == "DB"

			_VENC := DTOS(SE2->E2_VENCREA)

		ElseIf  !EMPTY(SE2->E2_DECRESC) .AND. SE2->E2_AJUSTE == "AI"

			_VENC  :=  "00000000"


		ElseIf  EMPTY(SE2->E2_DECRESC)

			_VENC  :=  "00000000"

		Endif

	ENDIF

Return(_VENC)


