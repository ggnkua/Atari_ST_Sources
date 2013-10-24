;DSP MOD replay routine written by bITmASTER of BSW
;This is source code for Devpack 3
;Additional code by Dusan

                opt D+


iera            equ $fffffa07           ;Interrupt-Enable-Register A
ierb            equ $fffffa09           ;                                                               B
imra            equ $fffffa13
isra            equ $fffffa0f
isrb            equ $fffffa11
tacr            equ $fffffa19
tbcr            equ $fffffa1b
tadr            equ $fffffa1f
tbdr            equ $fffffa21
tccr            equ $fffffa1d
tcdr            equ $fffffa23
aer             equ $fffffa03
STColor         equ $ffff8240
FColor          equ $ffff9800
vbl             equ $70
timer_int       equ $0120
timer_c_int     equ $0114

ym_select       equ $ffff8800
ym_write        equ $ffff8802
ym_read         equ $ffff8800

vbaselow        equ $ffff820d
vbasemid        equ $ffff8203
vbasehigh       equ $ffff8201
vcountlow       equ $ffff8209
vcountmid       equ $ffff8207
vcounthigh      equ $ffff8205
linewid         equ $ffff820f
hscroll         equ $ffff8265

keyctl          equ $fffffc00
keybd           equ $fffffc02

DspHost         equ $ffffa200
HostIntVec      equ $03fc

PCookies        equ $05a0

hop             equ $ffff8a3a
op              equ $ffff8a3b
line_nr         equ $ffff8a3c
mode            equ $ffff8a3c
skew            equ $ffff8a3d
endmask1        equ $ffff8a28
endmask2        equ $ffff8a2a
endmask3        equ $ffff8a2c
x_count         equ $ffff8a36
y_count         equ $ffff8a38
dest_x_inc      equ $ffff8a2e
dest_y_inc      equ $ffff8a30
dest_adr        equ $ffff8a32
src_x_inc       equ $ffff8a20
src_y_inc       equ $ffff8a22
src_adr         equ $ffff8a24

mpx_src         equ $ffff8930
mpx_dst         equ $ffff8932


		move.l	4(a7),a5
		move.l	a5,a6
		move.l	$c(a5),d0
		add.l	$14(a5),d0
		add.l	$1c(a5),d0
		addi.l	#500,d0
		move.l	d0,-(a7)
		move.l	a5,-(a7)
		clr.w	-(a7)
		move.w	#$4a,-(a7)		;memory shrink
		trap	#1
		add.l	#$c,a7


		move.l	#ime,a4
		pea	$81(a6)			;take name of MOD
		move.l	(a7)+,a3		;from stack
opet		cmp.b	#0,(a3)
		beq	izlaz
		move.b	(a3)+,(a4)+
		bra	opet
		
izlaz		CLR.W	-(A7)
		MOVE.L	#ime,-(A7)		;filename a0
		MOVE.W	#$3D,-(A7)
		TRAP	#1
		ADDQ.L	#%1000,A7

		MOVE.W	D0,D1
		move.l	#mod1,-(a7)		;addr of load
		MOVE.L	#512000,-(A7)		;lenght in a2
		MOVE.W	D1,-(A7)
		MOVE.W	#$3F,-(A7)
		TRAP	#1
		ADDA.L	#$C,A7

		move.w	d1,-(a7)  		;close file
		move.w	#$3e,-(a7)
		trap	#1
		add.l	#4,a7

		move.l	#mod_text,-(sp)
		move.w	#9,-(sp)
		trap	#1
		add.l	#6,sp

		move.l	#mod1,-(sp)
		move.w	#9,-(sp)
		trap	#1
		add.l	#6,sp

                lea     player,a0
                bsr     reloziere


                moveq   #1,d0
                lea     mod1,a0
                bsr     player+28       ;ein
                pea     init
                move.w  #$26,-(sp)
                trap    #14
                addq.l  #6,sp


                move.w  #1,-(sp)
                trap    #1
                addq.l  #2,sp

                pea     off
                move.w  #$26,-(sp)
                trap    #14
                addq.l  #6,sp
                bsr     player+28+4     ;aus

kraj            clr.w   -(sp)
                trap    #1


timer_b:        movem.l d0-a6,-(sp)
                bsr     player+28+8
                movem.l (sp)+,d0-a6
                bclr    #0,$fffffa0f.w
                rte


init:           lea     SaveArea,a0
                move.l  timer_int.w,(a0)+
                move.b  tbcr.w,(a0)+
                move.b  tbdr.w,(a0)+
                move.b  #246,tbdr.w
                move.b  #7,tbcr.w
                move.l  #timer_b,timer_int.w
                bset    #0,imra.w
                bset    #0,iera.w
                rts

off:            bclr    #0,iera.w
                bclr    #0,imra.w
                lea     SaveArea,a0
                move.l  (a0)+,timer_int.w
                move.b  (a0)+,tbcr.w
                move.b  (a0)+,tbdr.w
                rts

reloziere:      
                move.l  2(a0),d0        ;Relozieren
                add.l   6(a0),d0
                add.l   14(a0),d0
                adda.l  #$1c,a0
                move.l  a0,d1
                movea.l a0,a1
                movea.l a1,a2
                adda.l  d0,a1
                move.l  (a1)+,d0
                adda.l  d0,a2
                add.l   d1,(a2)
                clr.l   d0
L000A:          move.b  (a1)+,d0
                beq     L000C
                cmp.b   #1,d0
                beq     L000B
                adda.l  d0,a2
                add.l   d1,(a2)
                bra     L000A
L000B:          adda.l  #$fe,a2
                bra     L000A
L000C:          rts
		section	data
player:         incbin 'e:\devpack\sources\DSP.BSW'
mod_text	dc.b	'   DSP MOD Player for Falcon',13,10
		dc.b	'Original Protracker 3.0 replay by ',13,10
		dc.b	'      bITmASTER of BSW',13,10
		dc.b	'   Additional coding by Dusan',13,10,13,10
		dc.b	'Now playing ',0
		section bss
		even
mod1		ds.b	512000			;only moduls up to 512K!!
SaveArea:       ds.b 6
ime		ds.l	16