IMPLEMENTATION MODULE GrafBase;
(*$L-, R-, Y+*)


(*  Definition der grundlegenden Typen fÅr die Grafikbibliotheken des
 *  Megamax Modula-2 Entwicklungspackets. Auûerdem Routinen zur Ver-
 *  arbeitung dieser Strukturen.
 *
 *  Autor: Manuel Chakravarty           Erstellt: 28.10.87
 *
 *  Version   2.1     V#0021
 *
 *)
 
(*  28.10.87    | Definitionen
 *  02.08.89    | 'FrameRects' korrigiert
 *  13.08.89    | 'LongPnt', 'LongRect' def.; 'LPnt', 'LRect' def. + impl.
 *  18.08.89    | 'Get...MemFormDef' benutzt jetzt Line-A (das Modul wird
 *                nicht importiert um Zyklen zu vermeiden). Auûerdem die
 *                'L...'-Funktionen
 *  01.02.90    | Angepaût auf Compilerversion 4.0 (verdrehte SET's)
 *  10.12.93    | LFramePoints korrigiert
 *)


FROM SYSTEM     IMPORT ASSEMBLER, ADDRESS;

 
(*$L-*)
PROCEDURE Pnt (x, y: INTEGER): Point; END Pnt;
PROCEDURE LPnt (x, y: LONGINT): LongPnt; END LPnt;

PROCEDURE Rect (x, y, w, h: INTEGER): Rectangle; END Rect;
PROCEDURE LRect (x, y, w, h: LONGINT): LongRect; END LRect;
(*$L=*)

PROCEDURE ShortPoint (p: LongPnt): Point;

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3), D1
        MOVE.L  -4(A3), D0
        MOVE.W  D0, -4(A3)
        MOVE.W  D1, -2(A3)
        ADDI.L  #8000, D0
        SWAP    D0
        TST.W   D0
        BNE     err
        ADDI.L  #8000, D1
        SWAP    D1
        TST.W   D1
        BEQ     ende

err     TRAP    #6
        DC.W    -7

ende
    END;
  END ShortPoint;
  (*$L=*)
  
PROCEDURE LongPoint  (p: Point): LongPnt;

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -4(A3), D0
        MOVE.W  D0, D1
        EXT.L   D1
        SWAP    D0
        EXT.L   D0
        MOVE.L  D0, -4(A3)
        MOVE.L  D1, (A3)+
    END;
  END LongPoint;
  (*$L=*)
  
PROCEDURE ShortFrame (frame: LongRect): Rectangle;

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3), D1
        MOVE.L  -(A3), D0
        MOVE.W  D0, D2
        SWAP    D2
        MOVE.W  D1, D2
        ADDI.L  #8000, D0
        SWAP    D0
        TST.W   D0
        BNE     err
        ADDI.L  #8000, D1
        SWAP    D1
        TST.W   D1
        BEQ     cont

err     TRAP    #6
        DC.W    -7

cont
        MOVE.L  -4(A3), D1
        MOVE.L  -8(A3), D0
        MOVE.W  D0, -8(A3)
        MOVE.W  D1, -6(A3)
        MOVE.L  D2, -4(A3)
        ADDI.L  #8000, D0
        SWAP    D0
        TST.W   D0
        BNE     err2
        ADDI.L  #8000, D1
        SWAP    D1
        TST.W   D1
        BEQ     ende

err2    TRAP    #6
        DC.W    -7
ende
    END;
  END ShortFrame;
  (*$L=*)
  
PROCEDURE LongFrame  (frame: Rectangle): LongRect;
        
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -8(A3), D0
        MOVE.L  -4(A3), D2
        MOVE.W  D0, D1
        EXT.L   D1
        SWAP    D0
        EXT.L   D0
        MOVE.L  D0, -8(A3)
        MOVE.L  D1, -4(A3)
        MOVE.W  D2, D1
        EXT.L   D1
        SWAP    D2
        EXT.L   D2
        MOVE.L  D2, (A3)+
        MOVE.L  D1, (A3)+
    END;
  END LongFrame;
  (*$L=*)
  

PROCEDURE AbsZoomRect(frame:Rectangle;xDelta,yDelta:INTEGER):Rectangle;

  (*$L+*)
  BEGIN
    frame.x:=frame.x-xDelta;frame.y:=frame.y-yDelta;
    frame.w:=frame.w+xDelta*2;frame.h:=frame.h+yDelta*2;
    RETURN frame;
  END AbsZoomRect;
  (*$L=*)

PROCEDURE RelZoomRect(frame:Rectangle;xFactor,yFactor:LONGINT):Rectangle;

  VAR     newW, newH      : INTEGER;
  
  (*$L+*)
  BEGIN
    newW:=SHORT( LONG(frame.w)*xFactor DIV 1000L );
    newH:=SHORT( LONG(frame.h)*yFactor DIV 1000L );
    frame.x:=frame.x+frame.w DIV 2 -newW DIV 2;
    frame.y:=frame.y+frame.h DIV 2 -newH DIV 2;
    frame.w:=newW;
    frame.h:=newH;
    RETURN frame;
  END RelZoomRect;
  (*$L=*)

PROCEDURE TransRect (frame: Rectangle; p: Point): Rectangle;

  (*$L+*)
  BEGIN
    RETURN Rect(p.x,p.y,frame.w,frame.h);
  END TransRect;
  (*$L=*)
  
PROCEDURE LTransRect (frame: LongRect; p: LongPnt): LongRect;

  (*$L+*)
  BEGIN
    RETURN LRect (p.x, p.y, frame.w, frame.h);
  END LTransRect;
  (*$L=*)
  
PROCEDURE MinPoint (frame: Rectangle): Point;

  (*$L+*)
  BEGIN
    RETURN Pnt(frame.x,frame.y);
  END MinPoint;
  (*$L=*)
                         
PROCEDURE LMinPoint (frame: LongRect): LongPnt;

  (*$L+*)
  BEGIN
    RETURN LPnt(frame.x, frame.y);
  END LMinPoint;
  (*$L=*)
                         
PROCEDURE MaxPoint (frame: Rectangle): Point;

  (*$L+*)
  BEGIN
    RETURN Pnt(frame.x+frame.w-1,frame.y+frame.h-1);
  END MaxPoint;
  (*$L=*)
                         
PROCEDURE LMaxPoint (frame: LongRect): LongPnt;

  (*$L+*)
  BEGIN
    RETURN LPnt (frame.x + frame.w - 1L, frame.y + frame.h - 1L);
  END LMaxPoint;
  (*$L=*)
                         
PROCEDURE ClipRect (frame: Rectangle; clip: Rectangle): Rectangle;

  (*$L+*)
  BEGIN
    WITH frame DO
      IF x<clip.x THEN w:=w-clip.x+x; x:=clip.x END;
      IF y<clip.y THEN h:=h-clip.y+y; y:=clip.y END;
      IF (w<=0) OR (h<=0) THEN w:=0;h:=0 END;
      IF (x+w)>(clip.x+clip.w) THEN w:=clip.x+clip.w-x END;
      IF (y+h)>(clip.y+clip.h) THEN h:=clip.y+clip.h-y END;
      IF (w<=0) OR (h<=0) THEN w:=0;h:=0 END;
    END;
    RETURN frame;
  END ClipRect;
  (*$L=*)

PROCEDURE LClipRect (frame: LongRect; clip: LongRect): LongRect;

  (*$L+*)
  BEGIN
    WITH frame DO
      IF x<clip.x THEN w:=w-clip.x+x; x:=clip.x END;
      IF y<clip.y THEN h:=h-clip.y+y; y:=clip.y END;
      IF (w<=0L) OR (h<=0L) THEN w:=0L;h:=0L END;
      IF (x+w)>(clip.x+clip.w) THEN w:=clip.x+clip.w-x END;
      IF (y+h)>(clip.y+clip.h) THEN h:=clip.y+clip.h-y END;
      IF (w<=0L) OR (h<=0L) THEN w:=0L;h:=0L END;
    END;
    RETURN frame;
  END LClipRect;
  (*$L=*)

PROCEDURE FrameRects (r1, r2: Rectangle): Rectangle;

  VAR   r: Rectangle;
  
  (*$L+*)
  BEGIN
    WITH r DO
      IF r1.x > r2.x THEN x := r2.x ELSE x := r1.x END;
      IF r1.y > r2.y THEN y := r2.y ELSE y := r1.y END;
      r1.w := r1.x + r1.w;
      r2.w := r2.x + r2.w;
      IF r1.w < r2.w THEN w := r2.w - x ELSE w := r1.w - x END;
      r1.h := r1.y + r1.h;
      r2.h := r2.y + r2.h;
      IF r1.h < r2.h THEN h := r2.h - y ELSE h := r1.h - y END;
    END;
    
    RETURN r
  END FrameRects;
  (*$L=*)

PROCEDURE LFrameRects (r1, r2: LongRect): LongRect;

  VAR   r: LongRect;
  
  (*$L+*)
  BEGIN
    WITH r DO
      IF r1.x > r2.x THEN x := r2.x ELSE x := r1.x END;
      IF r1.y > r2.y THEN y := r2.y ELSE y := r1.y END;
      r1.w := r1.x + r1.w;
      r2.w := r2.x + r2.w;
      IF r1.w < r2.w THEN w := r2.w - x ELSE w := r1.w - x END;
      r1.h := r1.y + r1.h;
      r2.h := r2.y + r2.h;
      IF r1.h < r2.h THEN h := r2.h - y ELSE h := r1.h - y END;
    END;
    
    RETURN r
  END LFrameRects;
  (*$L=*)

PROCEDURE FramePoints (p1, p2: Point): Rectangle;

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.W      -4(A3),D0    ; q.x -> d0
        MOVE.W      D0,D1           ; q.x -> d1
        SUB.W       -8(A3),D0    ; q.x-p.x -> d0
        BCS         pxGreater       ; jump if p.x>q.x
        ADDQ.W      #1,D0
        MOVE.W      D0,-4(A3)    ; q.x-p.x+1 -> w
        BRA         cont
pxGreater
        MOVE.W      D1,-8(A3)    ; q.x -> x
        NOT.W       D0
        ADDQ.W      #2,D0
        MOVE.W      D0,-4(A3)    ; p.x-q.x+1 -> w
cont
        MOVE.W      -2(A3),D0    ; q.y -> d0
        MOVE.W      D0,D1           ; q.y -> d1
        SUB.W       -6(A3),D0    ; q.y-p.y -> d0
        BCS         pyGreater       ; jump if p.y>q.y
        ADDQ.W      #1,D0
        MOVE.W      D0,-2(A3)    ; q.y-p.y+1 -> h
        BRA         cont2
pyGreater
        MOVE.W      D1,-6(A3)    ; q.y -> y
        NOT.W       D0
        ADDQ.W      #2,D0
        MOVE.W      D0,-2(A3)    ; p.y-q.y+1 -> h
cont2
    END;
  END FramePoints;
  (*$L=*)

PROCEDURE LFramePoints (p1, p2: LongPnt): LongRect;

  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L      -8(A3),D0    ; q.x -> d0
        MOVE.L      D0,D1           ; q.x -> d1
        SUB.L       -16(A3),D0    ; q.x-p.x -> d0
        BCS         pxGreater       ; jump if p.x>q.x
        ADDQ.L      #1,D0
        MOVE.L      D0,-8(A3)    ; q.x-p.x+1 -> w
        BRA         cont
pxGreater
        MOVE.L      D1,-16(A3)    ; q.x -> x
        NOT.L       D0
        ADDQ.L      #2,D0
        MOVE.L      D0,-8(A3)    ; p.x-q.x+1 -> w
cont
        MOVE.L      -4(A3),D0    ; q.y -> d0
        MOVE.L      D0,D1           ; q.y -> d1
        SUB.L       -12(A3),D0    ; q.y-p.y -> d0
        BCS         pyGreater       ; jump if p.y>q.y
        ADDQ.L      #1,D0
        MOVE.L      D0,-4(A3)    ; q.y-p.y+1 -> h
        BRA         cont2
pyGreater
        MOVE.L      D1,-12(A3)    ; q.y -> y
        NOT.L       D0
        ADDQ.L      #2,D0
        MOVE.L      D0,-4(A3)    ; p.y-q.y+1 -> h
cont2
    END;
  END LFramePoints;
  (*$L=*)


(*  calcFormSize -- Setzt eine MemFormDef auf ATARI-Screen Parameter *
 *                  (ohne screen address). Zeiger auf MemForm in A0  *)

PROCEDURE calcFormSize;

  BEGIN
    ASSEMBLER
        MOVE.L  A0, -(A7)
        DC.W    $A000           ; Line-A-Init
        MOVE.L  (A7)+, A1
    
        MOVE.W  (A0), MemFormDef.planes(A1)
        MOVE.W  2(A0), D0
        LSR.W   #1, D0
        MOVE.W  D0, MemFormDef.words(A1)
        MOVE.W  -12(A0), MemFormDef.w(A1)
        MOVE.W  -4(A0), MemFormDef.h(A1)
        MOVE.W  #FALSE, MemFormDef.standardForm(A1)
    END;
  END calcFormSize;

PROCEDURE GetPhysMemForm(VAR memForm:MemFormDef);

  BEGIN
    ASSEMBLER
        MOVE.W      #2,-(A7)        ; XBIOS(2) -- Get physical screen addr
        TRAP        #14
        ADDQ.L      #2,A7
        MOVE.L      -(A3),A0
        MOVE.L      D0,MemFormDef.start(A0)
        JMP         calcFormSize
    END;
  END GetPhysMemForm;

PROCEDURE GetLogMemForm(VAR memForm:MemFormDef);

  BEGIN
    ASSEMBLER
        MOVE.W      #3,-(A7)        ; XBIOS(3) -- Get logical screen addr
        TRAP        #14
        ADDQ.L      #2,A7
        MOVE.L      -(A3),A0
        MOVE.L      D0,MemFormDef.start(A0)
        JMP         calcFormSize
    END;
  END GetLogMemForm;


PROCEDURE GetBlitterMode(VAR avaible,active:BOOLEAN);

BEGIN
  ASSEMBLER
        MOVE.W  #-1,-(A7)
        MOVE.W  #64,-(A7)
        TRAP    #14
        ADDQ.L  #4,A7
        CLR.W   D1
        
        BTST    #0,D0
        SEQ     D1
        ADDQ.B  #1,D1
        MOVE.L  -(A3),A0
        MOVE.W  D1,(A0)
        
        BTST    #1,D0
        SEQ     D1
        ADDQ.B  #1,D1
        MOVE.L  -(A3),A0
        MOVE.W  D1,(A0)
  END;
END GetBlitterMode;

PROCEDURE SetBlitterMode(active:BOOLEAN);

BEGIN
  ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE.W  #64,-(A7)
        TRAP    #14
        ADDQ.L  #4,A7
  END;
END SetBlitterMode;


PROCEDURE GetScreen(VAR log,phys:ADDRESS;VAR rez:INTEGER);

BEGIN
  ASSEMBLER
        MOVE.W  #4,-(A7)        ; XBIOS(4) -- get screen resolution
        TRAP    #14
        ADDQ.L  #2,A7
        MOVE.L  -(A3),A0
        MOVE.W  D0,(A0)
        
        MOVE.W  #2,-(A7)        ; XBIOS(2) -- Get physical screen addr
        TRAP    #14
        ADDQ.L  #2,A7
        MOVE.L  -(A3),A0
        MOVE.L  D0,(A0)
        
        MOVE.W  #3,-(A7)        ; XBIOS(3) -- Get logical screen addr
        TRAP    #14
        ADDQ.L  #2,A7
        MOVE.L  -(A3),A0
        MOVE.L  D0,(A0)
  END;
END GetScreen;

PROCEDURE SetScreen(log,phys:ADDRESS;rez:INTEGER);
    
BEGIN
  ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.W  #5,-(A7)        ; XBIOS(5) -- Setscreen
        TRAP    #14
        ADDA.L  #12,A7
  END;
END SetScreen;

PROCEDURE SetPalette(newPalette:PtrPalette);

BEGIN
  ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.W  #6,-(A7)        ; XBIOS(6) -- Setpalette
        TRAP    #14
        ADDQ.L  #6,A7
  END;
END SetPalette;

PROCEDURE SetColor(colorNum,color:CARDINAL);

BEGIN
  ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.W  #7,-(A7)        ; XBIOS(7) -- Setcolor
        TRAP    #14
        ADDQ.L  #6,A7
  END;
END SetColor;

PROCEDURE ColorNumber(colorNum:CARDINAL):CARDINAL;

BEGIN
  ASSEMBLER
        MOVE.W  #-1,-(A7)       ; neg. color => inquire
        MOVE.W  -(A3),-(A7)
        MOVE.W  #7,-(A7)        ; XBIOS(7) -- Setcolor
        TRAP    #14
        ADDQ.L  #6,A7
        MOVE.W  D0,(A3)+
  END;
END ColorNumber;


END GrafBase.
