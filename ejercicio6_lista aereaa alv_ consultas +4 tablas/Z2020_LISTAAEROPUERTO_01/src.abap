*&---------------------------------------------------------------------*
*&  Include           Z2020_LISTAAEROPUERTO_01_SCR
*&---------------------------------------------------------------------*


*PANTALLA DE SELECCIÓN

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS: s_pais FOR scitairp-airport.

SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.

PARAMETERS: r_opc1 RADIOBUTTON GROUP gr1, "Tablas locales (2 tablas)
            r_opc2 RADIOBUTTON GROUP gr1, "Select SINGLE (2 tablas)
            r_opc3 RADIOBUTTON GROUP gr1, "Select SINGLE (2 tablas)
            r_opc4 RADIOBUTTON GROUP gr1. "Read table (4 tablas)

SELECTION-SCREEN END OF BLOCK b2.