****************************************
* Fichier … inclure au d‚but d'un CPX  *
* Ce source n‚cessite la pr‚sence du   *
* label cpx_info donnant l'adresse des *
* diff‚rentes routines du CPX .        *
****************************************
* Plus de d‚tails dans :               *
*       - ST Mag nø54 p. 80            *
*       - ST Mag nø55 p. 68            *
*       - ST Mag nø57 p. 78            *
****************************************


cpx_init:
	move.l	4(sp),Xcpb
	move.l	#cpx_info,d0
	rts
Xcpb:
	dc.l	'Seb!'
	
Xcpb_call	macro
	move.l	Xcpb(pc),a0
	move.l	\1(a0),a0
	jsr	(a0)
	endm	

SkipRshFix	macro
	move.l	Xcpb(pc),a0
	move.w	6(a0),d0
	endm

Get_Head_Node	macro
	Xcpb_call	8
	endm

Save_Header	macro
	pea	\1
	Xcpb_call	12
	addq.l	#4,sp
	endm

rsh_fix	macro
	Xcpb_call	16
	endm

rsh_obfix	macro
	Xcpb_call	20
	endm

Popup	macro
	Xcpb_call	24
	endm

Sl_size	macro
	Xcpb_call	28
	endm

Sl_x	macro
	Xcpb_call	32
	endm

Sl_y	macro
	Xcpb_call	36
	endm

Sl_arrow	macro
	Xcpb_call	40
	endm

Sl_dragx	macro
	Xcpb_call	44
	endm

Sl_dragy	macro
	Xcpb_call	48
	endm

Xform_do	macro
	Xcpb_call	52
	endm

GetFirstRect	macro
	move.l	\1,-(sp)
	Xcpb_call	56
	addq.l	#4,sp
	endm

GetNextRect	macro
	Xcpb_call	60
	endm

Set_Evnt_Mask	macro
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	Xcpb_call	64
	lea	14(sp),sp
	endm

XGen_Alert	macro
	move.w	\1,-(sp)
	Xcpb_call	68
	addq.l	#2,sp
	endm
	
CPX_Save	macro
	move.l	\2,-(sp)
	pea	\1
	Xcpb_call	72
	addq.l	#8,sp
	endm
	
Get_Buffer	macro
	Xcpb_call	76
	endm
	
get_cookie	macro
	pea	\2
	move.l	\1,-(sp)
	Xcpb_call	80
	addq.l	#8,sp
	endm
	
MFsave	macro
	pea	\2
	move.w	\1,-(sp)
	Xcpb_call	84
	addq.l	#6,sp
	endm
