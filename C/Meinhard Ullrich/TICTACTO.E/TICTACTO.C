/***********************************************************
** TIC TAC TOE V1.0
**
** HALL OF FAME:
**    Meinhard Ullrich     12h
**    Claus Brod           2h
**
** Das Ziel dieses Spiels ist es, auf dem 3x3-Spielfeld
** drei eigene Steine horizontal, vertikal oder diagonal
** in einer Linie anzuordnen. Es wird abwechselnd gezogen.
** Wenn keiner der Kontrahenten einen Fehler macht, endet
** das Spiel zwingend remis! (Jaja, das gilt fÅr viele
** Strategiespiele, aber hier ist der Rechner wirklich
** nicht in der Lage, Fehler zu machen... ist ja auch
** ein 68000... Ñhem)
**
** Das Spiel eignet sich wegen seiner öberschaubarkeit
** hervorragend dazu, die Minimax-Strategie fÅr Zwei-
** Personen-Nullsummenspiele zu demonstrieren. Denn statt
** einer zweifelhaften und subjektiv vorbestimmten Be-
** punktung einer vorgegebenen Stellung kann die Bewer-
** tungsroutine fÅr jede Stellung eindeutig auf Verloren,
** Remis bzw. Gewonnen prÅfen. Da es nÑmlich im Vergleich
** zu anderen Strategiespielen wie zum Beispiel Schach
** nur relativ wenig Knoten im gesamten Spielbaum gibt,
** kann das Minimax-Verfahren fÅr jede Stellung korrekt
** angeben, welches Ergebnis eine Seite zwingend erreichen
** kann.
**
** Auf der Minimax-Strategie setzt hier noch das Alpha-
** Beta-Verfahren (mit tiefen Schnitten) auf, mit dessen
** Hilfe gro·e Teile des Spielbaums als redundant erkannt
** werden, so da· der Spielbaum betrÑchtlich gestutzt
** werden kann. Dies fÅhrt zu einem erheblichen Geschwin-
** digkeitsgewinn. Der Nachteil daran ist allerdings, da·
** somit nicht nach dem Zug gesucht werden kann, der dem
** Gegner die meisten Mîglichkeiten lÑ·t, Fehler zu be-
** gehen. Von mehreren ZÅgen, die dem Rechner zum Beispiel
** das Remis sichern, wird daher keiner favorisiert. Die
** frappierende Konsequenz: Es kann passieren, da· das Pro-
** gramm den eigenen Sieg hinausschiebt, was besonders ge-
** mein aussieht und vom Gegner meist auch so empfunden
** wird und werden soll.
**
** Sachdienliche Begleitliteratur bitte an jeder Polizei-
** dienststelle abzugeben. Hunde an die Leine fÅhren!
**
** Version 0.5 (Sommer 1989): AMIGA-Version, unverschÑmt
**                      unschlagbar
** Version 1.0 (Mai 1990):    ST-Version, noch ohne Erîffnungs-
**                      bibliothek 8-), fÅr Turbo C 2.0
** Version 2.0 (MÑrz 1997):   Erste Version fÅr die Entwickler-
**                     exemplare des TT.
***********************************************************/


/******************* Includes **********************/
# include <stdio.h>
# include <tos.h>
# include <stdlib.h>
# include <ctype.h>

/******************* Konstanten ********************/
# define LEER           0
# define RECHNER        1
# define SPIELER        2
/* Was heutzutage so alles auf einem Feld stehen darf */

# define MINUS_UNENDLICH -2
# define NIEDERLAGE      -1
# define UNENTSCHIEDEN   0
# define SIEG            1
# define PLUS_UNENDLICH  2
/* Werte fÅr die Stellungsbewertung */

# define MARCELO     Gibs_uns_Roy

# define FALSE       0
# define TRUE        (!FALSE)
/* Wie wahr, wie wahr... */

# define O(x)        Cconout(x)
# define CLS            O(27);O('E');\
   printf("* TICTACTOE V1.0 - ");\
   printf("(C)1990 Meinhard Ullrich, Claus Brod *\n")
# define PRINTAT(y, x)  O(27);O('Y');O(y+32);O(x+32)
# define DELLINE        printf("\n");O(27);O('A');O(27);O('K')
/* FÅr die Bildschirmausgabe - nix GEM, nur TOS */

/******************* Ulkige Typen *****************/
typedef short   Brett[3][3];
typedef struct    {  short Spalte;
                     short Zeile;
                  } Zugtyp;


/******************* Globale Variablen ************/
Brett Spielfeld;
  /* Ich leiste mir hier also den Luxus, ein zweidi-
  ** mensionales Feld zu verwenden, das global ist
  ** und das ausschlie·lich manipuliert wird, wenn
  ** neue Stellungen erzeugt werden oder wenn ZÅge
  ** zurÅckgenommen werden. Effizienter wÅrde das
  ** Programm arbeiten, wenn die Stellung in ein
  ** Langwort kopiert wÅrde, das sich in einem Register
  ** halten lie·e und auf dem nur mit booleschen
  ** Operatoren gearbeitet wÅrde. Das wÅrde aber das
  ** Programm fÅr den Betrachter bei weitem weniger
  ** anschaulich machen. Da sich dies zudem deshalb
  ** nicht lohnt, weil auch diese Version so schnell
  ** ist, da· sie den ersten Zug binnen weniger
  ** Sekunden findet, habe ich diese vorlÑufige Fassung
  ** beibehalten.
  */
short Zugzaehler;
  /* Arbeitsbeschaffungsma·nahme bei der
  ** Deutschen Bundesbahn
  */
  
/****** Prototypen (nein, ich habe nicht TT gesagt) ****/

int   Jein(char *);
int   Wer_beginnt (void);
void  Initialisierung (void);
void  Hole_Spielerzug (Zugtyp *);
void  Zeige_Zug (short, Zugtyp *);
short Bewertung (short);
short AlphaBeta (Zugtyp *, short, short, short);
int   main (void);


/********************* Funktionen *********************/

/* Jein()
** Auf dumme Fragen gibt's auch eine dumme Antwort.
** (Goethe nicht, aber vielleicht Schiller.)
**
** Liefert TRUE (fÅr 'j'/'J') oder FALSE (fÅr 'n'/'N').
*/
int Jein(Frage)
char *Frage;
{
   char c;
   int selbsterklaerende_variable;
      
   printf("%s (j/n)?\n", Frage);
   
   do
      c = toupper((int)Cnecin());
   while ((c != 'J') && (c != 'N'));
   
   printf("%c\n", c);
   return (c == 'J' ? TRUE : FALSE);
}

/* Wer_beginnt()
** Prosa: Fragt den Benutzer, wer anfangen soll, und lie-
**        fert als Ergebnis die Konstante SPIELER oder
**        RECHNER zurÅck.
*/
int Wer_beginnt()
{
   CLS; PRINTAT(3,3);
   return (Jein("Wollen Sie beginnen") == TRUE ? 
                           SPIELER : RECHNER);
}

/*********************************************************/

/* Initialisierung()
** Prosa: Erzeugt leeres Brett mit Koordinatenbeschriftung
**        auf dem Bildschirm. Das interne Spielfeld wollen
**        wir auch schnell lîschen (Datenschutz), und der
**        Zugzaehler mu· entlastet werden, sagt die Eisen-
**        bahnergewerkschaft.
*/
void Initialisierung()
{
   int x,y;
   
   CLS;  /* Lîscht den Bildschirm - schlierenfrei */
   
   PRINTAT(4,4); printf("   a b c ");
   PRINTAT(5,4); printf("1  . . . ");
   PRINTAT(6,4); printf("2  . . . ");
   PRINTAT(7,4); printf("3  . . . ");
   printf("\n");

   for (x=0; x<3; x++)
        for (y=0; y<3; y++)
         Spielfeld[x][y] = LEER;

   Zugzaehler = 0;
}

/**********************************************************/

/* Hole_Spielerzug()
** Prosa: Wie der Name schon sagt: Gibt dem Spieler die
**        Mîglichkeit, die Koordinaten seines gewÅnschten
**        Zugs kundzutun. Dieser wird in die der aufrufenden
**        Prozedur bekannten Variablen Zug geschrieben.
**      Zieht der Spieler es vor, statt der Zugkoordinaten
**      ein Telegramm aufzugeben, so kînnen und wollen wir
**      ihn nicht daran hindern. Vorsicht: Nach 80 Zeichen
**        wird das Telegramm verschickt, notfalls nach Nirwana.
*/
void Hole_Spielerzug(Zug)
   Zugtyp * Zug;
{
   char Spalte, Zeile; /* Erlaubt: 'a'-'c' bzw. '1'-'3' */
   char Puffer[80];    /* Die einfachste Lîsung, aber nicht
                       ** ganz narrensicher.
                       */

   do {
      PRINTAT(10,1); DELLINE; printf("Ihr Zug: ");
      scanf("%s", Puffer);
      Spalte = Puffer[0];
      Zeile  = Puffer[1];
      }
   while(   (Spalte < 'a') || (Spalte > 'c')
         || (Zeile  < '1') || (Zeile  > '3'));

   Zug->Spalte = (short)(Spalte - 'a');
   Zug->Zeile  = (short)(Zeile - '1');
}

/*********************************************************/

/* Zeige_Zug()
** Prosa: Der Åbergebene <<Zug>> wird auf dem Bildschirm
**        dargestellt in der "Farbe" des Spielers, der
**        gerade <<AmZug>> war.
*/
void Zeige_Zug(AmZug, Zug)
   short  AmZug;
   Zugtyp *Zug;
{
   PRINTAT(5 + Zug->Zeile, 7 + 2 * Zug->Spalte);
      if (AmZug == SPIELER)
         puts("O");
      else
         puts("X");
}

/*********************************************************/

/* Bewertung()
** Prosa: Die Bewertung prÅft in diesem einfachen Fall nur
**        nach, ob der Spieler, der zuletzt gezogen hat,
**        drei Steine in eine Reihe gebracht hat und somit
**        das Spiel gewonnen hat. Die einzige Eingabe ist
**        daher <<LetzterAmZug>>.
*/
short Bewertung(LetzterAmZug)
register short LetzterAmZug;
   /* FÅr C-Einsteiger: 'register short' bedeutet, da·
   ** der C-Compiler spezielle Hardwareeigenschaften
   ** nutzt, um die Datenregister auf 13 Bits zu kÅrzen.
   ** Die restlichen 19 Bits verwendet Motorola fÅr
   ** interne Zwecke. Vorsicht: Hîllisch inkompatibel!
   */
{

   /* Teste auf Muehlen (ich dachte, wir sind bei TicTacToe?) */
   if (Spielfeld[1][1] == LetzterAmZug)
   {
      if (Spielfeld[0][0] == LetzterAmZug)
         if (Spielfeld[2][2] == LetzterAmZug)
           return(SIEG);
      if (Spielfeld[1][0] == LetzterAmZug)
         if (Spielfeld[1][2] == LetzterAmZug)
           return(SIEG);
      if (Spielfeld[2][0] == LetzterAmZug)
         if (Spielfeld[0][2] == LetzterAmZug)
           return(SIEG);
      if (Spielfeld[0][1] == LetzterAmZug)
         if (Spielfeld[2][1] == LetzterAmZug)
           return(SIEG);
   }
   if (Spielfeld[0][0] == LetzterAmZug)
   {
      if (Spielfeld[1][0] == LetzterAmZug)
         if (Spielfeld[2][0] == LetzterAmZug)
            return(SIEG);
      if (Spielfeld[0][1] == LetzterAmZug)
         if (Spielfeld[0][2] == LetzterAmZug)
            return(SIEG);
   }
   if (Spielfeld[2][2] == LetzterAmZug)
   {
      if (Spielfeld[2][1] == LetzterAmZug)
         if (Spielfeld[2][0] == LetzterAmZug)
            return(SIEG);
      if (Spielfeld[1][2] == LetzterAmZug)
         if (Spielfeld[0][2] == LetzterAmZug)
            return(SIEG);
   }
   return(UNENTSCHIEDEN);
}

/*********************************************************/

/* AlphaBeta()
** Prosa: Sie befinden sich hier bei einer der grî·ten
**        SehenswÅrdigkeiten in diesem Programm, eine echte
**        RaritÑt. Die Wurzeln dieser Prozedur reichen bis
**        in die frÅhen vierziger Jahre dieses Jahrhunderts
**        zurÅck, als John von Neumann und Oskar Morgenstern
**        das Minimax-Verfahren vorschlugen. Wem man das
**        Alpha-Beta-Verfahren zuordnen soll, ist heute
**        etwas umstritten, gro·e Verdienste um seine
**        theoretische Erforschung erwarb sich Donald E.
**        Knuth.
**        Sie finden hier eine Implementierung vor, die
**        sich nicht nur einfacher, sondern auch tiefer
**        Schnitte bedient. Bei der Suche im Spielbaum ist
**        daher zu jeder Zeit ein Suchfenster vorgegeben.
**        Dieses besteht aus einem vorlÑufigen Maximum und
**        Minimum. Mit fortschreitender Suche kann dieses
**        Fenster immer mehr eingeengt werden, so da· im
**        Verlauf der Suche immer mehr éste des Spielbaums
**        als redundant erkannt und abgeschnitten werden
**        kînnen. (Wenn die Prozedur mit einem bestimmten
**        Fenster aufgerufen wurde und innerhalb der Pro-
**        zedur ein vorlÑufiger Wert ermittelt wird, der
**        au·erhalb dieses Fensters liegt - man sagt: die
**        Fenstergrenzen werden verletzt -, so kann die
**        Prozedur sofort verlassen werden - mit der
**        Fenstergrenze, die verletzt wurde, als RÅckgabe-
**        wert.)
**        Um noch einmal erheblich an Platz zu sparen,
**        habe ich hier statt der Minimax- die Negmax-
**        Variante implementiert, die allerdings fÅr
**        den Laien schwerer zu verstehen ist. (Einen
**        Beweis fÅr die équivalenz der Verfahren sowie
**        eine genauere Besprechung findet man zum Beispiel
**        bei: Claus Brod, Meinhard Ullrich: Programmierung
**        des MÅhlespiels auf verteilter Hardware,
**        Studienarbeit an der Friedrich-Alexander-UniversitÑt
**        Erlangen-NÅrnberg, Institut fÅr Mathematische
**       Maschinen und Datenverarbeitung, Lehrstuhl fÅr
**       Programmier- und Dialogsprachen sowie ihre Compiler.)
**
**      öberprÅfen Sie regelmÑ·ig Ihren Verbandkasten!
*/
short AlphaBeta(Inp_Zug, Inp_AmZug, alpha, beta)
Zugtyp * Inp_Zug;
short Inp_AmZug;
short alpha, beta;
{
   register short Zeile, Spalte;
   register short Wert;
   register short AktMaximum;
   Zugtyp Zug;
   register short LetzterAmZug;

   Zugzaehler++;

   /* Wir wollen die zeitraubende PrÅfung, ob ein Spieler
   ** eine "MÅhle" bauen konnte, nur einmal durchlaufen.
   ** Es kann ja immer nur der Spieler gewonnen haben, der
   ** zuletzt gezogen hat. Daher...
   */
   LetzterAmZug = (Inp_AmZug==SPIELER) ? RECHNER : SPIELER;

   /* Die nÑchsten beiden if's prÅfen, ob bereits eine
   ** Endstellung vorliegt.
   */
   if (Bewertung(LetzterAmZug) == SIEG)
   {
      Zugzaehler--;
      return(NIEDERLAGE);
      /* Der Spieler, der als letzter gezogen hat, hat eine
      ** Gewinnstellung, also hat der Spieler, der nun dran
      ** ist, bereits verloren.
      */
   }

   if (Zugzaehler > 9)
   {
      Zugzaehler--;
      return(UNENTSCHIEDEN);
   }

   AktMaximum = alpha;

   /* Die Zuggenerierung ist in diesem Fall so einfach, da·
   ** es am gÅnstigsten (weil am zeitsparendsten) ist, sie
   ** gleich in die AlphaBeta-Prozedur zu integrieren:
   */
   for (Zeile = 0; Zeile <= 2; Zeile++)
      for (Spalte = 0; (Spalte <= 2) && (AktMaximum<beta);
                                             Spalte++)
         if (Spielfeld[Spalte][Zeile] == LEER)
         {
            Spielfeld[Spalte][Zeile] = Inp_AmZug;
            Wert = -AlphaBeta(&Zug, LetzterAmZug, -beta,
                                             -AktMaximum);
            if (Wert > AktMaximum)
            {
               AktMaximum = Wert;
               Inp_Zug->Zeile = Zeile;
               Inp_Zug->Spalte = Spalte;
            }
            Spielfeld[Spalte][Zeile] = LEER;
         }

   Zugzaehler--;

   return (AktMaximum);
}

/*********************************************************/

/* main()
**            Allein das Wasser, das er ha·te
**         Und das ihn jetzt nach oben stî·t,
**         Nachdem Gerîhr es nicht mehr fa·te,
**         Hat ihm die Freude eingeflî·t.
**         (aus "Der Gulli", Ballade in 24 Strophen von
**          Meinhard Ullrich. Bei mehr als hundert Anfragen
**          demnÑchst als Paperback im gutsortierten 
**             Buchhandel.)
**
** Prosa: Hier passiert im Grunde nicht viel. Also machen
**       wir am besten auch gar nicht erst gro·e Worte
**        darum.
**
**        Naja, also gut: Falls es dem Spieler danach
**        gelÅstet, darf er den ersten Zug machen;
**        dann wird wechselweise die AlpaBeta-Prozedur
**        gestartet, um einen Zug fÅr den Rechner zu
**        ermitteln, und der Benutzer nach seinem
**        nÑchsten Zug befragt. Weil ich mir sicher bin,
**        da· das Programm nicht verlieren kann, ist eine
**        solche Abfrage erst gar nicht vorhanden. (Sollte
**        jemand das Gegenteil beweisen kînnen, bitte ich
**        darum die siegreiche Zugfolge an die Redaktion
**        einzusenden.) Sobald die Alpabeta-Prozedur einen
**        Gewinnweg fÅr den Rechner gefunden hat, wird dies
**        eingeblendet. Ist der Sieg fÅr den Rechner per-
**        fekt, wird dies natÅrlich gemeldet und das Spiel
**        ist abrupt zu Ende.
*/
int main()
{
   short Erfolgsaussicht;
   Zugtyp Zug;
   int Anfang;
   int NocheinSpiel = TRUE;
   int gewonnen;
     
   while (NocheinSpiel == TRUE)
   {
     Anfang = Wer_beginnt();
      Initialisierung();
      if (Anfang == SPIELER)
         {
         Hole_Spielerzug(&Zug);
         Zeige_Zug(SPIELER, &Zug);
         Spielfeld[Zug.Spalte][Zug.Zeile] = SPIELER;
         Zugzaehler++;
         }
   
      gewonnen = FALSE;
      
      while ((Zugzaehler < 9) && (gewonnen == FALSE))
      {
         /* Den vorgeschlagenen Zug legt die AlphaBeta-Prozedur
         ** in der vorgegebenen Struktur Zug ab:
         */
         Erfolgsaussicht = AlphaBeta(&Zug, RECHNER,
                             MINUS_UNENDLICH, PLUS_UNENDLICH);
         Zeige_Zug(RECHNER, &Zug);
         Spielfeld[Zug.Spalte][Zug.Zeile] = RECHNER;
   
         /* War der letzte Zug der Gewinnzug? */
         if (Bewertung(RECHNER) == SIEG)
         {
            PRINTAT(12,1); printf("Ich habe gewonnen!\n");
            gewonnen = TRUE;
         }
         else
         {
            /* Ist der Sieg schon sicher? */
            if (Erfolgsaussicht == SIEG)
            {
            PRINTAT(11,1); printf("Ich werde gewinnen!\n");
            }
   
            Zugzaehler++;
            if (Zugzaehler != 9)
            {
                  do Hole_Spielerzug(&Zug);
                  while(Spielfeld[Zug.Spalte][Zug.Zeile] != LEER);
                  Zeige_Zug(SPIELER, &Zug);
                  Spielfeld[Zug.Spalte][Zug.Zeile] = SPIELER;
                  Zugzaehler++;
               }
           }
      }
   
      if (gewonnen == FALSE)
      {
           PRINTAT(12,1);
           printf("Naja... einigen wir uns auf Unentschieden.\n");
      }
      
      PRINTAT (14,1); NocheinSpiel = Jein("Noch ein Spiel");
   }
   return 0;
}

