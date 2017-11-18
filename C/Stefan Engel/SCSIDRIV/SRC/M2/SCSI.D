DEFINITION MODULE Scsi;
(****************************************************************************
 *
 * SCSI-Kommandos
 * all devices
 *
 *
 * $Source: E:\HM2\LIB\se\rcs\scsi.d,v $
 *
 * $Revision: 1.1 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1996/02/03 19:31:10 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: scsi.d,v $
 * Revision 1.1  1996/02/03  19:31:10  S_Engel
 * Initial revision
 *
 ****************************************************************************
 * Altes Modul: SCSI2.D
 *
 * Revision 1.5  1995/10/30  17:45:14  S_Engel
 *
 *
 ****************************************************************************)

IMPORT
  SYSTEM;
FROM SYSTEM  IMPORT BYTE,ADDRESS,TSIZE;

FROM Portab IMPORT UChar, Char;


IMPORT
  ScsiIO;

(*--------- Deklarationsteil *)

CONST

  (*--- Konstanten fÅr Requenst-Sense-Kommando (SenseKey) *)

  NoSense         =  0;       (* keine Fehlerbeschreibung             *)
  RecoveredError  =  1;       (* behobener Fehler                     *)
  NotReady        =  2;       (* nicht bereit                         *)
  MediumError     =  3;       (* Medium Fehler                        *)
  HardwareError   =  4;       (* Hardware Fehler                      *)
  IllegalRequest  =  5;       (* falsche Parameter                    *)
  UnitAttention   =  6;       (* Unit-Attention-Status                *)
  DataProtect     =  7;       (* nicht benutzt von Festplatten        *)
  BlankCheck      =  8;       (*   "      "     "      "              *)
  VendorUnique    =  9;       (*   "      "     "      "              *)
  AbortedCopy     = 10;       (*   "      "     "      "              *)
  AbortedCommand  = 11;       (* Kommando abgebrochen                 *)
  DataEqual       = 12;       (* nicht benutzt von Festplatten        *)
  VolumeOverflow  = 13;       (*   "      "     "      "              *)
  Miscompare      = 14;       (* Vergleich fehlgeschlagen             *)

  (*--- Konstanten fÅr Device bei Inquiry gemÑû ANSI-Norm *)
  DirectAccessDev =  0;       (* GerÑt mit Direktzugriff (Festplatte) *)
  SeqAccessDev    =  1;       (*   "    "  seq. Zugriff  (Streamer)   *)
  PrinterDev      =  2;       (* Drucker                              *)
  ProcessorDev    =  3;       (* Hostadapter                          *)
  WormDev         =  4;       (* WORM-Laufwerk                        *)
  ReadOnlyDev     =  5;       (* nur-lese Laufwerk (CD-ROM)           *)


  DIRECTACCESSDEV =  0;       (* GerÑt mit Direktzugriff (Festplatte) *)
  SEQACCESSDEV    =  1;       (*   "    "  seq. Zugriff  (Streamer)   *)
  PRINTERDEV      =  2;       (* Drucker                              *)
  PROCESSORDEV    =  3;       (* Hostadapter                          *)
  WORMDEV         =  4;       (* WORM-Laufwerk                        *)
  ROMDEV          =  5;       (* nur-lese Laufwerk (CD-ROM)           *)
  SCANNERDEF      =  6;       (* Scanner                              *)
  OPTICALMEMDEV   =  7;       (* optical memory device                *)
  MEDIUMCHNGDEV   =  8;       (* medium changer device (zB JukeBox)   *)
  COMMDEV         =  9;       (* Communicationdevice                  *)
  GRAPHDEV1       = 10;
  GRAPHDEV2       = 11;
  UNKNOWNDEV      = 31;

TYPE

(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- Mode Pages                                                            -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)

                            (*    7     6     5     4     3     2     1     0 *)
(*** All Device Types ***)
    tDTDC         = BYTE;   (*    Reserved                       |  DTDC      *)
    tPage02       = RECORD   (* Disconnect/Reconnect Page *)
                      BufferFullRatio   : BYTE;
                      BufferEmptyRatio  : BYTE;
                      BudInactLimit     : SHORTCARD;
                      DiscTimeLimit     : SHORTCARD;
                      ConnectTimeLimit  : SHORTCARD;
                      MaxBurstSize      : SHORTCARD;
                      DTDC              : tDTDC;
                      Reserved13        : BYTE;
                      Reserved          : ARRAY[14..15] OF BYTE;
                    END;

    tPage09       = RECORD   (* Peripheral Device Page *)
                      Identifier  : SHORTCARD;
                      Reserved    : ARRAY[4..7] OF BYTE;
                      (* Vendor specific *)
                    END;

    tRLEC      = BYTE;      (* Reserved                                | RLEC *)
    tQueueModif= BYTE;      (* Queue Modif                 | Res | QErr| DQue *)
    tEECA      = BYTE;      (* EECA| Reserved              |RAENP|UAAENP|EAENP*)
    tPage0A    = RECORD     (* Control Mode Page *)
                      RLEC        : tRLEC;
                      QueueModif  : tQueueModif;
                      EECA        : tEECA;
                      Reserved    : BYTE;
                      AENHoldOff  : SHORTCARD;
                    END;

(*** Sequential Devices ***)

    (* Device Sepecific Qualifiers, Parameter Header *)
    tSeqFlags   = (Speed0,       (* Speed Code                   *)
                   Speed1,
                   Speed2,
                   Speed3,
                   BufMode,      (* Buffered Mode                *)
                   STR5,STR6,    (* reserviert                   *)
                   WrProt);      (* Write Protect                *)
    tsSeqFlags  = SET OF tSeqFlags;


    tSeqErrorFlags = (DCR, DTE, PER, EER, tSeqErrRes4, TB, tSeqErrRes6, tSeqErrRes7);
    tsSeqErrorFlags  = SET OF tSeqErrorFlags;
    tSeqPage01  = RECORD    (* Read-Write Error Recovery Page *)
                    SeqError        : tsSeqErrorFlags;
                    ReadRetryCount  : UChar;
                    Reserved1       : ARRAY[4..7] OF BYTE;
                    WriteRetryCount : UChar;
                    Reserved9       : BYTE;
                    Reserved10      : ARRAY[10..11] OF BYTE;
                  END;

    tSP10Fl1    = (NGroup0,
                   NGroup1,
                   NGroup2,
                   G3ECC,
                   RAW,
                   CAF,
                   cap,
                   SP10Fl1Res7);
    tSP10Fl2    = (REW,
                   RBO,
                   SOCF0,
                   SOCF1,
                   AVC,
                   RSmk,
                   BIS,
                   DBR);
    tSP10Fl3    = (SP10Fl3Res0,
                   SP10Fl3Res1,
                   SP10Fl3Res2,
                   SEW,
                   EEG,
                   EODDefined0,
                   EODDefined1,
                   EODDefined2);

    tSP10Flags1 = SET OF tSP10Fl1;
    tSP10Flags2 = SET OF tSP10Fl2;
    tSP10Flags3 = SET OF tSP10Fl3;
    tSeqPage10  = RECORD    (* Device Configurating Page *)
                    SP10Flags1      : tSP10Flags1;
                    ActivePart      : UChar;
                    WrtBuffRartio   : UChar;
                    RdBuffRatio     : UChar;
                    WriteDelay      : SHORTCARD;
                    SP10Flags2      : tSP10Flags2;
                    GapSize         : UChar;
                    SP10Flags3      : tSP10Flags3;
                    EarlyWarnMSB    : UChar;
                    EarlyWarnLSW    : SHORTCARD;
                    ComprAlgo       : UChar;
                    Reserved        : BYTE;
                  END;


    tSeqPage0F  = RECORD    (* Data Compression Characteristics (HP only??) *)
                    Flags1          : BYTESET;
                    Flags2          : BYTESET;
                    Compalgorythm   : LONGCARD;
                    Decompalgorythm : LONGCARD;
                    Reserved        : LONGCARD;
                  END;


(*** CD-ROM Devices ***)

    (* Device Sepecific Qualifiers, Parameter Header *)
    tCDFlags    = (EBC,           (* Enable Blank Check (res) *)
                   CDRes1,
                   CDRes2,
                   CDRes3,
                   Cache,         (* Laufwerk hat ein Cache   *)
                   CDRes5,
                   CDRes6,
                   CDRes7);
    tsCDFlags  = SET OF tSeqFlags;

    (* Page 0D : CD-ROM Parameters Page *)
    tCDPage0D   = RECORD
                    CDP0DRes2 : BYTE;
                    InactTMul : BYTE;      (* unteres Nibble *)
                    SperMSF   : SHORTCARD;
                    FperMSF   : SHORTCARD;
                  END;

    (* Page 0E : CD-ROM Audio Control Page *)
    tCDChSel = (Ch0,              (* Kanal 0 an diesen Output-Port  *)
                Ch1,              (* Kanal 1 an diesen Output-Port  *)
                Ch2,              (* Kanal 2 an diesen Output-Port  *)
                Ch3,              (* Kanal 3 an diesen Output-Port  *)
                ChRes4,
                ChRes5,
                ChRes6,
                ChgRes7);
    tsCDChSel = SET OF tCDChSel;
    tCDPage0E   = RECORD
                    ImmedFlags      : BYTESET;
                    CD0ERes3        : BYTE;
                    CD0ERes4        : BYTE;
                    LBAFlags        : BYTESET;
                    BlocksPerSecond : SHORTCARD;
                      (* Genau:
                       *   LBAFlags MOD 10H = 0 -> BlocksPerSecond
                       *   LBAFlags MOD 10H = 8 -> 256 * BlocksPerSecond
                       *)
                    Port0Channel    : tsCDChSel;
                    Port0Volume     : UChar;
                    Port1Channel    : tsCDChSel;
                    Port1Volume     : UChar;
                    Port2Channel    : tsCDChSel;
                    Port2Volume     : UChar;
                    Port3Channel    : tsCDChSel;
                    Port3Volume     : UChar;
                  END;


CONST
    CDDefDens         = 00H;
    CDUserDataDens    = 01H;
    CDUserDataAuxDens = 02H;
    CDOnlyAudioDens   = 04H;    (* 1/75 sec / Block *)


TYPE
    tModeParms  = RECORD
                    CASE : SHORTCARD OF
                      (* All Device-Types *)
                    |2   : P02      : tPage02;
                    |9   : P09      : tPage09;
                      (* Sequential Devices *)
                    |101H : SeqP01   : tSeqPage01;
                    |10FH : SeqP0F   : tSeqPage0F;
                    |110H : SeqP10   : tSeqPage10;
                    |201H : CDP0D    : tCDPage0D;
                    |202H : CDP0E    : tCDPage0E;
                    END;
                  END;

(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- ModeSense-Typen                                                       -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
    tDeviceSpecs  = RECORD
                      CASE : SHORTCARD OF
                       1 : Seq : tsSeqFlags;
                      |2 : CD  : tsCDFlags;
                      END;
                    END;

    tParmHead     = RECORD
                      ModeLength  : UChar;
                      MediumType  : UChar;
                      DeviceSpecs : BYTESET;        (* tDeviceSpecs *)
                      BlockDescLen: UChar;
                    END;
    (*$?TSIZE(tParmHead) # 4 : Fragezeichen? *)

    tBlockDesc    = RECORD
                      Blocks      : LONGCARD;       (* Byte HH = DensityCode *)
                      BlockLen    : LONGCARD;       (* Byte HH = Reserved    *)
                    END;
    (*$?TSIZE(tBlockDesc) # 8 : Fragezeichen? *)

    tPage         = RECORD
                      PageCode    : UChar;          (* PS | Res | Pagecode *)
                      PageLen     : UChar;
                      ModeParms   : tModeParms;     (* Seiten und TypabhÑngig *)
                    END;

    tModePage     = RECORD
                      ParmHead    : tParmHead;
                      BlockDesc   : tBlockDesc;
                      Page        : tPage;
                    END;



    tVendor       = ARRAY[0..07] OF CHAR;
    tProduct      = ARRAY[0..15] OF CHAR;
    tInquiry      = RECORD
                       Device          : UChar;
                       DeviceQualifier : BYTE;
                       VersionFlags    : BYTE;
                       FormatFlags     : BYTE;
                       AdditionalLen   : UChar;
                       Res1            : BYTE;
                       Reserved        : ARRAY[6..7] OF BYTE;
                       Vendor          : tVendor;
                       Product         : tProduct;
                       RevionsData     : ARRAY[0..3] OF CHAR;
                     END;


VAR ScsiFlags : BITSET;


PROCEDURE TestUnitReady() : BOOLEAN;
  (*
   * TestUnitReadyCmd testet, ob das gewÑhlte SCSI-GerÑt bereit ist.
   *)



(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- Inquiry mit der Mîglichkeit zu Vital Data                             -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
PROCEDURE Inquiry(Buffer : ADDRESS; Vital : BOOLEAN; Page : SHORTCARD;
                  Len : SHORTCARD) : BOOLEAN;



(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- Mode Select                                                           -*)
(*-                                                                       -*)
(*- SelectFlags : Parameter, wie gesichert werden soll                    -*)
(*- Buffer      : Zeiger auf die Mode-Parameter                           -*)
(*- ParmLen     : LÑnge des ParameterFeldes                               -*)
(*-                 LÑnge der Daten in der ModePage!                      -*)
(*-                 TSIZE(tModeParms.tag) + 2 !!                          -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
TYPE  tSelectFlag     = (SMP,          (* Save Mode Parameters         *)
                         tsRes1,
                         tsRes2,
                         tsRes3,
                         PF,           (* Page Format                  *)
                         tsLun0,
                         tsLun1,
                         tsLun2);
      tsSelectFlag    = SET OF tSelectFlag;
PROCEDURE ModeSelect(SelectFlags : tsSelectFlag;
                        Buffer      : ADDRESS;
                        ParmLen     : SHORTCARD) : BOOLEAN;

(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- Mode Sense                                                            -*)
(*-                                                                       -*)
(*- PageCode    : Nummer der zu lesenden Page                             -*)
(*- PageControl : auszulesende Parameter                                  -*)
(*- Buffer      : Zeiger auf die Mode-Parameter                           -*)
(*- ParmLen     : LÑnge des ParameterFeldes                               -*)
(*-                 LÑnge der Daten in der ModePage!                      -*)
(*-                 TSIZE(tModeParms.tag) + 2 !!                          -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
TYPE tPC = (CurrentValues, ChangeableValues, DefaultValues, SavedValues);
PROCEDURE ModeSense(PageCode     : SHORTCARD;
                       PageControl  : tPC;
                       Buffer       : ADDRESS;
                       ParmLen      : SHORTCARD) : BOOLEAN;




TYPE ErrorType = (nomedia, mediachange, reset, unknown);

PROCEDURE GetError(reqbuff : ADDRESS) : ErrorType;


PROCEDURE PreventMediaRemoval(Prevent:BOOLEAN) : BOOLEAN;
  (*
   * PreventMediaRemvolCmd ver- bzw. entriegelt das eingelegte Medium,
   * wenn Prevent gleich TRUE bzw. FALSE ist.
   *)
    


(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- Allgemeine Tools                                                      -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
(*PROCEDURE SuperOn;*)

(*PROCEDURE SuperOff;*)

PROCEDURE Wait(Ticks : LONGCARD);

PROCEDURE SetBlockSize(NewLen : LONGCARD);
  (*
   * SetBlockLen legt die BlocklÑnge fÅr das SCSI-GerÑt fest
   * (normalerweise 512 Bytes).
   *)

PROCEDURE GetBlockSize() : LONGCARD;
  (*
   * GetBlockLen gibt die aktuell eingestellte BlocklÑnge zurÅck.
   *)


VAR SetScsiUnit : PROCEDURE((* handle  *) ScsiIO.tHandle,
                            (* Lun     *) SHORTINT,
                            (* MaxLen  *) LONGCARD);
PROCEDURE MySetScsiUnit(handle : ScsiIO.tHandle; Lun : SHORTINT; MaxLen : LONGCARD);
  (*
   * SetScsiUnit legt das GerÑt fest an das die nachfolgenden Kommandos
   * gesendet werden und wie lang die Transfers maximal sein dÅrfen.
   *)


(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- Zugriff fÅr Submodule (ScsiStreamer, ScsiCD, ScsiDisk...)             -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)

TYPE
  tpCmd6  = POINTER TO tCmd6;
  tCmd6   = RECORD
              Command : UChar;
              LunAdr  : BYTE;
              Adr     : SHORTCARD;
              Len     : UChar;
              Flags   : BYTE;
            END;  

  tpCmd10 = POINTER TO tCmd10;
  tCmd10  = RECORD
              Command : UChar;
              Lun     : BYTE;
              Adr     : LONGCARD;
              Reserved: UChar;
              LenHigh : UChar;
              LenLow  : UChar;
              Flags   : BYTE; 
            END;

  tpCmd12 = POINTER TO tCmd12;
  tCmd12  = RECORD
              Command : UChar;
              Lun     : BYTE;
              Adr     : LONGCARD;
              Len     : LONGCARD;
              Reserved: BYTE;
              Flags   : BYTE; 
            END;

VAR
  Cmd6            : tCmd6;
  Cmd10           : tCmd10;
  Cmd12           : tCmd12;
  BlockLen        : SHORTCARD;
  MaxDmaLen       : LONGCARD;
  LogicalUnit     : SHORTCARD;

PROCEDURE SetCmd6(VAR CmdBlock : ARRAY OF SYSTEM.LOC;
                  Cmd :SHORTCARD;BlockAdr:LONGCARD;
                                   TransferLen:SHORTCARD) : tpCmd6;

PROCEDURE SetCmd10(VAR CmdBlock : ARRAY OF SYSTEM.LOC;
                   Cmd :SHORTCARD;BlockAdr:LONGCARD;
                                      TransferLen:SHORTCARD) : tpCmd10;
         
PROCEDURE SetCmd12(VAR CmdBlock : ARRAY OF SYSTEM.LOC;
                   Cmd : SHORTCARD; BlockAdr    : LONGCARD;
                                    TransferLen : LONGCARD) : tpCmd12;

PROCEDURE SetCmd(VAR ScsiCmd  : ARRAY OF SYSTEM.LOC;
                 VAR CmdBlock : ARRAY OF SYSTEM.LOC;
                     Buffer   : SYSTEM.ADDRESS;
                     Len      : LONGCARD;
                     TimeOut  : LONGCARD) : ScsiIO.tpSCSICmd;


END Scsi.
