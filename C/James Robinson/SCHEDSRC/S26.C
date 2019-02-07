/* S26.C -- WINDOW SLIDERS, OTHER PREFS */

#include "obdefs.h"
#include "gemdefs.h"
#include "ctype.h"
#include "schdefs.h"
#include "schedule.h"

extern char extalrt[];

extern int vdi_handle,gl_hbox,rez,dummy;

extern WIND window[NUM_WINDS];

extern OTHER_PREFS prefs;

set_sliders(whand,contents)
int whand,contents;
{
   int windex,val,height;

   windex=set_windex(whand);

   if(contents>=WC_REPORT)
   {
      height=work_shown(windex);

      val=((float)window[windex].wyindex/
          ((float)window[windex].wlines-
           (float)height))*1000.0;

      wind_set(whand,WF_VSLIDE,val,0,0,0);

      if(window[windex].wlines==0)
         val=1000;
      else
         val=((float)height/(float)window[windex].wlines)*1000.0;

      wind_set(whand,WF_VSLSIZE,val,0,0,0);

      val=((float)window[windex].wxindex/
          ((float)window[windex].wcolumns-
          ((float)window[windex].work_area.g_w/8)))*1000;
      wind_set(whand,WF_HSLIDE,val,0,0,0);

      if(window[windex].wcolumns==0)
         val=1000;
      else
         val=(((float)window[windex].work_area.g_w/8)/
              window[windex].wcolumns)*1000;
      wind_set(whand,WF_HSLSIZE,val,0,0,0);
   }
   else if(contents==WC_CALENDAR)
   {
      val=((float)window[windex].wxindex/window[windex].wlines)*1000;
      wind_set(whand,WF_VSLIDE,val,0,0,0);
   } 
}

other_prefs()
{
   OBJECT *tree;
   int exit_obj,valid,i;
   char **tedptr,ext_temp[4];

   hide_windows();

   rsrc_gaddr(0,TOTHERPF,&tree);

   if(prefs.opbackup)
      reset_rbuttons(tree,OPYESBAK,FALSE);
   else
      reset_rbuttons(tree,OPNOBAK,FALSE);

   if(prefs.optime_display)
      reset_rbuttons(tree,OPYESTIM,FALSE);
   else
      reset_rbuttons(tree,OPNOTIME,FALSE);

   if(prefs.opdate_display)
      reset_rbuttons(tree,OPYESDAT,FALSE);
   else
      reset_rbuttons(tree,OPNODATE,FALSE);

   tedptr=(char *)tree[OPEXTENS].ob_spec;
   strcpy(*tedptr,prefs.opdisk_extension);

   valid=FALSE;

   while(!valid)
   {
      exit_obj=do_dialog(tree,TOTHERPF,0,1,0);

      if(exit_obj!=OPCANCEL)
      {
         valid=TRUE;

         if(ob_selected(tree,OPYESBAK))
            prefs.opbackup=TRUE;
         else
            prefs.opbackup=FALSE;
         if(ob_selected(tree,OPYESTIM))
            prefs.optime_display=TRUE;
         else
            prefs.optime_display=FALSE;
         if(ob_selected(tree,OPYESDAT))
            prefs.opdate_display=TRUE;
         else
            prefs.opdate_display=FALSE;

         tedptr=(char *)tree[OPEXTENS].ob_spec;
         strcpy(ext_temp,*tedptr);

         for(i=0; i<strlen(ext_temp); i++)
            if(!isalpha(ext_temp[i]) &&
               !isdigit(ext_temp[i]))
               valid=FALSE;

         if(!valid)
            form_alert(1,extalrt);
      }
      else
         valid=TRUE;
   }

   if(exit_obj!=OPCANCEL)
      strcpy(prefs.opdisk_extension,ext_temp);

   show_windows();

   if(!prefs.opdate_display && !prefs.optime_display)
   {
      vst_color(vdi_handle,BLACK);
      vst_effects(vdi_handle,NORMAL);
      vswr_mode(vdi_handle,MD_REPLACE);

      HIDE_MOUSE;
      v_gtext(vdi_handle,544,7*rez,"          ");
      SHOW_MOUSE;
   }
   else
      time_display();
}


