*DECLARACIONES
TABLES: mara, marc.

*Tipos
TYPES: BEGIN OF gt_salida,
         matnr LIKE mara-matnr,
         ersda LIKE mara-ersda,
         werks LIKE marc-werks,
       END OF gt_salida.

*Tablas Internas y Estructura.
DATA: gi_salida TYPE STANDARD TABLE OF gt_salida.
DATA: gs_salida TYPE gt_salida.

*Declaraciones ALV
DATA: gi_fieldcat TYPE slis_t_fieldcat_alv,
      gs_layout   TYPE slis_layout_alv.