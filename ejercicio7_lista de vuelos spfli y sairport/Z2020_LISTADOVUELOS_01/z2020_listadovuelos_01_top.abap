*&---------------------------------------------------------------------*
*&  Include           Z2020_LISTADOVUELOS_01_TOP
*&---------------------------------------------------------------------*

TABLES: sairport, spfli.

*DECLARACIONES
*Tipos
TYPES: BEGIN OF gt_salida,
      id        like sairport-id,
      name      like sairport-name,
      countryto like spfli-countryto,
      countryfr like spfli-countryfr,
      carrid    like spfli-carrid,
      connid    like spfli-connid,
      airpto    like spfli-airpto,
      airpfrom  like spfli-airpfrom,
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