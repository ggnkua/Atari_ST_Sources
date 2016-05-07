	; :ts=8



	;amount_same - 	calculate # of words that are same as first word
amount_same
	clr.l	d5
	move.w	(a0),d2
	bra	zasloop
asloop
	cmp.w	(a0)+,d2
	bne	zam_same
	addq.l	#1,d5
zasloop	dbra	d1,asloop
zam_same	rts


	; amount_different - calculates # of words with no runs of 3 or more
	;	that are the same
amount_different
	clr.l	d5
	move.w	(a0),d2
	not.w	d2	; make sure this != last to start loop
	bra	zad_loop
ad_loop	move.w	d3,d4
	move.w	d2,d3
	move.w	(a0)+,d2
	cmp.w	d2,d3
	bne	incad_ct
	cmp.w	d2,d4
	bne	incad_ct  ;takes three in a row to break out of "different"
	subq.l	#2,d5
	bra	zadiff
incad_ct	addq.l	#1,d5
zad_loop	dbra	d1,ad_loop
zadiff	 rts




	;calc_compress_length(bits, length)
	;	figure out how long bits of length will be 
	;	after word-run compression
	public _calc_compress_length
firstp	set	4*4+4
bits	set	firstp
length	set	firstp+4
_calc_compress_length
	movem.l	d3/d4/d5/d7,-(sp)
	move.l	bits(sp),a1
	move.l	length(sp),d7
	clr.l	d0	; keep compressed length in d0
	clr.l	d5	; first time through loop don't bump pointers
ccloop	
	sub.l	d5,d7	; subtract last run from length
	ble	zccloop	; loop while length is positive
	add.l	d5,a1	; move forward source pointer
	add.l	d5,a1	; twice cause it's word indexing
	move.l	a1,a0	; set up source for amount different
	move.l	d7,d1	; set up limit parameter for amount same
	bsr	amount_same
	cmp.w	#2,d5	; if run's less than 3 don't compress it
	blt	diffccl
	addq.l	#2,d0	; run takes up 2 words
	bra	ccloop
diffccl	
	move.l	a1,a0	; set up source pointer for amount_different
	move.l	d7,d1	; set up limit parameter for amount different
	bsr	amount_different
	add.l	d5,d0
	addq.l	#1,d0	; uniques take up length + one for count
	bra	ccloop

zccloop
	movem.l	(sp)+,d3/d4/d5/d7
	rts




	;word_compress(s, d, length)
	;	compress s of length into d 
	;	with word-run compression
	public _word_compress
firstp	set	5*4+4
s	set	firstp
d	set	firstp+4
length	set	firstp+8
_word_compress
	movem.l	a2/d3/d4/d5/d7,-(sp)
	move.l	s(sp),a1
	move.l	d(sp),a2
	move.l	length(sp),d7
	clr.l	d0	; keep compressed length in d0
	clr.l	d5	; first time through loop don't bump pointers
wcloop	
	sub.l	d5,d7	; subtract last run from length
	ble	zwcloop	; loop while length is positive
	add.l	d5,a1	; move forward source pointer
	add.l	d5,a1	; twice cause it's word indexing
	move.l	a1,a0	; set up source for amount different
	move.l	d7,d1	; set up limit parameter for amount same
	bsr	amount_same
	cmp.w	#2,d5	; if run's less than 3 don't compress it
	blt	diffwcl
	move.w	d5,(a2)+ ;	store run length
	move.w	d2,(a2)+ ; store run value
	bra	wcloop
diffwcl	
	move.l	a1,a0	; set up source pointer for amount_different
	move.l	d7,d1	; set up limit parameter for amount different
	bsr	amount_different
	move.w	d5,d0	; get count
	or.w	#$8000,d0 ; set hi bit
	move.w	d0,(a2)+  ; and stor length
	move.l	a1,a0	; get source pointer again
	move.w	d5,d0	; get ready for copy loop
	bra	zdfwcp
dfwcp	move.w	(a0)+,(a2)+
zdfwcp	dbra	d0,dfwcp
	bra	wcloop
zwcloop
	movem.l	(sp)+,a2/d3/d4/d5/d7
	rts


	;word_uncompress(s, d, length)
	;	uncompress s of length into d 
	;	with word-run compression
	public _word_uncompress
firstp	set	12
s	set	firstp
d	set	firstp+4
length	set	firstp+8
_word_uncompress
	movem.l  d2/d3,-(sp)
	move.l	s(sp),a0
	move.l	d(sp),a1
	move.l	length(sp),d2

	;bra	zwuc_lp ;DEBUG

wuclp 	ble	zwuc_lp
	move.w	(a0)+,d0
	bmi	diffucl	; it's a uniq run (yuck!) have to branch
	move.w	(a0)+,d1 ; yeah! Get to repeat d1 d0 times
	move.w	d0,d3 ; so set up a "tower" to do it.
	asr.w	#4,d3 ; d3 is number of loops through tower
	and.w	#15,d0 ; d0 is where in tower to start
	add.w	d0,d0 ; 2 bytes/tower element
	neg.w	d0
	jmp	32+same_tower(pc,d0.w)
same_tower
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+

	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+

	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+

	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+

	dbra	d3,same_tower
	subq.l	#2,d2
	bra	wuclp
diffucl	and.w	#$7fff,d0	;	mask off hi bit
	sub.l	d0,d2	; subtract count from size to uncompress
	move.w	d0,d3 ; so set up a "tower" to do it.
	asr.w	#4,d3 ; d3 is number of loops through tower
	and.w	#15,d0 ; d0 is where in tower to start
	add.w	d0,d0 ; 2 bytes/tower element
	neg.w	d0
	jmp	32+uniq_tower(pc,d0.w)
uniq_tower	
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+

	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+

	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+

	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+

zdiflp	dbra	d3,uniq_tower
	subq.l	#1,d2
	bra	wuclp
zwuc_lp 
	movem.l  (sp)+,d2/d3
	rts

	; untwist(w, h, s, d)
	;	convert s memory form of dimensions w,h from word-interleaved
	;	to column-bitplane representation in d
	public	_untwist
utregs reg	d3/d4/d5/d6/d7/a2/a3
firstp	set	7*4+4
w	set	firstp
h	set	firstp+2
s	set	firstp+4
d	set	firstp+8
_untwist
	movem.l	utregs,-(sp)
	move.w	w(sp),d0
	move.w	h(sp),d1
	move.l	s(sp),a0
	move.l	d(sp),a1
	add.w	#15,d0	;d0 will have # of words in a row
	asr.w	#4,d0	
	move.w	d0,d3	;d3 will have bytes to next line
	asl.w	#3,d3
	move.w	#3,d4	;d4 has plane count
planelp	
	move.l	a0,a2
	addq	#2,a0
	move.w	d0,d5	;d5 counts down words in row
	bra	zrowlp
rowlp	move.l	a2,a3
	addq	#8,a2
	move.w	d1,d6	;d6 counts down words in column
	move.w	d6,d7
	lsr.w	#3,d7
	bra	zbcolulp
bcolulp	move.w	(a3),(a1)+
	adda.w	d3,a3
	move.w	(a3),(a1)+
	adda.w	d3,a3
	move.w	(a3),(a1)+
	adda.w	d3,a3
	move.w	(a3),(a1)+
	adda.w	d3,a3
	move.w	(a3),(a1)+
	adda.w	d3,a3
	move.w	(a3),(a1)+
	adda.w	d3,a3
	move.w	(a3),(a1)+
	adda.w	d3,a3
	move.w	(a3),(a1)+
	adda.w	d3,a3
zbcolulp dbra	d7,bcolulp
	and.w	#7,d6
	bra	zcolulp
colulp	move.w	(a3),(a1)+
	adda.w	d3,a3
zcolulp	dbra	d6,colulp
zrowlp	dbra	d5,rowlp
	dbra	d4,planelp

	movem.l	(sp)+,utregs
	rts

	; twist(w, h, s, d)
	;	convert s memory form of dimensions w,h from word-interleaved
	;	to column-bitplane representation in d
	public	_twist
tregs reg	d3/d4/d5/d6/d7/a2/a3
firstp	set	7*4+4
w	set	firstp
h	set	firstp+2
s	set	firstp+4
d	set	firstp+8
_twist
	movem.l	tregs,-(sp)
	move.w	w(sp),d0
	move.w	h(sp),d1
	move.l	s(sp),a0
	move.l	d(sp),a1
	add.w	#15,d0	;d0 will have # of words in a row
	asr.w	#4,d0	
	move.w	d0,d3	;d3 will have bytes to next line
	asl.w	#3,d3
	move.w	#3,d4	;d4 has plane count
tlanelp	
	move.l	a1,a2
	addq	#2,a1
	move.w	d0,d5	;d5 counts down words in row
	bra	ztowlp
towlp	move.l	a2,a3
	addq	#8,a2
	move.w	d1,d6	;d6 counts down words in column
	move.w	d6,d7
	lsr.w	#3,d7	; do bulk in 8 at a time loop
	bra	zbigtolulp
bigtolulp
	move.w	(a0)+,(a3)
	adda.w	d3,a3
	move.w	(a0)+,(a3)
	adda.w	d3,a3
	move.w	(a0)+,(a3)
	adda.w	d3,a3
	move.w	(a0)+,(a3)
	adda.w	d3,a3
	move.w	(a0)+,(a3)
	adda.w	d3,a3
	move.w	(a0)+,(a3)
	adda.w	d3,a3
	move.w	(a0)+,(a3)
	adda.w	d3,a3
	move.w	(a0)+,(a3)
	adda.w	d3,a3
zbigtolulp	dbra	d7,bigtolulp
	and.w	#7,d6	; mask off remainder
	bra	ztolulp
tolulp	
	move.w	(a0)+,(a3)
	adda.w	d3,a3
ztolulp	dbra	d6,tolulp
ztowlp	dbra	d5,towlp
	dbra	d4,tlanelp

	movem.l	(sp)+,tregs
	rts

