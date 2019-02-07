/* S24.C -- RECORD, MISC FUNCTIONS */

#include "stdio.h"
#include "obdefs.h"
#include "osbind.h"
#include "gemdefs.h"
#include "ctools.h"
#include "schdefs.h"
#include "schedule.h"

extern int rpt_index,rec_modified,dummy,descr_idx[4],rec_no,max_recs,
           xfed_tab[2][5],xfpar_tab[2][5],rpt_decision[9],device,
           line_number,page_number,tot_lines,rpt_free,pages_this_rpt,
           disk_full,cal_idx,trans_fhandle,move_flag,cur_file,total,
           cur_modified,inc_page,rm_decision[9],beg_flag,end_flag,
           line_this_rpt,add_on_flag,rez;

extern char timealrt[],notalrt[],tranalrt[],movealrt[],curalrt[],rec_file[129],
            memalrt[],drecalrt[],sys_date[9],sdatealrt[],chgrptalrt[],
            nowdwalrt[],freealrt[],header1[MAX_CLMS+1],header2[MAX_CLMS+1],
            und_score[MAX_CLMS+1],addonalrt[],dfullalrt[],pausalrt[],
            schwdwalrt[],rm_stime[6],rm_etime[6],rm_subj[41],
            rm_xfield[NUM_XFIELDS][41],rm_descr[41];

extern LAST_USED last;

extern SELECTION select[NUM_SELECTIONS];

extern RPT report[NUM_REPORTS];

extern CUSTOM data_entry;

extern WIND window[NUM_WINDS];

extern PAGE page_setup;

extern RECORD *rec;

extern long menu_tree;

extern OBJECT *citree;

extern CUSTOM trans_data;

extern FILE *asc_file;

static int old_decision[9];

modify_records(which)
int which;
{
   OBJECT *tree;
   char **tedptr,sdate[9],edate[9],stime[6],etime[6],subj[21],
        descr[41],xfield[NUM_XFIELDS][41],alrt_str[129],num[10];
   int exit_obj,err_obj,valid,sel_flag,rec_found=FALSE,whand,windex,
        sys_sdate,sys_edate,ret,old_line_number,loop;
   register int i,j,l;

   wind_update(1);

   if(which==WDWEDIT || which==WDWEDALL)
   {
      wind_get(0,WF_TOP,&whand,&dummy,&dummy,&dummy);

      if(whand==0)
      {
         form_alert(1,nowdwalrt);
         wind_update(0);
         return;
      }
   }

   if(which==WDWEDALL)
      loop=NUM_WINDS;
   else
      loop=1;

   hide_windows();

   for(l=0; l<loop; l++)
   {
      if(which==CALOPEN)
         windex=cal_idx;
      else if(which==WDWEDIT || which==WDWEDALL)
      {
         if(which==WDWEDIT)
         {
            windex=set_windex(whand);

            if(windex==(-1))
            {
               form_alert(1,schwdwalrt);
               show_windows();
               wind_update(0);
               return;
            }
         }   
         else if(which==WDWEDALL)
         {
            if(window[l].wopen==TRUE)
               windex=l;
            else
            {
               while(window[l].wopen!=TRUE && l<NUM_WINDS)
                  l++;
               if(l==NUM_WINDS)
               {
                  count_all_lines();
                  show_windows();
                  res_decisions(tree);
                  wind_update(0);
                  return;
               }
               else
                  windex=l;
            }
         }
  
         for(i=0; i<9; i++)
            old_decision[i]=rpt_decision[i];
      }

      total=0; move_flag=sel_flag=cur_file=beg_flag=end_flag=cur_modified=FALSE;

      for(i=0; i<NUM_SELECTIONS; i++)
      {
         if(select[i].sselected==TRUE)
         {
            sel_flag=TRUE;
            break;
         }
      }

      if(sel_flag==TRUE && which!=WDWEDIT && which!=WDWEDALL && which!=RPTPRINT)
      {
         if(which==RECEDIT)
            sel_edit();
         else if(which==RECDELET)
            sel_delete();
         else if(which==RECTRANS)
         {
            if(!sel_transfer())
            {
               show_windows();
               wind_update(0);
               return;
            }
         }
      }
      else
      {
         rsrc_gaddr(0,TPRTREPT,&tree);
         clear_form(tree);
         clr_msgs(tree,TPRTREPT);

         tedptr=(char *)tree[PRTITLE2].ob_spec;
         if(which==RECEDIT)
            strcpy(*tedptr,"      E D I T   R E C O R D S      ");
         else if(which==RECDELET)
            strcpy(*tedptr,"    D E L E T E   R E C O R D S    ");
         else if(which==RECTRANS)
            strcpy(*tedptr,"  T R A N S F E R   R E C O O R S  ");
         else if(which==WDWEDIT || which==WDWEDALL || which==CALOPEN)
         {
            if(window[windex].wcontents==WC_CALENDAR)
               strcpy(*tedptr,"C A L E N D A R   D E C I S I O N S");
            else
               strcpy(*tedptr,"  R E P O R T   D E C I S I O N S  ");
         }
         else if(which==RPTPRINT)
            strcpy(*tedptr,"      P R I N T   R E P O R T      ");
     
         if(which==WDWEDIT || which==WDWEDALL)
            put_wdw_info(tree,windex);

         err_obj=0; valid=FALSE;

         while(!valid)
         {
            if((which==CALOPEN || which==WDWEDIT || which==WDWEDALL) &&
               window[windex].wcontents==WC_CALENDAR)
            {
               ret=edit_calendar_info(windex);

               if(which==CALOPEN && ret==FALSE)
               {
                  show_windows();
                  res_decisions(tree);
                  wind_update(0);
                  return(FALSE);
               }

               ob_hide(tree,PSDLABEL);
               ob_hide(tree,PEDLABEL);
               ob_hide(tree,PRSDATE);
               ob_hide(tree,PREDATE);
               ob_hide(tree,PRSDMSG);
               ob_hide(tree,PREDMSG);

               tree[PSTPAR].ob_y-=(16*rez);
               tree[PETPAR].ob_y-=(16*rez);
               tree[PSUBJPAR].ob_y-=(16*rez);
               for(j=0; j<data_entry.dxfields; j++)
                 tree[xfpar_tab[1][j]].ob_y-=(16*rez);
               tree[PRBUTPAR].ob_y-=(16*rez);
               tree[PRDETREE].ob_y-=(16*rez);
               tree[PRDECBOX].ob_y-=(16*rez);
               tree[PRDECLAB].ob_y-=(16*rez);
               tree[0].ob_height-=(16*rez);
            }

            exit_obj=do_dialog(tree,TPRTREPT,err_obj,0,1);

            if((which==WDWEDIT || which==WDWEDALL || which==CALOPEN) &&
               window[windex].wcontents==WC_CALENDAR)
            {
               ob_unhide(tree,PSDLABEL);
               ob_unhide(tree,PEDLABEL);
               ob_unhide(tree,PRSDATE);
               ob_unhide(tree,PREDATE);
               ob_unhide(tree,PRSDMSG);
               ob_unhide(tree,PREDMSG);

               tree[PSTPAR].ob_y+=(16*rez);
               tree[PETPAR].ob_y+=(16*rez);
               tree[PSUBJPAR].ob_y+=(16*rez);
               for(j=0; j<data_entry.dxfields; j++)
                 tree[xfpar_tab[1][j]].ob_y+=(16*rez);
               tree[PRBUTPAR].ob_y+=(16*rez);
               tree[PRDETREE].ob_y+=(16*rez);
               tree[PRDECBOX].ob_y+=(16*rez);
               tree[PRDECLAB].ob_y+=(16*rez);
               tree[0].ob_height+=(16*rez);
            }

            if(exit_obj!=PRCANCEL)
            {
               valid=TRUE;

               tedptr=(char *)tree[PRSDATE].ob_spec;
               if(validate_date(*tedptr,TPRTREPT))
                  get_date(*tedptr,sdate,last.lsdate);
               else
               {
                  if(strlen(*tedptr)==0)
                  {
                     strcpy(sdate,"00000101");
                     beg_flag=TRUE;
                  }
                  else
                  {
                     valid=FALSE;
                     date_error_alert(*tedptr);
                     err_obj=PRSDATE;
                     continue;
                  }
               }

               tedptr=(char *)tree[PREDATE].ob_spec;
               if(validate_date(*tedptr,TPRTREPT))
                  get_date(*tedptr,edate,last.ledate);
               else
               {
                  if(strlen(*tedptr)==0)
                  {
                     strcpy(edate,"99991231");
                     end_flag=TRUE;
                  }
                  else
                  {
                     valid=FALSE;
                     date_error_alert(*tedptr);
                     err_obj=PREDATE;
                     continue;
                  }
               }
       
               if(strcmp(sdate,edate)>0)
               {
                  valid=FALSE;
                  form_alert(1,sdatealrt);
                  continue;
               }
    
               tedptr=(char *)tree[PRSTIME].ob_spec;
               if(time_valid(*tedptr))
                  get_time(*tedptr,stime,last.lstime);
               else
               {
                  valid=FALSE;
                  form_alert(1,timealrt);
                  err_obj=PRSTIME;
                  continue;
               }
         
               tedptr=(char *)tree[PRETIME].ob_spec;
               if(time_valid(*tedptr))
                  get_time(*tedptr,etime,last.letime);
               else
               {
                  valid=FALSE;
                  form_alert(1,timealrt);
                  err_obj=PRETIME;
                  continue;
               }
          
               tedptr=(char *)tree[PSUBJED].ob_spec;
               strcpy(subj,*tedptr);
               if(strlen(*tedptr)>0)
                  strcpy(last.lsubj,*tedptr);
            
               for(i=0; i<NUM_XFIELDS; i++)
               {
                  tedptr=(char *)tree[xfed_tab[1][i]].ob_spec;
                  strcpy(xfield[i],*tedptr);
                  if(strlen(*tedptr)>0)
                     strcpy(last.lxfield[i],*tedptr);
               }
              
               tedptr=(char *)tree[PRDESCR].ob_spec;
               strcpy(descr,*tedptr);
               if(strlen(*tedptr)>0)
                  strcpy(last.ldescr,*tedptr);

               if(which==WDWEDIT || which==WDWEDALL || which==RPTPRINT)
               {
                  tedptr=(char *)tree[PRSDMSG].ob_spec;
                  if(strcmp(left(*tedptr,17),"(use system date)")==0)
                     sys_sdate=TRUE;
                  else
                     sys_sdate=FALSE;
      
                  tedptr=(char *)tree[PREDMSG].ob_spec;
                  if(strcmp(left(*tedptr,17),"(use system date)")==0)
                     sys_edate=TRUE;
                  else
                     sys_edate=FALSE;
               }

               if(which==WDWEDIT || which==WDWEDALL || which==CALOPEN)
               {
                  if(window[windex].wcontents>=WC_REPORT)
                  {
                     window[windex].wsys_sdate=sys_sdate;
                     window[windex].wsys_edate=sys_edate;
                     window[windex].wbeg_flag=beg_flag;
                     window[windex].wend_flag=end_flag;
                     strcpy(window[windex].wsdate,sdate);
                     strcpy(window[windex].wedate,edate);
                  }

                  strcpy(window[windex].wstime,stime);
                  strcpy(window[windex].wetime,etime);
                  strcpy(window[windex].wsubj,subj);
                  for(i=0; i<NUM_XFIELDS; i++)
                     strcpy(window[windex].wxfield[i],xfield[i]);
                  strcpy(window[windex].wdescr,descr);
     
                  for(i=0; i<9; i++)
                     window[windex].wdecision[i]=rpt_decision[i];

                  if(window[windex].wcontents>=WC_REPORT)
                  {
                     if(form_alert(2,chgrptalrt)==1)
                     {
                        rpt_index=sel_report();
                        if(rpt_index>(-1))
                        {
                           window[windex].wcontents=WC_REPORT+rpt_index;
                           upd_name(windex);
                        }
                     }

                     if(which!=WDWEDALL)
                     {
                        count_lines(windex);
                        show_windows();
                        res_decisions(tree);
                        wind_update(0);
                        return;
                     }
                  }
                  else
                  {
                     if(which!=WDWEDALL)
                     {
                        show_windows();
                        res_decisions(tree);
                        wind_update(0);
                        return(TRUE);
                     }
                  }
               }

               if(which==RECTRANS)
               {
                  if(!get_transfer_file())
                  {
                     show_windows();
                     wind_update(0);
                     return;
                  }
               }

               if(which==RPTPRINT)
               {
                  strcpy(rm_stime,stime);
                  strcpy(rm_etime,etime);
                  strcpy(rm_subj,subj);
                  for(i=0; i<NUM_XFIELDS; i++)
                     strcpy(rm_xfield[i],xfield[i]);
                  strcpy(rm_descr,descr);
                  for(i=0; i<9; i++)
                     rm_decision[i]=rpt_decision[i];

                  if(beg_flag==TRUE)
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
                  if(end_flag==TRUE)
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
              
                  rpt_index=sel_report();
        
                  if(rpt_index==(-1))
                  {
                     show_windows();
                     wind_update(0);
                     return;
                  }
        
                  device=sel_device(FALSE);
                  if(device==(-1))
                  {
                     show_windows();
                     wind_update(0);
                     return;
                  }
        
                  if(device==DEV_PRINTER || device==DEV_DISK)
                  {
                     if(report[rpt_index].cstyle==DAILY && strcmp(sdate,edate)!=0)
                     {
                        if(form_alert(2,freealrt)==1)
                           rpt_free=TRUE;
                        else
                           rpt_free=FALSE;
                     }
                     else
                        rpt_free=FALSE;
     
                     page_setup.pnew_report=TRUE;
      
                     if(device==DEV_PRINTER)
                     {
                        if(add_on_flag==FALSE || form_alert(2,addonalrt)==1)
                           page_setup.pnew_report=TRUE;
                        else
                        {
                           page_setup.pnew_report=FALSE;
                           page_setup.pfirst_page=1;
                           page_setup.plast_page=32767;
                        }
                     }
             
                     if(!do_page_setup(device))
                     {
                        show_windows();
                        wind_update(0);
                        return;
                     }

                     add_on_flag=TRUE;

                     old_line_number=line_number;

                     graf_mouse(HOURGLASS,&dummy);
         
                     do_header(rpt_index,header1,header2,und_score);
               
                     if(page_setup.pnew_report && device==DEV_PRINTER)
                        print_schedule(DEV_COUNT_LINES,-1,sdate,edate,stime,etime,subj,
                                       xfield[0],xfield[1],xfield[2],xfield[3],xfield[4],
                                       descr);
                     else
                        tot_lines=0;
  
                     graf_mouse(ARROW,&dummy);
    
                     line_number=old_line_number;

                     if(device==DEV_DISK)
                     {
                        if(!do_disk())
                        {
                           show_windows();
                           wind_update(0);
                           return;
                        }
                     }

                     if(page_setup.pnew_report && device==DEV_PRINTER &&
                        !do_range())
                     {
                        show_windows();
                        wind_update(0);
                        return;
                     }
     
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

                        if(page_setup.pcopies>i+1)
                           inc_page=FALSE;
                        else
                           inc_page=TRUE;
                      
                        pages_this_rpt=0; line_this_rpt;

                        if(device==DEV_PRINTER)
                           while(!prt_ready());

                        print_schedule(device,-1,sdate,edate,stime,etime,subj,
                                       xfield[0],xfield[1],xfield[2],xfield[3],xfield[4],
                                       descr);
                 
                        if(device==DEV_PRINTER && page_setup.peject_page)
                        {
                           if(line_number>0)
                           {
                              prt_char(DEV_PRINTER,12);
                              line_number=0;
                              if(inc_page)
                                 page_number++;
                           }
                        }

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
                 
                     if(device==DEV_DISK)
                        fclose(asc_file);
                  }
           
                  show_windows();

                  if(device==DEV_WINDOW)
                  {
                     graf_mouse(HOURGLASS,&dummy);
                     windex=create_window(WC_REPORT,0x0FEF,TRUE,0);
                     if(windex==(-1))
                     {
                        show_windows();
                        wind_update(0);
                        return;
                     }
                     strcpy(window[windex].wsdate,sdate);
                     strcpy(window[windex].wedate,edate);
                     strcpy(window[windex].wstime,stime);
                     strcpy(window[windex].wetime,etime);
                     strcpy(window[windex].wsubj,subj);
                     for(i=0; i<NUM_XFIELDS; i++)
                        strcpy(window[windex].wxfield[i],xfield[i]);
                     strcpy(window[windex].wdescr,descr);
                     window[windex].wbeg_flag=beg_flag;
                     window[windex].wend_flag=end_flag;
                     window[windex].wsys_sdate=sys_sdate;
                     window[windex].wsys_edate=sys_edate;
                     for(i=0; i<9; i++)
                        window[windex].wdecision[i]=rpt_decision[i];
         
                     print_schedule(DEV_COUNT_LINES,windex,sdate,edate,stime,etime,subj,
                                    xfield[0],xfield[1],xfield[2],xfield[3],xfield[4],
                                    descr);

                     upd_name(windex);

                     open_window(windex);

                     shown_count(windex);

                     set_sliders(window[windex].whandle,window[windex].wcontents);
     
                     graf_mouse(ARROW,&dummy);
                  }

                  wind_update(0);
                  return;
               } 

               if(which!=WDWEDALL)
               {
                  strcpy(rm_stime,stime);
                  strcpy(rm_etime,etime);
                  strcpy(rm_subj,subj);
                  for(i=0; i<NUM_XFIELDS; i++)
                     strcpy(rm_xfield[i],xfield[i]);
                  strcpy(rm_descr,descr);
                  for(i=0; i<9; i++)
                     rm_decision[i]=rpt_decision[i];

                  for(i=0; i<rec_no; i++)
                  {
                     if(strcmp(sdate,rec[i].rdate)<=0 &&
                        strcmp(edate,rec[i].rdate)>=0)
                     {
                        if(rec[i].rdeleted!=TRUE)
                        {     
                           if(rec_match(&rec[i]))
                           {    
                              rec_found=TRUE;
                          
                              if(which==RECEDIT)
                              {
                                 ret=edit_record(i,"\0");
                                 if(ret==EREXIT)
                                    break;
                                 else if(ret==ERDELETE)
                                    total++;
                              }
                              else if(which==RECDELET)
                              {
                                 rec[i].rdeleted=2; /* marked */
                                 total++;
                              }
                              else if(which==RECTRANS)
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
                                    copy_rec(&rec[rec_no+total],&rec[i]);
                                 }
                                 else
                                 {
                                    do_transfer(i);
                                    if(move_flag==TRUE)
                                    {
                                       clr_record(i);
                                       rec[i].rdeleted=TRUE;
                                       strcpy(rec[i].rdate,"99991231");
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
                        }
                     } 
                     if(strcmp(edate,rec[i].rdate)<0 && rec[i].rdeleted!=TRUE)
                        break;
                  }
               }
            }
            else
            {
               if(which!=WDWEDALL)
               {
                  res_decisions(tree);
                  show_windows();
                  wind_update(0);
                  return(FALSE);
               }
               else
                  valid=TRUE;
            }
         }
         if(which!=WDWEDALL && !rec_found)
            form_alert(1,notalrt);
      }    
   }

   if(which==WDWEDALL)
   {
      count_all_lines();
      res_decisions(tree);
      show_windows();
      wind_update(0);
      return;
   }

   if((which==RECDELET && rec_found==TRUE) || which==RECTRANS)
   {
      itoa(total,num);
      if(which==RECDELET)
         strcpy(num,rjustify(num,5));
      strcpy(alrt_str,"[0][ | ");
      strcat(alrt_str,num);
      strcat(alrt_str," ");
      if(total==1)
         strcat(alrt_str,"record ");
      else
         strcat(alrt_str,"records ");
      if(which==RECDELET)
         strcat(alrt_str,"ready to | be deleted.  Are you | sure you want to delete | these records? | ]");
      else
         strcat(alrt_str,"transferred. | | ]");
      if(which==RECTRANS)
         strcat(alrt_str,"[ OK ]");
      else if(which==RECDELET)
         strcat(alrt_str,"[ YES | NO ]");
      if(which==RECTRANS)
         form_alert(1,alrt_str);
      else if(which==RECDELET)
      {
         if(form_alert(1,alrt_str)==1)
            chg_mark(TRUE);
         else
            chg_mark(FALSE);
      }
   }

   if(cur_file==TRUE)
      rec_no+=total;

   if(cur_modified)
      sort_cal(rec,rec_no);

   if(which==RECDELET || which==RECEDIT || move_flag==TRUE)
   {
      rec_no-=total;
      if(total>0)
      {
         del_state(menu_tree,RECNEW,DISABLED);
         del_state(menu_tree,CINEWREC,DISABLED);
      }
   }

   if(cur_modified)
      count_all_lines();

   if(which==RECTRANS && cur_file==FALSE)
      Fclose(trans_fhandle);

   set_names();

   show_windows();

   wind_update(0);
}

put_wdw_info(tree,windex)
OBJECT *tree;
int windex;
{
   char **tedptr;
   int i;

   if(window[windex].wcontents>=WC_REPORT)
   {
   tedptr=(char *)tree[PRSDATE].ob_spec;
   if(window[windex].wbeg_flag==TRUE || strlen(window[windex].wsdate)==0)
      strcpy(*tedptr,"\0");
   else if(window[windex].wsys_sdate==TRUE)
   {
      if(data_entry.dcentury==TRUE)
      {
         strcpy(*tedptr,right(sys_date,4));
         strcat(*tedptr,left(sys_date,4));
      }
      else
      {
         if(data_entry.dyear==TRUE)
         {
            strcpy(*tedptr,right(sys_date,4));
            strcat(*tedptr,mid(sys_date,3,2));
         }
         else
            strcpy(*tedptr,right(sys_date,4));
      }
   }
   else
   {
      if(data_entry.dcentury==TRUE)
      {
         strcpy(*tedptr,right(window[windex].wsdate,4));
         strcat(*tedptr,left(window[windex].wsdate,4));
      }
      else
      {
         if(data_entry.dyear==TRUE)
         {
            strcpy(*tedptr,right(window[windex].wsdate,4));
            strcat(*tedptr,mid(window[windex].wsdate,3,2));
         }
         else
            strcpy(*tedptr,right(window[windex].wsdate,4));
      }
   }

   tedptr=(char *)tree[PREDATE].ob_spec;
   if(window[windex].wend_flag==TRUE || strlen(window[windex].wedate)==0)
      strcpy(*tedptr,"\0");
   else if(window[windex].wsys_edate==TRUE)
   {
      if(data_entry.dcentury==TRUE)
      {
         strcpy(*tedptr,right(sys_date,4));
         strcat(*tedptr,left(sys_date,4));
      }
      else
      {
         if(data_entry.dyear==TRUE)
         {
            strcpy(*tedptr,right(sys_date,4));
            strcat(*tedptr,mid(sys_date,3,2));
         }
         else
            strcpy(*tedptr,right(sys_date,4));
      }
   }
   else
   {
      if(data_entry.dcentury==TRUE)
      {
         strcpy(*tedptr,right(window[windex].wedate,4));
         strcat(*tedptr,left(window[windex].wedate,4));
      }
      else
      {
         if(data_entry.dyear==TRUE)
         {
            strcpy(*tedptr,right(window[windex].wedate,4));
            strcat(*tedptr,mid(window[windex].wedate,3,2));
         }
         else
            strcpy(*tedptr,right(window[windex].wedate,4));
      }
   }
   }

   tedptr=(char *)tree[PRSTIME].ob_spec;
   if(strlen(window[windex].wstime)>0)
   {
      if(strcmp(mid(window[windex].wstime,2,2),"00")==0)
      {
         strcpy(*tedptr,"12");
         strcat(*tedptr,right(window[windex].wstime,2));
         strcat(*tedptr,left(window[windex].wstime,1));
      }
      else
      {
         strcpy(*tedptr,right(window[windex].wstime,4));
         strcat(*tedptr,left(window[windex].wstime,1));
      }
   }
   else
      strcpy(*tedptr,"\0");

   tedptr=(char *)tree[PRETIME].ob_spec;
   if(strlen(window[windex].wetime)>0)
   {
      if(strcmp(mid(window[windex].wetime,2,2),"00")==0)
      {
         strcpy(*tedptr,"12");
         strcat(*tedptr,right(window[windex].wetime,2));
         strcat(*tedptr,left(window[windex].wetime,1));
      }
      else
      {
         strcpy(*tedptr,right(window[windex].wetime,4));
         strcat(*tedptr,left(window[windex].wetime,1));
      }
   }
   else
      strcpy(*tedptr,"\0");

   tedptr=(char *)tree[PSUBJED].ob_spec;
   strcpy(*tedptr,window[windex].wsubj);

   tedptr=(char *)tree[PRDESCR].ob_spec;
   strcpy(*tedptr,window[windex].wdescr);

   for(i=0; i<NUM_XFIELDS; i++)
   {
      tedptr=(char *)tree[xfed_tab[1][i]].ob_spec;
      strcpy(*tedptr,window[windex].wxfield[i]);
   }

   if(window[windex].wsys_sdate==TRUE)
      do_msgs(tree,TPRTREPT,PRSDATE,FALSE,TRUE);
   else
      do_msgs(tree,TPRTREPT,PRSDATE,FALSE,FALSE);

   if(window[windex].wsys_edate==TRUE)
      do_msgs(tree,TPRTREPT,PREDATE,FALSE,TRUE);
   else
      do_msgs(tree,TPRTREPT,PREDATE,FALSE,FALSE);

   put_decision(tree,PRSTDEC,window[windex].wdecision[0]);
   put_decision(tree,PRETDEC,window[windex].wdecision[1]);
   put_decision(tree,PRSUBDEC,window[windex].wdecision[2]);
   put_decision(tree,PRXF1DEC,window[windex].wdecision[3]);
   put_decision(tree,PRXF2DEC,window[windex].wdecision[4]);
   put_decision(tree,PRXF3DEC,window[windex].wdecision[5]);
   put_decision(tree,PRXF4DEC,window[windex].wdecision[6]);
   put_decision(tree,PRXF5DEC,window[windex].wdecision[7]);
   put_decision(tree,PRDESDEC,window[windex].wdecision[8]);

   for(i=0; i<9; i++)
      rpt_decision[i]=window[windex].wdecision[i];
}

put_decision(tree,obj,decision)
OBJECT *tree;
int obj,decision;
{
   char **tedptr;

   tedptr=(char *)tree[obj].ob_spec;

   if(decision==IN)
      strcpy(*tedptr,"IN");
   else if(decision==EQUAL)
      strcpy(*tedptr,"=");
   else if(decision==NOT_EQUAL)
      strcpy(*tedptr,"<>");
   else if(decision==GT_OR_EQUAL)
      strcpy(*tedptr,">=");
   else if(decision==LT_OR_EQUAL)
      strcpy(*tedptr,"<=");
   else if(decision==GREATER_THAN)
      strcpy(*tedptr,">");
   else if(decision==LESS_THAN)
      strcpy(*tedptr,"<");
}

res_decisions(tree)
OBJECT *tree;
{
   int i;

   for(i=0; i<9; i++)
      rpt_decision[i]=old_decision[i];

   put_decision(tree,PRSTDEC,rpt_decision[0]);
   put_decision(tree,PRETDEC,rpt_decision[1]);
   put_decision(tree,PRSUBDEC,rpt_decision[2]);
   put_decision(tree,PRXF1DEC,rpt_decision[3]);
   put_decision(tree,PRXF2DEC,rpt_decision[4]);
   put_decision(tree,PRXF3DEC,rpt_decision[5]);
   put_decision(tree,PRXF4DEC,rpt_decision[6]);
   put_decision(tree,PRXF5DEC,rpt_decision[7]);
   put_decision(tree,PRDESDEC,rpt_decision[8]);
}

edit_calendar_info(windex)
int windex;
{
   OBJECT *tree;
   int mn,yr,exit_obj,valid,i;
   char **tedptr;

   rsrc_gaddr(0,TCALEDIT,&tree);

   mn=window[windex].wyindex;

   yr=window[windex].wxindex+1700;

   reset_rbuttons(tree,CEJAN+mn-1,FALSE);

   tedptr=(char *)tree[CEYEAR].ob_spec;
   itoa(yr,*tedptr);

   valid=FALSE;

   while(!valid)
   {
      exit_obj=do_dialog(tree,TCALEDIT,0,1,0);

      valid=TRUE;

      if(exit_obj!=CECANCEL)
      {
         yr=atoi(*tedptr);
         if(yr<1700 || yr>2099)
            valid=FALSE;
      }
   }

   if(exit_obj!=CECANCEL)
   {
      for(i=0; i<12; i++)
         if(ob_selected(tree,CEJAN+i))
            window[windex].wyindex=i+1;

      window[windex].wxindex=yr-1700;
   }

   set_sliders(window[windex].whandle,window[windex].wcontents);

   if(exit_obj==CECANCEL)
      return(FALSE);
   else
      return(TRUE);
}

