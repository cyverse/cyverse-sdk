$(function(){
  $('#giflist li a img').hover(function(){
    var customdata = $(this).parent().attr('href');
    $(this).attr('src',customdata); 
  }, function(){
    $(this).attr('src',$(this).attr('data-orig'));
  });
});
