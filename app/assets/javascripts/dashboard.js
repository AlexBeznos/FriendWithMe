$( document ).ready(function() {
  $('#collapseTable').on('shown.bs.collapse', function () {
    var height = $('.message-off').height() + 3;
    $('.message-on').css('min-height', height);
  });

  $('#collapseTable').on('hide.bs.collapse', function () {
    $('.message-on').css('min-height', 0);
  });
});
