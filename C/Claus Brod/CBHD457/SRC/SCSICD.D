DEFINITION MODULE ScsiCD;

(****************************************************************************
 *
 *
 * $Source: E:\HM2\LIB\se\rcs\scsicd.d,v $
 *
 * $Revision: 1.1 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1996/02/03 19:31:20 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: scsicd.d,v $
 * Revision 1.1  1996/02/03  19:31:20  S_Engel
 * Initial revision
 *
 *
 *
 ****************************************************************************)

FROM SYSTEM IMPORT ADDRESS, BYTE;

FROM Portab IMPORT UChar, Char;


(***************************************************************************)
(*-                                                                       -*)
(*- CD-ROM Devices                                                        -*)
(*-                                                                       -*)
(***************************************************************************)


(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- PauseResume entspricht der Pause-Taste des CD-Players.                -*)
(*- SCSI-Opcode $4B                                                       -*)
(*-                                                                       -*)
(*- Pause                                                                 -*)
(*-   TRUE  : CD hÑlt an                                                  -*)
(*-   FALSE : CD spielt weiter                                            -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
PROCEDURE PauseResume(Pause : BOOLEAN) : BOOLEAN;


(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- PlayAudio spielt von einee CD ab BlockAdr TransLength Blîcke ab.      -*)
(*- SCSI-Opcode $A5                                                       -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
PROCEDURE PlayAudio(BlockAdr, TransLength : LONGINT) : BOOLEAN;


TYPE tMSF = RECORD
              CASE : BOOLEAN OF
                 TRUE  : long : LONGCARD;
                |FALSE : Res  : UChar;
                         M    : UChar;        (* Minute    *)
                         S    : UChar;        (* Sekunde   *)
                         F    : UChar;        (* Fragment? *)
              END;
            END;
(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- PlayAudioMSF startet die CD an der absoluten Position Start und lÑût  -*)
(*- sie bis Stop laufen.                                                  -*)
(*- SCSI-Opcode $47                                                       -*)
(*-                                                                       -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
PROCEDURE PlayAudioMSF(Start, Stop : tMSF) : BOOLEAN;


(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- Spielt die StÅcke StarTrack.StartIndex bis EndTrack.EndIndex          -*)
(*- SCSI-Opcode $48                                                       -*)
(*-                                                                       -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
PROCEDURE PlayAudioTrack(StartTrack, StartIndex, EndTrack, EndIndex : SHORTCARD) : BOOLEAN;


(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- PlayAudioRelative startet den CD-Player bei der Position RelAdr in    -*)
(*- dem Track StartTrack und spielt Len Blîcke ab.                        -*)
(*- SCSI-Opcode $49                                                       -*)
(*-                                                                       -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
PROCEDURE PlayAudioRelative(StartTrack : SHORTCARD; RelAdr, Len : LONGCARD): BOOLEAN;


(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- ReadHeader fragt den Header der angegebenen BlockAdr ab.              -*)
(*-                                                                       -*)
(*- SCSI-Opcode $44                                                       -*)
(*-                                                                       -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
PROCEDURE ReadHeader(MSF : BOOLEAN; BlockAdr : LONGCARD;
                     VAR Mode : BYTE; VAR AbsoluteAdr : tMSF) : BOOLEAN;


(* Werte fÅr SubFormat *)
CONST SubQ      = 0;
      CDPos     = 1;
      MediaCatNo= 2;
      TrackISRC = 3;
(* Audio-Status-Codes *)
      NotSupp   = 0;
      Playing   = 011H;
      Paused    = 012H;
      Complete  = 013H;
      ErrStop   = 014H;
      NoStatus  = 015H;
(* Werte fÅr Adr (in ADRControl) *)
      NoQInfo = 0;      (* Sub-channel Q mode information not supplied. *)
      QencPos = 1;      (* Sub-channel Q encodes current position data. *)
      QencUPC = 2;      (* Sub-channel Q encodes media catalog number.  *)
      QencISRC = 3;     (* Sub-channel Q encodes ISRC.                  *)
(* ControlBits:
 Bit          0                                 1
  0       Audio without pre-emphasis    Audio with pre-emphasis  
  1       Digital copy prohibited       Digital copy permitted   
  2       Audio track                   Data track               
  3       Two channel audio             Four channel audio       
 *)


TYPE  tADRControl = (Ctrl0, Ctrl1, Ctrl2, Ctrl3,
                     Adr0, Adr1, Adr2, Adr3);
      tsADRControl = SET OF tADRControl;
      tSubData = RECORD
                  Res0        : BYTE;
                  AudioStatus : UChar;
                  SubLen      : SHORTCARD;  (* Header 4 Bytes *)

                  SubFormat   : BYTE;
                  ADRControl  : tsADRControl;
                  TrackNo     : UChar;

                  CASE : SHORTCARD OF
                    SubQ      :
                                QIndex    : UChar;
                                QAbsAdr   : tMSF;       (* auf der CD *)
                                QRelAdr   : tMSF;       (* im Track   *)
                                QMCVal    : BYTE;       (* Bit 8 *)
                                QUPC14    : BYTE;
                                QUPC      : ARRAY[0..13] OF BYTE;
                                QTCVal    : BYTE;       (* Bit 8 *)
                                QISRC14   : BYTE;
                                QISRC     : ARRAY[0..13] OF BYTE;
                                (* SubQ : insgesamt 48 Bytes *)

                   |CDPos     :
                                IndexNo   : UChar;
                                AbsAdr    : tMSF;       (* auf der CD *)
                                RelAdr    : tMSF;       (* im Track   *)
                                (* CDPos : insgesamt 16 Bytes *)

                   |MediaCatNo:
                                upcRes7   : BYTE;
                                MCVal     : BYTE;       (* Bit 8 *)
                                UPC14     : BYTE;
                                UPC       : ARRAY[0..13] OF BYTE;
                                (* MediaCatNo : insgesamt 24 Bytes *)

                   |TrackISRC :
                                isrcRes7  : BYTE;
                                TCVal     : BYTE;       (* Bit 8 *)
                                ISRC14    : BYTE;
                                ISRC      : ARRAY[0..13] OF BYTE;
                                (* TrackISR : insgesamt 24 Bytes *)
                  END;
                END;

(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- Sub-Channel Daten abfragen                                            -*)
(*- Datenformat ist tSubData.                                             -*)
(*- SCSI-Opcode $42                                                       -*)
(*-                                                                       -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
PROCEDURE ReadSubChannel(MSF, SUBQ : BOOLEAN;
                         SubFormat, Track : SHORTCARD;
                         Data : ADDRESS; Len : SHORTCARD) : BOOLEAN;


CONST MaxTOC = 100;  (* Maximum laut SCSI-2 *)
TYPE  tTOCEntry = RECORD
                    Res0        : BYTE;
                    ADRControl  : tsADRControl;
                    TrackNo     : UChar;
                    Res3        : BYTE;
                    AbsAddress  : tMSF;
                  END;

      tTOCHead =  RECORD
                    TOCLen      : SHORTCARD;    (* ohne TOCLen-Feld*)
                    FirstTrack  : UChar;
                    LastTrack   : UChar;
                  END;

      tTOC     =  RECORD
                    Head    : tTOCHead;
                    Entries : ARRAY[0..MaxTOC] OF tTOCEntry;
                  END;

(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- ReadTOC liest das Inhaltsverzeichnis einer CD ein.                    -*)
(*- Wenn StartTrack # 0 ist, so wird das Inhaltsverzeichnis ab dem ange-  -*)
(*- gebenen Track angegeben.                                              -*)
(*- SCSI-Opcode $43                                                       -*)
(*-                                                                       -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
PROCEDURE ReadTOC(MSF : BOOLEAN; StartTrack : SHORTCARD;
                  Buffer : ADDRESS; Len : SHORTCARD) : BOOLEAN;

PROCEDURE ToshibaReadDiscInfo(mode : SHORTCARD; VAR BlockAdr : LONGCARD) : BOOLEAN;



END ScsiCD.
