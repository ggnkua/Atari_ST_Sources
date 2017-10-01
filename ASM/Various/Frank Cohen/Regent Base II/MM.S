* Frank's Quick Memory Manager Routines
* (c) 1989 Regent Software

START MOVE.L A7,A5  ;Give me some memory!
 MOVE.L 4(A5),A5
 MOVE.L $C(A5),D0
 ADD.L $14(A5),D0
 ADD.L $1C(A5),D0
 ADD.L #$100,D0
 MOVE.L D0,-(A7)
 MOVE.L A5,-(A7)
 MOVE D0,-(A7)
 MOVE #$4A,-(A7)
 TRAP #1
 ADD.L #12,A7

 JSR INITAPPLZONE
 MOVE.L MM_MASTERS,A0
 MOVE #5,D0
 JSR DISPLAY
 JSR WAIT_KEY

 CLR -(A7)
 TRAP #1

* ///--- Memory Manager Internal Equates ---\\\ *

MM_MASTERCNT EQU 64    ;Starting number of master pointer block
MM_BLKSIZE EQU 200000  ;Default size of malloced block

MM_UNUSED EQU 0        ;1-Master pointer unused  MM_Flag values
MM_AVAIL EQU 1         ;1-Block not being used
MM_PURGE EQU 2         ;1-Purgeable block
MM_LOCK EQU 3          ;1-Locked block

MM_ADR EQU 0           ;Link-list parameters
MM_LAST EQU 4
MM_NEXT EQU 6
MM_FLAG EQU 8
MM_SIZE EQU 10
MM_LINKSIZE EQU 14     ;Size of link node

* \\\--- ------------------------------- ---/// *



* ///--- Memory Manager Error Codes ---\\\ *

MEMLOCKEDERR EQU -117 ;Block is locked
MEMPURERR    EQU -112 ;Attempt to purge a locked block
MEMWZERR     EQU -111 ;Attempt to operate on a free block
NILHANDLEERR EQU -109 ;Nil master pointer
MEMFULLERR   EQU -108 ;Not enough room in heap zone
NOLINKERR    EQU -103 ;No more master pointers available
UNKNOWNPTR   EQU -102 ;Unkown pointer
MEMLISTERR   EQU -101 ;Link list error
NILPTRERR    EQU -100 ;Nil pointer error
NOERR        EQU 0    ;No error

* \\\--- -------------------------- ---/// *



* ///--- Memory Manager Variables ---\\\ *

MM_MASTERS DS.L 1     ;Pointer to master pointer link list
MM_COUNT DS 1         ;Number of master links

* \\\--- ------------------------ ---/// *


*PACK_MEMORY
* - Walk linked list to move relocatable blocks

*NEWPTR
* - Search for free master pointer
* - Need more memory?
*     Yes- try COMPACTMEM first, then malloc new zone
* - Add new master pointer (locked)
* - Clear it

*DISPOSEPTR
* - Update master pointer information

*GETPTRSIZE
* - Find info from master pointer

*SETPTRSIZE
* - Is memory ahead of block free?
* - Yes, grab it
* - Clear it

*FREEMEM
*NEWHANDLE
*DISPOSEHANDLE
*GETHANDLESIZE
*SETHANDLESIZE
*REALLOCHANDLE
*HLOCK
*HUNLOCK
*HPURGE
*HNOPURGE



* ///--- *
* Name of Program/Subroutine: MORE_MASTERS
* Purpose/Description:
*  Extend master pointer block to add more master memory pointers
* Creation Date:  September 19, 1989
* Modification History:
* Inputs:
* Outputs:
*  D0 - Return code
* ---\\\ *

MORE_MASTERS MOVEM.L D1-D7/A0-A4,-(A7) ;Save registers
 MOVE.L MM_MASTERS,A0
 MOVE.L MM_ADR(A0),A0
 MOVE.L #MM_MASTERCNT*MM_LINKSIZE,D0
 JSR SET_PTR_SIZE
 TST D0
 BNE MM_MMDONE

 ADD #MM_MASTERCNT,MM_COUNT

 CLR D0
 MOVE MM_COUNT,D1
 SUB #1,D1
 CLR D2
 MOVE.L MM_MASTERS,A0
MM_MM100 TST MM_LAST(A0)
 BEQ MM_MM101
 ADD #1,D0
 ADD.L #MM_LINKSIZE,A0
 SUB #1,D1
 JMP MM_100

MM_MM101 MOVE D0,MM_LAST(A0)
 ADD #1,D0
 MOVE D0,MM_NEXT(A0)
 BSET #MM_UNUSED,MM_FLAG(A0)
 ADD.L #MM_LINKSIZE,A0
 DBF D1,MM_MM101
 SUB.L #MM_LINKSIZE,A0
 CLR MM_NEXT(A0)

 MOVE #NOERR,D7

MM_MMDONE MOVE D7,D0
 MOVEM.L (A7)+,D1-D7/A0-A4   ;Restore registers
 RTS


* ///--- *
* Name of Program/Subroutine: SET_PTR_SIZE
* Purpose/Description:
*  Extend or shrink block size
* Creation Date:  September 19, 1989
* Modification History:
* Inputs:
*  A0 - Pointer to block
*  D0 - New block size (long)
* Outputs:
*  D0 - Return code
* ---\\\ *

MM_HOLD_ADR DS.L 1
MM_HOLD_SIZE DS.L 1
MM_LINK_ADR DS.L 1    ;Address of link
MM_LINK_NBR DS 1      ;Link number
MM_NEXT_NBR DS 1      ;Next link number
MM_NEXT_ADR DS.L 1    ;Next link adress
MM_NEW_NBR DS 1       ;New link number
MM_NEW_ADR DS.L 1     ;New link adress

SET_PTR_SIZE MOVEM.L D1-D7/A1-A4,-(A7) ;Save registers

 ADD.L #1,D0           ;Round size to word boundary
 AND.L #$FFFFFFFE,D0
 MOVE.L D0,MM_HOLD_SIZE
 MOVE.L A0,MM_HOLD_ADR

 MOVE #UNKNOWNPTR,D7  ;Find link info
 MOVE.L A0,D1
 MOVE.L MM_MASTERS,A1
 CLR D0
MM_SP100 ADD #1,D0
 CMP.L MM_ADR(A1),D1
 BEQ MM_SP101
 TST MM_NEXT(A1)
 BEQ MM_SPDONE
 ADD.L #MM_LINKSIZE,A1
 JMP MM_SP100
MM_SP101 MOVE D0,MM_LINK_NBR
 MOVE.L A1,MM_LINK_ADR

 MOVE #NOERR,D7        ;Expand block or reduce?
 MOVE.L MM_SIZE(A1),D1
 CMP.L D0,D1
 BEQ MM_SPDONE
 BCS MM_SP_REDUCE

 JSR MM_WHOSE_NEXT  ;Expand the block
 TST D0
 BMI MM_SPDONE

 MOVE MM_FLAG(A0),D0
 BTST #MM_LOCK,D0
 BEQ MM_SPDONE
 BTST #MM_PURGE,D0
 BEQ MM_SP_PURGE
 BTST #MM_AVAIL,D0
 BEQ MM_SP_ATTACH

;Next block is being used, but is
;relocatable. So, relocate the
;next block, create a new link to take
;the extra memory, and update
;our block with the new size.

 JSR PACK_MEMORY      ; Relocate the block
 JSR MM_WHOSE_NEXT
 TST D0
 BMI MM_SPDONE

 MOVE.L MM_HOLD_SIZE,D0   ;Find available block big enough to hold next block
 SUB.L MM_SIZE(A0),D0
 MOVE.L D0,D2
 JSR MM_FIND_START
MM_RE_100 BTST #MM_AVAIL,MM_FLAG(A0)
 BNE MM_RE_101
 CMP.L MM_SIZE(A0),D2
 BCS MM_RE_200
MM_RE_101 TST MM_NEXT(A0)
 BEQ MM_SPDONE
 MOVE MM_NEXT(A0),D0
 MOVE D0,D1
 JSR MM_CALC
 JMP MM_RE_100

MM_RE_200 MOVE.L A0,MM_NEW_ADR
 MOVE D1,MM_NEW_NBR

 MOVE #MEMFULLERR,D7
 MOVE.L MM_NEXT_ADR,A0
 MOVE.L MM_NEW_ADR,A1

;Is next relocatable block larger
;or smaller than what needed?
 MOVE.L MM_SIZE(A0),D0
 CMP.L MM_SIZE(A1),D0
 BEQ MM_RE_300


                         ;Smaller, meaning a new link
                         ;must be created to take the left over memory







 JSR MM_FIND_FREE
 TST D0
 BMI MM_SPDONE
 MOVE D0,MM_NEW_NBR
 JSR MM_CALC
 MOVE.L A0,MM_NEW_ADR

 MOVE.L MM_NEXT_ADR,A0
 MOVE.L MM_ADR(A0),A0
 MOVE.L MM_SIZE(A0),D0
 JSR BLOCK_CLEAR

 MOVE.L MM_LINK_ADR,A0
 MOVE.L MM_NEW_ADR,A1
 MOVE.L MM_NEXT_ADR,A2
 MOVE MM_NEW_NBR,MM_NEXT(A0)
 MOVE MM_LINK_NBR,MM_LAST(A1)
 MOVE MM_NEXT_NBR,MM_NEXT(A1)
 MOVE MM_NEW_NBR,MM_LAST(A2)

 BSET #MM_AVAIL,MM_FLAG(A1)

 MOVE.L MM_HOLD_SIZE,D0
 SUB.L MM_SIZE(A0),D0
 SUB.L MM_SIZE(A2),D0
 MOVE.L D0,MM_SIZE(A1)

 MOVE.L MM_ADR(A0),D0
 ADD.L MM_HOLD_SIZE,D0
 MOVE.L D0,MM_ADR(A1)

 MOVE.L MM_HOLD_SIZE,MM_SIZE(A0)


MM_RE_300    ;Same size, so relocate and remove link

 


MM_SP_A100    ;Same size, so just do a block relocate
              ;then remove the destination block link


; Next block is available
; so reduce its size and
; increase our block



MM_SP_ATTACH

; Change size of destination block link,
; add to size of block being expanded

; If sizes are equal, remove the destination block link




MM_SP_PURGE MOVE #MEMFULLERR,D7  ;Is next block larger or smaller
 MOVE.L MM_HOLD_SIZE,D0          ;than what we need?
 SUB.L MM_SIZE(A1),D0
 CMP.L MM_SIZE(A0),D0
 BEQ MM_SP_P100
 BCS MM_SPDONE

 JSR MM_FIND_FREE              ;Something will be left over by
 TST D0                        ;purging the next block, so create
 BMI MM_SPDONE                 ;a new link for it.
 MOVE D0,MM_NEW_NBR
 JSR MM_CALC
 MOVE.L A0,MM_NEW_ADR

 MOVE.L MM_NEXT_ADR,A0
 MOVE.L MM_ADR(A0),A0
 MOVE.L MM_SIZE(A0),D0
 JSR BLOCK_CLEAR

 MOVE.L MM_LINK_ADR,A0
 MOVE.L MM_NEW_ADR,A1
 MOVE.L MM_NEXT_ADR,A2
 MOVE MM_NEW_NBR,MM_NEXT(A0)
 MOVE MM_LINK_NBR,MM_LAST(A1)
 MOVE MM_NEXT_NBR,MM_NEXT(A1)
 MOVE MM_NEW_NBR,MM_LAST(A2)

 BSET #MM_AVAIL,MM_FLAG(A1)

 MOVE.L MM_HOLD_SIZE,D0
 SUB.L MM_SIZE(A0),D0
 SUB.L MM_SIZE(A2),D0
 MOVE.L D0,MM_SIZE(A1)

 MOVE.L MM_ADR(A0),D0
 ADD.L MM_HOLD_SIZE,D0
 MOVE.L D0,MM_ADR(A1)

 MOVE.L MM_HOLD_SIZE,MM_SIZE(A0)

 CLR.L MM_ADR(A2)

 MOVE #NOERR,D7
 JMP MM_SPDONE

MM_SP_P100 MOVE #NOERR,D7        ;Do a clean purge of the next block
 MOVE.L MM_HOLD_SIZE,MM_SIZE(A1) ;the next block is the same size as
 CLR.L MM_ADR(A0)                ;the desired increase.
 MOVE.L MM_ADR(A0),A0

* UNLINK THE EMPTY NODE HERE

 JSR BLOCK_CLEAR
 JMP MM_SPDONE

MM_SP_REDUCE JSR MM_FIND_FREE   ;Reduce a block of memory
 TST D0
 BMI MM_SPDONE
 MOVE D0,MM_NEW_NBR
 JSR MM_CALC
 MOVE.L A0,MM_NEW_ADR
 MOVE.L MM_LINK_ADR,A1
 MOVE MM_NEXT(A1),D1
 MOVE MM_NEW_NBR,MM_NEXT(A1)
 MOVE D1,MM_NEXT(A0)
 MOVE MM_LINK_NBR,MM_LAST(A1)

 MOVE.L MM_ADR(A1),D2
 ADD.L MM_SIZE(A1),D2
 MOVE.L D2,MM_ADR(A0)

* UNLINK THE FREED LINK HERE

 MOVE.L MM_SIZE(A1),D0
 SUB.L MM_HOLD_SIZE,D0
 MOVE.L D0,MM_SIZE(A0)
 BSET #MM_AVAIL,MM_FLAG(A0)
 MOVE.L MM_HOLD_SIZE,MM_SIZE(A1)

 MOVE #NOERR,D7

MM_SPDONE MOVE D7,D0
 MOVEM.L (A7)+,D1-D7/A1-A4   ;Restore registers
 RTS


MM_WHOSE_NEXT MOVE #MEMFULLERR,D7
 MOVE.L MM_LINK_ADR,A0
 MOVE MM_NEXT(A0),D0
 MOVE D0,MM_NEXT_NBR
 BEQ MM_WN_100
 JSR MM_CALC
 MOVE.L A0,MM_NEXT_ADR
 MOVE #NOERR,D7
MM_WN_100 MOVE D7,D0
 RTS


MM_FIND_FREE MOVE.L MM_MASTERS,A0
 CLR D0
 MOVE #NOLINKERR,D7
MM_FF_100 BTST #MM_UNUSED,MM_FLAG(A0)
 BEQ MM_FF_101
 ADD.L #MM_LINKSIZE,A0
 ADD #1,D0
 CMP MM_COUNT,D0
 BNE MM_FF_100
 ADD #1,D0
 MOVE #NOERR,D7
MM_FF_101 MOVE D7,D0
 RTS

; Returns D0-return code
; D1-Link number
; A0-Link adr

MM_FIND_START MOVE.L MM_MASTERS,A0
 MOVE #1,D1
 MOVE #NOLINKERR,D7
MM_FS_100 TST MM_LAST(A0)
 BEQ MM_FS_101
 TST MM_NEXT(A0)
 BEQ MM_FS_102
 ADD #1,D1
 ADD.L #MM_LINKSIZE,A0
 JMP MM_FS_100
MM_FS_101 MOVE #NOERR,D7
MM_FS_102 MOVE D7,D0
 RTS

MM_FIND_END MOVE.L MM_MASTERS,A0
 CLR D0
 MOVE #NOLINKERR,D7
MM_FF_100 TST MM_NEXT(A0)
 BEQ MM_FF_101
 ADD.L #MM_LINKSIZE,A0
 ADD #1,D0
 CMP MM_COUNT,D0
 BNE MM_FF_100
 ADD #1,D0
 MOVE #NOERR,D7
MM_FF_101 MOVE D7,D0
 RTS

MM_FIND_NEXT_UNUSED MOVE #MEMFULLERR,D7  ;Find next available link
MM_FNF_100 TST MM_NEXT(A0)
 BEQ MM_FNF_DONE
 MOVE MM_NEXT(A0),D0
 JSR MM_CALC
 BTST #MM_UNUSED,MM_FLAG(A0)
 BNE MM_FNF_100
 MOVE #NOERR,D7
MM_FNF_DONE MOVE D7,D0
 RTS

MM_CALC AND.L #$FFFF,D0   ;Calculate address from link pointer
 SUB #1,D0
 MULU #MM_LINKSIZE,D0
 ADD.L MM_MASTERS,D0
 MOVE.L D0,A0
 RTS

* ///--- *
* Name of Program/Subroutine: PACK_MEMORY
* Purpose/Description:
*  Compact memory blocks
* Creation Date:  September 14, 1989
* Modification History:
* Inputs:
* Outputs:
*  D0 - Return code
* ---\\\ *

PACK_MEMORY


* ///--- *
* Name of Program/Subroutine: INIT_APPL_ZONE
* Purpose/Description:
*  Initialize the application heap.
* Creation Date:  September 14, 1989
* Modification History:
* Inputs:
* Outputs:
*  D0 - Return code
* ---\\\ *

INIT_APPL_ZONE MOVE #MEMFULLERR,D7
 MOVE.L #MM_BLKSIZE,D0
 JSR ALLOCATE_BLOCK
 TST.L D0
 BEQ MM_IADONE
 MOVE.L D0,MM_MASTERS
 MOVE #MM_MASTERCNT,MM_COUNT

 MOVE.L D0,A0
 MOVE.L #MM_BLKSIZE,D0
 JSR BLOCK_CLEAR

 MOVE #MM_MASTERCNT-1,D1
 CLR D0
 MOVE.L MM_MASTERS,A0
MM_IA100 MOVE D0,MM_LAST(A0)
 ADD #1,D0
 MOVE D0,MM_NEXT(A0)
 BSET #MM_UNUSED,MM_FLAG(A0)
 ADD.L #MM_LINKSIZE,A0
 DBF D1,MM_IA100
 SUB.L #MM_LINKSIZE,A0
 CLR MM_NEXT(A0)

 MOVE.L MM_MASTERS,A0
 MOVE.L A0,MM_ADR(A0)
 MOVE.L #MM_MASTERCNT*MM_LINKSIZE,MM_SIZE(A0)
 CLR MM_FLAG(A0)
 BSET #MM_LOCK,MM_FLAG(A0)
 ADD.L #MM_LINKSIZE,A0

 CLR MM_FLAG(A0)
 BSET #MM_AVAIL,MM_FLAG(A0)
 MOVE.L MM_MASTERS,D0
 ADD.L #MM_MASTERCNT*MM_LINKSIZE,D0
 MOVE.L D0,MM_ADR(A0)
 MOVE.L #MM_BLKSIZE,D0
 SUB.L #MM_MASTERCNT*MM_LINKSIZE,D0
 MOVE.L D0,MM_SIZE(A0)

 MOVE #NOERR,D7

MM_IADONE MOVE D7,D0
 RTS



* ///--- *
* Name of Program/Subroutine: ALLOCATE_BLOCK
* Purpose/Description:
*  Ask TOS to assign a block of memory
* Creation Date:  September 14, 1989
* Modification History:
* Inputs:
*  D0 - byteCount, Long value
* Outputs:
*  D0 - Address of allocated block
* Special case: Trying to allocate -1 bytes returns
*  size of available memory
* ---\\\ *

ALLOCATE_BLOCK MOVE.L D0,-(A7)  ;BIOS function: MALLOC
 MOVE #$48,-(A7)
 TRAP #1
 ADD.L #6,A7
 RTS


* ///--- *
* Name of Program/Subroutine:  BLOCK_MOVE
* Purpose/Description:
*  Move a block of memory to a new location
*  Doesn't matter if source and destination overlap
* Creation Date:  September 13, 1989
* Modification History:
* Inputs:
*  A0 - sourcePtr, Source pointer
*  A1 - destPtr, Destination pointer
*  D0 - byteCount, Long value
* Outputs:
*  Does not disturb unused registers
*  D0 - Result code
* ---\\\ *

BLOCK_MOVE MOVEM.L D1-D7/A2-A4,-(A7) ;Save registers

 MOVE #NILPTRERR,D7          ;Register D7 holds error value
 MOVE.L A0,D1                ;Check for nil pointers
 BEQ BLKMVDONE               ;Abort on bad values
 MOVE.L A1,D2
 BEQ BLKMVDONE

 TST.L D0                    ;Abort if block size is zero
 BEQ BLKNOERR
 CMP.L D1,D2                 ;Abort if source and destination are equal
 BEQ BLKNOERR

 CLR D5                      ;Check which move technique is to be used
 CMP.L D1,D2                 ;Register D5 is a flag,
 BLT BLKMVTOP                ;  0-Top down move 1-Bottom Up
 MOVE.L D1,D3
 ADD.L D0,D3
 CMP.L D3,D2
 BGT BLKMVTOP
 MOVE #-1,D5                 ;The blocks overlap, so D5 flag is set and
 ADD.L D0,A0                 ;the starting block pointers are set to the
 ADD.L D0,A1                 ;end of the blocks

BLKMVTOP CMP.L #34,D0        ;Use the byte-by-byte copy if less than
 BCS BLKMVBITS               ;34 bytes are being moved

 BTST #0,D1                  ;Test to see if the blocks begin on even
 BEQ BLKMVEVEN               ;byte boundaries.  If one or the other begins
 BTST #0,D2                  ;on an odd boundary, use the byte-by-byte copy
 BEQ BLKMVBITS

 TST D5                      ;Otherwise, move the first byte which bumps
 BNE BLKMVADJ1               ;the block pointers onto an even byte boundary
 MOVE.B (A0)+,(A1)+          ;Again, D5 controls the movement technique
 SUB.L #1,D0
 JMP BLKMVBIG
BLKMVADJ1 MOVE.B -(A0),-(A1)
 SUB.L #1,D0
 JMP BLKMVBIG

BLKMVEVEN BTST #0,D2         ;One last even byte boundary check
 BNE BLKMVBITS

BLKMVBIG TST D5              ;Top-down or Bottom-up movement technique?
 BNE BLKMVBIGUP

BLKMVL1 MOVE.L (A0)+,(A1)+   ;Do a fast move of the blocks using the
 MOVE.L (A0)+,(A1)+          ;top-down technique.  Using the long word
 MOVE.L (A0)+,(A1)+          ;move really speeds things up
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 SUB.L #32,D0                ;Keep track of how many more 32 byte blocks
 CMP.L #32,D0                ;need to be moved.  When below 32 bytes, use
 BGT BLKMVL1                 ;the byte-by-byte copy technique.
 JMP BLKMVBITS

BLKMVBIGUP MOVE.L -(A0),-(A1);Do a fast move of the blocks using the
 MOVE.L -(A0),-(A1)          ;bottom-up technique.
 MOVE.L -(A0),-(A1)
 MOVE.L -(A0),-(A1)
 MOVE.L -(A0),-(A1)
 MOVE.L -(A0),-(A1)
 MOVE.L -(A0),-(A1)
 MOVE.L -(A0),-(A1)
 SUB.L #32,D0                ;Any more 32 byte blocks need moving?
 CMP.L #32,D0
 BGT BLKMVBIGUP

BLKMVBITS TST.L D0           ;Just a quick test to see if any bytes
 BEQ BLKNOERR                ;need moving.  Then jump to the copy
 TST D5                      ;technique determined above
 BEQ BLKMVDN

BLKMVUP MOVE.B -(A0),-(A1)   ;Byte-by-byte bottom-up
 SUB.L #1,D0
 BNE BLKMVUP
 JMP BLKNOERR

BLKMVDN MOVE.B (A0)+,(A1)+   ;Byte-by-byte top-down
 SUB.L #1,D0
 BNE BLKMVDN

BLKNOERR MOVE #NOERR,D7      ;Report no errors

BLKMVDONE MOVE.L D7,D0       ;Move error value to D0 for return
 MOVEM.L (A7)+,D1-D7/A2-A4   ;Restore registers
 RTS


* ///--- *
* Name of Program/Subroutine:  BLOCK_CLEAR
* Purpose/Description:
*  Clear a block of memory
* Creation Date:  September 13, 1989
* Modification History:
* Inputs:
*  A0 - sourcePtr, Source pointer
*  D0 - byteCount, Long value
* Outputs:
*  Does not disturb unused registers
*  D0 - Result code
* ---\\\ *

BLOCK_CLEAR MOVEM.L D1-D7/A2-A4,-(A7) ;Save registers

 MOVE #NILPTRERR,D7          ;Register D7 holds error value
 MOVE.L A0,D1                ;Check for nil pointer
 BEQ BLKCLRDONE
 TST.L D0                    ;Abort if block size is zero
 BEQ BLKCLRNOERR

 CMP.L #34,D0                ;Use the byte-by-byte clear if less than
 BCS BLKCLRBITS              ;34 bytes are being cleared

 BTST #0,D1                  ;Test to see if the block begins on an even
 BEQ BLKCLREVEN              ;byte boundaries.

 CLR.B (A0)+                 ;Clear first byte to even word boundary
 SUB.L #1,D0

BLKCLREVEN CLR.L (A0)+       ;Do a fast block clear.
 CLR.L (A0)+
 CLR.L (A0)+
 CLR.L (A0)+
 CLR.L (A0)+
 CLR.L (A0)+
 CLR.L (A0)+
 CLR.L (A0)+
 SUB.L #32,D0                ;Keep track of how many more 32 byte blocks
 CMP.L #32,D0                ;need to be moved.  When below 32 bytes, use
 BGT BLKCLREVEN              ;the byte-by-byte copy technique

BLKCLRBITS TST.L D0          ;Just a quick test to see if any bytes
 BEQ BLKCLRNOERR             ;need moving

BLKCLRDN CLR.B (A0)+         ;Byte-by-byte block clear
 SUB.L #1,D0
 BNE BLKCLRDN

BLKCLRNOERR MOVE #NOERR,D7   ;Report no errors

BLKCLRDONE MOVE.L D7,D0      ;Move error value to D0 for return
 MOVEM.L (A7)+,D1-D7/A2-A4   ;Restore registers
 RTS

*------------DISPLAY CONTENTS OF STRUCTURE------------

DISPLAY MOVE.L A0,DIS_ADR
 MOVE D0,DIS_CNT
 CMP #1,D0
 BLT DISPDONE
 CLR COUNT

 LEA DIS1,A0
 JSR STRING

DISLOOP CLR.L D0
 MOVE COUNT,D0
 MULU #MM_LINKSIZE,D0
 ADD.L DIS_ADR,D0
 MOVE.L D0,A4

 LEA DIS2,A3
 MOVE MM_LAST(A4),D0
 JSR DISLCV
 MOVE MM_NEXT(A4),D0
 JSR DISLCV
 MOVE MM_FLAG(A4),D0
 JSR DISLCV
 MOVE MM_ADR(A4),D0
 JSR DISLCV
 MOVE MM_ADR+2(A4),D0
 JSR DISLCV
 MOVE MM_SIZE(A4),D0
 JSR DISLCV
 MOVE MM_SIZE+2(A4),D0
 JSR DISLCV

 LEA DIS2,A0
 JSR STRING

 ADD #1,COUNT
 MOVE COUNT,D0
 CMP DIS_CNT,D0
 BNE DISLOOP
 RTS

DISLCV MOVE D0,D1
 LSR #4,D1
 LSR #4,D1
 LSR #4,D1
 AND.L #15,D1
 JSR DISLCV2

 MOVE D0,D1
 LSR #4,D1
 LSR #4,D1
 AND.L #15,D1
 JSR DISLCV2

 MOVE D0,D1
 LSR #4,D1
 AND.L #15,D1
 JSR DISLCV2

 MOVE D0,D1
 AND.L #15,D1
 JSR DISLCV2

 ADD #2,A3
DISPDONE RTS

DISLCV2 CMP.B #10,D1
 BCC PT1
 ADD.B #'0',D1
 JMP PT2
PT1 SUB.B #10,D1
 ADD.B #'A',D1
PT2 MOVE.B D1,(A3)+
 RTS

DIS_ADR DC.L 0
DIS_CNT DC 0
COUNT DC 0

DIS1 DC.B 'NEXT  LAST  FLAG  ADR.......  SIZE......   ',13,10,0
DIS2 DC.B '                                           ',13,10,0
 EVEN

TESTPOINT LEA TSTMES,A3
 JSR CONV2DEC
 LEA TSTMES,A0
 JSR STRING

WAIT_KEY MOVE #7,-(A7)
 TRAP #1
 ADD.L #2,A7
 RTS

STRING MOVE.L A0,-(A7)
 MOVE #9,-(A7)
 TRAP #1
 ADD #6,A7
 RTS

TSTMES DC.B '0000',0
 EVEN

************************************
* CONVERT THE VALUE IN D0 TO ASCII *
* A3 POINTS TO ASCII BUFFER        *
************************************

CONV2DEC AND.L #$FFFF,D0
 DIVU #1000,D0
 MOVE.L D0,D1
 AND.L #15,D0
 ADD.B #'0',D0
 MOVE.B D0,(A3)

 SWAP D1
 AND.L #$FFFF,D1
 DIVU #100,D1
 MOVE.L D1,D0
 AND.L #15,D1
 ADD.B #'0',D1
 MOVE.B D1,1(A3)

 SWAP D0
 AND.L #$FFFF,D0
 DIVU #10,D0
 MOVE.L D0,D1
 AND.L #15,D0
 ADD.B #'0',D0
 MOVE.B D0,2(A3)

 SWAP D1
 AND.L #$FFFF,D1
 AND.L #15,D1
 ADD.B #'0',D1
 MOVE.B D1,3(A3)
 RTS

 END
