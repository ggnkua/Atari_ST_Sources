* Returns Start address of unpacked file in a0
*                            End address in a1
*                                 Lenght in d0

                lea     FILEN(pc),a0
                bsr     ICE_UNPACK
                movea.l a1,a0
                adda.w  d0,a1
                rts

ICE_UNPACK:     >PART 'ICE Packer'

* a0=address to source (and dest)
* out d0=lenght of uncrunched area if crunched... otherwize unchanged

                cmpi.l  #"Ice!",(a0)
                bne.s   NOICEATALL

                movem.l d0/a2-a3,-(a7)

                move.l  8(a0),d0        ; get size of orginal
                movea.l a0,a1
                lea     0(a0,d0.l),a0
                movea.l a0,a3
                movea.l a1,a2
                subq.l  #1,d0

DRAKULA:        move.b  (a2)+,(a3)+
                dbra    d0,DRAKULA

                movem.l (a7)+,d0/a2-a3




                bra.s   STARTICE


NOICEATALL:     rts

STARTICE:
;********************************************* Unpackroutine von ICE-PACK
; assemble with Devpac or any other Assembler
; length of this unpacking routine: 294 bytes
;  a0 = address of packed data
;  a1 = address of unpacked data
;  d0=lenght if crunched; otherwize unchaged
                movem.l d0-a6,-(a7)
                bsr.s   GET_LONG
                cmpi.l  #'Ice!',d0      ; Is file packed?
                bne.s   NOT_PACKED      ; no, leave this routine
                bsr.s   GET_LONG        ; Lenght of crunch (??)
                lea     -8(a0,d0.l),a5
                bsr.s   GET_LONG        ; Lenght of Orginal
                move.l  d0,(a7)
                movea.l a1,a4
                movea.l a1,a6
                adda.l  d0,a6
                movea.l a6,a3
                move.b  -(a5),d7
                bsr.s   ICE06
NOT_PACKED:     movem.l (a7)+,d0-a6
                rts

GET_LONG:       moveq   #3,d1           ; move 4-b to Longword
DUMMYLOOP:      lsl.l   #8,d0
                move.b  (a0)+,d0
                dbra    d1,DUMMYLOOP
                rts

ICE06:          bsr.s   ICE0A
                bcc.s   ICE09
                moveq   #0,d1
                bsr.s   ICE0A
                bcc.s   ICE08
                lea     ICE17(pc),a1
                moveq   #4,d3
ICE07:          move.l  -(a1),d0
                bsr.s   ICE0C
                swap    d0
                cmp.w   d0,d1
                dbne    d3,ICE07
                add.l   20(a1),d1
ICE08:          move.b  -(a5),-(a6)
                dbra    d1,ICE08
ICE09:          cmpa.l  a4,a6
                bgt.s   ICE0F
                rts
ICE0A:          add.b   d7,d7
                bne.s   ICE0B
                move.b  -(a5),d7
                addx.b  d7,d7
ICE0B:          rts
ICE0C:          moveq   #0,d1
ICE0D:          add.b   d7,d7
                bne.s   ICE0E
                move.b  -(a5),d7
                addx.b  d7,d7
ICE0E:          addx.w  d1,d1
                dbra    d0,ICE0D
                rts
ICE0F:          lea     ICE18(pc),a1
                moveq   #3,d2
ICE10:          bsr.s   ICE0A
                dbcc    d2,ICE10
                moveq   #0,d4
                moveq   #0,d1
                move.b  1(a1,d2.w),d0
                ext.w   d0
                bmi.s   ICE11
                bsr.s   ICE0C
ICE11:          move.b  6(a1,d2.w),d4
                add.w   d1,d4
                beq.s   ICE13
                lea     ICE19(pc),a1
                moveq   #1,d2
ICE12:          bsr.s   ICE0A
                dbcc    d2,ICE12
                moveq   #0,d1
                move.b  1(a1,d2.w),d0
                ext.w   d0
                bsr.s   ICE0C
                add.w   d2,d2
                add.w   6(a1,d2.w),d1
                bpl.s   ICE15
                sub.w   d4,d1
                bra.s   ICE15
ICE13:          moveq   #0,d1
                moveq   #5,d0
                moveq   #-1,d2
                bsr.s   ICE0A
                bcc.s   ICE14
                moveq   #8,d0
                moveq   #$3F,d2
ICE14:          bsr.s   ICE0C
                add.w   d2,d1
ICE15:          lea     2(a6,d4.w),a1
                adda.w  d1,a1
                move.b  -(a1),-(a6)
ICE16:          move.b  -(a1),-(a6)
                dbra    d4,ICE16
                bra     ICE06
                dc.b $7F,$FF,$00,$0E,$00,$FF,$00,$07
                dc.b $00,$07,$00,$02,$00,$03,$00,$01
                dc.b $00,$03,$00,$01
ICE17:          dc.b $00,$00,$01,$0D,$00,$00,$00,$0E
                dc.b $00,$00,$00,$07,$00,$00,$00,$04
                dc.b $00,$00,$00,$01
ICE18:          dc.b $09,$01,$00,$FF,$FF,$08,$04,$02
                dc.b $01,$00
ICE19:          dc.b $0B,$04,$07,$00,$01,$1F,$FF,$FF
                dc.b $00,$1F


                endpart

* Name and path to file which to uncrunch

                path 'K:\'
FILEN:          ibytes 'PREVIEW1.MED'

* Work area above file... ICE can't depack at same location so keep BIG!

                ds.w 16*1024    ; Work Area Above file
                end
