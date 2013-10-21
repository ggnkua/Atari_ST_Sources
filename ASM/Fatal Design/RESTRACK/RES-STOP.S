***********************************************************************
***********										***********
***********										***********
***********	Stop Resident DSP Replay and free memory	***********
***********										***********
***********										***********
***********		  By Simplet / FATAL DESIGN			***********
***********										***********
***********************************************************************

			OutPut	RES-STOP.TOS
			OPT		O+,OW-

***********************************************************************
***********				Inits TOS					***********
***********************************************************************

		Section	TEXT

; Swap into Supervisor Mode
		clr.l	-(sp)
		move.w	#$20,-(sp)			; SUPER
		trap		#1					; Gemdos
		addq.l 	#6,sp

; Get the player's structure
		movea.l	$74.w,a6
		cmp.l	#'MGTK',(a6)
		bne.s	Error

		jsr		([a6,12.w])			; Stop Replay
		jsr		([a6,16.w])			; Restore Sound

		move.l	8(a6),-(sp)			; Bloc Address
		move.w	#$49,-(sp)			; Mfree
		bsr		BP_Bidouille
		trap		#1					; Gemdos
		bsr		BP_Bidouille
		addq.l	#6,sp

; No Module currently played
		clr.l	$74.w

		clr.w 	-(sp)				; PTerm
		trap 	#1					; Gemdos

***********************************************************************
***********			 If there is no replay			***********
***********************************************************************

Error	pea.l	Error_No_Replay(pc)
		move.w	#9,-(sp)				; Cconws
		trap		#1					; GemDos
		addq.l	#6,sp

		move.w	#7,-(sp)				; Crawin
		trap		#1					; Gemdos
		addq.l	#2,sp

		clr.w 	-(sp)				; PTerm
		trap 	#1					; Gemdos

***********************************************************************
***********				Sub-Routines				***********
***********************************************************************

; Routine venant de ntk4_pub par Megar/Binaris
;****************************************************
; Bidouille de la basepage pour que le m‚chant
; Gemdos ne nous confisque pas notre bloc
; DŠs qu'on a le (MS)dos tourn‚ ...
;****************************************************
BP_Bidouille
	movem.l	d0-d1/a0-a2,-(sp)
	lea.l	S_run(pc),a0
;en a0: zone de sauvegarde de 132 octets.
	lea	$51e.w,a1		;adresse new basepage
	move.l	a1,a2
	move.w	#$2700,sr		;pas b“ mais indispensable
	moveq	#32-1,d0
.loop:	move.l	(a0),d1		;echange ...
	move.l	(a1),(a0)+
	move.l	d1,(a1)+
	dbf	d0,.loop
	move.l	$4f2.w,a1
	move.l	40(a1),a1		;a1=_run
	cmp.l	(a1),a2		;basepage = zone de sauvegarde ?
	beq.s	.same
	move.l	(a1),(a0)+	;sauve vraie basepage
	move.l	a2,(a1)		;fause basepage install‚e
.end:	movem.l	(sp)+,d0-d1/a0-a2
	rts
.same:	move.l	(a0)+,(a1)	;remet vraie basepage
	move.w	#$2300,sr		;r‚autorise BIOS
	movem.l	(sp)+,d0-d1/a0-a2
	rts

		Section	DATA

Error_No_Replay
		dc.b		27,'E'
		dc.b		"Resident Amiga DSP-Replay Routine by Simplet / FATAL DESIGN",13,10
		dc.b		"-----------------------------------------------------------",13,10,10
		dc.b		7
		dc.b		"Error, there is currently no replay...",13,10
		dc.b		"Press any key...",13,10,0

		Section	BSS

S_run	ds.b		134
