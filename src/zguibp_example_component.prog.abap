" Hello world component
" must implement zif_abapgit_gui_page

class lcl_hello_component definition final.
  public section.
    interfaces zif_abapgit_gui_page.

    " Actions, best practice is to define them as constants
    constants:
      begin of c_action,
        say_hello type string value 'say_hello',
      end of c_action.

    " This is just for convenient creation
    " example params:
    "   iv_name - displayed on the hello page
    "   iv_link - renders link to another page, handled by router
    class-methods create
      importing
        iv_name type string
        iv_link type string optional
      returning
        value(ro_component) type ref to lcl_hello_component.

  private section.
    data mv_name type string.
    data mv_link type string.

endclass.

class lcl_hello_component implementation.

  method zif_abapgit_gui_page~render.

    create object ro_html type zcl_abapgit_html.

    " Render hello text and an image from asset manager
    ro_html->add( |<h1>Hello world from { mv_name }</h1>| ).
    ro_html->add( '<img src="img/test.png" alt="test">' ).

    " render local action link
    ro_html->add_a(
      iv_txt = 'Say hello'
      iv_act = c_action-say_hello
      iv_typ = zif_abapgit_html=>c_action_type-sapevent
      iv_opt = zif_abapgit_html=>c_html_opt-strong ).

    " render link to another page, if specified
    if mv_link is not initial.
      ro_html->add( |<div>{ ro_html->a(
        iv_txt = 'Go to another page'
        iv_act = mv_link
        iv_typ = zif_abapgit_definitions=>c_action_type-sapevent
      ) }</div>| ).
    endif.

  endmethod.

  method zif_abapgit_gui_page~on_event.

    " by default action is not handled and passed through to next handler
    ev_state = zcl_abapgit_gui=>c_event_state-not_handled.

    " local action handling
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
