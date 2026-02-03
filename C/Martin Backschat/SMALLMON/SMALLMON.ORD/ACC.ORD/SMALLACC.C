/**************************************************************************/
/*                          ATARI ST - SmallMON                           */
/**************************************************************************/
/*         VerfÅgbar als TOS-Programm oder als Disk-ACCESSORY             */
/*                                                                        */
/*  -  geschrieben von MABA der 'Software FOUNDATION'...                  */
/*  -  dokumentiert von MABA ^                                            */
/*  -  basierend auf einer Idee Michael Istinie ^                         */
/**************************************************************************/
/*   Dieses Programm wurde mit dem von DIGITAL RESEARCH entwickelten      */
/*   DIGITAL-C geschrieben. Eine Umsetzung auf einen anderen C-Com-       */
/*   piler ist ohne weiteres, sofern Sie Åber die '.h'-Files, die         */
/*   hier vorkommen, verfÅgen.                                            */
/**************************************************************************/
/*   Die neuste Version dieses SmallMON ist von der                       */
/*                     'Software FOUNDATION Abt. Freesoft'                */
/*                     Tel. 08456/5495 ab 15:00                           */
/*   zu beziehen.                                                         */
/**************************************************************************/
/*   DIESES PROGRAMM IST ALS FREIES PROGRAMM VORGESEHEN, DAû SICH JEDER   */
/*   FREI KOPIEREN DARF.                                                  */
/*   WER ABER FAIR IST, UND DEM DIESES PROGRAMM GUT GEFéLLT, DER SOLLTE,  */
/*   UM EINE AUSFöHRLICHE ANLEITUNG ZU BEKOMMEN, UND UM DIESE ART DER     */
/*   PROGRAMMVERTEILUNG ZU FôRDERN, 10,-DM AN MABA SCHICKEN:              */
/*             MARTIN BACKSCHAT                                           */
/*             BERGSTRAûE 16                                              */
/*             8071 HEPBERG                                               */
/*                                                                        */
/*             IM VORAUS SCHON MAL VIEELLEN DAAAANNNNKKKK !               */
/**************************************************************************/



/**************************************************************************/
/*   Include Dateien, die fÅr den weiteren Ablauf des Prg. wichtig sind.  */
/**************************************************************************/
#include "stdio.h"            /* Standard I/O Routines      */
                              /* lÑdt noch <define.h> nach! */

#include "osbind.h"           /* enthÑlt alle GEMDOS, BIOS UND XBIOS  */
                              /* Routinen als C-Namen definiert.      */

/**************************************************************************/
/*   Wichtige Routinen, die im ATARI-C fehlen (in anderen vielleicht      */
/*   nicht!), und die je nachdem ob sie fehlen oder vorhanden sind        */
/*   gelîscht werden kînnen.                                              */
/**************************************************************************/
#define isupper(c)  (c >= 'A' && c <= 'Z')
#define islower(c)  (c >= 'a' && c <= 'z')
#define isdigit(c)  (c >= '0' && c <= '9')
#define isvokal(c)  (c == 'A' || c == 'E' || c == 'I' || c == 'O' || c == 'U')
#define toupper(c)  (islower(c) ? c + 'A' - 'a' : c)
#define tolower(c)  (isupper(c) ? c + 'a' - 'A' : c)
#define ischar(c)   (isupper(c) || islower(c))

/******************* Steuercodes fÅr ATARI ST *******************/
#define ESC 0x1b
#define SCRN(a)     putchar(ESC);  putchar(a);

#define CRSR_UP     SCRN('A')           /* Eine Zeile nach oben  */
#define CRSR_DOWN   SCRN('B')           /* nach unten            */
#define CRSR_RT     SCRN('C')           /* nach rechts           */
#define CRSR_LT     SCRN('D')           /* nach links            */
#define CLRSCRN     SCRN('E')           /* BS lîschen            */
#define HOME        SCRN('H')           /* in linke obere Ecke   */
#define DEL_EOP     SCRN('J')           /* bis BS-Ende lîschen   */
#define DEL_EOL     SCRN('K')           /* bis Zeilenende lîschen*/
#define INSRT_LIN   SCRN('L')           /* Zeile einfÅgen        */
#define DEL_LIN     SCRN('M')           /* Zeile lîschen         */
#define CRSR_OFF    SCRN('f')           /* C. ausschalten        */
#define CRSR_ON     SCRN('e')           /* C. einschalten        */
#define DEL_BOS     SCRN('d')           /* von BS-Anfang lîschen */
#define STORE_CRSR  SCRN('j')           /* C.-Position speichern */
#define RESTORE_CRSR     SCRN('k')      /* an gemerkte Pos. gehen*/
#define DEL_LIN     SCRN('l')           /* Zeile lîschen         */
#define DEL_BOL     SCRN('o')           /* ab Zeilenanf. lîschen */
#define REV_ON      SCRN('p')           /* Reverse Darst. ein    */
#define REV_OFF     SCRN('q')           /* Reverse Darst. aus    */

#define GOTO(x,y)   SCRN('Y'); putchar((char) x + 32); putchar((char) y + 32)


/**************************************************************************/
/*   Texte, die im Laufe des Programms ausgegeben werden...               */
/**************************************************************************/

/**** BegrÅûung des Benutzers ***/
char first_text[] = "\033w*** Welcome to \033pSmallMON v2.0\033q written by MABA ***";

/**** BefehlsÅbersicht ****/
char help_text[] = "Befehle des SmallMON:  \033pa c d e g l m p r s u v w x ? : + -\033q";

/* A : ok éndert auf max. Speicherkonf. v. 4MB   :a                   */
/* C : ok éndert Modus wert = B,W,L              :c (wert)            */
/* D : ok Gibt DIR (mit folgendem Muster aus)    :d [(name.form)]     */
/* E : ok LÑdt Programm und startet es...        :e                   */
/* G : ok Gibt Speicherinhalte ab neuer Adr. aus :g (adr)             */
/* L : ok LÑdt Programm nach                     :l                   */
/* M : ok Erlaubt Eingabe von Bytes und Zeichen  :m (adr) (werte...)  */
/* P : ok LÑdt und zeigt ein Bild an             :p                   */
/* R : ok Liest Datei in Speicher                :r                   */
/* S : ok Erlaubt hoch/runter scrollen der Screen:s                   */
/* U : ok Schaltet zwischen USER und SUPERVISOR  :u                   */
/*        (kontrolliert oder beliebiger) Speicherzugriff hinher       */
/* W : ok Schreibt Speicher auf Diskette         :w                   */
/* V : ok Gibt nochmal Infos zum letzten gel.File:v                   */
/* X : ok VerlÑût den Monitor                    :x                   */
/* ? : ok Gibt kurze öbersicht aus               :?                   */
/* : : ok éndert Laufwerksnummer                 :: (nr)              */
/* + : ok Erlaubt vorblÑttern der Speicheranzeige:+                   */
/* - : ok Erlaubt zurÅckblÑttern "    "          :-                   */


/**** Fehlermeldungen ****/
char *error[] =
     {    "\033pFehleingabe!\033q",
          "\033pSie dÅrfen kein Nibble unterschlagen!\033q",
          "\033pFalscher Modus!\033q",
          "\033pUngÅltige Adresse!\033q",
          "\033pLW-No. zu groû (nur A bis D)!\033q",
          "\033pLadefehler!\033q",
          "\033pEndadresse kleiner gleich Anfangsadresse!\033q",
          "\033pSchreibfehler!\033q" };


/*************************************************************/
/*   Untersten zwei Zeilen enthalten    Texte:               */
/*************************************************************/
char zeile_1[] = "      \033pModus:\033q Byte      \033pAdresse:\033q $000000  #00000000  %000000000000000000000000";

char hinweis[] = "Bitte eine \033pTASTE\033q drÅcken";

/********************************************/
/*   Makrodefinitionen                      */
/********************************************/
#define BEGZEILE 0
#define ENDZEILE 21

#define STATUSZEILE 23
#define TEXTZEILE 24

#define MODUS 13                   /* Position des Wortes MODUS  */
#define HADRESSE 33                /* Position der Hexaadresse   */
#define DADRESSE 42                /* Position der Dez.Adresse   */
#define BADRESSE 53                /* Position der Bin.Adresse   */

#define ENDMEM 0xff0000            /* Ende des Speichers; Beginn I/O  */

/********************************************/
/*   Globale Variablendeklarationen         */
/********************************************/

/* Die Extern-Variable Base_Page ist NICHT genormt, sie wurde vielmehr */
/* von MABA selbst definiert, und zwar im File APSTART.O, in der die   */
/* Basisadresse zusÑtzlich noch in Base_Page gespeichert wurde.        */

long *Base_Page;                   /* enthÑlt die Basisadresse des Monitors */

extern int gl_apid;

int Modus = 0;                     /* gibt an, welchen Modus als I/O der */
                                   /* Benutzer gewÑhlt hat:              */
                                   /* 0 = Byte;  1 = Wort;  3 = LWort    */

char *dump_adresse = 0x000000L;     /* Adresse, wo der Adressenpointer    */
                                    /* sich gerade befindet.              */

int akzel;                         /* Aktuelle Zeile                     */

char user = 0;                     /* 1 = USER   ; 0 = KONTROLLIERT    )  */
                                   /* d.h. 1: Monitor kontolliert Speich- */
                                   /* zugriffe des Benutzers.             */

long maxadr;                       /* EnthÑlt die max. ja nach Bank-      */
                                   /* konfiguration grossen Speicher-     */
                                   /* inhalt (beim 520er: 2 1/8 MB        */
                                   /*         beim 520+ : 4 MB            */

long adresse;                      /* enthÑlt nach Aufruf der Funktion    */
                                   /* adr_get() die vom Benutzer einge-   */
                                   /* gegebene Adresse.                   */

long kopie;                        /* enthÑlt in einigen Routinen eine    */
                                   /* Kopie des Speicherpointers dump_ad..*/

struct DTA                         /* Struktur fÅr Befehl DIR             */
{    char schrott[26];
     long length_of_prg;           /* LÑnge des Prgs in Bytes             */
     char name[14];
} dta;

struct BASEPAGE               /* Struktur fÅr die Basepage von einem File */
{    long p_lowtpa;  /* Low Adr. der TPA     */
     long p_hitpa;   /* Hi Adr. der TPA      */
     long p_tbase;   /* Base Adr. of Text    */
     long p_tlen;    /* Length of text       */
     long p_dbase;   /* Base Adr. of init DATA */
     long p_dlen;    /* Length of init DATA  */
     long p_bbase;   /* Base Adr. of BSS     */
     long p_blen;    /* Length of BSS        */
} ;

long *phystop = 0x42e;             /* enthÑlt das physische Ende des RAMs */

char file_name[13];                /* enthÑlt in einigen Routinen den     */
                                   /* Dateinamen                          */

long ANFANG = 0;         /* enthÑlt die Startadresse eines Files */
long ENDE = 0;           /* enthÑlt die Endadresse eines Files   */
char FILENAME[] = "SmallMON.tos";  /* enthÑlt den Namen des letzten Files */

struct BASEPAGE *BP;

/********************************/
/* Gibt Trennzeile aus.         */
/********************************/
trennen()
{
  register char x;
     GOTO(STATUSZEILE-1,0);
     for (x = 0; x < 80; ++x)
          putchar('#');
}

/*************************************************************************/
/*   Hauptschleife                                                       */
/*************************************************************************/
main()
{
  long save_ssp;
  int msgbuff[8],mx,my,ret,event,menu_id;


     appl_init();                  /* Apllikation initialisieren */
     menu_id = menu_register(gl_apid,"  SmallMON v2.0  ");

     /*************************************************/
     /* Multi-Event...                                */
     /*************************************************/

  while (TRUE) {

     event=evnt_multi(0x0012,1,1,1,0,0,0,0,0,0,0,0,0,0,msgbuff,0,0,&mx,&my,&ret,&ret,&ret,&ret);

     wind_update(TRUE);       /* andere Programme abschalten */
     if((msgbuff[0] == 40) && (msgbuff[4] == menu_id)) {   /* case of AC_OPEN */

     /***************************************/
     /* Beginn der eigentlichen Mainroutine */
     /***************************************/

     CLRSCRN;                      /* lîscht erstmal den Bildschirm   */

     save_ssp = Super((long) 0);   /* auf Supervisormodus schalten    */

     get_maxadr();                 /* Diese Routine holt die Speicher-*/
                                   /* konfiguration, Åbergibt sie der */
                                   /* Variablen maxadresse und gibt   */
                                   /* diese in der Trennzeile aus.    */

     init_scr();                   /* Initialisiert & erneuert BS     */

     print_out(first_text);             /* Gibt den Stringarray zur Be-  */
                                        /* grÅûung aus.                  */
     print_out(help_text);              /* Gibt Hilfsanleitung aus.   */

     analyse_loop();          /* Holt Kommandos, und fÅhrt diese aus. */
                              /* kommt erst wieder nach X zurÅck      */

     Super(save_ssp);         /* setzt Supervisorstackpointer zurÅck  */


      }   /* end of Multi-If    */

     wind_update(FALSE);      /* Multitasking wieder einschalten */

 }        /* end of Multi-while */
}


/******************************************************/
/* Kommandoschleife, die nur bei X verlassen wird     */
/******************************************************/
analyse_loop()
{
  int x;
  long basepage;
  char commando,parameter;
  char *anfangs_adr;

  while(TRUE)
  {
     get_command(&commando);            /* Holt ein Benutzerkommando     */
     switch(toupper(commando))          /* öberprÅft und filtert das  */
     {                                  /* Kommando aus.              */
          case '?':                     /* gibt Kurzanleitung aus     */
            print_out(help_text);
            continue;

          case 'X':                     /* VerlÑût Programm           */
            return;                     /* zurÅckspringen.......      */

          case '+':                     /* Eine Seite Speicher vorne  */
            dump_side();
            continue;

          case '-':                     /* Eine Seite Speicher nach   */
            sub(0x2c0);                 /* stat '-= 0x2c0'            */
            dump_side();
            continue;

          case 'C':                     /* éndert den Modus B W L     */
            GOTO(TEXTZEILE,0);
            DEL_LIN;
            screen("Welcher neuer Modus (B,W,L): >");
            get_taste(&parameter);           /* Taste holen */
            switch(toupper(parameter)) {
               case 'B':                     /* Eingabe BYTE? */
                 Modus = 0;
                 ausgabe();                  /* Gibt Werte im neuen Form. */
                 continue;                   /* ausgeben */

               case 'W':                     /* Eingabe WORT? */
                 Modus = 1;
                 ausgabe();
                 continue;

               case 'L':                     /* Eingabe LWORT? */
                 Modus = 3;
                 ausgabe();
                 continue;

               default:
                 print_out(error[2]);        /* sonst Fehlermeldung...*/
                 continue;
            }

          case 'A':                     /* éndert Konf. auf 4MB (max.)*/
            if (user)         continue; /* Falls sich Benutzer im nicht */
                                        /* Supervisormodus befindet,  */
                                        /* dann ignorieren...         */
            GOTO(TEXTZEILE,0);
            DEL_LIN;
            screen("Wollen Sie wirklich auf 4 MByte schalten? >");
            get_taste(&parameter);
            DEL_LIN;
            if (toupper(parameter) == 'N')
               continue;                /* falls nicht, ...           */

            maxadr = 4096*1024;         /* auf 4MB schalten           */
            konf_print();               /* und diese ausgeben...      */
            continue;

          case 'G':                     /* zu einer best. Speicherstelle */
            GOTO(TEXTZEILE,0);          /* springen.                     */
            DEL_LIN;
            screen("Wohin soll ich gehen? >");
            adr_get();                  /* Holt die Adresse           */
            dump_adresse = adresse;     /* glichsetzten der Adressen. */
            dump_side();                /* Seite ab neuer Pos. ausgeben  */
            GOTO(TEXTZEILE,0);
            DEL_LIN;
            continue;

          case 'S':                     /* Scrollen des Memoryblocks  */
            sub(0x160);
            for (akzel = 0; akzel <= TEXTZEILE; ++akzel)
                 dump_oneline();        /* DIE unteren Zeilen lîschen */

            HOME;   akzel = 0;          /* Cursor nach oben links     */
            sub(0x180);                 /* Adressenpointer nachziehen */

            while ((parameter = CURGET()) != ESC) {
               switch(parameter) {

                  case '-':
                    if (akzel == 0) {   /* muû gescrollt werden?      */
                       INSRT_LIN;       /* ja, dann Zeile einfÅgen    */
                       sub(0x20);
                       dump_oneline();  /* und eine Zeile ausgeben    */
                    }
                    else {              /* nein, dann nur zÑhlen.     */
                       akzel--;
                       sub(0x10);       /* eine Adresszeile abziehen  */
                    }
                    break;

                  case '+':
                    if (akzel == TEXTZEILE) {     /* muû gescrollt werden?*/
                         putchar('\n'); /* ja, dann Zeile einfÅgen    */
                         dump_oneline();/* zeile ausgeben             */
                    }
                    else {              /* sonst nur zÑhlen           */
                       akzel++;
                       add(0x10);       /* eine Adresszeile addieren  */
                    }
                    break;
               }
            }
            sub(0x10);        /* Um auf die richtige Adresse zu kommen  */
            init_scr();       /* baut Status- und Textzeile neu auf     */
            break;

          case 'U':           /* schaltet zwischen ROM und RAM her      */
            usrswt ();        /* natÅrlich werden auch die Var.         */
                              /* maxadr und minadr gesetzt!             */
            continue;

          case 'D':           /* anzeigen des Directories   */
            show_dir();
            continue;

          case ':':           /* LW No. neu setzten         */
            set_drv();
            continue;

          case 'M':           /* Will Benutzer Werte eingeben? */
            kopie = dump_adresse;  /* merken, da sie verÑndert wird! */
            read_mem();
            DEL_LIN;          /* nachher noch Zeile lîschen... */
            dump_adresse = kopie;  /* und wieder zurÅckfordern */
            continue;

          case 'E':           /* ladet und startet Programm      */
            load_prg(0);      /* hier keine Fehlerabfrage        */
            continue;

          case 'L':           /* Programm nur laden              */
            load_prg(3);      /* laden und BP-Infos anzeigen     */
            continue;

          case 'P':           /* Bild laden und anzeigen         */
            show_pic();
            continue;

          case 'R':           /* Speicher einlesen               */
            GOTO(TEXTZEILE,0);
            DEL_LIN;
            screen("Wie heiût die Datei, die unverÑndert eingelesen werden soll? >");

            readline(file_name,12);     /* Namen d. Datei einlese */

            Fsetdta(&dta);              /* DTA auf Benutzereigene setzen */
            if (Fsfirst(file_name,0)) { /* Ist das File nicht auffindbar?*/
               print_out(error[5]);     /* dann einfach Fehler ausgeben  */
               continue;
            }

            anfangs_adr = Malloc(dta.length_of_prg); /* Anfangsadresse bekommt man als Wert von der Fkt. MALLOC zurÅck */

            x = Fopen(file_name,0);     /* Datei zum Lesen îffnen */
            Fread(x,dta.length_of_prg,anfangs_adr);  /* und genau die Anzahl der Zeichen einlesen */
            Fclose(x);   /* schlieût das File */

            Mshrink(anfangs_adr,dta.length_of_prg);  /* Den Speicher wieder freistellen */

            DEL_LIN;
            GOTO(TEXTZEILE,0);
            screen ("Startadresse: $");
            hex_dump(anfangs_adr,4);    /* Anfangsadresse ausgeben */

            screen ("  |  Endadresse: $");
            hex_dump(anfangs_adr + dta.length_of_prg,4);  /* Endadresse + 1 ausgeben */

            screen ("  |  LÑnge: $");
            hex_dump(dta.length_of_prg,4);   /* LÑnge des. Prgs. ausgeben */

            ANFANG = anfangs_adr;  /* Startadresse fÅr Befehl VIEW merken */
            ENDE   = anfangs_adr + dta.length_of_prg;  /* Endadresse fÅr VIEW merken */
            strcpy(FILENAME,dta.name);  /* Dateiname fÅr VIEW merken */

            warte_auf_taste();     /* auf Taste warten */
            continue;

          case 'W':                /* Speicher auf Disk schreiben */
            GOTO(TEXTZEILE,0);
            DEL_LIN;

            screen("Anfangsadresse: $");
            adr_get();             /* Anfangsadresse holen */
            anfangs_adr = adresse;

            GOTO(TEXTZEILE,25);
            screen("|  Endadresse: $");
            adr_get();             /* Endadresse holen */

            if (anfangs_adr >= adresse) { /* Fehler bei Adresseeingabe? */
               print_out(error[6]);
               continue;
            }

            GOTO(TEXTZEILE,49);
            screen("|  Dateiname: >");
            readline(file_name,12);

            if ( (x = Fcreate(file_name,0)) < 0) { /* Fehler beim ôffnen? */
               print_out(error[7]);
               continue;
            }

            Fwrite(x, adresse - anfangs_adr, anfangs_adr); /* Daten auf Disk schreiben */
            Fclose(x);

            DEL_LIN;
            continue;

          case 'V':                     /* Anzeigen de Start- und End-*/
                                        /* adresse des letzten Files  */
            GOTO(TEXTZEILE,0);
            DEL_LIN;
            screen("Start: $");         /* gibt die Anfangsadresse aus*/
            hex_dump(ANFANG,4);

            screen("  |  Ende: $");     /* gibt die Endadresse aus    */
            hex_dump(ENDE,4);

            screen("  |  Dateiname: "); /* gibt den Namen der Datei   */
            screen(FILENAME);

            warte_auf_taste();
            continue;


          default:                      /* kein Kommando, dann Fehler */
            print_out(error[0]);        /* Fehlermeldung ausgeben     */
               continue;

     }    /* end of switch */
   }      /* end of while  */
}

/************************************************************************/
/* Gibt einen Text unten in Commandozeile zentriert aus, und wartet auf */
/* einen Tastendruck...                                                 */
/************************************************************************/
print_out(text)
  char   text[];
{
     GOTO(TEXTZEILE,0);
     DEL_LIN;                 /* mgl. Schmutz lîschen       */

     GOTO(TEXTZEILE,(80 - strlen(text))/2);
     screen(text);
     CRSR_OFF;           /* Cursor ausschalten.             */

     GOTO(TEXTZEILE,74);
     screen(" \033pTASTE\033q");    /* Hinweis auf tastdruck geben     */

     gemdos(7);          /* wartet auf einen Tastendruck    */
     DEL_LIN;            /* Zeile lîschen                   */
}


/*************************************************************************/
/*   Gibt den aktuellen Modus aus.                                       */
/*************************************************************************/
print_mode()
{
  static char *modus_text[] = { "Byte    ",
                                "Wort    ","?",
                                "Langwort" };

     GOTO(STATUSZEILE,MODUS);  
     screen(modus_text[Modus]);
}


/**************************************************************************/
/* Wartet bis Benutzer eine Taste drÅckt. Kehrt dann mit dieser zurÅck.   */
/**************************************************************************/
get_command(commando)
  char *commando;
{
     GOTO(TEXTZEILE,0);                           /* In Textzeile gehen */
     screen("Bitte Ihr Kommando eingeben: >");
     get_taste(commando);                  /* Holt Zeichen vom Benutzer  */
}

/***********************************************/
/*   Holt ein Zeichen mit blink. Cursor vom BS */
/***********************************************/
get_taste(commando)
  char *commando;
{
     CRSR_ON;
     /* Wartet solange, bis ein ordentliches Zeichen eingegeben wird  */
     while(!( (*commando = Crawcin()) && (*commando > 31) )) ;
     CRSR_OFF;
}


/*************************************************************************/
/*   Gibt aktuelle Adresse als Hex- und Dezimalwert in Textzeile aus.    */
/*************************************************************************/
print_adr()
{
     print_mode();                           /* gibt akt. Modus aus.       */

     GOTO(STATUSZEILE,HADRESSE);
     hex_dump(dump_adresse,3);               /* Adresse hexadezimal zeigen */

     GOTO(STATUSZEILE,DADRESSE);
     dez_dump(dump_adresse,8);               /* Adresse dezimal zeigen     */

     GOTO(STATUSZEILE,BADRESSE);
     bin_dump(dump_adresse,3);               /* Adresse binÑr zeigen       */
}


/********* Hexadezimale Ausgabe **********/
hex_dump(value,format)
  register long value;
  int format;
{
  register unsigned int byte;
  register int shift;

     for (shift = (format * 2) - 1; shift >= 0; --shift) {
          byte = (value >> (shift * 4)) & (long) 0x0f;
          putchar( byte + (byte > 9 ? 'W': '0'));
     }
}

/********** Dezimale Ausgabe *************/
dez_dump(l,format)
  register long int l;
  register int format;
{    if (!format)
          return;
     dez_dump((long) (l/10),--format);
     putchar('0' + (int) (l % 10));
}

/********* BinÑre Ausgabe ***************/
bin_dump(value,format)
  register long value;
  register int format;
{
  register int j;
     for (j = (format * 8) - 1; j >= 0; --j)
          if (value & (1 << j))
               putchar('1');
          else
               putchar('0');
}


/**********************************************************/
/*   Gibt eine Zeile mit Speicherinhalten aus.            */
/**********************************************************/
dump_oneline()
{
  int x,y;
  char wert;

     CRSR_OFF;                /* Cursor ausschalten    */
     GOTO(akzel,0);      /* an den Anfang springen */
     DEL_LIN;            /* Zeile lîschen         */
     hex_dump(dump_adresse,3);   /* Adresse ausgeben */
     screen("  :  ");

     for (x = 0; x < 16; x += (Modus+1)) {
          for (y=0; y<(Modus+1);++y) {
               wert = *dump_adresse;
               fadd();                  /* erhîht die Adresse um eins */
               hex_dump((long) wert,sizeof (char));
          }
          putchar(' ');
     }

     GOTO(akzel,80-20);       /* Fertigmachen zur Ascii-Ausgabe */

     sub(16);                 /* zieht von Adresse 16 ab.        */

     for (x = 0; x < 16; ++x) {    /* gibt Ascii-Zeichen aus     */
          if (wert = *dump_adresse)
               Bconout(5, wert);
          else putchar('.');       /* ist Zeichen 0, dann Punkt..... */

          fadd();                       /* erhîht die Adresse um eins */
     }
}


/********************************************/
/*   Gibt eine Seite Speicherinhalte aus.   */
/********************************************/
dump_side()
{
     for (akzel = BEGZEILE; akzel <= ENDZEILE; akzel++)
          dump_oneline();          /* gibt eine Seite Speicher aus.   */
     print_adr();
}


/****************************************************/
/* Gibt Seite nochmals aus... (fÅr C - Change Mode) */
/****************************************************/
ausgabe()
{
     sub(0x160);              /* zieht von akt. Adresse 0x160 ab-    */
     dump_side();             /* gibt Seite voll Speicherwerten aus. */
}


/*************************************************************************/
/* Da der Adreûzeiger ein 32 Bit Pointer ist, und beim Unterlauf eine    */
/* hîhere Zahl als 16MB rauskommen wÅrde, wÅrde dies zu einem Adreûfehler*/
/* (3 Bombem) fÅhren. Daher wird geprÅft ob die Subtraktion unterlÑuft,  */
/* und falls ja, dann wird der Wert eben von 16MB abgezogen -> leicht!   */
/*************************************************************************/
sub(operand)
  int operand;
{
     if ((dump_adresse - operand) < 0)
     /* Falls keine Sp.Kontrolle, dann statt maxadr physik. Ende nehmen */
          dump_adresse += ( (user) ? ENDMEM : maxadr) - operand;
     else dump_adresse -= operand;
}

/*************************************************************************/
/* Mit der Addition ist es dasselbe. ^!                                  */
/*************************************************************************/
add(operand)
  int operand;
{
     if ((dump_adresse + operand) >= ( (user) ? ENDMEM : maxadr))
          dump_adresse += operand - ( (user) ? ENDMEM : maxadr);
     else dump_adresse += operand;
}

/**************************************/
/*   Fast only for one Subtract       */
/**************************************/
fsub()
{
     if (dump_adresse == 0)
          dump_adresse = ( (user) ? ENDMEM : maxadr); /* gleiche wie sub() */
     else dump_adresse--;
}

/**************************************/
/*   Fast only for one Addition       */
/**************************************/
fadd()
{
     if (dump_adresse == ((user) ? ENDMEM : maxadr) - 1 )
          dump_adresse = 0;
     else dump_adresse++;
}


/************************************************************/
/* Diese Routine bestimmt die max. Speicherbereich, der     */
/* durch die beiden Banks ansprechbar ist.                  */
/************************************************************/
get_maxadr()
{
     maxadr = *phystop;       /* gibt das physische Ende des RAM an       */
     konf_print();            /* gibt Koniguration auf Screen aus.        */
}


/*****************************************************/
/* Gibt max. Speicherkonf. auf Screen aus.           */
/*****************************************************/
konf_print()
{
     GOTO(STATUSZEILE-1,80-((maxadr/1024) == 16384 ? 12 : 11));
     screen("\033pSP: ");
     dez_dump(maxadr/1024,((maxadr/1024) == 16384 ? 5 : 4));
     screen(" KB\033q");
}


/****************************************************/
/* Holt eine Zeile mit einer beliebiglangen Adresse */
/* DafÅr wurde eine eigende Routine geschrieben, die*/
/* ausschlieûlich 0-9 & a-f | A-F annimmt. Auch ein */
/* Backspace ist vorgesehen!                        */
/****************************************************/
adr_get()
{
   char adrstr[6];       /* max. 5 Stellen 'fffff' ! */
   char pos = 0;         /* Position im String.      */
   char i;               /* aktuelles Zeichen        */
  long pot=1,pot_old=1;  /* Beim Hex->Dez als Potenz 16,256,... */
   int x;                /* ZÑhler beim Hex->Dez     */

     CRSR_ON;            /* CURSOR einschalten         */
     while ( (i = Crawcin()) != '\r') {       /* noch nicht RETURN */

        i = tolower(i);                       /* 'A' -> 'a'        */
        if ((isdigit(i) || ((i >= 'a')) && (i <= 'f')) && (pos < 6))
                 adrstr[pos++] = i;

        else if (i == '\b') {        /* Backspace registrieren */
                   if (pos > 0) {    /* Position noch deletbar? */
                       pos--;
                       CRSR_LT;
                       putchar(' '); /* voriges Zeichen lîschen */
                       CRSR_LT; }
                   i = 0;            /* nicht, dann Zeichen unter- */
        }                            /* drÅcken.                   */

        else i = 0;                  /* nicht gewÅnschtes Zeichen  */
                                   /* einfach unterdrÅcken.      */

        putchar(i);                  /* gewÅnschtes Zeichen ausgeben    */
     }

     for (x=pos, adresse=0; x != 0; --x) {     /* Hexadez. umrechnen */
          adresse += pot * ((adrstr[x-1] < 'a') ? adrstr[x-1]-48 : adrstr[x-1]-87);
          pot = pot_old * 16;
          pot_old = pot;
     }
     CRSR_OFF;                     /* Cursor ausschalten         */

     if ((adresse >= maxadr) && (!user)) {  /* Adresse zu groû? */
          print_out(error[3]);
          sub(0x160);              /* Aktuelle Sp.Pos. bekommen  */
          adresse = dump_adresse;  /* Falls Fehler, dann auf alte Adr.*/
     }
}

/*************************/
/* Holt ein Zeichen      */
/*************************/
CURGET()
{
  char x;

     GOTO(akzel,0);      /* Cursor immer auf aktueller Zeile halten   */
     CRSR_ON;
     x = Crawcin();      /* Zeichen von Tastatur  */
     CRSR_OFF;
     return x;
}


/**********************************************************/
/* Da der Befehl screen das Prg. sehr verlÑngert, bis     */
/* zu 5KB, habe ich dafÅr eine eigene Routine geschrieben */
/**********************************************************/
screen(text)
  char *text;
{
  char *pt = text;

     while(*pt)     putchar(*pt++);     /* Zeichen aus Array ausgeben */
}


/*************************************/
/*   Schaltet zw. RAM und ROM hinher */
/*************************************/
usrswt()
{
     if (user) {    user = 0;      /* User = False; => Supervisor     */
       if (dump_adresse >= maxadr) {    /* Kontrollieren, ob noch im  */
          dump_adresse = 0x0L;          /* erlaubten Sp.Bereich. Wenn */
                                        /* nein, dann Seite ab $0 aus-*/
          dump_side();                  /* geben und Adr.Pointer setzen */
       }
     }
     else {         user = 1;      /* Wir sind nicht mehr unter Kontrolle */
       print_out("\033pAchtung: Bis zu einem weiteren 'u' ist die Adresskontrolle aufgehoben !\033q");
     }
     dis_user();
}

/*******************************/
/* Gibt RAM ROM Selektion aus  */
/*******************************/
dis_user()
{
     GOTO(STATUSZEILE,0);
     if (user)           screen("\033pUSER\033q");
     else                screen("\033pSPVI\033q");
}


/**************************************************/
/* Zeigt das Directory an...                      */
/**************************************************/
show_dir()
{
  char muster[13];            /* beinhaltet spÑter das Muster           */
  char buff [13];             /* beinhaltet gefundene Namen             */
  char x;
  int count = 0;

       DEL_LIN;
       screen("Geben Sie das DIR-Auswahlmuster ein (z.B. m?n.p*): >");

       readline(muster,12);        /* Liest Zeichen von Tastatur  */
                                   /* incl. Echo und 0 am Str.Ende*/

     clear_up();    /* lîscht die oberen Arbeitszeilen und HOME */

     while(step(muster,buff)) {
          screen(buff);
          screen("\015\014");   /* neue Zeile beginnen */

          if ( count++ == (STATUSZEILE-2)) {
               print_out(hinweis);           /* erwarte Tastendruck... */
               count = 0;  clear_up();
          }
     }

     print_out(hinweis);                     /* nochmals Tastendruck zum */
                                             /* Schluû.                  */
     sub(0x160);         /* um auf alte Adresse zu kommen */
     dump_side();        /* kaputte Seite neu aufbauen... */
}


int step(muster,buff)
  char *muster,*buff;
{
  static int first = TRUE;

     switch(first) {
      case TRUE:    Fsetdta(&dta);
                    if(!Fsfirst(muster,0))
                    {  strcpy(buff,dta.name);
                       first = FALSE;
                       return TRUE;
                    }
                    else return FALSE;

      case FALSE:   if (!Fsnext)
                    {  strcpy(buff,dta.name);
                       return TRUE;
                    }
                    else
                    { first = TRUE;
                      return FALSE;
                    }
     }
}


/************************************************/
/* Diese Routinen liest eine Zeile in ein Array */
/************************************************/
readline(buffer,anzahl)
  char buffer[80];       /* max. 80 Zeichen pro Zeile */
  int anzahl;
{
  int pos = 0;
  char i;

     CRSR_ON;

     while( (i = Crawcin()) != '\r' ) {

          if ( (i == '\b') && (pos) ) {      /* Backspace */
             pos--;
             CRSR_LT;
             putchar(' ');
             CRSR_LT;
             continue;
          }

          if ( (i < 32) || (pos == anzahl) )
             continue;                       /* kein annehmbares Zeichen*/
                                             /* oder schon zuviel?      */

          buffer[pos++] = i;            /* sonst Zeichen Åbernehmen...  */
          putchar(i);
          continue;
     }

     buffer[pos] = 0;
     CRSR_OFF;
     DEL_LIN;                 /* und zusÑtzl. Zeile lîschen */
}


/***********************************/
/* lîscht obere 21 Zeilen...       */
/***********************************/
clear_up()
{
     for(akzel = 0; akzel < (STATUSZEILE-1); akzel++)
     {    GOTO(akzel,0);
          DEL_LIN;
     }
     HOME;
}


/************************************************/
/* Baut die Status- und die Textzeile neu auf   */
/************************************************/
init_scr()
{
     trennen();               /* Gibt die Trennzeile zwischen Arbeits- und */
                              /* Monitor-spezifischen Zeilen aus.          */

     GOTO(STATUSZEILE,0);
     DEL_LIN;
     screen(zeile_1);         /* MUsterzeile der Statuszeile ausgeben */

     dis_user();              /* Gibt den Zugriffsmodus an USER/SPVI  */

     GOTO(TEXTZEILE,0);
     DEL_LIN;

     konf_print();            /* gibt die Speicherkonfiguration an    */
     dump_side();
}


/********************************/
/* Setzt LW-Nr. neu...          */
/********************************/
set_drv()
{
  char parameter,p2;
  int drv;

            DEL_LIN;
            GOTO(TEXTZEILE,0);
            screen("Altes Laufwerk: ");
            drv = Dgetdrv();  /* aktuelle LW Nr. holen      */
            putchar('A' + drv);
            screen("\t\tNeues Laufwerk: >");
            get_taste(&parameter); /* holt ein Zeichen - den Buchstaben */
            p2 = toupper(parameter);/* unbedingt in Groûbuchstaben wandeln*/

            /* Ist Buchstabe gÅltig (A-D), dann verarbeiten, sonst... */
            if ( (p2 >= 'A') && (p2 < 'E') ) {
                drv = (p2 - 'A');
                Dsetdrv(drv);  }
            else print_out(error[4]);/* ungÅltige No., dann fehler!       */

            DEL_LIN;                 /* Zeile lîschen                     */
}


/********************************************************/
/* liest ein Speicherzeile vom Benutzer in den Speicher */
/********************************************************/
read_mem()
{
  char text[80];   /* enthÑlt eingegebenen Text des Benutzers...*/
  char pos = 0;    /* enthÑlt Pos. im Array ^                   */
  char byte,store;

     GOTO(TEXTZEILE,0);
     DEL_LIN;
     screen("Adr. >");
     adr_get();               /* Åbergibt Startadresse der Var. adresse */
     dump_adresse = adresse;  /* Pointer setzen   */

     GOTO(TEXTZEILE,12);      /* Der Benutzer kann jetzt den text eingeben */
     putchar(':');            /* Trennzeichen ausgeben */
     readline(text,80-14);    /* LÑnge des Textes: 80-14 = 64 Zeichen max. */

     /* Jetzt kanns umwandeln in Nibbles losgehen... */

     while ( (byte = text[pos++]) != 0) {    /* solange lesen, bis Zeichen*/
                                             /* null ist (Endmarke!)      */

          if (ishex(byte)) {                 /* Soll eine Hexzahl eingeben werden? */
               store = byte;                 /* merken */

               if ( ((byte = text[pos++]) == 0) || (!ishex(byte)) ) {
                  print_out(error[1]);       /* Ist nÑschstes Zeichen kein*/
                  return;                    /* Nibble, dann Fehler!      */
               }
                    /* sonst Åbernehmen und Sp.Pointer erhîhen... */
               *dump_adresse = ( hextoi(byte) + (hextoi(store) << 4));
               fadd();
          }
 
          if (byte == '"') {       /* Will Benutzer einen Text einziehen? */
               while ( (byte = text[pos++]) != '"') {
                    if (byte == 0) return;
                    *dump_adresse = byte;    /* Zeichen in Speicher setzten */
                    fadd();
               }
          }

     }    /* end of while */

}         /* end of subroutine */


ishex(op)      /* prÅfen, ob Åbergebenes Zeichen ein Nibble in Hex ist */
  char op;
{
     op = toupper(op);
     return ( isdigit(op) || ( (op >= 'A') && (op <= 'F') ) );
}


hextoi(op)     /* wandelt Hexzeichen in ein Dezimales Zeichen um      */
  register char op;
{
     op = toupper(op);
     if(isdigit(op))
          return (op - '0');
     else
          return (10 + (op - 'A'));
}


/**********************************/
/* LÑdt Programm (und startet es) */
/**********************************/
load_prg(mode)
  int mode;         /* 0 = laden & starten ; 3 = nur laden */
{
  char *mem;
  char null = 0;
  long x;

     GOTO(TEXTZEILE,0);
     DEL_LIN;
     screen("Wie heiût das Programm? >");

     readline(file_name,12);            /* liest Dateinamen ein... */
     x = Pexec(mode,file_name,&null,&null);  /* lÑdt (und startet) das Prg. */

     DEL_LIN;

            if ( (x < 0) && (x > -68) && (mode == 3) ) { /* Fehler nur beim NURLADEN! */
               print_out(error[5]);     /* Fehler gefunden ? */
               return;
            }

            if (mode == 3) {       /* Falls NURLADEN, dann auch BP-Infos anzeigen */
                 BP = x;
                 BP = *BP;         /* durch dereferenzierung die Adresse der BP   */
                 mem = BP;

                    /* reservierten Speicherbereich wieder freigeben */
                 Mshrink(mem,(long) 0x100l + BP.p_tlen + BP.p_dlen + BP.p_blen);
                 ask_show_bp();    /* zeigt auf ANfrage die BasePage Infos an */
                 strcpy(FILENAME,file_name); /* setzt den Namen des aktuellen Files neu */
            }
}


/********************************/
/* lÑdt Bild und zeigt es an... */
/********************************/
show_pic()
{
  char x,*bildschirm;
  int handle;

     GOTO(TEXTZEILE,0);
     DEL_LIN;

     screen("Wie heiût das S/W Bild? >");
     readline(file_name,12);
     bildschirm = Physbase();      /* holt sich Bildschirmanfangsadresse */

     screen("Degas-Format (j/n)? >");   /* Degas-Format, dann - 34 Bytes */
     get_taste(&x);    /* holt ein Zeichen */

     if (toupper(x) == 'J')   bildschirm -= 34;

     if ( (handle = Fopen(file_name,0)) < 0) {
          print_out(error[5]);          /* Bei OPEN-Fehler, abbrechen    */
          return;
     }

     Fread(handle,0x8000l,bildschirm);  /* 32KB Bildschirm laden         */
     Fclose(handle);

     gemdos(7);          /* auf eine Taste warten */
     sub(0x160);
     init_scr();         /* BS neu aufbauen       */
}


/******************************************/
/* Gibt auf Anfrage die BP-Infos aus      */
/******************************************/
ask_show_bp()
{
     GOTO(TEXTZEILE,2);
     DEL_LIN;

     set_infos();             /* setzt die Start- und Endadresse */

     screen("Low Adr. TPA: $");
     hex_dump(ANFANG,4);

     screen(" | Hi Adr. TPA: $");
     hex_dump(ENDE,4);

     screen(" | LÑnge TPA: $");
     hex_dump( ENDE - ANFANG,4);

     warte_auf_taste();

     screen("Adr. Text: $");
     hex_dump(ANFANG + 0x100,4);

     screen(" | Adr. DATA: $");
     hex_dump(BP.p_dbase,4);

     screen(" | Adr. uninit BSS: $");
     hex_dump(BP.p_bbase,4);

     warte_auf_taste();
}

/*****************************************/
/* Wartet auf Taste und lîscht Textzeile */
/*****************************************/
warte_auf_taste()
{
     GOTO(TEXTZEILE,74);
     screen(" \033pTASTE\033q");
     gemdos(7);

     GOTO(TEXTZEILE,2);
     DEL_LIN;
}


/*******************************************/
/* setzt fÅr VIEW INFOS die Infos in Var.  */
/*******************************************/
set_infos()
{
     ANFANG = BP.p_lowtpa;    /* Anfangsadresse */
     ENDE   = BP.p_lowtpa + BP.p_tlen + BP.p_dlen + BP.p_blen + 0x100;
}

