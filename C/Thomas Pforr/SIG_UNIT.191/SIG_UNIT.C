/*------------------------------------------------*/
/*  Ausgabe von Text mit Signum E24-Font   1.0    */
/*        Anpassung in  TURBO-C 2.0               */
/*           Thomas Pforr 1.91                    */
/*                                                */
/*        vgl.: ct 6.90 S.290 ff                  */
/*              ST-Computer 2.89 S.85 ff          */
/*------------------------------------------------*/

#define _SIGUNIT_

#define _NEIG 4      /* Neigung fÅr Kusivschrift */

#include <tos.h>
#include <ext.h>
#include <string.h>
#include <vdi.h>

#include "sig_unit.h"

extern int handle,VDI_x,VDI_y;  /* <- im Hauptprogramm definieren ! */


long _ll;
long Fontadr=0L;
MFDB sigscreen_ptr,sig_ptr;
int _leerzeichen=5;
int _sigsperr=0;
int _hauptzeil=16;
int _wrtmode=SIG_REPLACE;
int _style=0;
int _hposition=0;
int _vposition=0;
int _hoehe=0;
int sigwork[8];

void unload_sigFont(void)
{
 if(Fontadr>0L) Mfree((void*)Fontadr);     /* Speicher freigeben */
 Fontadr=0L;
}


int load_sigFont(char *s)               /* Font laden und installieren */
{                                       /* Nicht benîtigter Teil der Datei */
int hdl;                                /* wird  nicht geladen (140 Bytes) */
long len,l;

     hdl=Fopen(s,0);
     if(hdl<0) return(hdl);     /* Font nicht gefunden etc. */

     unload_sigFont();          /* evt. alten Font lîschen */

     len=filelength(hdl)-140L;   /* Wie lang ist der Font */
     Fontadr=(long)Malloc(len); /* Speicher holen  */
     if(Fontadr<=0L) return(0); /* Kein Speicher ? */

     Fread(hdl,4L,&l);
     if(l!=0x65736574L)         /* nur Editor-Font zulassen */
      {
       Fclose(hdl);
       return(0);
      }

      Fread(hdl,136L,(char*)Fontadr);        /* Rest Åberlesen */
      if(len!=Fread(hdl,len,(char*)Fontadr))
      {
       unload_sigFont();        /* Font nur installieren wenn */
       Fclose(hdl);             /* Datei vollstÑndig geladen */
       return(0);
       }
      Fclose(hdl);

 sig_ptr.fd_w        =16;    /* Parameter fÅr vro_cpyfm */
 sig_ptr.fd_wdwidth  =1;     /* E24-Font hat 2 Byte/Zeichen */
 sig_ptr.fd_stand    =0;
 sig_ptr.fd_nplanes  =1;     /* fÅr SM 124 */

 *sigwork=*(sigwork+1)=0;    /* Ziel ist gesamter Bildschirm */
 *(sigwork+2)=16;
 *(sigwork+6)=VDI_x;
 *(sigwork+7)=VDI_y;         /* max. Bildschirmkoordinaten */


 /* Hîhe des 'A'(ASCII 65 *4=256) fÅr Vertikale Ausrichtung */

  _hoehe=*(char*)(Fontadr+*((long*) (Fontadr+256))+513L);

 return(1);
}

/*
 Ausgabe eines Zeichen

 x,y  : Position
 code : ASCII-Code des Zeichen
 mode : 1= ausgeben, 0= nur Breite holen
 return -> Breite des Zeichen

*/

int prt_sign(int x,int y,char code,int mode)
{
int i;
unsigned int mask=0x5555;
unsigned int _Fbuf[16];

 switch (code)
 {
  case 32  : return(_leerzeichen);
  case 'Ñ' : code=93;break;    /* Umwandlung ASCII in Signum-Code  */
  case 'î' : code=91;break;    /* Die Zeichen des Ziffernblock     */
  case 'Å' : code=64;break;    /* mÅssen gesondert behandelt werden */
  case 'é' : code=125;break;
  case 'ô' : code=123;break;
  case 'ö' : code= 92;break;
  case 'û' : code=127;break;
  case '{' : code= 1 ;break;   /* Diese Zeichen kînnen          */
  case '}' : code= 2 ;break;   /* je nach Font abweichen (s.o.) */
  case '[' : code=15 ;break;   /* hier Anpassung fÅr GROTLT     */
  case ']' : code=16 ;break;   /* ! nicht vollstÑndig */
  case '\\':
  case '@' : return(_leerzeichen);
 }


    if(code<1 || code>127) return(0) ; /* Nur Zeichen von 1-127
                                          erlaubt */


 _ll=*((long*) (Fontadr+(code<<2)));   /*Zeiger auf Header fÅr Zeichen */

 if((Fontadr+_ll)<=0L) return(0);    /* Zeichen nicht definiert */

 if(mode)          /* Wenn mode=1  dann ausgeben */
 {



 if(_style & (SIG_HELL|SIG_ITALIC))
 {
  memcpy((char*)_Fbuf,(char*)(Fontadr+_ll+516L),32);

  if(_style & SIG_HELL)
    for(i=0;i<16;i++)
     {
      _Fbuf[i] &=mask;
      mask=~mask;
     }

  if(_style & SIG_ITALIC)
  {
     mask=1;
      for(i=15;i>=0;i--)
      {
       _Fbuf[i] =(_Fbuf[i]>>mask);
       if (0==i % _NEIG) mask++;
      }
  }
  sig_ptr.fd_addr =(char*)_Fbuf; /* Adresse des Bitmap des Zeichen */
 }
 else
 sig_ptr.fd_addr =(char*)(Fontadr+_ll+516L);

 *(sigwork+3)=sig_ptr.fd_h =*((char*)(Fontadr+_ll+513L))-1;  /* Hîhe des Zeichen */
 *(sigwork+4)=x;                                               /* x-Position */
 *(sigwork+5)=y+*((char*)(Fontadr+_ll+512L))-17;               /* y-Position */
 vro_cpyfm(handle,_wrtmode,sigwork,&sig_ptr,&sigscreen_ptr);

 if(_style & SIG_FETT)
  {
  *(sigwork+4)=x+1;
  vro_cpyfm(handle,SIG_TRANSPARENT,sigwork,&sig_ptr,&sigscreen_ptr);
  }
 }


 return(*(char*)(Fontadr+_ll+514L));      /* Zeichenbreite zurÅckgeben */
}

/*
   Text ausgeben
    x,y : Startposition
    s   : Text mit 0-Byte am Ende;

    return -> neue x-Position

*/

int prt_text(int x,int y,char *s)
{
char *p;
int   w,pxy[4];


 w=0;

 p=s;
 if(Fontadr<=0L) return(x);            /* Nur wenn Font geladen */

 if(_hposition || _style & SIG_UNDER)    /* Breite berechnen */
 {
  while(*s)
           {
            w+=prt_sign(w,y,*s,0)+_sigsperr;
            s++;
           }

  switch(_hposition)
  {
   case SIG_CENTER : x-=w/2;break;
   case SIG_RIGHT  : x-=w  ;break;
  }
 }

  switch(_vposition)
  {
   case SIG_MIDLE  : y+=_hoehe/2;break;
   case SIG_TOP    : y+=_hoehe;break;
  }

 while(*p){
           x+=prt_sign(x,y,*p,1)+_sigsperr; /* Ausgabe der Zeichen */
           p++;
          }


  if(_style&SIG_UNDER)
  {
   pxy[0]=x-w;
   pxy[1]=pxy[3]=y+2;
   pxy[2]=x;
   v_pline(handle,2,pxy);
  }

  return(x);

}

/*
   Parameter setzen
   leer  : Breite des Leerzeichen
   sperr : Offset zur Proportionalbreite
   wmode : Scheibmode 0 - 15 ( vgl. vrq_cpyform )
   style : unterstrichen etc.
   hpos  : LinksbÅndig,Zentriert,RechtbÅndig
   vpos  : oben,mitte,unten
   neig  : Neigung bei Kursivschrift, 2,4,6,8 (ausprobieren)
*/

void set_sigpar(int leer,int sperr,int zeil,int wmode,int style,int hpos,int vpos)
{
 if(leer  !=NICHT)  _leerzeichen=leer;
 if(sperr !=NICHT)  _sigsperr   =sperr;
 if(zeil  !=NICHT)  _hauptzeil  =zeil;   /* noch nicht beutzt */
 if(wmode !=NICHT)  _wrtmode    =wmode;
 if(style !=NICHT)  _style      =style;
 if(hpos  !=NICHT)  _hposition   =hpos;
 if(vpos  !=NICHT)  _vposition   =vpos;
}

