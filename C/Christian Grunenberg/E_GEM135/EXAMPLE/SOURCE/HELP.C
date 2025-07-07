
#include <e_gem.h>
#include "example.h"

char *help[] =
{
"",
" F„higkeiten der EnhancedGEM-Library:",
"======================================",
"- l„žt sich mit GNU-C,Pure C (Pure-C-",
"  Libraries als auch MiNT-Libraries) und",
"  Lattice C einsetzen",
"  (dank Markus Kilbinger @ AC)","",
"- alle F„higkeiten von Let 'em fly, den",
"  FlyDials, der XFormDo-Library, den",
"  WinDials sowie der Ruby-Library und",
"  „hnlichen Libraries","",
"- beliebig viele Fensterdialoge und",
"  fliegende Dialoge gleichzeitig","",
"- fliegende Dialoge springen zur Maus-",
"  position bei Mausklick aužerhalb des",
"  Dialogs","",
"- Fensterdialoge optional auch (!) vor",
"  MTOS/Falcon-TOS im Hintergrund bedien-",
"  bar (funktioniert teilweise nicht ein-",
"  wandfrei bei aktivem ArrowFix)","",
"- unmodale/modale Fensterdialoge","",
"- erweiterte Alert-Funktion:",
"  --------------------------",
"   - 18 vordefinierte Icons",
"   - benutzerdefinierte Icons mit be-",
"     liebiger Gr”že",
"   - beliebig langen Zeilen und Buttons",
"   - maximal 10 Zeilen sowie 5 Buttons",
"   - Buttons ber Hotkey anw„hlbar",
"     (ohne Alternate-Taste)","",
"- Tastaturbedienung der Dialoge, wobei",
"  in Dialogen mit Eingabe-Feldern zus„tz-",
"  lich die Alternate-Taste gedrckt werden",
"  muž (Doppelklick durch zus„tzlich ge-",
"  drckte Shift-Taste)","",
"- erweiterte Eingabem”glichkeiten:",
"  --------------------------------",
"   - exakte Cursorpositionierung per Maus",
"   - Mauscursor wird ber Eingabefeldern",
"     zum Textcursor",
"   - erstes/letzes Eingabefeld",
"     (Home/Shift-Home)",
"   - Wort vor/zurck (Ctrl-Left/Right)",
"   - Anfang/Ende des Eingabesfeldes",
"     (Shift-Left/Right)",
"   - n„chstes Eingabefeld",
"     (Tab/(Shift-) Enter/Return",
"   - Eingabefeld l”schen (Esc)",
"   - Eingabefeld rechts von Cursor",
"     l”schen (Shift-Del)",
"   - Eingabebox fr alle Ascii-Zeichen",
"     (Shift-Insert)",
"   - Undo, sofern kein Undo-Button",
"     definiert ist",
"   - History ((Shift-) Ctrl-Up/Down)",
"   - Clipboarduntersttzung (Ctrl-X/C/V)",
"     (mit Shift -> Anh„ngen an Eingabefeld",
"      bzw. Clipboard)","",
"- Cookie-/Scrap-/Rsrc- und",
"  Environment-Library","",
"- erweiterte Rectangle- & Object-Library",
"  von PC-GEM 2.0","",
"- viele erweiterte Objekte:",
"  -------------------------",
"   - Radio-Buttons",
"   - Check-Buttons",
"   - Cycle-Buttons fr Popups",
"   - Help-Button",
"   - Undo-Button",
"   - Text mit Attributen",
"     - unterstrichen",
"     - kursiv",
"     - umrandet",
"     - schattiert",
"     - fett",
"     - hell",
"     - normaler/kleiner Font",
"   - Rahmen mit Titel",
"   - Titel (=unterstrichener Text)",
"     - beliebige Strichdicke",
"     - optional doppelt unterstrichen",
"   - Flugecke",
"   - Slider-Arrows",
"   - Niceline",
"   - opt. von Eingabenfeldern abh„ngiges",
"     DEFAULT-Objekt",
"   - modale Objekte, d.h. das Objekt kommt",
"     nur in modalen Dialogen vor",
"   - usw.","",
"- Echtzeitgummiband/-schieber","",
"- variable Popup-Mens:",
"  --------------------",
"   - vollst„ndig tastaturbedienbar",
"     - Cursor up/down/left/right",
"     - Home/Shift-Home (Anfang/Ende)",
"     - Esc/Undo (=Abbruch)",
"     - Space/Return (=Selektion)",
"     - Hotkeys",
"   - frei positionierbar sowie an Eltern-",
"     objekt ausrichtbar","",
"- variierbare Dialogoptik:",
"  ------------------------",
"   - Hintergrundbox (Muster,Farbe,Rahmen)",
"   - Flugecke wird an Hintergrundbox",
"     angepažt",
"   - Rahmen:",
"     - Titel optional einfach oder doppelt",
"       umrandet",
"     - normaler/kleiner Font",
"   - Titel-Unterstrich:",
"     - L„nge",
"     - Dicke",
"     - optional doppelt unterstrichen",
"   - Farben der erweiterten Objekte",
"   - viele Varianten der Radio-/Check/",
"     Cycle-Buttons sowie der Sliderpfeile",
"   - usw.","",
"- sauber programmiert, d.h. unabh„ngig von",
"   - Computer (ST/TT/Falcon/Emulator)",
"   - Aufl”sung und Anzahl der Farben",
"   - (Multi) TOS-Version",
"   - VDI/GDOS-Treiber",
"   - Gr”že des System-Fonts","",
"- an MultiTOS, Mag!X und Winx 2 angepažt","",
"- usw.",
""
};

int cdecl draw_help(PARMBLK *);
void do_help(OBJECT *,int,int,int);

extern DIAINFO help_info;
extern boolean scroll_help;

SLINFO sl_help ={&help_info,HELPPAR,HELPSLID,HELPUP,HELPDOWN,0,0,0,
				VERT_SLIDER,SL_LINEAR,200,0,do_help};

static int old_line,first_line;

int line_help_h,view_help_lines;
int help_lines = (int) sizeof(help)>>2;

USERBLK	helpblk = {draw_help,0};

/* Zeichnen des Ausschnitts des Hilfe-Textes (optimiert) */

int cdecl draw_help(PARMBLK *pb)
{
	reg int cnt_lines,start_line = first_line,delta_lines = (first_line>old_line) ? (first_line - old_line) : (old_line - first_line);
	reg int x = pb->pb_x,y = pb->pb_y;
	int dummy;

	vst_font(x_handle,small_font_id);
	vst_height(x_handle,small_font,&dummy,&dummy,&dummy,&dummy);

	if (!scroll_help || (pb->pb_y+pb->pb_h)>max_h || delta_lines>=(view_help_lines-3) || delta_lines<=0)
		cnt_lines = view_help_lines;
	else
	{
		reg GRECT source;
		reg int dy = delta_lines*line_help_h;

		source.g_x = x;
		source.g_y = y;
		source.g_w = pb->pb_w;
		source.g_h = pb->pb_h - dy;

		if (first_line>old_line)
		{
			source.g_y += dy;
			rc_sc_copy(&source,x,y,3);
			if (pb->pb_hc>pb->pb_h)
				start_line += view_help_lines - delta_lines;
			else
			{
				start_line += ((pb->pb_yc + pb->pb_hc - y)/line_help_h)-delta_lines;
				delta_lines++;
			}
		}
		else
		{
			rc_sc_copy(&source,x,y + dy,3);
			if (pb->pb_hc<=pb->pb_h)
			{
				start_line += (pb->pb_yc - y)/line_help_h;
				delta_lines++;
			}
		}

		start_line = max(start_line,first_line);
		cnt_lines = min(delta_lines,help_lines-start_line);

		if (start_line-first_line+cnt_lines>view_help_lines)
			cnt_lines = view_help_lines-start_line+first_line;
	}

	{
		reg GRECT clear;
		reg int index;

		y += (start_line-first_line)*line_help_h;

		clear.g_x = x;
		clear.g_y = y;
		clear.g_w = pb->pb_w;
		clear.g_h = cnt_lines*line_help_h;
		rc_intersect((GRECT *) &pb->pb_x,&clear);
		rc_sc_clear(&clear);

		y += gr_sh>>1;
		for (index=cnt_lines;--index>=0;y += line_help_h)
			v_gtext(x_handle,x,y,help[start_line++]);
	}

	return(0);
}

/* Funktion wird von graf_rt_slider() aufgerufen, sobald sich die Slider-
   position ge„ndert hat. Dadurch k”nnen entsprechende Objekte neu
   gezeichnet oder gesetzt werden */
 
void do_help(OBJECT *obj,int pos,int prev,int max_pos)
{
	old_line = prev;
	first_line = pos;

	ob_draw_chg(&help_info,HELPVIEW,NULL,FAIL,TRUE);
}
