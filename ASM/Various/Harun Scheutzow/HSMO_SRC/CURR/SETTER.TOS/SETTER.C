#include <stdio.h>

/* geschrieben fÅr&mit Sozobon C auf ATARI-ST */
/* Zum Einstellen von Parametern in PRG/GTP/TOS/TTP Files, */
/* die nach Harun Scheutzow Definition aufgebaut sind */

/* fÅr Sozobon */
/* 8Bit */
#define BYTE char
#define UBYTE unsigned char
/* 16Bit */
#define WORD short
/* 32Bit */
#define LONG long int
#define ULONG unsigned long int


/* MaximallÑnge des Files */
#define MAXINPLEN 32000

/* ungÅltig-Markierung in LONG-Tabellen */
#define UNUSEDL 0x80000000L
 

static BYTE usinpuff[128]; /* allgemeiner Puffer fÅr Usereingaben */


WORD ask_for_yes(void)
{
 int a, ok;
 ok = 0;
 while (0 == ok)
 {
  scanf("%126s", usinpuff);
  a = (int)usinpuff[0];
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


 
 
main(argc, argv)
int argc;
char *argv[ ];
{
 LONG *lptr;
 static BYTE inpbuf[MAXINPLEN];
 BYTE  *magisch;
 BYTE  *xptr, *sptr, *eptr;
 BYTE  c;
 UBYTE cfg_lbyte, cfg_hbyte;
 LONG  magptr;
 FILE *inpfp;
 int f, i, stop_it, inplen;

 struct {
  WORD branch; /* immer 0x601a */
  ULONG tlen; /* LÑnge des TEXT */
  ULONG dlen; /* LÑnge des DATA */
  ULONG blen;
  ULONG slen;
  ULONG res1;
  ULONG prgflags;
  WORD absflag;
 } p_head;
 
 magisch = "hAruNs cONfigER";
 
 printf("Konfigurator fÅr PRG/GTP/TOS/TTP nach Haruns Methode fÅr\n");
 printf("fremdkonfigurierte Programme. / Setter for programs.\n");
 printf("(C) Harun_Scheutzow@B.maus.de, 1994-05-07\n");
 if (2 == argc)
 {
  if (0 != (inpfp = fopen(argv[1],"rb+"))) /* einfaches = ist hier ok, File lesen & schreiben */
  {
   if (1 == fread(&p_head, sizeof(p_head), 1, inpfp)) /* lies Programmkopf */
   {
    inplen = fread(inpbuf, 1, MAXINPLEN, inpfp); /* lies gesamtes Programm */
    if ((inplen > 0) && (inplen < MAXINPLEN) && (p_head.tlen + p_head.dlen <= (ULONG)inplen))
    {
     /* suche nach dem magischen String in TEXT und DATA */
     sptr = inpbuf;
     eptr = sptr;
     eptr += (p_head.tlen + p_head.dlen);
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
      printf("\nBearbeite Programm / Work on program:\n");
      printf("%s\n", argv[1]);
      stop_it = 0;
      while ( *sptr && !stop_it)
      {
       /* Auswerteschleife */
       /* drucke den String aus */
       printf("\n Informationstext / information text :\n%s",(char *)sptr);
       while (0 != *sptr++); 
       if ((LONG)sptr & 1)  sptr++;
       cfg_hbyte = *sptr++;
       cfg_lbyte = *sptr++;
       switch(cfg_hbyte)
       {
       case 0:
        /* Ja/Nein Entscheidung */
        printf(" Aktuelle Einstellung / current setting : ");
        if (*((WORD *)sptr))
        {
         printf("Ja. / Yes.\n");
        }
        else
        {
         printf("Nein. / No.\n");
        }
        printf("  Eingeben: _J_a oder _N_ein. / enter: _Y_es or _N_o.\n");
        *(WORD *)sptr = ask_for_yes();
        sptr += 2; /* Zeiger weiter setzen */
        break;
       case 1:
        /* LONG-Werteliste eingeben */
        f = (int)cfg_lbyte;
        if (f)
        {
         printf(" Aktuelle Einstellungen / current settings :\n");
         lptr = (LONG *)sptr;
         i = 1;
         while (f--)
         {
          printf("Platz / place Nr.%d : ",i++);
          if (UNUSEDL == *lptr)
          {
           printf("ungÅltig / invalid\n");
           lptr++;
          }
          else
          {
           printf("%16ld\n",*lptr++);
          }
         }
         printf("\n Neue Werte eingeben, Platz ungÅltig markieren durch Eingabe von u.\n");
         printf(" / Enter new values. Mark place invalid by input of u.\n");
         lptr = (LONG *)sptr;
         f = (int)cfg_lbyte;
         i = 1;
         while (f)
         {
          printf("Platz / place Nr.%d : ",i);
          scanf("%60s",usinpuff);
          if ((char)0 == usinpuff[0] || 'U' == usinpuff[0] || 'u' == usinpuff[0])
          {
           /* U-Eingabe, den Platz ungÅltig markieren */
           i++; f--;
           *lptr++ = UNUSEDL;
          }
          else
          {
           if (1 == sscanf(usinpuff, "%li", lptr))
           {
            i++; f--; lptr++;
           }
           else printf("Falsche Eingabe, wiederholen! / Wrong input, again!\n");
          }
         }
         sptr = (BYTE *)lptr;
        }
        else 
        {
         printf("**** File damaged: 0 longs in list.\n");
         stop_it = 1;
        }
        break;
       case 2:
        /* String eingeben */
        if ((cfg_lbyte & 1) || (cfg_lbyte < 2))
        {
         printf("**** File damaged: odd or below 2 string place len.\n");
         stop_it = 1;
        }
        else
        {
         printf(" Aktuelle Einstellung / current setting:\n");
         printf("%s\n",(char *)sptr);
         printf("  Neue Eingabe, max. %d Zeichen / New input, max. %d characters\n", (int)cfg_lbyte - 1, (int)cfg_lbyte - 1);
         scanf("%126s", usinpuff);
         xptr = usinpuff;
         eptr = sptr;
         f = (int)cfg_lbyte;
         c = 1;       /* != fÅr Anfang */
         while (f-- > 1) /* letztes Byte wird hier nicht behandelt */
          c = *eptr++ = c ? *xptr++ : (BYTE)0; /* ist seltsam, aber OK */
         *eptr = (BYTE)0; /* immer ein Nullbyte am Ende */
         sptr += (int)cfg_lbyte;
        }
        break;
       default:
        printf("**** Unknown command. File damaged or use newer SETTER.\n Aborted!\n");
        stop_it = 1;
       }
      }
      printf("\nKonfiguration beendet. / Configuration completed.\n");
      printf("énderungen speichern / Save changes _J_a/_N_ein/_Y_es/_N_o?\n");
      if (ask_for_yes())
      {
       fseek(inpfp,(LONG)sizeof(p_head),SEEK_SET); /* nur Prgheader nicht zurÅckschreiben */
       if (inplen == fwrite(inpbuf, 1, inplen, inpfp))
       {
        printf("Konfiguration erfolgreich. / Configuration successful.\n");
       }
       else printf("**** Error during saving the file.\n");
      }
      else printf("Einstellungen NICHT gespeichert. / Settings NOT saved.\n");
     }
     else printf("**** The file does not contain configuration.\n");
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
  printf(" Nutzung / usage :\n");
  printf("setter Filename_des_zu_konfigurierenden_Programms\n");
 }
 return 0;
}
