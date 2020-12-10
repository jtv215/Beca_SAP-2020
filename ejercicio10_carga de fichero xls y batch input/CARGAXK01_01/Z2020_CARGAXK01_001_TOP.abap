*&---------------------------------------------------------------------*
*&  Include           Z2020_CARGAXK01_00_00_TOP
*&---------------------------------------------------------------------*


TYPES: BEGIN OF gt_fichero,
         nombre    LIKE lfa1-name1,
         calle     LIKE lfa1-stras,
         poblacion LIKE lfa1-ort01,
         c_p       LIKE lfa1-pstlz,
         telefono  LIKE lfa1-telf1,
       END OF gt_fichero.

DATA: gi_fichero TYPE STANDARD TABLE OF gt_fichero,
      gs_fichero LIKE LINE OF gi_fichero.

* Declaraciones batch input

DATA: gi_bdcdata TYPE STANDARD TABLE OF bdcdata.
DATA: gs_bdcdata TYPE bdcdata.

DATA gi_tabla_msg TYPE STANDARD TABLE OF bdcmsgcoll.
DATA gs_tabla_msg TYPE bdcmsgcoll.

* Tabla para log de mensajes.
TYPES: BEGIN OF gt_alv,
         nombre    LIKE lfa1-name1,
         calle     LIKE lfa1-stras,
         poblacion LIKE lfa1-ort01,
         c_p       LIKE lfa1-pstlz,
         telefono  LIKE lfa1-telf1,
         mensaje   TYPE string,
       END OF gt_alv.
DATA: gi_alv TYPE STANDARD TABLE OF gt_alv,
      gs_alv TYPE gt_alv.

DATA: gi_fieldcat TYPE slis_t_fieldcat_alv,
      gs_layout   TYPE slis_layout_alv,
      gv_repid    LIKE sy-repid.