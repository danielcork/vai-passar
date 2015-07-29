var dados_previsor;
var array_teste;
var dict_voto = { 'a': '2',
'b':'1',
'c':'0'
};




function abre_dados() { // Carrega dados do previsor
    d3.csv("dados/previsto.csv", function(dados) {
        dados_previsor = dados
    });
    array_teste = {pt: "2",
	gov: "2",
	minoria: "2",
	pmdb: "2",
	pp: "2",
	prb: "2",
	psb: "2",
	psd: "2",
	psdb: "2",
	dem: "2"};
    
}


abre_dados();

function descobre_resultado(escolhido) { // Função recebe variáveis escolhidas e devolve o resultado no banco
	var partidos=Object.keys(dados_previsor[0]);
	partidos.pop();

	dados_totais = dados_previsor;
	for ( var item in partidos ) {
		indexado = partidos[item];
		dados_totais= $.grep(dados_totais, function(n, i) { return n[indexado]===escolhido[indexado]; })
	}
	return dados_totais[0];
}



function le_escolhido() { // Função lê dados escolhidos e retorna array informando-os
	var escolhido={};
	var classes_escolhido=[];
	var partidos_escolhido=[];
	$('#opcoes dd').each(function(i, n) {
		classe = $(n).attr('class');
		classes_escolhido.push(classe);
	});
	$('#opcoes dt').each(function(i, n) {
		partidos_escolhido.push($(n).attr('id'));
		// console.log(teste[0]);
		
	});
	for (var i in partidos_escolhido) {
		party = partidos_escolhido[i];
		classi = classes_escolhido[i];
		if ( ( party =='pt' || party == 'gov' )  &&  classi=='b' ) { // Special Workaround
			escolhido[party]=dict_voto['a'];
		}
		else {
			escolhido[party]=dict_voto[classi];		
		}
	}	
	return escolhido;

}



function acerta_chances() {
	var escolhido=le_escolhido();
	resultado=descobre_resultado(escolhido)["resultado"];
	return resultado;
}



