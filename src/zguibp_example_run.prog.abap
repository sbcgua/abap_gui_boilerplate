selection-screen begin of block b1 with frame title txt_b1.
selection-screen begin of line.
selection-screen comment (24) t_dir for field p_dir.
parameters p_dir type char255 visible length 40.
selection-screen end of line.
selection-screen end of block b1.

form init.
  txt_b1   = 'Program params'.        "#EC NOTEXT
  t_dir    = 'Param 1'.               "#EC NOTEXT
endform.

form main.

  data lx type ref to cx_root.
  data lo_app type ref to lcl_app.

  try.
    create object lo_app.
    lo_app->run( ).
  catch cx_root into lx.
    message lx type 'E'.
  endtry.

endform.                    "run

initialization.
  perform htmlscr_init.
  perform init.

start-of-selection.
  perform main.
