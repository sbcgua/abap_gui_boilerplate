report zguibp_example_alv.

include zguibp_error.
include zguibp_alv.
include zguibp_html.
include zguibp_example_common.
include zguibp_example_component.

class lcl_gui_router definition final.
  public section.
    interfaces zif_abapgit_gui_router.
    class-methods create
      importing
        iv_payload type string
      returning
        value(ro_router) type ref to lcl_gui_router.
  private section.
    data mv_payload type string.
endclass.

class lcl_gui_router implementation.
  method create.
    create object ro_router.
    ro_router->mv_payload = iv_payload.
  endmethod.

  method zif_abapgit_gui_router~on_event.
    case iv_action.
      when zcl_abapgit_gui=>c_action-go_home.
        ei_page  = lcl_page_hoc=>wrap(
          iv_page_title = 'Home page'
          ii_child      = lcl_hello_component=>create( iv_name = mv_payload ) ).
        ev_state = zcl_abapgit_gui=>c_event_state-new_page.
    endcase.
  endmethod.
endclass.

class lcl_html_view definition final.
  public section.
    methods run
      importing
        iv_payload type string
      raising
        lcx_guibp_error.
endclass.

class lcl_html_view implementation.
  method run.
    lcl_gui_factory=>init(
      ii_router    = lcl_gui_router=>create( iv_payload )
      ii_asset_man = lcl_common_parts=>create_asset_manager( ) ).
    lcl_gui_factory=>run( ).
  endmethod.
endclass.

class lcl_content_view definition final inheriting from lcl_view_base.
  public section.

    methods constructor
      importing
        it_contents type any table.

    methods display redefinition.
    methods on_user_command redefinition.
    methods on_double_click redefinition.

  private section.
    methods build_toolbar
      returning
        value(rt_buttons) type ttb_button.

endclass.

class lcl_content_view implementation.

  method constructor.
    super->constructor( ).
    copy_content( it_contents ).
  endmethod.

  method display.

    create_alv( ).
    set_column_tech_names( ).
    set_default_handlers( ).
    set_default_layout( 'My view' ).
    set_sorting( 'NAME' ).
    set_toolbar( build_toolbar( ) ).
    mo_alv->display( ).

  endmethod.

  method on_user_command.

    data lv_msg type string.
    lv_msg = |User asked { iv_cmd }|.
    message lv_msg type 'I'.

  endmethod.                    "on_user_command

  method on_double_click.

    field-symbols <tab> type standard table.
    field-symbols <line> type any.
    assign mr_data->* to <tab>.
    read table <tab> assigning <line> index iv_row.

    field-symbols <name> type string.
    assign component 'NAME' of structure <line> to <name>.

    data lo_html type ref to lcl_html_view.
    data lx type ref to lcx_guibp_error.
    create object lo_html.
    try .
      lo_html->run( <name> ).
    catch lcx_guibp_error into lx.
      message lx type 'E' display like 'S'.
    endtry.

  endmethod.

  method build_toolbar.

    data ls_toolbar like line of rt_buttons.

    " Sort default
    clear ls_toolbar.
    ls_toolbar-function  = cl_gui_alv_grid=>mc_fc_sort_asc.
    ls_toolbar-quickinfo = 'SORT'.
    ls_toolbar-icon      = icon_sort_down.
    ls_toolbar-disabled  = space.
    append ls_toolbar to rt_buttons.

    " toolbar seperator
    clear ls_toolbar.
*    ls_toolbar-function  = '&&sep01'.
    ls_toolbar-butn_type = 3.
    append ls_toolbar to rt_buttons.

    " Custom command
    clear ls_toolbar.
    ls_toolbar-function  = 'ZCUSTOM'.
    ls_toolbar-quickinfo = 'Custom command'.
    ls_toolbar-icon      = icon_failure.
    ls_toolbar-disabled  = space.
    ls_toolbar-text      = 'Hello'.
    append ls_toolbar to rt_buttons.

  endmethod.

endclass.

**********************************************************************

class lcl_app definition final.
  public section.

    types:
      begin of ty_my_type,
        name type string,
        year type numc4,
        amount type dmbtr,
      end of ty_my_type,
      tt_my_type type standard table of ty_my_type with default key.

    methods run
      raising
        lcx_guibp_error.

    methods prepare_data
      returning value(rt_data) type tt_my_type.
endclass.

class lcl_app implementation.
  method prepare_data.

    field-symbols <i> like line of rt_data.

    append initial line to rt_data assigning <i>.
    <i>-name = 'Vasya'.
    <i>-year = '2014'.
    <i>-amount = '1234.10'.
    append initial line to rt_data assigning <i>.
    <i>-name = 'Grysha'.
    <i>-year = '2008'.
    <i>-amount = '10234.10'.
    append initial line to rt_data assigning <i>.
    <i>-name = 'Kostya'.
    <i>-year = '1999'.
    <i>-amount = '80034.10'.

  endmethod.

  method run.
    data lo_alv type ref to lcl_content_view.
    create object lo_alv exporting it_contents = prepare_data( ).
    lo_alv->display( ).
  endmethod.
endclass.

include zguibp_example_run.
