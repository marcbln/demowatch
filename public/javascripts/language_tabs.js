function switch_language_tab( language) {
    /* switch tabs */
    i18n_all_languages.each( function(l) {
        var t = $('language_tab_' + l);
        if( t) {
            t.removeClassName('tab_active');
            t.addClassName('tab_inactive');
        }
    })
    var t = $('language_tab_' + language);
    t.removeClassName('tab_inactive');
    t.addClassName('tab_active');

    /* switch content */
    i18n_active_languages.each( function(l) {
        var d = $('translation_container_' + l);
        if( d) {
            if( l == language) {
                d.show();
            }
            else {
                d.hide();
            }
        }
    })
}


function add_language_tab_menu() {
    Lightbox.showBoxByID('language_select_modal_dialog', 500, 300);
}
