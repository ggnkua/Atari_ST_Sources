/* S7.C -- DESIGN REPORT */

#include "obdefs.h"
#include "schdefs.h"
#include "schedule.h"
#include "ctools.h"

extern int  rpt_index,algn_tab[3][9],prdec_tab[9],prdec2_tab[7],
            dec_counter,rpt_decision[9],too_many_columns,rpt_modified;

extern char rptalrt[],delalrt[],norptalrt[],toevntalrt[],onedescalrt[];

extern long menu_tree;

extern RPT report[NUM_REPORTS];

extern CUSTOM data_entry;

extern WIND window[NUM_WINDS];

sel_report()
{
   OBJECT *tree;
   char **tedptr,*strptr;
   int  i,found,counter,column,rpt_tab[20],exit_obj;

   found=FALSE;

   for(i=0; i<20; i++)
      if(report[i+1].cavailable==TRUE)
         found=TRUE;

   if(!found)
   {
      form_alert(1,norptalrt);
      return(-1);
   }

   rsrc_gaddr(0,TSELRPT,&tree);

   found=FALSE; counter=0; column=0;

   for(i=0; i<10; i++)
   {
      tedptr=(char *)tree[SPNAME1+i].ob_spec;
      strcpy(*tedptr,"\0");
      set_state(tree,SPNAME1+i,DISABLED);
      strptr=(char *)tree[SPCLM1+i].ob_spec;
      strcpy(strptr,"\0");
   }

   for(i=0; i<10; i++)
   {
      tedptr=(char *)tree[SPNAME2+i].ob_spec;
      strcpy(*tedptr,"\0");
      set_state(tree,SPNAME2+i,DISABLED);
      strptr=(char *)tree[SPCLM2+i].ob_spec;
      strcpy(strptr,"\0");
   }
 
   for(i=0; i<20; i++)
   {
      if(report[i+1].cavailable==TRUE)
      {
         rpt_tab[counter]=i+1;

         if(counter<10)
            column=1;
         else
            column=2;

         if(column==1)
         {
            del_state(tree,SPNAME1+counter,DISABLED);
            strptr=(char *)tree[SPCLM1+counter].ob_spec;
            tedptr=(char *)tree[SPNAME1+counter].ob_spec;
         }
         else
         {
            del_state(tree,SPNAME2+counter-10,DISABLED);
            strptr=(char *)tree[SPCLM2+counter-10].ob_spec;
            tedptr=(char *)tree[SPNAME2+counter-10].ob_spec;
         }
         
         strcpy(*tedptr,report[i+1].cname);

         if(report[i+1].cavailable==TRUE)
         {
            if(report[i+1].ctot_clms[0]>report[i+1].ctot_clms[1])
            {
               if(report[i+1].ctot_clms[0]>0)
               itoa(report[i+1].ctot_clms[0],strptr);
               else
                  strcpy(strptr,"\0");
            }
            else
            {
               if(report[i+1].ctot_clms[1]>0)
               itoa(report[i+1].ctot_clms[1],strptr);
               else
                  strcpy(strptr,"\0");
            }
            strcpy(strptr,rjustify(strptr,3));
         }
         counter++;
      }
   }

   exit_obj=do_dialog(tree,TSELRPT,0,1,0);

   if(exit_obj!=SPCANCEL)
   {
      for(i=0; i<10; i++)
      {
         if(ob_selected(tree,SPNAME1+i))
            return(rpt_tab[i]);
      }

      for(i=0; i<10; i++)
      {
         if(ob_selected(tree,SPNAME2+i))
            return(rpt_tab[i+10]);
      }
   }
   else
      return(-1);
}

do_edit_report(tdef,sel_flag)
int  tdef,sel_flag;
{
   OBJECT *tree,*sel_tree;
   char **tedptr,*strptr;
   int  i,j,idx,exit_obj,min_spacing,org_info[2][9],
        org_length[2][9],org_spacing[2],org_align[2][9];

   hide_windows();

   idx=0;

   if(tdef==TCALINFO)
      rpt_index=0;

   if(sel_flag)
   {
      rpt_index=sel_report();

      if(rpt_index==(-1))
      {
         show_windows();
         return(-1);                         
      }
   }

   rsrc_gaddr(0,TEDITRPT,&tree);
   rsrc_gaddr(0,TSELRPT,&sel_tree);

   save_form(tree);

   tedptr=(char *)tree[EPTITLE1].ob_spec;
   if(sel_flag || tdef==TCALINFO)
      strcpy(*tedptr,"E D I T   R E P O R T");
   else
      strcpy(*tedptr," N E W   R E P O R T ");

   reset_rbuttons(tree,EPDET1,FALSE);

   if(rpt_index==0) /* calendar report */
      ob_hide(tree,EPDELETE);
   else
      ob_unhide(tree,EPDELETE);

   if(report[rpt_index].cstyle==COLUMN)
      hide_min_spacing(tree,FALSE);
   else
      show_min_spacing(tree,FALSE);

   tedptr=(char *)tree[EPNAME].ob_spec;
   if(sel_flag || tdef==TCALINFO)
      strcpy(*tedptr,report[rpt_index].cname);
   else if(tdef!=TCALINFO)
      strcpy(*tedptr,"Untitled Report");

   for(i=0; i<NUM_XFIELDS; i++)
   {
      strptr=(char *)tree[EPXF1BUT+i].ob_spec;
      if(strlen(data_entry.dxflabel[i])>0)
      {
         strcpy(strptr,data_entry.dxflabel[i]);
         del_state(tree,EPXF1BUT+i,DISABLED);
      }
      else
      {
         strcpy(strptr,"");
         set_state(tree,EPXF1BUT+i,DISABLED);
      }
   }

   if(data_entry.dstime!=TRUE && data_entry.detime!=TRUE)
      set_state(tree,EPTIME,DISABLED);
   else
      del_state(tree,EPTIME,DISABLED);

   if(data_entry.dsubj==TRUE)
      del_state(tree,EPSUBJ,DISABLED);
   else
      set_state(tree,EPSUBJ,DISABLED);

   tedptr=(char *)tree[EPMINSPA].ob_spec;
   itoa(report[rpt_index].cmin_spacing_per_day,*tedptr);

   if(report[rpt_index].cstyle==COLUMN)
      reset_rbuttons(tree,EPCOLUMN,FALSE);
   else if(report[rpt_index].cstyle==DAILY)
      reset_rbuttons(tree,EPDAILY,FALSE);

   check_column(tree,EPCLMCK1,FALSE);
   set_columns(tree,FALSE);
   upd_alignments(tree,FALSE);
   tot_columns(tree,FALSE);

   if(data_entry.dstime!=TRUE && data_entry.detime!=TRUE)
      objc_change(tree,EPTIME,0,0,0,0,0,DISABLED,0);

   for(i=0; i<9; i++)
   {
      for(j=0; j<2; j++)
      {
         org_info[j][i]=report[rpt_index].cinfo[j][i];
         org_length[j][i]=report[rpt_index].clength[j][i];
         org_spacing[j]=report[rpt_index].cspacing[j];
         org_align[j][i]=report[rpt_index].calign_fld[j][i];
      }
   }

   if(tdef==TCALINFO)
   {
      set_state(tree,EPNAME,DISABLED);
      set_state(tree,EPDET1,DISABLED);
      set_state(tree,EPDET2,DISABLED);
   }

   for(;;)
   {
      exit_obj=do_dialog(tree,TEDITRPT,0,1,1);
      if(exit_obj==EPDELETE)
      {
         if(form_alert(1,delalrt)==1)
         {
            report[rpt_index].cavailable=FALSE;
            report[rpt_index].cstyle=COLUMN;
            strcpy(report[rpt_index].cname,"\0");
            for(i=0; i<2; i++)
            {
               for(j=0; j<9; j++)
               {
                  report[rpt_index].cinfo[i][j]=CR_BLANK;
                  report[rpt_index].clength[i][j]=0;
               }
               report[rpt_index].cspacing[i]=2;
            }
            report[rpt_index].cmin_spacing_per_day=1;

            del_state(menu_tree,RPTCREAT,DISABLED);

            if(rpt_index!=1)
            {
               if(rpt_index>=11)
               {
                  reset_rbuttons(sel_tree,SPNAME2,FALSE);
                  del_state(sel_tree,SPNAME2,SELECTED);
               }
               reset_rbuttons(sel_tree,SPNAME1,FALSE);
            }

            break;
         }
      }
      else
      {
         if(too_many_columns==TRUE && exit_obj!=EPCANCEL)
            form_alert(1,rptalrt);
         else
            break;
      }
   }

   if(tdef==TCALINFO)
   {
      del_state(tree,EPNAME,DISABLED);
      del_state(tree,EPDET1,DISABLED);
      del_state(tree,EPDET2,DISABLED);
   }

   if(exit_obj!=EPCANCEL)
   {
      rpt_modified=TRUE;

      tedptr=(char *)tree[EPNAME].ob_spec;
      strcpy(report[rpt_index].cname,*tedptr);
      tedptr=(char *)tree[EPMINSPA].ob_spec;
      min_spacing=atoi(*tedptr);
      report[rpt_index].cmin_spacing_per_day=min_spacing;

      if(ob_selected(tree,EPCOLUMN))
         report[rpt_index].cstyle=COLUMN;
      else if(ob_selected(tree,EPDAILY))
         report[rpt_index].cstyle=DAILY;
   }
   else
   {
      for(i=0; i<9; i++)
      {
         for(j=0; j<2; j++)
         {
            report[rpt_index].cinfo[j][i]=org_info[j][i];
            report[rpt_index].clength[j][i]=org_length[j][i];
            report[rpt_index].cspacing[j]=org_spacing[j];
            report[rpt_index].calign_fld[j][i]=org_align[j][i];
         }
      }

      if(!sel_flag)
         report[rpt_index].cavailable=FALSE;

      cancel_form(tree);
   }

   if(exit_obj!=EPCANCEL)
   {
      count_all_lines();
      set_names();
   }

   show_windows();

   if(exit_obj==EPDELETE)
   {
      for(i=0; i<NUM_WINDS; i++)
      {
         if(window[i].wcontents-WC_REPORT==rpt_index)
         {
            wind_close(window[i].whandle);
            wind_delete(window[i].whandle);
            clr_window(window[i].whandle);
         }
      }
   }

   if(exit_obj!=EPCANCEL)
      set_all_wdw_headers();
}

do_create_report()
{
   int  i;

   for(i=1; i<NUM_REPORTS; i++)
   {
      if(report[i].cavailable==FALSE)
      {
         rpt_index=i;
         report[i].cavailable=TRUE;
         break;
      }
   }

   if(i<NUM_REPORTS)
      do_edit_report(TPRTREPT,FALSE);

   do_rpt_check();
}

do_rpt_check()
{
   int  i;

   for(i=0; i<NUM_REPORTS; i++)
      if(report[i].cavailable==FALSE)
         break;

   if(i>=NUM_REPORTS)
      set_state(menu_tree,RPTCREAT,DISABLED);
}

manip_number(tree,which,i)
OBJECT *tree;
int  which,i;
{
   char **tedptr,temp[80];
   int  val;

   if(i==(-10))
      tedptr=(char *)tree[EPSPACE].ob_spec;
   else if(i==(-11))
      tedptr=(char *)tree[EPMINSPA].ob_spec;
   else
      tedptr=(char *)tree[EPLEN1+i].ob_spec;

   val=atoi(*tedptr);

   if(which==MINUS)
      val--;

   if(which==PLUS)
      val++;

   if(i==(-11))
   {
      if(val<1)
         val=1;
   }
   else
   {
      if(val<0)
         val=0;
   }

   if(val>99) val=99;

   if((i==(-10) || i==(-11)) && val>9) val=9;

   itoa(val,temp);

   strcpy(*tedptr,temp);

   if(i==(-10))
      objc_draw(tree,EPSPACE,0,0,0,0,0);
   else if(i==(-11))
      objc_draw(tree,EPMINSPA,0,0,0,0,0);
   else
      objc_draw(tree,EPLEN1+i,0,0,0,0,0);
}

set_alignment(tree,which,i)
OBJECT *tree;
int  which,i;
{
   int  idx;

   if(ob_selected(tree,EPDET1))
      idx=0;
   else
      idx=1;

   report[rpt_index].calign_fld[idx][i]=which;
}

check_column(tree,obj,draw_flag)
register long tree;
int  obj,draw_flag;
{
   int  i;

   for(i=0; i<9; i++)
   {
      if(ob_checked(tree,EPCLMCK1+i))
      {
         ob_uncheck(tree,EPCLMCK1+i);
         if(draw_flag)
            objc_draw(tree,EPCLMCK1+i,8,0,0,0,0);
      }
   }
   objc_change(tree,obj,0,0,0,0,0,CHECKED,draw_flag);
}

chg_column(tree,which,draw_flag)
OBJECT *tree;
int  which,draw_flag;
{
   char **tedptr,*strptr,info[21],max_str[6];
   int  obj,i,j,max,info_type,num,idx,style,descr_flag;

   if(ob_selected(tree,EPDET1))
      idx=0;
   else
      idx=1;

   if(which==EPEMPTY)
   {
      strcpy(info,"BLANK");
      max=0;
      info_type=CR_BLANK;
   }
   if(which==EPDATE)
   {
      strcpy(info,"DATE");
      if(data_entry.dcentury==TRUE)
         max=10;
      else
         max=8;
      info_type=CR_DATE;
   }
   if(which==EPTIME)
   {
      strcpy(info,"TIME");
      if(data_entry.detime==TRUE)
         max=17;
      else
         max=8;
      info_type=CR_TIME;
   }
   if(which==EPSUBJ)
   {
      strcpy(info,"SUBJECT");
      max=data_entry.dlen_subj;
      info_type=CR_SUBJECT;
   }
   if(which==EPDESCR)
   {
      descr_flag=FALSE;

      for(i=0; i<2; i++)
         for(j=0; j<9; j++)
            if(report[rpt_index].cinfo[i][j]==CR_DESCRIPTION)
               descr_flag=TRUE;

      if(!descr_flag)
      {
         strcpy(info,"DESCRIPTION");
         max=0;
         for(i=0; i<4; i++)
            if(data_entry.dlen_descr[i]>max)
               max=data_entry.dlen_descr[i];
         info_type=CR_DESCRIPTION;
      }
      else
      {
         form_alert(1,onedescalrt);
         return;
      }
   }
   if(which==EPDAYSTO)
   {
      style=form_alert(3,toevntalrt);

      if(style==1)
      {
         max=4;
         info_type=CR_SHORT_TO_EVENT;
      }
      else if(style==2)
      {
         max=10;
         info_type=CR_MED_TO_EVENT;
      }
      else if(style==3)
      {
         max=26;
         info_type=CR_LONG_TO_EVENT;
      }

      strcpy(info,"TIME TO EVENT");
   }
   if(which==EPDAYWK)
   {
      strcpy(info,"DAY OF WEEK");
      max=9;
      info_type=CR_DAY_OF_WEEK;
   }
   for(i=0; i<5; i++)
   {
      if(which==EPXF1BUT+i)
      {
         strptr=(char *)tree[which].ob_spec;
         strcpy(info,strptr);
         max=data_entry.dxfchrs[i];
         info_type=CR_XFIELD1+i;
      }
   }

   strcat(info,replicate(' ',20-strlen(info)));

   for(i=0; i<9; i++)
   {
      if(ob_checked(tree,EPCLMCK1+i))
      {
         obj=EPCLMIN1+i;
         report[rpt_index].cinfo[idx][i]=info_type;
         num=i;
      }
   }

   tedptr=(char *)tree[obj].ob_spec;
   strcpy(*tedptr,info);
   if(draw_flag)
      objc_draw(tree,obj,8,0,0,0,0);

   itoa(max,max_str);
   tedptr=(char *)tree[EPLEN1+num].ob_spec;
   strcpy(*tedptr,max_str);
   if(draw_flag)
      objc_draw(tree,EPLEN1+num,8,0,0,0,0);

   ob_uncheck(tree,EPCLMCK1+num);
   if(draw_flag)
      objc_draw(tree,EPCLMCK1+num,8,0,0,0,0);

   obj=EPCLMCK1+num;

   if(obj<EPCLMCK1+8)
      obj++;
   else
      obj=EPCLMCK1;

   objc_change(tree,obj,0,0,0,0,0,CHECKED,draw_flag);
}

upd_alignments(tree,draw_flag)
OBJECT *tree;
int  draw_flag;
{
   int  i,idx;

   if(ob_selected(tree,EPDET1))
      idx=0;
   else
      idx=1;

   for(i=0; i<9; i++)
   {
      if(report[rpt_index].calign_fld[idx][i]==LEFT)
         reset_rbuttons(tree,algn_tab[0][i],draw_flag);
      else if(report[rpt_index].calign_fld[idx][i]==CENTER)
         reset_rbuttons(tree,algn_tab[1][i],draw_flag);
      else
         reset_rbuttons(tree,algn_tab[2][i],draw_flag);
   }
}

set_columns(tree,draw_flag)
OBJECT *tree;
int  draw_flag;
{
   char **tedptr,*strptr;
   int  i,idx;

   if(ob_selected(tree,EPDET1))
      idx=0;
   else
      idx=1;

   for(i=0; i<9; i++)
   {
      tedptr=(char *)tree[EPCLMIN1+i].ob_spec;
      if(report[rpt_index].cinfo[idx][i]==CR_MED_TO_EVENT ||
         report[rpt_index].cinfo[idx][i]==CR_LONG_TO_EVENT)
         strptr=(char *)tree[EPDAYSTO].ob_spec;
      else
         strptr=(char *)tree[EPEMPTY+report[rpt_index].cinfo[idx][i]].ob_spec;
      
      strcpy(*tedptr,strptr);
      strcat(*tedptr,replicate(' ',13-strlen(*tedptr)));
      tedptr=(char *)tree[EPLEN1+i].ob_spec;
      itoa(report[rpt_index].clength[idx][i],*tedptr);

      if(draw_flag)
      {
         objc_draw(tree,EPCLMIN1+i,0,0,0,0,0);
         objc_draw(tree,EPLEN1+i,0,0,0,0,0);
      }
   }

   tedptr=(char *)tree[EPSPACE].ob_spec;
   itoa(report[rpt_index].cspacing[idx],*tedptr);
   if(draw_flag)
      objc_draw(tree,EPSPACE,0,0,0,0,0);
}

tot_columns(tree,draw_flag)
register OBJECT *tree;
int  draw_flag;
{
   char **tedptr,totclm_str[5];
   int  length,spacing,tot_chr=0,tot_sp=0,tot_clm=0;
   register int  i,idx;

   if(ob_selected(tree,EPDET1))
      idx=0;
   else
      idx=1;

   for(i=0; i<9; i++)
   {
      tedptr=(char *)tree[EPLEN1+i].ob_spec;
      length=atoi(*tedptr);
      report[rpt_index].clength[idx][i]=length;
      tot_chr+=length;
   }

   tedptr=(char *)tree[EPSPACE].ob_spec;
   spacing=atoi(*tedptr);
   report[rpt_index].cspacing[idx]=spacing;

   for(i=0; i<9; i++)
      if(report[rpt_index].clength[idx][i]!=0)
         tot_sp+=spacing;

   tot_sp=max(tot_sp-spacing,0); /* last column needs no spacing */

   tot_clm=tot_chr+tot_sp;

   if(tot_clm>255)
      too_many_columns=TRUE;
   else
      too_many_columns=FALSE;

   itoa(tot_clm,totclm_str);

   tedptr=(char *)tree[EPTOTCHR].ob_spec;
   strcpy(*tedptr,totclm_str);
   strcat(*tedptr,replicate(' ',4-strlen(*tedptr)));
   if(draw_flag)
      objc_draw(tree,EPTOTCHR,8,0,0,0,0);

   report[rpt_index].ctot_clms[idx]=tot_clm;
}

hide_min_spacing(tree,draw_flag)
OBJECT *tree;
int  draw_flag;
{
   set_state(tree,EPMSLAB,DISABLED);
   set_state(tree,EPMSBORD,DISABLED);
   set_state(tree,EPMINSPA,DISABLED);
   set_state(tree,EPMIN11,DISABLED);
   set_state(tree,EPPLUS11,DISABLED);

   if(draw_flag)
   {
      objc_draw(tree,EPMSBORD,0,0,0,0,0);
      objc_draw(tree,EPMSLAB,0,0,0,0,0);
      objc_draw(tree,EPMINSPA,0,0,0,0,0);
      objc_draw(tree,EPMIN11,0,0,0,0,0);
      objc_draw(tree,EPPLUS11,0,0,0,0,0);
   }
}

show_min_spacing(tree,draw_flag)
OBJECT *tree;
int  draw_flag;
{
   del_state(tree,EPMSLAB,DISABLED);
   del_state(tree,EPMSBORD,DISABLED);
   del_state(tree,EPMINSPA,DISABLED);
   del_state(tree,EPMIN11,DISABLED);
   del_state(tree,EPPLUS11,DISABLED);

   if(draw_flag)
   {
      objc_draw(tree,EPMSBORD,0,0,0,0,0);
      objc_draw(tree,EPMSLAB,0,0,0,0,0);
      objc_draw(tree,EPMINSPA,0,0,0,0,0);
      objc_draw(tree,EPMIN11,0,0,0,0,0);
      objc_draw(tree,EPPLUS11,0,0,0,0,0);
   }
}

set_decision(tree,which,ed_obj,touch_obj) /* clicked on one of several */
OBJECT *tree;                             /* decision buttons          */
int  which,ed_obj,touch_obj;
{
   int  idx;
   char **tedptr,*strptr;

   if(ed_obj==PRSTIME)      idx=0;
   else if(ed_obj==PRETIME) idx=1;
   else if(ed_obj==PSUBJED) idx=2;
   else if(ed_obj==PXF1ED)  idx=3;
   else if(ed_obj==PXF2ED)  idx=4;
   else if(ed_obj==PXF3ED)  idx=5;
   else if(ed_obj==PXF4ED)  idx=6;
   else if(ed_obj==PXF5ED)  idx=7;
   else if(ed_obj==PRDESCR) idx=8;
   else
      return;

   rpt_decision[idx]=which;

   tedptr=(char *)tree[prdec_tab[idx]].ob_spec;
   strptr=(char *)tree[touch_obj].ob_spec;
   strcpy(*tedptr,strptr);
   objc_draw(tree,prdec_tab[idx],0,0,0,0,0);
}

click_decision(tree,obj) /* clicked on field's decision label */
OBJECT *tree;
int  obj;
{
   int  idx;
   char **tedptr,*strptr;

   dec_counter++;

   if(dec_counter>6)
      dec_counter=0;

        if(obj==PRSTDEC)  idx=0;
   else if(obj==PRETDEC)  idx=1;
   else if(obj==PRSUBDEC) idx=2;
   else if(obj==PRXF1DEC) idx=3;
   else if(obj==PRXF2DEC) idx=4;
   else if(obj==PRXF3DEC) idx=5;
   else if(obj==PRXF4DEC) idx=6;
   else if(obj==PRXF5DEC) idx=7;
   else if(obj==PRDESDEC) idx=8;
   else
      return;

   rpt_decision[idx]=IN+dec_counter;

   tedptr=(char *)tree[obj].ob_spec;
   strptr=(char *)tree[prdec2_tab[dec_counter]].ob_spec;
   strcpy(*tedptr,strptr);
   objc_draw(tree,obj,0,0,0,0,0);
}
