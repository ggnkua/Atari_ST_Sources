; ATOM.S

; Atomik pack tester

; Atomik v3.5
; so far: 450 bytes

; this simply unpacks the file and jumps to it
; the file is pc-relative, so no need to relocate!
;
;



unpack_offset	equ	256

		opt p-
		opt nodebug
		output	tiny.prg
CHECK_ATOMIK:

depack:
	lea	packed_file+4(pc),a0
	lea	unpack_offset(a0),a1

        ;cmp.l   #"ATM5",(a0)+
        ;bne     not_packed

        link    a2,#-28
        move.l  (a0)+,d0

        move.l  a1,a5
        add.l   d0,a5
        move.l  a5,a4

        lea     -$c(a4),a4
        move.l  (a0)+,d0

        ;move.l  a0,a6
        ;add.l   d0,a6
        ;subq    #1,a6
	lea	-1(a0,d0.w),a6

        move.b  -(a6),d7
        bra     take_type
decrunch:       move    d3,d5
take_lenght:
    	add.b   d7,d7
.cont_take:     dbcs    d5,take_lenght
        beq.s   .empty1
        bcc.s   .next_cod
        sub     d3,d5
        neg     d5
        bra.s   .do_copy1
.next_cod:      moveq   #3,d6
        bsr.s   get_bit2
        beq.s   .next_cod1
        bra.s   .do_copy
.next_cod1:     moveq   #7,d6
        bsr.s   get_bit2
        beq.s   .next_cod2
        add     #15,d5
        bra.s   .do_copy
.empty1:        move.b  -(a6),d7
        addx.b  d7,d7
        bra.s   .cont_take
.next_cod2:     moveq   #13,d6
        bsr.s   get_bit2
        add     #255+15,d5
.do_copy:       add     d3,d5
.do_copy1:      lea     decrun_table(pc),a4
        move    d5,d2
        bne.s   bigger
        add.b   d7,d7
        bne.s   .not_empty
        move.b  -(a6),d7
        addx.b  d7,d7
.not_empty:     bcs.s   .ho_kesako
        moveq   #1,d6
        bra.s   word
.ho_kesako:     moveq   #3,d6
        bsr.s   get_bit2
        tst.b   -28(a2)
        beq.s   .ho_kesako1
        move.b  10-28(a2,d5.w),-(a5)
        bra     tst_end
.ho_kesako1:    move.b  (a5),d0
        btst    #3,d5
        bne.s   .ho_kesako2
        bra.s   .ho_kesako3
.ho_kesako2:    add.b   #$f0,d5
.ho_kesako3:    sub.b   d5,d0
        move.b  d0,-(a5)
        bra     tst_end
get_bit2:       clr     d5
.get_bits:      add.b   d7,d7
        beq.s   .empty
.cont:  addx    d5,d5
        dbf     d6,.get_bits
        tst     d5
        rts
.empty: move.b  -(a6),d7
        addx.b  d7,d7
        bra.s   .cont
bigger: moveq   #2,d6
word:   bsr.s   get_bit2
contus: move    d5,d4
        move.b  14(a4,d4.w),d6
        ext     d6
        tst.b   1-28(a2)
        bne.s   .spe_ofcod1
        addq    #4,d6
        bra.s   .nospe_ofcod1
.spe_ofcod1:    bsr.s   get_bit2
        move    d5,d1
        lsl     #4,d1
        moveq   #2,d6
        bsr.s   get_bit2
        cmp.b   #7,d5
        blt.s   .take_orof
        moveq   #0,d6
        bsr.s   get_bit2
        beq.s   .its_little
        moveq   #2,d6
        bsr.s   get_bit2
        add     d5,d5
        or      d1,d5
        bra.s   .spe_ofcod2




.its_little:    or.b    2-28(a2),d1
        bra.s   .spe_ofcod3




.take_orof:     or.b    3-28(a2,d5.w),d1
.spe_ofcod3:    move    d1,d5
        bra.s   .spe_ofcod2




.nospe_ofcod1:  bsr.s   get_bit2
.spe_ofcod2:    add     d4,d4
        beq.s   .first
        add     -2(a4,d4.w),d5
.first: lea     1(a5,d5.w),a4
        move.b  -(a4),-(a5)
.copy_same:     move.b  -(a4),-(a5)
        dbf     d2,.copy_same
        bra.s   tst_end




make_jnk:       add.b   d7,d7
        bne.s   .not_empty
        move.b  -(a6),d7
        addx.b  d7,d7
.not_empty:     bcs.s   string
        move.b  -(a6),-(a5)
tst_end:        cmp.l   a5,a3
        bne.s   make_jnk
        cmp.l   a6,a0
        beq   work_done			;this is where the
					;depack ends, so
					;jump into the prg
take_type:      moveq   #0,d6
        bsr     get_bit2
        beq.s   .nospe_ofcod
        move.b  -(a6),d0
        lea     2-28(a2),a1
        move.b  d0,(a1)+
        moveq   #1,d1
        moveq   #6,d2
.next:  cmp.b   d0,d1
        bne.s   .no_off_4b
        addq    #2,d1
.no_off_4b:     move.b  d1,(a1)+
        addq    #2,d1
        dbf     d2,.next
        st      1-28(a2)
        bra.s   .spe_ofcod
.nospe_ofcod:   sf      1-28(a2)
.spe_ofcod:     moveq   #0,d6
        bsr     get_bit2
        beq.s   .relatif
        lea     10-28(a2),a1
        moveq   #15,d0
.next_f:        move.b  -(a6),(a1)+
        dbf     d0,.next_f
        st      -28(a2)
        bra.s   .freq
.relatif:       sf      -28(a2)
.freq:  clr     d3
        move.b  -(a6),d3
        move.b  -(a6),d0
        lsl     #8,d0
        move.b  -(a6),d0
        move.l  a5,a3
        sub     d0,a3
        bra.s   make_jnk
string: bra     decrunch

	;illegal


decrun_table:
	dc.w    32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
        dc.w    32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
        dc.b    0,1,3,4,5,6,7,8

packed_file:
		incbin	4k.pak
work_done:	equ	packed_file+unpack_offset+4

		section	bss
		ds.l	250000
