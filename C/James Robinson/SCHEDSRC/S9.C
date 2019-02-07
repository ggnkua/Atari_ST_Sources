/* S9.C -- PRINT DETAIL LINES OF REPORT */

#include "obdefs.h"
#include "stdio.h"
#include "osbind.h"
#include "gemdefs.h"
#include "schdefs.h"
#include "ctools.h"
#include "schedule.h"

extern int  vdi_handle,py,gl_hbox,rpt_index,rpt_free,line_number,day_spacing,
            tot_lines,cilines,cicounter,cixind,sel_tab[CAL_LINES],
            pages_this_rpt,rptcounter,cixdescr,skip_flag,cixshown,cishown,
            top_rec,*y_to_rec_no[9];

extern char sys_date[9],old_date[9],rpt_title[61],sys_time[6],
            rpt_edate[9],header1[MAX_CLMS+1],header2[MAX_CLMS+1],
            und_score[MAX_CLMS+1];

extern RECORD *rec;

extern WIND window[NUM_WINDS];

extern CUSTOM data_entry;

extern RPT report[NUM_REPORTS];

extern PAGE page_setup;

extern SELECTION select[NUM_SELECTIONS];

extern OBJECT *citree;

prt_detail(device,windex,record)
int  device,windex;
int  record;
{
   char date[9],**tedptr,detail[MAX_CLMS+1],detail2[MAX_CLMS+1],
        xtemp[3][MAX_CLMS+1],temp[MAX_CLMS+1],num_temp[20],
        st_temp[6],et_temp[6];
   register int j,k,l;
   int  filler[9],totcol,idx,max_detail,hours,mins,tte_flag;
   long days;

   for(j=0; j<9; j++)
      filler[j]=(-1);

   strcpy(date,rec[record].rdate);

   if(windex>(-1))
      idx=window[windex].wcontents-WC_REPORT;
   else
      idx=rpt_index;

   if(report[idx].cstyle==DAILY && windex!=(-2))
   {
      if(strcmp(rec[record].rdate,old_date)!=0)
      {   
         if(windex==(-1) && rpt_free==TRUE)
         {
            if(strlen(old_date)>0)
            {
               newline(device,report[idx].cmin_spacing_per_day-day_spacing);
               do_free_days(device,old_date,rec[record].rdate);
            }
         }

         if(skip_flag)
         {
            if(device==DEV_PRINTER || device==DEV_DISK)
            {
               if(report[idx].cmin_spacing_per_day-day_spacing>0)
                  newline(device,report[idx].cmin_spacing_per_day-day_spacing);
               else
                  newline(device,1);
               day_spacing=0;
            }
            if(device==DEV_COUNT_LINES && windex==(-1))
            {
               if(report[idx].cmin_spacing_per_day-day_spacing>0)
                  newline(device,report[idx].cmin_spacing_per_day-day_spacing);
               else
                  newline(device,1);
               day_spacing=0;
            }
            if(device==DEV_COUNT_LINES && windex>(-1))
               window[windex].wxdescr++;
            if(device==DEV_WINDOW)
               py+=gl_hbox-2;
            if(device==DEV_SHOWN)
            {
               select[rptcounter].srec_no=(-1);
               rptcounter++;
               py+=gl_hbox-2;
            }
         }

         if(device!=DEV_COUNT_LINES && device!=DEV_SHOWN)
         {
            strcpy(detail2,wday_str(rec[record].rdate));
            if(wday(rec[record].rdate)>0)
               strcat(detail2,", ");
            strcat(detail2,month_str(rec[record].rdate));
               strcat(detail2," ");
            if(strcmp(mid(rec[record].rdate,7,1),"0")!=0)
               strcat(detail2,right(rec[record].rdate,2));
            else
               strcat(detail2,right(rec[record].rdate,1));
            num_suffix(detail2);
            strcat(detail2,", ");
            strcat(detail2,left(rec[record].rdate,4));
            if(device==DEV_WINDOW)
            {
               if((skip_flag && strcmp(rec[record].rdate,old_date)!=0) ||
                  (!skip_flag && strcmp(rec[record].rdate,rec[record-1].rdate)!=0) ||
                  (!skip_flag && record==top_rec))
               {
                  vst_effects(vdi_handle,BOLD);
                  totcol=(window[windex].work_area.g_w-2)/8;
                  if(window[windex].wxindex+1<strlen(detail2))
                     wind_text(windex,mid(detail2,window[windex].wxindex+1,totcol));
                  else
                     py+=gl_hbox-2;
                  vst_effects(vdi_handle,NORMAL);
               }
            }
            else if(device==DEV_PRINTER || device==DEV_DISK)
            {
               dprint(device,detail2);
               newline(device,1);
               day_spacing++;
            }
         }
         else
         {
            if(device==DEV_COUNT_LINES && windex>(-1))
               window[windex].wxdescr++;
            else if(device==DEV_COUNT_LINES && windex==(-1))
            {
               newline(device,1);
               day_spacing++;
            }
            else if(device==DEV_SHOWN)
            {
               if((skip_flag && strcmp(rec[record].rdate,old_date)!=0) ||
                  (!skip_flag && strcmp(rec[record].rdate,rec[record-1].rdate)!=0) ||
                  (!skip_flag && record==top_rec))
               {
                  select[rptcounter].srec_no=(-1);
                  rptcounter++;
                  py+=gl_hbox-2;
               }
            }
         }
      }
   }

   if(windex==(-2))
      max_detail=1;
   else
      max_detail=2;

   for(l=0; l<max_detail; l++)
   {
      if(device!=DEV_COUNT_LINES && device!=DEV_SHOWN)
      {
         strcpy(detail,"\0");
         for(k=0; k<9; k++)
         {
            if(report[idx].cinfo[l][k]==CR_BLANK)
            {
               if(report[idx].clength[l][k]>0)
               {
                  strcpy(detail2,replicate(' ',report[idx].clength[l][k]));
                  strcat(detail,replicate(' ',report[idx].cspacing[l]));
                  strcat(detail,detail2);
               }
            }
            else if(report[idx].cinfo[l][k]==CR_DATE && report[idx].cstyle!=DAILY)
            {
               if(strcmp(mid(date,5,1),"0")==0)
                  strcpy(detail2,mid(date,6,1));
               else
                  strcpy(detail2,mid(date,5,2));
               strcat(detail2,"/");
               if(strcmp(mid(date,7,1),"0")==0)
                  strcat(detail2,right(date,1));
               else
                  strcat(detail2,right(date,2));

               if(report[idx].clength[l][k]>7)
               {
                  strcat(detail2,"/");
                  if(report[idx].clength[l][k]>=8 && report[idx].clength[l][k]<10)
                     strcat(detail2,mid(date,3,2));
                  else if(report[idx].clength[l][k]>=10)
                     strcat(detail2,left(date,4));
               }
               hndl_alignment(detail,detail2,idx,l,k);
            }
            else if(report[idx].cinfo[l][k]==CR_TIME)
            {
               strcpy(detail2,"\0");

               if(data_entry.dstime==TRUE)
               {
                  if(strlen(rec[record].rstime) == 5)
                  {
                     if(strcmp(mid(rec[record].rstime,2,2),"00")==0)
                        strcat(detail2,"12");
                     else if(strcmp(mid(rec[record].rstime,2,1),"0")==0)
                     {
                        strcat(detail2," ");
                        strcat(detail2,mid(rec[record].rstime,3,1));
                     }
                     else
                        strcat(detail2,mid(rec[record].rstime,2,2));
                     strcat(detail2,":");
                     strcat(detail2,right(rec[record].rstime,2));
                     strcat(detail2," ");
                     strcat(detail2,left(rec[record].rstime,1));
                     strcat(detail2,"m");
                  }
                  else
                     if(data_entry.dstime==TRUE)
                        strcat(detail2,"        ");
               }

               if(data_entry.detime==TRUE)
               {               
                  if(strlen(rec[record].retime) == 5 && report[idx].clength[l][k]>8)
                  {
                     strcat(detail2," - ");
                     if(strcmp(mid(rec[record].retime,2,2),"00")==0)
                        strcat(detail2,"12");
                     else if(strcmp(mid(rec[record].retime,2,1),"0")==0)
                     {
                        strcat(detail2," ");
                        strcat(detail2,mid(rec[record].retime,3,1));
                     }
                     else
                        strcat(detail2,mid(rec[record].retime,2,2));
                     strcat(detail2,":");
                     strcat(detail2,right(rec[record].retime,2));
                     strcat(detail2," ");
                     strcat(detail2,left(rec[record].retime,1));
                     strcat(detail2,"m");
                  }
                  else
                     if(data_entry.detime==TRUE)
                        strcat(detail2,"        ");
               }

               hndl_alignment(detail,detail2,idx,l,k);
            }
            else if(report[idx].cinfo[l][k]==CR_DAY_OF_WEEK &&
                    report[idx].cstyle!=DAILY)
            {
               strcpy(detail2,left(wday_str(date),9));
               hndl_alignment(detail,detail2,idx,l,k);
            }
            else if(report[idx].cinfo[l][k]==CR_SUBJECT)
            {
               if(data_entry.dsubj==TRUE)
               {
                  strcpy(detail2,rec[record].rsubj);
                  hndl_alignment(detail,detail2,idx,l,k);
               }
            }
            else if(report[idx].cinfo[l][k]==CR_DESCRIPTION)
            {
               if(k==0 || report[idx].cinfo[l][k-1]==CR_DESCRIPTION)
                  filler[k]=strlen(detail);
               else
                  filler[k]=strlen(detail)-filler[k-1]-1;

               strcpy(detail2,rec[record].rdescr[0]);
               hndl_alignment(detail,detail2,idx,l,k);
            }
            else if(report[idx].cinfo[l][k]==CR_SHORT_TO_EVENT ||
                    report[idx].cinfo[l][k]==CR_MED_TO_EVENT ||
                    report[idx].cinfo[l][k]==CR_LONG_TO_EVENT)
            {
               if(data_entry.dstime)
                  strcpy(st_temp,rec[record].rstime);
               else
                  strcpy(st_temp,"\0");

               if(data_entry.detime)
                  strcpy(et_temp,rec[record].retime);
               else
                  strcpy(et_temp,"\0");

               tte_flag=FALSE;

               if(strcmp(sys_date,rec[record].rdate)>0 ||
                 (strcmp(sys_date,rec[record].rdate)==0 &&
                  strcmp(sys_time,st_temp)>0) &&
                  strlen(st_temp)>0 &&
                  report[idx].cinfo[l][k]!=CR_SHORT_TO_EVENT)
               {
                  strcpy(temp,"past");
                  tte_flag=TRUE;
               }
              
               if(report[idx].cinfo[l][k]!=CR_SHORT_TO_EVENT)
               {
                  if(strcmp(sys_date,rec[record].rdate)==0 &&
                     strcmp(sys_time,st_temp)==0)
                  {
                     strcpy(temp,"NOW");
                     tte_flag=TRUE;
                  }

                  if(data_entry.detime)
                  {
                     if(strcmp(sys_date,rec[record].rdate)==0 &&
                        strcmp(sys_time,st_temp)>=0 &&
                        strcmp(sys_time,et_temp)<=0)
                     {
                        strcpy(temp,"NOW");
                        tte_flag=TRUE;
                     }
                  }
               } 
               
               if(!tte_flag)
               {
                  days=calc_bd(sys_date,rec[record].rdate);

                  strcpy(temp,"\0");

                  if(report[idx].cinfo[l][k]==CR_MED_TO_EVENT ||
                     report[idx].cinfo[l][k]==CR_LONG_TO_EVENT)
                  {
                     if(data_entry.dstime && strlen(rec[record].rstime)>0)
                     {
                        hours=hours_between(sys_time,rec[record].rstime);
                        mins=mins_between(sys_time,rec[record].rstime);
                        if(hours<0)
                        {
                           hours+=24;
                           days--;
                        }
                        if(mins<0)
                        {
                           mins+=60;
                           hours--;
                        }
                        if(hours<0)
                        {
                           hours=23;
                           days--;
                        }
                     }
                     else
                     {
                        hours=mins=0;
                     }

                     if(days>0)
                     {
                        ltoa(days,temp);

                        if(report[idx].cinfo[l][k]==CR_LONG_TO_EVENT)
                        {
                           if(days==1)
                              strcat(temp," day");
                           else
                              strcat(temp," days");
                        }
                     }
                     if(data_entry.dstime && strlen(rec[record].rstime)>0)
                     {
                        if(hours>0 || (days>0 &&
                           report[idx].cinfo[l][k]==CR_MED_TO_EVENT))
                        {
                           itoa(hours,num_temp);
                           if(report[idx].cinfo[l][k]==CR_LONG_TO_EVENT)
                           {
                              if(days>0)
                                 strcat(temp," ");
                              strcat(temp,num_temp);
                              if(hours==1)
                                 strcat(temp," hr");
                              else
                                 strcat(temp," hrs");
                           }
                           else
                           {
                              if(days>0)
                              {
                                 strcat(temp,",");
                                 strcpy(num_temp,rjustify(num_temp,2));
                                 chg_chr(num_temp,' ','0');
                              }
                              strcat(temp,num_temp);
                           }
                        }
                        itoa(mins,num_temp);
                        if(report[idx].cinfo[l][k]==CR_LONG_TO_EVENT)
                        {
                           strcat(temp," ");
                           strcat(temp,num_temp);
                           if(mins==1)
                              strcat(temp," min");
                           else
                              strcat(temp," mins");
                        }
                        else
                        {
                           if(days>0 || hours>0)
                           {
                              strcat(temp,":");
                              strcpy(num_temp,rjustify(num_temp,2));
                              chg_chr(num_temp,' ','0');
                           }
                           strcat(temp,num_temp);
                        }
                     }
                     else
                     {
                        if(report[idx].cinfo[l][k]==CR_MED_TO_EVENT)
                        {
                           if(days>0)
                              strcat(temp,",--:--");
                           else
                              strcat(temp,"today");
                        }
                        else if(report[idx].cinfo[l][k]==CR_LONG_TO_EVENT)
                        {
                           if(days==0)
                              strcat(temp,"today");
                        }
                     }
                  }
                  else
                     ltoa(days,temp);

                  if(strlen(temp)>report[idx].clength[l][k])
                     strcpy(temp,replicate('*',report[idx].clength[l][k]));
               }
               ltrim(temp);
               hndl_alignment(detail,temp,idx,l,k);
            }
            else
            {
               for(j=0; j<data_entry.dxfields; j++)
               {
                  if(report[idx].cinfo[l][k]==CR_XFIELD1+j)
                  {
                     strcpy(detail2,rec[record].rxfield[j]);
                     hndl_alignment(detail,detail2,idx,l,k);
                  }
               }
            }
         }
         if(strlen(detail)>0)
         {
            if(windex<=(-1))
               rtrim(detail);

            if(device==DEV_WINDOW)
            {
               totcol=(window[windex].work_area.g_w-2)/8;
               wind_text(windex,mid(detail,window[windex].wxindex+1,totcol));
            }
            if(device==DEV_PRINTER || device==DEV_DISK)
               dprint(device,detail);
            if(device==DEV_CINFO_WINDOW)
            {
               tedptr=(char *)citree[CIDESCR1+cicounter].ob_spec;
               strcpy(*tedptr,mid(detail,cixind+1,70));
               strcat(*tedptr,replicate(' ',70-strlen(*tedptr)));
               del_state(citree,CIDESCR1+cicounter,DISABLED);
               sel_tab[cicounter]=record;
               cicounter++;
            }
            if(device==DEV_PRINTER || device==DEV_DISK)
            {
               newline(device,1);
               day_spacing++;
            }
         }
      }
      else
      {
         if(device==DEV_SHOWN)
         {
            if(windex>(-1))
            {
               if(l==0 && strlen(window[windex].w1header)>0)
               {
                  py+=gl_hbox-2;
                  window[windex].wshown++;
                  select[rptcounter].srec_no=record;
                  rptcounter++;
               }
               if(l==1 && strlen(window[windex].w2header)>0)
               {
                  py+=gl_hbox-2;
                  select[rptcounter].srec_no=record;
                  select[rptcounter].scommon=TRUE;
                  rptcounter++;
               }
            }
            else if(windex==(-2))
            {
               cicounter++;
               cishown++;
            }
         }
         else
         {
            if(windex>(-1))
            {
               if(l==0 && strlen(window[windex].w1header)>0)
               {
                  y_to_rec_no[windex][window[windex].wlines]=record;
                  window[windex].wlines++;
               }
            }
            if(windex==(-1))
            {
               if(l==0 && strlen(header1)>0)
               {
                  newline(device,1);
                  day_spacing++;
               }
               if(l==1 && strlen(header2)>0)
               {
                  newline(device,1);
                  day_spacing++;
               }
            }
            if(windex==(-2))
            {
               y_to_rec_no[8][cilines]=record;
               cilines++;
            }
         }
      }

      if(device==DEV_COUNT_LINES || device==DEV_SHOWN)
      {
         for(k=0; k<9; k++)
         {
            if(report[idx].cinfo[l][k]==CR_DESCRIPTION)
            {
               if(k==0 || report[idx].cinfo[l][k-1]==CR_DESCRIPTION)
                  filler[k]=strlen(detail);
               else
                  filler[k]=strlen(detail)-filler[k-1]-1;
            }
         }
      }

      for(j=0; j<data_entry.ddescr_lines-1; j++)
      {
         strcpy(xtemp[j],"\0");
         if(strlen(rec[record].rdescr[j+1])>0)
         {
            for(k=0; k<9; k++)
            {
               if(filler[k]>(-1))
               {
                  strcat(xtemp[j],replicate(' ',filler[k]-strlen(xtemp[j])));
                  strcpy(temp,rec[record].rdescr[j+1]);
                  hndl_alignment(xtemp[j],temp,idx,l,k);
                  rtrim(xtemp[j]);
               }
            }

            if(strlen(xtemp[j])>0)
            {
               if(device==DEV_COUNT_LINES && windex>(-1))
                  window[windex].wxdescr++;

               if(device==DEV_SHOWN && windex>(-1))
               {
                  py+=gl_hbox-2;
                  select[rptcounter].srec_no=record;
                  select[rptcounter].scommon=TRUE;
                  rptcounter++;
               }

               if(device==DEV_SHOWN && windex==(-2))
               {
                  cicounter++;
                  if(cicounter<CAL_LINES)
                     cixshown++;
               }

               if(device==DEV_WINDOW)
               {
                  totcol=(window[windex].work_area.g_w-2)/8;
                  wind_text(windex,mid(xtemp[j],window[windex].wxindex+1,totcol));
               }
               else if(device==DEV_PRINTER || device==DEV_DISK)
               {
                  dprint(device,xtemp[j]);
                  newline(device,1);
                  day_spacing++;
               }
               else if(device==DEV_CINFO_WINDOW && cicounter<CAL_LINES)
               {
                  tedptr=(char *)citree[CIDESCR1+cicounter].ob_spec;
                  if(cixind<strlen(xtemp[j]))
                     strcpy(*tedptr,mid(xtemp[j],cixind+1,70));
                  else
                     strcpy(*tedptr,"\0");
                  strcat(*tedptr,replicate(' ',70-strlen(*tedptr)));
                  del_state(citree,CIDESCR1+cicounter,DISABLED);
                  sel_tab[cicounter]=(-2);
                  cicounter++;
               }
               else if(device==DEV_COUNT_LINES && windex==(-1))
               {
                  newline(device,1);
                  day_spacing++;
               }
               else if(device==DEV_COUNT_LINES && windex==(-2))
                  cixdescr++;
            }
         }
      }
   }
                    
   if(device==DEV_SHOWN && windex==(-2))
      if(cicounter>CAL_LINES)
         cishown--;

   if(device==DEV_SHOWN && windex>(-1))
      if(py>window[windex].work_area.g_h)
         window[windex].wshown--;

   strcpy(old_date,rec[record].rdate);

   skip_flag=TRUE;
}

hndl_alignment(dest,source,idx,l,k)
char *dest,*source;
int  idx,l,k;
{
   char temp[MAX_CLMS+1];

   if(report[idx].calign_fld[l][k]==LEFT)
   {
      if(report[idx].clength[l][k] > strlen(source))
         strcat(source,replicate(' ',report[idx].clength[l][k]-strlen(source)));
      else
         strcpy(source,left(source,report[idx].clength[l][k]));
   }
   if(report[idx].calign_fld[l][k]==CENTER)
   {
      if(report[idx].clength[l][k] > strlen(source))
      {
         strcpy(temp,replicate(' ',(report[idx].clength[l][k]-strlen(source))/2));
         strcat(temp,source);
         strcat(temp,replicate(' ',report[idx].clength[l][k]-strlen(temp)));
         strcpy(source,temp);
      }
      else
         strcpy(source,left(source,report[idx].clength[l][k]));
   }
   if(report[idx].calign_fld[l][k]==RIGHT)
   {
      if(report[idx].clength[l][k] > strlen(source))
      {
         strcpy(temp,replicate(' ',report[idx].clength[l][k]-strlen(source)));
         strcat(temp,source);
         strcpy(source,temp);
      }
      else
         strcpy(source,left(source,report[idx].clength[l][k]));
   }
   strcat(dest,source);
   strcat(dest,replicate(' ',report[idx].cspacing[l]));
}

do_free_days(device,old_date,new_date)
int  device;
char *old_date,*new_date;
{
   char res_date[9],detail[80];
   int  j,dummy,mx,my,obj,which;
   long diff,diff2;
   OBJECT *tree;

   if(strlen(old_date)==0 || strlen(new_date)==0)
      return;

   if(strcmp(old_date,new_date)==0)
      return;

   diff=calc_bd(old_date,new_date);

   if(diff>1)
   {
      if(device==DEV_PRINTER || device==DEV_DISK)
         newline(device,1);
      else if(device==DEV_COUNT_LINES)
         newline(device,1);
   }

   for(j=1; j<diff; j++)
   {
      if(device==DEV_PRINTER && page_setup.plast_page<pages_this_rpt+1)
         return;

      which=evnt_multi(MU_TIMER|MU_BUTTON,1,0x01,1,0,
                       0,0,0,0,0,0,0,0,0,&dummy,
                       0,0,&mx,&my,&dummy,&dummy,&dummy,&dummy);

      if(which & MU_BUTTON)
      {
         rsrc_gaddr(0,TPRINT,&tree);
         obj=objc_find(tree,0,8,mx,my);
         if(obj==PCANCEL)
         {
             objc_change(tree,PCANCEL,0,0,0,0,0,SELECTED,1);
             return;
         }
      }

      strcpy(res_date,fd_forward(old_date,j));

      strcpy(detail,"\0");
      cat_date(detail,res_date);

      if(device!=DEV_COUNT_LINES)
         dprint(device,detail);

      newline(device,report[rpt_index].cmin_spacing_per_day);

      skip_flag=TRUE;

      diff2=calc_bd(res_date,new_date);

      if(diff2>1)
         newline(device,1);

      day_spacing=report[rpt_index].cmin_spacing_per_day-1;
   }
}


   
