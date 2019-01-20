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
      iv_mime_name = 'ZGUIBP_CSS_COMMON'
      iv_inline    = concat_lines_of( table = lt_inline sep = cl_abap_char_utilities=>newline ) ).

    clear lt_inline.
    " @@abapmerge include zgui_boilerplate_js_common.w3mi.data.js > _inline '$$'.
    ro_asset_man->register_asset(
      iv_url       = 'js/common.js'
      iv_type      = 'text/javascript'
      iv_mime_name = 'ZGUIBP_JS_COMMON'
      iv_inline    = concat_lines_of( table = lt_inline sep = cl_abap_char_utilities=>newline ) ).

    clear lt_inline.
    " @@abapmerge include zgui_boilerplate_css_common.w3mi.data.css > _inline '$$'.
    ro_asset_man->register_asset(
      iv_url       = 'css/example.css'
      iv_type      = 'text/css'
      iv_mime_name = 'ZGUIBP_EXAMPLE_CSS'
      iv_inline    = concat_lines_of( table = lt_inline sep = cl_abap_char_utilities=>newline ) ).

    clear lt_inline.
    " @@abapmerge include zgui_boilerplate_example_tab.w3mi.data.mustache > _inline '$$'.
    ro_asset_man->register_asset(
      iv_url       = 'templates/table.mustache'
      iv_type      = 'text/plain'
      iv_mime_name = 'ZGUIBP_EXAMPLE_TAB'
      iv_cachable  = abap_false
      iv_inline    = concat_lines_of( table = lt_inline sep = cl_abap_char_utilities=>newline ) ).

    ro_asset_man->register_asset(
      iv_url       = 'img/test.png'
      iv_type      = 'image/png'
      iv_base64    =
           'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAC4jAAA'
        && 'uIwF4pT92AAABCUlEQVR42qWSwQpBQRSGLSW3kFhI4hm8gRfwHPIGHoInYCcbC0'
        && 'sLK2WPYqMsbtnYWSi5OvqmZpq5BlcWf9175pxvzvnPpEQk9Y+8wX43I8tRQdbTo'
        && 'tJ8EAixr4BOOyvhoiTXfVVuh5oS35dNRc6rsoKS4wVwoAsfYd0RMQ3ZjQMHYgDc'
        && '3GrmHMmp8RIjj5EcQDwpiu6SJGYAzEabSTpgjOMsb0xVAJyOAyjW8gEmvbQLwEA'
        && 'MswttcUaOF4ApuKw34CvWHWIim3BG4AfypzXa7W+HGbNKs0aMJIFOACHf7Nyu23'
        && '95SBzSIsm2iOlixvU+JA0hgWRbFNI2N799ynEQvlCA+I4XfgT8oifPjpj2isKBQ'
        && 'AAAAABJRU5ErkJggg==' ).

  endmethod.

endclass.
