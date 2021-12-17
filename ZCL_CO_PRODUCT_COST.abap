class ZCL_CO_PRODUCT_COST definition
  public
  final
  create public .

public section.

  types:
    begin of ty_itab,
             poper   type poper,
             gjhar   type gjahr,
             werks   type werks_d,
             matnr   type matnr,
             maktx   type maktx,
             categ   type CKML_CATEG,
             categtxt type DOMVALUE,
             quant   type kkb_ml_menge,
             meins   type meins,
             stval   type kkb_ml_bewer,
             prd     type ml4h_prd,
             kdm     type ml4h_kdm,
             total   type kkb_ml_ges,
             price   type kkb_ml_preis,
             "elesmhk type ck_elesmhk,
             ELM001  type MLCCS_D_ELM,
             ELM002  type MLCCS_D_ELM,
             ELM003  type MLCCS_D_ELM,
             ELM004  type MLCCS_D_ELM,
             ELM005  type MLCCS_D_ELM,
             ELM006  type MLCCS_D_ELM,
             ELM007  type MLCCS_D_ELM,
             ELM008  type MLCCS_D_ELM,
             ELM009  type MLCCS_D_ELM,
             ELM010  type MLCCS_D_ELM,
             ELM011  type MLCCS_D_ELM,
             ELM012  type MLCCS_D_ELM,
             ELM013  type MLCCS_D_ELM,
             ELM014  type MLCCS_D_ELM,
             ELM015  type MLCCS_D_ELM,
             ELM016  type MLCCS_D_ELM,
             ELM017  type MLCCS_D_ELM,
             ELM018  type MLCCS_D_ELM,

           end of ty_itab .

  data LT_ALL_SUM type FCML4H_COMMON_CCS_T .
  data:
    lt_cust type table of ty_itab .
  data:
    gt_elements type table of TCKH1 .

  methods GET_COST_MATERIAL
    importing
      !I_MATNR type MATNR
      !I_WERKS type WERKS_D
      !I_POPER type POPER
      !I_GJAHR type GJAHR
    exporting
      !E_CUST type TY_ITAB .

  methods GET_COST_MATERIAL_T
    importing
      !I_MATNR type MATNR
      !I_WERKS type WERKS_D
      !I_POPER type POPER
      !I_GJAHR type GJAHR     .


  protected section.
private section.

  methods GET_COST_DETAIL
    importing
      !I_MATNR type MATNR
      !I_WERKS type WERKS_D
      !I_POPER type POPER
      !I_GJAHR type GJAHR .

  methods GET_TXTMATERIAL
    importing
      !I_MATNR type MATNR
    returning
      value(RE_MAKTX) type MAKTX .




ENDCLASS.



CLASS ZCL_CO_PRODUCT_COST IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_CO_PRODUCT_COST->GET_COST_DETAIL
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_MATNR                        TYPE        MATNR
* | [--->] I_WERKS                        TYPE        WERKS_D
* | [--->] I_POPER                        TYPE        POPER
* | [--->] I_GJAHR                        TYPE        GJAHR
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method get_cost_detail.

    data: begin of ref_tab_line,
            kalnr  type mlkey-kalnr,
            runtyp type ckmlrunperiod-run_type,
            poper  type ckmlrunperiod-poper,
            bdatj  type ckmlrunperiod-gjahr,
            appl   type ckmlrunperiod-appl,
            elehk  type ck_elesmhk,
            ml_ref type ref to cl_ml_data_select,
          end of ref_tab_line,

          ref_tab like sorted table of ref_tab_line
                    with unique key kalnr poper bdatj elehk appl runtyp.
    data: ref_tab_line1     like line of ref_tab.

    constants: g_runref    type mldoc-runref value 'ACT',
               g_ccs_elehk type char2 value 'Z1',
               c_rldnr type char2 value '0L'.

    data gr_select type ref to cl_ml_data_select.
    data : mlkey type mlkey.

    " data lt_all_sum type  fcml4h_common_ccs_t.
    data : t_tckh3  type standard table of tckh3
                                   with non-unique key elehk elemt .
    data lt_jahper type range of mldoc-jahrper.

    lt_jahper = value #( ( sign = 'I' option = 'EQ' low = |{ i_gjahr }{ i_poper }|  high = |{ i_gjahr }{ i_poper }| ) ).

    select * from tckh3 into table t_tckh3  where elehk = g_ccs_elehk.
    select * from tckh1 into table gt_elements where elehk = g_ccs_elehk and spras = sy-langu.


    select single kalnr into @data(vl_kalnr) from ckmlhd where matnr eq @i_matnr and bwkey eq @i_werks.


    mlkey-matnr = i_matnr.
    mlkey-bwkey = i_werks.
    mlkey-kalnr = vl_kalnr.
    mlkey-curtp = 10.
    mlkey-bdatj = i_gjahr.
    mlkey-poper = i_poper.



    create object gr_select
      exporting
        iv_kalnr   = mlkey-kalnr
        iv_rldnr = c_rldnr
        iv_runref  = g_runref
        iv_no_st = ''
        it_jahrper = lt_jahper
        it_tckh3   = t_tckh3
        iv_elesmhk = g_ccs_elehk.

    move-corresponding mlkey to ref_tab_line1.
    ref_tab_line1-appl   = ''. "ckmlrunperiod-appl.
    ref_tab_line1-runtyp = ''. "ckmlrunperiod-run_type.
    ref_tab_line1-elehk  = g_ccs_elehk.
    if gr_select is bound.
      ref_tab_line1-ml_ref = gr_select.
      insert ref_tab_line1 into table ref_tab.
    endif.


    call method gr_select->get_sum_init
      exporting
        iv_curtp           = mlkey-curtp
        iv_keart           = 'H' " gs_ccskey-keart
        iv_mlcct           = '' " lv_mlcct
        iv_varfix          = '' "gs_ccskey-varfix
        iv_kkzst           = '' "gs_ccskey-kkzst
        iv_svrel           = abap_true                "to get all CCS
        iv_wip             = '' "gv_show_wip
      importing
        et_sum             = lt_all_sum
      exceptions
        material_not_found = 1
        internal_error     = 2
        others             = 3.

   if sy-subrc eq 0.

   endif.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CO_PRODUCT_COST->GET_COST_MATERIAL
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_MATNR                        TYPE        MATNR
* | [--->] I_WERKS                        TYPE        WERKS_D
* | [--->] I_POPER                        TYPE        POPER
* | [--->] I_GJAHR                        TYPE        GJAHR
* | [<---] E_CUST                         TYPE        TY_ITAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method get_cost_material.
    data ls_cust type  ty_itab.

    me->get_cost_detail( i_matnr = i_matnr i_werks = i_werks  i_poper =  i_poper i_gjahr = i_gjahr ).




    try.
        data(lt_cust_stock_final) = value #( lt_all_sum[ categ = 'EB' ] ).
        ls_cust = corresponding #( lt_cust_stock_final ).
      catch cx_sy_itab_line_not_found.

    endtry.

    if ls_cust-quant = 0 . "Estoque final zero.
      clear lt_cust_stock_final.
      try.
          lt_cust_stock_final = value #( lt_all_sum[ categ = 'KB' ] ).
          ls_cust = corresponding #( lt_cust_stock_final ).

          ls_cust-total =  ( ls_cust-stval + ls_cust-prd + ls_cust-kdm ) .
          try .
              ls_cust-price = ls_cust-total  / ls_cust-quant .
            catch cx_sy_zerodivide.
          endtry.

          try .
              ls_cust-elm001 = ls_cust-elm001 / ls_cust-quant .
            catch cx_sy_zerodivide.
          endtry.
          try .
              ls_cust-elm002 = ls_cust-elm002 / ls_cust-quant .
            catch cx_sy_zerodivide.
          endtry.
          try .
              ls_cust-elm003 = ls_cust-elm003 / ls_cust-quant .
            catch cx_sy_zerodivide.
          endtry.
          try .
              ls_cust-elm004 = ls_cust-elm004 / ls_cust-quant .
            catch cx_sy_zerodivide.
          endtry.
          try .
              ls_cust-elm005 = ls_cust-elm005 / ls_cust-quant .
            catch cx_sy_zerodivide.
          endtry.
          try .
              ls_cust-elm006 = ls_cust-elm006 / ls_cust-quant .
            catch cx_sy_zerodivide.
          endtry.
          try .
              ls_cust-elm007 = ls_cust-elm007 / ls_cust-quant .
            catch cx_sy_zerodivide.
          endtry.
          try .
              ls_cust-elm008 = ls_cust-elm008 / ls_cust-quant .
            catch cx_sy_zerodivide.
          endtry.
          try .
              ls_cust-elm009 = ls_cust-elm009 / ls_cust-quant .
            catch cx_sy_zerodivide.
          endtry.
          try .
              ls_cust-elm010 = ls_cust-elm010 / ls_cust-quant .
            catch cx_sy_zerodivide.
          endtry.
          try .
              ls_cust-elm011 = ls_cust-elm011 / ls_cust-quant .
            catch cx_sy_zerodivide.
          endtry.
          try .
              ls_cust-elm012 = ls_cust-elm012 / ls_cust-quant .
            catch cx_sy_zerodivide.
          endtry.
          try .
              ls_cust-elm013 = ls_cust-elm013 / ls_cust-quant .
            catch cx_sy_zerodivide.
          endtry.
          try .
              ls_cust-elm014 = ls_cust-elm014 / ls_cust-quant .
            catch cx_sy_zerodivide.
          endtry.
          try .
              ls_cust-elm015 = ls_cust-elm015 / ls_cust-quant .
            catch cx_sy_zerodivide.
          endtry.
          try .
              ls_cust-elm016 = ls_cust-elm016 / ls_cust-quant .
            catch cx_sy_zerodivide.
          endtry
          .try .
          ls_cust-elm017 = ls_cust-elm017 / ls_cust-quant .
        catch cx_sy_zerodivide.
      endtry.
      try .
          ls_cust-elm018 = ls_cust-elm018 / ls_cust-quant .
        catch cx_sy_zerodivide.
      endtry.

      ls_cust-quant = 0.
      ls_cust-total = 0.
      ls_cust-stval = 0.
      ls_cust-prd = 0.
      ls_cust-kdm = 0.


    catch cx_sy_itab_line_not_found.

  endtry.
else.

  ls_cust-total =  ( ls_cust-stval + ls_cust-prd + ls_cust-kdm ) .
  try .
      ls_cust-price = ls_cust-total  / ls_cust-quant .
    catch cx_sy_zerodivide.
  endtry.
endif.



ls_cust-werks = i_werks.
ls_cust-matnr = i_matnr.
ls_cust-maktx = me->get_txtmaterial( exporting i_matnr =  i_matnr ).
ls_cust-poper = i_poper.
ls_cust-gjhar = i_gjahr.

e_cust = ls_cust.

endmethod.

method get_cost_material_t.
    data ls_cust type  ty_itab.
    data lt_cust_detail type table of ty_itab.

    me->get_cost_detail( i_matnr = i_matnr i_werks = i_werks  i_poper =  i_poper i_gjahr = i_gjahr ).

    try.
      lt_cust_detail = corresponding #( lt_all_sum ).
      " data(lt_cust_stock_final) = value #( lt_all_sum[ categ = 'EB' ] ).
      "  ls_cust = corresponding #( lt_cust_stock_final ).

      catch cx_sy_itab_line_not_found.

    endtry.

    "Seleciona descrição das categorias:
    Select DOMVALUE_L as categ, DDTEXT as categtxt
      from DD07T
      into table @data(lt_categ)
       where DOMNAME = 'CKML_CATEG'
       and DDLANGUAGE  = @sy-langu.

    loop at lt_cust_detail assigning field-symbol(<fs_cust>).
        <fs_cust>-matnr = i_matnr.
        <fs_cust>-maktx = me->get_txtmaterial( exporting i_matnr =  i_matnr ).
        <fs_cust>-werks = i_werks.
        <fs_cust>-poper = i_poper.
        <fs_cust>-gjhar = i_gjahr.
        <fs_cust>-categtxt = lt_categ[ categ = <fs_cust>-categ ]-categtxt.

        "Sumariza a categoria de consumo
        collect <fs_cust> into lt_cust.
    endloop.

    unassign <fs_cust>.

    loop at lt_cust assigning <fs_cust>.
        <fs_cust>-total =  (  <fs_cust>-stval +  <fs_cust>-prd +  <fs_cust>-kdm ) .
        try .
         <fs_cust>-price =  <fs_cust>-total  /  <fs_cust>-quant .
        catch cx_sy_zerodivide.
        endtry.
    endloop.





endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_CO_PRODUCT_COST->GET_TXTMATERIAL
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_MATNR                        TYPE        MATNR
* | [<-()] RE_MAKTX                       TYPE        MAKTX
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_TXTMATERIAL.

    select single maktx  into re_maktx from makt where matnr = i_matnr and spras = sy-langu.

  endmethod.

ENDCLASS.
