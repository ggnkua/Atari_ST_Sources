DEFINITION MODULE ScsiDisk;
(****************************************************************************
 *
 *
 * $Source: E:\HM2\LIB\se\rcs\scsidisk.d,v $
 *
 * $Revision: 1.2 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1996/02/03 19:31:46 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: scsidisk.d,v $
 * Revision 1.2  1996/02/03  19:31:46  S_Engel
 * Kleine Anpassungen
 *
 * Revision 1.1  1995/11/13  17:38:26  S_Engel
 * Initial revision
 *
 *
 *
 ****************************************************************************)


FROM SYSTEM  IMPORT BYTE, ADDRESS, TSIZE;

IMPORT
  Portab;


TYPE
  tDefectList = RECORD
                  res : SHORTCARD;
                  len : SHORTCARD;
                  blocks : ARRAY[0..MAX(SHORTINT)] OF LONGCARD;
                END;

(*-----------------------------------------------------------------------
 *
 * Reassign Blocks.
 *
 * Buffer enthÑlt die Defectliste
 * count ist die Anzahl der Blocks!
 *
 *-----------------------------------------------------------------------*)
PROCEDURE ReassignBlocks(Buffer : ADDRESS; count : SHORTCARD) : BOOLEAN;

PROCEDURE Read6(BlockAdr : LONGCARD;
                TransferLen : SHORTCARD; Adr : ADDRESS) : BOOLEAN;

PROCEDURE Read10(BlockAdr : LONGCARD;
                 TransferLen : SHORTCARD; Adr : ADDRESS) : BOOLEAN;

PROCEDURE Write6(BlockAdr : LONGCARD;
                 TransferLen : SHORTCARD; Adr : ADDRESS) : BOOLEAN;

PROCEDURE Write10(BlockAdr : LONGCARD;
                  TransferLen : SHORTCARD; Adr : ADDRESS) : BOOLEAN;


PROCEDURE Read(BlockAdr : LONGCARD;
               TransferLen : SHORTCARD; ADR : ADDRESS) : BOOLEAN;
  (*
   * ReadCmd liest Datenblîcke ein
   * Wenn nîtig, wird ein langes Kommando (10 Byte, Class 1) verwendet.
   *)

PROCEDURE Write(BlockAdr : LONGCARD;
                TransferLen : SHORTCARD; ADR : ADDRESS) : BOOLEAN;
  (*
   * WriteCmd speichert Datenblîcke ab.
   * Wenn nîtig, wird ein langes Kommando (10 Byte, Class 1) verwendet.
   *)


(*
 *)
PROCEDURE StartStop(LoadEject, StartFlag : BOOLEAN) : BOOLEAN;


PROCEDURE Seek6(BlockAdr : LONGCARD) : BOOLEAN;
PROCEDURE Seek10(BlockAdr : LONGCARD) : BOOLEAN;

PROCEDURE Seek(BlockAdr : LONGCARD) : BOOLEAN;


PROCEDURE Format() : BOOLEAN;

(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- ReadCapacity fragt die Grîûe des Laufwerkes ab.                       -*)
(*- Bei PMI = TRUE wird der nach BlockAdr nÑchste Block angegeben, der    -*)
(*- noch ohne Verzîgerung Åbertragen werden kann.                         -*)
(*- Bei Platten kann dies der letzte PBlock auf dem gleichen Zylinder wie -*)
(*- BlockAdr sein, bei CD-ROMs in etwa der letzte Block, der ohne         -*)
(*- GeschwindigkeitsÑnderung Åbertragen werden kann.                      -*)
(*- PMI=FALSE erfragt die absolute Grîûe des GerÑtes.                     -*)
(*- SCSI-Opcode $25                                                       -*)
(*-                                                                       -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
PROCEDURE ReadCapacity(PMI : BOOLEAN; VAR BlockAdr, BlockLen : LONGCARD) : BOOLEAN;

(*-----------------------------------------------------------------------
 *
 * Defectliste erfragen
 *
 * Plist: Primary Defect List
 * Glist: Grown Defect List
 * Format: (s. SCSI-Norm FORMAT UNIT)
 *     0  = BLOCK FORMAT                (das dÅrfte das interessante sein)
 *   100b = BYTES FROM INDEX FORMAT
 *   101b = PHYSICAL SECTOR FORMAT
 *   110b = VENDOR SPECIFIC
 *-----------------------------------------------------------------------*)

TYPE
  tDefect0  = RECORD
                Block     : LONGCARD;
              END;
  tDefect4  = RECORD
                CylHead   : LONGCARD;  (* cyl, cyl, cyl, head *)
                FromIndex : LONGCARD;
              END;
  tDefect5  = RECORD
                CylHead   : LONGCARD;  (* cyl, cyl, cyl, head *)
                SecNo     : LONGCARD;
              END;

  tDefectHead = RECORD
                  res       : Portab.UChar;
                  ListType  : BYTESET;
                      (* 7..5: Reserved
                       * 4 : Plist
                       * 3 : Glist
                       * 2..0: Defect list format
                       *)
                  Len       : SHORTCARD;
                END;




PROCEDURE ReadDefectData(Buffer : ADDRESS;
                         Plist, Glist : BOOLEAN;
                         Format : SHORTCARD;
                         Len : SHORTCARD) : BOOLEAN;



END ScsiDisk.
