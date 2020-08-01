/*--------------------------------------------------------*/
/*          m e n u _ l i b . c                           */
/*        -----------------------------                   */
/*  TastenunterstÅtzung in Dropdown-MenÅs. Entnommen der  */
/*  ST-Computer November '89: "TastenunterstÅtzung in     */
/*  Dropdown-MenÅs".                                      */
/*                                                        */
/*   Version 2.10  vom 29.11.92                           */
/*                                                        */
/*   entwickelt    von Urs MÅller                         */
/*                 mit Megamax Laser C   Version 1.2      */
/*                                                        */
/*   umgeschrieben auf Mark Williams C  Version 3.09      */
/*           von Volker Nawrath                           */
/*--------------------------------------------------------*/



/* Headerdateien
 * ------------- */
#include <gemdefs.h>
#include <gemsys.h>
#include <obdefs.h>
#include <osbind.h>
#include <xbios.h>

/* Funktionen
 * ---------- */
/*   char *Keytbl();     */
extern    int  wind_update();

/* Konstanten
 * ---------- */
#define F1          0x3b      /* Scancode von F1                 */
#define F10         0x44      /* Scancode von F10                */
#define F11         0x54      /* Scancode von [Shift] F1         */
#define F20         0x5d      /* Scancode von [Shift] F10        */
#define M_NORMAL    1         /* Menutitel normal dargestellt    */
#define M_REVERSE   0         /* Menutitel schwarz auf weiû      */


/* ###########################
 * MenÅeintrag untersuchen
 * ########################### */

/* Diese Funktion durchsucht einen MenÅeintrag nach den letzten Buch-
 * staben und vergleicht diesen mit der Tastatureingabe (kstate und
 * key). Wird eine logische öbereinstimmung gefunden, so gibt die
 * Funktion den Wert TRUE zurÅck. Im anderen Fall gibt sie FALSE zu-
 * rÅck.
 *
 * Mîgliche Werte fÅr die letzten Buchstaben in einem MenÅeintrag sind,
 * mîglich, wobei X fÅr ein beliebiges Zeichen steht:
 * F1 bis F10      : Funktionstasten
 * F11 bis F20     : [Shift] Funktionstasten (F1 - F10)
 * F1 .. F10     : [Shift] Funktionstasten (F1 - F10)
 * ^X              : [Control] Buchstabe
 * X              : [Alternate] Buchstabe
 * 'X'             : Buchstabe ohne [Ctrl] und [Alt]
 *
 * Gesucht wird im MenÅeintrag von Rechts (wobei Spaces Åbersprungen
 * werden) nach einer der obigen Kombinationen. Bei den Buchstaben wird
 * nicht zwischen Groû und Klein unterschieden.                   */

static    int  test_entry(str,chr,scan,state)
     char *str;     /* MenÅstring                           */
     char chr;      /* Zeichen der gedrÅckten Taste         */
     int  scan;     /* Scancode der gedrÅckten Taste        */
     int  state;    /* Zustand der CTRL-,ALT-,SHIFT-Taste   */
{
     char *pchar,vchr;
     int  ret,zahl;    

     ret   = FALSE;
     pchar = str;

     /* pchar an den Schluû des Strings bringen
      * --------------------------------------- */
     while (*pchar) pchar++;

     /* Vom rechtes Rand aus erstes Zeichen suchen (Leerzeichen
      * werden Åberlesen
      * ------------------------------------------------------- */
     while (*--pchar == ' ');

     vchr = *pchar;

     /* Kleinbuchstaben in Groûbuchstaben umwandeln (MenÅstring)
      * -------------------------------------------------------- */
     if (vchr >= 'a' && vchr <= 'z')
          vchr = vchr - 'a' + 'A';

     if (vchr == chr)
     {
          /* Zeichen im MenÅstring stimmt mit Scancode Åberein;
           * prÅfen, ob CTRL- oder ALT-Taste gedrÅckt wurde und
           * vor dem Buchstaben im String das ^ oder das Fullbox-
           * symbol steht.
           * -------------------------------------------------- */
          pchar--;
          if (*pchar == '^' && state == K_CTRL ||
              *pchar == 7   && state == K_ALT    )
               ret = TRUE;
     }
     else if (*pchar == '\'' && (state & (K_CTRL | K_ALT)) == 0)
     {
          /* Hochkomma <'> im String gefunden; prÅfen, ob davor
           * ein Buchstabe steht und keine Zusatztaste (CTRL/ALT)
           * gedrÅckt ist. Vor dem Buchstaben muû auch ein Hoch-
           * komma stehen.
           * -------------------------------------------------- */
          pchar--;
          vchr = *pchar;
          if (vchr >= 'a' && vchr <= 'z')
               vchr = vchr - 'a' + 'A';
          if (vchr == chr && *(pchar - 1) == '\'')
               ret = TRUE;
     }
     else if (*pchar >= '0' && *pchar <= '9')
     {
          /* Ziffer gefunden; prÅfen, ob Funktionstaste im
           * String angegeben ist; im Feld "zahl" wird die
           * errechnete Nummer der Funktionstaste abgelegt.
           * --------------------------------------------- */
          zahl = *pchar - '0';
          pchar--;
          if (*pchar >= '0' && *pchar <= '9')
          {
               /* Zweite Ziffer gefunden (10'er Stelle).
                * -------------------------------------- */
               zahl += (*pchar - '0') * 10;
               pchar--;
          }
          if (*pchar == 'F')
          {
               /* Buchstabe "F" fÅr Funktionstaste gefunden
                * ----------------------------------------- */
               if (*(pchar - 1) == 1)
               {
                    /* Vor dem "F" wurde das Shiftzeichen
                     * gefunden
                     * ---------------------------------- */
                    zahl += 10;
               }

               /* PrÅfen, ob die im MenÅstring angegebene
                * Funktionstaste gedrÅckt wurde
                * --------------------------------------- */
               if ((zahl >= 1) && (zahl <= 10))
                    if (zahl == scan - F1 + 1)
                         ret = TRUE;
               if ((zahl >= 11) && (zahl <= 20))
                    if (zahl == scan - F11 + 11)
                         ret = TRUE;

          } /* ENDE if (*pchar == 'F') */

     } /* ENDE else if (*pchar >= '0' && *pchar <= '9') */

     /* RÅcksprung mit Schalter, ob Taste gefunden
      * ------------------------------------------ */
     return(ret);

} /* ENDE static int test_entry() */



/* ###########################################
 * Hauptprogramm fÅr das Durchsuchen des MenÅs
 * ########################################### */

/* Diese Funktion durchsucht alle MenueintrÑge des Åbergebenen Menubaums.
 * Ist weder der MenÅeintrag noch der entsprechende MenÅtitel "disabled",
 * wird der String im MenÅeintrag durch test_entry() durchsucht. Wird
 * bei einem Eintrag eine logische Åbereinstimmung mit den Werten von
 * kstate und key gefunden, so wird eine Meldung MN_SELECTED an die auf-
 * rufende Applikation geschickt.
 * menu_search() = 0 --> keine öbereinstimmung gefunden
 * menu_search() = 1 --> Tastenkombination in MenÅ gefunden
 */

int  menu_search(ap_id,m_tree,kstate,key)
     int  ap_id;         /* Applikationsnr.                 */
     OBJECT    *m_tree;  /* Baumstruktur                    */
     int  kstate;        /* Zustand CTRL-,ALT-,SHIFT-Taste  */
     int  key;           /* GedrÅckte Taste                 */
{
     int  msg_buff[8];             /* Message buffer        */
     int  do_quit,found;           /* Flag                  */
     struct    keytbl    *pkeytbl; /* Zeiger auf TastTab    */
     char *kbd_normal;             /* TastTab. normal       */
     char *kbd_shifted;            /* TastTab. shift        */
     char *kbd_caps;               /* TastTab. caps lock    */
     char chr;
     int  state,scan,desk;
     int  mother_title,child_title,mother_entry,child_entry;

     do_quit = FALSE;
     found   = FALSE;
     desk    = TRUE;

     /* öbersetzungstabelle der Tastatur bestimmen
      * ------------------------------------------ */
     pkeytbl     = Keytbl(-1L,-1L,-1L);
     kbd_normal  = (*pkeytbl).kt_normal;     /* Tabelle normal   */
     kbd_shifted = (*pkeytbl).kt_shifted;    /* Tabelle shift    */
     kbd_caps    = (*pkeytbl).kt_capslock;   /* Tabelle capslock */

     /* warten heruntergeklapptes MenÅ geschlossen
      * ------------------------------------------ */
     wind_update(BEG_UPDATE);
     wind_update(END_UPDATE);

     /* Scancode bestimmen
      * ------------------ */
     scan = key / 256 & 0xff;

     /* ASCII-Werte der Taste bestimmen, indem auf öbersetzungs-
      * tabelle der Tastatur zugegriffen wird
      * -------------------------------------------------------- */
     if ((kstate & (K_LSHIFT | K_RSHIFT)) == 0)
          chr = *(kbd_normal + (scan));
     else
          chr = *(kbd_shifted + (scan));

     /* ASCII-Werte fÅr Kleinbuchstaben werden in ASCII-Werte fÅr
      * Groûbuchstaben umgewandelt
      * --------------------------------------------------------- */
     if (chr >= 'a' && chr <= 'z')
          chr += 'A' - 'a';

     /* "state" belegen, wenn entweder Alternate- oder Controltaste.
      * Wenn beide gleichzeitig gedrÅckt wurden, MenÅ nicht durch-
      * suchen
      * ---------------------------------------------------------- */
     if ((kstate & K_ALT) != 0 && (kstate & K_CTRL) == 0)
          state = K_ALT;      /* [Alt] gedrÅckt */
     else if ((kstate & K_CTRL) != 0 && (kstate & K_ALT) == 0)
          state = K_CTRL;          /* [Ctrl] gedrÅckt */
     else if ((kstate & K_ALT) == 0 && (kstate & K_CTRL) == 0)
          state = 0;          /* nichts gedrÅckt */
     else
          do_quit = TRUE;

     /* Baumstruktur lesen und zwischenspeichern
      * ---------------------------------------- */
     mother_title = (m_tree + m_tree->ob_head)->ob_head;
     child_title  = (m_tree + mother_title)->ob_head;
     mother_entry = (m_tree + m_tree->ob_tail)->ob_head;
     child_entry  = (m_tree + mother_entry)->ob_head;

     /* Schleife zum durchsuchen des gesamten MenÅs
      * ------------------------------------------- */
     while (!do_quit)
     {
          /* PrÅfen, ob Titel "disabled"
           * --------------------------- */
          while (!do_quit && child_entry     != mother_entry
                    && mother_entry != -1
                    && ((m_tree+child_title)->ob_state &
                        DISABLED) == 0           )
          {
               /* Alle MenÅeintrÑge unter dem Titel durchsuchen
                * ------------------------------------------ */
               if ((((m_tree+child_entry)->ob_state &
                     DISABLED) == 0                ) &&
                   ((m_tree+child_entry)->ob_type == G_STRING ||
                    (m_tree+child_entry)->ob_type == G_BUTTON) )
                    do_quit = test_entry((char*)(m_tree +
                           child_entry)->ob_spec,
                           chr,scan,state         );
               if (do_quit)
               {
                    /* Nachricht senden, wenn öberein-
                     * stimmung zwischen MenÅeintrag und
                     * gedrÅckter Taste
                     * --------------------------------- */
                    found         = TRUE;
                    msg_buff[0] = MN_SELECTED;
                    msg_buff[1] = ap_id;
                    msg_buff[2] = 0;
                    msg_buff[3] = child_title;
                    msg_buff[4] = child_entry;
                    menu_tnormal(m_tree,child_title,
                              M_REVERSE      );
                    appl_write(ap_id,16,msg_buff);
               }

               /* Auf nÑchsten MenÅeintrag positionieren
                * -------------------------------------- */
               child_entry = (m_tree + child_entry)->ob_next;

               if (desk)
               {
                    /* Accessories nicht testen
                     * ------------------------ */
                    child_entry = mother_entry;
                    desk = FALSE;
               }
          }

          /* Auf nÑchsten MenÅtitel positionieren
           * ------------------------------------ */
          child_title  = (m_tree + child_title)->ob_next;
          mother_entry = (m_tree + mother_entry)->ob_next;
          child_entry  = (m_tree + mother_entry)->ob_head;

          /* PrÅfen, ob Ende erreicht
           * ------------------------ */
          if (child_title == mother_title)
               do_quit = TRUE;

     } /* ENDE while (!do_quit) */

     if (found)
          return(1);
     else
          return(0);

} /* ENDE int menu_search() */

