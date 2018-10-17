*	ACCSTART.S	4/30/85			MIKE SCHMAL
*
*	DESK ACCESSORY STARTUP PROGRAM
*
* This version only contains what is necessary for a desk accessory to run
* All other garbage has been removed as not to waste memory.
*

	.text
	.globl	_main
	.globl	_crystal
	.globl	_ctrl_cnts

*
*  Must be first object file in link statement
*

	move.l	#ustk,a7	* get program stack
	jsr	_main		* go to program
	move.l	#0,(a7)		* back to gemdos
	trap	#1
*
* necessary for the binds to work, everyone gets one
*

_crystal:
	move.l	4(a7),d1
	move.w	#200,d0
	trap	#2
	rts
*
*
*
*
	.globl	ldiv
	.globl	lmul
	.globl	lrem

*
*
* ========================================================
* ==							==
* ==			Long Divide			==
* ==							==
* ========================================================
*
ldiv:
*
~~ldiv:
~b=d4
~q=d5
~l1=d7
~l2=d6
~al1=8
~al2=12
~sign=d3
*
	link	a6,#-2
	movem.l	d2-d7,-(sp)
	clr	d3
	clr.l	d5
	move.l	8(a6),d7
	move.l	12(a6),d6
	bne	La2
	move.l	#$80000000,d0
	divs	#0,d0			*<<<<< div by zero trap   whf 3/7/84
	bra	La1
*
La2:
	bge	La3
	neg.l	d6
	add	#1,d3
*
La3:
	tst.l	d7
	bge	La4
	neg.l	d7
	add	#1,d3
*
La4:
	cmp.l	d7,d6
	bgt	La6
	bne	La7
	move.l	#1,d5
	clr.l	d7
	bra	La6
*
La7:
	cmp.l	#$10000,d7
	bge	La9
	divu	d6,d7
	move	d7,d5
	swap	d7
	ext.l	d7
	bra	La6
*
La9:
	move.l	#1,d4
*
La12:
	cmp.l	d6,d7
	blo	La11
	asl.l	#1,d6
	asl.l	#1,d4
	bra	La12
*
La11:
	tst.l	d4
	beq	La6
	cmp.l	d6,d7
	blo	La15
	or.l	d4,d5
	sub.l	d6,d7
*
La15:
	lsr.l	#1,d4
	lsr.l	#1,d6
	bra	La11
*
La6:
	cmp	#1,d3
	bne	La16
	neg.l	d7
	move.l	d5,d0
	neg.l	d0
	bra	La1
*
La16:
	move.l	d5,d0
*
La1:
	tst.l	(sp)+
	movem.l	(sp)+,d3-d7
	unlk	a6
	rts

****************** lrem
lrem:
~~lrem:
~b=d4
~q=d5
~l1=d7
~l2=d6
~al1=8
~al2=12
~sign=d3
*
	link	a6,#-2
	movem.l	d2-d7,-(sp)
	move.l	d1,-(sp)		/* rem */
	
	clr	d3
	clr.l	d5
	move.l	8(a6),d7
	move.l	12(a6),d6
	bne	Ba2
	move.l	#$80000000,d1		/* rem */
	move.l	#$80000000,d0
	divs	#0,d0			*<<<<< div by zero trap   whf 3/7/84
	bra	Ba1
*
Ba2:
	bge	Ba3
	neg.l	d6
	add	#1,d3
*
Ba3:
	tst.l	d7
	bge	Ba4
	neg.l	d7
	add	#1,d3
*
Ba4:
	cmp.l	d7,d6
	bgt	Ba6
	bne	Ba7
	move.l	#1,d5
	clr.l	d7
	bra	Ba6
*
Ba7:
	cmp.l	#$10000,d7
	bge	Ba9
	divu	d6,d7
	move	d7,d5
	swap	d7
	ext.l	d7
	bra	Ba6
*
Ba9:
	move.l	#1,d4
*
Ba12:
	cmp.l	d6,d7
	blo	Ba11
	asl.l	#1,d6
	asl.l	#1,d4
	bra	Ba12
*
Ba11:
	tst.l	d4
	beq	Ba6
	cmp.l	d6,d7
	blo	Ba15
	or.l	d4,d5
	sub.l	d6,d7
*
Ba15:
	lsr.l	#1,d4
	lsr.l	#1,d6
	bra	Ba11
*
Ba6:
	cmp	#1,d3
	bne	Ba16
	neg.l	d7
	move.l	d7,d1		/* rem */
	move.l	d5,d0
	neg.l	d0
	bra	Ba1
*
Ba16:
	move.l	d7,d1		/* rem */
	move.l	d5,d0
*
Ba1:
	move.l	d1,d0		/* rem to d0 */
	move.l	(sp)+,d1	/* restore d1 */
	tst.l	(sp)+
	movem.l	(sp)+,d3-d7
	unlk	a6
	rts
	
* ========================================================
* ==							
* ==    long multiply routine without floating point	==
* ==  call with:					==
* ==		two long values on stack		==
* ==  returns:						==
* ==		long value in d0 and d1			==
* ==							==
* == warning:  no overflow checking or indication!!!!	==
* ==							
* ========================================================

lmul:
~~lmul:
~sign=d2
~l1=8
~l2=12
~t1=-4
~t2=d6
	link	a6,#-4
	clr	d2
	tst.l	8(a6)		//is first arg negative?
	bge	L2
	neg.l	8(a6)		//yes, negate it
	inc	d2				// increment sign flag
*
L2:
	tst.l	12(a6)		//is second arg negative?
	bge	L3
	neg.l	12(a6)		//yes, make it positive
	inc	d2				//increment sign flag
*
L3:
	move	10(a6),d0		//arg1.loword
	mulu	14(a6),d0		//arg2.loword
	move.l	d0,-4(a6)	//save in temp
	move	8(a6),d0		//arg1.hiword
	mulu	14(a6),d0		//arg2.loword
	move	12(a6),d1		//arg2.hiword
	mulu	10(a6),d1		//arg1.loword
	add	d1,d0			//form the sum of 2 lo-hi products
	add	-4(a6),d0	//add to temp hiword
	move	d0,-4(a6)	//store back in temp hiword
	move.l	-4(a6),d0	//long results
	btst	#0,d2			//test sign flag
	beq	L4
	neg.l	d0		//complement the results
*
L4:
	unlk	a6
	rts

	globl	_bios,_xbios,_gemdos
_bios:
	move.l	(sp)+,retsav
	trap	#13
	move.l	retsav,-(sp)
	rts

_xbios:
	move.l	(sp)+,retsav
	trap	#14
	move.l	retsav,-(sp)
	rts

_gemdos:
	move.l	(sp)+,retsav
	trap	#1
	move.l	retsav,-(sp)
	rts

	.bss
	.even
retsav:	.ds.l	1
	.ds.l	256
ustk:	.ds.l	1
*
	.data
    	.even
_ctrl_cnts:			 	*	Application Manager
	.dc.b	0, 1, 0			* func 010		
      	.dc.b	2, 1, 1			* func 011		
       	.dc.b	2, 1, 1 		* func 012		
	.dc.b	0, 1, 1			* func 013		
	.dc.b	2, 1, 1			* func 014		
	.dc.b	1, 1, 1			* func 015		
	.dc.b	0, 0, 0			* func 016		
	.dc.b	0, 0, 0			* func 017		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 1, 0			* func 019		
*							 Event Manager
	.dc.b	0, 1, 0			* func 020		
	.dc.b	3, 5, 0			* func 021		
	.dc.b	5, 5, 0			* func 022		
	.dc.b	0, 1, 1			* func 023		
	.dc.b	2, 1, 0			* func 024		
	.dc.b	16, 7, 1 		* func 025		
	.dc.b	2, 1, 0			* func 026		
	.dc.b	0, 0, 0			* func 027		
	.dc.b	0, 0, 0			* func 028		
	.dc.b	0, 0, 0			* func 009		
*							 Menu Manager
	.dc.b	1, 1, 1			* func 030		
	.dc.b	2, 1, 1			* func 031		
	.dc.b	2, 1, 1			* func 032		
	.dc.b	2, 1, 1			* func 033		
	.dc.b	1, 1, 2			* func 034		
	.dc.b	1, 1, 1			* func 005		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0			* func 009		
*							 Object Manager
	.dc.b	2, 1, 1			* func 040		
	.dc.b	1, 1, 1			* func 041		
  	.dc.b	6, 1, 1			* func 042		
	.dc.b	4, 1, 1			* func 043		
	.dc.b	1, 3, 1			* func 044		
	.dc.b	2, 1, 1			* func 045		
	.dc.b	4, 2, 1			* func 046		
	.dc.b	8, 1, 1			* func 047		
	.dc.b	0, 0, 0			* func 048		
	.dc.b	0, 0, 0			* func 049		
*							 Form Manager
	.dc.b	1, 1, 1			* func 050		
	.dc.b	9, 1, 1			* func 051		
	.dc.b	1, 1, 1			* func 002		
	.dc.b	1, 1, 0			* func 003		
	.dc.b	0, 5, 1			* func 004		
	.dc.b	0, 0, 0			* func 005		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0			* func 009		
*							 Dialog Manager
	.dc.b	0, 0, 0			* func 060		
	.dc.b	0, 0, 0			* func 061		
	.dc.b	0, 0, 0			* func 062		
	.dc.b	0, 0, 0			* func 003		
	.dc.b	0, 0, 0			* func 004		
	.dc.b	0, 0, 0			* func 005		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0			* func 009		
*							Graphics Manager
	.dc.b	4, 3, 0			* func 070		
	.dc.b	8, 3, 0			* func 071		
	.dc.b	6, 1, 0			* func 072		
	.dc.b	8, 1, 0			* func 073		
	.dc.b	8, 1, 0			* func 074		
	.dc.b	4, 1, 1			* func 075		
	.dc.b	3, 1, 1			* func 076		
	.dc.b	0, 5, 0			* func 077		
	.dc.b	1, 1, 1			* func 078		
	.dc.b	0, 5, 0			* func 009		
*							Scrap Manager
	.dc.b	0, 1, 1			* func 080		
	.dc.b	0, 1, 1			* func 081		
	.dc.b	0, 0, 0			* func 082		
	.dc.b	0, 0, 0			* func 083		
	.dc.b	0, 0, 0			* func 084		
	.dc.b	0, 0, 0			* func 005		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0			* func 009		
*							fseler Manager
	.dc.b	0, 2, 2			* func 090		
	.dc.b	0, 0, 0			* func 091		
	.dc.b	0, 0, 0			* func 092		
	.dc.b	0, 0, 0			* func 003		
	.dc.b	0, 0, 0			* func 004		
	.dc.b	0, 0, 0			* func 005		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0 		* func 009		
*							Window Manager
	.dc.b	5, 1, 0			* func 100		
	.dc.b	5, 1, 0			* func 101		
	.dc.b	1, 1, 0			* func 102		
	.dc.b	1, 1, 0			* func 103		
	.dc.b	2, 5, 0			* func 104		
	.dc.b	6, 1, 0			* func 105		
	.dc.b	2, 1, 0			* func 106		
	.dc.b	1, 1, 0			* func 107		
	.dc.b	6, 5, 0			* func 108		
	.dc.b	0, 0, 0 		* func 009		
*							Resource Manger
	.dc.b	0, 1, 1			* func 110		
	.dc.b	0, 1, 0			* func 111		
	.dc.b	2, 1, 0			* func 112		
	.dc.b	2, 1, 1			* func 113		
	.dc.b	1, 1, 1			* func 114		
	.dc.b	0, 0, 0			* func 115		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0			* func 009		
*							Shell Manager
	.dc.b	0, 1, 2			* func 120		
	.dc.b	3, 1, 2			* func 121		
	.dc.b	1, 1, 1			* func 122		
	.dc.b	1, 1, 1			* func 123		
	.dc.b	0, 1, 1			* func 124		
	.dc.b	0, 1, 2			* func 125		
	.end
