; PLL-INSTALLATION (obwohl es keine PLL ist)
; GA 30.4.93/9.5.93
; Neuanfang 22.5.93
; ME 6.6.93: Beim Kaltstart immer (!) "versauter" Screen.
;			Versuche den Fehler zu beheben.
; GeneralÅberholung:
; ME 5.8.93: U.a. Anpassung auf hîheren Be-/Entladewiderstand
; ME 6.8.93: Erneute Anpassung an Entladewiderstand...
;			 Warteschleifen nicht mehr Prozessor-Geschw.-abhÑngig
; GA 26.8-1.9.93 PLL Regelverhalten noch etwas mehr auf 
;			'schnell-schnell-laaaangsaaaam' getrimmt
; GA 4.9		Paddle-Feedback implementiert
; 121094 ga: Beim Screensaver fÅhrt Paddlewert 255 nicht mehr zur Verwirrrrrung
;--------------------------------------------------------
; EXTERNE LABELS:
; c_frequ:	gewÅnschte Vertikalfrequenz
; pll_on:	0= AUS, 1=AN
; pll_mode: 1= wenn eingerastet->pll_on=0
; old_c_frequ: Alte Frequenz
;--------------------------------------------------------
	GLOBL install_vbl,de_install_vbl,pll_on,c_frequ,pll_mode
	GLOBL old_c_frequ,reset_pll,pll_lc_flag,pll_lc,old_av
	GLOBL vscr_enable,own_vbl_count,l_delta
	GLOBL res_paddle_pll,paddle_adjust
	
	GLOBL vscr_em
	
	GLOBL PLL_VERSION

tot	equ 256-10
wie_oft equ 6
au	equ 2

install_vbl:
		movem.l d0-a6,-(sp)
		clr.l old_pll_vbl
		clr own_vbl_count
		clr old_av
		move #0,pll_lc_flag
		move.l $70,d0		; Installiert den
		move.l d0,a0		; VBL-(P)LL-Handler
		move #-1,old_c_frequ
		move.l -8(a0),d1	; "Ketten"-Installation
		cmpi.l #"BLOW",d1	; nicht mîglich
		bne not_in
		move.l -4(a0),d0	; (P)LL ist schon installiert ->
		move.w -14(a0),old_c_frequ ; vorÅbergehend ausklinken
		move.l a0,old_pll_vbl	; alte pll in old_pll_merken
								; und in d0 den URalten vbl merken
		
not_in:
		move.l d0,old_vbl		; pll war noch nicht drin
								; alten vbl merken
		move.l #own_vbl,$70		; eigenen pll_vbl einhaengen
 		move.b $fffa1d,d0
		or.b #7,d0
		move.b #$ff,$ff9203
		movem.l (sp)+,d0-a6
		rts
;--------------------------------------------------------
; d2=0 -> ganz runter
; muss im supervisormode sein 
reset_pll:
		movem.l	d0-d2,-(sp)
		; Erstmal Frequenz GANZ runter
		bclr	#7,$ff9203	; Richtung setzen
		bclr	#6,$ff9203	; HOLD abschalten
		move.l	$4ba,d0		; Systemtimer holen
		add.l	#100,d0		; .5 Sekunde warten
wait_i:
		cmp.l	$4ba,d0		; Zeit verstrichen?
		bge		wait_i		; :-O (Das soll ein "GÑhni" sein)
		
		bset	#6,$ff9203	; HOLD setzen
		bset	#7,$ff9203
		
		move	sr,d1		; Maschinenstatus merken
		ori		#$700,sr	; Interrupts AUS
		move.b	$fffa1d,d0	; Timer C/D Control Reg.
		andi.b	#$f0,d0		; Timer D STOP
		move.b	d0,$fffa1d
		andi.l	#$ff,d2
		lsr.w	#1,d2		; Zeit halbieren
		move.b	d2,$fffa25	; Timer D Counter setzen
		ori.b	#6,$fffa1d	; TD Vorteiler 1:100
		
		bset	#7,$ff9203	; und wieder hoch
		bclr	#6,$ff9203	;
		
wait_ii:
		cmp.b 	#1,$fffa25	; Warte bis Timer D fertig
		bgt		wait_ii		; :-O  Schnarch
		
		bset 	#6,$ff9203	; HOLD
		bset 	#7,$ff9203		
		
		ori		#7,d0
		move.b	d0,$fffa1d	; Vorteiler 1:200
		move.b	#0,$fffa25	; Counter auf 256
		move	d1,sr		; Maschinenstatus restaurieren
		move.l	$4ba,d2		; Systemzeit holen
		add.l	#50,d2		; 0.25 Sekunden warten
wait_iii:
		cmp.l	$4ba,d2		; warten
		bge		wait_iii	; warten
		
		movem.l	(sp)+,d0-d2
		rts
;--------------------------------------------------------
paddle_adjust:			; bekommt in d0 den einzustellenden Wert
						; und in d1 die Hysterese
		movem.l a0/d1/d2/d3/d4/d5,-(sp)
		move sr,d3
		ori #$700,sr
		move.l #$ff9203,a0	; a0 muû also gesichert werden
		move #2000,d5		; timeout
paddle_loop:
		move #2000,d4
troedel0:
		nop
		nop
		nop
		nop
		dbra d4,troedel0
		move.w $ff9214,d2
		sub d1,d2
		sub.b d0,d2	; soll>ist
		bhi dreh_runter
		move.w $ff9214,d2
		cmpi #255,d2
		beq no_hyst
		add  d1,d2
no_hyst:
		sub.b d0,d2	; soll>ist
		bls dreh_hoch
		clr d0
paddle_go_home:
		move d3,sr
		movem.l (sp)+,a0/d1/d2/d3/d4/d5
		rts
dreh_runter:
		andi #$ff,d2
		addq #1,d2
		move.b #31,(a0)
troedel1:
		nop					; trîdel
		nop
		dbra d2,troedel1
		move.b #255,(a0)
		dbra d5,paddle_loop
		st d0
		bra paddle_go_home
dreh_hoch:
		neg d2
		andi #$ff,d2
		addq #1,d2
		move.b #255-64,(a0)
troedel2:
		nop
		nop					; trîdel
		dbra d2,troedel2
		move.b #255,(a0)
		dbra d5,paddle_loop
		st d0
		bra paddle_go_home			
;--------------------------------------------------------
de_install_vbl:
		tst.l old_pll_vbl	; war vorher schon eine pll da?		
		beq no_old_pll		; nein!
		move.l old_pll_vbl,$70	; alte pll
		rts
no_old_pll:
		move.l old_vbl,$70	; alter Handler
		rts
;--------------------------------------------------------
; XBRA-Protokoll (mit stolzgeschwellter Brust!)
lc_frequ:dc.w 3
uc_frequ:dc.w 1
c_frequ:dc.w 70
		dc.b	"XBRA"
		dc.b	"BLOW"
old_vbl:dc.l	0	
;-----------------PLL------------------------------------
own_vbl:
		tst		pll_on
		beq		cont_vbl		; PLL nicht eingeschaltet
		
		btst #0,$ffff820a.w
		beq cont_vbl			; ohne ext.syn gehts auch nicht
	
		tst.b	own_vbl_count+1	; %256!=0?
		bne		store_and_cont	; D merken und weiter
regelung:
		movem.l	d0-d4/a0,-(sp)
		move	sr,d3
		ori		#$700,sr		; INTs sperren
		movec	cacr,d0			; MC68030-Caches anschalten
		ori 	#4096+256+16+1,d0
		movec 	d0,cacr
		bset 	#0,$ff8007		; CPU auf 16MHz schalten
		
		move 	$ff82a0,d2		; vlines-count
		cmp 	$ff82ac,d2		; Vsync-start
		bge 	welcome_to_the_vbl
		cmpi 	#2,$ff82a0
		bgt 	no_vsync1		; wir sind nicht im Vsync

welcome_to_the_vbl:
		tst 	v_flag			; <>0 : Keine Messung
		bne 	no_vsync2		; Flag lîschen, Raus hier

;'''''''''''''''''''''''''''''''''''''''''''''''''''''
		clr		d1
		move.b 	old_a23,d1
		move	old_4bc,d0		; Anzahl 200Hz ints
		
		btst	#5,old_a0d		; Int TC pending?		
		beq 	na
		addq 	#1,d0			; 1*200hz mehr
		move 	#191,d1
na:
		andi 	#63,d0
		move.l 	#tab192,a0
		move 	(a0,d0.w*2),d4	; vielfache von 192
		sub 	#192,d1			; d1 aufwÑrts zÑhlend
		neg 	d1
		add 	d1,d4			; $4ba*192+TC
;'''''''''''''''''''''''''''''''''''''''''''''''''''''''
		move.b	$fffffa23.w,d1	; TC data
		move.b	d1,old_a23
		move	$4bc.w,d0		; Anzahl 200Hz ints
		move	d0,old_4bc
		
		move.b	$fffffa0d.w,d2
		move.b	d2,old_a0d
		btst	#5,d2			; Int TC pending?		
		beq		na1
		addq	#1,d0			; 1*200hz mehr
		move	#191,d1
na1:
		andi	#63,d0
		move	(a0,d0.w*2),d0	; vielfache von 192
		sub		#192,d1			; d1 aufwÑrts zÑhlend
		neg		d1
		add		d1,d0			; $4ba*192+TC
;'''''''''''''''''''''''''''''''''''''''''''''''''''''''		
		sub d4,d0				; alten Wert abziehen
		bpl nn
		add #64*192,d0
nn:
		move d0,$4f0

		
		move c_frequ,d1
		sub #1,d1
		cmp d1,d0
		bls	pll_decrement		; Frequenz muss runter
		add #2,d1
		cmp d1,d0
		bhi pll_increment		; oder rauf
		clr l_delta

pll_locked:						; keine énderung nîtig
		 addq #1,pll_lc
		 cmpi #2,pll_lc		; schon lÑnger als .. VBLs?
		 blt no_vsync
		 move #1,own_vbl_count
		 bra vsync_weiter
no_vsync:	
		move #256-wie_oft,own_vbl_count	; Signal fÅrs weiterzÑhlen
vsync_weiter:
		move d3,sr
		movem.l (sp)+,d0-d4/a0

cont_vbl:
		move.l old_vbl,-(sp)	; Alter VBL auf den Stack
		rts						; und Jump

no_vsync1:
		move #1,v_flag
		bra no_vsync
no_vsync2:
		clr v_flag
		move.b $fffffa23.w,old_a23		; TC data
		move $4bc.w,old_4bc			; Anzahl 200Hz ints
		move.b $fffffa0d.w,old_a0d
		bra no_vsync

no_vsync_tot:
		move #256-wie_oft,own_vbl_count	; Signal fÅrs weiterzÑhlen
		bra vsync_weiter
; Hierher kommt man nur, wenn die PLL schon eingerastet ist
store_and_cont:
		cmpi.b #255-wie_oft,own_vbl_count+1
		beq jetzt_merken_es_wir_uns
		addq #1,own_vbl_count	; sonst ZÑhler++
pll_sleep:
;		move   $4bc.w,old_4bc	; Werte merken
;		move.b $fffffa0d.w,old_a0d
;		move.b $fffffa23.w,old_a23
		move.l old_vbl,-(sp)
		rts	
jetzt_merken_es_wir_uns:

		addq #1,own_vbl_count
		move   $4bc.w,old_4bc	; Werte merken
		move.b $fffffa0d.w,old_a0d
		move.b $fffffa23.w,old_a23

		tst pll_mode	; =1? dann schlafen (fÅr BLOWCONF)
		bne pll_sleep_mode1

		move.l old_vbl,-(sp)
		rts		
;--
pll_sleep_mode1:
		cmpi #10,pll_lc
		ble pll_sleep
		clr pll_on
		bra pll_sleep
;--		
pll_increment:
		move c_frequ,d1
;		lsr #au,d1
		sub d0,d1
		neg d1
		move d1,d0
		lsr #3,d0
		lsr #2,d1		; 2
		add d0,d1
		cmp l_delta,d1
		ble ganz_normal_weiter1
		move l_delta,d1
ganz_normal_weiter1:
		move d1,l_delta
		cmp #15,d1
		bgt pll_inc1
		cmpi #4,d1
		bgt pll_inc_s2
		move #0,d1
		move.b #tot,own_vbl_count+1
		bra inc_short
pll_inc_s2:
		move #19,d1
pll_inc1:
		move.l a0,-(sp)
		move.l #$ff9203,a0
		move.b (a0),d0
		andi #%00111111,d0
		ori  #%10000000,d0
		move.b d0,(a0)
inc_wait:
		dbra d1,inc_wait
		
		bset #6,(a0)
		bset #7,(a0)
		move.l (sp)+,a0
		bra no_vsync
inc_short:
		move.l a0,-(sp)
		move.l #cmpdbl,a0
		move.b (a0),d0
		andi #%00111111,d0
		ori  #%10000000,d0
		moveq #1,d1
inc_sh_lo:
		move.b d0,(a0)
		bset #6,(a0)
		move.l #$ff9203,a0
		dbra d1,inc_sh_lo
		bset #7,(a0)
		move.l (sp)+,a0
		bra no_vsync_tot		
;--		
pll_decrement:
		move c_frequ,d1
;		lsr #au,d1
		sub d0,d1
		lsr #2,d1
		cmp l_delta,d1
		blt ganz_normal_weiter2
		move l_delta,d1
ganz_normal_weiter2:
		move d1,l_delta
		cmp #5,d1	; 6
		bgt pll_dec1
		move #0,d1
		move.b #tot,own_vbl_count+1
		bra dec_short
pll_dec1:
		move.l a0,-(sp)
		move.l #$ff9203,a0
		move.b (a0),d0
		andi #%00111111,d0
		move.b d0,(a0)
dec_wait:
		dbra d1,dec_wait
		
		bset #6,(a0)
		bset #7,(a0)
		move.l (sp)+,a0
		bra no_vsync
dec_short:
		move.l a0,-(sp)
		move.l #cmpdbl,a0
		move.b (a0),d0
		andi #%00111111,d0
		moveq #1,d1
dec_sh_lo:
		move.b d0,(a0)
		bset #6,(a0)
		move.l #$ff9203,a0
		dbra d1,dec_sh_lo
		bset #7,(a0)
		move.l (sp)+,a0
		bra no_vsync_tot		
;--------------------------------------------------------
	data
	
tab192:
		dc 0,192,192*2,192*3,192*4,192*5,192*6,192*7,192*8
		dc 9*192,10*192,11*192,12*192,13*192,14*192,15*192
		dc 16*192,17*192,18*192,19*192,20*192,21*192,22*192
		dc 23*192,24*192,25*192,26*192,27*192,28*192,29*192
		dc 30*192,31*192,32*192,33*192,34*192,35*192,36*192
		dc 37*192,38*192,39*192,40*192,41*192,42*192,43*192
		dc 44*192,45*192,46*192,47*192,48*192,49*192,50*192
		dc 51*192,52*192,53*192,54*192,55*192,56*192,57*192
		dc 58*192,59*192,60*192,61*192,62*192,63*192
	bss		
old_d:	ds.l 1
new_d: ds.l 1
old_av: ds.l 1
cmpdbl:	ds.l 2

own_vbl_count: ds.w 1
pll_lc:		 ds.l 1
pll_lc_flag: ds.l 1
old_pll_vbl: ds.l 1
last_vbl: ds.l 1
old_4bc: ds.w 1
old_a0d: ds.w 1
old_a23: ds.w 1
l_delta: ds.w 1
v_flag: ds.w 1
sa_cacr: ds.l 1

		end
