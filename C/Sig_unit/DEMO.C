 /*---------signu -Fonts ct. 6-90 290 FK */

#define _MAINMOD_


#include <tos.h>
#include "sig_unit.h"

#include <gemmakro.h>

/*
int handle,gem_handle,dummy;
int work_in={1,1,1,1,1,1,1,1,1,1,2};
int work_out[57];
int VDI_x,VDI_y;
*/
/*
void init_gem(void)
{

 if (appl_init()==-1)  Pterm(0);

 gem_handle=graf_handle(&dummy,&dummy,&dummy,&dummy);
 work_in[0]=handle=gem_handle;
 v_opnvwk(work_in,&handle,work_out);
 if (handle<=0)
    {
     form_alert(1,"[3][Kein handle fr opnvwk()][Oh]");
     appl_exit();
     Pterm(0);
    }

 VDI_x=work_out[0];
 VDI_y=work_out[1];


 work_out[0]=0;
 work_out[1]=0;
 work_out[2]=VDI_x;
 work_out[3]=VDI_y;
 vs_clip(handle,1,work_out);

}


void exit_gem(void)
{
 v_clsvwk(handle);
 appl_exit();
}


*/

void main(void)
{
int i;
char s[3]={0,0,0};

 init_gem();

 if(load_sigFont("D:\\SIGNUM\\CHSETS\\GROTLT.E24"))
   {
    v_hide_c(handle);
    vsf_interior(handle,0);
    work_out[0]=20;
    work_out[1]=20;
    work_out[2]=VDI_x-20;
    work_out[3]=VDI_y-20;
    v_bar(handle,work_out);

    work_out[0]=work_out[2]=320;
    v_pline(handle,2,work_out);


    work_out[0]=VDI_x/2;
    work_out[2]=360;


    for(i=0;i<3;i++)
       {
       set_sigpar(4,0,20,SIG_TRANSPARENT,0,SIG_LEFT+i,0);
       prt_text(320,50+i*20,"SIGNUM-E24_Font (hor. Ausrichtung)");
       }

    work_out[0]+=1;
    vsl_ends(handle,0,1);
    for(i=0;i<3;i++)
    {
      work_out[1]=work_out[3]=(VDI_y/2-50)+i*30;
      v_pline(handle,2,work_out);
      set_sigpar(4,0,20,SIG_TRANSPARENT,0,SIG_LEFT,i+SIG_BASE);
      prt_text(365,work_out[1],"SIGNUM-E24_Font (vert. Ausrichtung)");
    }
    vsl_ends(handle,0,0);


   set_sigpar(4,0,20,SIG_TRANSPARENT,0,0,0);

   for(i=32;i<256;i++)
   {
    *s=(char)i;
    prt_text(30+i%16*15,150+i/16*22,s);
   }

   set_sigpar(4,1,20,SIG_TRANSPARENT,SIG_FETT|SIG_UNDER,SIG_CENTER,0);
   prt_text(150,370,"Zeichensatz (unvollst„ndig) !");

   set_sigpar(4,1,20,SIG_TRANSPARENT,SIG_UNDER,0,0);
   prt_text(340,290,"Diese Zeile ist unterstrichen");

   set_sigpar(4,1,20,SIG_TRANSPARENT,SIG_FETT,0,0);
   prt_text(340,310,"Das ist Fettschrift");

   set_sigpar(4,1,20,SIG_TRANSPARENT,SIG_HELL,0,0);
   i=prt_text(340,330,"Die Hellschrift ist ");
   set_sigpar(4,0,20,SIG_TRANSPARENT,0,SIG_LEFT,0);
   prt_text(i,330,"nicht immer sinnvoll");

   set_sigpar(4,1,20,SIG_TRANSPARENT,SIG_ITALIC,0,0);
   prt_text(340,350,"Evt. geht auch Kursivschrift ");

   set_sigpar(4,1,20,SIG_TRANSPARENT,SIG_ITALIC|SIG_HELL,0,0);
   prt_text(340,370,"und hell mit Kursivschrift ");

   Bconin(2);
   unload_sigFont();
   v_show_c(handle,0);
  }
   else form_alert(1,"[3][Konnte Font nicht laden][Schluž]");

 exit_gem();
