class lcl_common_parts definition final.
  public section.

    class-methods create_asset_manager
      returning
        value(ro_asset_man) type ref to zcl_abapgit_gui_asset_manager.

endclass.

class lcl_common_parts implementation.

  method create_asset_manager.
    " used by abapmerge
    define _inline.
      append &1 to lt_data.
    end-of-definition.

    data lt_inline type string_table.

    create object ro_asset_man type zcl_abapgit_gui_asset_manager.

    clear lt_inline.
    " @@abapmerge include zgui_boilerplate_css_common.w3mi.data.css > _inline '$$'.
    ro_asset_man->register_asset(
      iv_url       = 'css/common.css'
      iv_type      = 'text/css'
      iv_mime_name = 'ZGUI_BOILERPLATE_CSS_COMMON'
      iv_inline    = concat_lines_of( table = lt_inline sep = cl_abap_char_utilities=>newline ) ).

    clear lt_inline.
    " @@abapmerge include zgui_boilerplate_js_common.w3mi.data.js > _inline '$$'.
    ro_asset_man->register_asset(
      iv_url       = 'js/common.js'
      iv_type      = 'text/javascript'
      iv_mime_name = 'ZGUI_BOILERPLATE_JS_COMMON'
      iv_inline    = concat_lines_of( table = lt_inline sep = cl_abap_char_utilities=>newline ) ).

    clear lt_inline.
    " @@abapmerge include zgui_boilerplate_example_tab.w3mi.data.mustache > _inline '$$'.
    ro_asset_man->register_asset(
      iv_url       = 'templates/table.mustache'
      iv_type      = 'text/plain'
      iv_mime_name = 'ZGUI_BOILERPLATE_EXAMPLE_TAB'
      iv_cachable  = abap_false
      iv_inline    = concat_lines_of( table = lt_inline sep = cl_abap_char_utilities=>newline ) ).

    ro_asset_man->register_asset(
      iv_url       = 'img/test.png'
      iv_type      = 'image/png'
      iv_base64    =
           'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQ'
        && 'U1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAADhSURBVDhPzZJbzgFBEEYnER'
        && '7EZQP8tiHEcty2I35W4LICYi+uwSI8cb7umXSmpwkPEic56SpplZqqjr5BB5d4xVt8LrC'
        && 'NL8njFLfYwxoW4rOPexxjDoNMcIUlk2XR72tUkQxqe4dFkznu8ZlQwSNmPkff3LVhCr+A'
        && 'GODchg4Nqm7DFKECunexoUPT1sB8QgV0T/dTfNJBAzMdaM9a3TsMcWZDh6Z6wLLJHH4HV'
        && 'dS9lsk8tF/t2S+SoBVucGSyAHph/3hCvbw/1MB0anXav/789CUmqD3tWYPStM9x3sSfI4'
        && 'oe3YcrMuOWvQgAAAAASUVORK5CYII=' ).

  endmethod.

endclass.
