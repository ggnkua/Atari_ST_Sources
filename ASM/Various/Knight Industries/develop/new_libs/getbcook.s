***********************************
*		        *
*		        *
* Cookie Search routine	        *
*		        *
* Returns:	d3 =0 if found       *
*	   =-1 if not found  *
*		        *
*	d4 = cookie value    *
*	   = -1 if not found *
*		        *
***********************************

cookie_jar	equ	$000005a0

	SECTION	text

; cookie to find in d0

; first enter SUPER mode

cookie_search

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#gemdos
	addq.l	#6,sp
	move.l	d0,-(sp)
	
	move.l	cookie_jar.w,a0
	tst.l	(a0)
	beq	.no_cookie_jar
	
	
.search_cookie_jar

	tst.l	(a0)
	beq	.cookie_not_found
	lea	8(a0),a0
	cmp.l	-8(a0),d3
	bne	.search_cookie_jar
	move.l	-4(a0),d4		; cookie value
	
	moveq.l	#0,d3
	
	bra	.end_cookie_search
	
	
.cookie_not_found
.no_cookie_jar

	moveq.l	#-1,d3	; neg as no cookie found
	moveq.l	#-1,d4	; (as above)
	
.end_cookie_search

	move.w	#$20,-(sp)
	trap	#gemdos
	addq.l	#6,sp	
	
	rts
	