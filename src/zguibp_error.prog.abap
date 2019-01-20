class lcx_guibp_error definition inheriting from cx_static_check.
  public section.
    interfaces if_t100_message.
    data msg type string read-only.
    data loc type string read-only.

    methods constructor
      importing
        msg type string
        loc type string optional.

    class-methods raise
      importing
        msg  type string
        loc type string optional
      raising lcx_guibp_error.
endclass.

class lcx_guibp_error implementation.

  method constructor.
    super->constructor( ).
    me->msg = msg.
    me->loc = loc.
    me->if_t100_message~t100key-msgid = 'SY'. " & & & &
    me->if_t100_message~t100key-msgno = '499'.
    me->if_t100_message~t100key-attr1 = 'MSG'.
    me->if_t100_message~t100key-attr2 = 'LOC'.
  endmethod.

  method raise.
    raise exception type lcx_guibp_error
      exporting
        msg = msg
        loc = loc.
  endmethod.

endclass.
