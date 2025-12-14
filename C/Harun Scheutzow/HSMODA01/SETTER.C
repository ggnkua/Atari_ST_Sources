#include <stdio.h>
#include <stdlib.h>

/* geschrieben fÅr GNU-C auf ATARI-ST */
/* Zum Einstellen von Parametern in PRG/GTP/TOS/TTP Files, */
/* die nach Harun Scheutzow Definition aufgebaut sind */

/* fÅr GNU-C */
/* 8Bit */
#define BYTE char
#define UBYTE unsigned char
/* 16Bit */
#define WORD short
/* 32Bit */
#define LONG long int


/* MaximallÑnge des Files */
#define MAXINPLEN 65536L

/* ungÅltig-Markierung in LONG-Tabellen */
#define UNUSEDL 0x80000000L
 

WORD ask_for_yes(void)
{
 int a, ok;
 ok = 0;
 while (0 == ok)
 {
  a = getc(stdin) & 0x0ff;
  if ((a == 'j') || (a == 'J') || (a == 'y') || (a == 'Y'))
  {
   a = -1; ok = 1;
  }
  else
  {
   if ((a == 'n') || (a == 'N'))
   {
    a = 0; ok = 1;
   }
  }
 }
 return (WORD)a;
}


 
 
main(int argc, char *argv[ ])
{
 LONG f, inplen, suchlen;
 LONG *lptr;
 static BYTE inpbuf[MAXINPLEN];
 BYTE  magisch[] = "hAruNs cONfigER";
 BYTE  *xptr, *sptr, *eptr;
 UBYTE cfg_lbyte, cfg_hbyte;
 LONG  magptr;
 FILE *inpfp;
 int i, stop_it;
 static char izbuf[512];

 struct {
  WORD branch; /* immer 0x601a */
  LONG tlen; /* LÑnge des TEXT */
  LONG dlen; /* LÑnge des DATA */
  LONG blen;
  LONG slen;
  LONG res1;
  LONG prgflags;
  WORD absflag;
 } p_head;
 
 
 printf("Konfigurator fÅr PRG/GTP/TOS/TTP nach Haruns Methode fÅr\n");
 printf("fremdkonfigurierte Programme.\n");
 printf("(C) Harun_Scheutzow@B.maus.de, 1993-11-21\n");
 if (2 == argc)
 {
  if (0 != (inpfp = fopen(argv[1],"rb+"))) /* einfaches = ist hier ok, File lesen & schreiben */
  {
   if (1 == fread(&p_head, sizeof(p_head), 1, inpfp)) /* lies Programmkopf */
   {
    inplen = fread(inpbuf, 1, MAXINPLEN, inpfp); /* lies gesamtes Programm */
    suchlen = p_head.tlen + p_head.dlen;
    if ((inplen > 0) && (inplen < MAXINPLEN) && (suchlen <= inplen))
    {
     /* suche nach dem magischen String in TEXT und DATA */
     sptr = inpbuf;
     eptr = sptr;
     eptr += suchlen;
     f = 0;
     while ( eptr - sptr > 16 && 16 > f)
     {
      if( magisch[f++] != *sptr++ )
      {
       sptr -= f; /* zurÅck auf Vergleichbeginn */
       f = 0;
       sptr += 2; /*auf nÑchstes WORD */
      }
      if( f == 16 )
      {
     	 magptr = *(LONG *)sptr;
       if( sptr - inpbuf - 16 != magptr )
       {
        /* Magischer String stimmte, Zeiger aber nicht, also erstes WORD */
        /* des Strings Åberspringen und weitersuchen */
       	sptr -= 14; 
       	f = 0;
       }
      }
     }
     if (16 == f)
     {
      /* magischer String da, Zeiger auch ok */
      sptr += 4;
      printf("\nKonfiguriere Programm %s :\n", argv[1]);
      stop_it = 0;
      while ( *sptr && !stop_it)
      {
       /* Auswerteschleife */
       /* drucke den String aus */
       printf("\n Informationstext:\n%s",(char *)sptr);
       while (0 != *sptr++); 
       if ((LONG)sptr & 1)  sptr++;
       cfg_hbyte = *sptr++;
       cfg_lbyte = *sptr++;
       switch(cfg_hbyte)
       {
       case 0:
        /* Ja/Nein Entscheidung */
        printf(" Aktuelle Einstellung: ");
        if (*((WORD *)sptr))
        {
         printf("Ja.\n");
        }
        else
        {
         printf("Nein.\n");
        };
        printf("  Eingeben: _J_a oder _N_ein.\n");
        *(WORD *)sptr = ask_for_yes();
        sptr += 2; /* Zeiger weiter setzen */
        break;
       case 1:
        /* LONG-Werteliste eingeben */
        f = (LONG)cfg_lbyte;
        if (f)
        {
         printf(" Aktuelle Einstellungen:\n");
         lptr = (LONG *)sptr;
         i = 1;
         while (f--)
         {
          printf("Platz Nr.%d : ",i++);
          if (UNUSEDL == *lptr)
          {
           printf("ungÅltig\n");
           lptr++;
          }
          else
          {
           printf("%16ld\n",*lptr++);
          };
         };
         printf("\n Neue Werte eingeben, Platz ungÅltig markieren durch Eingabe von u.\n");
         lptr = (LONG *)sptr;
         f = (LONG)cfg_lbyte;
         i = 1;
         while (f)
         {
          printf("Platz Nr.%d : ",i);
          scanf("%60s",izbuf);
          if ((char)0 == izbuf[0] || 'U' == izbuf[0] || 'u' == izbuf[0])
          {
           /* U-Eingabe, den Platz ungÅltig markieren */
           i++; f--;
           *lptr++ = UNUSEDL;
          }
          else
          {
           if (1 == sscanf(izbuf, "%li", lptr))
           {
            i++; f--; lptr++;
           }
           else printf("Falsche Eingabe, wiederholen!\n");
          };
         };
         sptr = (BYTE *)lptr;
        }
        else 
        {
         printf("**** File damaged: 0 longs in list.\n");
         stop_it = 1;
        };
        break;
       case 2:
        /* String eingeben */
        /*  NOCH NICHT IMPLEMENTIERT */
        
        /* break; erst spÑter rein, so geht es nach default weiter */
       default:
        printf("**** Unknown Config-Command. File damaged or use newer SETTER.\n Aborted!\n");
        stop_it = 1;
       }
      }
      printf("\nKonfiguration beendet.\nénderungen speichern _J_a/_N_ein?\n");
      if (ask_for_yes())
      {
       fseek(inpfp,sizeof(p_head),SEEK_SET); /* nur Prgheader nicht zurÅckschreiben */
       if (inplen == fwrite(inpbuf, 1, inplen, inpfp))
       {
        printf("Konfiguration erfolgreich.\n");
       }
       else printf("**** Fehler beim ZurÅckschreiben des Files.\n");
      }
      else printf("Daten NICHT gespeichert.\n");
     }
     else printf("**** The file is not configurable.\n");
    }
    else printf("**** Read Error OR File too long OR not a program\n");
   }
   else printf("**** File too short\n");
   fclose(inpfp);
  }
  else printf("**** Error opening file\n");
 }
 else
 {
  printf("**** Wrong number of parameters!\n");
  printf(" Nutzung:\n");
  printf("setter Filename_des_zu_konfigurierenden_Programms\n");
 }
 return 0;
}
