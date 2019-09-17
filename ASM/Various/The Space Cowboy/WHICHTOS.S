; Thanks to the Untouchables for the cart detect etc.
; The TOS version finder was in the book 'Introducing Atari ST Machine
; Code'   I hope they don't mind us nicking it! (I re-wrote it a bit).

; This code finds out :-	which TOS you have
;			if the sys_base is valid
;			if you have an STE
;			if you have 1 meg or half
;			if there are cartridges 

; This code is just an example of how to find some system settings.

; Note:-  you can only detect user carts like the Ultimate Ripper if
; they are switched on.
; I do not know how to find out the memory config properly so someone
; else will have to show you.
; Errm...   thats it.		T.S.C.

        	pea	0.w		supervisor mode
        	move.w  	#$20,-(sp)
        	trap    	#1
        	addq.l   	#6,sp
        	move.l  	d0,oldsp

oldsp	dc.l	0
	
	bsr	ste_hard		run all checks
	bsr	checkmeg
	bsr	carty
	bsr	tos_check
	
cont	bsr	print
	bsr	wait

	pea	oldsp		back to user mode
        	move.w  	#$20,-(sp)
        	trap    	#1
        	add.l   	#6,sp

	pea	0.w		quit
	trap	#1      

***************************************************************************
* Check for some carts

carty	cmp.l	#$fa52235f,$fa0000	diagnostix cartridge?
	bne.s	nextbit
	lea	nostix,a0
	bsr	print
	bra	honda
nextbit	cmp.l	#$abcdef42,$fa0000	user cartridge? (rippers etc)
	bne.s	kein_cart
	lea	ripper,a0
	bsr	print
	bra	honda
kein_cart	lea	cartless,a0
	bsr	print
honda	rts

***************************************************************************
* One way of checking for a meg of memory!

checkmeg	move.l	#"Meg!",$80000	
	cmp.l	#"Meg!",$80000
	bne.s	halfmeg
	lea	meg_mess,a0
	bsr	print
	bra	endy
halfmeg	lea	half_meg,a0
	bsr	print
endy	rts

***************************************************************************
* All this bit checks for valid system base and finds TOS number

tos_check	move.l  	$4f2,a0		get system base address, _sysbase
        	move.l  	a0,sys_base   	save for later use
        	add.l   	#$14,a0       	add $14 to get '_os_magic' value 
        	move.l  	(a0),a1
        	move.l  	(a1),d0

*  should be 'magic' number #$87654321 in d0. This should be tested
*  to confirm that we have a valid sys_base. Assume ok (not anymore!).

	bsr	base_ok?

        	clr.l   	d0
        	move.l  	sys_base,a0
        	addq.l   	#2,a0    		add 2 to get actual TOS versions
        	move.w  	(a0),d0
	cmpi.w  	#$100,d0		100 = tos 1.0 (1986)
        	beq.s    	tos1	
        	cmpi.w  	#$102,d0		102 = tos 1.2 + blitter (1987)
        	beq.s    	tos2
        	cmpi.w  	#$104,d0		104 = tos 1.4 (1988)
        	beq.s    	tos3
        	cmpi.w  	#$106,d0		106 = STE tos 1.6 with blitter
        	beq.s    	tos4
        	bra     	no_recog 	  if we are here the tos was not recognised !

tos1	lea  	tos_v1,a0		this bit puts the correct message
        	bra    	cont		in a0 so it can be printed
tos2	lea  	tos_v2,a0
        	bra    	cont
tos3	lea  	tos_v3,a0
        	bra    	cont
tos4	lea  	tos_v4,a0
	bra	cont
no_recog	lea	not_tos,a0
	bra	cont

; sys_base check by T.S.C.
; We really only need to check one part of d0 for the valid sys_base but 
; lets do both anyway.

base_ok?	cmpi.w	#$4321,d0		check 1st part
	bne.s	badnews		oh oh  invalid sys_base !
	swap	d0	

; swap high and low order words so we can get at the rest of the number.

	cmpi.w	#$8765,d0		check 2nd part
	beq.s	itsok		ok?  so its a valid sys_base
	bra	badnews		oh oh  invalid sys_base !
	rts

badnews	lea	bad_base,a0
	bra	cont		exit cos invalid sys_base
itsok	lea	ok_base,a0
	bsr	print
	rts
***************************************************************************
* Check for STE

ste_hard	cmp.l	#$e00000,$4.w	
	bge.s	notste
	lea	bugger,a0
	bsr	print
	bra	ian
notste	lea	no_e_in_it,a0
	bsr	print
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

	section data

sys_base	ds.l	1
meg_mess	dc.b	"1 Meg Memory",13,10,0
half_meg	dc.b	"512k Memory",13,10,0
bad_base	dc.b	"Invald System Base!!!",0
ok_base	dc.b	"Valid System Base",13,10,0
tos_v1	dc.b	"TOS Version 1.00",0
tos_v2	dc.b	"TOS Version 1.2",0
tos_v3	dc.b	"TOS Version 1.4",0
tos_v4	dc.b	"TOS Version STE 1.6",0
not_tos	dc.b	"TOS not recognised!!!",0
no_e_in_it	dc.b	"This Is An STF/STFM",13,10,0
bugger	dc.b	"This Is An STE",13,10,0
nostix	dc.b	"There Is A Diagnostic Cartridge Plugged In",13,10,0
ripper	dc.b	"There Is A User Cartridge Plugged In And Active",13,10,0
cartless	dc.b	"No Cartridges Detected/Active",13,10,0
	even




