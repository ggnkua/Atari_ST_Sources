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
int xyarray[8];
int z_xy[8]= {158, 35,481, 35,481,165,158,165};   /* coords for zoom window */
int qlines[32]={161,124,478,124,161,136,478,136,  /* some lines */
                162,124,162,136,263,124,263,136,264,124,264,136,
                375,124,375,136,376,124,376,136,477,124,477,136};
int envx,offset;      /* global envelope info */
int fullmode,lowpix,highpix,lowpeg,highpeg;
int zspoint[18];      /* coords for envelope points, scroll mode */
int zfpoint[18];      /* coords for envelope points, full mode */
char charbuf[20];     /* for text output to screen */
extern int Ndiffer;
extern char levsave[],sustsave[];
#define MAXPIX 1500
int repeat;           /* allow mouse repeat for scrolling */
long totalT;          /* current envelope total real time */
int npoints;          /* # of points on scroll page */
int p_point[18];      /* points on scroll page */
int zsbelow,zsabove;  /* points on boundary or just next to scroll page */

/*........................... zoom mode executive ............................*/

zoom(Envx)
int Envx;  /* =0-5 DCO 1, DCW 1, DCA 1, DCO 2, DCW 2, DCA 2 */
{
   FDB savefdb;
   int mousex,mousey,mstate,i,kstate;
   int done=0;
   int mbefore=0;
   int key,event;

/* grab mouse control off of AES */
   wind_update(3);
/* turn clipping off during all of module 6 */
   vs_clip(gl_hand,0,&dummy);   

/* build global info */
   envx=Envx;
   if (envx==0) offset=50;
   if (envx==1) offset=32;
   if (envx==2) offset=14;
   if (envx==3) offset=108;
   if (envx==4) offset=90;
   if (envx==5) offset=72;

/* save screen which will lie under zoom window */
   savefdb.fd_addr= saveptr;
   savefdb.fd_w= 640;
   savefdb.fd_h= 200*rez;
   savefdb.fd_wdwidth= 40;
   savefdb.fd_stand= 0;
   if (rez==1)
      savefdb.fd_nplanes= 2;
   else
      savefdb.fd_nplanes= 1;
   xyarray[0]= z_xy[0]; xyarray[1]= rez*z_xy[1]; 
   xyarray[2]= z_xy[2]; xyarray[3]= rez*z_xy[7];
   xyarray[4]= 0;   xyarray[5]= 0;
   xyarray[6]= z_xy[2]-z_xy[0];   xyarray[7]= rez*(z_xy[7]-z_xy[1]);
   v_hide_c(gl_hand);   
   if (saveptr) vro_cpyfm(gl_hand,3,xyarray,&scrfdb,&savefdb);
   v_show_c(gl_hand,0); 
/* expand into zoom window */
   graf_growbox(zoomxy[8*envx],rez*zoomxy[8*envx+1],
                zoomxy[8*envx+2]-zoomxy[8*envx]+1,
                rez*(zoomxy[8*envx+7]-zoomxy[8*envx+1])+1,
                z_xy[0],z_xy[1],z_xy[2]-z_xy[0]+1,rez*(z_xy[7]-z_xy[1])+1);
   fullmode=1;   /* start in full mode */
   lowpix=0;   highpix=277;   /* initialize scroll mode */
   lowpeg=1;   highpeg=0;
   z_window();     /* put up zoom window */
   repeat=0;       /* start with mouse repeat disabled */

/* executive loop */
   while (!done)
   {
      vq_mouse(gl_hand,&mstate,&mousex,&mousey);
      kstate=Kbshift(0xffff);
      if ((mstate&3)&&(!mbefore||repeat))
         done= do_zoom(mousex,mousey,mstate,kstate);
      event= evnt_multi(MU_TIMER|MU_KEYBD,0,0,0,0,0,0,0,0,0,0,0,0,0,
             &dummy,1,0,&mousex,&mousey,&dummy,&dummy,&key,&dummy);    
      if ((event & MU_KEYBD)&&(key==0x6100)) z_undo(mousex,mousey);
      mbefore=mstate;
   }
   
/* restore the screen */
   xyarray[0]= 0;    xyarray[1]= 0;   
   xyarray[2]= z_xy[2]-z_xy[0];   xyarray[3]= rez*(z_xy[7]-z_xy[1]);
   xyarray[4]= z_xy[0];  xyarray[5]= rez*z_xy[1];  
   xyarray[6]= z_xy[2];  xyarray[7]= rez*z_xy[7];
   if (saveptr)
   {
      v_hide_c(gl_hand);
      vro_cpyfm(gl_hand,3,xyarray,&savefdb,&scrfdb);
      v_show_c(gl_hand,0);
   }
   else
      redraw(ws_hand,z_xy[0],rez*z_xy[1],
             z_xy[2]-z_xy[0]+1,rez*(z_xy[7]-z_xy[1])+1);
/* shrink back into zoom box */
   graf_shrinkbox(zoomxy[8*envx],rez*zoomxy[8*envx+1],
                  zoomxy[8*envx+2]-zoomxy[8*envx]+1,
                  rez*(zoomxy[8*envx+7]-zoomxy[8*envx+1])+1,
                  z_xy[0],rez*z_xy[1],
                  z_xy[2]-z_xy[0]+1,rez*(z_xy[7]-z_xy[1])+1);
/* return mouse control to AES */
   wind_update(2);

} /* end zoom(Envx) */

/*........................... handle mouse click .............................*/

do_zoom(mousex,mousey,right,shift)   /* returns 1 done, 0 not done */
register int mousex,mousey;
int right,shift;
{
   int i,step,par,state,new_x,new_y,new_xx;
   char oldend,oldsust;
   int rangex1,rangex2,testx,testy;
   int dragpts[6];
   long time,time2,xint,yint;
   long Time();
   int Lnew,Lbelow,Labove,Rnew1,Rnew2;
   long delta1,delta2;
   
/* condition arguments */
   if (right&1)
      right=0;
   else
      right=1;
   if (shift&3)
      shift=1;
   else
      shift=0;
/* default: no mouse repeat */
   repeat=0;

/* OUTSIDE OF ZOOM WINDOW: */
   if ((mousex>481)||(mousex<158)||(mousey>rez*165)||(mousey<rez*35))
   {
      Cconout(7);     /* bell */
      return(0);
   } /* end outside of zoom window */

/* CLOSE: */
   if ((mousex>=161)&&(mousex<=184)&&
       (mousey>=rez*37)&&(mousey<=rez*47)&&!right)
      return(1);

/* FULL MODE: */
   if ((mousex>=163)&&(mousex<=262)&&(mousey>=rez*124)&&(mousey<=rez*136))
   {
      if (right||fullmode) return(0); 
      v_hide_c(gl_hand);
      uncurve();  /* erase old curve */
      z_mode();   /* toggle full/scroll buttons and fullmode */
      charbuf[0]=' ';   charbuf[1]=0;   /* no arrows or end marks */
      v_gtext(gl_hand,300,rez*133,charbuf);
      v_gtext(gl_hand,339,rez*133,charbuf);
      v_gtext(gl_hand,290,rez*133,charbuf);
      v_gtext(gl_hand,349,rez*133,charbuf);
      curve();    /* new curve */
      v_show_c(gl_hand,0);
      return(0);
   } /* end full mode */

/* SCROLL MODE */
   if ((mousex>=377)&&(mousex<=476)&&(mousey>=rez*124)&&(mousey<=rez*136))
   {
      if (right||(!fullmode)) return(0);
      v_hide_c(gl_hand);
      uncurve();  /* erase old curve */
      z_mode();   /* toggle full/scroll buttons and fullmode */
      charbuf[0]=4;     charbuf[1]=0;
      charbuf[2]=3;     charbuf[3]=0;    
      v_gtext(gl_hand,300,rez*133,&charbuf[0]);  /* arrows */
      v_gtext(gl_hand,339,rez*133,&charbuf[2]);
      charbuf[0]=0x7c;                          /* end marks */
      if (!lowpix) v_gtext(gl_hand,349,rez*133,&charbuf[0]);
      if (highpix==MAXPIX) v_gtext(gl_hand,290,rez*133,&charbuf[0]);
      curve();            /* new curve */
      v_show_c(gl_hand,0);
      return(0);
   } /* end scroll mode */

/* LEFT ARROW: */
   if ((mousex>=300)&&(mousex<=316)&&(mousey>=rez*125)&&(mousey<=rez*133))
   {
      if (right||fullmode) return(0);
      if (highpix==MAXPIX) return(0);   /* can't scroll any farther */
      uncurve();      /* erase old curve */
      lowpix= lowpix+15;   highpix=highpix+15;
      if (shift)
      {   lowpix=lowpix+15;   highpix=highpix+15;   }
      if (highpix>MAXPIX)
      {   highpix=MAXPIX;    lowpix=MAXPIX-277;   }
      curve();        /* new curve */
      charbuf[0]=0x7c;  charbuf[1]=0;          /* update end marks */
      if ((highpix==MAXPIX) && !highpeg)  /* we've just high-pegged */
      {
         v_hide_c(gl_hand);
         v_gtext(gl_hand,290,rez*133,&charbuf[0]);
         v_show_c(gl_hand,0);
         highpeg=1;  
      }
      if (lowpix && lowpeg)            /* we've just low-unpegged */
      {
         v_hide_c(gl_hand);
         v_gtext(gl_hand,349,rez*133,&" ");
         v_show_c(gl_hand,0);
         lowpeg=0;
      }
      repeat=1;       /* allow mouse repeat */
      return(0);
   } /* end left arrow */

/* RIGHT ARROW: */
   if ((mousex>=331)&&(mousex<=347)&&(mousey>=rez*125)&&(mousey<=rez*133))
   {
      if (right||fullmode) return(0);
      if (!lowpix) return(0);        /* can't scroll any farther */
      uncurve();        /* erase old curve */
      lowpix=lowpix-15;       highpix=highpix-15;
      if (shift)
      {   lowpix=lowpix-15;   highpix=highpix-15;   }
      if (lowpix<0)
      {   highpix=277;    lowpix=0;   }
      curve();          /* new curve */
      charbuf[0]=0x7c;  charbuf[1]=0;          /* update end marks */
      if (!lowpix && !lowpeg)              /* we've just low-pegged */
      {
         v_hide_c(gl_hand);
         v_gtext(gl_hand,349,rez*133,&charbuf[0]);
         v_show_c(gl_hand,0);
         lowpeg=1;
      }
      if ((highpix<MAXPIX) && highpeg)     /* we've just high-unpegged */
      {
         v_hide_c(gl_hand);
         v_gtext(gl_hand,290,rez*133,&" ");
         v_show_c(gl_hand,0);
         highpeg=0;
      }
      repeat=1;         /* allow mouse repeat */
      return(0);
   } /* end right arrow */

/* RIGHT END MARK */
   if ((mousex>=357)&&(mousex<=373)&&(mousey>=rez*125)&&(mousey<=rez*133))
   {
      if (right||fullmode) return(0);
      if (!lowpix) return(0);        /* can't scroll any farther */
      v_hide_c(gl_hand);
      uncurve();        /* erase old curve */
      highpix=277;    lowpix=0;   
      lowpeg=1;       highpeg=0;
      charbuf[0]=0x7c;  charbuf[1]=0;          /* update end marks */
      v_gtext(gl_hand,349,rez*133,&charbuf[0]);
      v_gtext(gl_hand,290,rez*133,&" ");
      curve();          /* new curve */
      v_show_c(gl_hand,0);
      repeat=1;         /* allow mouse repeat */
      return(0);
   } /* end right end mark */

/* LEFT END MARK: */
   if ((mousex>=266)&&(mousex<=290)&&(mousey>=rez*125)&&(mousey<=rez*133))
   {
      if (right||fullmode) return(0);
      if (highpix==MAXPIX) return(0);   /* can't scroll any farther */
      v_hide_c(gl_hand);
      uncurve();      /* erase old curve */
      highpix=MAXPIX;    lowpix=MAXPIX-277;   
      highpeg=1;         lowpeg=0;
      charbuf[0]=0x7c;  charbuf[1]=0;          /* update end marks */
      v_gtext(gl_hand,290,rez*133,&charbuf[0]);
      v_gtext(gl_hand,349,rez*133,&" ");
      curve();        /* new curve */
      v_show_c(gl_hand,0);
      repeat=1;       /* allow mouse repeat */
      return(0);
   } /* end left end mark */

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
         {                                    /* can't edit at end */ 
            if (step==ednorm[offset]) return(0); 
            par= offset+2+2*step;             /* parameter # */
         }
      }
      if (par!=500)
      {
         v_hide_c(gl_hand);
         uncurve();       /* erase old curve */
         if (right)                              /* do the editing */
            i=1;
         else
            i=(-1);
         if (shift) i=10*i;
         ednorm[par]= ednorm[par]+i;
         if (ednorm[par]<0)  ednorm[par]=100+ednorm[par];   /* wraparound */
         if (ednorm[par]>99) ednorm[par]=ednorm[par]-100;
         curve();        /* new curve */
         encode(charbuf,ednorm[par],2,1);
         v_gtext(gl_hand,264+24*step,rez*(155-(par%2)*9),charbuf);
         texttype(0);
         if (ednorm[par] > wsnorm[par]) 
            v_gtext(gl_hand,281+24*step,rez*(154-(par%2)*9)+2-2*rez,&"+");
         if (ednorm[par] < wsnorm[par]) 
            v_gtext(gl_hand,281+24*step,rez*(154-(par%2)*9)+2-2*rez,&"-");
         if (ednorm[par] == wsnorm[par]) 
            v_gtext(gl_hand,281+24*step,rez*(154-(par%2)*9)+2-2*rez,&" ");
         texttype(1);
         echoback();           /* update edit window behind zoom window */
         v_show_c(gl_hand,0);
         monedit(ednorm);
         return(0);   
      } /* end if (par!=500) */
   } /* end rate/level */

/* SUSTAIN/END POINTS */
   if ((mousex>=263)&&(mousex<=455)&&(mousey>=rez*157)&&(mousey<=rez*162))
   {
      i= (mousex-263)/24;     /* i= step */
      if (right)     /* editing end point */
      {
         if (i==ednorm[offset]) return(0);   /* no change */
         v_hide_c(gl_hand);
         uncurve();          /* erase old curve */
      /* restore L and sust pt */  
         oldend= ednorm[offset];
         ednorm[offset+2+2*oldend]= levsave[envx];  
         encode(charbuf,levsave[envx],2,1);
         v_gtext(gl_hand,264+24*oldend,rez*155,charbuf);
         texttype(0);
         if (levsave[envx] > wsnorm[offset+2+2*oldend])
            v_gtext(gl_hand,281+24*oldend,rez*154+2-2*rez,&"+");
         if (levsave[envx] < wsnorm[offset+2+2*oldend])
            v_gtext(gl_hand,281+24*oldend,rez*154+2-2*rez,&"-");
         if (levsave[envx] == wsnorm[offset+2+2*oldend])
            v_gtext(gl_hand,281+24*oldend,rez*154+2-2*rez,&" ");
         ednorm[offset]=i;   /* set new end point */
      /* end point overwrites sust point and L(end) */
         oldsust= sustsave[envx];
         if ((ednorm[offset+17]>=i)&&(ednorm[offset+17]!=8))
         {
            sustsave[envx]= ednorm[offset+17];
            ednorm[offset+17]=8;   
         }
         levsave[envx]= ednorm[offset+2+2*i];   
         if ((oldsust>=oldend) && (oldsust<i) && (oldsust!=9)) 
            ednorm[offset+17]= oldsust;
         ednorm[offset+2+2*i]=0;   
         curve();            /* new curve */
      /* show L(end) on screen */
         texttype(1);
         v_gtext(gl_hand,264+24*i,rez*155,&"00");
         texttype(0);
         if (wsnorm[offset+2+2*i])
            v_gtext(gl_hand,281+24*i,rez*154+2-2*rez,&"-");
         else
            v_gtext(gl_hand,281+24*i,rez*154+2-2*rez,&" ");
         texttype(1);
         v_show_c(gl_hand,0);
      }
      else           /* editing sust point */
      {
         if (ednorm[offset]<=i) return(0);   /* sust cannot overwrite end */
         if (ednorm[offset+17]==i)      
            ednorm[offset+17]=8;             /* cancel current sust point */
         else
            ednorm[offset+17]=i;             /* set new sust point */
         sustsave[envx]= 9;                  /* no saved sustain point */
      }
      /* show sust/end on screen */
      texttype(0);
      v_hide_c(gl_hand);
      for (i=0; i<=7; i++)
      {
         if (ednorm[offset+17]==i) 
            v_gtext(gl_hand,263+24*i,rez*160,&"sus");
         else
         {
            if (ednorm[offset]==i)
               v_gtext(gl_hand,263+24*i,rez*160,&"end");
            else
               v_gtext(gl_hand,263+24*i,rez*160,&"   ");
         }
      }
      if ((ednorm[offset]!=wsnorm[offset])||
          (ednorm[offset+17] != wsnorm[offset+17]))
         v_gtext(gl_hand,450,rez*160,&"*");
      else
         v_gtext(gl_hand,450,rez*160,&" ");
      texttype(1);
      echoback();        /* update edit window behind zoom window */
      v_show_c(gl_hand,0);
      monedit(ednorm);
      return(0);
   } /* end sust/end points */
   
/* Z-POINT */
   if (!ednorm[offset]) return(0);      /* nothing to grab */
   if (right) return(0);                /* can't grab with right button */
   if (fullmode)
   {
   for (i=1;  i<=ednorm[offset]; i++)   /* rubber-band effect */ 
   {
      testx=mousex;   testy=mousey;
      if (zfpoint[2*i]<195) testx= mousex-195+zfpoint[2*i];
      if (zfpoint[2*i]>468) testx= mousex-468+zfpoint[2*i];
      if (zfpoint[2*i+1]>(115*rez-2)) testy= mousey-115*rez+2+zfpoint[2*i+1];
      if ((testx>=zfpoint[2*i]-2)  &&(testx<=zfpoint[2*i]+2)
        &&(testy>=zfpoint[2*i+1]-2)&&(testy<=zfpoint[2*i+1]+2))
      {
         rangex1= zfpoint[2*i-2];   rangex2= zfpoint[2*i+2];   
         set_clip(193,50*rez,283,65*rez); /* set clipping to not damage axes */
         vsl_udsty(gl_hand,0);   /* line style = invisible */
         dragpts[0]= zfpoint[2*i-2];  dragpts[1]= zfpoint[2*i-1];
         dragpts[2]= zfpoint[2*i];    dragpts[3]= zfpoint[2*i+1];
         dragpts[4]= zfpoint[2*i+2];  dragpts[5]= zfpoint[2*i+3];
         v_hide_c(gl_hand);
         vq_mouse(gl_hand,&state,&new_x,&new_y);
         while (state&1)
         {
            if (new_x < rangex1) new_x= rangex1;
            if (new_x > rangex2) new_x= rangex2;
            if (new_y < rez*55) new_y= rez*55;
            if (new_y > rez*115) new_y= rez*115;
            if ((new_x!=dragpts[2])||(new_y!=dragpts[3]))
            {
               vsl_type(gl_hand,7);
               v_pline(gl_hand,3,dragpts);        /* erase old */
               polymark(1,&dragpts[2]);
               dragpts[2]=new_x;   dragpts[3]=new_y;
               dot();
               v_pline(gl_hand,3,dragpts);        /* display new */
            }
            vq_mouse(gl_hand,&state,&new_x,&new_y);
         } /* end while mouse left button down */
/* did we really go anywhere?  If not (very far) then do no editing */
         if (new_y < rez*55)  new_y= rez*55;
         if (new_y > rez*115) new_y= rez*115;
         if (new_x < rangex1) new_x= rangex1;
         if (new_x > rangex2) new_x= rangex2;
         if ((new_x>=mousex-1)&&(new_x<=mousex+1)&&
             (new_y>=mousey-1)&&(new_y<=mousey+1))
         { 
            vsl_type(gl_hand,7);
            v_pline(gl_hand,3,dragpts);        /* erase rubber lines */
            curve();    
            v_show_c(gl_hand,0);
            return(0);
         }
/* new_x,new_y = coords for new point, calculate new L and two new R's */
         step=i-1;
         time= (totalT*(new_x-zfpoint[2*step]))/
               (zfpoint[2*ednorm[offset]+2]-193);   
         Lnew= 99-(99*(new_y-rez*55))/(60*rez);
         if (!step)
            Lbelow=0;
         else
            Lbelow=ednorm[offset+2*step];
         time2= Time(Lbelow,Lnew,0);
         if (time >= time2)
            delta1= time-time2;
         else
            delta1= time2-time;
         Rnew1=0;
         for (i=1; i<=99; i++)
         {
            time2= Time(Lbelow,Lnew,i);
            if (time >= time2)
               delta2= time-time2;
            else
               delta2= time2-time;
            if (delta2>delta1) break;
            delta1=delta2;
            Rnew1=i;
         } /* end for */            
         Labove= ednorm[offset+2*step+4];
         time2= Time(Lnew,Labove,0);
         time= (totalT*(zfpoint[2*step+4]-new_x))/
               (zfpoint[2*ednorm[offset]+2]-193);   
         if (time >= time2)
            delta1= time-time2;
         else
            delta1= time2-time;
         Rnew2=0;
         for (i=1; i<=99; i++)
         {
            time2= Time(Lnew,Labove,i);
            if (time >= time2)
               delta2= time-time2;
            else
               delta2= time2-time;
            if (delta2>delta1) break;
            delta1=delta2;
            Rnew2=i;
         } /* end for */            
         goto outseq;          /* go to fullmode/scrollmode common code */
      } /* end if mouse clicked near a point */
   } /* end loop looking for a point near the mouse */
   return(0);                  /* mouse clicked in weird place */
   } /* end fullmode */

   else         /* scroll mode */
   {

   if (npoints==2) return(0);              /* nothing to grab */
   for (i=1;  i<=npoints-2; i++)   /* rubber-band effect */ 
   {
      testx=mousex;   testy=mousey;
      if (p_point[2*i]<195) testx= mousex-195+p_point[2*i];
      if (p_point[2*i]>468) testx= mousex-468+p_point[2*i];
      if (p_point[2*i+1]>(115*rez-2)) testy= mousey-115*rez+2+p_point[2*i+1];
      if ((testx>=p_point[2*i]-2)  &&(testx<=p_point[2*i]+2)
        &&(testy>=p_point[2*i+1]-2)&&(testy<=p_point[2*i+1]+2))
      {
         rangex1= p_point[2*i-2];   rangex2= p_point[2*i+2];   
         set_clip(193,rez*50,283,rez*65); /* set clipping to not damage axes */
         vsl_udsty(gl_hand,0);   /* line style = invisible */
         dragpts[0]= p_point[2*i-2];  dragpts[1]= p_point[2*i-1];
         dragpts[2]= p_point[2*i];    dragpts[3]= p_point[2*i+1];
         dragpts[4]= p_point[2*i+2];  dragpts[5]= p_point[2*i+3];
         v_hide_c(gl_hand);
         vq_mouse(gl_hand,&state,&new_x,&new_y);
         while (state&1)
         {
            if (new_x < rangex1) new_x= rangex1;
            if (new_x > rangex2) new_x= rangex2;
            if (new_y < rez*55) new_y= rez*55;
            if (new_y > rez*115) new_y= rez*115;
            if ((new_x!=dragpts[2])||(new_y!=dragpts[3]))
            {
               vsl_type(gl_hand,7);
               v_pline(gl_hand,3,dragpts);        /* erase old */
               polymark(1,&dragpts[2]);
               dragpts[2]=new_x;   dragpts[3]=new_y;
               if (i==1)   /* interpolate left boundary */
               {
                  new_xx= new_x -193 +lowpix;
                  xint= zspoint[2*zsbelow];     
                  yint= zspoint[2*zsbelow+1];   
                  dragpts[0]= 193;
                  if (new_xx==xint)
                     dragpts[1]= yint;
                  else
                     dragpts[1]= yint+((lowpix-xint)*(new_y-yint))
                                      /(new_xx-xint);
               }
               if (i==(npoints-2))   /* interpolate right boudary */
               {            
                  new_xx= new_x -193 +lowpix;
                  xint= zspoint[2*zsabove];
                  yint= zspoint[2*zsabove+1];
                  dragpts[4]= 470;
                  if (new_xx==xint)
                     dragpts[5]=yint;
                  else
                     dragpts[5]= new_y+((highpix-new_xx)*(yint-new_y))
                                       /(xint-new_xx);
               }
               dot();
               v_pline(gl_hand,3,dragpts);        /* display new */
            } 
            vq_mouse(gl_hand,&state,&new_x,&new_y);
         } /* while mouse left button */
/* did we really go anywhere?  If not (very far) then do no editing */
         if (new_y < rez*55)  new_y= rez*55;
         if (new_y > rez*115) new_y= rez*115;
         if (new_x < rangex1) new_x= rangex1;
         if (new_x > rangex2) new_x= rangex2;
         if ((new_x>=mousex-1)&&(new_x<=mousex+1)&&
             (new_y>=mousey-1)&&(new_y<=mousey+1))
         { 
            vsl_type(gl_hand,7);
            v_pline(gl_hand,3,dragpts);        /* erase rubber lines */
            curve();    
            v_show_c(gl_hand,0);
            return(0);
         }
/* new_x,new_y = coords for new point, calculate new L and two new R's */
         step= zsbelow+i-1;
         new_xx= new_x -193 +lowpix;
         time= (totalT*(new_xx-zspoint[2*step]))/zspoint[2*ednorm[offset]+2]; 
         Lnew= 99-(99*(new_y-55*rez))/(rez*60);
         if (!step)
            Lbelow=0;
         else
            Lbelow=ednorm[offset+2*step];
         time2= Time(Lbelow,Lnew,0);
         if (time >= time2)
            delta1= time-time2;
         else
            delta1= time2-time;
         Rnew1=0;
         for (i=1; i<=99; i++)
         {
            time2= Time(Lbelow,Lnew,i);
            if (time >= time2)
               delta2= time-time2;
            else
               delta2= time2-time;
            if (delta2>delta1) break;
            delta1=delta2;
            Rnew1=i;
         }             
         Labove= ednorm[offset+2*step+4];
         time2= Time(Lnew,Labove,0);
         time= (totalT*(zspoint[2*step+4]-new_xx))/zspoint[2*ednorm[offset]+2]; 
         if (time >= time2)
            delta1= time-time2;
         else
            delta1= time2-time;
         Rnew2=0;
         for (i=1; i<=99; i++)
         {
            time2= Time(Lnew,Labove,i);
            if (time >= time2)
               delta2= time-time2;
            else
               delta2= time2-time;
            if (delta2>delta1) break;
            delta1=delta2;
            Rnew2=i;
         }             
         goto outseq;        
      } /* end if mouse clicked near a p_point */
   } /* end loop looking for p_point near mouse */
   return(0);                  /* mouse clicked in weird place */
   } /* end scroll mode */

/* fullmode or scrollmode (common code): */
outseq:
   vsl_type(gl_hand,7);
   v_pline(gl_hand,3,dragpts);        /* erase rubber lines */
   uncurve();
   ednorm[offset+2*step + 1]= Rnew1;
   ednorm[offset+2*step + 2]= Lnew;
   ednorm[offset+2*step + 3]= Rnew2;
   curve();
/* rates */
   for (i=0; i<=14; i=i+2)
   {
      encode(charbuf,ednorm[offset+1+i],2,1);
      v_gtext(gl_hand,264+24*i/2,rez*146,charbuf);
   }
/* levels */
   for (i=0; i<=14; i=i+2)
   {
      encode(charbuf,ednorm[offset+2+i],2,1);
      v_gtext(gl_hand,264+24*i/2,rez*155,charbuf);
   }
/* indicate edited parameters */
   texttype(0);
   for (i=1; i<=16; i++)
   {
      if (ednorm[offset+i] > wsnorm[offset+i])
         v_gtext(gl_hand,281+24*((i-1)/2),rez*(154-(i%2)*9)+2-2*rez,&"+");
      if (ednorm[offset+i] < wsnorm[offset+i])
         v_gtext(gl_hand,281+24*((i-1)/2),rez*(154-(i%2)*9)+2-2*rez,&"-");
      if (ednorm[offset+i] == wsnorm[offset+i])
         v_gtext(gl_hand,281+24*((i-1)/2),rez*(154-(i%2)*9)+2-2*rez,&" ");
   }
   texttype(1);
   echoback();
   v_show_c(gl_hand,0);
   monedit(ednorm);
   return(0);
} /* end do_zoom(mousex,mousey,right,shift) */

/* EOF */
