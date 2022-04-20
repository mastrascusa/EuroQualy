#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

User Function BeP0203A()

Local cQuery	:= ""
Local cAlias	:= GetNextAlias()
Local cMsgHdr	:= ""
Local cMsgBody	:= ""
Local cRetfun	:= "u_BePLogin.apw"
Local lSession 	:= Execblock("BePVSess",.F.,.F.) // Valida Sess�o
Local aRetSaldo	:= {}
Local nSaldo	:= 0
Local nSaldoAtu := 0
Local nTotPed	:= 0
Local nRegSM0	:= SM0->(Recno())

Private cHtml 	:= ""    

WEB EXTENDED INIT cHtml                               

cHtml += Execblock("BePHeader",.F.,.F.)

If lSession

	cHtml += Execblock("BePMenus",.F.,.F.)

	dbSelectArea("SM0")
	dbSeek(cEmpAnt+Alltrim(HttpGet->filexc),.T.)
	cFilAnt := SM0->M0_CODFIL

	dbSelectArea("SC7")
	dbSetOrder(1)
	dbSeek(xFilial("SC7")+Alltrim(HttpGet->numped))

	dbSelectArea("SAK")
	dbSetOrder(2)
	dbSeek(xFilial("SAK")+Alltrim(HttpSession->ccodusr))
	
	dbSelectArea("SAL")       
	dbSetOrder(3)
	MsSeek(xFilial("SAL")+SC7->C7_APROV+SAK->AK_COD)    

	aRetSaldo := MaSalAlc(SAK->AK_COD,dDataBase)
	nSaldo 	  := aRetSaldo[1]

	cHtml += '<div class="main col-md-12" style="margin-top: 50px">'
	If HttpGet->nopc == "3"
		cHtml += '  <h2>Transfer�ncia Superior -  Autoriza��o de Entrega</h2>'+CRLF
		cHtml += '  <hr/>'+CRLF
		cHtml += '  <form method="POST" id="formpc" action="u_bep0203C.apw" class="col-md-12" style="margin-bottom: 10px;">'+CRLF
	Else
		cHtml += '  <h2>Libera��o Autoriza��o de Entrega</h2>'+CRLF
		cHtml += '  <hr/>'+CRLF
		cHtml += '  <form method="POST" id="formpc" action="u_bep0203B.apw" class="col-md-12" style="margin-bottom: 10px;">'+CRLF
	EndIf
	
	//Linha 1	
	/*
	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="filped">Filial:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="filped" name="filped" value="'+HttpGet->filexc+'" readonly>'+CRLF
	cHtml += '    </div>'+CRLF
	*/

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">N�mero:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="numpc" name="numpc" value="'+SC7->C7_NUM+'" readonly>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="pwd">Emiss�o:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="dtemis" name="dtemis" value="'+DtoC(SC7->C7_EMISSAO)+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	//Linha 2	
	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Fornecedor:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+SC7->C7_FORNECE+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="pwd">Loja:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codloja" name="codloja" value="'+SC7->C7_LOJA+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="pwd">Nome: </label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="nomforn" name="nomforn" value="'+Alltrim(Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NREDUZ"))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="condpagto">Condi��o Pagamentos: </label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="condpagto" name="condpagto" value="'+Alltrim(SC7->C7_COND)+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="condpagto">Descri��o: </label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="condpagto" name="condpagto" value="'+Alltrim(Posicione("SE4",1,xFilial("SE4")+SC7->C7_COND,"E4_DESCRI"))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	//Linha 3	
	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="pwd">Grp. Aprov.:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="grpapr" name="grpapr" value="'+HttpGet->grpapr+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="nivapr">N�vel Apr.:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="nivapr" name="nivapr" value="'+HttpGet->nivel+'" readonly>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Dt. Ref.:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="dterf" name="dtref" value="'+DtoC(dDataBase)+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="pwd">Saldo:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="sldcomp" name="sldcomp" value="'+Alltrim(Transform(nSaldo,PesqPict("SAK","AK_LIMITE")))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="filped">Filial:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="filped" name="filped" value="'+HttpGet->filexc+'" readonly>'+CRLF
	cHtml += '    </div>'+CRLF

	//Table
	cHtml += '	<div  class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF

	cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
	cHtml += '    	<table id="table" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
	cHtml += '    		<thead>'+CRLF
	cHtml += '      		<tr>'+CRLF
	cHtml += '		  			<th>A��es</th>
	cHtml += '		  			<th>Item</th>'+CRLF
	cHtml += '        			<th>Produto</th>'+CRLF
	cHtml += '        			<th>Descricao</th>'+CRLF
	cHtml += '        			<th>Local</th>'+CRLF
	cHtml += '        			<th>Saldo Estoque</th>'+CRLF
	cHtml += '        			<th>Ult.Pre�o</th>'+CRLF
	cHtml += '        			<th>Prev.Entrega</th>'+CRLF
	cHtml += '        			<th>Qtde.</th>'+CRLF
	cHtml += '        			<th>Moeda</th>'+CRLF
	cHtml += '        			<th>Prc. Unit.</th>'+CRLF
	cHtml += '        			<th>Total</th>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</thead>'+CRLF
	cHtml += '			<tbody>'+CRLF
	
	Do While SC7->(!Eof()) .And. SC7->C7_FILIAL == Alltrim(HttpGet->filexc) .And. SC7->C7_NUM == Alltrim(HttpGet->numped)
	
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+SC7->C7_PRODUTO)

		dbSelectArea("SB2")
		SB2->( dbSetOrder(1) )
		If SB2->( dbSeek(xFilial("SB2") + SC7->C7_PRODUTO + SC7->C7_LOCAL ) )
			nSaldoAtu := SaldoSB2()
		Else
			nSaldoAtu := 0
		EndIf

		cHtml += '				<tr>'+CRLF
		cHtml += '					<td>'
		cHtml += '						<div class="btn-group">'
		cHtml += ' 							<button type="button" class="btn btn-sm dropdown-toggle" data-toggle="dropdown">'
		cHtml += '    							<span class="caret"></span>'
		cHtml += '    							<span class="sr-only">Toggle Dropdown</span>'
		cHtml += '  						</button>'
		cHtml += '  						<ul class="dropdown-menu" role="menu">
		cHtml += '    							<li><a href="u_bep0206B.apw?codpro='+SC7->C7_PRODUTO+'&nopc=4">Consultar Produto</a></li>
		cHtml += '  						</ul>
		cHtml += '						</div>
		cHtml += '					</td>
		cHtml += '        			<td>'+SC7->C7_ITEM+'</td>'+CRLF
		cHtml += '        			<td nowrap>'+SC7->C7_PRODUTO+'</td>'+CRLF
		cHtml += '        			<td nowrap>'+Iif(!Empty(SC7->C7_DESCRI),Alltrim(SC7->C7_DESCRI),Alltrim(SB1->B1_DESC))+'</td>'+CRLF
		cHtml += '        			<td nowrap>'+SC7->C7_LOCAL+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(nSaldoAtu,PesqPict("SB2","B2_QATU"))+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(SB1->B1_UPRC,PesqPict("SB1","B1_UPRC"))+'</td>'+CRLF
		cHtml += '        			<td>'+DTOC(SC7->C7_DATPRF)+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(SC7->C7_QUANT,PesqPict("SC7","C7_QUANT"))+'</td>'+CRLF
		cHtml += '        			<td>'+Alltrim(Str(SC7->C7_MOEDA))+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(SC7->C7_PRECO,PesqPict("SC7","C7_PRECO"))+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(SC7->C7_TOTAL,PesqPict("SC7","C7_TOTAL"))+'</td>'+CRLF
		cHtml += '      		</tr>'+CRLF

		nTotPed += SC7->C7_TOTAL
		
		SC7->(dbSkip())
	
	EndDo
	
	cHtml += '				<tr>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td>TOTAL</td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td>'+Transform(nTotPed,PesqPict("SC7","C7_TOTAL"))+'</td>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</tbody>'+CRLF
	cHtml += '  	</table>'+CRLF
	cHtml += '	  </div>'+CRLF
	cHtml += '  </div>'+CRLF
	
	If HttpGet->nopc == "2" 
		cHtml += '	  <div class="form-group">'+CRLF
		cHtml += '  	<label for="comment">Observa��es:</label>'+CRLF
		cHtml += '  	<textarea form="formpc" class="form-control" rows="5" id="obslib" name="obslib"></textarea>'+CRLF
		cHtml += '	  </div>'+CRLF
	
		cHtml += '    <div class="checkbox col-md-12">'+CRLF
		cHtml += '		<label class="radio-inline"><input type="radio" name="optlib" value=1  required>Aprovar</label>'
		cHtml += '		<label class="radio-inline"><input type="radio" name="optlib" value=2>Reprovar</label>'
		cHtml += '    </div>'+CRLF
		cHtml += '	  <div class="form-group col-md-12">'+CRLF
		cHtml += '    	<button type="submit" class="btn btn-default">Confirmar</button>'+CRLF
		cHtml += '    	<a href="U_BeP0203.apw" class="btn btn-default">Cancelar</a>'+CRLF
		cHtml += '	  </div>'+CRLF
	ElseIf HttpGet->nopc == "3"
		dbSelectArea("SAK")
		dbSetOrder(1)
		dbSeek(xFilial("SAK")+Alltrim(HttpGet->superior))

		cHtml += '    <div class="form-group col-md-4">'+CRLF
		cHtml += '      <label for="codsup">Superior</label>'+CRLF
		cHtml += '      <input type="text" class="form-control" id="codsup" name="codsup" value="'+AllTrim(SAK->AK_COD)+'" disabled>'+CRLF
		cHtml += '    </div>'+CRLF

		cHtml += '    <div class="form-group col-md-8">'+CRLF
		cHtml += '      <label for="nomesup">Nome Aprovador Superior</label>'+CRLF
		cHtml += '      <input type="text" class="form-control" id="nomesup" name="nomesup" value="'+AllTrim(SAK->AK_NOME)+'" disabled>'+CRLF
		cHtml += '    </div>'+CRLF

		cHtml += '	  <div class="form-group col-md-12">'+CRLF
		cHtml += '    	<button type="submit" class="btn btn-default">Transferir</button>'+CRLF
		cHtml += '    	<a href="U_BeP0203.apw" class="btn btn-default">Cancelar</a>'+CRLF
		cHtml += '	  </div>'+CRLF
	Else
		cHtml += '	  <div class="form-group col-md-12">'+CRLF
		cHtml += '    	<a href="U_BeP0203.apw" class="btn btn-default">Voltar</a>'+CRLF
		cHtml += '	  </div>'+CRLF
	EndIf
	
	cHtml += '  </form>'+CRLF
	cHtml += '</div>'+CRLF

	SM0->(dbGoTo(nRegSM0))
	cFilAnt := SM0->M0_CODFIL

Else
	cMsgHdr		:= "BEP0203 - Sess�o n�o Iniciada"
	cMsgBody	:= "A sess�o n�o foi iniciada, realize o Login!"
	cRetFun		:= "u_BePLogin.apw"

	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
EndIf
	
cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END

Return (EncodeUTF8(cHtml))