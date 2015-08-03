var menuOpen = false;

function clicaMenu() {
	$( "#menu-hamburguer" ).click(function() {
		if (menuOpen == false) {
			$('#capa').addClass('menu-content');
			$('#menu-overlay').fadeIn('fast');
			menuOpen = true;
		} else {
			$('#capa').removeClass('menu-content');
			$('#menu-overlay').fadeOut('fast');
			menuOpen = false;
		}
	});
}

$(document).ready(function() {
	clicaMenu();
	ShareController();

	$('#shareBar > a').click(function(event) {
    	event.preventDefault();
  	});

  	$(window).load(function() {
  		$('body').removeClass('loading');

  		$('#slider').prepend('<span class="blankmark ui-slider-handle ui-state-default ui-corner-all" tabindex="0" style="left: 0%;"></span><span class="blankmark ui-slider-handle ui-state-default ui-corner-all" tabindex="0" style="left: 50%;"></span><span class="blankmark ui-slider-handle ui-state-default ui-corner-all" tabindex="0" style="left: 100%;"></span>');

  		$('#capa .loader').one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend',   
		    function(e) {
		    	$('#capa').addClass('menu');
		    	setTimeout(function(){ 
		    		$('html, body').css({ overflow: 'auto' }); 
		    	},1501);
			});
  	});
});



$(document).ready(function () {

    var menu = $('.barra_e_texto');
    var origOffsetY = menu.offset().top;

    function scroll() {
        var scrollBottom = $(window).scrollTop() + $(window).height();

        if (scrollBottom < origOffsetY) {
            menu.addClass('navbar-fixed-bottom');
        } else {
            menu.removeClass('navbar-fixed-bottom');
        }
    }

    document.onscroll = scroll;

});
