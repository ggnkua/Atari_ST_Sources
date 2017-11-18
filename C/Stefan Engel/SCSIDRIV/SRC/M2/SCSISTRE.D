DEFINITION MODULE ScsiStreamer;
(****************************************************************************
 *
 *
 * $Source: E:\HM2\LIB\se\rcs\scsistre.d,v $
 *
 * $Revision: 1.1 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1996/02/03 19:32:12 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: scsistre.d,v $
 * Revision 1.1  1996/02/03  19:32:12  S_Engel
 * Initial revision
 *
 *
 *
 ****************************************************************************)

FROM SYSTEM IMPORT ADR, ADDRESS;


PROCEDURE Rewind(Imed : BOOLEAN; TimeoutSeconds : LONGCARD) : BOOLEAN;
  (*
   * RewindCmd spult das 'Band' bei sequentiellen SCSI-GerÑten zurÅck.
   * Ist Imed gleich FALSE, so wird gewartet bis das 'Band' zurÅck
   * gespult worden ist. Ansonsten wird nicht gewartet. TimeoutSeconds
   * ist die Auszeit in Sekunden (bei Imed=FALSE entsprechend hoch
   * setzen).
   *)

CONST SpaceBlock        = 0;
      SpaceMark         = 1;
      SpaceSerie        = 2;
      SpaceEnd          = 3;
      SpaceSetmarks     = 4;
      SpaceSetmarkSerie = 5;

PROCEDURE Space(Code : SHORTCARD; Count : LONGINT;
                   TimeoutSeconds : LONGCARD) : BOOLEAN;
  (*
   * SpaceCmd sucht/Åberspult Count Dinge - je nach Code - auf einem 
   * sequentiellen Medium (Count<0 rÅckwÑrts).
   * Code = SpaceBlock  Count Blîcke Åberspulen
   *      = SpaceMark   Count Filemarks Åberspulen
   *      = SpaceSerie  bis Serie von Count Filemarks spulen
   *      = SpaceEnd    bis zum Ende des beschriebenen Bereichs
   *)

PROCEDURE WriteFilemark(Imed : BOOLEAN; Number : SHORTCARD; TimeoutSeconds : LONGCARD) : BOOLEAN;
  (*
   * WriteFilemarkCmd schreibt Number Filemarks auf ein sequentielles
   * Medium. Ist Imed gleich FALSE, so wird gewartet bis die Marken
   * geschrieben sind.
   *)


PROCEDURE Load(Imed, Ret, Eot, Load : BOOLEAN;
               TimeoutSeconds : LONGCARD) : BOOLEAN;
  (*
   * LoadUnloadCmd ist das StartStopCmd fÅr sequentielle Medien. Die 
   * Flags haben vollgende Bedeutung:
   * Imed=TRUE  AusfÅhrung nicht abwarten
   * Ret =TRUE  sequentielles Medium wird einmal ganz vor- und
   *            zurÅckgespult um z.B. bei BÑndern Spannungen zu 
   *            beseitigen (retension)
   * Eot =TRUE  vor entladen Ende des Mediums anfahren (END OF tape)
   * Laod=TRUE  Medium laden
   *) 

PROCEDURE Read(TransferLen : SHORTCARD; ADR : ADDRESS; TimeoutSeconds : LONGCARD) : BOOLEAN;
PROCEDURE ReadNum(VAR TransferLen : SHORTCARD; ADR:ADDRESS; TimeoutSeconds : LONGCARD) : BOOLEAN;
  (*
   * SeqReadCmd liest TransferLen Blîcke von einem sequentiellen Medium
   * an die durch ADR angegebene Adresse in den Speicher.
   *)


PROCEDURE Write(TransferLen : SHORTCARD; ADR : ADDRESS; TimeoutSeconds : LONGCARD) : BOOLEAN;
PROCEDURE WriteNum(VAR TransferLen : SHORTCARD; ADR : ADDRESS; TimeoutSeconds : LONGCARD) : BOOLEAN;
  (*
   * SeqWriteCmd schreibt TransferLen Blîcke aus dem Speicher, der bei
   * ADR beginnt, auf ein sequentielles Medium.
   *)

PROCEDURE Erase(TimeoutSeconds : LONGCARD) : BOOLEAN;
  (*
   * EraseCmd lîscht das im SCSI-GerÑt eingelegte sequentielle Medium.
   *)


PROCEDURE RequestBlockAdr(VAR BlockAdr:LONGCARD) : BOOLEAN;
  (* 
   * Aktuelle Blockadresse eines sequentiellen SCSI-GerÑtes abfragen.
   * Ein Kommando mit dem hier verwendeten Code $02 ist in der ANSI-Norm 
   * nicht spezifiziert, sondern ist als vom Hersteller frei verwendbar
   * ausgewiesen. Tandberg-Streamer kennen dieses Kommando.
   *)

PROCEDURE SeekBlock(Imed : BOOLEAN;
                    BlockAdr, TimeoutSeconds : LONGCARD) : BOOLEAN;
  (*
   * SeqSeekBlockCmd spult das 'Band' eines sequentiellen SCSI-GerÑtes
   * auf den Block mit der Nummer BlockAdr. Ist Imed gleich FALSE, so wird 
   * gewartet bis das 'Band' positioniert ist. Ansonsten wird nicht 
   * gewartet. TimeoutSeconds ist die Auszeit in Sekunden (bei Imed=FALSE 
   * entsprechend hoch setzen). Ein Kommando mit dem hier verwendeten Code 
   * $0C ist in der ANSI-Norm nicht spezifiziert, sondern ist als vom 
   * Hersteller frei verwendbar ausgewiesen. Tandberg-Streamer kennen 
   * dieses Kommando.
   *)


(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- Locate ist das Kommando zur Positionierung eines Streamers            -*)
(*- auf einer vorgegebenen Blocknummer.                                   -*)
(*- SCSI-Opcode $2B                                                       -*)
(*- Quelle : SCSI-2 draft proposal                                        -*)
(*-                                                                       -*)
(*- BlockAdresstype                                                       -*)
(*-   TRUE  : Block-Adresse als Device-Specific Value                     -*)
(*-   FALSE : Adresse als logische Block-Adresse                          -*)
(*- ChangePartition                                                       -*)
(*-   TRUE  : Band-Partition wechseln, Partitionsnummer Åbergeben         -*)
(*-   FALSE : Partition beibehalten                                       -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
PROCEDURE Locate(BlockAdresstype : BOOLEAN;
                 ChangePartition : BOOLEAN;
                 Imed            : BOOLEAN;
                 BlockAdress     : LONGCARD;
                 Partition       : SHORTCARD;
                 TimeoutSeconds  : LONGCARD) : BOOLEAN;

(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- Read Position ist das Kommando zur Abfrage der aktuellen              -*)
(*- Bandposition                                                          -*)
(*- SCSI-Opcode $34                                                       -*)
(*-                                                                       -*)
(*- BlockAdresstype                                                       -*)
(*-   TRUE  : Block-Adresse als Device-Specific Value                     -*)
(*-   FALSE : Adresse als logische Block-Adresse                          -*)
(*- Partition : Nummer der aktuellen Partition                            -*)
(*- BlockAdress : Adresse des nÑchsten zu Åbertragenden Blockes           -*)
(*-                                                                       -*)
(*- die Werte fÅr BOP, EOP, Last Block Location, Number of Blocks in      -*)
(*- Buffer Number of Bytes per Buffer werden bei der Prozedurantwort      -*)
(*- unterschlagen.                                                        -*)
(*- Zur Auswertung dieser Parameter bitte ALIASCMD.I beachten.            -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
PROCEDURE ReadPosition(    BlockAdresstype : BOOLEAN;
                       VAR Partition       : SHORTCARD;
                       VAR BlockAdress     : LONGCARD) : BOOLEAN;



END ScsiStreamer.
