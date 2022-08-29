
; Ice unpacker by Axe of Delight.
; Optimized by Nyh
;***************************************************************************
; Unpacking source for Pack-Ice Version 2.4
; a0: Pointer on packed Data
; a1: Pointer on destination of unpacked data
; return: d0=origsize

;Mofified by Lonny Puresll for use with GFABASIC (3/26/2017)
;notes: Called via return%=C:depack%(L:src%,L:dst%)
;	$C- is not required
;	Returns original file size, or 0 if file is not ICE packed
;	Should be ok on FireBee/CF68kLib
;	Listing for Devpac

		output	ice24.inl		;+ inline
		opt	chkpc			;+ check pc relative

SRC	=	4+(4*4)+0			;+ parameter offsets
DST	=	4+(4*4)+4			;+   ..

ice_24:
decrunch:       movem.l a3-a6,-(sp)		;+ gfa needs this
		move.l	SRC(sp),a0		;+ source adr
		move.l	DST(sp),a1		;+ destination adr
                moveq	#0,d0			;+ if not ice, force 0 size
                move.l  a0,a5
                cmpi.l  #'ICE!',(a0)+           ; Is data packed?
                beq.s   go                      ; yes!
done:           movem.l (sp)+,a3-a6		;+ keep gfa happy
                rts

go:             add.l  (a0)+,a5                 ; packed size
                move.l  (a0)+,d0                ; origsize
                movea.l a1,a6
                adda.l  d0,a6
                moveq   #0,d7

depac_loop:     bsr.s   get_bit
                bcc.s   tst_end
                bsr.s   get_bit
                bcc.s   literal
                lea     len_tab(pc),a3
                moveq   #0,d4
depack_lit_len: move.w  (a3)+,d6                ; 1,1,2,7,$e
                bsr.s   get_d6_bits
                add.w   d5,d4
                cmp.w   8(a3),d5                ; 3,3,7,$ff,$8000
                beq.s   depack_lit_len
literal_loop:   move.b  -(a5),-(a6)
                dbra    d4,literal_loop
literal:        move.b  -(a5),-(a6)

tst_end:        cmpa.l  a1,a6
                ble.s   done

sld_start:      moveq   #3,d3
sld_loop_0:     bsr.s   get_bit
                dbcc    d3,sld_loop_0
                moveq   #0,d4
                moveq   #0,d5
                move.b  sld_tab+1(pc,d3.w),d6  ; $09,$01,$00,$ff,$ff
                ext.w   d6
                bmi.s   no_extra_bits
                bsr.s   get_d6_bits
no_extra_bits:  move.b  sld_tab2+1(pc,d3.w),d4 ; $08,$04,$02,$01,$00
                beq.s   sld_offset_0
                add.w   d5,d4
                moveq   #1,d3
sld_loop_1:     bsr.s   get_bit
                dbcc    d3,sld_loop_1
                add.w   d3,d3
                move.w  sld_tab3+2(pc,d3.w),d6  ; $0b,$04,$07
                bsr.s   get_d6_bits
                add.w   sld_tab4+2(pc,d3.w),d5  ; $0120,$0000,$0020
                beq.s   sld_calc
                add.w   d4,d5
                bra.s   sld_calc
sld_offset_0:   moveq   #5,d6
                moveq   #0,d3
                bsr.s   get_bit
                bcc.s   sld_skip_offset
                moveq   #8,d6
                moveq   #$40,d3
sld_skip_offset:
                bsr.s   get_d6_bits
                add.w   d3,d5
sld_calc:       lea     1(a6,d5.w),a3
                move.b  -(a3),-(a6)
sld_mainloop:   move.b  -(a3),-(a6)
                dbra    d4,sld_mainloop
                bra.s   depac_loop

get_bit:        add.b   d7,d7
                bne.s   bit_done
                move.b  -(a5),d7
                addx.b  d7,d7
bit_done:       rts

get_d6_bits:    moveq   #0,d5
get_bits_loop:  add.b   d7,d7
                bne.s   get_d6_cont
                move.b  -(a5),d7
refill_cont:    addx.b  d7,d7
get_d6_cont:    addx.w  d5,d5
                dbra    d6,get_bits_loop
                rts

sld_tab:        dc.b $09,$01,$00,$ff,$ff
sld_tab2:       dc.b $08,$04,$02,$01,$00
sld_tab3:       dc.w $0b,$04,$07
sld_tab4:       dc.w $0120,$0000,$0020

len_tab:        dc.w 1,1,2,7,$e
                dc.w 3,3,7,$ff,$8000

