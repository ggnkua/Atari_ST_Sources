/*--------------------------------------------------------------------------\
|  FILE: Beaver.c                                                           |
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
#define MAX_ITERATION 1000L   /* Iterationen-Tiefe                         */
#define ZUSTAENDE 6           /* max. Anzahl der Zustaende                 */
#define SAVEANZ 100000L     /* Sicherung nach SAVEANZ getesteten Automaten */

struct Zustand                /* Struktur der Steuereinheit                */  
       {  char  zu_schreiben, /* Zeichen, das geschrieben wird             */
                nae_zustand;  /* in diesen Zustand wird als nÑchstes gegangen */
          int   nae_position; /* nÑchste Position des SLK                  */
       } Beaver[2][ZUSTAENDE];/* dieser Array ist die Steuereinheit        */

int Zustand_Max=0,Best_Beaver=0,exp2[10];
long *ptr,
     castor,cas_minis=0,cas_scien=0,cas_exfli=0;

int Next_Beaver(),Zaehlen();


#ifdef ST 
gettime()                        /* zum Zeitmessen wird beim ST die Anzahl */
{  *ptr=*(long *)0x466;          /* der VBL Routinen Aufrufe genommen      */
}
#endif



main()
{  register struct Zustand *aktB;   /* ein schneller Zeiger auf Zustand    */
   char  Band[BAND],                /* unendlich langes Band               */
         *best="be_best ",beaver=0, /* unter diesen Namen werden die Bieber abgespeichert */
         *minis="be_mini ",*scien="be_scie ",*exfli="be_exfl ";
   long time1,time2,high=0;         /* zwei Variablen zum Zeitmessen       */

   register char *band;  /* schneller Zeiger fÅr die aktuelle SLK-Position */
   register int  i;                 /* Hilfsvariable fÅr ...               */
   register long iteration,zustanz=SAVEANZ;
   
   printf("%cE\n\n   BieberjÑger \n\n  Gelesener Bieber :\n",27);
   fill_exp2();
   fill_beaver();                   /* Anfangsbieber wird geladen          */
   Write_Beaver("stdout");          /* und auf Bildschirm ausgegeben       */
   best[7]=(char)Zustand_Max+48;    /* an den Namen zum Abspeichern wird   */
   minis[7]=(char)Zustand_Max+48;   /* die Zustandanzahl angehÑngt damit   */
   scien[7]=(char)Zustand_Max+48;   /* sich die be_best unterscheiden      */
   exfli[7]=(char)Zustand_Max+48;

#ifdef ST
   ptr=&time1;Supexec(gettime);     /* time1 erhÑlt die Startzeit          */
#endif

   if(Zustand_Max>1) 
   do
   { 
      for(i=0;i<BAND;Band[i++]='0') /* Band mit '0' vorbesetzen            */
         {};
      Band[0]=0;                    /* Bandanfangsmarkierung               */
      Band[BAND-1]=0;               /* Bandendemarkierung                  */
      band=Band+BAND/2;       /* SLK auf die Bandmitte setzen (Startpunkt) */ 
      aktB=&(Beaver[0][1]);         /* Start mit Zustand 0                 */
      iteration=MAX_ITERATION;      /* IterationszÑhler setzen             */


      if (Beaver[0][1].nae_position)
      do                            /* Turingmaschine                      */
      {  
         *band=aktB->zu_schreiben;  /* schreibe Zeichen auf das Band       */
         band+=aktB->nae_position;  /* bewege SLK                          */
         aktB=&(Beaver[*band-48][aktB->nae_zustand]);
                                    /* gehe in nÑchsten Zustand Åber       */
      }  while((aktB->nae_position)&&(--iteration)&&(*band));
                                    /* solange Halt nicht erreicht wurde   */
                                    /* und das Bandende nicht erreicht     */

      if(*band) *band=aktB->zu_schreiben;
                                    /* wenn es nicht das Bandende war, soll*/
                                    /* das Zeichen noch geschrieben werden */

      if(!(--zustanz))              /* wenn der ZÑhler zum Speichern auf   */
      {  if(!beaver)                /* null ist, wird eine Sicherheitskopie*/
         {  beaver=1;               /* mit abwechselnden Namen gemacht     */
            Write_Beaver("beaver.a");
         }else
         {  Write_Beaver("beaver.b");
            beaver=0;
         }

         printf("%cE\n  getestete Zustaende : %ld * %ld\n",27,++high,SAVEANZ);
                                    /* zur Orientierung, wo sich der JÑger */
         Write_Beaver("stdout");    /* befindet, wird der aktuelle Bieber  */
                                    /* ausgegeben                          */
         zustanz=SAVEANZ;        /* ZÑhler fÅr Sicherheitskopie neu setzen */
      }
   
      i=Zaehlen(Band+1);        /* zÑhlen, wieviel Einsen auf dem Band sind*/

      if(!i)                     /* wenn Åberhaupt keine drauf waren,      */
       if(iteration)             /* prÅfe ob es ein spezieller Bieber war, */
       if(*band)                 /* der besser ist als die bisherigen.     */
       { iteration-=2;           /* Wenn ja, abspeichern und ausgeben      */

         castor=(long)(Band-band)+BAND/2;/* Entfernung des SLK von Mitte   */
                                         /* des Bandes (Startpunkt)        */
         if(castor<0)castor*=-1;       /* negative Entfernung gibt's nicht */

         if(castor>cas_minis)
         {  cas_minis=castor;
            Write_Beaver(minis);
            printf("%cE\n Castor Ministerialis :\n",27);
            Write_Beaver("stdout");
         }

         if((MAX_ITERATION-iteration)>cas_scien)
         {  cas_scien=MAX_ITERATION-iteration;
            Write_Beaver(scien);
            printf("%cE\n Castor Scientificus :\n",27);
            Write_Beaver("stdout");
         }

         if((!castor)&&((MAX_ITERATION-iteration)>cas_exfli))
         {  cas_exfli=MAX_ITERATION-iteration;
            Write_Beaver(exfli);
            printf("%cE\n Castor Exflippus :\n",27);
            Write_Beaver("stdout");
         }

         iteration+=2;
      }                          /* Ende der speziellen Bieber             */

      if((Best_Beaver<i)&&(*band)&&iteration)
                                 /* oder wars ein neuer Bester             */
      {  Best_Beaver=i;
         Write_Beaver(best);
         printf("%cE\n Best Beaver\n",27);
         Write_Beaver("stdout");   
      }
   }while(Next_Beaver());        /* solange noch neue Bieber da            */

#ifdef ST
 ptr=&time2;Supexec(gettime);    /* zeit nach Berechnung holen             */
 printf(" Time (sec) :%f  Zustaende :%f\n",((float)(time2-time1))/70,
       (float)(high)*(float)SAVEANZ+(float)(SAVEANZ-zustanz));
                /* Zeitdifferenz und insgesamt getestete ZustÑnde ausgeben */
#else
 printf(" Zustaende :%f\n",
       (float)(high)*(float)SAVEANZ+(float)(SAVEANZ-zustanz));
#endif

 getchar();
}

int Next_Beaver()
{  register int index,zustand,ueber,next,mode,halt_anz;
   register struct Zustand *aktB;

 do         /* konstruiere Folgekandidaten      */
 { index=1; /* vgl. mit Zaehlen im Dezimalsystem */
   halt_anz = 0;
   zustand=Zustand_Max;
   do
   {  aktB=&(Beaver[index][zustand]);
      ueber=0;
      if(((aktB->zu_schreiben=((aktB->zu_schreiben-47)%2)+48)=='0')&&
         ((aktB->nae_zustand=((aktB->nae_zustand)%Zustand_Max)+1)==1)&&
         ((aktB->nae_position=((aktB->nae_position+2)%3)-1)==-1))
         {  ueber=1;
            if((index=(index+1)%2)==1) zustand--;
         }
      if(!aktB->nae_position) aktB->nae_zustand=Zustand_Max;
/* Haltezustand, also nae_zustan unerheblich; waehle daher den 
   Hoechstwertigen -> ZUSTAND_MAX                                */
   } while(ueber);  

   index=1;
   while(index<Zustand_Max-2)
   {  if(Beaver[1][index].nae_zustand==2)
         Beaver[1][index].nae_zustand=Zustand_Max-index;
      if((index>1)&&(Beaver[0][index].nae_zustand==2))
         Beaver[0][index].nae_zustand=Zustand_Max-index;
      index++;
   }
                                  /* ueberpruefe, ob Automat sinnvoll */
/* alle Zustaende erreicht und genau ein Haltezustand ?              */
   if(Beaver[0][Zustand_Max].nae_position)
   {  mode=index=1;

      do
      {  if(Beaver[0][index].nae_position)
            ueber|=exp2[Beaver[0][index].nae_zustand];/* erreichter Zustand */
         else halt_anz++;                             /* Haltezustand       */

         if(Beaver[1][index].nae_position)
            ueber|=exp2[Beaver[1][index].nae_zustand];/* erreichter Zustand */
         else halt_anz++;                             /* Haltezustand       */

         mode|=exp2[index];
         ueber^=(ueber & mode); /* Ausschluû der schon erreichten Zustaende  */
   
         if ((ueber) && (halt_anz < 2))
         {  next=1;                 /* suche naechsten erreichbaren Zustand, */
            index=0;                /* wenn es einen gibt                   */
            do
            {  if(exp2[next] & ueber)index=next;
               next++;
            }while(!index);
         }
      }while ((ueber) && (halt_anz < 2));

      if ((halt_anz == 1) && (mode==exp2[Zustand_Max+1]-1)) return(1);
             /* alle erreicht und genau ein HALT -> return(1), Kandidat ok*/
   }
 } while(Beaver[0][1].nae_position); /* Symmetrie ausgenutzt  */

 return(0);                          /* kein weiterer Automat */
}




fill_beaver()              /* Anfangsbieber laden                          */
{  FILE *quelle,*fopen();
   char str[256];
   int i,j;

   quelle=fopen("beaver.a","r");    /* zuerst mit 'beaver.a' probieren     */

   if (!quelle)                     /* wenn's damit nicht ging             */
   {  puts("  Fehler beim îffnen der Datei: BEAVER.A");
      quelle=fopen("beaver.b","r"); /* probieren mit 'beaver.b'            */
      if (!quelle)                  /* wenn's damit auch nicht ging lÑuft  */
      {  printf("  Fehler beim îffnen der Datei: BEAVER.B\n\n"); /* nichts */
         printf("  Programm kann nicht ausgefÅhrt werden ! \n\n");
      }
   }

   if(quelle)                          /* wenn das File sich îffnen lieû   */
   {  hol_str(str,quelle);    
      Zustand_Max=i=atoi(str);         /* werden die Werte gesetzt         */

      hol_str(str,quelle);
      if(*str=='X')                    /* wenn hier ein 'X' steht ist es   */
         Get_Ur_Beaver();              /* der Anfang der Berechnung        */
      else
      {  Best_Beaver=atoi(str);        /* sonst werden die Werte mit denen */
                                       /* der Datei besetzt                */
         for(j=1;j<=i;++j)
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

         hol_str(str,quelle);
         cas_minis=atol(str);
         hol_str(str,quelle);
         cas_scien=atol(str);
         hol_str(str,quelle);
         cas_exfli=atol(str);

      }  /* else */
      fclose(quelle);
   }
}


Get_Ur_Beaver()      /* erzeugt den Bieber bei dem die Suche beginnt       */
{  register int i;
   
   for(i=1;i<=Zustand_Max;i++)
   {  Beaver[0][i].zu_schreiben='0';
      Beaver[0][i].nae_position=-1;
      Beaver[0][i].nae_zustand=1;

      Beaver[1][i].zu_schreiben='0';
      Beaver[1][i].nae_position=-1;
      Beaver[1][i].nae_zustand=1;
   }

     Beaver[0][1].nae_zustand=Zustand_Max; 
/*   die vorherige Bemerkung ist in der verbesserten Version als (V4) als
     Programmzeile zu Åbernehmen. Also die Kommentarzeichen weglassen  */
}


Write_Beaver(fname)  /* schreiben des aktuellen Biebers in den Outputstream*/
char *fname;         /* auf den fname zeigt                                */
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
   {  fprintf(file,"# ZustÑnde:\n%d\n",Zustand_Max);
      fprintf(file,"# Einsen:\n%d\n#\n",Best_Beaver);

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

      fprintf(file,"#\n# Entfernung Ministerialis:\n%ld\n",cas_minis);
      fprintf(file,"# Iterationen Scientificus:\n%ld\n",cas_scien);
      fprintf(file,"# Iterationen Exflippus:\n%ld\n",cas_exfli);
      if(*fname!='s')fclose(file); /* wenn's ein File war wieder schlieûen */
   }
}


/*--------------------------------------------------------------------------\
|                       ein paar Hilfsroutinen                              |
\--------------------------------------------------------------------------*/

int Zaehlen(chr)     /* zÑhlt die auf dem Band stehenden Einsen            */
char *chr;
{  register char *ch=chr;
   register int i=0;

   while(*ch) if(*(ch++)=='1')i++;
   return(i);
}


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


fill_exp2()          /* fÅllt den Array exp2 mit den Potenzen von zwei     */
{  register int i,j=1;

   for(i=0;i<10;i++)
   {  exp2[i]=j;
      j*=2;
   }
}

