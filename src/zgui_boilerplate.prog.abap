selection-screen begin of screen 1001.
* dummy screen for html
selection-screen end of screen 1001.

* sap back command re-direction
at selection-screen on exit-command.
  perform exit.

include zgui_boilerplate_abapgit_lib if found.
include zgui_boilerplate_forms.
include zgui_boilerplate_html.
