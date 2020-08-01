MODULE BIOS;

(* BIOS-Funktionen     Stephan Junker   11.7.92 *)

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |9.3.93   |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT SYSTEM;

CONST (* devices *)
   prt* = 0; aux* = 1; con* = 2; midi* = 3; kbd* = 4; scr* = 5;
   (* flags for Rwabs *)
   read* = 0; write* = 0; readnomc* = 2; writenomc* = 3;
   (* media change status *)
   nomc* = 0; maybemc* = 1; mc* = 2;
   (* shift bits *)
   rshift* = 0; lshift* = 1; control* = 2; altern* = 3; caps* = 4; rmbut* = 5;
   lmbut* = 6;

TYPE
   md*     = POINTER TO mdesc;
   mdesc*  = RECORD
               Next*   : md;
               Begad*  : SYSTEM.PTR;
               Length* : LONGINT;
               Owner*  : SYSTEM.PTR;
             END(*RECORD*);
   mpblock*= RECORD
               FreeList*  : md;
               AllocList* : md;
               Roving*    : SYSTEM.PTR;
             END(*RECORD*);
   mpb*    = POINTER TO mpblock;
   bpblock*= RECORD
               BytesPSec*  : INTEGER;
               SecPClus*   : INTEGER;
               BytesPClus* : INTEGER;
               SecPDir*    : INTEGER;
               SecPFAT*    : INTEGER;
               SecnumFAT*  : INTEGER;
               SecnumData* : INTEGER;
               NumClus*    : INTEGER;
               Flags*      : INTEGER;
             END(*RECORD*);
   bpb*    = POINTER TO bpblock;

PROCEDURE- Getmpb*(MpbPtr : mpb) 0,13;

PROCEDURE- Bconstat*(Device : INTEGER) : INTEGER 1,13;

PROCEDURE- Bconin*(Device : INTEGER) : LONGINT 2,13;

PROCEDURE- Bconout*(Char,Device : INTEGER) 3,13;

PROCEDURE- Rwabs*(Drive,Recno,Count : INTEGER; Buffer : SYSTEM.PTR;
                  RwFlag : INTEGER) : INTEGER 4,13;

PROCEDURE- Setexc*(Vector : SYSTEM.PTR; Vecnum : INTEGER) : SYSTEM.PTR 5,13;

PROCEDURE- Tickcal*() : LONGINT 6,13;

PROCEDURE- Getbpb*(Drive : INTEGER) : bpb 7,13;

PROCEDURE- Bcostat*(Device : INTEGER) : INTEGER 8,13;

PROCEDURE- Mediach*(Drive : INTEGER) : INTEGER 9,13;

PROCEDURE- Drvmap*() : SET 10,13;

PROCEDURE- Kbshift*(Shiftbits : INTEGER) : INTEGER 11,13;

END BIOS.
