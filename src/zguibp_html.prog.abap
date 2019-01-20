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


class lcl_gui definition final.
  public section.
    class-methods run_gui
      importing
        ii_router    type ref to zif_abapgit_gui_router
        ii_asset_man type ref to zif_abapgit_gui_asset_manager
      raising
        zcx_abapgit_exception.
    class-methods get_asset_man
      returning
        value(ri_asset_man) type ref to zif_abapgit_gui_asset_manager.
    class-methods get_gui
      returning
        value(ro_gui) type ref to zcl_abapgit_gui.
    class-methods free.
  private section.
    class-data gi_asset_man type ref to zif_abapgit_gui_asset_manager.
    class-data go_gui_instance type ref to zcl_abapgit_gui.
endclass.

class lcl_gui implementation.
  method get_asset_man.
    ri_asset_man = gi_asset_man.
  endmethod.
  method get_gui.
    ro_gui = go_gui_instance.
  endmethod.
  method run_gui.
    data lo_gui type ref to zcl_abapgit_gui.

    gi_asset_man = ii_asset_man.

    create object lo_gui
      exporting
        ii_router    = ii_router
        ii_asset_man = ii_asset_man.
    go_gui_instance = lo_gui.
    lo_gui->go_home( ).

    call selection-screen 1001. " trigger screen

    free( ).
  endmethod.
  method free.
    go_gui_instance->free( ).
    clear go_gui_instance.
    clear gi_asset_man.
  endmethod.
endclass.
