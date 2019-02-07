/* S27.C */

#include "portab.h"
#include "obdefs.h"
#include "osbind.h"
#include "d:ctools.h"
#include "d:year.h"
#include "d:schedule.h"

#define ADD (Y2FEB1-Y2JAN1)

EXTERN LONG menu_tree;

EXTERN WORD cal_flags[31];

EXTERN BYTE sys_date[9];

WORD obj_one[12]={Y2JAN1,Y2FEB1,Y2JAN1+ADD*2,Y2JAN1+ADD*3,
                  Y2JAN1+ADD*4,Y2JAN1+ADD*5,Y2JAN1+ADD*6,Y2JAN1+ADD*7,
                  Y2JAN1+ADD*8,Y2JAN1+ADD*9,Y2JAN1+ADD*10,Y2JAN1+ADD*11};

do_year_calendar()
{
   OBJECT *tree;

   hide_windows();

   rsrc_free();
   rsrc_load("YEAR.RSC");

   rsrc_gaddr(0,TYEARCAL,&tree);

   year_init(tree);

   do_dialog(tree,TYEARCAL,0,1,0);

   rsrc_free();
   rsrc_load("SCHEDULE.RSC");
   menu_tnormal(menu_tree,MCALEND,TRUE);

   show_windows();
}

year_init(tree)
OBJECT *tree;
{
   MLOCAL BYTE **tedptr,res_date[9],mn_str[3],yr_str[5],dy_str[3];
   REG WORD i,mn,dy,yr,first_used;
   
   wind_update(1);

   yr=1988;
   itoa(yr,yr_str);

   for(mn=1; mn<13; mn++)
   {
      itoa(mn,mn_str);

      strcpy(res_date,yr_str);
      chg_chr(yr_str,'0','O');
      if(mn<10)
         strcat(res_date,"0");
      strcat(res_date,mn_str);
      strcat(res_date,"01");

      for(i=obj_one[mn-1]; i<=obj_one[mn-1]+36; i++)
         objc_change(tree,i,0,0,0,0,0,NORMAL,0);

      flag_cal(res_date);

      first_used=wday(res_date)-1;

      for(i=obj_one[mn-1]; i<obj_one[mn-1]+first_used; i++)
      {
         tedptr=tree[i].ob_spec;
         strcpy(*tedptr,"  ");
      }

      dy=0;

      for(i=obj_one[mn-1]+first_used; i<=obj_one[mn-1]+36; i++)
      {
        dy++;
        if(dy>num_days(mn,yr))
           strcpy(dy_str,"  ");
        else
        {
           itoa(dy,dy_str);
           if(cal_flags[dy-1]==TRUE)
              set_state(tree,i,SELECTED);
           if(year(sys_date)==yr && month(sys_date)==mn && mday(sys_date)==dy)
              set_state(tree,i,DISABLED);
        }
        chg_chr(dy_str,'0','O');
        tedptr=tree[i].ob_spec;
        strcpy(*tedptr,rjustify(dy_str,2));
      }
   }

   wind_update(0);
}

