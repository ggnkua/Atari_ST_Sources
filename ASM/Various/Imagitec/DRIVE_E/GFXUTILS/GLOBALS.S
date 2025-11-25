Blitterstuff 	Equ $ff8a00
Halftone	Equ $000000
Src_Xinc	Equ $000020
Src_Yinc	Equ $000022
Src_Addr	Equ $000024
Endmask1	Equ $000028
Endmask2	Equ $00002a
Endmask3	Equ $00002c
Dst_Xinc	Equ $00002e
Dst_Yinc	Equ $000030
Dst_Addr	Equ $000032
X_Count		Equ $000036
Y_Count		Equ $000038
Hop		Equ $00003a
Op		Equ $00003b
Line_Num	Equ $00003c
Skew		Equ $00003d
Procswitch	Equ $ff8007
Pal256		Equ $ff9800
Scr_mod		Equ $ff820e
Scr_del		Equ $ff8264
Bp_Hi		Equ $ff8201
Bp_Md		Equ $ff8203
Bp_Lo		Equ $ff820c
Vd_Hi		Equ $ff8204
Vd_Md		Equ $ff8206
Vd_Lo		Equ $ff8208

Keycheck
;Return key in d0
	Move.w	#$ff,-(sp)
	Move.w	#6,-(sp)
	Trap	#1
	Addq.l	#4,sp
	Rts

Waitvb	
	Move.w	#37,-(sp)
	Trap	#14
	Addq.l	#2,sp
	Rts


Savepal
	Lea	Pal(pc),a0
	Lea	Pal256,a1
	Move.w	#$ff,d0
.Loop	Move.l	(a1),d2
	Move.l	d2,(a0)+
	Addq.l	#4,a1
	Dbra	d0,.Loop
	Rts	

Restorepal
	Lea	Pal(pc),a0
	Lea	$ff9800,a1
	Move.w	#$ff,d0
.Loop	Move.l	(a0)+,d2
	Move.l	d2,d2
	Move.l	d2,(a1)
	Addq.l	#4,a1
	Dbra	d0,.Loop
	Rts	

GSetup	clr.l   -(sp)
        move.w  #$20,-(sp)
        trap    #1                      set up supervisory mode
        addq.l  #6,sp

	move	#2,-(sp)
	trap	#14
	addq	#2,sp
;d0=Dest
        move.l  d0,scr1
        subi.l  #$2000*8,d0
        move.l  d0,scr2

        move.w  #-1,-(sp)                set resolution
        move.l  #-1,-(sp)
        move.l  #-1,-(sp)
        move.w  #5,-(sp)
        trap    #14
        add.l   #12,sp
	rts
Pal	Ds.l	256
;Scr1	Ds.l	1
;Scr2	Ds.l	1
