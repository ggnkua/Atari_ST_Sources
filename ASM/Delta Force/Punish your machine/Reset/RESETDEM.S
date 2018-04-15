***** PUNISH YOUR MACHINE RESETDEMO BY NEW MODE AND OXYGENE

;!!!!! THIS SOURCECODE IS COPYRIGHTED SOFTWARE !!!!!


disk_version    EQU 0
; 0 = Entwicklerversion/Festplatte
; 1 = Diskettenversion

                IFEQ disk_version
                OPT X+          ; Erweiterte Symboltable anschalten
                ELSE
                OPT X-          ; Symboltabelle aus
                ORG $1000       ; hier Relozieradresse angeben
                ENDC

                TEXT

                IFEQ disk_version
                pea     start_stars(PC)
                move.w  #38,-(A7)            ; Supexec
                trap    #14
                addq.l  #6,A7
                trap    #1
                clr.w   -(A7)
                ENDC

start_stars:

                lea     bss_start,A0
                lea     bss_ende,A1
                moveq   #0,D0
clear_bss:      move.l  D0,(A0)+
                cmpa.l  A0,A1
                bge.s   clear_bss

                move.l  A7,oldstack
                move    SR,old_sr
                ori     #$0700,SR            ; alle IRQ's sperren

		clr.l	$426.w			; Resvalid lîschen

                lea     stack,A7             ; eigenen Stack setzen

                bsr     install_all          ; alles initialisieren

		bsr	convert_font

		moveq	#1,d0
		jsr	music

		move.l	#vbl,$70.w

                bsr     calc_stars

                move.l  routine_pointer_tab+anim_stufen*4-4,clear_routine1
                move.l  #-1,clear_routine2
                move.l  #routine_pointer_tab,star_pointer

wait_for_text:	tst.w	stopped_text
		beq.s	wait_for_text
		
		moveq	#20,d0
		jsr	music+12
		
		move.w	#249,d7
wait_more:	bsr	vsync
		dbra	d7,wait_more

		moveq	#0,d0
		jsr	music
		
		move.l	#vbl2,$70.w
	
		bsr 	vsync
		bsr 	vsync

		movem.l	palette(pc),d0-d7
		movem.l	d0-d7,$ffff8240.w
		

                clr.b   key

wait:           bsr     vsync

                movem.w plot_registers,D0-D7
                movea.l screen_2(PC),A0
                movea.l clear_routine1,A1
                cmpa.l  #-1,A1
                beq.s   dont_clear_stars
                jsr     (A1)                 ; alte Sterne lîschen
dont_clear_stars:
                movea.l star_pointer,A6
                movea.l screen_2(PC),A0
                movea.l (A6)+,A1
                move.l  A1,clear_routine1
                jsr     (A1)

                cmpi.l  #-1,(A6)
                bne.s   nix_ende_tab
                lea     routine_pointer_tab,A6
nix_ende_tab:
                move.l  A6,star_pointer

                move.l  clear_routine1,D0    ; Pointer auf Lîschroutine
                move.l  clear_routine2,clear_routine1
                move.l  D0,clear_routine2

                move.l  screen_2(PC),D0
                move.l  screen_1(PC),screen_2
                move.l  D0,screen_1
                bsr     set_screen

                cmpi.b  #$39,key             ; Space gedrÅckt?
                bne     wait

ende:
		IFEQ	disk_version
                bsr     restore_all          ; alles zurÅcksetzen

                movea.l oldstack,A7          ; alten Stack setzen
                move    old_sr,SR
		illegal
		ENDC
		IFNE	disk_version
		move.l	$4.w,a0			; Reset auslîsen
		jmp	(a0)
		ENDC
		



;-----------------------------------------------------------------------------

calc_stars:
; Berechnet die Sternroutine vor.

stars_anzahl    EQU 8200
anim_stufen     EQU 64

                lea     routine_buffer,A4
                lea     routine_pointer_tab,A5
                moveq   #anim_stufen-1,D7

mega_calc_loop: move.w  D7,-(A7)

                lea     mul_160_tab(PC),A2
                moveq   #10,D5               ; fÅr Schieben um 10 nach rechts

                movem.l D0-A2,-(A7)
                movea.l screen_2(PC),A3
                lea     32000(A3),A3
                movem.w leer_feld,D1-A2      ; 10 Werte (erweitert)
                move.w  #199,D0              ; 200 Scanlines
clear_screen:   movem.l D1-A2,-(A3)          ; 160 Bytes lîschen
                movem.l D1-A2,-(A3)
                movem.l D1-A2,-(A3)
                movem.l D1-A2,-(A3)
                dbra    D0,clear_screen
                movem.l (A7)+,D0-A2

; Hier in a3 Anfang von Screen 2

                lea     stars_koord_tab(PC),A0

                move.w  #stars_anzahl-1,D7

; in a0 ist Tabelle mit den Koordinaten x,y,z (z verÑndert sich)
; auf Screen 2 wird vorberechnet, auf Screen 1 ist Scroller.

plot_stars_loop:
                moveq   #0,D0
                moveq   #0,D1
                move.w  (A0)+,D0             ; x
                move.w  (A0)+,D1             ; y
                move.w  (A0),D2              ; z (0-4095)
                sub.w   #64,D2
                and.w   #4095,D2

                addq.w  #1,D2
                move.w  D2,(A0)+             ; und z wieder speichern

                muls    #1600,D0
                muls    #1600,D1
                divs    D2,D0
                divs    D2,D1
                add.w   #160,D0              ; Clippen!
                cmp.w   #319,D0
                bhi.s   dont_plot
                add.w   #100,D1
                cmp.w   #199,D1
                bhi.s   dont_plot

                subq.w  #1,D2
                lsr.w   D5,D2                ; /1024 -> 0-3 = Farben
                eori.w  #3,D2
                add.w   D2,D2                ; *2

                move.w  D1,D3                ; y
                add.w   D3,D3                ; *2 wegen Wortzugriff
                move.w  0(A2,D3.w),D3        ; Wert aus Mult.tab (160) holen
                add.w   D2,D3                ; + Farbe (= Plane)

                move.w  D0,D1                ; x
                and.w   #-16,D1              ; untere 4 Bits weg
                lsr.w   #1,D1                ; jetzt Bitblock in d1 (0-152)

                add.w   D1,D3                ; Auf Offset addieren

                move.w  #$8000,D4            ; um Pixel zu bekommen
                and.w   #15,D0
                lsr.w   D0,D4

                or.w    D4,0(A3,D3.w)        ; Wert auf Screen einodern

dont_plot:      dbra    D7,plot_stars_loop

; --- CHECK FOR INVISIBAL STARS ---


                move.w  #200*20-1,D7
loop_check_invisibal:
                move.w  6(A3),D0
                not.w   D0
                and.w   D0,4(A3)
                and.w   D0,2(A3)
                and.w   D0,(A3)
                move.w  4(A3),D0
                not.w   D0
                and.w   D0,2(A3)
                and.w   D0,(A3)
                move.w  2(A3),D0
                not.w   D0
                and.w   D0,(A3)
                lea     8(A3),A3
                dbra    D7,loop_check_invisibal
                lea     -32000(A3),A3

; --- CREATE MEGA-CODE ---
                move.l  A4,(A5)+             ; in Pointertabelle ablegen
		moveq	#0,d5

; ***** DIESE ROUTINE ENTSCHEIDET SICH FUER LANGWORT ODER NORMAL ********

create_code:
		movem.w	(a3),d0/d1
		tst.w	d0
		beq.s	sero_word
		tst.w	d1
		beq.s	no_long_word
; ---- USE-LONG-WORD ----
		bsr.s	do_long
		bra.s	used_long_word
; ---- USE ONLY ONE WORD
no_long_word:
		bsr.s	do_word
sero_word:
		addq.l	#2,a3
		addq.w	#2,d5
used_long_word:
		cmp.l	screen_3(pc),a3
		blt.s	create_code
                move.w  #$4e75,(A4)+         ; RTS
                move.w  (A7)+,D7
                dbra    D7,mega_calc_loop
                move.l  #-1,(A5)+            ; Endekennung fÅr Pointertabelle

		sub.l	#start_stars,a4
		move.l	a4,$200.w
                rts

; ***** CREATE LONG-WORD CODE *****

do_long:
                move.w  #$0aa8,(A4)+         ; EOR.L
                move.l  (A3)+,(A4)+          ; DATA
                move.w  D5,(A4)+             ; OFFSET
                addq.w  #4,D5
                rts


; ***** CREATE WORD CODE *****

do_word:
                moveq   #0,D2
                move.w  (A3),D0
                move.w  D0,D1
                REPT 16
                add.w   D1,D1
                DC.W $6402      ; BCC zwei weiter
                addq.w  #1,D2
                ENDR

                tst.w   D2
                beq.s   sero_plane_word
                cmp.w   #1,D2
                beq.s   only_1_star

; ---- MEHR ALS 1 STERN -----

                move.w  #$0a68,(A4)+         ; EORI.W #$XXXX,YYYY(A0)
                move.w  D0,(A4)+             ; das ganze Wort
                move.w  D5,(A4)+             ; und Offset ablegen Åber a0
                bra.s   sero_plane_word
only_1_star:
; ---- 1 STERN ----

                moveq   #-1,D1               ; Pixel ermitteln
bit_not_set:
                addq.w  #1,D1
                add.w   D0,D0
                bcc.s   bit_not_set          ; BCC zwei zurueck

                move.w  D5,D6                ; Offset umkopieren

                btst    #3,D1                ; ist Bit 4 gesetzt (8-15)
                beq.s   not_in_byte

                addq.w  #1,D6

not_in_byte:    and.w   #7,D1                ; nur Werte von 0-7 (D0-D7)

                add.w   D1,D1                ; *2
                addq.w  #1,D1                ; +1
                move.b  D1,(A4)+             ; jetzt BCHG DX,Y(a0)
                move.b  #$68,(A4)+           ;
                move.w  D6,(A4)+             ; Offset speichern
sero_plane_word:
                rts




;-----------------------------------------------------------------------------

install_all:
; Initialisiert alle Hardware-Register

                move.b  $ffff820a.w,oldsync
                move.b  $ffff8260.w,oldres

                movem.l $ffff8240.w,D0-D7
                movem.l D0-D7,oldpalette

                lea     $ffff8240.w,A0
                moveq   #7,D0
clrpal:         clr.l   (A0)+
                dbra    D0,clrpal

                lea     $ffff8201.w,A0       ; Screenadresse holen
                movep.w 0(A0),D0
                move.w  D0,oldscreen

                move.l  #screen_base,D0
                and.l   #-256,D0             ; untere 8 Bits weg
                move.l  D0,screen_1
                movea.l D0,A0
                add.l   #200*160,D0
                move.l  D0,screen_2
                move.l	d0,d1
                add.l	#200*160,d1
                move.l	d1,screen_3
                movea.l D0,A1

                move.w  #(200*40)-1,D0       ; beide Screens lîschen
clr_screens:    clr.l   (A0)+
                clr.l   (A1)+
                dbra    D0,clr_screens

                move.l  screen_1(PC),D0
                bsr     set_screen

                bsr     init_mfp

                move    #$2300,SR            ; IRQ's an

                moveq   #$12,D0              ; Maus aus
                bsr     send_ikbd

                bsr     vsync
                move.b  #2,$ffff820a.w       ; 50 Hz

                bsr     vsync
                clr.b   $ffff8260.w          ; Lowres

                movem.l palette(PC),D0-D7
                movem.l D0-D7,$ffff8240.w

                rts


restore_all:
; alle Hardware-Register werden wieder so gesetzt wie am Anfang

                move.l  #start_vbl,$70.w
                bsr     vsync

                movem.l oldpalette,D0-D7
                movem.l D0-D7,$ffff8240.w

                bsr     vsync
                move.b  #2,$ffff820a.w       ; 50Hz

                bsr     vsync
                move.b  #0,$ffff820a.w       ; 60Hz (damit Syncerrors beheben)

                bsr     vsync
                move.b  oldsync,$ffff820a.w  ; alte Sync. und Res. zurÅck
                move.b  oldres,$ffff8260.w

                bsr     restore_mfp

                moveq   #$08,D0              ; Maus wieder ein
                bsr     send_ikbd

                move.w  oldscreen,D0
                lea     $ffff8201.w,A0
                movep.w D0,0(A0)             ; alte Screenadresse setzen

                rts

send_ikbd:
; sendet Byte aus d0 an IKBD
                lea     $fffffc00.w,A0
waitkeyready:   btst    #1,(A0)
                beq.s   waitkeyready
                move.b  D0,2(A0)
                rts
set_screen:
; in d0 = Screenadresse
                lsr.l   #8,D0
                lea     $ffff8201.w,A0
                movep.w D0,0(A0)
                rts

vsync:          lea     vsync_count,A0
                move.l  (A0),D0
wait_strahl:    cmp.l   (A0),D0
                beq.s   wait_strahl
                rts
init_mfp:
; rettet und setzt alle IRQ's

                move    SR,-(A7)
                ori     #$0700,SR
                move.l  $0118.w,oldkey
		move.l	$0114.w,oldtimerc
                move.l  $0120.w,oldtimerb
                move.l  $70.w,oldvbl
                lea     $fffffa00.w,A0       ; MFP
                move.b  $07(A0),oldmfp07
                move.b  $09(A0),oldmfp09
                move.b  $11(A0),oldmfp11
                move.b  $13(A0),oldmfp13
                move.b  $15(A0),oldmfp15
                move.b  $17(A0),oldmfp17
                move.b  $1b(A0),oldmfp1b
                move.b  $21(A0),oldmfp21
		move.b	$1d(a0),oldmfp1d
                clr.b   $07(A0)              ; alle IRQ's aus
                clr.b   $09(A0)
                clr.b   $13(A0)
                clr.b   $15(A0)
                bset    #0,$07(A0)           ; Timer B erlauben
                bset    #0,$13(A0)
		bset	#5,$15(a0)
                bset    #6,$09(A0)           ; Tastatur IRQ erlauben
                bset    #6,$15(A0)
		move.b	#%01000000,$17(a0)
		move.l	#start_vbl,$70.w
		move.l	#newkey,$118.w
		move.l	#timer_b,$120.w

                move.b  #$03,$fffffc00.w     ; ACIA-Init
                move.b  #$96,$fffffc00.w

                move    (A7)+,SR

                rts

restore_mfp:
; setzt alle MFP-Register wieder zurÅck

                move    SR,-(A7)
                ori     #$0700,SR
                move.l  oldkey,$0118.w
		move.l	oldtimerc,$114.w
                move.l  oldtimerb,$0120.w
                move.l  oldvbl,$70.w
                lea     $fffffa00.w,A0       ; MFP
                move.b  oldmfp07,$07(A0)
                move.b  oldmfp09,$09(A0)
                move.b  oldmfp11,$11(A0)
                move.b  oldmfp13,$13(A0)
                move.b  oldmfp15,$15(A0)
                move.b  oldmfp17,$17(A0)
                move.b  oldmfp1b,$1b(A0)
                move.b  oldmfp21,$21(A0)
		move.b	oldmfp1d,$1d(a0)
		move.b	#180,$fffffa23.w
                move    (A7)+,SR
                rts

start_vbl:      clr.b   $fffffa1b.w          ; Timer B aus
                addq.l  #1,vsync_count
                rte

;------------------------------------------------------------------------------




convert_font:
; wandelt Font von Screenformat in Format untereinander um.

                lea     font(PC),A0
                lea     font_buffer,A1
                moveq   #1,D0                ; 2 Zeilen
conv_loop1:     moveq   #39,D1               ; 40 Zeichen
                moveq   #1,D2                ; erster Addierwert
conv_loop2:     moveq   #7,D3                ; 8 Zeilen hoch
                movea.l A0,A2
conv_loop3:     movep.l 0(A2),D4
                move.l  D4,(A1)+
                lea     160(A2),A2
                dbra    D3,conv_loop3
                adda.l  D2,A0                ; 1 oder 7 aufaddieren
                eori.w  #6,D2                ; 1 oder 7 drin
                dbra    D1,conv_loop2
                lea     7*160(A0),A0
                dbra    D0,conv_loop1
                rts

print_line:
; Schreibt eine Zeile mit Text auf den Screen
		

                movea.l text_pointer(PC),A0
                cmpi.b  #-1,(A0)             ; Endekennung erreicht?
                bne.s   not_eot
		move.w	#-1,stopped_text
		rts
not_eot:        movea.l A0,A1                ; Pointer retten

                moveq   #39,D0               ; 40 Zeichen maximal
count_chars:    cmpi.b  #-2,(A1)+            ; Zentrierkennung?
                dbeq    D0,count_chars
                move.l  A1,text_pointer
                addq.w  #1,D0                ; jetzt 40-Anzahl in d0
                move.w  D0,D1
                sub.w   #40,D1
                neg.w   D1                   ; jetzt Anzahl in d1
                lsr.w   #1,D0                ; /2 wegen Zentrierung
                subq.w  #1,D1                ; Anzahl -1 wegen DBRA
                movea.l screen_1(PC),A1
                adda.w  text_ypos(PC),A1
                moveq   #1,D2                ; erster Addierwert nach Zeichen
                move.w  D0,D3
                and.w   #1,D3
                beq.s   is_gerade
                moveq   #7,D2                ; auf ungerader Position
                addq.l  #1,A1                ; Byteposition
is_gerade:      lsr.w   #1,D0                ; /2
                lsl.w   #3,D0                ; *8 (Grîûe Bitblock)
                adda.w  D0,A1

char_loop:      moveq   #0,D0
                move.b  (A0)+,D0             ; Zeichen holen
                sub.b   #' ',D0
                lsl.w   #5,D0                ; *32 = Zeichengrîûe
                lea     font_buffer,A2
                adda.w  D0,A2

off             SET 0
                REPT 8
                move.l  (A2)+,D3
                movep.l D3,off(A1)
off             SET off+160
                ENDR

                adda.w  D2,A1                ; Addierwert 1 oder 7
                eori.w  #6,D2                ; damit jetzt 7 oder 1

                dbra    D1,char_loop



                rts


fade_up:
; Blendet Farben hoch
; in a5=Sourcepalette, a6=Destination
                moveq   #7,D7                ; nur 8 Farben
ful01:          move.w  (A6),D0
                and.w   #%111,D0
                move.w  (A5),D1
                and.w   #%111,D1
                cmp.w   D0,D1
                beq.s   fcol21
                addq.w  #1,D0
                move.w  (A6),D1
                and.w   #%1111111111111000,D1
                or.w    D0,D1
                move.w  D1,(A6)
                bra.s   fcolok1
fcol21:         move.w  (A6),D0
                and.w   #%1110000,D0
                move.w  (A5),D1
                and.w   #%1110000,D1
                cmp.w   D0,D1
                beq.s   fcol31
                add.w   #$10,D0
                move.w  (A6),D1
                and.w   #%1111111110001111,D1
                or.w    D0,D1
                move.w  D1,(A6)
                bra.s   fcolok1
fcol31:         move.w  (A6),D0
                and.w   #%11100000000,D0
                move.w  (A5),D1
                and.w   #%11100000000,D1
                cmp.w   D0,D1
                beq.s   fcolok1
                add.w   #$0100,D0
                move.w  (A6),D1
                and.w   #%1111100011111111,D1
                or.w    D0,D1
                move.w  D1,(A6)
fcolok1:        lea     2(A6),A6
                lea     2(A5),A5
                dbra    D7,ful01
                rts

fade_down:
; faded Paletten runter
; a0=Zeiger auf Farben

                moveq   #7,D2                ; 8 Farben
fdl0:           move.w  (A0),D0
                and.w   #%111,D0
                beq.s   col2
                subq.w  #1,D0
                move.w  (A0),D1
                and.w   #%1111111111111000,D1
                or.w    D0,D1
                move.w  D1,(A0)
                bra.s   colok
col2:           move.w  (A0),D0
                and.w   #%1110000,D0
                beq.s   col3
                sub.w   #$10,D0
                move.w  (A0),D1
                and.w   #%1111111110001111,D1
                or.w    D0,D1
                move.w  D1,(A0)
                bra.s   colok
col3:           move.w  (A0),D0
                and.w   #%11100000000,D0
                beq.s   colok
                sub.w   #$0100,D0
                move.w  (A0),D1
                and.w   #%1111100011111111,D1
                or.w    D0,D1
                move.w  D1,(A0)
colok:          lea     2(A0),A0
                dbra    D2,fdl0
                rts


clear_line:     movea.l screen_1(PC),A0
                adda.w  text_ypos(PC),A0
                move.w  #(8*40)-1,D0
                moveq   #0,D1
cl_loop:        move.l  D1,(A0)+
                dbra    D0,cl_loop
                rts


vbl:
                movem.l D0-A6,-(A7)
                clr.b   $fffffa1b.w
                move.b  #10,$fffffa21.w
                move.b  #8,$fffffa1b.w
                move.l  #timer_b,$0120.w

                lea     pal_buffer,A0
                movem.l (A0)+,D0-D3
                movem.l D0-D3,$ffff8240.w    ; erste Palette setzen
                move.l  A0,pal_pointer

		tst.w	stopped_text
		bne	all_over

                tst.w   fade_down_flag
                bne.s   fade_down_ready

                lea     pal_buffer,A0
                adda.w  pal_offset(pc),A0
                movea.l A0,A6                ; merken fÅr spÑter
                bsr     fade_down

                moveq   #3,D0                ; 4*2 Farben
test_black:     tst.l   (A6)+                ; alle Farben schwarz?
                bne     all_over             ; <>0 -> noch nicht fertig
                dbra    D0,test_black

                move.w  #-1,fade_down_flag   ; runterfaden fertig!

                bsr     clear_line           ; Zeile lîschen

                bsr     print_line           ; Zeile ausgeben

                bra.s   all_over

fade_down_ready:
                lea     text_palette(PC),A5
                lea     pal_buffer,A6
                adda.w  pal_offset2(PC),A5
                adda.w  pal_offset(PC),A6
                bsr     fade_up

                moveq   #3,D0                ; 4*2 Farben
                lea     text_palette(PC),A5
                lea     pal_buffer,A6
                adda.w  pal_offset2(PC),A5
                adda.w  pal_offset(PC),A6
comp_pal:       cmpm.l  (A5)+,(A6)+          ; Farben gleich?
                bne.s   all_over
                dbra    D0,comp_pal

                clr.w   fade_down_flag       ; wieder von vorne
                addi.w  #16,pal_offset
                addi.w  #16,pal_offset2
                cmpi.w  #8*16,pal_offset2
                bne.s   not_last_pal
                clr.w   pal_offset2
not_last_pal:   addi.w  #10*160,text_ypos
                cmpi.w  #201*160,text_ypos
                bne.s   all_over
                move.w  #160,text_ypos       ; neuer Text
                clr.w   pal_offset
all_over:
		jsr	music+8		
                movem.l (A7)+,D0-A6
                addq.l  #1,vsync_count
                rte

vbl2:		clr.b	$fffffa1b.w	; Timer B anhalten
		addq.l	#1,vsync_count
		rte


text_ypos:      DC.W 160        ; hier steht Offset auf Screen drin
pal_offset:     DC.W 0
pal_offset2:    DC.W 0
fade_down_flag: DC.W 0
stopped_text:	DC.W 0



timer_b:
; setzt jeweils die ersten 8 Farben
                move.l  A0,-(A7)
                movea.l pal_pointer(PC),A0   ; setzt 8 Farben
                move.l  (A0)+,$ffff8240.w
                move.l  (A0)+,$ffff8244.w
                move.l  (A0)+,$ffff8248.w
                move.l  (A0)+,$ffff824c.w
                move.l  A0,pal_pointer
                movea.l (A7)+,A0
                rte



newkey:         move.w  D0,-(A7)             ; TastaturIRQ
                move.b  $fffffc00.w,D0
                btst    #7,D0
                beq.s   endkey
                move.b  $fffffc02.w,key
endkey:         move.w  (A7)+,D0
                rte


;------------------------------------------------------------------------------
                DATA

screen_1:       DC.L 0          ; so weit oben damit PC-Relativer Zugriff
screen_2:       DC.L 0
screen_3:	DC.L 0
key:            DC.W 0

palette:
                DC.W 0,$0222,$0444,$0444,$0666,$0666,$0666,$0666
                DC.W $0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777



pal_pointer:    DC.L pal_buffer

text_palette:   DC.W $00,$0774,$0763,$0752,$0741,$0630,$0520,$0410
                DC.W $00,$0477,$0376,$0275,$0174,$63,$52,$41
                DC.W $00,$0477,$0367,$0257,$0147,$36,$25,$14
                DC.W $00,$0747,$0736,$0725,$0714,$0603,$0502,$0401

                DC.W $00,$0477,$0376,$0275,$0174,$63,$52,$41
                DC.W $00,$0774,$0763,$0752,$0741,$0630,$0520,$0410
                DC.W $00,$0747,$0736,$0725,$0714,$0603,$0502,$0401
                DC.W $00,$0477,$0367,$0257,$0147,$36,$25,$14


text_pointer:   DC.L text

text:
; maximal 40 Zeichen pro Zeile
; -1 ist Endekennung
; -2 zentriert den Text
; immer 20 Zeilen!
;                    "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"

                DC.B "THE RESETDEMO",-2
                DC.B "-------------",-2
                DC.B " ",-2
                DC.B "YOU'VE PRESSED THE RESETBUTTON?",-2
                DC.B " ",-2
                DC.B "YOU WANT A DECENT RESETDEMO?",-2
                DC.B " ",-2
                DC.B "YOU'LL GET ONE!",-2
                DC.B " ",-2
                DC.B "IN SOME HOURS YOU'LL WITNESS",-2
                DC.B "A NEW STARFIELD-RECORD...",-2
                DC.B " ",-2
                DC.B "FORGET ELECTRA'S 1094 STARS...",-2
                DC.B " ",-2
                DC.B "FORGET FLIX'S 2000 STARS...",-2
                DC.B " ",-2
                DC.B "WE'LL BE DOING ALTOGETHER 8200 STARS",-2
                DC.B "ALONG WITH A FUCKING NEAT QUARTET-TUNE!",-2
                DC.B " ",-2
                DC.B " ",-2


                DC.B "SINCE THE PRECALCULATION TAKES AGES, WE "
                DC.B "DO THE CREDITS AND THE FANK-U-S BEFORE. "
                DC.B " ",-2
                DC.B " ",-2
                DC.B "CREDITS:",-2
                DC.B "--------",-2
                DC.B " ",-2
                DC.B "CODING BY:",-2
                DC.B "NEW MODE (DF) AND OXYGENE (TLB)",-2
                DC.B " ",-2
                DC.B "GRAPHICS BY:",-2
                DC.B "SLIME (DF) AND SPAZ (TLB)",-2
                DC.B " ",-2
                DC.B "MUSIC BY:",-2
                DC.B "SPAZ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "YOU'VE SEEN, THIS IS A JOINT-VENTURE OF",-2
                DC.B "DELTA FORCE AND THE LOST BOYS!",-2
                DC.B " ",-2

                DC.B "THE STARFIELD YOU'RE ABOUT TO SEE",-2
                DC.B "USES A NEW TECHNIQUE INVENTED BY",-2
                DC.B "NEW MODE AND OXYGENE AND WAS OPTIMIZED",-2
                DC.B "AT THE ICC 2.",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "WE ARE -NOT- CHEATING IN ANY WAY, ALL",-2
                DC.B "STARS ARE PLOTTED AND WE DON'T",-2
                DC.B "PRECALCULATE ANY SCREENS OR USE",-2
                DC.B "DELTA-PACKING OR SOMETHING LIKE THIS!",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "OF COURSE THE FLIGHT-PATHS ARE",-2
                DC.B "PRECALCULATED, BUT PLEASE TELL ME HOW",-2
                DC.B "TO DO 8200 STARS WITHOUT",-2
                DC.B "PRECALCULATING...",-2
                DC.B " ",-2
                DC.B "IF YOU MANAGE TO DO THIS, PLEASE TELL",-2
                DC.B "EITHER NEW MODE OR OXYGENE ABOUT YOUR",-2
                DC.B "NEW STARFIELD-RECORD...",-2

                DC.B "THANKS HAVE TO FLY TO:",-2
                DC.B " ",-2
                DC.B "MY (NEW MODE) UNIVERSITY-COMRADES:",-2
                DC.B " ",-2
                DC.B "ALEX, CHRISTOPH, MARKUS AND JUERGEN",-2
                DC.B "FOR THE MORAL SUPPORT DURING ALL THE",-2
                DC.B "FUCKING HARD SUMMERTIME WHILE PREPARING",-2
                DC.B "FOR OUR GODDAMNED MATHS-EXAM.",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "WALLISER COMPUTER",-2
                DC.B " ",-2
                DC.B "FOR THE ULTRAFAST REPAIR OF MY ST.",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "AUSPUFF-SOFORTDIENST",-2
                DC.B " ",-2
                DC.B "FOR THE FAST AND CHEAP REPAIR OF",-2
                DC.B "MY CAR.",-2
                DC.B " ",-2

                DC.B "BILBO AND STICK, AKA RIPPED OFF",-2
                DC.B " ",-2
                DC.B "FOR ALWAYS ASKING STUPID QUESTIONS",-2
                DC.B "AND FOR KEEPING US BUSY WITH THIS DEMO.",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "FRONT 242",-2
                DC.B " ",-2
                DC.B "FOR A BRILLIANT CONCERT THIS MAY.",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "FURYO OF THE OVERLANDERS",-2
                DC.B " ",-2
                DC.B "FOR ALL THE PHOTOS",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "AND TO ALL THE GUYS WHO CONTRIBUTED",-2
                DC.B "TO THIS DEMO (YOU KNOW WHO YOU ARE)",-2
                DC.B " ",-2
                DC.B " ",-2

                DC.B "THIS IS NOT OUR LAST DEMO, WE'LL BE",-2
                DC.B "DOING MORE DEMOS IN THE FUTURE!",-2
                DC.B " ",-2
                DC.B "BUT DON'T EXPECT ANY NEW DF-DEMOS IN THE"
                DC.B "NEXT FEW MONTHS, WE ARE NOW BUSY WITH",-2
                DC.B "A GAME (BORING HUH?) AND WE'LL ALSO",-2
                DC.B "BE DOING A LITTLE FACE-LIFTING FOR",-2
                DC.B "MAGGIE (WAIT FOR ISSUE 10!)",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B "WE HAVE LOTSA WORK WITH OUR",-2
                DC.B "STUDIES AND SCHOOL, SO THERE WON'T",-2
                DC.B "BE ANOTHER I.C.C. NEXT YEAR, SORRY!",-2
                DC.B " ",-2
                DC.B "PLEASE HAVE FUN WITH ALL OUR NEXT",-2
                DC.B "RELEASES AND HOPE THEY WILL BE OUT",-2
                DC.B "SOON...",-2
                DC.B " ",-2
		DC.B " ",-2
                DC.B "HASTA LA VISTA! NEW MODE,DELTA FORCE",-2

                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2
                DC.B " ",-2

                DC.B -1
                EVEN

font:
; 8*8
; im Screenformat abgelegt. Space ist erster Buchstabe

                DC.W $14,$0c,$00,$00,$00,$9000,$4800,$00
                DC.W $00,$00,$00,$00,$18,$08,$00,$00
                DC.W $0950,$0430,$0308,$00,$1c00,$0c00,$1c00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $5418,$3008,$0c00,$00,$acac,$6464,$1c1c,$00
                DC.W $c0ac,$4062,$1e,$00,$48ac,$2462,$1c1e,$00
                DC.W $5454,$3032,$0c0e,$00,$00,$00,$00,$00
                DC.W $08,$08,$04,$00,$2a,$18,$06,$00
                DC.W $48,$24,$1c,$00,$a84a,$6426,$1c1e,$00
                DC.W $944a,$4c26,$3c1e,$00,$4a4a,$2626,$1e1e,$00
                DC.W $08,$18,$04,$00,$00,$4800,$d800,$00
                DC.W $00,$00,$00,$00,$20,$28,$18,$00
                DC.W $0a54,$1948,$073c,$00,$3a00,$0600,$2e00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $5010,$ce30,$3e08,$00,$a2ba,$9e86,$7e7e,$00
                DC.W $56,$80ce,$403e,$00,$eea2,$5e9e,$3e7e,$00
                DC.W $5052,$cece,$3e3e,$00,$00,$00,$00,$00
                DC.W $00,$2010,$08,$00,$28,$0867,$1f,$00
                DC.W $a8,$5e,$3e,$00,$6cee,$da5e,$3e3e,$00
                DC.W $78ee,$c65e,$3e3e,$00,$eeee,$5e5e,$3e3e,$00
                DC.W $14,$10,$0c,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$10,$30,$00
                DC.W $2008,$2806,$180e,$00,$1300,$6900,$7f00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $8028,$8660,$4618,$00,$0a0a,$0606,$0e0e,$00
                DC.W $c880,$9880,$4040,$00,$4002,$800e,$400e,$00
                DC.W $4284,$0682,$c646,$00,$1800,$0800,$0400,$00
                DC.W $6020,$2020,$10,$00,$0841,$0843,$0427,$00
                DC.W $42,$c6,$06,$00,$c640,$8280,$4640,$00
                DC.W $8240,$8080,$4640,$00,$4000,$8080,$4040,$00
                DC.W $08,$04,$1c,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $2003,$1001,$7007,$00,$4c00,$3500,$7b00,$00
                DC.W $2a,$18,$06,$00,$00,$00,$00,$00
                DC.W $4848,$0640,$ce38,$00,$0c08,$0424,$1c1c,$00
                DC.W $1054,$5010,$c8ec,$00,$8814,$d80c,$441c,$00
                DC.W $5042,$4c00,$3cc6,$00,$1000,$1400,$0c00,$00
                DC.W $cc10,$c208,$3e18,$00,$c400,$400a,$3e06,$00
                DC.W $86,$82,$46,$00,$1880,$4cc0,$c440,$00
                DC.W $40c0,$06e8,$c218,$00,$c0d4,$e88c,$1842,$00
                DC.W $1c,$04,$1c,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $4003,$5001,$3007,$00,$0900,$4d00,$7300,$00
                DC.W $14,$32,$0e,$00,$00,$00,$00,$00
                DC.W $c600,$0208,$d618,$00,$20,$282c,$181c,$00
                DC.W $88a8,$0646,$fefe,$00,$5600,$5018,$ce38,$00
                DC.W $7a96,$c464,$3efa,$00,$00,$00,$00,$00
                DC.W $8608,$be04,$7e0c,$00,$aa10,$9414,$7e0c,$00
                DC.W $76,$12,$ce,$00,$c840,$4440,$dcc0,$00
                DC.W $c648,$0618,$c2f8,$00,$480a,$1858,$f8c6,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $200c,$2802,$180e,$00,$0200,$2200,$3e00,$00
                DC.W $7000,$1000,$00,$00,$c000,$4000,$2000,$00
                DC.W $c218,$0608,$e618,$00,$600a,$2006,$100e,$00
                DC.W $320a,$ce06,$fe0e,$00,$8260,$4450,$c630,$00
                DC.W $c03c,$c672,$467e,$00,$1800,$0800,$0400,$00
                DC.W $2048,$00,$6018,$00,$0c00,$00,$0c00,$00
                DC.W $8e,$42,$fe,$00,$4680,$c240,$c6c0,$00
                DC.W $8680,$0240,$c6c0,$00,$8084,$4042,$c0c6,$00
                DC.W $18,$08,$04,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $0928,$0764,$1f1c,$00,$0400,$1c00,$1c00,$00
                DC.W $c000,$d000,$3000,$00,$8000,$a000,$6000,$00
                DC.W $b628,$4e24,$fe1c,$00,$52aa,$4e66,$3e1e,$00
                DC.W $aa,$0866,$181e,$00,$6a00,$a6a0,$de60,$00
                DC.W $4202,$3e06,$fe06,$00,$1000,$1400,$0c00,$00
                DC.W $50,$40,$2030,$00,$18,$08,$0804,$00
                DC.W $06,$c2,$c6,$00,$2a6a,$a6a6,$dede,$00
                DC.W $2a68,$a6a6,$dede,$00,$400a,$80a6,$c0de,$00
                DC.W $10,$14,$0c,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $0b28,$0718,$0f78,$00,$00,$00,$00,$00
                DC.W $00,$2000,$e000,$00,$00,$00,$00,$00
                DC.W $6c14,$1c0c,$7c3c,$00,$26a4,$2e9c,$1e7c,$00
                DC.W $18a4,$089c,$187c,$00,$2400,$5c40,$7cc0,$00
                DC.W $3406,$0c06,$7c06,$00,$00,$00,$00,$00
                DC.W $10,$08,$78,$00,$10,$14,$0c,$00
                DC.W $c2,$c6,$c6,$00,$ac26,$dc5e,$fc7e,$00
                DC.W $ac26,$dc5e,$fc7e,$00,$c066,$c05e,$c07e,$00
                DC.W $8428,$4218,$00,$00,$2a86,$1842,$0600,$00
                DC.W $8084,$4042,$00,$00,$8448,$4224,$1c,$00
                DC.W $9448,$4c24,$3c1c,$00,$946a,$4c26,$3c1e,$00
                DC.W $aa84,$6642,$1e00,$00,$8484,$4242,$00,$00
                DC.W $c6c6,$4242,$00,$00,$aa00,$6600,$1e00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $4210,$c630,$08,$00,$2c4e,$22ca,$1e06,$00
                DC.W $404a,$c0ee,$00,$00,$42a8,$e65e,$3e,$00
                DC.W $6eac,$da5a,$3e3e,$00,$6ed6,$da4e,$3e3e,$00
                DC.W $6e42,$e6c6,$1e00,$00,$4242,$c6c6,$00,$00
                DC.W $0400,$8484,$4242,$00,$a200,$9e00,$7e00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $4428,$c420,$0218,$00,$8c,$0284,$065c,$00
                DC.W $a4,$8084,$407a,$00,$a444,$94c2,$6206,$00
                DC.W $8044,$82c6,$4602,$00,$80c0,$8280,$4640,$00
                DC.W $0884,$2084,$1842,$00,$8484,$8484,$4242,$00
                DC.W $64c8,$02aa,$ee66,$00,$0200,$0e00,$0e00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $8a10,$a008,$5e38,$00,$50,$0208,$06f8,$00
                DC.W $c05a,$8028,$40fe,$00,$5280,$2082,$fe46,$00
                DC.W $0680,$0282,$c646,$00,$0628,$0224,$c6dc,$00
                DC.W $2042,$2800,$18c6,$00,$4240,$10,$c6c6,$00
                DC.W $4820,$0404,$7c7c,$00,$00,$0c00,$1c00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $1438,$0a08,$fe38,$00,$06c8,$0218,$06f8,$00
                DC.W $d6,$4010,$c0d6,$00,$ce46,$1002,$dec6,$00
                DC.W $ea46,$2612,$dece,$00,$ea34,$264a,$de7e,$00
                DC.W $18c6,$0800,$38c6,$00,$c4d2,$0210,$c6ee,$00
                DC.W $1010,$0808,$3838,$00,$3000,$2800,$1800,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $c228,$0618,$c638,$00,$02a4,$064c,$06fc,$00
                DC.W $c084,$42,$c0c6,$00,$8cc2,$4a06,$cec6,$00
                DC.W $9482,$6c46,$fcce,$00,$ac02,$4402,$fc06,$00
                DC.W $2804,$1882,$38c6,$00,$0672,$a280,$eefe,$00
                DC.W $6838,$4428,$3c18,$00,$2000,$5000,$3000,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $4208,$c638,$c638,$00,$aa02,$66ca,$1ec6,$00
                DC.W $2a00,$a6c6,$dec6,$00,$422a,$c6a6,$c6de,$00
                DC.W $6a,$c0a6,$c0de,$00,$049a,$c246,$ce3e,$00
                DC.W $28ae,$18a2,$38de,$00,$082c,$44e2,$7cee,$00
                DC.W $2418,$6208,$ee38,$00,$cc00,$4200,$3e00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $c638,$c638,$c638,$00,$acc6,$9cc4,$7cc2,$00
                DC.W $b6c6,$cec6,$fec6,$00,$c67c,$c64c,$c67c,$00
                DC.W $c05c,$c04c,$c07c,$00,$c6ac,$c29c,$c67c,$00
                DC.W $1854,$380c,$387c,$00,$10c2,$28c6,$38c6,$00
                DC.W $4208,$c618,$c638,$00,$a600,$9e00,$7e00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00



plot_registers:
; d0-d7 mit 7-0 fÅr plotten
                DC.W 7,6,5,4,3,2,1,0


mul_160_tab:
; Tabelle mit Werten von 0-199 mit 160 multipliziert
wert            SET 0
                REPT 200
                DC.W wert*160
wert            SET wert+1
                ENDR

music:		INCBIN 'ENCHLAN1.MUS'

stars_koord_tab:
; jeweils X.w,Y.w,Z.w

                INCBIN 'STARTAB2.IMG' ; DF-Logo (2307)
                INCBIN 'TLB.IMG' ; TLB,  (1540)
; (Anzahl-2307-300)*6
                INCBIN 'STARTAB4.IMG' ; Normale Sterne (5000-2307-1540)

;------------------------------------------------------------------------------
		BSS
bss_start:      

oldmfp07:       DS.B 1
oldmfp09:       DS.B 1
oldmfp11:       DS.B 1
oldmfp13:       DS.B 1
oldmfp15:       DS.B 1
oldmfp17:       DS.B 1
oldmfp1b:       DS.B 1
oldmfp21:       DS.B 1
oldmfp1d:	DS.B 1
oldres:         DS.B 1
oldsync:        DS.B 1
oldtimerc:	ds.l 1
oldvbl:         DS.L 1
oldkey:         DS.L 1
oldtimerb:      DS.L 1
oldstack:       DS.L 1
oldpalette:     DS.L 8
oldscreen:      DS.W 1
vsync_count:    DS.L 1
old_sr:         DS.W 1
leer_feld:      DS.W 10         ; 10 Werte 0
star_pointer:   DS.L 1
clear_routine1: DS.L 1
clear_routine2: DS.L 1
pal_buffer:     DS.L 4*21       ; jeweils 4 Longs (8 Farben fÅr Paletten)

font_buffer:    DS.L 2*40*8     ; hier alle Zeichen untereinander

                DS.B 512        ; 512 Bytes Stack
stack:
                DS.B 256        ; wegen unteren 8 Bits des Screens
screen_base:    DS.B 32000*2    ; Platz fÅr 2 Screens

routine_pointer_tab:
                DS.L anim_stufen+1

routine_buffer:


bss_ende:       END
