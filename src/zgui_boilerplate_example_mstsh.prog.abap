report zgui_boilerplate_example_mstsh.

include zguibp_boilerplate.
include zguibp_example_lib.
include zmustache.

class lcl_mustache_component definition final.
  public section.
    interfaces zif_abapgit_gui_page.

    types:
      begin of ty_tab,
        name type string,
        value type string,
      end of ty_tab,
      tt_tab type standard table of ty_tab with key name.

    class-methods create
      returning
        value(ro_component) type ref to lcl_mustache_component.
  private section.
    methods get_data
      returning
        value(ro_slug) type ref to lcl_mustache_data.
endclass.

class lcl_mustache_component implementation.

  method get_data.

    data lt_tab type tt_tab.
    field-symbols <i> like line of lt_tab.

    append initial line to lt_tab assigning <i>.
    <i>-name = 'Some'.
    <i>-value = 'Data'.
    append initial line to lt_tab assigning <i>.
    <i>-name = 'In'.
    <i>-value = 'Table'.

    data lo_data type ref to lcl_mustache_data.
    create object lo_data.

    lo_data->add( iv_name = 'username' iv_val = sy-uname ).
    lo_data->add( iv_name = 'items' iv_val = lt_tab ).

  endmethod.

  method zif_abapgit_gui_page~render.

    data lo_asset_man type ref to zif_abapgit_gui_asset_manager.
    lo_asset_man ?= lcl_gui=>get_asset_man( ).

    create object ro_html.

    data lv_template type string.
    data lv_out type string.
    lv_template = lo_asset_man->get_text_asset( 'templates/table.mustache' ).



    data lt_tab type tt_tab.
    field-symbols <i> like line of lt_tab.

    append initial line to lt_tab assigning <i>.
    <i>-name = 'Some'.
    <i>-value = 'Data'.
    append initial line to lt_tab assigning <i>.
    <i>-name = 'In'.
    <i>-value = 'Table'.

    data lo_data type ref to lcl_mustache_data.
    create object lo_data.

    lo_data->add( iv_name = 'username' iv_val = sy-uname ).
    lo_data->add( iv_name = 'items' iv_val = lt_tab ).



    try .
      data lo_mustache type ref to lcl_mustache.
      lo_mustache = lcl_mustache=>create( lv_template ).
*      lv_out = lo_mustache->render( get_data( ) ).
      lv_out = lo_mustache->render( lo_data->get( ) ).
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
          iv_page_title = 'Mustache page'
          ii_child      = lcl_mustache_component=>create( ) ).
        ev_state = zcl_abapgit_gui=>c_event_state-new_page.
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
