UNIT AV_Protokoll;

INTERFACE

(* Definition der Nachrichten des Venus <-> Accessory Protokolls
 *
 * Sollten in Nachrichten Pfade oder Dateinamen vorkommen, so
 * muû immer der absolute Pfad angegeben werden (also mit Laufwerk)
 * und die Laufwerksbuchstaben mÅssen Groûbuchstaben sein. Pfade enden
 * IMMER mit einem Backslash!
 *
 * Nachrichten von Venus beginnen mit VA (Venus -> Accessory).
 * Nachrichten an Venus beginnen mit AV (Accessory -> Venus).
 *)

(* AV_PROTOKOLL: Mit dieser Nachrichtennummer sollte man bei 
 * anderen Applikationen und auch VENUS/GEMINI nachfragen, ob
 * und welche Nachrichten sie versteht.
 **

CONST AV_PROTOKOLL = $4700;
(*
 * Word 6+7: Pointer auf den Accessorynamen, wie er bei
 *           appl_find benutzt werden muû; also 8 Zeichen lang
 *           nullterminiert (char name[9]).
 * Die Bits in den Worten 3, 4 und 5 haben folgende Bedeutung:
 * Word 3:
 * Bit 0:		(VA_SETSTATUS)
 * Bit 1:		(VA_START)
 * Alle anderen Bits sind fÅr Erweiterungen reserviert und sollten
 * daher mit 0 vorbesetzt werden. Das gilt natÅrlich auch fÅr die
 * Bits in den Worten 4 und 5.
 *)
 
(* VA_PROTOSTATUS: Dem Sender von AV_PROTOKOLL wird mitgeteilt, daû
 * der EmpfÑnger etwas von diesem Protokoll weiû. Die Worte 3-7 des
 * Nachrichtenpuffers enthalten die Information, welche Nachrichten
 * verstanden werden. Gesetzte Bits stehen dafÅr, daû eine Nachricht
 * (Nachrichtengruppe) verstanden werden. 
 *)
CONST VA_PROTOSTATUS = $4701;
(*
 * Word 6+7: Pointer auf den Programmnamen, wie er bei
 *           appl_find benutzt werden muû; also 8 Zeichen lang
 *           nullterminiert (char name[9]).
 * Die Bits in den Worten 3, 4 und 5 haben folgende Bedeutung:
 * Word 3:
 * Bit 0		(AV_SENDKEY)
 * Bit 1		(AV_ASKFILEFONT)
 * Bit 2		(AV_ASKCONFONT, AV_OPENCONSOLE)
 * Bit 3		(AV_ASKOBJECT)
 * Bit 4		(AV_OPENWIND)
 * Bit 5		(AV_STARTPROG)
 * Bit 6		(AV_ACCWINDOPEN, AV_ACCWINDCLOSED)
 * Bit 7		(AV_STATUS, AV_GETSTATUS)
 * Bit 8		(AV_COPY_DRAGGED)
 * Bit 9        (AV_PATH_UPDATE, AV_WHAT_IZIT, AV_DRAG_ON_WINDOW)
 * Bit 10		(AV_EXIT)
 * 
 * Alle anderen Bits sind fÅr Erweiterungen reserviert und sollten
 * daher mit 0 vorbesetzt werden. Das gilt natÅrlich auch fÅr die
 * Bits in den Worten 4 und 5.
 *
 * AV_SENDKEY kann sicher jeder leicht in seine Programme einbauen.
 * Bei AV_OPENWIND kînnte ein Hauptprogramm auch seine "normale"
 * Routine zum ôffnen eines Dokumentes anwerfen und dabei den
 * Åbergebenen Pfad benutzen. Dies ist zusammen mit der Benutzung
 * von TreeView sicher eine einfache Art, Dateien aus anderen Ordnern
 * oder Laufwerken zu laden.
 *)

(* AV_GETSTATUS: Ein Accessory erfragt bei Venus den aktuellen
 * Status, den es Venus mit AV_STATUS mal gegeben hat.
 *)
CONST AV_GETSTATUS = $4703;

(* AV_STATUS: Ein Accessory kann Venus seinen Status mitteilen,
 * der dann von Venus im INF-File gespeichert wird und mit
 * AV_GETSTATUS wieder abgerufen werden kann.
 * Zuvor MUSS es sich aber mit AV_PROTOKOLL anmelden!
 * Word 3+4: Pointer auf einen String, der keine Steuerzeichen
 *           enthalten darf und nicht lÑnger als 256 Zeichen
 *           sein darf. Dieser Pointer darf allerdings NULL sein.
 *)
CONST AV_STATUS = $4704;

(* VA_SETSTATUS: Venus teilt dem Accessory den abgespeicherten
 * Status bei Nachfrage durch AV_GETSTATUS mit. Dieser kann dann 
 * von einem Accessory gesetzt werden.
 * Word 3+4: Pointer auf einen String, der keine Steuerzeichen
 *           enthÑlt.
 *           Dieser Pointer kann allerdings NULL sein, dann war
 *           kein Status gespeichert.
 *)
CONST VA_SETSTATUS = $4705;

(* AV_SENDKEY: Ein Acc sendet VENUS/GEMINI einen Tastaturevent, den
 * es selber vielleicht nicht versteht.
 * Word 3 = Tastaturstatus                 ev_mmokstate
 * Word 4 = Scancode der gedrÅckten Taste  ev_mkreturn
 *)
CONST AV_SENDKEY = $4710;

(* VA_START: Accessory wird aktiviert. Word 3 + 4 enthalten einen
 * Pointer auf eine Kommandozeile, der auch NULL sein kann.
 * In der Kommandozeile stehen Pfade oder Dateinamen.
 *)
CONST VA_START = $4711;

(* AV_ASKFILEFONT: Frage nach dem eingestellten Zeichensatz
 * fÅr Dateinamen.
 *)
CONST AV_ASKFILEFONT = $4712;

(* VA_FILEFONT: Gibt den derzeit eingestellten Zeichensatz.
 * Word 3 = Dateifontnummer (font id)
 * Word 4 = Dateifontgrîûe (in points)
 *)
CONST VA_FILEFONT = $4713;

(* (Nur Gemini) AV_ASKCONFONT: Frage nach dem eingestellten 
 * Zeichensatz fÅr das Console-Fenster.
 *)
CONST AV_ASKCONFONT = $4714;

(* VA_CONFONT: Gibt den derzeit eingestellten Zeichensatz.
 * Word 3 = Consolefontnummer (font id)
 * Word 4 = Consolefontgrîûe (in points)
 *)
CONST VA_CONFONT = $4715;

(* AV_ASKOBJECT: Fragt nach dem derzeit selektiertem Objekt.
 * Es wird der Name des derzeit selektierten Objektes zurÅckgegeben.
 * Ist kein Objekt selektiert, so ist der String leer.
 * Sind mehrere Objekte selektiert, so sind ihre Namen durch Leer-
 * zeichen getrennt.
 *)
CONST AV_ASKOBJECT = $4716;

(* VA_OBJECT: Gibt Namen der derzeit selektierten Objekte.
 * Aufbau wie bei VA_START
 *)
CONST VA_OBJECT = $4717;

(* (Nur Gemini)AV_OPENCONSOLE: Venus soll das Console-Fenster îffnen.
 * Ist es schon offen, so wird es nach vorne gebracht. Diese Aktion
 * ist vor allen Dingen sinnvoll, wenn ein Accessory ein TOS-Programm
 * mittels der system()-Funktion starten will (Warnung: Auf keinen
 * Fall darf ein GEM-Programm von einem Accessory via system() 
 * gestartet werden! (siehe auch AV_STARTPROG)
 * Auch sollte diese Nachricht nur auf ausdrÅcklichen Wunsch des
 * Benutzers gebraucht werden, da es ihn sonst nur verwirren kann.
 *
 * ACHTUNG: Diese Nachricht steht nur in Gemini.app zur VerfÅgung.
 *)
CONST AV_OPENCONSOLE = $4718;

(* VA_CONSOLEOPEN: Gibt zurÅck, ob das Console-Fenster nach vorne
 * gebracht worden ist. Word 3 == 0 (nein) != 0 (ja)
 *)
CONST VA_CONSOLEOPEN = $4719;

(* AV_OPENWIND: Venus soll ein Datei-Fenster îffnen.
 * Dies sollte auch nur geschehen, wenn die Ursache fÅr den
 * Benutzer ersichtlich ist.
 * Word 3+4 (Pointer) Pfad fÅr das Fenster (s.o.).
 * Word 5+6 (Pointer) Wildcard fÅr darzustellende Dateien.
 *)
CONST AV_OPENWIND = $4720;

(* VA_WINDOPEN: Gibt an, ob das Fenster geîffnet werden konnte.
 * siehe VA_CONSOLEOPEN
 *)
CONST VA_WINDOPEN = $4721;


(* Word 7 in AV_STARTPROG und Word 4 und 7 in VA_PROGSTART sind
 * neu seit dem 29. MÑrz 1992.
 *)
 
(* AV_STARTPROG: Venus soll ein Programm starten. Hierbei
 * werden die angemeldeten Applikationen der Venus mit
 * berÅcksichtigt. Man kann also auch eine Datei angeben, fÅr
 * die Venus dann ein Programm sucht.
 * Word 3+4 (Pointer) Programmname mit kompletten Pfad
 * Word 5+6 (Pointer) Kommandozeile (kann NULL sein)
 * Word 7   Beliebiges 16-Bit Wort, das in VA_PROGSTART wieder
 *          zurÅckgeliefert wird.
 *)
CONST AV_STARTPROG = $4722;

(* VA_PROGSTART: Gibt an, ob Venus das Programm startet.
 * Word 3 == 0: nicht gestartet, != 0 gestartet
 * Im Allgemeinen wird das Acc. im Fehlerfall sofort eine
 * Nachricht bekommen. Wenn das Programm aber gestartet wird, erhÑlt
 * das Acc. diese Nachricht erst nach dem Start des Programms, da
 * die Routine, die den Pexec macht nicht mehr wissen kann, das ein
 * Acc. noch schnell eine Nachricht bekommen muû. Bei einem GEM-
 * Programm, kann man der Erfolg auch an dem AC_CLOSE erkennen.
 * Auch ist die Fehlererkennung nicht optimal. Der RÅckgabewert weist
 * auch nicht aus, das das Programm fehlerfrei gelaufen ist.
 *
 * Word 4   Returncode des gestarteten Programms (so vorhanden)
 * Word 7   16-Bit Wort aus AV_STARTPROG
 *)
CONST VA_PROGSTART = $4723;

(* AV_ACCWINDOPEN: Mit dieser Nachricht kann ein Acc Venus mitteilen, daû
 * es ein Fenster geîffnet hat.
 * Word 3 AES-Handle des geîffneten Fensters
 *)
CONST AV_ACCWINDOPEN = $4724;

(* VA_DRAGACCWIND: Venus teilt dem Acc mit, daû Objekte auf eines seiner
 * mittels AV_ACCWINDOPEN angemeldeten Fenster gezogen worden sind.
 * Word 3   AES-Handle des Fensters
 * Word 4   X-Position der Maus
 * Word 5   Y-Position der Maus
 * Word 6+7 Pointer auf einen String, der die Namen der Objekte enthÑlt.
 *)
CONST VA_DRAGACCWIND = $4725;

(* AV_ACCWINDCLOSED: Acc teilt Venus mit, daû sein Fenster geschlossen
 * wurde. Dies braucht das Acc nur in dem Fall zu tun, wenn es selbst das
 * Fenster schlieût. Bekommt es eine AC_CLOSE Mitteilung vom AES, so weiû
 * Venus schon, daû alle Fenster weg sind.
 * Word 3   AES-Handle des Fensters
 *)
CONST AV_ACCWINDCLOSED = $4726;


(* Neu seit dem 11.04.1991!!!
 *)
 
(* AV_COPY_DRAGGED: Accessorie teilt Venus mit, daû die Objekte,
 * die auf sein Fenster gezogen wurden, zu kopieren sind.
 * Dies kann z.B. nach dem Ziehen von Objekten auf das TreeView-
 * Fenster erwÅnscht sein. Diese Nachricht ist nur als Antwort
 * auf VA_DRAGACCWIND gedacht.
 * Word 3	Tastaturstatus (Alternate, Control, Shift), der bei
 *          der VA_DRAGACCWIND-Nachricht Åbergeben wurde
 * Word 4+5	Pointer auf einen String, der den Namen des Zielobjektes 
 *			enthÑlt. Dies *muû* ein Pfad sein!
 *)
CONST AV_COPY_DRAGGED = $4728;

(* VA_COPY_COMPLETE: Antwort auf AV_COPY. 
 * Word 3	Status des Kopierens. (!= 0 heiût, daû wirklich etwas
 *			kopiert oder verschoben wurde. Dies kann das Acc evtl.
 *          zum Neuaufbau seines Fensters nutzen.)
 *)
CONST VA_COPY_COMPLETE = $4729;

(* AV_PATH_UPDATE: Programm/Accessory teilt Gemini mit, daû sich
 * der Inhalt eines Verzeichnisses geÑndert hat. Gemini stellt dann
 * dieses Verzeichnis (so ein Fenster davon offen ist) neu dar. Dies
 * wirkt auch auf die Unterverzeichnisse; Update von "C:\" sorgt
 * dafÅr, daû alles, was mit Laufwerk C:\ zu tun hat, neu eingelesen
 * wird.
 *
 * Word 3+4 Pointer auf den absolten Pfad
 *)
CONST AV_PATH_UPDATE = $4730;

(* AV_WHAT_IZIT: Programm/Accessory fragt Gemini, was sich an 
 * Position X/Y auf dem Bildschirm befindet. Die Koordinaten sind
 * normale Pixelkoordinaten mit Ursprung in der linken oberen
 * Bildschirmecke. Antwort ist VA_THAT_IZIT.
 * Word 3   X-Koordinate
 * Word 4   Y-Koordinate
 *)
CONST AV_WHAT_IZIT = $4732;

(* VA_THAT_IZIT:
 * Word 3   ID der zustÑndigen Applikation
 * Word 4   Typ des Objektes
 * word 5+6 Zeiger auf den Namen des Objektes (oder NULL, falls nicht 
 *          vorhanden)
 *
 * Typ ist wie folgt: (alle anderen fÅr Erweiterungen reserviert.)
 *)
CONST VA_OB_UNKNOWN =    0;
CONST VA_OB_TRASHCAN =   1;
CONST VA_OB_SHREDDER =   2;
CONST VA_OB_CLIPBOARD =  3;
CONST VA_OB_FILE =       4;
CONST VA_OB_FOLDER =     5;
CONST VA_OB_DRIVE =      6;
CONST VA_OB_WINDOW =     7;

CONST VA_THAT_IZIT = $4733;

(* AV_DRAG_ON_WINDOW: Programm/Accessory teilt Gemini mit, daû 
 * Objekte auf eines seiner mittels AV_WHATIZIT erfragten Fenster 
 * gezogen worden sind. Die Namen sind Namen von Dateien, Ordnern
 * oder Laufwerken, jeweils durch ein Leerzeichen getrennt. Namen
 * von Ordnern oder Laufwerken enden mit einem Backslash.
 *
 * Word 3   X-Position, wohin die Maus gezogen wurde
 * Word 4   Y-Position, wohin die Maus gezogen wurde
 * Word 5   Tastaturstatus (Shift,Control,Alternate)
 * Word 6+7 Pointer auf einen String, der die Namen der Objekte enthÑlt.
 *
 * (nun implementiert, beachte daû sich die Belegung der Nachricht
 *  leicht geÑndert hat. Das Fenster handle ist verschwunden und 
 *  dafÅr wurde der aktuelle Tastaturstatus eingefÅgt.)
 *
 *)
CONST AV_DRAG_ON_WINDOW	= $4734;

(* VA_DRAG_COMPLETE: Die Aktion, die mittels AV_DRAG_ON_WINDOW
 * ausgelîst wurde (Kopieren, Verschieben, Lôschen oder ablegen
 * auf den Hintergrund) ist beendet. Bei Erfolg wird ein Wert
 * wie bei AV_COPY_COMPLETE zurÅckgeliefert.
 * Word 3	Status der Aktion. (!= 0 heiût, daû wirklich etwas
 *			kopiert oder verschoben wurde. Dies kann das Acc evtl.
 *          zum Neuaufbau seines Fensters nutzen.)
 *)
CONST VA_DRAG_COMPLETE = $4735;

(* AV_EXIT: Ein Programm/Accessory teilt Gemini mit, daû es nicht
 * mehr am Protokoll teilnimmt (normalerweisem, weil es beendet
 * wurde).
 * Word 3   AES-ID des Programms/Accessories
 *)
CONST AV_EXIT = $4736;

IMPLEMENTATION

END (*AV_Protokoll*).