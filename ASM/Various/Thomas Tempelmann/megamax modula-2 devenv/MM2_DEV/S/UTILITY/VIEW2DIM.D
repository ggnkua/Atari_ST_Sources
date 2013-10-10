DEFINITION MODULE View2Dim;

(*
 * Thomas Tempelmann, 19.1.94
 *
 *  Das Modul dient zur Verwaltung von Fenstern fÅr die Darstellung von
 *  rechteckigen Feldern. Die Bedingungen sind Ñhnlich wie bei TextWindows,
 *  nur, daû anstatt von einzelnen Zeichen als Felder die Inahlte und die
 *  Grîûe der Felder frei definierbar sind. Allerdings mÅssen alle Felder
 *  dieselbe Grîûe haben.
 *  Dieses Modul kÅmmert sich dann um die Bedienung und das Scrollen des
 *  Fensters und ruft lediglich eine benutzerdefinierte Funktion auf, die
 *  zum Zeichnen eines Feldes auffordert.
 *
 *  So wÑre z.B. eine Anwendung denkbar zur Anzeige eines Kalenders.
 *  Man îffnet ein Fenster mit 7 Feldern in X- und 5 Feldern in Y-Richtung.
 *  Dazu braucht dann lediglich eine Prozedur erstellt werden, die in ein
 *  Feld (mit X-/Y-Angabe) die Datumsangaben hineinzeichnet. Die Grîûe
 *  dieser Felder muû beim Erzeugen des Fensters ebenfalls angegeben werden,
 *  kann aber nachtrÑglich geÑndert werden.
 *  
 *  Die aktuelle Implementierung des Moduls setzt auf den AES-Fenstern des
 *  GEM auf. Trotzdem ist es fÅr den Benutzer dieses Moduls nicht nîtig, daû
 *  er sich mit den Details der AES-Fensterprogrammierung auskennt. Wird re-
 *  gelmÑûig die Prozedur 'EventHandler.HandleEvents' oder 'EventMulti'
 *  aufgerufen, so ist es nicht nîtig, weitere AES-Routinen zu verwenden.
 *  Lediglich zum Darstellen der Fensterinhalte werden das VDI oder eigenen
 *  Grafikroutinen benîtigt.
 *)

FROM SYSTEM     IMPORT ADDRESS;
FROM GEMEnv     IMPORT DeviceHandle;
FROM GrafBase   IMPORT Point, Rectangle;
FROM GEMGlobals IMPORT SpecialKeySet, MButtonSet;
IMPORT WindowBase;

TYPE    CellWindow;             (* Das Window-Handle *)

        CellPnt = RECORD        (* Die Koordinaten eines Feldes *)
          x, y: CARDINAL;       (* links oben ist (0/0)         *)
        END;

        CellRect = RECORD       (* Die Ausmaûe jedes der Felder *)
          CASE : BOOLEAN OF
            TRUE:  pnt: CellPnt|
            FALSE: x, y: CARDINAL
          END;
          w, h: CARDINAL;
        END;
        
        ButEvRec = RECORD
          clicks: CARDINAL;
          mouseLoc: Point;
          buttons: MButtonSet;
          metaKeys: SpecialKeySet
        END;
        
        (*
         * Die Prozedur zum Darstellen eines Felder im Fenster
         * ('cell' ist die Feldkoordinate, 'frame' der Feldbereich,
         * in dem zu zeichnen ist, 'clip' der Clipping-Bereich,
         * der ggf. 'frame' einschrÑnkt):
         *)
        UpdateCellProc   = PROCEDURE ((* wdw   : *) CellWindow,
                                      (* env   : *) ADDRESS,
                                      (* cell  : *) CellPnt,
                                      (* frame : *) Rectangle,
                                      (* clip  : *) Rectangle,
                                      (* device: *) DeviceHandle);
        
        (*
         * Die Prozedur wird aufgerufen, wenn ein Feld mit der
         * Maus angeklickt wurde.
         *)
        ActivateCellProc = PROCEDURE ((* wdw   : *) CellWindow,
                                      (* env   : *) ADDRESS,
                                      (* cell  : *) CellPnt,
                                      (* frame : *) Rectangle,
                                      (* event : *) ButEvRec,
                                      (* device: *) DeviceHandle): BOOLEAN;

        (*
         * Wird aufgerufen, wenn das Fenster vom Benutzer oder vom
         * System geschlossen wurde.
         *)
        CloseCellWdwProc    = PROCEDURE ((* wdw: *) CellWindow,
                                         (* env: *) ADDRESS): BOOLEAN;


CONST   NoCellWindow  = CellWindow (WindowBase.NoWindow);


                        (*  Fensterverwaltung  *)
                        (*  =================  *)

PROCEDURE CreateCellWindow (VAR wdw            : CellWindow;
                                cellSizeX      : CARDINAL;
                                cellSizeY      : CARDINAL;
                                cellsX, cellsY : CARDINAL;
                                infoLine       : BOOLEAN;
                                drawGrid       : BOOLEAN;
                                redrawServer   : UpdateCellProc;
                                activateServer : ActivateCellProc;
                                closeServer    : CloseCellWdwProc;
                                serverEnv      : ADDRESS);
  (*
   * Erzeugt ein Fenster, îffnet es aber noch nicht.
   * 'cellSizeX/Y' bestimmen die Grîûe der Felder in Pixeln.
   * 'cellsX/Y' bestimmen die Anzahl der Felder in beiden Richtungen.
   * 'infoLine' bestimmt, ob eine Infozeile im Fenster angezeigt werden soll.
   * 'drawGrid' lÑût ggf. ein Gitter zwischen den Feldern zeichnen.
   * '...Server' sind die Prozeduren, deren Funktion oben beschrieben ist.
   * 'serverEnv' ist ein konstanter Wert, der an die Server-Prozeduren
   *    immer Åbergeben wird. Damit lassen sich mehrere Fenster mit ver-
   *    schiedenen Eigentschaften ggf. Åber die selben Server-Procs bedienen.
   *)

PROCEDURE DeleteCellWindow (VAR wdw: CellWindow);
  (*
   * Entfernt Fenster und gibt belegten Speicher frei.
   *)

PROCEDURE OpenCellWindow (wdw: CellWindow);
PROCEDURE CloseCellWindow (wdw: CellWindow);
  (*
   * ôffnet bzw. schlieût das Fenster auf dem Bildschirm.
   *)

PROCEDURE SpecifyCellWindow (wdw: CellWindow;
                             cellSizeX, cellSizeY, cellsX, cellsY: CARDINAL;
                             drawGrid: BOOLEAN);
  (*
   * Setzt einige der bei 'CreateWindow' spezifizierten Werte neu.
   *)

PROCEDURE RedrawCell (wdw: CellWindow; pos: CellPnt);
  (*
   * LÑût ein Feld neuzeichnen, falls es gerade sichtbar ist
   * (ist aufzurufen, wenn die Daten des Feldes verÑndert wurden).
   *)

PROCEDURE Win (wdw: CellWindow): WindowBase.Window;
  (*
   * Liefert den Handle des von WindowBase verwalteten Fensters.
   * Damit kann auf Informationen zugegriffen werden, die nur
   * Åber das WindowBase-Modul verfÅgbar sind (z.B. Abfragen der
   * Position des Fensters bzw. Neusetzen seiner Position mittels
   * '(Set)WindowWorkArea' oder Hervorholen mit 'PutWindowOnTop').
   *)

PROCEDURE CellWin (win: WindowBase.Window): CellWindow;
  (*
   * Umkehrung zur 'Win': Liefert das CallWindow-Handle eines
   * WindowBase-Fensters, falls es ein Fenster dieses Moduls ist.
   * Liefert bei fremden Fenstern 'NoCellWindow'.
   *)

PROCEDURE DevHdl (): DeviceHandle;
  (*
   * Liefert den von allen hiesigen Fenstern verwendeten Device-Handle,
   * um z.B. bestimmte VDI-Attribute vorzubesetzen.
   *)

PROCEDURE VisibleCells (wdw: CellWindow): CellRect;
  (* Liefert Bereich der gerade sichtbaren Felder *)

PROCEDURE MidCell (wdw: CellWindow): CellPnt;
  (* Liefert Mitte der gerade sichtbaren Felder *)

PROCEDURE TopLeftCell (wdw: CellWindow): CellPnt;
  (* Liefert Koordinate des sichtbaren Feldes links oben *)

PROCEDURE SetMid (wdw: CellWindow; cell: CellPnt);
  (* Setzt Mitte der gerade sichtbaren Felder *)

PROCEDURE SetTopLeft (wdw: CellWindow; cell: CellPnt);
  (* Setzt Koordinate des sichtbaren Feldes links oben *)

PROCEDURE SuppressUpdate (wdw: CellWindow);
PROCEDURE AllowUpdate (wdw: CellWindow; force: BOOLEAN);
  (*
   * éhnlich AESWindows.UpdateWindow(): Solange SuppressUpdate îfter
   * als AllowUpdate aufgerufen ist, werden keine Update-Anforderungen
   * ausgefÅhrt sondern schlicht ignoriert.
   * Mit 'force=TRUE' wird zudem erreicht, daû der ZÑhler wieder ganz
   * rÅckgesetzt wird.
   *)

END View2Dim.
