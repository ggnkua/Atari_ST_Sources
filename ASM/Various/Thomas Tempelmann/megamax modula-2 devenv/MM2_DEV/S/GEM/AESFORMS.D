DEFINITION MODULE AESForms;


(*  Megamax Modula-2 GEM-Library :  Die AES Formularfunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  05.11.87
 *
 *  Version   2.2     V#0015
 *)
 

(*      Dieses Modul unterstÅtzt die Benutzung von Formularen (Dialogboxen).
 *
 *      Die Prozeduren 'FormError' und 'FormAlert' fÅhren dabei einen kom-
 *      pletten Dialog und bauen die benîtigte Objektbaumstruktur selbst-
 *      stÑndig auf.
 *      Die restlichen Routinen Åbernehmen jeweils Teilaufgaben beim FÅhren
 *      eines Dialogs mit einer vom Benutzer frei definierbaren Dialogbox,
 *      deren Definition in Form eines Objektbaumes (siehe 'GEMGlobals')
 *      vorhanden sein muû.
 *)
 

FROM GrafBase   IMPORT Rectangle;

FROM GEMGlobals IMPORT GemChar, PtrObjTree;
 
 
                        (*  Form Manager  *)
                        (*  ============  *)

PROCEDURE FormCenter (tree: PtrObjTree): Rectangle;

        (*  Zentriert Dialogbox und liefert den belegten Bildschirmbereich.
         *
         *  Dabei ist 'tree' der Objektbaum, der die Box beschreibt und es
         *  werden die Ausmaûe und die neue Position der Dialogbox als Funk-
         *  tionswert geliefert.
         *)


TYPE    FormDialMode    = (reserveForm, growForm, shrinkForm, freeForm);
        
PROCEDURE FormDial (flag: FormDialMode; little, big: Rectangle);

        (*  Bereitet einen Dialog vor und beendet ihn auch wieder.
         *
         *  Eingabeparameter:
         *  -----------------
         *
         *  'flag'      -- Bestimmt die Funktion der Routine (siehe unten).
         *  'big'       -- Grîûe und Position der Dialogbox (z.B. von
         *                 'FormCenter').
         *  'little'    -- Bildschirmbereich in dem das Objekt (MenÅpunkt,
         *                 Icon, etc.) liegt, das den Dialog ausgelîût hat.
         *                 Wird nur bei 'growForm' und 'shrinkForm' gebrau-
         *                 cht.
         *
         *  Funktionen:
         *  -----------
         *
         *  'reserveForm' -- Reserviert den von der Dialogbox belegten Bild-
         *                   schirmbereich.
         *  'growForm'    -- Zeichnet ein sich ausdehnendes Rechteck.
         *  'shrinkForm'  -- Zeichnet ein schrumpfendes Rechteck.
         *  'freeForm'    -- Gibt den von der Dialogbox belegten Bildschirm-
         *                   bereich wieder frei, dabei wird das Neuzeichnen
         *                   des Bereichs veranlaût.
         *
         *  Die zweite und dritte Funktion ist optional, daû heiût sie sind
         *  beide schîn anzusehen, fÅr das korrekt Funktionieren des Dialogs
         *  sind sie aber nicht notwendig.
         *
         *  Der vierte Modus ist gut geeignet das Neuzeichnen, bestimmter
         *  Bildschirmausschnitte, zu erzwingen.
         *)
        
PROCEDURE FormDo (tree: PtrObjTree; first: CARDINAL; VAR retBut: CARDINAL);

        (*  FÅhrt einen Teildialog durch, daû heiût alle vom Benutzer inner-
         *  halb der Dialogbox durchgefÅhrten Aktionen werden selbstÑndig
         *  ausgewehrtet. Erst beim Selektieren eines Objektes mit gesetztem
         *  'selectExitFlg'-Flag oder Anklicken eines Objektes mit gesetztem
         *  'touchExitFlag' kehrt die Routine zurÅck.
         *
         *  Eingabeparameter:
         *  -----------------
         *
         *  'tree'      -- Objektbaum, der die Dialogbox beschreibt.
         *  'first'     -- Objektindex, der edierbaren Zeichenkette, auf
         *                 der der Cursor zuerst plaziert werden soll.
         *                 'Root' sollte Åbergeben werden, falls kein sol-
         *                 ches Feld existiert, oder das erste im Baum be-
         *                 nutzt werden soll.
         *
         *  Ausgabeparameter:
         *  -----------------
         *
         *  'retBut'    -- Index des Objektes, dessen Selektieren oder An-
         *                 klicken den Teildialog abgebrochen hat.
         *
         *    WICHTIG: Wird die Dialogbox mit einem Doppelklick verlassen,
         *             so ist das hîchstwertige Bit von 'retBut' gesetzt,
         *             d.h., der Wert ist um 32768 grîûer und muû unbedingt
         *             abgezogen werden, wenn der Wert als Index im Baum
         *             weiterbenutzt oder verglichen werden soll!
         *
         *  Voraussetzung fÅr das korrekte Funktionieren, dieser Prozedur,
         *  ist, daû sich die von 'tree' beschriebene Dialogbox schon auf
         *  dem Bildschirm befindet.
         *)
         

PROCEDURE FormAlert (    defBut: CARDINAL;
                     REF str   : ARRAY OF CHAR;
                     VAR retBut: CARDINAL);

        (*  FÅhrt einen vollstÑndigen Dialog mit dem Benutzer. Der Dialog
         *  ist auf einen maximal 5 zeiligen Text und die Angabe von bis
         *  zu 3 Knîpfen begrenzt.
         *
         *  Es bestimmt 'defBut' den Standardknopf, d.h. den Knopf, der
         *  selektiert wird, sobald der Benutzer die <Return>-Taste drÅckt.
         *  Auûerdem bestimmt 'str' den Inhalt der Dialogbox und 'retBut'
         *  liefert den Knopf, dessen Selektion den Dialog beendet hat.
         *
         *  Diese Art von Formularen wird meist fÅr Fehler- oder Warnmel-
         *  dungen benutzt, ihr Inhalt wird wie folgt festgelegt.
         *
         *  Aufbau von 'str':
         *  -----------------
         *
         *  Syntax:    '[' <Icon> '][' <Text> '][' <Knîpfe> ']'
         *
         *  Dabei ist,
         *
         *    <Icon> eine Zahl zwischen 0 und 3
         *
         *              0 -- kein Icon (Piktogramm)
         *              1 -- NOTE-Icon
         *              2 -- WAIT-Icon
         *              3 -- STOP-Icon
         *
         *    <Text> ein String, der in maximal 5 Blîcke mit 29 Zeichen
         *    aufgeteilt ist. Die Trennung der einzelnen Blîcke, die von
         *    der Routine in verschiedenen Zeilen ausgegeben werden, fin-
         *    det durch '|' statt;
         *
         *    <Knîpfe> ist ebenfalls eine Zeichenkette, die durch '|' in
         *    diesmal hîchstens 3 Blîcke zu je 9 Zeichen geteilt wird.
         *    Jeder Block wird auf dem Bildschirm zu einem Knopf (button).
         *    Die Buttons werden von links nach rechts von 1 bis 3 durch-
         *    nummeriert.
         *
         *  Eine Besonderheit dieses Dialoges ist, daû der Bildschirmhinter-
         *  grund automatisch gerettet und am Dialogende wiederhergestellt
         *  wird.
         *
         *  Beispiel:
         *  ---------
         *
         *    FormAlert(1,'[3][ *** BUS ERROR *** | in Zeile 5!][ Pech ]',but)
         *
         *    Es wÅrde das STOP-Icon erscheinen mit dem Text ' *** BUS
         *    ERROR *** ' in der ersten und ' in Zeile 5!' in zweiten
         *    Zeile. Der einzige Knopf wÑre gleichzeitig Standardknopf
         *    und besÑûe den Text ' Pech '.
         *    'but' muû eine Variable vom Typ CARDINAL sein.
         *)

PROCEDURE FormError (errNo: INTEGER);

        (*  Gibt eine Systemfehlermeldung mit Hilfe einer Alertbox aus.
         *
         *  'errNo' kann die folg. Werte annehmen:
         *
         *    2, 3, 18: "Diese Anwendung kann Datei oder Ordner nicht finden"
         *    4: "Kein Platz mehr fÅr weitere Fenster - Bitte eins schlieûen"
         *    5: "Datei existiert bereits oder ist SchreibgeschÅtzt"
         *    8, 10, 11: "Es steht nicht genug Speicher fÅr diese Anwendung
         *                zur VerfÅgung"
         *    15: "Dieses Laufwerk ist nicht vorhanden"
         *
         *  Diese Werte entsprechen Åbrigens den Fehlernummern bei MS-DOS.
         *)

PROCEDURE FormKeyboard (    tree   : PtrObjTree;
                            index  : CARDINAL;
                        VAR nextObj: CARDINAL;
                        VAR ch     : GemChar;
                        VAR cont   : BOOLEAN);
                        
        (*  Diese Prozedur verarbeitet die bei einer Dialogsitzung anfal-
         *  lenden Steuerzeichen.
         *  Es ist 'tree' ein Zeiger auf das Dialogformular und 'index', der
         *  Baumindex des zu edierenden Objekts (= 0, falls keines vorhanden).
         *  'nextObj' ist der Index des nÑchsten Objekts und 'ch' enthÑlt die
         *  betÑtigte Taste. Falls 'ch' ein Steuerzeichen enthÑlt, so wird
         *  dies bearbeitet und 'ch' der Wert 0C zugewiesen, sonst wird 'ch'
         *  nicht verÑndert und kann mit 'AESObject.EditObjText' weiterver-
         *  arbeitet werden. 'nextObj' liefert das nÑchste Objekt.
         *  Ist 'cont = FALSE', so sollte der Teildialog abgebrochen werden,
         *  da zum Beispiel ein mit 'selectExitFlg' gekennzeichnetes Objekt
         *  angewÑhlt wurde.
         *)

PROCEDURE FormButton (    tree   : PtrObjTree;
                          index  : CARDINAL;
                          clicks : CARDINAL;
                      VAR nextObj: CARDINAL;
                      VAR cont   : BOOLEAN);
                      
        (*  Mit Hilfe dieser Routine kînnen die Mausklicks einer Dialog-
         *  sitzung verarbeitet werden.
         *  'tree' ist der Formularbaum und 'index' enthÑlt das angeklickte
         *  Objekt. In 'clicks' steht, wie oft der Mausknopf gedrÅckt wurde
         *  und in 'nextObj' wird das nÑchste Objekt zurÅckgegeben.
         *  Je nach Objekttyp von 'obj' fÅhrt die Routine die entsprechenden
         *  Aktionen aus, wie zum Beispiel Objekt selektieren und Radioknîpfe
         *  verÑndern.
         *  Ist 'cont = FALSE', so sollte der Teildialog abgebrochen werden,
         *  da zum Beispiel ein mit 'selectExitFlg' gekennzeichnetes Objekt
         *  angewÑhlt wurde.
         *)


END AESForms.