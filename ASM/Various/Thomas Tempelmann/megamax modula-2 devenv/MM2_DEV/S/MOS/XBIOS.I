IMPLEMENTATION MODULE XBIOS;
(*$Z-,S-,N+,R-,L-*)
(*$Y+*)

(*
TT 20.07.90: ConfigurePrinter: MOVE.W statt MOVE.L, SET mÅûte nun stimmen
TT 21.08.90: BlitMode & FlopRate neu
TT 08.04.91: SetKeyTable funktioniert nun
TT 20.10.91: $M- entfernt.
*)

FROM SYSTEM IMPORT ASSEMBLER;

FROM SYSTEM IMPORT ADDRESS, LONGWORD, WORD, CAST, BYTE;


PROCEDURE InitMouse (mtyp: MouseType; VAR parm: ParamBlk; serveproc: ADDRESS);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.W  -(A3),-(A7)
        MOVE    #0,-(A7)
        TRAP    #14
        ADDA.W  #12,A7
    END
  END InitMouse;

PROCEDURE ScreenPhysicalBase (): ADDRESS;
  BEGIN
    ASSEMBLER
        MOVE    #2,-(A7)
        TRAP    #14
        ADDQ.L  #2,A7
        MOVE.L  D0,(A3)+
    END
  END ScreenPhysicalBase;

PROCEDURE ScreenLogicalBase (): ADDRESS;
  BEGIN
    ASSEMBLER
        MOVE    #3,-(A7)
        TRAP    #14
        ADDQ.L  #2,A7
        MOVE.L  D0,(A3)+
    END
  END ScreenLogicalBase;

PROCEDURE GetResolution (): INTEGER;
  BEGIN
    ASSEMBLER
        MOVE    #4,-(A7)
        TRAP    #14
        ADDQ.L  #2,A7
        MOVE.W  D0,(A3)+
    END
  END GetResolution;

PROCEDURE SetScreenBase (logAddr, physAddr: ADDRESS; res: INTEGER);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        BNE     OK1
        SUBQ.L  #1,(A7)
      OK1
        MOVE.L  -(A3),-(A7)
        BNE     OK2
        SUBQ.L  #1,(A7)
      OK2
        MOVE.W  -(A3),-(A7)
        MOVE    #5,-(A7)
        TRAP    #14
        ADDA.W  #12,A7
    END
  END SetScreenBase;

PROCEDURE SetPalette (VAR parm: Palette);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE    #6,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
    END
  END SetPalette;

PROCEDURE SetColour (no, col: CARDINAL): CARDINAL;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE    #7,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
        MOVE.W  D0,(A3)+
    END
  END SetColour;

PROCEDURE rw;
  
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.W  -(A3),-(A7)
        CLR.L   -(A7)
        MOVE.L  -(A3),-(A7)
        MOVE    D0,-(A7)
        TRAP    #14
        ADDA.W  #20,A7
        MOVE.W  D0,(A3)+
    END
  END rw;
  

PROCEDURE FloppyRead (buffer: ADDRESS; drive0, sector,
                      track, side, count: CARDINAL): INTEGER;
  
  BEGIN
    ASSEMBLER
        MOVEQ   #8,D0
        JMP     rw
    END
  END FloppyRead;
  

PROCEDURE FloppyWrite (buffer: ADDRESS; drive0, sector,
                       track, side, count: CARDINAL): INTEGER;
  
  BEGIN
    ASSEMBLER
        MOVEQ   #9,D0
        JMP     rw
    END
  END FloppyWrite;
  

PROCEDURE FloppyFormat (buffer: ADDRESS; drive0, sectors, track,
                        side, interleave, virgin: CARDINAL): INTEGER;
  
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE.L  #$87654321,-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.W  -(A3),-(A7)
        CLR.L   -(A7)
        MOVE.L  -(A3),-(A7)
        MOVE    #10,-(A7)
        TRAP    #14
        ADDA.W  #26,A7
        MOVE.W  D0,(A3)+
    END
  END FloppyFormat;
  

PROCEDURE MIDIWS (VAR str: ARRAY OF BYTE; len: CARDINAL);
  
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0
        SUBQ.L  #2,A3
        MOVE.L  -(A3),-(A7)
        MOVE.W  D0,-(A7)
        MOVE    #12,-(A7)
        TRAP    #14
        ADDQ.L  #8,A7
    END
  END MIDIWS;
  

PROCEDURE MFPint (no: CARDINAL; proc: PROC);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.W  -(A3),-(A7)
        MOVE    #13,-(A7)
        TRAP    #14
        ADDQ.L  #8,A7
    END
  END MFPint;

PROCEDURE IORec (dev: SerialDevice): IORECPTR;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE    #14,-(A7)
        TRAP    #14
        ADDQ.L  #4,A7
        MOVE.L  D0,(A3)+
    END
  END IORec;

PROCEDURE ConfigureRS232 (baud: SerialSpeed; handshake: FlowFlavor;
                          ucr, rsr, tsr, scr: INTEGER);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE    #15,-(A7)
        TRAP    #14
        ADDA.W  #14,A7
    END
  END ConfigureRS232;

PROCEDURE SetKeyTable (VAR unshift, shift, caps: KeyTransPtr): KeyTablePtr;
  BEGIN
    ASSEMBLER
        ; oops - hier hÑtte es kein VAR-Parm sein sollen!
        MOVE.L  -(A3),A0
        MOVE.L  (A0),-(A7)
        MOVE.L  -(A3),A0
        MOVE.L  (A0),-(A7)
        MOVE.L  -(A3),A0
        MOVE.L  (A0),-(A7)
        MOVE    #16,-(A7)
        TRAP    #14
        ADDA.W  #14,A7
        MOVE.L  D0,(A3)+
    END
  END SetKeyTable;

PROCEDURE Random (): LONGCARD;
  BEGIN
    ASSEMBLER
        MOVE    #17,-(A7)
        TRAP    #14
        ADDQ.L  #2,A7
        MOVE.L  D0,(A3)+
    END
  END Random;

PROCEDURE PrototypeBootSector (buffer: ADDRESS; serial: LONGINT;
                               dtype, exec: INTEGER);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE    #18,-(A7)
        TRAP    #14
        ADDA.W  #14,A7
    END
  END PrototypeBootSector;

PROCEDURE FloppyVerify (buffer: ADDRESS; drive0, sector,
                        track, side, count: CARDINAL): INTEGER;
  
  BEGIN
    ASSEMBLER
        MOVEQ   #19,D0
        JMP     rw
    END
  END FloppyVerify;
  

PROCEDURE ScreenDump ();
  BEGIN
    ASSEMBLER
        MOVE    #20,-(A7)
        TRAP    #14
        ADDQ.L  #2,A7
    END
  END ScreenDump;

PROCEDURE ConfigureCursor (mode: INTEGER; rate: INTEGER): INTEGER;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE    #21,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
        MOVE.W  D0,(A3)+
    END
  END ConfigureCursor;

PROCEDURE SetDateTime (time: LONGCARD);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE    #22,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
    END
  END SetDateTime;

PROCEDURE GetDateTime (): LONGCARD;
  BEGIN
    ASSEMBLER
        MOVE    #23,-(A7)
        TRAP    #14
        ADDQ.L  #2,A7
        MOVE.L  D0,(A3)+
    END
  END GetDateTime;

PROCEDURE BiosKeys ();
  BEGIN
    ASSEMBLER
        MOVE    #24,-(A7)
        TRAP    #14
        ADDQ.L  #2,A7
    END
  END BiosKeys;

PROCEDURE KeyboardWS (VAR str: ARRAY OF BYTE; len: CARDINAL);
  
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0
        SUBQ.L  #2,A3
        MOVE.L  -(A3),-(A7)
        MOVE.W  D0,-(A7)
        MOVE    #25,-(A7)
        TRAP    #14
        ADDQ.L  #8,A7
    END
  END KeyboardWS;
  

PROCEDURE DisableInterrupt (no: CARDINAL);
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE    #26,-(A7)
        TRAP    #14
        ADDQ.L  #4,A7
    END
  END DisableInterrupt;

PROCEDURE EnableInterrupt (no: CARDINAL);
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE    #27,-(A7)
        TRAP    #14
        ADDQ.L  #4,A7
    END
  END EnableInterrupt;

PROCEDURE GIRead (reg: CARDINAL): CARDINAL;
  
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0
        ANDI    #$7F,D0         ; lesen
        MOVE.W  D0,-(A7)
        CLR     -(A7)
        MOVE    #28,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
        MOVE    D0,(A3)+
    END
  END GIRead;
  

PROCEDURE GIWrite (reg: CARDINAL; data: CARDINAL);
  
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D1
        MOVE.W  -(A3),D0
        ORI     #$80,D0         ; schreiben
        MOVE.W  D0,-(A7)
        MOVE.W  D1,-(A7)
        MOVE    #28,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
    END
  END GIWrite;
  

PROCEDURE GIOffBit (bitno: CARDINAL);
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE    #29,-(A7)
        TRAP    #14
        ADDQ.L  #4,A7
    END
  END GIOffBit;

PROCEDURE GIOnBit (bitno: CARDINAL);
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE    #30,-(A7)
        TRAP    #14
        ADDQ.L  #4,A7
    END
  END GIOnBit;

PROCEDURE SetTimerInterrupt (which: Timer; ctrl, data: CARDINAL; proc: PROC);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.W  -(A3),-(A7)
        MOVE    #31,-(A7)
        TRAP    #14
        ADDA.W  #12,A7
    END
  END SetTimerInterrupt;

PROCEDURE DoSound (data: ADDRESS);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE    #32,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
    END
  END DoSound;

PROCEDURE ConfigurePrinter (data: PrtConfigSet): PrtConfigSet;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE    #33,-(A7)
        TRAP    #14
        ADDQ.L  #4,A7
        MOVE.W  D0,(A3)+
    END
  END ConfigurePrinter;

PROCEDURE KeyboardVectors (): KBVectorPtr;
  BEGIN
    ASSEMBLER
        MOVE    #34,-(A7)
        TRAP    #14
        ADDQ.L  #2,A7
        MOVE.L  D0,(A3)+
    END
  END KeyboardVectors;

PROCEDURE KeyboardRate (delay, repeat: INTEGER): CARDINAL;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE    #35,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
        MOVE.W  D0,(A3)+
    END
  END KeyboardRate;

PROCEDURE VSync ();
  BEGIN
    ASSEMBLER
        MOVE    #37,-(A7)
        TRAP    #14
        ADDQ.L  #2,A7
    END
  END VSync;

PROCEDURE SuperExec (proc: PROC);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE    #38,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
    END
  END SuperExec;

PROCEDURE PuntAES ();
  BEGIN
    ASSEMBLER
        MOVE    #39,-(A7)
        TRAP    #14
        ADDQ.L  #2,A7
    END
  END PuntAES;

PROCEDURE BlitMode (flag: INTEGER): BITSET;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),-(SP)
        MOVE.W  #64,-(SP)
        TRAP    #14
        ADDQ.L  #4,SP
        MOVE.W  D0,(A3)+
    END;
  END BlitMode;

PROCEDURE FlopRate (drive: CARDINAL; rate: INTEGER): INTEGER;
  BEGIN
    ASSEMBLER
        ; zuerst TOS-Version ermitteln
        PEA     tv(PC)
        MOVE    #38,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
        CMPI    #$0100,D0
        BEQ     tos10
        CMPI    #$0102,D0
        BEQ     tos12
        
        MOVE.L  -(A3),-(A7)
        MOVE    #41,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
        MOVE.W  D0,(A3)+
        RTS
     
     tos10
        MOVE.W  #$A09,A0
        BRA     cont
     tos12
        MOVE.W  #$A4F,A0
     cont
        MOVE.W  -(A3),D0
        TST     -(A3)
        BEQ     drvA
        ADDQ.L  #4,A0   ; drive B
     drvA
        TST.W   D0
        BMI     getOnly
        MOVE.B  D0,(A0)
     getOnly
        MOVEQ   #0,D0
        MOVE.B  (A0),D0
        MOVE.W  D0,(A3)+
        RTS
        
     tv MOVE.L  $4F2,A0
        MOVE.W  2(A0),D0
    END
  END FlopRate;

(* TT-Funktionen: *)

PROCEDURE DMAread (sector: LONGCARD; count: CARDINAL; buffer: ADDRESS;
                   devNo: CARDINAL): INTEGER;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE    #$2A,-(A7)
        TRAP    #14
        ADDA.W  #14,A7
        MOVE    D0,(A3)+
    END
  END DMAread;

PROCEDURE DMAwrite (sector: LONGCARD; count: CARDINAL; buffer: ADDRESS;
                   devNo: CARDINAL): INTEGER;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE    #$2B,-(A7)
        TRAP    #14
        ADDA.W  #14,A7
        MOVE    D0,(A3)+
    END
  END DMAwrite;

PROCEDURE NVMaccess (op, start, count: CARDINAL; buffer: ADDRESS): INTEGER;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.W  -(A3),-(A7)
        MOVE    #$2E,-(A7)
        TRAP    #14
        ADDA.W  #12,A7
        MOVE    D0,(A3)+
    END
  END NVMaccess;

PROCEDURE Bconmap (devNo: WORD): LONGWORD;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE    #$2C,-(A7)
        TRAP    #14
        ADDQ.L  #4,A7
        MOVE.L  D0,(A3)+
    END
  END Bconmap;

PROCEDURE EsetShift (shftMode: WORD): WORD;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE    #80,-(A7)
        TRAP    #14
        ADDQ.L  #4,A7
        MOVE.W  D0,(A3)+
    END
  END EsetShift;

PROCEDURE EgetShift (): WORD;
  BEGIN
    ASSEMBLER
        MOVE    #81,-(A7)
        TRAP    #14
        ADDQ.L  #2,A7
        MOVE.W  D0,(A3)+
    END
  END EgetShift;

PROCEDURE EsetBank (bankNum: INTEGER): INTEGER;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE    #82,-(A7)
        TRAP    #14
        ADDQ.L  #4,A7
        MOVE.W  D0,(A3)+
    END
  END EsetBank;

PROCEDURE EsetColor (colorNum, color: INTEGER): INTEGER;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE    #83,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
        MOVE.W  D0,(A3)+
    END
  END EsetColor;

PROCEDURE EsetPalette (colorNum, count: INTEGER; palettePtr: ADDRESS);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE    #84,-(A7)
        TRAP    #14
        ADDA.W  #10,A7
    END
  END EsetPalette;

PROCEDURE EgetPalette (colorNum, count: INTEGER; palettePtr: ADDRESS);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE    #85,-(A7)
        TRAP    #14
        ADDA.W  #10,A7
    END
  END EgetPalette;

PROCEDURE EsetGray (switch: INTEGER): INTEGER;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE    #86,-(A7)
        TRAP    #14
        ADDQ.L  #4,A7
        MOVE.W  D0,(A3)+
    END
  END EsetGray;

PROCEDURE EsetSmear (switch: INTEGER): INTEGER;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),-(A7)
        MOVE    #87,-(A7)
        TRAP    #14
        ADDQ.L  #4,A7
        MOVE.W  D0,(A3)+
    END
  END EsetSmear;

END XBIOS.
