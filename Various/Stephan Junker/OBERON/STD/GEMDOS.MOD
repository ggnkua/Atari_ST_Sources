MODULE GEMDOS;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |9.3.93   |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT SYSTEM;

CONST (* modi for Fopen *)
   read* = 0; write* = 1; readwrite* = 2;
   (* file attributes *)
   readonly* = 0; hidden* = 1; system* = 2; label* = 3; subdir* = 4; archiv* = 5;
   (* modi for Fseek *)
   absbeg* = 0; rel* = 1; absend* = 2;
   (* modi for Fattrib and Fdatime *)
   get* = 0; set* = 1;

TYPE
   dtarec*    = RECORD
                  SearchStr*   : ARRAY 12 OF CHAR;
                  Reserved     : ARRAY 8 OF CHAR;
                  Attribut*    : INTEGER;
                  Time*,Date*  : INTEGER;
                  Length*      : LONGINT;
                  Name*        : ARRAY 14 OF CHAR;
                END(*RECORD*);
   dta*       = POINTER TO dtarec;
   dfreedesc* = RECORD
                  FreeClus*    : INTEGER;
                  NumClus*     : INTEGER;
                  BytesPClus*  : INTEGER;
                  SecPClus*    : INTEGER;
                END(*RECORD*);
   dfree*     = POINTER TO dfreedesc;

PROCEDURE- Pterm0*() 0,1;

PROCEDURE- Cconin*() : LONGINT 1,1;

PROCEDURE- Cconout*(c : INTEGER) 2,1;

PROCEDURE- Cauxin*() : LONGINT 3,1;

PROCEDURE- Cauxout*(c : INTEGER) 4,1;

PROCEDURE- Cprnout*(c : INTEGER) 5,1;

PROCEDURE- Crawio*(c : INTEGER) : LONGINT 6,1;

PROCEDURE- Crawcin*() : LONGINT 7,1;

PROCEDURE- Cconws*(StrPtr : SYSTEM.PTR) 9,1;

PROCEDURE- Cconrs*(StrPtr : SYSTEM.PTR) 10,1;

PROCEDURE- Cconis*() : INTEGER 11,1;

PROCEDURE- Dsetdrv*(Drive : INTEGER) : SET 14,1;

PROCEDURE- Cconos*() : INTEGER 16,1;

PROCEDURE- Cprnos*() : INTEGER 17,1;

PROCEDURE- Cauxis*() : INTEGER 18,1;

PROCEDURE- Cauxos*() : INTEGER 20,1;

PROCEDURE- Dgetdrv*() : INTEGER 25,1;

PROCEDURE- Fsetdta*(Dta : dta) 26,1;

PROCEDURE- Super*(Stack : LONGINT) : LONGINT 32,1;

PROCEDURE- Tgetdate*() :INTEGER 42,1;

PROCEDURE- Tsetdate*(Date : INTEGER) 43,1;

PROCEDURE- Tgettime*() : INTEGER 44,1;

PROCEDURE- Tsettime*(Time : INTEGER) 45,1;

PROCEDURE- Fgetdta*() : dta 47,1;

PROCEDURE- Sversion*() : INTEGER 48,1;

PROCEDURE- Ptermres*(Return : INTEGER; NumBytes : LONGINT) 49,1;

PROCEDURE- Dfree*(Drive : INTEGER; Dfree : dfree) : INTEGER 54,1;

PROCEDURE- Dcreate*(Path : SYSTEM.PTR) : INTEGER 57,1;

PROCEDURE- Ddelete*(Path : SYSTEM.PTR) : INTEGER 58,1;

PROCEDURE- Dsetpath*(Path : SYSTEM.PTR) : INTEGER 59,1;

PROCEDURE- Fcreate*(Attribs : INTEGER; Name : SYSTEM.PTR) : INTEGER 60,1;

PROCEDURE- Fopen*(Mode : INTEGER; Name : SYSTEM.PTR) : INTEGER 61,1;

PROCEDURE- Fclose*(Handle : INTEGER) 62,1;

PROCEDURE- Fread*(Buffer : SYSTEM.PTR; Count : LONGINT; Handle : INTEGER) : LONGINT 63,1;

PROCEDURE- Fwrite*(Buffer : SYSTEM.PTR; Count : LONGINT; Handle : INTEGER) : LONGINT 64,1;

PROCEDURE- Fdelete*(Name : SYSTEM.PTR) : INTEGER 65,1;

PROCEDURE- Fseek*(Mode,Handle : INTEGER; NumBytes : LONGINT) : LONGINT 66,1;

PROCEDURE- Fattrib*(Attribs,Mode : INTEGER; Name : SYSTEM.PTR) : INTEGER 67,1;

PROCEDURE- Fdup*(StdHandle : INTEGER) : INTEGER 69,1;

PROCEDURE- Fforce*(NStdHandle,StdHandle : INTEGER) : INTEGER 70,1;

PROCEDURE- Dgetpath*(Drive : INTEGER; Path : SYSTEM.PTR) : INTEGER 71,1;

PROCEDURE- Malloc*(Bytes : LONGINT) : SYSTEM.PTR 72,1;

PROCEDURE- Mfree*(Adr : SYSTEM.PTR) : INTEGER 73,1;

PROCEDURE- Mshrink*(Size : LONGINT; Adr : SYSTEM.PTR; Rsv : INTEGER) : INTEGER 74,1;

PROCEDURE- Pexec*(Env,Command,Name : SYSTEM.PTR; Mode : INTEGER) : SYSTEM.PTR 75,1;

PROCEDURE- Pterm*(Return : INTEGER) 76,1;

PROCEDURE- Fsfirst*(Attribs : INTEGER; Name : SYSTEM.PTR) : INTEGER 78,1;

PROCEDURE- Fsnext*() : INTEGER 79,1;

PROCEDURE- Frename*(New,Old : SYSTEM.PTR; Rsv : INTEGER) : INTEGER 86,1;

PROCEDURE- Fdatime*(Mode,Handle : INTEGER; Buffer : SYSTEM.PTR) 87,1;

END GEMDOS.
