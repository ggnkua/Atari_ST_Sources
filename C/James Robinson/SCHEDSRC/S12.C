/* S12.C -- RESHAPE RECORD DIALOGS */

#include "obdefs.h"
#include "schdefs.h"
#include "ctools.h"
#include "schedule.h"

extern int xflab_tab[2][5],xfed_tab[2][5],xfpar_tab[2][5],descr_idx[4],rez;

extern CUSTOM data_entry;

extern PAGE page_setup;

cust_forms(tick_flag)
int tick_flag;
{
   OBJECT *tree;
   char *tmp_ptr,*val_ptr,*strptr;
   int ymin[2],i,j,longest,desc_ymin;

   if(tick_flag==FALSE)
      do_century(data_entry.dcentury);

   ymin[0]=0; ymin[1]=0;

   rsrc_gaddr(0,TEDITREC,&tree);
   unhide_all(tree);
   restore_ob_xy(tree,TEDITREC);

   rsrc_gaddr(0,TPRTREPT,&tree);
   unhide_all(tree);
   restore_ob_xy(tree,TPRTREPT);

   rsrc_gaddr(0,TEDITREC,&tree);

   if(data_entry.dtickler!=TRUE && tick_flag!=TRUE)
   {
      rsrc_gaddr(0,TEDITREC,&tree);
      ob_hide(tree,ERTIKPAR);
      ob_hide(tree,ERTICKLE);
      ymin[0]+=(8*rez);
   }

   if(data_entry.dstime!=TRUE || tick_flag==TRUE)
   {
      rsrc_gaddr(0,TEDITREC,&tree);
      ob_hide(tree,ERSTPAR);
      ob_hide(tree,ERSTIME);
      ymin[0]+=(8*rez);
      rsrc_gaddr(0,TPRTREPT,&tree);
      ob_hide(tree,PSTPAR);
      ob_hide(tree,PRSTIME);
      ymin[1]+=(8*rez);
   }
   else
   {
      rsrc_gaddr(0,TEDITREC,&tree);
      tree[ERSTPAR].ob_y-=ymin[0];
   }

   if(data_entry.detime!=TRUE || tick_flag==TRUE)
   {
      rsrc_gaddr(0,TEDITREC,&tree);
      ob_hide(tree,ERETPAR);
      ob_hide(tree,ERETIME);
      ymin[0]+=(8*rez);
      rsrc_gaddr(0,TPRTREPT,&tree);
      ob_hide(tree,PETPAR);
      ob_hide(tree,PRETIME);
      ymin[1]+=(8*rez);
   }
   else
   {
      rsrc_gaddr(0,TEDITREC,&tree);
      tree[ERETPAR].ob_y-=ymin[0];
   }

   if(data_entry.dsubj!=TRUE)
   {
      rsrc_gaddr(0,TEDITREC,&tree);
      ob_hide(tree,TSUBJPAR);
      ob_hide(tree,TSUBJED);
      ymin[0]+=(8*rez);
      rsrc_gaddr(0,TPRTREPT,&tree);
      ob_hide(tree,PSUBJPAR);
      ob_hide(tree,PSUBJED);
      ymin[1]+=(8*rez);
   }
   else
   {
      rsrc_gaddr(0,TEDITREC,&tree);
      tree[TSUBJPAR].ob_y-=ymin[0];

      tree[TSUBJED].ob_width=(data_entry.dlen_subj+1)*8;
      ((TEDINFO *)tree[TSUBJED].ob_spec)->te_txtlen=data_entry.dlen_subj+1;
      tmp_ptr=((TEDINFO *)tree[TSUBJED].ob_spec)->te_ptmplt;
      strcpy(tmp_ptr,replicate('_',data_entry.dlen_subj));
      val_ptr=((TEDINFO *)tree[TSUBJED].ob_spec)->te_pvalid;
      strcpy(val_ptr,replicate('U',data_entry.dlen_subj));

      rsrc_gaddr(0,TPRTREPT,&tree);
      tree[PSUBJPAR].ob_y-=ymin[1];

      tree[PSUBJED].ob_width=(data_entry.dlen_subj+1)*8;
      ((TEDINFO *)tree[PSUBJED].ob_spec)->te_txtlen=data_entry.dlen_subj+1;
      tmp_ptr=((TEDINFO *)tree[PSUBJED].ob_spec)->te_ptmplt;
      strcpy(tmp_ptr,replicate('_',data_entry.dlen_subj));
      val_ptr=((TEDINFO *)tree[PSUBJED].ob_spec)->te_pvalid;
      strcpy(val_ptr,replicate('U',data_entry.dlen_subj));
   }

   for(i=0; i<2; i++)
   {
      if(i==0)
         rsrc_gaddr(0,TEDITREC,&tree);
      if(i==1)
         rsrc_gaddr(0,TPRTREPT,&tree);

      for(j=0; j<data_entry.dxfields; j++)
      {
         strptr=(char *)tree[xflab_tab[i][j]].ob_spec;
         strcpy(strptr,rjustify(data_entry.dxflabel[j],13));
         strcat(strptr,":");
         tree[xfpar_tab[i][j]].ob_y-=ymin[i];

         tree[xfed_tab[i][j]].ob_width=(data_entry.dxfchrs[j]+1)*8;
         ((TEDINFO *)tree[xfed_tab[i][j]].ob_spec)->te_txtlen=data_entry.dxfchrs[j]+1;
         tmp_ptr=((TEDINFO *)tree[xfed_tab[i][j]].ob_spec)->te_ptmplt;
         strcpy(tmp_ptr,replicate('_',data_entry.dxfchrs[j]));
         val_ptr=((TEDINFO *)tree[xfed_tab[i][j]].ob_spec)->te_pvalid;
         strcpy(val_ptr,replicate('U',data_entry.dxfchrs[j]));
      }
   }

   for(i=0; i<2; i++)
   {
      if(i==0)
         rsrc_gaddr(0,TEDITREC,&tree);
      if(i==1)
         rsrc_gaddr(0,TPRTREPT,&tree);
         
      for(j=data_entry.dxfields; j<NUM_XFIELDS; j++)
      {
         ob_hide(tree,xfpar_tab[i][j]);
         ob_hide(tree,xflab_tab[i][j]);
         ob_hide(tree,xfed_tab[i][j]);
         ymin[i]+=(8*rez);
      }
   }

   rsrc_gaddr(0,TEDITREC,&tree);

   desc_ymin=0;

   for(i=0; i<4; i++)
   {
      if(data_entry.ddescr_lines<i+1)
      {
         ob_hide(tree,descr_idx[i]);
         desc_ymin+=(8*rez);
      }
      tree[descr_idx[i]].ob_width=(data_entry.dlen_descr[i]+1)*8;
      ((TEDINFO *)tree[descr_idx[i]].ob_spec)->te_txtlen=data_entry.dlen_descr[i]+1;
      tmp_ptr=((TEDINFO *)tree[descr_idx[i]].ob_spec)->te_ptmplt;
      strcpy(tmp_ptr,replicate('_',data_entry.dlen_descr[i]));
      val_ptr=((TEDINFO *)tree[descr_idx[i]].ob_spec)->te_pvalid;
      strcpy(val_ptr,replicate('X',data_entry.dlen_descr[i]));
   }

   tree[ERDELABL].ob_y-=ymin[0];
   tree[ERDEPAR].ob_y-=ymin[0];
   tree[EROK].ob_y-=(ymin[0]+desc_ymin);
   tree[ERCANCEL].ob_y-=(ymin[0]+desc_ymin);
   tree[ERDELETE].ob_y-=(ymin[0]+desc_ymin);
   tree[EREXIT].ob_y-=(ymin[0]+desc_ymin);
   tree[0].ob_height-=(ymin[0]+desc_ymin);

   rsrc_gaddr(0,TPRTREPT,&tree);

   longest=0;

   for(i=0; i<4; i++)
      if(data_entry.ddescr_lines>i && data_entry.dlen_descr[i]>longest)
         longest=data_entry.dlen_descr[i];

   tree[PRDESCR].ob_width=(longest+1)*8;
   ((TEDINFO *)tree[PRDESCR].ob_spec)->te_txtlen=longest+1;
   tmp_ptr=((TEDINFO *)tree[PRDESCR].ob_spec)->te_ptmplt;
   strcpy(tmp_ptr,replicate('_',longest));
   val_ptr=((TEDINFO *)tree[PRDESCR].ob_spec)->te_pvalid;
   strcpy(val_ptr,replicate('U',longest));

   tree[PRBUTPAR].ob_y-=ymin[1];
   tree[PRDETREE].ob_y-=ymin[1];
   tree[PRDECBOX].ob_y-=ymin[1];
   tree[PRDECLAB].ob_y-=ymin[1];
   tree[0].ob_height-=ymin[1];
}

