/* S4.C -- EXTEND DIALOG (handle special buttons) */

#include "obdefs.h"
#include "schdefs.h"
#include "schedule.h"

extern int  eparr_tab[2][9],cixind,ciyind,cicolumns,cilines,cishown,
            algn_tab[3][9],sel_tab[CAL_LINES],rpt_decision[9],prdec_tab[9],
            ed_obj,line_number;

extern char linealrt[];

int  extend_dialog(tree,tdef,obj)
OBJECT *tree;
int  tdef,obj;
{
   int  i,j;

   if((tdef==TPRTREPT && (obj==PRSDATE || obj==PREDATE)) ||
      (tdef==TEDITREC && (obj==ERDATE))                  ||
      (tdef==TCALCBD  && (obj==BDSDATE || obj==BDEDATE)) ||
      (tdef==TCALCFD  && (obj==FDDATE))                  ||
      (tdef==TSYSDATE && (obj==SDDATE))                  ||
      (tdef==TGODATE && (obj==GDDATE)))
   {
      do_msgs(tree,tdef,ed_obj,TRUE,FALSE);
      return(ed_obj);
   }

   switch(tdef)
   {
      case TPRTREPT:
                     if(obj==PRSTDEC  || obj==PRETDEC  || obj==PRSUBDEC ||
                        obj==PRXF1DEC || obj==PRXF2DEC || obj==PRXF3DEC ||
                        obj==PRXF4DEC || obj==PRXF5DEC || obj==PRDESDEC)
                        click_decision(tree,obj);
                     else
                     {                        
                      switch(obj)
                      {
                       case PRINBUT: set_decision(tree,IN,ed_obj,obj);
                                     objc_change(tree,obj,0,0,0,0,0,NORMAL,1);
                                     break;
                       case PRLTBUT: set_decision(tree,LESS_THAN,ed_obj,obj);
                                     objc_change(tree,obj,0,0,0,0,0,NORMAL,1);
                                     break;
                       case PRGTBUT: set_decision(tree,GREATER_THAN,ed_obj,obj);
                                     objc_change(tree,obj,0,0,0,0,0,NORMAL,1);
                                     break;
                       case PRLEBUT: set_decision(tree,LT_OR_EQUAL,ed_obj,obj);
                                     objc_change(tree,obj,0,0,0,0,0,NORMAL,1);
                                     break;
                       case PRGEBUT: set_decision(tree,GT_OR_EQUAL,ed_obj,obj);
                                     objc_change(tree,obj,0,0,0,0,0,NORMAL,1);
                                     break;
                       case PREQBUT: set_decision(tree,EQUAL,ed_obj,obj);
                                     objc_change(tree,obj,0,0,0,0,0,NORMAL,1);
                                     break;
                       case PRNEBUT: set_decision(tree,NOT_EQUAL,ed_obj,obj);
                                     objc_change(tree,obj,0,0,0,0,0,NORMAL,1);
                                     break;
                     }
                    }
                    return(ed_obj);
      case TCALINFO:
                    switch(obj)
                    {
                       case CICLEAR:  ci_clear(tree,TRUE);
                                      objc_change(tree,CICLEAR,0,0,0,0,0,NORMAL,1);
                                      break;
                       case CILFARR:  cixind--;
                                      ci_header(tree);
                                      ci_report();
                                      set_hz_pos(tree);
                                      break;
                       case CIRTARR:  cixind++;
                                      ci_header(tree);
                                      ci_report();
                                      set_hz_pos(tree);
                                      break;
                       case CIUPARR:  ci_clear(tree,TRUE);
                                      ciyind--;
                                      set_vt_pos(tree);
                                      ci_report();
                                      break;
                       case CIDNARR:  ci_clear(tree,TRUE);
                                      ciyind++;
                                      set_vt_pos(tree);
                                      ci_report();
                                      break;
                       case CIVTSLID: ci_vt_slider(tree);
                                      ci_clear(tree,TRUE);
                                      set_vt_pos(tree);
                                      ci_report();
                                      break;
                       case CIHZSLID: ci_hz_slider(tree);
                                      set_hz_pos(tree);
                                      ci_report();
                                      break;
                       case CIVTSCR:  vt_scroll(tree);
                                      ci_clear(tree,TRUE);
                                      ci_report();
                                      break;
                       case CIHZSCR:  hz_scroll(tree);
                                      ci_header(tree);
                                      ci_report();
                                      break;
                    }
                    for(i=0; i<CAL_LINES; i++)
                    {
                       if(obj==CIDESCR1+i)
                       {
                          if(!(ob_disabled(tree,obj)))
                          {
                             objc_change(tree,obj,0,0,0,0,0,SELECTED,1);
                             if(i<CAL_LINES-1)
                             {
                                for(j=i+1; j<CAL_LINES; j++)
                                {
                                   if(sel_tab[j]==(-2))
                                      objc_change(tree,CIDESCR1+j,0,0,0,0,0,SELECTED,1);
                                   else
                                      break;
                                }
                             }
                             if(sel_tab[i]==(-2))
                             {
                                for(j=i-1; j>=0; j--)
                                {
                                   if(sel_tab[j]==(-2))
                                      objc_change(tree,CIDESCR1+j,0,0,0,0,0,SELECTED,1);
                                   else
                                   {
                                      objc_change(tree,CIDESCR1+j,0,0,0,0,0,SELECTED,1);
                                      break;
                                   }
                                }
                             }
                          }
                       }
                    }
                    break;
      case TCUSTOM:
                    switch(obj)
                    {
                       case CENTYES:  reset_rbuttons(tree,YEARYES,TRUE);
                                      ob_hide(tree,YEARNO);
                                      objc_draw(tree,YEARPAR,8,0,0,0,0);
                                      break;
                       case CENTNO:   ob_unhide(tree,YEARNO);
                                      objc_draw(tree,YEARPAR,8,0,0,0,0);
                                      break;
                       case STIMEYES: ob_unhide(tree,ETIMEYES);
                                      objc_draw(tree,TIMEPAR,8,0,0,0,0);
                                      break;
                       case STIMENO:  if(ob_selected(tree,ETIMEYES))
                                         reset_rbuttons(tree,ETIMENO,TRUE);
                                      ob_hide(tree,ETIMEYES);
                                      objc_draw(tree,TIMEPAR,8,0,0,0,0);
                                      break;
                    }
                    break;
      case TSELRPT:
                    if(obj>=SPNAME2)
                    {
                       for(i=0; i<10; i++)
                          if(ob_selected(tree,SPNAME1+i))
                             objc_change(tree,SPNAME1+i,0,0,0,0,0,NORMAL,1);
                    }
                    else
                    {
                       for(i=0; i<10; i++)
                          if(ob_selected(tree,SPNAME2+i))
                             objc_change(tree,SPNAME2+i,0,0,0,0,0,NORMAL,1);
                    }
                    break;
      case TEDITRPT:
                    for(i=0; i<9; i++)
                       if(obj==EPCLMCK1+i)
                          check_column(tree,EPCLMCK1+i,TRUE);
                    for(i=0; i<9; i++)
                       if(obj==EPCLMIN1+i)
                          check_column(tree,EPCLMCK1+i,TRUE);
                    for(i=0; i<9; i++)
                    {
                       if(obj==algn_tab[0][i])
                          set_alignment(tree,LEFT,i);
                       else if(obj==algn_tab[1][i])
                          set_alignment(tree,CENTER,i);
                       else if(obj==algn_tab[2][i])
                          set_alignment(tree,RIGHT,i);
                    }

                    if(obj==EPDAILY)
                       show_min_spacing(tree,TRUE);
                    if(obj==EPCOLUMN)
                       hide_min_spacing(tree,TRUE);

                    if(obj==EPDET1 || obj==EPDET2)
                    {
                       check_column(tree,EPCLMCK1,TRUE);
                       set_columns(tree,TRUE);
                       upd_alignments(tree,TRUE);
                    }

                    for(i=0; i<9; i++)
                       if(obj==eparr_tab[0][i])
                           manip_number(tree,PLUS,i);

                    for(i=0; i<9; i++)
                       if(obj==eparr_tab[1][i])
                           manip_number(tree,MINUS,i);

                    if(obj==EPPLUS10)
                       manip_number(tree,PLUS,-10);
                    if(obj==EPMIN10)
                       manip_number(tree,MINUS,-10);

                    if(obj==EPPLUS11)
                       manip_number(tree,PLUS,-11);
                    if(obj==EPMIN11)
                       manip_number(tree,MINUS,-11);

                    if(obj==EPEMPTY || obj==EPDATE || obj==EPTIME ||
                       obj==EPDESCR || obj==EPSUBJ || obj==EPDAYSTO ||
                       obj==EPDAYWK)
                    {
                       chg_column(tree,obj,TRUE);
                       objc_change(tree,obj,0,0,0,0,0,NORMAL,1);
                    }

                    for(i=0; i<5; i++)
                    {
                       if(obj==EPXF1BUT+i)
                       {
                          chg_column(tree,EPXF1BUT+i,TRUE);
                          objc_change(tree,obj,0,0,0,0,0,NORMAL,1);
                       }
                    }

                    tot_columns(tree,TRUE);
                    return(ed_obj);
                    break;

      case TPAGESET:

                    if(obj==PSPGNUM || obj==PSPHEAD  || obj==PSPTIME ||
                       obj==PSPDATE || obj==PSPFILE  || obj==PSEJECT ||
                       obj==PSZERO)
                    {
                       if(ob_selected(tree,obj))
                          objc_change(tree,obj,0,0,0,0,0,NORMAL,1);
                       else 
                          objc_change(tree,obj,0,0,0,0,0,SELECTED,1);

                       up_button();

                       if(obj==PSZERO)
                       {
                          line_number=0;
                          form_alert(1,linealrt);
                          objc_change(tree,obj,0,0,0,0,0,NORMAL,1);
                       }
                    }
                    else
                    {
                    switch(obj)
                    {
                       case PSSNLQ:   reset_rbuttons(tree,PSMDRAFT,TRUE);
                                      set_state(tree,PSMDRAFT,DISABLED);
                                      set_state(tree,PSMBOLD,DISABLED);
                                      set_state(tree,PSMDOUBL,DISABLED);
                                      set_state(tree,PSMEXPAN,DISABLED);
                                      set_state(tree,PSDOUBLD,DISABLED);
                                      objc_draw(tree,PSMBOX,8,0,0,0,0);
                                      break;
                       case PSSPICA:  del_state(tree,PSMDRAFT,DISABLED);
                                      del_state(tree,PSMBOLD,DISABLED);
                                      del_state(tree,PSMDOUBL,DISABLED);
                                      del_state(tree,PSMEXPAN,DISABLED);
                                      del_state(tree,PSDOUBLD,DISABLED);
                                      objc_draw(tree,PSMBOX,8,0,0,0,0);
                                      break;
                       case PSSELITE: if(ob_selected(tree,PSMBOLD))
                                         reset_rbuttons(tree,PSMDRAFT,TRUE);
                                      if(ob_selected(tree,PSDOUBLD))
                                         reset_rbuttons(tree,PSMDRAFT,TRUE);
                                      del_state(tree,PSMDRAFT,DISABLED);
                                      set_state(tree,PSMBOLD,DISABLED);
                                      del_state(tree,PSMDOUBL,DISABLED);
                                      set_state(tree,PSDOUBLD,DISABLED);
                                      objc_draw(tree,PSMBOX,8,0,0,0,0);
                                      break;
                       case PSSCOND: if(ob_selected(tree,PSMBOLD))
                                         reset_rbuttons(tree,PSMDRAFT,TRUE);
                                      if(ob_selected(tree,PSDOUBLD))
                                         reset_rbuttons(tree,PSMDRAFT,TRUE);
                                      del_state(tree,PSMDRAFT,DISABLED);
                                      set_state(tree,PSMBOLD,DISABLED);
                                      del_state(tree,PSMDOUBL,DISABLED);
                                      set_state(tree,PSDOUBLD,DISABLED);
                                      objc_draw(tree,PSMBOX,8,0,0,0,0);
                                      break;
                    }
                    }
                    return(ed_obj);
                    break;
   }
   return(ed_obj);
}


