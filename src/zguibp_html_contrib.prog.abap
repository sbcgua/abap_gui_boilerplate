**********************************************************************
* the below code is mostly based on abapGit html components
**********************************************************************

" Changes:
" - gui-on_error
" - html interface

* EXCEPTION

CLASS zcx_abapgit_cancel DEFINITION
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcx_abapgit_cancel IMPLEMENTATION.
ENDCLASS.

CLASS zcx_abapgit_exception DEFINITION
  INHERITING FROM cx_static_check
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES:
      if_t100_message.
    CLASS-METHODS:
      raise IMPORTING iv_text     TYPE clike
                      ix_previous TYPE REF TO cx_root OPTIONAL
            RAISING   zcx_abapgit_exception,
      raise_t100 IMPORTING VALUE(iv_msgid) TYPE symsgid DEFAULT sy-msgid
                           VALUE(iv_msgno) TYPE symsgno DEFAULT sy-msgno
                           VALUE(iv_msgv1) TYPE symsgv DEFAULT sy-msgv1
                           VALUE(iv_msgv2) TYPE symsgv DEFAULT sy-msgv2
                           VALUE(iv_msgv3) TYPE symsgv DEFAULT sy-msgv3
                           VALUE(iv_msgv4) TYPE symsgv DEFAULT sy-msgv4
                 RAISING   zcx_abapgit_exception .
    METHODS:
      constructor  IMPORTING textid   LIKE if_t100_message=>t100key OPTIONAL
                             previous LIKE previous OPTIONAL
                             msgv1    TYPE symsgv OPTIONAL
                             msgv2    TYPE symsgv OPTIONAL
                             msgv3    TYPE symsgv OPTIONAL
                             msgv4    TYPE symsgv OPTIONAL.
    DATA:
      subrc TYPE sysubrc READ-ONLY,
      msgv1 TYPE symsgv READ-ONLY,
      msgv2 TYPE symsgv READ-ONLY,
      msgv3 TYPE symsgv READ-ONLY,
      msgv4 TYPE symsgv READ-ONLY.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      gc_generic_error_msg TYPE string VALUE `An error occured (ZCX_ABAPGIT_EXCEPTION)` ##NO_TEXT.
ENDCLASS.

CLASS zcx_abapgit_exception IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).

    me->msgv1 = msgv1.
    me->msgv2 = msgv2.
    me->msgv3 = msgv3.
    me->msgv4 = msgv4.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.

  METHOD raise.
    DATA: lv_msgv1    TYPE symsgv,
          lv_msgv2    TYPE symsgv,
          lv_msgv3    TYPE symsgv,
          lv_msgv4    TYPE symsgv,
          ls_t100_key TYPE scx_t100key,
          lv_text     TYPE string.

    IF iv_text IS INITIAL.
      lv_text = gc_generic_error_msg.
    ELSE.
      lv_text = iv_text.
    ENDIF.

    cl_message_helper=>set_msg_vars_for_clike( lv_text ).

    ls_t100_key-msgid = sy-msgid.
    ls_t100_key-msgno = sy-msgno.
    ls_t100_key-attr1 = 'MSGV1'.
    ls_t100_key-attr2 = 'MSGV2'.
    ls_t100_key-attr3 = 'MSGV3'.
    ls_t100_key-attr4 = 'MSGV4'.
    lv_msgv1 = sy-msgv1.
    lv_msgv2 = sy-msgv2.
    lv_msgv3 = sy-msgv3.
    lv_msgv4 = sy-msgv4.

    RAISE EXCEPTION TYPE zcx_abapgit_exception
      EXPORTING
        textid   = ls_t100_key
        msgv1    = lv_msgv1
        msgv2    = lv_msgv2
        msgv3    = lv_msgv3
        msgv4    = lv_msgv4
        previous = ix_previous.
  ENDMETHOD.

  METHOD raise_t100.
    DATA: ls_t100_key TYPE scx_t100key.

    ls_t100_key-msgid = iv_msgid.
    ls_t100_key-msgno = iv_msgno.
    ls_t100_key-attr1 = 'MSGV1'.
    ls_t100_key-attr2 = 'MSGV2'.
    ls_t100_key-attr3 = 'MSGV3'.
    ls_t100_key-attr4 = 'MSGV4'.

    IF iv_msgid IS INITIAL.
      CLEAR ls_t100_key.
    ENDIF.

    RAISE EXCEPTION TYPE zcx_abapgit_exception
      EXPORTING
        textid = ls_t100_key
        msgv1  = iv_msgv1
        msgv2  = iv_msgv2
        msgv3  = iv_msgv3
        msgv4  = iv_msgv4.
  ENDMETHOD.
ENDCLASS.

* INTERFACES

INTERFACE zif_abapgit_html.

  CONSTANTS:
    BEGIN OF c_action_type,
      sapevent  TYPE c VALUE 'E',
      url       TYPE c VALUE 'U',
      onclick   TYPE c VALUE 'C',
      separator TYPE c VALUE 'S',
      dummy     TYPE c VALUE '_',
    END OF c_action_type .
  CONSTANTS:
    BEGIN OF c_html_opt,
      strong   TYPE c VALUE 'E',
      cancel   TYPE c VALUE 'C',
      crossout TYPE c VALUE 'X',
    END OF c_html_opt .

  METHODS add
    IMPORTING
      !ig_chunk TYPE any .
  METHODS render
    IMPORTING
      !iv_no_indent_jscss TYPE abap_bool OPTIONAL
    RETURNING
      VALUE(rv_html)      TYPE string .
  METHODS is_empty
    RETURNING
      VALUE(rv_yes) TYPE abap_bool .
  METHODS add_a
    IMPORTING
      !iv_txt   TYPE string
      !iv_act   TYPE string
      !iv_typ   TYPE char1 DEFAULT c_action_type-sapevent
      !iv_opt   TYPE clike OPTIONAL
      !iv_class TYPE string OPTIONAL
      !iv_id    TYPE string OPTIONAL
      !iv_style TYPE string OPTIONAL.
  CLASS-METHODS a
    IMPORTING
      !iv_txt       TYPE string
      !iv_act       TYPE string
      !iv_typ       TYPE char1 DEFAULT zif_abapgit_html=>c_action_type-sapevent
      !iv_opt       TYPE clike OPTIONAL
      !iv_class     TYPE string OPTIONAL
      !iv_id        TYPE string OPTIONAL
      !iv_style     TYPE string OPTIONAL
    RETURNING
      VALUE(rv_str) TYPE string .
  CLASS-METHODS icon
    IMPORTING
      !iv_name      TYPE string
      !iv_hint      TYPE string OPTIONAL
      !iv_class     TYPE string OPTIONAL
    RETURNING
      VALUE(rv_str) TYPE string .

ENDINTERFACE.

INTERFACE zif_abapgit_gui_asset_manager .

  TYPES:
    BEGIN OF ty_web_asset,
      url          TYPE w3url,
      type         TYPE char50,
      subtype      TYPE char50,
      content      TYPE xstring,
      is_cacheable TYPE abap_bool,
    END OF ty_web_asset .
  TYPES:
    tt_web_assets TYPE STANDARD TABLE OF ty_web_asset WITH DEFAULT KEY .

  METHODS get_all_assets
    RETURNING
      VALUE(rt_assets) TYPE tt_web_assets
    RAISING
      zcx_abapgit_exception.

  METHODS get_asset
    IMPORTING
      iv_url          TYPE string
    RETURNING
      VALUE(rs_asset) TYPE ty_web_asset
    RAISING
      zcx_abapgit_exception.

  METHODS get_text_asset
    IMPORTING
      iv_url          TYPE string
    RETURNING
      VALUE(rv_asset) TYPE string
    RAISING
      zcx_abapgit_exception.

ENDINTERFACE.

INTERFACE zif_abapgit_gui_page .

  METHODS on_event
    IMPORTING iv_action    TYPE clike
              iv_prev_page TYPE clike
              iv_getdata   TYPE clike OPTIONAL
              it_postdata  TYPE cnht_post_data_tab OPTIONAL
    EXPORTING ei_page      TYPE REF TO zif_abapgit_gui_page
              ev_state     TYPE i
    RAISING   zcx_abapgit_exception zcx_abapgit_cancel.

  METHODS render
    RETURNING VALUE(ro_html) TYPE REF TO zif_abapgit_html
    RAISING   zcx_abapgit_exception.

ENDINTERFACE.

INTERFACE zif_abapgit_gui_router .

  METHODS on_event
    IMPORTING
      iv_action    TYPE clike
      iv_prev_page TYPE clike
      iv_getdata   TYPE clike OPTIONAL
      it_postdata  TYPE cnht_post_data_tab OPTIONAL
    EXPORTING
      ei_page      TYPE REF TO zif_abapgit_gui_page
      ev_state     TYPE i
    RAISING
      zcx_abapgit_exception
      zcx_abapgit_cancel.

ENDINTERFACE.

* UTILS

CLASS zcl_abapgit_string_utils DEFINITION
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS string_to_xstring
      IMPORTING
        iv_str         TYPE string
      RETURNING
        VALUE(rv_xstr) TYPE xstring.

    CLASS-METHODS base64_to_xstring
      IMPORTING
        iv_base64      TYPE string
      RETURNING
        VALUE(rv_xstr) TYPE xstring.

    CLASS-METHODS bintab_to_xstring
      IMPORTING
        it_bintab      TYPE lvc_t_mime
        iv_size        TYPE i
      RETURNING
        VALUE(rv_xstr) TYPE xstring.

    CLASS-METHODS xstring_to_bintab
      IMPORTING
        iv_xstr   TYPE xstring
      EXPORTING
        ev_size   TYPE i
        et_bintab TYPE lvc_t_mime.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ZCL_ABAPGIT_STRING_UTILS IMPLEMENTATION.


  METHOD base64_to_xstring.

    CALL FUNCTION 'SSFC_BASE64_DECODE'
      EXPORTING
        b64data = iv_base64
      IMPORTING
        bindata = rv_xstr
      EXCEPTIONS
        OTHERS  = 1.
    ASSERT sy-subrc = 0.

  ENDMETHOD.


  METHOD bintab_to_xstring.

    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
      EXPORTING
        input_length = iv_size
      IMPORTING
        buffer       = rv_xstr
      TABLES
        binary_tab   = it_bintab
      EXCEPTIONS
        failed       = 1 ##FM_SUBRC_OK.
    ASSERT sy-subrc = 0.

  ENDMETHOD.


  METHOD string_to_xstring.

    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text   = iv_str
      IMPORTING
        buffer = rv_xstr
      EXCEPTIONS
        OTHERS = 1.
    ASSERT sy-subrc = 0.

  ENDMETHOD.


  METHOD xstring_to_bintab.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = iv_xstr
    IMPORTING
      output_length = ev_size
    TABLES
      binary_tab    = et_bintab.

  ENDMETHOD.
ENDCLASS.

* HTML RENDERER

CLASS zcl_abapgit_html DEFINITION
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_abapgit_html.

    ALIASES:
      add      FOR zif_abapgit_html~add,
      render   FOR zif_abapgit_html~render,
      is_empty FOR zif_abapgit_html~is_empty,
      add_a    FOR zif_abapgit_html~add_a,
      a        FOR zif_abapgit_html~a,
      icon     FOR zif_abapgit_html~icon.

    CONSTANTS c_indent_size TYPE i VALUE 2 ##NO_TEXT.

    CLASS-METHODS class_constructor .

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA: go_single_tags_re TYPE REF TO cl_abap_regex.

    DATA: mt_buffer TYPE string_table.

    TYPES:
      BEGIN OF ty_indent_context,
        no_indent_jscss TYPE abap_bool,
        within_style    TYPE abap_bool,
        within_js       TYPE abap_bool,
        indent          TYPE i,
        indent_str      TYPE string,
      END OF ty_indent_context,

      BEGIN OF ty_study_result,
        style_open   TYPE abap_bool,
        style_close  TYPE abap_bool,
        script_open  TYPE abap_bool,
        script_close TYPE abap_bool,
        tag_close    TYPE abap_bool,
        curly_close  TYPE abap_bool,
        openings     TYPE i,
        closings     TYPE i,
        singles      TYPE i,
      END OF ty_study_result.

    METHODS indent_line
      CHANGING
        cs_context TYPE ty_indent_context
        cv_line    TYPE string.

    METHODS study_line
      IMPORTING iv_line          TYPE string
                is_context       TYPE ty_indent_context
      RETURNING VALUE(rs_result) TYPE ty_study_result.

ENDCLASS.

CLASS ZCL_ABAPGIT_HTML IMPLEMENTATION.

  METHOD a.

    DATA: lv_class TYPE string,
          lv_href  TYPE string,
          lv_click TYPE string,
          lv_id    TYPE string,
          lv_style TYPE string,
          lv_span  TYPE string.

    lv_class = iv_class.

    IF iv_opt CA zif_abapgit_html=>c_html_opt-strong.
      lv_class = lv_class && ' emphasis' ##NO_TEXT.
    ENDIF.
    IF iv_opt CA zif_abapgit_html=>c_html_opt-cancel.
      lv_class = lv_class && ' attention' ##NO_TEXT.
    ENDIF.
    IF iv_opt CA zif_abapgit_html=>c_html_opt-crossout.
      lv_class = lv_class && ' crossout grey' ##NO_TEXT.
    ENDIF.
    IF lv_class IS NOT INITIAL.
      SHIFT lv_class LEFT DELETING LEADING space.
      lv_class = | class="{ lv_class }"|.
    ENDIF.

    lv_href  = ' href="#"'. " Default, dummy
    IF iv_act IS NOT INITIAL OR iv_typ = zif_abapgit_html=>c_action_type-dummy.
      CASE iv_typ.
        WHEN zif_abapgit_html=>c_action_type-url.
          lv_href  = | href="{ iv_act }"|.
        WHEN zif_abapgit_html=>c_action_type-sapevent.
          lv_href  = | href="sapevent:{ iv_act }"|.
        WHEN zif_abapgit_html=>c_action_type-onclick.
          lv_href  = ' href="#"'.
          lv_click = | onclick="{ iv_act }"|.
        WHEN zif_abapgit_html=>c_action_type-dummy.
          lv_href  = ' href="#"'.
      ENDCASE.
    ENDIF.

    IF iv_id IS NOT INITIAL.
      lv_id = | id="{ iv_id }"|.
    ENDIF.

    IF iv_style IS NOT INITIAL.
      lv_style = | style="{ iv_style }"|.
    ENDIF.

    lv_span = |<span class="tooltiptext hidden"></span>|.

    rv_str = |<a{ lv_id }{ lv_class }{ lv_href }{ lv_click }{ lv_style }>{ iv_txt }{ lv_span }</a>|.

  ENDMETHOD.


  METHOD add.

    DATA: lv_type TYPE c,
          lo_html TYPE REF TO zcl_abapgit_html.

    FIELD-SYMBOLS: <lt_tab> TYPE string_table.

    DESCRIBE FIELD ig_chunk TYPE lv_type. " Describe is faster than RTTI classes

    CASE lv_type.
      WHEN 'C' OR 'g'.  " Char or string
        APPEND ig_chunk TO mt_buffer.
      WHEN 'h'.         " Table
        ASSIGN ig_chunk TO <lt_tab>. " Assuming table of strings ! Will dump otherwise
        APPEND LINES OF <lt_tab> TO mt_buffer.
      WHEN 'r'.         " Object ref
        ASSERT ig_chunk IS BOUND. " Dev mistake
        TRY.
            lo_html ?= ig_chunk.
          CATCH cx_sy_move_cast_error.
            ASSERT 1 = 0. " Dev mistake
        ENDTRY.
        APPEND LINES OF lo_html->mt_buffer TO mt_buffer.
      WHEN OTHERS.
        ASSERT 1 = 0. " Dev mistake
    ENDCASE.

  ENDMETHOD.


  METHOD add_a.

    add( a( iv_txt   = iv_txt
            iv_act   = iv_act
            iv_typ   = iv_typ
            iv_opt   = iv_opt
            iv_class = iv_class
            iv_id    = iv_id
            iv_style = iv_style ) ).

  ENDMETHOD.


  METHOD class_constructor.
    CREATE OBJECT go_single_tags_re
      EXPORTING
        pattern     = '<(AREA|BASE|BR|COL|COMMAND|EMBED|HR|IMG|INPUT|LINK|META|PARAM|SOURCE|!)'
        ignore_case = abap_false.
  ENDMETHOD.


  METHOD icon.

    DATA: lv_hint  TYPE string,
          lv_name  TYPE string,
          lv_color TYPE string,
          lv_class TYPE string.

    SPLIT iv_name AT '/' INTO lv_name lv_color.

    IF iv_hint IS NOT INITIAL.
      lv_hint  = | title="{ iv_hint }"|.
    ENDIF.
    IF iv_class IS NOT INITIAL.
      lv_class = | { iv_class }|.
    ENDIF.
    IF lv_color IS NOT INITIAL.
      lv_color = | { lv_color }|.
    ENDIF.

    rv_str = |<i class="octicon octicon-{ lv_name }{ lv_color }{ lv_class }"{ lv_hint }></i>|.

  ENDMETHOD.


  METHOD indent_line.

    DATA: ls_study TYPE ty_study_result,
          lv_x_str TYPE string.

    ls_study = study_line(
      is_context = cs_context
      iv_line    = cv_line ).

    " First closing tag - shift back exceptionally
    IF (  ls_study-script_close = abap_true
       OR ls_study-style_close = abap_true
       OR ls_study-curly_close = abap_true
       OR ls_study-tag_close = abap_true )
       AND cs_context-indent > 0.
      lv_x_str = repeat( val = ` ` occ = ( cs_context-indent - 1 ) * c_indent_size ).
      cv_line  = lv_x_str && cv_line.
    ELSE.
      cv_line = cs_context-indent_str && cv_line.
    ENDIF.

    " Context status update
    CASE abap_true.
      WHEN ls_study-script_open.
        cs_context-within_js    = abap_true.
        cs_context-within_style = abap_false.
      WHEN ls_study-style_open.
        cs_context-within_js    = abap_false.
        cs_context-within_style = abap_true.
      WHEN ls_study-script_close OR ls_study-style_close.
        cs_context-within_js    = abap_false.
        cs_context-within_style = abap_false.
        ls_study-closings       = ls_study-closings + 1.
    ENDCASE.

    " More-less logic chosen due to possible double tags in a line '<a><b>'
    IF ls_study-openings <> ls_study-closings.
      IF ls_study-openings > ls_study-closings.
        cs_context-indent = cs_context-indent + 1.
      ELSEIF cs_context-indent > 0. " AND ls_study-openings < ls_study-closings
        cs_context-indent = cs_context-indent - 1.
      ENDIF.
      cs_context-indent_str = repeat( val = ` ` occ = cs_context-indent * c_indent_size ).
    ENDIF.

  ENDMETHOD.


  METHOD is_empty.
    rv_yes = boolc( lines( mt_buffer ) = 0 ).
  ENDMETHOD.


  METHOD render.

    DATA: ls_context TYPE ty_indent_context,
          lt_temp    TYPE string_table.

    FIELD-SYMBOLS: <lv_line>   LIKE LINE OF lt_temp,
                   <lv_line_c> LIKE LINE OF lt_temp.

    ls_context-no_indent_jscss = iv_no_indent_jscss.

    LOOP AT mt_buffer ASSIGNING <lv_line>.
      APPEND <lv_line> TO lt_temp ASSIGNING <lv_line_c>.
      indent_line( CHANGING cs_context = ls_context cv_line = <lv_line_c> ).
    ENDLOOP.

    CONCATENATE LINES OF lt_temp INTO rv_html SEPARATED BY cl_abap_char_utilities=>newline.

  ENDMETHOD.


  METHOD study_line.

    DATA: lv_line TYPE string,
          lv_len  TYPE i.

    lv_line = to_upper( shift_left( val = iv_line sub = ` ` ) ).
    lv_len  = strlen( lv_line ).

    " Some assumptions for simplification and speed
    " - style & scripts tag should be opened/closed in a separate line
    " - style & scripts opening and closing in one line is possible but only once

    " TODO & Issues
    " - What if the string IS a well formed html already not just single line ?

    IF is_context-within_js = abap_true OR is_context-within_style = abap_true.

      IF is_context-within_js = abap_true AND lv_len >= 8 AND lv_line(8) = '</SCRIPT'.
        rs_result-script_close = abap_true.
      ELSEIF is_context-within_style = abap_true AND lv_len >= 7 AND lv_line(7) = '</STYLE'.
        rs_result-style_close = abap_true.
      ENDIF.

      IF is_context-no_indent_jscss = abap_false.
        IF lv_len >= 1 AND lv_line(1) = '}'.
          rs_result-curly_close = abap_true.
        ENDIF.

        FIND ALL OCCURRENCES OF '{' IN lv_line MATCH COUNT rs_result-openings.
        FIND ALL OCCURRENCES OF '}' IN lv_line MATCH COUNT rs_result-closings.
      ENDIF.

    ELSE.
      IF lv_len >= 7 AND lv_line(7) = '<SCRIPT'.
        FIND FIRST OCCURRENCE OF '</SCRIPT' IN lv_line.
        IF sy-subrc > 0. " Not found
          rs_result-script_open = abap_true.
        ENDIF.
      ENDIF.
      IF lv_len >= 6 AND lv_line(6) = '<STYLE'.
        FIND FIRST OCCURRENCE OF '</STYLE' IN lv_line.
        IF sy-subrc > 0. " Not found
          rs_result-style_open = abap_true.
        ENDIF.
      ENDIF.
      IF lv_len >= 2 AND lv_line(2) = '</'.
        rs_result-tag_close = abap_true.
      ENDIF.

      FIND ALL OCCURRENCES OF '<'  IN lv_line MATCH COUNT rs_result-openings.
      FIND ALL OCCURRENCES OF '</' IN lv_line MATCH COUNT rs_result-closings.
      FIND ALL OCCURRENCES OF REGEX go_single_tags_re IN lv_line MATCH COUNT rs_result-singles.
      rs_result-openings = rs_result-openings - rs_result-closings - rs_result-singles.

    ENDIF.

  ENDMETHOD.
ENDCLASS.


* ASSET MANAGER

CLASS zcl_abapgit_gui_asset_manager DEFINITION FINAL CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abapgit_gui_asset_manager.

  TYPES:
    BEGIN OF ty_asset_entry.
      INCLUDE TYPE zif_abapgit_gui_asset_manager~ty_web_asset.
      TYPES:  mime_name TYPE wwwdatatab-objid,
    END OF ty_asset_entry,
    tt_asset_register TYPE STANDARD TABLE OF ty_asset_entry WITH KEY url.

  METHODS register_asset
    IMPORTING
      iv_url       TYPE string
      iv_type      TYPE string
      iv_cachable  TYPE abap_bool DEFAULT abap_true
      iv_mime_name TYPE wwwdatatab-objid OPTIONAL
      iv_base64    TYPE string OPTIONAL
      iv_inline    TYPE string OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mt_asset_register TYPE tt_asset_register.

    METHODS get_mime_asset
      IMPORTING
        iv_mime_name    TYPE c
      RETURNING
        VALUE(rv_xdata) TYPE xstring
      RAISING
        zcx_abapgit_exception.

    METHODS load_asset
      IMPORTING
        is_asset_entry TYPE ty_asset_entry
      RETURNING
        VALUE(rs_asset) TYPE zif_abapgit_gui_asset_manager~ty_web_asset
      RAISING
        zcx_abapgit_exception.

ENDCLASS.



CLASS ZCL_ABAPGIT_GUI_ASSET_MANAGER IMPLEMENTATION.


  METHOD get_mime_asset.

    DATA: ls_key    TYPE wwwdatatab,
          lv_size_c TYPE wwwparams-value,
          lv_size   TYPE i,
          lt_w3mime TYPE STANDARD TABLE OF w3mime.

    ls_key-relid = 'MI'.
    ls_key-objid = iv_mime_name.

    " Get exact file size
    CALL FUNCTION 'WWWPARAMS_READ'
      EXPORTING
        relid            = ls_key-relid
        objid            = ls_key-objid
        name             = 'filesize'
      IMPORTING
        value            = lv_size_c
      EXCEPTIONS
        entry_not_exists = 1.

    IF sy-subrc IS NOT INITIAL.
      RETURN.
    ENDIF.

    lv_size = lv_size_c.

    " Get binary data
    CALL FUNCTION 'WWWDATA_IMPORT'
      EXPORTING
        key               = ls_key
      TABLES
        mime              = lt_w3mime
      EXCEPTIONS
        wrong_object_type = 1
        import_error      = 2.

    IF sy-subrc IS NOT INITIAL.
      RETURN.
    ENDIF.

    rv_xdata = zcl_abapgit_string_utils=>bintab_to_xstring(
      iv_size   = lv_size
      it_bintab = lt_w3mime ).

  ENDMETHOD.


  METHOD load_asset.

    MOVE-CORRESPONDING is_asset_entry TO rs_asset.
    IF rs_asset-content IS INITIAL AND is_asset_entry-mime_name IS NOT INITIAL.
      " inline content has the priority
      rs_asset-content = get_mime_asset( is_asset_entry-mime_name ).
    ENDIF.
    IF rs_asset-content IS INITIAL.
      zcx_abapgit_exception=>raise( |failed to load GUI asset: { is_asset_entry-url }| ).
    ENDIF.

  ENDMETHOD.


  METHOD register_asset.

    DATA ls_asset LIKE LINE OF mt_asset_register.

    SPLIT iv_type AT '/' INTO ls_asset-type ls_asset-subtype.
    ls_asset-url          = iv_url.
    ls_asset-mime_name    = iv_mime_name.
    ls_asset-is_cacheable = iv_cachable.
    IF iv_base64 IS NOT INITIAL.
      ls_asset-content = zcl_abapgit_string_utils=>base64_to_xstring( iv_base64 ).
    ELSEIF iv_inline IS NOT INITIAL.
      ls_asset-content = zcl_abapgit_string_utils=>string_to_xstring( iv_inline ).
    ENDIF.

    APPEND ls_asset TO mt_asset_register.

  endmethod.


  METHOD zif_abapgit_gui_asset_manager~get_all_assets.

    FIELD-SYMBOLS <a> LIKE LINE OF mt_asset_register.

    LOOP AT mt_asset_register ASSIGNING <a>.
      APPEND load_asset( <a> ) TO rt_assets.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_abapgit_gui_asset_manager~get_asset.

    FIELD-SYMBOLS <a> LIKE LINE of mt_asset_register.

    READ TABLE mt_asset_register WITH KEY url = iv_url ASSIGNING <a>.
    IF <a> IS NOT ASSIGNED.
      zcx_abapgit_exception=>raise( |Cannot find GUI asset: { iv_url }| ).
    ENDIF.
    rs_asset = load_asset( <a> ).

  ENDMETHOD.


  METHOD zif_abapgit_gui_asset_manager~get_text_asset.

    FIELD-SYMBOLS <a> LIKE LINE OF mt_asset_register.
    DATA ls_asset TYPE zif_abapgit_gui_asset_manager~ty_web_asset.

    READ TABLE mt_asset_register WITH KEY url = iv_url ASSIGNING <a>.
    IF <a> IS NOT ASSIGNED.
      zcx_abapgit_exception=>raise( |Cannot find GUI asset: { iv_url }| ).
    ENDIF.
    ls_asset = load_asset( <a> ).

    rv_asset = cl_bcs_convert=>xstring_to_string(
      iv_xstr = ls_asset-content
      iv_cp   = '4110' ). " UTF8

  endmethod.
ENDCLASS.

* GUI

CLASS zcl_abapgit_gui DEFINITION FINAL .

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_event_state,
        not_handled         VALUE 0,
        re_render           VALUE 1,
        new_page            VALUE 2,
        go_back             VALUE 3,
        no_more_act         VALUE 4,
        new_page_w_bookmark VALUE 5,
        go_back_to_bookmark VALUE 6,
        new_page_replacing  VALUE 7,
      END OF c_event_state .

    CONSTANTS:
      BEGIN OF c_action,
        go_home TYPE string VALUE 'go_home',
      END OF c_action.

    METHODS go_home
      RAISING
        zcx_abapgit_exception.

    METHODS back
      IMPORTING
        iv_to_bookmark TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rv_exit) TYPE xfeld
      RAISING
        zcx_abapgit_exception.

    METHODS on_event FOR EVENT sapevent OF cl_gui_html_viewer
      IMPORTING
        action
        frame
        getdata
        postdata
        query_table.

    METHODS constructor
      IMPORTING
        ii_router    TYPE REF TO zif_abapgit_gui_router
        ii_asset_man TYPE REF TO zif_abapgit_gui_asset_manager
      RAISING
        zcx_abapgit_exception.

    METHODS free.

    EVENTS on_error
      EXPORTING
        VALUE(io_exception) TYPE REF TO cx_root.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_page_stack,
        page     TYPE REF TO zif_abapgit_gui_page,
        bookmark TYPE abap_bool,
      END OF ty_page_stack.

    DATA: mi_cur_page    TYPE REF TO zif_abapgit_gui_page,
          mt_stack       TYPE STANDARD TABLE OF ty_page_stack,
          mi_router      TYPE REF TO zif_abapgit_gui_router,
          mi_asset_man   TYPE REF TO zif_abapgit_gui_asset_manager,
          mo_html_viewer TYPE REF TO cl_gui_html_viewer.

    METHODS startup
      RAISING
        zcx_abapgit_exception.

    METHODS cache_html
      IMPORTING
        iv_text       TYPE string
      RETURNING
        VALUE(rv_url) TYPE w3url.

    METHODS cache_asset
      IMPORTING
        iv_text       TYPE string OPTIONAL
        iv_xdata      TYPE xstring OPTIONAL
        iv_url        TYPE w3url OPTIONAL
        iv_type       TYPE c
        iv_subtype    TYPE c
      RETURNING
        VALUE(rv_url) TYPE w3url.

    METHODS render
      RAISING
        zcx_abapgit_exception.

    METHODS get_current_page_name
      RETURNING
        VALUE(rv_page_name) TYPE string.

    METHODS call_page
      IMPORTING
        ii_page          TYPE REF TO zif_abapgit_gui_page
        iv_with_bookmark TYPE abap_bool DEFAULT abap_false
        iv_replacing     TYPE abap_bool DEFAULT abap_false
      RAISING
        zcx_abapgit_exception.

    METHODS handle_action
      IMPORTING
        iv_action      TYPE c
        iv_frame       TYPE c OPTIONAL
        iv_getdata     TYPE c OPTIONAL
        it_postdata    TYPE cnht_post_data_tab OPTIONAL
        it_query_table TYPE cnht_query_table OPTIONAL.

ENDCLASS.

CLASS ZCL_ABAPGIT_GUI IMPLEMENTATION.

  METHOD back.

    DATA: lv_index TYPE i,
          ls_stack LIKE LINE OF mt_stack.

    lv_index = lines( mt_stack ).

    IF lv_index = 0.
      rv_exit = abap_true.
      RETURN.
    ENDIF.

    DO lv_index TIMES.
      READ TABLE mt_stack INDEX lv_index INTO ls_stack.
      ASSERT sy-subrc = 0.

      DELETE mt_stack INDEX lv_index.
      ASSERT sy-subrc = 0.

      lv_index = lv_index - 1.

      IF iv_to_bookmark = abap_false OR ls_stack-bookmark = abap_true.
        EXIT.
      ENDIF.
    ENDDO.

    mi_cur_page = ls_stack-page. " last page always stays
    render( ).

  ENDMETHOD.


  METHOD cache_asset.

    DATA: lv_xstr  TYPE xstring,
          lt_xdata TYPE lvc_t_mime,
          lv_size  TYPE int4.

    ASSERT iv_text IS SUPPLIED OR iv_xdata IS SUPPLIED.

    IF iv_text IS SUPPLIED. " String input
      lv_xstr = zcl_abapgit_string_utils=>string_to_xstring( iv_text ).
    ELSE. " Raw input
      lv_xstr = iv_xdata.
    ENDIF.

    zcl_abapgit_string_utils=>xstring_to_bintab(
      EXPORTING
        iv_xstr   = lv_xstr
      IMPORTING
        ev_size   = lv_size
        et_bintab = lt_xdata ).

    mo_html_viewer->load_data(
      EXPORTING
        type         = iv_type
        subtype      = iv_subtype
        size         = lv_size
        url          = iv_url
      IMPORTING
        assigned_url = rv_url
      CHANGING
        data_table   = lt_xdata
      EXCEPTIONS
        OTHERS       = 1 ) ##NO_TEXT.

    ASSERT sy-subrc = 0. " Image data error

  ENDMETHOD.


  METHOD cache_html.

    rv_url = cache_asset( iv_text    = iv_text
                          iv_type    = 'text'
                          iv_subtype = 'html' ).

  ENDMETHOD.


  METHOD call_page.

    DATA: ls_stack TYPE ty_page_stack.

    IF iv_replacing = abap_false AND NOT mi_cur_page IS INITIAL.
      ls_stack-page     = mi_cur_page.
      ls_stack-bookmark = iv_with_bookmark.
      APPEND ls_stack TO mt_stack.
    ENDIF.

    mi_cur_page = ii_page.
    render( ).

  ENDMETHOD.


  METHOD constructor.

    mi_router    = ii_router.
    mi_asset_man = ii_asset_man.
    startup( ).

  ENDMETHOD.


  METHOD free.

    SET HANDLER me->on_event FOR mo_html_viewer ACTIVATION space.
    mo_html_viewer->close_document( ).
    mo_html_viewer->free( ).
    FREE mo_html_viewer.

  ENDMETHOD.


  METHOD get_current_page_name.
    IF mi_cur_page IS BOUND.
      rv_page_name = cl_abap_classdescr=>describe_by_object_ref( mi_cur_page )->get_relative_name( ).
    ENDIF." ELSE - return is empty => initial page

  ENDMETHOD.


  METHOD go_home.

    on_event( action = |{ c_action-go_home }| ). " doesn't accept strings directly

  ENDMETHOD.


  METHOD handle_action.

    DATA: lx_exception TYPE REF TO zcx_abapgit_exception,
          li_page      TYPE REF TO zif_abapgit_gui_page,
          lv_state     TYPE i.

    TRY.
        IF mi_cur_page IS BOUND.
          mi_cur_page->on_event(
            EXPORTING
              iv_action    = iv_action
              iv_prev_page = get_current_page_name( )
              iv_getdata   = iv_getdata
              it_postdata  = it_postdata
            IMPORTING
              ei_page      = li_page
              ev_state     = lv_state ).
        ENDIF.

        IF lv_state IS INITIAL.
          mi_router->on_event(
            EXPORTING
              iv_action    = iv_action
              iv_prev_page = get_current_page_name( )
              iv_getdata   = iv_getdata
              it_postdata  = it_postdata
            IMPORTING
              ei_page      = li_page
              ev_state     = lv_state ).
        ENDIF.

        CASE lv_state.
          WHEN zcl_abapgit_gui=>c_event_state-re_render.
            render( ).
          WHEN zcl_abapgit_gui=>c_event_state-new_page.
            call_page( li_page ).
          WHEN zcl_abapgit_gui=>c_event_state-new_page_w_bookmark.
            call_page( ii_page = li_page iv_with_bookmark = abap_true ).
          WHEN zcl_abapgit_gui=>c_event_state-new_page_replacing.
            call_page( ii_page = li_page iv_replacing = abap_true ).
          WHEN zcl_abapgit_gui=>c_event_state-go_back.
            back( ).
          WHEN zcl_abapgit_gui=>c_event_state-go_back_to_bookmark.
            back( abap_true ).
          WHEN zcl_abapgit_gui=>c_event_state-no_more_act.
            " Do nothing, handling completed
          WHEN OTHERS.
            zcx_abapgit_exception=>raise( |Unknown action: { iv_action }| ).
        ENDCASE.

      CATCH zcx_abapgit_exception INTO lx_exception.
        RAISE EVENT on_error EXPORTING io_exception = lx_exception.
      CATCH zcx_abapgit_cancel ##NO_HANDLER.
        " Do nothing = gc_event_state-no_more_act
    ENDTRY.

  ENDMETHOD.


  METHOD on_event.

    handle_action(
      iv_action      = action
      iv_frame       = frame
      iv_getdata     = getdata
      it_postdata    = postdata
      it_query_table = query_table ).

  ENDMETHOD.


  METHOD render.

    DATA: lv_url  TYPE w3url,
          li_html TYPE REF TO zif_abapgit_html.

    li_html = mi_cur_page->render( ).
    lv_url  = cache_html( li_html->render( iv_no_indent_jscss = abap_true ) ).

    mo_html_viewer->show_url( lv_url ).

  ENDMETHOD.


  METHOD startup.

    DATA: lt_events TYPE cntl_simple_events,
          ls_event  LIKE LINE OF lt_events,
          lt_assets TYPE zif_abapgit_gui_asset_manager=>tt_web_assets.

    FIELD-SYMBOLS <ls_asset> LIKE LINE OF lt_assets.

    CREATE OBJECT mo_html_viewer
      EXPORTING
        query_table_disabled = abap_true
        parent               = cl_gui_container=>screen0.

    lt_assets = mi_asset_man->get_all_assets( ).
    LOOP AT lt_assets ASSIGNING <ls_asset> WHERE is_cacheable = abap_true.
      cache_asset( iv_xdata   = <ls_asset>-content
                   iv_url     = <ls_asset>-url
                   iv_type    = <ls_asset>-type
                   iv_subtype = <ls_asset>-subtype ).
    ENDLOOP.

    ls_event-eventid    = mo_html_viewer->m_id_sapevent.
    ls_event-appl_event = abap_true.
    APPEND ls_event TO lt_events.

    mo_html_viewer->set_registered_events( lt_events ).
    SET HANDLER me->on_event FOR mo_html_viewer.

  ENDMETHOD.
ENDCLASS.
