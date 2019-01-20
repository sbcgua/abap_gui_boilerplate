form exit raising zcx_abapgit_exception.
  case sy-ucomm.
    when 'CBAC'.  "back
      if sy-dynnr = '1001' and lcl_gui=>get_gui( )->back( ) is initial.
        leave to screen 1001.
      endif.
  endcase.
endform.

form remove_toolbar using pv_dynnr type char4.

  data: ls_header               type rpy_dyhead,
        lt_containers           type dycatt_tab,
        lt_fields_to_containers type dyfatc_tab,
        lt_flow_logic           type swydyflow.

  call function 'RPY_DYNPRO_READ'
    exporting
      progname             = sy-cprog
      dynnr                = pv_dynnr
    importing
      header               = ls_header
    tables
      containers           = lt_containers
      fields_to_containers = lt_fields_to_containers
      flow_logic           = lt_flow_logic
    exceptions
      cancelled            = 1
      not_found            = 2
      permission_error     = 3
      others               = 4.
  if sy-subrc is not initial.
    return. " ignore errors, just exit
  endif.

  if ls_header-no_toolbar = abap_true.
    return. " no change required
  endif.

  ls_header-no_toolbar = abap_true.

  call function 'RPY_DYNPRO_INSERT'
    exporting
      header                 = ls_header
      suppress_exist_checks  = abap_true
    tables
      containers           = lt_containers
      fields_to_containers = lt_fields_to_containers
      flow_logic           = lt_flow_logic
    exceptions
      cancelled              = 1
      already_exists         = 2
      program_not_exists     = 3
      not_executed           = 4
      missing_required_field = 5
      illegal_field_value    = 6
      field_not_allowed      = 7
      not_generated          = 8
      illegal_field_position = 9
      others                 = 10.
  if sy-subrc <> 2 and sy-subrc <> 0.
    return. " ignore errors, just exit
  endif.

endform.

form hide_standard_buttons.

  if sy-dynnr <> '1001'.
    return.
  endif.

  perform set_pf_status in program rsdbrunt if found.

  data lt_ucomm type table of sy-ucomm.
  append 'CRET' to lt_ucomm.  "button execute
  append 'SPOS' to lt_ucomm.  "button save

  call function 'RS_SET_SELSCREEN_STATUS'
    exporting
      p_status  = sy-pfkey
    tables
      p_exclude = lt_ucomm.

endform.

form boilerplate_init.

  DATA: lt_ucomm TYPE TABLE OF sy-ucomm.

  PERFORM set_pf_status IN PROGRAM rsdbrunt IF FOUND.

  APPEND 'CRET' TO lt_ucomm.  "Button Execute
  APPEND 'SPOS' TO lt_ucomm.  "Button Save

  CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
    EXPORTING
      p_status  = sy-pfkey
    TABLES
      p_exclude = lt_ucomm.

  perform remove_toolbar using '1001'. " remove toolbar on html screen
endform.
