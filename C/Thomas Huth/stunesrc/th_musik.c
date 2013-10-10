/**
 * STune - The battle for Aratis
 * th_musik.c : All functions related to music and sound
 * Copyright (C) 2003 Thomas Huth
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */

#include <string.h>

#include <osbind.h>
#include <falcon.h>

#include "stunmain.h"
#include "th_init.h"
#include "th_aesev.h"
#include "th_graf.h"

#ifdef __TURBOC__
#define CDECL1
#define CDECL2 cdecl
#endif

#ifdef SOZOBON
#define CDECL1 cdecl
#define CDECL2
#endif

#ifdef __GNUC__
#define CDECL1 
#define CDECL2
#endif


/* ########### MOD Definitionen und Strukturen ############ */

/* **Die defines von TeTra:** */
#define MOD_OK       0x4D00
/* MOD_NAK: Not okay, the command was understood but rejected. */
#define MOD_NAK      0x4D01
/* MOD_PLAY: Play the module, MOD_OK or MOD_NAK is replied. */
#define MOD_PLAY     0x4D02
/* MOD_STOP: Stop playing the module. */
#define MOD_STOP     0x4D03
/* MOD_LOAD: Load a module into the buffer, MOD_NAK is replied if
 something went wrong, MOD_OK if it is okay. msgbuf[3]+msgbuf[4]
 are a pointer to the module filename. */
#define MOD_LOAD     0x4D04
/* MOD_CLEAR: Stop module and clear the buffer. */
#define MOD_CLEAR    0x4D05

/* **Die defines von Paula (mind. V2.4!)** */
/* MP_ACK: Paula sagt OK! Das vorige Kommando ist verstanden
    worden. msg[7] enthÑlt die Versionsnummer des Programms; 0x204 =
    v2.4 */
#define MP_ACK 0x4800
/* MP_NAK: Paula sagt NICHT OK! Das vorige Kommando ist
    nicht verstanden bzw. abgelehnt worden. msg[7] enthÑlt die
    Versionsnummer des Programms; 0x204 = v2.4 */
#define MP_NAK 0x4801
/* MP_START: Funktion ist identisch mit VA_START. Nach
    öbernahme des Kommandostrings schickt Paula aber eine MP_ACK
    (bzw. MP_NAK)-Nachricht an den Absender zurÅck, und signalisiert
    so, daû der in der MP_START-Nachricht angegebene Speicherbereich
    anderweitig benutzt werden kann. */
#define MP_START 0x4802
/* MP_STOP: Stoppt Paula und gibt den fÅr MODs und Playlisten
    allozierten Speicher frei. Das Fenster bleibt offen. Paula
    schickt MP_ACK zurÅck. */
#define MP_STOP 0x4803
/* MP_SHUTDOWN: Stoppt und beendet Paula. Im Accessory-
    Modus wird nur der Speicher freigegeben und das Fenster
    geschlossen.Paula schickt MP_ACK zurÅck. */
#define MP_SHUTDOWN 0x4804

/* **Die defines von Ultimate-Tracker:** */
#define  T_LOAD      900
#define  T_PLAY      901
#define  T_PAUSE     904
#define  T_STOP      905
#define  ID_TRACK    999


/* *** SPI Interface Strukturen *** */
typedef struct
{
 long magic;
 short mainvers;        /* SPI Definitionsversion */
 short tpivers;         /* Version of the SPI - quite unimportant! */
 void *tbp;          /* Pointer to the basepage of the player */
 unsigned long support; /* Bitfield of supported calls/modes */
 long plflags;       /* Bitfield of player-flags */
 long res1;
 char *cstr1;        /* Pointer to the 1st Copyrightstring */
 char *cstr2;        /*   "      "  "  2nd   "     "    */
 char *frqstr1;
 char *frqstr2;
 char *frqstr3;
 CDECL1 int CDECL2 (*modplay)(void *modaddr);     /* Play routine */
 CDECL1 int CDECL2 (*modstop)(void);      /* Stop routine */
 CDECL1 int CDECL2 (*modsetup)(short opcode, long subcode);   /* Configuration routine */
 CDECL1 int CDECL2 (*modpause)(void);     /* Pause */
 CDECL1 int CDECL2 (*modforward)(void);   /* Fast forward*/
 CDECL1 int CDECL2 (*modbackward)(void);  /* Fast backward */
 CDECL1 int CDECL2 (*samplay)(void *start, void *end, int chan);
} SPI;

typedef struct spi_basep
{
 char    *p_lowtpa;
 char    *p_hitpa;
 long    (*p_tbase)(void);
 long    p_tlen;
 char    *p_dbase;
 long    p_dlen;
 char    *p_bbase;
 long    p_blen;
 char    *p_dta;
 struct spi_basep  *p_parent;
 char    *p_resrvd0;
 char    *p_env;
 char    p_resrvd1[80];
 char    p_cmdlin[128];
} SPI_BP;



/* ############## Variablen ############ */

/* PSG-Geraeusche, fertig fÅr Dosound() */
unsigned short mg[]={ 0x0006, 0x0104, 0x0600, 0x07F4, 0x0BAE, 0x0C01, 0x0D08, 0x0810, 0xFF16, 0x0800, 0xFF00 };
unsigned short click1[]={ 0x0273, 0x0300, 0x07F4, 0x090F, 0xFF01, 0x0900, 0xFF00 };
unsigned short click2[]={ 0x024B, 0x0300, 0x07F4, 0x090F, 0xFF01, 0x0900, 0xFF00 };
unsigned short kaputt[]={ 0x00A0, 0x010F, 0x061F, 0x0810, 0x0B98, 0x0C3A, 0x0D09, 0xFF00 };
unsigned short granate[]={ 0x00B8, 0x010B, 0x0610, 0x0810, 0x0B70, 0x0C17, 0x0D09, 0xFF00 };
unsigned short moep[]={ 0x0014, 0x0105, 0x0810, 0x0C00, 0x0B56, 0x07F8, 0x0D08, 0xFF0F, 0x0800, 0xFF00 };
unsigned short ready[]={0x07D9, 0x0800, 0x0A00, 0x0266, 0x0301, 0x090C, 0xFE0F, 0x02EF, 0x0300, 0xFE2D, 0x07DB, 0x0900, 0xFF00 };

/* Flags zum Abspielmodus: */
short sndpsgflag=0;
short sndsamflag=1;
short sndvocflag=1;
short sndmodflag=0;

/* Allgemeine Variablen: */
int samqueue[8]={-1,-1,-1,-1,-1,-1,-1,-1}; /* Warteschleife fÅr Samples */
int sqanz=0;

int ptyp;               /* Playertyp: 0=keiner; 1=SPI; 2=TeTra; 3=Paula; 4=U-Tracker */
int pl_id;              /* AES-Id des Players */
int wmsgbf[8];          /* Nachrichtenbuffer zum Verschicken */

SPI *tspi;
short playflag=FALSE;
void *mod_addr=0L;
short aktchan=0;


#define SAM_ANZAHL 17
typedef struct
{
 char *name;
 short type;            /* 0=Immer im Speicher; 1=Muss erst nachgeladen werden */
 short playtype;        /* 0=Voicesample (->in Queue); sonst: GerÑuschsample, sofort spielen */
 void *start;           /* Anfangsadresse */
 void *end;             /* Endadresse */
 void *dosnd;           /* Alternativer DoSound */
 char *text;            /* Text fÅr das Infofenster */
} THSAMPLE;

THSAMPLE samples[SAM_ANZAHL]=
{
 "ang.raw",0,0,0L,0L,0L,0L/*"Unsere Basis wird angegriffen! "*/,
 "ein.raw",0,0,0L,0L,ready,0L/*"Einheit bereit. "*/,
 "energie.raw",0,0,0L,0L,0L,0L/*"Energieniveau kritisch! "*/,
 "erfol.raw",0,0,0L,0L,ready,0L/*"Einsatz erfolgreich. "*/,
 "fehl.raw",0,0,0L,0L,0L,0L/*"Einsatz fehlgeschlagen. "*/,
 "finanz.raw",0,0,0L,0L,0L,0L/*"Unzureichende Finanzmittel. "*/,
 "kon.raw",0,0,0L,0L,ready,0L/*"Konstruktion abgeschlossen. "*/,
 "radar.raw",0,0,0L,0L,0L,0L/*"Radar aktiviert. "*/,
 "radarde.raw",0,0,0L,0L,0L,0L/*"Radar deaktiviert. "*/,
 "verl.raw",0,0,0L,0L,0L,0L/*"Einheit verloren. "*/,
 "maschine.raw",0,1,0L,0L,mg,0L,
 "click1.raw",0,1,0L,0L,click1,0L,
 "click2.raw",0,1,0L,0L,click2,0L,
 "kaputt.raw",0,1,0L,0L,kaputt,0L,
 "granate.raw",0,1,0L,0L,granate,0L,
 "moep.raw",0,1,0L,0L,moep,0L,
 "scream.raw",0,0,0L,0L,0L,0L
};



/* ############# Funktionen ############### */


/* ***MOD-Player initialisieren*** */
int mod_init(void)
{
 short sfh;
 SPI_BP *spibp;
 int i;
 char *sname;
 unsigned long scookie;

 if( !xgetcookie(0x5F534E44L, &scookie) ) scookie=0;    /* '_SND' */

 for(i=0; i<=2; i++)
  {
   switch(i)
    {
     case 0:
       if( (scookie & 0x1E)!=0x1E ) continue;
       sname="musik\\dsp.spi";
       break;
     case 1:
       if( (scookie & 0x2)!=0x2 ) continue;
       sname="musik\\dma.spi";
       break;
     case 2:
       if( (scookie & 0x20)!=0x20 ) continue;
       sname="musik\\xbios.spi";
       break;
    }
   if( (sfh=Fopen(sname, 0)) > 0L ) /* Check if the SPI exists */
    {
     Fclose(sfh);
     spibp=(SPI_BP *)Pexec(3, sname, "", "");   /* Load the SPI */
     if((long)spibp>0L)
      {
       Mshrink(spibp, spibp->p_tlen+spibp->p_dlen+spibp->p_blen+256L);
       tspi=(SPI *)spibp->p_tbase();             /* Init the TPI */
       if((long)tspi>0L)
        {
         tspi->tbp=spibp;
         ptyp=1;
         return(0);
        }
       else
        {
         /*form_alert(1, "[3][SPI init error][Ok]");*/
         tspi=0L; Mfree(spibp);
        }
      }
    }
  }

 pl_id=appl_find("TETRA   ");
 if(pl_id>=0)
  {
   ptyp=2;
   return(0);
  }

 pl_id=appl_find("TETRAX  ");
 if(pl_id>=0)
  {
   ptyp=2;
   return(0);
  }

 pl_id=appl_find("PAULA   ");
 if(pl_id>=0)
  {
   ptyp=3;
   return(0);
  }

 pl_id=appl_find("U_TRACK ");
 if(pl_id>=0)
  {
   ptyp=4;
   return(0);
  }

 ptyp=0;
 return(-1);
}

/* ***Auf das Okay des Players warten*** */
int wait4plok(void)
{
 int i, mok, mnak;

 if(ptyp==2) { mok=MOD_OK; mnak=MOD_NAK; }
 if(ptyp==3) { mok=MP_ACK; mnak=MP_NAK; }

 i=0;
 do
  {
   evnt_mesag(msgbuf);
   if( msgbuf[0]==mnak || i++>10)  return(-1);
   if( msgbuf[0]!=mok )  mesages();
  }
 while( msgbuf[0]!=mok );

 return(0);
}


/* ***MOD spielen*** */
int mod_play(char *mname)
{
 /*int i;*/

 wmsgbf[1]=ap_id;
 wmsgbf[2]=0;

 switch(ptyp)
  {
   case 1:
     if(tspi)
      {
       int fhndl;
       long flength;
       if(playflag && mod_addr)  /* Already playing? */
         tspi->modstop();     /* Yes: Stop first */
       fhndl=Fopen(mname, 0);
       if(fhndl<0) return(fhndl);
       flength=Fseek(0L, fhndl, 2);     /* Grîûe ermitteln */
       Fseek(0L, fhndl, 0);
       mod_addr=(char *)Mxalloc(flength, 0);  /* Speicher reservieren */
       if( ((signed long)mod_addr)==-32L )  mod_addr=(char *)Malloc(flength);
       if( ((signed long)mod_addr)<=0L )  return( (int)mod_addr );
       Fread(fhndl, flength, mod_addr);
       Fclose(fhndl);
       tspi->modplay(mod_addr);  /* Start playing */
       playflag=TRUE;
      }
     break;
   case 2:  /* Tetra */
     wmsgbf[0]=MOD_LOAD;
     *(char **)&wmsgbf[3]=mname;
     if( !appl_write(pl_id, 16, wmsgbf) )  return(-1);
     if( wait4plok() ) return(-1);
     wmsgbf[0]=MOD_PLAY;
     if( !appl_write(pl_id, 16, wmsgbf) )  return(-1);
     if( wait4plok() ) return(-1);
     break;
   case 3:  /* Paula */
     wmsgbf[0]=MP_START;
     *(char **)&wmsgbf[3]=mname;
     if( !appl_write(pl_id, 16, wmsgbf) )  return(-1);
     if( wait4plok() ) return(-1);
     break;
   case 4:  /* Ultimate Tracker */
     wmsgbf[0]=ID_TRACK;
     wmsgbf[1]=T_LOAD;
     *(char **)&wmsgbf[2]=mname;
     if( !appl_write(pl_id, 16, wmsgbf) )  return(-1);
     wmsgbf[1]=T_PLAY;
     if( !appl_write(pl_id, 16, wmsgbf) )  return(-1);
     break;
   default:
     return(-1);
  }

 return(0);
}

/* ***MOD-Wiedergabe beenden*** */
int mod_stop()
{
 wmsgbf[1]=ap_id;
 wmsgbf[2]=0;

 switch(ptyp)
  {
   case 1:  /* SPI */
     if(tspi && playflag)
      {
       tspi->modstop();
       Mfree(mod_addr);
       mod_addr=0L;
      }
     playflag=FALSE;
     break;
   case 2:  /* TeTra */
     wmsgbf[0]=MOD_STOP;
     if( !appl_write(pl_id, 16, wmsgbf) ) return(-1);
     if( wait4plok() ) return(-1);
     wmsgbf[0]=MOD_CLEAR;
     if( !appl_write(pl_id, 16, wmsgbf) )  return(-1);
     if( wait4plok() ) return(-1);
     break;
   case 3:  /* Paula */
     wmsgbf[0]=MP_STOP;
     if( !appl_write(pl_id, 16, wmsgbf) )  return(-1);
     if( wait4plok() ) return(-1);
     break;
   case 4:  /* Ultimate Tracker */
     wmsgbf[0]=ID_TRACK;
     wmsgbf[1]=T_STOP;
     if( !appl_write(pl_id, 16, wmsgbf) )  return(-1);
     break;
   default:
     return(-1);
  }

 return(0);
}




/* ***Samplesounds laden:*** */
int initsamples(void)
{
 long flength;
 int fhndl, i;
 char *samadr;
 char samname[22];

 for(i=0; i<SAM_ANZAHL; i++)
  {
   if( samples[i].type ) continue;
   strcpy(samname, "musik\\");
   strcat(samname, samples[i].name);
   fhndl = Fopen(samname, 0);
   if(fhndl<0)  return(fhndl);
   flength=Fseek(0L, fhndl, 2);     /* Grîûe ermitteln */
   Fseek(0L, fhndl, 0);

   samadr=(char *)Mxalloc(flength, 0);  /* Speicher reservieren */
   if( ((signed long)samadr)==-32L )  samadr=(char *)Malloc(flength);
   if( ((signed long)samadr)<=0L )  return((int)samadr);
   Fread(fhndl, flength, samadr);
   Fclose(fhndl);
   samples[i].start=samadr;
   samples[i].end=samadr+flength-2;
  }

 return(0);
}


/* ***Neues Sample in Abspielliste aufnehmen oder direkt spielen*** */
void playsample(short snr)
{
 int i=0;

 if( samples[snr].text )  neuemeldung(samples[snr].text);  /* Auch als Text ausgeben */

 if( samples[snr].playtype==0 )
  {
   if( sndvocflag )
    {
     while(i<7 && samqueue[i]!=-1) i++;          /* In Queue aufnehmen */
     if(samqueue[i]==-1)
      {
       samqueue[i]=snr;
       sqanz+=1;
      }
    }
    else
     if(sndpsgflag && samples[snr].dosnd)
       Dosound(samples[snr].dosnd);
  }
  else                                   /* Sample direkt spielen */
  {
   if( sndpsgflag && samples[snr].dosnd )
     Dosound(samples[snr].dosnd);
    else
     if( samples[snr].start )         /* ungÅltige Samples ignorieren */
      {
       if( ptyp==1 && playflag && tspi )
        {
         tspi->samplay(samples[snr].start, samples[snr].end, aktchan);
         aktchan+=1;
         if(aktchan==4) aktchan=0;
        }
        else if( /*sndsamflag &&*/ !Buffoper(-1) && Locksnd()==1 )
        {
         if( samples[snr].type )
           { } /* Nachladbare Samples kommen spÑter */
          else
           {
            Devconnect(0, 8, 0, 3, 1);     /* 25kHz einstellen, fÅr 12.5kHz: 7 statt 3 */
            Setmode(2);
            Setbuffer(0, samples[snr].start, samples[snr].end);
            Buffoper(1);                   /* Sample direkt spielen */
           }
          Unlocksnd();
         }
      }
  }

}


/* *** Samples in der Queue nacheinander abspielen: *** */
void sam_abarbeiten()
{
 static int aktsam=0;

 if( !sqanz ) return;

 if( samqueue[aktsam]!=-1 )
  {
   if( samples[samqueue[aktsam]].type )
    { } /* Nachladbare Samples kommen spÑter */
    else
    {
     if( samples[samqueue[aktsam]].start ) /* ungÅltige Samples ignorieren */
      {
       if( ptyp==1 && playflag && tspi)
         {
          tspi->samplay(samples[samqueue[aktsam]].start, samples[samqueue[aktsam]].end, aktchan);
          aktchan+=1;
          if(aktchan==4) aktchan=0;
          samqueue[aktsam]=-1;
          sqanz-=1;
          aktsam+=1;
          if( aktsam>=8 ) aktsam=0;
         }
        else
         {
          if( Buffoper(-1)==0 && Locksnd()==1 )
           {
            Devconnect(0, 8, 0, 3, 1);  /* 25kHz einstellen, fÅr 12.5kHz: 7 statt 3 */
            Setmode(2);
            Setbuffer(0, samples[samqueue[aktsam]].start, samples[samqueue[aktsam]].end);
            Buffoper(1);                /* Sample spielen */
            samqueue[aktsam]=-1;
            sqanz-=1;
            aktsam+=1;
            if( aktsam>=8 ) aktsam=0;
            Unlocksnd();
           }
         }
      }
    }
  }
  else
  {
   int i=8;
   while( i>0 && samqueue[aktsam]==-1 )
    {
     aktsam+=1;
     if( aktsam>=8 ) aktsam=0;
     i-=1;
    }
  }

}
