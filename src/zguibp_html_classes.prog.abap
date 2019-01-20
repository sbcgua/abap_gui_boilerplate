class lcl_page_hoc definition final.
  public section.
    interfaces zif_abapgit_gui_page.

    class-methods wrap
      importing
        iv_page_title type string
        ii_child      type ref to zif_abapgit_gui_page
      returning
        value(ro_page) type ref to lcl_page_hoc.

  private section.
    data mv_page_title type string.
    data mi_child type ref to zif_abapgit_gui_page.
endclass.

class lcl_page_hoc implementation.

  method zif_abapgit_gui_page~render.

    create object ro_html.
    ro_html->add( '<!DOCTYPE html>' ).                      "#EC NOTEXT
    ro_html->add( '<html>' ).                               "#EC NOTEXT

    ro_html->add( '<head>' ).                               "#EC NOTEXT

    ro_html->add( '<meta http-equiv="content-type" content="text/html; charset=utf-8">' ). "#EC NOTEXT
    ro_html->add( '<meta http-equiv="X-UA-Compatible" content="IE=11,10,9,8" />' ).        "#EC NOTEXT
    ro_html->add( |<title>{ mv_page_title }</title>| ).                                    "#EC NOTEXT
    ro_html->add( '<link rel="stylesheet" type="text/css" href="css/common.css">' ).       "#EC NOTEXT
    ro_html->add( '<script type="text/javascript" src="js/common.js"></script>' ).         "#EC NOTEXT
    ro_html->add( '</head>' ).                              "#EC NOTEXT

    ro_html->add( '<body>' ).                               "#EC NOTEXT
    ro_html->add( '<div id="root">' ).                      "#EC NOTEXT
    ro_html->add( mi_child->render( ) ).
    ro_html->add( '</div>' ).                               "#EC NOTEXT
    ro_html->add( '</body>' ).                              "#EC NOTEXT

* TODO render after_body, html or component ???

    ro_html->add( '</html>' ).                              "#EC NOTEXT

  endmethod.

  method zif_abapgit_gui_page~on_event.

    mi_child->on_event(
      EXPORTING
        iv_action    = iv_action
        iv_prev_page = iv_prev_page
        iv_getdata   = iv_getdata
        it_postdata  = it_postdata
      IMPORTING
        ei_page      = ei_page
        ev_state     = ev_state ).

  endmethod.

  method wrap.

    create object ro_page.
    ro_page->mv_page_title = iv_page_title.
    ro_page->mi_child = ii_child.

  endmethod.

endclass.

class lcl_gui_default_error_handler definition.
  public section.
    methods on_gui_error for event on_error of zcl_abapgit_gui
      importing
        io_exception.
endclass.

class lcl_gui_default_error_handler implementation.
  method on_gui_error.
    message io_exception type 'S' display like 'E'.
  endmethod.
endclass.

class lcl_gui_factory definition final create private.
  public section.
    class-methods init
      importing
        ii_router                   type ref to zif_abapgit_gui_router
        ii_asset_man                type ref to zif_abapgit_gui_asset_manager
        iv_no_default_error_handler type abap_bool default abap_false
      raising
        lcx_guibp_error.

    class-methods free.
    class-methods run
      raising
        lcx_guibp_error.

    class-methods get_asset_man
      returning
        value(ri_asset_man) type ref to zif_abapgit_gui_asset_manager.
    class-methods get_router
      returning
        value(ri_router) type ref to zif_abapgit_gui_router.
    class-methods get_gui
      returning
        value(ro_gui) type ref to zcl_abapgit_gui.

  private section.
    class-data gi_router type ref to zif_abapgit_gui_router.
    class-data gi_asset_man type ref to zif_abapgit_gui_asset_manager.
    class-data go_gui_instance type ref to zcl_abapgit_gui.
endclass.

class lcl_gui_factory implementation.
  method get_asset_man.
    ri_asset_man = gi_asset_man.
  endmethod.

  method get_router.
    ri_router = gi_router.
  endmethod.

  method get_gui.
    ro_gui = go_gui_instance.
  endmethod.

  method init.
    data lo_gui type ref to zcl_abapgit_gui.
    data lx type ref to zcx_abapgit_exception.

    if go_gui_instance is bound.
      lcx_guibp_error=>raise( 'Cannot instantiate GUI twice' ).
    endif.

    gi_asset_man = ii_asset_man.
    gi_router    = ii_router.

    try .
      create object go_gui_instance
        exporting
          ii_router    = ii_router
          ii_asset_man = ii_asset_man.
    catch zcx_abapgit_exception into lx.
      lcx_guibp_error=>raise( lx->get_text( ) ).
    endtry.

    data lo_handler type ref to lcl_gui_default_error_handler.
    if iv_no_default_error_handler = abap_false.
      create object lo_handler.
      set handler lo_handler->on_gui_error for go_gui_instance.
    endif.

  endmethod.

  method run.

    data lx type ref to zcx_abapgit_exception.

    try .
      go_gui_instance->go_home( ).
      call selection-screen 1001. " trigger screen
      free( ).
    catch zcx_abapgit_exception into lx.
      lcx_guibp_error=>raise( lx->get_text( ) ).
    endtry.

  endmethod.

  method free.
    go_gui_instance->free( ).
    clear go_gui_instance.
    clear gi_asset_man.
    clear gi_router.
  endmethod.
endclass.
