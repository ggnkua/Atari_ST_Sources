
char *al_text =
"_ Erweiterte Alertboxen: |^|"\
"^- bis zu 16 Zeilen Text u. 5 Buttons|"\
"^- 18 vordefinierte Icons, benutzerdefinierte Icons|"\
"^  beliebiger Grîûe|"\
"^- Tastaturbedienung per Hotkeys, Undo-/Default-Button|"\
"^- beliebige Textattribute, groûer/kleiner Systemfont|"\
"^- sonstige Mîglichkeiten s. Alert-Dialog|^|"\
"</linksbÅndig|:%zentriert|@!>rechtsbÅndig";

char *al_button = "[Huh-Huh|[This sucks!";

char *paula_text = "_ Paula V2.4: ";

char *paula_button = "[Terminate|[Stop|[Play|Cancel";

char *ci_text =
"^|^:When I look into your eyes|"\
"^:I can see a love restrained.|"\
"^:But darlin\' when I hold you|"\
"^:don\'t you know I feel the same.|"\
"^:Cause nothin\' lasts forever|"\
"^:and we both know hearts can change|"\
"^:and it\'s hard to hold a candle|"\
"^:in the cold november rain.|"\
"^:We\'ve been through this such a long long time|"\
"^:just tryin\' to kill the pain.|"\
"^:But lovers always come and lovers always go|"\
"^:an\' no one\'s really sure who\'s lettin\' go today -|"\
"^:walking away.|"\
"^:If we could take the time to lay it on the line|"\
"^:I could rest my head|"\
"^:just knowin\' that you were mine -|"\
"^:all mine!|"\
"^:So if you want to love me|"\
"^:then darlin\' don\'t refrain|"\
"^:or I\'ll just end up walkin\'|"\
"^:in the cold november rain.|";

char *ci_button = "[Guns \'n roses";

char *help[] =
{
"",
" Bedienung der Demonstrations-Dialoge: ",
"=====================================================================",
" (genaue Beschreibung u. weitere Mîglichkeiten s. Anleitung) ",
"",
" - Tastaturbedienung (Hotkeys) der Dialoge, wobei in Dialogen mit",
"   Eingabefeldern sowie in nicht-modalen Fensterdialogen zusÑtzlich",
"   die Alternate-Taste gedrÅckt werden muû",
"   (Doppelklick-/Rechtsklick-Simulation durch zusÑtzlich gedrÅckte",
"   Shift-/Control-Taste)",
" - TastendrÅcke gehen an den Dialog unter dem Mauszeiger",
" - Rechtsklick auf ein Dialog-Objekt simuliert Doppelklick",
" - fliegende Dialoge springen zur Mausposition bei Mausklick",
"   auûerhalb des Dialogs (u.a. system-modale Alertboxen), kînnen",
"   bei gedrÅckter Maustaste oder durch einen kurzen Klick auf das",
"   Flugobjekt und einen nochmaligen Klick oder durch Anklicken eines",
"   nicht selektier-/editierbaren Objekts mit der linken Maustaste",
"   verschoben werden",
" - Fensterdialoge sind auch im Hintergrund bedienbar",
" - Fensterdialoge (u.a. applikations-modale Alertboxen) lassen sich",
"   durch Anklicken eines nicht selektier-/editierbaren Objekts und",
"   GedrÅckthalten der linken Maustaste verschieben",
" - Hintergrundfenster werden nach einem kurzen Linksklick auf ein",
"   nicht selektier-/editierbares Objekt nach vorne gebracht",
"",
"  MTOS-Ikonifizierung:",
"   - Anklicken des Ikonifizierungsbuttons",
"     -> ein einzelnes Fenster verkleinern",
"   - Anklicken des Ikonifizierungsbuttons bei gedrÅckter Control-Taste",
"     -> alle Fenster in ein Fenster verkleiner",
"   - Doppelklick in ein ikonifiziertes Fenster îffnet es wieder",
"     an der alten Position (Hotkey: CTRL-Space)",
"",
"  ICFS-(kompatible-) Ikonifizierung:",
"   - [Alternate]-Closer - ein einzelnes Fenster verkleinern",
"     (Hotkey: Ctrl-Space)",
"   - [Shift]-Closer     - alle Fenster einzeln verkleinern",
"     (Hotkey: Ctrl-Shift-Space)",
"   - [Control]-Closer   - alle Fenster in ein Fenster verkleinern",
"     (alternativ: [Alternate-Shift]-Closer unter Winx)",
"   - Mausklick in ein verkleinertes Fenster îffnet es wieder an der",
"     alten Position (Hotkey: Ctrl-Space). Durch eine zusÑtzlich ge-",
"     drÅckte Shift-Taste werden alle Fenster an der alten Position",
"     geîffnet.",
"",
" - erweiterte Mîglichkeiten in Eingabe-Feldern:",
"   - Text kann per ACC_TEXT-Nachricht eingegeben werden",
"   - exakte Cursorpositionierung per Maus",
"   - Cursor kann in ein Eingabefeld gezielt per Alternate+Hotkey",
"     gesetzt werden",
"   - Mauscursor wird Åber Eingabefeldern zum Textcursor",
"   - EnthÑlt die Eingabemaske eines der Zeichen \',.;:\\/\' und wird",
"     dieses Zeichen eingegeben, wenn der Cursor VOR diesem Zeichen",
"     steht, so wird das Eingabefeld bis zu diesem Zeichen mit",
"     Leerzeichen gefÅllt und der Cursor hinter dieses Zeichen",
"     gesetzt (Beispiel: Punkt '.' in Dateimasken)",
"   - Wird in einem Eingabefeld, in dem Leerzeichen nicht eingegeben",
"     werden kînnen, ein Leerzeichen eingegeben, so wird das Eingabe-",
"     feld bis zum nÑchsten festen Maskenzeichen mit Leerzeichen ge-",
"     fÅllt. Wurde das ganze Eingabefeld gefÅllt, so wird anschlieûend",
"     zum nÑchsten Feld gesprungen.",
"   - erstes/letztes (bei Shift-Home an das Ende, bei Shift-Down",
"     an den Anfang) Eingabefeld (Home/Shift-Home, Shift-Up/Down)",
"   - Wort vor/zurÅck (Ctrl-Left/Right)",
"   - Anfang/Ende des Eingabesfeldes (Shift-Left/Right)",
"   - vorheriges Eingabesfeld (Up,Shift-Tab/Enter/Return)",
"   - nÑchstes Eingabefeld (Down/Tab/Enter)",
"   - Cursor ein Zeichen nach links/rechts (Left/Right)",
"   - Eingabefeld lîschen (Esc)",
"   - alle Eingabefelder lîschen (Shift-Esc)",
"   - Eingabefeld ab Cursor lîschen (Shift-Del)",
"   - Eingabefeld bis Cursor lîschen (Shift-Backspace)",
"   - Eingabebox fÅr alle Ascii-Zeichen (Shift-Insert)",
"   - Sonderzeicheneingabe durch Eingabe des dezimalen ASCII-Wertes",
"     bei gedrÅckter Alternate-Taste auf dem Ziffernblock",
"     => sofern der ASCII-Wert nicht eindeutig ist (ASCII<=25), mÅssen",
"        alle drei Stellen (evtl. mit fÅhrenden Nullen) eingegeben",
"        werden",
"   - Undo (Undo bzw. Shift-Undo, sofern Undo-Button vorhanden)",
"   - History-Funktion der letzten eingegebenen Texte (Ctrl-Up/Down)",
"     => mit Shift-Taste: Text in History suchen",
"   - ClipboardunterstÅtzung:",
"     => mit Shift-Taste: Text an Clipboard/Eingabe-Feld anhÑngen",
"       -> Ctrl-X: Text ausschneiden und in Clipboard ablegen",
"       -> Ctrl-C: Text in Clipboard ablegen",
"       -> Ctrl-V: Text in Eingabefeld einfÅgen",
"   - EinfÅge-/öberschreibenmodus (Insert -> Strich-/Block-Cursor)",
"   - Return selektiert beim letzten Eingabefeld das DEFAULT-Objekt",
"",
" - Slider-Bedienung:",
"   - Pfeile (links/rechts,hoch/runter,Minus/Plus,usw.):",
"      -> Einzelklick: Zeile hoch/runter (bzw. Wert erniedrigen/-hîhen)",
"      -> Doppelklick: Anfang/Ende (bzw. minimaler/maximaler Wert)",
"   - Hintergrundelement (grauer Bereich):",
"      -> Einzelklick: Seite hoch/runter",
"      -> Doppelklick: Slider positionieren",
"   - Slider:",
"      -> Echtzeitverschieben wÑhrend Maustaste gedrÅckt ist oder",
"         durch einen kurzen Klick und einen weiteren Klick zur Posi-",
"         tionierung",
"",
" - Popup-MenÅs:",
"   - Auswahl eines Eintrags per Maus (Bereich auûerhalb des Popups",
"     fÅr Abbruch):",
"     -> kurzer Klick auf Popup-Button/-Text und nochmaliger Klick",
"        auf gewÅnschten Eintrag oder",
"     -> GedrÅckthalten der Maustaste beim Anklicken des",
"        Popup-Buttons/-Textes und Loslassen der Maustaste Åber",
"        gewÅnschtem Eintrag",
"   - Cycle-Button:",
"       -> nÑchsten (Einfachklick)/vorherigen (Doppel-/Rechtsklick)",
"          Eintrag wÑhlen",
"       -> per Alternate-Shift-Hotkey (nÑchster Eintrag) bzw.",
"          Alternate-Control-Shift-Hotkey (vorheriger Eintrag) anwÑhlbar",
"   - Hotkeys (unterstrichener Buchstabe, optional mit gedrÅckter",
"     Alternate-Taste)",
"   - vorheriger Eintrag (Cursor links/hoch)",
"   - nÑchster Eintrag (Cursor rechts/runter)",
"   - erster Eintrag (Home)",
"   - letzter Eintrag (Shift-Home)",
"   - Abbruch (Escape/Undo)",
"   - aktuellen Eintrag auswÑhlen (Space,Return,Enter)",
"   - Doppel-/Rechtsklicksimulation durch zusÑtzlich gedrÅckte",
"     Shift-/Control-Taste",
"   - SubmenÅs:",
"       -> Aufklappen per Selektion des entsprechenden Eintrags",
"          (Return, Enter, Space, Hotkeys, Cursor-Right) oder nach",
"          einer kurzen Verzîgerung, wenn der Mauszeiger Åber dem",
"          entsprechenden Eintrag steht",
"       -> SubmenÅs lassen sich i.A. wie Popups bedienen, aber zusÑtz-",
"          lich per Cursor-Left (entspricht dann Escape/Undo) wieder",
"          verlassen",
""
};

char scroll_text[] =
"When I look into your eyes "\
"I can see a love restrained. "\
"But darlin\' when I hold you "\
"don\'t you know I feel the same. "\
"Cause nothin\' lasts forever "\
"and we both know hearts can change "\
"and it\'s hard to hold a candle "\
"in the cold november rain. "\
"We\'ve been through this such a long long time "\
"just tryin\' to kill the pain. "\
"But lovers always come and lovers always go "\
"an\' no one\'s really sure who\'s lettin\' go today - "\
"walking away. "\
"If we could take the time to lay it on the line "\
"I could rest my head "\
"just knowin\' that you were mine - "\
"all mine! "\
"So if you want to love me "\
"then darlin\' don\'t refrain "\
"or I\'ll just end up walkin\' "\
"in the cold november rain. "\
"Do you need some time on your own, "\
"do you need some time all alone? "\
"Everybody needs some time on their own! "\
"Don\'t you know you need some time all alone? "\
"I know it\'s hard to keep an\' open heart "\
"when even friends seem out to harm you. " \
"But if you could heal a broken heart "\
"wouldn't time be out to charm you? "\
"Sometimes I need some time on my own, "\
"sometimes I need some time all alone. "\
"Everybody needs some time on their own! "\
"Don\'t you know you need some time all alone? "\
"And when your tears subside "\
"and shadows still remain "\
"I know that you can love me "\
"when there's no one left to blame. "\
"So never mind the darkness "\
"we still can find a way "\
"cause nothin\' lasts forever "\
"even cold november rain! "\
"Don\'t ya think that you need somebody, "\
"don\'t ya think that you need someone? "\
"Everybody needs somebody! "\
"You\'re not the only one, "\
"you\'re not the only one! "\
" (The end)   ---   ";
