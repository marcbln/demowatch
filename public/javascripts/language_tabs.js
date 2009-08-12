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

function remove_language_tab( lang) {
  $('language_tab_' + lang).remove();
  $('translation_container_' + lang).remove();
  i18n_active_languages = i18n_active_languages.without( lang);
  switch_language_tab( i18n_active_languages[0]);
  check_add_language_button();
}

function check_add_language_button() {
  if( i18n_active_languages.length >= i18n_all_languages.length) {
    $('add_language_button').hide();
  }
  else {
    $('add_language_button').show();
  }
}
