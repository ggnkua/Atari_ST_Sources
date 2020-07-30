/********************************************************************/
/* Funktionsprototypen fÅr Funktionen, die die Kommunikation mit
   GEMINI bzw. Venus vereinfachen

   (c) 1990,91,92 by Stephan Gerle

   E-Mail: Maus Net: Stephan Gerle @ DO
           Internet: sg@do.maus.de

   Stand: 8.3.92

   SÑmtliche Funktionen liefern 1, wenn die Hauptapplikation die
   Funktion kennt bzw. 0, wenn die Hauptapplikation die Funktion
   nicht kennt.

   Die Funktionen wurden komplett umgeschrieben, da es erhebliche
   Probleme mit dem Timeout gab.
   Da das AV-Protokoll Event-orientiert arbeitet, ist die Realisierung
   einiger Funktionen als Funktion nicht mîglich bzw. fÅhrt nur
   zu Problemen.

   Siehe auch VAPROTO.H.

   Achtung: 5er Tabs
*/

#ifndef __VAFUNC_H
#define __VAFUNC_H

#include <sg\vaproto.h>

/*** Macros **********************************************************/

/* AVSTR2MSG setzt den Wert eines String-Pointers in ein Message-
   array ein.
       msg    : Name des Integerarrays.
       offset : Kleinerer Index des Interger-PÑrchens
       str    : Zeiger auf String
*/
#define  AVSTR2MSG(msg,offset,str)  (*(char **)(msg+offset) = str)

/* AVMSG2STR bastelt aus einem Integer-PÑrchens einer Messages einen
   String-Pointer zusammen.
       msg    : Name des Integerarrays
       offset : Kleinerer Index des Integer-PÑrchens.
*/
#define  AVMSG2STR(msg,offset)         ((char *)(((long)msg[offset]<<16)|(((long)msg[offset+1])&0xffff)))

/* AVHasProto() dient zum Test, ob die Hauptapplikation eine bestimmte
   Funktion des AV-Protokolls unterstÅtzt.
   Als Parameter wird die Nummer des Words (0-2) sowie die Bitnummer
   im Word Åbergeben.
   NÑheres hierzu siehe VAPROTO.H bei VA_PROTOSTATUS */

#define  AVHasProto(word,bit)       (AVStatus[word]&(1<<bit))


/* Liefert TRUE, wenn eine MultiTasking fÑhiges AES installiert ist.
*/

#define  MultiAES()  (_GemParBlk.global[1]!=1)

#define	AP_TERM	50

/*** Globale Variablen fÅr die Library fÅr das AV-Protokoll **********/



/* AVName ist ein Pointer auf einen String, in dem der Name der
   Hauptapplikation steht, die das AV-Protokoll beherrscht.
   Diese Variable wird durch AVActive gesetzt. Der String ist ein
   Leerstring, wenn das Hauptprogramm das AV-Protokoll nicht versteht.*/

extern char AVName[];

/* AVStatus[3] enthÑlt den Protokollstatus der Hauptapplikation.
   Mittels AVHasProto(word,bit) kann damit jede einzelne Funktion des
   AV-Protokolls ÅberprÅft werden. */

extern int  AVStatus[3];


/*** Funktionen fÅr die ProtokollunterstÅtzung ***********************/


/* AVInit muû einmal beim Start des Acc's aufgerufen werden. Damit
   wird die Applikationsid, der Name des Acc (wie bei appl_find benutzt;
   also 8 des Programmnamens eventuell mit Leerzeichen aufgefÅllt) sowie
   die vom Acc unterstÅtzten Funktionen als Bitvektor den Funktionen
   fÅr das AV-Protokoll Åbergeben.
   Diese Routine sollte direkt vor Eintritt in die Messageloop
   aufgerufen werden. */

void  AVInit(int myapid,char *myname,int myprotostatus);


/* Ermittelt, ob Gemini oder Venus bzw. irgendein Hauptprogramm,
   welches das AV-Protokoll versteht, aktiv ist.
   Wenn nein, so wird 0 zurÅckgeliefert, sonst ein Wert ungleich 0.
   Falls der Protokollstatus noch nicht ermittelt werden konnte, so
   wird eine entsprechende Message an das Hauptprogramm geschickt.
   Das Ergebnis ist dann ersteinmal 0. */

int   AVActive(void);


/* Sorgt dafÅr, das der AV-Protokoll-Status neu ermittelt wird. Diese
   Funktion wird bei einem AC_CLOSE durch AVProcessMsg() automatisch
   aufgerufen. */

void  AVGetNewProtoStatus(void);


/* Sendet Statusinformationen an die Hauptapplikation. */

int   AVSendStatus(char *status);


/* Fragt bei der Hauptapplikation den fÅr das Acc gespeicherten Status
   nach.
   Als Antwort kommt von der Hauptapplikation die Meldung VA_SETSTATUS.
   Ansonsten muû die Meldung VA_SETSTATUS in der Messageloop behandelt
   werden. In msg[3/4] ist ein Pointer auf einen String, der den
   Status enthÑlt. */

void  AVReceiveStatus(void);


/* AVProcessMsg muss fÅr jede empfangene Message aufgerufen werden.
   AVProcessMsg liefert einen Wert ungleich 0, falls sich der
   Protokollstatus geÑndert hat. Das heiût aber nicht, das die
   Nachricht VA_PROTOSTATUS gekommen ist!!! */

int   AVProcessMsg(int *msg);



/*** Programmspezifische Funktionen *********************************/



/* Emittelt den fÅr Verzeichnisfenster eingestellten Font und die
   Fonthîhe.
   Die Hauptapplikation schickt daraufhin die Message VA_FILEFONT. */

int   AVAskFileFont(void);


/* Dasselbe wie AVAskFileFont, nur fÅr das Console-Fenster.
   Als Ergebnis kommt die Message VA_CONFONT. */

int   AVAskConsoleFont(void);


/* Fragt bei der Hauptapplikation nach den selektierten Objekten.
   Als Antwort kommt die Message VA_OBJECT. Die Objekte sind jeweils
   durch ein ' ' im String voneinander getrennt. */

void  AVAskSelectedObjects(void);


/* Sagt Gemini, daû das Console-Fenster geîffnet werden soll. */

int   AVOpenConsole(void);


/* Sagt der Hauptapplikation, das ein Fenster mit dem Verzeichnis
   pfad und der Maske mask geîffnet werden soll. */

int   AVOpenWindow(char *pfad,char *mask);


/* Startet mittels Venus bzw. Gemini ein Programm. In pfad steht
   der komplette Pfad und der Programmname. cmdline enthÑlt
   die Kommandozeile fÅr das zu startende Programm. */

int   AVStartProgram(char *pfad,char *cmdline);


/* Sagt der Hauptapplikation, daû das Accessorie ein Fenster geîffnet hat.
 */

int   AVAccOpenedWindow(int winhandle);


/* Sagt der Hauptapplikation, daû das Accessorie ein Fenster geschlossen
 hat.
   (ist nur bei nicht durch AC_CLOSE bedingtem Schlieûen notwendig) */

int   AVAccClosedWindow(int winhandle);


/* Schickt der Hauptapplikation einen Tastaturevent. Ist dann anzuwenden,
   wenn ein ACC ein Fenster offen hat, und einen Tastendruck bekommt,
   den es selber nicht verwendet. */

int   AVSendKeyEvent(int state,int key);


/* AVCopyDragged schickt die Message AV_COPY_DRAGGED an die
 Hauptapplikation.
   Die Hauptapplikation sollte daraufhin die vorher in das Fenster des
   Accs gedraggten Icons in den Zielpfad kopieren.
   kstate ist der Tastaturstatus wie von evnt_multi() erhalten.
   Von der Hauptapplikation kommt als Antwort VA_COPY_COMPLETE. Nachdem
   diese Mitteilung empfangen wurde, kann ein eventuell fÅr das Kopieren
   allozierter Speicher wieder freigegeben werden.
   Diese Funktion darf nur als Antwort auf VA_DRAGACCWIND benutzt werden,
   da sonst nicht eindeutig ist, was kopiert werden soll. */

int   AVCopyDragged(int kstate,char *dest);



/*** Zur Anwendung ***************************************************/

#ifdef __DO_NOT_DEFINE

/* Hier ein minimales Skelett fÅr die Verwendung der AV-Funktionen. */

void  HandleMessage(int kstate,int *msg)
{
   int   FontId,FontPointsHeight;
   char  *status;

   if (AVProcessMsg(msg))
   {
      /* Protokollstatus hat sich geÑndert */

      if ("Habe offene Fenster")
         for ("fÅr jedes offene Fenster")
            AVAccOpenedWindow(winhandle);
      AVAskFileFont();
      AVReceiveStatus();
      ...
   }
   switch (msg[0])
   {
      case  WM_FULLED:  ...
      case  WM_SIZED:      ...
      case  WM_MOVED:      ...
      case  WM_REDRAW:  ...
      case  WM_TOPPED:  ...
      case  WM_ARROWED: ...
      case WM_VSLID:    ...
      case WM_HSLID:    ...

      case  VA_SETSTATUS:
               /* msg[3] und msg[4] enthalten Pointer auf
                  String mit Status (kann auch NULL sein) */
               ...
               break;
      case  VA_FILEFONT:
               /* msg[3] und msg[4] enthalten die Fontdaten
                  (siehe VAPROTO.H) */
               ...
               break:
      case  VA_START:
               /* msg[3] und msg[4] enthalten Pointer auf
                  Kommandozeile */
               ...
               break;
      case  VA_DRAGACCWIND:
               /* msg[6] und msg[7] enthalten Pointer auf
                  String mit Liste der auf das Fenster gezogenen
                  Objekte. */
               ...
               break;
      case  VA_COPY_COMPLETE:
               /* Kopiervorgang beendet. Eventuelle allozierter
                  Speicher wieder freigeben. */
               break;
      ...
   }
}

void  HandleKey(int ks,int kb)
{
   switch (kb)
   {
      ...
      default: AVSendKeyEvent(ks,kb);
            break;
   }
}

void  EventLoop(void)
{
   int   event,msg[8],kb,ks;

   do
   {
      event = evnt_multi(MU_MESAG|MU_KEYBD...,...,msg,...,ks,kb,...);
      if (event&MU_MESAG)
         HandleMessage(ks,msg);
      if (event&MU_KEYBD)
         HandleKey(ks,kb);
      ...
   } while (!QuitFlg);
}

/* Die AV-Protokollfunktionen mÅssen durch den Aufruf von AVInit()
   initialisiert werden.
   Dieser Aufruf muû vor Benutzung aller anderen AV-Funktionen
   gemacht werden. */

int   gl_apid;

void  main(void)
{
   if ((gl_apid = appl_init())>=0)
   {
      ...
      AVInit(gl_apid,"ACCNAME ",1|2);
      if (MultiAES())
         "Warte, bis Status kommt oder Benutzer was will";
      else
      {
         "Tue eventuell selber was (Fenster îffnen o.Ñ.)"
         EventLoop();
      }
      ...
      appl_exit();
   }
}
#endif
#endif
