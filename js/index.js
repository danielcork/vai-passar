
var markup = '<span></span><span></span><span></span><a></a><p></p>';
var txt    = ['Contra', 'Neutro', 'A favor']
var cur, el, aim, x1, x2, y1, y2, pressed;

// inicia
$('#opcoes dd').each(function(){
  $(this).html(markup);
  cur = $(this).attr('class');
  if (cur == 'a') { aim = 0; }
  if (cur == 'b') { aim = 1; }
  if (cur == 'c') { aim = 2; }
  label($(this),aim);
});

// muda o nome
function label(el,n) {
  el.find('p').html(txt[n]);
}

// muda a classe
function muda(el) {
  cur = el.attr('class');
  el.removeClass();
  if (cur == 'a' ) { el.addClass('b'); aim = 1; }
  if (cur == 'b' ) { el.addClass('c'); aim = 2; }
  if (cur == 'c' ) { el.addClass('a'); aim = 0; }
  label(el,aim);
}

// idenficia se estou 'hovering' no touch
function touchOver(x, y) {
    $('#opcoes dd span').each(function() {
      if (!(
          x <= $(this).offset().left || x >= $(this).offset().left + $(this).width() ||
          y <= $(this).offset().top  || y >= $(this).offset().top + $(this).height()
      )) {
        el = $(this).parent();
        aim = $(this).index();
        el.removeClass();
        if (aim == 0 ) { el.addClass('a'); }
        if (aim == 1 ) { el.addClass('b'); }
        if (aim == 2 ) { el.addClass('c'); }
        label(el,aim);
      }
    });
}

// identifica quando soltou o mouse
$('#opcoes dd span').on('mousedown mouseup', function(e) {
  el = $(this).parent();
  aim = $(this).index();
  el.removeClass();
  if (aim == 0 ) { el.addClass('a'); }
  if (aim == 1 ) { el.addClass('b'); }
  if (aim == 2 ) { el.addClass('c'); }
  label(el,aim);
  pressed = false;
});

// identifica quando clicou no label (texto) 
$('#opcoes dd p').click(function() {
  if (!pressed) {
    el = $(this).parent();
    muda(el);
  }
});

// identifica quando clicou no partido (texto) 
$('#opcoes dt').click(function() {
  if (!pressed) {
    el = $(this).next();
    muda(el);
  } 
});

// identifica se o 'drag' foi horizontal
function horizontal() {
  if (Math.abs(x1 - x2) > Math.abs(y1 - y2)) { return true } 
  else { return false }
}

// teste de 'drag'
$('#opcoes dd span').on('mousedown', function(e) {
  pressed = true;
  el = $(this).parent();
  x1 = e.pageX;
  y1 = e.pageY;
});

// quando solto o botão do mouse
$(document).on('mouseup', function(e) {
  if (pressed) {
    if (!$(event.target).closest('#opcoes dd span').length) {
        x2 = e.pageX;
        y2 = e.pageY;
        if (x1 > x2) { // arrastou para <-- 
          if (horizontal()) {
            el.removeClass().addClass('a');
            label(el,0);
          }
        } else { // arrastou para -->
          if (horizontal()) {
            el.removeClass().addClass('c');
            label(el,2);
          }
        } 
    }
  }
  pressed = false;
});

// quando passar o mouse por cima e estiver pressionando o botão do mouse
$('#opcoes dd span').hover(function(e) {
  if (pressed) {
      el = $(this).parent();
      aim = $(this).index();
      el.removeClass();
      if (aim == 0 ) { el.addClass('a'); }
      if (aim == 1 ) { el.addClass('b'); }
      if (aim == 2 ) { el.addClass('c'); }
      label(el,aim);
  }
});

// idenficia se estou 'hovering' no touch
$('#opcoes').bind("touchmove", function(e){
  var touch = e.originalEvent.touches[0]
  touchOver(touch.clientX, touch.clientY);
});

// as of 1.4.2 the mobile safari reports wrong values on offset()
// http://dev.jquery.com/ticket/6446
// remove once it's fixed
if ( /webkit.*mobile/i.test(navigator.userAgent)) {
  (function($) {
      $.fn.offsetOld = $.fn.offset;
      $.fn.offset = function() {
        var result = this.offsetOld();
        result.top -= window.scrollY;
        result.left -= window.scrollX;
        return result;
      };
  })(jQuery);
}
