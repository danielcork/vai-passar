$( document ).ready(function() {

    /**
     * Created by rodrigoburg on 30/07/15.
     */
    var partidos = {
        "PT": "#BE003E",
        "PSDB": "#634600",
        //"DEM": "#9A740F",
        "PMDB": "#3A3A8B",
        "PSD": "#7BAC39",
        //"PP": "#5E196F",
        //"PRB": "#98007F",
        //"PSB": "#0066A4",
        "Geral": "gray"
    }

    //funcao pra fakeclick
    var fakeClick = function(target) {
        var event = document.createEvent('MouseEvents');
        event.initMouseEvent('click');
        target.dispatchEvent(event);
    };

    //funcao pra pegar ultimo elemento no d3.selectAll
    d3.selection.prototype.last = function() {
        var last = this.size() - 1;
        return d3.select(this[0][last]);
    };

    //agora comecamos no d3
    var dados;

    var margin = {
            top: 20,
            right: 20,
            bottom: 30,
            left: 30
        },
        width = $("#content").width() - margin.left - margin.right,
        height = 500 - margin.top - margin.bottom;

    var parseDate = d3.time.format("%Y-%m-%d").parse;

    var x = d3.time.scale()
        .range([0, width]);

    var y = d3.scale.linear()
        .range([height, 0]);

    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom")
        .tickFormat(d3.time.format("%m/%y"));

    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left");

    var line = d3.svg.line()
        .x(function(d) {
            return x(d.date);
        })
        .y(function(d) {
            return y(d.valor);
        })
        .interpolate("cardinal");

    var svg = d3.select("#grafico_pe").append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    //coloca um retangulo branco
    svg.append("rect")
        .attr("width",width+20)
        .attr("height",height)
        .style("fill","white");

    d3.json("dados/hist_dilma_camara_2.json", function(error, data) {
        if (error) throw error;

        //salva dados em variavel global
        dados = data;

        //arruma datas
        for (key in dados) {
            dados[key].forEach(function(d) {
                d.date = parseDate(d.date);
            });
        }

        //pegamos una das datas só para criarmos maximo e minimo
        var data = dados["Geral"];

        //maximo e minimo
        x.domain(d3.extent(data, function(d) {
            return d.date;
        }));
        y.domain([0,100]);


        //coloca eixos
        svg.append("g")
            .transition()
            .duration(500)
            .attr("class", "x axis")
            .attr("transform", "translate(0," +( height )+ ")")
            .style("background-color","white")
            .call(xAxis);

        svg.append("g").transition()
            .duration(500)
            .attr("class", "y axis")
            .call(yAxis);

            cria_seletores_tooltip()
        for (partido in partidos) {
            desenha_linha(partido);
        }

        //finge que clicou no ultimo geral para preencher a tooltip
        fakeClick(d3.selectAll("circle.Geral").last()[0][0])});

    function cria_seletores_tooltip() {
        tooltip = d3.select(".tooltip");
        topo = d3.select("#topo");
        resto = d3.select("#resto");
    }

    function desenha_linha(variavel) {
        var data = dados[variavel];

        svg.append("path")
            .datum(data)
            .attr("class", "line " + variavel)
            .attr("d", line)
            .style("stroke","lightgray")
            .style("opacity",0.5)
            .on("click", function () {
                poe_destaque(variavel);
                var x_ = d3.mouse(this)[0];
                var d = acha_circulo_mais_proximo(variavel,x_);
                    mostra_tooltip(d,variavel);
            })
            .on("mouseover", function () {
                poe_destaque(variavel);
                var x_ = d3.mouse(this)[0];
                var d = acha_circulo_mais_proximo(variavel,x_);
                mostra_tooltip(d,variavel);
            })
            .on("mouseout",function (d) {
                if (variavel != "Geral") {
                    tira_destaque(variavel);
                }
            })

        svg.append("g")
            .selectAll("circle")
            .data(data)
            .enter()
            .append("circle")
            .attr("cx", function (d) {
                return x(d.date);
            })
            .attr("cy", function (d) {
                return y(d.valor);
            })
            .attr("class", "circle " + variavel)
            .attr("r", 5)
            .style("opacity",0.1)
            .style("fill","light-gray")

            .on("mouseover",function (d) {
                poe_destaque(variavel);
                mostra_tooltip(d,variavel);
            })
            .on("click", function (d) {
                poe_destaque(variavel);
                mostra_tooltip(d,variavel);
            })
            .on("mouseout",function (d) {
                if (variavel != "Geral") {
                    tira_destaque(variavel);
                }
            })
    }

    function poe_destaque(variavel) {
        d3.selectAll("circle."+variavel)
            .style("fill",function (d) {
                return partidos[variavel]
            })
            .style("opacity",0.9);

        d3.selectAll("path."+variavel)
            .style("stroke",function (d) {
                return partidos[variavel]
            })
            .style("opacity",0.9);
    }

    function tira_destaque(variavel) {
        d3.selectAll("circle."+variavel)
            .style("fill","lightgray")
            .style("opacity",0.5);

        d3.selectAll("path."+variavel)
            .style("stroke","lightgray")
            .style("opacity",0.5);
    }

    function mostra_tooltip(d,variavel) {
        tooltip.transition()
            .duration(200)
            .style("opacity", .9);

        tooltip.style("border-color",partidos[variavel])
        topo.html(variavel)
        topo.style("background-color",partidos[variavel])
        var dateObj = d.date;
        var month = dateObj.getUTCMonth() + 1; //months from 1-12
        var year = dateObj.getUTCFullYear();
        resto.html("<b>Data:</b> "+ month +"/" +year+"<br/><b>Governismo:</b> "+ d.valor)
    }

    function acha_circulo_mais_proximo(variavel,x_) {
        var maximo = width;
        var objeto;
        d3.selectAll("circle."+variavel).each(function (d) {
            var distancia = Math.abs(d3.select(this).attr("cx") - x_);
            if (distancia < maximo) {
                maximo = distancia;
                objeto = d;
            }
        })
        return objeto
    }
});