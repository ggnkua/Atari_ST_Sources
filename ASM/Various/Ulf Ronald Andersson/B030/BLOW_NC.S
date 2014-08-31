;----------------------------------------------------------------------------
;File name:	BLOW_NC.S			Revision date:	1999.01.22
;Created by:	Ulf Ronald Andersson		Creation date:	1997.03.14
;----------------------------------------------------------------------------
	output	.BS
;----------------------------------------------------------------------------
	include	RA_TOS.I
	include	bs_comp\TRACER.I
;----------------------------------------------------------------------------
trace_mode	set	0
;----------------------------------------------------------------------------
	TEXT
;----------------------------------------------------------------------------
code_beg:
	bra.s	main_code	;boot sector code link
;----------------------------------------------------------------------------
	ds.b	28		;boot sector parts reserved for BIOS use
;----------------------------------------------------------------------------
main_code:
	move.l	a0,-(sp)		;push entry a0
	lea	booter_regs(pc),a0	;a0 -> save area
	movem.l	d0-d7/a0-a6,(a0)	;save most entry regs (not a0/a7)
	move.l	(sp)+,8*4(a0)		;save a0
;
	pea	code_beg(pc)		;push -> boot sector start
;
	gemdos	Malloc,#128*1024	;temporarily allocate 128 KBytes
	move.l	d0,a3			;save the base address in a3
	gemdos	Mfree,(a3)		;release the area again
	add.l	#64*1024,a3		;a3 -> booter RAM buffer
	xbios	Setscreen,-1.w,-1.w,#0
	gemdos	Cconws,message_s(pc)
	gemdos	Crawcin
;
	lea	code_beg(pc),a2	;a2 -> booter code base
	lea	(a3),a1			;a1 -> booter RAM buffer
	move.w	#(booter_end-code_beg+3)/4-1,d0
.copy_loop:
	move.l	(a2)+,(a1)+		;copy booter code
	dbra	d0,.copy_loop
	jmp	booter_2-code_beg(a3)	;goto copy of booter_2
;----------------------------------------------------------------------------
;'booter_2' below is only executed after moving it
;----------------------------------------------------------------------------
booter_2:
	move.l	(sp)+,a4			;pull a4 -> boot sector base
;
;here sp is back at entry value -> boot retadr
;
	xbios	Floprd,(a4),#0,#0,#1,#0,#0,#1	;load bootsector data
	tst.l	d0				;boot sectorloadable ?
	bmi.s	boot_normally			;if not, go boot without it
	move	#(code_end-id_code)/2-1,d0	;d0 = dbra count for id test
	lea	id_code(pc),a0			;a0 -> id code of self
	lea	id_code-code_beg(a4),a1	;a1 -> id code of boot sector
id_loop:
	cmpm.w	(a0)+,(a1)+
	dbne	d0,id_loop
	beq.s	boot_normally			;if same disk, boot normally
	clr	d0
	lea	(a4),a1
	move	#$200/2-1,d1
checksum_loop:
	add	(a1)+,d0
	dbra	d1,checksum_loop
	cmp	#$1234,d0			;boot sector executable ?
	bne.s	boot_normally			;if not, go boot without it
boot_alien_sector:
	pea	(a4)				;push -> boot sector
	bra.s	complete_boot	
;----------------------------------------------------------------------------
booter_regs:
	ds.l	16
;----------------------------------------------------------------------------
boot_normally:
complete_boot:
	lea	_CPU_cid(pc),a0
	bsr.s	find_cookie
	bmi.s	done_CACR
	cmp.l	#30,d1
	bne.s	done_CACR
	move.l	#$0A0A,d0			;fix value for CACR
	movec.l	d0,CACR				;store d0 as cache control bits
done_CACR:
	movem.l	booter_regs(pc),d0-d7/a0-a6	;restore entry regs
	rts					;exit to TOS boot
;----------------------------------------------------------------------------
id_code:
	dc.l	'BLOW'
	dc.l	'_NC!'
_CPU_cid:
	dc.l	'_CPU'
message_s:
	dc.b	ESC,'E',CR,LF
	dc.b	'Ready to boot.',CR,LF
	dc.b	'To boot a disk, place it',CR,LF
	dc.b	'in A: and press any key.',CR,LF
	dc.b	NUL
	even
;----------------------------------------------------------------------------
	include	"bs_comp\FINDCOOK.S"
;----------------------------------------------------------------------------
	trace_CODE
;----------------------------------------------------------------------------
code_end:
code_size	=	code_end-code_beg
;----------------------------------------------------------------------------
sz_pad	MACRO	id,limit,pos
	IFNE	((\2)>(\3))
sz_pad__tmp	set	\2-\3
	dcb.b	sz_pad__tmp,0
;--Note--;	\1 was padded by \<sz_pad__tmp> bytes. OK!
	ELSE
	IFNE	((\3)>(\2))
sz_pad__tmp	set	\3-\2
	FAIL	\1 was too large by \<sz_pad__tmp> bytes.
	ENDC
	ENDC
	ENDM	;sz_pad
;----------------------------------------------------------------------------
	sz_pad	boot_sector,510,code_size
;
checksum:
	dc.w	0
;----------------------------------------------------------------------------
booter_end:
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	BLOW_NC.S
;----------------------------------------------------------------------------
