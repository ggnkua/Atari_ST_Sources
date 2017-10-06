/* 
	Beispiel fÅr einen einfachen Windowhandler unter MAGIC.
	Das Programm îffnet drei Fenster und macht sonst nichts.
   
	Orginalversion in Pure Pascal von Peter Hellinger.
	Portierung nach C von Dirk Stadler.
*/
  
#include <magic.h>
#include <stddef.h>
#include <stdio.h>

#define SMALLER   0x4000  /* MULTITOS >= 1.08 */

/* Globale Variablen */
int FirstWin, SecondWin, ThirdWin;
int ProgEnde;

/* Prototypen */
int OpenWin( char *wname, char *winfo,
             int  xPos, int yPos,
             int  Breite, int Hoehe,
             int  wrap  );

/* 
	Der Windowhandler:
	Im Prinzip wird alles von MAGIC geregelt.
	Man muû nur die Aktionen an MAGIC in der 
	Variablen 'action' zÅruckmelden.
*/
void WinHandler(PtrWinPara w)
{
    w->action = wDefault;
    
    switch (w->message) {
        case WinRedraw:		break;
        case WinTopped: 	w->action = wTopped;
        					break;
        case WinClosed: 	w->action = wClose;
                        	ProgEnde--;
                        	break;
        case WinFulled:   	w->action = wFulled;
        					break;
        case WinSized:    	w->action = wSized;
        					break;
        case WinMoved:    	w->action = wMoved;
        					break;
        case WinBottomed: 	w->action = wBottomed;
        					break;
        case WinIconify:    SetIcontext(w->window, "SCHRUMPF");
                       		w->action = wIconify;
                      		break;
        case WinUniconify: 	w->action = wUnIconify;
	}
} /* WinHandler */


/* 
	Die Routine îffnet ein Texfenster mit allem was dazugehîrt. 
*/
int OpenWin( char *wname, char *winfo,
             int  xPos, int yPos,
             int  Breite, int Hoehe,
             int  wrap  )
{
	OBJECT *x;
	BITSET f;

	f = MOVER | NAME | CLOSER | FULLER | INFO | SIZER | SMALLER;
   	x = NULL;
	
	ProgEnde++;
	
    return(OpenTextwindow ( WinHandler,
                            f, 0,
                            xPos, yPos,
                            Breite, Hoehe,
                            0, 0, 0, 0,     /* Offsets */
                            0, 1,           /* Farben */
                            100, 10,        /* Font,Grîûe */
                            0,              /* Effekte */
                            wrap,           /* Umbruch */
                            wname,          /* Titel */
                            winfo,          /* Infozeile */
                            x ));           /* Ressource */
} /* OpenWin */

/* 
	Das Hauptprogramm îffnet drei Fenster und ruft dann in einer Endlosschleife
   	solange den Dispatcher auf bis alle Fenster geschlossen sind.
*/
void main()
{

	char name[30];

	ApplInit();
	
    MouseOn();
    MouseArrow();

    ProgEnde = 0;
	
	sprintf(name,"%3d <- Applikationsnummer!",ApplIdent);
	
    FirstWin = OpenWin(" Hello World 1 ", name, 100, 100, 250, 150, 50);
    WriteLine(FirstWin, "Hello World");

    SecondWin = OpenWin(" Hello World 2 ", name, 400, 300, 200, 100, 50);
    WriteLine(SecondWin, "Hello World");

    ThirdWin = OpenWin(" Hello World 3 ", name, 200, 150, 200, 100, 50);
    WriteLine (ThirdWin, "Hello World");

    while (ProgEnde >= 1)
        CentralDispatcher();

    ApplTerm(0);
} /* main */
