<?php 
  /* Grupo de variáveis obrigatórias */
  $OAS_SITEPAGE = "estadao2014/infograficos/especiais/previsor-parlamentar";
  $OAS_LISTPOS = "Position1,x17,x01";
?>
<!DOCTYPE html>
<html lang="pt-br">
	<head>
		<?php include "includes/seo.php"; ?>
		<?php include "includes/styles.php"; ?>
		<?php include "head_header.php"; ?> <!-- QUANDO SUBIR NO SERVIDOR, ADICIONAR: /var/www/html/infograficos/public/geral/include/X.php -->
	</head>
	<body class="loading">
		<?php include "body_header.php"; ?> <!-- QUANDO SUBIR NO SERVIDOR, ADICIONAR: /var/www/html/infograficos/public/geral/include/X.php -->

    <section id="capa">
      <?php include "includes/nav.php"; ?>
    </section>
    
    <section id="content">
      <h1>Previsor<br>Parlamentar</h1>

      <select>
        <option>PROJETO DE LEI</option>
        <option value="MP665">MP665</option>
        <option value="MPXXX">MPXXX</option>
        <option value="MPYYY">MPYYY</option>
        <option value="MPZZZ">MPZZZ</option>
        <option value="MPKKK">MPKKK</option>
        <option value="MPWWW">MPWWW</option>
      </select>

   <!--
      <select>
        <option>PARTIDO</option>
        <option value="PT">PT</option>
        <option value="PMDB">PMDB</option>
        <option value="PSDB">PSDB</option>
        <option value="PSol">PSol</option>
        <option value="PTB">PTB</option>
        <option value="PCdoB">PCdoB</option>
      </select>
-->
      <div class="projeto-info">
        <h5>Lorem Ipsum</h5>
        <p>
          Dunt alibus modit el illores sitatis et estrum quas sinctur acerovidusa vendae pro tet quist endipitiis il mos et molorecab id qui tessimillest quis dolorest delitatque voluptatus sita dis doluptatus, suntio to velis est, ulpari occae quis dolorest delitatque  porest, se cuptas rerati tem aut magnihit laborporum rerati tem.
        </p>
      </div>

      <div class="projeto-info" id="como-vota">
        <h5>Defina como votam os partidos</h5>
        <!--
        <div id="slider"></div>
          <p id="amount"></p>
        -->
        <section id="opcoes">
          <dl>
            <dt id="pt">PT</dt>
            <dd class="b"></dd>
            
            <dt id="psdb">PSDB</dt>
            <dd class="b"></dd>
            
            <dt id="pcdob">PCdoB</dt>
            <dd class="b"></dd>
            
            <dt id="psol">PSOL</dt>
            <dd class="b"></dd>
            
            <dt id="pmdb">PMDB</dt>
            <dd class="b"></dd>
            
            <dt id="dem">DEM</dt>
            <dd class="b"></dd>
            
            <dt id="PCB">PCB</dt>
            <dd class="b"></dd>
            
            <dt id="pv">PV</dt>
            <dd class="b"></dd>
          </dl>
        </section>
      </div>
      <div style="clear:both"></div>
          <div class="knob-wrap">
              <p class="chances">As chances do governo</p>
              <p class="porcentagem">%</p>
              <a class="tooltips" href="#">|
                <span>Governo Ganhará</span>
              </a>
              <input class="knob" data-width="260" data-height="260" value="0" data-fgColor="#666666" data-thickness=".05" data-angleOffset="180" data-readOnly="true">
          </div>
      <div style="clear:both"></div>

    </section>

    <section id="chart">
      <img src="img/grafico-fake.png">
    </section>

  <?php include "includes/scripts.php"; ?>
  <script>
      $('#opcoes dl').click(function() {
        var porcentagemFake = Math.floor(Math.random()*100);
        $('.knob')
            .val(porcentagemFake)
            .trigger('change');
      });
    </script>

     <script>
        var cor;

            $(function($) {

                $(".knob").knob({
                    change : function (value) {
                        //console.log("change : " + value);
                    },
                    release : function (value) {
                        //console.log(this.$.attr('value'));
                        console.log("release : " + value);

                        if (value > 50) { 
                          cor = '#00884e';
                          $('.tooltips span').css('visibility', 'visible');
                        } else {
                          cor = '#666666';
                          $('.tooltips span').css('visibility', 'hidden');
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
        </script>
  <?php include "body_footer.php"; ?> <!-- QUANDO SUBIR NO SERVIDOR, ADICIONAR: /var/www/html/infograficos/public/geral/include/X.php -->
</body>
</html>