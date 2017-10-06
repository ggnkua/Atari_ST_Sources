IMPLEMENTATION MODULE ScsiIO;
(****************************************************************************
 *
 * Scsi-Input/Output auf midlevel-Ebene
 *
 * (c) 1990-1992 Helge Schulz
 * (c) 1990-1993 Steffen Engel
 *
 * $Source: E:\HM2\LIB\se\rcs\scsiio.m,v $
 *
 * $Revision: 1.10 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1996/02/03 19:34:10 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: scsiio.m,v $
 * Revision 1.10  1996/02/03  19:34:10  S_Engel
 * Kleine Anpassungen
 *
 * Revision 1.9  1995/10/30  17:44:48  S_Engel
 * *** empty log message ***
 *
 * Revision 1.8  1995/05/11  15:24:38  S_Engel
 * virtuelles RAM: Daten werden kopiert.
 *
 * Revision 1.7  1995/04/04  15:10:14  S_Engel
 * GrundsÑtzlich Verwendung externer SCSI-Routinen
 *
 * Revision 1.6  1995/03/08  03:19:44  S_Engel
 * InquireDev und InquireSCSI korrekt mit langem Ergebnis
 *
 * Revision 1.5  1995/02/25  23:23:34  S_Engel
 * BugFix: InquireSCSI verwendete Adresse der Pufferadreûvariablen.
 *
 * Revision 1.4  1995/02/10  14:02:02  S_Engel
 * In und Out als Prozedurvariablen, damit man sich davor
 * einklinken kann.
 *
 * Revision 1.3  1995/02/10  12:38:46  S_Engel
 * Anpassungen an aktuellen SCSI-Treiber
 *
 * Revision 1.2  1995/02/07  23:59:48  S_Engel
 * Umstellung auf handleorientierte SCSI-Routinen
 *
 * Revision 1.1  1995/01/01  19:14:54  S_Engel
 * Initial revision
 *
 *
 *  30.09.93 KompatibilitÑt mit virtuellem RAM fertiggestellt
 *  08.09.93 EndgÅltige Umstellung auf den Betrieb mit FRB. ScsiIO geht autark mit dem FRB um, und sollte auch mit virtuellem RAM klarkommen.
 *  10.01.93 Falcon-Routinen eingebaut (SE)
 *  15.10.92 BHDI fÅr den Gebrauch mit Alien eingebaut (SE)
 *  08.10.92 Fehlermeldung OnlyTT eingebaut (Cookie-Check) (SE)
 *  05.10.92 Cache-Clear installiert, TT anscheinend jetzt stabil
 *  29.04.92 TT-UnterstÅtzung installiert (SE)
 *  13.04.92 SetScsiAdr setzt LastCmd auf 0
 *  30.12.91 MaxScsiAdr auf 7 erhîht fÅr modifizierte Adapter
 *  21.07.91 Auszeitprozedurvariablen
 *  19.07.91 Anpassung an Compiler-Version 4.1
 *  30.11.90 Aufteilung von StopDiscMotor in Break- und StopDisc
 *  28.11.90 Konstante DevDiscTimeout und DiscWaitTime
 *  02.10.90 Prozedur StopDiscMotor
 *
 *****************************************************************************)


 (*$S- $V- $T- *)

(* SystemabhÑngiges *)
(* IMPLEMENTATION FöR  >>> HÑnisch-Modula-2 <<< *)
(*                                              *)
(* DurchgefÅhrt von Steffen Engel               *)
(*                                              *)
(*$S-   Stack-Checks                            *)
(*$I-   keine Variablen-Initialisierung         *)
(*$V-   keine arithmetischen Kontrollen         *)
(*$T-   kein Bereichstest                       *)
(*$Y-   keine Laufzeittests auf RETURN und CASE *)
(*                                              *)
(*----------------------------------------------*)

(*$R2+ D2/A2 sichern        *)
(*$K+  Aufrufer rÑumt Stack *)



IMPORT SYSTEM, System;

(* Standard HM2-Libs *)
FROM SYSTEM IMPORT ADR, BYTE, ADDRESS, WORD, CAST, TSIZE, LOAD, STORE, CODE;
IMPORT Cookie, Block, void;
IMPORT Str;

(* Magic-Lib *)
IMPORT MagicDOS;

(* Eigene Libs *)
IMPORT Err;

(* Projektlibs *)
IMPORT ScsiDefs;


  (* String fÅr WHAT - leider ein biûchen HM2-spezifisches *)
  CONST What = '@(#) ScsiIO, compiled '
               + CHR(SYSTEM.DATE DIV 1000000H DIV 10 + 48)
               + CHR(SYSTEM.DATE DIV 1000000H MOD 10 + 48) + '.'
               + CHR(SYSTEM.DATE DIV 10000H MOD 100H DIV 10 MOD 10 + 48)
               + CHR(SYSTEM.DATE DIV 10000H MOD 100H MOD 10 + 48) + '.'
               + CHR(SYSTEM.DATE MOD 10000H DIV 10 MOD 10 + 48)
               + CHR(SYSTEM.DATE MOD 10000H MOD 10 + 48)
               + '  (c) S. Engel';

CONST ForeignXFRB = FALSE;      (* Soll ein globaler FRB benutzt werden, falls vorhanden? *)

   (*------ Deklarationsteil *)


(* Alles fÅr den XFRB *)

TYPE  tXFRB = RECORD
                version : SHORTINT;            (* Version des XFRB-cookies, $0101 = 1.00 *)
                xflock  : POINTER TO SHORTINT;  (* extended flock, Semaphore *)
                buffer  : ADDRESS;             (* Adresse eines Puffers im ST-RAM, mindestens 64 KByte *)
                size    : LONGINT;             (* Puffergrîûe *)
                next    : POINTER TO tXFRB;    (* Zeiger auf weitere Struktur *)
              END;
VAR   XFRB            : POINTER TO tXFRB;
      HasVirtualRAM   : BOOLEAN;



PROCEDURE MyIn(Parms : ScsiDefs.tpSCSICmd): LONGINT;
VAR dest        : SYSTEM.ADDRESS;
    len         : LONGCARD;
    phystop[042EH] : LONGCARD;

  BEGIN
    IF ScsiActive
      THEN
        IF HasVirtualRAM
          THEN
            dest := Parms^.Buffer;
            len := Parms^.TransferLen;
            IF dest > phystop
              THEN
                Parms^.Buffer := XFRB^.buffer;
              END;
          END;

        ScsiErrorCode := ScsiCall^.In(Parms);

        IF HasVirtualRAM
          THEN
            IF dest > phystop
              THEN
                Block.Move(XFRB^.buffer, dest, len);
              END;
          END;
      ELSE
        ScsiErrorCode := MIN(SHORTINT);
      END;
    RETURN ScsiErrorCode;

  END MyIn;

PROCEDURE MyOut(Parms : ScsiDefs.tpSCSICmd): LONGINT;
VAR phystop[042EH] : LONGCARD;

  BEGIN
    IF ScsiActive
      THEN
        IF HasVirtualRAM AND (Parms^.Buffer > phystop)
          THEN
            Block.Move(Parms^.Buffer, XFRB^.buffer, Parms^.TransferLen);
            Parms^.Buffer := XFRB^.buffer;
          END;
        ScsiErrorCode := ScsiCall^.Out(Parms);
      ELSE
        ScsiErrorCode := MIN(SHORTINT);
      END;
    RETURN ScsiErrorCode;
  END MyOut;

PROCEDURE InquireSCSI(    what : SHORTINT;
                      VAR Info : ScsiDefs.tBusInfo) : LONGINT;

  BEGIN
    IF ScsiActive
      THEN
        RETURN ScsiCall^.InquireSCSI(what, Info);
      ELSE
        RETURN MIN(LONGINT);
      END;

  END InquireSCSI;

PROCEDURE InquireBus (    what     : SHORTINT;
                          BusNo    : SHORTINT;
                      VAR Dev      : ScsiDefs.tDevInfo) : LONGINT;

  BEGIN
    IF ScsiActive
      THEN
        RETURN ScsiCall^.InquireBus(what, BusNo, Dev);
      ELSE
        RETURN MIN(SHORTINT);
      END;

  END InquireBus;

PROCEDURE CheckDev(     BusNo : SHORTINT;
                    VAR (*$RO*) DevNo : ScsiDefs.DLONG;
                    VAR Name : STRING;
                    VAR Features : BITSET): LONGINT;

  BEGIN
    IF ScsiActive
      THEN
        RETURN ScsiCall^.CheckDev(BusNo, DevNo, Name, Features);
      ELSE
        RETURN MIN(SHORTINT);
      END;
  END CheckDev;

PROCEDURE RescanBus(BusNo : SHORTINT) : LONGINT;

  BEGIN
    IF ScsiActive
      THEN
        RETURN ScsiCall^.RescanBus(BusNo);
      ELSE
        RETURN MIN(SHORTINT);
      END;
  END RescanBus;

PROCEDURE Open(     Bus : SHORTINT;
                VAR (*$RO*) Id : ScsiDefs.DLONG;
                VAR MaxLen : LONGCARD) : LONGINT;
VAR count : SHORTCARD;

  BEGIN
    IF ScsiActive
      THEN
        RETURN ScsiCall^.Open(Bus, Id, MaxLen);
      ELSE
        RETURN MIN(LONGINT);
      END;

  END Open;

PROCEDURE Close(handle : ScsiDefs.tHandle) : LONGINT;
VAR ret : LONGINT;
  BEGIN
    IF ScsiActive
      THEN
        RETURN ScsiCall^.Close(handle);
      ELSE
        RETURN MIN(LONGINT);
      END;

  END Close;

PROCEDURE Error(handle : ScsiDefs.tHandle; rwflag, error : SHORTINT) : LONGINT;
VAR ret : LONGINT;

  BEGIN
    IF ScsiActive
      THEN
        RETURN ScsiCall^.Error(handle, rwflag, error);
      ELSE
        RETURN MIN(LONGINT);
      END;

  END Error;

PROCEDURE CheckVirtual;
VAR CkVal : LONGINT;

  BEGIN
    HasVirtualRAM := Cookie.Get(LONGCARD('PMMU'), CkVal)
                      AND (CkVal # 0);

    IF HasVirtualRAM AND (XFRB = NIL)
      THEN
        (* Dann mÅssen wir wohl einen anlegen *)
        XFRB := MagicDOS.Mxalloc(64*1024+SIZE(XFRB^)+2, MagicDOS.STRAM);
        IF XFRB = NIL
          THEN
            HALT;   (* Tja, Keine Chance! *)
          ELSE
            WITH XFRB^ DO
              version := 0101H;
              size := 64*1024;
              xflock := XFRB + ADDRESS(SIZE(XFRB^));  (* hinter dem Cookie im ST-RAM *)
              xflock^ := 0;
              buffer := XFRB + ADDRESS(SIZE(XFRB^) + 2);
            END;
          END;
      END;

  END CheckVirtual;

PROCEDURE Init;

  VAR CkVal : LONGINT;
      count : SHORTINT;

  BEGIN

    ScsiActive  := FALSE;

    (* haben wir einen SCSI-Treiber mit brauchbarer Version im System? *)
    IF ~Cookie.Get(LONGCARD('SCSI'), ScsiCall)
       OR (ScsiCall = NIL)
  (* vorerst genau prÅfen *)
    (*$?ScsiDefs.ScsiCallVersion # 00100H: anpassen! *)
        OR (ScsiCall^.Version DIV 0100H # ScsiDefs.ScsiCallVersion DIV 0100H)
      THEN
        ScsiCall := NIL; (* Sicherheitshalber *)
      ELSE
        ScsiActive := TRUE;
      END;

(*$?ForeignXFRB:
    IF XFRB = NIL
      THEN
        (* Versuchen wir's *)
        VOID(Cookie.Get(LONGCARD('XFRB'), XFRB));
      END;
 *)

  CheckVirtual;

  
  END Init;

BEGIN
  In := MyIn;
  Out := MyOut;

  XFRB := NIL;
  Init;
END ScsiIO.
