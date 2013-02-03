
CANDINFO = {
    setup: function() {
        // construct new DOM elements
        //$('<label for="filter" class="explanation">' +
        //  'Restrict to elected officials' +
        //  '</label>' +
        //  '<input type="checkbox" id="filter"/>'
        // ).insertBefore('#candidates').change(CANDINFO.filter_not_elected);
        // add invisible 'div' to end of page:
        $('<div id="contributionInfo"></div>').
            hide().
            appendTo($('body'));
        $('#candidates a.list_contribs').click(CANDINFO.getContributionList);
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
    },
    getContributionList: function() {
        $.ajax({type: 'GET',
                url: $(this).attr('href'),
                timeout: 5000,
                success: CANDINFO.showContributionList,
                error: function() { alert('Error!'); }
               });
        return(false);
    },
    showContributionList: function(data) {
        // center a floater 1/2 as wide and 1/4 as tall as screen
        var oneFourth = Math.ceil($(window).width() / 4);
        $('#contributionInfo').
            html(data).
            css({'left': oneFourth,  'width': 2*oneFourth, 'top': 250}).
            show();
        // make the Close link in the hidden element work
        $('#closeLink').click(CANDINFO.hideContributionList);
        return(false);  // prevent default link action
    },
    hideContributionList: function() {
        $('#contributionInfo').hide(); 
        return(false);
    },
}
$(CANDINFO.setup);       // when document ready, run setup code