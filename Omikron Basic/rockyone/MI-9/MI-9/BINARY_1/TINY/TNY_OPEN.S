; rockyone			pour MI-3			23/06/2016
;
;                 OPEN TNY	TNY,TN1,TN2,RN3
;		  ------------------------------
; Decompresses aslo tny image with bytes too			
;			
; Buf_tiny 	: Buffer size file + two bytes reserved
; Destination	: buffer 32034 bytes
; Anime	  	: Buffer 34 bytes 
; 
;	
; bload "pic.tny", Buf_tiny+1
;------------------**********
;
; 	CALL Tny_open( L Buf_Tny,L destination, L Anime )
;       ----------------********------------------------   	     
;
; Return low  d0 .... 	-2  Erreur number of bytes of control or  
;               	    erreur number of word image data         
;   		     	Or number cycle color  ( if not error )
;	             	 
;
;Return in Anime :  16 word cycle color format Degas Elite / or nothinq 
;		     1 word time animation for viewer
;
;-------------------------------------------------------------------------
;1(a0) source
;a1 a6 destination
;a2    anime

	movem.l	d1-d7/a0-a6,-(a7)
 	movem.l	60(sp),a0-a2

	lea.l	34(a0),a6		; Pointe to number bytes of conrol
	addq.l	#1,a0

;....................test resolution image / resolution ‚cran.............
	moveq.l	#0,d1
	move.b	(a0),d1
	cmp.b	#3,d1			; cycle color ? 
	bmi.s	ok_resol		; no
	subq.b	#3,d1
	addq.l	#4,a6			; Pointe to number bytes of conrol

ok_resol:
	move.w	d1,resol		; stok resol

;........................................................................
	moveq.l	#-2,d0		;R. erreur	

 	cmp.w	#10668,(a6)+	; contol the number of bytes of control
	bpl	end_prg		;  > 10667 

	cmp.w	#16001,(a6)	; contol the number of word of image data  
	bmi.s	ok_word		; Format TNY

	sub.w	#$8000,(a6)	; Sometimes modified by Synth‚tic_Art v3
	cmp.w	#16001,(a6)	;  >16000       
	bpl	end_prg		;

ok_word:
	moveq.l	#0,d0		;R. no error


;..Activate these line of code if your Anime buffer is unprepared.........	
*	move.l	#$10001,16(a2)	; Initialise the sens of color cycle
*	move.l	#$10001,20(a2)  ; animation Degas Elite size


;.......................................Test Cycle ..................
	cmp.b	#3,(a0)+
	bmi.s	not_cycle

	moveq.l	#1,d0			;R. number cycle

	move.b  (a0),d1			; first color cycle
	lsr.b	#4,d1			; 
	move.b	d1,1(a2)		;
     
	move.b	(a0)+,9(a2)		; last color cycle
	andi.b 	#$f,9(a2)		;


	move.b	#0,17(a2) 		; left
	move.b	(a0)+,25(a2)		; -128 to 128 ?
	bmi.s	left			; yes if negative !

	move.b	#2,17(a2)		; reverse direction	
	neg.b	25(a2)			; + to - 
	sub.b	#128,25(a2)		;
	bra.s	iteration
left:
	add.b	#128,25(a2)
;.......................................

iteration:
	move.w	(a0)+,32(a2)		; time animation for wiever

not_cycle:
	move.w	resol,(a1)+		; copy resolution

;...............................display palette

	moveq.l	#7,d1
color:
	move.l	(a0)+,(a1)+
	dbra.w	d1,color
	

;...........................................
;a0 >>> bytes of control
;a2 >>> words data on peer address

	move.w 	(a0)+,d7	; number of bytes of control	**
	move.w	(a0)+,d1	; number of words of data image	**

	lea.l 0(a0,d7.w),a2	; address word dada

	move.l	a2,d2		;
	and.l	#1,d2 		; peer address ?
	beq.s 	peer_address	; yes

 	lsl.l	#1,d1		; Number of data bytes to move
	adda.w	d1,a2		; Start end buffer Source

	subq.b	#1,d1		; -1 for dbra
recopy:
	move.b	-(a2),1(a2)
	dbra.w	d1,recopy
	addq.w	#1,a2

;------------------------------DEPAKT IMAGE-----------------------------
peer_address:	
*	subq.b	#1,d7		; Number of control byte -1 for dbra
	movea.l	a1,a3		; screen
	moveq.l	#0,d1		; byte repetition
	moveq.l	#0,d3		; repeat counter
	move.l	#200,d4		; line
	moveq.l	#0,d5		; column
	moveq.l	#0,d6		; a repeat data( word )
	moveq.l	#4,d2		; 80 column for picture outsized TNY
;				; And the unneccessary byte format TNY
boucle:
	move.b	(a0)+,d1	; read a new control byte
	cmpi	#127,d1		; >= 127 ?
	bgt.s	plus_127	;        yes
        cmpi	#2,d1		; < 2 ?
	blt.s	moin_2		;        yes

	move	d1,d3		;
	subq	#1,d3		; repeat counter -1
	bra.s	data_repeat
moin_2: 	
	move.b	(a0)+,d3	;
	mulu	#256,d3		;
	add.b	(a0)+,d3	;
	subq	#1,d3		;

*	subq	#2,d7		; count bytes of control

	tst	d1		; byte repetition
	beq.s 	data_repeat
	bra.s	data_unique	

plus_127:
	move	d1,d3
	eori	#255,d3
*------------------------------------------------
data_unique:
	move.w	(a2)+,(a1)
	subq	#1,d4		; line -1
	beq.s	lig_200		; if = 0
	lea	160(a1),a1	; next line

	dbra	d3,data_unique
	bra.s	next
;...............................next column
lig_200:
	move.w	#200,d4
	addq	#8,d5		; next column
	cmpi	#158,d5		; last column of a group ?  (20 colonne)
	ble.s	moin_158	; no. 			   
***
	subq.b	#1,d2		; end of the last column ?  ( 80 column )
	beq.s	end_prg		; no
***
	subi	#158,d5		; first colum of the next group
moin_158:
	lea	0(a3,d5),a1	; next column
	dbra	d3,data_unique
	bra.s 	next
*------------------------------------------------
data_repeat:
	move.w	(a2)+,d6
repeat_data:
	move.w	d6,(a1)
	subq	#1,d4		; last line ?
	beq.s	lg_200		; yes  d4 = 0

	lea	160(a1),a1	; next line
	dbra	d3,repeat_data	
	bra.s	next
;...............................
lg_200:
	move.w	#200,d4		; 200 line per column
	addq	#8,d5		; next column
	cmpi	#158,d5		; last column of a group ?   20 column
	ble.s	same_plan	; no
****
	subq.b	#1,d2		; end of the last column ?   80 column 
	beq.s	end_prg		; yes 	
****
	subi	#158,d5		; first column , next group 

same_plan:
	lea	0(a3,d5),a1  	; hight column
	dbra 	d3,repeat_data

next:
	tst.b	d2
	bhi	boucle		; plan suivant

* 	dbra 	d7,boucle 	; another control byte ?

;..................................................
end_prg:
	movem.l	(a7)+,d1-d7/a0-a6
 	rts

;.............................................
resol:
	dc.w	0
	end
;.............................................