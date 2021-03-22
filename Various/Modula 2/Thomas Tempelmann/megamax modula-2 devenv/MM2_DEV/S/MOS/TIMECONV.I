IMPLEMENTATION MODULE TimeConvert; (* V#064 *)
(*$R-*)
(*$Y+*)
FROM SYSTEM IMPORT ASSEMBLER;

(*
  05.02.89: Frz. Monatsnamen gehen jetzt.
  09.08.89: Optmierungen: FastStrings verwendet; TimeToText & Chr in Asm.
  03.09.89: #U f. user-defined Monatsnamen; TextToDate lÑût nun auch
            nicht-dtsche Umlaute zu und es kînnen Monate von -9999 bis
            +9999 eingegeben werden - allerdings werden 80 bis 99 nach
            1980 bis 1999 gewandelt!
  30.06.90: TimeToText und TextToTime funktionieren jetzt immer korrekt,
            d.h. TextToTime kann auch mit 100250 (10 Uhr 2min 50sec)
            aufgerufen werden und TimeToText wertet jetzt die Maske
            aus! énderungen durch Dirk Steins (DS). Gekennzeichnte mit %%.
  05.07.90: énderungen von Dirk Steins korrigiert, TextTo-Funktionen setzen
            valid nun auf FALSE, wenn nach der Zeit-/Datumsangabe der String
            nicht endet.
  10.11.90: TextToDate prÅft nun auch den 31. bei den Monaten sowie Schaltjahre
            (von D.Steins)
  14.02.91: DateToText/Repl zerstîrt nicht mehr D3-D6
  14.01.94: DateToText/TimeToText korrigiert (D.Steins)
*)

FROM SYSTEM IMPORT WORD, ADR;

FROM Characters IMPORT IsAlpha;

FROM Clock IMPORT Time, Date;

FROM StrConv IMPORT CardToStr, NumToStr, StrToCard, StrToInt;

FROM Strings IMPORT Upper, StrEqual, String, Empty;

FROM FastStrings IMPORT Delete, Assign, Pos, Length, Copy, Chr;

IMPORT Strings;

FROM MOSGlobals IMPORT StringOverflow;

FROM MOSConfig IMPORT NameOfMonth, StdDateExp, StdDateMask, StdTimeMask;


CONST langHigh = 2; (* hîchster Sprachindex f. 'mon' *)
      monHigh = 9;

TYPE MonStr= ARRAY [0..monHigh] OF CHAR;

VAR strok: BOOLEAN;

PROCEDURE Repl (VAR source: ARRAY OF CHAR; index,len:WORD; VAR dest:ARRAY OF CHAR );
(*$L-*)
BEGIN
  ASSEMBLER
        MOVEM.L D3-D6,-(A7)
        MOVE    -(A3),D6         ;HIGH(dest)
        MOVE.L  -(A3),A2         ;dest
        MOVE    -(A3),D0         ;D0:=len
        MOVE    -(A3),D1         ;D1:=index
        MOVE    -(A3),D5         ;HIGH(source)
        MOVE.L  -(A3),A1         ;source
        MOVEQ   #0,D4           ; index f. dest
        MOVEQ   #-1,D2          ; index f. source
        TST     D0
        BNE     start
        
l2      ADDQ    #1,D2
        CMP     D1,D2           ; haben wir start-index erreicht ?
        BEQ     ok
        CMP     D5,D2
        BHI     ende             ; Stringende Åberschritten
        TST.B   0(A1,D2.W)
        BEQ     ende
        BRA     l2              ; Nein, noch nicht kopieren
        
l       ADDQ    #1,D2
        CMP     D5,D2
        BHI     ende             ; Stringende Åberschritten
        MOVE.B  0(A1,D2.W),D3
        BEQ     ende
        CMP     D1,D2           ; haben wir start-index erreicht ?
        BCS     l               ; Nein, noch nicht kopieren
        CMP     D6,D4           ; paût Zeichen noch in String ?
        BHI     ende
        MOVE.B  D3,0(A2,D4.W)   ; Zeichen kopieren
        ADDQ    #1,D4
start   DBRA    D0,l
ok
ende    MOVEM.L (A7)+,D3-D6
  END
END Repl;
(*$L=*)


PROCEDURE TimeToText ( s: Time; REF mask: ARRAY OF CHAR; VAR d: ARRAY OF CHAR );
(*
    IF HIGH (d) < 7 THEN
      ASSEMBLER
        TRAP    #6
        DC.W    -8      ; string overflow
      END
    ELSE
      WITH s DO
        d[0]:=CHR(48 + hour DIV 10);
        d[1]:=CHR(48 + hour MOD 10);
        d[2]:=':';
        d[3]:=CHR(48 + minute DIV 10);
        d[4]:=CHR(48 + minute MOD 10);
        d[5]:=':';
        d[6]:=CHR(48 + second DIV 10);
        d[7]:=CHR(48 + second MOD 10)
      END;
      IF HIGH (d) > 7 THEN
        d[8]:= 0C
      END
    END
*)
(*
    ASSEMBLER
        MOVE.W  -(A3),D0
        MOVE.L  -(A3),A0
        MOVE.W  -(A3),D1
        MOVE.L  -(A3),A1        ; mask
        CMPI    #7,D0
        BCC     ok
        TRAP    #6
        DC.W    StringOverflow
        SUBQ.L  #6,A3
        BRA     ende
      ok
        BEQ     ok2
        CLR.B   8(A0)
      ok2
        MOVEQ   #48,D1
        BSR     upro
        MOVE.B  #':',(A0)+
        BSR     upro
        MOVE.B  #':',(A0)+
        BSR     upro
        BRA     ende
      upro
        MOVEQ   #0,D0
        MOVE.W  -(A3),D0        ; Time.hour
        DIVU    #10,D0
        ADD.B   D1,D0
        MOVE.B  D0,(A0)+
        SWAP    D0
        ADD.B   D1,D0
        MOVE.B  D0,(A0)+
        RTS
      ende
    END
*)
    (* %% Komplett neue PROCEDURE TimeToText. Wertet jetzt 'mask' komplett
     * aus. Jeder Wert wird nur einmal in das Ergebnis gesetzt.
     * Es wird kein Test auf ungÅltige Werte in 's' vorgenommen, sollten
     * aber auch nicht drin sein.
     *)
    VAR english : BOOLEAN;
        l       : CARDINAL;
        p       : INTEGER;
        i,j     : CARDINAL;
        ch      : CHAR;
        up, hSet, mSet, sSet, eSet: BOOLEAN;
        
  PROCEDURE set (value: CARDINAL; zeros: BOOLEAN);
    VAR ins: String;
    BEGIN
      ins := NumToStr (value,10,2,'0');
      IF zeros OR (ins[0] # '0') THEN
        d[j] := ins[0];
        INC(j);
      END;
      d[j] := ins[1];
      INC(j);
      INC(i, 2);
    END set;

  PROCEDURE copy;
    BEGIN
      d[j] := mask[i];
      INC(j);
      INC(i);
    END copy;
  
  BEGIN
    IF Empty (mask) THEN
      TimeToText (s, StdTimeMask, d);
      RETURN
    END;
    (* Flags initialisieren *)
    english := FALSE;
    hSet := FALSE;
    mSet := FALSE;
    sSet := FALSE;
    eSet := FALSE;
    l := Length (mask);
    IF l > (HIGH(d)+1) THEN
      ASSEMBLER
        TRAP    #6
        DC.W    StringOverflow
      END;
      l:= HIGH (d)+1
    END;
    
    (* Test auf englische Notierung: *)
    p:= 0;
    LOOP
      p:= Strings.Pos ('#', mask, p);
      IF p < 0 THEN EXIT END;
      INC (p);
      IF CAP (mask[p]) = 'E' THEN
        english := TRUE;
        EXIT
      END
    END;
    
    (* Maske scannen *)
    j := 0;
    i := 0;
    WHILE i < l DO
      ch:= mask[i];
      IF (ch = '#') & (CAP(mask[i+1])='E') & ~eSet THEN
        up:= mask[i+1]='E';
        IF s.hour > 12 THEN
          d[j] := 'p'
        ELSE
          d[j] := 'a'
        END;
        IF up THEN d[j]:= CAP (d[j]) END;
        INC(j);
        IF up THEN d[j]:= 'M' ELSE d[j]:= 'm' END;
        INC(j);
        INC(i,2);
        eSet := TRUE;
      ELSIF mask[i+1]=ch THEN
        up:= ch = CAP (ch);
        IF (CAP (ch) = 'H') & ~hSet THEN
          IF english & (s.hour > 12) THEN
            set (s.hour-12, up);
          ELSE
            set (s.hour, up)
          END;
          hSet:= TRUE
        ELSIF (CAP (ch) = 'M') & ~mSet THEN
          set (s.minute, up);
          mSet:= TRUE
        ELSIF (CAP (ch) = 'S') & ~sSet THEN
          set (s.second, up);
          sSet:= TRUE
        ELSE
          copy
        END
      ELSE
        copy
      END
    END (* WHILE i *);
    IF j <= HIGH (d) THEN
      d[j] := 0c
    END;
  END TimeToText;


PROCEDURE mon (lang: INTEGER; month: CARDINAL): MonStr;
          (* lang: -1: User-defined, 0: Deutsch, 1:Frz., 2:Engl *)
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE    -(A3),D0
        SUBQ    #1,D0
        MOVE    -(A3),D1
        MOVE.L  A3,A0
        ADDA.W  #monHigh+1,A3
        BEQ     tger
        BMI     tusr
        SUBQ    #2,D1
        BCS     tfrz

        LEA     eng(PC),A1
        BRA     cont
      tfrz:
        LEA     frz(PC),A1
        BRA     cont
      tger:
        LEA     ger(PC),A1
        BRA     cont

      lup:
        TST.B   (A1)+
        BNE     lup
      cont:
        DBRA    D0,lup
      lup2:
        MOVE.B  (A1)+,(A0)+
        BNE     lup2
        RTS

      tusr:
        LEA     NameOfMonth,A1
        MULU    #10,D0          ; SIZE (NameOfMonth[1])
        ADDA.W  D0,A1
        MOVEQ   #monHigh,D1
      lupu:
        MOVE.B  (A1)+,(A0)+
        DBEQ    D1,lupu
        RTS

      ger:
        ACZ     'Januar'
        ACZ     'Februar'
        ACZ     'MÑrz'
        ACZ     'April'
        ACZ     'Mai'
        ACZ     'Juni'
        ACZ     'Juli'
        ACZ     'August'
        ACZ     'September'
        ACZ     'Oktober'
        ACZ     'November'
        ACZ     'Dezember'
        
      frz:
        ACZ     'Janvier'
        ACZ     'FÇvrier'
        ACZ     'Mars'
        ACZ     'Avril'
        ACZ     'Mai'
        ACZ     'Juin'
        ACZ     'Juillet'
        ACZ     'Aoñt'
        ACZ     'Septembre'
        ACZ     'Octobre'
        ACZ     'Novembre'
        ACZ     'DÇcembre'
        
      eng:
        ACZ     'January'
        ACZ     'February'
        ACZ     'March'
        ACZ     'April'
        ACZ     'May'
        ACZ     'June'
        ACZ     'July'
        ACZ     'August'
        ACZ     'September'
        ACZ     'October'
        ACZ     'November'
        ACZ     'December'
    END
  END mon;
  (*$L=*)

PROCEDURE DateToText ( s: Date; REF m0: ARRAY OF CHAR; VAR d: ARRAY OF CHAR );

  VAR mask: String;

  PROCEDURE Del (a,b:INTEGER);
    BEGIN
      Delete (d,a,b);
      Delete (mask,a,b)
    END Del;

  PROCEDURE set (ch:CHAR; v: CARDINAL): BOOLEAN;
    VAR p,l,n:CARDINAL; ps: POINTER TO String; s2:String; c1,c2: CHAR; ok: BOOLEAN;
    BEGIN
      ok:= Pos (ch,d)>=0;
      IF ok THEN
        p:= Pos (ch,d);
        n:=1;
        WHILE Chr (d,p+n) = ch DO
          INC (n)
        END;
        IF (Chr(d,p+n)='#') & (Chr(mask,p+n+1)='E') THEN
          IF v=1 THEN c1:='s'; c2:='t'
          ELSIF v=2 THEN c1:='n'; c2:='d'
          ELSIF v=3 THEN c1:='r'; c2:='d'
          ELSE c1:='t'; c2:='h' END;
          d[p+n]:=c1; d[p+n+1]:=c2
        END;
        s2:= CardToStr (v,0);
        l:= Length (s2);
        IF l >= n THEN
          (* Feld wird vollst. gefÅllt; die Zahl rechtsbÅndig kopieren: *)
          ps:= ADR (d)+LONG(p);
          Repl (s2,l-n,n,ps^)
        ELSE
          IF mask[p] >= 'a' THEN
            (* Feld ist zu groû; kÅrzen: *)
            Del (p,n-l);
            ps:= ADR (d)+LONG(p);
            Repl (s2,0,l,ps^);
          ELSE
            (* Feld ist zu groû; mit Nullen fÅllen: *)
            WHILE l # n DO
              d[p]:='0';
              INC (p);
              DEC (n)
            END;
            ps:= ADR (d)+LONG(p);
            Repl (s2,0,l,ps^)
          END
        END
      END;
      RETURN ok
    END set;

  PROCEDURE monset (ch:CHAR; v: INTEGER);
    VAR p,l,n:CARDINAL; ps: POINTER TO String; s2: MonStr;
    BEGIN
      IF Pos (ch,d)>=0 THEN
        p:= Pos (ch,d);
        n:=1;
        WHILE Chr (d,p+n) = ch DO
          INC (n)
        END;
        s2:= mon(v,s.month);
        l:= Length (s2);
        IF l >= n THEN
          (* Feld wird vollst. gefÅllt; den String linksbÅndig kopieren: *)
          l:=n;
        ELSE
          (* Feld ist zu groû; kÅrzen: *)
          Del (p,n-l)
        END;
        ps:= ADR (d)+LONG(p);
        Repl (s2,0,l,ps^)
      END
    END monset;
  
  VAR ok: BOOLEAN;
  
  BEGIN
    IF m0[0]=0C THEN
      Assign (StdDateMask,mask)
    ELSE
      Assign (m0,mask)
    END;
    IF HIGH (d)+1 < Length (mask) THEN
      ASSEMBLER
        TRAP    #6
        DC.W    -8      ; string overflow
      END
    ELSE
      Assign (mask,d);
      IF ~set ('D',s.day) THEN ok:= set ('d',s.day) END;
      IF ~set ('M',s.month) THEN ok:= set ('m',s.month) END;
      IF ~set ('Y',s.year) THEN ok:= set ('y',s.year) END;
      monset ('U',-1);
      monset ('G',0);
      monset ('F',1);
      monset ('E',2);
    END
  END DateToText;

PROCEDURE skip (VAR s:ARRAY OF CHAR; VAR p:CARDINAL);
  BEGIN
    WHILE (p<Length(s)) & ( (s[p]<'0') OR ((s[p]>'9') & (s[p]<'@')) ) DO
      INC (p)
    END;
  END skip;

PROCEDURE get (VAR s: ARRAY OF CHAR; VAR p: CARDINAL;
               VAR valid: BOOLEAN; required: BOOLEAN;
               n: CARDINAL; low,hi:INTEGER; VAR i: WORD);
  VAR p2:CARDINAL; str: ARRAY [0..3] OF CHAR; v: BOOLEAN;
  BEGIN
    (* maximal n Ziffern auswerten *)
    Copy (s,p,n,str);
    p2:= 0;
    i:= WORD (StrToInt (str, p2, v));
    INC (p, p2);
    skip (s,p);
    IF v THEN
      IF (INTEGER(i)<low) OR (INTEGER(i)>hi) THEN i:= WORD(0); valid:=FALSE END
    ELSE
      i:= WORD(0);
      IF required THEN valid:= FALSE END
    END;
  END get;

PROCEDURE TextToTime ( s: ARRAY OF CHAR; VAR d: Time; VAR valid: BOOLEAN );
  
  VAR p: CARDINAL; v: BOOLEAN;
  
  BEGIN
    p:=0;
    valid:=TRUE;
    (* fÅhrende Blanks Åberspringen *)
    WHILE s[p]=' ' DO INC (p) END;
    get (s,p,valid,TRUE,2,0,23,d.hour);
    get (s,p,valid,FALSE,2,0,59,d.minute);
    get (s,p,valid,FALSE,2,0,59,d.second);
    (* prÅfen: Nach der Zeitangabe muû der String zu Ende sein *)
    IF p < Length (s) THEN valid:= FALSE END
  END TextToTime;

(*
   1: d-m-y
   2: m-d-y
   3: y-m-d
   4: y-d-m
*)

PROCEDURE TextToDate ( s: ARRAY OF CHAR; exp: CARDINAL; VAR d: Date; VAR valid: BOOLEAN );
  VAR p:CARDINAL;
  PROCEDURE getd;
    BEGIN
      IF valid THEN
        get (s,p,valid,TRUE,2,1,31,d.day)
      END
    END getd;
  PROCEDURE getm;
    VAR n,m:CARDINAL; lang: INTEGER; m1,m2: MonStr;
    BEGIN
      IF valid THEN
        WHILE Chr(s,p)=' ' DO INC (p) END;
        n:=0;
        WHILE IsAlpha (Chr (s,p+n)) DO INC (n) END;
        IF n>0 THEN
          Copy (s,p,n,m1);
          FOR m:=1 TO 12 DO
            FOR lang:=-1 TO langHigh DO
              Strings.Copy (mon(lang,m),0,n,m2,strok);
              Upper (m2);
              IF StrEqual (m2,m1) THEN
                d.month:=m;
                INC (p,n); skip (s,p);
                RETURN
              END
            END
          END;
          valid:= FALSE
        ELSE
          get (s,p,valid,TRUE,2,1,12,d.month)
        END
      END
    END getm;
  PROCEDURE gety;
    BEGIN
      IF valid THEN
        get (s,p,valid,TRUE,4,-30000,30000,d.year);
        IF valid THEN
          IF (d.year>=80) & (d.year<=99) THEN INC (d.year,1900) END
        END
      END
    END gety;
  BEGIN
    IF (exp=0) OR (exp>4) THEN exp:= StdDateExp END;
    valid:=TRUE;
    Upper (s);
    p:=0;
    (* fÅhrende Blanks Åberspringen *)
    WHILE s[p]=' ' DO INC (p) END;
    CASE exp OF
      1: getd; getm; gety|
      2: getm; getd; gety|
      3: gety; getm; getd|
      4: gety; getd; getm|
    END;
    (* Numerisch gÅltig, jetzt logische PrÅfung
     (Jedes 4. Jahr, auûer es ist ein Jahrhundert und nicht ein Jahrvierhundert)
    *)
    IF valid THEN
      (* prÅfen: Nach der Zeitangabe muû der String zu Ende sein *)
      WITH d DO
        IF p < Length (s) THEN
          valid:= FALSE
        ELSIF (day > 30) & ((month = 2) OR (month = 4) OR (month = 6) OR
            (month = 9) OR (month = 11)) THEN
           valid := FALSE;
        ELSIF (day > 29) & (month = 2) THEN
          valid := FALSE;
        ELSIF (day = 29) & (month = 2) THEN
          IF ~((year MOD 4 = 0) &
              ((year MOD 100 <> 0) OR (year MOD 400 = 0))) THEN
            valid := FALSE;
          END
        END
      END;
    END;
  END TextToDate;

END TimeConvert.
