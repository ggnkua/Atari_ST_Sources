;DSP MOD replay routine written by bITmASTER of BSW
;This is source code for Devpack 3
;Additional code by Dusan
;Modified by T.E.Haines to be called from C

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

	CSECT		code
	XDEF		@mod_init
	XDEF		@mod_play
	
@mod_init
		movem.l	d0-d7/a0-a6,-(sp)	
        lea     player,a0
        bsr     reloziere
        movem.l (sp)+,d0-d7/a0-a6
        rts

@mod_play
		movem.l	d0-d7/a0-a6,-(sp)	
* address of module in a0
        tst.b   d0
        beq     stop_mod
                moveq   #1,d0
                lea		player,a1
                jsr     (a1,28)       ;ein
                pea     init
                move.w  #$26,-(sp)
                trap    #14
                addq.l  #6,sp
return_playing  movem.l (sp)+,d0-d7/a0-a6
                rts

stop_mod        pea     off
                move.w  #$26,-(sp)
                trap    #14
                addq.l  #6,sp
                lea		player,a0
                jsr     (a0,28+4)     ;aus
return_stopped  movem.l (sp)+,d0-d7/a0-a6
				rts

timer_b:        movem.l d0-d7/a0-a6,-(sp)
                lea		player,a0
                jsr     (a0,28+8)
                movem.l (sp)+,d0-d7/a0-a6
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
		section	data,data
player    
      incbin 'DSP.BSW'
		even
SaveArea:       ds.b 6
	END