;----------------------------------------------------------------------------------------
;	aes_call.s, part of TOS Linker for CodeWarrior
;
;	Low level AES system calls for TOS
;	Pure Asm version
;
;	16.11.1998 by Manfred Lippert
;	based on MT_AES from Andreas Kromke
;
;	last change: 18.11.1998
;
;	Don't edit this file.
;
;	If you have to make any changes on this file, please contact:
;	mani@mani.de
;----------------------------------------------------------------------------------------

.export _mt_aes

sizeof_AESPB = 24

;PARMDATA:
APD_contrl		= 0		; int16 contrl[5];
APD_intin		= 10	; int16 intin[16];
APD_intout		= 42	; int16 intout[16];
APD_addrin		= 74	; void *addrin[16];
APD_addrout		= 138	; void *addrout[16];
sizeof_PARMDATA = 202

; A0:		PARMDATA *d
; A1:		int16 *ctrldata
; 4(sp):	int16 *global

.MODULE _mt_aes
	move.l	a2,-(sp)
	lea		-sizeof_AESPB(sp),sp		; space for AESPB
	movea.l	sp,a2
	move.l	a0,(a2)+					; set AESPB:contrl pointer to PARMDATA:contrl field

	move.l	(a1)+,(a0)+					; fill out PARMDATA:contrl[0/1]
	move.l	(a1)+,(a0)+					; fill out PARMDATA:contrl[2/3]
	clr.w	(a0)+						; fill out PARMDATA:contrl[4]

	move.l	sizeof_AESPB+8(sp),(a2)+	; set AESPB:global pointer to global
	move.l	a0,(a2)+					; set AESPB:intin pointer to PARMDATA:intin field
	lea		APD_intout-APD_intin(a0),a0	; intout field
	move.l	a0,(a2)+					; set AESPB:intout pointer to PARMDATA:intout field
	lea		APD_addrin-APD_intout(a0),a0
	move.l	a0,(a2)+					; etc...
	lea		APD_addrout-APD_addrin(a0),a0
	move.l	a0,(a2)+

	move.w	#200,d0
	move.l	sp,d1
	trap	#2

	lea		sizeof_AESPB(sp),sp
	movea.l	(sp)+,a2
	rts
