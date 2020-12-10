*&---------------------------------------------------------------------*
*&  Include           Z2020_LISTAAEROPUERTO_01_TOP
*&---------------------------------------------------------------------*

TABLES: scitairp, sairport, scounter, scarr.

TYPES: BEGIN OF gt_salida,
      city       like scitairp-city,
      country    like scitairp-country,
      airport    like scitairp-airport,
      mastercity like scitairp-mastercity,
      id         like sairport-id,
      name       like sairport-name,
      carrid     like scounter-carrid,
      countnum   like scounter-countnum,
      carrname   like scarr-carrname,
      currcode   like scarr-currcode,
      END OF gt_salida.

DATA: gi_salida TYPE STANDARD TABLE OF gt_salida,
      gs_salida TYPE gt_salida.

*Variables de tipo ALV y Layout
DATA: gi_fieldcat TYPE slis_t_fieldcat_alv,
      gs_layout   TYPE slis_layout_alv.