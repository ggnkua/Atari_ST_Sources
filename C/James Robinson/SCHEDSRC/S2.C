/* S2.C -- MSG HANDLER, WINDOW KEYBOARD FUNCTIONS */

#include "obdefs.h"
#include "gemdefs.h"
#include "schdefs.h"

extern int  mgbuf[8],sel_windex,topped,windex,gl_hbox,cal_idx;

extern WIND window[NUM_WINDS];

hndl_msg()
{
   int  whand,work,cnt_shown,old_x,old_y;

   whand=mgbuf[3];

   windex=set_windex(whand);

   old_x=window[windex].wxindex; old_y=window[windex].wyindex;

   switch (mgbuf[0])
   {
      case WM_REDRAW:
      {
         if(whand>0 && windex!=(-1) && window[windex].wopen)
            redraw(whand,(GRECT *) &mgbuf[4],window[windex].wcontents);
         break;
      }
      case WM_CLOSED:
      {
         if(sel_windex!=(-1))
            sel_clear(&window[sel_windex].work_area,TRUE);
         wind_close(whand);
         wind_delete(whand);
         clr_window(whand);
         break;
      }
      case WM_TOPPED:
      {
         if(sel_windex!=(-1))
            sel_clear(&window[sel_windex].work_area,TRUE);
         if(whand>0 && window[windex].wopen)
         {
            top_window(window[windex].whandle,TRUE);
            clr_tops();
            window[windex].wtopped=TRUE;
            topped=window[windex].whandle;

            if(window[windex].wcontents>=WC_REPORT)
               shown_count(windex);
         }
         break;
      }
      case WM_FULLED:
      {
         if(sel_windex!=(-1))
            sel_clear(&window[sel_windex].work_area,TRUE);
         fulled(whand);
         shown_count(windex);
         set_sliders(whand,window[windex].wcontents);
         break;
      }
      case WM_MOVED:
      {
         if(sel_windex!=(-1))
            sel_clear(&window[sel_windex].work_area,TRUE);

         if(window[windex].wopen)
         {
            mgbuf[4]=align_x(mgbuf[4])-1;

            wind_set(whand,WF_CXYWH,
                     mgbuf[4],mgbuf[5],mgbuf[6],mgbuf[7]);
            wind_get(whand,WF_WXYWH,
                     &window[windex].work_area.g_x,&window[windex].work_area.g_y,
                     &window[windex].work_area.g_w,&window[windex].work_area.g_h);
            if(window[windex].wcontents==WC_CALENDAR)
               set_xy(window[windex].work_area.g_x,window[windex].work_area.g_y);
            wind_get(whand,WF_CXYWH,
                     &window[windex].wx,&window[windex].wy,
                     &window[windex].wwidth,&window[windex].wheight);
         }
         break;
      }
      case WM_SIZED:
      {
         if(sel_windex!=(-1))
            sel_clear(&window[sel_windex].work_area,TRUE);
         wind_calc(1,window[windex].wfeatures,mgbuf[4],mgbuf[5],mgbuf[6],mgbuf[7],
                   &window[windex].work_area.g_x,&window[windex].work_area.g_y,
                   &window[windex].work_area.g_w,&window[windex].work_area.g_h);
         wind_set(whand,WF_CXYWH,mgbuf[4],mgbuf[5],mgbuf[6],mgbuf[7]);
         wind_get(whand,WF_CXYWH,
                  &window[windex].wx,&window[windex].wy,
                  &window[windex].wwidth,&window[windex].wheight);

         shown_count(windex);
         set_sliders(whand,window[windex].wcontents);
         break;
      }
      case WM_HSLID:
      {
         if(sel_windex!=(-1))
            sel_clear(&window[sel_windex].work_area,TRUE);

         work=(float)window[windex].work_area.g_w/8.0;

         window[windex].wxindex=((float)mgbuf[4]/1000.0)*
                                ((float)window[windex].wcolumns-
                                 (float)work);

         rpt_boundaries(windex);

         if(old_x!=window[windex].wxindex)
         {   
            set_sliders(whand,window[windex].wcontents);
            wind_report(windex,&window[windex].work_area);
         }
         break;
      }
      case WM_VSLID:
      {
         if(window[windex].wcontents==WC_CALENDAR)
         {
            window[windex].wxindex=(float)window[windex].wlines*
                                   ((float)mgbuf[4]/1000.0);

            set_sliders(whand,window[windex].wcontents);
            if(cal_idx!=windex)
               cal_idx=windex;
            draw_cal(windex,&window[windex].work_area);
         }
         else if(window[windex].wcontents>=WC_REPORT)
         {
            work=work_shown(windex);

            window[windex].wyindex=((float)mgbuf[4]/1000.0)*
                                   ((float)window[windex].wlines-
                                    (float)work);

            rpt_boundaries(windex);

            if(old_y!=window[windex].wyindex)
            {
               if(sel_windex!=(-1))
                  sel_clear(&window[sel_windex].work_area,TRUE);
               shown_count(windex);
               set_sliders(whand,window[windex].wcontents);
               wind_report(windex,&window[windex].work_area);
            }
         }
         break;
      }
      case WM_ARROWED:
      {
         cnt_shown=TRUE;

         switch(mgbuf[4])
         {
            case WA_UPPAGE:
            {
               if(window[windex].wcontents==WC_CALENDAR)
                  window[windex].wxindex--;
               else if(window[windex].wcontents>=WC_REPORT)
                  window[windex].wyindex-=window[windex].wshown;
               break;
            }
            case WA_DNPAGE:
            {
               if(window[windex].wcontents==WC_CALENDAR)
                  window[windex].wxindex++;
               else if(window[windex].wcontents>=WC_REPORT)
                  window[windex].wyindex+=window[windex].wshown;
               break;
            }
            case WA_UPLINE:
            {
               window[windex].wyindex--;
               break;
            }
            case WA_DNLINE:
            {
               window[windex].wyindex++;
               break;
            }
            case WA_LFPAGE:
            {
               window[windex].wxindex-=(window[windex].work_area.g_w/8);
               cnt_shown=FALSE;
               break;
            }
            case WA_RTPAGE:
            {
               window[windex].wxindex+=(window[windex].work_area.g_w/8);
               cnt_shown=FALSE;
               break;
            }
            case WA_LFLINE:
            {
               window[windex].wxindex--;
               cnt_shown=FALSE;
               break;
            }
            case WA_RTLINE:
            {
               window[windex].wxindex++;
               cnt_shown=FALSE;
               break;
            }
         }

         if(window[windex].wcontents>=WC_REPORT)
            rpt_boundaries(windex);

         if(old_x!=window[windex].wxindex || old_y!=window[windex].wyindex)
         {
            if(cnt_shown && window[windex].wcontents>=WC_REPORT)
               shown_count(windex);

            set_sliders(whand,window[windex].wcontents);

            if(window[windex].wcontents==WC_CALENDAR)
            {
               if(cal_idx!=windex)
                  cal_idx=windex;
               draw_cal(windex,&window[windex].work_area);
            }
            else if(window[windex].wcontents>=WC_REPORT)
            {
               if(sel_windex!=(-1))
                  sel_clear(&window[sel_windex].work_area,TRUE);
               wind_report(windex,&window[windex].work_area);
            }
         }

         break;
      }
   }
}

hndl_keyboard(kr)
int kr;
{
   int windex,whand,ok,cnt_shown,dummy,i,found,old_x,old_y;

   ok=FALSE; cnt_shown=FALSE;

   wind_get(0,WF_TOP,&whand,&dummy,&dummy,&dummy);
   windex=set_windex(whand);

   if(whand==0 || windex==(-1))
      return;

   old_x=window[windex].wxindex; old_y=window[windex].wyindex;

   switch(kr)
   {
      case 0x5200: /* Insert -- change top window */
      {
         found=FALSE;

         for(i=windex+1; i<NUM_WINDS; i++)
         {
            if(window[i].wopen)
            {
               windex=i;
               found=TRUE;
               break;
            }
         }   

         if(!found && windex>(-1)) 
         {
            for(i=0; i<=windex; i++)
            {
               if(window[i].wopen)
               {
                  windex=i;
                  break;
               }
            }
         }

         if(windex>(-1) && window[windex].wopen)
         {
            if(sel_windex!=(-1))
               sel_clear(&window[sel_windex].work_area,TRUE);

            top_window(window[windex].whandle,TRUE);
            clr_tops();
            window[windex].wtopped=TRUE;
            topped=window[windex].whandle;

            if(window[windex].wcontents>=WC_REPORT)
               shown_count(windex);
         }
         break;
      }
      case 0x4700: /* Clr/Home -- full window */
      {
         if(window[windex].wcontents>=WC_REPORT)
         {
            if(sel_windex!=(-1))
               sel_clear(&window[sel_windex].work_area,TRUE);
            fulled(whand);
            shown_count(windex);
            set_sliders(whand,window[windex].wcontents);
         }
         break;
      }
      case 0x4800: /* Up Arrow - page up */
      {
         if(window[windex].wcontents==WC_CALENDAR)
            window[windex].wxindex--;
         else if(window[windex].wcontents>=WC_REPORT)
            window[windex].wyindex-=window[windex].wshown;
         ok=TRUE;
         cnt_shown=TRUE;
         break;
      }
      case 0x5000: /* Down Arrow -- page down */
      {
         if(window[windex].wcontents==WC_CALENDAR)
            window[windex].wxindex++;
         else if(window[windex].wcontents>=WC_REPORT)
            window[windex].wyindex+=window[windex].wshown;
         ok=TRUE;
         cnt_shown=TRUE;
         break;
      }
      case 0x4b00: /* Left Arrow -- page left */
      {
         if(window[windex].wcontents==WC_CALENDAR)
            window[windex].wyindex--;
         else if(window[windex].wcontents>=WC_REPORT)
            window[windex].wxindex-=(window[windex].work_area.g_w/8);
         ok=TRUE;
         break;
      }
      case 0x4d00: /* Right Arrow -- page right */
      {
         if(window[windex].wcontents==WC_CALENDAR)
            window[windex].wyindex++;
         else if(window[windex].wcontents>=WC_REPORT)
            window[windex].wxindex+=(window[windex].work_area.g_w/8);
         ok=TRUE;
         break;
      }
   }

   if(ok && window[windex].wcontents>=WC_REPORT)
      rpt_boundaries(windex);

   if(ok && (old_x!=window[windex].wxindex || old_y!=window[windex].wyindex))
   {
      if(cnt_shown && window[windex].wcontents>=WC_REPORT)
         shown_count(windex);

      set_sliders(whand,window[windex].wcontents);

      if(window[windex].wcontents==WC_CALENDAR)
      {
         if(cal_idx!=windex)
            cal_idx=windex;
         draw_cal(windex,&window[windex].work_area);
      }
      else if(window[windex].wcontents>=WC_REPORT)
      {
         if(sel_windex!=(-1))
            sel_clear(&window[sel_windex].work_area,TRUE);
         wind_report(windex,&window[windex].work_area);
      }
   }
}

