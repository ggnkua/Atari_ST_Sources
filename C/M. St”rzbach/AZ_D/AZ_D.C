/* Programm zur automatischen Zeitstellung
Funktion: erzeugt alle 5 min eine Datei auf D: ( jede Harddisk hat D: , oder? ); 
   beim Booten wird das Datum/die Uhrzeit dieser Datei eingestellt, wenn
     die Systemzeit nicht jÅnger ist!
   Gelingt das zum éndern des Filedatums nîtige ôffnen 2mal in Folge nicht,
   so wird die Zeitkontrolle abgestellt. Das Programm beginnt wieder zu 
   arbeiten, wenn es im Desktop angeklickt wird!
     Bisher wurden folgende UnvertrÑglichkeiten festgestellt:
5.1.90: 
	Anfangsschwierigkeiten beruhten auf der Nichtverdopplung des \ in der
Angabe von d:\\Autozeit.zei
	Die Grîûe von Åber 10kB rÅhrt von dem sprintf her, um den Fehler-
code eines evtl. fehlgeschlagenen Fopen auszugeben.
	sprintf durch einfache Umwandlungsroutinen ersetzt: intochar.
   */
#include <define.h>
#include <stdio.h>
#include <osbind.h>
/*
#include <osdefs.h>
*/
#include <gemdefs.h>
/*                  Erzeugungstext ( noch unten in form_alert eintragen )*/
static BYTE *Orig="Autozeit.c V2R2 06.01.90 MStî ATARI ST/LASER-C";
long _stksize=1000L;
/* MDEBUG: Autozeit als normales Programm ausfÅhrbar; autozeit.zei auf B: ! */
/*#define MDEBUG/**/
/* ACCDEBUG: Meldungen wÑhrend Installierung und Lauf! */
/*#define ACCDEBUG/**/

#ifdef MDEBUG

#	define WARTEZEIT 5000
#	define ANTDEF
#	define DATEI "B:\\AUTOZEI.ZEI"

#else

#	define DATEI "D:\\AUTOZEI.ZEI"
/*                            alle 5 min Zeit eintragen */
#	define WARTEZEIT 300000L
#endif


extern void appl_exit(), _exit();
extern char ant();						/* Aus libv */
extern _app;								/* 0: Accessory */

static void mach_fz(roh,datzeit)
     int roh[2];    datetime *datzeit;
{    datzeit->realtime=(((LONG)roh[1]<<16)&0xffff0000L) |
       ((LONG)roh[0]&0x0000ffffL);
}

static void mach_roh(roh,syszeit)
int roh[2]; datetime *syszeit;
{    roh[1]=syszeit->realtime>>16 &0xffff;
     roh[0]=syszeit->realtime &0xffff;
}
/*  Umwandeln einer ( kleinen ) Zahl in eine Zeichenfolge;
( Bem.: da Zahl eine int ist, kînnen max. 5 Ziffern auftreten, entsprechend
		ist nur wenig Stack nîtig ) 
	Aufruf: intochar(puffer,zahl):
		puffer: In puffer wird die Zeichenkette erzeugt.
		zahl: die umzuwandelnde Zahl, vorzeichenbehaftet.
	
	itc_convert(): Unterpogramm, das Dezimalenweise rekursiv die Umwandlung
		erledigt.
*/
static BYTE itc_zeichen[10]={'0','1','2','3','4','5','6','7','8','9'};
static BYTE *itc_convert(string,zahl)	BYTE *string; WORD zahl;
{	if ( zahl>9 ) 
	{ 	WORD temp=zahl/10;
		string=itc_convert(string,temp);
		zahl -= temp*10;
	}
	*(string++) = itc_zeichen[zahl];
	return string;
}

static void *intochar(string,zahl)
BYTE *string; WORD zahl;
{	if ( zahl < 0 ) 
	{	*(string++)='-';
		zahl= - zahl;
	}
	if ( zahl==0)
		*(string++)='0';
	else						/* Jetzt geht's los */	
		string=itc_convert(string,zahl);
	*string='\0';
}

static void passiviere()
{

#ifdef ACCDEBUG
puts("Anfang passiviere()!"); ant();
#endif

#ifdef MDEBUG
     _exit();
#else
     FOREVER evnt_timer(0,3600);
#endif

}

#ifndef MDEBUG
void exit()
{}
#endif


main()
{    int app_id,fd,iercnt=0,ereignis,msgpuff[8],eintrag,
          ereignis_maske=MU_MESAG|MU_TIMER;
     register WORD i,j;
     LONG diskmap,dummy;
     datetime syszeit,filezeit;
     int fz_roh[2];
     diskmap=Drvmap();
     syszeit.realtime=Gettime();   /* Hole Systemzeit */
     app_id=appl_init();
	if ( ! _app) eintrag=menu_register(app_id,"  Autozeit ");

/*   if ( diskmap & 4L ) */
     {    if ( (fd=Fopen(DATEI,1))<0 )
          {    if ((fd=Fcreate(DATEI,0))<=0 )
               passiviere();  /* File kann nicht geîffnet werden! */
               }
               /*                  Zeitdatei existiert */
          Fdatime(fz_roh,fd,0);
          mach_fz(fz_roh,&filezeit);
/*             Systemzeit ist, wenn nicht gesetzt: 128 ( + '80 ) !! */
/*			Jahreszahlen in Register ÅberfÅhren */
		i=syszeit.part.year; j=filezeit.part.year;
          if ( ( i< j-1) || ( i > j ))
          {         /* Setze Systemzeit nach filezeit */
               Settime(filezeit.realtime);
               syszeit.realtime=filezeit.realtime;
          }
          mach_roh(fz_roh,&syszeit);
#ifdef ACCDEBUG
puts("vor Dateizeit angleichen"); ant(); 
#endif
          Fclose(fd);
/*
-----------------------------------------------------------------
               Die ewige Schleife                                */
#ifdef MDEBUG
{    int i; for ( i=0; i<5; i++ )
#else
          FOREVER
#endif
          {
#ifdef ACCDEBUG
puts("vor evnt_multi"); ant(); 
#endif
/*                  Message: eintrag angeklickt; Zeit */
               ereignis=evnt_multi(ereignis_maske,
               1,1,1,1,1,1,1,1,1,1,1,1,1,
               msgpuff,(WORD)(WARTEZEIT&0xffff),(WORD)(WARTEZEIT>>16),
               &dummy,&dummy,&dummy,&dummy,&dummy,&dummy);

               if ( ereignis&MU_TIMER )
               {
                    if ((fd=Fopen(DATEI,1))>0)
                    {
                         syszeit.realtime=Gettime();
                         mach_roh(fz_roh,&syszeit);
                         Fdatime(fz_roh,fd,1);
                         Fclose(fd);    iercnt=0;
                    }
                    else if ( iercnt<1)
                    {	BYTE zahl[8];
                    		intochar(zahl,fd);
                    		{	BYTE tt[100];
                    			strcpy(tt,"[3][**** Autozeit ****|Datei DATEI |ist nicht beschreibbar!|Erg. Fopen=");
                    			strcat(tt,zahl);
                    			strcat(tt,"][ éndern! ]");
                     		form_alert(1,tt);
                         	iercnt++;
                         }
                    }
                    else      /* 2 Fehler -> autozeit passivieren, bis per
                                   MenÅ wieder angeklickt!  */
                    {    form_alert(1,
     "[3][**** Autozeit ****|Abgeschaltet!!!|aktiv.: im Desktop anklicken!][OK]");
                         ereignis_maske &= ~MU_TIMER;
                    }
               }
                                                       /* Eintrag angeklickt */
               if ( (ereignis &MU_MESAG)&&(msgpuff[0]==40)&&(msgpuff[4]==eintrag) )
               {    form_alert(1,
     "[1][Autozeit V2R2 ( MStî 6.1.89 )|Setzt Systemzeit entsprechend|Datum von  D:\\Autozeit.zei][OK]");
                    ereignis_maske |= MU_TIMER;
               }
          }
#ifdef MDEBUG
}
#endif
     }
}
