DEFINITION MODULE GrafBase;


(*  Definition der grundlegenden Typen fÅr die Grafikbibliotheken des
 *  Megamax Modula-2 Entwicklungspackets. Auûerdem Routinen zur Ver-
 *  arbeitung dieser Strukturen.
 *
 *  Autor: Manuel Chakravarty           Erstellt: 28.10.87
 *
 *  Version   2.1     V#0016
 *)
 
 
(*  Dieses Modul enthÑlt grundlegende Grafikstrukturen, die sowohl von
 *  dem Modul 'LineA', als auch von den GEM-Moduln benutzt werden.
 *)
 
 
FROM SYSTEM IMPORT WORD, ADDRESS;
 
 
CONST           (* Standard Farbenpalette *)

        white           = 0;
        black           = 1;
        red             = 2;
        green           = 3;
        blue            = 4;
        cyan            = 5;
        yellow          = 6;
        magenta         = 7;
        lwhite          = 8;
        lblack          = 9;
        lred            = 10;
        lgreen          = 11;
        lblue           = 12;
        lcyan           = 13;
        lyellow         = 14;
        lmagenta        = 15;
        
        
TYPE    WritingMode     = (replaceWrt, transWrt, xorWrt, reverseWrt);
        
        (*  Es bedeutet dabei:
         *
         *  'replaceWrt' -- Die Zeichnung verdeckt den Hintergrund.
         *                  (Wird meistens benutzt)
         *  'transWrt'   -- Die Zeichnung ist durchsichtigt,
         *                  d.h ist in der Zeichenmaske ein Punkt
         *                  nicht besetzt, so scheint der aktuelle
         *                  Hintergrund durch.
         *                  (entspricht einer ODER-VerknÅpfung)
         *  'eorWrt'     -- Die Zeichnung wird mit dem Hintergrund ex-
         *                  clusiv-oder verknÅpft. Dieser Modus hat
         *                  unter anderem zur Folge, daû zweimaliges
         *                  Zeichnen derselben Zeichnung den Hinter-
         *                  grund wieder restauriert.
         *  'reverseWrt' -- Auch hier ist die Zeichnung durchsichtigt,
         *                  aber diesmal scheint der Hintergrund an den
         *                  Punkten durch, die in der Zeichenmaske ge-
         *                  setzt sind
         *)
         
         
        BitOperation    = (allZero, sAndD, sAndNotD, onlyS,
                           notSAndD, onlyD, sXorD, sOrD,
                           not0SOrD, not0SXorD, notD, sOrNotD,
                           notS, notSOrD, not0SAndD, allOne);
        
        (*  Die Operationen sind folgendermaûen definiert:
         *
         *   allZero   --  Zn = 0           (Ziel wird vollstÑndig gelîscht)
         *   sAndD     --  Zn = Q & Z
         *   sAndNotD  --  Zn = Q & ~Z
         *   onlyS     --  Zn = Q           (Zielbereich wird einfach ersetzt)
         *   notSAndD  --  Zn = ~Q & Z      (Quelle lîscht Zielbereich)
         *   onlyD     --  Zn = Z           (Ziel bleibt erhalten)
         *   sXorD     --  Zn = Q xor Z     (Exclusiv-Oder VerknÅpfung)
         *   sOrD      --  Zn = Q | Z       (Transparent)
         *   not0SOrD  --  Zn = ~(Q | Z)    (Transparent und invertiert)
         *   not0SXorD --  Zn = ~(Q xor Z)
         *   notD      --  Zn = ~Z
         *   sOrNotD   --  Zn = Q | ~Z
         *   notS      --  Zn = ~Q          (Kopiert invertierten Quellbereich)
         *   notSOrD   --  Zn = ~Q | Z
         *   not0SAndD --  Zn = ~(Q & Z)
         *   allOne    --  Zn = 1           (Ziel wird vollstÑndig gesetzt)
         *
         *  Dabei ist:
         *              'Q'   -- Bits im Quellbereich
         *              'Z'   -- Bits im Zielbereich (vor der VerknÅpfung)
         *              'Zn'  -- Bits im Zielbereich (nach dem VerknÅpfung)
         *              '&'   -- Logisches UND
         *              '|'   -- Logisches ODER
         *              '~'   -- Logisches NICHT
         *              'xor' -- Logisches EXCLUSIV-ODER
         *
         *  Anmerkung: Diese VerknÅpfungen reprÑsentieren jede zweistellige
         *             Operation auf Bits (2^4 = 16 Mîglichkeiten).
         *)
         
         
        Point           = RECORD
                            x: INTEGER;
                            y: INTEGER;
                          END;
        
        LongPnt         = RECORD
                            x: LONGINT;
                            y: LONGINT;
                          END;
                         
        Rectangle       = RECORD
                            x: INTEGER;
                            y: INTEGER;
                            w: INTEGER;
                            h: INTEGER;
                          END;
                                 
        LongRect        = RECORD
                            x: LONGINT;
                            y: LONGINT;
                            w: LONGINT;
                            h: LONGINT;
                          END;
                                 
PROCEDURE Pnt (x, y: INTEGER): Point;
PROCEDURE LPnt (x, y: LONGINT): LongPnt;

        (*  Liefert ein Record, welches den Punkt mit den Koordinaten 'x'
         *  und 'y' beschreibt.
         *)

PROCEDURE Rect (x, y, w, h: INTEGER): Rectangle;
PROCEDURE LRect (x, y, w, h: LONGINT): LongRect;

        (*  Erzeugt ein Record, das ein Rechteck beschreibt, dessen linker,
         *  oberer Punkt die Koordinaten 'x' und 'y' besitzt und das 'w'
         *  Pixel breit und 'h' Pixel hoch ist.
         *)

PROCEDURE ShortPoint (p    : LongPnt  ): Point;
PROCEDURE LongPoint  (p    : Point    ): LongPnt;
PROCEDURE ShortFrame (frame: LongRect ): Rectangle;
PROCEDURE LongFrame  (frame: Rectangle): LongRect;

        (*  Typwandlungen
         *)

PROCEDURE AbsZoomRect (frame: Rectangle; xDelta, yDelta: INTEGER): Rectangle;

        (*  'frame' wird zentrisch gestreckt und zwar in x-Richtung um
         *  'xDelta' Pixel und in y-Richtung um 'yDelta' Pixel.
         *  Negative Deltawerte verkleinern die Ausmaûe des Rechtecks,
         *  und fÅhren fÅr Werte kleiner '-frame.w' bzw. '-frame.h'
         *  zu einer Spiegelung des Rechtecks an einer Parallelen der
         *  x-Achse bzw. y-Achse, die durch den Mittelpunkt des Recht-
         *  eckes geht. Sind beide Werte kleiner, so entspricht dies
         *  einer Punktspiegelung am Rechtecksmittelpunkt.
         *)

PROCEDURE RelZoomRect (frame: Rectangle; xFactor, yFactor: LONGINT): Rectangle;

        (*  Auch hier wird das Rechteck 'frame' zentrisch gestreckt, nur
         *  werden diesmal relative Maûzahlen fÅr die Streckung benutzt.
         *  Die Ausmaûe des Rechtecks werden mit '...Factor DIV 1000'
         *  multipliziert. Das bedeutet, daû ein Faktor von 1000 das
         *  Rechteck unverÑndert lÑût, negative Faktoren eine Spiegelung,
         *  Faktoren zwischen -999 und 999 eine Verkleinerung und Fak-
         *  toren deren Betrag grîûer 1000 ist eine Vergrîûerung nach
         *  sich ziehen.
         *)

PROCEDURE TransRect (frame: Rectangle; p: Point): Rectangle;
PROCEDURE LTransRect (frame: LongRect; p: LongPnt): LongRect;

        (*  Liefert 'Rect (p.x, p.y, frame.w, frame.h)' entspricht also
         *  einer Translation des Rechtecks 'frame' zum Punkt 'p'.
         *)

PROCEDURE MinPoint (frame: Rectangle): Point;
PROCEDURE LMinPoint (frame: LongRect): LongPnt;

        (*  Liefert 'Pnt(frame.x,frame.y)'
         *)

PROCEDURE MaxPoint (frame: Rectangle): Point;
PROCEDURE LMaxPoint (frame: LongRect): LongPnt;

        (*  Liefert 'Pnt(frame.x+frame.w-1,frame.y+frame.h-1)'
         *)

PROCEDURE ClipRect (frame: Rectangle; clip: Rectangle): Rectangle;
PROCEDURE LClipRect (frame: LongRect; clip: LongRect): LongRect;

        (*  Diese Routine "clippt" das Rechteck 'frame' auf den Bereich
         *  'clip', d.h. es wird der Ausschnitt von 'frame' berechnet,
         *  der innerhalb von 'clip' liegt.
         *)

PROCEDURE FrameRects (frame1, frame2: Rectangle): Rectangle;
PROCEDURE LFrameRects (frame1, frame2: LongRect): LongRect;

        (*  Liefert das kleinste Rechteck, das 'frame1' und 'frame2'
         *  vollstÑndig einschlieût.
         *)

PROCEDURE FramePoints (p1, p2: Point): Rectangle;
PROCEDURE LFramePoints (p1, p2: LongPnt): LongRect;

        (*  Liefert das Rechteck, das von 'p1' und 'p2' aufgespannt wird.
         *)


TYPE
        (*  Bit0(b0) bis Bit15(b15) sind in der Reihenfolge aufgefÅhrt,
         *  in der sie auch im Speicher abgelegt werden.
         *
         *  ACHTUNG: Ab Version 2.1 ist dies nun eine neue Reihenfolge.
         *           FÅr Compilerversionen 4.0 aufwÑrts.
         *)
        
        BitsPerWord             = (b0,b1,b2 ,b3 ,b4 ,b5 ,b6 ,b7,
                                   b8,b9,b10,b11,b12,b13,b14,b15);
        WordBitSet              = SET OF BitsPerWord;
        
        PtrBitPattern           = POINTER TO ARRAY [0..MaxCard] OF WordBitSet;
        
        BitBlk16x16             = ARRAY [0..15] OF WordBitSet;
        PtrBitBlk16x16          = POINTER TO BitBlk16x16;


        MouseFormDef            = RECORD
                                    hotSpot     : Point;
                                    noPlanes    : CARDINAL;
                                    maskColor   : CARDINAL;
                                    dataColor   : CARDINAL;
                                    mask        : BitBlk16x16;
                                    data        : BitBlk16x16;
                                  END;
        PtrMouseFormDef         = POINTER TO MouseFormDef;
        
        (*  Es bedeutet:
         *
         *  'hotSpot'   -- Gibt den Punkt innerhalb der Mausform an, der
         *                 beim Erfragen der Mauszeigerposition als Er-
         *                 gebniss geliefert wird.
         *  'noPlanes'  -- Anzahl der Bitebenene (muû gleich 1 sein)
         *  'maskColor' -- Farbindex der Maskenbits
         *  'dataColor' -- Farbindex der Datenbits
         *  'mask'      -- 16x16 bit Muster der Maske
         *  'data'      -- Bitmuster der Datenbits
         *)
                                    
        MemFormDef              = RECORD
                                    start        : ADDRESS;
                                    w            : CARDINAL;
                                    h            : CARDINAL;
                                    words        : CARDINAL;
                                    standardForm : BOOLEAN;
                                    planes       : CARDINAL;
                                    res1         : WORD;
                                    res2         : WORD;
                                    res3         : WORD;
                                  END;
        PtrMemFormDef           = POINTER TO MemFormDef;
        
        (*
         *
         *  Dabei bedeuten:
         *
         *          'start'        -- Startaddresse des Speicherbereichs
         *          'w'            -- Breite des Rasters (in Pixel)
         *          'h'            -- Hîhe des Rasters (in Pixel)
         *          'words'        -- Breite des Rasters (in 16-Bit-Worten)
         *          'standardForm' -- TRUE  ~ Standard Format
         *                            FALSE ~ GerÑtespezifisches Format
         *          'planes'       -- Anzahl der Bitebenen
         *          'res1 - 3'     -- Reserviert fÅr zukÅnftige Anwendungen
         *
         *  Setzt man die Startaddresse gleich Null, so wird keiner der
         *  folgenden Parameter berÅcksichtigt und statt dessen das ange-
         *  gebene physikalische GerÑt (wird durch GerÑte-Handle identi-
         *  fiziert) benutzt (z.B. Bildschirm). In diesem Fall wird auch,
         *  falls es gesetzt ist, das Clipping-Rechteck berÅcksichtigt
         *  (siehe 'VDIControls').
         *  Wird eine Startaddresse ungleich Null angegeben, so ist der
         *  Platzbedarf des beschriebene Blocks 'words * h * 2' Byte.
         *  Auûerdem gilt 'w = words * h'.
         *
         *)
                         
                         
PROCEDURE GetPhysMemForm (VAR memForm: MemFormDef);

        (*  Berechnet den Memory Form Definition Block fÅr den aktuellen
         *  physikalischen Bildschirm (mit aktueller Auflîsung).
         *
         *  ACHTUNG: Da diese Routine auf den Line-A-Variablen aufbaut
         *           und teilweise auch die negativen Line-A-Variablen
         *           nutzt, sollte sie in Programmen, die mit der Ziel-
         *           setzung erstellt werden auch auf Weiterentwicklungen
         *           des Atari ST zu funktionieren nicht verwendet werden.
         *           Eine Alternative bietet 'GEMEnv.DeviceParameter',
         *           die das VDI nutzt.
         *)

PROCEDURE GetLogMemForm (VAR memForm: MemFormDef);

        (*  Entspricht 'GetPhysMemForm' fÅr den logischen Bildschirm.
         *)
        

(*  Die folgenden Routinen erfragen ihre Daten durch XBIOS-Aufrufe.
 *)
 
PROCEDURE GetBlitterMode (VAR available, active: BOOLEAN);

        (*  Erfragt den Zustand des Blitters.
         *
         *  'available' gibt an ob der Blitter im Rechner eingebaut ist,
         *  und 'active' meldet, ob der Blitter benuzt wird oder nicht.
         *)

PROCEDURE SetBlitterMode (active: BOOLEAN);

        (*  Falls ein Bit-Block Transfer Processor eingebaut ist, so
         *  kann mit dieser Routine bestimmt werden, ob er benutzt
         *  werden soll oder nicht.
         *)
 
PROCEDURE GetScreen (VAR log, phys:ADDRESS; VAR rez: INTEGER);

        (*  Liefert die Addresse des aktuellen logischen Bildschirms
         *  (das ist der Bildschirm auf den alle Ausgaben gemacht
         *  werden) und des physikalischen Bildschirms (dies ist der
         *  sichtbare Bildschirm) und die momentane Auflîsung, dabei
         *  gilt: 2 ~ HiRes | 1 ~ MidRes | 0 ~ LowRes .
         *
         *  HINWEIS: Die in 'rez' gelieferte Bildschirmauflîsung
         *           beachtet Sonderauflîsungen, wie Groûbildschirme
         *           oder Ñhnliches natÅrlich nicht.
         *)

PROCEDURE SetScreen (log, phys: ADDRESS; rez: INTEGER);

        (*  Mit 'SetScreen' lassen sich die mit 'GetScreen' erfragten
         *  Parameter neu setzen. Soll einer der Werte unverÑndert
         *  bleiben, so muû fÅr ihn -1L bzw. -1 Åbergeben werden.
         *)
         

TYPE    Palette         = ARRAY [0..15] OF CARDINAL;
        PtrPalette      = POINTER TO Palette;
        
        (*  Ein Paletteneintrag ist folgendermaûen aufgebaut:
         *
         *  0000 0rrr 0ggg 0bbb ,  dabei steht jedes Zeichen fÅr ein Bit
         *                         rrr gibt den Rotanteil, ggg den GrÅn-
         *                         anteil und bbb den Blauanteil der be-
         *                         schriebenen Farbe an.
         *)
         
PROCEDURE SetPalette (newPalette: PtrPalette);

        (*  Setzt eine neue Farbpalette. Die neue Palette wird beim
         *  nÑchsten VBL-Interrupt gesetzt.
         *)
         
PROCEDURE SetColor (colorNum, color: CARDINAL);

        (*  Damit wird die Farbe 'colorNum' auf den Farbwert 'color' gesetzt.
         *  Der Aufbau des Farbwertes entspricht einem Eintrag in 'Palette'.
         *)

PROCEDURE ColorNumber (colorNum: CARDINAL): CARDINAL;

        (*  Lieût den mit 'SetColor' gesetzten Wert.
         *)

END GrafBase.
