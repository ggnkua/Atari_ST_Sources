; xa STE code

; For more information, see xa.txt

;-----------------------------------------------

xa_getnumberofframes
; In:  a0.l - pointer to xa file
; Out: d0.l - number of frames in file MINUS ONE (prepared for dbra)
	cmp.l #"xa00",(a0)
	bne .exitall
	move.l #0,d0
	move.w 38(a0),d0
.exitall
	rts


xa_getpalette
; In:  a0.l - pointer to xa file
;      a1.l - pointer to 16-word space to write palette to
	cmp.l #"xa00",(a0)+
	bne .exitall
	movem.l d0-d7,-(sp)
	movem.l (a0),d0-d7
	movem.l d0-d7,(a1)
	movem.l (sp)+,d0-d7
.exitall
	rts


xa_unpackoneframe
; In:  a0.l - pointer to source
;      a1.l - pointer to dest
; Out: a0.l - points to next frame
	movem.l d0-d7/a1-a6,-(sp)
	cmp.l #"xa00",(a0)
	bne .noheader
	move.b 36(a0),xa_var_bpls
	add.l #40,a0
.noheader

	cmp.b #4,xa_var_bpls
	beq .bpl4
	cmp.b #3,xa_var_bpls
	beq .bpl3
	cmp.b #2,xa_var_bpls
	beq .bpl2
	cmp.b #1,xa_var_bpls
	beq .bpl1

.bpl1
.oneblock1
	move.w (a0)+,d6
	cmp.w #0,d6
	beq .exitall
	cmp.w #1,d6
	beq .framedone1
	cmp.w #2,d6
	bne .notskip1
	; skip
	add.l (a0)+,a1
	bra .oneblock1 ; fetch next block
.notskip1
	cmp.w #4,d6
	bne .notdata1
	; data
	move.l (a0)+,d5
.blocksize1
block set 20
	cmp.l #block,d5
	blt .smallblock1
.bigblock1
offs set 0
	rept block
	move.w (a0)+,offs(a1)
offs set offs+8
	endr
	add.l #block*8,a1
	sub.l #block,d5
	bra .blocksize1
.smallblock1
	move.w (a0)+,(a1)
	add.l #8,a1
	dbra d5,.smallblock1
	bra .oneblock1
.notdata1
.framedone1
	bra .exitall

.bpl2
.oneblock2
	move.w (a0)+,d6
	cmp.w #0,d6
	beq .exitall
	cmp.w #1,d6
	beq .framedone2
	cmp.w #2,d6
	bne .notskip2
	; skip
	add.l (a0)+,a1
	bra .oneblock2 ; fetch next block
.notskip2
	cmp.w #4,d6
	bne .notdata2
	; data
	move.l (a0)+,d5
.blocksize2
block set 20
	cmp.l #block,d5
	blt .smallblock2
.bigblock2
offs set 0
	rept block
	move.l (a0)+,offs(a1)
offs set offs+8
	endr
	add.l #block*8,a1
	sub.l #block,d5
	bra .blocksize2
.smallblock2
	move.l (a0)+,(a1)
	add.l #8,a1
	dbra d5,.smallblock2
	bra .oneblock2
.notdata2
.framedone2
	bra .exitall

.bpl3
.oneblock3
	move.w (a0)+,d6
	cmp.w #0,d6
	beq .exitall
	cmp.w #1,d6
	beq .framedone3
	cmp.w #2,d6
	bne .notskip3
	; skip
	add.l (a0)+,a1
	bra .oneblock3 ; fetch next block
.notskip3
	cmp.w #4,d6
	bne .notdata3
	; data
	move.l (a0)+,d5
.blocksize3
block set 20
	cmp.l #block,d5
	blt .smallblock3
.bigblock3
offs set 0
	rept block
	move.l (a0)+,offs(a1)
	move.w (a0)+,offs+4(a1)
offs set offs+8
	endr
	add.l #block*8,a1
	sub.l #block,d5
	bra .blocksize3
.smallblock3
	move.l (a0)+,(a1)
	move.w (a0)+,4(a1)
	add.l #8,a1
	dbra d5,.smallblock3
	bra .oneblock3
.notdata3
.framedone3
	bra .exitall

.bpl4
.oneblock4
	move.w (a0)+,d6
	cmp.w #0,d6
	beq .exitall
	cmp.w #1,d6
	beq .framedone4
	cmp.w #2,d6
	bne .notskip4
	; skip
	add.l (a0)+,a1
	bra .oneblock4 ; fetch next block
.notskip4
	cmp.w #4,d6
	bne .notdata4
	; data
	move.l (a0)+,d5
.blocksize4
block set 20
	cmp.l #block,d5
	blt .smallblock4
.bigblock4
	rept block*2
	move.l (a0)+,(a1)+
	endr
	sub.l #block,d5
	bra .blocksize4
.smallblock4
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	dbra d5,.smallblock4
	bra .oneblock4
.notdata4
.framedone4
	bra .exitall

.exitall
	movem.l (sp)+,d0-d7/a1-a6
	rts


xa_unpack
; In:  d0.l - number of vbls between frames
;      a0.l - pointer to source
;      a1.l - pointer to image dest
;      a2.l - pointer to palette dest
	movem.l d0-d7/a0-a6,-(sp)
	cmp.l #"xa00",(a0)+
	bne .exitall ; bad header
	sub.l #1,d0
	move.l d0,-(sp)
	movem.l (a0)+,d0-d7
	movem.l d0-d7,(a2)
	move.l (sp)+,d0
	move.b (a0),xa_var_bpls
	add.l #2,a0

	move.l #0,d7
	move.w (a0)+,d7
.oneframe

	bsr xa_unpackoneframe
	
	;backcol 333
	move.l d0,-(sp)
	bsr wait4vbld0 ; 1=wait 1 bpl
	move.l (sp)+,d0
	;backcol 000
	move.l a1,a2
	dbra d7,.oneframe
.exitall
	movem.l (sp)+,d0-d7/a0-a6
	rts


xa_var_bpls
	dc.b 0

	even

;-----------------------------------------------
