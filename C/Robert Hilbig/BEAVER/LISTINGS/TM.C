/*--------------------------------------------------------------------------\
|  FILE: TM.C                                                               |
|---------------------------------------------------------------------------|
|  Ersteller:     Robert Hilbig & Bernward Musiol                           |
|  Datum:         18.06.1988                                                |
|  Letzte Aend.:  06.08.1989                                                |
|  Compiler:      Turbo C V1.5 / Megamax C V1.1 / THINK's Lightspeed C      |
|  OS:            MS-DOS V2.xx / Atari ST-TOS   / Apple Macintosh           |
\--------------------------------------------------------------------------*/


#include <osbind.h>
#include <stdio.h>
#include <string.h>

#define ST            /* fuer Preprozessor damit er die ST-Version erzeugt */
#define BAND 80               /* Bandlaenge                                */
#define ZUSTAENDE 6           /* max. Anzahl der Zustaende                 */

struct Zustand                /* Struktur der Steuereinheit                */  
       {  char  zu_schreiben, /* Zeichen, das geschrieben wird             */
                nae_zustand;  /* in diesen Zustand wird als nÑchstes gegangen */
          int   nae_position; /* nÑchste Position des SLK                  */
       } Beaver[2][ZUSTAENDE];/* dieser Array ist die Steuereinheit        */

int Zustand_Max= 0,           /* Initialisierung der Turing-Maschine bzgl. */
    BandLaenge = 0,           /* Anzahl der ZustÑnde, BandlÑnge und        */
    BandPosition = 0;         /* Position des Schreib-/Lesekopfes          */

char Band[BAND];              /* 'unendlich' langes Band                   */

int Next_Beaver(),Zaehlen();


main()
{  register struct Zustand *aktB;   /* ein schneller Zeiger auf Zustand    */

   register char *band;  /* schneller Zeiger fÅr die aktuelle SLK-Position */
   register int  i,                 /* Hilfsvariable fÅr ...               */
            automat = 1;

   printf("%cE\n\n   Turing-Maschine \n\n",27);
   fill_beaver();                   /* Maschine wird geladen               */
   Write_Beaver("stdout");          /* und auf Bildschirm ausgegeben       */


   Band[0]=0;                       /* Bandanfangsmarkierung               */
   Band[BAND-1]=0;                  /* Bandendemarkierung                  */
   band=Band+BandPosition;
   aktB=&(Beaver[0][1]);            /* Start mit Zustand 1                 */

   do                               /* Turingmaschine                      */
   {
      printf("%s   Zustand: %d\n",Band+1,automat);
                                    /* gebe aktuelles Band aus             */
      for (i=1;i<BandPosition;i++) printf(" ");
      printf("^");                  /* markiere Position des SLK           */
      getchar();
  
      *band=aktB->zu_schreiben;     /* schreibe Zeichen auf das Band       */
      automat = aktB->nae_zustand;
      band+=aktB->nae_position;     /* bewege SLK                          */
      BandPosition += aktB->nae_position;
      aktB=&(Beaver[*band-48][aktB->nae_zustand]);
                                    /* gehe in nÑchsten Zustand Åber       */
   }  while((aktB->nae_position)&&(*band));
                                    /* solange Halt nicht erreicht wurde   */
                                    /* und das Bandende nicht erreicht     */

   if(*band) *band=aktB->zu_schreiben;
                                    /* wenn es nicht das Bandende war, soll*/
                                    /* das Zeichen noch geschrieben werden */
   else printf("Bandende erreicht !");

   printf("hinterlassenes Band:\n\n%s   Endzustand: %d\n",Band+1,automat);

   for (i=1;i<BandPosition;i++) printf(" ");
   printf("^");


   getchar();
}


fill_beaver()              /* Turing-Maschine laden                        */
{  FILE *quelle,*fopen();
   char str[256];
   int j;

   quelle=fopen("Turing.Mac","r");  /* îffne File mit Turing-Maschine      */  
 
   if (!quelle)                     /* wenn's damit nicht ging -> FEHLER!  */
   {  puts("  Fehler beim îffnen der Datei: Turing.Mac");
      puts("  Programm kann nicht ausgefÅhrt werden ! \n\n");
   }

   if(quelle)                          /* wenn das File sich îffnen lieû   */
   {  hol_str(str,quelle);             /* werden die Werte gesetzt.        */
      Zustand_Max = atoi(str);         /* Anzahl der ZustÑnde              */
     
      hol_str(str,quelle);
      BandLaenge = atoi(str);          /* LÑnge des Bandes                 */

      hol_str(str,quelle);
      BandPosition = atoi(str);        /* Startposition des SLK            */

      hol_str(str,quelle);
      strncpy(&(Band[1]),str,BandLaenge); /* Bandinhalt zum Start          */

      for(j=1;j<=Zustand_Max;++j)      /* Einlesen der Maschine            */
      {  
        hol_str(str,quelle);
        Beaver[0][j].zu_schreiben=str[0];
        if(str[2]=='L')
            Beaver[0][j].nae_position=-1;
        else if(str[2]=='R')
            Beaver[0][j].nae_position=1;
        else
            Beaver[0][j].nae_position=0;
        Beaver[0][j].nae_zustand=str[4]-48;

        Beaver[1][j].zu_schreiben=str[6];
        if(str[8]=='L')
            Beaver[1][j].nae_position=-1;
        else if(str[8]=='R')
            Beaver[1][j].nae_position=1;
        else
            Beaver[1][j].nae_position=0;
        Beaver[1][j].nae_zustand=str[10]-48;
      } 
      fclose(quelle);
   }
}


Write_Beaver(fname)
char *fname;       
{  register int j;
   char str[13];
   FILE *file,*fopen();

   if(*fname=='s')   /* wenn stdout, dann Ausgabe auf Bildschirm           */
      file=stdout;
   else              /* sonst îffnen des files                             */
      file=fopen(fname,"w");

   if(!file)         /* îffnen des Files ist schiefgegangen                */
      puts("Fehler beim schreiben des Biebers");
   else              /* hurra, es hat geklappt                             */
   {  
      for(j=0;j<11;str[j++]=' ')
         {};
      str[11]=10;
      str[12]=0;

      for(j=1;j<=Zustand_Max;++j)   /* Matrix schreiben                    */
      {  
         str[0]=Beaver[0][j].zu_schreiben;
         if(Beaver[0][j].nae_position==-1)
            str[2]='L';
         else if(Beaver[0][j].nae_position==1)
            str[2]='R';
         else
            str[2]='H';
         if(str[2]!='H')
            str[4]=Beaver[0][j].nae_zustand+48;
         else
            str[4]=' ';

         str[6]=Beaver[1][j].zu_schreiben;
         if(Beaver[1][j].nae_position==-1)
            str[8]='L';
         else if(Beaver[1][j].nae_position==1)
            str[8]='R';
         else
            str[8]='H';
         if(str[8]!='H')
            str[10]=Beaver[1][j].nae_zustand+48;
         else
            str[10]=' ';

         fputs(str,file);
      }

      if(*fname!='s')fclose(file); /* wenn's ein File war wieder schlieûen */
   }
}


/*--------------------------------------------------------------------------\
|                       ein paar Hilfsroutinen                              |
\--------------------------------------------------------------------------*/

hol_str(str,quelle)  /* holt einen String von der Datei, auf die Quelle    */
char *str;           /* zeigt und schreibt ihn in str                      */
FILE quelle;
{  char  *chr;
   
   do
   {
      chr=fgets(str,256,quelle);
      if(chr!=str)
         puts("  Fehler beim lesen der Datei: BEAVER");
   }while(*chr=='#');/* # in der ersten Spalte -> Zeile wird Åberlesen     */
}




