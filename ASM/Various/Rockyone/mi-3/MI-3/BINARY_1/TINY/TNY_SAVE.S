;rockyone			pour Mi-3			25/06/2016
;--------
;                       	Save Tiny format
:
:
; Source      : Buffer imagr fotmat DEGAS PI1-3
; 
; Destination : address buffer of 64045 bytes.32045 bytes maximum for TNY 	
; 	          			      32000 bytes to convert image
;
; Anime	      : address of a buffer containing 34 bytes :
;		16 word color cycle in the format Degas-Elite                         
;		+ 1 word total time animation for viewer( 0 to 128 )
;		---
;		Or 34 bytes equal zero 
;
;		call tny_save ( L Source, L Destination, L Anime )
;		--------------------------------------------------
;
; Return:  	In low d0   The total file size
; 		I high d0   -4 if number cycle valide >1
;
; Return the complete file to be saved in a buffer Destination+1
;		     			    ********************
;
; save  Fwrite (L "file.tny", L destination+1, low(lpeek(reserved(0))) )
;..........
;a0 Source
;a1 Destination
;a2 Anime
	movem.l	d1-d7/a0-a6,-(sp)
	movem.l	60(sp),a0-a2
        addq.l	#1,a0

	lea.l	32002(a1),a6		; to convert image 
 	addq	#1,a1			; Start image

	move.b	(a0)+,(a1)+		; screen resolution

	moveq.l	#0,d0			;R. too color cycles

;........................................Account of valid and active color cycle.
;a3 Anime

	moveq.l	#3,d4			;
	moveq.l	#0,d1			; number of active cycle	
loop_cycle:
	cmp.w	#1,16(a2)		; Active cycle ?
	beq.s	next_cycle		; no	

	tst.w	24(a2)			; vbl cycle ?
	beq.s	next_cycle		; no

	move.w	0(a2),d2		; Fist color cycle
	sub.w	8(a2),d2		; < Last color cycle ?
	bpl.s	next_cycle		; No 

	addq.b	#1,d1			; Account the valide cycles			
	movea.l	a2,a3			; Address cycle ok

next_cycle:				
	addq	#2,a2			
	dbra.w	d4,loop_cycle
;
	cmp.b	#2,d1			; Too cycle ?  if >1 
	bmi.s 	number_cycle		; no 
	moveq.l	#-4,d0			; error: too color cycle
	bra.s	not_cycle

number_cycle:
	tst.b	d1			; an active cycle ?
	beq.s	not_cycle		; no

	addq.b	#3,-1(a1)		; add one cycle color to resol

				
	move.w	0(a3),d4		; first color of cycle		
	lsl.w	#4,d4				
	add.b	9(a3),d4		; last color of cycle
	move.b	d4,(a1)+		; save first and last color cycle

;.......................................direction du cycle.............	
	move.w	24(a3),d4
	tst.w	16(a3)
	beq.s	save_direction
	neg.w	d4
	
save_direction:	
	add.w	#128,d4
	move.b	d4,(a1)+		; Direction and Vbl
			
	move.w	32(a3),(a1)+		; time for viewer		

not_cycle:
;........................................Copy palette................	
;a1 Destination
;a3 palette
*	movea.l	#$ff8240,a3
	moveq.l	#7,d4
copy_pal:
	move.l	(a0)+,(a1)+
	dbra.w	d4,copy_pal
;.......................................; Skip the  word nb_byte
;					; Skip the  word nb_data			
	adda.w	#4,a1			; Stard of contol byte 
	movea.l	a1,a5			; To calculat the number of byte
	
	move.l	a6,a1			; to convert the image 
*		a6			; to calculate the number of word
	
;.........................................Converting the image in four
;					  groups of columns (TNY  format)
;a0 source
;a1 destination

	move.w	#15999,d4		; 16000 word 
	lea	32000.w,a2		; end column				
	lea	160.w,a3		; end line
	sub.l	a4,a4			; a4=0

ConvertLoop:	
	move.w	0(a0,a4.w),(a1)+	; Copy word to destination
	add.l	a3,a4			; Next ligne 
	cmp.w	a2,a4			; Last line of the column ?
	blt.s	ConvSkip		; No
	lea	-32000+8(a4),a4		; Next column in order tny format
	cmp.w	a3,a4			; Last column of a group ? 20 col.
	blt.s	convSkip		; No
	lea	-158(a4),a4		; Point on the first colunm of 
;					; the next group
convSkip:
	dbra	d4,ConvertLoop		 

;.....................................compression of the four groups Tny.....	
;
;a6 a0 a3 a4       buffer group
;a5 a2,a1 	   buffer Destination
;			  		
	move.l	a5,a1		        ; start control byte
	move.l	a6,a0		        ; start word data
	move.l	a0,a2		  	;   "    "   "
	lea.l	32000(a0),a3		; end of the four groups
	move.l	a0,a4			; start group

NewCode	
	move.w	(a0)+,d4		; lecture d'un word data
	cmp.l	a0,a3			; End group ?
	beq.s	CodeCOPY		; yes
SameLoop	
	cmp.w	(a0)+,d4		; diff‚rant
	bne.s	NotSame			; yes
	cmp.l	a0,a3
	bne.s	SameLoop
	bra.s	CodeREPEAT

*	dc.b	"TINYPACK by Nucleus/HMD"
*	EVEN
*	************** MODIFIED BY ROCKYONE :  ******
NotSame	
	move.l	a0,d1			;
	sub.l	a4,d1			;
	cmpi.w	#4,d1			;#4
	bne.s	CodeREPEAT1
	cmp.l	a0,a3
	beq.s	CodeCOPY
	move.w	-2(a0),d4
NotSameLoop	
	move.w	(a0)+,d1
	cmp.w	d4,d1		
	beq.s	CodeCOPY1
	move.w	d1,d4		
	cmp.l	a0,a3
	bne.s	NotSameLoop
	bra.s	CodeCOPY

CodeCOPY1	
	subq.l	#4,a0			;#4
CodeCOPY	
	move.l	a0,d1
	sub.l	a4,d1
	lsr.w	#1,d1
	cmp.w	#127,d1			;end boucle ?
	ble.s	Less127			; yes <=
	move.b	#1,(a1)+
	movep	d1,0(a1)
	move.b	d1,1(a1)
	addq.w	#2,a1
	dbra	d1,copy
Less127	
	move.b	d1,(a1)
	neg.b	(a1)+
	subq.w	#1,d1
copy	
	move.w	(a4)+,(a2)+
	dbf	d1,copy
	cmp.l	a0,a3
	bne.s	NewCode
	bra.s	EndOfPict
CodeREPEAT1	
	subq.l	#2,a0
CodeREPEAT	
	move.l	a0,d1
	sub.l	a4,d1
	lsr.w	#1,d1
	cmp.w	#127,d1
	ble.s	Less127_1
	clr.b	(a1)+
	movep	d1,0(a1)
	move.b	d1,1(a1)
	addq.l	#2,a1
	bra.s	REPEATEnd
Less127_1
	move.b	d1,(a1)+
REPEATEnd	
	move.w	d4,(a2)+
	move.l	a0,a4		Start adr
	cmp.l	a0,a3
	bne	NewCode

EndOfPict
;...........................calculat the number of bytes of control......
	
	move.l	a1,d1                           ; adr last bytes
	sub.l	a5,d1				; adr first bytes
	move.w	d1,-4(a5)

;.......................................calculat the number of word......
	move.l	a2,d1			; last word
	sub.l	a6,d1			; first word
	lsr.w	#1,d1
	move.w	d1,-2(a5)		; save number of word
;					; Synthetic_art v3  add $8000 !?

;.........................................Recopy data word......
; TNY adds one control byte and one data word for a peer address !...
; Not me ! For my unpaking routine, load the files on an odd adress.
; In fact, here i would a odd address! :)

	lsl.w	#1,d1
	subq.b	#1,d1			; -1 pour dbra

recopy_data
	move.b	(a6)+,(a1)+
	dbra	d1,recopy_data

;.........................................END...............
	swap d0
	move.l	64(SP),a2	        	; adr star destination
	suba.l	a2,a1				;-adr last data word
	move.l	a1,d0			
	subq.b	#1,d0				; -1 added byte to a6 from
;						;  the routine.

	movem.l	(sp)+,d1-d7/a0-a6
	rts	

	end
;............................................................