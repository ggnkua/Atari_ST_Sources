DEFINITION MODULE LineA;


(*  Megamax Modula-2 Line-A-Routinen
 *
 *  Autor: Manuel Chakravarty
 *
 *  Created: 7.4.1987           Version 2.1   V#0069
 *)
 
 
(*
 *      HINWEIS: Bei der Verwendung der Line-A-Routine ist eine gewisse Vor-
 *               sicht geboten, da diese auf eventuellen Nachfolgermodellen
 *               des Atari ST wahrscheinlich nicht mehr auf diese Weise unter-
 *               stÅtzt werden und darauf aufbauende Programme dann nicht
 *               mehr lauffÑhig sein kînnten.
 *
 *      Die Line-A-Routinen stellen die grundlegenden Ausgabemîglichkeiten
 *      des ATARI ST dar. Mit ihrer Hilfe kann man sowohl Striche, wie auch
 *      Zeichen auf den Bildschirm bannen. Das gesamte GEM ist auf diese
 *      Routinen aufgesetzt, was natÅrlich bedingt, daû die Line-A-Funktionen
 *      den VDI Routinen an Geschwindigkeit und FlexibilitÑt Åberlegen sind.
 *      DafÅr sind sie weniger komplex und komfortabel.
 *      Die Line-A-Prozeduren arbeiten auf den Line-A-Variablen, dies ist
 *      ein statischer Variablenbereich, der ermittelt und manipuliert wer-
 *      den kann. Diese Variablen enthalten einen Groûteil der, fÅr die
 *      Routinen notwendigen, Parameter. Welche Variablen eine Routine aus-
 *      wertet wird in ihrer Beschreibung angegeben.
 *)


FROM SYSTEM     IMPORT BYTE, WORD, ADDRESS;

FROM GrafBase   IMPORT WordBitSet, WritingMode, BitOperation, Point, Rectangle,
                       PtrMouseFormDef, PtrMemFormDef;
 
 
TYPE    PtrByteArray            = POINTER TO ARRAY[0..MaxCard] OF BYTE;
        PtrIntArray             = POINTER TO ARRAY[0..MaxCard] OF INTEGER;
        PtrCardArray            = POINTER TO ARRAY[0..MaxCard] OF CARDINAL;
        
        SystemFont              = (font6x6, font8x8, font8x16);
        PtrFontHeader           = POINTER TO FontHeader;
        FontHeader              = RECORD
                                    id           : CARDINAL;
                                    size         : INTEGER;
                                    name         : ARRAY[0..31] OF CHAR;
                                    minADE       : CARDINAL;
                                    maxADE       : CARDINAL;
                                    topToBase    : CARDINAL;
                                    ascentToBase : CARDINAL;
                                    halfToBase   : CARDINAL;
                                    descentToBase: CARDINAL;
                                    bottomToBase : CARDINAL;
                                    maxCharWidth : CARDINAL;
                                    maxBoxWidth  : CARDINAL;
                                    leftOffset   : INTEGER;
                                    rightOffset  : INTEGER;
                                    thickening   : CARDINAL;
                                    underLineH   : CARDINAL;
                                    lightMask    : CARDINAL;
                                    skewMask     : CARDINAL;
                                    flags        : WordBitSet;
                                    horOffsetTab : PtrIntArray;
                                    charOffsetTab: PtrIntArray;
                                    fontData     : PtrCardArray;
                                    formWidth    : CARDINAL;
                                    formHeight   : CARDINAL;
                                    next         : PtrFontHeader;
                                  END;
        PtrSysFontHeader        = POINTER TO ARRAY SystemFont OF PtrFontHeader;
        
        (*  Definition der Line-A-Varaible.
         *  Eine genauere Beschreibung ist im Handbuch zu finden.
         *)
        LineAVars               = RECORD
                                    planes       : CARDINAL;
                                    bytesPerLine : CARDINAL;
                                    contrl       : PtrIntArray;
                                    intin        : PtrIntArray;
                                    ptsin        : PtrIntArray;
                                    intout       : PtrIntArray;
                                    ptsout       : PtrIntArray;
                                    plane1       : BOOLEAN;
                                    plane2       : BOOLEAN;
                                    plane3       : BOOLEAN;
                                    plane4       : BOOLEAN;
                                    lastLine     : BOOLEAN;
                                    lineMask     : CARDINAL;
                                    writingMode  : WritingMode;
                                    p            : Point;
                                    q            : Point;
                                    patternPtr   : PtrCardArray;
                                    patternMask  : CARDINAL;
                                    multiFill    : BOOLEAN;
                                    clipping     : BOOLEAN;
                                    minClip      : Point;
                                    maxClip      : Point;
                                    scaleAcc     : CARDINAL;
                                    scaleFactor  : CARDINAL;
                                    scaleMode    : WordBitSet;
                                    monoStatus   : BOOLEAN;
                                    source       : Point;
                                    dest         : Point;
                                    width        : CARDINAL;
                                    height       : CARDINAL;
                                    formBase     : PtrCardArray;
                                    formWidth    : INTEGER;
                                    style        : WordBitSet;
                                    lightMask    : CARDINAL;
                                    skewMask     : CARDINAL;
                                    weight       : CARDINAL;
                                    rightOff     : INTEGER;
                                    leftOff      : INTEGER;
                                    scale        : BOOLEAN;
                                    chup         : CARDINAL;
                                    textFg       : CARDINAL;
                                    scratchArea  : PtrCardArray;
                                    scratchOff2  : CARDINAL;
                                    textBg       : CARDINAL;
                                    copyTrans    : BOOLEAN;
                                    seedAbort    : ADDRESS;
                                  END;
        PtrLineAVars            = POINTER TO LineAVars;
        
        NegLineAVars            = RECORD
                                    
                                    (*  Zeichenhîhe
                                     *)
                                    cellHeight   : CARDINAL;
                                    
                                    (*  Maximale Cursor Spalten- und Zeilen-
                                     *  position.
                                     *)
                                    maxColumn    : CARDINAL;
                                    maxRow       : CARDINAL;
                                    
                                    (*  Zeichenzeilenbreite in Bytes
                                     *)
                                    charRowWidth : CARDINAL;
                                    
                                    (*  Hinter- und Vordergrundfarbe
                                     *)
                                    bgColor      : CARDINAL;
                                    fgColor      : CARDINAL;
                                    
                                    (*  Adresse der aktuellen Cursorposition
                                     *)
                                    cursAddr     : ADDRESS;
                                    
                                    (*  Vertikaler Offset zum Anfang des
                                     *  Bildschirms. Siehe auch 'VDIEscapes.
                                     *  SetLineOffset'.
                                     *)
                                    lineOffset   : INTEGER;
                                    
                                    (*  Spalten- und Zeilenposition des
                                     *  Cursors
                                     *)
                                    cursColumn   : CARDINAL;
                                    cursRow      : CARDINAL;
                                    
                                    (*  Blinkgeschw. des Cursors und ZÑhler
                                     *  fÅr das Cursorblinken.
                                     *)
                                    cursFrequence: BYTE;
                                    cursCount    : BYTE;
                                    
                                    (*  Zeiger auf den Systemzeichensatz
                                     *  Siehe auch 'VDIEscapes.InitSystemFont'.
                                     *)
                                    sysFontAddr  : ADDRESS;
                                    
                                    (*  ASCII-Wert des letzten und ersten
                                     *  Zeichens im Systemzeichensatz und
                                     *  Breite der Fontdaten in Bytes.
                                     *)
                                    maxADE       : CARDINAL;
                                    minADE       : CARDINAL;
                                    fontWidth    : CARDINAL;
                                    
                                    (*  Bildschirmbreite in Pixel
                                     *)
                                    screenWidth  : CARDINAL;
                                    
                                    (*  Zeiger auf die Offset-Tabelle des
                                     *  Systemzeichensatzes.
                                     *)
                                    fontOffset   : ADDRESS;
                                    
                                    (*  Aktueller Cursorzustand:
                                     *
                                     *    b0 -- Cursorblinken ein/aus
                                     *    b1 -- momentaner Cursorzustand
                                     *          (normal/invertiert)
                                     *    b2 -- Cursor unsichtbar/sichtbar
                                     *    b3 -- Wrapping ein/aus
                                     *    b4 -- Inverse Darstellung ein/aus
                                     *    b5 -- Cursorposition gespeichert
                                     *)
                                    cursStatus   : WordBitSet;
                                    
                                    (*  Bildschirmhîhe in Pixel
                                     *)
                                    screenHeight : CARDINAL;
                                    
                                    (*  Breite einer Bildschirmzeile in Byte
                                     *)
                                    bytesPerLine : CARDINAL;
                                    
                                  END;
        PtrNegLineAVars         = POINTER TO NegLineAVars;
        
 
PROCEDURE SystemFonts (): PtrSysFontHeader;
        
        (*  Durch diese Funktion erhÑhlt man einen Zeiger auf ein Feld,
         *  in dem die Startaddressen der drei System-Font-Header gespei-
         *  chert sind.
         *)


PROCEDURE LineAVariables (): PtrLineAVars;
        
        (*  Liefert einen Zeiger auf die Line-A-Variablen.
         *)

PROCEDURE NegLineAVariables (): PtrNegLineAVars;
        
        (*  Liefert einen Zeiger auf die 'VDI-Escape-Variablen' (negative
         *  Line-A-Variablen).
         *
         *  Die Benutzung dieser Variablen ist nicht uneingeschrÑnkt zu
         *  empfehlen, da ihre Lage von Atari nicht offiziell dokumen-
         *  tiert ist. Da sie aber bei allen bisherigen TOS-Versionen
         *  ihre Lage relativ zu den Line-A-Variablen nicht verÑndert
         *  haben, ist ihre Benutzung relativ sicher.
         *)


PROCEDURE PutPixel (p: Point; color: CARDINAL);

        (*  Diese Routine weiût dem Punkt 'p' des logischen Bildschirms
         *  die Farbe 'color' zu. Dabei wird weder das Clipping noch ei-
         *  ne andere der Line-A-Variablen berÅcksichtigt.
         *)
        
PROCEDURE PixelColor (p: Point): CARDINAL;

        (*  Ermittelt den Farbwert des Punktes 'p'.
         *)

PROCEDURE Line (p, q: Point);

        (*  'Line' zieht eine Linie zwischen den beiden Punkten 'p' und
         *  'q', dabei wird die Farbe durch die Line-A-Variablen 'plane1'
         *  bis 'plane4' bestimmt, auûerdem wird 'writingMode', 'lineMask'
         *  und 'lastLine' berÅcksichtigt.
         *)

PROCEDURE HorizontalLine (x1, x2, y: INTEGER);

        (*  Zieht eine horizontale Line von 'x1' bis 'x2' auf der Hîhe von
         *  'y', die Farbe wird wieder durch 'plane1' bis 'plane4' bestimmt
         *  und es werden noch 'writingMode', 'patternPtr', 'patternMask'
         *  und 'multiFill' berÅcksichtigt.
         *)

PROCEDURE FilledRectangle (p, q: Point);

        (*  Diese Procedur zeichnet ein gefÅlltes Rechteck, dessen Ausmaûe
         *  durch 'p' und 'q' bestimmt werden, dabei ist 'p' der linke,
         *  obere und 'q' der rechte, untere Eckpunkt. Die Parameter wer-
         *  den durch die gleichen Line-A-Variablen, wie bei 'Horizontal-
         *  Line' festgelegt, nur werden zusÑtzlich noch die Clippingvar-
         *  iablen benutzt.
         *)

PROCEDURE FilledPolygon (REF pts: ARRAY OF Point; noPts: CARDINAL; y: INTEGER);

        (*  Mit dieser Funktion kann man gefÅllte Polygone zeichnen, aller-
         *  dings wird bei einem einzelnen Aufruf noch nicht das gesamte
         *  Polygon, sondern nur eine einzelne Zeile daraus gezeichnet.
         *  Welche Zeile gezeichnet wird, gibt 'y' an. Um das vollstÑndige
         *  Vieleck zu erhalten, muû man also die oberste und unterste Bild-
         *  schirmzeile ermitteln, in der das Polygon liegt; danach ruft
         *  man 'FilledPolygon' fÅr alle Zeilen, die zwischen der obersten
         *  und untersten liegen auf. Das Feld 'pts' enthÑlt alle Eckpunkte
         *  des Vielecks, wobei der erste Punkt (pts[0]) noch einmal als
         *  letzter auftretten muû. Wieviel effektive Eckpunkt das Polygon
         *  besitzt, wird in 'noPts' angegeben. Ist 'noPts = 0', so wird das
         *  gesamte Feld benutzt.
         *  Die berÅcksichtigten Line-A-Variablen entsprechen denen von
         *  'FilledRectangle'.
         *)


TYPE    BBTDeskriptor   = RECORD
                            w            : CARDINAL;
                            h            : CARDINAL;
                            destPlanes   : CARDINAL;
                            setBitCol    : CARDINAL;
                            unsetBitCol  : CARDINAL;
                            mode00       : BYTE;
                            mode01       : BYTE;
                            mode10       : BYTE;
                            mode11       : BYTE;
                            sourceStart  : Point;
                            sourceAddr   : ADDRESS;
                            sourceInc    : CARDINAL;
                            sourceWidth  : CARDINAL;
                            sourceWidth2 : CARDINAL;
                            destStart    : Point;
                            destAddr     : ADDRESS;
                            destInc      : CARDINAL;
                            destWidth    : CARDINAL;
                            destWidth2   : CARDINAL;
                            patternPtr   : PtrByteArray;
                            patternWidth : CARDINAL;
                            patPlaneOff  : CARDINAL;
                            patternEnd   : CARDINAL;
                            scratch      : ARRAY[0..11] OF WORD;
                          END;
        PtrBBTDeskriptor= POINTER TO BBTDeskriptor;

PROCEDURE BitBlockTransfer (deskriptor: PtrBBTDeskriptor);

        (*  Diese Routine kopiert Speicherbereiche, insbesondere Bild-
         *  schirmausschnitte, wobei allerdings auch noch ein FÅll-
         *  muster als Maske verwendet werden kann. Falls ein Blitter
         *  vorhanden und dieser auch aktiviert ist, so wird die ei-
         *  gentliche Kopierarbeit an ihn Åbertragen, ist der Chip
         *  nicht im Rechner eingebaut oder abgeschalten, so wird die
         *  Aufgabe von einer Art Software-Blitter Åbernommen, wodurch
         *  alles etwas langsamer, aber im Prinzip gleichartig ablÑuft.
         *  Das Record, auf das 'deskriptor' zeigt, beschreibt den Ko-
         *  pierauftrag vollstÑndig, es werden also keine Line-A-Var-
         *  iablen benutzt.
         *)

PROCEDURE TextBlockTransfer (font: PtrFontHeader; ch: CHAR; spot: Point);
        
        (*  Gibt das Zeichen 'ch' des Fonts 'font' ab dem Bildschirmpunkt
         *  'spot' aus, dabei werden nur die Daten, die speziell dieses
         *  Zeichen, den Font und den angegebenen Punkt betreffen in die
         *  Line-A Variablen eingetragen, daû setzen von Effekten etc.
         *  muû vorher durgefÅhrt werden.
         *  Die Variable 'writingMode' und die Clippingvariablen haben
         *  die gleiche Wirkung wie immer, auûerdem werden an speziellen
         *  Textausgabevariablen noch 'scaleAcc', 'scaleFactor', 'scale-
         *  Mode', 'style', 'scaling', 'chup', 'textFg' und 'textBg' aus-
         *  gewertet. Falls man Texteffecte und/oder Scaling benutzt, muû
         *  man 'scratchArea' und 'scratchOff2' noch mit den richtigen
         *  Werten belegen.
         *)
         

PROCEDURE ShowMouse (force: BOOLEAN);

        (*  Macht den Mauscursor sichtbar. Falls 'force = TRUE' ist, wird
         *  der Cursor auf alle FÑlle sichbar, sonst wird er erst sicht-
         *  bar, wenn genauso viele 'ShowMouse' wie vorher 'HideMouse'
         *  durchgefÅhrt worden sind.
         *)

PROCEDURE HideMouse;

        (*  Versteckt den Mauscursor. Es wird mitgezÑhlt, wie oft die
         *  Procedur aufgerufen wurde (siehe auch 'ShowMouse').
         *)

PROCEDURE TransformMouse (newForm: PtrMouseFormDef);

        (*  Mit dieser Routine kann man dem Mauscursor ein neues Aussehen
         *  verleihen, dabei ist 'newForm' ein Zeiger auf den Parameter-
         *  block, der das neue Aussehen des Cursors bestimmt.
         *)
                         
                         
TYPE    SpriteFormat    = (vdiFormat, xorFormat);
        SpriteDefBlock  = RECORD
                            offset       : Point;
                            format       : SpriteFormat;
                            backColor    : CARDINAL;
                            foreColor    : CARDINAL;
                            pattern      : ARRAY[0..31] OF CARDINAL;
                          END;
        PtrSpriteDef    = POINTER TO SpriteDefBlock;
        
        (*  Es bedeuten:
         *
         *  'offset'    -- Distanz zwischen dem angegebenen Hot-Spot (Siehe
         *                 'DrawSprite') und dem Pixel, an dem die linke,
         *                 obere Ecke des Sprites erscheint.
         *  'format'    -- Gibt an auf welche Art der Sprite mit dem alten
         *                 Bildschirminhalt verknÅpft werden soll.
         *                 Es steht 'Vg' fÅr die Bits des Vordergrundmusters
         *                 und 'Hg' fÅr die des Hintergrundmusters. Das Er-
         *                 gebnis gibt an, welche Farbe sichtbar wird, dabei
         *                 steht 'orginal' fÅr die Farbe des Pixels bevor
         *                 'DrawSprite' aufgerufen wurde. 'xor' stellt die
         *                 logische Exclusiv-Oder VerknÅpfung dar.
         *
         *                                 Vg    Hg       Ergebnis
         *
         *                 'vdiFormat':    0     0        orginal
         *                                 0     1        'backColor'
         *                                 1     0        'foreColor'
         *                                 1     1        'foreColor'
         *
         *                 'xorFormat':    0     0        orginal
         *                                 0     1        'backColor'
         *                                 1     0    orginal xor 'foreColor'
         *                                 1     1        'foreColor'
         *
         *  'backColor' -- Hintergrundfarbe
         *  'foreColor' -- Vordergrundfarbe
         *  'pattern'   -- Abwechselnd die Worte fÅr das Hinter- und das
         *                 Vordergrundmuster. Zuerst die oberste Zeile des
         *                 Hintergrundes, darauf die oberste Zeile des Vor-
         *                 dergrundes, dann die zweite Zeile des Hinter-
         *                 grundes und weiter mit der zweiten Zeile des Vor-
         *                 dergrundes usw.
         *)
        
        PtrSpriteBuffer = RECORD
                            CASE (* planes *) :CARDINAL OF
                              1 :  onePlane  : POINTER TO ARRAY[0..73] OF BYTE|
                              2 :  twoPlanes : POINTER TO ARRAY[0..137] OF BYTE|
                              4 :  fourPlanes: POINTER TO ARRAY[0..265] OF BYTE|
                            END;
                          END;
                          
        (*  Dabei gilt, 'onePlane'   fÅr monochrome Darstellung
         *              'twoPlanes'  fÅr 4 farbige Darstellung
         *              'fourPlanes' fÅr 16 farbige Darstellung
         *)
                         
PROCEDURE UndrawSprite (buffer: PtrSpriteBuffer);

        (*  Lîscht einen Sprite wieder vom Bildschirm, wobei der Hinter-
         *  grund restauriert wird. 'buffer' ist der Speicherbereich, in
         *  den der Hintergrund beim Zeichnen des Sprites gerettet wurde
         *)

PROCEDURE DrawSprite (hotSpot: Point;
                      sprite : PtrSpriteDef;
                      buffer : PtrSpriteBuffer);
        
        (*  Diese Procedur zeichnet den Sprite, der durch 'sprite' beschrieben
         *  wird, ab dem Punkt 'hotSpot' auf den Bildschirm. Dabei wird der
         *  ehemalige Inhalt des Bildschirmspeichers (Hintergrund) in den Spei-
         *  cherbereich gerettet, auf den 'buffer' zeigt.
         *)
         

TYPE    RasterMode      = RECORD
                            CASE :BOOLEAN OF
                              FALSE :  opaque : BitOperation|
                              TRUE  :  trans  : WritingMode|
                            END
                          END;

PROCEDURE CopyRasterForm (sourceMem,
                          destMem    : PtrMemFormDef;
                          sourceStart,
                          sourceEnd,
                          destStart,
                          destEnd    : Point;
                          mode       : RasterMode;
                          setCol,
                          unsetCol   : CARDINAL);
                         
        (*  Diese Routine kopiert einen rechteckigen Bildschirmausschnitt,
         *  dabei ist es nicht nîtig, daû der Bildspeicher genau die Grîûe
         *  eines physikalischen Bildspeichers besitzt (32000 Byte). Viel-
         *  mehr wird die Form des Bildspeichers durch eine Variable vom
         *  Typ 'MemFormDef' bestimmt. 'sourceMem' beschreibt den Quell-
         *  bereich, 'sourceStart' gibt die linke, obere und 'sourceEnd'
         *  die rechte, untere Ecke des Quellrechtecks an. Entsprechend
         *  beschreiben 'destMem', 'destStart' und 'destEnd' den Ziel-
         *  bereich. 'mode' bestimmt die VerknÅpfungsart, der Inhalte des
         *  Ziel- und des Quellbereichs. 'setCol' und 'unsetCol' bestimmen
         *  beim 'CopyTransparent'-Modus die Farben im Zielbereich.
         *  Diese Procedur benÅtzt die 'BitBlockTransfer'-Routine.
         *
         *  Man muû zwei Arten des Kopievorgangs unterscheiden. Es ist
         *  'LineAVars.copyTrans':
         *
         *  'FALSE' -- Es muû 'mode.opaque' gesetzt werden.
         *             'setCol' und 'unsetCol' sind wirkungslos 'source
         *             Mem.planes' muû gleich 'destMem.planes' sein.
         *             Entspricht 'VDIRasters.CopyOpaque'.
         *  'TRUE'  -- Es muû 'mode.trans' benutzt werden.
         *             'setCol' legt die Farbe der in 'sourceMem' auf 1
         *             gesetzten Bits fest, 'unsetCol' die der auf 0 ge-
         *             setzten Bits. Dabei muû 'sourceMem.planes=1' sein.
         *             Entspricht 'VDIRasters.CopyTrans'.
         *)
         
PROCEDURE ContourFill (p: Point; color: CARDINAL; useColor: BOOLEAN);

        (*  Diese Routine fÅllt einen Bildschirmbereich von dem Punkt 'p'
         *  ausgehend. Ist 'useColor = TRUE', so wird der Bereich durch
         *  die Farbe 'color' abgegrenzt, sonst durch jede Farbe, auûer
         *  der, die dem Punkt 'p' vor dem Funktionsaufruf zugeordnet ist.
         *  Diese Routine benutzt unter anderem die Variable 'seedAbort'.
         *
         *  ACHTUNG: Die Routine ist offiziell nicht dokumentiert. Ihre
         *           Funktionsweise kann sich also bei einer zukÅnftigen
         *           TOS-Version Ñndern!
         *)

END LineA.
