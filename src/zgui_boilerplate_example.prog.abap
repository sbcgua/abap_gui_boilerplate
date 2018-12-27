report zgui_boilerplate_example.

include zgui_boilerplate.
include zmustache.
include zmustache_ut.

class lcl_home_component definition final.
  public section.
    interfaces zif_abapgit_gui_page.

    constants:
      begin of c_action,
        say_hello type string value 'say_hello',
      end of c_action.

    class-methods create
      returning
        value(ro_component) type ref to lcl_home_component.
endclass.

class lcl_home_component implementation.

  method zif_abapgit_gui_page~render.
    create object ro_html.
    ro_html->add( '<h1>Hello world</h1>' ).
    ro_html->add( '<img src="img/test.png" alt="test">' ).
    ro_html->add_a(
      iv_txt = 'Say hello'
      iv_act = c_action-say_hello
      iv_typ = zif_abapgit_definitions=>c_action_type-sapevent
      iv_opt = zif_abapgit_definitions=>c_html_opt-strong ).
    ro_html->add( |<div>{ ro_html->a(
      iv_txt = 'Go to page 2'
      iv_act = 'goto-page2'
      iv_typ = zif_abapgit_definitions=>c_action_type-sapevent
    ) }</div>| ).
  endmethod.

  method zif_abapgit_gui_page~on_event.
    ev_state = zif_abapgit_definitions=>c_event_state-not_handled.
    case iv_action.
      when c_action-say_hello.
        message 'Hello !' type 'S'.
        ev_state = zif_abapgit_definitions=>c_event_state-no_more_act.
    endcase.
  endmethod.

  method create.
    create object ro_component.
  endmethod.

endclass.


class lcl_table_component definition final.
  public section.
    interfaces zif_abapgit_gui_page.

    types:
      begin of ty_tab,
        name type string,
        value type string,
      end of ty_tab,
      tt_tab type standard table of ty_tab with key name,
      begin of ty_slug,
        items type tt_tab,
      end of ty_slug.

    class-methods create
      returning
        value(ro_component) type ref to lcl_table_component.
  private section.
    methods get_data
      returning
        value(rs_slug) type ty_slug.
endclass.

class lcl_table_component implementation.

  method get_data.

    data ls_data like line of rs_slug-items.

    ls_data-name = 'Hello'.
    ls_data-value = 'World!'.
    append ls_data to rs_slug-items.
    ls_data-name = 'Hello'.
    ls_data-value = 'User!'.
    append ls_data to rs_slug-items.


*    types:
*      begin of ty_tab,
*        name type string,
*        value type string,
*      end of ty_tab.
*
*    data lt_data type standard table of ty_tab.
*    data ls_data type ty_tab.
*
*    ls_data-name = 'Hello'.
*    ls_data-value = 'World!'.
*    append ls_data to lt_data.
*    ls_data-name = 'Hello'.
*    ls_data-value = 'User!'.
*    append ls_data to lt_data.
*
*    data ls_slug like line of rt_slug.
*
*    ls_slug-name = 'items'.
*    get reference of lt_data into ls_slug-dref.
*    append ls_slug to rt_slug.

  endmethod.

  method zif_abapgit_gui_page~render.

    data lo_asset_man type ref to zif_abapgit_gui_asset_manager.
    lo_asset_man ?= lcl_gui=>get_asset_man( ).

    create object ro_html.

    data lv_template type string.
    data lv_out type string.
    lv_template = lo_asset_man->get_text_asset( 'templates/table.mustache' ).

    try .
      data lo_mustache type ref to lcl_mustache.
      lo_mustache = lcl_mustache=>create( lv_template ).
      lv_out = lo_mustache->render( get_data( ) ).
    catch lcx_mustache_error.
      zcx_abapgit_exception=>raise( 'Error rendering table component' ).
    endtry.

    ro_html->add( lv_out ).

  endmethod.

  method zif_abapgit_gui_page~on_event.
  endmethod.

  method create.
    create object ro_component.
  endmethod.

endclass.


class lcl_gui_router definition final.
  public section.
    interfaces zif_abapgit_gui_router.
endclass.

class lcl_gui_router implementation.
  method zif_abapgit_gui_router~on_event.
    case iv_action.
      when zcl_abapgit_gui=>c_action-go_home.
        ei_page  = lcl_page_hoc=>wrap(
          iv_page_title = 'Home page'
          ii_child      = lcl_home_component=>create( ) ).
        ev_state = zif_abapgit_definitions=>c_event_state-new_page.
      when 'goto-page2'.
        ei_page  = lcl_page_hoc=>wrap(
          iv_page_title = 'Page 2'
          ii_child      = lcl_table_component=>create( ) ).
        ev_state = zif_abapgit_definitions=>c_event_state-new_page.
    endcase.
  endmethod.
endclass.

class lcl_app definition final.
  public section.
    methods run
      raising
        zcx_abapgit_exception.
  private section.
    class-methods create_asset_manager
      returning
        value(ro_asset_man) type ref to zcl_abapgit_gui_asset_manager.

endclass.

class lcl_app implementation.

  method create_asset_manager.
    " used by abapmerge
    define _inline.
      append &1 to lt_data.
    end-of-definition.

    data lt_inline type string_table.

    create object ro_asset_man type zcl_abapgit_gui_asset_manager.

    clear lt_inline.
    " @@abapmerge include zgui_boilerplate_css_common.w3mi.data.css > _inline '$$'.
    ro_asset_man->register_asset(
      iv_url       = 'css/common.css'
      iv_type      = 'text/css'
      iv_mime_name = 'ZGUI_BOILERPLATE_CSS_COMMON'
      iv_inline    = concat_lines_of( table = lt_inline sep = cl_abap_char_utilities=>newline ) ).

    clear lt_inline.
    " @@abapmerge include zgui_boilerplate_js_common.w3mi.data.js > _inline '$$'.
    ro_asset_man->register_asset(
      iv_url       = 'js/common.js'
      iv_type      = 'text/javascript'
      iv_mime_name = 'ZGUI_BOILERPLATE_JS_COMMON'
      iv_inline    = concat_lines_of( table = lt_inline sep = cl_abap_char_utilities=>newline ) ).

    clear lt_inline.
    " @@abapmerge include zgui_boilerplate_example_tab.w3mi.data.mustache > _inline '$$'.
    ro_asset_man->register_asset(
      iv_url       = 'templates/table.mustache'
      iv_type      = 'text/plain'
      iv_mime_name = 'ZGUI_BOILERPLATE_EXAMPLE_TAB'
      iv_inline    = concat_lines_of( table = lt_inline sep = cl_abap_char_utilities=>newline ) ).

    ro_asset_man->register_asset(
      iv_url       = 'img/test.png'
      iv_type      = 'image/png'
      iv_base64    =
           'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQ'
        && 'U1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAADhSURBVDhPzZJbzgFBEEYnER'
        && '7EZQP8tiHEcty2I35W4LICYi+uwSI8cb7umXSmpwkPEic56SpplZqqjr5BB5d4xVt8LrC'
        && 'NL8njFLfYwxoW4rOPexxjDoNMcIUlk2XR72tUkQxqe4dFkznu8ZlQwSNmPkff3LVhCr+A'
        && 'GODchg4Nqm7DFKECunexoUPT1sB8QgV0T/dTfNJBAzMdaM9a3TsMcWZDh6Z6wLLJHH4HV'
        && 'dS9lsk8tF/t2S+SoBVucGSyAHph/3hCvbw/1MB0anXav/789CUmqD3tWYPStM9x3sSfI4'
        && 'oe3YcrMuOWvQgAAAAASUVORK5CYII=' ).

  endmethod.

  method run.

    data:
      li_router    type ref to zif_abapgit_gui_router.




    create object li_router type lcl_gui_router.
    lcl_gui=>run_gui(
      ii_router    = li_router
      ii_asset_man = create_asset_manager( ) ).

    " Call ALV with dummy data
      " prepare dummy data
      " create ALV, pass data, fill column names
      " add buttons, assign handler
      " display alv
    " On button -> show html
      " create router
      " assign dummy page

  endmethod.

endclass.

selection-screen begin of block b1 with frame title txt_b1.
selection-screen begin of line.
selection-screen comment (24) t_dir for field p_dir.
parameters p_dir type char255 visible length 40.
selection-screen end of line.
selection-screen end of block b1.

form init.
  txt_b1   = 'Program params'.        "#EC NOTEXT
  t_dir    = 'Param 1'.               "#EC NOTEXT
endform.

form main.

  data lx_exception type ref to zcx_abapgit_exception.
  data lo_app type ref to lcl_app.

  try.
    create object lo_app.
    lo_app->run( ).
  catch zcx_abapgit_exception into lx_exception.
    message lx_exception type 'E'.
  endtry.

endform.                    "run

initialization.
  perform boilerplate_init.
  perform init.

start-of-selection.
  perform main.
