
MODULE Mario;

(* Erstellt: tt 26.2.88 nach Listing v. Turbo 4.0 / MSDOS v. cd

*)

FROM VDIOutputs IMPORT Mark;
FROM VDIAttributes IMPORT DefineColor, SetMarkerColor;
FROM VDIInquires IMPORT GetColorDef;
FROM GrafBase IMPORT Point;
FROM GEMEnv IMPORT DeviceParameter, PtrDevParm, DeviceHandle, InitGem, RC;

FROM SYSTEM IMPORT
        ADDRESS;

FROM Storage IMPORT
        ALLOCATE;

FROM InOut IMPORT
        WriteString, WriteLn, WriteHex, WriteReal, GotoXY, ReadReal, Done,
        FlushKbd, Read, BusyRead, ReadCard, WritePg, WriteFix, ReadString,
        WriteCard;

FROM Strings IMPORT
        Empty, Length, Upper;

IMPORT MathLib0, Files, Binary;


CONST
        x_start     = 0.35;
        zoom        = 5000;
        fname       = '\MARIO.IMG';

TYPE
        seqrange = [1..79];

VAR
        conv_crit: LONGREAL;
        sequence: ARRAY seqrange OF CHAR;
        seqlen: seqrange;
        
        a_min, a_max, b_min, b_max: LONGREAL;
        x_points, y_points: CARDINAL;


MODULE math;
(*$R-*)

  IMPORT
        seqrange, x_start, conv_crit, sequence, seqlen;

  FROM MathLib0 IMPORT
        ln;

  EXPORT
        lyapunow;

  VAR
        iteration: LONGCARD;
        sum: LONGREAL;
        quer, quer_alt: LONGREAL;
        conv: LONGREAL;

        ln2: LONGREAL;

  PROCEDURE poincare (r, x: LONGREAL): LONGREAL;
    BEGIN
      RETURN r * x * (1.-x)
    END poincare;

  PROCEDURE dpc (r, x: LONGREAL): LONGREAL;
    BEGIN
      RETURN r - 2. * r * x
    END dpc;

  PROCEDURE quer_conv (log: LONGREAL; VAR quer, conv: LONGREAL);
    BEGIN
      sum:= sum + log;
      quer:= sum / LFLOAT (iteration);
      conv:= ABS (quer - quer_alt);
      quer_alt:= quer
    END quer_conv;

  PROCEDURE lyapunow (a, b: LONGREAL): LONGREAL;
    
    VAR
        (*$Reg*)conv_alt,
        (*$Reg*)x,
        (*$Reg*)x_alt,
        (*$Reg*)r,
        (*$Reg*)abl: LONGREAL;
        seqidx: seqrange;
        
    BEGIN
      x_alt:= x_start;
      sum:= 0.;
      quer_alt:= 0.;
      conv:= conv_crit * 2.;
      iteration:= 0;
      REPEAT
        FOR seqidx:= 1 TO seqlen DO
          IF sequence [seqidx] = 'A' THEN r:= a ELSE r:= b END;
          INC (iteration);
          conv_alt:= conv;
          (*x:= poincare (r, x_alt);*)
          x:= r * x_alt * (1.-x_alt);
          (*abl:= ABS (dpc (r, x_alt));*)
          abl:= ABS (r - 2. * r * x_alt);
          IF abl # 0. THEN
            (*quer_conv (ln (abl) / ln2, quer, conv);*)
            sum:= sum + ln (abl) / ln2;
            quer:= sum / LFLOAT (iteration);
            conv:= ABS (quer - quer_alt);
            quer_alt:= quer
          ELSE
            quer:= 0.;
            conv:= -200000.0
          END;
          x_alt:= x
        END
      UNTIL (conv < conv_crit) AND (conv_alt < conv_crit);
      RETURN quer
    END lyapunow;

  BEGIN
    ln2:= ln (2.)
  END (* module *) math;
(*$R+*)


PROCEDURE input (): BOOLEAN;
  VAR i: CARDINAL;
  BEGIN
    WritePg;
    a_min:= 3.825;
    b_min:= 3.825;
    a_max:= 3.86;
    b_max:= 3.86;
    x_points:= 50;
    y_points:= 50;
    conv_crit:= 0.001;
    sequence:= 'AABBAB';
    (*
    WriteString ('min (A)  ? ');
    ReadReal (a_min);
    IF ~Done THEN RETURN FALSE END;
    WriteString ('max (A)  ? ');
    ReadReal (a_max);
    IF ~Done THEN RETURN FALSE END;
    WriteString ('min (B)  ? ');
    ReadReal (b_min);
    IF ~Done THEN RETURN FALSE END;
    WriteString ('max (B)  ? ');
    ReadReal (b_max);
    IF ~Done THEN RETURN FALSE END;
    WriteString ('n (A)    ? ');
    ReadCard (x_points);
    IF ~Done THEN RETURN FALSE END;
    WriteString ('n (B)    ? ');
    ReadCard (y_points);
    IF ~Done THEN RETURN FALSE END;
    WriteString ('conv     ? ');
    ReadReal (conv_crit);
    IF ~Done THEN RETURN FALSE END;
    WriteString ('sequence ? ');
    ReadString (sequence);
    IF Length (sequence) < 2 THEN RETURN FALSE END;
    Upper (sequence);
    FOR i:= 1 TO Length (sequence) DO
      IF (sequence [i] # 'A') AND (sequence [i] # 'B') THEN RETURN FALSE END
    END;
    *)
    RETURN TRUE
  END input;


PROCEDURE stop (): BOOLEAN;
  VAR ch: CHAR;
  BEGIN
    BusyRead (ch);
    RETURN ch = 33C
  END stop;


VAR
        a_inc, b_inc: LONGREAL;
        a, b: LONGREAL;
        x, y: CARDINAL;
        lyap: LONGREAL;

        point, image: POINTER TO INTEGER;
        v: LONGINT;
        vs: INTEGER;

        ch: CHAR;

PROCEDURE init (): BOOLEAN;
  BEGIN
    a_inc:= (a_max-a_min) / LFLOAT (x_points);
    b_inc:= (b_max-b_min) / LFLOAT (y_points);
    seqlen:= Length (sequence);
    ALLOCATE (image, SIZE (image^) * LONG (x_points) * LONG (y_points));
    RETURN image # NIL
  END init;

PROCEDURE saveImage;

  VAR f: Files.File;

  PROCEDURE err (): BOOLEAN;
    BEGIN
      IF Files.State (f) < 0 THEN
        WriteLn;
        WriteString ('Write error !');
        Files.ResetState (f);
        Files.Close (f);
        RETURN TRUE
      ELSE
        RETURN FALSE
      END
    END err;

  VAR card: CARDINAL;

  BEGIN
    WriteLn;
    WriteString ('Writing image...');
    Files.Create (f, fname, Files.writeOnly, Files.replaceOld);
    IF err () THEN RETURN END;
    card:= 12345;
    Binary.WriteBlock (f, card);
    IF err () THEN RETURN END;
    Binary.WriteBlock (f, x_points);
    IF err () THEN RETURN END;
    Binary.WriteBlock (f, y_points);
    IF err () THEN RETURN END;
    card:= SHORT (SIZE (image^));
    Binary.WriteBlock (f, card);
    IF err () THEN RETURN END;
    card:= zoom;
    Binary.WriteBlock (f, card);
    IF err () THEN RETURN END;
    Binary.WriteBytes (f, image, LONGCARD (ADDRESS (point) - ADDRESS (image)));
    IF err () THEN RETURN END;
    Files.Close (f);
    IF err () THEN RETURN END;
    WriteString (' OK.');
  END saveImage;

PROCEDURE showPos (x,y:CARDINAL);
  BEGIN
    GotoXY (0, 12);
    WriteString ('  x    y');
    WriteLn;
    WriteCard (x,4);
    WriteCard (y,5);
  END showPos;

PROCEDURE showLyap;
  BEGIN
    WriteLn;
    WriteReal (lyap,3,8);
  END showLyap;

VAR ok: BOOLEAN;
    dh: DeviceHandle;
    dp: PtrDevParm;
    n: CARDINAL;
    r,g,b0:ARRAY [0..1023] OF CARDINAL;

PROCEDURE rstcol;
  VAR ch: CHAR; n: CARDINAL;
  BEGIN
    FOR n:= 0 TO dp^.noColors-1 DO
      DefineColor (dh, n, r[n],g[n],b0[n])
    END;
  END rstcol;

PROCEDURE finish;
  VAR ch: CHAR; n: CARDINAL;
  BEGIN
    WriteLn;
    WriteString ('Press a key to end...');
    FlushKbd;
    Read (ch);
  END finish;


BEGIN
  IF input () AND init () THEN
    InitGem (RC, dh, ok);
    IF NOT ok THEN HALT END;
    
    dp:= DeviceParameter (dh);
    
    FOR n:= 0 TO dp^.noColors-1 DO
      GetColorDef (dh, n, FALSE, r[n],g[n],b0[n])
    END;
    FOR n:= 0 TO 127 DO
      DefineColor (dh, n, n*8, 0, 0);
    END;
    FOR n:= 0 TO 127 DO
      DefineColor (dh, n+128, 0, n*8, 0);
    END;
    
    point:= image;
    b:= b_min;
    FOR y:= 1 TO y_points DO
      a:= a_min;
      FOR x:= 1 TO x_points DO
        lyap:= lyapunow (a,b);
        (*
        showPos (x,y);
        showLyap;
        *)
        (*
        IF lyap # 0.0 THEN
          v:= MathLib0.entier (lyap * LFLOAT (zoom));
          IF v = 0L THEN
            IF lyap < 0. THEN v:= MinInt ELSE v:= MaxInt END
          END
        ELSE
          v:= 0
        END;
        IF v < 0L THEN
          IF v < LONG (MinInt) THEN v:= MinInt END
        ELSE
          IF v < LONG (MaxInt) THEN v:= MaxInt END
        END;
        point^:= SHORT (v);
        INC (point, SHORT (SIZE (point^)));
        *)
        (*
        WriteCard (y,5);
        WriteCard (x,5);
        WriteInt (v, 10);
        WriteLn;
        *)
        vs:= VAL (INTEGER,lyap * LFLOAT (128));
        IF vs < 0 THEN
          IF vs < -128 THEN vs:= -128 END;
          (*vs:= -(129-INTEGER(ABS(vs)))*)
        ELSE
          IF vs > 127 THEN vs:= 127 END;
          (*vs:= 127-vs*)
        END;
        SetMarkerColor (dh, vs+128);
        Mark (dh, Point {x,y});
        a:= a + a_inc;
        IF stop () THEN rstcol; RETURN END
      END;
      b:= b + b_inc
    END;
    (*
    saveImage;
    *)
  END;
  finish;
  rstcol
END Mario.
 
(* $000011FE$00000C07$00001EE9$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF990DA$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1$FFF3BAC1Ä$00001A90T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00000416$00000BB6$000018C0$00001A90$00000119$00001AAB$00001A90$000011BB$00001897$00001ACC$FFEB9CC2$FFEB9CC2$FFEB9CC2$0000192F$00000011$00000422êÄÄ*)
