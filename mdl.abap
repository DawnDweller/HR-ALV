*&---------------------------------------------------------------------*
*& Include          ZCO016_I_SABIT_DEGISKEN_MDL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include zco012_i_transfer_fiili_mdl
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
 lcl_main_controller=>pbo( iv_scrn = sy-dynnr ).
ENDMODULE.

MODULE pai INPUT.
 lcl_main_controller=>pai( iv_scrn = sy-dynnr ).
ENDMODULE.
MODULE ext INPUT.
 lcl_main_controller=>ext( iv_scrn = sy-dynnr ).
ENDMODULE.
