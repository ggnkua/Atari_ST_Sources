
;
; DUMP
;
; September 21, 2003
; Anders Eriksson
; ae@dhs.nu
; 
; samples.s

		section	text

		tst.w	samplenames				;if not 0 skip samplename print
		bne.w	.nosamplenames				;

		move.l	#samp_head_txt,d0			;Samplenames:
		bsr.w	print					;

		lea.l	samples_text,a0				;make spaces of zeroes
		move.w	#33*28+4-1,d7				;to avoid early endoftext
.spaceloop:	move.b	#" ",(a0)+				;
		dbra	d7,.spaceloop				;

		move.l	filebuffer,a0				;address to module
		lea.l	20(a0),a0				;offset to sample info
		lea.l	samples_text,a1				;own sampletext buffer
		move.l	a1,a2
		lea.l	samples_numb,a3				;sample numbers
		clr.l	d0
	
		move.w	#31-1,d7				;31 samples
.sampleloop:	move.w	#22-1,d6				;22 char per sample
		move.l	(a3)+,(a1)+				;sample number

.snamechars:	move.b	(a0)+,d0				;get char
		beq.s	.charjump				;if zero make space
		move.b	d0,(a1)+				;store char
		bra.s	.chardone				;

.charjump:	move.b	#" ",(a1)+				;
.chardone:	dbra	d6,.snamechars				;next char

		cmp.l	#samples_text,a2			;if first column add linebreaks
		bne.s	.realnext				;
		move.b	#13,-28(a1)				;linebreak
		move.b	#10,-27(a1)				;
.realnext:		
		addq.l	#8,a0					;offset to next sample
		addq.w	#1,samples_break			;when samples_break=12 make new column
		cmp.w	#11,samples_break			;
		beq.s	.break					;do new column

		add.l	#(26*2)+2,a1				;next row
		bra.s	.next_sample				;

.break:		lea.l	26(a2),a2				;next column
		move.l	a2,a1					;

		clr.w	samples_break				;clear counter
.next_sample:	dbra	d7,.sampleloop				;

		lea.l	samples_text+880,a1			:offset for end chars
		move.b	#13,(a1)+				;linebreak
		move.b	#10,(a1)+				;
		move.b	#0,(a1)+				;end of list

		move.l	#samples_text,d0			;print it
		bsr.w	print					;

.nosamplenames:

		section	text
		