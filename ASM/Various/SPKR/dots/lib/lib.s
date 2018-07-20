
	SECTION TEXT
checkMachineTypeAndSetStuff
    move.l  $5a0.w,d0
    beq.s   .st             ;Null pointer = ST
    move.l  d0,a0

    move.l  #128-1,d7
.search_mch:    
    tst.l   (a0)
    beq.s   .st             ;Null termination of cookiejar, no _MCH found = ST
    cmp.l   #"_MCH",(a0)
    beq.s   .mch_found
    addq.l  #8,a0
    dbra    d7,.search_mch
    bra.s   .st             ;Default to ST

.mch_found: 
    move.l  4(a0),d0
    cmp.l   #$00010000,d0
    beq.s   .ste
    cmp.l   #$00010010,d0
    beq.s   .megaste
    cmp.l   #$00020000,d0
    beq.s   .tt

.st:        
    move.l  #"ST  ",_computer_type
    bra.s   .cookie_done

.ste:       
    move.l  #"STe ",_computer_type
    move.w  #1,_is_ste
    bra.s   .cookie_done

.megaste:   
    move.l  #"MSTe",_computer_type
    clr.b	$FF8E21
    bra.s   .cookie_done

.tt:        
    move.l  #"TT  ",_computer_type
;    bra.s   .cookie_done

.cookie_done

    tst.w   _is_ste
    beq     .no_ste
    	move.b	$FF820D,_FF820D
    	move.b	$FF820F,_FF820F
    	move.b	$FF8265,_FF8265
        move.b  #0,$FF820D
        move.b  #0,$FF820F
        move.b  #0,$FF8265
.no_ste
	rts

restoresForMachineTypes
	tst.w	_is_ste
	beq		.no_ste
    	move.b	_FF820D,$FF820D
    	move.b	_FF820F,$FF820F
    	move.b	_FF8265,$FF8265
.no_ste
	rts

disableMouse:
	move.b	#$12,$fffffc02.w		;Kill mouse
	rts

_save_keymode	ds.b	1
	even

enableMouse:
	move.b	#$8,$fffffc02.w			;Enable mouse
	move.l	#$80,d0
.x
	btst	#1,$fffffc00.w
	beq.s	.x
	move.b	d0,$fffffc02.w

	move.l	#$01,d0
.y
	btst	#1,$fffffc00.w
	beq.s	.y
	move.b	d0,$fffffc02.w

	moveq	#0,d0
.z	
	btst	#0,$fffffc00.w
	beq.s	.z
	move.b	d0,$fffffc02.w
	rts


;superUserMode:
;            clr.l 	-(a7) 
;            move.w 	#32,-(a7)
;            trap 	#1
;            addq.l 	#6,a7
;            move.l 	d0,_old_stack
;            rts
;
;_old_stack	ds.l	1
;
;userMode:
;            move.l	_old_stack,-(a7) 
;            move.w  #32,-(a7)  
;            trap 	#1
;            addq.l  #6,a7  
;            rts
;
;quit:
;			clr.w   -(A7)
;			trap    #1


backupPalAndScrMemAndResolutionAndSetLowRes:
	lea		_save_screenadr,a0    		;  the address of where to be saved
	move.b	$ffff8201.w,(a0)+		; move data in
	move.b	$ffff8203.w,(a0)+
	move.b	$ffff820d.w,(a0)+

	; save the palette
	movem.l $ffff8240.w,d0-d7		; load the palette bites into data regs
	movem.l	d0-d7,_save_pal			; move the data to the pointed address
	
	;save old resolution
	move.b	$ffff8260.w,_save_res    ; save old
	wait_for_vbl
	clr.b	$ffff8260.w				; set low res
	wait_for_vbl

	rts


restorePalAndScreenMemAndResolution
		move.b	_save_res,$ffff8260.w		;Restore old resolution
		movem.l	_save_pal,d0-d7				;Restore old palette
		movem.l	d0-d7,$ffff8240.w			;

		lea		_save_screenadr,a0			;Restore old screen address
		move.b	(a0)+,$ffff8201.w			;
		move.b	(a0)+,$ffff8203.w			;
		move.b	(a0)+,$ffff820d.w			;
	rts


setScreen64kAligned
	;align new screen address
	move.l	#screen1+65536,d0
	move.w	#0,d0
	move.l	d0,screenpointer

	move.l	d0,$ffff8200.w

	;align new screen address for double buffer

	add.l	#$10000,d0
	move.l	d0,screenpointer2
	rts

;_start:
;;................................................................
;    move.l  4(sp),a5                
;    move.l  $0c(a5),d0              
;    add.l   $14(a5),d0              
;    add.l   $1c(a5),d0              
;    add.l   #$1000,d0               
;    add.l   #$100,d0                
;    move.l  a5,d1                   
;    add.l   d0,d1                   
;    and.l   #-2,d1                  
;    move.l  d1,sp                   
;    move.l  d0,-(sp)                
;    move.l  a5,-(sp)                
;    move.w  d0,-(sp)                
;    move.w  #$4a,-(sp)              
;    trap    #1                      
;    lea     12(sp),sp               
;
;	pea 	demo
;	move.w	#$26,-(sp)
;	trap	#14
;	addq.l	#6,sp
;	
;	clr.w	-(sp)
;	trap	#1    
;
;demo:


initMusic:
	move.l	sndh_pointer,a0
	jsr		(a0)
	rts



stopMusic
		move.l	sndh_pointer,a0
		jsr		4(a0)
			move.l	#8*256,d0
	  		move.l	#$ffff8800,a1
	  		move.l	#3-1,d1
.loop:
	  		movep.w	d0,(0,a1)
	  		add.w	#256,d0
	  		dbra	d1,.loop

		move.l	#$80,d0
.x
		btst	#1,$fffffc00.w
		beq.s	.x
		move.b	d0,$fffffc02.w

		move.l	#$01,d0
.y
		btst	#1,$fffffc00.w
		beq.s	.y
		move.b	d0,$fffffc02.w

		moveq	#0,d0
.z		
		btst	#0,$fffffc00.w
		beq.s	.z
		move.b	d0,$fffffc02.w
	rts

saveAndKillTimers
		move.w	#$2700,sr					;Stop all interrupts (using $ means hexidecimal)
		move.l	$70.w,_save_vbl				;Save old VBL
		move.l	$68.w,_save_hbl				;Save old HBL
		move.l	$134.w,_save_ta				;Save old Timer A
		move.l	$120.w,_save_tb				;Save old Timer B
		move.l	$114.w,_save_tc				;Save old Timer C
		move.l	$110.w,_save_td				;Save old Timer D
		move.l	$118.w,_save_acia			;Save old ACIA
		move.l	#dummyvbl,$70.w				;Install our own VBL
		move.l	#dummy,$68.w				;Install our own HBL (dummy)
		move.l	#dummy,$134.w				;Install our own Timer A (dummy)
		move.l	#dummy,$120.w				;Install our own Timer B
		move.l	#dummy,$114.w				;Install our own Timer C (dummy)
		move.l	#dummy,$110.w				;Install our own Timer D (dummy)
		move.l	#dummy,$118.w				;Install our own ACIA (dummy)
		move.b	$fffffa07.w,_save_inta		;Save MFP state for interrupt enable A
		move.b	$fffffa13.w,_save_inta_mask	;Save MFP state for interrupt mask A
		move.b	$fffffa09.w,_save_intb		;Save MFP state for interrupt enable B
		move.b	$fffffa15.w,_save_intb_mask	;Save MFP state for interrupt mask B
		clr.b	$fffffa07.w					;Interrupt enable A (Timer-A & B)
		clr.b	$fffffa13.w					;Interrupt mask A (Timer-A & B)
		clr.b	$fffffa09.w					;Interrupt enable B (Timer-C & D)
		clr.b	$fffffa15.w					;Interrupt mask B (Timer-C & D)
 		move.b  $484.w,_save_keymode               ; save keyclick
		move.w	#$2300,sr					;Interrupts back on
		move.b	#$12,$fffffc02.w			;Kill mouse
		rts

dummy
	rte
dummyvbl
	addq.w	#1,$466
	rte

restoreTimers:
		move.w	#$2700,sr					;Stop all interrupts
		move.l	_save_vbl,$70.w				;Restore old VBL
		move.l	_save_hbl,$68.w				;Restore old HBL
		move.l	_save_ta,$134.w				;Restore old Timer A
		move.l	_save_tb,$120.w				;Restore old Timer B
		move.l	_save_tc,$114.w				;Restore old Timer C
		move.l	_save_td,$110.w				;Restore old Timer D
		move.l	_save_acia,$118.w			;Restore old ACIA
		move.b	_save_inta,$fffffa07.w
		move.b	_save_inta_mask,$fffffa13.w	
		move.b	_save_intb,$fffffa09.w		;Restore MFP state for interrupt enable B
		move.b	_save_intb_mask,$fffffa15.w	;Restore MFP state for interrupt mask B
		clr.b	$fffffa1b.w					;Timer B control (Stop)
		move.b	_save_keymode,$484.w


	rts
	
; a0 vbl
; a1 hbl		
install_vbl_hbl:
		move.l	a0,-(sp)						;Save A0
		move.l	a1,-(sp)						;Save A0	
		move.w	#$2700,sr					;Stop all interrupts (using $ means hexidecimal)
		move.l	a0,$70.w					;Install our own VBL
		move.l	a1,$120.w					;Install our own Timer B
		clr.b	$fffffa07.w					;Interrupt enable A (Timer-A & B)
		clr.b	$fffffa13.w					;Interrupt mask A (Timer-A & B)
		clr.b	$fffffa09.w					;Interrupt enable B (Timer-C & D)
		clr.b	$fffffa15.w					;Interrupt mask B (Timer-C & D)
		move.w	#$2300,sr					;Interrupts back on
		move.l	(sp)+,a1
		move.l	(sp)+,a0
		rts


exitDemo	macro
	move.w	#$2700,sr
	move.l	#dummyvbl,$70.w				;Install our own VBL
	move.l	#dummy,$68.w				;Install our own HBL (dummy)
	move.l	#dummy,$134.w				;Install our own Timer A (dummy)
	move.l	#dummy,$120.w				;Install our own Timer B
	move.l	#dummy,$114.w				;Install our own Timer C (dummy)
	move.l	#dummy,$110.w				;Install our own Timer D (dummy)
	move.l	#dummy,$118.w				;Install our own ACIA (dummy)
	clr.b	$fffffa07.w					;Interrupt enable A (Timer-A & B)
	clr.b	$fffffa13.w					;Interrupt mask A (Timer-A & B)
	clr.b	$fffffa09.w					;Interrupt enable B (Timer-C & D)
	clr.b	$fffffa15.w					;Interrupt mask B (Timer-C & D)
	move.w	#$2300,sr

	jsr	restoreLowerMem
	jsr restoresForMachineTypes
	jsr	restorePalAndScreenMemAndResolution
	jsr	restoreTimers
	jsr	stopMusic
	jsr	enableMouse
	rts
	endm

	SECTION BSS
sndh_pointer	ds.l	1
no_music		ds.l	5

_save_vbl		ds.l	1
_save_hbl		ds.l	1
_save_ta		ds.l	1
_save_tb		ds.l	1
_save_tc		ds.l	1
_save_td		ds.l	1
_save_acia		ds.l	1
_save_inta		ds.b	1
_save_inta_mask	ds.b	1
_save_intb		ds.b	1
_save_intb_mask	ds.b	1
_save_pal		ds.l	8
_save_screenadr	ds.l	1
_save_res		ds.b	1

;	even
_FF8265			ds.b	1
_computer_type	ds.l	1
_is_ste			ds.w	1
_FF820D			ds.b	1
_FF820F			ds.b	1

	even
	SECTION DATA