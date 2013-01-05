
CANDINFO = {
    setup: function() {
        // construct new DOM elements
        $('<label for="filter" class="explanation">' +
          'Restrict to elected officials' +
          '</label>' +
          '<input type="checkbox" id="filter"/>'
         ).insertBefore('#candidates').change(CANDINFO.filter_not_elected);
    },
    filter_not_elected: function () {
        // 'this' is element that received event (checkbox)
        if ($(this).is(':checked')) {
            $('#candidates tbody tr').each(CANDINFO.hide_if_not_elected_row);
        } else {
            $('#candidates tbody tr').show();
        };
    },
    hide_if_not_elected_row: function() {
        if ( /^No/i.test($(this).find('td:nth-child(1)').text())) {
            $(this).hide();
        }
    }
}
$(CANDINFO.setup);       // when document ready, run setup code