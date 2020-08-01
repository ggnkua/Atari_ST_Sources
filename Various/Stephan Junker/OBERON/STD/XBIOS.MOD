MODULE XBIOS;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |11.3.93  |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT SYSTEM;

CONST (* mouse modi *)
  off* = 0; rel* = 1; abs* = 2; key* = 4;
  (* resolutions *)
  low* = 0; mid* = 1; high* = 2;
  (* floppies *)
  flopa* = 0; flopb* = 1;
  (* devices *)
  aux* = 0; ikbd* = 1; midi* = 2;
  (* disk types *)
  sssd* = 0; dssd* = 1; ssdd* = 2; dsdd* = 3;
  (* exec flag *)
  noexec* = 0; exec* = 1;
  (* cursor function *)
  curoff* = 0; curon* = 1; blink* = 2; noblink* = 3; setrate* = 4; getrate* = 5;
  (* timers *)
  timera* = 0; timerb* = 1; timerc* = 2; timerd* = 3;
  (* bits for printer configuration *)
  typewheel* = 0; color* = 1; epson* = 2; nlq* = 3; serial* = 4; singlesheet* = 5;

TYPE
   PROC         = PROCEDURE;
   mparam*      = RECORD
                    Ystart* : INTEGER; (* 0 = unten, 1 = oben Y = 0 *)
                    ToIKBD* : INTEGER; (* Fachliteratur *)
                    ScaleX* : INTEGER;
                    ScaleY* : INTEGER;
                    MaxX*   : INTEGER; (* Diese vier Werte nur falls Absolut *)
                    MaxY*   : INTEGER;
                    AbsX*   : INTEGER;
                    AbsY*   : INTEGER;
                  END(*RECORD*);
   mpar*        = POINTER TO mparam;
   palettedesc* = ARRAY 16 OF INTEGER;
   palette*     = POINTER TO palettedesc;
   siobufdesc*  = RECORD
                    Buffer* : SYSTEM.PTR;
                    Size*   : INTEGER;
                    Tail*   : INTEGER;
                    Head*   : INTEGER;
                    Low*    : INTEGER;
                    High*   : INTEGER;
                  END(*RECORD*);
   siobuf*      = POINTER TO siobufdesc;
   keytabdesc*  = RECORD
                   Unshift*,Shift*,Capslock* : POINTER TO ARRAY 128 OF CHAR;
                 END(*RECORD*);
   keytab*      = POINTER TO keytabdesc;
   sysvecs*     = RECORD
                    Midivec* : PROC;
                    Kbderr*  : PROC;
                    Midierr* : PROC;
                    Statvec* : PROC;
                    Mousevec*: PROC;
                    Clockvec*: PROC;
                    Joyvec*  : PROC;
                    Midisys* : PROC;
                    Ikbdsys* : PROC;
                  END(*RECORD*);
   sysvec*      = POINTER TO sysvecs;
   prtdesc*     = RECORD
                    Screen*  : SYSTEM.PTR;
                    Offset*  : INTEGER;
                    Width*   : INTEGER;
                    Height*  : INTEGER;
                    LeftMar* : INTEGER;
                    RightMar*: INTEGER;
                    ScrRes*  : INTEGER;
                    PrtRes*  : INTEGER;
                    Palette* : palette;
                    PrtType* : INTEGER;
                    PrtPort* : INTEGER;
                    Mask*    : LONGINT;
                  END(*RECORD*);
   prtpar*      = POINTER TO prtdesc;

PROCEDURE- Initmouse*(Vector : PROC; Param : mpar; Mode : INTEGER) 0,14;

PROCEDURE- Physbase*() : SYSTEM.PTR 2,14;

PROCEDURE- Logbase*() : SYSTEM.PTR 3,14;

PROCEDURE- Getrez*() : INTEGER 4,14;

PROCEDURE- Setscreen*(Resol : INTEGER; Physbase,Logbase : SYSTEM.PTR) 5,14;

PROCEDURE- Setpalette*(Palette : palette) 6,14;

PROCEDURE- Setcolor*(Color,Register : INTEGER) : INTEGER 7,14;

PROCEDURE- Floprd*(Count,Side,Track,Sector,Floppy : INTEGER;
                   Filler : LONGINT; Buffer : SYSTEM.PTR) : INTEGER 8,14;

PROCEDURE- Flopwr*(Count,Side,Track,Sector,Floppy : INTEGER;
                   Filler : LONGINT; Buffer : SYSTEM.PTR) : INTEGER 9,14;

PROCEDURE- Flopfmt*(Virgin : INTEGER; Magic : LONGINT; Interleave,Side,Track,Secno,
                    Floppy : INTEGER; Filler : LONGINT;
                    Buffer : SYSTEM.PTR) : INTEGER 10,14;

PROCEDURE- Midiws*(DataPtr : SYSTEM.PTR; Count : INTEGER) 12,14;

PROCEDURE- Mfpint*(Vector : PROC; Vecnum : INTEGER) 13,14;

PROCEDURE- Iorec*(Device : INTEGER) : siobuf 14,14;

PROCEDURE- Rsconf*(Scr,Tsr,Rsr,Ucr,Flowctl,Speed : INTEGER) 15,14;

PROCEDURE- Keytbl*(Capslock,Shift,Unshift : SYSTEM.PTR) : keytab 16,14;

PROCEDURE- Random*() : LONGINT 17,14;

PROCEDURE- Protobt*(ExecFlag,Disktype : INTEGER; SerialNo : LONGINT;
                    Buffer : SYSTEM.PTR) 18,14;

PROCEDURE- Flopver*(Count,Side,Track,Sector,Floppy : INTEGER;
                    Filler : LONGINT; Buffer : SYSTEM.PTR) : INTEGER 19,14;

PROCEDURE- Scrdump*() 20,14;

PROCEDURE- Cursconf*(Operand,Function : INTEGER) : INTEGER 21,14;

PROCEDURE- Settime*(DateTime : LONGINT) 22,14;

PROCEDURE- Gettime*() : LONGINT 23,14;

PROCEDURE- Bioskeys*() 24,14;

PROCEDURE- Ikbdws*(DataPtr : SYSTEM.PTR; Count : INTEGER) 24,14;

PROCEDURE- Jdisint*(Intno : INTEGER) 26,14;

PROCEDURE- Jenabint*(Intno : INTEGER) 27,14;

PROCEDURE- Giaccess*(Regno,Data : INTEGER) : INTEGER 28,14;

PROCEDURE- Offgibit*(Data : INTEGER) 29,14;

PROCEDURE- Ongibit*(Data : INTEGER) 30,14;

PROCEDURE- Xbtimer*(Vector : PROC; Data,Control,Timer : INTEGER) 31,14;

PROCEDURE- Dosound*(DataPtr : SYSTEM.PTR) 32,14;

PROCEDURE- Setprt*(Config : INTEGER) : INTEGER 33,14;

PROCEDURE- Kbdvbase*() : sysvec 34,14;

PROCEDURE- Kbrate*(Repeat,Initial : INTEGER) : INTEGER 35,14;

PROCEDURE- Prtblk*(Parameter : prtpar) 36,14;

PROCEDURE- Vsync*() 37,14;

PROCEDURE- Supexec*(Code : PROC) 38,14;

END XBIOS.
