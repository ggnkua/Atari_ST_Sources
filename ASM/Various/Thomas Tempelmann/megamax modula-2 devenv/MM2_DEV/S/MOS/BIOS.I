IMPLEMENTATION MODULE BIOS;
(*$Z-,Y+,S-,N+,R-,L-*)

(*
   TT 21.07.89  BConOut l”scht High-Byte der auszugebenden Zeichen, weil
                sonst abscheinend Busfehler bei ESC-Sequenzen auftreten
                k”nnen.
   TT 20.07.90  DriveMap: SETs verkehrt
*)

FROM SYSTEM IMPORT ADDRESS, LONGWORD, ASSEMBLER, CAST;

PROCEDURE BConStat (dev: Device): BOOLEAN;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE.W  #$01,-(A7)
        TRAP    #13
        ADDQ.L  #4,A7
        ANDI    #1,D0
        MOVE    D0,(A3)+
    END;
  END BConStat;

PROCEDURE BCosStat (dev: Device): BOOLEAN;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE.W  #$08,-(A7)
        TRAP    #13
        ADDQ.L  #4,A7
        ANDI    #1,D0
        MOVE    D0,(A3)+
    END;
  END BCosStat;

PROCEDURE BConIn (dev: Device): LONGCARD;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE    #2,-(A7)
        TRAP    #13
        ADDQ.L  #4,A7
        MOVE.L  D0,(A3)+
    END
  END BConIn;

PROCEDURE BConOut (dev: Device; ch: CHAR);
  BEGIN
    ASSEMBLER
        SUBQ.L  #1,A3
        MOVEQ   #0,D0
        MOVE.B  -(A3),D0
        MOVE.W  D0,-(A7)
        MOVE.W  -(A3),-(A7)
        MOVE    #3,-(A7)
        TRAP    #13
        ADDQ.L  #6,A7
    END
  END BConOut;

PROCEDURE RWAbs (mode: RW; buffer: ADDRESS;
                 blocks, blkno, drive0: CARDINAL): LONGINT;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.W  #$04,-(A7)
        TRAP    #13
        ADDA.W  #14,A7
        MOVE.L  D0,(A3)+
    END;
  END RWAbs;

PROCEDURE SetException (excno: CARDINAL; proc: ADDRESS);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.W  -(A3),-(A7)
        MOVE    #5,-(A7)
        TRAP    #13
        ADDQ.L  #8,A7
    END
  END SetException;

PROCEDURE GetException (excno: CARDINAL): ADDRESS;
  BEGIN
    ASSEMBLER
        MOVE.L  #-1,-(A7)
        MOVE.W  -(A3),-(A7)
        MOVE    #5,-(A7)
        TRAP    #13
        ADDQ.L  #8,A7
        MOVE.L  D0,(A3)+
    END
  END GetException;

PROCEDURE TimerCalibration (): LONGCARD;
  BEGIN
    ASSEMBLER
        MOVE    #6,-(A7)
        TRAP    #13
        ADDQ.L  #2,A7
        MOVE.L  D0,(A3)+
    END
  END TimerCalibration;

PROCEDURE GetBPB (drive0: CARDINAL): BPBPtr;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE    #7,-(A7)
        TRAP    #13
        ADDQ.L  #4,A7
        MOVE.L  D0,(A3)+
    END
  END GetBPB;

PROCEDURE MediaChange (drive0: CARDINAL): MCState;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE    #9,-(A7)
        TRAP    #13
        ADDQ.L  #4,A7
        MOVE.W  D0,(A3)+
    END
  END MediaChange;

PROCEDURE DriveMap (): DriveSet;
  BEGIN
    ASSEMBLER
        MOVE    #10,-(A7)
        TRAP    #13
        ADDQ.L  #2,A7
        MOVE.L  D0,(A3)+
    END
  END DriveMap;

PROCEDURE SetKBShift (keys: KBShifts);
  BEGIN
    ASSEMBLER
        SUBQ.L  #1,A3
        MOVE.B  -(A3),D0
        MOVE    D0,-(A7)
        MOVE    #11,-(A7)
        TRAP    #13
        ADDQ.L  #4,A7
    END
  END SetKBShift;

PROCEDURE GetKBShift (): KBShifts;
  BEGIN
    ASSEMBLER
        MOVE    #-1,-(A7)
        MOVE    #11,-(A7)
        TRAP    #13
        ADDQ.L  #4,A7
        MOVE.B  D0,(A3)+
        CLR.B   (A3)+
    END
  END GetKBShift;

END BIOS.
