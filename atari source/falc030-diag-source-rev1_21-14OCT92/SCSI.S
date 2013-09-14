        .include hardware
        .include defs
;       .include var
        .include nvram
        
        .extern scsitst,wait100,wait400
* Does a non-destructive read and write with one buffer and then reads
* again into a different 32k memory buffer.
* Errors seen by or caused by interaction with the SCSI controller
* will stop the operation and display an error. 
* If no errors have occur then the two memory buffer contents are
* compared and any DMA data errors reported. (a check is also made for
* DMA writing outside the read/write buffer boundary) 
* 

wdc  equ  $ffff8604
wdl  equ  $ffff8606
wdend     equ  $ffff860f

scsispry  equ  $18010000                ; buffer end/start flag

.macro w4req
        bsr     w4reqold
.endm

.macro doack
        bsr     doackold
.endm

.macro hshake xword
        move.w  d0,-(sp)
        move.w  \xword,d0
        bsr     hshakeold
        move.w  (sp)+,d0
.endm

  .macro rscsi      srcreg,dst
          move.w    \srcreg,wdl
          move.w    wdc,\dst
  .endm

  .macro wscsi      val,dstreg
          move.w    \dstreg,wdl
          move.w    \val,wdc
  .endm

.macro rstdelay
        bsr     rstdelayold
.endm

        .text

scsitst:  move.l    #$7000,scsibuf      ; test drive zero
          move.l    #$20000,scsibuf1    ; point to buffers
          lea       scsi0msg,a5         ; display sign on
          bsr       dsptst
          move.l    scsibuf,a0
          move.l    #$8000,a1           ; 32k offset
          move.l    #scsispry,-4(a0)    ; underspray
          move.l    #scsispry,0(a1,a0.l) ; over spray (32k)

*       Clear 1772 if it needs it
clrintx: btst      #5,mfp+gpip
         bne       wrts1x
         bsr       reset1770       ;if int, clear 1772
         bra.s     clrintx

wrts1x: 
         bsr       resetSCSI           ; start from known position

* begin testing scsi drive 0
* read 64 blocks in dma mode

          move.w    #$2700,sr
          bsr       rdshort
          tst       d6
          bmi       scsi_no        ; exit on error

          move.l    scsibuf,a0     ; load buffer adr
          move.l    #64,d2         ; load block count    
          bsr       rddma          ; read from scsi device in dma mode
          bmi       scsi_no        ; exit on error
          bne       scsiserr

;write 64 blocks in dma mode
          bsr       wrtshort
          tst       d6
          bmi       scsi_no        ; exit on error
          move.l    scsibuf,a0     ; load buffer adr
          move.l    #64,d2         ; load block count    
          bsr       wrtdma         ; write to scsi device in dma mode
          bmi       scsi_no        ; exit on error
          bne       scsiserr

;read 64 blocks in dma mode
          bsr       rdshort

          tst       d6
          bmi       scsi_no        ; exit on error
          move.l    scsibuf1,a0    ; load buffer adr (compare buffer)
          move.l    #64,d2         ; load block count    
          bsr       rddma          ; read from scsi device in dma mode
          bmi       scsi_no        ; exit on error
          bne       scsiserr

          bsr       scsi_ck1       ; do a block compare
          beq.s     scsinorm       ; exit on ok          
          bsr       scsicdma       ; exit on compare error (dma)

scsi_no:  move.w    #$2400,sr      ; exit no scsi or dmac failure 
scsiserr: rscsi     #$8f,d0        ; exit scsi status bad (5380)
          move.w    #red,palette   
          move.l    #falmsg,a5
        move.b  #t_SCSI,d0
          bsr       dsppf
          rts

scsinorm: move.w    #$2400,sr
          movea.l   #pasmsg,a5
        move.b  #t_SCSI,d0
          bsr       dsppf
          rts                      ; return to main diagnostics


**************************************************************************
*    subroutines
**************************************************************************

;rdlong:   bsr       selSCSI        ; select by arbitration, scsi
;          bmi       scsinot        ; branch on error
;          move.b    #$28,d0        ; load extended read command
;          clr.l     d1             ; load select zero block
;          move.w    #64,d2         ; load 64 (512 byte) blocks (max 64k blk)
;          bsr       send10         ; send 10 byte command
;scsinot:  rts
;wrtlong:  bsr       selSCSI        ; select by arbitration
;          bmi       scsinot        ; branch on error
;          move.b    #$2a,d0        ; load extended write command
;          clr.l     d1             ; load select zero block
;          move.w    #64,d2         ; load 64 blocks (512 byte) blocks
;          bsr       send10         ; send 10 byte command
;          rts

rdshort:  bsr       selSCSI        ; select by arbitration,scsi
          tst       d0
          bmi       scsinot        ; branch on error
          move.l    #$08,d0        ; load short read command
          clr.l     d1             ; load select 0 block
          move.l    #64,d2         ; load block count (max 256 blocks)
          bsr       send6          ; send 6 byte command
          rts
wrtshort: bsr       selSCSI        ; select by arbitration,scsi
          tst       d0
          bmi       scsinot        ; branch on error
          move.b    #$0a,d0        ; load short write command
          clr.l     d1             ; load select 0 block
          move.l    #64,d2         ; load block count (max 256)
          bsr       send6          ; send 6 byte command
scsinot:  rts

*************************************************************************
*
*compares write buffer to read buffer (512 bytes) and flags error

;scsi_ck:  move.l    scsibuf,a0
;          move.l    scsibuf1,a1
;          cmp.l     #scsispry,-4(a0) ; ck for spray
;          bne.s     sc_ck2         ; bra on under error
;          cmp.l     #scsispry,512(a1) ; ck for spray
;          bne.s     sc_ck2         ; bra on over error
;          move.l    scsibuf1,a0    ; check buffer
;          move.l    scsibuf,a1     ; dma read/write buffer
;          move.w    #511,d0        ; byte count -1
;sci_ck1:  cmp.b     (a0)+,(a1)+    ; compare buffers
;          bne       sci_ck2        ; branch on error
;          dbra      d0,sci_ck1     ; else check next byte
;sci_ck2:  rts                      ; return zero if no errors

*compares write buffer to read buffer (32k bytes) and flags error

scsi_ck1: move.l    scsibuf,a0
          move.l    scsibuf1,a1
          cmp.l     #scsispry,-4(a0)     ; ck for spray
          bne.s     sc_ck2         ; bra on under error
          move.l    #$8000,a1      ; offset for data
          cmp.l     #scsispry,0(a1,a0.l) ; ck for spray
          bne.s     sc_ck2         ; bra on over error
          move.l    scsibuf1,a0    ; check buffer
          move.l    scsibuf,a1     ; dma read/write buffer
          move.w    #$7fff,d0      ; byte count -1
sc_ck1:   cmp.b     (a0)+,(a1)+    ; compare buffers
          bne       sc_ck2         ; branch on error
          dbra      d0,sc_ck1      ; else check next byte
sc_ck2:   rts                      ; return zero if no errors


**************************************************************************
**************************************************************************
*    sub subroutines
**************************************************************************
**************************************************************************

* send a 10 byte command to scsi device
*
* entered with d0 = command byte ($28 or $2a for extended read/write)
* entered with d1 = start block # (zero in our case)
* entered with d2 = block count   (64 blocks in our case)
*

;send10:   move.w    #$8b,wdl  ; select reg. 3
;          move.w    #2,wdc
;          move.w    #$89,wdl  ; select reg. 1
;          move.w    #1,wdc
;          hshake    d0             ; write the command      -- 00 --
;          hshake    #0             ; send default byte      -- 01 --
;          rol.l     #8,d1          ; send 4 bytes of block number
;          hshake    d1             ;                        -- 02 --
;          rol.l     #8,d1          
;          hshake    d1             ;                        -- 03 --
;          rol.l     #8,d1
;          hshake    d1             ;                        -- 04 --
;          rol.l     #8,d1
;          hshake    d1             ;                        -- 05 --
;          hshake    #0             ; default reserved byte  -- 06 --
;          rol.w     #8,d2          ; block count
;          hshake    d2             ; send high block count  -- 07 --
;          rol.w     #8,d2          ; 
;          hshake    d2             ; send low block count   -- 08 --
;          hshake    #0             ; send the control byte  -- 09 --
;          rts

**************************************************************************
*
* send a six byte command to scsi device
*
* enter with d0 = command byte ($08 or $0a read/write command)
* enter with d1 = block number (word)
* enter with d2 = block count  (byte)

send6:    move.w    #$8b,wdl       ; select reg. 3 (scsidat+6) 
          move.w    #2,wdc         ; assert c/d

          move.w    #$89,wdl       ; select reg. 1 (scsidat+2)
          move.w    #1,wdc         ; assert data bus

          hshake    d0             ; write the command      -- 00 --
          bmi     send60
          hshake    #0             ; default 0 (max 33 meg) -- 01 --
          bmi     send60
          rol.w     #8,d1          ; load block number
          hshake    d1             ; send high byte         -- 02 --
          bmi     send60
          rol.w     #8,d1          ;
          hshake    d1             ; now low byte           -- 03 --
          bmi     send60
          hshake    d2             ; load block count       -- 04 --
          bmi.s     send60
          hshake    #0             ; control byte default   -- 05 --
          bmi.s     send60
          moveq.l   #$0,d6
          rts
send60:   bra       scsilock       ; error - hand shake broke

**************************************************************************
**************************************************************************
*a0 points to buffer, d2 = block count
* read in dma mode

rddma:
          wscsi     #0,#$89             ; data bus no
          wscsi     #1,#$8b             ; data in phase
          rscsi     #$8f,d6             ; clear pot.interrupt
          wscsi     #2,#$8a             ; dma mode yes

          movea.l   #$ffff8604,a1
          bsr       setadma             ; load the buffer address (a0)
          move.w    #$190,$2(a1)
          rstdelay
          move.w    #$90,$2(a1)
          rstdelay

          move.w    d2,(a1)             ; load count
rdma1:
          btst.b    #$3,wdend
          bne.s     rdma1
 
          wscsi     #0,#$8f             ; start dma
          move.w    #$0,wdl
          bsr       scsiwait            ; waits on interrupts
          tst.w     d6
          beq.s     rdma2

          move.w    #$2400,sr
          bsr       scsinblk            ; dma block move timeout
          rscsi     #$8f,d1
          rts
rdma2:    bsr       scsistat
;          move.w    #$2400,sr
          rts

setadma:
          move.l    a0,-(a7)
          move.b    $3(a7),dmalow      ; $860d       ;dma low
          move.b    $2(a7),dmamid      ; $860b       ;dma mid
          move.b    $1(a7),dmahigh     ; $8609       ;dma hi
          addq.l    #$4,a7
          rts

**************************************************************************
*
* write in dma mode

wrtdma:
          wscsi     #0,#$8b               ; set data out phase
          rscsi     #$8f,d6                ; clear potential interrupt
          wscsi     #2,#$8a               ; enable DMA mode

          movea.l   #$ffff8604,a1
          bsr       setadma             ; load the start address
          move.w    #$90,$2(a1)
          rstdelay
          move.w    #$190,$2(a1)
          rstdelay

          move.w    d2,(a1)             ; load count
wdma1:
          btst    #$3,wdend 
          bne.s     wdma1
          wscsi     #0,#$18d            ; start dma
          move.w    #$100,wdl
          bsr       scsiwait            ; wait on interrupts
          tst.w     d6
          beq.s     wdma2

;          move.w    #$2400,sr
          bsr       scsinblk            ; dma block move timeout
          rscsi     #$8f,d1
          rts
wdma2:    bsr       scsistat
;          move.w    #$2400,sr
          rts

**************************************************************************
*
* wait here for end of dma
*
scsiwait: move.l    #$1000,d6           ; load time out count (250ms x 10)
sw0:      btst      #5,mfp+gpip         ; ck mfp for irq
          beq.s     waitover            ; if 0, branch 
          bsr       wait                ; 2.5 msec each pass    
          dbra      d6,sw0
          bsr       resetSCSI
          moveq.l   #$ff,d6
          rts
* else no error
waitover:
          rscsi     #$8f,d0              ; clear potential interrupt
          wscsi     #0,#$8a              ; disable DMA mode
          wscsi     #0,#$89             ; insure data bus not asserted
          moveq.l   #0,d6
          rts                           ; normal exit


**************************************************************************

resetSCSI:

resetsps: btst      #$3,wdend           ;$860f
          bne.s     resetsps
          move.w    #$190,wdl           ;$8606    (reset dma chip)
          rstdelay
          move.w    #$90,wdl
          rstdelay

          wscsi     #$80,#$89 ; set the reset bit
          bsr       wait100   ; wait 250 mS

          wscsi     #0,#$89   ; reset the reset bit
          bsr       wait400   ; wait 1000 mS
          rts

          
;wait100:  move.l    d0,-(a7)            ; wait for 250 ms
;          move.l    #98,d0              ; for 16 mhz 00 00 00
;;         btst.b    #0,SPControl
;;         bne.s     wait10a             ;                 
;;         move.l    #98,d0              ; for 8 mhz (00 00)  
;
;wait10a:  bsr       wait                ; 
;          dbra      d0,wait10a
;          move.l    (a7)+,d0
;          rts
;wait400:  move.l    d0,-(a7)
;          move.l    #3,d0               ; wait 1000 mS
;wait40a:  bsr       wait100
;          dbra      d0,wait40a
;          move.l    (a7)+,d0
;          rts

**************************************************************************
*  
*select the scsi device

selSCSI:  move.l    #99,d0   ; load time out count (250ms)
.0:       rscsi     #$8c,d6
          btst      #$6,d6    ; not STILL busy from last time ?
          beq.s     .1
          bsr       wait
          dbra      d0,.0
          bra       scsibusy

.1:       wscsi     #0,#$8b
          wscsi     #0,#$8c    ; no interrupt from selection
          wscsi     #$c,#$89   ; BSY, SEL yes

          clr.w     d6
          bset.l    #$0,d6     ; get unit zero
          wscsi     d6,#$88
          wscsi     #5,#$89    ; SEL, data bus yes
          rscsi     #$8a,d6    ; select reg. 2 (scsidat+4)
          andi.b    #$fe,d6    ; clr arbitrate bit
          move.w    d6,wdc
          rscsi     #$89,d6
          andi.b    #$f7,d6    ; clr BUSY
          move.w    d6,wdc
          nop
          nop

          move.l    #99,d0     ; load time out count (250ms)
.2:       rscsi     #$8c,d6
          btst      #$6,d6     ; check for bus to be busy
          bne.s     .3         ; branch on busy set

          bsr       wait       ; wait is 2.5 mS
          dbra      d0,.2      ; total wait 250ms
          bra       scsistop  ; display error msg and exit

.3:       wscsi     #0,#$89   ; clear SEL and data bus assertion
          clr.w     d0        ; return ok!
          rts

**************************************************************************
**************************************************************************

scsistat: wscsi     #3,#$8b   ; status in phase
          rscsi     #$8f,d0   ; clear potential interrupt
          
          w4req
          bmi       sst1                ; branch on no hand shake           
          clr.w     d0
          rscsi     #$88,d0
          andi.w    #$ff,d0
          move.w    d0,-(sp)            ; push status on stack
          doack

          w4req
          bmi.s     sst0                ; branch on no hand shake
          rscsi     #$88,d3
          andi.w    #$ff,d3             ; get message byte
          doack

          move.w    (sp),d1             ; copy status byte
          bne.s     scsi_err
          move.w    (sp)+,d1            ; recall status byte
          move.l    #0,d0               ; ok!
          rts                           ; end of this SCSI test
sst0:
          move.w    (sp)+,d1            ; recall status byte
sst1:     
          bra       scsilock            ; error - hand shake broke

**************************************************************************

;msg routines

scsi_err: lea       scsierr,a5          ; can't use dspmsg, has cr/lf
scsi_er0: move.b    (a5)+,d1
          cmp.b     #eot,d1
          beq       scsi_er1
          bsr       ascii_out
          bra       scsi_er0
scsi_er1: bsr       dspspc
          rol.w     #8,d1               ; move status to high byte
          move.b    d3,d1               ; get msg byte back
          bsr       dspwrd              ; display it
          move.w    (sp)+,d0            ; recall status byte
          rts                           ; end of this SCSI test

scsilock: lea       scsilck,a5          ; no scsi?
          bsr       dspmsg
          move.l    #$ff,d0
          rts
scsicdma: lea       scscdma,a5
          bsr       dspmsg
          rts
scsistop: lea       csistop,a5
          bsr       dspmsg
          moveq.l   #$ff,d0
          wscsi     #0,#$89
          rts
scsibusy: lea       csibusy,a5
          bsr       dspmsg
          moveq.l   #$ff,d0
          wscsi     #0,#$89
          rts
scsinblk: lea       scscnblk,a5
          moveq.l   #$ff,d0
          bsr       dspmsg
          rts

**********************
* EX-MACROS

w4reqold:
.1:     rscsi      #$8c,d6
          btst      #5,d6
          bne.s     .2
          bsr       wait
          move.w    wdc,d6
          btst      #5,d6
          bne.s     .2
          moveq.l   #$ff,d6
          bra.s     .3
.2:     moveq.l   #$0,d6
.3:     nop
        rts

doackold:
         wscsi      d6,#$89
          ori.b     #$11,d6
          move.w    d6,wdc
          andi.b    #$ef,d6
          move.w    d6,wdc
        rts

hshakeold:
         w4req
          bmi.s     .1
          move.w    #$88,wdl  ; select reg. 0
          move.w    d0,wdc
         doack
          moveq.l   #$0,d6
.1:     nop
        rts

rstdelayold:
          tst.b     gpip
          tst.b     gpip
          tst.b     gpip
          tst.b     gpip
        rts

          .data

scsierr:  dc.b  'ERROR  - SCSI STATUS CODE -  ',eot
csibusy:  dc.b  'ERROR  - TIME OUT - SCSI BUS ALWAYS BUSY      ',eot
csistop:  dc.b  'ERROR  - CANNOT SELECT SCSI DISK -  ',eot
scsilck:  dc.b  'ERROR DMA MODE -5380 OR SCSI DISK IS NOT RESPONDING-  ',eot
scscdma:  dc.b  'ERROR DMA MODE -READ AND WRITE BUFFERS DO NOT COMPARE- ',eot
scsi0msg: dc.b  'SCSI test',eot
scscnblk:  dc.b  '  ERROR - DMA BLOCK MOVE TIME OUT',cr,lf,eot



