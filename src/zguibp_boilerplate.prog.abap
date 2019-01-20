selection-screen begin of screen 1001.
* dummy screen for html
selection-screen end of screen 1001.

* sap back command re-direction
at selection-screen on exit-command.
  perform exit.

at selection-screen output.
  perform hide_standard_buttons.

include zguibp_html.
include zguibp_forms.
