report zguibp_example.

include zguibp_html.
include zguibp_example_lib.

* Hello world component
* must implement zif_abapgit_gui_page
class lcl_home_component definition final.
  public section.
    interfaces zif_abapgit_gui_page.

    constants:
      begin of c_action,
        say_hello type string value 'say_hello',
      end of c_action.

    class-methods create
      importing
        iv_name type string
        iv_link type string optional
      returning
        value(ro_component) type ref to lcl_home_component.

  private section.
    data mv_name type string.
    data mv_link type string.

endclass.

class lcl_home_component implementation.

  method zif_abapgit_gui_page~render.
    create object ro_html.
    ro_html->add( |<h1>Hello world from { mv_name }</h1>| ).
    ro_html->add( '<img src="img/test.png" alt="test">' ).
    ro_html->add_a(
      iv_txt = 'Say hello'
      iv_act = c_action-say_hello
      iv_typ = zcl_abapgit_html=>c_action_type-sapevent
      iv_opt = zcl_abapgit_html=>c_html_opt-strong ).
    if mv_link is not initial.
      ro_html->add( |<div>{ ro_html->a(
        iv_txt = 'Go to another page'
        iv_act = mv_link
        iv_typ = zif_abapgit_definitions=>c_action_type-sapevent
      ) }</div>| ).
    endif.
  endmethod.

  method zif_abapgit_gui_page~on_event.
    ev_state = zcl_abapgit_gui=>c_event_state-not_handled.
    case iv_action.
      when c_action-say_hello.
        message 'Hello !' type 'S'.
        ev_state = zcl_abapgit_gui=>c_event_state-no_more_act.
    endcase.
  endmethod.

  method create.
    create object ro_component.
    ro_component->mv_name = iv_name.
    ro_component->mv_link = iv_link.
  endmethod.

endclass.

* global router
* must implement zif_abapgit_gui_router
class lcl_gui_router definition final.
  public section.
    interfaces zif_abapgit_gui_router.
    class-methods create
      returning
        value(ro_router) type ref to lcl_gui_router.
endclass.

class lcl_gui_router implementation.
  method create.
    create object ro_router.
  endmethod.

  method zif_abapgit_gui_router~on_event.
    case iv_action.
      when zcl_abapgit_gui=>c_action-go_home.
        ei_page  = lcl_page_hoc=>wrap(
          iv_page_title = 'Home page'
          ii_child      = lcl_home_component=>create( iv_name = 'Home page' iv_link = 'goto-page2' ) ).
        ev_state = zcl_abapgit_gui=>c_event_state-new_page.
      when 'goto-page2'.
        ei_page  = lcl_page_hoc=>wrap(
          iv_page_title = 'Page 2'
          ii_child      = lcl_home_component=>create( iv_name = 'Page 2' ) ).
        ev_state = zif_abapgit_definitions=>c_event_state-new_page.
    endcase.
  endmethod.
endclass.

class lcl_app definition final.
  public section.
    methods run
      raising
        zcx_abapgit_exception.
endclass.

class lcl_app implementation.
  method run.

    lcl_gui=>run_gui(
      ii_router    = lcl_gui_router=>create( )
      ii_asset_man = lcl_common_parts=>create_asset_manager( ) ).

  endmethod.
endclass.

include zguibp_example_run.
