/****************************************************************************
 * NEO2MONO                                   Version:   31.03.86
 * geschrieben von:  Thomas Weinstein                    08.05.86
 *                   Koenigsberger Str. 29d
 *                   7500 Karlsruhe 1
 *
 * Konvertiert Neochromebilder (320 * 200) fuer
 * Monochrome Bildschirm (640 * 400).
 * Farben werden durch Grauabstufungen angenaehert.
 *
 ****************************************************************************/

/*
 * DEFINES
 */

#define  printline(s)                      gemdos(0x09,s);
#define  create(name,mode)                 gemdos(0x3c,name,mode)
#define  open(name,att)                    gemdos(0x3d,name,att)
#define  close(hndl)                       gemdos(0x3e,hndl)
#define  read(hndl,size,buff)    (long)    gemdos(0x3f,hndl,size,buff)
#define  write(hndl,size,buff)   (long)    gemdos(0x40,hndl,size,buff)
#define  Log_base()              (short *) xbios(0x03)
#define  Wait()                            gemdos(0x01)

#define  C_OFF       "\033f"
#define  C_ON        "\033e"
/*
 * GLOBALE VARIABLE, FUNKTIONEN
 */

long     gemdos();
long     xbios();
short    buff[16000];      /* Puffer fuer Neochrome Farbbild */
short    *logbase;         /* Bildschirm Basisadresse        */

/*
 * MAIN
 */
main(argc,argv) char **argv;
{
     short wflag = 0;

     logbase   =  Log_base();  /* hole logische Bildschirmbasis */
     printline(C_OFF);         /* Cursor ausschalten.           */

     if (argc == 3)  /* Programmname + 2 Argumente */
       if (!strcmp(argv[1],"-w")) {
                             wflag++;
                             argc--;
                             argv++;
        }

     if (argc == 2) {
         if (load_file(argv[1])) {;   /* Neochromebild laden           */
                          convert();  /* Konvertieren                  */
                          if (wflag)
                             save_file(argv[1]); /* Grauwertbild speichern */
                          Wait();
         } else
            printline("Fehler beim Einlesen aufgetreten\n");
      } else {
         printline( "USAGE: hilow [-w] <filename.neo>\n");
         Wait();
      }
      printline(C_ON);              /* Cursor einschalten            */
} /* MAIN */


/*
 * Laedt Datei 'name' nach 'buff'. Keine Pruefung ob gueltige Neochromedatei
 */

load_file(name)   char *name;
{
   short hndl;

       if ((hndl = open(name,0)) < 0) {
          printline("Kann Datei nicht oeffnen!\n");
          Wait();
          exit(1);
       }
       read(hndl,128L,buff);   /* Header lesen       */
       if (read(hndl,32000L,buff) < 0L) { /* Bilddatei einlesen */
         printline("Fehler beim Lesen\n");
         Wait();
         return(0);
       }
       close(hndl);            /* Datei Schliessen   */

       return(1);
}

/*
 * Schreibt konvertiertes Bild nach <Filename.mon>
 */

save_file(name) char *name;
{
   char  *strcat(), *strchr(), *help; 
   short hndl;

   if ((help = strchr(name,'.')) == (char *) 0) {
       printline(" Kein '.' in Eingabedateiname ");
       return;
   }

   *++help = '\0';      /* Extension abschneiden   */
   strcat(name,"mon");  /* 'mon' ans Ende kopieren */

   if ((hndl = create(name,0)) < 0) {
       printline("Kann Datei nicht zum Schreiben oeffnen");
       return;
   }

   if (write(hndl,32000L,logbase) < 0) {
       printline("Kann Bild nicht schreiben");
       return;
   }
   close(hndl);
}


/*
 * Konvertiert Neochromebild in Monochrome Grauwertbild
 */

convert()
{
   register long  l1,l2,*ptr1,*ptr2;  /* Hilfsvariable fuer Grauwertbildung */
   register short *word, bit;
   register short color,x,y;          /* Laufvariablen fuer Farbbild        */

   ptr1 = (long *) logbase;           /* Zeiger auf 1. Zeile Grauwertbild   */
   ptr2 = (long *) logbase + 20;      /* Zeiger auf 2. Zeile Grauwertbild   */

   word = &buff[0];
   for (y=0; y <= 16000; y += 80) {  /* Ueber Zeilen von Farbild laufen */
      for (x=0; x < 80; x += 4) {    /* Zeile konvertieren. Immer vier  */
                                     /* 16 Bit Worte geben 16 Pixel     */
            l1 = l2 = 0L;
            for (bit = 15; bit >= 0; bit--) { /* 16 Bit Wort untersuchen   */
            color =  test(word,bit);          /* test liefert 0 - 4        */
            l1 <<= 2; l2 <<= 2;               /* Grauwert 2 Bit nach links */
              switch (color) {                /* Ergibt folgende Grauwerte:*/
                case 4:
                    l1 += 3;                  /*   XX         X = schwarz  */
                    l2 += 3;                  /*   XX         0 = weiss    */
                    break;
                case 3:
                    l1 += 3;                  /*   XX                      */
                    l2 += 2;                  /*   X0                      */
                    break;
                case 2:
                    l1 += 2;                  /*   X0                      */
                    l2 += 1;                  /*   0X                      */
                    break;
                case 1:
                    l1 += 1;                  /*   0X                      */
              }                               /*   00                      */
            }
            *ptr1++ = l1;  *ptr2++ = l2; /* In Bildspeicher schreiben */
            word += 4;                   /* Die naechsten 4 Worte     */
      }
      ptr1 += 20; ptr2 += 20;
   }
}

/*
 * liefert 0 - 4 je nachdem wieviel Farbbits fuer Pixel gesetzt sind
 */

test(word,bit)
register short *word;
short bit;
{
   register short shift;

          shift = 1 << bit;

          return (((*word    & shift) ? 1 : 0) +
                 ((*(word+1) & shift) ? 1 : 0) +
                 ((*(word+2) & shift) ? 1 : 0) +
                 ((*(word+3) & shift) ? 1 : 0));
}
/* ENDE VON HILOW.TTP */
