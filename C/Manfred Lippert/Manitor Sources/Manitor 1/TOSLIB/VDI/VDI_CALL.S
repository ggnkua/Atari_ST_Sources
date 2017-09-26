;----------------------------------------------------------------------------------------
;	vdicall.s, part of TOS Linker for CodeWarrior
;
;	Low level VDI system calls for TOS
;	Pure Asm version
;
;	17.11.1998 by Manfred Lippert
;
;	last change: 18.11.1998
;
;	Don't edit this file.
;
;	If you have to make any changes on this file, please contact:
;	mani@mani.de
;----------------------------------------------------------------------------------------

.export mt_vdi
.export vq_gdos

; A0: XVDIPB *pb
; A1: VDICONIN *conin
.MODULE mt_vdi
	pea (a2)
	move.l (a0),a2			; pb->contrl in A2
	move.l (a1)+,(a2)		; opcode/ptsin_count kopieren
	move.w (a1)+,6(a2)		; intin_count kopieren
	move.w (a1),10(a2)		; subcode kopieren
	moveq.l #0x73,d0
	move.l a0,d1			; VDIPB*
	trap #2
	move.l (sp)+,a2
	rts

.MODULE vq_gdos
	pea (a2)
	moveq.l #-2,d0
	trap #2
	addq.w #2,d0
	move.l (sp)+,a2
	rts
