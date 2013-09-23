   ************************************
**** Bigborder-Demo fÅr Syntax-Terror ****
****       (C) by Chaos, Inc.         ****
**** 09.08.90 -> Version fÅr $1000    ****
   ************************************

diskversion EQU 0               ; 0=Platte, 1=Disk


                IFNE    diskversion
                ORG     $1000
		OUTPUT	"bigbord.img"
                ENDC

		IFEQ	diskversion
		pea	start(pc)
		move.w	#38,-(a7)
		trap	#14
		addq.l	#6,a7

		clr.w	-(a7)
		trap	#1
		ENDC

start:          
		lea	bssstart(pc),a0
		lea	bssende,a1
clrbss:		clr.l	(a0)+
		cmp.l	a1,a0
		blt.s	clrbss
		

		bsr     init

		clr.w	key
		
mainloop:	bsr     hbl_change           ;Reinfaden
                bsr     fill_raster          ;Raster einfÅllen
                bsr     draw_df              ;Delta Force LOGO zeichnen
                bsr     scroller             ;Laufschrift
                bsr     write                ;Big Border hinschreiben
                move.l  screen1,D0
                move.l  screen2,screen1
                move.l  D0,screen2
		bsr	vsync
		cmp.b	#$39,key
		bne.s	mainloop

endfuck:	bsr	hbl_off
		moveq	#0,d0
		bsr	music			; Musik abschalten
		
		IFNE	diskversion
		move.l	#$78000,d0
		ENDC
		IFEQ	diskversion
		move.l	oldscreen(pc),d0
		ENDC
		move.l	d0,a0
		lsr.l	#8,d0
		move.b	d0,$ffff8203.w
		lsr.w	#8,d0
		move.b	d0,$ffff8201.w
;		bsr	cls
		IFEQ	diskversion
		movem.l	oldpalette(pc),d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.b	#1,$ffff8260.w
		move.b	#0,$ffff820a.w
		rts
		ENDC
		MOVEQ	#0,d0
		jmp	$500.w
						


hbl_change:     subq.w  #1,fade_counter
                bpl.s   raus_hier

                move.w  #4,fade_counter

                movea.l hbl_pos,A0
                lea     hbl1(PC),A1
lp2:            move.w  (A0)+,D0
                cmp.w   #-1,D0
                beq.s   schluss
                move.w  D0,(A1)+
                bra.s   lp2

schluss:        movea.l hbl_pos,A0
                adda.w  richtung,A0
                cmpa.l  #ende,A0
                bgt     anders_rum
                cmpa.l  #anfang,A0
                blt     anders_rum
                bra     schultz_jetzt

anders_rum:     neg.w   richtung
                adda.w  richtung,A0

schultz_jetzt:  move.l  A0,hbl_pos
raus_hier:      rts

write:          movea.l screen2,A1
                lea     96*160+56+6(A1),A1
                lea     big_border(PC),A0
                moveq   #15,D7               ;Anzahl an Scanlines
lp:             move.w  (A0)+,(A1)
                move.w  (A0)+,8(A1)
                move.w  (A0)+,16(A1)
                move.w  (A0)+,24(A1)
                move.w  (A0)+,32(A1)
                move.w  (A0)+,40(A1)
                lea     160(A1),A1           ;Eine Zeile tiefer
                dbra    D7,lp
                rts

scroller:       movea.l screen1,A0
                movea.l screen2,A1
                lea     120*160+56+46(A0),A0
                lea     120*160+56+46(A1),A1

                addq.w  #1,flag              ;nÑchstes Zeichen
                cmpi.w  #4,flag              ;alle 4?
                blt     okay

                clr.w   flag
                bra     newchar

okay:           move.w  flag,D0
                mulu    #60*5,D0
                lea     chars_shiftet,A3
                adda.l  D0,A3

                movea.l scrollpos,A2
                moveq   #0,D0
                move.b  (A2),D0
                bra     gem1

newchar:        moveq   #0,D0                ;Flag ist Null
                addq.l  #1,scrollpos
                movea.l scrollpos,A3
                tst.b   (A3)
                bpl     okay

                move.l  #scrolltext-1,scrollpos
                bra.s   newchar

gem1:           move.w  D0,D1
                add.w   D0,D0                ;mal 2
                add.w   D0,D0                ;mal 4
                add.w   D1,D0                ;mal 5
                adda.w  D0,A3                ;Adresse des Zeichens

                moveq   #4,D7                ;5 Scanlines
scroll_loop:    moveq   #0,D0
                move.b  (A3)+,D0

                moveq   #5,D6                ;6 PlanestÅcke
loop3:          moveq   #0,D1
                move.w  (A0),D1              ;Plane holen
                lsl.l   #1,D1                ;1<-
                or.w    D0,D1
                move.w  D1,(A1)              ;wieder abspeichern
                subq.l  #8,A1                ;16 Pixel weiter links
                subq.l  #8,A0

                swap    D1                   ;rausgeschobener Rest holen
                move.w  D1,D0                ;und nach d0
                dbra    D6,loop3
                lea     208(A0),A0
                lea     208(A1),A1           ;Eine Zeile tiefer
                dbra    D7,scroll_loop       ;nÑchste Scanline
                rts


draw_df:        bsr     wabbel               ;DF wabbeln lassen
                lea     tab_scroll,A2        ;Tabelle, welche Zeile genommen wird
                lea     zeil_off,A3          ;Offset auf die Zeilenwerte
                movea.l screen2,A1
                lea     74*160+56+6(A1),A1

                moveq   #14,D7               ;Zeilen
zeile:          move.w  (A2)+,D0             ;Offset auf DF-Shiftet
                add.w   (A3)+,D0             ;Offset in den DF-Bildern
                lea     df_shiftet,A0
                adda.w  D0,A0

                move.w  (A0)+,(A1)
                move.w  (A0)+,8(A1)
                move.w  (A0)+,16(A1)
                move.w  (A0)+,24(A1)
                move.w  (A0)+,32(A1)
                move.w  (A0)+,40(A1)
                lea     160(A1),A1           ;Eine Zeile tiefer
                dbra    D7,zeile

                rts

;Sorgt dafÅr, daû das DF Logo wabbelt
wabbel:         subq.w  #1,wab_counter
                bne.s   raus1

                move.w  #2,wab_counter

;scrollt die Tabelle nach oben
                lea     tab_scroll,A4
                moveq   #13,D7               ;14 mal hochsetzen
setz:           move.w  2(A4),(A4)+
                dbra    D7,setz

                tst.w   pause_counter
                bmi     no_pause

                movea.l tab_ak,A1
                move.w  (A1),(A4)            ;alten Wert setzen
                subq.w  #1,pause_counter
                rts

no_pause:       movea.l tab_ak,A1            ;nÑchster Wert
                move.w  (A1)+,D0             ;holen
                bpl     ok_tab

		move.l	$466.w,d0
                move.b  $ffff8209.w,d0          ; Random!
                and.l   #$ffff,D0

                lea     tabelle(PC),A1
                divu    #anzahl+1,D0
                swap    D0
                tst.w   D0
                beq.s   pause

                subq.w  #1,D0                ;eins zurÅck
                lsl.w   #2,D0

                movea.l 0(A1,D0.w),A1
                move.w  (A1)+,D0             ;Neuen Wert setzen

ok_tab:         move.w  D0,(A4)
                move.l  A1,tab_ak            ;sichern
raus1:          rts

pause:          movea.l tab_ak,A0
                move.w  -(A0),(A4)
                move.l  A0,tab_ak

                move.w  #15,pause_counter
                rts

fill_raster:    lea     raster(PC),A0
                move.w  raster_pos,D0
                mulu    #48,D0               ;48 Bytes pro Scanline
                adda.l  D0,A0

                movea.l screen2,A1
                lea     73*160+56(A1),A1     ;Mitte des Screens

                moveq   #17,D7               ;Anzahl an Scanlines
fill_loop:      movem.l (A0)+,D0-D6/A2-A6
                movem.l D0-D6/A2-A6,(A1)
                movem.l D0-D6/A2-A6,2880(A1)
                movem.l D0-D6/A2-A6,5760(A1)
                lea     160(A1),A1
                dbra    D7,fill_loop

                cmpi.w  #1,wab_counter
                bne.s   no_wrap

                addq.w  #1,raster_pos
                cmpi.w  #18,raster_pos
                bne.s   no_wrap
                clr.w   raster_pos
no_wrap:        rts


init:           ; initialisiert alles

                move.l  #screenbuff,d0
                and.l   #-256,d0
                add.l   #256,d0
                move.l  d0,screen1
                add.l   #32000,d0
                move.l  d0,screen2

                IFEQ    diskversion
                clr.b   $ffff8260.w             ; Lowres
                move.b  #2,$ffff820a.w          ; 50Hz
                movem.l	$ffff8240.w,d0-d7
                movem.l	d0-d7,oldpalette
		move.w	#2,-(a7)
		trap	#14
		addq.l	#2,a7
		move.l	d0,oldscreen
                ENDC

                movem.l colors(PC),D0-D7
                movem.l D0-D7,vbl_palette

                move.w  #0,raster_pos        ;Position der Rasters

                lea     df(PC),A0            ;Original DF
                lea     df_shiftet,A1
                moveq   #14,D7               ;15 Scanlines
null_ran:       move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.w  (A0)+,(A1)+
                clr.w   (A1)+
                dbra    D7,null_ran

                lea     df_shiftet,A0
                lea     df_shiftet+180,A1    ;Ein DF tiefer
                move.w  #674,D7              ;16 mal schieben
                andi    #%1111,CCR           ;X lîschen
shift_loop:     move.l  (A0)+,D0             ;Wert holen
                roxr.l  #1,D0                ;einmal nach rechts
                move.l  D0,(A1)+
                dbra    D7,shift_loop

                lea     tab_scroll,A0
                moveq   #15,D7               ;16 EintrÑge der Tabelle
fill2:          move.w  #8*180,(A0)+
                dbra    D7,fill2

                lea     tabelle(PC),A0
loop1:          movea.l (A0)+,A1             ;Eintrag der Tabelle
                cmpa.l  #-1,A1
                beq.s   ende1

loop2:          move.w  (A1),D0
                bmi     loop1
                cmp.w   #180,D0
                bge     nichts
                mulu    #180,D0
nichts:         move.w  D0,(A1)+
                bra     loop2

ende1:          move.l  #tab1,tab_ak
                move.w  #3,wab_counter
                move.w  #-1,pause_counter

                bsr     wandel               ;Scrolltext in Eigencode wandeln

ende2:          lea     chars(PC),A0
                lea     chars_shiftet,A1
                lea     chars_shiftet+60*5,A2
                lea     chars_shiftet+120*5,A3
                lea     chars_shiftet+180*5,A4
                moveq   #29,D7               ;30 Zeichenpaare
char3:          moveq   #4,D6                ;5 Scanlines
char_expand:    move.b  (A0),D0              ;1. Zeichen holen
                lsr.b   #7,D0                ;Linke HÑlfte 1. Zeichen
                move.b  D0,(A1)+
                move.b  (A0),D0
                lsr.b   #6,D0
                and.b   #%1,D0
                move.b  D0,(A2)+
                move.b  (A0),D0
                lsr.b   #5,D0
                and.b   #%1,D0
                move.b  D0,(A3)+
                move.b  (A0),D0
                lsr.b   #4,D0
                and.b   #%1,D0
                move.b  D0,(A4)+

                lea     30(A0),A0            ;Eine Zeile tiefer
                dbra    D6,char_expand
                lea     -150(A0),A0          ;ZurÅck zur 1. Scanline

                moveq   #4,D6                ;5 Scanlines
char2:          move.b  (A0),D0              ;2. Zeichen holen
                lsr.b   #3,D0
                and.b   #%1,D0
                move.b  D0,(A1)+
                move.b  (A0),D0              ;2. Zeichen holen
                lsr.b   #2,D0
                and.b   #%1,D0
                move.b  D0,(A2)+
                move.b  (A0),D0              ;2. Zeichen holen
                lsr.b   #1,D0
                and.b   #%1,D0
                move.b  D0,(A3)+
                move.b  (A0),D0              ;2. Zeichen holen
                and.b   #%1,D0
                move.b  D0,(A4)+

                lea     30(A0),A0            ;eine Scanline tiefer
                dbra    D6,char2
                lea     -149(A0),A0          ;ZurÅck zur ersten Scanline, 3. Zeichen
                dbra    D7,char3

                move.l  #scrolltext-1,scrollpos
                move.w  #3,flag
                move.w  #1,wt

                move.l  #hbl_fade,hbl_pos
                move.w  #30,richtung
                move.w  #0,fade_counter

		move.l	screen1(pc),a0
		bsr	cls
		move.l	screen2(pc),a0
		bsr	cls

                moveq   #1,D0
                bsr     music

                bsr     hbl_on
                rts


wandel:         lea     scrolltext,A0

w_loop:         moveq   #0,D0
                move.b  (A0),D0              ;Zeichen holen
                cmp.b   #-1,D0               ;Ende?
                beq.s   ende4

                cmp.w   #'Å',D0
                beq     ueh
                cmp.w   #'ö',D0
                beq     ueh
                cmp.w   #'Ñ',D0
                beq     aeh
                cmp.w   #'é',D0
                beq     aeh
                cmp.w   #'î',D0
                beq     oeh
                cmp.w   #'ô',D0
                beq     oeh

                cmp.w   #'a',D0
                blt     unter_a
                cmp.w   #'z',D0
                bgt     Åber_z

;Liegt zwischen a..z

                sub.w   #'a'-'A'+' ',D0      ;in Groûbuchstaben
                bra.s   rein_damit

unter_a:        sub.w   #' ',D0
                bra.s   rein_damit

aeh:            move.w  #'&'-' ',D0
                bra     rein_damit
ueh:            move.w  #'#'-' ',D0
                bra     rein_damit
oeh:            move.w  #'$'-' ',D0
                bra     rein_damit

Åber_z:         moveq   #0,D0                ;Space

rein_damit:     move.b  D0,(A0)+
                bra     w_loop

ende4:          rts



vsync:          move.l  $0466.w,D0
wait_vbl:       cmp.l   $0466.w,D0
                beq     wait_vbl
                rts

cls:            move.w  #7999,d0
clsloop:        clr.l   (a0)+
                dbra    d0,clsloop
                rts


hbl_on: 	move	sr,-(a7)
		clr.w	hbl_col
		ori	#$0700,sr
		lea	hbl_buff(pc),a0
		move.l	$0118.w,(a0)+
		move.l	$0120.w,(a0)+
		move.l	$70.w,(a0)+
		move.b	$fffffa09.w,(a0)+   	; Werte retten
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa13.w,(a0)+
		move.b	$fffffa1b.w,(a0)+
		move.b	$fffffa11.w,(a0)+
		move.b	$fffffa21.w,(a0)+
		move.b	$fffffa17.w,(a0)+
		andi.b	#$df,$fffffa09.w    	; Timer C aus
		andi.b	#$fe,$fffffa07.w    	; Timer B aus
		move.l	#newkey,$0118.w
		move.l	#vbl,$70.w
		move.l	#hbl_routine,$0120.w
		ori.b	#1,$fffffa07.w	    	; Timer B an
		ori.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w	    	; automatic EOI
		move	(a7)+,sr
		rts

hbl_off:	move	sr,-(a7)
		ori	#$0700,sr
		lea	hbl_buff(pc),a0     	; Werte zurueck!
		move.l	(a0)+,$0118.w
		move.l	(a0)+,$0120.w
		move.l	(a0)+,$70.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa13.w
		move.b	(a0)+,$fffffa1b.w
		move.b	(a0)+,$fffffa11.w
		move.b	(a0)+,$fffffa21.w
		move.b	(a0)+,$fffffa17.w
		move	(a7)+,sr
		rts


; VBL-Routine:
vbl:            movem.l D0-A6,-(A7)          ; Register sichern

                clr.b   $fffffa1b.w
                move.b  #74,$fffffa21.w      ; Erster HBL in Zeile 100

                move.l  #hbl_routine,$0120.w ; HBL-Vektor setzen
                bclr    #0,$fffffa0f.w       ; HBL freigeben
                move.b  #8,$fffffa1b.w       ; Event-Count Mode

                addq.l  #1,$0466.w           ; VrClock erhîhen
                move.l  screen2(pc),D0       ; zu zeigender Bildschirm
                lsr.l   #8,D0                ; Screen 1 wird immer
                move.b  D0,$ffff8203.w       ; dargestellt!
                lsr.w   #8,D0
                move.b  D0,$ffff8201.w

                movem.l vbl_palette,D0-D7
                movem.l D0-D7,$ffff8240.w

                move.w  hbl_palette,hbl_col  ; Farbe vorbereiten
                move.l  #hbl_palette+2,hbl_pointer ; nachher hier weite

                bsr     music+8

                movem.l (A7)+,D0-A6
                rte

; Hbl routine
hbl_routine:    movem.l D0/A0,-(A7)

                move.w  hbl_col,D0
                lea     $ffff8250.w,A0       ; neue Farbe setzen
                swap    D0
                move.w  hbl_col,D0
                move.l  D0,(A0)+
                move.l  D0,(A0)+
                move.l  D0,(A0)+
                move.l  D0,(A0)

                move.w  #1,no_ok2+2

                movea.l hbl_pointer,A0       ; nÑchste Farbe vorbereiten
                move.w  (A0)+,D0
                bpl     okay22
                neg.w   D0
                move.w  D0,no_ok2+2
                move.w  (A0)+,D0

okay22:         move.w  D0,hbl_col
                move.l  A0,hbl_pointer       ; wieder abspeichern

                clr.b   $fffffa1b.w
no_ok2:         move.b  #1,$fffffa21.w       ; Alles 12 Pixel HBL

                bclr    #0,$fffffa0f.w       ; HBL freigeben
                move.b  #8,$fffffa1b.w       ; und starten

                movem.l (A7)+,D0/A0
                rte

newkey:		move.w	d0,-(A7)
		move.b	$fffffc00.w,d0
		btst	#7,d0
		beq.s	endkey
		move.b	$fffffc02.w,key
endkey:		move.w	(a7)+,d0
		bclr	#6,$fffffa11.w
		rte

                DATA

music:          INCBIN 'TERAMIS.IMG'

delta:          DC.W 130,80
                DC.W 131,90
                DC.W 132,100
                DC.W 133,110
                DC.W 134,120

zeil_off:       DC.W 0,12,24,36,48,60,72,84,96,108,120,132,144,156,168,180

tabelle:        DC.L tab1,tab2,tab3,tab4,tab5,tab6,tab7,tab8
                DC.L tab9
                DC.L -1

tab1:           DC.W 8,9,10,11,12,13,14,15,14,13,12,11,10,9,8,7,6,5,4,3
                DC.W 2,1,0,1,2,3,4,5,6,7,8,-1

tab2:           DC.W 8,9,10,11,12,13,12,11,10,9,8,-1

tab3:           DC.W 8,9,8,7,8,9,8,7,8,9,8,7,8,9,8,7,8,-1
tab4:           DC.W 8,9,10,10,11,11,11,12,12,12,12,11,11,11,10,10,9,8,-1
tab5:           DC.W 8,9,10,10,11,11,12,12,12,13,13,13,14,14,14,14
                DC.W 15,15,15,15,15,15
                DC.W 14,14,14,14,13,13,13,12,12,12,11,11,10,10,9,8
tab6:           DC.W 8,7,6,6,5,5,4,4,4,3,3,3,2,2,2,2
                DC.W 1,1,1,1,1
                DC.W 2,2,2,2,3,3,3,4,4,4,5,5,6,6,7,8,-1
tab7:           DC.W 8,9,10,11,12,13,14,15
                DCB.W 16,16
                DC.W 15,14,13,12,11,10,9,8,-1
tab8:           DC.W 8,16,8,16,8,16,8,16,8,16,8,16,8,16,8,16,8,16,8,16
                DC.W 8,16,8,16,8,16,8,16,8,16,8,16,8,-1
tab9:           DCB.W 16,16
                DC.W -1

anzahl          EQU 9

colors:         DC.W $00,$0666,$0111,$0222,$0333,$0444,$0555,$0724
                DC.W $57,$0766,$0655,$0544,$0433,$0322,$0211,$00

hbl_palette:    DC.W $0106,$0205,$0304,$0403,$0502,$0601,$0700
                DC.W $0710,$0720,$0730,$0740,$0750,$0760,$0770,$0770
                DC.W -8
hbl1:           DC.W $0777,$0557,$0447,$0337,$0227,$0117,$07
                DC.W -4
                DC.W $0777,$0757,$0747,$0737,$0727,$0717
                DC.W -9
                DC.W $0777,$0755,$0700,$0700,$0700,$0700,$0700,-200

hbl_fade:
anfang:         DC.W $0777,$0557,$0447,$0337,$0227,$0117,7
                DC.W -4
                DC.W $0777,$0757,$0747,$0737,$0727,$0717,-1

                DC.W $0666,$0556,$0446,$0336,$0226,$0116,$06
                DC.W -4
                DC.W $0666,$0656,$0646,$0636,$0626,$0616,-1

                DC.W $0555,$0555,$0445,$0335,$0225,$0115,$05
                DC.W -4
                DC.W $0555,$0555,$0545,$0535,$0525,$0515,-1

                DC.W $0444,$0444,$0444,$0334,$0224,$0114,$04
                DC.W -4
                DC.W $0444,$0444,$0444,$0434,$0424,$0414,-1

                DC.W $0333,$0333,$0333,$0333,$0223,$0113,$03
                DC.W -4
                DC.W $0333,$0333,$0333,$0333,$0323,$0313,-1

                DC.W $0222,$0222,$0222,$0222,$0222,$0112,$02
                DC.W -4
                DC.W $0222,$0222,$0222,$0222,$0222,$0212,-1

                DC.W $0111,$0111,$0111,$0111,$0111,$0111,1
                DC.W -4
                DC.W $0111,$0111,$0111,$0111,$0111,$0111,-1

                DC.W 0,0,0,0,0,0,0
ende:           DC.W -4
                DC.W 0,0,0,0,0,0,-1

raster:         DC.W $6619,$e1e1,$1ffe,$00,$9986,$f878,$07ff,$00
                DC.W $6661,$7e1e,$81ff,$00,$9998,$1f87,$e07f,$00
                DC.W $6666,$87e1,$f81f,$00,$1999,$e1f8,$fe07,$00
                DC.W $330c,$f0f0,$0fff,$00,$ccc3,$fc3c,$03ff,$00
                DC.W $3330,$3f0f,$c0ff,$00,$cccc,$0fc3,$f03f,$00
                DC.W $3333,$c3f0,$fc0f,$00,$0ccc,$f0fc,$ff03,$00
                DC.W $9986,$f878,$07ff,$00,$6661,$7e1e,$81ff,$00
                DC.W $9998,$1f87,$e07f,$00,$6666,$87e1,$f81f,$00
                DC.W $1999,$e1f8,$fe07,$00,$8666,$787e,$ff81,$00
                DC.W $ccc3,$fc3c,$03ff,$00,$3330,$3f0f,$c0ff,$00
                DC.W $cccc,$0fc3,$f03f,$00,$3333,$c3f0,$fc0f,$00
                DC.W $0ccc,$f0fc,$ff03,$00,$c333,$3c3f,$ffc0,$00
                DC.W $6661,$7e1e,$81ff,$00,$9998,$1f87,$e07f,$00
                DC.W $6666,$87e1,$f81f,$00,$1999,$e1f8,$fe07,$00
                DC.W $8666,$787e,$ff81,$00,$6199,$1e1f,$ffe0,$00
                DC.W $3330,$3f0f,$c0ff,$00,$cccc,$0fc3,$f03f,$00
                DC.W $3333,$c3f0,$fc0f,$00,$0ccc,$f0fc,$ff03,$00
                DC.W $c333,$3c3f,$ffc0,$00,$30cc,$0f0f,$fff0,$00
                DC.W $9998,$1f87,$e07f,$00,$6666,$87e1,$f81f,$00
                DC.W $1999,$e1f8,$fe07,$00,$8666,$787e,$ff81,$00
                DC.W $6199,$1e1f,$ffe0,$00,$9866,$8787,$7ff8,$00
                DC.W $cccc,$0fc3,$f03f,$00,$3333,$c3f0,$fc0f,$00
                DC.W $0ccc,$f0fc,$ff03,$00,$c333,$3c3f,$ffc0,$00
                DC.W $30cc,$0f0f,$fff0,$00,$cc33,$c3c3,$3ffc,$00
                DC.W $6666,$87e1,$f81f,$00,$1999,$e1f8,$fe07,$00
                DC.W $8666,$787e,$ff81,$00,$6199,$1e1f,$ffe0,$00
                DC.W $9866,$8787,$7ff8,$00,$6619,$e1e1,$1ffe,$00
                DC.W $3333,$c3f0,$fc0f,$00,$0ccc,$f0fc,$ff03,$00
                DC.W $c333,$3c3f,$ffc0,$00,$30cc,$0f0f,$fff0,$00
                DC.W $cc33,$c3c3,$3ffc,$00,$330c,$f0f0,$0fff,$00
                DC.W $1999,$e1f8,$fe07,$00,$8666,$787e,$ff81,$00
                DC.W $6199,$1e1f,$ffe0,$00,$9866,$8787,$7ff8,$00
                DC.W $6619,$e1e1,$1ffe,$00,$9986,$f878,$07ff,$00
                DC.W $0ccc,$f0fc,$ff03,$00,$c333,$3c3f,$ffc0,$00
                DC.W $30cc,$0f0f,$fff0,$00,$cc33,$c3c3,$3ffc,$00
                DC.W $330c,$f0f0,$0fff,$00,$ccc3,$fc3c,$03ff,$00
                DC.W $8666,$787e,$ff81,$00,$6199,$1e1f,$ffe0,$00
                DC.W $9866,$8787,$7ff8,$00,$6619,$e1e1,$1ffe,$00
                DC.W $9986,$f878,$07ff,$00,$6661,$7e1e,$81ff,$00
                DC.W $c333,$3c3f,$ffc0,$00,$30cc,$0f0f,$fff0,$00
                DC.W $cc33,$c3c3,$3ffc,$00,$330c,$f0f0,$0fff,$00
                DC.W $ccc3,$fc3c,$03ff,$00,$3330,$3f0f,$c0ff,$00
                DC.W $6199,$1e1f,$ffe0,$00,$9866,$8787,$7ff8,$00
                DC.W $6619,$e1e1,$1ffe,$00,$9986,$f878,$07ff,$00
                DC.W $6661,$7e1e,$81ff,$00,$9998,$1f87,$e07f,$00
                DC.W $30cc,$0f0f,$fff0,$00,$cc33,$c3c3,$3ffc,$00
                DC.W $330c,$f0f0,$0fff,$00,$ccc3,$fc3c,$03ff,$00
                DC.W $3330,$3f0f,$c0ff,$00,$cccc,$0fc3,$f03f,$00
                DC.W $9866,$8787,$7ff8,$00,$6619,$e1e1,$1ffe,$00
                DC.W $9986,$f878,$07ff,$00,$6661,$7e1e,$81ff,$00
                DC.W $9998,$1f87,$e07f,$00,$6666,$87e1,$f81f,$00
                DC.W $cc33,$c3c3,$3ffc,$00,$330c,$f0f0,$0fff,$00
                DC.W $ccc3,$fc3c,$03ff,$00,$3330,$3f0f,$c0ff,$00
                DC.W $cccc,$0fc3,$f03f,$00,$3333,$c3f0,$fc0f,$00
                DC.W $6619,$e1e1,$1ffe,$00,$9986,$f878,$07ff,$00
                DC.W $6661,$7e1e,$81ff,$00,$9998,$1f87,$e07f,$00
                DC.W $6666,$87e1,$f81f,$00,$1999,$e1f8,$fe07,$00
                DC.W $330c,$f0f0,$0fff,$00,$ccc3,$fc3c,$03ff,$00
                DC.W $3330,$3f0f,$c0ff,$00,$cccc,$0fc3,$f03f,$00
                DC.W $3333,$c3f0,$fc0f,$00,$0ccc,$f0fc,$ff03,$00
                DC.W $9986,$f878,$07ff,$00,$6661,$7e1e,$81ff,$00
                DC.W $9998,$1f87,$e07f,$00,$6666,$87e1,$f81f,$00
                DC.W $1999,$e1f8,$fe07,$00,$8666,$787e,$ff81,$00
                DC.W $ccc3,$fc3c,$03ff,$00,$3330,$3f0f,$c0ff,$00
                DC.W $cccc,$0fc3,$f03f,$00,$3333,$c3f0,$fc0f,$00
                DC.W $0ccc,$f0fc,$ff03,$00,$c333,$3c3f,$ffc0,$00
                DC.W $6661,$7e1e,$81ff,$00,$9998,$1f87,$e07f,$00
                DC.W $6666,$87e1,$f81f,$00,$1999,$e1f8,$fe07,$00
                DC.W $8666,$787e,$ff81,$00,$6199,$1e1f,$ffe0,$00
                DC.W $3330,$3f0f,$c0ff,$00,$cccc,$0fc3,$f03f,$00
                DC.W $3333,$c3f0,$fc0f,$00,$0ccc,$f0fc,$ff03,$00
                DC.W $c333,$3c3f,$ffc0,$00,$30cc,$0f0f,$fff0,$00
                DC.W $9998,$1f87,$e07f,$00,$6666,$87e1,$f81f,$00
                DC.W $1999,$e1f8,$fe07,$00,$8666,$787e,$ff81,$00
                DC.W $6199,$1e1f,$ffe0,$00,$9866,$8787,$7ff8,$00
                DC.W $cccc,$0fc3,$f03f,$00,$3333,$c3f0,$fc0f,$00
                DC.W $0ccc,$f0fc,$ff03,$00,$c333,$3c3f,$ffc0,$00
                DC.W $30cc,$0f0f,$fff0,$00,$cc33,$c3c3,$3ffc,$00
                DC.W $6666,$87e1,$f81f,$00,$1999,$e1f8,$fe07,$00
                DC.W $8666,$787e,$ff81,$00,$6199,$1e1f,$ffe0,$00
                DC.W $9866,$8787,$7ff8,$00,$6619,$e1e1,$1ffe,$00
                DC.W $3333,$c3f0,$fc0f,$00,$0ccc,$f0fc,$ff03,$00
                DC.W $c333,$3c3f,$ffc0,$00,$30cc,$0f0f,$fff0,$00
                DC.W $cc33,$c3c3,$3ffc,$00,$330c,$f0f0,$0fff,$00
                DC.W $1999,$e1f8,$fe07,$00,$8666,$787e,$ff81,$00
                DC.W $6199,$1e1f,$ffe0,$00,$9866,$8787,$7ff8,$00
                DC.W $6619,$e1e1,$1ffe,$00,$9986,$f878,$07ff,$00
                DC.W $0ccc,$f0fc,$ff03,$00,$c333,$3c3f,$ffc0,$00
                DC.W $30cc,$0f0f,$fff0,$00,$cc33,$c3c3,$3ffc,$00
                DC.W $330c,$f0f0,$0fff,$00,$ccc3,$fc3c,$03ff,$00
                DC.W $8666,$787e,$ff81,$00,$6199,$1e1f,$ffe0,$00
                DC.W $9866,$8787,$7ff8,$00,$6619,$e1e1,$1ffe,$00
                DC.W $9986,$f878,$07ff,$00,$6661,$7e1e,$81ff,$00
                DC.W $c333,$3c3f,$ffc0,$00,$30cc,$0f0f,$fff0,$00
                DC.W $cc33,$c3c3,$3ffc,$00,$330c,$f0f0,$0fff,$00
                DC.W $ccc3,$fc3c,$03ff,$00,$3330,$3f0f,$c0ff,$00
                DC.W $6199,$1e1f,$ffe0,$00,$9866,$8787,$7ff8,$00
                DC.W $6619,$e1e1,$1ffe,$00,$9986,$f878,$07ff,$00
                DC.W $6661,$7e1e,$81ff,$00,$9998,$1f87,$e07f,$00
                DC.W $30cc,$0f0f,$fff0,$00,$cc33,$c3c3,$3ffc,$00
                DC.W $330c,$f0f0,$0fff,$00,$ccc3,$fc3c,$03ff,$00
                DC.W $3330,$3f0f,$c0ff,$00,$cccc,$0fc3,$f03f,$00
                DC.W $9866,$8787,$7ff8,$00,$6619,$e1e1,$1ffe,$00
                DC.W $9986,$f878,$07ff,$00,$6661,$7e1e,$81ff,$00
                DC.W $9998,$1f87,$e07f,$00,$6666,$87e1,$f81f,$00
                DC.W $cc33,$c3c3,$3ffc,$00,$330c,$f0f0,$0fff,$00
                DC.W $ccc3,$fc3c,$03ff,$00,$3330,$3f0f,$c0ff,$00
                DC.W $cccc,$0fc3,$f03f,$00,$3333,$c3f0,$fc0f,$00


*    pixels/scanline    = $0050 (bytes/scanline: $000A)
*  # scanlines (height) = $000F
df:             DC.W $1f0f,$bfff,$e01f,$8c3c,$0f7c,$1f8c,$b0e5,$e01c
                DC.W $9e3e,$1e64,$1ccc,$3061,$e01c,$3633,$38e0,$18cc
                DC.W $3061,$e018,$7733,$b0c0,$18dc,$70c3,$6018,$6773
                DC.W $70c0,$18df,$60c2,$601f,$6773,$70f0,$18d8,$60c6
                DC.W $601e,$677e,$61f0,$38d8,$60c7,$e018,$666e,$6180
                DC.W $3998,$618f,$e030,$6e6e,$6180,$3998,$6198,$6030
                DC.W $6ee6,$6580,$3f3a,$e998,$6030,$7ce6,$7d90,$3e7e
                DC.W $f998,$6030,$38c6,$39f0,$00,$00,$30,$00
                DC.W $00,$00,$00,$20,$00,$00,$00,$00
                DC.W $20,$00,$00

*    pixels/scanline    = $00EC (bytes/scanline: $001E)
*  # scanlines (height) = $0005
chars:          DC.W $0255,$5452,$2250,$01,$2166,$4727,$2200,$1046
                DC.W $7263,$6773,$5215,$4562,$6263,$7555,$5570,$0250
                DC.W $2122,$4122,$01,$5311,$5441,$5522,$2721,$7554
                DC.W $5444,$5215,$4755,$5554,$2555,$5510,$0205,$5250
                DC.W $4177,$2702,$5122,$7662,$2300,$4012,$7764,$5665
                DC.W $7216,$4555,$6562,$2555,$2220,$05,$5470,$4122
                DC.W $2004,$5141,$1152,$5122,$2720,$7554,$5445,$5255
                DC.W $4555,$4551,$2557,$5240,$0202,$2150,$2250,$4024
                DC.W $2176,$1622,$2604,$1042,$7563,$6743,$5225,$7552
                DC.W $4356,$2725,$5270

*    pixels/scanline    = $005D (bytes/scanline: $000C)
*  # scanlines (height) = $0010
big_border:     DC.W $3f,$3e7e,$01f8,$f9f9,$f1fd,$f800,$03,$8000
                DC.W $1c,$1c1c,$00,$1c00,$3b,$9ce0,$01dd,$dddd
                DC.W $ddc1,$dc00,$3f,$1cfe,$01f9,$ddf9,$ddf9,$f800
                DC.W $3b,$9cee,$01dd,$ddf9,$ddc1,$f800,$3b,$9cee
                DC.W $01dd,$dddd,$f9c1,$dc00,$3f,$3e7e,$01f8,$f9dd
                DC.W $f1fd,$dc00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$3e66,$fb,$33c7,$8f80
                DC.W $03d9,$9f00,$0306,$00,$3060,$c000,$01,$8000
                DC.W $3e3c,$0183,$f7ec,$cf00,$019f,$b000,$3318,$0183
                DC.W $366c,$c18c,$019b,$b038,$3e18,$fb,$3667,$9f0c
                DC.W $03d9,$9f38,$00,$00,$00,$18,$00,$00

scrolltext:
		DC.B	"            CAN YOU READ THIS? YES? O.K.!"
		DC.B    " SLIME AGAIN PENETRATING THE KEYS OF NEW"
		DC.B    " MODE'S ST..... I WILL TRY TO WRITE SOME"
		DC.B    " INTERESTING STUFF, ALTHOUGH I HAVEN'T GOT"
		DC.B    " A BRAINWAVE OF WHAT I CAN WRITE......."
		DC.B    " LET ME SAY SOMETHING ABOUT THE SCREEN:"
		DC.B    " IT IS A JOKE! ALL CODE AND BUGS ARE DONE BY"
		DC.B    " CHAOS INC.! NEW MODE HAS INCLUDED IT IN"
		DC.B    " THE DEMO AND THE PIXELS ARE FROM ME."
		DC.B    " THE NAME OF THE SCREEN IS  BIG BORDER"
		DC.B    "  AS AN ANSWER TO ALL THESE SCREENS THAT"
		DC.B    " REMOVE ALL THESE LOVELY BORDERS. WE NEVER"
		DC.B    " UNDERSTOOD THAT! BUT NOW... FIRST TIME IN"
		DC.B    " HISTORY, IT WAS POSSIBLE TO INCREASE ALL"
		DC.B    " BORDERS AT THE SAME TIME! AS YOU SEE,  WITH"
		DC.B    " ALL BORDERS ON, WE CAN SCROLL THE WHOLE"
		DC.B    " SCREEN IN FOUR PLANES... IT'S GREAT!"
		DC.B    " WAIT FOR OUR NEXT EXPERIENCE IN BORDER"
		DC.B    " TECHNOLOGY: THE        FULLBORDER   !"
		DC.B    " NOW LET'S WRAP!   W R A P      BYE!"
		DC.B    "                                          "
		DC.B    "                                          " 
                DC.B 	-1
		EVEN
		
                BSS
bssstart:	
		IFEQ diskversion
oldpalette:	ds.l	8
oldscreen:	ds.l	1
		ENDC
key:		ds.w 1
screen2:        DS.L 1          ;Pointer auf die Mitte von Screen2
screen1:        DS.L 1          ;Pointer auf die Mitte von Screen1
screen1_ori:    DS.L 1          ;Originaler Screen
raster_pos:     DS.W 1          ;Position des Hintergrundrasters
tab_ak:         DS.L 1          ;Aktuelle Position in der DF-Tabelle
tab_scroll:     DS.W 16         ;Tabelle, nach der die geschobenen DF's kommen
wab_counter:    DS.W 1          ;Platz fÅr den Wabbelcounter
pause_counter:  DS.W 1          ;Counter fÅr Wabbelpause
scrollpos:      DS.L 1          ;Position des Scrollers
flag:           DS.W 1
hbl_pos:        DS.L 1          ;FÅr Fader
richtung:       DS.W 1          ;Richtung des Faders
fade_counter:   DS.W 1
wt:             DS.W 1
zeros:          DS.W 16         ; 16 Worte schwarz
old_vbl:        DS.L 1          ; Alter VBL-Vektor
hbl_pointer:    DS.L 1          ; HBL Farbpointer
vbl_palette:    DS.W 16         ; Farben, die vom VBL gesetzt werden
hbl_col:        DS.W 1          ; Farbe, die als nÑchstes gesetzt wird
hbl_buff:       DS.l 5         ; Zwischenspeicher fÅr MFP-Register

df_shiftet:     DS.B 180*17     ;16*geshiftet
chars_shiftet:  DS.B 60*5*4     ;Nimmt den Zeichensatz auf
                ds.b    256
screenbuff:     ds.b    32000*2 ; Platz fÅr 2 Screens
bssende:	
                END

