var dados_previsor;
var array_teste;
var dict_voto { 'a': 0,
'b':1,
'c':2
};



function abre_dados() { // Carrega dados do previsor
    d3.csv("dados/previsto.csv", function(dados) {
        dados_previsor = dados
    });
    array_teste = {dem: "2",
	gov: "2",
	minoria: "2",
	pmdb: "2",
	pp: "2",
	prb: "2",
	psb: "2",
	psd: "2",
	psdb: "2",
	pt: "2"};
    
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
	return dados_totais;
}

function le_escolhido() { // Função lê dados escolhidos e retorna array informando-os
	var escolhido={};
	
}



