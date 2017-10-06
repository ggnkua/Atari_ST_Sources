DEFINITION MODULE ScsiIO;
(****************************************************************************
 *
 * Scsi-Input/Output auf midlevel-Ebene
 *
 *  (c) 1990-1992 Helge Schulz
 *  (c) 1990-1993 Steffen Engel
 *
 * $Source: E:\HM2\LIB\se\rcs\scsiio.d,v $
 *
 * $Revision: 1.9 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1996/02/03 19:32:00 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: scsiio.d,v $
 * Revision 1.9  1996/02/03  19:32:00  S_Engel
 * Kleine Anpassungen
 *
 * Revision 1.8  1995/10/30  17:45:14  S_Engel
 * *** empty log message ***
 *
 * Revision 1.7  1995/05/10  11:19:34  S_Engel
 * Export von Init
 *
 * Revision 1.6  1995/04/04  14:56:04  S_Engel
 * ScsiActive statt der Varianten internal/external/none
 *
 * Revision 1.5  1995/03/08  03:20:24  S_Engel
 * InquireDev und InquireSCSI korrekt mit langem Ergebnis.
 *
 * Revision 1.4  1995/02/10  14:01:04  S_Engel
 * In und Out als Prozedurvariablen, damit man sich davor
 * einklinken kann.
 *
 * Revision 1.3  1995/02/10  12:40:44  S_Engel
 * Anpassungen an aktuellen SCSI-Treiber
 *
 * Revision 1.2  1995/02/08  00:00:10  S_Engel
 * Umstellung auf handleorientierte SCSI-Routinen
 *
 * Revision 1.1  1995/01/01  19:14:04  S_Engel
 * Initial revision
 *
 *
 *
 ****************************************************************************)


(* Systemabh„ngiges *)
(* IMPLEMENTATION FšR  >>> H„nisch-Modula-2 <<< *)
(*                                              *)
(* Durchgefhrt von Steffen Engel               *)
(*                                              *)
(*$S-   Stack-Checks                            *)
(*$I-   keine Variablen-Initialisierung         *)
(*$V-   keine arithmetischen Kontrollen         *)
(*$T-   kein Bereichstest                       *)
(*$Y-   keine Laufzeittests auf RETURN und CASE *)
(*                                              *)
(*----------------------------------------------*)

(*$R2+ D2/A2 sichern        *)
(*$K+  Aufrufer r„umt Stack *)


IMPORT SYSTEM, System;

(* Standard HM2-Libs *)

(* Eigene Libs *)

(* Projektlibs *)
IMPORT ScsiDefs;



  (*------ Deklarationsteil *)

TYPE
  tSCSICmd  = ScsiDefs.tSCSICmd;
  tpSCSICmd = ScsiDefs.tpSCSICmd;
  tHandle   = ScsiDefs.tHandle;


CONST
    DefTimeout     =      2000; (* Standard Auszeit fr Kommandos (2 S)    *)
    DmaBlockLen    =       512; (* Blockl„nge des DMA-Bausteins            *)

    NOSCSIERROR     = ScsiDefs.NOSCSIERROR;   (* Kein Fehler                                  *)
    SELECTERROR     = ScsiDefs.SELECTERROR;   (* Fehler beim Selektieren                      *)
    STATUSERROR     = ScsiDefs.STATUSERROR;   (* Default-Fehler                               *)
    PHASEERROR      = ScsiDefs.PHASEERROR;    (* ungltige Phase                              *)
    BSYERROR        = ScsiDefs.BSYERROR;      (* BSY verloren                                 *)
    BUSERROR        = ScsiDefs.BUSERROR;      (* Busfehler bei DMA-šbertragung                *)
    TRANSERROR      = ScsiDefs.TRANSERROR;    (* Fehler beim DMA-Transfer (nichts bertragen) *)
    FREEERROR       = ScsiDefs.FREEERROR;     (* Bus wird nicht mehr freigegeben              *)
    TIMEOUTERROR    = ScsiDefs.TIMEOUTERROR;  (* Timeout                                      *)
    DATATOOLONG     = ScsiDefs.DATATOOLONG;   (* Daten fr ACSI-Softtransfer zu lang          *)
    LINKERROR       = ScsiDefs.LINKERROR;     (* Fehler beim Senden des Linked-Command (ACSI) *)
    TIMEOUTARBIT    = ScsiDefs.TIMEOUTARBIT;  (* Timeout bei der Arbitrierung                 *)
    PENDINGERR      = ScsiDefs.PENDINGERR;    (* auf diesem Handle liegt noch ein Fehler an   *)
    PARITYERROR     = ScsiDefs.PARITYERROR;   (* auf diesem Handle liegt noch ein Fehler an   *)

(*
    MaxCmdLen      =        50; (* H”chste m”gliche Kommandol„nge          *)
    MaxDmaAdr      =         7; (* H”chste m”gliche DMA-Adresse            *)
    MaxScsiAdr     =         7; (* H”chste m”gliche SCSI-Adresse           *)
    MaxRetrys      =         5; (* Max. Anzahl der Versuche nach Timeout   *)
(*    MaxDmaLen      =    130048; (* H”chste Anzahl von Bytes fr DMA-Modus  *)*)
    MaxDmaLen      =   64*1024; (* H”chste Anzahl von Bytes fr DMA-Modus  *)
    MaxScsiLenTT   =  512*1024; (* H”chste Anzahl von Bytes fr TT-SCSI    *)
    DefDiscTimeout =       400; (* Standard Auszeit fr Motorabs. (2 S)    *)
    DiscWaitTime   =         1; (* Wartezeit fr Floppy-Chip  (1/200 S)    *)
    MsgWaitTime    =        10; (* Wartezeit fr Message-BYTE (1/200 S)    *)
*)

CONST ACSIBus = 0;
      SCSIBus = 1;
      ALIABus = 2;



VAR
    ScsiErrorCode  : SHORTINT;
      (*
       * ScsiErrorCode gibt die Fehlerursache an, falls eine der
       * nachfolgenden Funktionen FALSE zurckgibt.
       * Werte gr”žer 0 : Statusbyte
       * Kleiner 0      : Fehlernummer
       *) 

    ReqBuff         : ARRAY[0..17] OF SYSTEM.LOC;


VAR ScsiActive  : BOOLEAN;
    ScsiCall    : ScsiDefs.tpScsiCall;


(* Als Variablen, um sich davor einzuklinken *)
VAR In  : PROCEDURE (ScsiDefs.tpSCSICmd) : LONGINT;
    Out : PROCEDURE (ScsiDefs.tpSCSICmd) : LONGINT;


PROCEDURE MyIn(Parms : ScsiDefs.tpSCSICmd): LONGINT;

PROCEDURE MyOut(Parms : ScsiDefs.tpSCSICmd): LONGINT;


PROCEDURE InquireSCSI(    what : SHORTINT;
                      VAR Info : ScsiDefs.tBusInfo) : LONGINT;

PROCEDURE InquireBus (    what     : SHORTINT;
                          BusNo    : SHORTINT;
                      VAR Dev      : ScsiDefs.tDevInfo) : LONGINT;


PROCEDURE CheckDev(     BusNo     : SHORTINT;
                    VAR (*$RO*) DevNo     : ScsiDefs.DLONG;
                    VAR Name      : STRING;
                    VAR Features  : BITSET): LONGINT;

PROCEDURE RescanBus(BusNo : SHORTINT) : LONGINT;

PROCEDURE Open (    Bus     : SHORTINT;
                VAR (*$RO*) Id      : ScsiDefs.DLONG;
                VAR MaxLen  : LONGCARD) : LONGINT;

PROCEDURE Close(handle : ScsiDefs.tHandle) : LONGINT;

PROCEDURE Error(handle  : ScsiDefs.tHandle;
                rwflag,
                error   : SHORTINT) : LONGINT;


PROCEDURE Init;
(* Initialisiert die SCSI-Routinen.
 * wir vom Modulrumpf automatisch initialisiert, kann aber nachtr„glich erneut
 * gerufen werden, falls ein Treiber nachgeladen wurde.
 *)

END ScsiIO.

