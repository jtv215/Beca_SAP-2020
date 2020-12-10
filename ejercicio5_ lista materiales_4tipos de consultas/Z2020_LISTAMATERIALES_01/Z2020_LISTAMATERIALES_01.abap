*&---------------------------------------------------------------------*
*& Report Z2020_LISTAMATERIALES_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z2020_listamateriales_01.
include z2020_listamateriales_01_top.
include z2020_listamateriales_01_scr.
include z2020_listamateriales_01_sub.

* LOGICA PRINCIPAL
START-OF-SELECTION.
  CASE 'X'.
    WHEN r_opc1 .
      PERFORM logica_principal.
    WHEN r_opc2.
      PERFORM logica_principal_ss.
    WHEN r_opc3.
      PERFORM logica_principal_join.
      WHEN r_opc4.
      PERFORM logica_principal_fa.
    WHEN OTHERS.
  ENDCASE.

END-OF-SELECTION.

IF gi_salida[] IS INITIAL. " Si no hay datos
    MESSAGE s001(Z2020_01_MENSAJES) DISPLAY LIKE 'E'.
  ELSE.
    PERFORM imprimir.
  ENDIF.