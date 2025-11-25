file_load:	movem.l	d1-d7/a0-a6,-(sp)	;save all registers
;		MOVE.L	A0,FILENAMEADDR
		lea	$804000,a6
		move.w	(a6)+,d2		a6 points to table of offsets.l
		lsl.w	#2,d2			d2*2
		lea	4(a6,d2.w),a5		a5 points to the filenames
		moveq	#0,d6			d6 is file number
.loop		move.b	(a5),d7
		cmp.b	#-1,d7
		bne.s	.valid_char
		illegal				file not found
.valid_char	move.l	a0,a2			copy the filename accross
.a_loop		tst.b	(a5)			see if end of filename in rom
		bne.s	.cont			if not then continue
		tst.b	(a2)			  else then check end of filename in ram
		beq.s	.found			    if so then file name found
		bne.s	.not_found		      else its not this filename
.cont		cmp.b	(a2)+,(a5)+		compare characters
		beq.s	.a_loop			if same the carry on
.not_found	addq.w	#4,d6
.wait_till_zero	tst.b	(a5)+			find the next filename
		bne.s	.wait_till_zero
		bra.s	.loop			loop until file is found
.found		move.l	(a6,d6.w),a0
		add.l	a6,a0
		moveq	#0,d0
;		LEA	FILE_TO_BODGE,A3
;		MOVE.L	FILENAMEADDR,A4
;.LOOPZ		CMP.B	(A3)+,(A4)+
;		BNE.S	.NOT_FILENAME
;		TST.B	-1(A3)
;		BNE.S	.LOOPZ
;		ILLEGAL

;.NOT_FILENAME

		Cmp.l	#"RNC"<<8+1,(a0)
		Bne.s	.Not_Compressed		
		Move.l	4(a0),-(sp)
		Ifnd	ROB68K
		Movem.l	d0-a6,-(sp)
		move.l	#GPUPP_S,a0
		move.l	#GPUPP_E,d0
		Moveq	#0,d1
		Moveq	#0,d2
		St	Loading_Stuff
		Jsr	SETUPGPU
		Movem.l	(sp)+,d0-a6
		Moveq	#%11,d0	
		Moveq	#0,d0	
		Jsr	DECOMPRESSGPUPP1
		Jsr	WAITFORGPU
		Jsr	Stop_Gpu
		Else
		bsr.s	PP_UNPACK
		Endc
		Clr.b	Loading_Stuff+Data
		Addq.l	#8,(sp)
		And.l	#-8,(sp)
		movem.l	(sp)+,d0-d7/a0-a6	;restore registers
		rts
.Not_Compressed	Moveq	#0,d0	
		Move.l	a0,$20(sp)
		movem.l	(sp)+,d1-d7/a0-a6	;restore registers
		Rts

		Ifd	ROB68K
		include	rnc_1.s	
		Endc
;FILENAMEADDR
;		DC.L	0
;FILE_TO_BODGE	Dc.b	"SPRITES1.JHD",0
;		EVEN
		