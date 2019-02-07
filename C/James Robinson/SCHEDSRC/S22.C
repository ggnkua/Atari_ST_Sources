/* S22.C -- PAGE SETUP, PRINTER CODES */

#include "obdefs.h"
#include "osbind.h"
#include "ctools.h"
#include "schedule.h"
#include "schdefs.h"

extern int rec_no,tot_lines,rpt_index,cod_modified,line_number,cicolumns,
           title_retained,rez;

extern char rpt_title[61],poffalrt[],code_file[129];

extern RPT report[NUM_REPORTS];

extern PAGE page_setup;

extern PCODES prt_codes;

do_page_setup(device)
int device;
{
   OBJECT *tree;
   int exit_obj,val,valid;
   char **tedptr;

   rsrc_gaddr(0,TPAGESET,&tree);

   save_form(tree);

   tedptr=(char *)tree[PSTITLE].ob_spec;
   strcpy(*tedptr,"\0");

   if(device==DEV_DISK || line_number==0 || page_setup.pnew_report)
   {
      ob_hide(tree,PSZERO);
      ob_hide(tree,PSZCBOX);
   }

   if(device==DEV_PRINTER && !page_setup.pnew_report)
   {
      ob_hide(tree,PSCBOX);
      ob_hide(tree,PSCOPIES);
   }

   if(device==DEV_DISK)
   {
      ob_hide(tree,PSMARBOX);
      ob_hide(tree,PSCBOX);
      ob_hide(tree,PSCOPIES);
      ob_hide(tree,PSSBOX);
      ob_hide(tree,PSSHBOX);
      ob_hide(tree,PSMBOX);
      ob_hide(tree,PSSIZBOX);
      ob_hide(tree,PSPGSIZE);
      ob_hide(tree,PSLEFTM);
      ob_hide(tree,PSRIGHTM);
      ob_hide(tree,PSTOPM);
      ob_hide(tree,PSBOTM);
      ob_hide(tree,PSEJECT);
      ob_hide(tree,PSPGNUM);

      tree[PSBUTBOX].ob_y-=(112*rez);
      tree[0].ob_height-=(112*rez);

      tree[PSPHEAD].ob_y-=(40*rez);
      tree[PSPTIME].ob_y-=(40*rez);
      tree[PSPDATE].ob_y-=(40*rez);
      tree[PSPFILE].ob_y-=(40*rez);
   }

   valid=FALSE;

   while(!valid)
   {
      exit_obj=do_dialog(tree,TPAGESET,0,0,0);

      valid=TRUE;

      if(exit_obj!=PSCANCEL)
      {
         tedptr=(char *)tree[PSCOPIES].ob_spec;
         val=atoi(*tedptr);
         if(val<1)
            valid=FALSE;
         else
            page_setup.pcopies=val;

         tedptr=(char *)tree[PSLEFTM].ob_spec;
         val=atoi(*tedptr);
         if(val<1)
            valid=FALSE;
         else
            page_setup.plmarg=val;

         tedptr=(char *)tree[PSRIGHTM].ob_spec;
         val=atoi(*tedptr);
         if(val<=page_setup.plmarg)
            valid=FALSE;
         else   
            page_setup.prmarg=val;

         tedptr=(char *)tree[PSTOPM].ob_spec;
         val=atoi(*tedptr);
         if(val<1)
            valid=FALSE;
         else
            page_setup.ptmarg=val;

         tedptr=(char *)tree[PSBOTM].ob_spec;
         val=atoi(*tedptr);
         if(val<page_setup.ptmarg+9)
            valid=FALSE;
         else
            page_setup.pbmarg=val;

         tedptr=(char *)tree[PSPGSIZE].ob_spec;
         val=atoi(*tedptr);
         if(val<page_setup.pbmarg || val<10)
            valid=FALSE;
         else
            page_setup.ppage_size=val;
      }
   }

   if(exit_obj!=PSCANCEL)
   {
      title_retained=FALSE;

      tedptr=(char *)tree[PSTITLE].ob_spec;
      if(strlen(*tedptr)>0 || page_setup.pnew_report)
         strcpy(rpt_title,*tedptr);
      else
      {
         if(page_setup.pnew_report==FALSE)
            title_retained=TRUE;
      }

      if(ob_selected(tree,PSPGNUM))
         page_setup.pnumber_page=TRUE;
      else
         page_setup.pnumber_page=FALSE;

      if(ob_selected(tree,PSPHEAD))
         page_setup.pheader=TRUE;
      else
         page_setup.pheader=FALSE;

      if(ob_selected(tree,PSEJECT))
         page_setup.peject_page=TRUE;
      else
         page_setup.peject_page=FALSE;

      if(ob_selected(tree,PSPDATE))
         page_setup.pdate_stamp=TRUE;
      else
         page_setup.pdate_stamp=FALSE;

      if(ob_selected(tree,PSPTIME))
         page_setup.ptime_stamp=TRUE;
      else
         page_setup.ptime_stamp=FALSE;

      if(ob_selected(tree,PSPFILE))
         page_setup.pfile_stamp=TRUE;
      else
         page_setup.pfile_stamp=FALSE;

      if(ob_selected(tree,PSEJECT))
         page_setup.peject_page=TRUE;
      else
         page_setup.peject_page=FALSE;

      if(ob_selected(tree,PSSINGLE))
         page_setup.ptype_sheet=SINGLE;
      else
         page_setup.ptype_sheet=CONTINUOUS;

      if(ob_selected(tree,PSSNLQ))
         page_setup.pstyle=NLQ;
      else if(ob_selected(tree,PSSPICA))
         page_setup.pstyle=PICA;
      else if(ob_selected(tree,PSSELITE))
         page_setup.pstyle=ELITE;
      else if(ob_selected(tree,PSSCOND))
         page_setup.pstyle=CONDENSED;

      if(ob_selected(tree,PSMDRAFT))
         page_setup.pmode=DRAFT;
      else if(ob_selected(tree,PSMBOLD))
         page_setup.pmode=BOLD;
      else if(ob_selected(tree,PSMDOUBL))
         page_setup.pmode=DOUBLE;
      else if(ob_selected(tree,PSMEXPAN))
         page_setup.pmode=EXPANDED;
      else if(ob_selected(tree,PSDOUBLD))
         page_setup.pmode=DOUBLE_BOLD;
   }

   if(device==DEV_DISK || line_number==0 || page_setup.pnew_report)
   {
      ob_unhide(tree,PSZERO);
      ob_unhide(tree,PSZCBOX);
   }

   if(device==DEV_PRINTER && !page_setup.pnew_report)
   {
      ob_unhide(tree,PSCBOX);
      ob_unhide(tree,PSCOPIES);

      page_setup.pcopies=1;
   }

   if(device==DEV_DISK)
   {
      ob_unhide(tree,PSMARBOX);
      ob_unhide(tree,PSCBOX);
      ob_unhide(tree,PSCOPIES);
      ob_unhide(tree,PSSBOX);
      ob_unhide(tree,PSSHBOX);
      ob_unhide(tree,PSMBOX);
      ob_unhide(tree,PSSIZBOX);
      ob_unhide(tree,PSPGSIZE);
      ob_unhide(tree,PSLEFTM);
      ob_unhide(tree,PSRIGHTM);
      ob_unhide(tree,PSTOPM);
      ob_unhide(tree,PSBOTM);
      ob_unhide(tree,PSEJECT);
      ob_unhide(tree,PSPGNUM);

      tree[PSBUTBOX].ob_y+=(112*rez);
      tree[0].ob_height+=(112*rez);

      tree[PSPHEAD].ob_y+=(40*rez);
      tree[PSPTIME].ob_y+=(40*rez);
      tree[PSPDATE].ob_y+=(40*rez);
      tree[PSPFILE].ob_y+=(40*rez);

      page_setup.plmarg=1;
      page_setup.prmarg=report[rpt_index].ctot_clms[0];
      if(report[rpt_index].ctot_clms[1]>page_setup.prmarg)
         page_setup.prmarg=report[rpt_index].ctot_clms[1];
      page_setup.ptmarg=1;
      page_setup.pbmarg=66;
      page_setup.ppage_size=66;
      page_setup.pcopies=1;
      page_setup.peject_page=FALSE;
      page_setup.pnumber_page=FALSE;
   }

   tedptr=(char *)tree[PSCOPIES].ob_spec;
   strcpy(*tedptr,"1");

   if(exit_obj==PSCANCEL)
   {
      cancel_form(tree);
      return(FALSE);
   }
   else
      return(TRUE);
}

do_range()
{
   OBJECT *tree;
   int exit_obj,last_pg;
   char **tedptr;

   if(tot_lines/page_setup.pbmarg==0)
   {
      page_setup.pfirst_page=1;
      page_setup.plast_page=1;

      return(TRUE);
   }

   rsrc_gaddr(0,TPAGERNG,&tree);

   tedptr=(char *)tree[PGRTOTPG].ob_spec;
   itoa((tot_lines/page_setup.pbmarg)+1,*tedptr);

   tedptr=(char *)tree[PGRFIRST].ob_spec;
   strcpy(*tedptr,"1");

   tedptr=(char *)tree[PGRLAST].ob_spec;
   last_pg=(tot_lines/page_setup.pbmarg)+1;
   if(last_pg<0)
      last_pg=32767;
   itoa(last_pg,*tedptr);

   exit_obj=do_dialog(tree,TPAGERNG,0,0,0);

   if(exit_obj!=PGRCNCL)
   {
      tedptr=(char *)tree[PGRFIRST].ob_spec;
      page_setup.pfirst_page=atoi(*tedptr);

      tedptr=(char *)tree[PGRLAST].ob_spec;
      page_setup.plast_page=atoi(*tedptr);

      if(page_setup.plast_page>last_pg)
         page_setup.plast_page=last_pg;

      return(TRUE);
   }
   else
      return(FALSE);
}

do_codes()
{
   OBJECT *tree;
   int exit_obj;

   hide_windows();

   rsrc_gaddr(0,TPRTCODE,&tree);

   save_form(tree);

   for(;;)
   {
      exit_obj=do_dialog(tree,TPRTCODE,0,0);
      if(exit_obj==PCLOAD)
      {
         load_codes(TRUE);
         put_codes();
      }
      else if(exit_obj==PCSAVE)
      {
         get_codes();
         save_codes(TRUE);
      }
      else
         break;
   }

   if(exit_obj==PCCANCEL)
   {
      cancel_form(tree);
      get_codes();
   }
   else
   {
      get_codes();
      cod_modified=TRUE;
   }

   enable_pbuttons();

   show_windows();
}

get_codes()
{
   OBJECT *tree;
   int i,found,val;
   char **tedptr;

   rsrc_gaddr(0,TPRTCODE,&tree);

   tedptr=(char *)tree[PCNOTES].ob_spec;
   strcpy(prt_codes.pnotes,*tedptr);

   found=FALSE;

   for(i=0; i<4; i++)
   {
      tedptr=(char *)tree[PCNLQON+i].ob_spec;
      val=atoi(*tedptr);
      prt_codes.ponnlq[i]=val;
      if(val>0)
         found=TRUE;
   }
   for(i=0; i<4; i++)
   {
      tedptr=(char *)tree[PCNLQOFF+i].ob_spec;
      val=atoi(*tedptr);
      prt_codes.poffnlq[i]=val;
      if(val>0)
         found=TRUE;
   }
   for(i=0; i<4; i++)
   {
      tedptr=(char *)tree[PCBOLDON+i].ob_spec;
      val=atoi(*tedptr);
      prt_codes.ponbold[i]=val;
      if(val>0)
         found=TRUE;
   }
   for(i=0; i<4; i++)
   {
      tedptr=(char *)tree[PCBOLDOF+i].ob_spec;
      val=atoi(*tedptr);
      prt_codes.poffbold[i]=val;
      if(val>0)
         found=TRUE;
   }
   for(i=0; i<4; i++)
   {
      tedptr=(char *)tree[PCDOUBON+i].ob_spec;
      val=atoi(*tedptr);
      prt_codes.pondouble[i]=val;
      if(val>0)
         found=TRUE;
   }
   for(i=0; i<4; i++)
   {
      tedptr=(char *)tree[PCDOUBOF+i].ob_spec;
      val=atoi(*tedptr);
      prt_codes.poffdouble[i]=val;
      if(val>0)
         found=TRUE;
   }
   for(i=0; i<4; i++)
   {
      tedptr=(char *)tree[PCEXPAON+i].ob_spec;
      val=atoi(*tedptr);
      prt_codes.ponexpanded[i]=val;
      if(val>0)
         found=TRUE;
   }
   for(i=0; i<4; i++)
   {
      tedptr=(char *)tree[PCEXPAOF+i].ob_spec;
      val=atoi(*tedptr);
      prt_codes.poffexpanded[i]=val;
      if(val>0)
         found=TRUE;
   }
   for(i=0; i<4; i++)
   {
      tedptr=(char *)tree[PCPICA+i].ob_spec;
      val=atoi(*tedptr);
      prt_codes.ppica[i]=val;
      if(val>0)
         found=TRUE;
   }
   for(i=0; i<4; i++)
   {
      tedptr=(char *)tree[PCELITE+i].ob_spec;
      val=atoi(*tedptr);
      prt_codes.pelite[i]=val;
      if(val>0)
         found=TRUE;
   }
   for(i=0; i<4; i++)
   {
      tedptr=(char *)tree[PCCONDEN+i].ob_spec;
      val=atoi(*tedptr);
      prt_codes.pcondensed[i]=val;
      if(val>0)
         found=TRUE;
   }

   if(!found)
      strcpy(code_file,"\0");
}

pc(tree,obj,code0,code1,code2,code3)
OBJECT *tree;
int obj,code0,code1,code2,code3;
{
   char **tedptr;
   int i,table[4];

   table[0]=code0; table[1]=code1; table[2]=code2; table[3]=code3;

   for(i=0; i<4; i++)
   {
      tedptr=(char *)tree[obj+i].ob_spec;
      if(table[i]>0)
         itoa(table[i],*tedptr);
      else
         strcpy(*tedptr,"\0");
   }
}

put_codes()
{
   OBJECT *tree;
   char **tedptr;

   rsrc_gaddr(0,TPRTCODE,&tree);

   tedptr=(char *)tree[PCNOTES].ob_spec;
   strcpy(*tedptr,prt_codes.pnotes);

   pc(tree,PCNLQON,prt_codes.ponnlq[0],prt_codes.ponnlq[1],
                   prt_codes.ponnlq[2],prt_codes.ponnlq[3]);
   pc(tree,PCNLQOFF,prt_codes.poffnlq[0],prt_codes.poffnlq[1],
                    prt_codes.poffnlq[2],prt_codes.poffnlq[3]);
   pc(tree,PCBOLDON,prt_codes.ponbold[0],prt_codes.ponbold[1],
                    prt_codes.ponbold[2],prt_codes.ponbold[3]);
   pc(tree,PCBOLDOF,prt_codes.poffbold[0],prt_codes.poffbold[1],
                    prt_codes.poffbold[2],prt_codes.poffbold[3]);
   pc(tree,PCDOUBON,prt_codes.pondouble[0],prt_codes.pondouble[1],
                    prt_codes.pondouble[2],prt_codes.pondouble[3]);
   pc(tree,PCDOUBOF,prt_codes.poffdouble[0],prt_codes.poffdouble[1],
                    prt_codes.poffdouble[2],prt_codes.poffdouble[3]);
   pc(tree,PCEXPAON,prt_codes.ponexpanded[0],prt_codes.ponexpanded[1],
                    prt_codes.ponexpanded[2],prt_codes.ponexpanded[3]);
   pc(tree,PCEXPAOF,prt_codes.poffexpanded[0],prt_codes.poffexpanded[1],
                    prt_codes.poffexpanded[2],prt_codes.poffexpanded[3]);
   pc(tree,PCPICA,prt_codes.ppica[0],prt_codes.ppica[1],
                  prt_codes.ppica[2],prt_codes.ppica[3]);
   pc(tree,PCELITE,prt_codes.pelite[0],prt_codes.pelite[1],
                   prt_codes.pelite[2],prt_codes.pelite[3]);
   pc(tree,PCCONDEN,prt_codes.pcondensed[0],prt_codes.pcondensed[1],
                    prt_codes.pcondensed[2],prt_codes.pcondensed[3]);
}

enable_pbuttons()
{
   OBJECT *tree;

   rsrc_gaddr(0,TPAGESET,&tree);

   en_code(tree,prt_codes.ponnlq[0],PSSNLQ,PSSPICA);
   en_code(tree,prt_codes.pelite[0],PSSELITE,PSSPICA);
   en_code(tree,prt_codes.pcondensed[0],PSSCOND,PSSPICA);
   en_code(tree,prt_codes.ponbold[0],PSMBOLD,PSMDRAFT);
   en_code(tree,prt_codes.pondouble[0],PSMDOUBL,PSMDRAFT);
   en_code(tree,prt_codes.ponexpanded[0],PSMEXPAN,PSMDRAFT);
   en_code(tree,prt_codes.pondouble[0],PSDOUBLD,PSMDRAFT);
}

en_code(tree,code,select,reset)
OBJECT *tree;
int code,select,reset;
{
   if(code==0)
   {
      if(ob_selected(tree,select))
         reset_rbuttons(tree,reset,FALSE);
      set_state(tree,select,DISABLED);
   }
   else
      del_state(tree,select,DISABLED);
}

send_code()
{
   OBJECT *tree;
   int exit_obj,i;
   char **tedptr;

   rsrc_gaddr(0,TSENDCOD,&tree);

   clear_form(tree);

   exit_obj=do_dialog(tree,TSENDCOD,0,0,0);

   if(exit_obj!=SCCANCEL)
   {
      while(!prt_ready())
         if(form_alert(1,poffalrt)==2)
            return;

      for(i=0; i<7; i++)
      {
         tedptr=(char *)tree[SCCODE1+i].ob_spec;
         prt_char(DEV_PRINTER,atoi(*tedptr));
      }
   }
}

on_codes()
{
   int i;

   if(page_setup.pstyle==NLQ)
      for(i=0; i<4; i++)
         Bconout(DEV_PRINTER,prt_codes.ponnlq[i]);
   else if(page_setup.pstyle==PICA)
      for(i=0; i<4; i++)
         Bconout(DEV_PRINTER,prt_codes.ppica[i]);
   else if(page_setup.pstyle==ELITE)
      for(i=0; i<4; i++)
         Bconout(DEV_PRINTER,prt_codes.pelite[i]);
   else if(page_setup.pstyle==CONDENSED)
      for(i=0; i<4; i++)
         Bconout(DEV_PRINTER,prt_codes.pcondensed[i]);

   if(page_setup.pmode==BOLD || page_setup.pmode==DOUBLE_BOLD)
      for(i=0; i<4; i++)
         Bconout(DEV_PRINTER,prt_codes.ponbold[i]);
   if(page_setup.pmode==DOUBLE || page_setup.pmode==DOUBLE_BOLD)
      for(i=0; i<4; i++)
         Bconout(DEV_PRINTER,prt_codes.pondouble[i]);
   else if(page_setup.pmode==EXPANDED)
      for(i=0; i<4; i++)
         Bconout(DEV_PRINTER,prt_codes.ponexpanded[i]);
}

off_codes()
{
   int i;

   if(page_setup.pstyle==NLQ)
      for(i=0; i<4; i++)
         Bconout(DEV_PRINTER,prt_codes.poffnlq[i]);

   if(page_setup.pmode==BOLD || page_setup.pmode==DOUBLE_BOLD)
      for(i=0; i<4; i++)
         Bconout(DEV_PRINTER,prt_codes.poffbold[i]);
   if(page_setup.pmode==DOUBLE || page_setup.pmode==DOUBLE_BOLD)
      for(i=0; i<4; i++)
         Bconout(DEV_PRINTER,prt_codes.poffdouble[i]);
   else if(page_setup.pmode==EXPANDED)
      for(i=0; i<4; i++)
         Bconout(DEV_PRINTER,prt_codes.poffexpanded[i]);
}

