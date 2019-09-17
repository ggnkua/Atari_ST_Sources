;WhichTos2 - Amended by PoshPaws (S.H.R.) for general interest
;Hope you don't mind the alterations T.S.C.!

; Thanks to the Untouchables for the cart detect etc.
; The TOS version finder was in the book 'Introducing Atari ST Machine
; Code'   I hope they don't mind us nicking it! (I re-wrote it a bit).

; This code finds out :-	which TOS you have
;			if the sys_base is valid
;			if you have an STE,ST,TT or Falcon
;			how much memory you have
;			if there are cartridges and what they are called

; This code is just an example of how to find some system settings.

; Note:-  you can only detect user carts like the Ultimate Ripper if
; they are switched on.
; I do not know how to find out the memory config properly so someone
; else will have to show you. - Use _phystop - S.H.R.
; Errm...   thats it.		T.S.C.

	text
        	pea	0.w		supervisor mode
        	move.w  	#$20,-(sp)
        	trap    	#1
        	addq.l   	#6,sp
        	move.l  	d0,oldsp

	bss		;must be in bss or data segment else executed!
oldsp	ds.l	1
	
	text
	bsr	ste_hard		run all checks
	bsr.s	checkmeg
	bsr.s	carty
	bsr	tos_check
	
cont	bsr	wait

	pea	oldsp		back to user mode
        	move.w  	#$20,-(sp)
        	trap    	#1
        	addq.w   	#6,sp

	clr.w	-(sp)		quit - don't use pea - it pushes the Contents of 0.w!
	trap	#1      

***************************************************************************
* Check for some carts
**********************
* Diagnostics cartridges contain code at $fa0004 that is executed almost
* immediately after the reset button is pressed. - S.H.R.
* I have no cartridges with code in so this needs checking - 
*    it should return all application names in the cartridge

carty	cmp.l	#$fa52255f,$fa0000	diagnostix cartridge?
					;SHR - note: 5f not 3f as it was!
	bne.s	nextbit
	lea	nostix,a0
	bsr	print
	bra.s	honda
nextbit	move.l	#$fa0000,a5		use 'safe' register
	cmp.l	#$abcdef42,(a5)+	user cartridge? (rippers etc)
	bne.s	kein_cart
	lea	ripper,a0
	bsr	print
	lea	rip2,a0
	bsr	print
app_plus	lea	rip3,a0
	bsr	print
	lea	$14(a5),a0	;cartridge app name
	bsr	print
	lea	crlf,a0
	bsr	print
	lea	(a5),a5	;pointer to next cart app header
	move.l	a5,d0
	tst.l	d0
	bne.s	app_plus	;loop for next app names
	bra.s	honda
kein_cart	lea	cartless,a0
	bsr	print
honda	rts

***************************************************************************
* One way of checking for a meg of memory! - could write over a program!
* SHR - Use the _phystop variable - multitos would stop you from writing
* into (potentially) some other program's memory and falcons no longer
* appear to use the memory configuration registers ($ff8004 or $424)
* _phystop is at $42e and contains the address of the first unuseable
* byte of memory.
checkmeg	
	move.l	#memmsg1,a0
	bsr	print
	move.l	$42e.w,d0
	lsr.l	#8,d0	;get it in K's
	lsr.l	#2,d0	;i.e. divide by 2^10=1024
	move.l	#memsize,a0
	bsr.s	long_val
	move.l	#memsize,a0
	bsr	print
	move.l	#memmsg2,a0
	bsr	print
	rts

long_val	move.l	a0,a1
	move.b	#$30,(a0)
lv_1	addq.b	#1,(a0)
	sub.l	#1000000000,d0
	bge.s	lv_1
	cmp.b	#$31,(a0)	;zero answer
	bne.s	lv_1x	;if not, carry on
	cmp.l	a0,a1	;leading zero
	beq.s	lv_1y	;if so, write over it
lv_1x	subq.b	#1,(a0)+
lv_1y	add.l	#1000000000,d0
	move.b	#$30,(a0)
lv_2	addq.b	#1,(a0)
	sub.l	#100000000,d0
	bge.s	lv_2
	cmp.b	#$31,(a0)	;zero answer
	bne.s	lv_2x	;if not, carry on
	cmp.l	a0,a1	;leading zero
	beq.s	lv_2y	;if so, write over it
lv_2x	subq.b	#1,(a0)+
lv_2y	add.l	#100000000,d0
	move.b	#$30,(a0)
lv_3	addq.b	#1,(a0)
	sub.l	#10000000,d0
	bge.s	lv_3
	cmp.b	#$31,(a0)	;zero answer
	bne.s	lv_3x	;if not, carry on
	cmp.l	a0,a1	;leading zero
	beq.s	lv_3y	;if so, write over it
lv_3x	subq.b	#1,(a0)+
lv_3y	add.l	#10000000,d0
	move.b	#$30,(a0)
lv_4	addq.b	#1,(a0)
	sub.l	#1000000,d0
	bge.s	lv_4
	cmp.b	#$31,(a0)	;zero answer
	bne.s	lv_4x	;if not, carry on
	cmp.l	a0,a1	;leading zero
	beq.s	lv_4y	;if so, write over it
lv_4x	subq.b	#1,(a0)+
lv_4y	add.l	#1000000,d0
	move.b	#$30,(a0)
lv_5	addq.b	#1,(a0)
	sub.l	#100000,d0
	bge.s	lv_5
	cmp.b	#$31,(a0)	;zero answer
	bne.s	lv_5x	;if not, carry on
	cmp.l	a0,a1	;leading zero
	beq.s	lv_5y	;if so, write over it
lv_5x	subq.b	#1,(a0)+
lv_5y	add.l	#100000,d0
	move.b	#$30,(a0)
lv_6	addq.b	#1,(a0)
	sub.l	#10000,d0
	bge.s	lv_6
	cmp.b	#$31,(a0)	;zero answer
	bne.s	lv_6x	;if not, carry on
	cmp.l	a0,a1	;leading zero
	beq.s	lv_6y	;if so, write over it
lv_6x	subq.b	#1,(a0)+
lv_6y	add.l	#10000,d0
	move.b	#$30,(a0)
lv_7	addq.b	#1,(a0)
	sub.l	#1000,d0
	bge.s	lv_7
	cmp.b	#$31,(a0)	;zero answer
	bne.s	lv_7x	;if not, carry on
	cmp.l	a0,a1	;leading zero
	beq.s	lv_7y	;if so, write over it
lv_7x	subq.b	#1,(a0)+
lv_7y	add.l	#1000,d0
	move.b	#$30,(a0)
lv_8	addq.b	#1,(a0)
	sub.l	#100,d0
	bge.s	lv_8
	cmp.b	#$31,(a0)	;zero answer
	bne.s	lv_8x	;if not, carry on
	cmp.l	a0,a1	;leading zero
	beq.s	lv_8y	;if so, write over it
lv_8x	subq.b	#1,(a0)+
lv_8y	add.l	#100,d0
	move.b	#$30,(a0)
lv_9	addq.b	#1,(a0)
	sub.l	#10,d0
	bge.s	lv_9
	cmp.b	#$31,(a0)	;zero answer
	bne.s	lv_9x	;if not, carry on
	cmp.l	a0,a1	;leading zero
	beq.s	lv_9y	;if so, write over it
lv_9x	subq.b	#1,(a0)+
lv_9y	add.l	#10,d0
	move.b	#$30,(a0)
lv_A	addq.b	#1,(a0)
	subq.l	#1,d0
	bge.s	lv_A
	subq.b	#1,(a0)+
	addq.l	#1,d0
	clr.b	(a0)+
	rts
	
***************************************************************************
* All this bit checks for valid system base and finds TOS number

tos_check	move.l  	$4f2.w,a0		get system base address, _sysbase
        	move.l  	a0,sys_base   	save for later use
        	lea   	$14(a0),a0       	add $14 to get '_os_magic' value 
        	move.l  	(a0),a1
        	move.l  	(a1),d0

*  should be 'magic' number #$87654321 in d0. This should be tested
*  to confirm that we have a valid sys_base. Assume ok (not anymore!).

	bsr	base_ok?

        	clr.l   	d0
        	move.l  	sys_base,a4	;safe register
        	addq.l   	#2,a4 	;add 2 to get actual TOS versions
	move.l	#tosver,a0
	bsr	print
        	move.b  	(a4)+,d0
	move.l	#memsize,a0
	bsr.s	byte_val	
	move.l	#memsize,a0
	bsr	print
	move.l	#tosrev,a0
	bsr	print
	move.b	(a4),d0	;frigged - want hex not decimal
	lsr.b	#4,d0	;1st hex digit
	move.l	#memsize,a0
	bsr.s	byte_val
	move.b	(a4),d0
	and.b	#15,d0	;2nd hex digit
	move.l	#memsize+1,a0
	bsr.s	byte_val
	move.l	#memsize,a0
	bsr	print
	move.l	#crlf,a0
	bsr	print
	rts
	
byte_val	ext.w	d0
	ext.l	d0
	move.l	a0,a1
	divu	#100,d0
	move.b	#$30,(a0)
	cmp.b	#0,d0	;leading zero?
	bne.s	bv_1x
	cmp.l	a0,a1
	beq.s	bv_1y
bv_1x	add.b	d0,(a0)+
bv_1y	swap	d0	;remainder
	ext.l	d0
	divu	#10,d0
	move.b	#$30,(a0)
	cmp.b	#0,d0	;leading zero?
	bne.s	bv_2x
	cmp.l	a0,a1
	beq.s	bv_2y
bv_2x	add.b	d0,(a0)+
bv_2y	swap	d0	;remainder
	move.b	#$30,(a0)
	add.b	d0,(a0)+
	clr.b	(a0)+
	rts
; sys_base check by T.S.C.
; We really only need to check one part of d0 for the valid sys_base but 
; lets do both anyway.

base_ok?	cmp.l	#$87654321,d0		check _sysbase
	beq.s	itsok		ok?  so its a valid sys_base
badnews	lea	bad_base,a0
	bsr.s	print
	bra	cont		exit cos invalid sys_base
itsok	lea	ok_base,a0
	bsr.s	print
	rts
***************************************************************************
* Check for STE - should use cookie jar! - assuming it exists!

ste_hard	lea	$5a0.w,a4
	tst.l	$5a0.w
	beq.s	notcookie
	move.l	(a4),a4
nxt_cookie	move.l	(a4)+,d0	;cookie
	move.l	(a4)+,d1	;value
	tst.l	d0
	beq.s	ian	;end of cookies	
	cmp.l	#"_MCH",d0
	bne.s	nxt_cookie
	swap	d1	;high word contains machine type
	lsl.w	#2,d1	;index to messages
	move.l	#mch_types,a0
	move.l	(a0,d1.w),a0
	bsr.s	print
	rts
notcookie	move.l	#no_e_in_it,a0
	bsr.s	print
ian	rts

***************************************************************************
print	move.l  	a0,-(sp)  	print message
       	move.w  	#9,-(sp)  
       	trap    	#1
       	addq.l  	#6,sp     
	rts
wait	move.w	#7,-(sp)		wait for a key
	trap	#1
	addq.l	#2,sp
	rts

	bss
sys_base	ds.l	1
memsize	ds.b	12	;room for 32 bit number
	data
mch_types	dc.l	stfm,ste,tt,falc
stfm	dc.b	"This is a vanilla flavour ST",13,10,0
ste	dc.b	"This is an STE",13,10,0
tt	dc.b	"This is the Infamous TT",13,10,0
falc	dc.b	"This Lucky Sod has a falcon!",13,10,0
bad_base	dc.b	"Invald System Base!!!",0
ok_base	dc.b	"Valid System Base",13,10,0
tosver	dc.b	"TOS Version ",0
tosrev	dc.b	" Revision ",0
no_e_in_it	dc.b	"This Is An Old TOS with NO COOKIES!",13,10,0
nostix	dc.b	"There Is A Diagnostic Cartridge Plugged In",13,10,0
ripper	dc.b	"There Is A User Cartridge Plugged In And Active",13,10,0
rip2	dc.b	"Containing: ",13,10,0
rip3	dc.b	"            ",0
crlf	dc.b	13,10,0
cartless	dc.b	"No Cartridges Detected/Active",13,10,0
memmsg1	dc.b	"There is ",0
memmsg2	dc.b	"K of system RAM present",13,10,0
	even




