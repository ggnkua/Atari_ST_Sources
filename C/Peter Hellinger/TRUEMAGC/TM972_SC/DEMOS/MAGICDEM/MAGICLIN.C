/* Atari Demo: Bouncing lines */

/* --------------------------------------------------------------- *
 * (c) Copyright Modula 2 Software Ltd 1986.  All rights reserved. *
 * --------------------------------------------------------------- *
 * (c) Copyright TDI Software Inc 1985, 1986. All rights reserved. *
 * --------------------------------------------------------------- *
 *         Portiert auf MAGICLIB by Peter Hellinger  06.01.91      *
 * --------------------------------------------------------------- *
 *   Portiert nach Pascal, angepasst an Magic 4.00   04.08.93/Hp   *
 * --------------------------------------------------------------- *
 *   Portiert nach C                           4/94 Dirk Stadler   *
 * ----------------------------------------------------------------*/

#include <magic.h>
#include <stddef.h>
#include <string.h>

#ifdef SOZOBON
#include "magicdem/magicdem.h"
#else
#include "magicdem.h"
#endif

#define maxLines  30
#define SMALLER   0x4000  /* MULTITOS >= 1.08 */
 
typedef int LineDescr[4];

/* Globale Variablen */
int GraphWin, TimerId;
int maxX, maxY, min;
int t, i, new, old, ii, color, colcount;
int fback;
GRECT r;
LineDescr Ball, Vel, max;
LineDescr _Lines[maxLines];

extern OBJECT *colicon;

void TheLines(void);

/* 
	Zeichnet Linien.
*/
void DrawLines()
{
	if (new >= maxLines) {        
		/* L”sche alte Linie */
		vsl_color(DefaultWS.Handle, fback);
		v_pline(DefaultWS.Handle, 2, _Lines[old % maxLines]);
		old++;
	}
	/* Zeichne neue Linie */
	for (i=0; i<=3; i++)
		_Lines[new % maxLines][i] = Ball[i];
	new++;
	vsl_color(DefaultWS.Handle, color);
	v_pline(DefaultWS.Handle, 2, Ball); 	
} /* DrawLines */

/* 
	Timerhandler, der alle 10 ms Linien ausgibt. 
*/
void LinesTimer()
{
	int i;
	
	if (GraphWin > 0) {
		if (!WinIconified(GraphWin)) {
			for (i=0; i<=3; i++) {
				t = Ball[i] + Vel[i];
				if (t >= max[i]) {
					t = max[i] * 2 - Vel[i] - Ball[i];
					Vel[i] *= -1;
				}
				if (!(i % 2))
					min = r.g_y;
				else
					min = r.g_x;
				if (t < min) {
					if (t < 0)
						t = -t;
					else
						t = min;
					Vel[i] = -Vel[i];
				}
				Ball[i] = t;
			}
			
			/* Linien ausgeben */
			RewriteWindow(GraphWin, DefaultWS.Handle, DrawLines);
			colcount++;
			if (colcount > 10) {
				color++;
				if (color >= DefaultWS.DefColors)
					color = 0;
				if (color == fback)
					color++;
				colcount = 0;
			}
		}
	}
} /* LinesTimer */

/*
	Der Fensterhandler fr das Graphikfenster.
*/
void LinesWinHandler(PtrWinPara w)
{
	w->action = wDefault;  /* Erstmal nicht reagieren */
	
	switch (w->message) {
		case WinRedraw:		
			TheLines();
		break;
		case WinTopped:
			w->action = wTopped;
		break;
		case WinClosed:
			GraphWin = -1;
			RemoveMUTIMER(TimerId);
			w->action = wClose;
		break;
		case WinFulled:
			TheLines();
			w->action = wFulled;
		break;
		case WinSized:
			TheLines();
			w->action = wSized;
		break;
		case WinMoved:
			SetWinPos(GraphWin, w->spec.g_x, w->spec.g_y);
			TheLines();
		break;
		case WinBottomed:
			w->action = wBottomed;
		break;
		case WinIconify:
			w->action = wIconify;
		break;
		case WinAlliconify:
			w->action = wAllIconify;
		break;
		case WinUniconify:
			w->action = wUnIconify;
	}
} /* LinesWinHandler */

/* 
	Normales Fenster ”ffnen und Timerhandler installieren. 
*/
void TheLines()
{
	int i;
	WinTreeList tl;
	char x[12];
	
	if (GraphWin < 0) {
		strcpy(x," THE LINES ");
		tl[0].tree = (OBJECT *)(GetObjcspec(colicon, Coloricon)->ciconblk);
		tl[0].xpos = tl[0].ypos = 0;
		tl[0].mode = tbIcon;
		tl[0].res2 = x;
		tl[1].tree = NULL;
		
		GraphWin = OpenWindow(LinesWinHandler,
							  MOVER | NAME | CLOSER | SIZER | FULLER | SMALLER,
							  WinIconOpen | WinMultiRsc,
							  fback, 7, -1, -1, 250, 200, 0, 0, 0, 0,
							  " The Lines ", "", tl, NULL);
		TimerId = InstMUTIMER(LinesTimer, 10L);
	}
	
	GetUseableRect(GraphWin, &r);
	maxX = r.g_x + r.g_w;
	maxY = r.g_y + r.g_h;
	max[0] = maxX;
	max[1] = maxY;
	max[2] = maxX;
	max[3] = maxY;
	
	for (i=0; i<=3; i++) {
		Vel[i] = RndInt(16) - 8;
		ii = max[i] - 100;
		Ball[i] = RndInt(ii) + 50;
	}
	
	new = old = 0;
} /* TheLines */

/* 
	Dient zur Initialisierung der Variablen. 
*/
void Lines()
{
	GraphWin = -1;
	colcount = 0;
	if (DefaultWS.DefColors > 2)
		fback = 1;
	else
		fback = 0;
	color = fback + 1;
} /* Lines */
				
							
