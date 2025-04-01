
                EXPORT  line
                EXPORT  set_line
                EXPORT  cntrcs
                EXPORT	w


line:           move    d0,d2
                lsr     #3,d0
                lea     0(a0,d0.w),a0
                andi.b  #7,d2
                move.b  #$80,d0
                lsr.b   d2,d0
nx:             or.b    d0,(a0)
patch:          lea     -1(a0),a0
                dbf     d1,nx
                rts
                
set_line:       move    d0,2+patch
                rts



cntrcs:         movem.l d0/a0,_cntrcspar
                pea     _cntrcs
                move    #38,-(a7)
                trap    #14
                addq.l  #6,a7
                rts

_cntrcspar:     ds.l    2

_cntrcs:        ori     #$700,sr
                movem.l _cntrcspar,d0/a0
                movea.l #$ff8800,a1
                move.b  #7,(a1)
                move.b  (a1),d1
                andi.b  #$7f,d1
                move.b  d1,2(a1)
_cntrcs_lp:     move.b  #$e,(a1)        ; strobe high
                move.b  (a1),d1
                ori.b   #$20,d1
                move.b  d1,2(a1)
                move.b  #$f,(a1)
                move.b  (a1),d1
                lsr.b   #2,d1
                sub.b   #32,d1
                ext     d1
                move    d1,(a0)+
                clr     (a0)+
                move.b  #$e,(a1)        ; strobe low
                move.b  (a1),d1
                andi.b  #$df,d1
                move.b  d1,2(a1)
                dbf     d0,_cntrcs_lp
                andi    #$fbff,sr
                rts



; Wurzeln der komplexen Einheit fÅr N=256, vorberechnet als
; Fixkomma-Shortinteger mit 4 Bit Fixkommastelle

				DATA
				
w:	dc.b	$00,$10,$00,$00,$00,$10,$00,$00,$00,$10,$00,$01,$00,$10,$00,$01
	dc.b	$00,$10,$00,$02,$00,$10,$00,$02,$00,$10,$00,$02,$00,$10,$00,$03
	dc.b	$00,$10,$00,$03,$00,$10,$00,$04,$00,$10,$00,$04,$00,$0f,$00,$04
	dc.b	$00,$0f,$00,$05,$00,$0f,$00,$05,$00,$0f,$00,$05,$00,$0f,$00,$06
	dc.b	$00,$0f,$00,$06,$00,$0f,$00,$06,$00,$0e,$00,$07,$00,$0e,$00,$07
	dc.b	$00,$0e,$00,$08,$00,$0e,$00,$08,$00,$0e,$00,$08,$00,$0e,$00,$09
	dc.b	$00,$0d,$00,$09,$00,$0d,$00,$09,$00,$0d,$00,$0a,$00,$0d,$00,$0a
	dc.b	$00,$0c,$00,$0a,$00,$0c,$00,$0a,$00,$0c,$00,$0b,$00,$0c,$00,$0b
	dc.b	$00,$0b,$00,$0b,$00,$0b,$00,$0c,$00,$0b,$00,$0c,$00,$0a,$00,$0c
	dc.b	$00,$0a,$00,$0c,$00,$0a,$00,$0d,$00,$0a,$00,$0d,$00,$09,$00,$0d
	dc.b	$00,$09,$00,$0d,$00,$09,$00,$0e,$00,$08,$00,$0e,$00,$08,$00,$0e
	dc.b	$00,$08,$00,$0e,$00,$07,$00,$0e,$00,$07,$00,$0e,$00,$06,$00,$0f
	dc.b	$00,$06,$00,$0f,$00,$06,$00,$0f,$00,$05,$00,$0f,$00,$05,$00,$0f
	dc.b	$00,$05,$00,$0f,$00,$04,$00,$0f,$00,$04,$00,$10,$00,$04,$00,$10
	dc.b	$00,$03,$00,$10,$00,$03,$00,$10,$00,$02,$00,$10,$00,$02,$00,$10
	dc.b	$00,$02,$00,$10,$00,$01,$00,$10,$00,$01,$00,$10,$00,$00,$00,$10
	dc.b	$00,$00,$00,$10,$00,$00,$00,$10,$ff,$ff,$00,$10,$ff,$ff,$00,$10
	dc.b	$ff,$fe,$00,$10,$ff,$fe,$00,$10,$ff,$fe,$00,$10,$ff,$fd,$00,$10
	dc.b	$ff,$fd,$00,$10,$ff,$fc,$00,$10,$ff,$fc,$00,$10,$ff,$fc,$00,$0f
	dc.b	$ff,$fb,$00,$0f,$ff,$fb,$00,$0f,$ff,$fb,$00,$0f,$ff,$fa,$00,$0f
	dc.b	$ff,$fa,$00,$0f,$ff,$fa,$00,$0f,$ff,$f9,$00,$0e,$ff,$f9,$00,$0e
	dc.b	$ff,$f8,$00,$0e,$ff,$f8,$00,$0e,$ff,$f8,$00,$0e,$ff,$f7,$00,$0e
	dc.b	$ff,$f7,$00,$0d,$ff,$f7,$00,$0d,$ff,$f6,$00,$0d,$ff,$f6,$00,$0d
	dc.b	$ff,$f6,$00,$0c,$ff,$f6,$00,$0c,$ff,$f5,$00,$0c,$ff,$f5,$00,$0c
	dc.b	$ff,$f5,$00,$0b,$ff,$f4,$00,$0b,$ff,$f4,$00,$0b,$ff,$f4,$00,$0a
	dc.b	$ff,$f4,$00,$0a,$ff,$f3,$00,$0a,$ff,$f3,$00,$0a,$ff,$f3,$00,$09
	dc.b	$ff,$f3,$00,$09,$ff,$f2,$00,$09,$ff,$f2,$00,$08,$ff,$f2,$00,$08
	dc.b	$ff,$f2,$00,$08,$ff,$f2,$00,$07,$ff,$f2,$00,$07,$ff,$f1,$00,$06
	dc.b	$ff,$f1,$00,$06,$ff,$f1,$00,$06,$ff,$f1,$00,$05,$ff,$f1,$00,$05
	dc.b	$ff,$f1,$00,$05,$ff,$f1,$00,$04,$ff,$f0,$00,$04,$ff,$f0,$00,$04
	dc.b	$ff,$f0,$00,$03,$ff,$f0,$00,$03,$ff,$f0,$00,$02,$ff,$f0,$00,$02
	dc.b	$ff,$f0,$00,$02,$ff,$f0,$00,$01,$ff,$f0,$00,$01,$ff,$f0,$00,$00


