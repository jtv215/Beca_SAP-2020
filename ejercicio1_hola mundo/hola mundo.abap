&---------------------------------------------------------------------*
*& Report ZHOLAMUNDO2020_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zholamundo2020_01.

*DECLARACIONES
DATA: gv_texto TYPE string.
*PANTALLA DE SELECCIÓN
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE Text-001.
PARAMETERS: p_ent(20) TYPE c OBLIGATORY.
PARAMETERS: p_ent2(20) TYPE c OBLIGATORY.

SELECTION-SCREEN END OF BLOCK b1.


* RadioButton
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE Text-002.
PARAMETERS: r_opc1 RADIOBUTTON GROUP gr1, "Imprime parametro1
            r_opc2 RADIOBUTTON GROUP gr1. "Imprime parametro2
SELECTION-SCREEN END OF BLOCK b2.

* LOGICA PRINCIPAL
START-OF-SELECTION.
  PERFORM logica_principal.

END-OF-SELECTION.

  PERFORM imprimir.

*WRITE 'Hola Mundo'.  "Comentario
*&---------------------------------------------------------------------*
*&      Form  LOGICA_PRINCIPAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM logica_principal .
  gv_texto = 'hola Mundo'.

  "IF r_opc1 EQ 'X'.
  "IF r_opc1 = 'X'.

  IF r_opc1 IS NOT INITIAL.
    WRITE p_ent.
  ELSEIF r_opc2 IS NOT INITIAL.
    WRITE p_ent2.
  ELSE.

  ENDIF.


ENDFORM.


FORM imprimir.
  "WRITE gv_texto.
  WRITE p_ent.
  WRITE p_ent2.

ENDFORM.