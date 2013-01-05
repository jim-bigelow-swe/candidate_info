
CONTRIBSINFO = {
    setup: function() {
        // construct new DOM elements
        $('<label for="filter" class="explanation">' +
          'Restrict to elected officials' +
          '</label>' +
          '<input type="checkbox" id="filter"/>'
         ).insertBefore('#contributions').change(CONTRIBSINFO.filter_not_elected);
    },
    filter_not_elected: function () {
        // 'this' is element that received event (checkbox)
        if ($(this).is(':checked')) {
            $('#contributions tbody tr').each(CONTRIBSINFO.hide_if_not_elected_row);
        } else {
            $('#contributions tbody tr').show();
        };
    },
    hide_if_not_elected_row: function() {
        $('#contributions tr.notelected').hide();
    }
}
$(CONTRIBSINFO.setup);       // when document ready, run setup code