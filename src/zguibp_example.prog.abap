report zguibp_example.

include zguibp_error.
include zguibp_html.
include zguibp_example_common.
include zguibp_example_component.

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
          iv_show_debug_div  = abap_true
          iv_before_body_end = '<script type="text/javascript">confirmInitialized();</script>'
          iv_add_styles      = 'css/example.css'
          iv_page_title      = 'Home page'
          ii_child           = lcl_hello_component=>create( iv_name = 'Home page' iv_link = 'goto-page2' ) ).
        ev_state = zcl_abapgit_gui=>c_event_state-new_page.
      when 'goto-page2'.
        ei_page  = lcl_page_hoc=>wrap(
          iv_page_title = 'Page 2'
          ii_child      = lcl_hello_component=>create( iv_name = 'Page 2' ) ).
        ev_state = zif_abapgit_definitions=>c_event_state-new_page.
    endcase.
  endmethod.
endclass.

class lcl_app definition final.
  public section.
    methods run
      raising
        lcx_guibp_error.
endclass.

class lcl_app implementation.
  method run.
    lcl_gui_factory=>init(
      ii_router    = lcl_gui_router=>create( )
      ii_asset_man = lcl_common_parts=>create_asset_manager( ) ).
    lcl_gui_factory=>run( ).
  endmethod.
endclass.

include zguibp_example_run.
