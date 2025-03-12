* Smart-code by Tobias Nilsson
start:
	move.l	4(sp),a5
	move.l	$0c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$1100,d0
	move.l	a5,d1
	add.l	d0,d1
	and.l	#-2,d1

	move.l	d1,sp
	move.l	d0,-(sp)		; bytes to keep
	move.l	a5,-(sp)		; where...
	move.w	d0,-(sp)		; dummy
	move.w	#74,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi.l	error

*********

	pea	$0			; super
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,old_sp

	pea 	txt1(pc)  
	move.w	#9,-(sp) 
	trap	#1      
	addq.l	#6,sp  

	tst.l	$42A
	beq.s	no_fuck
	pea 	txt2(pc)  
	move.w	#9,-(sp) 
	trap	#1      
	addq.l	#6,sp  
no_fuck:
***
	move.l	$8,d0
	cmp.l	$c,d0
	bne.s	not_inst
	cmp.l	$10,d0
	bne.s	not_inst

	pea 	txt3(pc)  
	move.w	#9,-(sp) 
	trap	#1      
	addq.l	#6,sp  

	bsr.s	pause
	bra.s	end
***
not_inst:

;	bsr.s	pause

	move.l	#end_phenix,d0
	sub.l	#phenix_code,d0
	move.l	d0,length

	move.l	d0,-(sp)	; bytes to reserve
	move.w	#72,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	beq.L	error

;	rts
;	move.l	#$30000,d0

	move.l	d0,start_code

* relocate
	lea	phenix_code,a0
	move.l	d0,a1
	
	move.w	length+2,d7
	subq.w	#1,d7
reloc:	move.b	(a0)+,(a1)+
	dbf	d7,reloc

;	move.l	#phenix_code,start_code	; !!!

	bsr	set_vectors
;	bsr	set_old
;	rts
;	pea	old_sp			; not super

end:
	bsr.s	pause

	pea	0
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

;	clr.w	-(sp)			; pterm
;	trap	#1
	
	move.w	#-1,-(sp)		; exit & keep prg
	move.l	#18000,-(sp)
	move.w	#49,-(sp)
	trap	#1


old_sp:	dc.l 0

pause:
	move.w	#0,$468.w
p_lp:	cmp.w	#125,$468.w
	blo.s	p_lp
	rts

**********************************
* Warning! No userfriendly code! *
**********************************
set_vectors:

	lea	$8,a0
	lea	old_vectors,a1
	move.l	(a0),(a1)+	; bus error
	move.l	start_code,(a0)+
	move.l	(a0),(a1)+	; addr error
	move.l	start_code,(a0)+
	move.l	(a0),(a1)+	; illegal
	move.l	start_code,(a0)+
	rts

old:
	lea	old_vectors,a0
	lea	$8,a1
	move.l	(a0)+,(a1)+	; bus error
	move.l	(a0)+,(a1)+	; addr error
	move.l	(a0)+,(a1)+	; illegal
	rts

txt1:
dc.b 27,69,13,10
dc.b "Bus, addr & illegal error "
dc.b "will reset!"		
dc.b 27,89,35,32
dc.b "(C) Tobias Nilsson T0300/29623",0
txt2:
dc.b 27,89,39,32
dc.b "By the way, I found shit in res"
dc.b "-vector!",0
txt3:
dc.b 27,89,37,32
dc.b "This is already installed!!",0
even

length:		dc.l 0
start_code:	dc.l 0
error:	illegal
old_vectors:	blk.l 3,0


phenix_code:
;	reset

	move.w	sr,d0
	btst	#13,d0
	bne.s	super_ready

	pea	$0			; super
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

super_ready:
	move.w	#$2700,sr
	
	moveq	#-1,d0
col_lp:	addq.b	#1,$ffff8240.w
	nop
	nop
	nop
	nop
	nop
	dbf	d0,col_lp

	reset				; Ohh... I love it!

;	rts	

	dc.b "Code by Techwave/ICE -93!"
	even
end_phenix:	
