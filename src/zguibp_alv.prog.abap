class lcl_view_base definition abstract.
  public section.
    methods display abstract
      raising lcx_guibp_error.

    methods on_user_command abstract
      importing
        iv_cmd type char70
      returning
        value(rv_processed) type abap_bool.

    methods on_output.
    methods close.

  protected section.
    data mo_alv type ref to cl_salv_table.

    class-methods set_columns
      importing
        io_alv type ref to cl_salv_table.

endclass.

class lcl_view_base implementation.
  method on_output.
  endmethod.

  method set_columns.

    data lo_cols type ref to cl_salv_columns.
    data lt_columns type salv_t_column_ref.

    lo_cols = io_alv->get_columns( ).
    lo_cols->set_optimize( abap_true ).
    lt_columns = lo_cols->get( ).

    field-symbols <c> like line of lt_columns.
    loop at lt_columns assigning <c>.
      <c>-r_column->set_short_text( |{ <c>-columnname }| ).
      <c>-r_column->set_medium_text( |{ <c>-columnname }| ).
      <c>-r_column->set_long_text( |{ <c>-columnname }| ).
    endloop.

  endmethod.  " set_columns.

  method close.
    mo_alv->close_screen( ).
  endmethod.

endclass.

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
    class-methods toggle_toolbar
      importing
        io_salv type ref to cl_salv_table.
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
    data mt_tracked_salv type standard table of ref to cl_salv_table.
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
    data lo_event_handler type ref to lcl_salv_enabler.

    if lcl_salv_enabler=>go_event_handler is not bound.
      create object lcl_salv_enabler=>go_event_handler type lcl_salv_enabler.
    endif.

    lo_event_handler ?= lcl_salv_enabler=>go_event_handler.
    append io_salv to lo_event_handler->mt_tracked_salv.

    set handler lo_event_handler->on_after_refresh
      for all instances
      activation 'X'.
    set handler lo_event_handler->on_toolbar
      for all instances
      activation 'X'.

  endmethod.                    "set_editable

  method on_after_refresh.
    data lo_grid   type ref to cl_gui_alv_grid.
    data ls_layout type lvc_s_layo.
    data lo_salv   type ref to cl_salv_table.

    try.
      loop at mt_tracked_salv into lo_salv.
        lo_grid = lcl_salv_enabler=>get_grid( lo_salv ).
        check lo_grid eq sender.

        set handler me->on_after_refresh " deregister the event handler
          for all instances
          activation space.

        lo_grid->get_frontend_layout( importing es_layout = ls_layout ).
        ls_layout-no_toolbar = ''.
        lo_grid->set_frontend_layout( ls_layout ).
      endloop.
    catch cx_salv_error.
    endtry.
  endmethod.

  method on_toolbar.

    data lo_grid    type ref to cl_gui_alv_grid.
    data lt_toolbar type ttb_button.
    data ls_toolbar like line of lt_toolbar.
    data lo_salv    type ref to cl_salv_table.

    try.
      loop at mt_tracked_salv into lo_salv.
        lo_grid = lcl_salv_enabler=>get_grid( lo_salv ).
        if lo_grid eq sender.
          exit.
        else.
          clear lo_grid.
        endif.
      endloop.
    catch cx_salv_msg cx_salv_error.
      return.
    endtry.

    if lo_grid is not bound.
      return.
    endif.

    set handler me->on_toolbar " deregister the event handler
      for all instances
      activation space.


    " Sort default
    clear ls_toolbar.
    ls_toolbar-function  = cl_gui_alv_grid=>mc_fc_sort_asc.
    ls_toolbar-quickinfo = 'SORT'.
    ls_toolbar-icon      = icon_sort_down.
    ls_toolbar-disabled  = space.
    append ls_toolbar to lt_toolbar.

    " toolbar seperator
    clear ls_toolbar.
    ls_toolbar-function  = '&&sep01'.
    ls_toolbar-butn_type = 3.
    append ls_toolbar to lt_toolbar.

    " Custom command
    clear ls_toolbar.
    ls_toolbar-function  = 'ZCUSTOM'.
    ls_toolbar-quickinfo = 'Custom command'.
    ls_toolbar-icon      = icon_failure.
    ls_toolbar-disabled  = space.
    ls_toolbar-text      = 'Hello'.
    append ls_toolbar to lt_toolbar.

    append lines of lt_toolbar to e_object->mt_toolbar.

  endmethod.

endclass.
