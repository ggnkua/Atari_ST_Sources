/*
 * @(#) Gemini\vaproto.h
 * @(#) Stefan Eissing, 11. Dezember 1994
 *
 *
 * Beschreibung: Definition der Nachrichten des Venus <-> Accessory
 * Protokolls
 *
 * 07.12.: AV_PATH_UPDATE, AV_WHAT_IZIT, AV_DRAG_ON_WINDOW eingebaut.
 * 21.10.94: AV_STARTED 
 * 31.10.94: AV_XWIND und VA_FONTCHANGED eingefÅhrt.
 *           Siehe auch die neue Bitbelegung in PROTOSTATUS
 * 12.11.94  Neues Bit im PROTOSTATUS des Accessories zum "Quoten"
 *           von Dateinamen
 */

#ifndef __vaproto__
#define __vaproto__

/* Message-Nummern fÅr das xAcc-Protokoll von Konrad Hinsen
 * Venus gibt bei ACC_ID "VENUS.APP" und Gemini gibt "GEMINI.APP"
 * zurÅck. Gemini unterstÅtzt xAcc der Stufe 0.
 */
#define ACC_ID		0x400
#define ACC_OPEN	0x401
#define ACC_CLOSE	0x402
#define ACC_ACC		0x403

/* Message-Nummern fÅr die Kommunikation zwischen Venus und
 * verschiedenen Accesories.
 * Sollten in Nachrichten Pfade oder Dateinamen vorkommen, so
 * muû immer der absolute Pfad angegeben werden (also mit Laufwerk)
 * und die Laufwerksbuchstaben mÅssen Groûbuchstaben sein. Pfade 
 * sollten immer mit einem Backslash enden!
 * Neu seit dem 12.11.94 ist, daû optional Namen auch mit einfachen
 * AnfÅhrungszeichen versehen werden kînnen. Siehe AV_PROTOKOLL.
 *
 * Nachrichten von Venus beginnen mit VA (Venus -> Accessory).
 * Nachrichten an Venus beginnen mit AV (Accessory -> Venus).
 *
 * Mit AV_PROTOKOLL kann jedes Acc nachfragen, welche Nachrichten
 * verstanden werden (Dies ist ja bei VENUS und GEMINI 
 * unterschiedlich! Es wÑre schîn, wenn auch andere Programme auf
 * dieses Protokoll reagieren wÅrden. Zumindest AV_SENDKEY ist
 * sicher leicht zu implementieren und ist die einzige Methode, wie
 * Åber Nachrichten TastaturdrÅcke simuliert werden kînnen.
 *
 * Unter normalem TOS fragt dazu ein Accessory, wenn es eine
 * AC_CLOSE-Nachricht vom AES erhalten hat, die Applikation 0
 * mit AV_PROTOKOLL, ob sie etwas davon versteht.
 * Unter MultiTOS muû aber das Programm nicht mehr die ID 0
 * haben, zudem kommt es (fast) nicht mehr zu AC_CLOSE-Nachrichten.
 * Es kînnen auch nicht nur Accessories, sondern auch normale
 * Programme mit Gemini kommunizieren wollen. Was tun?
 * Wenn es mehr als eine Hauptapplikation geben kann, dann sollte
 * das Programm/Accessory versuchen, mit GEMINI Kontakt aufzunehmen.
 * Die ID kann ja mit appl_find ermittelt werden. Scheitert dies, so
 * kann noch nach AVSERVER oder dem Inhalt der (AES-)Environmentvariable
 * AVSERVER gesucht werden. Besonders die letzte Mîglichkeit erlaubt
 * eine leichte Konfiguration "von auûen". Die neuen Versionen der
 * Library VAFUNC von Stephan Gerle (in gutsortierten Mailboxen
 * erhÑltlich) verfahren fast genauso.
 */

/* AV_PROTOKOLL: Mit dieser Nachrichtennummer sollte man bei 
 * anderen Applikationen und auch GEMINI nachfragen, ob
 * und welche Nachrichten sie versteht.
 */

#define AV_PROTOKOLL		0x4700
/*
 * Word 6+7: Pointer auf den Accessorynamen, wie er bei
 *           appl_find benutzt werden muû; also 8 Zeichen lang
 *           nullterminiert (char name[9]).
 * Die Bits in den Worten 3, 4 und 5 haben folgende Bedeutung:
 * Word 3:
 * Bit 0:		(VA_SETSTATUS)
 * Bit 1:		(VA_START)
 * Bit 2:       (AV_STARTED)
 * Bit 3:       (VA_FONTCHANGED)
 * Bit 4:       (Versteht und benutzt Quoting von Dateinamen)
 *
 * Alle anderen Bits sind fÅr Erweiterungen reserviert und sollten
 * daher mit 0 vorbesetzt werden. Das gilt natÅrlich auch fÅr die
 * Bits in den Worten 4 und 5.
 * (Mehr zum Quoting siehe unten)
 */
 
/* Macros zum Testen des Protkollstatus auf Quoting
 */
#define VA_ACC_QUOTING(a)		((a) & 0x10)
#define VA_SERVER_QUOTING(a)	((a) & 0x40)

/* VA_PROTOSTATUS: Dem Sender von AV_PROTOKOLL wird mitgeteilt, daû
 * der EmpfÑnger etwas von diesem Protokoll weiû. Die Worte 3-7 des
 * Nachrichtenpuffers enthalten die Information, welche Nachrichten
 * verstanden werden. Gesetzte Bits stehen dafÅr, daû eine Nachricht
 * (Nachrichtengruppe) verstanden werden. 
 */
#define VA_PROTOSTATUS		0x4701
/*
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
 * Bit 11       (AV_XWIND)
 * Bit 12       (VA_FONTCHANGED)
 * Bit 13		(AV_STARTED)
 * Bit 14       (Versteht und benutzt Quoting von Dateinamen)
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
 *
 * Zu Bit 14 (im Server, z.B. Gemini), bzw. Bit 4 im Client 
 * (Accessory):
 * Mit "Quoting" ist im VA-Protkoll gemeint, daû Dateinamen optional
 * mit einfachen AnfÅhrungszeichen 'name' versehen werden kînnen.
 * Dies ist aber nur erlaubt, wenn beide Parteien (Server und Client)
 * sich darÅber einig sind (lies: beide es verstehen kînnen).
 * Wie geht das also vor sich? Angenommen Gemini schickt an ein
 * Accessory einen Dateinamen, der ein Leerzeichen enthÑlt. Ein Acc,
 * das Quoting nicht kann, wird statt einem zwei Dateinamen erkennen,
 * da normalerweise Leerzeichen Dateinamen trennen.
 * Versteht das Acc aber Quoting (Bit 4 in seinem Protokollstatus),
 * so wird Gemini den Dateinamen mit '' umgeben und das Acc erkennt,
 * daû das Leerzeichen zum Dateinamen gehîrt.
 * Gleiches gilt natÅrlich auch fÅr Dateinamen, die von einem Acc
 * an einen Server geschickt werden. Die Frage bleibt, wie man denn
 * nun einfache AnfÅhrungszeichen ÅbertrÑgt. Nun, solche Zeichen,
 * die zum Dateinamen gehîren, werden einfach verdoppelt. Aus
 * Julian's Profibuch wird fÅr die öbertragung 'Julian''s Profibuch'.
 * Einfach nicht? Nun, die Idee stammt nicht von mir, sondern wird
 * genauso auch in Atari's Drag&Drop Protokoll benutzt.
 */

/* AV_GETSTATUS: Ein Accessory erfragt bei Venus den aktuellen
 * Status, den es Venus mit AV_STATUS mal gegeben hat.
 */
#define AV_GETSTATUS		0x4703

/* AV_STATUS: Ein Accessory kann Venus seinen Status mitteilen,
 * der dann von Venus im INF-File gespeichert wird und mit
 * AV_GETSTATUS wieder abgerufen werden kann.
 * Zuvor MUSS es sich aber mit AV_PROTOKOLL anmelden!
 * Word 3+4: Pointer auf einen String, der keine Steuerzeichen
 *           enthalten darf und nicht lÑnger als 256 Zeichen
 *           sein darf. Dieser Pointer darf allerdings NULL sein.
 */
#define AV_STATUS			0x4704

/* VA_SETSTATUS: Venus teilt dem Accessory den abgespeicherten
 * Status bei Nachfrage durch AV_GETSTATUS mit. Dieser kann dann 
 * von einem Accessory gesetzt werden.
 * Word 3+4: Pointer auf einen String, der keine Steuerzeichen
 *           enthÑlt.
 *           Dieser Pointer kann allerdings NULL sein, dann war
 *           kein Status gespeichert.
 */
#define VA_SETSTATUS		0x4705

/* AV_SENDKEY: Ein Acc sendet VENUS/GEMINI einen Tastaturevent, den
 * es selber vielleicht nicht versteht.
 * Word 3 = Tastaturstatus                 ev_mmokstate
 * Word 4 = Scancode der gedrÅckten Taste  ev_mkreturn
 */
#define	AV_SENDKEY			0x4710

/* VA_START: Accessory wird aktiviert. Word 3 + 4 enthalten einen
 * Pointer auf eine Kommandozeile, der auch NULL sein kann.
 * In der Kommandozeile stehen Pfade oder Dateinamen.
 */
#define VA_START			0x4711

/* AV_ASKFILEFONT: Frage nach dem eingestellten Zeichensatz
 * fÅr Dateinamen.
 */
#define AV_ASKFILEFONT		0x4712

/* VA_FILEFONT: Gibt den derzeit eingestellten Zeichensatz.
 * Word 3 = Dateifontnummer (font id)
 * Word 4 = Dateifontgrîûe (in points)
 */
#define VA_FILEFONT			0x4713

/* (Nur Gemini) AV_ASKCONFONT: Frage nach dem eingestellten 
 * Zeichensatz fÅr das Console-Fenster.
 */
#define AV_ASKCONFONT		0x4714

/* VA_CONFONT: Gibt den derzeit eingestellten Zeichensatz.
 * Word 3 = Consolefontnummer (font id)
 * Word 4 = Consolefontgrîûe (in points)
 */
#define VA_CONFONT			0x4715

/* AV_ASKOBJECT: Fragt nach dem derzeit selektiertem Objekt.
 * Es wird der Name des derzeit selektierten Objektes zurÅckgegeben.
 * Ist kein Objekt selektiert, so ist der String leer.
 * Sind mehrere Objekte selektiert, so sind ihre Namen durch Leer-
 * zeichen getrennt.
 */
#define AV_ASKOBJECT	0x4716

/* VA_OBJECT: Gibt Namen der derzeit selektierten Objekte.
 * Aufbau wie bei VA_START
 */
#define VA_OBJECT		0x4717

/* (Nur Gemini)AV_OPENCONSOLE: Venus soll das Console-Fenster îffnen.
 * Ist es schon offen, so wird es nach vorne gebracht. Diese Aktion
 * ist vor allen Dingen sinnvoll, wenn ein Accessory ein TOS-Programm
 * mittels der system()-Funktion starten will (Warnung: Auf keinen
 * Fall darf ein GEM-Programm von einem Accessory via system() 
 * gestartet werden! (siehe auch AV_STARTPROG)
 * Auch sollte diese Nachricht nur auf ausdrÅcklichen Wunsch des
 * Benutzers gebraucht werden, da es ihn sonst nur verwirren kann.
 *
 * ACHTUNG: Diese Nachricht steht nur in Gemini.app zur VerfÅgung.
 */
#define AV_OPENCONSOLE	0x4718

/* VA_CONSOLEOPEN: Gibt zurÅck, ob das Console-Fenster nach vorne
 * gebracht worden ist. Word 3 == 0 (nein) != 0 (ja)
 */
#define VA_CONSOLEOPEN	0x4719

/* AV_OPENWIND: Venus soll ein Datei-Fenster îffnen.
 * Dies sollte auch nur geschehen, wenn die Ursache fÅr den
 * Benutzer ersichtlich ist.
 * Word 3+4 (Pointer) Pfad fÅr das Fenster (s.o.).
 * Word 5+6 (Pointer) Wildcard fÅr darzustellende Dateien.
 */
#define AV_OPENWIND		0x4720

/* VA_WINDOPEN: Gibt an, ob das Fenster geîffnet werden konnte.
 * siehe VA_CONSOLEOPEN
 */
#define VA_WINDOPEN		0x4721


/* Word 7 in AV_STARTPROG und Word 4 und 7 in VA_PROGSTART sind
 * neu seit dem 29. MÑrz 1992.
 */
 
/* AV_STARTPROG: Venus soll ein Programm starten. Hierbei
 * werden die angemeldeten Applikationen der Venus mit
 * berÅcksichtigt. Man kann also auch eine Datei angeben, fÅr
 * die Venus dann ein Programm sucht.
 * Word 3+4 (Pointer) Programmname mit kompletten Pfad
 * Word 5+6 (Pointer) Kommandozeile (kann NULL sein)
 * Word 7   Beliebiges 16-Bit Wort, das in VA_PROGSTART wieder
 *          zurÅckgeliefert wird.
 */
#define AV_STARTPROG	0x4722

/* VA_PROGSTART: Gibt an, ob Venus das Programm startet.
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
 */
#define VA_PROGSTART	0x4723

/* AV_ACCWINDOPEN: Mit dieser Nachricht kann ein Acc Venus mitteilen, daû
 * es ein Fenster geîffnet hat.
 * Word 3 AES-Handle des geîffneten Fensters
 */
#define AV_ACCWINDOPEN	0x4724

/* VA_DRAGACCWIND: Venus teilt dem Acc mit, daû Objekte auf eines seiner
 * mittels AV_ACCWINDOPEN angemeldeten Fenster gezogen worden sind.
 * Word 3   AES-Handle des Fensters
 * Word 4   X-Position der Maus
 * Word 5   Y-Position der Maus
 * Word 6+7 Pointer auf einen String, der die Namen der Objekte enthÑlt.
 */
#define VA_DRAGACCWIND	0x4725

/* AV_ACCWINDCLOSED: Acc teilt Venus mit, daû sein Fenster geschlossen
 * wurde. Dies braucht das Acc nur in dem Fall zu tun, wenn es selbst das
 * Fenster schlieût. Bekommt es eine AC_CLOSE Mitteilung vom AES, so weiû
 * Venus schon, daû alle Fenster weg sind.
 * Word 3   AES-Handle des Fensters
 */
#define AV_ACCWINDCLOSED	0x4726


/* Neu seit dem 11.04.1991!!!
 */
 
/* AV_COPY_DRAGGED: Accessorie teilt Venus mit, daû die Objekte,
 * die auf sein Fenster gezogen wurden, zu kopieren sind.
 * Dies kann z.B. nach dem Ziehen von Objekten auf das TreeView-
 * Fenster erwÅnscht sein. Diese Nachricht ist nur als Antwort
 * auf VA_DRAGACCWIND gedacht.
 * Word 3	Tastaturstatus (Alternate, Control, Shift)
 * Word 4+5	Pointer auf einen String, der den Namen des Zielobjektes 
 *			enthÑlt. Dies *muû* ein Pfad sein!
 */
#define AV_COPY_DRAGGED		0x4728

/* VA_COPY_COMPLETE: Antwort auf AV_COPY. 
 * Word 3	Status des Kopierens. (!= 0 heiût, daû wirklich etwas
 *			kopiert oder verschoben wurde. Dies kann das Acc evtl.
 *          zum Neuaufbau seines Fensters nutzen.)
 */
#define VA_COPY_COMPLETE	0x4729


/* AV_PATH_UPDATE: Programm/Accessory teilt Gemini mit, daû sich
 * der Inhalt eines Verzeichnisses geÑndert hat. Gemini stellt dann
 * dieses Verzeichnis (so ein Fenster davon offen ist) neu dar. Dies
 * wirkt auch auf die Unterverzeichnisse; Update von "C:\" sorgt
 * dafÅr, daû alles, was mit Laufwerk C:\ zu tun hat, neu eingelesen
 * wird.
 *
 * Word 3+4 Pointer auf den absolten Pfad
 */
#define AV_PATH_UPDATE		0x4730


/* AV_WHAT_IZIT: Programm/Accessory fragt Gemini, was sich an 
 * Position X/Y auf dem Bildschirm befindet. Die Koordinaten sind
 * normale Pixelkoordinaten mit Ursprung in der linken oberen
 * Bildschirmecke. Antwort ist VA_THAT_IZIT.
 * Word 3   X-Koordinate
 * Word 4   Y-Koordinate
 */
#define AV_WHAT_IZIT		0x4732

/* VA_THAT_IZIT:
 * Word 3   ID der zustÑndigen Applikation
 * Word 4   Typ des Objektes
 * word 5+6 Zeiger auf den Namen des Objektes (oder NULL, falls nicht 
 *          vorhanden)
 *
 * Typ ist wie folgt: (alle anderen fÅr Erweiterungen reserviert.)
 */
#define	VA_OB_UNKNOWN	0		
#define VA_OB_TRASHCAN  1
#define VA_OB_SHREDDER  2
#define VA_OB_CLIPBOARD 3
#define VA_OB_FILE      4
#define VA_OB_FOLDER	5
#define VA_OB_DRIVE		6
#define VA_OB_WINDOW    7

#define VA_THAT_IZIT		0x4733

/* AV_DRAG_ON_WINDOW: Programm/Accessory teilt Gemini mit, daû 
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
 */
#define AV_DRAG_ON_WINDOW	0x4734

/* VA_DRAG_COMPLETE: Die Aktion, die mittels AV_DRAG_ON_WINDOW
 * ausgelîst wurde (Kopieren, Verschieben, Lôschen oder ablegen
 * auf den Hintergrund) ist beendet. Bei Erfolg wird ein Wert
 * wie bei AV_COPY_COMPLETE zurÅckgeliefert.
 * Word 3	Status der Aktion. (!= 0 heiût, daû wirklich etwas
 *			kopiert oder verschoben wurde. Dies kann das Acc evtl.
 *          zum Neuaufbau seines Fensters nutzen.)
 */
#define VA_DRAG_COMPLETE	0x4735

/* AV_EXIT: Ein Programm/Accessory teilt Gemini mit, daû es nicht
 * mehr am Protokoll teilnimmt (normalerweisem, weil es beendet
 * wurde).
 * Word 3   AES-ID des Programms/Accessories
 */
#define AV_EXIT				0x4736

/* AV_STARTED: Ein Programm/Accessory teilt Gemini mit, daû es
 * die VA_START Nachricht verstanden hat und der Speicher des
 * Strings, der an die Nachricht angehÑngt war, freigegeben werden
 * kann. Zum Erkennen um welche VA_START Nachricht es sich handelt,
 * werden die Werte von VA_START zurÅckgeliefert.
 * Word 3+4: exakt derselbe Inhalt der VA_START Nachricht.
 */
#define AV_STARTED          0x4738

/* VA_FONTCHANGED: Einer der in Gemini eingestellen Fonts hat
 * sich geÑndert. Wird an alle Applikationen geschickt, die schon
 * mal den Font von Gemini erfragt haben.
 *
 * Word 3 = Dateifontnummer   (font id)
 * Word 4 = Dateifontgrîûe    (in points)
 * Word 5 = Consolefontnummer (font id)
 * Word 6 = Consolefontgrîûe  (in points)
 */
#define VA_FONTCHANGED		0x4739

/* AV_XWIND: Venus soll ein Datei-Fenster îffnen (eXtended).
 * Dies sollte auch nur geschehen, wenn die Ursache fÅr den
 * Benutzer ersichtlich ist.
 * Word 3+4 (Pointer) Pfad fÅr das Fenster (s.o.).
 * Word 5+6 (Pointer) Wildcard als Filter fÅr Anzeige
 * Word 7   Bitmaske  0x0001 - toppe evtl. vorhandenes Fenter
 *                    0x0002 - Wildcard soll nur selektieren
 *                           - alle anderen Bits auf 0 setzen!
 */
#define AV_XWIND		0x4740

/* VA_XOPEN: Gibt an, ob das Fenster geîffnet werden konnte.
 * (Word 3 == 0 (nein) != 0 (ja))
 */
#define VA_XOPEN		0x4741

#endif