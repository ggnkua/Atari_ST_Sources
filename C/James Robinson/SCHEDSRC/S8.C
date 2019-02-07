/* S8.C -- REPORT PRINTING RELATED FUNCTIONS */

#include "stdio.h"
#include "obdefs.h"
#include "gemdefs.h"
#include "osbind.h"
#include "schdefs.h"
#include "ctools.h"
#include "schedule.h"

extern int  rpt_index,tot_lines,line_number,page_number,sel_tab[CAL_LINES],
            rec_no,vdi_handle,rpt_free,dummy,gl_hbox,py,skip_flag,rptcounter,
            rpt_decision[9],gl_wbox,ciyind,cicounter,cixdescr,cilines,
            device,xfed_tab[2][5],pxy[8],mx,my,cixshown,cishown,sel_windex,
            pages_this_rpt,day_spacing,cal_idx,*y_to_rec_no[9],top_rec,
            title_retained,inc_page,rm_decision[9],end_flag,line_this_rpt,
            rez;

extern char header1[MAX_CLMS+1],header2[MAX_CLMS+1],und_score[MAX_CLMS+1],
            timealrt[],freealrt[],apalrt[],rpt_sdate[9],rpt_edate[9],
            old_date[9],diskalrt[],sdatealrt[],pausalrt[],poffalrt[],
            rpt_title[61],rec_name[20],sys_date[9],sys_time[6],samedalrt[],
            asc_name[129],rm_stime[6],rm_etime[6],rm_subj[6],
            rm_xfield[NUM_XFIELDS][41],rm_descr[41];

extern OBJECT *citree;

extern RPT report[NUM_REPORTS];

extern SELECTION select[NUM_SELECTIONS];

extern RECORD *rec;

extern WIND window[NUM_WINDS];

extern PAGE page_setup;

extern CUSTOM data_entry;

extern FILE *asc_file;

extern OTHER_PREFS prefs;

print_schedule(device,windex,sdate,edate,stime,etime,subj,
               xfield0,xfield1,xfield2,xfield3,xfield4,descr)
int  device,windex;
char *sdate,*edate,*stime,*etime,*subj,
     *xfield0,*xfield1,*xfield2,*xfield3,*xfield4,*descr;
{
   OBJECT *tree;
   int  xdial,ydial,wdial,hdial,obj,which,idx,firstrec,firstfound,aborted,key,
        rec_printed,found[9],decision[9];
   register int  i,j,start,y_counter;
   static char xfield[5][41],**tedptr,old_time[6],old_sys_date[9],
               free_sdate[9],free_edate[9];

   if(rec_no==0)
      return;

   wind_update(1);
   wind_update(3);

   strcpy(rpt_sdate,sdate); strcpy(rpt_edate,edate);

   strcpy(old_date,"\0");

   if(device==DEV_PRINTER)
   {
      while(!prt_ready())
      {
         if(form_alert(1,poffalrt)==2)
         {
            wind_update(0);
            wind_update(2);
            return(-1);
         }
      }
   }

   if(device==DEV_PRINTER || device==DEV_DISK)
   {
      rsrc_gaddr(0,TPRINT,&tree);

      form_center(tree,&xdial,&ydial,&wdial,&hdial);
      form_dial(0,0,0,0,0,xdial,ydial,wdial,hdial);

      if(device==DEV_PRINTER && page_setup.pnew_report)
      {
         tedptr=(char *)tree[PPRINTED].ob_spec;
         itoa(pages_this_rpt,*tedptr);
         strcat(*tedptr,replicate(' ',4-strlen(*tedptr)));

         tedptr=(char *)tree[PREMAIN].ob_spec;
         itoa(page_setup.plast_page-pages_this_rpt,*tedptr);
         strcat(*tedptr,replicate(' ',4-strlen(*tedptr)));
      }
      else
      {
         ob_hide(tree,PPRINTED);
         ob_hide(tree,PPRTLAB);
         ob_hide(tree,PREMAIN);
         ob_hide(tree,PREMLAB);
      }

      objc_draw(tree,0,8,xdial,ydial,wdial,hdial);

      evnt_timer(1000,0);

      key=Bconstat(2);

      while(key)
      {
         Bconin(2);
         key=Bconstat(2);
      }
   }

   strcpy(xfield[0],xfield0);
   strcpy(xfield[1],xfield1);
   strcpy(xfield[2],xfield2);
   strcpy(xfield[3],xfield3);
   strcpy(xfield[4],xfield4);

   if(device==DEV_COUNT_LINES && windex>(-1))
   {
      window[windex].wlines=0;
      window[windex].wxdescr=0;
   }

   if(device==DEV_COUNT_LINES && windex==(-2))
   {
      cixdescr=0;
      cilines=0;
      cicounter=0;
   }

   if(device==DEV_CINFO_WINDOW)
      cicounter=0;

   if(device==DEV_SHOWN)
   {
      if(windex>(-1))
      {
         window[windex].wshown=0;
         for(j=0; j<NUM_SELECTIONS; j++)
         {
            select[j].sselected=FALSE;
            select[j].srec_no=(-1);
            select[j].scommon=FALSE;
            rptcounter=0;
         }
      }
      if(windex==(-2))
      {
         cicounter=0;
         cixshown=0;
         cishown=0;
      }
   }

   if(device==DEV_WINDOW || device==DEV_COUNT_LINES || device==DEV_SHOWN)
   {
      if(windex>(-1))
      {
         idx=window[windex].wcontents-WC_REPORT;
         for(i=0; i<9; i++)
            decision[i]=window[windex].wdecision[i];
      }
   }

   if(device==DEV_COUNT_LINES || device==DEV_DISK || device==DEV_PRINTER)
   {
      if(windex==(-1))
      {
         idx=rpt_index;
         for(i=0; i<9; i++)
            decision[i]=rpt_decision[i];

         day_spacing=0;
      }
   }

   if(device==DEV_COUNT_LINES || device==DEV_CINFO_WINDOW || device==DEV_SHOWN)
   {
      if(windex==(-2))
      {
         idx=0;
         for(i=0; i<9; i++)
            decision[i]=window[cal_idx].wdecision[i];
      }
   }

   strcpy(rm_stime,stime);
   strcpy(rm_etime,etime);
   strcpy(rm_subj,subj);
   for(i=0; i<NUM_XFIELDS; i++)
      strcpy(rm_xfield[i],xfield[i]);
   strcpy(rm_descr,descr);
   for(i=0; i<9; i++)
      rm_decision[i]=decision[i];

   if(device==DEV_WINDOW)
   {
      vswr_mode(vdi_handle,MD_REPLACE);
      vst_color(vdi_handle,BLACK);
      vst_effects(vdi_handle,NORMAL);
   }

   if((device==DEV_WINDOW || device==DEV_COUNT_LINES || device==DEV_SHOWN) &&
       windex>(-1))
   {
      if(window[windex].wsys_sdate==TRUE)
      {
          strcpy(sdate,sys_date);
          strcpy(window[windex].wsdate,sys_date);
      }

      if(window[windex].wsys_edate==TRUE)
      {
          strcpy(edate,sys_date);
          strcpy(window[windex].wedate,sys_date);
      }

      if(window[windex].wbeg_flag==TRUE)
      {
         for(i=0; i<rec_no; i++)
         {
            if(rec[i].rdeleted!=TRUE && rec_match(&rec[i]))
            {
               strcpy(sdate,rec[i].rdate);
               break;
            }
         }
      }
      if(window[windex].wend_flag==TRUE)
      {
         for(i=rec_no-1; i>=0; i--)
         {
            if(rec[i].rdeleted!=TRUE && rec_match(&rec[i]))
            {
               strcpy(edate,rec[i].rdate);
               break;
            }
         }
      }
   }

   if(device==DEV_COUNT_LINES && windex==(-1))
   {
      line_number=0;
      tot_lines=0;
   }

   if(device==DEV_CINFO_WINDOW || (device==DEV_SHOWN && windex==(-2)))
   {
      start=y_to_rec_no[8][ciyind];

      if(start==(-1))
      {
         wind_update(0);
         wind_update(2);
         return;
      }
   }
   else if(device==DEV_WINDOW || (device==DEV_SHOWN && windex>(-1)))
   {
      start=y_to_rec_no[windex][window[windex].wyindex];
      if(start==(-1))
      {
         wind_update(0);
         wind_update(2);
         return;
      }
   }
   else
      start=0;

   if(device==DEV_PRINTER)
      on_codes();

   if(device==DEV_PRINTER || device==DEV_DISK ||
     (device==DEV_COUNT_LINES && windex==(-1)))
      prt_title(device);

   if(device==DEV_WINDOW || (device==DEV_SHOWN && windex>(-1)))
   {
      py=0;

      if(strlen(window[windex].w1header)>0)
         py+=gl_hbox-1;
      if(strlen(window[windex].w2header)>0)
         py+=gl_hbox-1;
   }
 
   skip_flag=FALSE; firstrec=TRUE; aborted=FALSE; firstfound=TRUE;

   rec_printed=FALSE; y_counter=0;

   for(i=start; i<rec_no; i++)
   {
      if(device==DEV_PRINTER || device==DEV_DISK)
      {
         which=evnt_multi(MU_KEYBD|MU_TIMER|MU_BUTTON,1,0x01,1,0,
                          0,0,0,0,0,0,0,0,0,&dummy,
                          5,0,&mx,&my,&dummy,&dummy,&key,&dummy);

         strcpy(old_time,sys_time);
         strcpy(old_sys_date,sys_date);

         get_sys_date(FALSE);

         if((prefs.optime_display && strcmp(old_time,sys_time)!=0) ||
            (prefs.opdate_display && strcmp(old_sys_date,sys_date)!=0))
            time_display();

         if(which & MU_BUTTON)
         {
            obj=objc_find(tree,0,8,mx,my);
            if(obj==PCANCEL)
               objc_change(tree,PCANCEL,0,0,0,0,0,SELECTED,1);
         }

         if(which & MU_KEYBD)
         {
            if(key=0x1C0D || key==0x720D)
               objc_change(tree,PCANCEL,0,0,0,0,0,SELECTED,1);
         }
      }

      if((device==DEV_DISK || device==DEV_PRINTER) &&
         ob_selected(tree,PCANCEL))
      {
         aborted=TRUE;
         break;
      }

      for(j=0; j<9; j++)
         found[j]=FALSE;

      if(device==DEV_WINDOW)
         if(py>=window[windex].work_area.g_h)
            break;

      if(device==DEV_SHOWN && windex>(-1))
         if(py>=window[windex].work_area.g_h)
            break;

      if(device==DEV_SHOWN && windex==(-2))
         if(cicounter>CAL_LINES-1)
            break;

      if(device==DEV_CINFO_WINDOW)
         if(cicounter>CAL_LINES-1)
            break;

      if(device==DEV_PRINTER && page_setup.plast_page<pages_this_rpt)
         break;

      if(strcmp(rec[i].rdate,sdate)>=0 && strcmp(rec[i].rdate,edate)<=0)
      {
         if(rec[i].rdeleted!=TRUE)
         {
            if(firstrec && rpt_free && windex==(-1))
            {
               if(strcmp(sdate,rec[i].rdate)!=0)
               {
                  strcpy(free_sdate,fd_backward(sdate,1));
                  do_free_days(device,free_sdate,rec[i].rdate);
               }
            }
            firstrec=FALSE;

            if(rec_match(&rec[i]))
            {
               prt_detail(device,windex,i);

               if(firstfound && device==DEV_COUNT_LINES)
                  if(windex>(-1))
                     top_rec=i;

               firstfound=FALSE;

               rec_printed=TRUE;
            }
         }
      }
      if(strcmp(edate,rec[i].rdate)<0)
         break;

      y_counter++;

      if(device==DEV_CINFO_WINDOW || (device==DEV_SHOWN && windex==(-2)))
      {
         if(i<y_to_rec_no[8][ciyind+y_counter])
            i=y_to_rec_no[8][ciyind+y_counter]-1;
      }
      else if(device==DEV_WINDOW || (device==DEV_SHOWN && windex>(-1)))
      {
         if(i<y_to_rec_no[windex][window[windex].wyindex+y_counter])
            i=y_to_rec_no[windex][window[windex].wyindex+y_counter]-1;
      }
   }

   if(device==DEV_COUNT_LINES)
   {
      if(windex>(-1))
         y_to_rec_no[windex][window[windex].wlines]=(-1);
      else if(windex==(-2))
         y_to_rec_no[8][cilines]=(-1);
   }

   if(rpt_free && windex==(-1) && !rec_printed)
   {
      strcpy(free_sdate,fd_backward(sdate,1));
      strcpy(free_edate,fd_forward(edate,1));
      do_free_days(device,free_sdate,free_edate);
   }
   else if(rpt_free && windex==(-1) && !aborted)
   {
      newline(device,report[idx].cmin_spacing_per_day-day_spacing);
      if(!end_flag)
         strcpy(free_edate,fd_forward(edate,1));
      do_free_days(device,old_date,free_edate);
   }

   if(device==DEV_CINFO_WINDOW)
   {
      for(i=CAL_LINES-1; i>=cicounter; i--)
      {
         tedptr=(char *)citree[CIDESCR1+i].ob_spec;
         strcpy(*tedptr,replicate(' ',70));
         sel_tab[i]=(-1);
         set_state(citree,CIDESCR1+i,DISABLED);
      }
      objc_draw(citree,CIWDWBOX,8,0,0,0,0);
   }

   if(device==DEV_DISK || (device==DEV_PRINTER && line_number>0))
      if(report[rpt_index].cstyle==DAILY)
         newline(device,1);

   if(device==DEV_PRINTER)
   {
      off_codes();
      if(page_setup.peject_page && line_number>0)
      {
         prt_char(DEV_PRINTER,12);
         line_number=0;
         if(inc_page)
            page_number++;
      }
   }

   if(device==DEV_PRINTER || device==DEV_DISK)
   {
      if(device==DEV_PRINTER)
         upd_print_dialog();
      form_dial(3,0,0,0,0,xdial,ydial,wdial,hdial);
      objc_change(tree,PCANCEL,0,0,0,0,0,NORMAL,0);

      if(device==DEV_DISK || page_setup.pnew_report==FALSE)
      {
         ob_unhide(tree,PPRINTED);
         ob_unhide(tree,PPRTLAB);
         ob_unhide(tree,PREMAIN);
         ob_unhide(tree,PREMLAB);
      }

      key=Bconstat(2);

      while(key)
      {
         Bconin(2);
         key=Bconstat(2);
      }
   }

   wind_update(0);
   wind_update(2);
}

int 
match(which,str,substr)
int  which;
char str[41],substr[41];
{
   switch(which)
   {
      case IN:           if(instr(str,substr))
                            return(TRUE);
                         else
                            return(FALSE);
                         break;
      case EQUAL:        if(strcmp(str,substr)==0)
                            return(TRUE);
                         else
                            return(FALSE);
                         break;
      case NOT_EQUAL:    if(strcmp(str,substr))
                            return(TRUE);
                         else
                            return(FALSE);
                         break;
      case LESS_THAN:    if(strcmp(str,substr)<0)
                            return(TRUE);
                         else
                            return(FALSE);
                         break;
      case GREATER_THAN: if(strcmp(str,substr)>0)
                            return(TRUE);
                         else
                            return(FALSE);
                         break;
      case LT_OR_EQUAL:  if(strcmp(str,substr)<=0)
                            return(TRUE);
                         else
                            return(FALSE);
                         break;
      case GT_OR_EQUAL:  if(strcmp(str,substr)>=0)
                            return(TRUE);
                         else
                            return(FALSE);
                         break;
   }
}

shown_count(windex)
int  windex;
{
   if(window[windex].wopen!=TRUE ||
      window[windex].wcontents<WC_REPORT)
      return;

   if(window[windex].wlines>0)
      rpt_boundaries(windex);

   print_schedule(DEV_SHOWN,windex,window[windex].wsdate,window[windex].wedate,
                  window[windex].wstime,window[windex].wetime,
                  window[windex].wsubj,window[windex].wxfield[0],
                  window[windex].wxfield[1],window[windex].wxfield[2],
                  window[windex].wxfield[3],window[windex].wxfield[4],
                  window[windex].wdescr);
}

count_lines(i)
int  i;
{
   int  j;
   char xfield[NUM_XFIELDS][41];

   wind_update(1);

   graf_mouse(HOURGLASS,&dummy);

   for(j=0; j<NUM_XFIELDS; j++)
      strcpy(xfield[j],window[i].wxfield[j]);

   print_schedule(DEV_COUNT_LINES,i,window[i].wsdate,window[i].wedate,
                  window[i].wstime,window[i].wetime,window[i].wsubj,
                  xfield[0],xfield[1],xfield[2],xfield[3],xfield[4],
                  window[i].wdescr);

   shown_count(i);
   set_wdw_header(i);
   set_sliders(window[i].whandle,window[i].wcontents);

   graf_mouse(ARROW,&dummy);

   wind_update(0);
}

count_all_lines()
{
   int  i;

   wind_update(1);

   for(i=0; i<NUM_WINDS; i++)
      if(window[i].wopen==TRUE && window[i].wcontents>=WC_REPORT)
         count_lines(i);

   wind_update(0);
}

rpt_update(windex)
int  windex;
{
   GRECT box,dummy;

   wind_update(1);

   HIDE_MOUSE;

   wind_get(window[windex].whandle,WF_FIRSTXYWH,
            &box.g_x,&box.g_y,&box.g_w,&box.g_h);
   while(box.g_w && box.g_h)
   {
      if(sel_windex==windex && sel_windex!=(-1))
         sel_clear(&box,FALSE);
      wind_report(windex,&box);
      wind_get(window[windex].whandle,WF_NEXTXYWH,
         &box.g_x,&box.g_y,&box.g_w,&box.g_h);
   }

   if(sel_windex==windex && sel_windex!=(-1))
      sel_clear(&dummy,TRUE);

   wind_update(0);

   SHOW_MOUSE;
}

uses_time(idx)
int  idx;
{
   register int  i,j;

   for(i=0; i<2; i++)
   {
      for(j=0; j<9; j++)
      {
         if(report[idx].cinfo[i][j]==CR_MED_TO_EVENT ||
            report[idx].cinfo[i][j]==CR_LONG_TO_EVENT)
            return(TRUE);
      }
   }
   return(FALSE);
}

uses_day(idx)
int  idx;
{
   register int  i,j;

   for(i=0; i<2; i++)
      for(j=0; j<9; j++)
         if(report[idx].cinfo[i][j]==CR_SHORT_TO_EVENT)
            return(TRUE);

   return(FALSE);
}

time_rpts_update()
{
   int  i;

   if(rec_no==0)
      return;

   for(i=0; i<NUM_WINDS; i++)
   {
      if(window[i].wopen==TRUE && window[i].wcontents>=WC_REPORT &&
         window[i].whidden!=TRUE)
      {
         if(uses_time(window[i].wcontents-WC_REPORT))
            rpt_update(i);
      }
   }
}

day_rpts_update()
{
   int  i;

   if(rec_no==0)
      return;

   sys_count();

   for(i=0; i<NUM_WINDS; i++)
   {
      if(window[i].wopen==TRUE && window[i].wcontents>=WC_REPORT &&
         window[i].whidden!=TRUE)
      {
         if(uses_day(window[i].wcontents-WC_REPORT))
            rpt_update(i);
         else if(window[i].wsys_sdate || window[i].wsys_edate)
            rpt_update(i);
      }
      else if(window[i].wopen==TRUE && window[i].wcontents==WC_CALENDAR &&
              window[i].whidden!=TRUE)
      {
         cal_idx=i;
         draw_cal(i,&window[i].work_area);
      }
   }
}

sys_count()
{
   int  i;

   if(rec_no==0)
      return;

   for(i=0; i<NUM_WINDS; i++)
   {
      if(window[i].wopen==TRUE && window[i].wcontents>=WC_REPORT)
         if(window[i].wsys_sdate || window[i].wsys_edate)
            count_lines(i);
   }
}

rpt_boundaries(windex)
int  windex;
{
   int  val;

   val=window[windex].work_area.g_w/8;
   if(window[windex].wxindex>window[windex].wcolumns-val)
      window[windex].wxindex=window[windex].wcolumns-val;
   if(window[windex].wxindex<0)
      window[windex].wxindex=0;

   if(window[windex].wyindex>window[windex].wlines-1)
      window[windex].wyindex=window[windex].wlines-1;
   if(window[windex].wyindex<0)
      window[windex].wyindex=0;
}

wind_report(windex,clip_area)
int  windex;
GRECT *clip_area;
{
   int  old_y;

   HIDE_MOUSE;

   wind_update(1);

   old_y=window[windex].wyindex;

   if(window[windex].wlines>0)
      rpt_boundaries(windex);

   if(old_y!=window[windex].wyindex)
      shown_count(windex);

   fill_window(clip_area);
   wdw_header(windex,clip_area);

   grect_to_array(clip_area,pxy);
   set_clip(vdi_handle,TRUE,clip_area);
   print_schedule(DEV_WINDOW,windex,window[windex].wsdate,window[windex].wedate,
                  window[windex].wstime,window[windex].wetime,window[windex].wsubj,
                  window[windex].wxfield[0],window[windex].wxfield[1],
                  window[windex].wxfield[2],window[windex].wxfield[3],
                  window[windex].wxfield[4],window[windex].wdescr);
   set_clip(vdi_handle,FALSE,clip_area);

   wind_update(0);

   SHOW_MOUSE;
}

wind_text(windex,string)
int  windex;
char *string;
{
   v_gtext(vdi_handle,window[windex].work_area.g_x,
                      window[windex].work_area.g_y+py+(7*rez),string);

   py+=gl_hbox-2;
}

newline(device,n)
int  device,n;
{
   int  i,j;

   for(i=0; i<n; i++)
   {
      if(device==DEV_PRINTER)
      {
         prt_char(device,13);
         prt_char(device,10);

         line_number++;

         line_this_rpt++;

         if(line_this_rpt>=page_setup.pbmarg)
         {
            pages_this_rpt++;
            line_this_rpt=0;
         }

         if(line_number>=page_setup.pbmarg)
         {
            for(j=0; j<page_setup.ppage_size-page_setup.pbmarg; j++)
            {
               prt_char(device,13);
               prt_char(device,10);
            }

            line_number=0;

            page_number++;

            if(page_setup.ptype_sheet==SINGLE &&
               page_setup.pfirst_page<pages_this_rpt+1 &&
               page_setup.plast_page>=pages_this_rpt+1)
               form_alert(1,pausalrt);

            upd_print_dialog();

            prt_title(device);
         }
         if(device==DEV_PRINTER && page_setup.plast_page<pages_this_rpt+1)
            line_number=0;
      }
      else if(device==DEV_DISK)
         prt_char(device,'\n');
      else if(device==DEV_COUNT_LINES)
      {
         tot_lines++;

         line_number++;

         if(line_number>=page_setup.pbmarg)
         {
            line_number=0;
            prt_title(device);
         }
      }
   }
}

upd_print_dialog()
{
   OBJECT *tree;
   char **tedptr;

   if(!page_setup.pnew_report)
      return;

   rsrc_gaddr(0,TPRINT,&tree);

   tedptr=(char *)tree[PPRINTED].ob_spec;
   itoa(pages_this_rpt,*tedptr);
   strcat(*tedptr,replicate(' ',4-strlen(*tedptr)));

   objc_draw(tree,PPRINTED,0,0,0,0,0);

   tedptr=(char *)tree[PREMAIN].ob_spec;
   itoa(page_setup.plast_page-pages_this_rpt,*tedptr);
   strcat(*tedptr,replicate(' ',4-strlen(*tedptr)));

   objc_draw(tree,PREMAIN,0,0,0,0,0);
}

prt_char(device,c)
int  device,c;
{
   if(device==DEV_PRINTER)
   {
      if(!page_setup.pnew_report) /* adding on to existing report */
         Bconout(device,c);
      else if(page_setup.pfirst_page<=pages_this_rpt+1 &&
              page_setup.plast_page>=pages_this_rpt+1)
         Bconout(device,c);
   }
   else if(device==DEV_DISK)
      fputc(c,asc_file);
}

prt_ready()
{
   evnt_timer(50,0);
   return((int )gemdos(0x11));
}

dprint(device,string)
int  device;
char *string;
{
   int  i;

   if(device==DEV_PRINTER)
      for(i=0; i<page_setup.plmarg-1; i++)
         prt_char(device,' ');

   if(device==DEV_PRINTER || device==DEV_DISK)
   {
      for(i=0; string[i]!=0; i++)
      {
         prt_char(device,string[i]);
         if(device==DEV_PRINTER && i+1>=page_setup.prmarg-page_setup.plmarg-1)
            break;
      }
   }
}

prt_title(device)
int  device;
{
   char title[MAX_CLMS+1],temp[MAX_CLMS+1],temp2[MAX_CLMS+1],temp3[6],
        temp4[MAX_CLMS+1];

   if(device==DEV_PRINTER && page_setup.plast_page<pages_this_rpt+1)
      return;

   if((device==DEV_PRINTER || device==DEV_COUNT_LINES) && line_number==0)
      newline(device,page_setup.ptmarg-1);

   strcpy(temp,"\0");
   strcpy(temp2,"\0");
   strcpy(temp3,"\0");
   strcpy(temp4,"\0");

   if(page_setup.pfile_stamp==TRUE)
   {
      strcat(temp2,rec_name);
      rtrim(temp2);
      strcat(temp2," ");
   }

   if(page_setup.pdate_stamp==TRUE)
   {
      cat_short_date(temp2,sys_date);
      strcat(temp2," ");
   }

   if(page_setup.ptime_stamp==TRUE)
   {
      if(strcmp(mid(sys_time,2,2),"00")==0)
         strcat(temp2,"12");
      else
      {
         if(sys_time[1]=='0')
         {
            strcat(temp2," ");
            strcat(temp2,mid(sys_time,3,1));
         }
         else
            strcat(temp2,mid(sys_time,2,2));
      }
      strcat(temp2,":");
      strcat(temp2,right(sys_time,2));
      if(sys_time[0]=='a')
         strcat(temp2," a.m.");
      else
         strcat(temp2," p.m.");
      strcat(temp2," ");
   }

   if(page_setup.pnumber_page==TRUE && line_number<=page_setup.ptmarg-1)
   {
      strcpy(temp4," Page ");
      itoa(page_number,temp3);
      strcat(temp4,temp3);
   }

   strcpy(temp,left(rpt_title,page_setup.prmarg-page_setup.plmarg-1-
                              (strlen(temp2)+strlen(temp4))));

   strcpy(title,temp2);
   strcat(title,replicate(' ',(page_setup.prmarg/2)-(strlen(temp)/2)-strlen(temp2)));
   strcat(title,temp);

   if(page_setup.pnumber_page==TRUE)
   {
      strcat(title,replicate(' ',page_setup.prmarg-page_setup.plmarg-1-strlen(title)-strlen(temp4)));
      strcat(title,temp4);
   }

   rtrim(title);

   if(device==DEV_PRINTER || device==DEV_COUNT_LINES)
      if((strlen(title)>0 && !title_retained) || page_setup.pheader)
         if(report[rpt_index].cstyle==COLUMN && line_number>page_setup.ptmarg-1)
            newline(device,1);

   if(device==DEV_DISK || line_number<=page_setup.ptmarg ||
     (!page_setup.pnew_report && !title_retained) ||
      page_setup.pnew_report)
   {
      if(strlen(title)>0)
      {
         dprint(device,title);

         if(page_setup.pnew_report)
            newline(device,3);
         else
            newline(device,2);
      }
   }

   if(page_setup.pheader)
   {
      if(strlen(header1)>0)
      {
         dprint(device,header1);
         newline(device,1);
      }
      if(strlen(header2)>0)
      {
         dprint(device,header2);
         newline(device,1);
      }
      if(strlen(und_score)>0)
      {
         dprint(device,und_score);
         newline(device,1);
      }
   }
}

int 
sel_device(hide_window)
int  hide_window;
{
   int  exit_obj;
   OBJECT *tree;

   rsrc_gaddr(0,TPRTDEV,&tree);

   if(hide_window)
   {
      if(ob_selected(tree,PDWINDOW))
         reset_rbuttons(tree,PDPRINT,FALSE);

      ob_hide(tree,PDWINDOW);
      ob_hide(tree,PDWDWICN);
   }

   exit_obj=do_dialog(tree,TPRTDEV,0,1,0);

   if(hide_window)
   {
      ob_unhide(tree,PDWINDOW);
      ob_unhide(tree,PDWDWICN);
   }

   if(exit_obj!=PDCANCEL)
   {
      if(ob_selected(tree,PDWINDOW))
         return(DEV_WINDOW);
      if(ob_selected(tree,PDPRINT))
         return(DEV_PRINTER);
      if(ob_selected(tree,PDDISK))
         return(DEV_DISK);
   }
   else
      return(-1);
}

do_header(rpt_index,header1,header2,und_score)
int  rpt_index;
char *header1,*header2,*und_score;
{
   int  i,j,k;
   static char temp[MAX_CLMS+1],temp3[MAX_CLMS+1],
               und1_temp[MAX_CLMS+1],und2_temp[MAX_CLMS+1];

   for(i=0; i<2; i++)
   {
      strcpy(temp,"\0"); strcpy(temp3,"\0");

      for(j=0; j<9; j++)
      {
         if(report[rpt_index].cinfo[i][j]==CR_BLANK)
         {
            if(report[rpt_index].clength[i][j]>0)
            {
               strcat(temp,replicate(' ',report[rpt_index].clength[i][j]));
               strcat(temp,replicate(' ',report[rpt_index].cspacing[i]));

               strcat(temp3,replicate('-',report[rpt_index].clength[i][j]));
               strcat(temp3,replicate(' ',report[rpt_index].cspacing[i]));
            }
         }
         if(report[rpt_index].cinfo[i][j]==CR_DATE && report[rpt_index].cstyle!=DAILY)
            add_header(rpt_index,"DATE",i,j,temp,temp3);
         if(report[rpt_index].cinfo[i][j]==CR_TIME)
            add_header(rpt_index,"TIME",i,j,temp,temp3);
         if(report[rpt_index].cinfo[i][j]==CR_DAY_OF_WEEK &&
            report[rpt_index].cstyle!=DAILY)
         {
            if(report[rpt_index].clength[i][j]>=11)
               add_header(rpt_index,"DAY OF WEEK",i,j,temp,temp3);
            else if(report[rpt_index].clength[i][j]>=3)
               add_header(rpt_index,"DOW",i,j,temp,temp3);
            else
               add_header(rpt_index,"DW",i,j,temp,temp3);
         }
         if(report[rpt_index].cinfo[i][j]==CR_SUBJECT)
            add_header(rpt_index,"SUBJECT",i,j,temp,temp3);
         if(report[rpt_index].cinfo[i][j]==CR_DESCRIPTION)
            add_header(rpt_index,"EVENT DESCRIPTION",i,j,temp,temp3);
         if(report[rpt_index].cinfo[i][j]==CR_LONG_TO_EVENT ||
            report[rpt_index].cinfo[i][j]==CR_MED_TO_EVENT)
         {
            if(report[rpt_index].clength[i][j]>=13)
               add_header(rpt_index,"TIME TO EVENT",i,j,temp,temp3);
            else if(report[rpt_index].clength[i][j]>=9)
               add_header(rpt_index,"TIME LEFT",i,j,temp,temp3);
            else
               add_header(rpt_index,"LEFT",i,j,temp,temp3);
         }
         if(report[rpt_index].cinfo[i][j]==CR_SHORT_TO_EVENT)
            add_header(rpt_index,"DAYS",i,j,temp,temp3);
         for(k=0; k<NUM_XFIELDS; k++)
            if(report[rpt_index].cinfo[i][j]==CR_XFIELD1+k)
               add_header(rpt_index,data_entry.dxflabel[k],i,j,temp,temp3);
      }
      if(i==0)
      {
         strcpy(header1,temp);
         strcpy(und1_temp,temp3);
      }
      else
      {
         strcpy(header2,temp);
         strcpy(und2_temp,temp3);
      }
   }

   if(strlen(und1_temp)>strlen(und2_temp))
      strcpy(und_score,und1_temp);
   else
      strcpy(und_score,und2_temp);
}

add_header(rpt_index,title,i,j,header,und_score)
char *title,*header,*und_score;
int  rpt_index,i,j;
{
   char temp[MAX_CLMS+1],temp2[20];

   strcpy(temp2,title);
   strcpy(temp,replicate(' ',(report[rpt_index].clength[i][j]-strlen(temp2))/2));
   strcat(temp,temp2);
   if(report[rpt_index].clength[i][j]>strlen(temp))
      strcat(temp,replicate(' ',report[rpt_index].clength[i][j]-strlen(temp)));
   else
      strcpy(temp,left(temp,report[rpt_index].clength[i][j]));
   strcat(header,temp);
   strcat(header,replicate(' ',report[rpt_index].cspacing[i]));

   strcat(und_score,replicate('-',report[rpt_index].clength[i][j]));
   strcat(und_score,replicate(' ',report[rpt_index].cspacing[i]));
}

do_disk()
{
   FILE *fopen();
   int  exit_obj,but;
   static char path[128],dir[128],name[20],spec[6];

   if(strlen(asc_name)>0 && form_alert(1,samedalrt)==1)
   {
      asc_file=fopen(asc_name,"r");
      if(!asc_file)
      {
         asc_file=fopen(asc_name,"w");
         if(!asc_file)
            return(FALSE);
      }
      else
      {
         fclose(asc_file);
         asc_file=fopen(asc_name,"a");
      }
   }
   else
   {
      form_alert(1,diskalrt);

      strcpy(spec,"*.");
      strcat(spec,prefs.opdisk_extension);

      get_path(dir,path,spec);
      fsel_input(path,name,&exit_obj);
      if(exit_obj!=0 && strlen(name)>0)
      {
         do_extension(name,prefs.opdisk_extension);
         path_to_name(path,name);
         strcpy(asc_name,path);
         asc_file=fopen(asc_name,"r");
         if(!asc_file)
         {
            asc_file=fopen(asc_name,"w");
            if(!asc_file)
               return(FALSE);
         }
         else
         {
            fclose(asc_file);

            but=form_alert(2,apalrt);
            if(but==2)
               asc_file=fopen(asc_name,"a");
            else
               asc_file=fopen(asc_name,"w");
         }
      }
      else
         return(FALSE);
   }

   return(TRUE);
}

