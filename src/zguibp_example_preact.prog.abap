report zguibp_example_preact.

include zguibp_error.
include zguibp_html.
include zguibp_example_common.

class lcl_preact_page definition final.
  public section.
    interfaces zif_abapgit_gui_renderable.
    class-methods create
      returning
        value(ro_page) type ref to lcl_preact_page.
endclass.

class lcl_preact_page implementation.

  method zif_abapgit_gui_renderable~render.

    create object ro_html type zcl_abapgit_html.
    ro_html->add( '<!DOCTYPE html>' ).                      "#EC NOTEXT
    ro_html->add( '<html>' ).                               "#EC NOTEXT

    ro_html->add( '<head>' ).                               "#EC NOTEXT
    ro_html->add( '<meta http-equiv="content-type" content="text/html; charset=utf-8">' ).  "#EC NOTEXT
    ro_html->add( '<meta http-equiv="X-UA-Compatible" content="IE=11,10,9,8" />' ).         "#EC NOTEXT
    ro_html->add( |<title>Preact test</title>| ).                                           "#EC NOTEXT
    ro_html->add( '</head>' ).                              "#EC NOTEXT

    ro_html->add( '<body>' ).                                           "#EC NOTEXT
    ro_html->add( '<script src="https://unpkg.com/preact"></script>' ). "#EC NOTEXT
    ro_html->add( '<script src="lib/index.js"></script>' ).             "#EC NOTEXT
    ro_html->add( '</body>' ).                                          "#EC NOTEXT
    ro_html->add( '</html>' ).                                          "#EC NOTEXT

  endmethod.

  method create.
    create object ro_page.
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
    lcl_gui_factory=>init(
      io_component = lcl_preact_page=>create( )
      ii_asset_man = lcl_common_parts=>create_asset_manager( ) ).
    lcl_gui_factory=>run( ).
  endmethod.
endclass.

include zguibp_example_run.
