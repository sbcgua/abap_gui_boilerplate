report zgui_boilerplate_example.

include zgui_boilerplate.
include zmustache.
include zmustache_ut.

include zgui_boilerplate_example_lib.

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
    class-methods create
      returning
        value(ro_router) type ref to lcl_gui_router.
endclass.

class lcl_gui_router implementation.
  method create.
    create object ro_router.
  endmethod.
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
endclass.

class lcl_app implementation.

  method run.

    lcl_gui=>run_gui(
      ii_router    = lcl_gui_router=>create( )
      ii_asset_man = lcl_common_parts=>create_asset_manager( ) ).

    " scenario todo
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
