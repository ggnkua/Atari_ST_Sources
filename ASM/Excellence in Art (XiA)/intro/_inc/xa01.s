; xa STE code

; For more information, see xa.txt

;##############################################################################################
;## xa01

XA_BLOCK_PFT_DATA equ $DEAD
XA_BLOCK_GGN_DATA equ $DEAE
XA_BLOCK_RAW_DATA equ $DEAF
XA_BLOCK_DEFJAM_DATA equ $DEB0

XA_PFT_SKIP equ 1
XA_PFT_DATA equ 2
XA_PFT_REPEAT equ 3


xa_getnumberofframes
; In:  a0.l - pointer to xa file
; Out: d0.l - number of frames in file MINUS ONE (prepared for dbra)
	cmp.l #"xa01",(a0)
	bne .exitall
	move.l #0,d0
	move.w 38(a0),d0
  sub.l #1,d0
.exitall
	rts


xa_getpalette
; In:  a0.l - pointer to xa file
;      a1.l - pointer to 16-word space to write palette to
	cmp.l #"xa01",(a0)+
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
	cmp.l #"xa01",(a0)
	bne .noheader
	move.b 36(a0),xa_var_bpls
	; Dig out number of frames, to jump past directory
	move.l #0,d0
	move.w 38(a0),d0 ; number of frames
	lsl.l #3,d0
	add.l #40,a0 ; jump past header
	add.l d0,a0  ; jump past all frames in directory	
	; a0 now points to very first frame
.noheader


;XA_BLOCK_PFT_DATA
;XA_BLOCK_GGN_DATA
;XA_BLOCK_RAW_DATA
;XA_BLOCK_DEFJAM_DATA

  move.w (a0)+,d7
  cmp.w #XA_BLOCK_PFT_DATA,d7
  beq .pft
  cmp.w #XA_BLOCK_GGN_DATA,d7
  beq .ggn
  cmp.w #XA_BLOCK_RAW_DATA,d7
  beq .raw
  cmp.w #XA_BLOCK_DEFJAM_DATA,d7
  beq .defjam
  
  bra .exitall



.ggn
  move.l #0,d7
  move.w (a0)+,d7 ; d7 is number of chunks
  cmp.w #$ffff,d7
  beq .exitall
  add.l #1,d7
  move.l d7,d6
  lsr.l #5,d6
  and.l #$001f,d7
  
  cmp.w #0,d6
  beq .nobig
  sub.l #1,d6
  move.l #0,d0
.bigchunkloopggn
  rept 32
    move.w (a0)+,d0
    move.w (a0)+,(a1,d0)
  endr
  dbra d6,.bigchunkloopggn
.nobig

  cmp.w #0,d7
  beq .noremainder
  sub.l #1,d7
.remainderchunkloopggn
  move.w (a0)+,d0
  move.w (a0)+,(a1,d0)
  dbra d7,.remainderchunkloopggn
.noremainder

  bra .exitall


xa_raw_unpack macro
  ; Usage: xa_raw_unpack [number of bitplanes]
  iflt \1-1 ; disallow values lower than 1
    fail
  endc
  ifgt \1-4 ; disallow values higher than 4
    fail
  endc

  move.l #200-1,d7
.line\@

  ; 4 bitplanes
  ifeq \1-4
    rept 20
      move.l (a0)+,(a1)+
      move.l (a0)+,(a1)+
    endr
  endc
  
  ; 3 bitplanes
  ifeq \1-3
o set 0
    rept 20
      move.l (a0)+,o(a1)
o set o+4
      move.w (a0)+,o(a1)
o set o+4
    endr
    add.l #160,a1
  endc
  
  ; 2 bitplanes
  ifeq \1-2
o set 0
    rept 20
      move.l (a0)+,o(a1)
o set o+8
    endr
    add.l #160,a1
  endc
  
  ; 1 bitplane
  ifeq \1-1
o set 0
    rept 20
      move.w (a0)+,o(a1)
o set o+8
    endr
    add.l #160,a1
  endc
  
  dbra d7,.line\@

  endm

.raw
	cmp.b #4,xa_var_bpls
	beq .raw_bpl4
	cmp.b #3,xa_var_bpls
	beq .raw_bpl3
	cmp.b #2,xa_var_bpls
	beq .raw_bpl2
	cmp.b #1,xa_var_bpls
	beq .raw_bpl1

  bra .exitall

.raw_bpl4
  xa_raw_unpack 4
  bra .exitall

.raw_bpl3
  xa_raw_unpack 3
  bra .exitall

.raw_bpl2
  xa_raw_unpack 2
  bra .exitall

.raw_bpl1
  xa_raw_unpack 1
  bra .exitall



.defjam
  bra .exitall



xa_pft_unpack macro
  ; Usage: xa_pft_unpack [number of bitplanes]
  iflt \1-1 ; disallow values lower than 1
    fail
  endc
  ifgt \1-4 ; disallow values higher than 4
    fail
  endc

  move.l #0,d7
  move.w (a0)+,d7 ; d7 is number of chunks
  cmp.w #$ffff,d7
  beq .exitall
.chunkloop4\@

  move.w (a0)+,d6
  cmp.w #XA_PFT_SKIP,d6
  beq .skip4\@
  cmp.w #XA_PFT_DATA,d6
  beq .data4\@
  cmp.w #XA_PFT_REPEAT,d6
  beq .repeat4\@

.skip4\@
  move.w (a0)+,d6
  add.w d6,a1
  bra .done4\@
  
.data4\@
  move.l #0,d6
  move.w (a0)+,d6
.dataloop4\@

  ; 4 bitplanes
  ifeq \1-4
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+
  endc

  ; 3 bitplanes
  ifeq \1-3
    move.l (a0)+,(a1)+
    move.w (a0)+,(a1)
    add.l #4,a1
  endc

  ; 2 bitplanes
  ifeq \1-2
    move.l (a0)+,(a1)
    add.l #8,a1
  endc

  ; 1 bitplane
  ifeq \1-1
    move.w (a0)+,(a1)
    add.l #8,a1
  endc

  dbra d6,.dataloop4\@
  bra .done4\@


.repeat4\@
  move.l #0,d6
  move.w (a0)+,d6

  ; 4 bitplanes
  ifeq \1-4
    move.l (a0)+,d0
    move.l (a0)+,d1
  endc

  ; 3 bitplanes
  ifeq \1-3
    move.l (a0)+,d0
    move.w (a0)+,d1
  endc

  ; 2 bitplanes
  ifeq \1-2
    move.l (a0)+,d0
  endc

  ; 1 bitplane
  ifeq \1-1
    move.w (a0)+,d0
  endc

.repeatloop4\@

  ; 4 bitplanes
  ifeq \1-4
    move.l d0,(a1)+
    move.l d1,(a1)+
  endc

  ; 3 bitplanes
  ifeq \1-3
    move.l d0,(a1)+
    move.w d1,(a1)+
  endc

  ; 2 bitplanes
  ifeq \1-2
    move.l d0,(a1)+
  endc

  ; 1 bitplanes
  ifeq \1-1
    move.w d0,(a1)+
  endc

  dbra d6,.repeatloop4\@
  bra .done4\@



.done4\@
  dbra d7,.chunkloop4\@
  endm



.pft
	cmp.b #4,xa_var_bpls
	beq .pft_bpl4
	cmp.b #3,xa_var_bpls
	beq .pft_bpl3
	cmp.b #2,xa_var_bpls
	beq .pft_bpl2
	cmp.b #1,xa_var_bpls
	beq .pft_bpl1

  bra .exitall

.pft_bpl4
  xa_pft_unpack 4
  bra .exitall

.pft_bpl3
  xa_pft_unpack 3
  bra .exitall

.pft_bpl2
  xa_pft_unpack 2
  bra .exitall

.pft_bpl1
  xa_pft_unpack 1
  bra .exitall


.exitall
	movem.l (sp)+,d0-d7/a1-a6
	rts




xa_unpack
; In:  d0.l - number of vbls between frames
;      a0.l - pointer to source
;      a1.l - pointer to image dest
;      a2.l - pointer to palette dest
  ;move.b #0,$ffffc123
	movem.l d0-d7/a0-a6,-(sp)
	move.l a0,a6
	cmp.l #"xa01",(a0)+
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
	sub.l #1,d7
	move.l a6,a0
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



;##
;##############################################################################################

xa_var_bpls
	dc.b 0

	even

