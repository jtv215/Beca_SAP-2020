*&---------------------------------------------------------------------*
*& Report Z2020_CARGAXK01_00
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z2020_cargaxk01_01.
INCLUDE z2020_cargaxk01_001_top.
INCLUDE z2020_cargaxk01_001_scr.
INCLUDE z2020_cargaxk01_001_sub.



* LOGICA PRINCIPAL
START-OF-SELECTION.
  gv_repid = sy-repid.
  PERFORM logica_principal.

END-OF-SELECTION.

  PERFORM imprimir.