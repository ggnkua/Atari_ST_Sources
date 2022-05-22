;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
;                                                               ;
;                       Pro-Pack Ver 2.0                        ;
;                                                               ;
;                (C) E.S.D. and Russ Payne '90                  ;
;                                                               ;
;       Original Version by Russ Payne - 21/5/89                ;
;                                                               ;
;       Version 2.0 By Stewart Gilray and Russ Payne - 13/5/90  ;
;                                                               ;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
;                                                               ;
;       Other Extras over Ver 1.0 :-                            ;
;                                                               ;
;       1. Pack Program files...                                ;
;       2. Pack data files...                                   ;
;       3. De-pack Data files...                                ;
;       4. Packs Data files into Program files...               ;
;       5. STE - TOS 1.4 Compatible...                          ;
;                                                               ;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;

		opt	o+,ow-,c-

main:
                movea.l 4(sp),a6
                lea     mystack(pc),sp
;
; release memory back to dos
;
                move.l  $0c(a6),d0      ;text size
                add.l   $14(a6),d0      ;data size
                add.l   $1c(a6),d0      ;bss  size
                add.l   #$0100,d0       ;basepage size
                move.l  d0,-(sp)
                move.l  a6,-(sp)        ;address
                clr.w   -(sp)
                move.w  #$4a,-(sp)      ;mshrink
                trap    #1
                lea     12(sp),sp
;
; see how much memory we have free
;
                moveq   #-1,d0          ;
                move.l  d0,-(sp)        ;ask for all memory
                move.w  #$48,-(sp)      ;malloc
                trap    #1              ;
                addq.w  #6,sp           ;
                and.b   #$fc,d0         ;round down
                move.l  d0,freemem      ;save this value
;
; allocate all this just for us
;
                move.l  freemem(pc),-(sp) ;
                move.w  #$48,-(sp)      ;ask for this number
                trap    #1              ;of bytes
                addq.w  #6,sp           ;
                addq.l  #2,d0           ;ensure word boundary
                and.b   #$fe,d0         ;
                move.l  d0,baseadr      ;save address
;
; supervisor mode
;
                clr.l   -(sp)           ;supervisor mode on
                move.w  #$20,-(sp)
                trap    #1
                addq.w  #6,sp
                move.l  d0,savereg

                pea     moff(pc)        ;mouse off
                clr.w   -(sp)
                move.w  #25,-(sp)
                trap    #14
                addq.l  #8,sp
                dc.w $a00a

                move.w  #4,-(sp)        ;get resolution
                trap    #14
                addq.l  #2,sp
                move.w  d0,oldrez
                move.l  $044e.w,oldscr
;why it's not used        move.l  #$70000,screen

                movem.l $ffff8240.w,d0-d7 ;set colors
                movem.l d0-d7,oldpal

;-------------------
; JMP into main part of PROPACK V2.0

                bsr     mainmenu

;-------------------
; EXIT from PROPACK V2.0

exit:           movem.l oldpal(pc),d0-d7 ;old colors back
                movem.l d0-d7,$ffff8240.w
                move.w  oldrez(pc),-(sp) ;old resolution back
                move.l  oldscr(pc),-(sp)
                move.l  oldscr(pc),-(sp)
                move.w  #5,-(sp)
                trap    #14
                adda.l  #12,sp

                pea     mon(pc)         ;mouse on
                clr.w   -(sp)
                move.w  #25,-(sp)
                trap    #14
                addq.l  #8,sp
                dc.w $a009

                move.l  savereg(pc),-(sp) ;leave supervisor
                move.w  #$20,-(sp)
                trap    #1
                addq.l  #6,sp

                clr.w   -(sp)           ;sayonara!
                trap    #1

oldrez:         dc.w 0
oldscr:         dc.l 0
savereg:        dc.l 0
;not used ... screen  dc.l    0
oldpal:         ds.w 16
mon:            dc.b $08
moff:           dc.b $12
                ds.b 2048
mystack:        dc.l 0

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
;                                                               ;
;                       Main Menu code etc                      ;
;                                                               ;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;

mainmenu:
                lea     maintext(pc),a0
                bsr     print

keys1:          move.w  #$ff,-(sp)
                move.w  #$06,-(sp)
                trap    #1
                adda.l  #$04,sp
                swap    d0

                cmpi.b  #$02,d0
                beq.s   prgpak
                cmpi.b  #$03,d0
                beq     datpak
                cmpi.b  #$04,d0
                beq     unpakdat
                cmpi.b  #$05,d0
                beq.s   credits
                cmpi.b  #$06,d0
                beq     exit
                bra.s   keys1

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
;                                                               ;
;                       Credits screen...                       ;
;                                                               ;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;

credits:        lea     credtext(pc),a0
                bsr     print

                move.w  #7,-(sp)        ;Wait for a key
                trap    #1
                addq.l  #2,sp

                bsr.s   mainmenu

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
;                                                               ;
;                         Packers etc                           ;
;                                                               ;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;

;---------------------------;
; Program Packer....        ;
;---------------------------;

prgpak:         lea     prgtext(pc),a0
                bsr     print

keys2:          move.w  #$ff,-(sp)
                move.w  #$06,-(sp)
                trap    #1
                adda.l  #$04,sp
                swap    d0

                cmpi.b  #$02,d0
                beq.s   filenme1
                cmpi.b  #$03,d0
                beq.s   pakprg
                cmpi.b  #$04,d0
                beq.s   mainmenu
                bra.s   keys2

filenme1:
                lea     prgfile(pc),a0
                bsr     print

                lea     prgfilenme(pc),a0
                move.b  #40,(a0)
                pea     (a0)
                move.w  #$0a,-(sp)
                trap    #1
                addq.l  #6,sp
;
; fix returned string
;
                lea     prgfilenme+1(pc),a0
                clr.w   d0
                move.b  (a0)+,d0
                subq.w  #1,d0
                bmi.s   .zerolen
.copyname:      move.b  (a0)+,-3(a0)
                dbra    d0,.copyname
.zerolen:       clr.b   -2(a0)

                bra.s   prgpak

;--------------------------------
; Lets Pak that file....

pakprg:         lea     pakmess(pc),a0
                bsr     print
                lea     prgfilenme(pc),a0
                bsr     print

                lea     crlf(pc),a0
                bsr     print

                lea     prgfilenme(pc),a0
                bsr     readfile
                bmi     prgpak

                lea     notprogram(pc),a0
                movea.l baseadr(pc),a1
                cmpi.w  #$601a,(a1)
                bne     ooops

                bsr     partition
                bsr     initbitpack
                bsr     initsearch
                movea.l srcend(pc),a0
                bsr     pack
                bsr     flushbits
                move.l  srcend(pc),d0
                sub.l   srcstr(pc),d0
                addq.l  #1,d0
                move.l  pakend(pc),d1
                sub.l   a6,d1
                movem.l d0-d1,-(a6)     ;save sizes
                move.l  a6,pakstr

                move.l  pakend(pc),d6
                sub.l   pakstr(pc),d6
                add.l   #pakprog-start,d6
                move.l  d6,headertext   ;new text size
                bsr     encode

                bsr     prgsave

                clr.w   -(sp)
                pea     prgfilenme(pc)
                move.w  #$3c,-(sp)
                trap    #1
                addq.w  #8,sp
                move.w  d0,d7           ;save filehandle
                bmi     prgpak          ;failed to open file!
                pea     headerblock(pc)
                pea     pakprog-headerblock
                move.w  d7,-(sp)        ;filehandle
                move.w  #$40,-(sp)      ;
                trap    #1              ;
                lea     12(sp),sp       ;
                move.l  pakstr(pc),-(sp) ;buffer address
                move.l  d6,-(sp)        ;number of bytes
                move.w  d7,-(sp)        ;filehandle
                move.w  #$40,-(sp)      ;
                trap    #1              ;
                lea     12(sp),sp       ;
                move.l  d0,-(sp)
                move.w  d7,-(sp)        ;close file
                move.w  #$3e,-(sp)      ;
                trap    #1              ;
                addq.w  #4,sp           ;
                move.l  (sp)+,d0

                lea     completed(pc),a0

ooops:          bsr     print
                move.w  #7,-(sp)        ;Wait for a key
                trap    #1
                addq.l  #2,sp
                bra     prgpak

;-------------------------------;
; Data file packer...           ;
;-------------------------------;

datpak:         lea     dattext(pc),a0
                bsr     print

keys3:          move.w  #$ff,-(sp)
                move.w  #$06,-(sp)
                trap    #1
                adda.l  #$04,sp
                swap    d0

                cmpi.b  #$02,d0
                beq.s   filenme2
                cmpi.b  #$03,d0
                beq.s   pakdat
                cmpi.b  #$04,d0
                beq     mainmenu
                bra.s   keys3

filenme2:
                lea     datfile(pc),a0
                bsr     print

                lea     datfilenme(pc),a0
                move.b  #40,(a0)
                pea     (a0)
                move.w  #$0a,-(sp)
                trap    #1
                addq.l  #6,sp
;
; fix returned string
;
                lea     datfilenme+1(pc),a0
                clr.w   d0
                move.b  (a0)+,d0
                subq.w  #1,d0
                bmi.s   zerolen1
copyname1:      move.b  (a0)+,-3(a0)
                dbra    d0,copyname1
zerolen1:       clr.b   -2(a0)

                bra.s   datpak

;--------------------------------
; Lets Pak that Data-file....

pakdat:         lea     pakmess(pc),a0
                bsr     print
                lea     datfilenme(pc),a0
                bsr     print

                lea     crlf(pc),a0
                bsr     print

                lea     datfilenme(pc),a0
                bsr     readfile
                bmi     prgpak

                bsr     partition
                bsr     initbitpack
                bsr     initsearch
                movea.l srcend(pc),a0
                bsr     pack
                bsr     flushbits
                move.l  srcend(pc),d0
                sub.l   srcstr(pc),d0
                addq.l  #1,d0
                move.l  pakend(pc),d1
                sub.l   a6,d1
                movem.l d0-d1,-(a6)     ;save sizes
                move.l  a6,pakstr

                move.l  pakend(pc),d6
                sub.l   pakstr(pc),d6
;               add.l   #pakprog-start,d6

                bsr     datsave

                clr.w   -(sp)
                pea     datfilenme(pc)
                move.w  #$3c,-(sp)
                trap    #1
                addq.w  #8,sp
                move.w  d0,d7           ;save filehandle
                bmi     datpak          ;failed to open file!
                move.l  pakstr(pc),-(sp) ;buffer address
                move.l  d6,-(sp)        ;number of bytes
                move.w  d7,-(sp)        ;filehandle
                move.w  #$40,-(sp)      ;
                trap    #1              ;
                lea     12(sp),sp       ;
                move.l  d0,-(sp)
                move.w  d7,-(sp)        ;close file
                move.w  #$3e,-(sp)      ;
                trap    #1              ;
                addq.w  #4,sp           ;
                move.l  (sp)+,d0

                lea     completed(pc),a0
                bsr     print

                move.w  #7,-(sp)        ;Wait for a key
                trap    #1
                addq.l  #2,sp
                bra     datpak

;------------------------;
; Data file De-packer... ;
;------------------------;

unpakdat:       lea     undattext(pc),a0
                bsr     print

keys4:          move.w  #$ff,-(sp)
                move.w  #$06,-(sp)
                trap    #1
                adda.l  #$04,sp
                swap    d0

                cmpi.b  #$02,d0
                beq.s   filenme3
                cmpi.b  #$03,d0
                beq.s   datunpak
                cmpi.b  #$04,d0
                beq     mainmenu
                bra.s   keys4

filenme3:
                lea     undatfile(pc),a0
                bsr     print

                lea     undatfilenme(pc),a0
                move.b  #40,(a0)
                pea     (a0)
                move.w  #$0a,-(sp)
                trap    #1
                addq.l  #6,sp
;
; fix returned string
;
                lea     undatfilenme+1(pc),a0
                clr.w   d0
                move.b  (a0)+,d0
                subq.w  #1,d0
                bmi.s   zerolen2
copyname2:      move.b  (a0)+,-3(a0)
                dbra    d0,copyname2
zerolen2:       clr.b   -2(a0)

                bra.s   unpakdat


;--------------------------------
; Lets Un-Pak that Data-file....

datunpak:       lea     unpakmess(pc),a0
                bsr     print
                lea     undatfilenme(pc),a0
                bsr     print

                lea     crlf(pc),a0
                bsr     print

                lea     undatfilenme(pc),a0
                bsr.s   readfile
                bmi     unpakdat

                movea.l baseadr(pc),a0
                lea     safearea(a0),a1
                pea     (a1)
                move.l  (a0),-(sp)
                bsr     unpack
                move.l  (sp)+,d6
                move.l  (sp)+,d5

                clr.w   -(sp)
                pea     undatfilenme(pc)
                move.w  #$3c,-(sp)
                trap    #1
                addq.w  #8,sp
                move.w  d0,d7           ;save filehandle
                bmi     unpakdat        ;failed to open file!
                move.l  d5,-(sp)        ;buffer address
                move.l  d6,-(sp)        ;number of bytes
                move.w  d7,-(sp)        ;filehandle
                move.w  #$40,-(sp)      ;
                trap    #1              ;
                lea     12(sp),sp       ;
                move.w  d0,-(sp)
                move.w  d7,-(sp)        ;close file
                move.w  #$3e,-(sp)      ;
                trap    #1              ;
                addq.w  #4,sp           ;

                lea     completed(pc),a0
                bsr.s   print

                move.w  #7,-(sp)        ;Wait for a key
                trap    #1
                addq.l  #2,sp
                bra     unpakdat


;
; read a file
;       a0 = pointer to filename
;       baseadr = load address
; returns
;       filesize
;
readfile:       clr.w   -(sp)
                pea     (a0)            ;filename
                move.w  #$3d,-(sp)
                trap    #1
                lea     8(sp),sp
                move.w  d0,d7
                bpl.s   .ok
                lea     openfailed(pc),a0
                bsr.s   print
                move.w  #7,-(sp)        ;Wait for a key
                trap    #1
                addq.l  #2,sp
                bra     mainmenu
.ok:            move.l  baseadr(pc),-(sp)
                move.l  freemem(pc),-(sp)
                move.w  d7,-(sp)
                move.w  #$3f,-(sp)      ;read data
                trap    #1
                lea     12(sp),sp
                move.l  d0,filesize     ;save number of bytes
                move.w  d7,-(sp)
                move.w  #$3e,-(sp)
                trap    #1
                addq.w  #4,sp
                rts

;-----------------------
; Print Routine

print:          pea     (a0)
                move.w  #9,-(sp)
                trap    #1
                addq.w  #6,sp
                rts
;
; setup memory partitions ...
;
; baseadr = start of free memory
; freemem = number of bytes of free memory
; filesize = size of original file
;

partition:      move.l  baseadr(pc),d0  ;start
                move.l  d0,srcstr       ;
                add.l   filesize(pc),d0 ;end of source+1
                subq.l  #1,d0           ;
                move.l  d0,srcend       ;
                addq.l  #4,d0           ;next word aligned boundary
                and.l   #$fffffffc,d0   ;for packed data
                move.l  d0,pakstr       ;
                add.l   #65536,d0       ;gives end of packed bit
                move.l  d0,pakend       ;
                addq.l  #4,d0           ;then we have the free bit
                move.l  d0,wrkstr       ;used as workspace
                sub.l   baseadr(pc),d0  ;number of bytes used
                move.l  freemem(pc),d1  ;
                sub.l   d0,d1           ;number remaining
                add.l   wrkstr(pc),d1   ;+ start
                move.l  d1,wrkend       ;
                rts

pack:           move.b  (a0),d0         ;
                bsr     search          ;found a group?
                bne.s   foundgroup      ;
;
; found unique data which we cannot create from elsewhere
;
                movea.l a0,a3           ;save this position
                moveq   #0,d5           ;
uniqueloop:     bsr     update          ;
                addq.w  #1,d5           ;count this byte
                cmp.w   #$ffff,d5       ;full 16 bits?
                beq.s   uniquefull      ;
                cmpa.l  srcstr(pc),a0   ;are we at the start?
                ble.s   uniquestart     ;
                move.b  -(a0),d0        ;fetch next byte
                bsr     search          ;
                beq.s   uniqueloop      ;
;
; write string of bytes to the output area
;
                bsr.s   copyout         ;
;
; found a group of data
;
foundgroup:     moveq   #0,d5           ;reset counter
                movea.l a2,a3           ;
                suba.l  a0,a3           ;
grouploop:      bsr     update          ;update tables
                addq.w  #1,d5           ;
                cmp.w   #$ffff,d5       ;full 16 bits?
                beq.s   copyfull        ;
                cmpa.l  srcstr(pc),a0   ;are we at the start?
                ble.s   copystart       ;
                move.b  -(a0),d0        ;fetch next
                cmp.b   -(a2),d0        ;
                beq.s   grouploop       ;
;
; end of run
;
                bsr.s   copyfrom        ;
                bra.s   pack            ;round for some more
;
; 65535 bytes of data from source!
;
uniquefull:     bsr.s   copyout         ;finish off
                move.b  -(a0),d0        ;read next
                bra.s   pack            ;and re-evaluate
;
; 65535 bytes of data from move
;
copyfull:       bsr.s   copyfrom        ;finish off
                move.b  -(a0),d0        ;read next
                bra.s   pack            ;and re-evaluate
;
; reached start of source during simple copy
;
uniquestart:    bsr.s   copyout         ;finish off
                rts                     ;
;
; reached start of source during move
;
copystart:      bsr.s   copyfrom        ;finish off
                rts                     ;
;
copyfrom:
                moveq   #1,d0           ;write a one bit
                bsr.s   putbit          ;
                move.w  a3,d0           ;offset
                bsr.s   putnum          ;
                move.w  d5,d0           ;number
;               subq.w  #3,d0           ;count must be >3
                bsr.s   putnum          ;
                bsr     progress        ;update progress report
                rts                     ;
;
copyout:        moveq   #0,d0           ;write a zero bit
                bsr.s   putbit          ;
                move.w  d5,d0           ;number of bytes
                bsr.s   putnum          ;
copyout1:       move.b  (a3),d0         ;
                bsr.s   putbyte         ;
                subq.w  #1,a3           ;move down
                subq.w  #1,d5           ;
                bne.s   copyout1        ;
                bsr     progress        ;update progress report
                rts

;--------------------------------------------------------------------------
; procedure:            initbitpack
; description:          initializes the bit packing output routine
;
; exit:
;       d6.w = count for number of bits held in d7.l
;       d7.l = working storage for bits written
;
;--------------------------------------------------------------------------

initbitpack:
                moveq   #0,d7           ;clear workspace
                moveq   #32,d6          ;space for 32 bits
                movea.l pakend(pc),a6   ;
                rts                     ;

;--------------------------------------------------------------------------
; procedure:            putbit
; description:          writes a single bit into the output data area
;
; entry:
;       d0.l = bit 0 is the bit to be used
;       d6.w = count for number of bits held in d7.l
;       d7.l = working storage for bits written
;       a6.l = pointer to packed data memory
;       (pakstr).l = pointer to start of packed data memory
;
;--------------------------------------------------------------------------

putbit:
                roxr.l  #1,d0           ;carry = bit0
                addx.l  d7,d7           ;into work reg
                subq.w  #1,d6           ;count of # of bits
                beq.s   putbit1         ;need new block
                rts                     ;
putbit1:        move.l  d7,-(a6)        ;store data
                moveq   #0,d7           ;clear bits
                moveq   #32,d6          ;32 bits free
;               cmpa.l  a0,a6           ;
;               ble.s   nomemerr        ;fullup?
                rts                     ;
;nomemerr:      lea     nomemory(pc),a0 ;error message
;               bra     syserr          ;and abort

;--------------------------------------------------------------------------
; procedure:            putnum
; description:          writes a number to the output area (16 bits max)
;
; entry:
;       d0.l = number to be written
;
; exit:
;       output area numbers coded as follows:
;
;               0 0  -  4 bit number follows
;               0 1  -  8 bit number follows
;               1 0  - 12 bit number follows
;               1 1  - 16 bit number follows
;
;       all numbers are unsigned quantities
;
;--------------------------------------------------------------------------

putnum:
                move.w  d0,d2
                cmp.w   #16,d0          ;0-15
                bcs.s   .put4
                cmp.w   #256,d0         ;0-255
                bcs.s   .put8
                cmp.w   #4096,d0        ;0-4095
                bcs.s   .put12
;
; output a 16 bit number
;
.put16:         moveq   #%11,d0         ;11 = (3)
                moveq   #16-1,d1        ;16 bits
                bra.s   .putno
.put12:         moveq   #%1,d0          ;10 = (2)
                moveq   #12-1,d1        ;12 bits
                bra.s   .putno
.put8:          moveq   #%10,d0         ;01 = (1)
                moveq   #8-1,d1         ;8 bits
                bra.s   .putno
.put4:          moveq   #%0,d0          ;00 = (0)
                moveq   #4-1,d1
;
; d0 = 2 bits of header
; d1 = number of bits to write less one
; d2 = actual number to write
;
.putno:         bsr.s   putbit          ;2 header bits
                bsr.s   putbit
.put16loop:     btst    d1,d2
                sne     d0              ;set bit 0 in D0
                bsr.s   putbit
                dbra    d1,.put16loop
                rts

;--------------------------------------------------------------------------
; procedure:            putbyte
; description:          writes a bytes worth of bits to output area
;
; entry:
;       d0.b = bits to be written
;
;--------------------------------------------------------------------------

putbyte:
                moveq   #8-1,d1
                move.b  d0,d2
.ploop:         btst    d1,d2
                sne     d0
                bsr.s   putbit
                dbra    d1,.ploop
                rts

;--------------------------------------------------------------------------
; procedure:            flushbits
; description:          writes any remaining bits in work register
;
; entry:
;       d6.w = count for number of bits held in d7.l
;       d7.l = working storage for bits written
;       a6.l = pointer to packed data memory
;
;--------------------------------------------------------------------------

flushbits:      cmp.w   #32,d6          ;started new block?
                bne.s   flush1          ;no...needs fixing
                rts                     ;
flush1:         moveq   #0,d0           ;pad with zero's
                bsr.s   putbit          ;
                cmp.w   #32,d6          ;just written it?
                bne.s   flush1          ;no...send another
                rts                     ;

;--------------------------------------------------------------------------
; procedure:            initsearch
; description:          initialize search data areas
;
; exit:
;       lookup table of 256 pointers into workspace
;       count table of 256 longs containing how many entries used
;
; exit:
;       a4 = pointer to lookup table
;       a5 = pointer to counts table
;
;--------------------------------------------------------------------------

initsearch:     move.l  wrkend(pc),d0
                sub.l   wrkstr(pc),d0   ;# of free bytes
                lsr.l   #8,d0
                lsr.l   #2,d0           ;d0 = entries per byte key
                move.l  d0,d1
                asl.l   #2,d1           ;d1 = bytes per entry
                move.l  d1,off2next
                move.l  wrkstr(pc),d2
                lea     runadr(pc),a3
                lea     lookup(pc),a4   ;initialize both the
                lea     counts(pc),a5   ;count and lookup tables
                move.w  #256-1,d3
s1:             clr.l   (a3)+
                move.l  d2,(a4)+        ;point at blanks
                clr.l   (a5)+           ;zero entries used
                add.l   d1,d2
                dbra    d3,s1
                lea     lookup(pc),a4
                lea     counts(pc),a5   ;return registers
                rts

;--------------------------------------------------------------------------
; procedure:            update
; description:          update tables to account for new data item
;
; entry:
;       a0.l = address of this data byte
;       a4.l = pointer to lookup table
;       a5.l = pointer to counts table
;
;--------------------------------------------------------------------------

update:         moveq   #0,d0
                move.b  (a0),d0         ;convert to unsigned word
                add.w   d0,d0           ;and multiply by 4
                add.w   d0,d0
                move.l  0(a5,d0.w),d1   ;offset to next entry
                cmp.l   off2next(pc),d1
                beq.s   u1              ;jump if all used!
;
; space in table, so simply store pointer and increment offset
;
                movea.l 0(a4,d0.w),a1   ;ptr to table
                move.l  a0,0(a1,d1.l)   ;store position
                addq.l  #4,d1           ;move to next
                move.l  d1,0(a5,d0.w)   ;update offset
                rts
;
; table full, so shuffle elements forwards and fill in the next one
;
u1:             addq.w  #1,a0
                lea     runadr(pc),a1
                cmpa.l  0(a1,d0.w),a0
                beq     runlen
                subq.w  #1,a0
                move.l  a0,0(a1,d0.w)
addadr:         movea.l 0(a4,d0.w),a1
                move.l  d1,d2
                asr.l   #6,d1           ;/(16*4)
                and.w   #60,d2
                neg.w   d2
                jmp     .next(pc,d2.w)
.loop:          
		rept 16
                move.l  4(a1),(a1)+     ;4 bytes per instruction
                endr
.next:          dbra    d1,.loop
                move.l  a0,-(a1)        ;replace last entry
;
; do a little tidy, if the first entry in the table is >65535 away
;
cleanup:        movea.l 0(a4,d0.w),a1   ;ptr to 1st
                move.l  (a1),d1         ;
                sub.l   a0,d1           ;find distance
                cmp.l   #$ffff,d1       ;
                bcc.s   cu4             ;jump if out of range
                rts
;
; remove first entry from table
;
cu4:            move.l  0(a5,d0.w),d1   ;offset to last
                add.l   a1,d1           ;actual addr of last
cu5:            move.l  4(a1),(a1)+     ;overwrite 1st with 2nd
                cmp.l   a1,d1           ;reached end yet?
                bne.s   cu5             ;
                subq.l  #4,0(a5,d0.w)   ;count down
                bne.s   cleanup         ;some left?
                rts                     ;
;
; runlength of same bytes
;
runlen:         subq.w  #1,a0
                move.l  a0,0(a1,d0.w)   ;for next time
                move.b  (a0),d0
                cmp.b   -1(a0),d0       ;end of a run?
                beq.s   ignore          ;yep...add this address
                and.w   #$ff,d0
                add.w   d0,d0           ;could re-arrange
                add.w   d0,d0           ;better
                bra     addadr
ignore:         rts

;--------------------------------------------------------------------------
; procedure:            search
; description:          search for pattern of bytes
;
; entry:
;       d0.b = byte to index from
;       a0.l = address of this data byte
;       a4.l = pointer to lookup table
;       a5.l = pointer to counts table
;
; exit:
;       zero = not found
;       non-zero = found
;
;--------------------------------------------------------------------------

search:
                and.w   #$ff,d0         ;convert to unsigned word
                add.w   d0,d0           ;and multiply by 4
                add.w   d0,d0
                move.l  0(a5,d0.w),d1   ;fetch counter
                bne.s   s11             ;jump if some entries
                rts
s11:            bsr.s   cleanup
                move.l  0(a5,d0.w),d1   ;fetch new number
                bne.s   search1
                rts
;
; ok entry has some values
;
search1:        movea.l 0(a4,d0.w),a1   ;start of table
                add.l   a1,d1
                exg     a1,d1           ;d1=start a1=end
                move.l  d1,s5+2
                move.b  -1(a0),d1
                move.b  -2(a0),d2
                move.b  -3(a0),d3       ;search for these
                moveq   #0,d0
                moveq   #0,d4           ;max found so far
s2:             movea.l -(a1),a2
                cmp.b   -(a2),d1        ;found one?
                beq.s   s7
s5:             cmpa.l  #$12345678,a1
                bne.s   s2              ;reached start?
                movea.l d0,a2
                tst.l   d0              ;set flags
                rts
s7:             cmp.b   -(a2),d2        ;found two?
                bne.s   s5
                cmp.b   -(a2),d3
                bne.s   s5
                suba.l  a0,a2
                cmpa.l  #$ffff-4,a2     ;out of range?
                bcc.s   s5
                lea     3(a0,a2.l),a2
                swap    d2
                swap    d3
                move.w  #-3,d2
s3:             move.b  0(a0,d2.w),d3   ;count number of
                cmp.b   0(a2,d2.w),d3   ;bytes that are same
                bne.s   s8
                subq.w  #1,d2
                bmi.s   s3
;
; more than 32768 same! use this now
;
                moveq   #1,d0           ;return found
                rts
;
; remember max and position thereof
;
s8:             neg.w   d2              ;get number
                cmp.w   d4,d2
                ble.s   s4
                move.l  a2,d0           ;store pointer
                move.w  d2,d4           ;and counter
s4:             swap    d2
                swap    d3              ;restore d2 and d3
                bra.s   s5

;--------------------------------------------------------------------------
; procedure:            progress
; description:          keep user happy with a progress report
;
; enter:
;
;--------------------------------------------------------------------------

progress:       eori.w  #$4e71^$4e75,slow
slow:           nop                     ;not in ROM anyway
                movem.l d0-a6,-(sp)
                suba.l  srcstr(pc),a0
                move.l  a0,d0
                lea     togo_n(pc),a0
                bsr.s   numout
                lea     togo_m(pc),a0
                bsr     print
                movem.l (sp)+,d0-a6
                rts

;--------------------------------------------------------------------------
; procedure:            numout
; description:          convert number to ascii digits
;
; entry:
;       d0.l = number
;       a0.l = address to store number
;
; exit:
;       10 ascii decimal equivalent of unsigned 32 bit number held in d0.l
;
;--------------------------------------------------------------------------

numout:
                lea     x10(pc),a1      ;lookup table for decimal
n1:             moveq   #'0'-1,d1
n2:             addq.w  #1,d1
                sub.l   (a1),d0         ;count down
                bcc.s   n2
                add.l   (a1)+,d0
                move.b  d1,(a0)+        ;store ascii
                tst.l   (a1)
                bne.s   n1
                or.b    #'0',d0         ;finish last digit
                move.b  d0,(a0)         ;as special case
                suba.w  #9,a0
                moveq   #8,d0
n3:             cmpi.b  #'0',(a0)+
                bne.s   n4
                move.b  #'_',-1(a0)
                dbra    d0,n3
n4:             rts

x10:            dc.l 1000000000
                dc.l 100000000
                dc.l 10000000
                dc.l 1000000
                dc.l 100000
                dc.l 10000
                dc.l 1000
                dc.l 100
                dc.l 10
                dc.l 0

;=========================================================================
;
;  HEADER ATTACTED TO THE START OF THE PACKED PROGRAM
;
;=========================================================================
;
; starts here
;
headerblock:    dc.w $601a
headertext:     dc.l pakprog-start ;text size
headerdata:     dc.l 0          ;data size
headerbss:      dc.l 0          ;bss size
headersym:      dc.l 0          ;symbol size
                dc.l 0
                dc.l 1          ;fast load on TOS 1.4
                dc.w $ffff      ;zero if no reloc-stuff
;
; equates
;
code1           equ $a5e3       ;mustn't change the codes
code2           equ $a3d7       ;without a new header
safearea        equ 1024

;
; main program (speed is of the essence)
;

start:          pea     super(pc)
                move.w  #38,-(sp)
                trap    #14

super:          move.l  seed(pc),d7
                moveq   #0,d5
                lea     codestart(pc),a2
                lea     pakprog(pc),a3
                lea     xtrace(pc),a5
                move.l  a5,$24.w
                ori     #$8700,sr
                jmp     xstart-xtrace(a5)
                dc.b 0,0
                dc.b "TCC & "
seed:           dc.b "RUSS"
                dc.b 0,0
xtrace:         movea.l 2(sp),a6
                eor.l   d6,(a5)
                eor.l   d7,(a6)
                move.l  d7,d6
                movea.l a6,a5
                rte
xstart:         dc.w $baca,$63a2
                dc.w $eba2,$39cd
                dc.w $2ccd,$7d2a
                dc.w $4ddc,$a823 ;ha ha ha ha
                dc.w $a023,$b8d5
                dc.w $af23,$143b
                dc.w $b8a8,$aab0 ;arf arf arf
                dc.w $25d5,$d76d
                dc.w $aabc,$b2e3
                dc.w $b55e,$aa98
                dc.w $1ffb,$d76d
                dc.w $5561,$a523 ;(he he he)
                dc.w $b023,$e1c4
                dc.w $f412,$11ed
                dc.w $ad35,$7f56
                dc.w $874d,$7d56
                dc.w $8179,$fe30
                dc.w $9f2b,$faa1
                dc.w $2292,$19ed
                dc.w $4d16,$5d4e
codestart:      dc.w $011b,$6cc0
                movea.l $04a2.w,a0      ;find return address
                lea     super(pc),a1    ;in BIOS save area
                lea     start-2(pc),a2
.search:        cmpa.l  (a0)+,a1
                bne.s   .search
                move.l  a2,-(a0)        ;and put back to start
                move.w  #$5c4f,(a2)     ;clean up the stack
;
; unpack program
;
                bsr     do_unpack
;
; relocate to this address
;
                lea     pakprog+safearea(pc),a0
                lea     start(pc),a2

;--------------------------------------------------------------------------
; procedure:            reloc
; description:          relocate program to given address
;
; entry:
;       a0 = address of program
;       a2 = address to be run from
;
; exit:
;
;--------------------------------------------------------------------------

                tst.w   $1a(a0)         ;any reloc info?
                bne.s   noreloc
                movea.l 2(a0),a1        ;text size in bytes
                adda.l  6(a0),a1        ;data size in bytes
                adda.l  14(a0),a1       ;symbols size in bytes
                lea     $1c(a0),a0
                adda.l  a0,a1
                move.l  a2,d0           ;address for relocation
                move.l  (a1)+,d1
                beq.s   noreloc
                adda.l  d1,a0
                add.l   d0,(a0)
                moveq   #0,d1           ;this rather
                moveq   #1,d2           ;awkward arrangement
                move.b  (a1)+,d1
                beq.s   noreloc
                bra.s   doanother
bigoffset:      lea     $fe(a0),a0      ;skip 254 bytes
                move.b  (a1),d1
                clr.b   (a1)+
                tst.b   d1
                beq.s   noreloc
doanother:      cmp.b   d2,d1
                beq.s   bigoffset
                adda.l  d1,a0           ;relocate longword
                add.l   d0,(a0)         ;at given offset
getnext:        move.b  (a1),d1
                clr.b   (a1)+
                tst.b   d1
                bne.s   doanother
noreloc:
;
; fill in empty basepage variables for the new program
;
                lea     pakprog+safearea+2(pc),a0
                lea     start-256+8(pc),a1
                lea     start(pc),a2
                move.l  a2,(a1)+        ;text start address
                move.l  (a0),(a1)+      ;text size
                adda.l  (a0)+,a2
                move.l  a2,(a1)+        ;data start
                move.l  (a0),(a1)+      ;data size
                adda.l  (a0)+,a2
                move.l  a2,(a1)+        ;bss start
                move.l  (a0),(a1)+      ;bss size
                movea.l a2,a3
                adda.l  (a0),a3
;
; move program to address it's going to be run at
;
                lea     pakprog+safearea+$1c(pc),a0
                lea     start(pc),a1
                movem.l movmem(pc),d0-d7
                movem.l d0-d7,-128(sp)
                jmp     -128(sp)

movmem:         move.l  (a0)+,(a1)+     ;                       (2)
                move.l  (a0)+,(a1)+     ;                       (2)
                move.l  (a0)+,(a1)+     ;                       (2)
                move.l  (a0)+,(a1)+     ;                       (2)
                cmpa.l  a2,a1           ;copy to run address    (2)
                ble.s   movmem          ;                       (2)
                move.l  a2,d0           ;                       (2)
                lsr.l   #1,d0           ;                       (2)
                bcc.s   clrmem          ;                       (2)
                clr.b   (a2)+           ;                       (2)
clrmem:         clr.l   (a2)+           ;clear bss segment      (2)
                clr.l   (a2)+           ;                       (2)
                cmpa.l  a3,a2           ;                       (2)
                ble.s   clrmem          ;                       (2)
                rts                     ;and exec program       (2)

;--------------------------------------------------------------------------
; procedure:            unpack
; description:          unpacks data
;
; note that unpacking works from the 'end' back to the start, this
; allows for the two areas to overlap. in fact if the data has a repeated
; block at the start, then the destination area can be the same has the
; packed area! the current gap of 1024 bytes has proved sufficient for
; all of the programs that i have tried so far
;
; entry:
;       a0 = pointer to packed data
;       a1 = pointer to memory to place unpacked data
;
; exit:
;       most registers destroyed
;
; important: must be executed in supervisor mode
;
;--------------------------------------------------------------------------

getbit:         add.l   d7,d7
                bne.s   isnot0
                move.l  -(a0),d7
                addx.l  d7,d7
isnot0:         rts

do_unpack:      lea     pakprog(pc),a0
                lea     pakprog+safearea(pc),a1

unpack:         moveq   #0,d2
                moveq   #0,d4
                moveq   #7,d5
                movea.l a1,a2
                adda.l  (a0)+,a1        ;work from end to start
                adda.l  (a0)+,a0
                lea     getnum(pc),a5   ;faster than bsr
                move.l  -(a0),d7        ;read long      14
                add.l   d7,d7           ;carry = bit15  8
                bset    d4,d7           ;               <8
                bcs.s   dorun
unique:         jsr     (a5)            ;read number of bytes
                move.w  d0,d2
                move.w  d0,d3
                subq.w  #1,d2
getbyte:        clr.w   d0
                rept 8
                bsr.s   getbit
                addx.w  d0,d0           ;1
                endr
                move.b  d0,-(a1)        ;copy to unpacked data
                dbra    d2,getbyte
                cmpa.l  a2,a1
                ble.s   exitunpack
mainunpack:     bsr.s   getbit
                bcc.s   unique
dorun:          jsr     (a5)            ;read offset
                move.w  d0,d2
                jsr     (a5)
                move.w  d0,d3
                lsr.w   #3,d3
                and.w   d5,d0
                add.w   d0,d0
                add.w   d0,d0
                neg.w   d0
                jmp     cop(pc,d0.w)
cop8:           
		rept 8
                move.b  -1(a1,d2.l),-(a1)
                endr
cop:            dbra    d3,cop8
                cmpa.l  a2,a1
                bgt.s   mainunpack
exitunpack:     rts

;--------------------------------------------------------------------------
; procedure:            getnum
; description:          read number from packed data
;
; entry:
;       0 0 = 4  bits
;       0 1 = 8  bits
;       1 0 = 12 bits
;       1 1 = 16 bits
;       followed bit number (bits in reverse order)
;
; exit:
;       d0.w = number
;
;--------------------------------------------------------------------------


getnum:         clr.w   d0
                clr.w   d1
                bsr     getbit
                addx.w  d1,d1
                bsr     getbit
                addx.w  d1,d1
                move.b  .numbits(pc,d1.w),d1
                jmp     get16(pc,d1.w)
.numbits:       dc.b get4-get16 ;0
                dc.b get8-get16 ;1
                dc.b get12-get16 ;2
                dc.b get16-get16 ;3
get16:          bsr     get8
get8:           bsr.s   get4
                bra.s   get4
get12:          bsr.s   get8
get4:           
		rept 4
                bsr     getbit
                addx.w  d0,d0
                endr
                rts

;--------------------------------------------------------------------------
;
;                       end of header
;
;--------------------------------------------------------------------------

pakprog:        dc.w 0

;
; encode the above loader
;
encode:         move.w  #code1,d0
                move.w  #code2,d1
                lea     codestart(pc),a2
                lea     pakprog(pc),a3
encode1:        eor.w   d0,(a2)+
                add.w   d1,d0
                cmpa.l  a3,a2
                blt.s   encode1
                rts

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
;                                   ;
;       workout savings             ;
;                                   ;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;

prgsave:        lea     crlf(pc),a0
                bsr     print

                move.l  pakend(pc),d7   ;end of work
                sub.l   pakstr(pc),d7   ;start of packed bit
                add.l   #pakprog-headerblock+4,d7 ;overhead of unpacker
                move.l  d7,d0           ;
                lea     newsize_n(pc),a0 ;
                bsr     numout          ;
                move.l  filesize(pc),d0 ;original size
                sub.l   d7,d0           ;less newsize gives
                bpl.s   smaller
                neg.l   d0
                lea     bigger_n(pc),a0
                bsr     numout
                lea     bigger_m(pc),a0
                bsr     print
                move.w  #7,-(sp)        ;Wait for a key
                trap    #1
                addq.l  #2,sp
                bra     prgpak
smaller:        lea     saving_n(pc),a0 ;saving in bytes
                bsr     numout          ;
                lea     newsize_m(pc),a0 ;
                bsr     print           ;
                rts

datsave:        lea     crlf(pc),a0
                bsr     print

                move.l  pakend(pc),d7   ;end of work
                sub.l   pakstr(pc),d7   ;start of packed bit
                move.l  d7,d0           ;
                lea     newsize_n(pc),a0 ;
                bsr     numout          ;
                move.l  filesize(pc),d0 ;original size
                sub.l   d7,d0           ;less newsize gives
                bpl.s   datsmall
                neg.l   d0
                lea     bigger_n(pc),a0
                bsr     numout
                lea     bigger_m(pc),a0
                bsr     print
                move.w  #7,-(sp)        ;Wait for a key
                trap    #1
                addq.l  #2,sp
                bra     datpak
datsmall:       lea     saving_n(pc),a0 ;saving in bytes
                bsr     numout          ;
                lea     newsize_m(pc),a0 ;
                bsr     print           ;
                rts


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
;                                                               ;
;            All Texts for all parts of ProPack V2.0            ;
;                                                               ;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;

maintext:       dc.b 27,"E                               Pro-Pack Ver 2.0",$0d,$0a
                dc.b "                           ~~~~~~~~~~~~~~~~~~~~~~~~",$0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a
                dc.b "                          1. Pack - Program files...",$0d,$0a,$0d,$0a
                dc.b "                          2. Pack - Data files...",$0d,$0a,$0d,$0a
                dc.b "                          3. De-pack - data files...",$0d,$0a,$0d,$0a
                dc.b "                          4. Credits page...",$0d,$0a,$0d,$0a
                dc.b "                          5. Exit to Desktop...",$0d,$0a
                dc.b $0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a
                dc.b "                        (C) E.S.D. and Russ Payne 1990.",$00

credtext:       dc.b 27,"E                                    Credits.",$0d,$0a
                dc.b "                                    ~~~~~~~~",$0d,$0a,$0d,$0a
                dc.b "	Original Version by Russ Payne...",$0d,$0a,$0d,$0a
                dc.b "	Version 2.0 by Stewart Gilray of E.S.D. and Russ Payne...",$0d,$0a,$0d,$0a
                dc.b "	Originally started  Sunday 21st of May 1989...",$0d,$0a,$0d,$0a
                dc.b "	Ver 2.0    started  Sunday 13th of May 1990...",$0d,$0a,$0d,$0a
                dc.b "-------------------------------------------------------------------------------",$0d,$0a,$0d,$0a
                dc.b " This next bit is not credits but infact greetings (I'm weird).",$0d,$0a,$0d,$0a
                dc.b "Keith McMurtire - Mark Jones - Richard Fox - Stuart Robertson - Graham McCann",$0d,$0a
                dc.b "Graeme Robertson - Hamish Rust - Martin McKenzie - Paul Laurence - Andy Smith",$0d,$0a
                dc.b "Steve Chalmers - Carl Andersson - Nic Alderton - Mharie - Andrew Buchanan",$0d,$0a
                dc.b "Daniel Hyland - Craig Williams - Laurence McDonald - Martin Griffiths ",$0d,$0a
                dc.b "Jose Miguel - Martin Reid - Steven Reid - Kev Holland - Grahame Hay ",$0d,$0a
                dc.b "John Cameron - Stephen Brown - Scott McCabe - Rab Walker - Ann Miller...",$0d,$0a,$0d,$0a
                dc.b "Some of the above are members of E.S.D. others are friends and colleges",$0d,$0a,$0d,$0a
                dc.b "                                 Press any key.",$00

prgtext:        dc.b 27,"E",27,"f"
                dc.b "                              Pack a Program Menu.",$0d,$0a
                dc.b "                              ~~~~~~~~~~~~~~~~~~~~",$0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a
                dc.b "                   1. Enter file name for packing...",$0d,$0a,$0d,$0a
                dc.b "                   2. Pack the file...",$0d,$0a,$0d,$0a
                dc.b "                   3. Return to main menu...",$0d,$0a
                dc.b $0d,$0a,$0d,$0a,$0d,$0a
                dc.b "       Instructions:",$0d,$0a
                dc.b "       ~~~~~~~~~~~~~",$0d,$0a,$0d,$0a
                dc.b " First enter the name of the file to be packed by pressing 1.",$0d,$0a
                dc.b " After that if you still want to pack that file press 2.",$0d,$0a
                dc.b " If not then just press 3 to return to the Main Menu.",$00

prgfile:        dc.b 27,"E",27,"e"
                dc.b $0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a
                dc.b "Please enter Name of Executable file to pack.",$0d,$0a,$0d,$0a
                dc.b " : ",$00

dattext:        dc.b 27,"E                              Pack a Data-file Menu.",$0d,$0a
                dc.b "                              ~~~~~~~~~~~~~~~~~~~~~~",$0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a
                dc.b "                   1. Enter file name for packing...",$0d,$0a,$0d,$0a
                dc.b "                   2. Pack the Data-file...",$0d,$0a,$0d,$0a
                dc.b "                   3. Return to main menu...",$0d,$0a
                dc.b $0d,$0a,$0d,$0a,$0d,$0a
                dc.b "       Instructions:",$0d,$0a
                dc.b "       ~~~~~~~~~~~~~",$0d,$0a,$0d,$0a
                dc.b " First enter the name of the Data-file to be packed by pressing 1.",$0d,$0a
                dc.b " After that if you still want to pack that Data-file press 2.",$0d,$0a
                dc.b " If not then just press 3 to return to the Main Menu.",$00

datfile:        dc.b 27,"E",$0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a
                dc.b "Please enter the Name of the Data file to be Packed.",$0d,$0a,$0d,$0a
                dc.b " : ",$00

undattext:      dc.b 27,"E                            Un-Pack a Data-file Menu.",$0d,$0a
                dc.b "                            ~~~~~~~~~~~~~~~~~~~~~~~~~",$0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a
                dc.b "                   1. Enter file name for Un-packing...",$0d,$0a,$0d,$0a
                dc.b "                   2. Un-Pack the Data-file...",$0d,$0a,$0d,$0a
                dc.b "                   3. Return to main menu...",$0d,$0a
                dc.b $0d,$0a,$0d,$0a,$0d,$0a
                dc.b "       Instructions:",$0d,$0a
                dc.b "       ~~~~~~~~~~~~~",$0d,$0a,$0d,$0a
                dc.b " First enter the name of the Data-file you want to Un-packed by pressing 1.",$0d,$0a
                dc.b " After that if you still want to Un-pack that Data-file press 2.",$0d,$0a
                dc.b " If not then just press 3 to return to the Main Menu.",$00

undatfile:      dc.b 27,"E",$0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a,$0d,$0a
                dc.b "Please enter the Name of the Data file to be Un-packed.",$0d,$0a,$0d,$0a
                dc.b " : ",$00


pakmess:        dc.b 27,"ECrunching  : ",$00

unpakmess:      dc.b 27,"EUn-Packing : ",$00

togo_m:         dc.b "Working on : "
togo_n:         dc.b "1234567890",13,0

freemem_m:      dc.b 10,13,10,13,"freememory "
freemem_n:      dc.b "1234567890 bytes",0
filesize_m:     dc.b 10,13,"filesize   "
filesize_n:     dc.b "1234567890 bytes",10,13,0
newsize_m:      dc.b "New size   "
newsize_n:      dc.b "1234567890 bytes",10,13
                dc.b $0d,$0a,"Saving is  "
saving_n:       dc.b "1234567890 bytes",10,13,10,13,0
bigger_m:       dc.b "newfile is "
bigger_n:       dc.b "1234567890 bytes bigger",10,13
                dc.b "will not save! press return to exit",10,13,0
;writing_m      dc.b    "writing to ",0
;wotnofile:     dc.b    " must give a file to compact!",10,13,0
notprogram:     dc.b " File is not a program!",10,13,0
;nofreeblocks:  dc.b    " no free blocks!",10,13,0
;nomemory:      dc.b    " not enough memory!",10,13,0
openfailed:     dc.b " could not open file!",10,13,0
crlf:           dc.b $0d,$0a,$0d,$0a,$00
;createfailed:  dc.b    " could not create file!",10,13,0
;badsavemsg:    dc.b    " could not save correct number of bytes!",10,13,0

completed:      dc.b "Completed save ... press RETURN",0

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;
;                                                               ;
;                             Data                              ;
;                                                               ;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-;

prgfilenme:     dc.b 40
                dc.b 0
                ds.b 40

datfilenme:     dc.b 40
                dc.b 0
                ds.b 40

undatfilenme:   dc.b 40
                dc.b 0
                ds.b 40

baseadr:        dc.l 0          ;ptr to free memory
freemem:        dc.l 0          ;bytes free
filesize:       dc.l 0          ;
srcstr:         dc.l 0          ;ptr to source
srcend:         dc.l 0          ;end (inclusive)
pakstr:         dc.l 0          ;ptr to pack workspace
pakend:         dc.l 0          ;end (long aligned)
wrkstr:         dc.l 0          ;ptr to workspace
wrkend:         dc.l 0          ;end (inclusive)

off2next:       dc.l 0          ;bytes to next table
lookup:         ds.l 256        ;ptrs to workspace
counts:         ds.l 256        ;count of entries / byte
runadr:         ds.l 256        ;for run eliminations
                end
