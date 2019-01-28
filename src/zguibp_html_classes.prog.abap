class lcl_page_hoc definition final.
  public section.
    interfaces zif_abapgit_gui_page.

    class-methods wrap
      importing
        iv_page_title      type string
        ii_child           type ref to zif_abapgit_gui_renderable
        iv_show_debug_div  type abap_bool default abap_false
        iv_before_body_end type string optional
        iv_add_styles      type any optional
      returning
        value(ro_page) type ref to lcl_page_hoc.

  private section.
    data mv_page_title      type string.
    data mi_child           type ref to zif_abapgit_gui_renderable.
    data mv_show_debug_div  type abap_bool.
    data mv_before_body_end type string.
    data mt_add_styles      type string_table.
endclass.

class lcl_page_hoc implementation.

  method zif_abapgit_gui_page~render.

    field-symbols <s> like line of mt_add_styles.

    create object ro_html type zcl_abapgit_html.
    ro_html->add( '<!DOCTYPE html>' ).                      "#EC NOTEXT
    ro_html->add( '<html>' ).                               "#EC NOTEXT

    ro_html->add( '<head>' ).                               "#EC NOTEXT
    ro_html->add( '<meta http-equiv="content-type" content="text/html; charset=utf-8">' ). "#EC NOTEXT
    ro_html->add( '<meta http-equiv="X-UA-Compatible" content="IE=11,10,9,8" />' ).        "#EC NOTEXT
    ro_html->add( |<title>{ mv_page_title }</title>| ).                                    "#EC NOTEXT
    ro_html->add( '<link rel="stylesheet" type="text/css" href="css/common.css">' ).       "#EC NOTEXT
    ro_html->add( '<script type="text/javascript" src="js/common.js"></script>' ).         "#EC NOTEXT

    loop at mt_add_styles assigning <s>.
      ro_html->add( |<link rel="stylesheet" type="text/css" href="{ <s> }">| ).     "#EC NOTEXT
    endloop.

    ro_html->add( '</head>' ).                              "#EC NOTEXT

    ro_html->add( '<body>' ).                               "#EC NOTEXT
    ro_html->add( '<div id="root">' ).                      "#EC NOTEXT
    ro_html->add( mi_child->render( ) ).
    ro_html->add( '</div>' ).                               "#EC NOTEXT

    if mv_show_debug_div = abap_true.
      ro_html->add( '<div id="debug-output"></div>' ).      "#EC NOTEXT
    endif.
    if mv_before_body_end is not initial.
      ro_html->add( mv_before_body_end ). " can be used for end script section
    endif.

    ro_html->add( '</body>' ).                              "#EC NOTEXT
    ro_html->add( '</html>' ).                              "#EC NOTEXT

  endmethod.

  method zif_abapgit_gui_page~on_event.

    data li_page_eh type ref to zif_abapgit_gui_event_handler.

    try.
      li_page_eh ?= mi_child.
      catch cx_sy_move_cast_error.
        return.
    endtry.

    li_page_eh->on_event(
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
    ro_page->mv_page_title      = iv_page_title.
    ro_page->mi_child           = ii_child.
    ro_page->mv_show_debug_div  = iv_show_debug_div.
    ro_page->mv_before_body_end = iv_before_body_end.

    data lv_type type c.
    if iv_add_styles is not initial.
      describe field iv_add_styles type lv_type.
      if lv_type co 'Cg'.
        append iv_add_styles to ro_page->mt_add_styles.
      elseif lv_type = 'h'.
        ro_page->mt_add_styles = iv_add_styles. " Assume string_table
      endif. " Ignore errors ?
    endif.

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
        io_component                type ref to object
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
        value(ro_router) type ref to object.
    class-methods get_gui
      returning
        value(ro_gui) type ref to zcl_abapgit_gui.

  private section.
    class-data go_router type ref to object.
    class-data gi_asset_man type ref to zif_abapgit_gui_asset_manager.
    class-data go_gui_instance type ref to zcl_abapgit_gui.
endclass.

class lcl_gui_factory implementation.
  method get_asset_man.
    ri_asset_man = gi_asset_man.
  endmethod.

  method get_router.
    ro_router = go_router.
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

    if zcl_abapgit_gui=>is_renderable( io_component ) = abap_false
      and zcl_abapgit_gui=>is_event_handler( io_component ) = abap_true.
      go_router ?= io_component.
    endif.

    try .
      create object go_gui_instance
        exporting
          io_component = io_component
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
    clear go_router.
  endmethod.
endclass.
