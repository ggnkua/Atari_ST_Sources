* Degas low res picture displayer
* coded by Runrig

	clr.l	-(a7)		; into supervisor mode please
	move.w	#$20,-(a7)	; function SUPERMODE
	trap	#1		; call GEMDOS
	addq.l	#6,a7		; fix stack
	move.l	d0,SSP		; save supervisor stack pointer

	dc.w	$A00A		; hide mouse

	move.w	#0,-(a7)	; low res
	move.l	#-1,-(a7)	; keep PHYSIC the same
	move.l	#-1,-(a7)	; keep LOGIC the same
	move.w	#5,-(a7)	; function SETSCREEN
	trap	#14		; call XBIOS
	add.l	#12,a7		; fix stack

	move.w	#2,-(a7)	; function GET PHYSIC
	trap	#14		; call XBIOS
	addq.l	#2,a7		; fix stack
	move.l	d0,PHYSIC	; save address of PHYSIC
	
	move.l	#$FFFFF8240,a1 	; address of colour registers
	move.l	#OLD_PAL,a0	; address of space to save palette in
	
	move.l	#15,d0		; number of colours to save minus 1
save_pal	
	move.w	(a1)+,(a0)+	; save colour
	dbf	d0,save_pal	; decrement d0 and loop

	move.l 	#pic+2,a1	; address of degas palette
	move.l	#$FFFFF8240,a0  ; address of colour registers
	
	move.l	#15,d0		; number of colours to change-1
col_set
	move.w	(a1)+,(a0)+	; set colour
	dbf	d0,col_set	; decrement d0 and loop

	move.l	#7999,d0	; number of longs to set (32000/4)-1
	move.l	#pic+34,a1	; address of picture data
	move.l	PHYSIC,a0	; address of physical screen
display	
	move.l	(a1)+,(a0)+	; move pic data into screen
	dbf	d0,display	; decrement d0 and loop
	
	move.w	#7,-(a7)	; function WAIT KEY
	trap	#1		; call GEMDOS
	addq.l	#2,a7		; fix stack

	move.l 	#OLD_PAL,a1	; address of saved palette
	move.l	#$FFFFF8240,a0  ; address of colour registers
	
	move.l	#15,d0		; number of colours to change-1
col_restore:
	move.w	(a1)+,(a0)+	; restore colour
	dbf	d0,col_restore	; decrement d0 and loop

	dc.w	$A009		; show mouse

	move.l	SSP,-(a7)	; back into user mode please
	move.w	#$20,-(a7)	; function SUPERMODE
	trap	#1		; call GEMDOS
	addq.l	#6,a7		; fix stack
	
	clr.l	-(a7)		; function QUIT
	trap	#1		; call GEMDOS

* Space to save supervisor stack pointer
SSP:	ds.l	1

* Space to save address of physical screen
PHYSIC:	ds.l	1	

* Space to save old palette
OLD_PAL	ds.w	16

* A degas picture. Change to whatever you want to display.
* This is a picture of the editor of this great publication
* and its main coder!
* I (Runrig) am on the left and Eddie is on the right!
* Ugly gits aren't we?

pic:	incbin	"\source\asm\2.PI1"	

; I must point out that this picture was taken during the Great British
; International ST Party by a guy from the Sub Humans In Turkey who
; had brought VIDI-ST with in. Notice the bags under my eyes.....	

; Please write to us and let us know who you think is the ugliest
; member of the HP Source team, Eddie or I. Send your letters to:
; I think Eddie is the ugliest,
;	Ugly Compo,
;	   	HP Source,
;			Cwm Cottage,
;				Abermule,
;					Montgomery,
;						Welshpool
;							Powys,
;	                                                    SY15 6JL