*&---------------------------------------------------------------------*
*&  Include           Z2020_LISTAMATERIALES_01_SCR
*&---------------------------------------------------------------------*

*PANTALLA DE SELECCIÓN
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS: s_matnr FOR mara-matnr,
                s_ersda FOR mara-ersda.

SELECTION-SCREEN END OF BLOCK b1.


SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-003.

PARAMETERS: r_opc1 RADIOBUTTON GROUP gr1, "Tablas Locales
            r_opc2 RADIOBUTTON GROUP gr1, "Select Single
            r_opc3 RADIOBUTTON GROUP gr1, "Select Join
            r_opc4 RADIOBUTTON GROUP gr1. "For all Entries

SELECTION-SCREEN END OF BLOCK b3.


SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-004.

PARAMETERS: r_wrt RADIOBUTTON GROUP gr2, "Salida write
            r_alv RADIOBUTTON GROUP gr2. "Salida con ALV

SELECTION-SCREEN END OF BLOCK b4.

SELECTION-SCREEN END OF BLOCK b2.