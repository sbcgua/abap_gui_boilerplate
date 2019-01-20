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

    methods handle_double_click
      for event double_click of cl_salv_events_table
      importing row column.

    methods on_alv_user_command
      for event added_function of cl_salv_events
      importing e_salv_function.

    methods on_before_salv_function
      for event before_salv_function of cl_salv_events
      importing e_salv_function.

    methods update_data
      importing
        it_contents type any table.

    events mock_selected exporting value(mock_name) type string.
    events request_mock_delete exporting value(mock_name) type string.

  private section.
    data mr_data type ref to data.

    methods acqure_content
      importing
        it_contents type any table.

endclass.

class lcl_content_view implementation.

  method acqure_content.

    data lo_ttype type ref to cl_abap_tabledescr.
    data lo_stype type ref to cl_abap_structdescr.

    if mr_data is initial.
      lo_ttype ?= cl_abap_typedescr=>describe_by_data( it_contents ).
      lo_stype ?= lo_ttype->get_table_line_type( ).
      lo_ttype = cl_abap_tabledescr=>create( lo_stype ). "ensure standard table
      create data mr_data type handle lo_ttype.
    endif.

    field-symbols <tab> type standard table.
    assign mr_data->* to <tab>.
    <tab> = it_contents.

  endmethod.

  method constructor.
    super->constructor( ).
    acqure_content( it_contents ).
  endmethod.

  method display.
    data lx_alv type ref to cx_salv_error.
    field-symbols <tab> type standard table.
    assign mr_data->* to <tab>.

    try.
      cl_salv_table=>factory(
        importing
          r_salv_table = mo_alv
        changing
          t_table      = <tab> ).
    catch cx_salv_msg into lx_alv.
      write / 'Error'.
    endtry.

    set_columns( mo_alv ).

    data: lo_functions type ref to cl_salv_functions_list.
    lo_functions = mo_alv->get_functions( ).
*    lo_functions->set_default( abap_true ).
*    lo_functions->get_flavour( ).
*    mo_alv->set_screen_status( report = sy-cprog pfstatus = 'CONTENTS_VIEW' ).

    data: lo_display type ref to cl_salv_display_settings.
    lo_display = mo_alv->get_display_settings( ).
    lo_display->set_striped_pattern( 'X' ).
    lo_display->set_list_header( 'My view' ).

    data lo_event type ref to cl_salv_events_table.
    lo_event = mo_alv->get_event( ).
    set handler handle_double_click for lo_event.
    set handler on_alv_user_command for lo_event.
    set handler on_before_salv_function for lo_event.

*    data lo_sorts type ref to cl_salv_sorts.
*    lo_sorts = mo_alv->get_sorts( ).

*    try.
*      lo_sorts->add_sort( 'FOLDER' ).
*      lo_sorts->add_sort( 'NAME' ).
*    catch cx_salv_error into lx_alv.
*      lcx_error=>raise( lx_alv->get_text( ) ).
*    endtry.

    lcl_salv_enabler=>toggle_toolbar( mo_alv ).

    mo_alv->display( ).
  endmethod.

  method on_alv_user_command.
    on_user_command( e_salv_function ).
  endmethod.

  method on_user_command.
    data lv_msg type string.
    lv_msg = |User asked { iv_cmd }|.
    message lv_msg type 'S'.
  endmethod.                    "on_user_command

  method on_before_salv_function.
    data vvv type i.
    vvv = 1.
  endmethod.

  method handle_double_click.

    field-symbols <tab> type standard table.
    field-symbols <line> type any.
    assign mr_data->* to <tab>.
    read table <tab> assigning <line> index row.

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

  method update_data.
    acqure_content( it_contents ).
    mo_alv->refresh( ).
  endmethod.

endclass.



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
