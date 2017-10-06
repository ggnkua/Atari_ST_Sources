/*
	Beispielprogramm zur Benutzung der Handler und anderer Features unter MAGIC.
	
	Orginalversion in Pure Pascal von Peter Hellinger.
	Portierung nach C von Dirk Stadler.
*/

#include <magic.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#ifdef SOZOBON
#include "magicdem/magicdem.h"
#else
#include "magicdem.h"
#endif

#define SMALLER   0x4000  /* MULTITOS >= 1.08 */

#define Bit6  0x0040
#define Bit7  0x0080
#define Bit8  0x0100
#define Bit9  0x0200
#define Bit10 0x0400
#define Bit11 0x0800
#define Bit12 0x1000
#define Bit13 0x2000
#define Bit14 0x4000
#define Bit15 0x8000
#define AlertString1 "[4|Alert-Demonstration|2|6||500]"\
                     "[%D3D-Effekte im Alert|"\
                     "%FFettgeschriebenes|"\
                     "%ISchrÑggestelltes|"\
                     "%UUnterstrichenes|"\
                     "Alles ist in Magic mîglich...||"\
                     "...Sogar bis zu 4 Buttons!]"\
                     "[ [Sicher | [Klar | [OK | [Abbruch ]"
#ifdef __PUREC__
#define AlertString2 "[2|Magic und Pure C|2|6][Programm beenden?][ [OK | [Abbruch ]"
#define AlertString3 "[2|Magic und Pure C|2][RSC-Datei nicht gefunden!!!][ [Abbruch ]"
#define Programm     "Pure C - Demo"
#else
#ifdef __GNUC__
#define AlertString2 "[2|Magic und GNU C|2|6][Programm beenden?][ [OK | [Abbruch ]"
#define AlertString3 "[2|Magic und GNU C|2][RSC-Datei nicht gefunden!!!][ [Abbruch ]"
#define Programm     "GNU C - Demo"
#else
#ifdef SOZOBON
#define AlertString2 "[2|Magic und SOZOBON C|2|6][Programm beenden?][ [OK | [Abbruch ]"
#define AlertString3 "[2|Magic und SOZOBON C|2][RSC-Datei nicht gefunden!!!][ [Abbruch ]"
#define Programm     "SOZOBON C - Demo"
long _STKSIZ = 8192L;
#else
#define AlertString2 "[2|Magic und C|2|6][Programm beenden?][ [OK | [Abbruch ]"
#define AlertString3 "[2|Magic und C|2][RSC-Datei nicht gefunden!!!][ [Abbruch ]"
#define Programm     "C - Demo"
#endif /* GNUC */
#endif /* PUREC */
#endif /* SOZOBON */

/* Globale Variablen */
int theWindow, theTimer;
int progende, imagecolor;
char name[30];
void   *rsc;
BITSET eff;
OBJECT *menu, *dial, *edit, *slid, *lbox, *buttbox, *strbox;
OBJECT *framebox, *bbox, *pop1, *pop2, *pop3, *colicon;
OBJECT *ibutt, *tbox, *rcard;

/* Prototypen */
#ifdef SOZOBON
#include "magicdem/prototyp.h"
#else
#include "prototyp.h"
#endif

extern void TheLines(void);
extern void Lines(void);

/*
	Ein Handler, der alle 20 ms eine Zeile in das Textfenster ausgibt.
	Die Ausgabe erfolgt ganz einfach mit WriteLine aus dem Modul mpTerminal.
	Ausgaben Åber mpTerminal berÅcksichtigen alles wichtige, wie z.B. die
	Rechteckliste des Fensters und geben nur in die sichtbaren Teile des
	Fensters aus, auch wenn dieses im Hintergrund liegt.  ZusÑtzlich
	hat man den Vorteil, daû man sich nicht um Redraw-Events kÅmmern
	muû, das macht mpTerminal von ganz alleine.
	Installation unter dem Eintrag 'Fensterauf' im MenÅhandler.
*/
void HandleTimer(PtrEP para)
{
	char s[11];
	int j;
	
	if (WinOpen(theWindow)) {
		CursorOn(theWindow);
		for (j=0; j<=9; j++)
		    s[j] = (char)toascii(RndInt(127-32) + 32);
		s[10] = '\0';
		WriteLine(theWindow, s);
	}
	/* Die Ausgabe erfolgt ganz einfach mit WriteLine aus dem Modul M_Terminal.
         * Ausgaben Åber M_Terminal berÅcksichtigen alles wichtige, wie zB. die 
         * Rechteckliste des Fensters und geben nur in die sichtbaren Teile des 
         * Fensters aus, auch wenn dieses im Hintergrund liegt.  ZusÑtzlich
         * hat man den Vorteil, daû man sich nicht um Redraw-Events kÅmmern
         * muû, das macht M_Terminal von ganz alleine.
        */
} /* HandleTimer */

/*
	Handler fÅr die Alertbox, die bei Programmende erscheint.
*/
void QuitAlert(PtrAlertpara ap)
{
	switch(ap->message) {
		case AlertClicked: 		
		    if (ap->objc == 1)
		       progende = -1;
	}
} /* QuitAlert */

/*
	Handler fÅr die Demo-Alertbox.
*/
void DemoAlert(PtrAlertpara ap)
{
	switch (ap->message) {
		case AlertTimer:
		    Cconout(7);
	}
} /* DemoAlert */

/*
	Setzt Flags der angewÑhlten Objekte.
*/
void SetBFlags(OBJECT *t, BITSET b, int _gem, int magic, int gback,
               int mback, BOOLEAN incl)
{
	if (incl) {
		if (_gem > 0) t[_gem].ob_flags = t[_gem].ob_flags | b;
		if (magic > 0) t[magic].ob_flags = t[magic].ob_flags | b;
	}
	else {
		if (_gem > 0) t[_gem].ob_flags = t[_gem].ob_flags & ~b;
		if (magic > 0) t[magic].ob_flags = t[magic].ob_flags & ~b;
	}
	
	if (_gem > 0) DialDraw(t, gback, 8, &ScreenRect);
	if (magic > 0) DialDraw(t, mback, 8, &ScreenRect);
} /* SetBFlags */


/*
	Setzt Status der angewÑhlten Objekte.
*/
void SetBState(OBJECT *t, BITSET b, int _gem, int magic, int gback,
               int mback, BOOLEAN incl)
{
	if (incl) {
		if (_gem > 0) t[_gem].ob_state = t[_gem].ob_state | b;
		if (magic > 0) t[magic].ob_state = t[magic].ob_state | b;
	}
	else {
		if (_gem > 0) t[_gem].ob_state = t[_gem].ob_state & ~b;
		if (magic > 0) t[magic].ob_state = t[magic].ob_state & ~b;
	}
	
	if (_gem > 0) DialDraw(t, gback, 8, &ScreenRect);
	if (magic > 0) DialDraw(t, mback, 8, &ScreenRect);
} /* SetBState */

/*
	Handler fÅr den Button-Dialog.
*/
void ButtonHandler(PtrDialpara dp)
{
	dp->action = aDefault;
	
	switch(dp->message) {
		case WinClosed:	
			dp->action = aClose;
		break;
		case ObjcClicked:
		case ObjcDblClicked:	
			if (dp->objc == Mb_ok)
				dp->action = aDeselect | aClose;
			else if (dp->objc == Mb_default)
				SetBFlags(dp->tree,DEFAULT,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mb_exit)
				SetBFlags(dp->tree,EXIT,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mb_radio)
				SetBFlags(dp->tree,RBUTTON,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mb_indicator) {
				if (dp->tree[dp->objc].ob_state & SELECTED) {
					dp->tree[Mb_gem].ob_flags = (dp->tree[Mb_gem].ob_flags | Bit9) & ~Bit10;
					dp->tree[Mb_magic].ob_flags = (dp->tree[Mb_magic].ob_flags | Bit14) & ~Bit15;
				}
				else {
					dp->tree[Mb_gem].ob_flags = (dp->tree[Mb_gem].ob_flags & ~Bit9) & ~Bit10;
					dp->tree[Mb_magic].ob_flags = dp->tree[Mb_magic].ob_flags & ~Bit14;
				}
				dp->list[0] = Mb_gback;
				dp->list[1] = 8;
				dp->list[2] = Mb_mback;
				dp->list[3] = 8;
				dp->list[4] = -1;
				dp->objc = Mb_activator;
				dp->action = aDeselect | aDraw | aDrawList;
			}
			else if (dp->objc == Mb_activator) {
				if (dp->tree[dp->objc].ob_state & SELECTED) {
					dp->tree[Mb_gem].ob_flags = (dp->tree[Mb_gem].ob_flags | Bit9) | Bit10;
					dp->tree[Mb_magic].ob_flags = (dp->tree[Mb_magic].ob_flags | Bit15) & ~Bit14;
				}
				else {
					dp->tree[Mb_gem].ob_flags = (dp->tree[Mb_gem].ob_flags & ~Bit9) & ~Bit10;
					dp->tree[Mb_magic].ob_flags = (dp->tree[Mb_magic].ob_flags & ~Bit15);
				}
				dp->list[0] = Mb_gback;
				dp->list[1] = 8;
				dp->list[2] = Mb_mback;
				dp->list[3] = 8;
				dp->list[4] = -1;
				dp->objc = Mb_indicator;
				dp->action = aDeselect | aDraw | aDrawList;
			}
			else if (dp->objc == Mb_selected)
				SetBState(dp->tree,SELECTED,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mb_crossed)
				SetBState(dp->tree,CROSSED,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);	
			else if (dp->objc == Mb_checked)
				SetBState(dp->tree,CHECKED,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mb_disabled)
				SetBState(dp->tree,DISABLED,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);	
			else if (dp->objc == Mb_outlined)
				SetBState(dp->tree,OUTLINED,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mb_shadowed)
				SetBState(dp->tree,SHADOWED,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mb_whitebak)
				SetBState(dp->tree,Bit6,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);	
			else if (dp->objc == Mb_draw3d)

				SetBState(dp->tree,Bit7,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mb_state8)
				SetBState(dp->tree,Bit8,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);		
			else if (dp->objc == Mb_state9)
				SetBState(dp->tree,Bit9,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mb_state10)
				SetBState(dp->tree,Bit10,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mb_state11)
				SetBState(dp->tree,Bit11,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mb_state12)
				SetBState(dp->tree,Bit12,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mb_state13)
				SetBState(dp->tree,Bit13,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mb_state14)
				SetBState(dp->tree,Bit14,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mb_state15)
				SetBState(dp->tree,Bit15,Mb_gem,Mb_magic,Mb_gback,Mb_mback,dp->tree[dp->objc].ob_state & SELECTED);		
			else {
				if (dp->tree[dp->objc].ob_state & SELECTED)
					dp->action = aDeselect | aDraw;
				else
					dp->action = aSelect | aDraw;
			}
	}
} /* ButtonHandler */

/*
	Handler fÅr den String-Dialog.
*/
void StringHandler(PtrDialpara dp)
{
	dp->action = aDefault;
	
	switch(dp->message) {
		case WinClosed:			
			dp->action = aClose;
		break;
		case ObjcClicked:
		case ObjcDblClicked:	
			if (dp->objc == Ms_ok)
				dp->action = aDeselect | aClose;
			else if (dp->objc == Ms_indicator) {
				if (dp->tree[dp->objc].ob_state & SELECTED) {
					dp->tree[Ms_gem].ob_flags = (dp->tree[Ms_gem].ob_flags | Bit9) & ~Bit10;
					dp->tree[Ms_magic].ob_flags = (dp->tree[Ms_magic].ob_flags | Bit14) & ~Bit15;
				}
				else {
					dp->tree[Ms_gem].ob_flags = (dp->tree[Ms_gem].ob_flags  | Bit9) & ~Bit10;
					dp->tree[Ms_magic].ob_flags = dp->tree[Ms_magic].ob_flags & ~Bit14;
				}
				dp->list[0] = Ms_gback;
				dp->list[1] = 8;
				dp->list[2] = Ms_mback;
				dp->list[3] = 8;
				dp->list[4] = -1;
				dp->objc = Ms_activator;
				dp->action = aDeselect | aDraw | aDrawList;
			}
			else if (dp->objc == Ms_activator) {
				if (dp->tree[dp->objc].ob_state & SELECTED) {
					dp->tree[Ms_gem].ob_flags = (dp->tree[Ms_gem].ob_flags | Bit9) | Bit10;
					dp->tree[Ms_magic].ob_flags = (dp->tree[Ms_magic].ob_flags | Bit15) & ~Bit14;
				}	
				else {
					dp->tree[Ms_gem].ob_flags = (dp->tree[Ms_gem].ob_flags | Bit9) | Bit10;
					dp->tree[Ms_magic].ob_flags = dp->tree[Ms_magic].ob_flags & ~Bit15;
				}
				dp->list[0] = Ms_gback;
				dp->list[1] = 8;
				dp->list[2] = Ms_mback;
				dp->list[3] = 8;
				dp->list[4] = -1;
				dp->objc = Ms_indicator;
				dp->action = aDeselect | aDraw | aDrawList;
			}
			else if (dp->objc == Ms_selected)
				SetBState(dp->tree,SELECTED,Ms_gem,Ms_magic,Ms_gback,Ms_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Ms_crossed)
				SetBState(dp->tree,CROSSED,Ms_gem,Ms_magic,Ms_gback,Ms_mback,dp->tree[dp->objc].ob_state & SELECTED);	
			else if (dp->objc == Ms_checked)
				SetBState(dp->tree,CHECKED,Ms_gem,Ms_magic,Ms_gback,Ms_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Ms_disabled)
				SetBState(dp->tree,DISABLED,Ms_gem,Ms_magic,Ms_gback,Ms_mback,dp->tree[dp->objc].ob_state & SELECTED);	
			else if (dp->objc == Ms_outlined)
				SetBState(dp->tree,OUTLINED,Ms_gem,Ms_magic,Ms_gback,Ms_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Ms_shadowed)
				SetBState(dp->tree,SHADOWED,Ms_gem,Ms_magic,Ms_gback,Ms_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Ms_whitebak)
				SetBState(dp->tree,Bit6,Ms_gem,Ms_magic,Ms_gback,Ms_mback,dp->tree[dp->objc].ob_state & SELECTED);	
			else if (dp->objc == Ms_draw3d)
				SetBState(dp->tree,Bit7,Ms_gem,Ms_magic,Ms_gback,Ms_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Ms_state8)
				SetBState(dp->tree,Bit8,Ms_gem,Ms_magic,Ms_gback,Ms_mback,dp->tree[dp->objc].ob_state & SELECTED);		
			else if (dp->objc == Ms_state9)
				SetBState(dp->tree,Bit9,Ms_gem,Ms_magic,Ms_gback,Ms_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Ms_state10)
				SetBState(dp->tree,Bit10,Ms_gem,Ms_magic,Ms_gback,Ms_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Ms_state11)
				SetBState(dp->tree,Bit11,Ms_gem,Ms_magic,Ms_gback,Ms_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Ms_state12)
				SetBState(dp->tree,Bit12,Ms_gem,Ms_magic,Ms_gback,Ms_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Ms_state13)
				SetBState(dp->tree,Bit13,Ms_gem,Ms_magic,Ms_gback,Ms_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Ms_state14)
				SetBState(dp->tree,Bit14,Ms_gem,Ms_magic,Ms_gback,Ms_mback,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Ms_state15)
				SetBState(dp->tree,Bit15,Ms_gem,Ms_magic,Ms_gback,Ms_mback,dp->tree[dp->objc].ob_state & SELECTED);		
			else {
				if (dp->tree[dp->objc].ob_state & SELECTED)
					dp->action = aDeselect | aDraw;
				else
					dp->action = aSelect | aDraw;
			}
	}
} /* StringHandler */

/*
	Handler fÅr den Frame-Dialog.
*/		
void FrameHandler(PtrDialpara dp)
{
	dp->action = aDefault;
	
	switch(dp->message) {
		case WinClosed:			
			dp->action = aClose;
		break;
		case ObjcClicked:
		case ObjcDblClicked:	
			if (dp->objc == Mf_ok)
				dp->action = aDeselect | aClose;
			else if (dp->objc == Mf_indicator) {
				if (dp->tree[dp->objc].ob_state & SELECTED)
					dp->tree[Mf_frame].ob_flags = (dp->tree[Mf_frame].ob_flags | Bit14) & ~Bit15;
				else
					dp->tree[Mf_frame].ob_flags = dp->tree[Mf_frame].ob_flags & ~Bit14;
				dp->list[0] = Mf_back;
				dp->list[1] = 8;
				dp->list[2] = -1;
				dp->objc = Mf_activator;
				dp->action = aDeselect | aDraw | aDrawList;
			}
			else if (dp->objc == Mf_activator) {
				if (dp->tree[dp->objc].ob_state & SELECTED)
					dp->tree[Mf_frame].ob_flags = (dp->tree[Mf_frame].ob_flags | Bit15) & ~Bit14;
				else
					dp->tree[Mf_frame].ob_flags = dp->tree[Mf_frame].ob_flags & ~Bit15;
				dp->list[0] = Mf_back;
				dp->list[1] = 8;
				dp->list[2] = -1;
				dp->objc = Mf_indicator;
				dp->action = aDeselect | aDraw | aDrawList;
			}
			else if (dp->objc == Mf_selected)
				SetBState(dp->tree,SELECTED,-1,Mf_frame,-1,Mf_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mf_crossed)
				SetBState(dp->tree,CROSSED,-1,Mf_frame,-1,Mf_back,dp->tree[dp->objc].ob_state & SELECTED);	
			else if (dp->objc == Mf_checked)
				SetBState(dp->tree,CHECKED,-1,Mf_frame,-1,Mf_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mf_disabled)
				SetBState(dp->tree,DISABLED,-1,Mf_frame,-1,Mf_back,dp->tree[dp->objc].ob_state & SELECTED);	
			else if (dp->objc == Mf_outlined)
				SetBState(dp->tree,OUTLINED,-1,Mf_frame,-1,Mf_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mf_shadowed)
				SetBState(dp->tree,SHADOWED,-1,Mf_frame,-1,Mf_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mf_whitebak)
				SetBState(dp->tree,Bit6,-1,Mf_frame,-1,Mf_back,dp->tree[dp->objc].ob_state & SELECTED);	
			else if (dp->objc == Mf_draw3d)
				SetBState(dp->tree,Bit7,-1,Mf_frame,-1,Mf_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mf_state8)
				SetBState(dp->tree,Bit8,-1,Mf_frame,-1,Mf_back,dp->tree[dp->objc].ob_state & SELECTED);		
			else if (dp->objc == Mf_state9)
				SetBState(dp->tree,Bit9,-1,Mf_frame,-1,Mf_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mf_state10)
				SetBState(dp->tree,Bit10,-1,Mf_frame,-1,Mf_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mf_state11)
				SetBState(dp->tree,Bit11,-1,Mf_frame,-1,Mf_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mf_state12)
				SetBState(dp->tree,Bit12,-1,Mf_frame,-1,Mf_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mf_state13)
				SetBState(dp->tree,Bit13,-1,Mf_frame,-1,Mf_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mf_state14)
				SetBState(dp->tree,Bit14,-1,Mf_frame,-1,Mf_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mf_state15)
				SetBState(dp->tree,Bit15,-1,Mf_frame,-1,Mf_back,dp->tree[dp->objc].ob_state & SELECTED);		
			else {
				if (dp->tree[dp->objc].ob_state & SELECTED)
					dp->action = aDeselect | aDraw;
				else
					dp->action = aSelect | aDraw;
			}
	}
} /* FrameHandler */

/*
	Handler fÅr den Boxen-Dialog.
*/
void BoxHandler(PtrDialpara dp)
{
	dp->action = aDefault;
	
	switch(dp->message) {
		case WinClosed:			
			dp->action = aClose;
		break;
		case ObjcClicked:
		case ObjcDblClicked:	
			if (dp->objc == Mx_ok)
				dp->action = aDeselect | aClose;
			else if (dp->objc == Mx_indicator) {
				if (dp->tree[dp->objc].ob_state & SELECTED)
					dp->tree[Mx_box].ob_flags = (dp->tree[Mx_box].ob_flags | Bit14) & ~Bit15;
				else
					dp->tree[Mx_box].ob_flags = dp->tree[Mx_box].ob_flags & ~Bit14;
				dp->list[0] = Mx_back;
				dp->list[1] = 8;
				dp->list[2] = -1;
				dp->objc = Mx_activator;
				dp->action = aDeselect | aDraw | aDrawList;
			}
			else if (dp->objc == Mx_activator) {
				if (dp->tree[dp->objc].ob_state & SELECTED)
					dp->tree[Mx_box].ob_flags = (dp->tree[Mx_box].ob_flags | Bit15) & ~Bit14;
				else
					dp->tree[Mx_box].ob_flags = dp->tree[Mx_box].ob_flags & ~Bit15;
				dp->list[0] = Mx_back;
				dp->list[1] = 8;
				dp->list[2] = -1;
				dp->objc = Mx_indicator;
				dp->action = aDeselect | aDraw | aDrawList;
			}
			else if (dp->objc == Mx_selected)
				SetBState(dp->tree,SELECTED,-1,Mx_box,-1,Mx_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mx_crossed)
				SetBState(dp->tree,CROSSED,-1,Mx_box,-1,Mx_back,dp->tree[dp->objc].ob_state & SELECTED);	
			else if (dp->objc == Mx_checked)
				SetBState(dp->tree,CHECKED,-1,Mx_box,-1,Mx_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mx_disabled)
				SetBState(dp->tree,DISABLED,-1,Mx_box,-1,Mx_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mx_outlined)
				SetBState(dp->tree,OUTLINED,-1,Mx_box,-1,Mx_back,dp->tree[dp->objc].ob_state & SELECTED);	
			else if (dp->objc == Mx_shadowed)
				SetBState(dp->tree,SHADOWED,-1,Mx_box,-1,Mx_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mx_whitebak)
				SetBState(dp->tree,Bit6,-1,Mx_box,-1,Mx_back,dp->tree[dp->objc].ob_state & SELECTED);	
			else if (dp->objc == Mx_draw3d)
				SetBState(dp->tree,Bit7,-1,Mx_box,-1,Mx_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mx_state8)
				SetBState(dp->tree,Bit8,-1,Mx_box,-1,Mx_back,dp->tree[dp->objc].ob_state & SELECTED);		
			else if (dp->objc == Mx_state9)
				SetBState(dp->tree,Bit9,-1,Mx_box,-1,Mx_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mx_state10)
				SetBState(dp->tree,Bit10,-1,Mx_box,-1,Mx_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mx_state11)
				SetBState(dp->tree,Bit11,-1,Mx_box,-1,Mx_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mx_state12)
				SetBState(dp->tree,Bit12,-1,Mx_box,-1,Mx_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mx_state13)
				SetBState(dp->tree,Bit13,-1,Mx_box,-1,Mx_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mx_state14)
				SetBState(dp->tree,Bit14,-1,Mx_box,-1,Mx_back,dp->tree[dp->objc].ob_state & SELECTED);
			else if (dp->objc == Mx_state15)
				SetBState(dp->tree,Bit15,-1,Mx_box,-1,Mx_back,dp->tree[dp->objc].ob_state & SELECTED);		
			else {
				if (dp->tree[dp->objc].ob_state & SELECTED)
					dp->action = aDeselect | aDraw;
				else
					dp->action = aSelect | aDraw;
			}
	}
} /* BoxHandler */

/*  
	Handler fÅr die Toolbxen
*/
void ToolboxHandler(PtrDialpara dp)
{
	dp->action = aDefault; 
	
	switch (dp->message) {
		case ObjcClicked:
		case ObjcDblClicked:
			if (dp->objc == Tb1) {
				if (InState(dp->tree, dp->objc, SELECTED))
					eff |= Fat;
				else
					eff &= ~Fat;
				SetAttribut(theWindow, eff);
			}
			else if (dp->objc == Tb2) {
				if (InState(dp->tree, dp->objc, SELECTED))
					eff |= Italic;
				else
					eff &= ~Italic;
				SetAttribut(theWindow, eff);
			}
			else if (dp->objc == Tb3) {
				if (InState(dp->tree, dp->objc, SELECTED))
					eff |= Underline;
				else
					eff &= ~Underline;
				SetAttribut(theWindow, eff);
			}
			else if (dp->objc == Tbtcol)
				DropNext(dp->tree, Tbtf);
			else if (dp->objc == Tbhcol)			
				DropNext(dp->tree, Tbhf);
		break;
		case ObjcDroped:
			if (dp->objc == Tbtf) 
				ForegroundColor(theWindow, dp->spec.g_x);
			else if (dp->objc == Tbhf)
				BackgroundColor(theWindow, dp->spec.g_x);
		break;
	}
}

/*
	Handler fÅr die Dialogboxen.
*/
void DialHandle(PtrDialpara dp)
{
	char *cstr;
	
	dp->action = aDefault;
	
	if (dp->tree == dial) {
		switch (dp->message) {
			case WinClosed:			
				dp->action = aClose;
			break;
			case ObjcClicked:
			case ObjcDblClicked:    
				if (dp->objc == Moremagic)
					CallMagic(99);
				dp->action = aDeselect | aClose;
			break;
			case ObjcTimer:			
				imagecolor++;
				if (imagecolor == DefaultWS.DefColors)
					imagecolor = 0;
				SetObjcColor(dp->tree, Magiclogo, imagecolor, -1, -1, -1);
				dp->objc = Magiclogo;
				dp->action = aDraw;
			break;
		}
	}
	else if (dp->tree == edit) {
		switch (dp->message) {
			case WinClosed:			
				dp->action = aClose;
			break;
			case ObjcClicked:
			case ObjcDblClicked:
				if (dp->objc == Editok)
					dp->action = aDeselect | aClose;
			break;
			case ObjcGotCursor:	
			break;
			case ObjcLostCursor:
			break;
			case ObjcEditkey:
				dp->action = aAsterik;
		}
		if (dp->window > 0) Cconout(7);
	}
	else if (dp->tree == slid) {
		switch (dp->message) {
			case WinClosed:			
				dp->action = aClose;
			break;
			case ObjcClicked:
			case ObjcDblClicked:
				if (dp->objc == Sliderok)
					dp->action = aDeselect | aClose;
			break;
			case ObjcSlided:
				dp->spec.g_x = dp->spec.g_w;
				dp->action = aSlider | aDrawSlider;
			break;
			case ObjcPgLeft:		
				dp->spec.g_x -= 100;
				dp->action = aSlider | aDrawSlider;
			break;
			case ObjcPgRight:
				dp->spec.g_x += 100;
				dp->action = aSlider | aDrawSlider;
			break;
			case ObjcArLeft:
				dp->spec.g_x -= 10;
				dp->action = aSlider | aDrawSlider;
			break;
			case ObjcArRight:
				dp->spec.g_x += 10;
				dp->action = aSlider | aDrawSlider;
		}
	}
	else if (dp->tree == lbox) {
		switch (dp->message) {
			case WinClosed:		
				dp->action = aClose;
			break;
			case ObjcClicked:
			case ObjcDblClicked:
				if (dp->objc == Deselect) {
					SelectAll(dp->tree, Listbox1, 0, SELECTED, FALSE);
					RedrawListbox(lbox, Listbox1, -1);
					dp->action = aDeselect | aDraw;
				}
				else if (dp->objc == Listboxok)
					dp->action = aDeselect | aClose;
				else if (dp->objc == Checkmode) {
					if (lbox[Checkmode].ob_state & SELECTED)
						SetListboxMode (lbox, Listbox1, CheckMulti);
					else
						SetListboxMode (lbox, Listbox1, SelectMulti);
					RedrawListbox(lbox, Listbox1, -1);
				}
			break;
			case ObjcEdited:
				SelectAll(dp->tree, Listbox1, 0, SELECTED, FALSE);
				cstr = ObjcStringAdr(dp->tree, Searchinput);
				SelectMatching(dp->tree, Listbox1, 0, cstr, SELECTED, TRUE, TRUE);
				RedrawListbox(lbox, Listbox1, FindSelected(dp->tree, Listbox1, 0));
			break;
			case OutsideClick:
				Cconout(7);
		}
	}
	else if (dp->tree == colicon) {
		switch (dp->message) {
			case WinClosed:	
				dp->action = aClose;
			break;
			case ObjcClicked:
			case ObjcDblClicked:
				if (dp->objc == Colorok)
					dp->action = aDeselect | aClose;
		}
	}
	else if (dp->tree == ibutt) {
		switch (dp->message) {
			case WinClosed:	
				dp->action = aClose;
			break;
			case ObjcClicked:
			case ObjcDblClicked:
				if (dp->objc == Ibuttok)
					dp->action = aDeselect | aClose;
		}
	}
	else if (dp->tree == rcard) {
		switch (dp->message) {
			case WinClosed:	
				dp->action = aClose;
			break;
			case ObjcClicked:
			case ObjcDblClicked:
				if (dp->objc == Rcbutton)
					dp->action = aDeselect | aClose;
		}
	}
} /* DialHandler */

/*
	Handler fÅr das Textfenster.
*/
void WinHandler(PtrWinPara w)
{
	w->action = wDefault;
	
	switch (w->message) {
		case WinClicked:
			WriteLine(theWindow, "Mausclick gekriegt!");
			WriteLn(theWindow);
			w->action = wBell;
		break;
		case WinRedraw:
		break;
		case WinTopped:
			w->action = wTopped;
		break;
		case WinClosed:
			RemoveMUTIMER(theTimer);
			menu[Fensterzu].ob_state = DISABLED;
			menu[Fensterauf].ob_state = NORMAL;
			w->action = wClose;
		break;
		case WinFulled:
			w->extended[0] =  150;
			w->extended[1] =    1;		
	 		w->extended[2] =   -1;
			w->extended[3] = 1500;
			w->extended[4] =  300;
			w->extended[5] =   -1;
			w->action = wFulled | wVSUpdate | wHSUpdate;
		break;
		case WinSized:
			w->extended[0] =  150;
			w->extended[1] =    1;		
	 		w->extended[2] =   -1;
			w->extended[3] = 1500;
			w->extended[4] =  300;
			w->extended[5] =   -1;
			w->action = wSized | wVSUpdate | wHSUpdate;
		break;
		case WinMoved:
			w->action = wMoved;
		break;
		case WinBottomed:
			w->action = wBottomed;
		break;
		case WinChangefont:
			w->action = wChangeFont;
		break;
		case WinIconify:
			SetWinIcon(w->window,GetObjcspec(colicon,Coloricon)->ciconblk);
			w->action = wIconify;
		break;
		case WinAlliconify:
			w->action = wAllIconify;
		break;
		case WinUniconify:
			w->action = wUnIconify;
	}
} /* WinHandler */

/*
	Routine îffnet Textfenster mit allem drum und dran.
*/
void OpenWin(char *wname, char *winfo, BOOLEAN mn)
{
	OBJECT *x;
	BITSET f, f2;
	WinTreeList tl;
	
	if (!mn) {
		f = MOVER | NAME | INFO | CLOSER | SIZER | FULLER | VSLIDE | HSLIDE;
		f2 = 0;
		x = NULL;
	}			
	else {
		f = MOVER | NAME | INFO | CLOSER | SIZER | FULLER | VSLIDE | HSLIDE | SMALLER;
		f2 = WinMenu | WinMultiRsc;
		x = menu;
	}
	
	tl[0].tree = x;
	tl[0].xpos = 0;
	tl[0].ypos = 0;
	tl[0].mode = tbMenu;
	
	tl[1].tree = tbox;
	tl[1].xpos = 0;
	tl[1].ypos = tbox[0].ob_height;
	tl[1].mode = tbDown;
	
	tl[2].tree = NULL;
	
	theWindow = OpenTextwindow( WinHandler,		/* unsere Handleprozedur */
								f, f2,			/* diese Fensterelemente wollen wir */
								-1, -1,			/* XY-Position des Fensters */
								300, 150,		/* Breite und Hîhe des Fensters */
								0, 0, 0, 0,		/* Rand-Offsets */
								0, 1,			/* Farben */
								100, 10,		/* Font, Grîsse */
								0,				/* Effekte */
								75,				/* Wrap-Position */
								wname,			/* Titelzeile */
								winfo,			/* Infozeile */
								(void *)tl );	/* eventuelle Resource */
	progende++;
} /* OpenWin */

/*
	Handler fÅr das MenÅ.
*/
void HandleMenu (PtrMenupara mp)
{
	int i, win, item, button;
	BOOLEAN open;
	Dialmode mode;
	OBJECT *pop;
	char p[128], n[128];
	
	mp->action = mDefault;
	
	switch (mp->entry) {
		case Infodial:
			OpenDial(dial, dNonmodal, dDefault, -1, -1, -1, -1, -1, -1, "");
		break;
  		case Buttons:
  			OpenDial(buttbox, dNonmodal, dDefault, -1, -1, -1, -1, -1, -1, "");
  		break;
  		case Strings:
  			OpenDial(strbox, dNonmodal, dDefault, 1, -1, -1, -1, -1, -1, "");
  		break;
  		case Boxes:
  			OpenDial(bbox, dNonmodal, dDefault, 1, -1, -1, -1, -1, -1, "Schnabbeldu");
  		break;
  		case Editfeld:
  			OpenDial(edit, dNonmodal, dInfo | dAllkeys, 1, -1, -1, -1, -1, -1, "");
            DialInfo(edit, &mode, &win, &open);
            SetWinInfo(win, "Hallo du kleines Editfeld!!!");
        break;
  		case Slider:
  			OpenDial(slid, dNonmodal, dDefault, -1, -1, -1, -1, -1, -1, "Schieberdemo");
  		break;
  		case Listboxen:
  			OpenDial(lbox, dNonmodal, dDefault, 0, 0, -1, -1, -1, -1, "");
  		break;
  		case Frameboxen:
  			OpenDial(framebox, dNonmodal, dDefault, -1, -1, -1, -1, -1, -1, "");
  		break;
  		case Coloricons:
  			OpenDial(colicon, dNonmodal, dDefault, -1, -1, -1, -1, -1, -1, "");
  		break;
  		case Ibutton:
  			OpenDial(ibutt, dNonmodal, dDefault, -1, -1, -1, -1, -1, -1, "");
  		break;
  		case Rcards:
  			OpenDial(rcard, dNonmodal, dDefault, -1, -1, -1, -1, -1, -1, "");
  		break;
 		case Popups:
 			Popup(pop1, -1, -1, 0, &pop, &item);
            if (pop == pop1) {
            	WriteLine(theWindow, "Tree: pop1 Item: ");
                WriteInt(theWindow, item, 0);
			}
            else if (pop == pop2) {
            	WriteLine(theWindow, "Tree: pop2 Item: ");
            	WriteInt(theWindow, item, 0);
            }
            else if (pop == pop3) {
            	WriteLine(theWindow, "Tree: pop3 Item: ");
            	WriteInt(theWindow, item, 0);
           	}
            else
            	WriteLine(theWindow, "Undefined...");
			WriteLn(theWindow);
		break;
  		case Linesdemo:
  			TheLines();
  		break;
  		case Quit:
  			WindowAlert(-1, -1, 1, AlertString2, QuitAlert);
  		break;
  		case Runprogram: 	
  			/* Quick and Dirty */
            n[0]= '\0';
            if (fsel_input(p, n, &button)) {
            	i = (int)strlen(p) - 1;
                while (p[i] != '\\') {
                	p[i] = '\0';
                	i--;
             	}
             	strcat(p, n);
             	Pexec (0, p, "", NULL);
             }
        break;
  		case Selectfont:
  			SampleSentence("Magic 4.00, besser denn je!");
  			TermfontSelector ("Terminal-Font auswÑhlen", fsNonmodal | fsOwntext);
  		break;
  		case Fensterauf:
  			if (theWindow < 0) {
            	sprintf(name,"%3d <- Applikationsnummer!",ApplIdent);
                OpenWin (" Textfenster ", name, TRUE);
                WrapOn (theWindow);
                theTimer = InstMUTIMER (HandleTimer, 2L); /* Timer-Event anmelden. Alle 2ms */
             }
             else {
               	theTimer = InstMUTIMER (HandleTimer, 2L); /* Timer-Event anmelden. Alle 2ms */
                ReopenWin(theWindow);
             }
             mp->spec.g_x = Fensterauf;
             mp->spec.g_y = Fensterzu;
             mp->action = mSwapDisabled;
        break;
  		case Fensterzu:  	
  			RemoveMUTIMER(theTimer);
  			TempCloseWin(theWindow);
            mp->spec.g_x = Fensterauf;
            mp->spec.g_y = Fensterzu;
            mp->action = mSwapDisabled;
      	break;
  		case Alertbox:
  			SetIconslot(6, GetObjcspec(colicon, Coloricon)->ciconblk);
  			WindowAlert(-1, -1, 3, AlertString1, DemoAlert);
		}
} /* HandleMenu */

/*
	Routine fÅllt List- und Dropboxen mit Dummy-EintrÑgen.
*/
void FillDrop()
{
	int i, j;
	char s[22];
	
	for(i=0; i<=100; i++) {
		MouseRotor();
		sprintf(s,"%4d Dropboxeintrag",i);
		AddEntry(lbox, Dropbox1, 0, NULL, s);
	}
	SetDropboxElement(lbox, Dropbox1, 0, FALSE);

	for(i=0; i<=100; i++) {
		MouseRotor();
		s[21] = '\0';
		for(j=0; j<21; j++)
			s[j] = (char)(RndInt(96)+32);	
		AddEntry(lbox, Listbox1, 0, NULL, s);
	}
	
	for(i=0; i<=50; i++) {
		MouseRotor();
		sprintf(s,"%4d Listboxeintrag",i);
		AddEntry(lbox, Listbox2, 0, NULL, s);
	}
	InsertEntry(lbox, Listbox2, 50, 0, NULL, "InsertEntry");
	ChangeEntry(lbox, Listbox2, 25, 0, NULL, "ChangeEntry");
	SelectEntry(lbox, Listbox2, 3, SELECTED, TRUE);	
} /* FillDrop */

void AddList(OBJECT *t, int list, int sel)
{
	AddEntry(t, list, 0, NULL, "Weiss");
	AddEntry(t, list, 0, NULL, "Schwarz");
	if (DefaultWS.DefColors > 2) {
		AddEntry(t, list, 0, NULL, "Rot");
		AddEntry(t, list, 0, NULL, "GrÅn");
		if (DefaultWS.DefColors > 4) {
			AddEntry(t, list, 0, NULL, "Blau");
			AddEntry(t, list, 0, NULL, "Cyan");
			AddEntry(t, list, 0, NULL, "Gelb");
			AddEntry(t, list, 0, NULL, "Magenta");
			AddEntry(t, list, 0, NULL, "Grau");
			AddEntry(t, list, 0, NULL, "Dunkelgrau");
			AddEntry(t, list, 0, NULL, "Dunkelrot");
			AddEntry(t, list, 0, NULL, "DunkelgrÅn");
			AddEntry(t, list, 0, NULL, "Dunkelblau");
			AddEntry(t, list, 0, NULL, "Dunkelcyan");
			AddEntry(t, list, 0, NULL, "Dunkelgelb");
			AddEntry(t, list, 0, NULL, "Dunkelmagenta");
		}
	}
	SetDropboxElement(t, list, sel, FALSE);
} /* AddList */
	
/*
	Hauptprogramm
*/
void main()
{
	int term;
	
	char MagicVersion[30];
	char DialString[30];
	
	term = -1;
	imagecolor = 1;
	eff = 0;
	
	/* Initialisierung */
	ApplInit();
	ProgName(Programm);
	
	/* Abspanndialog aus */
	Appl->MAGICParaBlk->IntIn[0] = 1;
	CallMagic(98);
	
	/* Maus an */
	MouseOn();	
	
	/* RSC-Datei laden */	
    if (LoadRsc("MAGICDEM.RSC",&rsc)) {

    	/* Adressen der Rsc-Objekte ermitteln */
    	
    	menu = GaddrRsc(rsc, R_TREE, Menutree);
    	InitMenuline(menu, HandleMenu, TRUE);
    	InstallDeskMenu(menu);
    	
    	dial = GaddrRsc(rsc, R_TREE, Infodialog);
    	MagicVerString(MagicVersion);
    	sprintf(DialString,"Magic %s",MagicVersion);
    	SetObjcStringAdr(dial, Release, DialString);
    	
    	edit = GaddrRsc(rsc, R_TREE, Editdialog);
    	slid = GaddrRsc(rsc, R_TREE, Sliderdialog);
    	lbox = GaddrRsc(rsc, R_TREE, Listboxdialog);
    	buttbox = GaddrRsc(rsc, R_TREE, Magicbuttons);
    	strbox = GaddrRsc(rsc, R_TREE, Magicstrings);
    	framebox = GaddrRsc(rsc, R_TREE, Magicframes);
    	bbox = GaddrRsc(rsc, R_TREE, Magicboxes);
    	colicon = GaddrRsc(rsc, R_TREE, Farbicons);
    	pop1 = GaddrRsc(rsc, R_TREE, Popupdial);
    	pop2 = GaddrRsc(rsc, R_TREE, Subpop1);
    	pop3 = GaddrRsc(rsc, R_TREE, Subpop2);
    	ibutt = GaddrRsc(rsc, R_TREE, Iconbutton);
    	tbox = GaddrRsc(rsc, R_TREE, Toolbox);
    	rcard = GaddrRsc(rsc, R_TREE, Register);
    	
    	/* PopupmenÅ zusammenkleben */
    	AttachPopup(pop1, pop2, 5);
    	AttachPopup(pop1, pop3, 7);
    	AttachPopup(pop2, pop3, 3);
    	
    	/* Dialogboxen den Handlern zuweisen */
    	NewDial(dial, DialHandle);
    	NewDial(edit, DialHandle);
    	NewDial(slid, DialHandle);
    	NewDial(lbox, DialHandle);
    	NewDial(buttbox, ButtonHandler);
    	NewDial(strbox, StringHandler);
    	NewDial(framebox, FrameHandler);
    	NewDial(bbox,BoxHandler);
    	NewDial(colicon, DialHandle);
		NewDial(ibutt, DialHandle);
		NewDial(tbox, ToolboxHandler);
		NewDial(rcard, DialHandle);
		
		/* Listboxen  und Toolbox mit Tasten belegen */
		SetUserkey(lbox, Sliderup, F1, TRUE, TRUE);
		SetUserkey(lbox, Sliderup, ShF1, TRUE, TRUE);
		SetUserkey(lbox, Sliderup, CtrlF1, TRUE, TRUE);
		SetUserkey(lbox, Sliderdown, F2, TRUE, TRUE);
		SetUserkey(lbox, Sliderdown, ShF2, TRUE, TRUE);
		SetUserkey(lbox, Sliderdown, CtrlF2, TRUE, TRUE);
		SetUserkey(lbox, Slup, F3, TRUE, TRUE);
		SetUserkey(lbox, Slup, ShF3, TRUE, TRUE);
		SetUserkey(lbox, Slup, CtrlF3, TRUE, TRUE);
		SetUserkey(lbox, Sldown, F4, TRUE, TRUE);
		SetUserkey(lbox, Sldown, ShF4, TRUE, TRUE);
		SetUserkey(lbox, Sldown, CtrlF4, TRUE, TRUE);
		SetUserkey(tbox, Tb1, AltF, TRUE, TRUE);
		SetUserkey(tbox, Tb2, AltI, TRUE, TRUE);
		SetUserkey(tbox, Tb3, AltU, TRUE, TRUE);
		
		/* Slider setzen */
		SetSlider(slid, VSlider, 0, 100);
		SetSlider(slid, HSlider, 0, 100);
		
		AddList(tbox, Tbtf, 1);
		AddList(tbox, Tbhf, 0);
		
		/* List- u. Dropboxen auffÅllen */
		FillDrop();
		
		/* MAGIC-Meldung ausgeben */
		CallMagic(99);
		
		/* Maus als Pfeil */
		MouseArrow();
		
		/* Initialisierung einiger Variablen */
		theWindow = -1;
		Lines();
		progende = 1;
		
		/* Dispatcher-Endlosschleife */
		while (progende >= 1)
			CentralDispatcher();
			
		term = 0;
	}
	else
		/* keine RSC-Datei gefunden */
		Alert(-1, -1, 1, AlertString3);
	
	/* Und TschÅss */	
	ApplTerm(term);
} /* main */		
