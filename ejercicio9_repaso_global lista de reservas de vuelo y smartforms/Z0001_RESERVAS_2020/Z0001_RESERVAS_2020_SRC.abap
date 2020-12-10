*&---------------------------------------------------------------------*
*&  Include           Z0001_RESERVAS_2020_SRC
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS: so_compa FOR snvoice-carrid OBLIGATORY.
SELECT-OPTIONS: so_book  FOR snvoice-bookid.

SELECTION-SCREEN END OF BLOCK b1.


*Datos de salida / Tratamiento BBDD
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.

PARAMETERS: r_opc1 RADIOBUTTON GROUP gr1,  "ALV
            r_opc2 RADIOBUTTON GROUP gr1. "Salida por formulario

SELECTION-SCREEN END OF BLOCK b2.