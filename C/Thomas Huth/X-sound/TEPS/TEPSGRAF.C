/* TEPS: Grafischer Teil */

#include <osbind.h>
#include <falcon.h>
#include <aes.h>                /* GEM - Definitionen */
#include <vdi.h>
#include "teps.h"

#ifndef TRUE
#define TRUE -1
#endif

/* Prototypen: */
char  *strcpy( char *s1, const char *s2 );      /* Standartfunktionen */
char  *itoa( int value, char *string, int radix );

extern OBJECT *dialtree;         /* Definitionen in TEPSMAIN */
extern int swihndl;
extern int dwix, dwiy, dwiw, dwih;
extern int vhandle;
extern char *lvolslid;
extern char *rvolslid;
extern char *playbufstart;
extern char *playbufend;
extern long playlength;
extern int vhandle;              /* Definition in TEPSINIT */
extern char popupposibl;
extern char *lvolslid, *rvolslid;
extern short etimer;

MFDB scrmfdb = { 0L, 0, 0, 0, 0, 0, 1, 1, 1};   /* MFDB auf Schirm */

char soundmode=0;       /* 0=8Bit mono, 1=8Bit stereo, 2=16Bit */


/* ***Sample zeichnen*** */
void drawsample(void)
{
 GRECT swi;             /* Koordinaten Samplefenster */
 GRECT clip;            /* Clippingkoordinaten */
 int xy[8];             /* Koordinatenfeld */
 register char *s_pos;
 register int samwert;  /* Sample-Wert */

 winx_get(swihndl, WF_WORKXYWH, &swi);

 wind_update(BEG_UPDATE); graf_mouse(M_OFF, 0L);

 winx_get(swihndl, WF_FIRSTXYWH, &clip);
 do
  {
   if( rc_intersect(&swi, &clip) )
    {
     xy[0]=xy[4]=clip.g_x;             xy[1]=xy[5]=clip.g_y;
     xy[2]=xy[6]=clip.g_x+clip.g_w-1;  xy[3]=xy[7]=clip.g_y+clip.g_h-1;
     vro_cpyfm(vhandle, ALL_WHITE, xy, &scrmfdb, &scrmfdb);  /* Clear */
    }
   winx_get(swihndl, WF_NEXTXYWH, &clip);
  }
 while(clip.g_w && clip.g_h);

 winx_get(swihndl, WF_FIRSTXYWH, &clip);

 for(s_pos=playbufstart; s_pos<playbufend; s_pos+=playlength/swi.g_w*2)
  {
   samwert=*s_pos;
   switch(soundmode)
    {
     case 1: samwert=(samwert+ *s_pos++)/2;    /* 8-Bit stereo */
        break;
     case 2: samwert=(samwert+ *(++s_pos))/2;  /* 16-Bit stereo */
        s_pos+=2; break;
    }

   xy[0]=(int)(swi.g_x+(long)swi.g_w*(s_pos-playbufstart)/playlength);
   xy[2]=xy[0]+1;
   xy[1]=xy[3]=swi.g_y+swi.g_h/2+samwert*swi.g_h/255;
   winx_get(swihndl, WF_FIRSTXYWH, &clip);
   do
    {
     if(xy[0]>clip.g_x && xy[0]<clip.g_x+clip.g_w && xy[1]>clip.g_y && xy[1]<clip.g_y+clip.g_h)
       {
        v_pmarker(vhandle, 2, xy);     /* Punkt setzen */
        clip.g_w=0;
       }
      else winx_get(swihndl, WF_NEXTXYWH, &clip);
    }
   while(clip.g_w && clip.g_h);

  }

 graf_mouse(M_ON, 0L); wind_update(END_UPDATE);
}

/* ***Oszilloskop*** */
void oscilloscope(void)
{
 GRECT swi;					/* Koordinaten Samplefenster */
 GRECT clip;				/* Clippingkoordinaten */
 register int x_pos;
 register char *s_pos;
 int xy[8];					/* Koordinatenfeld */
 static int cnt;
 register int  samwert;		/* Sample-Wert */
 SndBufPtr bufptr;			/* enth„lt Zeiger auf akt. Wert */

 if((Buffoper(-1)&1)==0) { if(etimer>=0) drawsample(); etimer=-1; return; }

 winx_get(swihndl, WF_WORKXYWH, &swi);

 Buffptr(&bufptr);
 s_pos=(char *)(bufptr.play)-swi.g_w/8;

/* wind_update(BEG_UPDATE);*/

 if(!((cnt++)&3))
 {
 winx_get(swihndl, WF_FIRSTXYWH, &clip);
 do
  {
   if( rc_intersect(&swi, &clip) )
    {
     xy[0]=xy[4]=clip.g_x;  xy[2]=xy[6]=clip.g_x+clip.g_w-1;
     xy[1]=xy[5]=clip.g_y;  xy[3]=xy[7]=clip.g_y+clip.g_h-1;
     vro_cpyfm(vhandle, ALL_WHITE, xy, &scrmfdb, &scrmfdb);  /* Clear */
    }
   winx_get(swihndl, WF_NEXTXYWH, &clip);
  }
 while(clip.g_w && clip.g_h);
 }

 for(x_pos=swi.g_x; x_pos<swi.g_x+swi.g_w-1; x_pos+=4)
  {
   samwert=*s_pos++;    /* Wert lesen */
   switch(soundmode)
    {
     case 1: samwert=(samwert+ *s_pos++)/2;    /* 8-Bit stereo */
        break;
     case 2: samwert=(samwert+ *(++s_pos))/2;  /* 16-Bit stereo */
        s_pos+=2; break;
    }
   if(s_pos<playbufstart)  samwert=*playbufstart;
   if(s_pos>playbufend)  samwert=*playbufend;

   xy[0]=x_pos;    xy[1]=swi.g_y+swi.g_h/2+samwert*swi.g_h/255;
   winx_get(swihndl, WF_FIRSTXYWH, &clip);
   do
    {
     if(xy[0]>clip.g_x && xy[0]<clip.g_x+clip.g_w && xy[1]>clip.g_y && xy[1]<clip.g_y+clip.g_h)
       {
        v_pmarker(vhandle, 1, xy);     /* Punkt setzen */
        clip.g_w=0;
       }
      else winx_get(swihndl, WF_NEXTXYWH, &clip);
    }
   while(clip.g_w && clip.g_h);
  }

/* wind_update(END_UPDATE);*/
}


/* ***Slider bewegen + auswerten*** */
void do_slider(int pa_box, int slider, int sndcmd)
{
 int mausx, mausy, mausbut, dummy;      /* Mauskoordinaten + Knopf */
 int slidx, box_x, max_slidx, slider_w;
 int s_wert;

 objc_offset(dialtree, pa_box, &box_x, &dummy);
 slider_w=dialtree[slider].ob_width;
 max_slidx=box_x+dialtree[pa_box].ob_width-slider_w;

 wind_update(BEG_UPDATE);
 graf_mouse(FLAT_HAND, 0L);
 objc_change(dialtree, slider, 0, dwix, dwiy, dwiw, dwih, SELECTED, 1);
 do
  {
   graf_mkstate(&mausx, &mausy, &mausbut, &dummy);
   slidx=mausx-slider_w/2-(mausx % (slider_w/3));
   if(slidx<box_x)  slidx=box_x;
   if(slidx>max_slidx)  slidx=max_slidx;
   slidx-=box_x;
   if(slidx!=dialtree[slider].ob_x)
   {
   s_wert=slidx/(slider_w/3);
   switch(sndcmd)
    {
     case 0: itoa(s_wert, lvolslid, 10); break;
     case 1: itoa(s_wert, rvolslid, 10); break;
    }
   Soundcmd(sndcmd, (15-s_wert)<<4);
   dialtree[slider].ob_x=slidx;
   objc_draw(dialtree, pa_box, 1, dwix, dwiy, dwiw, dwih);
   }
  }
 while(mausbut==1);
 objc_change(dialtree, slider, 0, dwix, dwiy, dwiw, dwih,
          NORMAL, 1);
 graf_mouse(ARROW, 0L);
 wind_update(END_UPDATE);
}
