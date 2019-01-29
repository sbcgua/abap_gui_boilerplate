[![Build Status](https://travis-ci.org/sbcgua/abap_gui_boilerplate.svg?branch=master)](https://travis-ci.org/sbcgua/abap_gui_boilerplate)
# Boilerplate for ABAP applications with HTML UI and abapmerge

*version: 0.1*

Work in progress, all may change, however safe enough to try ;)

## Main idea

A template/framework for HTML based GUI applications like in abapGit. Based on abapGit GUI classes.

The examples of usage are in:

- `ZGUIBP_EXAMPLE` - pure HTML example, UI, 2 pages and the router to control navigation between them
- `ZGUIBP_EXAMPLE_MSTSH` - HTML is rendered by [abap_mustache](https://github.com/sbcgua/abap_mustache) library (needs to be installed to compile). Mustache template is saved as MIME binary.
- `ZGUIBP_EXAMPLE_ALV` - combination of ALV and HTML UI, ALV is displayed first, double click open HTML page

The examples have some common components:

- `ZGUIBP_EXAMPLE_COMMON` - implementation of asset manager that takes care of preloaded data
- `ZGUIBP_EXAMPLE_COMPONENT` - implementation of simple HTML page for HTML UI

Also, ALV ! How could it be without ALV ?! ;)

- `ZGUIBP_ALV` - implement a common base class for SALV with controllable toolbar (based on zevolving blogs). Well, may be of interest, though I guess everybody has ALV boilerplates of his own ...

## Shortly the concept of HTML UI classes

The main class is `lcl_gui_factory` - supposed to be a single instance. Suppose to be instantiated with `init` and then `run`. `init` accepts instance of loaded `zcl_abapgit_gui_asset_manager` and instance of router (`zif_abapgit_gui_event_handler`) or page (`zif_abapgit_gui_renderable`) to render.

Asset manager (`zcl_abapgit_gui_asset_manager`) hold the assets. Asset can be loaded from MIME repository of be a base64 string.

Page (`zif_abapgit_gui_renderable` or `zif_abapgit_gui_page`) must implement render method which returns instance of `zif_abapgit_html` (supposed to be `zcl_abapgit_html`), which is a wrapper for convenient html construction. 

`lcl_page_hoc` - a high order component to add HTML head, body and some other useful stuff. Can be reused for simple cases.

Quick pseudo code for implementation
```abap
  class lcl_my_page inheriting zif_abapgit_gui_renderable.
    method render.
      ro_html = new zcl_abapgit_html.
      ro_html->add( 'some html stuff, in-body only' ).
      return 
    endmethod.
  endclass.

  form main.
    data lo_assets type ref to zcl_abapgit_gui_asset_manager.
    lo_assets = new zcl_abapgit_gui_asset_manager.
    lo_assets->register_asset(
      iv_url       = 'css/common.css'
      iv_type      = 'text/css'
      iv_mime_name = 'ZMY_MIME_CSS_COMMON' ).
    
    data lo_page type ref to zif_abapgit_gui_renderable.
    lo_page = lcl_page_hoc=>wrap(
      iv_page_title = 'Page 2'
      ii_child      = new lcl_my_page ).

    lcl_gui_factory=>init(
      io_component = lo_page
      ii_asset_man = lo_assets ).
    lcl_gui_factory=>run( ).
  endform.
```

## abapGit

The HTML UI classes reside in `ZGUIBP_HTML_CONTRIB` and are heavily based (90%) on abapGit code. However a bit unified. Maybe will be directly based on abapGit in future.

## TODO

- the code should be build-able with `abapmerge` into a working single file without dependencies
- better docs
- eliminate `ZGUIBP_HTML_CONTRIB`, base directly on abapGit classes (PR differences to abapGit)
