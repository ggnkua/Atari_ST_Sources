**************************************************************************
*                                                                        *
*                              RAMDISK+                                  *
*                                                                        *
* Little non-volatile ram disk program for the Atari ST.                 *
*                                                                        *
*                                            ½ Metacomco plc August 1988 *
**************************************************************************
*
            INCLUDE    'osbind.i'
            INCLUDE    'error.i'
*
* Various constants (change strings at end of program if defaults changed)
*
defaultRDsize  EQU     62*1024             Default Ram Disk size (Kbytes)
defaultRDdrive EQU     3                   Default Ram Disk drive ('D')
minimumleft    EQU     128*1024            Must leave at least 128K
*

***************************************************************************
            TEXT
***************************************************************************
*
* Entry point to ram disk driver program for pass1 (after auto executed) &
* for pass2 (after RESET from pass1 below). Decide which pass to perform.
* Note that manually reseting the machine after the Ram Disk has been 
* installed should result in pass2 being performed.
*
start    
            MOVE.L     #0,-(SP)            Set super stack to user stack
            MOVE.W     #super,-(SP)        And enter supervisor mode
            TRAP       #1
            ADDQ.L     #6,SP
            MOVE.L     d0,oldsuper         Save old supervisor stack ptr
*
            MOVEA.L    #_memtop,A4         Get address of _memtop variable
            MOVEA.L    #phystop,A5         Get address of phystop variable
            MOVEA.L    (A5),A1             Get address of top of physical RAM
            CMPI.L     #$02000002,(A1)     Have we been here before ?
            BEQ        pass2               Branch if yes
*
***************************************************************************
*                          PASS1
***************************************************************************
* The following code is only executed on the first pass. We get here when a
* new Ram Disk is to be installed. Get size and drive from the filename or,
* if this is not found, use the defaults.
*
pass1       
            MOVE.W     #A_READWRITE,-(SP)
            PEA.L      myfilename          Get pattern for this filename
            MOVE.W     #fsfirst,-(SP)      Search Auto folder for this file
            TRAP       #1
            ADDQ.L     #8,SP
            TST.W      D0                  Was it found ?
            BNE.S      2$                  Branch if pattern not found
*
            MOVE.W     #fgetdta,-(SP)      Get the DTA set up by fsfirst
            TRAP       #1
            ADDQ.L     #2,SP
*
            MOVE.L     D0,A0               Get DTA into A0
            LEA.L      dta_filename(A0),A0 Get filename into A0
            LEA.L      3(A0),A0            Skip 'RAM' to size characters
            LEA.L      sizestring,A2       Get address of buffer to save size
            MOVEQ.L    #3,D0               Four size chars (minus 1 for DBRA) 
            MOVEQ.L    #0,D1               Clear D1
            MOVE.L     D1,D2               And D2
1$
            MOVE.B     (A0)+,D1            Get character digit
            MOVE.B     D1,(A2)+            Save character
            SUBI.L     #'0',D1             Convert to number
            MOVE.L     D2,D3               Note : 10x = (x << 3) + (x << 1)
            LSL.L      #3,D3
            LSL.L      #1,D2
            ADD.L      D3,D2               Accumulator = accumulator * 10
            ADD.L      D1,D2               Accumulator = accumulator + n
            DBRA       D0,1$               Branch for next position
*
            LSL.L      #8,D2               Convert requested size to Kbytes
            LSL.L      #2,D2
            MOVE.L     D2,RDsize           Set requested Ram Disk size
*
            MOVEQ.L    #0,D0
            MOVE.B     (A0),D0             Get requested Ram Disk drive
            LEA.L      drivestring,A2
            MOVE.B     D0,(A2)             Save character in string
            SUBI.B     #'A',D0             Convert character to digit
            MOVE.W     D0,RDdrive          Save requested Ram Disk drive
2$
            MOVE.L     RDsize,D2           Get Ram Disk size (in bytes)
            MOVE.L     D2,D1               Into D1
            LSR.L      #8,D1  
            LSR.L      #2,D1               Convert to Kbytes
            SUBI.L     #$A,D1              Less 10K for hdv, boot, FATs etc
            LEA.L      RDbpb,A2            Get ramdisk's BPB
            MOVE.W     D1,bpb_numcl(A2)    Set number of data clusters    
            MOVE.L     D2,D1               RamDisk byte size to D1
            ADD.L      _membot,D1          Add bottom of memory
            ADDI.L     #minimumleft,D1     Add minimum amount to be left
            CMP.L      (A4),D1             Is amount left > minimum ?
            BLT.S      mem_ok              Branch if yes
*
            LEA.L      nospace,A1          Not enough space left
            BSR        write               Tell user
            BSR        wait                Await response
            BRA        exit                Exit
mem_ok
            SUB.L      D2,(A4)             Lower _memtop by RamDisk size
            SUB.L      D2,(A5)             Lower phystop by RamDisk size
*
            MOVE.L     hdv_bpb,HDgetbpb    Save original hard disk
            MOVE.L     hdv_rw,HDrwabs      routines in the save area 
            MOVE.L     hdv_mediach,HDmediach
*
* All that remains to be done before resetting the machine is to copy the
* data and code which will remain resident into the area just allocated.
*
            LEA.L      RDbpb,A0            Get start of data and code
            MOVEA.L    (A5),A1             Get (modified) phystop
            MOVE.L     #((write-RDbpb)>>2),D7 Get size of data and code
1$
            MOVE.L     (A0)+,(A1)+
            DBRA       D7,1$               Copy resident bit above phystop
*
            LEA.L      intro,A1            Tell user that new Ram Disk
            BSR        write               has been installed
            LEA.L      drivestring,A1      Get drive string
            BSR        write
            LEA.L      sizeis,A1           Output the size of the Ram Disk
            BSR        write
            LEA.L      sizestring,A1       Get size as character string
            BSR        write
*
            BSR        wait                Wait for a character
*
            MOVEA.L    $4,A0
            JMP        (A0)                Reset the machine
*
***************************************************************************
*                          PASS2
***************************************************************************
* The following code is only executed on the second pass. By the time we
* get here, the area above phystop has been set up and all that remains to
* be done is to reset the system variables with my addresses and values.
*
pass2
            MOVE.L     (A5),A0             Get phystop (= RamDisk BPB)
            MOVE.L     A0,D1
            ADDI.L     #(RDgetbpb-RDbpb),D1  
            MOVE.L     D1,hdv_bpb          Update with RD getbpb routine
            MOVE.L     A0,D1
            ADDI.L     #(RDrwabs-RDbpb),D1
            MOVE.L     D1,hdv_rw           Update with RD rwabs routine
            MOVE.L     A0,D1
            ADDI.L     #(RDmediach-RDbpb),D1
            MOVE.L     D1,hdv_mediach      Update with RD mediach routine
*
            MOVE.L     _drvbits,D2         Get current system drive map
            MOVEQ.L    #0,D1               Clear (top half of) D1
            MOVE.W     (RDdrive-RDbpb)(A0),D1
            BSET.B     D1,D2               Set the bit for the Ram Disk
            MOVE.L     D2,_drvbits         Set the new system drive map
exit
            MOVE.L     oldsuper,-(SP)      Restore original super stack
            MOVE.W     #super,-(SP)        and return to user mode
            TRAP       #1
            ADDQ.L     #6,SP
*
            MOVE.W     #0,-(A7)            Zero return code
            MOVE.W     #pterm,-(A7)        Term
            TRAP       #1                  Don't return
*
            CNOP       0,4                 Ensure rest is longword aligned
*
*************************************************************************
* The following data and code will be copied above the new phystop. Note
* that all data accesses from the code must now be PC (or phystop) 
* relative as it is the copied data that we are referencing. Note also
* that the first longword below ($02000002) is used above (in start)
*************************************************************************
*
RDbpb                                      ; Ram disk's Bios Paramter Block
            DC.W       512                 Physical sector size in bytes   
            DC.W       2                   Cluster size in sectors
            DC.W       1024                Cluster size in bytes    
            DC.W       7                   Root directory length in sectors
            DC.W       5                   FAT size in sectors
            DC.W       6                   Sector# of 1st sector of 2nd FAT
            DC.W       18                  Sector# of 1st data sector
            DC.W       0                   No of data clusters (filled above) 
            DC.W       1                   Flags (16-bit FAT entries)
*
HDgetbpb    DC.L       0                   Hard disk getbpb routine save area
HDrwabs     DC.L       0                   Hard disk rwabs routine save area
HDmediach   DC.L       0                   Hard disk mediach routine save area
RDsize      DC.L       defaultRDsize       Ram disk size might be set above
RDdrive     DC.W       defaultRDdrive      Ram disk drive might be set above
RDstatus    DC.W       0                   Updated after first mediach call
*
*************************************************************************
*                          GETBPB
*************************************************************************
* Routine to perform getbpb for the ram disk
*               getbpb( dev : word )
*
RDgetbpb        
            MOVE.W     RDdrive(PC),D0      Get Ram Disk drive number
            CMP.W      4(A7),D0            Get ram's bpb ?
            BNE.S      1$                  Branch if no
*
            MOVE.L     phystop,D0          Return new location of RDbpb
            RTS
1$
            MOVE.W     4(A7),-(A7)         Otherwise call original rtn
            MOVE.L     HDgetbpb(PC),A0     With dev id passed
            JSR        (A0)
            ADDQ.L     #2,A7               Restore the stack
            RTS
*
***************************************************************************
*                          RWABS
***************************************************************************
* Routine to perform rwabs for the ram disk
*   rwabs( rwflag : word; buf : long; count, secno, dev : word )
* A6 offsets 8             10           14     16    18
*
RDrwabs
            LINK       A6,#0               Use A6 for parameter access
            MOVEM.L    D1-D7/A0-A5,-(A7)   Save registers
            MOVE.W     RDdrive(PC),D0      Get Ram Disk drive number
            CMP.W      18(A6),D0           rwabs for ram disk ?
            BNE.S      notRD               Branch if not
* 
            LEA.L      RDbpb(PC),A0        Get new location of RDbpb 
            ADDA.L     #$200,A0            Get address of RD buffer
            MOVEA.L    10(A6),A1           Get buffer parameter
            MOVEQ.L    #0,D1
            MOVE.W     16(A6),D1           Get secno parameter
            LSL.L      #8,D1
            LSL.L      #1,D1               Convert to byte offset
            ADDA.L     D1,A0               Form address of required sector
*
            MOVEQ.L    #0,D0               Clear (top half of) D0        
            MOVE.W     14(A6),D0           Get count parameter into D0
*
            MOVE.L     A1,D2               Save passed buffer in D2
            BTST       #0,9(A6)            Is rwflag odd (=> write)         
            BNE.S      1$                  Branch if not (=> read)
*
            EXG        A0,A1               Exchange buffers if writing
1$
            BTST       #0,D2               Is passed buffer word aligned ?
            BNE.S      odd_byte            Branch if not
even_byte
            MOVE.W     #$F,D1              Want to move D0 (512 byte) sectors
*                                          (512 bytes = 16 * 8 longs)
1$
            MOVE.L     (A1)+,(A0)+         Having eight long moves here is
            MOVE.L     (A1)+,(A0)+         more efficient than having just
            MOVE.L     (A1)+,(A0)+         one move repeated byte move.
            MOVE.L     (A1)+,(A0)+
            MOVE.L     (A1)+,(A0)+
            MOVE.L     (A1)+,(A0)+
            MOVE.L     (A1)+,(A0)+
            MOVE.L     (A1)+,(A0)+
            DBRA       D1,1$
*
            SUBQ.L     #1,D0               One less 512 byte sector to copy
            BNE.S      even_byte           Branch if any more
            BRA.S      out                 Otherwise return
odd_byte
            MOVE.W     #$3F,D1             Want to move D0 (512 byte) sectors
*                                          (512 bytes = 64 * 8 bytes)
1$
            MOVE.B     (A1)+,(A0)+         Having eight byte moves here is
            MOVE.B     (A1)+,(A0)+         more efficient than having just
            MOVE.B     (A1)+,(A0)+         one repeated byte move.
            MOVE.B     (A1)+,(A0)+
            MOVE.B     (A1)+,(A0)+
            MOVE.B     (A1)+,(A0)+
            MOVE.B     (A1)+,(A0)+
            MOVE.B     (A1)+,(A0)+
            DBRA       D1,1$
*
            SUBQ.L     #1,D0               One less 512 byte sector to copy
            BNE.S      odd_byte            Branch if any more
            BRA.S      out                 Otherwise return
notRD
            MOVE.W     18(A6),-(A7)        Not for ram disk so copy all
            MOVE.W     16(A6),-(A7)        of the parameters back
            MOVE.W     14(A6),-(A7)        onto the stack
            MOVE.L     10(A6),-(A7)        
            MOVE.W     8(A6),-(A7)
            MOVE.L     HDrwabs(PC),A0      Call original routine
            JSR        (A0)
            LEA.L      12(A7),A7           Restore the stack
out
            MOVEM.L    (A7)+,D1-D7/A0-A5   Restore registers
            UNLK       A6
            RTS
*
***************************************************************************
*                          MEDIACH
***************************************************************************
* Routine to perform mediach for the ram disk
*               mediach( dev : word )
* The philosophy is to return 'has changed' on the first request and 'has
* not changed' on subsequent requests.
*
RDmediach       
            MOVE.W     RDdrive(PC),D0      Get Ram Disk drive number
            CMP.W      4(A7),D0            Mediach for ram disk ?
            BNE.S      2$                  Branch if not
*
            LEA.L      RDstatus(PC),A0     Get address of RDstatus
            TST.W      (A0)                Have we been here before
            BNE.S      1$                  Branch if so
*
            MOVE.W     #1,(A0)             Remember that we've been here
            MOVE.L     #MEDIA_HASCHANGED,D0
            RTS
1$
            MOVE.L     #MEDIA_NOTCHANGED,D0
            RTS
2$
            MOVE.W     4(A7),-(A7)         Not for ram disk so call
            MOVE.L     HDmediach(PC),A0    The original routine
            JSR        (A0)                Result left in D0
            ADDQ.L     #2,A7               Restore the stack
            RTS
*
***************************************************************************
*           END OF RESIDENT SECTION REST IS FOR PASSES 1 AND 2 ONLY
***************************************************************************
*
            CNOP       0,4
*
***************************************************************************
*                          WRITE
***************************************************************************
* Routine to write out the string pointed to by A1
*
write   
            MOVE.L     A1,-(A7)
            MOVE.W     #cconws,-(A7)
            TRAP       #1
            ADDQ.L     #6,A7
            RTS
*
***************************************************************************
*                          WAIT
***************************************************************************
* Routine to wait for a character to be typed
*
wait 
            LEA.L      typechar,A1
            BSR        write
*
            MOVE.W     #2,-(A7)            Keyboard device
            MOVE.W     #bconin,-(A7)       conin
            TRAP       #13
            ADDQ.L     #4,A7
            RTS
*
***************************************************************************
            DATA
***************************************************************************
*
intro       DC.B       'Ramdisk+ V1.02',$D,$A
            DC.B       'Copyright ½ Metacomco plc 1988',$D,$A
            DC.B       'Drive : ',0
sizeis      DC.B       ' Size : ',0
nospace     DC.B       'Not enough space for ram disk',0
typechar    DC.B       $D,$A,'Press any key to continue',0
myfilename  DC.B       'A:\AUTO\RAM?????.PRG',0
drivestring DC.B       'D ',0
sizestring  DC.B       '  62 Kbytes',0
*
***************************************************************************
            BSS
***************************************************************************
*
programsize DS.L       1                   Program byte size save area
oldsuper    DS.L       1                   Old supervisor stack pointer
*
            END                            End of RAMDISK+.ASM
*
***************************************************************************
