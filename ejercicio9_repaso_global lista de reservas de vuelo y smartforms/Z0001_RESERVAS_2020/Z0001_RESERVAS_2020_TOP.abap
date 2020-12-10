*&---------------------------------------------------------------------*
*&  Include           Z0001_RESERVAS_2020_TOP
*&---------------------------------------------------------------------*

TABLES: scarr, sflight, snvoice.

*DECLARACIONES
*Tipos
TYPES: BEGIN OF gt_salida,
      carrid      like scarr-carrid,
      carrname    like scarr-carrname,
      connid      like sflight-connid,
      fldate      like sflight-fldate,
      seatsmax    like sflight-seatsmax,
      seatsmax_b  like sflight-seatsmax_b,
      seatsmax_f  like sflight-seatsmax_f,
      seatsocc    like sflight-seatsocc,
      seatsocc_b  like sflight-seatsocc_b,
      seatsocc_f  like sflight-seatsocc_f,
      libre       type sflight-seatsmax,
      bookid      like snvoice-bookid,
      customid    like snvoice-customid,
      instno      like snvoice-instno,
      amount      like snvoice-amount,
      currency    like snvoice-currency,
      END OF gt_salida.

*Tablas internas y estructuras
DATA: gi_salida TYPE STANDARD TABLE OF gt_salida,
      gs_salida TYPE gt_salida.

*Variables de tipo ALV y Layout
DATA: gi_fieldcat TYPE slis_t_fieldcat_alv,
      gs_layout   TYPE slis_layout_alv.

*ALV Header declarations
DATA: lt_header TYPE slis_t_listheader,
      ls_header TYPE slis_listheader,
      lt_line   LIKE ls_header-info.

DATA: g_repid   TYPE sy-repid.
g_repid = sy-repid.

*DATA: g_output_options TYPE ssfcompop,  " Output Options for Smartform
*      g_control_options TYPE ssfctrlop.