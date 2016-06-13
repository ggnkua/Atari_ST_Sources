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

/*............................. editor global variables ......................*/

extern int edlines[],zoomxy[],eddata[];
extern long zoomdata[],truerast[],testrast[];
extern char ednorm[],wsnorm[],levsave[],sustsave[];
extern long vibwv0[],vibwv1[],vibwv2[],vibwv3[];
extern int dcowv8[],dcowv0[],dcowv1[],dcowv2[],dcowv3[],dcowv4[],dcowv5[];
extern int dcowv6[],dcowv7[];
extern FDB edfdb;
extern int xyarray[],color[];
extern int Ndiffer,offset,ed_skip;

/*.......................handle menu choice= undoedit.........................*/

undoedit()
{
   register int i;
   int top;

   if (!Ndiffer) return;                /* there's nothing to undo */
   if (form_alert(1,CHEKSAFE) == 2) return;   /* are you sure? */
   copybyte(wsnorm,ednorm,135);         /* do it */
   monedit(ednorm);
   Ndiffer=0;
   for (i=0; i<=5; i++) { levsave[i]=0; sustsave[i]=9; }
   wind_get(dummy,WF_TOP,&top,&dummy,&dummy,&dummy);
   if (top==ws_hand)   /* no desk acc window on top */
   {
      vs_clip(gl_hand,0,&dummy);
      v_hide_c(gl_hand);
      for (i=0; i<=126; i++)
         outpar(ednorm,i);
      v_gtext(gl_hand,432,27*rez+2,&"  0");
      v_show_c(gl_hand,0);
   }
   else        /* desk acc window on top */
      redraw(ws_hand,0,0,0,0);
} /* end undoedit() */

/*.......................handle mouse click event.............................*/

ed_mouse(mousex,mousey,right,shift)
int mousex,mousey,right,shift;
{
   if (chekedit()) return;   /* check for editor lockout */
   edx_mouse(mousex,mousey,right,shift);
}

edx_mouse(mousex,mousey,right,shift)
register int mousex,mousey;
int right,shift;
{
   int i,par,state,top,envx;
   char codebuf[4],oldsust,oldend;
   int second=0;   /* default: no secondary outpar */
   int third=0;    /* default: no tertiary outpar */

/* condition arguments */
   if (right&1)
      right=0;     /* right=0 means left button or both buttons */
   else
      right=1;     /* right=1 means right button */
   if (shift&3)
      shift=1;     /* shift=1 means either shift key */
   else
      shift=0;     /* shift=0 means neither shift key */

/* handle zoom box */
   for (par=0; par<=40; par=par+8)
   {
      if ((mousex>=zoomxy[par])  &&(mousex<=zoomxy[par+2])&&
          (mousey>=rez*zoomxy[par+1]+2-2*rez)
          &&(mousey<=rez*zoomxy[par+1]+12-rez))
      {
         if (right) return;  /* can't use right button to zoom */
         zoom(par/8); /* left button (with or without shift): start zoom */
         wind_get(dummy,WF_TOP,&top,&dummy,&dummy,&dummy);
         if (top==ws_hand)   /* no desk acc window on top */
         {
            v_hide_c(gl_hand);
            for (i=0; i<=17; i++)
               outpar(ednorm,offset+i);  /* note: offset imported from zoom() */
            v_show_c(gl_hand,0);
         }
         else        /* desk acc window on top */
            redraw(ws_hand,0,0,0,0);
         return;
      } /* end if mouse clicked in zoom box (par) */
   } /* end for (par=0; par<=40; par=par+8) */
/* edit which parameter? */
   par=500;  
   for (i=0; i<=756; i=i+6)
   {
      if ((mousex>=eddata[i])&&(mousex<=(eddata[i]+eddata[i+2]))&&
          (mousey>=rez*(eddata[i+1]-eddata[i+3]))&&(mousey<=rez*eddata[i+1]))
      {   par=i/6;  break;   }
   }
   if (par==500) return;    /* mouse clicked not on a parameter */
/* env sust/end points */
   if ((par==14)||(par==32)||(par==50) ||(par==72)||(par==90)||(par==108))
   {
      if (par==14)  envx=2;      /* index into levsave and sustsave arrays */
      if (par==32)  envx=1;
      if (par==50)  envx=0;
      if (par==72)  envx=5;
      if (par==90)  envx=4;
      if (par==108) envx=3;
      i= (mousex-eddata[6*par])/(eddata[6*par+2]/8);   /* i=step=0-7 */
      if (right)     /* editing end point */
      {
         if (ednorm[par]==i) return;   /* no change */
         oldend= ednorm[par];
         ednorm[par+2+2*oldend]= levsave[envx];  /* restore L */
         third= par+2+2*oldend;
         levsave[envx]= ednorm[par+2+2*i];    /* save L */
         ednorm[par]=i;   /* set new end point */
      /* end point overwrites sust point */
         oldsust= sustsave[envx];
         if ((ednorm[par+17]>=i)&&(ednorm[par+17]!=8))
         {
            sustsave[envx]= ednorm[par+17];
            ednorm[par+17]=8;  
         }
         if ((oldsust>=oldend) && (oldsust<i) && (oldsust!=9)) 
            ednorm[par+17]= oldsust;
         ednorm[par+2+2*i]=0;   /* L at end point must be 0 */
         second=par+2+2*i;
      }
      else           /* editing sust point */
      {
         if (ednorm[par]<=i) return;   /* sust cannot overwrite end */
         if (ednorm[par+17]==i)      
            ednorm[par+17]=8;          /* cancel current sust point */
         else
            ednorm[par+17]=i;          /* set new sust point */
         sustsave[envx]=9;             /* no overwritten sustain point */
      }
      goto outseq;
   } /* end if sust/end point */
/* can't edit L(step=end) */
   for (i=0; i<=7; i++)
   {
      if ((par==16+2*i)&&(i==ednorm[14])) return;
      if ((par==34+2*i)&&(i==ednorm[32])) return;
      if ((par==52+2*i)&&(i==ednorm[50])) return;
      if ((par==74+2*i)&&(i==ednorm[72])) return;
      if ((par==92+2*i)&&(i==ednorm[90])) return;
      if ((par==110+2*i)&&(i==ednorm[108])) return;
   }      
/* can't edit modulation while line select < 2 */
   if ((par==126)&&(ednorm[0]<2)) return;
/* determine increment/decrement amount */
   if (right)
      i=1;
   else
      i=(-1);
   if ((shift)&&(eddata[6*par+5]>=60)) i=10*i;
/* do the edit, wrap around in both directions */
   ednorm[par]= ednorm[par]+i;
   if (ednorm[par]<0) ednorm[par]= eddata[6*par+5]+1+ednorm[par];
   if (ednorm[par]>eddata[6*par+5])
      ednorm[par]= ednorm[par]-eddata[6*par+5]-1;
/* don't allow certain combinations of DCO waves */
   if ((ednorm[10]>4)&&(ednorm[11]>4)&&(ednorm[11]!=8)&&((par==10)||(par==11)))
   {
      if (right) 
         ednorm[par]=(par-10)*8;
      else
         ednorm[par]=4;
   }
   if ((ednorm[68]>4)&&(ednorm[69]>4)&&(ednorm[69]!=8)&&((par==68)||(par==69)))
   {
      if (right) 
         ednorm[par]=(par-68)*8;
      else
         ednorm[par]=4;
   }
/* if line goes to 2 or 3, turn off modulation */
   if ((ednorm[0]<2)&&(par==0))
   {
      ednorm[126]=0;
      second=126;
   }

outseq:
   monedit(ednorm);
/* update screen */
   vs_clip(gl_hand,0,&dummy);
   v_hide_c(gl_hand);
   outpar(ednorm,par);
   if (second) outpar(ednorm,second);  /* secondary outpar */
   if (third) outpar(ednorm,third);  /* tertiary outpar */
/* update info line */
   i=ndiffer();
   if (i!=Ndiffer)
   {
      encode(codebuf,i,3,0);
      v_gtext(gl_hand,432,27*rez+2,codebuf);
      Ndiffer=i;
   }
   v_show_c(gl_hand,0);
} /* end ed_mouse(mousex,mousey,right,shift) */

/*................................ undo key ..................................*/

ed_undo(mousex,mousey)
register int mousex,mousey;
{
   int par,i,tempmon,envx;
   char codebuf[4];
   int par1,par2,par3,par4;

   if (chekedit()) return;       /* check for lockout conditions */

/* un-edit a group of four parameters */
   par1=0;
   if ((mousex>=19)&&(mousex<=109)&&(mousey>=144*rez)&&(mousey<=156*rez))
   {   par1=13;  par2=71;  par3=12;  par4=70;   }   /* key follows */
   if ((mousex>=161)&&(mousex<=225)&&(mousey>=144*rez)&&(mousey<=156*rez))
   {   par1=6;   par2=7;   par3=8;   par4=9;    }   /* vibrato */
   if ((mousex>=291)&&(mousex<=350)&&(mousey>=144*rez)&&(mousey<=156*rez))
   {   par1=2;   par2=4;   par3=5;   par4=3;    }   /* detune */
   if (par1)
   {
      ednorm[par1]=wsnorm[par1];         ednorm[par2]=wsnorm[par2];   
      ednorm[par3]=wsnorm[par3];         ednorm[par4]=wsnorm[par4];   
      monedit(ednorm);
      vs_clip(gl_hand,0,&dummy);
      v_hide_c(gl_hand);
      outpar(ednorm,par1);      outpar(ednorm,par2);
      outpar(ednorm,par3);      outpar(ednorm,par4);
      i=ndiffer();
      if (i!=Ndiffer)
      {
         encode(codebuf,i,3,0);
         v_gtext(gl_hand,432,27*rez+2,codebuf);
         Ndiffer=i;
      }
      v_show_c(gl_hand,0);
      return;
   } /* end un-edit a group of four parameters */

/* un-edit an entire envelope */
   envx=500;
   if ((mousex>=0)&&(mousex<=136)&&(mousey>=31*rez)&&(mousey<=43*rez))
   {  envx=0;   par=50;  }   /* DCO 1 */
   if ((mousex>=216)&&(mousex<=352)&&(mousey>=31*rez)&&(mousey<=43*rez))
   {  envx=1;   par=32;  }   /* DCW 1 */
   if ((mousex>=424)&&(mousex<=560)&&(mousey>=31*rez)&&(mousey<=43*rez))
   {  envx=2;   par=14;  }   /* DCA 1 */
   if ((mousex>=0)&&(mousex<=136)&&(mousey>=87*rez)&&(mousey<=99*rez))
   {  envx=3;   par=108; }   /* DCO 2 */
   if ((mousex>=216)&&(mousex<=352)&&(mousey>=87*rez)&&(mousey<=99*rez))
   {  envx=4;   par=90;  }   /* DCW 2 */
   if ((mousex>=424)&&(mousex<=560)&&(mousey>=87*rez)&&(mousey<=99*rez))
   {  envx=5;   par=72;  }   /* DCA 2 */
   if (envx!=500)
   {
      for (i=0; i<=17; i++) ednorm[par+i]= wsnorm[par+i];
      vs_clip(gl_hand,0,&dummy);
      v_hide_c(gl_hand);
      for (i=0; i<=17; i++)
         outpar(ednorm,par+i);
      Ndiffer=ndiffer();
      encode(codebuf,Ndiffer,3,0);
      v_gtext(gl_hand,432,27*rez+2,codebuf);
      v_show_c(gl_hand,0);
      monedit(ednorm);
      levsave[envx]=0;   sustsave[envx]=9;
      return;
   }
      
/* un-edit which parameter? */
   par=500;  
   for (i=0; i<=756; i=i+6)
   {
      if ((mousex>=eddata[i])&&(mousex<=(eddata[i]+eddata[i+2]))&&
          (mousey>=rez*(eddata[i+1]-eddata[i+3]))&&(mousey<=rez*eddata[i+1]))
      {   par=i/6;  break;   }
   }
   if (par==500) return;    /* mouse not on a parameter */

/* sustain/end points */
   if ((par==14)||(par==32)||(par==50) ||(par==72)||(par==90)||(par==108))
   {
      mousey= rez*eddata[6*par+1];
      if (ednorm[par]!=wsnorm[par])
      {
         mousex= eddata[6*par] + wsnorm[par]*eddata[6*par+2]/8;
         edx_mouse(mousex,mousey,2,0);   /* undo end point */
      }
      if (ednorm[par+17]!=wsnorm[par+17])
      {
         if (wsnorm[par+17]==8)
            mousex= eddata[6*par] + ednorm[par+17]*eddata[6*par+2]/8;
         else
            mousex= eddata[6*par] + wsnorm[par+17]*eddata[6*par+2]/8;
         edx_mouse(mousex,mousey,1,0);   /* undo sustain point */
      }
      if (par==14)  envx=2;    
      if (par==32)  envx=1;
      if (par==50)  envx=0;
      if (par==72)  envx=5;
      if (par==90)  envx=4;
      if (par==108) envx=3;
      levsave[envx]=0;   sustsave[envx]=9;
      return;
   } /* end if sust/end points unediting */

/* no un-editing needed ? */
   if (wsnorm[par]==ednorm[par]) return; 

/* can't undo L(step)=end) */
   for (i=0; i<=7; i++)
   {
      if ((par==16+2*i)  && (i==ednorm[14]))  return;
      if ((par==34+2*i)  && (i==ednorm[32]))  return;
      if ((par==52+2*i)  && (i==ednorm[50]))  return;
      if ((par==74+2*i)  && (i==ednorm[72]))  return;
      if ((par==92+2*i)  && (i==ednorm[90]))  return;
      if ((par==110+2*i) && (i==ednorm[108])) return;
   }      

/* can't undo into illegal dco wave combinations */
   if ((par==10)&&(ednorm[11]>4)&&(ednorm[11]!=8)&&(wsnorm[10]>4)) return;
   if ((par==68)&&(ednorm[69]>4)&&(ednorm[69]!=8)&&(wsnorm[68]>4)) return;
   if ((par==11)&&(ednorm[10]>4)&&(wsnorm[11]>4)&&(wsnorm[11]!=8)) return;
   if ((par==69)&&(ednorm[68]>4)&&(wsnorm[69]>4)&&(wsnorm[69]!=8)) return;

/* do the un-edit */
   ednorm[par]=wsnorm[par];

/* common exit sequence */
undoout:
   monedit(ednorm);
   vs_clip(gl_hand,0,&dummy);
   v_hide_c(gl_hand);
   outpar(ednorm,par);
   i=ndiffer();
   if (i!=Ndiffer)
   {
      encode(codebuf,i,3,0);
      v_gtext(gl_hand,432,27*rez+2,codebuf);
      Ndiffer=i;
   }
   v_show_c(gl_hand,0);

} /* end ed_undo(mousex,mousey) */

/*........................redraw edit window contents.........................*/

ed_window()
{
   int x,y,w,h;

   if (!ed_skip)
   {
/* get window's work area */
      wind_get(ws_hand,WF_WORKXYWH,&x,&y,&w,&h); 
/* define rectangle for work area background */
      xyarray[0]= x;
      xyarray[1]= y-1;
      xyarray[2]= x+w-1;
      xyarray[3]= y-1;
      xyarray[4]= x+w-1;
      xyarray[5]= y+h;
      xyarray[6]= x;
      xyarray[7]= y+h;

      vsf_color(gl_hand,0);
      vsf_interior(gl_hand,1);
/* no vsf_style needed for interior 1 */
      vsf_perimeter(gl_hand,0);
/* paint work area background */
      v_fillarea(gl_hand,4,xyarray);
   } /* end if (!ed_skip) */
   if (edited)
      ed_draw(ednorm);
   else
      ed_draw(wsnorm);      
} /* end ed_window() */

ed_draw(area)
char area[];   /* 135 bytes normalized */
{
   int i;
   char codebuf[4];   /* will contain # parameters edited */
   int tempxy[8];

/* update info line */
   encode(codebuf,Ndiffer,3,0);
   xyarray[0]=0; xyarray[1]=31*rez; xyarray[2]=639; xyarray[3]=31*rez;
   v_pline(gl_hand,2,xyarray);
   v_gtext(gl_hand,8,27*rez+2,editline);
   v_gtext(gl_hand,432,27*rez+2,codebuf);
   if (ed_skip) return;

/* draw lines */
   for (i=0; i<=1000; i=i+4)
   {
      if (edlines[i]==800) break;
      tempxy[0]=edlines[i];     tempxy[1]= rez*edlines[i+1];
      tempxy[2]=edlines[i+2];   tempxy[3]= rez*edlines[i+3];
      v_pline(gl_hand,2,tempxy);
   }
/* normal-sized text */
   vst_color(gl_hand,2);
   v_gtext(gl_hand,15,40*rez,&"DCO 1 Envelope");
   v_gtext(gl_hand,231,40*rez,&"DCW 1 Envelope");
   v_gtext(gl_hand,439,40*rez,&"DCA 1 Envelope");
   v_gtext(gl_hand,15,96*rez,&"DCO 2 Envelope");
   v_gtext(gl_hand,231,96*rez,&"DCW 2 Envelope");
   v_gtext(gl_hand,439,96*rez,&"DCA 2 Envelope");
   v_gtext(gl_hand,25,153*rez,&"Key Follow");
   v_gtext(gl_hand,166,153*rez,&"Vibrato");
   v_gtext(gl_hand,298,153*rez,&"Detune");
   vst_color(gl_hand,1);
   v_gtext(gl_hand,28,166*rez,&"DCW 1:");
   v_gtext(gl_hand,28,176*rez,&"DCW 2:");
   v_gtext(gl_hand,28,186*rez,&"DCA 1:");
   v_gtext(gl_hand,28,196*rez,&"DCA 2:");
   v_gtext(gl_hand,137,166*rez,&"Wave:");
   v_gtext(gl_hand,137,176*rez,&"Delay:");
   v_gtext(gl_hand,137,186*rez,&"Rate:");
   v_gtext(gl_hand,137,196*rez,&"Depth:");
   v_gtext(gl_hand,264,166*rez,&"Direction:");
   v_gtext(gl_hand,264,176*rez,&"Octave:");
   v_gtext(gl_hand,264,186*rez,&"Note:");
   v_gtext(gl_hand,264,196*rez,&"Fine:");
   v_gtext(gl_hand,524,159*rez,&"Line:");
   v_gtext(gl_hand,524,175*rez,&"Octave:");
   v_gtext(gl_hand,524,191*rez,&"Mod:");

/* miniature text */
   texttype(0);
   v_gtext(gl_hand,15,53*rez,&"RATES");
   v_gtext(gl_hand,15,69*rez,&"LEVELS");
   v_gtext(gl_hand,231,53*rez,&"RATES");
   v_gtext(gl_hand,231,69*rez,&"LEVELS");
   v_gtext(gl_hand,439,53*rez,&"RATES");
   v_gtext(gl_hand,439,69*rez,&"LEVELS");
   v_gtext(gl_hand,15,109*rez,&"RATES");
   v_gtext(gl_hand,15,125*rez,&"LEVELS");
   v_gtext(gl_hand,231,109*rez,&"RATES");
   v_gtext(gl_hand,231,125*rez,&"LEVELS");
   v_gtext(gl_hand,439,109*rez,&"RATES");
   v_gtext(gl_hand,439,125*rez,&"LEVELS");
   v_gtext(gl_hand,419,153*rez,&"WAVE 1");
   v_gtext(gl_hand,470,153*rez,&"WAVE 2");
   v_gtext(gl_hand,389,166*rez,&"DCO");
   v_gtext(gl_hand,396,172*rez,&"1");
   v_gtext(gl_hand,389,187*rez,&"DCO");
   v_gtext(gl_hand,396,193*rez,&"2");
   texttype(1);   /* normal text */
/* zoom boxes */
   edfdb.fd_w= 32;
   edfdb.fd_h= 12;
   edfdb.fd_wdwidth= 2;
   edfdb.fd_stand= 0;
   edfdb.fd_nplanes= 1;
   edfdb.fd_addr= &zoomdata;
   xyarray[0]=0;   xyarray[1]=0;   xyarray[2]=27;   xyarray[3]= 11;
   for (i=0; i<=40; i=i+8)
   {
      xyarray[4]= zoomxy[i];   xyarray[5]= rez*zoomxy[i+1]+1-rez;
      xyarray[6]= zoomxy[i+4]; xyarray[7]= rez*zoomxy[i+5]+1-rez;
      vrt_cpyfm(gl_hand,1,xyarray,&edfdb,&scrfdb,color);
   }
/* set up test raster */
   if (rez==1)
      edfdb.fd_nplanes= 2;
   else
      edfdb.fd_nplanes= 1;
   edfdb.fd_addr= &truerast;
   xyarray[0]= zoomxy[32];   xyarray[1]= rez*zoomxy[33];
   xyarray[2]= zoomxy[36];   xyarray[3]= rez*(zoomxy[37]-2);
   xyarray[4]= 0;   xyarray[5]= 0;   xyarray[6]= 28; xyarray[7]= 11;
   vro_cpyfm(gl_hand,3,xyarray,&scrfdb,&edfdb);

/* put up non-cz-1 parameters */
   for (i=0; i<=126; i++)
     outpar(area,i);

} /* end ed_draw(area) */

/*........................... output a parameter .............................*/

outpar(area,n)
char area[];  /* --> 135 bytes normalized */
register int n;        /* =0-126 */
{
   char codebuf[6];
   int sustpt,endpt,i,n2;

   if (!eddata[6*n+4])       /* numerical type data */
   {
      encode(codebuf,area[n],eddata[6*n+2]/8,1);
      v_gtext(gl_hand,eddata[6*n],rez*eddata[6*n+1],codebuf);
      texttype(0);   /* miniature text */
      if ((edited)&&(ednorm[n] > wsnorm[n]))
         v_gtext(gl_hand,eddata[6*n]+eddata[6*n+2]+1,
                 rez*eddata[6*n+1]+2-3*rez,&"+");
      if ((edited)&&(ednorm[n] < wsnorm[n]))
         v_gtext(gl_hand,eddata[6*n]+eddata[6*n+2]+1,
                 rez*eddata[6*n+1]+2-3*rez,&"-");
      if ((edited)&&(ednorm[n] == wsnorm[n]))
         v_gtext(gl_hand,eddata[6*n]+eddata[6*n+2]+1,
                 rez*eddata[6*n+1]+2-3*rez,&" ");
      texttype(1);    /* normal text */
   }
   else
   {
      if (n==0)
      {
         if (area[n]==0) strcpy(codebuf,"1   ");
         if (area[n]==1) strcpy(codebuf,"2   ");
         if (area[n]==2) strcpy(codebuf,"1+1\'");
         if (area[n]==3) strcpy(codebuf,"1+2\'");
      }
      if (n==1)
      {
         if (area[n]==0) strcpy(codebuf,"0 ");
         if (area[n]==1) strcpy(codebuf,"+1");
         if (area[n]==2) strcpy(codebuf,"-1");
      }
      if (n==2)
      {
         if (area[n]==0) strcpy(codebuf,"+");
         if (area[n]==1) strcpy(codebuf,"-");
      } 
      if (n==126)
      {
         if (area[n]==0) strcpy(codebuf,"off  ");
         if (area[n]==1) strcpy(codebuf,"ring ");
         if (area[n]==2) strcpy(codebuf,"noise");
      }
      if ((n<=2)||(n==126))
      {
         v_gtext(gl_hand,eddata[6*n],rez*eddata[6*n+1],codebuf);
         texttype(0);   /* miniature text */
         if ((edited)&&(ednorm[n] != wsnorm[n]))
            v_gtext(gl_hand,eddata[6*n]+eddata[6*n+2]+1,
                            rez*eddata[6*n+1]+1-2*rez,&"*");
         else
            v_gtext(gl_hand,eddata[6*n]+eddata[6*n+2]+1,
                            rez*eddata[6*n+1]+1-2*rez,&" ");
         texttype(1);   /* normal text */
         return;
      }
      if (n==6)
      {
         edfdb.fd_w= 32;
         edfdb.fd_h= 8;
         edfdb.fd_wdwidth= 2;
         edfdb.fd_stand= 0;
         edfdb.fd_nplanes= 1;
         if (area[n]==0) edfdb.fd_addr= &vibwv0;
         if (area[n]==1) edfdb.fd_addr= &vibwv1;
         if (area[n]==2) edfdb.fd_addr= &vibwv2;
         if (area[n]==3) edfdb.fd_addr= &vibwv3;
         xyarray[0]=0;  xyarray[1]= 0;   xyarray[2]= 31;   xyarray[3]= 7;
         xyarray[4]= eddata[6*n];
         xyarray[5]= rez*eddata[6*n+1] - eddata[6*n+3] + 3 - 2*rez;
         xyarray[6]= eddata[6*n] + eddata[6*n+2] -1;
         xyarray[7]= rez*eddata[6*n+1] + 2 - 2*rez;
         vrt_cpyfm(gl_hand,1,xyarray,&edfdb,&scrfdb,color);
         texttype(0);   /* miniature text */
         if ((edited)&&(ednorm[n] > wsnorm[n]))
            v_gtext(gl_hand,eddata[6*n]+eddata[6*n+2]+1,
                            rez*eddata[6*n+1]+2-3*rez,&"+");
         if ((edited)&&(ednorm[n] < wsnorm[n]))
            v_gtext(gl_hand,eddata[6*n]+eddata[6*n+2]+1,
                            rez*eddata[6*n+1]+2-3*rez,&"-");
         if ((edited)&&(ednorm[n] == wsnorm[n]))
            v_gtext(gl_hand,eddata[6*n]+eddata[6*n+2]+1,
                            rez*eddata[6*n+1]+2-3*rez,&" ");
         texttype(1);   /* normal text */
         return;
      }
      if ((n==10)||(n==11)||(n==68)||(n==69))   /* DCO waves */
      {
         edfdb.fd_w= 48;
         edfdb.fd_h= 20;
         edfdb.fd_wdwidth= 3;
         edfdb.fd_stand= 0;
         edfdb.fd_nplanes= 1;
         if (area[n]==0) edfdb.fd_addr= &dcowv0;
         if (area[n]==1) edfdb.fd_addr= &dcowv1;
         if (area[n]==2) edfdb.fd_addr= &dcowv2;
         if (area[n]==3) edfdb.fd_addr= &dcowv3;
         if (area[n]==4) edfdb.fd_addr= &dcowv4;
         if (area[n]==5) edfdb.fd_addr= &dcowv5;
         if (area[n]==6) edfdb.fd_addr= &dcowv6;
         if (area[n]==7) edfdb.fd_addr= &dcowv7;
         if (area[n]==8) edfdb.fd_addr= &dcowv8;
         xyarray[0]=0;  xyarray[1]= 0;   xyarray[2]= 44;   xyarray[3]= 19;
         xyarray[4]= eddata[6*n];
         xyarray[5]= rez*eddata[6*n+1] - eddata[6*n+3] + 11 - 10*rez;
         xyarray[6]= eddata[6*n] + eddata[6*n+2] -1;
         xyarray[7]= rez*eddata[6*n+1] + 10 - 10*rez;
         vrt_cpyfm(gl_hand,1,xyarray,&edfdb,&scrfdb,color);
         texttype(0);   /* miniature text */
         if ((edited)&&(ednorm[n] != wsnorm[n]))
            v_gtext(gl_hand,eddata[6*n]+1,
                    rez*(eddata[6*n+1]-eddata[6*n+3])+5,&"*");
         else
            v_gtext(gl_hand,eddata[6*n]+1,
                    rez*(eddata[6*n+1]-eddata[6*n+3])+5,&" ");
         texttype(1);   /* normal text */
         return;
      }
      if ((n==14)||(n==32)||(n==50)||(n==72)||(n==90)||(n==108))
      {    /* given end point, find sustain point */
         sustpt= area[n+17];   n2= n+17;
         endpt= area[n];
      }
      else   /* given sustain point, find end point */
      {
         sustpt= area[n];
         endpt= area[n-17];    n2= n-17;
      }
      texttype(0);   /* miniature text */
      for (i=0; i<=7; i++)
      {
         strcpy(codebuf,&"   ");
         if (i==sustpt) strcpy(codebuf,&"sus");
         if (i==endpt)  strcpy(codebuf,&"end");
         v_gtext(gl_hand,eddata[6*n]+24*i,rez*eddata[6*n+1],codebuf);
         if ((edited)&&((ednorm[n] != wsnorm[n])||(ednorm[n2] != wsnorm[n2])))
            v_gtext(gl_hand,eddata[6*n]+eddata[6*n+2]+2,
                            rez*eddata[6*n+1],&"*");
         else
            v_gtext(gl_hand,eddata[6*n]+eddata[6*n+2]+2,
                            rez*eddata[6*n+1],&" ");
      }      
      texttype(1);   /* normal text */
   } /* end if (!eddata[6*n+4]) */
} /* end outpar(area,n) */

/*.............................. encode a number .............................*/
 
encode(target,source,ndigits,padflag)
int source,ndigits,padflag;
char target[];
{
   int right,left;

   right= source/10;
   left= source%10;
   if (ndigits==1) target[0]= left+0x30;
   if (ndigits==2)
   {
      target[0]= right+0x30;
      if ((!padflag)&&(target[0]=='0')) target[0]=' ';
      target[1]= left+0x30;
   }
   if (ndigits==3)
   {
      target[0]= right/10 + 0x30;
      if ((!padflag)&&(target[0]=='0')) target[0]=' ';
      target[1]= right%10 + 0x30;
      if ((target[1]=='0')&&(target[0]==' ')) target[1]=' ';
      target[2]= left + 0x30;
   }
   target[ndigits]= 0;
} /* end encode(target,source,ndigits,padflag) */
      
/*.......................... send ednorm/wsnorm to CZ ........................*/

monedit(area)
char area[];  /* 135 bytes normalized */
{
   char pcchnge[2];

   if (!editmon) return;

   normtocz(area,&ws_dat);

/* channelize communication */   
   tocz1[4]= (tocz1[4] & 0xF0) | midi_ch;
   tocz2[4]= (tocz2[4] & 0xF0) | midi_ch;
/* program # = sound area */
   tocz1[6]= 0x60;
/* argument for writsyn */
   midiptr= &czbuf[0];
   writsyn();  /* ignore error condition */
/* for 230S, change patch to 96 */
   pcchnge[0]= 0xc0 | midi_ch;
   pcchnge[1]= 0x60;
   Midiws(1,pcchnge);

} /* end monedit(area) */

/*.......................... compare ednorm/wsnorm ...........................*/

ndiffer()   /* return 0-135 */
{
   register int count,i;

   count=0;
   for (i=0; i<=134; i++)
      if (ednorm[i]!=wsnorm[i]) count++;
   return(count);
} /* end ndiffer() */

/*.......................... editor lockout conditions .......................*/

chekedit()   /* returns 1 for lockout, 0 for ok */
{
   long tree;
   register int i;
   int top;

/* interacting with a menu */
   tree= menuaddr;
   if (     (LWGET(OB_STATE(DESK)) & SELECTED) 
          ||(LWGET(OB_STATE(FILE)) & SELECTED) 
          ||(LWGET(OB_STATE(EDIT)) & SELECTED) 
          ||(LWGET(OB_STATE(OPTIONS)) & SELECTED)
          ||(LWGET(OB_STATE(QUIT)) & SELECTED)          ) return(1);

/* don't allow un-editing during original display */
   if (!edited) return(1);

/* don't allow un-editing while a desk acc has a window on top */
   wind_get(dummy,WF_TOP,&top,&dummy,&dummy,&dummy);
   if (top!=ws_hand) return(1);

/* don't allow un-editing while a desk acc has a dialog box up */
   edfdb.fd_w= 32;
   edfdb.fd_h= 12;
   edfdb.fd_wdwidth= 2;
   edfdb.fd_stand= 0;
   if (rez==1)
      edfdb.fd_nplanes= 2;
   else
      edfdb.fd_nplanes= 1;
   edfdb.fd_addr= &testrast;
   xyarray[0]= zoomxy[32];   xyarray[1]= rez*zoomxy[33];
   xyarray[2]= zoomxy[36];   xyarray[3]= rez*(zoomxy[37]-2);
   xyarray[4]= 0;   xyarray[5]= 0;   xyarray[6]= 28; xyarray[7]= 11;
   v_hide_c(gl_hand);
   vro_cpyfm(gl_hand,3,xyarray,&scrfdb,&edfdb);
   v_show_c(gl_hand,0);
   for (i=0; i<=23; i++) if (testrast[i]!=truerast[i]) return(1);

   return(0);
} /* end chekedit() */

/* EOF */
