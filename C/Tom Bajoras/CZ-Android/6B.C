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

extern int zoomxy[],color[];
extern char ednorm[],wsnorm[];
extern int xyarray[];
extern int z_xy[];
extern int qlines[];
extern int envx,offset;      /* global envelope info */
extern int fullmode,lowpix,highpix,lowpeg,highpeg;
extern int zspoint[];      /* coords for envelope points, scroll mode */
extern int zfpoint[];      /* coords for envelope points, full mode */
extern char charbuf[];     /* for text output to screen */
extern int Ndiffer;
extern char levsave[],sustsave[];
#define MAXPIX 1500
extern int repeat;           /* allow mouse repeat for scrolling */
extern long totalT;          /* current envelope total real time */
extern int npoints;          /* # of points on scroll page */
extern int p_point[];      /* points on scroll page */
extern int zsbelow,zsabove;  

/*.................................. undo key ................................*/

z_undo(mousex,mousey)
register int mousex,mousey;
{
   int par,i,step;

/* SUSTAIN/END POINTS */
   if ((mousex>=263)&&(mousex<=455)&&(mousey>=157*rez)&&(mousey<=162*rez))
   {
      if (ednorm[offset]!=wsnorm[offset])
      {
         mousex= 24*wsnorm[offset] + 263;
         do_zoom(mousex,mousey,2,0);   /* undo end point */
      }
      if (ednorm[offset+17]!=wsnorm[offset+17])
      {
         if (wsnorm[offset+17]==8)
            mousex= 24*ednorm[offset+17] + 263;
         else
            mousex= 24*wsnorm[offset+17] + 263;
         do_zoom(mousex,mousey,1,0);   /* undo sustain point */
      }
      levsave[envx]=0;   sustsave[envx]=9;
      return;
   } /* end sustain/end points */

/* WHOLE ENVELOPE */
   if (  (mousex>193)&&(mousex<470)&&(mousey>55*rez)&&(mousey<115*rez)  )
   {
      v_hide_c(gl_hand);
      uncurve();
      for (i=0; i<=17; i++) ednorm[offset+i]=wsnorm[offset+i];
      curve();        /* new curve */
      z_pars();
      echoback();           /* update edit window behind zoom window */
      v_show_c(gl_hand,0);
      monedit(ednorm);
      return;
   } /* end whole envelope */

/* RATE/LEVEL */
   if ((mousex>=264)&&(mousex<=448))
   {
      par=500;   /* default meaning not level or rate */
      step=(mousex-264)/23;                 
      if ((mousey>=rez*138)&&(mousey<=rez*146))     /* rate */
         par= offset+1+2*step;                 /* parameter # */
      else
      {
         if ((mousey>=rez*147)&&(mousey<=rez*155))    /* level */
         {                               /* can't un-edit at end */
            if (step==ednorm[offset]) return(0); 
            par= offset+2+2*step;             /* parameter # */
         }
      }
      if (par==500) return;
      if (ednorm[par]==wsnorm[par]) return;   /* no un-edit needed */
      v_hide_c(gl_hand);
      uncurve();                 /* erase old curve */
      ednorm[par]=wsnorm[par];  
      curve();        /* new curve */
      encode(charbuf,ednorm[par],2,1);
      v_gtext(gl_hand,264+24*step,rez*(155-(par%2)*9),charbuf);
      texttype(0);
      v_gtext(gl_hand,281+24*step,rez*(154-(par%2)*9)+2-2*rez,&" ");
      texttype(1);
      echoback();           /* update edit window behind zoom window */
      v_show_c(gl_hand,0);
      monedit(ednorm);
   } /* end rate/level */

} /* end z_undo(mousex,mousey) */

/*........................... draw zoom window ...............................*/

z_window()
{
   register int i;
   int tempxy[8];

   v_hide_c(gl_hand);            /* hide mouse during this */
   vsf_color(gl_hand,1);
   vsf_interior(gl_hand,0);      /* paint background */
   /* no vsf_style needed for interior 0 */
   vsf_perimeter(gl_hand,1);     /* outlined */
   for (i=0; i<=6; i=i+2) tempxy[i]= z_xy[i];
   for (i=1; i<=7; i=i+2) tempxy[i]= rez*z_xy[i];
   v_fillarea(gl_hand,4,tempxy);
   xyarray[0]= z_xy[0]+3;   xyarray[1]= rez*(z_xy[1]+2);
   xyarray[2]= z_xy[2]-3;   xyarray[3]= rez*(z_xy[3]+2);
   xyarray[4]= z_xy[4]-3;   xyarray[5]= rez*(z_xy[5]-2);
   xyarray[6]= z_xy[6]+3;   xyarray[7]= rez*(z_xy[7]-2);
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
   if (envx==0) strcpy(charbuf," DCO 1 ");
   if (envx==1) strcpy(charbuf," DCW 1 ");
   if (envx==2) strcpy(charbuf," DCA 1 ");
   if (envx==3) strcpy(charbuf," DCO 2 ");
   if (envx==4) strcpy(charbuf," DCW 2 ");
   if (envx==5) strcpy(charbuf," DCA 2 ");
   v_gtext(gl_hand,304,rez*45,charbuf);
/* more lines */
   for (i=0; i<=28; i=i+4)
   {
      tempxy[0]= qlines[i];   tempxy[1]= rez*qlines[i+1];
      tempxy[2]= qlines[i+2]; tempxy[3]= rez*qlines[i+3];
      v_pline(gl_hand,2,tempxy);
   }
/* indicate full mode */
   vsf_interior(gl_hand,1);
   xyarray[0]=163;   xyarray[1]=124*rez; 
   xyarray[2]=262;   xyarray[3]=124*rez;
   xyarray[4]=262;   xyarray[5]=136*rez;
   xyarray[6]=163;   xyarray[7]=136*rez;
   v_fillarea(gl_hand,4,xyarray);      
   vswr_mode(gl_hand,3);
   v_gtext(gl_hand,177,133*rez,&"Full Mode");
   vswr_mode(gl_hand,1);
   v_gtext(gl_hand,384,133*rez,&"Scroll Mode");
/* no arrows (because we are in full mode) */
   z_pars();        /* display parameters */
/* axes */
   xyarray[0]=192; xyarray[1]=55*rez; xyarray[2]=192; xyarray[3]=115*rez;
   xyarray[4]=470; xyarray[5]=115*rez;
   v_pline(gl_hand,3,xyarray);
/* y tic marks */
   xyarray[0]=188; xyarray[2]=192;
   for (i=0; i<=5; i++)
   {
      if (i)
         encode(charbuf,100-20*i,2,1);
      else
         encode(charbuf,99,2,1);
      v_gtext(gl_hand,167,rez*(58+ 12*i),charbuf);
      xyarray[1]= xyarray[3]= rez*(55+ 12*i);
      v_pline(gl_hand,2,xyarray);
   }
   curve();       /* display the envelope */
   
   v_show_c(gl_hand,0);          /* restore mouse */
} /* end z_window() */

/*...............................(un)draw envelope ...........................*/

curve()          /* note: mouse is invisible already */
{
   register int i;
   int R,L1,L2;
   long f_scale,s_scale;
   long time[8];
   long Time();
   long xx;

   dot();            /* dotted lines */
   if (!ednorm[offset]) return;  /* can't draw a dot */
/* set up zspoint and zfpoint arrays */
   totalT= 0L;     /* init total time */
   for (i=0; i<=ednorm[offset]; i++)
   {
      if (!i) 
         L1=0;
      else
         L1=L2;
      L2= ednorm[offset+2+2*i];
      R= ednorm[offset+1+2*i];   
      time[i]= Time(L1,L2,R);
      totalT= totalT+time[i];
   } /* end for (i=0; i<=ednorm[offset]; i++) */
   f_scale= totalT/278  +1;   /* time per pixel */
   s_scale= totalT/(MAXPIX+1) +1;
   zfpoint[0]= 193;   zfpoint[1]= 115*rez;
   zspoint[0]= 0;     zspoint[1]= 115*rez;
   for (i=0; i<=ednorm[offset]; i++)
   {
      zfpoint[2*i+2]= zfpoint[2*i] + time[i]/f_scale;
      zspoint[2*i+2]= zspoint[2*i] + time[i]/s_scale;
      zspoint[2*i+3]= zfpoint[2*i+3]= rez*(115- (60*ednorm[offset+2+2*i])/99);
   }
   /* scroll across all available pixels */
   if (zspoint[2*ednorm[offset]+2] < MAXPIX)
   {
      for (i=0; i<=ednorm[offset]+1; i++)
      {
         xx= zspoint[2*i] * MAXPIX;
         zspoint[2*i]= xx / zspoint[2*ednorm[offset]+2];
      }
   }
   if (zfpoint[2*ednorm[offset]+2] < 470)
   {
      for (i=0; i<=ednorm[offset]+1; i++)
      {
         xx= 277*(zfpoint[2*i]-193);
         zfpoint[2*i]= 193 + xx / (zfpoint[2*ednorm[offset]+2]-193);
      }
   }
   do_curve();
} /* end curve() */
   
do_curve()             /* note: mouse is invisible already */
{                      /*       and end != 0               */
   int i,test;
   int p=0;            /* index into p_point array */
   long x1,x2,y1,y2;    /* for interpolation */
   
   set_clip(193,rez*50,283,rez*65);   /* set clipping to not damage axes */
   vsl_color(gl_hand,2);  /* use color #2 for curve */
   if (fullmode)
   {
      v_pline(gl_hand,ednorm[offset]+2,zfpoint);
      polymark(ednorm[offset],&zfpoint[2]);
   }
   else
   {
      /* loop through all zspoints up to env end point, looking for points
      which belong on this page */
      npoints=0;
      for (i=0; i<=(ednorm[offset]+1); i++)
      {
         if ((zspoint[2*i] > lowpix)&&(zspoint[2*i] < highpix))
         {          /* found one */
            npoints++;
            p_point[p++]= zspoint[2*i] - lowpix + 193;
            p_point[p++]= zspoint[2*i+1];
         }
         if ((zspoint[2*i] <= lowpix)&&(zspoint[2*i+2] > lowpix))
         {       /* interpolate low point */
            npoints++;
            x1= zspoint[2*i];     x2= zspoint[2*i+2];
            y1= zspoint[2*i+1];   y2= zspoint[2*i+3];
            zsbelow= i;
            p_point[p++]= 193;
            p_point[p++]= y1 + ((lowpix-x1)*(y2-y1))/(x2-x1);
         }
         if ((zspoint[2*i] < highpix)&&(zspoint[2*i+2] >= highpix)
            &&(i<=ednorm[offset]))
         {       /* interpolate high point */
            npoints++;
            x1= zspoint[2*i];     x2= zspoint[2*i+2];
            y1= zspoint[2*i+1];   y2= zspoint[2*i+3];
            zsabove=i+1;
            p_point[p++]= 470;
            p_point[p++]= y1 + ((highpix-x1)*(y2-y1))/(x2-x1);
         }
      } /* end for (i=0; i<=(ednorm[offset]+1); i++) */
      v_pline(gl_hand,npoints,p_point);
      polymark(npoints-2,&p_point[2]);
   }
   vsl_color(gl_hand,1);   /* back to color #1 for v_pline calls */
   vs_clip(gl_hand,0,&dummy);      /* clipping back off */
} /* end do_curve() */

uncurve()          /* note: mouse is invisible already */
{
   if (!ednorm[offset]) return;  /* can't draw a dot */
   vsl_type(gl_hand,7);
   vsl_udsty(gl_hand,0);   /* line style = invisible */
   do_curve();
   vsl_type(gl_hand,1);    /* back to solid line */
} /* end uncurve() */

/*............................... full/scroll mode ...........................*/

z_mode()                /* note: mouse is invisible already */
{
/* de-select button */   
   vsf_interior(gl_hand,0);                      
   xyarray[0]=377-214*fullmode;   xyarray[1]=124*rez; 
   xyarray[2]=476-214*fullmode;   xyarray[3]=124*rez;
   xyarray[4]=476-214*fullmode;   xyarray[5]=136*rez;
   xyarray[6]=377-214*fullmode;   xyarray[7]=136*rez;
   v_fillarea(gl_hand,4,xyarray);      
   if (fullmode)
      v_gtext(gl_hand,177,133*rez,&"Full Mode");
   else
      v_gtext(gl_hand,384,133*rez,&"Scroll Mode");
/* toggle mode */
   if (fullmode)
      fullmode=0;
   else
      fullmode=1;
/* select new button */
   vsf_interior(gl_hand,1);
   xyarray[0]=377-214*fullmode; xyarray[2]=476-214*fullmode; xyarray[3]=124*rez;
   xyarray[4]=476-214*fullmode; xyarray[6]=377-214*fullmode; xyarray[7]=136*rez;
   v_fillarea(gl_hand,4,xyarray);      
   vswr_mode(gl_hand,3);
   if (fullmode)
      v_gtext(gl_hand,177,133*rez,&"Full Mode");
   else
      v_gtext(gl_hand,384,133*rez,&"Scroll Mode");
   vswr_mode(gl_hand,1);      

} /* end z_mode() */


/*..................... update edit window behind zoom window ................*/

echoback()        /* note: mouse is already invisible */
{
   register int i;

   i=ndiffer();             /* update Ndiffer and info line */
   if (i!=Ndiffer)
   {
      encode(charbuf,i,3,0);
      v_gtext(gl_hand,432,27*rez+2,charbuf);
      Ndiffer=i;
   } 
   if ((envx==1)||(envx==4)) return(0);     /* DCW envelopes are hidden */
   if ((envx==0)||(envx==3))                /* DCA/DCO envs partially hidden */
      set_clip(0,0,158,200*rez);
   else
      set_clip(482,0,158,200*rez);
   for (i=0; i<=17; i++)        /* update visible portions of DCA/DCO */
      outpar(ednorm,offset+i);
   vs_clip(gl_hand,0,&dummy);   /* turn clipping back off */
} /* end echoback() */

/*...............................  dotted lines ..............................*/

dot()        /* note: mouse already invisible */
{
   register int i;

/* dotted lines */
   vsl_type(gl_hand,3);
   xyarray[0]=197;  xyarray[2]=470;
   for (i=0; i<=4; i++)
   {
      xyarray[1]= xyarray[3]= rez*(55+ 12*i);
      v_pline(gl_hand,2,xyarray);
   }
   vsl_type(gl_hand,1);  /* back to solid lines */   
} /* end dot() */

/*................... compute an envelope segment realtime ...................*/

long Time(L1,L2,R)
int L1,L2,R;
{
   long k,q,aa,d,a1,a2;
   int i,rate,temp1,temp2;
   long Alev();

/* convert R into rate */
   rate= (119*R)/99;

/*** note: The following code causes DCW envelopes to behave strangely ...

   if ((envx==0)||(envx==3)) rate= (127*R)/99;      
   if ((envx==1)||(envx==4)) rate= (119*R)/99+8;    
   if ((envx==2)||(envx==5)) rate= (119*R)/99;     ***/

/* calculate differential rate d */
   temp1= rate>>3;
   temp2= rate&7;
   d= 8L+temp2;
   if (temp1>8) d=(2*d+1)<<(temp1-9);
/* calculate ratio factor q */
   temp1= rate>>3;
   if (temp1>=8)
      q=1L;
   else
      q= 1L<<(8-temp1);
/* convert levels into absolute levels a1,a2 */
   a1= Alev(L1);
   a2= Alev(L2);
/* get adding rate constant k */
   k= 5L;

/*** note: The following code causes DCW envelopes to behave strangely ...

   if ((envx==2)||(envx==5)) k=5L;
   if ((envx==1)||(envx==4)) k=10L;
   if ((envx==0)||(envx==3)) k=20L;         ***/

/* get absolute difference of absolute levels aa */
   if ((a2-a1)>=0L)
      aa= a2-a1;
   else
      aa= a1-a2;
/* return the result */
   k= ((k*q*aa)/d)/100;
   return(k);
} /* end Time(L1,L2,R) */

long Alev(L)          /* convert level into absolute level */
int L;
{
   int temp1;
   long LL;

   return(    LL=(L+28)<<9   );

/*** note: The following code causes DCW envelopes to behave strangely ...

   if ((envx==2)||(envx==5)) return(    LL=(L+28)<<9   );
   if ((envx==1)||(envx==4)) return(    LL=((127*L)/99)<<9   );
   if ((envx==0)||(envx==3)) 
   {
      temp1=L;
      if (L>=64) temp1=temp1+4;
      if (temp1&0x40)
         return(    LL=temp1<<10   );
      else
         return(    LL=(temp1<<6) & 0x00000fff   );
   }            ***/

} /* end Alev(L) */

/*............................. poly markers .................................*/

polymark(n,array)
register int n;
int array[];
{
   register int i;
   int box[10];
   int p=0;

   vsl_color(gl_hand,1);   /* markers are black */
   for (i=1; i<=n; i++)
   {
      box[0]= array[p++]-2;   box[1]= array[p++]-2;
      if (box[0]<193) box[0]=193;
      if (box[1]>rez*115-4) box[1]=rez*115-4;
      if (box[0]>466) box[0]=466;
      box[2]= box[0]+4;       box[3]= box[1];
      box[4]= box[2];         box[5]= box[3]+4;
      box[6]= box[0];         box[7]= box[5];
      box[8]= box[0];         box[9]= box[1];
      v_pline(gl_hand,5,box);
   }
} /* end polymark(n,array) */

/*........................... display rates/levels .......................... */

z_pars()   /* note: mouse is invisible during this */
{
   register int i;

/* rates */
   v_gtext(gl_hand,193,146*rez,&"Rates:");
   for (i=0; i<=14; i=i+2)
   {
      encode(charbuf,ednorm[offset+1+i],2,1);
      v_gtext(gl_hand,264+24*i/2,146*rez,charbuf);
   }
/* levels */
   v_gtext(gl_hand,193,155*rez,&"Levels:");
   for (i=0; i<=14; i=i+2)
   {
      encode(charbuf,ednorm[offset+2+i],2,1);
      v_gtext(gl_hand,264+24*i/2,155*rez,charbuf);
   }
/* sustain/end points */
   texttype(0);
   for (i=0; i<=7; i++)
   {
      if (i==ednorm[offset+17])
         v_gtext(gl_hand,263+24*i,160*rez,&"sus");
      else
      {
         if (i==ednorm[offset])
            v_gtext(gl_hand,263+24*i,160*rez,&"end");
         else
            v_gtext(gl_hand,263+24*i,160*rez,&"   ");
      }
   }
/* indicate edited parameters */
   for (i=1; i<=16; i++)
   {
      if (ednorm[offset+i] > wsnorm[offset+i])
         v_gtext(gl_hand,281+24*((i-1)/2),rez*(154-(i%2)*9)+2-2*rez,&"+");
      if (ednorm[offset+i] < wsnorm[offset+i])
         v_gtext(gl_hand,281+24*((i-1)/2),rez*(154-(i%2)*9)+2-2*rez,&"-");
      if (ednorm[offset+i] == wsnorm[offset+i])
         v_gtext(gl_hand,281+24*((i-1)/2),rez*(154-(i%2)*9)+2-2*rez,&" ");
   }
   if ((ednorm[offset] != wsnorm[offset])||
      (ednorm[offset+17] != wsnorm[offset+17]))
      v_gtext(gl_hand,450,160*rez,&"*");
   else
      v_gtext(gl_hand,450,160*rez,&" ");
   texttype(1);
} /* end z_pars() */

/*....................... miniature/normal-sized text ........................*/

texttype(normal)
register int normal;
{
   if (normal)
   {
      if (rez==1)
         vst_height(gl_hand,6,&dummy,&dummy,&dummy,&dummy);
      else
         vst_point(gl_hand,13,&dummy,&dummy,&dummy,&dummy);
   }
   else
   {
      if (rez==1)
         vst_height(gl_hand,4,&dummy,&dummy,&dummy,&dummy);
      else
         vst_point(gl_hand,8,&dummy,&dummy,&dummy,&dummy);
   }
} /* end texttype(normal) */

/* EOF */
