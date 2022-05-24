
#include <e_gem.h>

char *help[] =
{
"",
" Bedienung der Demonstrations-Dialoge: ",
"=======================================",
" (weitere M”glichkeiten s. Anleitung) ",
"",
" - fliegende Dialoge springen zur Mausposition bei Mausklick",
"   aužerhalb des Dialogs  (u.a. system-modale Alertboxen)",
" - Rechtsklick auf ein Dialog-Objekt simuliert Doppelklick",
" - Fensterdialoge auch im Hintergrund bedienbar",
" - Tastaturbedienung (Hotkeys) der Dialoge, wobei in Dialogen mit",
"   Eingabefeldern zus„tzlich die Alternate-Taste gedrckt werden muž",
"   (Doppelklick-Simulation durch zus„tzlich gedrckte Shift-Taste)",
" - Tastendrcke gehen an den Dialog unter dem Mauszeiger",
"",
" - Ikonififizierung von Fenstern bei vorhandenem ICFS-Server:",
"   (analog falls weder MTOS- noch ICFS-Ikonifizierung vorhanden)",
"   - [Alternate]-Closer - ein einzelnes Fenster verkleinern",
"     (Hotkey: Ctrl-Space oder Ctrl-'*')",
"   - [Shift]-Closer     - alle Fenster einzeln verkleinern",
"     (Hotkey: Ctrl-Shift-Space oder Ctrl-Shift-'*')",
"   - Mausklick in ein verkleinertes Fenster ”ffnet es wieder an der",
"     alten Position",
"",
" - erweiterte M”glichkeiten in Eingabe-Feldern:",
"   - Text kann per ACC_TEXT-Nachricht eingegeben werden",
"   - exakte Cursorpositionierung per Maus",
"   - Mauscursor wird ber Eingabefeldern zum Textcursor",
"   - Enth„lt die Eingabemaske eines der Zeichen \',.;:\\/\' und wird",
"     dieses Zeichen eingegeben, wenn der Cursor VOR diesem Zeichen",
"     steht, so wird das Eingabefeld bis zu diesem Zeichen mit",
"     Leerzeichen gefllt und der Cursor hinter dieses Zeichen",
"     gesetzt (Beispiel: Punkt '.' in Dateimasken)",
"   - erstes/letzes Eingabefeld (Home/Shift-Home, Shift-Up/Down)",
"   - Wort vor/zurck (Ctrl-Left/Right)",
"   - Anfang/Ende des Eingabesfeldes (Shift-Left/Right)",
"   - vorheriges Eingabesfeld (Up,Shift-Tab/Enter/Return)",
"   - n„chstes Eingabefeld (Down/Tab/Enter)",
"   - Cursor ein Zeichen nach links/rechts (Left/Right)",
"   - Eingabefeld l”schen (Esc)",
"   - alle Eingabefelder l”schen (Shift-Esc)",
"   - Eingabefeld ab Cursor l”schen (Shift-Del)",
"   - Eingabefeld bis Cursor l”schen (Shift-Backspace)",
"   - Eingabebox fr alle Ascii-Zeichen (Shift-Insert)",
"   - Sonderzeicheneingabe durch Eingabe des dezimalen ASCII-Wertes",
"     bei gedrckter Alternate-Taste auf dem Ziffernblock",
"     => sofern der ASCII-Wert nicht eindeutig ist (ASCII<=25), mssen",
"        alle drei Stellen (evtl. mit fhrenden Nullen) eingegeben",
"        werden",
"   - Undo (Undo bzw. Shift-Undo, sofern Undo-Button vorhanden)",
"   - History-Funktion der letzten eingegebenen Texte (Ctrl-Up/Down)",
"     => mit Shift-Taste: Text in History suchen",
"   - Clipboarduntersttzung:",
"     => mit Shift-Taste: Text an Clipboard/Eingabe-Feld anh„ngen",
"       -> Ctrl-X: Text ausschneiden und in Clipboard ablegen",
"       -> Ctrl-C: Text in Clipboard ablegen",
"       -> Ctrl-V: Text in Eingabefeld einfgen",
"   - Einfge-/šberschreibenmodus (Insert -> Strich-/Block-Cursor)",
"   - Return selektiert beim letzten Eingabefeld das DEFAULT-Objekt",
"",
" - Popup-Mens:",
"   - Hotkeys (unterstrichener Buchstabe, optional mit gedrckter",
"     Alternate-Taste)",
"   - vorheriger Eintrag (Cursor links/hoch)",
"   - n„chster Eintrag (Cursor rechts/runter)",
"   - erster Eintrag (Home)",
"   - letzter Eintrag (Shift-Home)",
"   - Abbruch (Escape/Undo)",
"   - aktuellen Eintrag ausw„hlen (Space,Return)",
""
};

int old_line,first_line,scroll_help;
int line_help_h,view_help_lines;
int help_lines = (int) sizeof(help)>>2;

/* Zeichnen des Hilfetext-Ausschnitts */

int cdecl draw_help(PARMBLK *pb)
{
	GRECT work = *(GRECT *) &pb->pb_x;
	reg char **ptr;
	reg int x = pb->pb_x,y = pb->pb_y,i,start_line = first_line,lines = abs(first_line - old_line);
	int pxy[4];

	v_set_mode(MD_REPLACE);
	v_set_text(small_font_id,small_font,BLACK,NULL);
	rc_intersect((GRECT *) &pb->pb_xc,&work);

	if (scroll_help)
	{
		i = lines*line_help_h;
		if (first_line<old_line)
			i = -i;

		if (!rc_sc_scroll(&work,0,i,&work))
			return (0);
		else
		{
			rc_grect_to_array(&work,pxy);
			restore_clipping(pxy);
		}
	}

	rc_sc_clear(&work);

	start_line += (work.g_y - y)/line_help_h;
	y += (start_line - first_line)*line_help_h;

	i = min((work.g_y - y + work.g_h + line_help_h - 1)/line_help_h,help_lines-start_line);
	for (ptr=&help[start_line];--i>=0;y+=line_help_h)
		v_gtext(x_handle,x,y,*ptr++);

	return(0);
}

USERBLK	helpblk = {draw_help,0};
