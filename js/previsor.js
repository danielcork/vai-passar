var dados_previsor;


function abre_dados() {
    d3.csv("dados/previsto.csv", function(dados) {
        dados_previsor = dados
    })
}
