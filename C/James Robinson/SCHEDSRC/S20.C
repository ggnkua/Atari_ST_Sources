/* S20.C -- SPECIAL EDITING KEYS */

#include "obdefs.h"
#include "schdefs.h"
#include "gemdefs.h"
#include "ctools.h"

extern int ed_idx;

is_edit_key(tree,ed_obj,kr,ks)
OBJECT *tree;
int ed_obj,kr,ks;
{
   char **tedptr,temp[41];
   int i,cntr,new_idx=ed_idx,draw_flag=FALSE,found=FALSE;

   tedptr=(char *)tree[ed_obj].ob_spec;

   objc_edit(tree,ed_obj,0,&ed_idx,EDEND);

   if(kr==0x5200) /* Clr (Home) : end of field */
   {
      if(ed_idx>0)
         new_idx=0;
      else
         new_idx=strlen(*tedptr);

      draw_flag=FALSE; found=TRUE;
   }
   else if(kr==0x4700) /* Insert : start of field */
   {
      if(ed_idx<strlen(*tedptr))
         new_idx=strlen(*tedptr);
      else
         new_idx=0;

      draw_flag=FALSE; found=TRUE;
   }
   else if(kr==0x537F && (ks==0x0001 || ks==0x0002))
   {  /* Shift Delete : erase to end of field */
      new_idx=ed_idx;
      strcpy(*tedptr,left(*tedptr,ed_idx));
      draw_flag=TRUE; found=TRUE;
   }
   else if(kr==0x0F09 && ks==0x0008) /* Alt Tab : erase word */
   {
      new_idx=ed_idx;

      strcpy(temp,*tedptr);
      i=ed_idx;
      if(word_end(temp[i]))
         cntr=0;
      else
         cntr=1;
      for(;;)
      {
         if(word_end(temp[i]))
            cntr++;
         if(cntr==2)
            break;
         if(i>=strlen(*tedptr))
            break;
         i++;
      }
      strcpy(temp,left(*tedptr,ed_idx));
      strcat(temp,right(*tedptr,(strlen(*tedptr)-i)));
      strcpy(*tedptr,temp);

      draw_flag=TRUE; found=TRUE;
   }
   else if(kr==0x0F09 && (ks==0x0001 || ks==0x0002)) /* Shift Tab : back word */
   {
      strcpy(temp,*tedptr);

      if(ed_idx>0)
      {
         i=1;

         while(!(word_end(temp[ed_idx-i])) || i<2)
            i++;
         new_idx=ed_idx-i+1;
      }
      else
         new_idx=ed_idx;

      draw_flag=FALSE; found=TRUE;
   }
   else if(kr==0x0F09) /* Tab : ahead word */
   {
      strcpy(temp,*tedptr);

      if(ed_idx<strlen(*tedptr))
      {
         i=1;

         while(!(word_end(temp[ed_idx+i])) && temp[ed_idx+i]!='\0')
            i++;
         new_idx=ed_idx+i;
      }
      else
         new_idx=ed_idx;

      draw_flag=FALSE; found=TRUE;
   }

   if(new_idx<0)
      new_idx=0;
   if(new_idx>strlen(*tedptr))
      new_idx=strlen(*tedptr);

   if(draw_flag)
      objc_draw(tree,ed_obj,0,0,0,0,0);

   ed_idx=new_idx;
   objc_edit(tree,ed_obj,0,&ed_idx,EDEND);

   return(found);
}

