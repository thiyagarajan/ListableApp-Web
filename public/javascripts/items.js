$(document).ready(function() {

  var completeItem = function(item) {
    $.ajax({
        type: "POST",
        url: '/lists/' + $('#listId').text() + '/items/' + item.id,
        data: { _method: 'PUT', item : { completed : !item.completed } },
        dataType: 'json',
        success: function(msg) {
          clearLists();
          reloadLists();
        }
    });
  };

  var deleteItem = function(item) {
    $.ajax({
        type: "POST",
        url: '/lists/' + $('#listId').text() + '/items/' + item.id,
        data: { _method: 'DELETE' },
        dataType: 'json',
        success: function(msg) {
          clearLists();
          reloadLists();
        }
    });
  };

  var itemTextFor = function(item) {
    var item_state = item.completed ? "completed" : "active";

    var tag = '<li class="list_item">';
    if ( !item.completed ) {
      tag += '<img src="/images/handle.png" alt="Drag to reorder" height="32" width="16" class="handleImage" title="Drag to reorder this list item" />';
    }

    var toggle_item_verb = item.completed ? "uncomplete" : "complete";

    return tag +
      '<img src="/images/' + item_state + '.png" height="20" width="20" class="complete_box" title="Click to ' + toggle_item_verb + ' this list item" />' +
      '<input type="checkbox" class="' + item_state + 'ListItemCheckbox" name="list_item_' + item.id + '_checkbox" value="selected" title="Select to apply bulk actions to this list item using the selected box above" />' +
      '<span class ="list_item_name" id="editable_item_' + item.id + '_name">' +
      item.name +
      '</span>' +
      '<img src="/images/garbage.png" alt="Delete this list item" height="23" width="23" class="delete_box" title="Click to delete this list item" />' +
      '</li>';
  };
    
  var clearLists = function() {
    $('.item_list').text('');  
  };

  var populatePageWith = function(data) {
    var completed_items = 0;
    var active_items    = 0;

    $.each(data, function(i, item) {
      var item_state = item.completed ? "completed" : "active";

      $("#" + item_state + "_items").find('ul').append(itemTextFor(item));
      $("#" + item_state + "_items ul li:last-child").data('item', item);

      var editable_item_name = "#editable_item_" + item.id + "_name";
      $(editable_item_name).editable('/lists/' + $('#listId').text() + '/items/' + item.id + '.json', {
        submit   : 'OK',
        cancel   : 'Cancel',
        type     : 'textarea',
        indicator: 'Saving...',
        tooltip  : 'Click to edit this list item',
        width    : '350px',
        callback : function(response) { $(editable_item_name).html(jQuery.parseJSON(response).name ) },
        name     : 'item[name]',
        method   : 'PUT',
        onblur   : 'ignore'
      });

      item.completed ? completed_items++ : active_items++;
    });

    $('#active_item_count').html('(' + active_items + ')');
    $('#completed_item_count').html('(' + completed_items + ')');

    $(".complete_box").bind('click', function() {
      completeItem($(this).parent('li').data('item'));
    });

    $(document.body).data('activeItemsSelected', false);
    $(document.body).data('completedItemsSelected', false);

    $(".delete_box").bind('click', function() {
      var answer = confirm("Are you sure you wish to delete this item?");

      if (answer) {
        deleteItem($(this).parent('li').data('item'));
        return false;
      }
    });

    $('#sortable').sortable('refresh');
  };

  var reloadLists = function() {
    if ( $('#listId').text() != "" ) {
      // Load the lists from JSON and construct them in the lists section dynamically
      $.getJSON('/lists/' + $('#listId').text() + '/items.json', function(data) {
        populatePageWith(data);
      });
    }
  };

  $("#sortable").sortable({
    handle : 'img.handleImage',
    axis : 'y'
  });

  $("#sortable").disableSelection();

  // Sortable list processing
  $("#sortable").bind( "sortupdate", function(event, ui) {
    var itemIds = $('ul#sortable li');
    var itemOrder = new Array();

    for (var i = 0; i < itemIds.length; i++) {
      itemOrder[i] = $(itemIds[i]).data('item').id;
    }

    $.post('/list_order', {
      list_id : $('#listId').text(),
      authenticity_token : $('#authToken').text(),
      items : itemOrder
    });
  });

  reloadLists();
  
  $('.list_title').editable('/lists/' + $('#listId').text() + '.json', {
    submit  : 'OK',
    cancel  : 'Cancel',
    tooltip : 'Click to edit this list title',
    width   : 260,
    callback: function(response) { $( '.list_title').html(jQuery.parseJSON(response).name ) },
    name    : 'list[name]',
    method  : 'PUT'
  });

  $('#sortAction').change(function() {
    var selectedValue = $('#sortAction option:selected').text();
    $.getJSON('/lists/' + $('#listId').text() + '/items.json?sort=' + selectedValue +
                          '&keyword=' + $('#filterListTextField').val(), function(data) {
      clearLists();
      populatePageWith(data);
    });
    
    return false;
  });

  $('#addItemForm').hide();

  $('#addItemCancel').click(function(){
    $('#addItemButton').show();
    $('#addItemForm').hide();
    $('#listItems').focus();
  });

  $("#newItemName").bind('keyup', 'esc', function() {
    $('#addItemButton').show();
    $('#addItemForm').hide();
  });

  var revealAddItemForm = function() {
    $('#addItemForm').show();
    $('#addItemButton').hide();
    $("#newItemName").focus();
  };

  $('#addItemButton').click(function() {
    revealAddItemForm();
  });

  $(document).bind('keyup', 'a', function(){
    revealAddItemForm();
  });

  // Accepts 'active' or 'completed' as toggle section
  var toggleSelectedState = function(sectionToToggle) {
    var newSelectedState = !$(document.body).data(sectionToToggle + 'ItemsSelected');
    var checkBoxes = $("." + sectionToToggle + "ListItemCheckbox");
    
    for (var i = 0; i < checkBoxes.length; i++) {
      $(checkBoxes[i]).attr('checked', newSelectedState);
    }

    $(document.body).data(sectionToToggle + 'ItemsSelected', newSelectedState);
    return false;
  };

  $("#selectActiveItems").click(function(){
    toggleSelectedState('active');
  });

  $("#selectCompletedItems").click(function(){
    toggleSelectedState('completed');  
  });

  var submitForm = function() {
    var itemName = $('#newItemName').val();
    var listId = $('#listId').text();
    var authToken = $('#authToken').text();

    var hideNewItemForm = function(data) {
      $('#addItemButton').show();
      $('#addItemForm').hide();
      $('#newItemName').val('');
    };
      
    var successFunction = function(data) {
      hideNewItemForm();
      clearLists();
      reloadLists();
    };

    var errorFunction = function(xhr, ajaxOptions, thrownError) {
      alert('Item save failed.');
    };

    if (!itemName.length == 0) {
      $.ajax({
        url: '/lists/' + listId + '/items',
        type: "POST",
        data: { item : { name: itemName } },
        success: successFunction,
        error: errorFunction
      });
    } else {
      hideNewItemForm();
      alert('Unable to create item with empty name.');
    }

    return false;
  };

  $('#addItemSubmit').click(submitForm);
  $('#newItemForm').submit(submitForm);

  var delayed;
  $('#filterListTextField').keyup(function() {
       clearTimeout(delayed);
       var value = this.value;
       delayed = setTimeout(function() {
         var selectedValue = $('#sortAction option:selected').text();
         $.getJSON('/lists/' + $('#listId').text() + '/items.json?sort=' + selectedValue +
                               '&keyword=' + $('#filterListTextField').val(), function(data) {
           clearLists();
           populatePageWith(data);
         });
       }, 900);
  });

  $('#selectedAction').change(function() {

    var selectedValue = $('#selectedAction option:selected').text();

    var checkedItems = $(':checkbox:checked');
    var selectedItemIds = new Array();
    for (var i = 0; i < checkedItems.length ; i++) {
      selectedItemIds[i] = $(checkedItems[i]).parent('li').data('item').id;
    }

    var reloadItemsFunction = function() {
      clearLists();
      reloadLists();
    };

    $.ajax({
      url: '/lists/' + $('#listId').text() + '/bulk_update',
      type: "PUT",
      data: { apply : selectedValue, items : selectedItemIds, authenticity_token : $('#authToken').text() },
      success: reloadItemsFunction
    });

    return false;
  });
});
