var dados_previsor;
var cor;
var dict_voto = { 'a': '0',
'b':'1',
'c':'2'
};



function abre_dados() { // Carrega dados do previsor
    d3.csv("dados/previsto.csv", function(dados) {
        dados_previsor = dados;
   //     setTimeout(muda_valores,500); // Parece que encontramos um workaround
    });
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

function muda_valores() {
    var valor = acerta_chances()*100;
    $('.knob')
        .val(valor)
        .trigger('change');
}

$('#opcoes dl').click(function() {
    muda_valores();
});

function barraCor(value) {
    progressbar = $('#progressbar');
    progressbarValue = progressbar.find( ".ui-progressbar-value" );
    if (value > 70) {
        cor = '#00884e';
        progressbarValue.css({
            "background": cor
        });
    }
    else if ( value < 30 ) {
        cor = '#e80000';
        progressbarValue.css({
            "background": cor
        });
    }
    else {
        cor = '#666666';
        progressbarValue.css({
            "background": cor
        });
    }

}
function barraValor(value) {
    var progressbar = $( "#progressbar" ),
        progressLabel = $( ".progress-label" );
    progressLabel.text( Math.round(value) + "%" );
}


$(function($) {
    $(".knob").knob({
        format : function (value) {
            return value + '%';
        },  
        change : function (value) {
            //console.log("change : " + value);
        },
        release : function (value) {
            //console.log(this.$.attr('value'));
            // console.log("release : " + value);

            if (value > 60) {
                cor = '#00884e';

            }
            else if ( value < 40 ) {
                cor = '#b71067';
            }
            else {
                cor = '#666666';
            }

            $('.knob').trigger(
                'configure',
                {
                    "fgColor": cor
                }
            );
            $('.knob, .porcentagem').css('color', cor);
        },
        cancel : function () {
            console.log("cancel : ", this);
        },
        /*format : function (value) {
         return value + '%';
         },*/
        draw : function () {

            // "tron" case
            if(this.$.data('skin') == 'tron') {

                this.cursorExt = 0.3;

                var a = this.arc(this.cv)  // Arc
                    , pa                   // Previous arc
                    , r = 1;

                this.g.lineWidth = this.lineWidth;

                if (this.o.displayPrevious) {
                    pa = this.arc(this.v);
                    this.g.beginPath();
                    this.g.strokeStyle = this.pColor;
                    this.g.arc(this.xy, this.xy, this.radius - this.lineWidth, pa.s, pa.e, pa.d);
                    this.g.stroke();
                }

                this.g.beginPath();
                this.g.strokeStyle = r ? this.o.fgColor : this.fgColor ;
                this.g.arc(this.xy, this.xy, this.radius - this.lineWidth, a.s, a.e, a.d);
                this.g.stroke();

                this.g.lineWidth = 2;
                this.g.beginPath();
                this.g.strokeStyle = this.o.fgColor;
                this.g.arc( this.xy, this.xy, this.radius - this.lineWidth + 1 + this.lineWidth * 2 / 3, 0, 2 * Math.PI, false);
                this.g.stroke();

                return false;
            }
        }
    });

    // Example of infinite knob, iPod click wheel
    var v, up=0,down=0,i=0
        ,$idir = $("div.idir")
        ,$ival = $("div.ival")
        ,incr = function() { i++; $idir.show().html("+").fadeOut(); $ival.html(i); }
        ,decr = function() { i--; $idir.show().html("-").fadeOut(); $ival.html(i); };
    $("input.infinite").knob(
        {
            min : 0
            , max : 20
            , stopper : false
            , change : function () {
            if(v > this.cv){
                if(up){
                    decr();
                    up=0;
                }else{up=1;down=0;}
            } else {
                if(v < this.cv){
                    if(down){
                        incr();
                        down=0;
                    }else{down=1;up=0;}
                }
            }
            v = this.cv;
        }
        });
});



