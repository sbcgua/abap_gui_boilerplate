**********************************************************************
* lcl_salv_agent, lcl_salv_enabler
* code based on Naimesh Patel (aka zevolving) example
* http://zevolving.com/2015/06/salv-table-21-editable-with-single-custom-method/

class lcl_salv_agent definition inheriting from cl_salv_model_base.
  public section.
    class-methods:
      get_grid
        importing
          io_salv_model type ref to cl_salv_model
        returning
          value(ro_gui_alv_grid) type ref to cl_gui_alv_grid
        raising
          cx_salv_msg.
endclass.

class lcl_salv_agent implementation.
  method get_grid.
    data:
     lo_grid_adap type ref to cl_salv_grid_adapter,
     lo_fs_adap   type ref to cl_salv_fullscreen_adapter,
     lo_root      type ref to cx_root.

    try.
      lo_grid_adap ?= io_salv_model->r_controller->r_adapter.
    catch cx_root into lo_root.
      try. "could be fullscreen adaptper
        lo_fs_adap ?= io_salv_model->r_controller->r_adapter.
      catch cx_root into lo_root.
        raise exception type cx_salv_msg
          exporting
            previous = lo_root
            msgid    = '00'
            msgno    = '001'
            msgty    = 'E'
            msgv1    = 'Check PREVIOUS exception'.
      endtry.
    endtry.

    if lo_grid_adap is not initial.
      ro_gui_alv_grid = lo_grid_adap->get_grid( ).
    elseif lo_fs_adap is not initial.
      ro_gui_alv_grid = lo_fs_adap->get_grid( ).
    else.
      raise exception type cx_salv_msg
        exporting
          msgid = '00'
          msgno = '001'
          msgty = 'W'
          msgv1 = 'Adapter is not bound yet'.
    endif.
  endmethod.

endclass.

class lcl_salv_enabler definition final.

  public section.

    types:
      begin of ty_tracked,
        salv type ref to cl_salv_table,
        buttons type ttb_button,
      end of ty_tracked.

    class-methods toggle_toolbar
      importing
        io_salv    type ref to cl_salv_table
        it_buttons type ttb_button.

    class-methods get_grid
      importing
        io_salv_model type ref to cl_salv_model
      returning
        value(ro_grid) type ref to cl_gui_alv_grid
      raising
        cx_salv_error.

    methods:
      on_after_refresh
        for event after_refresh of cl_gui_alv_grid
        importing sender,
      on_toolbar
        for event toolbar of cl_gui_alv_grid
        importing e_object e_interactive sender.

  private section.
    data mt_tracked_salv type standard table of ty_tracked.
    class-data go_event_handler type ref to object.

endclass.

CLASS lcl_salv_enabler IMPLEMENTATION.

  method get_grid.
    data lo_error type ref to cx_salv_msg.
    if io_salv_model->model ne if_salv_c_model=>table.
      raise exception type cx_salv_msg
        exporting
          msgid = '00'
          msgno = '001'
          msgty = 'E'
          msgv1 = 'Incorrect SALV Type'.
    endif.
    ro_grid = lcl_salv_agent=>get_grid( io_salv_model ).
  endmethod.                    "GET_GRID

  method toggle_toolbar.

    if lcl_salv_enabler=>go_event_handler is not bound.
      create object lcl_salv_enabler=>go_event_handler type lcl_salv_enabler.
    endif.

    data lo_event_handler type ref to lcl_salv_enabler.
    lo_event_handler ?= lcl_salv_enabler=>go_event_handler.

    if lines( lo_event_handler->mt_tracked_salv ) = 0.
      set handler lo_event_handler->on_after_refresh
        for all instances
        activation 'X'.
      set handler lo_event_handler->on_toolbar
        for all instances
        activation 'X'.
    endif.

    field-symbols <t> like line of lo_event_handler->mt_tracked_salv.
    append initial line to lo_event_handler->mt_tracked_salv assigning <t>.
    <t>-salv    = io_salv.
    <t>-buttons = it_buttons.

  endmethod.                    "set_editable

  method on_after_refresh.
    data lo_grid   type ref to cl_gui_alv_grid.
    data ls_layout type lvc_s_layo.
    data lv_idx  type i.
    field-symbols <t> like line of mt_tracked_salv.

    try.
      loop at mt_tracked_salv assigning <t>.
        lv_idx = sy-tabix.
        lo_grid = lcl_salv_enabler=>get_grid( <t>-salv ).
        check lo_grid eq sender.
        lo_grid->get_frontend_layout( importing es_layout = ls_layout ).
        ls_layout-no_toolbar = ''.
        lo_grid->set_frontend_layout( ls_layout ).
        delete mt_tracked_salv index lv_idx.
      endloop.
    catch cx_salv_error.
      return.
    endtry.

    if lines( mt_tracked_salv ) = 0.
      set handler me->on_after_refresh " deregister the event handler
        for all instances
        activation space.
      set handler me->on_toolbar " deregister the event handler
        for all instances
        activation space.
    endif.

  endmethod.

  method on_toolbar.

    data lo_grid type ref to cl_gui_alv_grid.
    field-symbols <t> like line of mt_tracked_salv.

    try.
      loop at mt_tracked_salv assigning <t>.
        lo_grid = lcl_salv_enabler=>get_grid( <t>-salv ).
        if lo_grid eq sender.
          append lines of <t>-buttons to e_object->mt_toolbar.
          exit.
        endif.
      endloop.
    catch cx_salv_msg cx_salv_error.
      return.
    endtry.

  endmethod.

endclass.

**********************************************************************
* sample ALV base class
*

class lcl_view_base definition abstract.
  public section.
    methods display abstract
      raising lcx_guibp_error.

    methods on_user_command abstract
      importing
        iv_cmd type char70.

    methods on_double_click abstract
      importing
        iv_row    type salv_de_row
        iv_column type salv_de_column.

    methods close.

    methods handle_double_click
      for event double_click of cl_salv_events_table
      importing row column.

    methods on_alv_user_command
      for event added_function of cl_salv_events
      importing e_salv_function.

    methods update_content
      importing
        it_contents type any table.

  protected section.
    data mo_alv type ref to cl_salv_table.
    data mr_data type ref to data.

    methods set_column_tech_names.

    methods set_default_layout
      importing
        iv_title type lvc_title.

    methods set_default_handlers.

    methods set_sorting
      importing
        iv_fields type any
      raising
        lcx_guibp_error.

    methods set_toolbar
      importing
        it_buttons type ttb_button.

    methods copy_content
      importing
        it_contents type any table.

    methods create_alv
      raising lcx_guibp_error.

endclass.

class lcl_view_base implementation.

  method create_alv.

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
      lcx_guibp_error=>raise( lx_alv->get_text( ) ).
    endtry.

  endmethod.

  method set_column_tech_names.

    data lo_cols type ref to cl_salv_columns.
    data lt_columns type salv_t_column_ref.

    lo_cols = mo_alv->get_columns( ).
    lo_cols->set_optimize( abap_true ).
    lt_columns = lo_cols->get( ).

    field-symbols <c> like line of lt_columns.
    loop at lt_columns assigning <c>.
      <c>-r_column->set_short_text( |{ <c>-columnname }| ).
      <c>-r_column->set_medium_text( |{ <c>-columnname }| ).
      <c>-r_column->set_long_text( |{ <c>-columnname }| ).
    endloop.

  endmethod.

  method set_default_layout.

    data lo_functions type ref to cl_salv_functions_list.
    lo_functions = mo_alv->get_functions( ).
    lo_functions->set_default( abap_true ).

    data lo_display type ref to cl_salv_display_settings.
    lo_display = mo_alv->get_display_settings( ).
    lo_display->set_striped_pattern( abap_true ).
    lo_display->set_list_header( iv_title ).

  endmethod.

  method set_sorting.

    data lx_alv    type ref to cx_salv_error.
    data lo_sorts  type ref to cl_salv_sorts.
    data lt_fields type string_table.
    data lv_ftype  type c.
    data lv_fld    type string.
    field-symbols <sorts> type string_table.

    describe field iv_fields type lv_ftype.
    lo_sorts = mo_alv->get_sorts( ).

    try.
      if lv_ftype ca 'Cg'. " Value, assume char like
        split iv_fields at ',' into table lt_fields.
        assign lt_fields to <sorts>.
      elseif lv_ftype = 'h'. " Table, assume string table
        assign iv_fields to <sorts>.
      else.
        lcx_guibp_error=>raise( 'Wrong sorting parameter' ).
      endif.

      loop at <sorts> into lv_fld.
        lv_fld = to_upper( lv_fld ).
        condense lv_fld.
        check lv_fld is not initial.
        lo_sorts->add_sort( |{ lv_fld }| ).
      endloop.
    catch cx_salv_error into lx_alv.
      lcx_guibp_error=>raise( lx_alv->get_text( ) ).
    endtry.

  endmethod.

  method set_toolbar.
    lcl_salv_enabler=>toggle_toolbar(
      io_salv    = mo_alv
      it_buttons = it_buttons ).
  endmethod.

  method set_default_handlers.

    data lo_event type ref to cl_salv_events_table.
    lo_event = mo_alv->get_event( ).
    set handler handle_double_click for lo_event.
    set handler on_alv_user_command for lo_event.

  endmethod.

  method on_alv_user_command.
    on_user_command( e_salv_function ).
  endmethod.

  method handle_double_click.
    on_double_click( iv_row = row iv_column = column ).
  endmethod.

  method close.
    mo_alv->close_screen( ).
  endmethod.

  method copy_content.

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

  method update_content.
    copy_content( it_contents ).
    mo_alv->refresh( ).
  endmethod.

endclass.
