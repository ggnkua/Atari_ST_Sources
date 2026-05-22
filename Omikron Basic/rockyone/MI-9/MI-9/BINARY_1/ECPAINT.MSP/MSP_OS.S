;ROCKYONE			POUR MI-9			  17/01/2017
;
;
;
;		   		ECPAINT! :  MST
;
; fichier sans palette de couleur
; Ecpaint ne charge pas de palette meme pour Degas  !  Bug ???
;
;.............................................
;
;		    	     OPEN	     SAVE
;		Source	:  file.msp	  format degas
;		But	:  32034 bytes	  32032  bytes
;		op%	:      0	      1
;
;		open	Msp_Os( L Source, L But, W Op%)
;		save	Msp_Os( L but, L source, W Op%)
;		........-------------------------------
;
; Return in Low d0   	0 not error
;			-2 header error
;			or file size
;
; header : 32 octets. description en fin de fichier
;	
;-------------------------------------------------------------------------- 

		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1

		lea.l	header(pc),a3
		moveq.l	#7,d1

		tst.w	68(sp)		; Open or save ?
		beq.s	open_msc

;.......................................SAVE PI3 to MSP....................	
;a1 source
;a0 but
;********
		exg.l	a0,a1


copy_header:	move.l	(a3)+,(a1)+
		dbra.w	d1,copy_header

		lea.l	34(a0),a0	; jump resol et palette source		lea.l	34(a1),a1	; jump resol et palette source
		move.l	#32032,d0	; R. file size
		bra.s	copy_data		

;.......................................OPEN MSP to PI3...................
;a0 source
;a1 but
;*********
open_msc:	moveq.l	#-2,d0			;R. error header
test_header:	cmpm.l	(a3)+,(a0)+
		bne.s	end_prg
		dbra.w	d1,test_header

		moveq.l	#0,d0			;R. not error	

		move.w	#2,(a1)+		; write resol
		move.l	#$FFF0000,(a1)		; write 2 colors
		lea.l	32(a1),a1		; Point to destination image

copy_data:	move.w	#15999,d1
data:		move.w	#$ffff,d2
		sub.w	(a0)+,d2
		move.w	d2,(a1)+
		dbra.w	d1,data

;..........................................................


end_prg:	movem.l (sp)+,d1-d7/a0-a6
		rts
;....................
header:		even
		dc.l	$44616E4D		;'DanM'
		dc.l	$80029001       	; Largeur, hauteur
		dc.l	$01000100		; ?
		dc.l	$2c012c01 		; ?
		dc.l	$80022003		; ? copy largeur ?
		dc.l	$00000000		; ?
		dc.l	$9a2e873d		; ?
		dc.l	$e36c8536		; ?
		even

		end
;------------------------------------------------------------------------
