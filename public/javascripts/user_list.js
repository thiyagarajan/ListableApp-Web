$(document).ready(function(){
    
    $("#movable-user-list").sortable({
        handle : $('li'),
        axis : 'y'
      });

   $("#movable-user-list").disableSelection();
    
    $("#movable-user-list").bind('sortupdate', function(event, ui) {
        var listIds = $('.activeLists');
        var listOrder = new Array();

        for (var i = 0; i < listIds.length; i++) {
          listOrder[i] = $(listIds[i]).attr('id');
        }

        $.post('/user_list_order', {
            'movable-user-list': listOrder
        });
    });

});