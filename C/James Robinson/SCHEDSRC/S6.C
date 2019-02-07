/* S6.C -- RECORD FUNCTIONS */

#include "obdefs.h"
#include "stdio.h"
#include "gemdefs.h"
#include "osbind.h"
#include "schdefs.h"
#include "ctools.h"
#include "schedule.h"

extern int  rpt_index,rec_modified,dummy,descr_idx[4],rec_no,max_recs,
            xfed_tab[2][5],rpt_decision[9],disk_full,device,sel_windex,
            trans_fhandle,move_flag,cur_file,total,line_number,skip_flag,
            page_number,tot_lines,pages_this_rpt,cur_modified,rpt_free,
            day_spacing,inc_page,new_transfer_file,line_this_rpt;

extern char timealrt[],notalrt[],tranalrt[],movealrt[],curalrt[],rec_file[129],
            memalrt[],drecalrt[],dfullalrt[],old_date[9],poffalrt[],
            addonalrt[],pausalrt[];

extern LAST_USED last;

extern SELECTION select[NUM_SELECTIONS];

extern CUSTOM data_entry;

extern WIND window[NUM_WINDS];

extern RECORD *rec;

extern long menu_tree;

extern OBJECT *citree;

extern CUSTOM trans_data;

extern PAGE page_setup;

extern RPT report[NUM_REPORTS];

extern FILE *asc_file;

enter_records()
{
   OBJECT *tree;
   char **tedptr;
   int  exit_obj,ret,err_obj;

   wind_update(1);

   hide_windows();

   rsrc_gaddr(0,TEDITREC,&tree);

   cur_modified=FALSE;

   for(;;)
   {
      tedptr=(char *)tree[ERTITLE1].ob_spec;
      strcpy(*tedptr,"    N E W   R E C O R D    ");

      ob_hide(tree,EREXIT);
      ob_hide(tree,ERDELETE);

      clear_form(tree);
      clr_msgs(tree,TEDITREC);

      err_obj=0;

      for(;;)
      {
         exit_obj=do_dialog(tree,TEDITREC,err_obj,0,1);

         if(exit_obj!=ERCANCEL)
         {
            ret=save_event(tree,FALSE);
  
            if(ret>=0)
               break;
            else if(ret==(-1))
               err_obj=ERDATE;
            else if(ret==(-2))
               err_obj=ERSTIME;
            else if(ret==(-3))
               err_obj=ERETIME;
            else if(ret==(-4))
               break;
         }
         else
            break;
      }
      if(exit_obj==ERCANCEL || rec_no>=max_recs || !enter_more())
         break;
   }

   if(cur_modified)
   {
      sort_cal(rec,rec_no);
      count_all_lines();
      set_names();
   }

   ob_unhide(tree,EREXIT);
   ob_unhide(tree,ERDELETE);

   show_windows();

   wind_update(0);
}

int 
save_event(tree,tick_flag)
OBJECT *tree;
int  tick_flag;
{
   static char **tedptr,res_date[9];
   int  i,direction,days;

   if(rec_no>=max_recs)
   {
      form_alert(1,memalrt);
      set_state(menu_tree,RECNEW,DISABLED);
      set_state(citree,CINEWREC,DISABLED);
      return(-4);
   }

   clr_record(rec_no);

   tedptr=(char *)tree[ERDATE].ob_spec;
   if(validate_date(*tedptr,TEDITREC))
      get_date(*tedptr,rec[rec_no].rdate,last.lsdate);
   else
   {
      date_error_alert(*tedptr);
      return(-1);
   }

   if(data_entry.dtickler==TRUE || tick_flag==TRUE)
   {
      tedptr=(char *)tree[ERTICKLE].ob_spec;
      if(strlen(*tedptr)>0)
         strcpy(last.ldays,*tedptr);
      days=atoi(*tedptr);
      if(days>0)
      {
         if(ob_selected(tree,ERTICKAH))
            direction=FORWARD;
         else
            direction=BACKWARD;

         if(direction==FORWARD)
            strcpy(res_date,fd_forward(rec[rec_no].rdate,days));
         else
            strcpy(res_date,fd_backward(rec[rec_no].rdate,days));

         tick_result(res_date);

         strcpy(rec[rec_no].rdate,res_date);
      }
   }

   if(data_entry.dstime==TRUE && tick_flag!=TRUE)
   {
      tedptr=(char *)tree[ERSTIME].ob_spec;
      if(time_valid(*tedptr))
         get_time(*tedptr,rec[rec_no].rstime,last.lstime);
      else
      {
         form_alert(1,timealrt);
         return(-2);
      }
   }

   if(data_entry.detime==TRUE && tick_flag!=TRUE)
   {
      tedptr=(char *)tree[ERETIME].ob_spec;
      if(time_valid(*tedptr))
         get_time(*tedptr,rec[rec_no].retime,last.letime);
      else
      {
         form_alert(1,timealrt);
         return(-3);
      }
   }

   if(data_entry.dsubj==TRUE)
   {
      tedptr=(char *)tree[TSUBJED].ob_spec;
      if(strlen(*tedptr)>0 && !tick_flag)
         strcpy(last.lsubj,*tedptr);
      strcpy(rec[rec_no].rsubj,*tedptr);
   }

   for(i=0; i<data_entry.dxfields; i++)
   {
      tedptr=(char *)tree[xfed_tab[0][i]].ob_spec;
      if(strlen(*tedptr)>0)
         strcpy(last.lxfield[i],*tedptr);
      strcpy(rec[rec_no].rxfield[i],*tedptr);
   }

   for(i=0; i<data_entry.ddescr_lines; i++)
   {
      tedptr=(char *)tree[descr_idx[i]].ob_spec;
      if(strlen(*tedptr)>0 && !tick_flag)
         strcpy(last.ldescr[i],*tedptr);

      strcpy(rec[rec_no].rdescr[i],*tedptr);
   }

   rec[rec_no].rdeleted=FALSE;

   if(tick_flag!=TRUE)
   {
      auto_perform();
      rec_no++;
   }

   if(rec_no>=max_recs)
   {
      form_alert(1,memalrt);
      set_state(menu_tree,RECNEW,DISABLED);
      set_state(citree,CINEWREC,DISABLED);
      return(-4);
   }

   rec_modified=TRUE;
   cur_modified=TRUE;

   return(TRUE);
}

int 
edit_record(record,date)
int  record;
char date[9]; /* used by NEW RECORD button in do_info() */
{
   OBJECT *tree;
   char **tedptr,res_date[9],old_date[9],old_stime[6],old_etime[6],
        old_subj[41],old_xfield[NUM_XFIELDS][41],old_descr[4][41];
   int  exit_obj,i,valid,days,direction,err_obj,changed;

   rsrc_gaddr(0,TEDITREC,&tree);

   tedptr=(char *)tree[ERTITLE1].ob_spec;
   if(strlen(date)==0)
      strcpy(*tedptr,"E D I T I N G   R E C O R D");
   else
      strcpy(*tedptr,"     N E W   R E C O R D   ");

   if(strlen(date)!=0)
   {
      ob_hide(tree,EREXIT);
      ob_hide(tree,ERDELETE);
   }

   tedptr=(char *)tree[ERDATE].ob_spec;
   if(strlen(date)==0)
   {
      if(data_entry.dcentury==TRUE)
      {
         strcpy(*tedptr,right(rec[record].rdate,4));
         strcat(*tedptr,left(rec[record].rdate,4));
      }
      else
      {
         if(data_entry.dyear==TRUE)
         {
            strcpy(*tedptr,right(rec[record].rdate,4));
            strcat(*tedptr,mid(rec[record].rdate,3,2));
         }
         else
            strcpy(*tedptr,right(rec[record].rdate,4));
      }
   }
   else
   {
      if(data_entry.dcentury==TRUE)
      {
         strcpy(*tedptr,right(date,4));
         strcat(*tedptr,left(date,4));
      }
      else
      {
         if(data_entry.dyear==TRUE)
         {
            strcpy(*tedptr,right(date,4));
            strcat(*tedptr,mid(date,3,2));
         }
         else
            strcpy(*tedptr,right(date,4));
      }
   }

   if(data_entry.dtickler==TRUE)
   {
      tedptr=(char *)tree[ERTICKLE].ob_spec;
      strcpy(*tedptr,"\0");
   }

   if(data_entry.dstime==TRUE)
   {
      tedptr=(char *)tree[ERSTIME].ob_spec;
      if(strlen(date)==0)
      {
         if(strcmp(mid(rec[record].rstime,2,2),"00")==0)
         {
            strcpy(*tedptr,"12");
            strcat(*tedptr,right(rec[record].rstime,2));
            strcat(*tedptr,left(rec[record].rstime,1));
         }
         else
         {
            if(strlen(rec[record].rstime)>0)
            {
               strcpy(*tedptr,right(rec[record].rstime,4));
               strcat(*tedptr,left(rec[record].rstime,1));
            }
            else
               strcpy(*tedptr,"\0");
         }
      }
      else
         strcpy(*tedptr,"\0");
   }

   if(data_entry.detime==TRUE)
   {
      tedptr=(char *)tree[ERETIME].ob_spec;
      if(strlen(date)==0)
      {
         if(strcmp(mid(rec[record].retime,2,2),"00")==0)
         {
            strcpy(*tedptr,"12");
            strcat(*tedptr,right(rec[record].retime,2));
            strcat(*tedptr,left(rec[record].retime,1));
         }
         else
         {
            if(strlen(rec[record].retime)>0)
            {
               strcpy(*tedptr,right(rec[record].retime,4));
               strcat(*tedptr,left(rec[record].retime,1));
            }
            else
               strcpy(*tedptr,"\0");
         }
      }
      else
         strcpy(*tedptr,"\0");
   }

   if(data_entry.dsubj==TRUE)
   {
      tedptr=(char *)tree[TSUBJED].ob_spec;
      if(strlen(date)==0)
         strcpy(*tedptr,rec[record].rsubj);
      else
         strcpy(*tedptr,"\0");
   }

   for(i=0; i<data_entry.dxfields; i++)
   {
      tedptr=(char *)tree[xfed_tab[0][i]].ob_spec;
      if(strlen(date)==0)
         strcpy(*tedptr,rec[record].rxfield[i]);
      else
         strcpy(*tedptr,"\0");
   }

   for(i=0; i<4; i++)
   {
      if(data_entry.ddescr_lines>i)
      {
         tedptr=(char *)tree[descr_idx[i]].ob_spec;
         if(strlen(date)==0)
            strcpy(*tedptr,rec[record].rdescr[i]);
         else
            strcpy(*tedptr,"\0");
      }
   }

   valid=FALSE;

   do_msgs(tree,TEDITREC,ERDATE,FALSE,FALSE);

   if(strlen(date)==0)
      err_obj=0;
   else
      err_obj=ERTICKLE;

   while(!valid)
   {
      exit_obj=do_dialog(tree,TEDITREC,err_obj,0,1);

      if(strlen(date)!=0)
      {
         ob_unhide(tree,EREXIT);
         ob_unhide(tree,ERDELETE);
      }

      valid=TRUE;

      if(exit_obj!=ERCANCEL && exit_obj!=EREXIT && exit_obj!=ERDELETE)
      {
         strcpy(old_date,rec[record].rdate);
         if(data_entry.dstime==TRUE)
            strcpy(old_stime,rec[record].rstime);
         if(data_entry.detime==TRUE)
            strcpy(old_etime,rec[record].retime);
         if(data_entry.dsubj==TRUE)
            strcpy(old_subj,rec[record].rsubj);
         for(i=0; i<data_entry.dxfields; i++)
            strcpy(old_xfield[i],rec[record].rxfield[i]);
         for(i=0; i<data_entry.ddescr_lines; i++)
            strcpy(old_descr[i],rec[record].rdescr[i]);

         tedptr=(char *)tree[ERDATE].ob_spec;
         if(validate_date(*tedptr,TEDITREC))
            get_date(*tedptr,rec[record].rdate,last.lsdate);
         else
         {
            valid=FALSE;
            date_error_alert(*tedptr);
            err_obj=ERDATE;
            continue;
         }

         if(data_entry.dtickler==TRUE)
         {
            tedptr=(char *)tree[ERTICKLE].ob_spec;
            if(strlen(*tedptr)>0)
               strcpy(last.ldays,*tedptr);
            days=atoi(*tedptr);
            if(days>0)
            {
               if(ob_selected(tree,ERTICKAH))
                  direction=FORWARD;
               else
                  direction=BACKWARD;

               if(direction==FORWARD)
                  strcpy(res_date,fd_forward(rec[record].rdate,days));
               else
                  strcpy(res_date,fd_backward(rec[record].rdate,days));

               tick_result(res_date);

               strcpy(rec[record].rdate,res_date);
            }
         }

         if(data_entry.dstime==TRUE)
         {
            tedptr=(char *)tree[ERSTIME].ob_spec;
            if(time_valid(*tedptr))
               get_time(*tedptr,rec[record].rstime,last.lstime);
            else
            {
               valid=FALSE;
               form_alert(1,timealrt);
               err_obj=ERSTIME;
               continue;
            }
         }

         if(data_entry.detime==TRUE)
         {
            tedptr=(char *)tree[ERETIME].ob_spec;
            if(time_valid(*tedptr))
               get_time(*tedptr,rec[record].retime,last.letime);
            else
            {
               valid=FALSE;
               form_alert(1,timealrt);
               err_obj=ERETIME;
               continue;
            }
         }

         if(data_entry.dsubj==TRUE)
         {
            tedptr=(char *)tree[TSUBJED].ob_spec;
            strcpy(rec[record].rsubj,*tedptr);
            if(strlen(*tedptr)>0)
               strcpy(last.lsubj,*tedptr);
         }

         for(i=0; i<data_entry.dxfields; i++)
         {
            tedptr=(char *)tree[xfed_tab[0][i]].ob_spec;
            strcpy(rec[record].rxfield[i],*tedptr);
            if(strlen(*tedptr)>0)
               strcpy(last.lxfield[i],*tedptr);
         }
        
         for(i=0; i<data_entry.ddescr_lines; i++)
         {
            tedptr=(char *)tree[descr_idx[i]].ob_spec;
            strcpy(rec[record].rdescr[i],*tedptr);
            if(strlen(*tedptr)>0)
               strcpy(last.ldescr[i],*tedptr);
          }

         if(strlen(date)!=0)
         {
            rec[record].rdeleted=FALSE;
            auto_perform();
            rec_no++;
            if(rec_no>=max_recs)
            {
               form_alert(1,memalrt);
               set_state(citree,CINEWREC,DISABLED);
               set_state(menu_tree,RECNEW,DISABLED);
            }
         }

         changed=FALSE;

         if(strcmp(old_date,rec[record].rdate)!=0   ||
            (data_entry.dstime && strcmp(old_stime,rec[record].rstime)!=0) ||
            (data_entry.detime && strcmp(old_etime,rec[record].retime)!=0) ||
            (data_entry.dsubj  && strcmp(old_subj,rec[record].rsubj)!=0))
            changed=TRUE;
         for(i=0; i<data_entry.dxfields; i++)
            if(strcmp(old_xfield[i],rec[record].rxfield[i])!=0)
               changed=TRUE;
         for(i=0; i<data_entry.ddescr_lines; i++)
            if(strcmp(old_descr[i],rec[record].rdescr[i])!=0)
               changed=TRUE;

         if(exit_obj!=ERCANCEL && changed)
         {
            rec_modified=TRUE;
            cur_modified=TRUE;
         }
      }
   }

   if(exit_obj==ERCANCEL)
      return(ERCANCEL);

   set_names();

   if(exit_obj==ERDELETE)
   {
      clr_record(record);
      rec[record].rdeleted=TRUE;
      strcpy(rec[record].rdate,"99999999");
      rec_modified=TRUE;
      cur_modified=TRUE;
      del_state(menu_tree,RECNEW,DISABLED);
      del_state(citree,CINEWREC,DISABLED);
      return(ERDELETE);
   }

   if(exit_obj==EREXIT)
      return(EREXIT);
   else
      return(EROK);
}

clr_record(record)
int  record;
{
   int  i;

   rec[record].rdeleted=TRUE;

   if(data_entry.dstime==TRUE)
      strcpy(rec[record].rstime,"\0");
   if(data_entry.detime==TRUE)
      strcpy(rec[record].retime,"\0");
   if(data_entry.dsubj==TRUE)
      strcpy(rec[record].rsubj,"\0");

   for(i=0; i<data_entry.dxfields; i++)
      strcpy(rec[record].rxfield[i],"\0");

   for(i=0; i<data_entry.ddescr_lines; i++)
      strcpy(rec[record].rdescr[i],"\0");
}

get_transfer_file()
{
   static char name[20],fname[128],path[128],dir[128];
   long size;
   int  sort_flag,exit_obj,magic,i;

   form_alert(1,tranalrt);

   get_path(dir,path,"*.REC");
   fsel_input(path,name,&exit_obj);
   path_to_name(path,name);
   strcpy(fname,path);
   do_extension(fname,"REC");
   do_extension(name,"REC");

   if(strcmp(fname,rec_file)==0)
   {
      cur_file=TRUE;
      form_alert(1,curalrt);
      return;
   }
   else
      cur_file=FALSE;

   new_transfer_file=FALSE;

   if(exit_obj!=0)
   {
      graf_mouse(HOURGLASS,&dummy);

      trans_fhandle=ERROR;
      trans_fhandle=Fopen(fname,2);
      if(trans_fhandle<=ERROR)
      {
         trans_fhandle=Fcreate(fname,0);
         new_transfer_file=TRUE;
      }
      if(trans_fhandle>ERROR)
      {
         disk_full=FALSE;

         magic=REC_MAGIC;

         EFwrite(trans_fhandle,2L,&magic);

         sort_flag=TRUE;
         EFwrite(trans_fhandle,2L,&sort_flag); /* file will need sorting */

         if(new_transfer_file)
         {
            size=sizeof(CUSTOM);
            EFwrite(trans_fhandle,size,&data_entry);

            if(disk_full)
            {
               form_alert(1,dfullalrt);
               return(FALSE);
            }

            trans_data.dstime=data_entry.dstime;
            trans_data.detime=data_entry.detime;
            trans_data.dsubj=data_entry.dsubj;
            trans_data.dlen_subj=data_entry.dlen_subj;
            trans_data.ddescr_lines=data_entry.ddescr_lines;
            for(i=0; i<4; i++)
               trans_data.dlen_descr[i]=data_entry.dlen_descr[i];
            trans_data.dxfields=data_entry.dxfields;
            for(i=0; i<NUM_XFIELDS; i++)
               trans_data.dxfchrs[i]=data_entry.dxfchrs[i];
         }
         else
         {
            size=sizeof(CUSTOM);
            Fread(trans_fhandle,size,&trans_data);

            Fseek(0L,trans_fhandle,2); /* go to end of file */
         }
         if(form_alert(1,movealrt)==1)
            move_flag=TRUE;
         else
            move_flag=FALSE;

         return(TRUE);
      }
      else
         return(FALSE);
   }
   else
      return(FALSE);
}

copy_rec(dest,source)
RECORD *dest,*source;
{
   int  i;

   dest->rdeleted=FALSE;

   strcpy(dest->rdate,source->rdate);
   if(data_entry.dstime)
      strcpy(dest->rstime,source->rstime);
   if(data_entry.detime)
      strcpy(dest->retime,source->retime);
   if(data_entry.dsubj)
      strcpy(dest->rsubj,source->rsubj);
   for(i=0; i<data_entry.dxfields; i++)
      strcpy(dest->rxfield[i],source->rxfield[i]);
   for(i=0; i<data_entry.ddescr_lines; i++)
      strcpy(dest->rdescr[i],source->rdescr[i]);

   rec_modified=TRUE;
   cur_modified=TRUE;
}

do_transfer(i)
int  i;
{
   char empty[41];
   int  j,k,xfidx;
   long val;

   strcpy(empty,"\0");

   EFwrite(trans_fhandle,9L,rec[i].rdate);
   if(trans_data.dstime)
      EFwrite(trans_fhandle,6L,rec[i].rstime);
   if(trans_data.detime)
      EFwrite(trans_fhandle,6L,rec[i].retime);
   if(trans_data.dsubj)
   {
      val=trans_data.dlen_subj+1;
      EFwrite(trans_fhandle,val,rec[i].rsubj);
   }
   for(j=0; j<trans_data.dxfields; j++)
   {
      xfidx=(-1);

      if(strcmp(trans_data.dxflabel[j],
         data_entry.dxflabel[j])!=0 && !new_transfer_file)
      {
         for(k=0; k<NUM_XFIELDS; k++)
         {
            if(strcmp(trans_data.dxflabel[j],
               data_entry.dxflabel[k])==0)
            {
               xfidx=k;
               break;
            }
         }
      }
      else
         xfidx=j;

      val=trans_data.dxfchrs[j]+1;

      if(xfidx>(-1))
         EFwrite(trans_fhandle,val,rec[i].rxfield[xfidx]);
      else
         EFwrite(trans_fhandle,val,empty);
   }
   for(j=0; j<trans_data.ddescr_lines; j++)
   {
      val=trans_data.dlen_descr[j]+1;
      EFwrite(trans_fhandle,val,rec[i].rdescr[j]);
   }
}

sel_print()
{
   int  i,j,device;

   wind_update(1);

   hide_windows();

   device=sel_device(TRUE);

   if(device==(-1))
   {
      show_windows();
      wind_update(0);
      return;
   }

   rpt_index=window[sel_windex].wcontents-WC_REPORT;

   tot_lines=0; page_setup.pfirst_page=1; page_setup.plast_page=32767;

   if(device==DEV_PRINTER && form_alert(2,addonalrt)==2)
      page_setup.pnew_report=FALSE;
   else
      page_setup.pnew_report=TRUE;

   rpt_free=FALSE;

   if(!do_page_setup(device))
   {
      show_windows();
      wind_update(0);
      return;
   }

   if(device==DEV_DISK && !do_disk())
   {
      show_windows();
      wind_update(0);
      return;
   }

   if(device==DEV_PRINTER)
   {
      while(!prt_ready())
      {
         if(form_alert(1,poffalrt)==2)
         {
            show_windows();
            wind_update(0);
            return;
         }
      }
      on_codes();
   }

   strcpy(old_date,"\0");

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

      pages_this_rpt=0; line_this_rpt=0;

      prt_title(device);

      skip_flag=FALSE;

      if(page_setup.pcopies>j+1)
         inc_page=FALSE;
      else
         inc_page=TRUE;

      if(device==DEV_PRINTER)
         while(!prt_ready());

      graf_mouse(HOURGLASS,&dummy);

      for(i=0; i<NUM_SELECTIONS; i++)
         if(select[i].sselected==TRUE && select[i].srec_no>(-1) &&
            select[i].scommon!=TRUE)
            prt_detail(device,-1,select[i].srec_no);

      if(device==DEV_PRINTER && page_setup.peject_page)
      {
         if(line_number>0)
         {
            prt_char(DEV_PRINTER,12);
            if(inc_page)
               page_number++;
            line_number=0;
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

   show_windows();

   wind_update(0);
}

sel_edit()
{
   int  i,exit_obj;

   for(i=0; i<NUM_SELECTIONS; i++)
   {
      if(select[i].sselected==TRUE && select[i].srec_no>(-1) &&
         select[i].scommon!=TRUE)
      {
         exit_obj=edit_record(select[i].srec_no,"\0");
         if(exit_obj==EREXIT)
            break;
         else if(exit_obj==ERDELETE)
            total++;
      }
   }
}

sel_delete()
{
   register int i;

   if(form_alert(1,drecalrt)!=1)
      return(0);

   for(i=0; i<NUM_SELECTIONS; i++)
   {
      if(select[i].sselected==TRUE && select[i].srec_no>(-1) &&
         select[i].scommon!=TRUE)
      {
         clr_record(select[i].srec_no);
         rec[select[i].srec_no].rdeleted=TRUE;
         strcpy(rec[select[i].srec_no].rdate,"99991231");
         rec_modified=TRUE;
         cur_modified=TRUE;

         total++;
      }
   }
}

sel_transfer()
{
   int  i;

   if(!get_transfer_file())
      return(FALSE);

   for(i=0; i<NUM_SELECTIONS; i++)
   {
      if(select[i].sselected==TRUE && select[i].srec_no>(-1) &&
         select[i].scommon!=TRUE)
      {
         if(cur_file)
         {
            if(rec_no+total>=max_recs)
            {
               form_alert(1,memalrt);
               set_state(menu_tree,RECNEW,DISABLED);
               set_state(citree,CINEWREC,DISABLED);
               break;
            }
            copy_rec(&rec[rec_no+total],&rec[select[i].srec_no]);
         }
         else
         {
            do_transfer(select[i].srec_no);
            if(move_flag==TRUE)
            {
               clr_record(select[i].srec_no);
               rec[select[i].srec_no].rdeleted=TRUE;
               strcpy(rec[select[i].srec_no].rdate,"99991231");
               rec_modified=TRUE;
               cur_modified=TRUE;
            }
            if(disk_full)
            {
               form_alert(1,dfullalrt);
               break;
            }
         }
         total++;
      }
   }
   return(TRUE);
}

chg_mark(which)
int  which;
{
   register int i;

   wind_update(1);

   graf_mouse(HOURGLASS,&dummy);

   for(i=0; i<rec_no; i++)
   {
      if(rec[i].rdeleted==2)
      {
         if(which==TRUE)
         {
            clr_record(i);
            rec[i].rdeleted=TRUE;
            strcpy(rec[i].rdate,"99991231");
            rec_modified=TRUE;
            cur_modified=TRUE;
         }
         else
            rec[i].rdeleted=FALSE;
      }
   }

   if(which==FALSE)
      total=0;

   graf_mouse(ARROW,&dummy);

   wind_update(0);
}



