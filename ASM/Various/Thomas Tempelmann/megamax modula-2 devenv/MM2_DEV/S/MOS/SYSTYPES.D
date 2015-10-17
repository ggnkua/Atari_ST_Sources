DEFINITION MODULE SysTypes;

(* Einige nÅtzliche Types und die Exception-Vektor-Konstanten incl. FPU *)

FROM SYSTEM IMPORT BYTE, WORD, LONGWORD, ADDRESS;

TYPE    CHARSET = SET OF CHAR;

        PtrBYTE = POINTER TO BYTE;

        BBS = SET OF [0..7]; (* Byte BitSet *)

        PtrBBS = POINTER TO BBS; (* FÅr Zugriff auf Peripheriebausteine *)

        PtrBP = POINTER TO BasePage;
        
        BasePage = RECORD
                     p_lowtpa: ADDRESS;
                     p_hitpa : ADDRESS;
                     p_tbase : ADDRESS;
                     p_tlen  : ADDRESS;
                     p_dbase : ADDRESS;
                     p_dlen  : ADDRESS;
                     p_bbase : ADDRESS;
                     p_blen  : ADDRESS;
                     p_dta   : ADDRESS;
                     p_parent: ADDRESS;
                     reserve1: ADDRESS;
                     p_env   : ADDRESS;
                     reserve2: ARRAY [$30..$67] OF BYTE;
                     regD0   : LONGCARD;
                     regA3   : LONGCARD;
                     regA4   : LONGCARD;
                     regA5   : LONGCARD;
                     regA6   : LONGCARD;
                     regs    : POINTER TO RECORD
                                 SP: LONGCARD; SR: CARDINAL; PC: LONGCARD;
                                 D1: LONGCARD; D2: LONGCARD; D3: LONGCARD;
                                 D4: LONGCARD; D5: LONGCARD; D6: LONGCARD;
                                 D7: LONGCARD; A0: LONGCARD; A1: LONGCARD;
                                 A2: LONGCARD;
                               END;
                     cmdline : RECORD
                                 len: CHAR;
                                 str: ARRAY [$00..$7E] OF CHAR
                               END
                   END;


        PtrOSHeader = POINTER TO OSHeader;

        OSHeader = RECORD
                     entry: CARDINAL;   (* BRA to reset handler *)
                     version: CARDINAL; (* TOS version number *)
                     reseth: ADDRESS;   (* reset handler *)
                     beg: ADDRESS;      (* base of OS *)
                     end: ADDRESS;      (* end BIOS/GEMDOS/VDI ram usage *)
                     rsv1: LONGWORD;    (* unused, reserved *)
                     magic: ADDRESS;    (* GEM memory usage parm. block *)
                     date: LONGCARD;    (* Date of system build (YYYYMMDD) *)
                     conf: CARDINAL;    (* OS configuration bits *)
                     dosdate: CARDINAL; (* DOS-format date of system build *)
                   (* Die folgenden Felder sind erst seit TOS 1.2 vorhanden: *)
                     root: ADDRESS;     (* base of OS pool *)
                     kbshift: ADDRESS;  (* keyboard shift state variable *)
                     run: ADDRESS;      (* GEMDOS PID of current process *)
                   END;


        PtrAnyType     = POINTER TO AnyType;
        PtrAnyByteType = POINTER TO AnyByteType;
        PtrAnyWordType = POINTER TO AnyWordType;
        PtrAnyLongType = POINTER TO AnyLongType;

        AnyType = RECORD
                    CASE : CARDINAL OF
                      0 : b  : BYTE|
                      1 : ch : CHAR|
                      2 : s  : BBS|
                      3 : w  : WORD|
                      5 : i  : INTEGER|
                      6 : c  : CARDINAL|
                      7 : l  : LONGWORD|
                      8 : ad : ADDRESS|
                      9 : p  : PtrAnyType|
                      10: pb : PtrBYTE|
                      11: ps : PtrBBS|
                      12: pab: PtrAnyByteType|
                      13: paw: PtrAnyWordType|
                      14: pal: PtrAnyLongType|
                      15: li : LONGINT|
                      16: lc : LONGCARD|
                      17: r  : LONGREAL
                    END
                  END;

        AnyLongType = RECORD
                        CASE : CARDINAL OF
                          0 :             (* *)  b3: BYTE; b2: BYTE; b1: BYTE;
                              b  : BYTE|
                          1 :             (* *)  ch3: CHAR; ch2: CHAR; ch1: CHAR;
                              ch : CHAR|
                          2 :             (* *)  s3: BBS; s2: BBS; s1: BBS;
                              s  : BBS|
                          3 :             (* *)  w1: WORD;
                              w  : WORD|
                          5 :             (* *)  i1: INTEGER;
                              i  : INTEGER|
                          6 :             (* *)  c1: CARDINAL;
                              c  : CARDINAL|
                          7 : l  : LONGWORD|
                          8 : ad : ADDRESS|
                          9 : p  : PtrAnyType|
                          10: pb : PtrBYTE|
                          11: ps : PtrBBS|
                          12: pab: PtrAnyByteType|
                          13: paw: PtrAnyWordType|
                          14: pal: PtrAnyLongType|
                          15: li : LONGINT|
                          16: lc : LONGCARD|
                        END
                     END;

        AnyWordType = RECORD
                        CASE : CARDINAL OF
                          0 :             (* *)  b1: BYTE;
                              b  : BYTE|
                          1 :             (* *)  ch1: CHAR;
                              ch : CHAR|
                          2 :             (* *)  s1: BBS;
                              s  : BBS|
                          3 : w  : WORD|
                          5 : i  : INTEGER|
                          6 : c  : CARDINAL
                        END
                     END;

        AnyByteType = RECORD
                        CASE : CARDINAL OF
                          0 : b  : BYTE|
                          1 : ch : CHAR|
                          2 : s  : BBS
                        END
                     END;

(* f. Modul SysCtrl: *)

        ScanDesc = RECORD
                     pc, link, stack: ADDRESS
                   END;

(* f. Modul Excepts: *)

CONST   (* Alle relevanten Exception-Vektornummern des ST *)
        BusError   = 2;
        AddrError  = 3;
        IllInstr   = 4;
        ZeroDivide = 5;     (* Used by Modula System, trapped by 'ErrBase' *)
        CHKExc     = 6;     (* Used by Modula System, trapped by 'ErrBase' *)
        TRAPVExc   = 7;     (* Used by Modula System, trapped by 'ErrBase' *)
        PrivViol   = 8;
        Trace      = 9;
        Emul1010   = 10;    (* Used by GEM *)
        Emul1111   = 11;    (* Used by GEM *)
        ProtViol   = 13;    (* Coprocessor exception *)
        FormatErr  = 14;
        UninitializedIR = 15;
        SpuriousIR = 24;
        IRLevel1 = 25;
        IRLevel2 = 26;      (* Used by TOS *)
        IRLevel3 = 27;
        IRLevel4 = 28;      (* Used by TOS *)
        IRLevel5 = 29;
        IRLevel6 = 30;      (* Used by TOS *)
        IRLevel7 = 31;
        TRAP0  = 32;
        TRAP1  = 33;        (* Used by TOS *)
        TRAP2  = 34;
        TRAP3  = 35;
        TRAP4  = 36;        (* Used by 'SysCtrl' to get into Supervisor mode *)
        TRAP5  = 37;        (* Used by Modula System, Module 'Debug' *)
        TRAP6  = 38;        (* Used by Modula System, trapped by 'ErrBase' *)
        TRAP7  = 39;
        TRAP8  = 40;
        TRAP9  = 41;
        TRAP10 = 42;
        TRAP11 = 43;
        TRAP12 = 44;
        TRAP13 = 45;        (* Used by TOS *)
        TRAP14 = 46;        (* Used by TOS *)
        TRAP15 = 47;

(* FPU exceptions *)
        BSUnExc      = 48;
        InexactRes   = 49;
        FPZeroDivide = 50;
        FPUnderflow  = 51;
        OpError      = 52;
        FPOverflow   = 53;
        NANExc       = 54;

(* 'Soft'-Interrupts, must be terminated by RTS instead of RTE *)
        EtvTimer = 256;     (* Used by TOS *)
        EtvCritic = 257;
        EtvTerm = 258;      (* Caught already by 'PrgCtrl.CatchProcessTerm' *)
        Etv103 = 259;       (* unused, reserved by Atari for future use *)
        Etv104 = 260;       (* unused, reserved by Atari for future use *)
        Etv105 = 261;       (* unused, reserved by Atari for future use *)
        Etv106 = 262;       (* unused, reserved by Atari for future use *)
        Etv107 = 263;       (* unused, reserved by Atari for future use *)

TYPE    Exceptions = [2..263];

        ExcSet = SET OF Exceptions;

        ExcDesc = RECORD (* enthÑlt alle wichtigen Daten einer Exception *)
                    regD0 : AnyLongType;
                    regD1 : AnyLongType;
                    regD2 : AnyLongType;
                    regD3 : AnyLongType;
                    regD4 : AnyLongType;
                    regD5 : AnyLongType;
                    regD6 : AnyLongType;
                    regD7 : AnyLongType;
                    regA0 : AnyLongType;
                    regA1 : AnyLongType;
                    regA2 : AnyLongType;
                    regA3 : AnyLongType;
                    regA4 : AnyLongType;
                    regA5 : AnyLongType;
                    regA6 : AnyLongType;
                    regSSP: ADDRESS;     (* SR/PC bereits abgerÑumt *)
                    regUSP: ADDRESS;
                    regPC : ADDRESS;
                    regSR : WORD;
                    CASE excNo: Exceptions OF
                      BusError, AddrError:   (* zusÑtzlich bei Bus/Adr-Error:*)
                       accessAddr : ADDRESS; (* Zugriffsadresse *)
                       superSR    : WORD;    (* Super-Status-Word *)
                       instruction: WORD     (* Fehler erzeugende Anweisung *)
                    END
                  END;

END SysTypes.
