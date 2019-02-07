/* S17.C -- SET FIELDS, RECORD ALLOCATIONS */

#include "stdio.h"
#include "osbind.h"
#include "obdefs.h"
#include "gemdefs.h"
#include "schdefs.h"
#include "schedule.h"

extern int dummy,rec_modified,rec_no,max_recs,size_rec,disk_full,
           xf_table[NUM_XFIELDS],*y_to_rec_no[9];

extern char memalrt[],limalrt[],setalrt[],fldalrt[],newfldalrt[];

extern long menu_tree;

extern OBJECT *citree;

extern RECORD *rec;

extern CUSTOM data_entry,prev_data;

extern char *buf_stime,*buf_etime,*buf_subj,*buf_xfields,*buf_descr;

cust_data_entry()
{
   OBJECT *tree;
   char   **tedptr;
   int   exit_obj,i,j,chrs,finished=FALSE,use_malloc,counter;

   wind_update(1);

   hide_windows();

   if(rec_modified)
   {
      form_alert(1,setalrt);
      show_windows();
      wind_update(0);
      return;
   }

   rsrc_gaddr(0,TCUSTOM,&tree);

   if(data_entry.dcentury==TRUE)
      reset_rbuttons(tree,CENTYES,FALSE);
   else
      reset_rbuttons(tree,CENTNO,FALSE);

   if(data_entry.dyear==TRUE)
      reset_rbuttons(tree,YEARYES,FALSE);
   else
      reset_rbuttons(tree,YEARNO,FALSE);

   if(data_entry.dtickler==TRUE)
      reset_rbuttons(tree,TICKYES,FALSE);
   else
      reset_rbuttons(tree,TICKNO,FALSE);

   if(data_entry.dstime==TRUE)
      reset_rbuttons(tree,STIMEYES,FALSE);
   else
      reset_rbuttons(tree,STIMENO,FALSE);

   if(data_entry.detime==TRUE)
      reset_rbuttons(tree,ETIMEYES,FALSE);
   else
      reset_rbuttons(tree,ETIMENO,FALSE);

   if(data_entry.dsubj==TRUE)
      reset_rbuttons(tree,SUBJYES,FALSE);
   else
      reset_rbuttons(tree,SUBJNO,FALSE);

   tedptr=(char *)tree[CSUBJLEN].ob_spec;
   itoa(data_entry.dlen_subj,*tedptr);

   reset_rbuttons(tree,DELINES1+data_entry.ddescr_lines-1,FALSE);

   for(i=0; i<4; i++)
   {
      tedptr=(char *)tree[CDELEN1+i].ob_spec;
      itoa(data_entry.dlen_descr[i],*tedptr);
   }

   for(i=0; i<NUM_XFIELDS; i++)
   {
      tedptr=(char *)tree[CAFLAB1+i].ob_spec;
      strcpy(*tedptr,data_entry.dxflabel[i]);

      tedptr=(char *)tree[CAFCHRS1+i].ob_spec;
      if(data_entry.dxfchrs[i]>0)
         itoa(data_entry.dxfchrs[i],*tedptr);
      else
         strcpy(*tedptr,"\0");
   }

   save_form(tree);

   if(ob_selected(tree,CENTYES))
      ob_hide(tree,YEARNO);
   else
      ob_unhide(tree,YEARNO);

   while(!finished)
   {
      exit_obj=do_dialog(tree,TCUSTOM,0,0);

      if(exit_obj!=CCANCEL)
      {
         finished=TRUE;

         prev_data.dcentury=data_entry.dcentury;
         prev_data.dyear=data_entry.dyear;
         prev_data.dtickler=data_entry.dtickler;
         prev_data.dstime=data_entry.dstime;
         prev_data.detime=data_entry.detime;
         prev_data.dsubj=data_entry.dsubj;
         prev_data.dlen_subj=data_entry.dlen_subj;
         prev_data.ddescr_lines=data_entry.ddescr_lines;
         for(i=0; i<4; i++)
            prev_data.dlen_descr[i]=data_entry.dlen_descr[i];
         prev_data.dxfields=data_entry.dxfields;
         for(i=0; i<NUM_XFIELDS; i++)
         {
            strcpy(prev_data.dxflabel[i],data_entry.dxflabel[i]);
            prev_data.dxfchrs[i]=data_entry.dxfchrs[i];
         }

         data_entry.dxfields=0;

         if(ob_selected(tree,CENTYES))
            data_entry.dcentury=TRUE;
         else
            data_entry.dcentury=FALSE;

         if(ob_selected(tree,YEARYES))
            data_entry.dyear=TRUE;
         else
            data_entry.dyear=FALSE;

         if(ob_selected(tree,TICKYES))
            data_entry.dtickler=TRUE;
         else
            data_entry.dtickler=FALSE;

         if(ob_selected(tree,STIMEYES))
            data_entry.dstime=TRUE;
         else
            data_entry.dstime=FALSE;

         if(ob_selected(tree,ETIMEYES))
            data_entry.detime=TRUE;
         else
            data_entry.detime=FALSE;

         if(ob_selected(tree,SUBJYES))
            data_entry.dsubj=TRUE;
         else
            data_entry.dsubj=FALSE;

         tedptr=(char *)tree[CSUBJLEN].ob_spec;
         data_entry.dlen_subj=atoi(*tedptr);
         if(data_entry.dlen_subj<1 || data_entry.dlen_subj>40)
         {
            finished=FALSE;
            form_alert(1,limalrt);
         }

         for(i=0; i<4; i++)
            if(ob_selected(tree,DELINES1+i))
               data_entry.ddescr_lines=i+1;

         for(i=0; i<4; i++)
         {
            tedptr=(char *)tree[CDELEN1+i].ob_spec;
            data_entry.dlen_descr[i]=atoi(*tedptr);
            if(data_entry.dlen_descr[i]<1 || data_entry.dlen_descr[i]>40)
            {
               finished=FALSE;
               form_alert(1,limalrt);
               break;
            }
         }

         for(i=0; i<NUM_XFIELDS; i++)
         {
            strcpy(data_entry.dxflabel[i],"\0");
            data_entry.dxfchrs[i]=0;
         }

         counter=0;

         for(i=0; i<NUM_XFIELDS; i++)
         {
            tedptr=(char *)tree[CAFLAB1+i].ob_spec;
            if(strlen(*tedptr)>0)
            {
               strcpy(data_entry.dxflabel[counter],*tedptr);
               data_entry.dxfields++;
               tedptr=(char *)tree[CAFCHRS1+i].ob_spec;
               chrs=atoi(*tedptr);
               data_entry.dxfchrs[counter]=chrs;
               if(chrs>40 || chrs<=0)
               {
                  finished=FALSE;
                  form_alert(1,limalrt);
                  break;
               }
               counter++;
            }
         }

         for(i=counter; i<NUM_XFIELDS; i++)
         {
            strcpy(data_entry.dxflabel[counter],"\0");
            data_entry.dxfchrs[counter]=0;
         }
      }
      else
      {
         finished=TRUE;
         cancel_form(tree);
      }
   }

   if(exit_obj!=CCANCEL)
   {
      use_malloc=FALSE;

      for(i=0; i<data_entry.dxfields; i++)
      {
         xf_table[i]=(-1);

         if(strcmp(prev_data.dxflabel[i],data_entry.dxflabel[i])!=0 &&
            strlen(prev_data.dxflabel[i])>0)
         {
            for(j=0; j<NUM_XFIELDS; j++)
            {
               if(strcmp(prev_data.dxflabel[j],data_entry.dxflabel[i])==0)
               {
                  xf_table[i]=j;
                  break;
               }
            }
         }
         else
            xf_table[i]=i;

         if(xf_table[i]==(-1))
         {
            for(j=0; j<strlen(data_entry.dxflabel[i]); j++)
               newfldalrt[18+j]=data_entry.dxflabel[i][j];
            for(j=strlen(data_entry.dxflabel[i]); j<12; j++)
               newfldalrt[18+j]=' ';

            if(form_alert(1,newfldalrt)==1)
               xf_table[i]=(-1);
            else
            {
               if(prev_data.dxfields>1)
                  xf_table[i]=do_xf_change(data_entry.dxflabel[i]);
               else
                  xf_table[i]=0;
            }
         }
      }

      if((data_entry.dstime!=prev_data.dstime) ||
         (data_entry.detime!=prev_data.detime) ||
         (data_entry.dsubj!=prev_data.dsubj) ||
         (data_entry.dlen_subj!=prev_data.dlen_subj) ||
         (data_entry.ddescr_lines!=prev_data.ddescr_lines) ||
         (data_entry.dxfields!=prev_data.dxfields))
         use_malloc=TRUE;

      for(i=0; i<4; i++)
         if(prev_data.dlen_descr[i]!=data_entry.dlen_descr[i])
            use_malloc=TRUE;

      for(i=0; i<NUM_XFIELDS; i++)
      {
         if(prev_data.dxfchrs[i]!=data_entry.dxfchrs[i])
            use_malloc=TRUE;
         if(strcmp(prev_data.dxflabel[i],data_entry.dxflabel[i])!=0)
            use_malloc=TRUE;
      }

      if(!use_malloc)
         cust_forms(FALSE);
      else
      {
         if(rec_no==0 || form_alert(1,fldalrt)==1)
         {
            cust_forms(FALSE);
            if(rec_no>0)
               save_recs(FALSE,&prev_data,TRUE);
            mal_records(TRUE);
            count_all_lines();
         }
         else
         {
            cancel_form(tree);

            data_entry.dcentury=prev_data.dcentury;
            data_entry.dyear=prev_data.dyear;
            data_entry.dtickler=prev_data.dtickler;
            data_entry.dstime=prev_data.dstime;
            data_entry.detime=prev_data.detime;
            data_entry.dsubj=prev_data.dsubj;
            data_entry.dlen_subj=prev_data.dlen_subj;
            data_entry.ddescr_lines=prev_data.ddescr_lines;
            for(i=0; i<4; i++)
               data_entry.dlen_descr[i]=prev_data.dlen_descr[i];
            data_entry.dxfields=prev_data.dxfields;
            for(i=0; i<NUM_XFIELDS; i++)
            {
               strcpy(data_entry.dxflabel[i],prev_data.dxflabel[i]);
               data_entry.dxfchrs[i]=prev_data.dxfchrs[i];
            }
        
            if(ob_hidden(tree,ETIMEYES))
               ob_unhide(tree,ETIMEYES);
         }
      }
   }

   show_windows();

   if(exit_obj!=CCANCEL)
      set_all_wdw_headers();

   wind_update(0);
}

do_xf_change(chg_fld)
char chg_fld[13];
{
   OBJECT *tree;
   int i,exit_obj;
   char *strptr;

   rsrc_gaddr(0,TSELXFLD,&tree);

   for(i=0; i<NUM_XFIELDS; i++)
   {
      if(prev_data.dxfields>i)
      {
         strptr=(char *)tree[SXXFLD1+i].ob_spec;
         strcpy(strptr,prev_data.dxflabel[i]);
      }
      else
         ob_hide(tree,SXXFLD1+i);
   }

   strptr=(char *)tree[SXCHGFLD].ob_spec;
   strcpy(strptr,chg_fld);
   strcat(strptr,"?");

   exit_obj=do_dialog(tree,TSELXFLD,0,1,0);

   for(i=prev_data.dxfields; i<NUM_XFIELDS; i++)
      ob_unhide(tree,SXXFLD1+i);

   return(exit_obj-SXXFLD1);
}

mal_records(free_flag)
int free_flag;
{
   register int i,j;
   long tot_free,free_mem();

   wind_update(1);

   if(free_flag)
   {
      if(disk_full)
      {
         wind_update(0);
         return;
      }

      for(i=0; i<9; i++)
         free((char *)y_to_rec_no[i]);

      for(i=0; i<max_recs; i++)
      {
         if(prev_data.dstime)
            free(rec[i].rstime);
         if(prev_data.detime)
            free(rec[i].retime);
         if(prev_data.dsubj)
            free(rec[i].rsubj);
         for(j=0; j<prev_data.dxfields; j++)
            free(rec[i].rxfield[j]);
         for(j=0; j<prev_data.ddescr_lines; j++)
            free(rec[i].rdescr[j]);
      }
      Mfree(rec);
   }

   size_rec=0;

   if(data_entry.dstime==TRUE)
      size_rec+=mal_align(6);
   if(data_entry.detime==TRUE)
      size_rec+=mal_align(6);
   if(data_entry.dsubj==TRUE)
      size_rec+=mal_align(data_entry.dlen_subj+1);
   for(i=0; i<4; i++)
   {
      if(data_entry.ddescr_lines>i)
         size_rec+=mal_align(data_entry.dlen_descr[i]+1);
   }
   for(i=0; i<NUM_XFIELDS; i++)
   {
      if(data_entry.dxfields>i)
         size_rec+=mal_align(data_entry.dxfchrs[i]+1);
   }

   tot_free=free_mem();

   max_recs=((long)((long)tot_free-24000L)/
            ((long)sizeof(RECORD)+(long)size_rec));
   max_recs=((long)((long)tot_free-24000L-((long)max_recs*9L))/
            ((long)sizeof(RECORD)+(long)size_rec));

   if(max_recs>1000)
      max_recs=1000;

   graf_mouse(HOURGLASS,&dummy);

   for(i=0; i<9; i++)
      y_to_rec_no[i]=(int *)malloc((unsigned int)max_recs+2);

   rec=(RECORD *) Malloc((long)max_recs*(long)sizeof(RECORD));

   for(i=0; i<max_recs; i++)
   {
      if(!rec_store(&rec[i]))
         break;
   }

   max_recs=i;

   graf_mouse(ARROW,&dummy);

   if(free_flag && rec_no>0)
   {
      open_recs(TRUE,FALSE,TRUE,FALSE);

      if(max_recs<=rec_no)
      {
         form_alert(1,memalrt);
         set_state(menu_tree,RECNEW,DISABLED);
         set_state(citree,CINEWREC,DISABLED);
      }
      else
      {
         del_state(menu_tree,RECNEW,DISABLED);
         del_state(citree,CINEWREC,DISABLED);
      }
   }
   wind_update(0);
}

rec_store(p)
RECORD *p;
{
   register int i;
   extern char *malloc();

   if(data_entry.dstime==TRUE)
   {
      p->rstime=malloc((unsigned int)6);
      if(p->rstime=='\0')
         return(FALSE);
   }

   if(data_entry.detime==TRUE)
   {
      p->retime=malloc((unsigned int)6);
      if(p->retime=='\0')
         return(FALSE);
   }

   if(data_entry.dsubj==TRUE)
   {
      p->rsubj=malloc((unsigned int)data_entry.dlen_subj+1);
      if(p->rsubj=='\0')
         return(FALSE);
   }

   for(i=0; i<data_entry.ddescr_lines; i++)
   {
      p->rdescr[i]=malloc((unsigned int)data_entry.dlen_descr[i]+1);
      if(p->rdescr[i]=='\0')
         return(FALSE);
   }

   for(i=0; i<data_entry.dxfields; i++)
   {
      p->rxfield[i]=malloc((unsigned int)data_entry.dxfchrs[i]+1);
      if(p->rxfield[i]=='\0')
         return(FALSE);
   }

   return(TRUE);
}

mal_align(x)
int x;
{
   static int table[11]={4,8,12,16,20,24,28,32,36,40,44};

   return(table[(x-1)/4]);
}

long free_mem()
{
   char *buf[20];
   long chunk,tot;
   int i,idx;

   chunk=99; idx=0; tot=0;

   while(chunk>0 && idx<15)
   {
      chunk=Malloc(-1L);
      buf[idx]=(char *)Malloc(chunk);
      if(chunk>0)
      {
         idx++;
         tot+=chunk;
      }
   }

   for(i=idx-1; i>=0; i--)
      Mfree((char *)buf[i]);

   return((long)tot);
}
