;rockyone			pour MI-3 & Mi-9		13/02/2017
;
;
;
;			open|save Picworks CP3
;Op% 0 = open
;    1 = save
;	open	call	cp3_open( L source, L destination,W op%)
;	save	call	cp3_open( L destination, L source,W op%)
;
;Destination : 32034 byte
;Op%         : 0 for save, >0 for open
;-------------------------------------------------------------------------

		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1
		move.w	68(sp),d0
		bne.s	save_cp3

;...............................................OPEN CP3..............
		move.w	#2,(a1)+	; high resol
		move.l	#$fff0000,(a1)+	; 2 colors
		lea.l	28(a1),a1
		lea.l	32000(a1),a6	; end destination

		move.w	(a0),d1		  
		lsl.w	#2,d1		; 
		lea.l	4(a0,d1.w),a2	; point to data image

		move.w	(a0)+,d1	; number of word cmd
		addq.l	#2,a0		; point to cmd

;.......................................

loop1:		move.w	(a0)+,d2
		beq.s	copy_lw		

literally:	move.l	(a2)+,(a1)+
		move.l	(a2)+,(a1)+
		subq.w	#1,d2		; .w obliged !
		bgt.s	literally	 

copy_lw:	move.w	(a0)+,d2
		move.l	(a2)+,d3
		move.l	(a2)+,d4	

recopy:		move.l	d3,(a1)+
		move.l	d4,(a1)+
		subq.w	#1,d2
		bgt.s	recopy

		subq.w	#1,d1		
		bgt.s	loop1		; >0

loop4:		cmp.l	a6,a1
		bpl.s	end_prg		; >=0
		move.l	(a2)+,(a1)+
		move.l	(a2)+,(a1)+
		bra.s	loop4

;...............................................SAVE CP3..............
;a1 a6		source
;a0 a2 a3 a4    destination
save_cp3:
		lea.l	34(a1),a1	; skip resol and color palette	
  		lea.l	32000(a1),a6	; end_source    

 		movea.l	a0,a2		; for calculate file size
 		lea.l	8008(a0),a3	; tempory place for long words
 		movea.l	 a3,a4		; 
		addq.l	#4,a0		; second word of Picworks is unused
		moveq.l	#0,d4    

loops1:		move.l	(a1)+,d5      
          	move.l	(a1)+,d6     
          	moveq.l	#1,d7		; reset cpt
                                   
cmp_lw: 	cmp.l	a6,a1		; end_source ? a0<a6
          	bpl.s	not_equal   	; if n=0
          	cmp.l	(a1),d5       
          	bne.s	not_equal      
          	cmp.l	4(a1),d6 
          	bne.s	not_equal     
  
		addq.l	#8,a1
          	addq.l	#1,d7         
		bra.s	cmp_lw

not_equal:	cmpi.w	#1,d7
          	bls.s	zero_equal	; if  <=1  

          	move.w	d4,(a0)+       
          	move.w	d7,(a0)+       
          	addq.w	#1,(a2)		; count L.W ( *4+4=address LW )          
          	moveq.l	#0,d4          
          	bra.s	next          

zero_equal:	addq.w	#1,d4         
next:          	move.l	d5,(A3)+      
          	move.l	d6,(A3)+      

          	cmp.l	a6,a1		; end source ?
          	bmi.s	loops1		; if n=-1         


replace:  	move.l	(a4)+,(a0)+	; replace long words
          	cmp.l	a4,a3
          	bne.s	replace	

          	suba.l	a2,a0		; calculate file size
          	move.l	a0,d0             

;.................................................................
	
end_prg:	movem.l (sp)+,d1-d7/a0-a6
		rts

		end

;-------------------------------------------------------------------------



