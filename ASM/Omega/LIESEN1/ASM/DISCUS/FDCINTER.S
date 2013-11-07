
;************************************************************
;****              LISTING => FDCINTER.S                 ****
;************************************************************

;*****************************************************************
;*******               FDC/BASIC INTERFACE                ********
;*****************************************************************

;Hardware registers

dmamode   = $ff8606
dmascnt   = $ff8604
dmalow    = $ff860d
dmamid    = $ff860b
dmahigh   = $ff8609
giselect  = $ff8800
giwrite   = $ff8802
mfp       = $fffa01

;Control words for the DMA controller (DMA data direction => READ) 

srcmd = $80  ; select command register
srtrk = $82  ; select track register
srsec = $84  ; select sector register
srdat = $86  ; select data register
srcnt = $90  ; select DMA sector-count register

;control words for the DMA controller (DMA data direction => WRITE)

swcmd = $180 ; same as for => READ
swtrk = $182
swsec = $184
swdat = $186
swcnt = $190

;*****************************************************************
 align
STart:
 bra.s run   ; to start of program

;************************ Kommando-Worte *************************

rest:  dc.w $01 ; Restore      MO, 3ms Step rate
see:   dc.w $11 ; Seek         MO, 3ms Step rate
stp:   dc.w $31 ; Step         MO, 3ms Step rate, update track reg.
stpi:  dc.w $51 ; Step-in      MO, 3ms Step rate, update track reg.
stpo:  dc.w $71 ; Step-out     MO, 3ms Step rate, update track reg.

rsec:  dc.w $90 ; Read-Sector  MO, multiple
wsec:  dc.w $b0 ; Write-Sector MO, multiple, write precompensation

radr:  dc.w $c0 ; Read-Address MO,
rtrk:  dc.w $e0 ; Read-Track   MO,
wtrk:  dc.w $f0 ; Write-Track  MO, write precompensation

forc:  dc.w $d0 ; Force-Interrupt

;*******************   Parameters  ***********************

prm:   dc.w 00 ; function number
       dc.w 00 ; drive number
       dc.w 00 ; track number
       dc.w 00 ; sector number
       dc.w 00 ; number of bytes to transfer
       dc.w 00 ; number of ID fields to read
       dc.w 00 ; FDC status
       dc.w 00 ; DMA status
       dc.w 00 ; timeout? (1=timeout)
       dc.w 00 ; number of bytes to transfer
       dc.l 00 ; DMA start address
       dc.l 00 ; DMA end address
       dc.l 00 ; address of the track buffer
       dc.l 00 ; address of the sector buffer
       dc.l 00 ; address of the ID buffer
       dc.l 00 ; address of the ID status buffer

;****************    Here we go    ***************** 

run:

 tst.w 4(sp)               ; parameters passed?
 bne exit                  ; yes, return to BASIC

;Since the source can only be addressed PC relative, we use A3 
;as the program counter.

 LEA STart(PC),A3             ; PROGRAM RT IN ADDRESS REG. 3
 MOVEM.L D0-D7/A0-A6,SAVREG-STart(A3) ; E REGISTERS

;*******************  Set supervisor mode  ***********************

 clr.l -(sp)               ; user stack => superv. stack
 move.w #$20,-(sp)         ; command => Super
 trap #1
 addq.l #6,sp              ; correct stack
 MOVE.L D0,SAVSTACK-STart(A3) ; SAVE OLDACK POINTER

;*** Clear some flags and calculate absolute address of the *** 
;*** desired function.                                      ***

 LEA PRM-STart(A3),A5         ; POINTER PARAMETER BLOCK

 move.w #1,$43e            ; disable floppy VBL
 move.w #0,16(a5)          ; clear timeout flag
 MOVE.W #0,DMA-STart(A3)      ; CLEAR DMLAG
 MOVE.W #0,VBLFLAG-STart(A3)  ; CLEAR VBESET FLAG

 move.w 0(a5),d0           ; get function number
 and.l #$0f,d0             ; there are only 16 functions (0-15)
 lsl.l #2,d0               ; times 4 = functab offset

 LEA FUNCTAB-STart(A3),A4     ; FUNC-TABADDRESS
 move.l 0(a4,d0),d0        ; relative start address of the routine

 jsr 0(a3,d0)              ; +program start=abs. addr. of routine

 TST.W VBLFLAG-STart(A3)      ; VBL ON (ER DESELECTING)?
 beq letoff                ; no
 move.w #0,$43e            ; turn on

letoff:

;******************  back to user mode  ********************  

 MOVE.L SAVSTACK-STart(A3),D0 ; GET OLD CK POINTER BACK
 move.l d0,-(a7)           ; pass old stack pointer
 move.w #$20,-(sp)         ; command => Super
 trap #1
 addq.l #6,sp              ; correct stack

 MOVEM.L SAVREG-STart(A3),D0-D7/A0-A6 ; TORE REGISTERS

exit:
 rts                       ; back to BASIC


; That was it!  (All) we have left are the following routines 


;***********************  Restore FDC ****************************

restore:

 move.w #srcmd,dmamode     ; select command reg
 MOVE.W REST-STart(A3),D7     ; COMMAND RESTORE
 bsr wrt1772               ; pass command
 bsr fdcwait               ; wait until FDC is ready
 rts
 
;***********************  SEEK TRACK  ****************************

seek:

 move.w #srdat,dmamode     ; select data reg
 move.w 4(a5),d7           ; track number in d7
 bsr wrt1772               ; write track number
 move.w #srcmd,dmamode     ; select command reg
 MOVE.W SEE-STart(A3),D7      ; COMMAND SEEK
 bsr wrt1772               ; write command
 bsr fdcwait               ; wait until FDC ready
 rts

;************************  Step  *********************************

step:

 move.w #srcmd,dmamode     ; select FDC command reg
 MOVE.W STP-STart(A3),D7      ; COMMAND STEP
 bsr wrt1772               ; write command
 bsr fdcwait               ; wait until FDC ready
 rts

;*************************  Step in  *****************************                            

stepin:

 move.w #srcmd,dmamode     ; select FDC command reg
 MOVE.W STPI-STart(A3),D7     ; COMMAND STEP IN
 bsr wrt1772               ; write command
 bsr fdcwait               ; wait until FDC is ready
 rts

;************************  Step out  *****************************

stepout:

 move.w #srcmd,dmamode     ; select FDC command reg
 MOVE.W STPO-STart(A3),D7     ; COMMAND STEP OUT 
 bsr wrt1772               ; write command
 bsr fdcwait               ; wait until FDC is ready
 rts

;***********************  Force Interrupt  ***********************

Force:

 MOVE.W FORC-STart(A3),D7     ; COMMAND FORCE INTERRUPT
 bsr wrt1772               ; write command
 move.w #$100,d7           ; delay loop
wtfrc:
 dbra d7,wtfrc
 rts

;*********************  READ SECTOR(S)  **************************

readsector:

 move.l 32(a5),d7          ; DMA address to sector buffer
 bsr setdma
 MOVE.W #1,DMA-STart(A3)      ; SET DMA G
 move.w #srcnt,dmamode     ; toggle DMA R/W
 move.w #swcnt,dmamode
 move.w #srcnt,dmamode     ; select DMA sector count
 move.w #$0c,d7            ; load with 12 (corresponds to 6kB)
 bsr wrt1772               ; load DMA scnt

 move.w #srsec,dmamode     ; select sector reg
 move.w 6(a5),d7           ; sector number in d7
 bsr wrt1772               ; write sector number

 move.w #srcmd,dmamode     ; select command reg
 MOVE.W RSEC-STart(A3),D7     ; COMMAND READ MULTIPLE SECTORS
 bsr wrt1772               ; write command

 bsr fdcwait               ; wait until FDC is ready
 bsr readstat              ; read status and number of bytes
 rts

;**********************  Read Address  ***************************

readaddress:

 move.l 40(a5),a4          ; load address of the status buffer
 move.l 36(a5),d7          ; DMA address to ID field buffer
 bsr setdma
 move.w #srcnt,dmamode     ; toggle DMA R/W
 move.w #swcnt,dmamode
 move.w #srcnt,dmamode     ; select DMA sector count
 move.w #$01,d7            ; load with 1 (corresponds to 512 bytes)
 bsr wrt1772
 move.w #srcmd,dmamode     ; select FDC command reg
 move.w 10(a5),d4          ; #ID fields in D4
 and.w  #$7f,d4            ; but only max. 128

idloop:
 MOVE.W RADR-STart(A3),D7     ; COMMAND READ ADDRESS
 bsr wrt1772               ; write command
 bsr fdcwait               ; wait until FDC is ready
 move.b d0,(a4)+           ; save status in buffer
 tst.w 16(a5)              ; timeout ?
 dbne d4,idloop            ; no, read next ID field
 bsr readstat              ; read status and number of bytes
 rts

;***********************  READ TRACK  ****************************

readtrack:

 move.l 28(a5),d7          ; DMA address to track buffer
 bsr setdma
 MOVE.W #1,DMA-STart(A3)      ; SET DMA G
 move.w #srcnt,dmamode     ; toggle DMA R/W
 move.w #swcnt,dmamode
 move.w #srcnt,dmamode     ; select DMA sector count
 move.w #$0e,d7            ; load with 14 (corresponds to 7kB)
 bsr wrt1772
 move.w #srcmd,dmamode     ; select command reg
 MOVE.W RTRK-STart(A3),D7     ; COMMAND READ TRACK
 bsr wrt1772               ; write command
 bsr fdcwait               ; wait until FDC is ready
 bsr readstat              ; read status and number of bytes
 rts

;*********************  WRITE SECTOR(S)  *************************

writesector:

 move.l 32(a5),d7          ; DMA address to sector buffer
 bsr setdma
 MOVE.W #1,DMA-STart(A3)      ; SET DMA G
 move.w #swcnt,dmamode     ; toggle DMA R/W
 move.w #srcnt,dmamode
 move.w #swcnt,dmamode     ; select DMA sector count
 move.w #$0c,d7            ; load with 12 (corresponds to 6kB)
 bsr wrt1772               ; write DMA scnt
 move.w #swsec,dmamode     ; select sector reg
 move.w 6(a5),d7           ; sector number in d7
 bsr wrt1772               ; write sector reg

 move.w #swcmd,dmamode     ; select command reg
 MOVE.W WSEC-STart(A3),D7     ; COMMAND WRITE MULTIPLE SECTORS
 bsr wrt1772               ; write command
 bsr fdcwait               ; wait until FDC is ready
 bsr readstat              ; read status and number of bytes
 rts

;**********************  WRITE TRACK  ****************************

writetrack:

 move.l 28(a5),d7          ; DMA address to track buffer
 bsr setdma
 MOVE.W #1,DMA-STart(A3)      ; SET DMA G
 move.w #swcnt,dmamode     ; toggle DMA R/W
 move.w #srcnt,dmamode
 move.w #swcnt,dmamode     ; select DMA sector count
 move.w #$0e,d7            ; load with 14 (corresponds to 7kB)
 bsr wrt1772               ; write DMA scnt
 move.w #swcmd,dmamode     ; select command reg
 MOVE.W WTRK-STart(A3),D7     ; COMMAND WRITE TRACK
 bsr wrt1772               ; write command
 bsr fdcwait               ; wait until FDC is ready
 bsr readstat              ; read status and number of bytes
 rts

;*****************************************************************
;*****************************************************************

;Those were the routines that access the WD1772 commands
;We now have more subroutines, which are called partially from the
;main routines and partially directly from BASIC (such as setdrive)

;******************  REad sector register  ***********************

rsecreg:

 move.w #srsec,dmamode     ; select sector reg
 bsr read1772              ; and read
 and.w #$ff,d0             ; only lower byte
 move.w d0,6(a5)           ; into FDC array
 move.w #srcmd,dmamode     ; select command reg
 rts

;*******************  read track register  **********************

rtrkreg:

 move.w #srtrk,dmamode     ; select track reg
 bsr read1772              ; and read
 and.w #$ff,d0             ; lower byte only
 move.w d0,4(a5)           ; into FDC array
 move.w #srcmd,dmamode     ; Command-Reg. selektieren
 rts

;*********************  read status reg  ***********************

rstareg:

 move.w #srcmd,dmamode     ; select status reg
 bsr read1772              ; and read
 and.w #$ff,d0             ; status in lower byte
 move.w d0,12(a5)          ; into FDC array
 rts

;********************  write track reg  **********************

wtrkreg:

 move.w #srtrk,dmamode     ; select track reg
 move.w 4(a5),d7           ; get track number
 and.w #$ff,d7
 bsr wrt1772               ; and write
 move.w #srcmd,dmamode     ; select command reg
 rts

;********************  Set DMA transfer address  *****************

setdma:

 move.l d7,20(a5)          ; save start address in FDC array
 move.b d7,dmalow          ; first the low byte
 lsr.l #8,d7
 move.b d7,dmamid          ; then the middle byte
 lsr.l #8,d7
 move.b d7,dmahigh         ; and last the high byte

 move.l 20(a5),d7          ; get start address back
 clr.l d6
 move.w 8(a5),d6           ; number of bytes to transfer
 add.l d6,d7               ; add the two
 move.l d7,24(a5)          ; =expected end address
 rts

;*** Read DMA status; calculate number of transferred bytes ***

readstat:

 move.w dmamode,d0         ; read DMA status
 and.w #$7,d0              ; take lower 3 bit only
 move.w d0,14(a5)          ; to fdcout

 clr.l d1                  ; read DMA end address
 move.b dmahigh,d1    
 lsl.l #8,d1
 move.b dmamid,d1
 lsl.l #8,d1
 move.b dmalow,d1

 move.l d1,24(a5)          ; end address into array
 sub.l 20(a5),d1           ; end addr minus start addr
 move.w d1,18(a5)          ; =number of bytes
 rts

;*****************    Write FDC register   *******************

wrt1772:

 bsr wait
 move.w d7,dmascnt       ; write FDC reg or DMA sector count reg
 bsr wait
 rts

;*****************     Read FDC register     ********************

read1772:

 bsr wait
 move.w dmascnt,d0        ; read FDC reg or DMA sector-count reg
 bsr wait
 rts

;****************    Wait until FDC is ready    *******************

fdcwait:

 move.l #$180,d5           ; wait until Busy is set
litlwt:
 dbra d5,litlwt

 move.l #$40000,d5         ; d5 as timeout counter
 cmp.w #$9,0(a5)           ; READ-ADDRESS command?
 bne readmfp
 move.l #$28000,d5         ; yes, shorter timeout

readmfp:

 btst #5,mfp               ; is command done?
 beq fdcready              ; yes

 subq.l #1,d5              ; no, decrement timeout counter
 beq timeout               ; if timedout

 TST.W DMA-STart(A3)          ; COMMAND H DATA TRANSFER?
 beq readmfp               ; no, keep testing

 MOVE.B DMAHIGH,TEMP+1-STart(A3)  ; EXPED END DMA ADDRESS
 MOVE.B DMAMID,TEMP+2-STart(A3)   ; REAC?
 MOVE.B DMALOW,TEMP+3-STart(A3)
 MOVE.L TEMP-STart(A3),D7
 cmp.l 24(a5),d7
 blt readmfp               ; no, keep testing

 bsr force                 ; if so, then terminate command
 MOVE.W #0,DMA-STart(A3)      ; CLEAR DMLAG
 bra fdcready              ; and end routine normally

timeout:

 move.w dmascnt,d0         ; read status before termination
 and.w #$ff,d0             ; mask out top byte
 move.w d0,12(a5)          ; and into array
 bsr force                 ; terminate fommand
 move.w #1,16(a5)          ; set timeout flag
 rts

fdcready:

 move.w dmascnt,d0         ; read status
 and.w #$ff,d0             ; mask out top byte
 move.w d0,12(a5)          ; and into FDC array
 rts

;************  Wait until motor is off  *****************

motoroff:

 move.w #srcmd,dmamode     ; select status reg
test:
 bsr read1772              ; and read
 btst #7,d0                ; Motor on set?
 bne test                  ; yes, keep waiting
 rts

;*************************    Wait   *****************************

wait:

 move.w sr,-(a7)           ; save status
 move.w #$20,d5            ; d5 as counter
wt2:
 dbf d5,wt2
 move.w (a7)+,sr           ; get status back
 rts

;*****************  Select drive and side  ****************

setdrive:

 clr.l d7
 move.w 2(a5),d7           ; get drive number
 bne set
 bsr motoroff              ; if 0, delselect when motor off
 MOVE.W #1,VBLFLAG-STart(A3)  ; SET VBL ET FLAG
set:
 eor.b #7,d7               ; invert bits for hardware
 and.b #7,d7               ; only the lower 4 bits are affected
 move.w sr,-(a7)           ; save status
 or.w #$700,sr             ; turn off interrupts
 move.b #$e,giselect       ; select port A of the sound chip
 move.b giselect,d0        ; read port A
 and.b  #$f8,d0            ; clear bits 0-2
 or.b   d0,d7              ; set new bits
 move.b d7,giwrite         ; write to port A
 move.w (a7)+,sr           ; restore status
 rts

;***************************************************************
;*******************  Variables and tables  ********************
;***************************************************************

 align

SAVREG:   ds.L 16,0
savprm:   dc.l 0
savstack: dc.l 0

vblflag:  dc.w 0
dma:      dc.w 0
temp:     dc.l 0

FUNCTAB:  DC.L RESTORE-STart,SEEK-STart
          DC.L STEP-STart,STEPIN-STart
          DC.L STEPOUT-STart,READSECTOR-START
          dc.l writesector-start,readtrack-start
          dc.l writetrack-start,readaddress-start
          dc.l force-start,setdrive-start
          dc.l rsecreg-start,rtrkreg-start
          dc.l rstareg-start,wtrkreg-start

  align

;***************************** END ******************************

 end
                     