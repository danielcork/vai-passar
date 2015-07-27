var ShareController = function(){
  
  var $this = this;
  var urlToShare = $('meta[property="og:url"]').attr('content');
  
  $('.btFbShare').sharrre({
    share: {
      facebook: true
    },
    enableHover: false,
    enableTracking: true,
    template: '<span>{total}</span>',
    url: urlToShare,
    click: function(api, options){
      //api.simulateClick();
      api.openPopup('facebook');
    }
  });
  $('.btGPlusShare').sharrre({
    share: {
      googlePlus: true
    },
    urlCurl: 'http://infograficos.estadao.com.br/geral/libs/sharrre.php',
    enableHover: false,
    enableTracking: true,
    template: '<span>{total}</span>',
    url: urlToShare,
    click: function(api, options){
      //api.simulateClick();
      api.openPopup('googlePlus');
    }
  });
  $('.btTwitterShare').sharrre({
    share: {
      twitter: true
    },
    enableHover: false,
    enableTracking: true,
    template: '<span>{total}</span>',
    url: urlToShare,
    click: function(api, options){
      //api.simulateClick();
      api.openPopup('twitter');
    }
  });
}