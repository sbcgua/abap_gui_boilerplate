selection-screen begin of screen 1001.
* dummy screen for html
selection-screen end of screen 1001.

* sap back command re-direction
at selection-screen on exit-command.
  perform exit.

at selection-screen output.
  perform htmlscr_hide_standard_buttons.

include zguibp_html_classes.
include zguibp_forms.
