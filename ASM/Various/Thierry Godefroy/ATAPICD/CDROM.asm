********************************************************************************
*        CD-ROM device driver / thing v0.06 (c) 2001 Thierry Godefroy.         *
*    This software is free and open source (under the "artistic" license).     *
********************************************************************************

          data      0
          section   CDROM

          include   drv1_src_asm_ATAPI_inc

* Thing/driver version Id:

VERSION   equ       '0.06'

* Room needed by the thing definition block. Note that this block is immediately
* followed by the device driver linkage block.

THGDEF    equ       50

* Some system variables:

SYS_FSDD  equ       $100
SYS_FSCH  equ       $140

* Some offsets into the device driver linkage block:

IOD_PLLK  equ       $08
IOD_SHLK  equ       $10
IOD_OLK   equ       $18
IOD_IOAD  equ       $1C
IOD_DNUS  equ       $3C

DLB_LONGN equ       $50                           Pointer to last long filename.
DLB_ATAPI equ       $54                           ATAPI thing linkage block add.
DLB_DDRIV equ       $58                           Default drive number (word).
DLB_DTABL equ       $5A                           Device table (8 long words).
*         Each table entry into the device table as follow:
*         - 1st (MS) byte: 2*controller number (0-3)+IDE bus drive number (0/1).
*         - 2nd      byte: Session number (0 to n) on the CD-R for device.
*         - 3rd      byte: reserved.
*         - 4th (LS) byte: reserved.

DLB_LEN   equ       200                           Driver linkage block length.

* Some offsets into the drives physical definition block:

FS_DRIVN  equ       $14
FS_MNAME  equ       $16
FS_FILES  equ       $22

PDB_LEN   equ       1024                          Length of physical def. block.

* Some offsets into the channels definition block:

CHN_LINK  equ       $18                           Linked list of channel blocks.
CHN_ACCS  equ       $1C                           Access mode.
CHN_DRID  equ       $1D                           Drive Id.
CHN_QDID  equ       $1E                           QDOS file Id.
CHN_SCTL  equ       $1E                           Sector length.
CHN_FPOS  equ       $20                           File position.
CHN_FEOF  equ       $24                           File EOF position.
CHN_LNAME equ       $28                           Pointer to long filename.
CHN_NAME  equ       $32                           File name (short one).
CHN_DDEF  equ       $58                           Pointer to physical def block.
CHN_DRNR  equ       $5C                           Drive number.
CHN_FLID  equ       $5E                           File Id (start block number).
CHN_SDID  equ       $62                           (Sub-)directory Id.
CHN_SDPS  equ       $64                           (Sub-)directory entry pos.
CHN_SDEF  equ       $68                           (Sub-)directory end of file.
CHN_FLAGS equ       $6C                           Misc. channel flags (byte).
CHN_PKT   equ       $6E                           Channel ATAPI packet buffer.

* Channel flags value:

CHN..POST equ       0                             Post-processing flag.
CHN..PERR equ       1                             Error while post-proc. flag.

CHN.POST  equ       %00000001                     Waiting for post-processing.
CHN.PERR  equ       %00000010                     Error occured in post-process.

* IDE STATUS bits:

IDE..ERR  equ       0                             Error in previous command.

IDE.ERR   equ       %00000001                     Error in previous command.

* IDE ERROR bits:

IDE..SNS  equ       %11110000                     Mask for sense bits.
IDE..MCR  equ       3                             Media change request.
IDE..ABRT equ       2                             Aborted command.
IDE..EOM  equ       1                             End of media detected.
IDE..ILI  equ       0                             Illegal length indication.

* Sense keys (as available in IDE error byte shifted right into lower nibble):

SNS.RECOV equ       1                             Recovered data with err/corr.
SNS.NOTRD equ       2                             Logical drive not ready
SNS.UNREC equ       3                             Unrecoverable error.
SNS.BADCD equ       5                             Bad command/parameters.
SNS.RESET equ       6                             RESET in progress.

*******************************************************************************
* Initialization routine:

          MOVEQ     #1,D7                         Set the first init flag.
          BRA.S     INIT                          Initialize CDROM thing now.
CDROMLINK MOVEQ     #0,D7                         Reset the "first init" flag.
INIT      MOVEQ     #0,D0                         | Get system info.
          TRAP      #1                            |
          MOVEQ     #-19,D0                       "Not implemented" error code.
          CMPI.L    #'SMSQ',(A0)                  Are we running under SMSQ(/E)?
          BNE.S     INIT_END                      If not then return with error.
          MOVEQ     #-2,D0                        "Invalid job Id" error code.
          TST.L     D1                            Is job 0 the calling job ?
          BNE.S     INIT_END                      If no, then return with error.
          BSR.S     INIT_THG                      Initialize the thing.
          BNE.S     INIT_END                      Return if error.
          TST.B     D7                            Is the "first init" flag set ?
          BEQ.S     INIT1                         If no then jump over...
          LEA       PROC_FN,A1                    PROC/FN table address.
          MOVEA.W   $110,A2                       | Link in the new PROCs/FNs.
          JSR       (A2)                          |
          BNE.S     INIT_END                      If error, return.
INIT1     LEA       COPYRIGHT,A1                  Get copyright message address.
          SUBA.L    A0,A0                         SBASIC #0 channel Id.
          MOVEA.W   $D0,A2                        | Print the copyright.
          JSR       (A2)                          |
INIT_END  RTS                                     Return to SBASIC.

*******************************************************************************
* CDROM thing initialization:

INIT_THG  BSR       SEARCH                        Search for the THING vector.
          BNE.S     INIT_END                      If error, return now.
          LEA       CDRNAME,A0                    Pointer on thing name.
          MOVEQ     #$27,D0                       | Remove possible previously
          JSR       (A4)                          |  loaded old ATAPI thing.
          CMPI.L    #-9,D0                        Is the old thing still in use?
          BEQ.S     INIT_END                      If yes, then return now...
          LEA       ATPNAME,A0                    ATAPI thing name.
          MOVEQ     #0,D2                         No specific extension needed.
          MOVEQ     #-1,D1                        Use it for the current job.
          MOVEQ     #$28,D0                       | Use the ATAPI thing.
          JSR       (A4)                          |
          TST.L     D0                            Error ?
          BNE.S     INIT_END                      If yes, return now.
          MOVEA.L   A2,A5                         Save ATAPI thing link blk add.
          MOVEQ     #0,D2                         | Reserves some space for the
          MOVE.L    #THGDEF+DLB_LEN,D1            |  thing linkage block in the
          MOVEQ     #$18,D0                       |  common heap (owner is the
          TRAP      #1                            |  un-removable job 0).
          TST.L     D0                            Error ?
          BNE.S     INIT_END                      If yes, return immediately.
          MOVEA.L   A0,A3                         Save linkage block address.
          ADDQ.L    #8,A0                         Jump over system links.
          CLR.L     (A0)+                         Use default TH_FRFRE routine.
          CLR.L     (A0)+                         Use default TH_FRZAP routine.
          LEA       CDROM_THG,A1                  CDROM thing address.
          MOVE.L    A1,(A0)+                      Store thing address.
          CLR.L     (A0)+                         Use default TH_USE routine.
          CLR.L     (A0)+                         Use default TH_FREE routine.
          CLR.L     (A0)+                         Use default TH_FFREE routine.
          LEA       CDRTHGRMV,A1                  CDROM thing TH_REMOV addr.
          MOVE.L    A1,(A0)+                      Use my routine for TH_REMOV.
          CLR.W     (A0)+                         This thing is shareable.
          MOVE.L    #VERSION,(A0)+                Thing version ID.
          MOVE.W    #5,(A0)+                      Length of thing name.
          MOVE.L    #'CDRO',(A0)+                 | Name of thing.
          MOVE.W    #'M ',(A0)+                   |
          MOVEA.L   A3,A1                         A1=thing linkage block addr.
          MOVEQ     #$26,D0                       | Link in my thing.
          JSR       (A4)                          |
          TST.L     D0                            Is there any error ?
          BEQ.S     INIT_DRV                      If no jump over...
          MOVE.L    D0,D4                         Save error code.
          LEA       ATPNAME,A0                    ATAPI thing name.
          MOVEQ     #-1,D1                        User is current job.
          MOVEQ     #$29,D0                       | Free the ATAPI thing.
          JSR       (A4)                          |
          MOVEA.L   A3,A0                         Thing linkage block address.
          MOVEQ     #$19,D0                       | Release common heap area
          TRAP      #1                            |  (thing linkage block).
          MOVE.L    D4,D0                         Restore error code.
          RTS                                     Return.

*******************************************************************************
* CDR device driver initialisation:

INIT_DRV  LEA       THGDEF(A3),A4                 A4=end of thing definition.
          ST        DLB_DDRIV(A4)                 No default drive yet.
          MOVE.L    A5,DLB_ATAPI(A4)              Save ATAPI thing link blk add.
          MOVEQ     #7,D0                         DBRA counter (8 devices).
          LEA       DLB_DTABL(A4),A0              Devices table.
INITDRV1  ST        (A0)                          Mark device as undefined.
          ADDQ.L    #4,A0                         Point on next device entry.
          DBRA      D0,INITDRV1                   Mark next device.
          CLR.L     IOD_PLLK(A4)                  | No polled interrupt routine
          CLR.L     IOD_PLLK+4(A4)                |  needed for this device.
          CLR.L     IOD_SHLK(A4)                  | No scheduler loop routine
          CLR.L     IOD_SHLK+4(A4)                |  needed for this device.
          LEA       IOD_IOAD(A4),A0               I/O routine link.
          LEA       CD_IO,A2                      I/O routine.
          MOVE.L    A2,(A0)+                      Store its address.
          LEA       CD_OPEN,A2                    Open routine.
          MOVE.L    A2,(A0)+                      Store its address.
          LEA       CD_CLOSE,A2                   Close routine.
          MOVE.L    A2,(A0)+                      Store its address.
          CLR.L     (A0)+                         No forced slaving.
          CLR.L     (A0)+                         Reserved.
          LEA       CD_ERRNI,A2                   Not implemented routine.
          MOVE.L    A2,(A0)+                      Set channel name rouinte.
          MOVE.L    A2,(A0)+                      Format medium routine.
          MOVE.L    #PDB_LEN,(A0)+                Length of physical def. block.
          MOVEQ     #3,D0                         Length of device name.
          MOVE.L    #'CDR0',D1                    Name of device.
          MOVE.W    D0,(A0)+                      | Store the current (usage)
          MOVE.L    D1,(A0)+                      |  device name.
          MOVE.W    D0,(A0)+                      | Store the real device name.
          MOVE.L    D1,(A0)+                      |
          LEA       IOD_OLK(A4),A0                Device driver linkage addr.
          MOVEQ     #$22,D0                       | Link in the new device
          TRAP      #1                            |  driver.
          MOVEQ     #0,D0                         No error.
INITDRV2  RTS                                     Return.

********************************************************************************
* CDROM_UNLINK (PROC), syntax:  CDROM_UNLINK
*
* This procedure unlinks the CDROM thing. Note that the SBASIC extensions are
* _not_ removed by this code.

CDROMUNLK BSR       SEARCH                        Get the THING vector.
          BNE.S     INITDRV2                      If error then return.
          LEA       CDRNAME,A0                    Name of the thing to remove.
          MOVEQ     #$27,D0                       | Remove the CDROM thing.
          JMP       (A4)                          |

********************************************************************************
* This code is called when the CDROM thing is removed.

CDRTHGRMV MOVEA.L   A1,A5                         Save thing linkage block addr.
          LEA       THGDEF(A5),A4                 Base address for thing vars.

* Unlink the device driver:

          LEA       IOD_OLK(A4),A0                Device driver linkage block.
          MOVEQ     #$23,D0                       | Remove the CDR device.
          TRAP      #1                            |

* Free the ATAPI thing:

          BSR       SEARCH                        Get the thing vector.
          BNE.S     CDRTHGRM1                     If error don't free.
          LEA       ATPNAME,A0                    ATAPI thing name.
          MOVEQ     #0,D1                         User is job 0.
          MOVEQ     #$29,D0                       | Free the ATAPI thing.
          JSR       (A4)                          |

* And finally we must return the thing linkage block to the common heap:

CDRTHGRM1 MOVEA.L   A5,A0                         Thing linkage block address.
          MOVEQ     #$19,D0                       | De-allocate this block from
          TRAP      #1                            |  the common heap.
          MOVEQ     #0,D0                         No error.
          RTS                                     Return.

********************************************************************************
* CDR device driver routines:

* Not implemented routines branch here:

CD_ERRNI  MOVEQ     #-19,D0                       "not implemented" error.
          RTS                                     Return.

* No operation...

CD_NOOP   MOVEQ     #0,D0
          RTS

* Bad parameter:

CD_ERRBP  MOVEQ     #-15,D0
          RTS

* Not completed:

CD_ERRNC  MOVEQ     #-1,D0
          RTS

* I/O routine:

CD_IO     TST.W     D0                            D0 < 0 ?
          BMI.S     CD_ERRNI                      Unknown operation !
          CMPI.W    #4,D0                         D0 < 4 ?
          BMI.S     CD_IOBAS                      OK, do it !
          BEQ.S     CD_ERRBP                      We can't do IOB.ELIN !
          CMPI.W    #8,D0                         5 <= D0 < 8 ?
          BMI       CD_ERRRO                      Read only file system !
          CMPI.W    #$40,D0                       8 <= DO < $40 ?
          BMI.S     CD_ERRBP                      This applies to console !
          CMPI.W    #$4F,D0                       D0 > $4F ?
          BGT.S     CD_ERRNI                      Unknown operation !

CD_IOEXT  MOVEM.L   D4/D5/A2/A4/A5,-(SP)          Save context.
          SUBI.W    #$40,D0                       Make D0 an index (0 to $F).
          LEA       IO_TABLE,A5                   Routine pointers table.
CD_IO1    MOVEA.L   DLB_ATAPI(A3),A2              ATAPI thing linkage block add.
          LSL.W     #1,D0                         Turn index into a table offset.
          MOVE.W    0(A5,D0.W),D0                 Get the relative address.
          ADDA.W    D0,A5                         Address of the I/O routine.
          MOVEQ     #-1,D0                        "not complete" error code.
          BTST      #CHN..POST,CHN_FLAGS(A0)      Is the post-processing over ?
          BNE.S     CD_IO2                        If no, return with error.
          BTST      #CHN..PERR,CHN_FLAGS(A0)      Error during post-processing ?
          BNE.S     CD_IO3                        If yes, decode this error.
          JSR       (A5)                          Execute the I/O routine.
CD_IO2    MOVEM.L   (SP)+,D4/D5/A2/A4/A5          Restore context.
          RTS                                     Return.
CD_IO3    MOVEA.L   A0,A4                         Save pointer to channel.
          LEA       CHN_PKT+PKT_DATA(A0),A0       Pointer on sense data.
          JSR       ATP_JDSNS(A2)                 Decode sense data.
          MOVEA.L   A4,A0                         Restore channel header ptr.
          BRA.S     CD_IO2                        Restore context and return.

CD_IOBAS  MOVEM.L   D4/D5/A2/A4/A5,-(SP)          Save context.
          LEA       IOB_TABLE,A5                  Routine pointers table.
          BRA.S     CD_IO1                        Get routine address and do it.

IO_TABLE  dc.w      CD_ERRNI-IO_TABLE             IOF.CHEK
          dc.w      CD_ERRNI-IO_TABLE             IOF.FLSH
          dc.w      IOF_POSA-IO_TABLE             IOF.POSA
          dc.w      IOF_POSR-IO_TABLE             IOF.POSR
          dc.w      CD_ERRNI-IO_TABLE             IOF.MINF
          dc.w      CD_ERRRO-IO_TABLE             IOF.SHDR
          dc.w      CD_ERRNI-IO_TABLE             IOF.RHDR
          dc.w      IOF_LOAD-IO_TABLE             IOF.LOAD
          dc.w      CD_ERRRO-IO_TABLE             IOF.SAVE
          dc.w      CD_ERRRO-IO_TABLE             IOF.RNAM
          dc.w      CD_ERRRO-IO_TABLE             IOF.TRNC
          dc.w      CD_ERRNI-IO_TABLE             IOF.DATE
          dc.w      CD_ERRRO-IO_TABLE             IOF.MKDR
          dc.w      CD_ERRNI-IO_TABLE             IOF.VERS
          dc.w      CD_ERRNI-IO_TABLE             IOF.XINF

IOB_TABLE dc.w      IOB_TEST-IOB_TABLE            IOB.TEST
          dc.w      IOB_FBYT-IOB_TABLE            IOB.FBYT
          dc.w      IOB_FLIN-IOB_TABLE            IOB.FLIN
          dc.w      IOB_FMUL-IOB_TABLE            IOB.FMUL

IOB_FMUL  MOVE.W    CHN_SCTL(A0),D0               Direct sector access in force?
          BEQ.S     IOBFMUL0                      If no, jump over...
          CMPI.W    #2,D2                         Asked for sector length ?
          BNE.S     IOBFMUL0                      No, so jump over...
          LSL.W     #8,D0                         Multiply "density" by 256.
          MOVE.W    D0,(A1)+                      Store sector length.
          MOVEQ     #2,D1                         Two bytes "fetched".
          MOVEQ     #0,D0                         No error.
          RTS                                     Return.

IOBFMUL0  EXT.L     D2                            Extend D2 to a long word.
IOF_LOAD  LEA       CHN_PKT(A0),A4                Our ATAPI packet address.
          EXG       A0,A4                         A0=packet, A4=channel.
          TST.W     D3                            Is it the first call ?
          BMI.S     IOBFMUL1                      No, so check for completion.
          JSR       ATP_JZPKT(A2)                 Clear the packet area.
          MOVE.L    A1,PKT_BUFF(A0)               Address of buffer.
          MOVE.L    D2,PKT_BUFLN(A0)              Store buf len into pkt header.
          MOVE.L    D2,D0                         Copy length into D0.
          LSR.L     #8,D0                         | Turn length into number of
          LSR.L     #3,D0                         |  2048 bytes blocks.
          ADDQ.L    #1,D0                         Round it up.
          LSL.L     #8,D0                         Pad number of blocks.
          MOVE.L    D0,PKT_DATA+6(A0)             Store transfer length.
          MOVE.L    CHN_FPOS(A4),D0               Current position in file.
          ADD.L     CHN_FLID(A4),D0               Add file start block address.
          MOVE.L    D0,D1                         Save it into D1.
          ANDI.L    #2047,D0                      Number of bytes to skip.
          MOVE.L    D0,PKT_SKIP(A0)               Stored into packet header.
          MOVE.B    #$28,PKT_DATA(A0)             Read command.
          LSR.L     #8,D1                         | Turn the FPOS into a 2048 
          LSR.L     #3,D1                         |  bytes block start number.
          MOVE.L    D1,PKT_DATA+2(A0)             Store logical block address.
          MOVE.W    CHN_DRNR(A4),D1               Get device number.
          LSL.W     #2,D1                         Make it a relative pointer.
          LEA       DLB_DTABL(A3),A5              Device table address.
          MOVE.B    0(A5,D1.W),D1                 Get IDE drive number.
          JSR       ATP_JQPKT(A2)                 Queue our packet.
          MOVEQ     #0,D1                         Nothing tranfered yet.
IOBFMUL1  JSR       ATP_JWPCC(A2)                 Check for command completion.
          EXG       A0,A4                         A0=channel, A4=packet.
          BNE.S     IOBFMUL2                      If error, return now.
          MOVE.L    PKT_DDONE(A4),D1              Number of bytes fetched.
          ADD.L     D1,CHN_FPOS(A0)               Update file pointer.
          ADDA.L    D1,A1                         Update pointer to buffer.
IOBFMUL2  RTS                                     Return.

IOB_FBYT  MOVEM.L   D2/A1,-(SP)                   Save context.
          MOVEQ     #1,D2                         One byte required only.
          LEA       CHN_PKT+PKT_DATA+16(A0),A1    Buffer for return.
          BSR       IOF_LOAD                      Get the byte into buffer.
          TST.L     D0                            Error ?
          BNE.S     IOBFBYT1                      If yes, return.
          MOVE.B    CHN_PKT+PKT_DATA+16(A0),D1    Put the fetched byte into D1.
IOBFBYT1  MOVEM.L   (SP)+,D2/A1                   Retore context.
          RTS                                     Return.

IOB_TEST  MOVEQ     #-10,D0                       "end of file" error code.
          MOVE.L    CHN_FPOS(A0),D1               Get current file position.
          CMP.L     CHN_FEOF(A0),D1               Are we at EOF ?
          BPL.S     IOBTEST1                      If yes, then return with err.
          MOVEQ     #0,D0                         No error.
IOBTEST1  RTS                                     Return.

IOB_FLIN  MOVE.L    A1,-(SP)                      Save pointer on buffer.
          BSR       IOBFMUL0                      Fill the buffer with data.
          MOVEA.L   (SP)+,A1                      Restore pointer on buffer.
          TST.L     D0                            Error ?
          BNE.S     IOBFLIN1                      If yes, return.
          MOVE.W    D1,D0                         Copy number of bytes fetched.
          BEQ.S     IOBFLIN2                      If none, return now...
          SUBQ.W    #1,D0                         Make D0 a DBRA counter.
          MOVEQ     #0,D1                         Number of bytes in line.
IOBFLIN3  ADDQ.W    #1,D1                         One more character in line.
          CMPI.B    #10,(A1)+                     End of line ?
          DBEQ      D0,IOBFLIN3                   Do it until found/end of buf.
          TST.L     D0                            All buffer scanned ?
          BMI.S     IOBFLIN2                      If yes, nothing to adjust...
          EXT.L     D0                            Extend to a long word.
          SUB.L     D0,CHN_FPOS(A0)               Adjust file pointer.
IOBFLIN2  MOVEQ     #0,D0                         No error.
IOBFLIN1  RTS                                     Return.

* File pointer positionning TRAPs:

IOF_POSR  ADD.L     CHN_FPOS(A0),D1               Make file position absolute.
IOF_POSA  TST.L     D1                            Is file position negative ?
          BPL.S     IOFPOS1                       If no, then jump over...
          MOVEQ     #0,D1                         New file position.
          BRA.S     IOFPOS2                       Store file position.
IOFPOS1   CMP.L     CHN_FEOF(A0),D1               Compare new position to EOF.
          BMI.S     IOFPOS2                       If smaller, jump over...     
          MOVE.L    CHN_FEOF(A0),D1               Get EOF position.
IOFPOS2   MOVE.L    D1,CHN_FPOS(A0)               Store the new position.
          MOVEQ     #0,D0                         No error.
IOFPOS3   RTS                                     Return.

* One can't write on a CD-ROM...

CD_ERRRO  MOVEQ     #-20,D0                       "write protected" error.
          RTS                                     Return.

* Open routine:
*
* ==> TO DO: - wait for the medium presence.

CD_OPEN   TST.W     D3                            D3<0 (DELETE) ?
          BMI.S     CD_ERRRO                      Yes, report "write protected".
          CMPI.W    #2,D3                         D3=2 (OPEN_NEW) ?
          BEQ.S     CD_ERRRO                      Yes, report "write protected".
          CMPI.W    #3,D3                         D3=2 (OPEN_OVER) ?
          BEQ.S     CD_ERRRO                      Yes, report "write protected".
          CMPI.W    #4,D3                         Is this OPEN_DIR ?
          BEQ       CD_ERRNI                      Not yet implemented...
          MOVEM.L   D1/D2/A2/A4,-(SP)             Save context.
          CLR.L     CHN_LNAME(A0)                 No long name.
          CLR.W     CHN_FLAGS(A0)                 Clear flags and post-proc err.
          MOVE.L    A1,CHN_DDEF(A0)               Store ptr to physical def blk.
          MOVEQ     #-7,D0                        "not found" error code.
          MOVEQ     #0,D2                         Clear MS bytes.
          MOVE.B    FS_DRIVN(A1),D2               Get device number.
          MOVE.W    D2,CHN_DRNR(A0)               Store it in channel def block.
          LSL.W     #2,D2                         Make it a relative pointer.
          LEA       DLB_DTABL(A3),A2              Device table address.
          MOVE.B    0(A2,D2.W),D2                 Get IDE drive number.
          BMI       CD_OPEN1                      If undefined, return with err.
          CLR.W     CHN_SCTL(A0)                  Normal file access.
          CLR.L     CHN_FLID(A0)                  Clear file start block number.
*         CMPI.W    #7,CHN_NAME(A0)               7 characters in filename ?
*         BNE.S     CD_OPEN3                      If no, jump over...
*         MOVE.L    CHN_NAME+2(A0),D1             Get first 4 characters.
*         ANDI.L    #$DFDFDFFF,D1                 Upper case letters.
*         CMPI.L    #'QXL.',D1                    Starts with "QXL." ?
*         BNE       CD_OPEN1                      No, so report error.
*         MOVE.L    CHN_NAME+6(A0),D1             Get last 3 characters.
*         LSR.L     #8,D1                         Ignore padding byte.
*         ANDI.L    #$DFDFDF,D1                   Upper case letters.
*         CMPI.L    #'WIN',D1                     Ends with "WIN" ?
*         BNE       CD_OPEN1                      If no, return with error.
*         MOVE.L    #24*2048,CHN_FLID(A0)         !!!! FAKE !!!!
*         BRA.S     CD_OPEN4                      Continue the open call...
CD_OPEN3  CMPI.W    #4,CHN_NAME(A0)               4 characters in filename ?
          BNE       CD_OPEN1                      No, so report error.
          MOVE.L    CHN_NAME+2(A0),D1             Get filename.
          ANDI.L    #$FFDFDFDF,D1                 Upper-case letters.
          CMPI.L    #'*QWA',D1                    QLWA/QWA CD-R ?
          BEQ.S     CD_OPEN4                      If, yes jump over...
          MOVE.L    CHN_NAME+2(A0),D1             Get "filename".
          ANDI.L    #$FFDFF1DF,D1                 Upper-case and mask digit.
          CMPI.L    #'*D0D',D1                    Is it a direct sector access ?
          BNE       CD_OPEN1                      No, so report error.
          MOVEQ     #-'0',D1                      Code to substract.
          ADD.B     CHN_NAME+4(A0),D1             Add the density digit code.
          EXT.W     D1                            Extend density to a word.
          MOVE.W    D1,CHN_SCTL(A0)               Store the density.    
          SUBQ.B    #6,D1                         Was it 6 ?
          BEQ       CD_OPEN1                      If yes, then return with err.
CD_OPEN4  CLR.L     CHN_FPOS(A0)                  Clear file position.
          MOVE.L    #$2BBFFFFF,CHN_FEOF(A0)       Default end of file (700Mb-1).
          MOVEA.L   A0,A4                         Save channel block address.
          MOVEA.L   DLB_ATAPI(A3),A2              ATAPI thing linkage block add.
          JSR       ATP_JATPK(A2)                 Allocate a transient packet.
          BNE.S     CD_OPEN2                      If error, jump over...
          MOVE.W    D2,D1                         Drive number.
          JSR       ATP_JQPKT(A2)                 Queue the transient packet.
          JSR       ATP_JATPK(A2)                 Allocate a transient packet.
          BNE.S     CD_OPEN2                      If error, jump over...
          MOVE.B    #$1B,PKT_DATA(A0)             ATAPI command (load).
          MOVE.B    #1,PKT_DATA+1(A0)             Cmd param (immediate flag).
          MOVE.B    #3,PKT_DATA+4(A0)             Command parameter (load flag).
          JSR       ATP_JQPKT(A2)                 Queue the transient packet.
          JSR       ATP_JATPK(A2)                 Allocate a transient packet.
          BNE.S     CD_OPEN2                      If error, jump over...
          JSR       ATP_JQPKT(A2)                 Queue the transient packet.
          JSR       ATP_JATPK(A2)                 Allocate a transient packet.
          BNE.S     CD_OPEN2                      If error, jump over...
          MOVE.B    #$1E,PKT_DATA(A0)             ATAPI command (lock).
          MOVE.B    #1,PKT_DATA+4(A0)             Command parameter (lock flag).
          JSR       ATP_JQPKT(A2)                 Queue the transient packet.
CD_OPEN2  LEA       CHN_PKT(A4),A0                Channel packet address.
          JSR       ATP_JZPKT(A2)                 Clear the whole packet block.
          MOVE.B    #$28,PKT_DATA(A0)             ATAPI command (read CD).
          MOVE.B    #1,PKT_DATA+8(A0)             Number of blocks to read.
          LEA       POST_OPEN,A2                  Post processing routine addr.
          MOVE.L    A2,PKT_POSTP(A0)              Store it into packet header.
          BSET      #CHN..POST,CHN_FLAGS(A4)      Set the post-processing flag.
          MOVEA.L   DLB_ATAPI(A3),A2              ATAPI thing linkage block add.
          JSR       ATP_JQPKT(A2)                 Queue the packet.
          MOVEA.L   A4,A0                         Restore channel base address.
          MOVEQ     #0,D0                         No error.
CD_OPEN1  MOVEM.L   (SP)+,D1/D2/A2/A4             Restore context.
          RTS                                     Return.

* This is the first part of the post-processing routine for OPEN call.
* We first check that we could read the first block of the CD-ROM without
* error. If we could not, then we retry until we succeed. If we could, then
* we queue the "READ CD SIZE" ATAPI command with POSTOPEN0 as the post-
* processing routine.

POST_OPEN LEA       -CHN_PKT(A0),A4               A4=channel header pointer.
          BTST      #IDE..ERR,PKT_STATS(A0)       Test error flag.
          BEQ.S     POSTOPEN2                     If no error, then jump over...
          BSET      #CHN..PERR,CHN_FLAGS(A4)      An error occured !
          MOVE.B    PKT_DATA+2(A0),D0             Get sense byte + misc flags.
          ANDI.B    #$0F,D0                       Keep sense key in LS nibble.
          BEQ.S     POSTOPEN4                     If no sense info, retry...
          CMPI.B    #SNS.RESET,D0                 Will drive soon be ready ?
          BEQ.S     POSTOPEN4                     If yes, then retry read...
          SUBQ.B    #SNS.NOTRD,D0                 Is drive not ready ?
          BNE.S     POSTOPEN5                     If no, then don't retry.
          MOVE.W    PKT_DATA+12(A0),D0            Get ASC + ASCQ bytes.
          BEQ.S     POSTOPEN4                     If no sense info, retry...
          CMPI.W    #$0401,D0                     In progress of becoming ready?
          BEQ.S     POSTOPEN4                     If yes, then retry read.
          CMPI.W    #$3A00,D0                     Is medium not present ?
          BEQ.S     POSTOPEN4                     If yes, then retry read.
POSTOPEN5 BCLR      #CHN..POST,CHN_FLAGS(A4)      Post processing is over.
          RTS                                     Return.
POSTOPEN4 BSR.S     NEVERSENT                     Pretend packet never sent.
          MOVE.B    #$28,PKT_DATA(A0)             ATAPI command (read CD).
          MOVE.B    #1,PKT_DATA+8(A0)             Command parameter (size).
          CLR.L     PKT_BUFF(A0)                  Clear return buffer address.
          CLR.L     PKT_BUFLN(A0)                 Clear length of buffer.
          LEA       POST_OPEN,A1                  Post processing routine addr.
          BRA.S     POSTOPEN3                     Store it and return to sched.

POSTOPEN2 BCLR      #CHN..PERR,CHN_FLAGS(A4)      No error occured.
          BSR.S     NEVERSENT                     Pretend packet never sent.
          MOVE.B    #$25,PKT_DATA(A0)             ATAPI command (read CD size).
          LEA       PKT_DATA(A0),A1               Address for data buffer.
          MOVE.L    A1,PKT_BUFF(A0)               Store it into pkt header.
          MOVEQ     #8,D0                         Data buffer length.
          MOVE.L    D0,PKT_BUFLN(A0)              Store it into pkt header.
          LEA       POSTOPEN0,A1                  Post processing routine addr.
POSTOPEN3 MOVE.L    A1,PKT_POSTP(A0)              Store it into packet header.
          ADDQ.L    #4,SP                         Don't return to SCHEDINT.
          RTS                                     Return to the scheduler.

NEVERSENT BCLR      #PKT..SENT,PKT_FLAGS(A0)      | Pretend the packet was never
          BCLR      #PKT..DXCH,PKT_FLAGS(A0)      |  sent.
          CLR.W     PKT_SAVE1(A0)                 |
          CLR.W     PKT_STATS(A0)                 |
          LEA       PKT_DATA(A0),A1               Address of packet data.
          CLR.L     (A1)+                         |
          CLR.L     (A1)+                         | Clear the data.
          CLR.L     (A1)+                         |
          CLR.L     (A1)                          |
          RTS                                     Return.

* This is the second part of the post-open routine. It is executed once we
* ensured that the actual CD-ROM size was read and put at CHN_PKT+PKT_DATA
* offset. The routine calculates the actual size of the CD-ROM and stores the
* result into the channel header as EOF.

POSTOPEN0 LEA       -CHN_PKT(A0),A4               A4=channel header pointer.
          BCLR      #CHN..POST,CHN_FLAGS(A4)      Clear wait post-proc flag.
          BTST      #IDE..ERR,PKT_STATS(A0)       Test error flag.
          BEQ.S     POSTOPEN1                     If no error, then jump over...
          BSET      #CHN..PERR,CHN_FLAGS(A4)      An error occured.
          RTS                                     Return to SCHEDINT.

* Note: the CD-ROM drives should return the net data block size (i.e. CRC bytes
*       excluded), the problem is that some do not... So we assume the block
*       size is 2048 bytes.

POSTOPEN1 MOVE.W    #2048,D0                      CD-R block size in bytes.
*         MOVE.L    PKT_DATA+4(A0),D0             CD-R block size in bytes.
          MOVE.L    PKT_DATA(A0),D2               CD-R size in blocks.
          MOVE.W    D2,D1                         LSW of size in blocks.
          MULU      D0,D1                         Size LSW * block size.
          SWAP      D2                            MSW of size in blocks.
          MULU      D0,D2                         Size MSW * block size.
          LSL.L     #8,D2                         | Multiply by 65536.
          LSL.L     #8,D2                         |
          ADD.L     D2,D1                         Add for 32 bits result...
          SUB.L     CHN_FLID(A4),D1               Substract file start.
          MOVE.L    D1,CHN_FEOF(A4)               Store actual CD-R size.
          BCLR      #CHN..PERR,CHN_FLAGS(A4)      No error occured.
          RTS

* Close routine:
*
* ==> TO DO: Before unlocking the drive door, check that no files are open
*            on other devices linked to this drive.

CD_CLOSE  MOVEM.L   A4/A5,-(SP)                   Save context.
          MOVEA.L   A0,A5                         Save the channel base address.
          LEA       CHN_PKT(A0),A0                Address of ATAPI packet buff.
          MOVEA.L   DLB_ATAPI(A3),A2              ATAPI thing linkage block add.
          MOVEQ     #1,D1                         Forced unqueueing.
          JSR       ATP_JUQPK(A2)                 Unqueue our packet.
          MOVE.L    CHN_LNAME(A5),D0              Is there a long name ?
          BEQ.S     CDCLOSE4                      No, so jump over...
          MOVEA.L   D0,A0                         Base address of long name buf.
          MOVEA.W   $C2,A2                        | Free the common heap space.
          JSR       (A2)                          |
CDCLOSE4  MOVEA.L   CHN_DDEF(A5),A0               Get phys def block address.
          SUBQ.B    #1,FS_FILES(A0)               Decrement files count.
          BNE.S     CDCLOSE5                      If still files open, jump...
          MOVEA.L   DLB_ATAPI(A3),A2              ATAPI thing linkage block add.
          JSR       ATP_JATPK(A2)                 Allocate a transient packet.
          BNE.S     CDCLOSE6                      If error, jump over...
          MOVE.B    #$1E,PKT_DATA(A0)             ATAPI command (unlock).
          MOVE.W    CHN_DRNR(A5),D1               Get drive Id.
          LSL.W     #2,D1                         Make it a relative pointer.
          LEA       DLB_DTABL(A3),A1              Device table address.
          MOVE.B    0(A1,D1.W),D1                 Get IDE drive number.
          JSR       ATP_JQPKT(A2)                 Queue this transient packet.
CDCLOSE6  MOVEA.L   A5,A0                         Restore channel header addr.
CDCLOSE5  LEA       SYS_FSCH(A6),A1               Pointer to linked list start.
          LEA       CHN_LINK(A0),A2               Address of the channel link.
          EXG       A0,A2                         Put it in A0 and save chn add.
          MOVEA.W   $D4,A4                        | Unlink the file from the
          JSR       (A4)                          |  linked list.
          MOVEA.L   A2,A0                         Base channel def. block addr.
          MOVEA.W   $C2,A4                        | Free the common heap space
          JSR       (A4)                          |  from the channel def. blk.
          MOVEM.L   (SP)+,A4/A5                   Restore context.
          MOVEQ     #0,D0                         No error.
          RTS                                     Return.

********************************************************************************
* Extension thing code:

* 'PLAY' : PLAY an audio CD:
*
* Input parameters  :  D1.L = drive number.
*                      D3.L = 1st (MS) byte: starting minute (0-99).
*                             2nd      byte: starting second (0-59).
*                             3rd      byte: ending minute   (0-99).
*                             4th (LS) byte: ending second   (0-59).
*                      A2.L = thing linkage block address.
* Output parameters :  D0.L = error code.
* Modified registers:  D0, A1.

PLAYCD    LEA       PLAYCD1,A1                    Routine for packet data init.
          BRA       COMMONCD                      Branch to common routine.
PLAYCD1   MOVE.B    #$47,PKT_DATA(A0)             ATAPI command.
          MOVE.W    D3,PKT_DATA+6(A0)             Ending M and S bytes.
          MOVE.B    #74,PKT_DATA+8(A0)            Ending F field (74=max value).
          CLR.W     D3                            Clear LS word.
          SWAP      D3                            Put starting M and S in LSW.
          CMPI.W    #2,D3                         Start < 0'02" ?
          BPL.S     PLAYCD2                       If no, jump over...
          MOVE.W    #2,D3                         Start at 0'02"...
PLAYCD2   LSL.L     #8,D3                         Pad data.
          MOVE.L    D3,PKT_DATA+2(A0)             Store starting M, S and F(=0).
          RTS                                     Return.

* 'STOP' : STOP playing an audio CD:
*
* Input parameters  :  D1.L = drive number.
*                      A2.L = thing linkage block address.
* Output parameters :  D0.L = error code.
* Modified registers:  D0, A1.

STOPCD    LEA       STOPCD1,A1                    Routine for packet data init.
          BRA       COMMONCD                      Branch to common routine.
STOPCD1   MOVE.B    #$4E,PKT_DATA(A0)             ATAPI command.
          RTS                                     Return.

* 'PAUS' : PAUSe while playing an audio CD:
*
* Input parameters  :  D1.L = drive number.
*                      A2.L = thing linkage block address.
* Output parameters :  D0.L = error code.
* Modified registers:  D0, A1.

PAUSECD   LEA       PAUSECD1,A1                   Routine for packet data init.
          BRA       COMMONCD                      Branch to common routine.
PAUSECD1  MOVE.B    #$4B,PKT_DATA(A0)             ATAPI command.
          RTS                                     Return.

* 'RESU' : RESUMe playing of an audio CD:
*
* Input parameters  :  D1.L = drive number.
*                      A2.L = thing linkage block address.
* Output parameters :  D0.L = error code.
* Modified registers:  D0, A1.

RESUMECD  LEA       RESUMECD1,A1                  Routine for packet data init.
          BRA.S     COMMONCD                      Branch to common routine.
RESUMECD1 MOVE.B    #$4B,PKT_DATA(A0)             ATAPI command.
          MOVE.B    #1,PKT_DATA+8(A0)             Cmd parameter (resume flag).
          RTS                                     Return.

* 'LOCK' : LOCK drive tray:
*
* Input parameters  :  D1.L = drive number.
*                      A2.L = thing linkage block address.
* Output parameters :  D0.L = error code.
* Modified registers:  D0, A1.

LOCKCD    LEA       LOCKCD1,A1                    Routine for packet data init.
          BRA.S     COMMONCD                      Branch to common routine.
LOCKCD1   MOVE.B    #$1E,PKT_DATA(A0)             ATAPI command.
          MOVE.B    #1,PKT_DATA+4(A0)             Command parameter (lock flag).
          RTS                                     Return.

* 'ULCK' : UnLoCK drive tray:
*
* Input parameters  :  D1.L = drive number.
*                      A2.L = thing linkage block address.
* Output parameters :  D0.L = error code.
* Modified registers:  D0, A1.

ULCKCD    LEA       ULCKCD1,A1                    Routine for packet data init.
          BRA.S     COMMONCD                      Branch to common routine.
ULCKCD1   MOVE.B    #$1E,PKT_DATA(A0)             ATAPI command.
          RTS                                     Return.

* 'LOAD' : LOAD a CD into the drive (close tray).
*
* Input parameters  :  D1.L = drive number.
*                      A2.L = thing linkage block address.
* Output parameters :  D0.L = error code.
* Modified registers:  D0, A1.

LOADCD    LEA       LOADCD1,A1                    Routine for packet data init.
          BRA.S     COMMONCD                      Branch to common routine.
LOADCD1   MOVE.B    #$1B,PKT_DATA(A0)             ATAPI command.
          MOVE.B    #1,PKT_DATA+1(A0)             Cmd param (immediate flag).
          MOVE.B    #3,PKT_DATA+4(A0)             Command parameter (load flag).
          RTS                                     Return.

* 'EJCT' : EJeCT a CD from the drive (open tray).
*
* Input parameters  :  D1.L = drive number.
*                      A2.L = thing linkage block address.
* Output parameters :  D0.L = error code.
* Modified registers:  D0, A1.

EJECTCD   LEA       EJECTCD1,A1                   Routine for packet data init.
          BRA.S     COMMONCD                      Branch to common routine.
EJECTCD1  MOVE.B    #$1B,PKT_DATA(A0)             ATAPI command.
          MOVE.B    #1,PKT_DATA+1(A0)             Cmd param (immediate flag).
          MOVE.B    #2,PKT_DATA+4(A0)             Cmd parameter (unload flag).
          RTS                                     Return.

* 'SPED' : set drive reading an writing SPEeDs (in Kb/s).
*
* Input parameters  :  D1.L = drive number.
*                      D3.L = MSW: reading speed, LSW: writing speed (Kb/s).
*                      A2.L = thing linkage block address.
* Output parameters :  D0.L = error code.
* Modified registers:  D0, A1.

CDSPEED   LEA       CDSPEED1,A1                   Routine for packet data init.
          BRA.S     COMMONCD                      Branch to common routine.
CDSPEED1  MOVE.B    #$BB,PKT_DATA(A0)             ATAPI command.
          MOVE.L    D3,PKT_DATA+2(A0)             Cmd parameters (drive speeds).
          RTS                                     Return.

COMMONCD  MOVEM.L   D1-D5/A2,-(SP)                Save context.
          MOVE.L    D1,D4                         Save drive number.
          MOVEA.L   THGDEF+DLB_ATAPI(A2),A2       ATAPI thing linkage block add.
          JSR       ATP_JIDEN(A2)                 Is this an ATAPI drive ?
          BNE.S     COMMONCD1                     If no, then return with error.
          JSR       ATP_JANPK(A2)                 Allocate a normal packet.
          BNE.S     COMMONCD1                     If error, return now.
          JSR       (A1)                          Fill-in the packet data.
          MOVE.L    A0,D5                         Save our packet address.
          MOVEQ     #0,D0                         | Get SV base.
          TRAP      #1                            |
          MOVE.L    D4,D1                         Restore drive number.
          MOVE.W    SR,D2                         Save 680x0 status register.
          TRAP      #0                            Go supervisor.
          MOVE.L    A6,D4                         Save job base pointer.
          MOVEA.L   A0,A6                         SV base address.
          JSR       ATP_JATPK(A2)                 Allocate a transient packet.
          BNE.S     COMMONCD2                     If error, jump over...
          JSR       ATP_JQPKT(A2)                 Queue our transient packet.
          JSR       ATP_JATPK(A2)                 Allocate a transient packet.
          BNE.S     COMMONCD2                     If error, jump over...
          JSR       ATP_JQPKT(A2)                 Queue our transient packet.
COMMONCD2 MOVEA.L   D4,A6                         Restore job base address.
          MOVE.W    D2,SR                         Go back to user mode.
          MOVEA.L   D5,A0                         Restore our packet address.
          JSR       ATP_JQPKT(A2)                 Queue-in our packet.
          JSR       ATP_JWPCC(A2)                 Wait for command completion.
          MOVE.L    D0,D4                         Save error code.
          MOVEQ     #$19,D0                       | Free the memory.
          TRAP      #1                            |
          MOVE.L    D4,D0                         Restore error code.
COMMONCD1 MOVEM.L   (SP)+,D1-D5/A2                Restore context.
          RTS                                     Return.

* 'INFO' : get INFOrmation about the drive:
*
* Input parameters  :  D1.L = drive number.
*                      A2.L = thing linkage block address.
* Output parameters :  D0.L = error code.
*                      A0.L = Info block address (to release after usage).
* Modified registers:  D0, A0.

DRIVINFO  MOVEM.L   D1-D3/A1-A4,-(SP)             Save context.
          MOVE.W    D1,D3                         Save drive number.
          BSR.S     CHECK4CDR                     Check for a CDROM drive here.
          BNE.S     DRVINFO1                      If error, return now.
          JSR       ATP_JANPK(A2)                 Reserve a packet header.
          BNE.S     DRVINFO1                      If error, return now.
          MOVEA.L   A0,A4                         Save packet address.
          MOVEQ     #100,D1                       100 bytes needed for buffer.
          MOVEQ     #-1,D2                        Owner = current (calling) job.
          MOVEM.L   D1/D3/A1,-(SP)                Save context.
          MOVEQ     #$18,D0                       | Reserve space on the common
          TRAP      #1                            |  heap.
          MOVEM.L   (SP)+,D1/D3/A1                Restore context.
          EXG       A0,A4                         A0=packet addr, A4=buffer add.
          TST.L     D0                            Error ?
          BNE.S     DRVINFO2                      If yes, deallocate and return.
          MOVE.L    A4,PKT_BUFF(A0)               Store buffer addr in header.
          MOVE.L    D1,PKT_BUFLN(A0)              Store buffer length in header.
          MOVE.B    #$12,PKT_DATA(A0)             ATAPI command.
          MOVE.B    D1,PKT_DATA+4(A0)             Cmd parameter (buffer length).
          MOVE.W    D3,D1                         Restore drive number.
          JSR       ATP_JQPKT(A2)                 Queue-in our packet.
          JSR       ATP_JWPCC(A2)                 Wait for command completion.
          MOVE.L    D0,D4                         Save error code.
DRVINFO2  MOVEQ     #$19,D0                       | Free the memory.
          TRAP      #1                            |
          MOVE.L    D4,D0                         Restore error code.
DRVINFO1  MOVEA.L   A4,A0                         A0=buffer address.
          MOVEM.L   (SP)+,D1-D3/A1-A4             Restore context.
          RTS                                     Return.

* Check that the drive is a CD-ROM drive.

CHECK4CDR MOVEA.L   THGDEF+DLB_ATAPI(A2),A1       ATAPI thing linkage block add.
          EXG       A1,A2                         A2=CDROM thing, A1=ATAPI thg.
          JSR       ATP_JIDEN(A2)                 Identify the device.
          MOVEQ     #-16,D0                       "bad medium" error code.
          MOVE.L    D1,D2                         Copy of conf/capability flags.
          SWAP      D2                            Conf word in LSW.
          CMPI.B    #$85,D2                       Is this an ATAPI CD-ROM ?
          BNE.S     CHECKCDR1                     No, so return with error...
          MOVEQ     #0,D0                         No error.
CHECKCDR1 RTS

* 'USE ' : to set the USagE name for the "CDR" device:
*
* Input parameters  :  D1.L = drive name (3 letters, left justified).
*                      A2.L = thing linkage block address.
* Output parameters :  D0.L = error code (always 0).
* Modified registers:  D0, D1.

CDRUSE    ANDI.L    #$DFDFDF00,D1                 Upper case name and zero LSB.
          MOVE.B    #'0',D1                       Put the mandatory "0".
          MOVE.L    D1,IOD_DNUS+2+THGDEF(A2)      Set the new device name
          MOVEQ     #0,D0                         No error.
          RTS                                     Return.

* 'DRIV' : set the DRIVe number and session for a device:
*
* Input parameters  :  D1.L = MSW: device, LSW: drive (MSB)/session (LSB).
*                      A2.L = thing linkage block address.
* Output parameters :  D0.L = error code.
* Modified registers:  D0.
*
* ===> TO DO: check first that no channel is open on this device !

CDRDRIV   MOVEM.L   D1-D3/A0/A1,-(SP)             Save context.
          MOVE.L    D1,D3                         Save parameter.
          LSR.W     #8,D1                         Put drive number in LSB.
          BSR       CHECK4CDR                     Is it an ATAPI CD-ROM drive ?
          EXG       A1,A2                         A2=CDROM thing linkage block.
          BNE.S     CDRDRIV1                      If not an ATAPI CDROM, return.
          MOVE.L    D3,D2                         Parameter working copy.
          TST.W     THGDEF+DLB_DDRIV(A2)          Is there a default drive ?
          BPL.S     CDRDRIV3                      If yes then jump over...
          LSR.W     #8,D2                         Put drive number in LSB.
          MOVE.W    D2,THGDEF+DLB_DDRIV(A2)       Set the default drive.
CDRDRIV3  SWAP      D2                            Device number in LS word.
          LSL.W     #2,D2                         Make device number an index.
          LEA       THGDEF+DLB_DTABL(A2),A0       Device table address.
          MOVE.W    D3,0(A0,D2.W)                 Store drive/session in table.
          MOVEQ     #0,D0                         No error.
CDRDRIV1  MOVEM.L   (SP)+,D1-D3/A0/A1             Restore context.
          RTS                                     Return.

********************************************************************************
* SBASIC PROCedures and FuNctions:

* Sub-routine to get the drive number (0 to 7, 1 is the default): returns
* directly to SBASIC in case of error. If successful, the drive number is
* in D1.L.

GET_DRIVE PEA       EXIT                          Return to SBASIC if error.
          CMPA.L    A3,A5                         Are there parameters ?
          BNE.S     GETDRIVE1                     Yes, so get them...
          MOVEQ     #0,D2                         No extension.
          BSR       USE_CDROM                     Use the "CDROM" thing.
          BNE.S     GETDRIVE3                     If error, return now.
          MOVE.W    THGDEF+DLB_DDRIV(A2),D1       Get the default drive number.
          BSR       FRE_CDROM                     Free the "CDROM" thing.
          BRA.S     GETDRIVE2                     Check the drive number.
GETDRIVE1 MOVEQ     #1,D4                         One parameter awaited.
          BSR       GETWORD                       Get a word integer.
          MOVE.W    0(A6,A1.L),D1                 Get the drive number.
GETDRIVE2 MOVEQ     #-15,D0                       "Bad parameter" error code.
          TST.W     D1                            Is drive number < 0 ?
          BMI.S     GETDRIVE3                     If yes, return with error.
          CMPI.W    #8,D1                         Is it < 8 ?
          BPL.S     GETDRIVE3                     If no, return with error.
          EXT.L     D1                            Extend it on long integer.
          ADDQ.L    #4,SP                         Pop EXIT return address.
GETDRIVE3 RTS                                     Return.

* CD_PLAY (PROC), syntax:
*         CD_PLAY [drive],Start_minute,Start_second,End_minute,End_second

CD_PLAY   MOVEQ     #-15,D0                       "bad parameter" error code.
          MOVEQ     #4*8,D1                       At least 4 parameters awaited.
          ADD.L     A3,D1                         | Check for number of passed
          SUB.L     A5,D1                         |  parameters.
          BGT.S     GETDRIVE3                     If less than 4, error.
          MOVE.L    A5,D7                         Save ptr on last parameter.
          LEA       8(A3),A5                      Pretend 1 param was passed.
          ADDQ.L    #8,D1                         Was there 5 parameters ?
          BEQ.S     CD_PLAY1                      If yes, then jump over...
          BMI.S     GETDRIVE3                     If 6 or more, error...
          MOVEA.L   A3,A5                         Pretend there is no parameter.
CD_PLAY1  BSR.S     GET_DRIVE                     Get the drive number.
          MOVEA.L   D7,A5                         Restore ptr on last parameter.
          LEA       -4*8(A5),A3                   Pointer 4 params before last.
          MOVEQ     #4,D4                         4 parameters awaited.
          BSR       GETWORD                       Get integer parameters.
          MOVEQ     #3,D0                         DBRA counter.
CD_PLAY2  LSL.L     #8,D3                         Make room for a new byte.
          MOVE.B    1(A6,A1.L),D3                 Get a parameter (byte).
          ADDQ.L    #2,A1                         Point on next parameter.
          DBRA      D0,CD_PLAY2                   Get next parameter if any.
          MOVE.L    #'PLAY',D2                    Use 'PLAY' extension.
          BRA       CALL_EXT

* CD_STOP (PROC), syntax: CD_STOP [drive]

CD_STOP   BSR.S     GET_DRIVE                     Get the drive number.
          MOVE.L    #'STOP',D2                    Use 'STOP' extension.
          BRA       CALL_EXT

* CD_LOCK (PROC), syntax: CD_LOCK [drive]

CD_LOCK   BSR       GET_DRIVE                     Get the drive number.
          MOVE.L    #'LOCK',D2                    Use 'LOCK' extension.
          BRA       CALL_EXT

* CD_UNLOCK (PROC), syntax: CD_UNLOCK [drive]

CD_ULCK   BSR       GET_DRIVE                     Get the drive number.
          MOVE.L    #'ULCK',D2                    Use 'ULCK' extension.
          BRA       CALL_EXT

* CD_PAUSE (PROC), syntax: CD_PAUSE [drive]

CD_PAUSE  BSR       GET_DRIVE                     Get the drive number.
          MOVE.L    #'PAUS',D2                    Use 'PAUS' extension.
          BRA       CALL_EXT

* CD_RESUME (PROC), syntax: CD_RESUME [drive]

CD_RESUME BSR       GET_DRIVE                     Get the drive number.
          MOVE.L    #'RESU',D2                    Use 'RESU' extension.
          BRA       CALL_EXT

* CD_LOAD (PROC), syntax: CD_LOAD [drive]

CD_LOAD   BSR       GET_DRIVE                     Get the drive number.
          MOVE.L    #'LOAD',D2                    Use 'LOAD' extension.
          BRA.S     CALL_EXT

* CD_UNLOAD (PROC), syntax: CD_UNLOAD [drive]

CD_EJECT  BSR       GET_DRIVE                     Get the drive number.
          MOVE.L    #'EJCT',D2                    Use 'EJCT' extension.
          BRA.S     CALL_EXT

* CD_SPEED (PROC), syntax: CD_SPEED [drive],Reading_speed,Writing_speed

CD_SPEED  MOVEQ     #-15,D0                       "bad parameter" error code.
          MOVEQ     #2*8,D1                       At least 2 parameters awaited.
          ADD.L     A3,D1                         | Check for number of passed
          SUB.L     A5,D1                         |  parameters.
          BGT.S     CALL_EXT1                     If less than 4, error.
          MOVE.L    A5,D7                         Save ptr on last parameter.
          LEA       8(A3),A5                      Pretend 1 param was passed.
          ADDQ.L    #8,D1                         Was there 3 parameters ?
          BEQ.S     CD_SPEED1                     If yes, then jump over...
          BMI.S     CALL_EXT1                     If 4 or more, error...
          MOVEA.L   A3,A5                         Pretend there is no parameter.
CD_SPEED1 BSR       GET_DRIVE                     Get the drive number.
          MOVEA.L   D7,A5                         Restore ptr on last parameter.
          LEA       -2*8(A5),A3                   Pointer 2 params before last.
          MOVEQ     #2,D4                         2 parameters awaited.
          BSR       GETWORD                       Get integer parameters.
          MOVE.W    0(A6,A1.L),D3                 Get reading speed factor.
          BMI.S     CD_SPEED2                     If negative, jump over...
          MULU      #150,D3                       Multiply by 150 Kb/s (x1).
          BRA.S     CD_SPEED3                     Get writing speed...
CD_SPEED2 MOVEQ     #-1,D3                        Maximum reading speed.
CD_SPEED3 SWAP      D3                            Save READING speed in MS word.
          MOVE.W    2(A6,A1.L),D0                 Get writing speed factor.
          BMI.S     CD_SPEED4                     If negative, jump over...
          MULU      #150,D0                       Multiply by 150 Kb/s (x1).
          BRA.S     CD_SPEED5                     Get writing speed...
CD_SPEED4 MOVEQ     #-1,D0                        Maximum writing speed.
CD_SPEED5 MOVE.W    D0,D3                         Store writing speed.
          MOVE.L    #'SPED',D2                    Use 'PLAY' extension.
          BRA.S     CALL_EXT

* Sub-routine to use the "CDROM" thing:

USE_CDROM BSR       SEARCH                        Get the THING vector.
          BNE.S     CALL_EXT1                     If error then return.
          MOVEM.L   D1/D3,-(SP)                   Save context.
          LEA       CDRNAME,A0                    Name of the thing to use.
          MOVEQ     #-1,D1                        User = calling job.
          MOVEQ     #-1,D3                        Infinite timeout.
          MOVEQ     #$28,D0                       | Use the CDROM thing.
          JSR       (A4)                          |
          MOVEM.L   (SP)+,D1/D3                   Restore context.
          TST.L     D0                            Set CCR according to error.
          RTS                                     Return.
          
* Common end routine used to call the CDROM extension thing:
*
* Input parameters  :  D1.L = parameter.
*                      D2.L = extension Id.
*                      D3.L = parameter.
* Output parameters :  D0.L = error code.

CALL_EXT  BSR.S     USE_CDROM                     Use the "CDROM" thing.
          BNE.S     CALL_EXT1                     If error then return.
          JSR       $18(A1)                       Call the extension thing.

FRE_CDROM MOVEM.L   D0/D1/A0/A1,-(SP)             Save context.
          LEA       CDRNAME,A0                    Name of the thing to free.
          MOVEQ     #-1,D1                        User = calling job.
          MOVEQ     #$29,D0                       | Free the CCDROM thing.
          JSR       (A4)                          |
          MOVEM.L   (SP)+,D0/D1/A0/A1             Restore context.
CALL_EXT1 RTS

* CDR_USE (PROC), syntax: CDR_USE device_name$
*
* ===> TO DO: - check that device name only contains letters.
*             - make this procedure to accept a name as parameter.

CDR_USE   BSR       GETNAME                       Get a string or name.
          CMPI.W    #3,0(A6,A1.L)                 Is the string 3 chars long ?
          BNE       BADPAR                        If no, return with error.
          MOVE.L    2(A6,A1.L),D1                 New name for the device.
          MOVE.L    #'USE ',D2                    Extension name.
          BRA.S     CALL_EXT                      Call the extension thing.

* CDR_DRIVE (PROC), syntax: CDR_DRIVE device,drive,session

CDR_DRIV  MOVEQ     #3,D4                         Three parameters awaited.
          BSR       GETWORD                       Get word integers.
          MOVEQ     #-15,D0                       "bad parameter" error code.
          MOVE.W    0(A6,A1.L),D1                 Device number.
          BLE.S     CALL_EXT1                     If <= 0, return with error.
          CMPI.W    #8,D1                         Is it > 8 ?
          BGT.S     CALL_EXT1                     If yes, return with error.
          SWAP      D1                            Save device number in MS word.
          MOVE.W    2(A6,A1.L),D1                 Get drive number.
          BMI.S     CALL_EXT1                     If < 0, return with error.
          CMPI.W    #7,D1                         Is it > 7 ?
          BGT.S     CALL_EXT1                     If yes, return with error.
          MOVE.W    4(A6,A1.L),D2                 Get session number.
          BMI.S     CALL_EXT1                     If < 0, return with error.
          CMPI.W    #99,D2                        Is it > 99 ?
          BGT.S     CALL_EXT1                     If yes, return with error.
          LSL.W     #8,D1                         Make room for session in LSB.
          MOVE.B    D2,D1                         Store session number.
          MOVE.L    #'DRIV',D2                    Extension name.
          BRA       CALL_EXT                      Call the extension thing.

* CDR_INFO$ (FN), syntax: DriveName$=CDR_INFO$(device)

CDR_INFO  MOVEA.L   $58(A6),A1                    Get arithmetic stack pointer.
          BSR       GET_DRIVE                     Get the drive number.
          ADDQ.L    #2,A1                         Update arithmetic stack ptr.
          MOVE.L    A1,$58(A6)                    And save it.
          MOVE.L    #'INFO',D2                    Extension name.
          BSR       CALL_EXT                      Call the extension thing.
          TST.L     D0                            Error ?
          BNE.S     CDRINFO1                      If error, return now.
          MOVEQ     #-16,D0                       "bad medium" error code.
          CMPI.B    #5,(A0)                       Is the drive a CD-ROM ?
          BNE.S     CDRINFO2                      No, dealloc & return with err.
          MOVEQ     #29,D1                        | Reserve 29 bytes on the
          BSR       MSRESV0                       |  arithmetic stack.
          MOVEQ     #27,D1                        Number of characters.
          MOVE.W    D1,0(A6,A1.L)                 Store the string length.
          SUBQ.W    #1,D1                         Make D1 a DBRA counter.
          MOVEA.L   A1,A2                         Copy of arithmetic stack ptr.
          LEA       8(A0),A4                      Abs. buffer ptr. to 1st char.
CDRINFO3  MOVE.B    (A4)+,2(A6,A2.L)              Copy a character into stack.
          ADDQ.L    #1,A2                         Increment relative pointer.
          DBRA      D1,CDRINFO3                   Copy the whole string.
          MOVEQ     #1,D4                         Key for string ret. parameter.
          MOVEQ     #0,D0                         No error.
CDRINFO2  MOVEM.L   D0-D3/A0-A3,-(SP)             Save context.
          MOVEQ     #$19,D0                       | Deallocate the buffer
          TRAP      #1                            |  holding the drive info.
          MOVEM.L   (SP)+,D0-D3/A0-A3             Restore context.
CDRINFO1  RTS                                     Return.

********************************************************************************
* General usage routines:

* Name or string parameter extraction routine:
*
* Input parameters  :  A3.L = pointer (relative to A6) on parameter list start.
*                      A6.L = S*BASIC base pointer.
* Output parameters :  D0.L = error code.
*                      A1.L = pointer (relative to A6) on the QDOS string into
*                             arithemtic stack ($58(A6) points at the end of
*                             the string).
*                      A3.L = updated pointer (relative to A6) on the parameter
*                             list.
* Modified registers:  D0, A1, A3.

GETNAME   MOVEM.L   D1-D3/A0/A2/A5,-(SP)          Save the context.
          MOVEQ     #$F,D0                        Parameter type mask.
          AND.B     1(A6,A3.L),D0                 Mask the parameter type.
          SUBQ.B    #1,D0                         Parameter type = string ?
          BNE.S     GETNAME1                      If no, then jump over...
          LEA       8(A3),A5                      Extract only one parameter.
          MOVEA.W   $116,A2                       | Get a string parameter.
          JSR       (A2)                          |
          BNE.S     GETNAME4                      If error, return now.
          MOVEQ     #3,D1                         | Calculate the room taken
          ADD.W     0(A6,A1.L),D1                 |  by this string into the
          BCLR      #0,D1                         |  arithmetic stack.
          ADD.L     D1,$58(A6)                    Update arithmetic stack ptr.
          BRA.S     GETNAME3                      Return without error.
GETNAME1  MOVEQ     #-15,D0                       "bad parameter" error code.
          MOVEQ     #0,D1                         Clear MS word.
          MOVE.W    2(A6,A3.L),D1                 Get param pos in name table.
          BMI.S     GETNAME4                      If negative, error.
          LSL.L     #3,D1                         Rel ptr on addr in name table.
          ADD.L     $18(A6),D1                    Add start table address to it.
          MOVEA.W   2(A6,D1.L),A2                 Rel ptr on start of name list.
          ADDA.L    $20(A6),A2                    Add addr of name list start.
          MOVEQ     #0,D1                         Clear MS bytes.
          MOVE.B    0(A6,A2.L),D1                 Length of the name.
          ADDQ.L    #2,D1                         Take length word into account.
          PEA       GETNAME4                      For a direct return if error.
          BSR       MSRESV2                       Reserve space of arith. stack.
          ADDQ.L    #4,SP                         Unstack error return address.
          MOVEA.L   $58(A6),A1                    New arithmetic stack address.
          ADDA.L    D1,A2                         Point on last name character.
          SUBQ.L    #1,A1                         Point on last char pos in stk.
GETNAME2  MOVE.B    0(A6,A2.L),0(A6,A1.L)         Copy a character into stack.
          SUBQ.L    #1,A2                         | One charcater copied, point
          SUBQ.L    #1,A1                         |  onto the previous one.
          DBRA      D1,GETNAME2                   Copy all string characters.
          CLR.B     0(A6,A1.L)                    Clear MSB of length word.
GETNAME3  MOVEQ     #0,D0                         No error.
          MOVEM.L   (SP)+,D1-D3/A0/A2/A5          Restore context.
          ADDQ.L    #8,A3                         One parameter processed.
          RTS                                     Return.
GETNAME4  MOVEM.L   (SP)+,D1-D3/A0/A2/A5          Restore context.

EXIT      ADDQ.L    #4,SP                         Pop the return address.
          RTS                                     Return to caller of caller...

BADPAR    MOVEQ     #-15,D0                       "bad parameter" error code.
          RTS                                     Return.

* Parameter fetching routines:
*
* Put the number of awaited parameters in D4.W (or 0 if number unknown) and call
* the appropriate routine. In case of error, these routine will return to the
* caller of the caller which is supposed to be SBASIC; if these routine are to
* be called from a SUBROUTINE of a PROC/FN, then call them as follow:
*
*         PEA       EXIT
*         BSR.S     GET....
*         ADDQ.L    #4,SP
*
* No test is needed after a call to these routines (the parameters are OK and in
* good number), unless D4 was set to 0 (in which case a check for the number of
* fetched parameters is needed).

GETWORD   MOVEA.W   $112,A2
          BRA.S     GETPAR
GETSTRG   MOVEA.W   $116,A2
          BRA.S     GETPAR
GETLONG   MOVEA.W   $118,A2
GETPAR    MOVEM.L   D1/D2/D4/D6/A0,-(SP)
          JSR       (A2)
          MOVEM.L   (SP)+,D1/D2/D4/D6/A0
          BNE.S     EXIT
          TST.W     D4
          BEQ.S     GETPAR1
          MOVEQ     #-15,D0
          CMP.W     D3,D4
          BNE.S     EXIT
          MOVEQ     #0,D0
GETPAR1   RTS

* The following routine converts a long integer held into D4 into a floating
* point number which is put onto the arithmetic stack.

LITOFP    MOVE.L    D4,D1
          SUBQ.L    #6,A1
          CLR.W     0(A6,A1.L)
          TST.L     D1
          BEQ.S     LITOFP2
          MOVE.W    #$820,D2
LITOFP1   SUBQ.W    #1,D2
          ASL.L     #1,D1
          BVC.S     LITOFP1
          ROXR.L    #1,D1
          MOVE.W    D2,0(A6,A1.L)
LITOFP2   MOVE.L    D1,2(A6,A1.L)
LITOFP3   MOVEQ     #2,D4
LITOFP4   MOVE.L    A1,$58(A6)
          MOVEQ     #0,D0
          RTS

* Arithmetic stack space reservation routine.

MSRESV0   MOVEA.L   $58(A6),A1
          BRA.S     MSRESV2
MSRESV1   MOVEQ     #6,D1
MSRESV    MOVE.L    A1,$58(A6)
MSRESV2   ADDQ.L    #1,D1
          BCLR      #0,D1
          MOVEM.L   D1-D3/A2,-(SP)
          MOVEA.W   $11A,A2
          JSR       (A2)
          MOVEM.L   (SP)+,D1-D3/A2
          MOVEA.L   $58(A6),A1
          SUBA.L    D1,A1
          MOVE.L    A1,$58(A6)
          RTS

* Routine searching for the "THING" vector:
*
* Call parameters   : none.
* ~~~~~~~~~~~~~~~
* Return parameters : A0.L = "THING" thing address (if D0=0)
* ~~~~~~~~~~~~~~~~~   A4.L = "TH_ENTRY" routine address
*                     D0.L = error code (0: no error, -19: not implemented),
*
* Modified registers: D0, A0, A4.
* ~~~~~~~~~~~~~~~~~~

SEARCH    MOVEM.L   D1/D2,-(SP)                   Save the context.
          MOVEQ     #0,D0                         | Get system info (we need
          TRAP      #1                            |  the system variable addr.).
          MOVEQ     #-19,D0                       "Not implemented" error code.
          LEA       $B8(A0),A0                    Things linked list pointer.
          MOVE.L    A0,D1                         Is it zero ?
          BEQ.S     SEARCH3                       If yes, return (no things).
SEARCH1   MOVE.L    (A0),D1                       D1=Thing linkage block addr.
          BEQ.S     SEARCH2                       If last thing then end.
          MOVEA.L   D1,A0                         | Else search for the next
          BRA.S     SEARCH1                       |  thing.
SEARCH2   MOVEA.L   16(A0),A0                     Pointer on the thing header.
          CMPI.L    #'THG%',(A0)                  Is it actually a thing ?
          BNE.S     SEARCH3                       If no then return with error.
          CMPI.L    #-1,4(A0)                     Is it the "THING" thing ?
          BNE.S     SEARCH3                       If no then return with error.
          MOVEA.L   8(A0),A4                      Get the TH_ENTRY vector.
          MOVEQ     #0,D0                         No error.
SEARCH3   MOVEM.L   (SP)+,D1/D2                   Restore the context.
          TST.L     D0                            Set the CCR.
          RTS                                     Return.

********************************************************************************
* Data:

* PROCedures and FuNctions definition table:

PROC_FN   dc.w      16
          dc.w      CDROMLINK-*
          dc.b      10,'CDROM_LINK',0
          dc.w      CDROMUNLK-*
          dc.b      12,'CDROM_UNLINK',0
          dc.w      CD_PLAY-*
          dc.b      7,'CD_PLAY'
          dc.w      CD_STOP-*
          dc.b      7,'CD_STOP'
          dc.w      CD_PAUSE-*
          dc.b      8,'CD_PAUSE',0
          dc.w      CD_RESUME-*
          dc.b      9,'CD_RESUME'
          dc.w      CD_LOCK-*
          dc.b      7,'CD_LOCK'
          dc.w      CD_ULCK-*
          dc.b      9,'CD_UNLOCK'
          dc.w      CD_LOAD-*
          dc.b      7,'CD_LOAD'
          dc.w      CD_EJECT-* 
          dc.b      8,'CD_EJECT',0
          dc.w      CD_SPEED-* 
          dc.b      8,'CD_SPEED',0
          dc.w      CDR_USE-*
          dc.b      7,'CDR_USE'
          dc.w      CDR_DRIV-*
          dc.b      9,'CDR_DRIVE'
          dc.w      0
          dc.w      2
          dc.w      CDR_INFO-*
          dc.b      9,'CDR_INFO$'
          dc.w      0

* Copyright message:

COPYRIGHT dc.w      COPYREND-*-1
          dc.b      'CD-ROM device driver v'
          dc.l      VERSION
          dc.b      ' (c) 2001 Thierry GODEFROY.'
COPYREND  dc.b      10
          dc.w      0

* Thing names:

CDRNAME   dc.w      5
          dc.b      'CDROM',0

ATPNAME   dc.w      5
          dc.b      'ATAPI',0

* Thing header:

CDROM_THG
CDR_THG4  dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      CDR_THG5-CDR_THG4             Pointer to next extension.
          dc.b      'LOCK'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       LOCKCD                        Jump to actual extension code.
CDR_THG5  dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      CDR_THG6-CDR_THG5             Pointer to next extension.
          dc.b      'ULCK'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       ULCKCD                        Jump to actual extension code.
CDR_THG6  dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      CDR_THG7-CDR_THG6             Pointer to next extension.
          dc.b      'PLAY'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       PLAYCD                        Jump to actual extension code.
CDR_THG7  dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      CDR_THG8-CDR_THG7             Pointer to next extension.
          dc.b      'STOP'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       STOPCD                        Jump to actual extension code.
CDR_THG8  dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      CDR_THG9-CDR_THG8             Pointer to next extension.
          dc.b      'PAUS'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       PAUSECD                       Jump to actual extension code.
CDR_THG9  dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      CDR_THG10-CDR_THG9            Pointer to next extension.
          dc.b      'RESU'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       RESUMECD                      Jump to actual extension code.
CDR_THG10 dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      CDR_THG11-CDR_THG10           Pointer to next extension.
          dc.b      'LOAD'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       LOADCD                        Jump to actual extension code.
CDR_THG11 dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      CDR_THG12-CDR_THG11           Pointer to next extension.
          dc.b      'EJCT'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       EJECTCD                       Jump to actual extension code.
CDR_THG12 dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      CDR_THG13-CDR_THG12           Pointer to next extension.
          dc.b      'SPED'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       CDSPEED                       Jump to actual extension code.
CDR_THG13 dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      CDR_THG14-CDR_THG13           Pointer to next extension.
          dc.b      'INFO'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       DRIVINFO                      Jump to actual extension code.
CDR_THG14 dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      CDR_THG15-CDR_THG14           Pointer to next extension.
          dc.b      'USE '                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       CDRUSE                        Jump to actual extension code.
CDR_THG15 dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      0                             No more extension.
          dc.b      'DRIV'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       CDRDRIV                       Jump to actual extension code.

          end
