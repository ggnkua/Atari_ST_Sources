;	MACROs pour la video	du Falcon 030
;	ecris par G.Audoly
;	je ne prends aucunement la responsabilite de degats pouvant etres
;	causes par ces MACROs

Setres0:	MACRO
	Vsetmode	#-1
	move.w	d0,res
	VgetRGB	#0,#10000,#mem_pal
	VgetRGB	#0,d0,#mem_pal
	Setscreen	\1,\2,#3,\3
	ENDM

Setres:	MACRO
	Vsetmode	#-1
	move.w	d0,res
	VgetRGB	#0,#10000,#mem_pal
	VgetRGB	#0,d0,#mem_pal
	;Vsetmode	#%110001000		;petite res pour ne pas avoir de pb
	Setscreen	\1,\2,#-1,#-1
	Vsetmode	\3
	ENDM
	
Resress:	MACRO
	Vgetsize	res
	move.l	$436.w,d1
	sub.l	d0,d1
	sub.l	#256,d1
	and.b	#-8,d1
	Setscreen	d1,d1,#3,res
	Vsetmode	res
	ENDM
Resresc:	MACRO
	VgetRGB	#0,#10000,#mem_pal
	VsetRGB	#0,d0,#mem_pal
	ENDM
	
Resres0:	MACRO
	Resress
	Resresc
	ENDM

Resres:	MACRO
	Resress
	Vsetmode	res
	Resresc
	ENDM
	
Setres2:	MACRO
	move.l	$ffff8288.w,videl0
	Phybase
	move.l	d0,phybase
	Logbase
	move.l	d0,logbase
	Vsetmode	#-1
	move.w	d0,res
	VgetRGB	#0,#10000,#mem_pal
	VgetRGB	#0,d0,#mem_pal
	move.w	res,d0
	and.w	\4,d0
	or.w	\3,d0
	;Setscreen	\1,\2,#3,d0
	Vsetmode	#%110001000		;petite res pour ne pas avoir de pb
	Setscreen	\1,\2,#-1,#-1
	move.w	res,d0
	and.w	\4,d0
	or.w	\3,d0
	Vsetmode	d0
	ENDM


Resres2:	MACRO
	;Setscreen	logbase,phybase,#3,res
	Setscreen	logbase,phybase,#-1,#-1
	Vsetmode	res
	Vsetmode	res
	move.l	videl0,$ffff8288.w
	Resresc
	ENDM

	

Phybase:	MACRO
	move.w	#2,-(sp)
	trap	#14
	addq.w	#2,sp
	ENDM


Logbase:	MACRO
	move.w	#3,-(sp)
	trap	#14
	addq.w	#2,sp
	ENDM


Getrez:	MACRO
	move.w	#4,-(sp)
	trap	#14
	addq.w	#2,sp
	ENDM


Setscreen:	MACRO		;#log, #phy, #res, #mode
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea.l	14(sp),sp
	ENDM

Vsetmode:	MACRO		;#mode
	move.w	\1,-(sp)
	move.w	#$58,-(sp)
	trap	#14
	addq.w	#4,sp
	ENDM

Mon_type:	MACRO
	move.w	#$59,-(sp)
	trap	#14
	addq.w	#2,sp
	ENDM
	
Vgetsize:	MACRO		;#mode
	move.w	\1,-(sp)
	move.w	#$5b,-(sp)
	trap	#14
	addq.w	#4,sp
	ENDM	

VsetSync:	MACRO
	move.w	\1,-(sp)
	move.w	#$5a,-(sp)
	trap	#14
	addq.w	#4,sp
	ENDM
	
VsetRGB:	MACRO		;#index.W, #count.W, #L*array.L
	move.l	\3,-(sp)
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#$5d,-(sp)	
	trap	#14
	lea.l	10(sp),sp
	ENDM

VgetRGB:	MACRO		;#index.W, #count.W, #L*array.L
	move.l	\3,-(sp)
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#$5e,-(sp)
	trap	#14
	lea.l	10(sp),sp
	ENDM

	