/* S16.C -- MACROS */

#include "obdefs.h"
#include "schdefs.h"
#include "gemdefs.h"
#include "schedule.h"

extern int ed_idx,mac_modified;

extern char mac_file[129];

macros()
{
   OBJECT *tree;
   int i,exit_obj,found;
   char **tedptr;

   hide_windows();

   rsrc_gaddr(0,TMACROS,&tree);

   save_form(tree);

   for(;;)
   {
      exit_obj=do_dialog(tree,TMACROS,0,0,0);
      if(exit_obj==MACLOAD)
         load_macs(TRUE);
      else if(exit_obj==MACSAVE)
         save_macs(TRUE);
      else
         break;
   }

   if(exit_obj==MCANCEL)
      cancel_form(tree);
   else
   {
      found=FALSE;

      for(i=0; i<26; i++)
      {
         tedptr=(char *)tree[AMAC+i].ob_spec;
         if(strlen(*tedptr)>0)
            found=TRUE;
      }

      if(!found)
         strcpy(mac_file,"\0"); /* clear old mac pref file if no macs */

      mac_modified=TRUE;
   }

   show_windows();
}

is_macro(tree,obj,kr)
OBJECT *tree;
int kr;
{
   OBJECT *macro_tree;
   char **tedptr,*mac_str,*obj_str;
   int i,index;
   static int scan_code[26]={ 0x1E00,0x3000,0x2E00,0x2000,0x1200,0x2100,0x2200,
                               0x2300,0x1700,0x2400,0x2500,0x2600,0x3200,0x3100,
                               0x1800,0x1900,0x1000,0x1300,0x1F00,0x1400,0x1600,
                               0x2F00,0x1100,0x2D00,0x1500,0x2C00 };

   rsrc_gaddr(0,TMACROS,&macro_tree);

   index=(-1);

   for(i=0; i<26; i++)
      if(scan_code[i]==kr)
         index=i;

   if(index>=0)
   {
      tedptr=(char *)macro_tree[AMAC+index].ob_spec;
      mac_str= *tedptr;

      tedptr=(char *)tree[obj].ob_spec;
      obj_str= *tedptr;

      for(i=0; mac_str[i]!=0; i++)
         if(!val_special(tree,mac_str[i]))
            objc_edit(tree,obj,mac_str[i],&ed_idx,EDCHAR);

      return(TRUE);
   }
   else
      return(FALSE);
}

