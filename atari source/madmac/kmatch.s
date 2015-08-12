;+
;  Traverse keyword table (fast 68000 version)
;
;    int kmatch(string, kwbase, kwcheck, kwtab, kwaccept)
;	char *string;	4(sp)		a0
;	WORD *kwbase;	8(sp)		a1
;	WORD *kwcheck;	$c(sp)		a2
;	WORD *kwtab;	$10(sp)		a3
;	WORD *kwaccept;	$14(sp)
;
;  Returns:	d0 < 0, no match
;		d0 >= 0, match
;
;  Uses:	C registers
;
;-
_kmatch::
	movem.l	d3/a3, .regsave		; save temp registers
	movem.l	4(sp),a0-a3		; load up pointer registers
	moveq	#0,d0			; state = 0
	moveq	#0,d1
	move.b	(a0)+,d1		; get first char from string

.loop:	cmp.b	#'Z',d1			; convert char to lowercase
	bgt.s	.2			; > 'Z'
	cmp.b	#'A',d1
	blt.s	.2			; < 'A'
	add.b	#$20,d1			; adjust to lowercase

.2:	add.w	d0,d0			; (state = word index)
	move.w	d1,d2			; j/2 = char + base[state]
	add.w	(a1,d0.w),d2
	add.w	d2,d2			; (j = word index)
	move.w	(a2,d2.w),d3		; d3 = check value/2
	add.w	d3,d3
	cmp.w	d3,d0			; if (d3 != state)
	bne.s	.fail			;	then reject (can't transition)

	move.b	(a0)+,d1		; get next char from string
	beq.s	.1			;	must accept or reject at EOS
	move.w	(a3,d2.w),d0		; state/2 = mntab[j]
	bpl.s	.loop			;	continue if state >= 0

.fail:	movem.l	.regsave,d3/a3		; restore registers
	moveq	#-1,d0			; and return -1L
	rts

.1:	move.l	$14(sp),a0		; get accept value
	move.w	(a0,d2.w),d0		; d0 = accept[j]
	movem.l	.regsave,d3/a3		; restore registers and return d0
	rts	

;
;  Temp storage while we clobber D3 and A3
;
    .bss
.regsave:	ds.l	2
