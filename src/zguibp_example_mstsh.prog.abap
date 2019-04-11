report zguibp_example_mstsh.

include zguibp_error.
include zguibp_html.
include zguibp_example_common.

class lcl_mustache_component definition final.
  public section.
    interfaces zif_abapgit_gui_renderable.
    class-methods create
      returning
        value(ro_component) type ref to lcl_mustache_component.

  private section.
    methods build_data
      returning
        value(ro_data) type ref to object. "ref to zcl_mustache_data.
endclass.

class lcl_mustache_component implementation.

  method build_data. " Create some dummy data

    types:
      begin of ty_tab,
        name type string,
        value type string,
      end of ty_tab.

    data lt_tab type table of ty_tab.
    field-symbols <i> like line of lt_tab.

    append initial line to lt_tab assigning <i>.
    <i>-name  = 'Some'.
    <i>-value = 'Data'.
    append initial line to lt_tab assigning <i>.
    <i>-name  = 'In'.
    <i>-value = 'Table'.

    create object ro_data type ('ZCL_MUSTACHE_DATA').
    call method ro_data->('ADD')
      exporting
        iv_name = 'username'
        iv_val  = sy-uname.
    call method ro_data->('ADD')
      exporting
        iv_name = 'items'
        iv_val  = lt_tab.

*    ro_data->add( iv_name = 'username' iv_val = sy-uname ).
*    ro_data->add( iv_name = 'items'    iv_val = lt_tab ).

  endmethod.

  method zif_abapgit_gui_renderable~render.

    data lo_asset_man type ref to zif_abapgit_gui_asset_manager.
    data lv_template type string.
    data lv_out type string.
    data lo_data type ref to object. " ref to zcl_mustache_data.

    lo_asset_man ?= lcl_gui_factory=>get_asset_man( ).
    lv_template   = lo_asset_man->get_text_asset( 'templates/table.mustache' ).
    lo_data       = build_data( ).
    create object ro_html type zcl_abapgit_html.

    try .
      data lo_mustache type ref to object. " ref to zcl_mustache.

      call method ('ZCL_MUSTACHE')=>('CREATE')
        exporting
          iv_template = lv_template
        receiving
          ro_instance = lo_mustache.

*      lo_mustache = zcl_mustache=>create( lv_template ).

      call method lo_mustache->('RENDER')
        exporting
          i_data = lo_data
        receiving
          rv_text = lv_out.

*      lv_out = lo_mustache->render( lo_data->get( ) ).
    catch cx_static_check. " zcx_mustache_error.
      zcx_abapgit_exception=>raise( 'Error rendering table component' ).
    endtry.

    ro_html->add( lv_out ).

  endmethod.

  method create.
    create object ro_component.
  endmethod.

endclass.

**********************************************************************
* APP
**********************************************************************

class lcl_app definition final.
  public section.
    methods run
      raising
        lcx_guibp_error.
endclass.

class lcl_app implementation.
  method run.
    data lv_version_fits type abap_bool.

    call method ('ZCL_MUSTACHE')=>('CHECK_VERSION_FITS')
      exporting
        i_required_version = 'v2.0.0'
      receiving
        r_fits = lv_version_fits.

*    if zcl_mustache=>check_version_fits( 'v2.0.0' ) = abap_false.
    if lv_version_fits = abap_false.
      write: / 'Please update mustache library the version is too low.'.
      return.
    endif.

    data li_page type ref to zif_abapgit_gui_renderable.
    li_page ?= lcl_page_hoc=>wrap(
      iv_add_styles = 'css/example.css'
      iv_page_title = 'Mustache page'
      ii_child      = lcl_mustache_component=>create( ) ).
    lcl_gui_factory=>init(
      io_component = li_page
      ii_asset_man = lcl_common_parts=>create_asset_manager( ) ).
    lcl_gui_factory=>run( ).
  endmethod.
endclass.

include zguibp_example_run.
