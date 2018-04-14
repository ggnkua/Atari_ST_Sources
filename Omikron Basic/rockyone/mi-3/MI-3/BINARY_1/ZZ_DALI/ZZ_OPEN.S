; rockyone			pour M1-3 et MI-9		26/05/2017
;
;
;
;SD0-2	: +4 	palette,  +128 data image uncompresed
;
;?PK	: +0 	palette, number cmd, size data image, cmd, data image
;
;RGH	: +0	header, number cmd, palette, cmd, data image
;
;
;There are not bytes of resolution in these formats.
;
;			|------------|-----|-----|-----|
;			| Resolution |  0  |  1  |  2  |
;			|------------|-----|-----|-----| 
;		  	| DALI	     | SD0 | SD1 | SD2 |
;			|	     | LPK | MPK | HPK |
;			|------------|-----|-----|-----|     
;			| ZZ-ROUGHT  | RGH |     |     |
;			|------------|-----|-----|-----|
:
; Source 	buffer image
;			    
; Destination	buffer of 32034 bytes
;
;
; Rez%         	Image resolution - only for open -
;
; Apl%	 	2 	dali unpakted	SD0,DD1,SD2
;		0 	dali pakted 	LPK,MPK,HPK
;		1 	zz_rought	RGH
;						    d5      d6
; Basic 	Zz_open( L Source, L Destination, W Rez%, W Apl%)
;		-------------------------------------------------------
;			
; Return in low d0	-1 error resolution
;			-2 error header RGH
;-------------------------------------------------------------------------
;a0 source
;a1 destination
;d5 image resolution
;d6 apl%
;--------	
	movem.l	d1-d7/a0-a6,-(sp)
	movem.l	60(sp),a0-a1		
	movem.w	68(sp),d5-d6	
;.......................................test resolution............
	moveq.l	#-1,d0	
	tst.b	d5		; pic low resolusion
	bne.s	ok_resol
	cmpi.b  #2,$44c		; screen resolution
	beq	error		; 

ok_resol:			
;.................................................................

	move.w	d5,(a1)+		; write resol 

	cmpi.b	#2,d6			; Dali not packed ?
	beq	dali_normal		; yes

	tst.b	d6			; Dali packed ?
	beq.s	go_pal			; yes

;........................................Header RGH......
	lea.l	rgh(pc),a3
	moveq.l	#2,d1
	move.w	#-2,d0			;R. -2 for error in header RGH

test_rgh:
	move.l	(a3)+,d2		; "(c)F.MARCHAL"
	cmp.l	(a0)+,d2
	bne.s	error			
	dbra.w	d1,test_rgh

	bsr.s	number			; Return in d3  
	move.l	d3,d4			; the number of byte of repeat
;					; for Zz_rought
;.......................................
go_pal:	bsr.s	copy_pal

	cmpi.b	#1,d6			; Zz_Rought ?
	beq.s	depack

;........................................ Only Dali..........
	bsr.s	number			; Return in d3 
	move.l	d3,d4			; the number of byte of repeat
	bsr.s	number			; Return in d3 size long word

;.........................................Depack image............
;a0 	byte 	  :  cmd
;a2	long word :  data image
;
;a1 a3  destination
;d1     byte repeat
;d2	colum
;d3	line
;d4	number of byte of cmd


depack:	lea.l	0(a0,d4.w),a2		; Address long_word ( -4 )
	subq.w	#4,a2
	moveq.l	#1,d1
	moveq.l	#39,d2			; 40 colonne

column:	move.w	#199,d3			; 200 ligne
	move.l	a1,a3			; high screen

Line:	subq.b	#1,d1	
	bne.s	recopy
	addq.w	#4,a2			; point to data
	move.b	(a0)+,d1		; read byte of repeat

recopy:	move.b	0(a2),(a3)+
	move.b	1(a2),(a3)+
	move.b	2(a2),(a3)+
	move.b	3(a2),(a3)+
	lea.l	160-4(a3),a3		; next line

	dbra.w	d3,line

	addq.w	#4,a1			; next column
	dbra.w	d2,column
;.......................................

end_prg:	moveq.l	#0,d0
error:		movem.l	(sp)+,d1-d7/a0-a6
		rts
;----------------------------------------------------------------------

;.........................................Palette...............
copy_pal:	move.l	#31,d3		; 16 word of color
copy_color:	move.b	(a0)+,(a1)+	; Recopy palette 
		dbra.w	d3,copy_color	
		rts

;........................................Number ASCII in HEXA...
number:		moveq.l	#0,d3
		moveq.l	#0,d1

next_chiffre:	move.b	(a0)+,d1
		cmp.b	#13,d1
		beq.s	end_number
		andi.b	#$F,d1
		mulu.w	#$A,d3
		add.w	d1,d3
		bra.s	next_chiffre
end_number:	adda.w	#$1,a0
		rts

;........................................Dali non compress‚...
dali_normal:	addq.w	#4,a0		; address palette
		bsr.s	copy_pal

		move.w	#7999,d1	; 8000 long_word
		adda.w	#92,a0		; = Source+128

copy_pic:	move.l	(a0)+,(a1)+
		dbra.w	d1,copy_pic	
		bra.s	end_prg

;........................................Header RGH.........
rgh:	dc.b	'(c)F.MARCHAL'

	end
;-------------------------------------------------------------------------