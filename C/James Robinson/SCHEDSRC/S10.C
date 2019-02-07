/* S10.C -- SORT RECORDS */

#include "obdefs.h"
#include "gemdefs.h"
#include "schdefs.h"

extern int dummy;

extern CUSTOM data_entry;

sort_cal(v,n)
RECORD v[];
int  n;
{
   register int i,j,gap,brk1,brk2;

   graf_mouse(HOURGLASS,&dummy);

   wind_update(1);

   for(gap=n/2; gap>0; gap/=2)
   {
      for(i=gap; i<n; i++)
      {
         for(j=i-gap; j>=0; j-=gap)
         {
            brk1=brk2=FALSE;

            if(strcmp(v[j].rdate,v[j+gap].rdate)<0)
               break;
            else if(strcmp(v[j].rdate,v[j+gap].rdate)==0 &&
                    (data_entry.dstime &&
                     strcmp(v[j].rstime,v[j+gap].rstime)<0))
               break;
            else if(strcmp(v[j].rdate,v[j+gap].rdate)==0 &&
                    (data_entry.dstime &&
                     strcmp(v[j].rstime,v[j+gap].rstime)==0) &&
                    (data_entry.detime && 
                     strcmp(v[j].retime,v[j+gap].retime)<0))
               break;

            if(strcmp(v[j].rdate,v[j+gap].rdate)==0 &&
               (data_entry.dstime && strcmp(v[j].rstime,v[j+gap].rstime)==0))
               brk1=TRUE;

            if(brk1 &&
              (data_entry.dsubj && strcmp(v[j].rsubj,v[j+gap].rsubj)<0))
               break;

            if(brk1 &&
              (data_entry.dsubj && strcmp(v[j].rsubj,v[j+gap].rsubj)==0) &&
               strcmp(v[j].rdescr[0],v[j+gap].rdescr[0])<=0)
               break;

            swap_rec(&v[j],&v[j+gap]);
         }
      }
   }

   wind_update(0);

   graf_mouse(ARROW,&dummy);
}

swap_rec(px,py)
RECORD *px,*py;
{
   RECORD temp;

   temp = *px;
   *px  = *py;
   *py  = temp;
}

