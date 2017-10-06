DEFINITION MODULE ScsiDefs;
(****************************************************************************
 *
 * Definitionen fÅr den SCSI-Treiber
 *
 *  (c) 1995 Steffen Engel
 *
 * $Source: E:\HM2\LIB\se\rcs\scsidefs.d,v $
 *
 * $Revision: 1.2 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1996/02/03 19:31:28 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: scsidefs.d,v $
 * Revision 1.2  1996/02/03  19:31:28  S_Engel
 * Kleine Anpassungen
 *
 * Revision 1.1  1995/11/13  17:37:00  S_Engel
 * Initial revision
 *
 *
 *
 *
 ****************************************************************************)


(*$R2+ D2/A2 sichern        *)
(*$K+  Aufrufer rÑumt Stack *)
(* Damit sind die Parameter wie PureC cdecl *)

FROM SYSTEM IMPORT ADDRESS;


TYPE
  WORD            = SHORTINT;         (* 16 Bit signed    *)
  UWORD           = SHORTCARD;        (* 16 Bit unsigned  *)
  LONG            = LONGINT;          (* 32 Bit signed    *)
  ULONG           = LONGCARD;         (* 32 Bit unsigned  *)
  BYTE            = [-128..127];      (* 8 Bit signed     *)
  UBYTE           = [0..255];         (* 8 Bit unsigned   *)
  DLONG           = RECORD            (* 64 Bit unsigned  *)
                      hi, lo : LONGCARD;
                    END;

(*
 * Standardtypen und öbergabekonventionen bei Modula-2:
 *
 * BITSET : 16 Bit Bitvektor
 * ADDRESS : Zeiger void *
 *
 * ParameterÅbergabe VAR entspricht ZeigerÅbergabe:
 *  PROCEDURE call(VAR val : SHORTCARD);
 *  void cdecl call(UWORD *val);
 *
 * öbergabe VAR (*$RO*) entspricht const *
 *  PROCEDURE call(VAR (*$RO*)val : SHORTCARD);
 *  void cdecl call(const UWORD *val);
 *
 * VAR STRING ist char *
 *  PROCEDURE call(VAR str : STRING);
 *  void cdecl call(char *str);
 *
 * ParameterÅbergabe entspricht cdecl:
 *  PROCEDURE call(par1, par2, par3 : SHORTCARD);
 *  void cdecl call(UWORD par1, UWORD par2, UWORD par3);
 *
 * Prozedurergebnis immer in D0
 *
 *)

CONST

  ScsiCallVersion = 00100H;   (* Version = 1.00 *)


  (*--- Werte fÅr Fehlerart (ScsiErrorCode) *)
  NOSCSIERROR     =   0; (* Kein Fehler                                   *)
  SELECTERROR     =  -1; (* Fehler beim Selektieren                       *)
  STATUSERROR     =  -2; (* Default-Fehler                                *)
  PHASEERROR      =  -3; (* ungÅltige Phase                               *)
  BSYERROR        =  -4; (* BSY verloren                                  *)
  BUSERROR        =  -5; (* Busfehler bei DMA-öbertragung                 *)
  TRANSERROR      =  -6; (* Fehler beim DMA-Transfer (nichts Åbertragen)  *)
  FREEERROR       =  -7; (* Bus wird nicht mehr freigegeben               *)
  TIMEOUTERROR    =  -8; (* Timeout                                       *)
  DATATOOLONG     =  -9; (* Daten fÅr ACSI-Softtransfer zu lang           *)
  LINKERROR       = -10; (* Fehler beim Senden des Linked-Command (ACSI)  *)
  TIMEOUTARBIT    = -11; (* Timeout bei der Arbitrierung                  *)
  PENDINGERR      = -12; (* auf diesem Handle liegt noch ein Fehler an    *)
  PARITYERROR     = -13; (* Es trat ein Parity-Fehler auf                 *)

TYPE
  tHandle = POINTER TO BITSET;      (* Zeiger auf BusFeatures,
                                     * Rest ist Treibersache
                                     *)

  tpSCSICmd       = POINTER TO tSCSICmd;
  tSCSICmd        = RECORD
                      handle      : tHandle;    (* das handle des GerÑtes *)
                      Cmd         : ADDRESS;    (* Zeiger auf CmdBlock    *)
                      CmdLen      : SHORTCARD;  (* LÑnge des Cmd-Block    *)
                      Buffer      : ADDRESS;    (* Datenpuffer            *)
                      TransferLen : LONGCARD;   (* öbertragungslÑnge      *)
                      SenseBuffer : ADDRESS;    (* Puffer (min 18 Bytes)  *)
                      Timeout     : LONGCARD;   (* Timeout in 1/200 sec   *)
                      Flags       : BITSET;     (* fÅr AblaufwÅnsche      *)
                    END;

CONST
  (* fÅr Flags *)
  Disconnect = 4;  (* Bit 4: Transfer mit Disconnect durchfÅhren *)

TYPE
  tpBusInfo = POINTER TO tBusInfo;
  tBusInfo        = RECORD
                      Private : ARRAY[0..31] OF BYTE;
                      (* fÅr den Treiber
                       *)
                      BusName : ARRAY[0..19] OF CHAR;
                      (* zB 'SCSI', 'ACSI', 'PAK-SCSI' *)
                      BusNo   : SHORTCARD;
                        (* Die Identifikationsnummer des Busses
                         * Dient zur öbergabe des gewÅnschten Busses an
                         * In und Out
                         *)
                      Features: BITSET;
                        (* bis zu 16 Features, die der Bus kann, zB Arbit,
                         * Full-SCSI (alle SCSI-Cmds im Gegensatz zu ACSI)
                         * Target oder Initiator gesteuert
                         * kann alle Adressen bedienen (Stichwort: ACSI-Port
                         * im TT!)
                         * Diese Information ist auch im SCSI-Handle tHandle
                         * wiederzufinden.
                         *)
                      MaxLen  : LONGCARD;
                        (* maximale TransferlÑnge auf diesem Bus (in Bytes)
                         * entspricht zB bei ACSI der Grîûe des FRB
                         *)
                    END;

CONST
  (* Bus-Features (jeweils die BitNummer!) *)
  cArbit          = 0;  (* auf dem Bus wird arbitriert                        *)
  cAllCmds        = 1;  (* alle Kommandos kînnen grundsÑtzlich benutzt werden *)
  cTargCtrl       = 2;  (* Das Target steuert den Ablauf (so soll's sein!)    *)
  cTarget         = 3;  (* auf diesem Bus kann ein Target installiert werden  *)
  cCanDisconnect  = 4;  (* auf dem Bus ist Disconnect mîglich                 *)
  cScatterGather  = 5;  (* Scatter gather bei virtuellem RAM                  *)

TYPE
  tReqData        = RECORD
                      ErrCode     : BYTE;
                      SegNo       : BYTE;
                      SenseKey    : BYTE;
                      InfoByte1   : BYTE;     (* auf ODD ADDRESS!!! *)
                      InfoByte2   : BYTE;
                      InfoByte3   : BYTE;
                      InfoByte4   : BYTE;
                      AddLen      : BYTE;
                      CmdSpec     : LONGCARD; (* Cmd-Specific *)
                      AddSense    : BYTE;
                      AddSenseQual: BYTE;
                      FieldRepl   : BYTE;
                      SKeySpec0   : BYTE;
                      SKeySpec1   : BYTE;
                      SKeySpec2   : BYTE;
                    END;

  tpCmd           = POINTER TO ARRAY[0..11] OF BYTE;

  tpTargetHandler = POINTER TO tTargetHandler;
  tTargetHandler  = RECORD
                      next        : tpTargetHandler;
                      TSel        : PROCEDURE((* bus *) SHORTCARD,
                                              (* CSB *) SHORTCARD,
                                              (* CSD *) SHORTCARD) : BOOLEAN;
                      TCmd        : PROCEDURE((* bus *) SHORTCARD,
                                              (* Cmd *) tpCmd) : BOOLEAN;
                      TCmdLen     : PROCEDURE((* bus *) SHORTCARD,
                                              (* Cmd *) SHORTCARD) : SHORTCARD;
                      TReset      : PROCEDURE((* bus *) SHORTCARD);
                      TEOP        : PROCEDURE((* bus *) SHORTCARD);
                      TPErr       : PROCEDURE((* bus *) SHORTCARD);
                      TPMism      : PROCEDURE((* bus *) SHORTCARD);
                      TBLoss      : PROCEDURE((* bus *) SHORTCARD);
                      TUnknownInt : PROCEDURE((* bus *) SHORTCARD);
                    END;

(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- Funktionen zum SCSI-Zugriff                                           -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
  tInProc         = PROCEDURE ((* Parms *) tpSCSICmd): LONGINT;
  tOutProc        = PROCEDURE ((* Parms *) tpSCSICmd): LONGINT;

(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- Funktionen zur Bus/GerÑtesuche                                        -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
  tInquireSCSIProc= PROCEDURE (   (* what     *) SHORTINT,
                               VAR(* Info     *) tBusInfo) : LONGINT;

CONST
  cInqFirst       = 0;
  cInqNext        = 1;

TYPE
  tDevInfo        = RECORD
                      Private : ARRAY[0..31] OF BYTE;
                        (* fÅr den Treiber *)
                      Id      : DLONG;
                        (* Ansprechbare Id (muû kein GerÑt anwesend sein!) *)
                    END;

  (* Funktionen zur Bus/GerÑtesuche *)
  tInquireBusProc = PROCEDURE (   (* what     *) SHORTINT,  (* cInqFirst/Next *)
                                  (* BusNo    *) SHORTINT,  (* aus tBusInfo   *)
                               VAR(* Dev      *) tDevInfo) : LONGINT;


  tCheckDevProc   = PROCEDURE (   (* BusNo    *) SHORTINT,
                               VAR(*$RO*) (* DevNo    *) DLONG,
                               VAR(* Name     *) STRING,
                               VAR(* Features *) BITSET): LONGINT;

  tRescanBusProc  = PROCEDURE (   (* BusNo    *) SHORTINT) : LONGINT;


(* Funktionen zur Verwaltung von Handles *)
  tOpenProc       = PROCEDURE (   (* bus      *) SHORTINT,
                               VAR(*$RO*) (* Id       *) DLONG,
                               VAR(* MaxLen   *) LONGCARD) : LONGINT;
  tCloseProc      = PROCEDURE (   (* handle   *) tHandle) : LONGINT;
  tErrorProc      = PROCEDURE (   (* handle   *) tHandle,
                                  (* rwflag   *) SHORTINT,
                                  (* Error    *) SHORTINT) : LONGINT;
CONST
  cErrRead        = 0;
  cErrWrite       = 1;
    cErrMediach     = 0;
    cErrReset       = 1;  (* kann auch Mediach gemeldet werden *)

TYPE
  (* Routinen als Target *)
  tInstallProc    = PROCEDURE ((* bus     *) SHORTCARD,
                               (* Handler *) tpTargetHandler);
  tDeinstallProc  = PROCEDURE ((* Handler *) tpTargetHandler);
  tGetCmdProc     = PROCEDURE ((* bus     *) SHORTCARD,
                               (* Cmd     *) tpCmd) : BOOLEAN;
  tSendDataProc   = PROCEDURE ((* bus     *) SHORTCARD,
                               (* Buffer  *) ADDRESS,
                               (* Len     *) LONGCARD) : BOOLEAN;
  tGetDataProc    = PROCEDURE ((* bus     *) SHORTCARD,
                               (* Buffer  *) ADDRESS,
                               (* Len     *) LONGCARD) : BOOLEAN;
  tSendStatusProc = PROCEDURE ((* bus     *) SHORTCARD,
                               (* Status  *) SHORTCARD) : BOOLEAN;
  tSendMsgProc    = PROCEDURE ((* bus     *) SHORTCARD,
                               (* Msg     *) SHORTCARD) : BOOLEAN;
  tGetMsgProc     = PROCEDURE ((* bus     *) SHORTCARD,
                               VAR (* Msg     *) SHORTCARD) : BOOLEAN;

  tScsiCall       = RECORD
                      Version     : SHORTCARD;

                      (* Routinen als Initiator *)
                      In          : tInProc;
                      Out         : tOutProc;
                      InquireSCSI : tInquireSCSIProc;
                      InquireBus  : tInquireBusProc;
                      CheckDev    : tCheckDevProc;
                      RescanBus   : tRescanBusProc;
                      Open        : tOpenProc;
                      Close       : tCloseProc;
                      Error       : tErrorProc;

                      (* Routinen als Target *)
                      Install     : tInstallProc;
                      Deinstall   : tDeinstallProc;
                      GetCmd      : tGetCmdProc;
                      SendData    : tSendDataProc;
                      GetData     : tGetDataProc;
                      SendStatus  : tSendStatusProc;
                      SendMsg     : tSendMsgProc;
                      GetMsg      : tGetMsgProc;
                      (* globale Variablen *)
                      ReqData     : POINTER TO tReqData;
                    END;


  tpScsiCall      = POINTER TO tScsiCall;

END ScsiDefs.