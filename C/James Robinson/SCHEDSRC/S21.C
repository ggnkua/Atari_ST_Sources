/* S21.C COPY/PAST, USE LAST INFO (F1,F2,F3 keys) */

#include "obdefs.h"
#include "schdefs.h"
#include "ctools.h"
#include "schedule.h"

extern int ed_idx,xfed_tab[2][5],descr_idx[4];

extern char fld_buffer[160],copyalrt[];

extern LAST_USED last;

extern CUSTOM data_entry;

do_copy(tree,ed_obj)
OBJECT *tree;
int ed_obj;
{
   char **tedptr;

   tedptr=(char *)tree[ed_obj].ob_spec;
   if(strlen(*tedptr)>0)
   {
      strcpy(fld_buffer,*tedptr);
      form_alert(1,copyalrt);
   }
}

do_paste(tree,tdef,ed_obj)
OBJECT *tree;
int tdef,ed_obj;
{
   char **tedptr;
   int i;

   tedptr=(char *)tree[ed_obj].ob_spec;
   for(i=0; fld_buffer[i]!=0; i++)
      if(!val_special(tree,fld_buffer[i]))
         objc_edit(tree,ed_obj,fld_buffer[i],&ed_idx,EDCHAR);

   if(ob_date(tree,ed_obj))
      do_msgs(tree,tdef,ed_obj,TRUE,FALSE);
}

do_last(tree,tdef,ed_obj)
OBJECT *tree;
int tdef,ed_obj;
{
   char **tedptr,*string;
   int i,found,is_date,len;

   found=FALSE; is_date=FALSE;

   if(tdef==TEDITREC)
   {
      switch(ed_obj)
      {
         case ERDATE:   string=last.lsdate;
                        found=TRUE;
                        is_date=TRUE;
                        break;
         case ERTICKLE: string=last.ldays;
                        found=TRUE;
                        len=4;
                        break;
         case ERSTIME:  string=last.lstime;
                        found=TRUE;
                        len=5;
                        break;
         case ERETIME:  string=last.letime;
                        found=TRUE;
                        len=5;
                        break;
         case TSUBJED:  string=last.lsubj;
                        upper(string);
                        found=TRUE;
                        len=data_entry.dlen_subj;
                        break;
      }
      for(i=0; i<5; i++)
      {
         if(ed_obj==xfed_tab[0][i])
         {
            string=last.lxfield[i];
            upper(string);
            found=TRUE;
            len=data_entry.dxfchrs[i];
            break;
         }
      }
                        
      for(i=0; i<4; i++)
      {
         if(ed_obj==descr_idx[i])
         {
            string=last.ldescr[i];
            found=TRUE;
            len=data_entry.dlen_descr[i];
         }
      }
   }
   else if(tdef==TPRTREPT)
   {
      switch(ed_obj)
      {
         case PRSDATE:  string=last.lsdate;
                        found=TRUE;
                        is_date=TRUE;
                        break;
         case PREDATE:  string=last.ledate;
                        found=TRUE;
                        is_date=TRUE;
                        break;
         case PRSTIME:  string=last.lstime;
                        found=TRUE;
                        len=5;
                        break;
         case PRETIME:  string=last.letime;
                        found=TRUE;
                        len=5;
                        break;
         case PSUBJED:  string=last.lsubj;
                        upper(string);
                        found=TRUE;
                        len=data_entry.dlen_subj;
                        break;
         case PRDESCR:  string=last.ldescr[0];
                        upper(string);
                        found=TRUE;
                        len=data_entry.dlen_descr[0];
                        break;
      }
      for(i=0; i<5; i++)
      {
         if(ed_obj==xfed_tab[1][i])
         {
            string=last.lxfield[i];
            upper(string);
            found=TRUE;
            len=data_entry.dxfchrs[i];
            break;
         }
      }
   }
   else switch(tdef)
   {
      case TCALCBD:  switch(ed_obj)
                     {
                        case BDSDATE:  string=last.lsdate;
                                       found=TRUE;
                                       is_date=TRUE;
                                       break;
                        case BDSTIME:  string=last.lstime;
                                       found=TRUE;
                                       len=5;
                                       break;
                        case BDEDATE:  string=last.ledate;
                                       found=TRUE;
                                       is_date=TRUE;
                                       break;
                        case BDETIME:  string=last.letime;
                                       found=TRUE;
                                       len=5;
                                       break;
                     }
      break;

      case TCALCFD:  switch(ed_obj)
                     {
                        case FDDATE:   string=last.lsdate;
                                       found=TRUE;
                                       is_date=TRUE;
                                       break;
                        case FDDAYS:   string=last.ldays;
                                       found=TRUE;
                                       len=4;
                                       break;
                     }
      break;

      case TGODATE:  switch(ed_obj)
                     {
                        case GDDATE:   string=last.lsdate;
                                       found=TRUE;
                                       is_date=TRUE;
                                       break;
                     }
      break;

      case TSYSDATE: switch(ed_obj)
                     {
                        case SDDATE:  string=last.lsdate;
                                      found=TRUE;
                                      is_date=TRUE;
                                      break;
                        case SDTIME:  string=last.lstime;
                                      found=TRUE;
                                      len=5;
                                      break;
                     }
      break;
   }

   if(found && strlen(string)>0)
   {
      tedptr=(char *)tree[ed_obj].ob_spec;
      if(is_date)
      {
         if(tdef==TSYSDATE)
         {
            strcpy(*tedptr,left(string,4));
            strcat(*tedptr,right(string,2));
         }
         else
         {
            if(data_entry.dcentury==TRUE)
               strcpy(*tedptr,string);
            else
            {
               if(data_entry.dyear==TRUE)
               {
                  strcpy(*tedptr,left(string,4));
                  strcat(*tedptr,right(string,2));
               }
               else
                  strcpy(*tedptr,left(string,4));
            }
         }
         do_msgs(tree,tdef,ed_obj,TRUE,FALSE);
      }
      else
         strcpy(*tedptr,left(string,len));

      objc_draw(tree,ed_obj,0,0,0,0,0);
   }
}

