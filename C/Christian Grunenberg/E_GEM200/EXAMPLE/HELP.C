
#include <e_gem.h>

char *help[] =
{
"",
" FÑhigkeiten der EnhancedGEM-Library:",
"======================================",
" - lÑût sich mit GNU-C, Pure C und Lattice C einsetzen",
" - an MultiTOS, Mag!X ab V2.0 sowie Winx ab V2.1 angepaût",
" - Definitionen der Protokolle XAcc2, AV, MenÅ, Clipboard",
"   und Drag&Drop",
" - XAcc2-, AV- und Clipboard-Protokoll werden automatisch unterstÅtzt",
" - verbesserte Ereignis-Verwaltung mit 4 Rechteck-, 2 Button- und",
"   2 Timer-Events",
" - beliebig viele Fenster-/fliegende Dialoge gleichzeitig",
" - fliegende Dialoge springen zur Mausposition bei Mausklick",
"   auûerhalb des Dialogs",
" - Rechtsklick auf Objekt im Vordergrund-Dialog (bei aktiver Hinter-",
"   grundbedienung auch im Hintergrund-Dialog) simuliert Doppelklick",
" - Fensterdialoge durch zusÑtzlich gedrÅckte rechte Maustaste im",
"   Hintergrund bedienbar (optional auch ohne rechte Maustaste)",
" - Fenster wechseln/schlieûen (Hotkeys und MenÅpunkte definierbar)",
" - unmodale/modale Fensterdialoge",
" - Tastaturbedienung der Dialoge, wobei in Dialogen mit Edit-Feldern",
"   zusÑtzlich die Alternate-Taste gedrÅckt werden muû",
"   (Doppelklick-Simulation durch zusÑtzlich gedrÅckte Shift-Taste)",
" - TastendrÅcke optional zum Dialog unter dem Mauszeiger",
" - unter MTOS (ab AES 4.1) sowie MagiC 3.0 oder bei vorhandenem ICFS",
"   kînnen Fenster bzw. Fensterdialoge ikonifiziert werden",
"   (Hotkey: Ctrl-'*' (Ziffernblock), nur bei ICFS)","",
" - erweiterte Alert-Funktion:",
"   - 18 vordefinierten Icons",
"   - benutzerdefinierte Icons beliebiger Grîûe",
"   - beliebig langen Zeilen und Buttons",
"   - maximal 10 Zeilen sowie 5 Buttons",
"   - Buttons Åber Hotkey anwÑhlbar (auch ohne Alternate-Teste)","",
" - erweiterte Mîglichkeiten in Eingabe-Feldern",
"   - exakte Cursorpositionierung per Maus",
"   - Mauscursor wird Åber Eingabefeldern zum Textcursor",
"   - erstes/letzes Eingabefeld (Home/Shift-Home, Shift-Up/Down)",
"   - Wort vor/zurÅck (Ctrl-Left/Right)",
"   - Anfang/Ende des Eingabesfeldes (Shift-Left/Right)",
"   - vorheriges Eingabesfeld (Up,Shift-Tab/Enter/Return)",
"   - nÑchstes Eingabefeld (Down/Tab/Enter)",
"   - Cursor ein Zeichen nach links/rechts (Left/Right)",
"   - Eingabefeld lîschen (Esc)",
"   - Eingabefeld ab Cursor lîschen (Shift-Del)",
"   - Eingabefeld bis Cursor lîschen (Shift-Backspace)",
"   - Eingabebox fÅr alle Ascii-Zeichen (Shift-Insert)",
"   - Sonderzeicheneingabe durch Eingabe des dezimalen ASCII-Wertes",
"     bei gedrÅckter Alternate-Taste auf dem Ziffernblock",
"      => sofern der ASCII-Wert nicht eindeutig ist (ASCII<=25), mÅssen",
"         alle drei Stellen (evtl. mit fÅhrenden Nullen) eingegeben",
"         werden",
"   - Undo (Undo bzw. Shift-Undo, sofern Undo-Button vorhanden)",
"   - History-Funktion der letzten eingegebenen Texte (Ctrl-Up/Down)",
"      => mit Shift-Taste: Text in History suchen",
"   - ClipboardunterstÅtzung:",
"      => mit Shift-Taste: Text an Clipboard/Eingabe-Feld anhÑngen",
"      -> Ctrl-X: Text ausschneiden und in Clipboard ablegen",
"      -> Ctrl-C: Text in Clipboard ablegen",
"      -> Ctrl-V: Text in Eingabefeld einfÅgen",
"   - EinfÅge-/öberschreibenmodus (Insert)",
"      => Strich-/Block-Cursor",
"   - neue zusÑtzliche GÅltigkeitsmasken in Eingabefeldern:",
"      \'c\',\'C\': Ziffern \"0-9\", Komma \".,\", Rechenzeichen \"+-*/^\",",
"               Klammern \"(){}[]\"",
"      \'l\',\'L\': LED-Ziffern \"0-9\"",
"      \'<Ziffer>\': Ziffer=\'0\'-\'9\'",
"               alle Ziffern von \'0\' bis <Ziffer>, z.B.",
"               \'1\': BinÑrziffern",
"               \'7\': Oktalziffernn",
"               \'9\': Dezimalziffern",
"      \'h\',\'H\': Hexadezimalziffern \"0-9A-F\",",
"               Umwandlung in Klein/Groûbuchstaben",
"      \'u\',\'U\': ASCII 32-127, Umwandlung in Klein-/Groûbuchstaben",
"      \'v\',\'V\': ASCII 32-255, Umwandlung in Klein-/Groûbuchstaben",
"      \'w\',\'W\': ASCII 32-127",
"      \'y\',\'Y\': ASCII 32-255",
"   - grîûtenteils automatische Anpassung (sofern mîglich) der",
"     eingegeben Zeichen an GÅltigkeitsmaske",
"   - kleiner/groûer System-Font kînnen in Eingabefeldern benutzt",
"     werden"
"   - Bedeutung von Return wahlweise",
"      -> Return selektiert DEFAULT-Objekt",
"      -> Return springt zum nÑchsten Eingabefeld (zyklisch)",
"      -> Return selektiert beim letzten Eingabefeld das DEFAULT-Objekt","",
" - Cookie-/Scrap-/Resource- u. Environment-Library",
" - erweiterte Rectangle- & Object-Library von PC-GEM 2.0","",
" - viele erweiterte Objekte:",
"   - Radio-Buttons",
"   - Check-Buttons",
"   - Cycle-Buttons fÅr Popups",
"   - Help-Button",
"   - Undo-Button",
"   - Text mit Attributen",
"     -> unterstrichen,kursiv,umrandet,schattiert,fett,hell,klein/groû",
"   - Rahmen mit Titel",
"   - Titel (= unterstrichener Text)",
"     -> beliebige Strichdicke, optional doppelt unterstrichen",
"   - Flugecke",
"   - Slider-Arrows (optional umrandet)",
"   - Niceline",
"   - opt. von Eingabefeldern abhÑngiges DEFAULT-Objekt",
"   - unmodale und modale Objekte, d.h. die Objekte kommen nur in",
"     (un-) modalen Dialogen vor",
"   - usw.","",
" - Echtzeitgummiband/-schieber mit halb- oder vollautomatischer Ver-",
"   waltung bzw. Ereignisauswertung sowie optionaler Tastaturbedienung",
" - variable Popup-MenÅs (vollstÑndig tastaturbedienbar (Hotkeys),",
"   frei positionierbar)","",
" - Dialogoptik in weiten Grenzen variierbar:",
"   - Hintergrundbox (Muster,Farbe,Rahmen)",
"   - Flugecke wird an Hintergrundbox angepaût",
"   - Rahmen (Schrift einfach/doppelt umrandet,Schriftgrîûe)",
"   - Titel-Unterstrich (LÑnge,Dicke,einfach/doppelt unterstrichen)",
"   - Farben der erweiterten Objekte",
"   - viele Varianten der Radio-/Check/Cycle-Buttons sowie Sliderpfeile",
"   - usw.","",
" - sauber programmiert, d.h. unabhÑngig von",
"   - Computer (ST/STE/TT/Falcon/Emulator)",
"   - Auflîsung und Anzahl der Farben",
"   - Betriebsystem (TOS,MTOS,MagiC,Geneva,MultiGEM)",
"   - VDI/GDOS-Treiber",
"   - Grîûe des System-Fonts",
"   - usw.",""
};

int cdecl draw_help(PARMBLK *);

int old_line,first_line,scroll_help;
int line_help_h,view_help_lines;
int help_lines = (int) sizeof(help)>>2;

USERBLK	helpblk = {draw_help,0};

/* Zeichnen des Ausschnitts des Hilfe-Textes (optimiert) */

int cdecl draw_help(PARMBLK *pb)
{
	reg int cnt_lines,start_line = first_line,delta_lines = (first_line>old_line) ? (first_line - old_line) : (old_line - first_line);
	reg int x = pb->pb_x,y = pb->pb_y;

	v_set_text(small_font_id,small_font,-1,NULL);
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

		for (index=cnt_lines;--index>=0;y += line_help_h)
			v_gtext(x_handle,x,y,help[start_line++]);
	}

	return(0);
}
