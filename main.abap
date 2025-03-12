*&---------------------------------------------------------------------*
*& Report ZHR060_P_TKR_KSNTLRN_TKB
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhr060_p_toplu_uretim.


INCLUDE ZHR060_I_TOPLU_URETIM_TOP.
INCLUDE ZHR060_I_TOPLU_URETIM_SEL.
INCLUDE ZHR060_I_TOPLU_URETIM_CLS.
INCLUDE ZHR060_I_TOPLU_URETIM_MDL.




START-OF-SELECTION.
 GET pernr.
  rp_provide_from_frst p0000 space pn-begda pn-endda.
  rp_provide_from_frst p0002 space pn-begda pn-endda.
  rp_provide_from_frst p0009 space pn-begda pn-endda.
  rp_provide_from_frst p0105 space pn-begda pn-endda.
  rp_provide_from_frst p0014 space pn-begda pn-endda.
  rp_provide_from_frst p0770 space pn-begda pn-endda.

lcl_main_controller=>get_data( ).

END-OF-SELECTION.
lcl_main_controller=>end_of_selection( ).
