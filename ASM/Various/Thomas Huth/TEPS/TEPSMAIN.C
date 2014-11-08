/* TEPS: Haupteil/Reaktion auf Benutzer */

#include <osbind.h>
#include <falcon.h>
#include <aes.h>
#include <string.h>
#include "teps.h"
#include "windial.h"

#ifndef TRUE
#define TRUE   -1
#endif

/* Prototypen: */
void write_error(char *text);                /* ->TEPSINIT */
int  initsamplebuf(void);
int  initGEM(void);
void exitGEM(void);
void drawsample(void);                       /* ->TEPSGRAF */
void oscilloscope(void);
void do_slider(int pa_box, int slider, int sndcmd);
int  do_popup(OBJECT *buttree, int butnr, MENU *popdat);
void swtchsign(char *start, char *ende, int modus);   /* ->TEPSCONV */

short msgbuff[8];                  /* Nachrichtenbuffer */
OBJECT *menutree;                /* Adresse des Menbalkens */
OBJECT *dialtree;                /*  "      " Dialogfeldes */
OBJECT *moditree;   /* Fr Modi-PopUpmen */
OBJECT *freqstree;
int dwihndl;
int swihndl;                     /* Sample-Fensterkennung */
short dwix, dwiy, dwiw, dwih;
short choice;
short etimer=-1;

short freqsitem=F12KHZ, modiitem=M8BUT;

char *sambufstart;               /* Zeiger auf den Sample-Buffer */
char *sambufend;                 /* Zeiger aufs Ende */
char *playbufstart;
char *playbufend;
long samlength;
long playlength;
int sndmodus=0;                  /* 0=Mono8, 1=Stereo8, 2=Stereo16 */

char endeflag=0;				/* Wenn true -> Ende */

char dateiname[32]="NONAME.SAM";  /* Globaler Filename */
char fpath[256];                  /* Globaler Pfadname */

/* ***Fileselectbox darstellen und Name zusammenfgen*** */
int fileselect(char *pathnname, char *boxtitle)
{
 int i, fs_button;
 char *pathend;

 wind_update(BEG_MCTRL);
 if(gl_apversion>0x0130)
   i=fsel_exinput(fpath, dateiname, &fs_button, boxtitle);
  else
   i=fsel_input(fpath, dateiname, &fs_button);
 wind_update(END_MCTRL);
 if(i==0 || fs_button==0)  return(-1);

 strcpy(pathnname, fpath);
 pathend=strrchr(pathnname, '\\');
 if(pathend==0)
   pathend=pathnname; else ++pathend;
 strcpy(pathend, dateiname);            /* Pfad und Name zusammen */

 return(0);
}

/* ***Ein Sample laden*** */
void loadsample(void)
{
 char fullname[128];
 int fhandle;

 if( fileselect(fullname, "Sample laden") ) /* Pfad und Name -> fullname */
   return;

 fhandle=Fopen(fullname, 0);
 playlength=Fread(fhandle, samlength, sambufstart);
 if(playlength<0L)
  {
   write_error("Datei konnte|nicht geladen werden!");
   playlength=samlength;
  }
 playbufend=playbufstart+playlength;
 Setbuffer(0, playbufstart, playbufend);
 Fclose(fhandle);
}


/* ***Menauswahl*** */
void reactmenu(short title, short entry)
{
 register long *s_pos;

 switch(entry)
  {
   case ABOUT:
    form_alert(1,
      "[1][TEPS V0.9ž|Player fr Samplesounds"
      "|Geschrieben von T. Huth|\xBD 1996/99][ OK ]");
    break;
   case NEW:
    for(s_pos=(long *)playbufstart; s_pos<(long *)playbufend; s_pos++)
      *s_pos=0;
    drawsample();
    break;
   case SAMLOAD:
    loadsample();
    break;
   case ENDE:
    endeflag=TRUE;      /* Ende signalisieren */
    break;
   case CHGNSIGN:
    swtchsign(playbufstart, playbufend, sndmodus);
    drawsample();
    break;
  }

 menu_tnormal(menutree, title, 1);
}


void hndlmsgs(int *msgbf)
{
   switch(msgbf[0])
    {
     case WM_REDRAW:
      if(msgbf[3]==swihndl)  drawsample();
      break;
     case WM_TOPPED:
      wind_set(msgbf[3], WF_TOP, 0, 0, 0, 0);
      break;
     case WM_MOVED:
      wind_set(msgbf[3], WF_CURRXYWH, msgbf[4], msgbf[5], msgbf[6], msgbf[7]);
      break;
     case MN_SELECTED:
      reactmenu(msgbf[3], msgbf[4]);
      break;
    }
}


/* ***Hauptteil*** */
int main(void)
{
 int i;

 if( initGEM() )  { return(-1); }

 i=(int)Locksnd();             /* Soundsubsystem fr andere sperren */
 if(i!=1)
  {
   if(i==-129)
    {
     if(form_alert(1, "[3][Soundsubsystem ist|schon gesperrt!][Weiter|Stop]")==2)
      {exitGEM();  return(-1);}
    }
    else
    {
     if(form_alert(1, "[3][Kein Soundsubsystem|vorhanden!][Weiter|Stop]")==2)
      {exitGEM();  return(-1);}
    }
  }

 if( initsamplebuf() )  { exitGEM(); Unlocksnd(); return(-1); }

 fpath[0]='A'+Dgetdrv();      /* Laufwerk ermitteln */
 fpath[1]=':';
 Dgetpath(&fpath[2], 0);
 strcat(fpath, "\\*.*");

 dwihndl=wdial_init(dialtree, " TEPS - The Sampleplayer ");
 if(!dwihndl)
  { exitGEM(); Unlocksnd(); return(-1); }

 do
 {
  choice=wdial_formdo(dwihndl, dialtree, 0, hndlmsgs, etimer, oscilloscope)&0x7FFF;
  wind_get(dwihndl, WF_WORKXYWH, &dwix, &dwiy, &dwiw, &dwih);

  switch(choice)
   {
    case PLAY:
      if(dialtree[SREPEAT].ob_state & SELECTED)  i=3;  else i=1;
      if( Buffoper(i) )
        write_error("Sample konnte nicht|gestartet werden!");
      etimer=20;
      objc_change(dialtree, PLAY, 0, dwix, dwiy, dwiw, dwih, NORMAL, 1);
      break;
    case STOP:
      if( Buffoper(0) )
        write_error("Sample konnte nicht|angehalten werden!");
      objc_change(dialtree, STOP, 0, dwix, dwiy, dwiw, dwih, NORMAL, 1);
      etimer=-1;
      drawsample();
      break;
    case MODUSBUT:
      if( wdial_popupbutn(dialtree, MODUSBUT, moditree, &modiitem) )
      switch(modiitem)
       {
        case M8BUT:  Setmode(MONO8); sndmodus=0; break;
        case S8BUT:  Setmode(STEREO8); sndmodus=1; break;
        case S16BUT:
         if(Setmode(STEREO16))
           write_error("Kein 16-Bit m”glich!");
          else sndmodus=2;
         break;
       }
      break;
    case FREQBUT:
      if( wdial_popupbutn(dialtree, FREQBUT, freqstree, &freqsitem) )
        Devconnect(DMAPLAY, DAC, 0, freqsitem-F50KHZ+1, 1);
      break;
    case SREPEAT:
      dialtree[SREPEAT].ob_state^=SELECTED;
      objc_draw(dialtree, SREPEAT, 0, dialtree->ob_x, dialtree->ob_y,
                dialtree->ob_height, dialtree->ob_width);
      do { short d;
           graf_mkstate(&d, &d, &i, &d); } while(i==1);  /* Bis Maustaste losgelassen wird */
      if(Buffoper(-1)!=0)
       if(dialtree[SREPEAT].ob_state & SELECTED)
        Buffoper(3);  else Buffoper(1);
      break;
    case LVOLSLID:
      do_slider(LVOLBOX, LVOLSLID, 0);
      break;
    case RVOLSLID:
      do_slider(RVOLBOX, RVOLSLID, 1);
      break;
   }

 }
 while( !endeflag );       /* Ende der Hauptschleife */

 wdial_close(dwihndl);
 exitGEM();
 Unlocksnd();
 return(0);
}
