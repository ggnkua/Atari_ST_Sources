IMPLEMENTATION MODULE Clock; (* V#005 *)
(*$Y+,R-*)

FROM SYSTEM IMPORT ASSEMBLER;

(*
  06.08.89  TT  öbernahme der DateUtil-Funktionen (V2.00) von Markus Kilbinger
  10.11.90  TT  $L+ bei DateUtil-Funktionen - sollten nun laufen
*)

(*
TYPE    Date = RECORD
                 day  : [1..31];
                 month: [1..12];
                 year : CARDINAL
               END;

        Time = RECORD
                 second: [0..59];
                 minute: [0..59];
                 hour  : [0..23]
               END;
*)

(*$L-*)

PROCEDURE PackDate ( d: Date ): CARDINAL;
  BEGIN
    ASSEMBLER
        MOVE    -(A3),D0        ; YEAR
        SUBI    #1980,D0
        BCC     C
        MOVE    (A3),D0
     C: ANDI    #$7F,D0
        LSL     #8,D0
        LSL     #1,D0
        
        MOVE    -(A3),D1        ; MONTH
        ANDI    #$F,D1
        LSL     #5,D1
        
        MOVE    -(A3),D2        ; DAY
        ANDI    #$1F,D2
        
        OR      D1,D0
        OR      D2,D0
        MOVE    D0,(A3)+
    END
  END PackDate;

PROCEDURE UnpackDate ( d: CARDINAL ): Date;
  BEGIN
    ASSEMBLER
        MOVE    -(A3),D0
        
        MOVE    D0,D1
        ANDI    #$1F,D1
        MOVE    D1,(A3)+
        
        LSR     #5,D0
        MOVE    D0,D1
        ANDI    #$F,D1
        MOVE    D1,(A3)+
        
        LSR     #4,D0
        ADDI    #1980,D0
        MOVE    D0,(A3)+
    END
  END UnpackDate;

PROCEDURE PackTime ( t: Time ): CARDINAL;
  BEGIN
    ASSEMBLER
        MOVE    -(A3),D0        ; HOUR
        ANDI    #$1F,D0
        LSL     #8,D0
        LSL     #3,D0
        
        MOVE    -(A3),D1        ; MINUTE
        ANDI    #$3F,D1
        LSL     #5,D1
        
        MOVE    -(A3),D2        ; SEC
        LSR     #1,D2
        ANDI    #$1F,D2
        
        OR      D1,D0
        OR      D2,D0
        MOVE    D0,(A3)+
    END
  END PackTime;

PROCEDURE UnpackTime ( t: CARDINAL ): Time;
  BEGIN
    ASSEMBLER
        MOVE    -(A3),D0
        
        MOVE    D0,D1
        ANDI    #$1F,D1
        LSL     #1,D1
        MOVE    D1,(A3)+
        
        LSR     #5,D0
        MOVE    D0,D1
        ANDI    #$3F,D1
        MOVE    D1,(A3)+
        
        LSR     #6,D0
        MOVE    D0,(A3)+
    END
  END UnpackTime;

PROCEDURE CurrentDate (): Date;
  BEGIN
    ASSEMBLER
        MOVE    #$2A,-(A7)
        TRAP    #1
        ADDQ.L  #2,A7
        MOVE    D0,(A3)+
        JMP     UnpackDate
    END
  END CurrentDate;

PROCEDURE CurrentTime (): Time;
  BEGIN
    ASSEMBLER
        MOVE    #$2C,-(A7)
        TRAP    #1
        ADDQ.L  #2,A7
        MOVE    D0,(A3)+
        JMP     UnpackTime
    END
  END CurrentTime;

PROCEDURE SetDateAndTime ( d: Date; t: Time );
  BEGIN
    ASSEMBLER
        JSR     PackTime
        MOVE    -(A3),-(A7)
        MOVE    #$2D,-(A7)
        TRAP    #1
        ADDQ.L  #2,A7
        
        JSR     PackDate
        MOVE    -(A3),-(A7)
        MOVE    #$2B,-(A7)
        TRAP    #1
        ADDQ.L  #2,A7
        
        MOVE    #22,-(A7)       ; TIME & DATE NOCH AUF STACK
        TRAP    #14
        ADDQ.L  #6,A7
    END
  END SetDateAndTime;


PROCEDURE GetDateAndTime ( VAR d:Date; VAR t: Time );
  BEGIN
    ASSEMBLER
        MOVE    #23,-(A7)
        TRAP    #14
        ADDQ.L  #2,A7
        MOVE.L  D0,-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE    D0,(A3)+
        JSR     UnpackTime
        MOVE.L  (A7)+,A0
        ADDQ.L  #6,A0
        MOVE.L  -(A3),-(A0)
        MOVE.W  -(A3),-(A0)
        MOVE.L  (A7)+,D0
        SWAP    D0
        MOVE.L  -(A3),-(A7)
        MOVE    D0,(A3)+
        JSR     UnpackDate
        MOVE.L  (A7)+,A0
        ADDQ.L  #6,A0
        MOVE.L  -(A3),-(A0)
        MOVE.W  -(A3),-(A0)
    END
  END GetDateAndTime;

(*$L+*)


CONST
    SYear       =       4;   (* MOD fÅr Schaltjahr.        *)
    Century     =     100;   (* MOD fÅr Jahrhundert.       *)
    SCentury    =     400;   (* MOD fÅr Schaltjahrhundert. *)
    DaysPerWeek =       7;   (* MOD fÅr Wochentag.         *)
    WeekdayOff  =       5;   (* Offset fÅr Wochentag.      *)
    January     =       1;   (* Nr. vom Januar.            *)
    February    =       2;   (* Nr. vom Februar.           *)
    March       =       3;   (* Nr. vom MÑrz.              *)
    December    =      12;   (* Nr. vom Dezember.          *)
    DaysPerYear =    365L;   (* Tage pro Jahr.             *)
    Dividend    =    400L;   (* kgV von 4, 100, 400.       *)
    Divisor     = 146097L;   (* 400 * 365 + 100 - 4 + 1.   *)

VAR off : ARRAY [January..December] OF INTEGER;   (* Offsets der Monate. *)


PROCEDURE IsSYear (y : CARDINAL) : BOOLEAN;
(* Testet, ob 'y' ein Schaltjahr ist unter BerÅcksichtigung des
   gregorianischen Kalenders: Jahre, die mit zwei Nullen enden, sind nur
   dann ein Schaltjahr, wenn sie durch 400 teilbar sind. *)
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVEQ   #0,D0
        MOVE.W  -(A3),D0
        MOVE    D0,D1
        ANDI    #3,D1
        BNE     no
        MOVE.L  D0,D1
        DIVU    #100,D1
        SWAP    D1
        TST.W   D1
        BNE     yes
        DIVU    #400,D0
        SWAP    D0
        TST.W   D0
        BNE     no
    yes MOVE    #1,(A3)+
        RTS
     no CLR     (A3)+
    END
  END IsSYear;
  (*$L=*)
  
  
PROCEDURE DayOfWeek (d : Date) : WeekDays;
  VAR w: INTEGER;
  BEGIN
    WITH d DO
      w := year + (year DIV SYear) - (year DIV Century) +
           (year DIV SCentury) + off [month] + INTEGER(day) + WeekdayOff;
      IF (IsSYear (year) AND (month < March)) THEN
        DEC (w);
      END;
    END;
    w := w MOD DaysPerWeek;
    RETURN WeekDays (w);
  END DayOfWeek;
  
  
PROCEDURE YearFac (y : CARDINAL) : LONGINT;
(* Berechnet den Teil des 'Factor', der durch das Jahr 'y' bedingt ist. *)
  (*$L-*)
  BEGIN
    ASSEMBLER
        ; RETURN (LONG (y) * DaysPerYear + LONG ((y DIV SYear) -
        ; (y DIV Century) + (y DIV SCentury)));
        MOVEQ   #0,D0
        MOVE    -(A3),D0
        MOVE    D0,D1
        MULU    #365,D1
        MOVE.L  D0,D2
        LSR.L   #2,D2
        ADD.L   D2,D1
        MOVE.L  D1,A0
        MOVE.L  D0,D2
        DIVU    #100,D2
        SUBA.W  D2,A0
        DIVU    #400,D0
        ADDA.W  D0,A0
        MOVE.L  A0,(A3)+
    END
  END YearFac;
  (*$L=*)
  
  
PROCEDURE Factor (d : Date) : LONGINT;
(* Berechnet die Anzahl der Tage zu einem fiktiven Datum fÅr Tag-Differenz. *)
  VAR f : LONGINT;
  BEGIN
    WITH d DO
      f := YearFac (year) + LONG (off [month] + INTEGER(day));
      IF (IsSYear (year) AND (month < March)) THEN
        DEC (f);
      END;
    END;
    RETURN f;
  END Factor;
  
  
PROCEDURE DaysBetween (d1, d2 : Date) : LONGINT;
  BEGIN
    RETURN (Factor (d2) - Factor (d1));
  END DaysBetween;


PROCEDURE UnFactor (f : LONGINT) : Date;
(* Wandelt eine mit 'Factor' erzeugt Anzahl 'f' von Tagen in ein Datum um. *)

  VAR
    g : LONGINT;
    d : Date;
    s : INTEGER;
    i : CARDINAL;

  BEGIN
    WITH d DO
      year := SHORT (((f - 1L) * Dividend) DIV Divisor);
      g    := YearFac (year);
      
      IF ((f - g) > DaysPerYear) THEN
        INC (year);
        g := YearFac (year);
      END;
      s := SHORT (f - g);
      
      IF (IsSYear (year) AND (s <= off [March])) THEN
        INC (s);
        
        IF (s > off [February]) THEN
          month := February;
          DEC (s, off [February]);
        ELSE
          month := January;
        END;
      ELSE
        i := December;
        
        WHILE (i >= January) DO
          month := i;
          
          IF (s > off [i]) THEN
            i := January;
          END;
          DEC (i);
        END;
        DEC (s, off [month]);
      END;
      day := s;
    END;
    RETURN d;
  END UnFactor;


PROCEDURE DaysAdded (d : Date; n : LONGINT) : Date;
  BEGIN
    RETURN UnFactor (Factor (d) + n);
  END DaysAdded;
  
  
BEGIN
  ASSEMBLER
        LEA     off,A0
        CLR.W   (A0)+
        MOVE.W  #31,(A0)+    (* + 31 *)
        MOVE.W  #59,(A0)+    (* + 28 *)
        MOVE.W  #90,(A0)+    (* + 31 *)
        MOVE.W  #120,(A0)+   (* + 30 *)
        MOVE.W  #151,(A0)+   (* + 31 *)
        MOVE.W  #181,(A0)+   (* + 30 *)
        MOVE.W  #212,(A0)+   (* + 31 *)
        MOVE.W  #243,(A0)+   (* + 31 *)
        MOVE.W  #273,(A0)+   (* + 30 *)
        MOVE.W  #304,(A0)+   (* + 31 *)
        MOVE.W  #334,(A0)    (* + 30 *)
  END;
END Clock.
