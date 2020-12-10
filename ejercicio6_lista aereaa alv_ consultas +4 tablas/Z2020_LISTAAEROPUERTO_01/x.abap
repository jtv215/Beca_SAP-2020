*&---------------------------------------------------------------------*
*& Report Z2020_LISTAAEROPUERTO_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z2020_listaaeropuerto_01.

INCLUDE z2020_listaaeropuerto_01_top.
INCLUDE z2020_listaaeropuerto_01_scr.
INCLUDE z2020_listaaeropuerto_01_sub.

*LOGICA PRINCIPAL
START-OF-SELECTION.
  CASE 'X'.
    WHEN r_opc1.
      PERFORM logica_principal.
    WHEN r_opc2.
      PERFORM logica_principal_ss.
    WHEN r_opc3.
      PERFORM logica_principal_join.
    WHEN r_opc4.
      PERFORM logica_principal_cuatroTabla.
    WHEN OTHERS.
  ENDCASE.

END-OF-SELECTION.

*PERFORM imprimir.