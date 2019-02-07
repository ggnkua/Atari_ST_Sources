/* S14.C -- CALENDAR DIALOG */

#include "stdio.h"
#include "obdefs.h"
#include "osbind.h"
#include "gemdefs.h"
#include "schdefs.h"
#include "ctools.h"
#include "schedule.h"

extern int  line_number,device,rpt_index,rec_no,sel_tab[CAL_LINES],cishown,
            dummy,page_number,tot_lines,cixind,ciyind,cicolumns,cilines,
            cicounter,cidraw,rec_modified,old_line_number,max_recs,
            pages_this_rpt,day_spacing,cal_idx,cur_modified,rpt_free,
            inc_page,line_this_rpt;

extern char hdate[9],ddayalrt[],poffalrt[],addonalrt[],pausalrt[];

extern long menu_tree;

extern OBJECT *citree;

static int  cur_rec=0;

extern FILE *asc_file;

extern WIND window[NUM_WINDS];

extern RECORD *rec;

extern PAGE page_setup;

extern LAST_USED last;

extern RPT report[NUM_REPORTS];

do_info(windex,day_str)
int  windex;
char day_str[3];
{
   int  exit_obj,choice,cnt_flag,ret;

   hide_windows();

   cnt_flag=FALSE;

   strcpy(hdate,window[windex].wsdate); /* contains year and month */
   strcat(hdate,day_str);               /* contains selected day   */

   upd_info(hdate,TRUE);

   ci_reset(citree);

   while(exit_obj!=CIDONE)
   {
      ci_events(citree);

      ci_clear(citree,FALSE);

      exit_obj=do_dialog(citree,TCALINFO,0,1,0);

      cur_rec=sel_tab[0];
      if(cur_rec<0)
      {
         if(rec_no>0 && strcmp(rec[rec_no-1].rdate,hdate)<=0)
            cur_rec=rec_no-1;
         else
            cur_rec=0;
      }

      if(rec_no>0)
      {
         if(exit_obj==CIDELETE)
         {
            info_delete(citree);
            upd_info(hdate,TRUE);
            cnt_flag=TRUE;
         }
         if(exit_obj==CIEDIT)
         {
            info_edit(citree);
            upd_info(hdate,TRUE);
         }
         if(exit_obj==CIPRINT)
            info_print(citree,hdate);
         if(exit_obj==CIPRINTD)
            info_day_print(hdate);
         if(exit_obj==CISEEKAH)
         {
            seek_ahead(hdate); 
            ci_reset(citree);
            upd_info(hdate,TRUE);
         }
         if(exit_obj==CISEEKBK)
         {
            seek_back(hdate);
            ci_reset(citree);
            upd_info(hdate,TRUE);
         }
         if(exit_obj==CIDELDAY)
         {
            choice=form_alert(1,ddayalrt);
            if(choice==1)
            {
               day_delete(hdate);
               ci_reset(citree);
               upd_info(hdate,TRUE);
               cnt_flag=TRUE;
            }
         }
         if(exit_obj==CIEDDAY)
         {
            day_edit(hdate);
            ci_reset(citree);
            upd_info(hdate,TRUE);
            cnt_flag=TRUE;
         }
      }
      if(exit_obj==CIBACKD)
      {
         strcpy(hdate,fd_backward(hdate,1));
         ci_reset(citree);
         upd_info(hdate,TRUE);
      }
      if(exit_obj==CIAHEADD)
      {
         strcpy(hdate,fd_forward(hdate,1));
         ci_reset(citree);
         upd_info(hdate,TRUE);
      }
      if(exit_obj==CIGODATE)
      {
         go_date(hdate);
         ci_reset(citree);
         upd_info(hdate,TRUE);
      }
      if(exit_obj==CINEWREC)
      {
         for(;;)
         {
            ret=edit_record(rec_no,hdate);

            if(ret==ERCANCEL || rec_no>=max_recs || !enter_more())
               break;
         }
         sort_cal(rec,rec_no);
         cnt_flag=TRUE;
         upd_info(hdate,TRUE);
      }
      if(exit_obj==CIDONE)
         ci_clear(citree,FALSE);
   }

   show_windows();

   if(cnt_flag)
      count_all_lines();
}

ci_events(tree)
OBJECT *tree;
{
   char **tedptr,temp[40];

   itoa(cilines,temp);

   if(cilines!=1)
      strcat(temp," events");
   else
      strcat(temp," event");

   tedptr=(char *)tree[CIEVENTS].ob_spec;
   strcpy(*tedptr,temp);
}

info_delete(tree)
OBJECT *tree;
{
   int  i,tot_del;

   tot_del=0;

   cur_modified=FALSE;

   for(i=0; i<CAL_LINES; i++)
   {
      if(ob_selected(tree,CIDESCR1+i))
      {
         if(sel_tab[i]>(-1))
         {
            rec_modified=TRUE;
            cur_modified=TRUE; 

            rec[sel_tab[i]].rdeleted=TRUE;
            clr_record(sel_tab[i]);
            strcpy(rec[sel_tab[i]].rdate,"99999999");
            tot_del++;
         }
      }
   }

   if(cur_modified)
   {
      sort_cal(rec,rec_no);
      rec_no-=tot_del;
      del_state(menu_tree,RECNEW,DISABLED);
      del_state(citree,CINEWREC,DISABLED);
   }
}

day_delete(hdate)
char hdate[9];
{
   int  i,tot_del;

   tot_del=0;

   cur_modified=FALSE;

   for(i=0; i<rec_no; i++)
   {
      if(strcmp(hdate,rec[i].rdate)==0 && rec_match(&rec[i]) &&
         rec[i].rdeleted!=TRUE)
      {
         rec_modified=TRUE;
         cur_modified=TRUE;

         rec[i].rdeleted=TRUE;
         clr_record(i);
         strcpy(rec[i].rdate,"99999999");
         tot_del++;
      }
   }

   if(cur_modified)
   {
      sort_cal(rec,rec_no);
      rec_no-=tot_del;
      del_state(menu_tree,RECNEW,DISABLED);
      del_state(citree,CINEWREC,DISABLED);
   }
}

day_edit(hdate)
char hdate[9];
{
   int  i,tot_deleted,ret;

   tot_deleted=0;

   cur_modified=FALSE;

   for(i=0; i<rec_no; i++)
   {
      if(strcmp(hdate,rec[i].rdate)==0 && rec_match(&rec[i]) &&
         rec[i].rdeleted!=TRUE)
      {
         ret=edit_record(i,"\0");

         if(ret==EREXIT)
            break;
         else if(ret==ERDELETE)
            tot_deleted++;
      }
   }

   if(cur_modified)
   {
      sort_cal(rec,rec_no);
      rec_no-=tot_deleted;
      del_state(menu_tree,RECNEW,DISABLED);
      del_state(menu_tree,CINEWREC,DISABLED);
   }
}

info_edit(tree)
OBJECT *tree;
{
   int  i,tot_deleted,ret;

   tot_deleted=0;

   cur_modified=FALSE;

   for(i=0; i<CAL_LINES; i++)
   {
      if(ob_selected(tree,CIDESCR1+i))
      {
         if(sel_tab[i]>(-1))
         {
            ret=edit_record(sel_tab[i],"\0");

             if(ret==EREXIT)
                break;
             else if(ret==ERDELETE)
                tot_deleted++;
         }
      }
   }

   if(cur_modified)
   {
      sort_cal(rec,rec_no);
      rec_no-=tot_deleted;
      del_state(menu_tree,RECNEW,DISABLED);
      del_state(menu_tree,CINEWREC,DISABLED);
   }
}

info_print(tree,hdate)
OBJECT *tree;
char hdate[9];
{
   static char temp[81];
   int  i,j,sel_det;

   rpt_index=0;

   sel_det=FALSE;

   for(i=0; i<CAL_LINES; i++)
      if(ob_selected(tree,CIDESCR1+i))
         if(sel_tab[i]>(-1))
            sel_det=TRUE;

   if(!sel_det && report[rpt_index].cstyle==COLUMN)
      return;

   device=sel_device(TRUE);

   if(device==(-1))
      return;

   tot_lines=0; page_setup.pnew_report=TRUE;

   if(device==DEV_PRINTER)
   {
      if(form_alert(2,addonalrt)==1)
         page_setup.pnew_report=TRUE;
      else
      {
         page_setup.pnew_report=FALSE;
         page_setup.pfirst_page=1; page_setup.plast_page=32767;
      }
   }

   if(!do_page_setup(device))
      return;

   if(device==DEV_DISK && !do_disk())
      return;

   if(device==DEV_PRINTER)
   {
      while(!prt_ready())
         if(form_alert(1,poffalrt)==2)
            return;
   }

   if(device==DEV_PRINTER)
      on_codes();

   for(j=0; j<page_setup.pcopies; j++)
   {
      if(device==DEV_PRINTER && page_setup.pnew_report)
      {
         if(line_number>0)
         {
            prt_char(DEV_PRINTER,12);
            if(page_setup.ptype_sheet==SINGLE)
               form_alert(1,pausalrt);
         }
         page_number=1;
         line_number=0;
      }      

      graf_mouse(HOURGLASS,&dummy);

      if(page_setup.pcopies>j+1)
         inc_page=FALSE;
      else
         inc_page=TRUE;

      pages_this_rpt=0; line_this_rpt=0;

      day_spacing=0;

      prt_title(device);

      if(report[rpt_index].cstyle==DAILY)
      {
         strcpy(temp,"\0");
         cat_date(temp,hdate);
         dprint(device,temp);
         newline(device,1);
      }

      if(device==DEV_PRINTER)
         while(!prt_ready());

      for(i=0; i<CAL_LINES; i++)
         if(ob_selected(tree,CIDESCR1+i))
            if(sel_tab[i]>(-1))
               prt_detail(device,-1,sel_tab[i]);

      if(device==DEV_PRINTER)
      {
         if(page_setup.peject_page)
         {
            if(line_number>0)
            {
               prt_char(DEV_PRINTER,12);
               line_number=0;
               if(inc_page)
                  page_number++;
            }
         }
      }

      graf_mouse(ARROW,&dummy);

      if(device==DEV_PRINTER &&
         page_setup.ptype_sheet==SINGLE &&
         page_setup.pcopies>j+1)
      {
         if(line_number>0)
            prt_char(DEV_PRINTER,12);
         page_number=1;
         line_number=0;
         form_alert(1,pausalrt);
      }
   }

   if(report[rpt_index].cstyle==DAILY && (line_number>0 || device==DEV_DISK))
   {
      if(report[rpt_index].cmin_spacing_per_day-day_spacing>0)
         newline(device,report[rpt_index].cmin_spacing_per_day-day_spacing);
      else
         newline(device,1);
   }

   if(device==DEV_PRINTER)
      off_codes();

   if(device==DEV_DISK)
      fclose(asc_file);
}

seek_ahead(hdate)
char *hdate;
{
   register int  i;

   for(i=cur_rec; i<rec_no; i++)
   {
      if(rec[i].rdeleted!=TRUE && rec_match(&rec[i]))
      {
         if(strcmp(rec[i].rdate,hdate)>0)
         {
            strcpy(hdate,rec[i].rdate);
            break;
         }
      }
   }
}

seek_back(hdate)
char *hdate;
{
   register int  i,start;

   if(!cal_criteria(hdate,rec,rec_no) && rec_no>0)
      start=rec_no-1;
   else
      start=cur_rec;

   for(i=start; i>=0; i--)
   {
      if(rec[i].rdeleted!=TRUE && rec_match(&rec[i]))
      {
         if(strcmp(rec[i].rdate,hdate)<0)
         {
            strcpy(hdate,rec[i].rdate);
            break;
         }
      }
   }
}

info_day_print(hdate)
char hdate[9];
{
   static char detail[80];
   int  i,old_line_number;

   rpt_index=0; rpt_free=FALSE;

   if(!cal_criteria(hdate,rec,rec_no) &&
      report[rpt_index].cstyle==COLUMN)
      return;

   device=sel_device(TRUE);

   if(device==(-1))
      return;

   page_setup.pnew_report=TRUE;

   if(device==DEV_PRINTER)
   {
      if(form_alert(2,addonalrt)==1)
         page_setup.pnew_report=TRUE;
      else
      {
         page_setup.pnew_report=FALSE;
         page_setup.pfirst_page=1; page_setup.plast_page=32767;
      }
   }

   if(!do_page_setup(device))
      return;

   old_line_number=line_number;

   graf_mouse(HOURGLASS,&dummy);
   print_schedule(DEV_COUNT_LINES,-1,hdate,hdate,window[cal_idx].wstime,
                  window[cal_idx].wetime,window[cal_idx].wsubj,
                  window[cal_idx].wxfield[0],window[cal_idx].wxfield[1],
                  window[cal_idx].wxfield[2],window[cal_idx].wxfield[3],
                  window[cal_idx].wxfield[4],window[cal_idx].wdescr);
   graf_mouse(ARROW,&dummy);

   line_number=old_line_number;

   if(device==DEV_PRINTER && !do_range())
      return;

   if(device==DEV_DISK && !do_disk())
      return;

   if(device==DEV_PRINTER)
   {
      while(!prt_ready())
         if(form_alert(1,poffalrt)==2)
            return;
   }

   if(tot_lines>0)
   {
      for(i=0; i<page_setup.pcopies; i++)
      {
         if(device==DEV_PRINTER && page_setup.pnew_report)
         {
            if(line_number>0)
            {
               prt_char(DEV_PRINTER,12);
               if(page_setup.ptype_sheet==SINGLE)
                  form_alert(1,pausalrt);
            }
            page_number=1;
            line_number=0;
         }

         pages_this_rpt=0; line_this_rpt=0;

         if(page_setup.pcopies>i+1)
            inc_page=FALSE;
         else
            inc_page=TRUE;

         if(device==DEV_PRINTER)
            while(!prt_ready());

         print_schedule(device,-1,hdate,hdate,window[cal_idx].wstime,
                        window[cal_idx].wetime,window[cal_idx].wsubj,
                        window[cal_idx].wxfield[0],window[cal_idx].wxfield[1],
                        window[cal_idx].wxfield[2],window[cal_idx].wxfield[3],
                        window[cal_idx].wxfield[4],window[cal_idx].wdescr);

         if(device==DEV_PRINTER &&
            page_setup.ptype_sheet==SINGLE &&
            page_setup.pcopies>i+1)
         {
            if(line_number>0)
               prt_char(DEV_PRINTER,12);
            page_number=1;
            line_number=0;
            form_alert(1,pausalrt);
         }
      }
   }
   else
   {
      if(report[rpt_index].cstyle==DAILY)
      {
         if(device==DEV_PRINTER)
            on_codes();

         prt_title(device);

         strcpy(detail,"\0");
         cat_date(detail,hdate);
         dprint(device,detail);
         newline(device,1);

         if(device==DEV_PRINTER)
            off_codes();

         day_spacing=0;
      }
   }

   if(report[rpt_index].cstyle==DAILY && (line_number>0 || device==DEV_DISK))
      newline(device,report[rpt_index].cmin_spacing_per_day-day_spacing);

   if(device==DEV_DISK)
      fclose(asc_file);
}

upd_info(hdate,count_flag)
char *hdate;
int  count_flag;
{
   int  i;
   char **tedptr;

   tedptr=(char *)citree[CITITLE].ob_spec;
   strcpy(*tedptr," ");
   cat_date(*tedptr,hdate);
   strcat(*tedptr," ");

   for(i=0; i<CAL_LINES; i++)
   {
      tedptr=(char *)citree[CIDESCR1+i].ob_spec;
      strcpy(*tedptr,"\0");
   }

   if(count_flag)
   {
      old_line_number=line_number;

      rpt_index=0; cilines=0; cicolumns=0; line_number=0;

      print_schedule(DEV_COUNT_LINES,-2,hdate,hdate,window[cal_idx].wstime,
                     window[cal_idx].wetime,window[cal_idx].wsubj,
                     window[cal_idx].wxfield[0],window[cal_idx].wxfield[1],
                     window[cal_idx].wxfield[2],window[cal_idx].wxfield[3],
                     window[cal_idx].wxfield[4],window[cal_idx].wdescr);

      line_number=old_line_number;
   }
}

ci_clear(tree,draw_flag)
OBJECT *tree;
int  draw_flag;
{
   int  i;

   for(i=0; i<CAL_LINES; i++)
      if(ob_selected(tree,CIDESCR1+i))
         objc_change(tree,CIDESCR1+i,0,0,0,0,0,NORMAL,draw_flag);
}

go_date(hdate)
char *hdate;
{
   OBJECT *tree;
   char **tedptr;
   int  exit_obj,not_valid;

   rsrc_gaddr(0,TGODATE,&tree);
   clear_form(tree);

   clr_msgs(tree,TGODATE);

   not_valid=TRUE;

   while(not_valid && exit_obj!=GDCANCEL)
   {
      exit_obj=do_dialog(tree,TGODATE,0,1,1);

      if(exit_obj!=GDCANCEL)
      {
         tedptr=(char *)tree[GDDATE].ob_spec;
         if(validate_date(*tedptr,TGODATE))
         {
            get_date(*tedptr,hdate,last.lsdate);
            not_valid=FALSE;
         }
         else
            date_error_alert(*tedptr);
      }
   }
}

