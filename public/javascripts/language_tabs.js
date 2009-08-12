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

    $('current_language_tab').value = language;
}


function add_language_tab_menu() {
    i18n_all_languages.each( function(s, index) {
      if( i18n_active_languages.indexOf( s) < 0) {
        $("modal_language_select_"+s).show();
      }
      else {
        $("modal_language_select_"+s).hide();
      }
    });
    Lightbox.showBoxByID('language_select_modal_dialog', 500, 300);
}
