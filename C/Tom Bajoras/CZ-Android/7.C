/*........................ include header files ..............................*/

#include <vdibind.h>    /* VDI stuff */
#include <gemdefs.h>    /* AES stuff */
#include <obdefs.h>     /* more AES stuff */
#include <osbind.h>     /* GEMDOS, BIOS, XBIOS stuff */
#include <taddr.h>      /* OB macros */
#include <portab.h>     
#include <machine.h>    /* LW macros */
#include <cz_andrd.h>   /* created by RCS */

#include <defines.h>
#include <externs.h>

/*............................ global variables ..............................*/

extern char ednorm[],wsnorm[];
extern int eddata[];
int xyarray[8];
int cz1_xy[8]= {158, 35,481, 35,481,114,158,114}; /* cz1pars window coords */
int gridxy[36]= {155,29,311,29,   155,39,311,39,   155,40,311,40,
                 155,50,311,50,   155,60,311,60,   155,70,311,70,
                 155,29,155,70,   236,29,236,70,   311,29,311,70};
int arrowxy[40]={81,46,113,46,   113,46,110,43,   113,46,110,49,
                 81,46,81,66,
                 81,56,101,56,   101,56,98,53,   101,56,98,59,
                 81,66,97,66,    97,66,94,63,    97,66,94,69   };
char charbuf[20];     /* for text output to screen */
int ed_skip=0;        /* flag used by ed_draw() and ed_window() in 5b */
extern int Ndiffer;

/*............................ cz1 mode executive ............................*/

cz1pars()
{
   FDB savefdb;
   int mousex,mousey,mstate,i,kstate;
   int done=0;
   int mbefore=0;
   int key,event;

/* grab mouse control off of AES */
   wind_update(3);
/* turn clipping off during all of module 7 */
   vs_clip(gl_hand,0,&dummy);   

/* save screen which will lie under cz1pars window */
   savefdb.fd_addr= saveptr;
   savefdb.fd_w= 640;
   savefdb.fd_h= 200*rez;
   savefdb.fd_wdwidth= 40;
   savefdb.fd_stand= 0;
   if (rez==1)
      savefdb.fd_nplanes= 2;
   else
      savefdb.fd_nplanes= 1;
   xyarray[0]= cz1_xy[0]; xyarray[1]= rez*cz1_xy[1]; 
   xyarray[2]= cz1_xy[2]; xyarray[3]= rez*cz1_xy[7];
   xyarray[4]= 0;   xyarray[5]= 0;
   xyarray[6]= cz1_xy[2]-cz1_xy[0];   xyarray[7]= rez*(cz1_xy[7]-cz1_xy[1]);
   v_hide_c(gl_hand);   
   if (saveptr) vro_cpyfm(gl_hand,3,xyarray,&scrfdb,&savefdb);
   v_show_c(gl_hand,0); 
   graf_growbox((cz1_xy[0]+cz1_xy[2])/2,rez*(cz1_xy[1]+cz1_xy[5])/2,1,1,
                cz1_xy[0],cz1_xy[1],
                cz1_xy[2]-cz1_xy[0]+1,rez*(cz1_xy[7]-cz1_xy[1])+1);
   cz1_wind();     /* put up cz1pars window */

/* executive loop */
   while (!done)
   {
      vq_mouse(gl_hand,&mstate,&mousex,&mousey);
      kstate=Kbshift(0xffff);
      if ((mstate&3)&&!mbefore)
         done= do_cz1(mousex,mousey,mstate,kstate);
      event= evnt_multi(MU_TIMER|MU_KEYBD,0,0,0,0,0,0,0,0,0,0,0,0,0,
             &dummy,1,0,&mousex,&mousey,&dummy,&dummy,&key,&dummy);    
      if ((event & MU_KEYBD)&&(key==0x6100)) cz1_undo(mousex,mousey);
      mbefore=mstate;
   }

   vs_clip(gl_hand,0,&dummy);   /* turn clipping off (clobbered by redraw */
/* restore the screen */
   xyarray[0]= 0;    xyarray[1]= 0;   
   xyarray[2]= cz1_xy[2]-cz1_xy[0];   xyarray[3]= rez*(cz1_xy[7]-cz1_xy[1]);
   xyarray[4]= cz1_xy[0];  xyarray[5]= rez*cz1_xy[1];  
   xyarray[6]= cz1_xy[2];  xyarray[7]= rez*cz1_xy[7];
   if (saveptr)
   {
      v_hide_c(gl_hand);
      vro_cpyfm(gl_hand,3,xyarray,&savefdb,&scrfdb);
      v_show_c(gl_hand,0);
   }
   else
      redraw(ws_hand,cz1_xy[0],rez*cz1_xy[1],
             cz1_xy[2]-cz1_xy[0]+1,rez*(cz1_xy[7]-cz1_xy[1])+1);
   graf_shrinkbox((cz1_xy[0]+cz1_xy[2])/2,rez*(cz1_xy[1]+cz1_xy[5])/2,1,1,
                cz1_xy[0],cz1_xy[1],
                cz1_xy[2]-cz1_xy[0]+1,rez*(cz1_xy[7]-cz1_xy[1])+1);   
/* return mouse control to AES */
   wind_update(2);

} /* end cz1pars() */

/*........................... handle mouse click .............................*/

do_cz1(mousex,mousey,right,shift)   /* returns 1 done, 0 not done */
register int mousex,mousey;
int right,shift;
{
   int i,par,mstate;
   char codebuf[10];

/* condition arguments */
   if (right&1)
      right=0;
   else
      right=1;
   if (shift&3)
      shift=1;
   else
      shift=0;

/* OUTSIDE OF CZ1PARS WINDOW: */
   if ((mousex>481)||(mousex<158)||(mousey>rez*114)||(mousey<rez*35))
   {
      Cconout(7);     /* bell */
      return(0);
   } 

/* CLOSE: */
   if ((mousex>=161)&&(mousex<=184)&&
       (mousey>=rez*37)&&(mousey<=rez*47)&&!right)
      return(1);

/* EDIT A PARAMETER */

/* edit which parameter? */
   par=500;  
   for (i=762; i<=804; i=i+6)
   {
      if ((mousex>=eddata[i])&&(mousex<=(eddata[i]+eddata[i+2]))&&
          (mousey>=rez*(eddata[i+1]-eddata[i+3]))&&(mousey<=rez*eddata[i+1]))
      {   par=i/6;  break;   }
   }
   if (par==500) return(0);    /* mouse clicked not on a parameter */

/* determine increment/decrement amount */
   if (right)
      i=1;
   else
      i=(-1);

/* do the edit, wrap around in both directions */
   ednorm[par]= ednorm[par]+i;
   if ((par==130)||(par==134)) 
      i=1;
   else
      i=0;
   if (ednorm[par]<i) ednorm[par]= eddata[6*par+5]+1+ednorm[par]-i;
   if (ednorm[par]>eddata[6*par+5])
      ednorm[par]= ednorm[par]-eddata[6*par+5]-1+i;

   monedit(ednorm);
/* update screen */
   vs_clip(gl_hand,0,&dummy);
   v_hide_c(gl_hand);
   outpar(ednorm,par);
   v_show_c(gl_hand,0);

/* update info line */
   Ndiffer=ndiffer();
   ed_skip=1;
   redraw(ws_hand,0,0,0,0);
   ed_skip=0;
   return(0);
} /* end do_cz1(mousex,mousey,right,shift) */

/*.................................. undo key ................................*/

cz1_undo(mousex,mousey)
register int mousex,mousey;
{
   int i,par;
   char codebuf[10];

/* which parameter ? */
   par=500;  
   for (i=762; i<=804; i=i+6)
   {
      if ((mousex>=eddata[i])&&(mousex<=(eddata[i]+eddata[i+2]))&&
          (mousey>=rez*(eddata[i+1]-eddata[i+3]))&&(mousey<=rez*eddata[i+1]))
      {   par=i/6;  break;   }
   }
   if (par==500) return;    /* mouse clicked not on a parameter */

/* do the un-edit */
   if (ednorm[par]==wsnorm[par]) return;   /* no need to un-edit */
   ednorm[par]=wsnorm[par];
   monedit(ednorm);
   vs_clip(gl_hand,0,&dummy);
   v_hide_c(gl_hand);
   outpar(ednorm,par);
   v_show_c(gl_hand,0);

/* update info line */
   Ndiffer=ndiffer();
   ed_skip=1;
   redraw(ws_hand,0,0,0,0);
   ed_skip=0;

} /* end cz1_undo(mousex,mousey) */

/*........................... draw cz1pars window ............................*/

cz1_wind()
{
   register int i;
   int tempxy[8];

   v_hide_c(gl_hand);            /* hide mouse during this */
   vsf_color(gl_hand,1);
   vsf_interior(gl_hand,0);      /* paint background */
   /* no vsf_style needed for interior 0 */
   vsf_perimeter(gl_hand,1);     /* outlined */
   for (i=0; i<=6; i=i+2) tempxy[i]= cz1_xy[i];
   for (i=1; i<=7; i=i+2) tempxy[i]= rez*cz1_xy[i];
   v_fillarea(gl_hand,4,tempxy);
   xyarray[0]= cz1_xy[0]+3;   xyarray[1]= rez*(cz1_xy[1]+2);
   xyarray[2]= cz1_xy[2]-3;   xyarray[3]= rez*(cz1_xy[3]+2);
   xyarray[4]= cz1_xy[4]-3;   xyarray[5]= rez*(cz1_xy[5]-2);
   xyarray[6]= cz1_xy[6]+3;   xyarray[7]= rez*(cz1_xy[7]-2);
   v_fillarea(gl_hand,4,xyarray);   /* double outline */
   
/* simulate close box */
   charbuf[0]=5;  charbuf[1]=0;
   v_gtext(gl_hand,169,rez*45,charbuf);

/* simulate title bar */
   xyarray[0]=161; xyarray[1]=rez*47; xyarray[2]=478, xyarray[3]=rez*47;
   v_pline(gl_hand,2,xyarray);
   vsf_color(gl_hand,1);
   vsf_interior(gl_hand,2);
   vsf_style(gl_hand,2);
   vsf_perimeter(gl_hand,0);     /* not outlined */  
   xyarray[0]=185;  xyarray[1]=1+rez*37; xyarray[2]=477;  xyarray[3]= 1+rez*37;
   xyarray[4]=477;  xyarray[5]=rez*47-1; xyarray[6]=185;  xyarray[7]= rez*47-1;
   v_fillarea(gl_hand,4,xyarray);
   xyarray[2]=xyarray[6];   xyarray[3]=xyarray[7];
   v_pline(gl_hand,2,xyarray);
   v_gtext(gl_hand,264,rez*45,&" CZ-1 Parameters ");

/* grid */
   for (i=0; i<=8; i++)
   {
      tempxy[0]= gridxy[4*i]+cz1_xy[0];  
      tempxy[1]= rez*(cz1_xy[1]+gridxy[4*i+1]);
      tempxy[2]= gridxy[4*i+2]+cz1_xy[0];  
      tempxy[3]= rez*(cz1_xy[1]+gridxy[4*i+3]);
      v_pline(gl_hand,2,tempxy);
   }

/* text */
   v_gtext(gl_hand,170+cz1_xy[0],rez*(23+cz1_xy[1]),&"Line 1");
   v_gtext(gl_hand,250+cz1_xy[0],rez*(23+cz1_xy[1]),&"Line 2");
   v_gtext(gl_hand,104+cz1_xy[0],rez*(37+cz1_xy[1]),&"level:");
   v_gtext(gl_hand,120+cz1_xy[0],rez*(48+cz1_xy[1]),&"amp:");
   v_gtext(gl_hand,16+cz1_xy[0],rez*(58+cz1_xy[1]),&"Velocity");
   v_gtext(gl_hand,112+cz1_xy[0],rez*(58+cz1_xy[1]),&"wave:");
   v_gtext(gl_hand,104+cz1_xy[0],rez*(68+cz1_xy[1]),&"pitch:");

/* arrows */
   for (i=0; i<=9; i++)
   {
      tempxy[0]= arrowxy[4*i]+cz1_xy[0];  
      tempxy[1]= rez*(cz1_xy[1]+arrowxy[4*i+1]);
      tempxy[2]= arrowxy[4*i+2]+cz1_xy[0];  
      tempxy[3]= rez*(cz1_xy[1]+arrowxy[4*i+3]);
      v_pline(gl_hand,2,tempxy);
   }

/* display parameters */
   for (i=127; i<=134; i++)
      outpar(ednorm,i);
   
   v_show_c(gl_hand,0);          /* restore mouse */
} /* end cz1_wind() */

/* EOF */
