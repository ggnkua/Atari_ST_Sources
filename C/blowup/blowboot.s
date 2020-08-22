;/* BLOW UP BOOT PRGRAMM */
; 21.6.93 Richtiger auf Test Treibernr<11 fÅr Speedo

VERSION_	equ (VERSIONX!=-1)
	
	if (!VERSION_)
VERSION		equ 2
		print "internal definition of VERSION"
	else
VERSION		equ VERSIONX
		print "external"
	endif
	
	
FRANCAISE_ 	equ (FRANCAISEX!=-1)
	
	if (!FRANCAISE_)
FRANCAISE	equ 0
	else
FRANCAISE	equ FRANCAISEX	
	endif
	
	if (FRANCAISE)
		print "Francaise"
	endif

PLL_VERSION equ 2
XTAL_VERSION equ 1
SOFT_VERSION equ 0

DEMO_VERSION equ 0
DA_VERSION equ 0

	GLOBL install,de_install_vbl,pll_on,c_frequ,pll_mode
	GLOBL old_c_frequ,reset_pll,pll_lc,old_av
	GLOBL res_paddle_pll,paddle_adjust
	
	GLOBL v_curx,v_cury,l_delta
	
	GLOBL actdat,screen_mem,linea,vscr_enable
	
	GLOBL saver_install

	GLOBL _vscr_rx,_vscr_ry,_bpl,_col_mode,_vscr_x,_vscr_y
	GLOBL install_qckswtch,Xmontype,actres
	GLOBL actbank,tabele,set_video,pieps
	
	GLOBL infovscr,ivscr_cookie,ivscr_product,ivscrt_version
	GLOBL ivscr_x, ivscr_y, ivscr_w, ivscr_h
	GLOBL disable_vscr_cookie,enable_vscr_cookie

	
flag1	equ 0		; 
flag2 	equ 2
flag3	equ 4
;
xres 	equ $40				; farbregister brauchen wir nicht
yres 	equ xres+2			; 2
bpl 	equ yres+2			; 4
slen 	equ bpl+2			; 6
celwr	equ slen+4			; a
planes 	equ celwr+2			; c
c_cfrequ equ planes+2		; e
pll_flag equ c_cfrequ+2		; 10=blubber[40]
pll_res	 equ pll_flag+2		; 12=42
pll_r1	 equ pll_res+2		; 14 paddle-wert
pll_r2 	 equ pll_r1+2		; 16
pll_r3   equ pll_r2+2		; 18
vscr_flag equ pll_r3+2		; 1a
vscr_rx	  equ vscr_flag+2	; 1c	(real xres)
vscr_ry		equ vscr_rx+2	; 1e
col_mode	equ vscr_ry+2	; 20
monitor_type1 equ col_mode+2; 22
critical_flag equ monitor_type1+2; 24		(blubber[50])
max_s_c equ critical_flag+2	; 26
sav_act equ max_s_c+4		; 2a

;---------------------------------
		bra.w 	anfang
	
tabele:	dc.w 2		; monoch, 
		ds.w 127
		dc.w 2		; 4
		ds.w 127
		dc.w 2		; 16
		ds.w 127
		dc.w 2		; 256
		ds.w 127	
		dc.w 2		; TC
		ds.w 127
tabele2:
		dc.w 2		; monoch2 
		ds.w 127
		dc.w 2		; 4-2
		ds.w 127
		dc.w 2		; 16-2
		ds.w 127
		dc.w 2		; 256-2
		ds.w 127	
		dc.w 2		; TC-2
		ds.w 127
res1_2:					; 
		dc.b 0,0,0,0,0,0	; bank0 default

		dc.l set_modes
monitor_type: 
		dc.w 2		; monitortyp TV,SM,VG
		
; hier offset 2604
max_saver_counter:
		dc.l 300*200		; Schonzeit
saver_active:
		dc.w 0		; 0=inaktiv, sonst aktiv
saver_counter:
		ds.l 1		; ZÑhler

; offset 2614
ID:
		dcb.b 10,0
reg_txt:
if DEMO_VERSION
if DA_VERSION
		dc.b "DEMO VERSION  for Digital Arts     ",13,10,0
else
		dc.b "DEMO VERSION       ",13,10,0
		endif
else
		dc.b "                       ",13,10,0
endif								;
		ds.b 80			; 130Bytes

		dc.b 248,63,143,6,74
		dc.b 5,95,55,29,42
		
		dc.b 68,75,31,55,165		; 50 MÅllbytes
		dc.b 130,17,151,234,18
		
		dc.b 57,77,3,184,248
		dc.b 51,5,62,41,74
		
		dc.b 221,119,189,45,134
		dc.b 159,115,51,71,3
		
		dc.b 60,27,56,124,98
		dc.b 86,244,64,36,94

h2_version: ; 2614+166 bytes
		dc.w 0		
Xmontype:
		dc.w 0			; (TV,SM,VGA,SVGA,MS) = (0,1,2,3,4)
Su78:
		dc.w 0
		even
;---------------------------------
anfang:	
	MOVE.L  4(A7), A3   ; BasePagePointer from Stack
	
	MOVE.L  12(A3),A0
	ADD.L   20(A3),A0
	ADD.L   28(A3),A0
	ADD.W   #$110,A0

	lea		stack(pc),a7
	move.l	a0,proglen
	move.l a0,-(sp)
	move.l a3,-(sp)
	move.w #0,-(sp)
	move #$4a,-(sp)
	trap #1				; mshrink
	lea $c(sp),sp
	
; der screen-realloc wird erst im vdi teil gemacht
		clr.l screen_mem
		move.l #0,screen
		move #0,vscr_enable
		move #1,actres		
		move #0,boot
		move #0,old_handle
		move #0,vsetflag				
		move.l #welcome,a1
		bsr text_ausg
			
		move #-1,-(sp)
		move #$b,-(sp)
		trap #13		; bios kbshift
		addq.l #4,sp
		and #3,d0
		bne error
bootinst_goon:		
		move #89,-(sp)
		trap #14
		addq.l #2,sp
		move d0,actual_monitor_type
		cmp monitor_type,d0
;		bne wrong_monitor
		
		pea		install(pc)
		move.w	#$26,-(a7)
		trap	#14		; supexec
		addq.l	#6,a7

		move.l #ow_txt,a1
		bsr text_ausg
		

		clr.w	-(a7)
		move.l	proglen(pc),-(a7)
		move.w	#$31,-(a7)
		trap 	#1  	; ptermres
;-----------------------------------------------------------		
error:
		move.l #error_msg,a1	
		bsr text_ausg
		move.l #$00020002,-(sp) ;bconin CON
		trap #13
		addq.l #4,sp
		cmpi.b #'n',d0
		beq no_bootinst
		cmpi.b #'N',d0
		beq no_bootinst
		bra bootinst_goon
no_bootinst:
		move.l #error_msg2,a1	
		bsr text_ausg
		clr.w	-(sp)
		trap	#1		; pterm
wrong_monitor:
		move.l #error_msg1,a1
		bsr text_ausg
		clr.w -(sp)
		trap 	#1
;-----------------------------------------------------------
create_jar:		; Legt einen Cookie-Jar an, wenn es noch gar keinen
				; gibt. Anzahl der Cookie-PlÑtze in D0.
		movem.l d0-a6,-(sp)
		
		move.l	d0,-(sp)	; Anzahl zwischenspeichern
		lsl.l	#3,d0		; D0 mal acht fÅr LÑnge in Bytes
		clr.w	-(sp)		; ST-Ram
		move.l	d0,-(sp)	; LÑnge
		move.w	#68,-(sp)	; Gemdos #68
		trap	#1			; Mxalloc
		addq.l	#8,sp		; Stack aufrÑumen
		tst.l	d0			; D0 testen
		beq		error		; kein Speicher? Dann Abbruch.
		move.l	d0,$5a0		; Cookie-Adresse setzen
		move.l	d0,a0
		move.l	#0,(a0)+	; NULL-Cookie schreiben
		move.l	(sp)+,(a0)	; Jar-LÑnge schreiben	
		
		movem.l (sp)+,d0-a6
		rts
;----------------
extend_cookie:
		; Vergrîûert Cookieplatz um 16 weitere Cookies.
		; Parameter: Jetzige CookielÑnge in D0.
		; Ergebnis: Neue Cookieadresse in $5a0 und Zeiger auf
		;   Nullcookie in A0.
		add.l	#16,d0
		lsl.l	#3,d0		; D0 mal acht fÅr LÑnge in Bytes
		clr.w	-(sp)		; ST-Ram
		move.l	d0,-(sp)	; LÑnge
		move.w	#68,-(sp)	; Gemdos #68
		trap	#1			; Mxalloc
		addq.l	#8,sp		; Stack aufrÑumen
		tst.l	d0			; D0 testen
		beq		error		; kein Speicher? Dann Abbruch.
		move.l	$5a0,a0		; Alte Cookie-Jar Adresse
		move.l	d0,$5a0		; Neue Cookie-Jar Adresse
		move.l	d0,a1
exco_loop:
		move.l	(a0)+,(a1)+	; Cookie-ID kopieren
		beq		exco_end	; Letztes Cookie? Dann fertig!
		move.l	(a0)+,(a1)+	; Cookie-Parameter kopieren
		bra.s	exco_loop	; NÑchster Cookie
exco_end:
		move.l	(a0),(a1)	; Cookie-Parameter kopieren
		lea		-4(a1),a0	; Adresse des NULL-Cookie nach A0
		rts					; ZurÅck.
;----------------
install_cookie:
		movem.l d0-a6,-(sp) ; Register retten
		move.l $5a0,d0		; Existiert schon ein Cookie-Jar?
		bne cookie_there	; Ja, dann weiter
		move.l #16,d0		; 16 freie PlÑtze
		bsr create_jar		; Erzeuge Cookie-Jar
cookie_there:
		move.l $5a0,a0		; Cookie-Jar Adresse nach A0
		moveq.l #0,d0		; ZÑhler fÅr gefundene Cookies
cookie_loop:
		tst.l (a0)			; Cookie-Inhalt testen
		beq free_cookie		; Leeres Cookie?
		cmpi.l #"BLOW",(a0) ; Wir selber schon da?
		beq error			; Programmabbruch
		addq.l #8,a0		; NÑchstes Cookie
		addq.l #1,d0		; CookiezÑhler erhîhen
		bra cookie_loop
free_cookie:				; NULL-Cookie gefunden
		move.l 4(a0),d1		; Cookie-Grîûe holen
		addq.l #3,d0		; Paût unser Cookie+Nullcookie noch rein?
					; ...und das VSCR-Cookie?
		cmp.l	d0,d1		; Vergleiche Jargrîûe <-> max. Jargrîûe
		blt write_cookie	; Verzweige, wenn max.Jargrîûe < Jargrîûe
		move.l	d1,d0		; Jetzige CookielÑnge Åbergeben
		bsr	extend_cookie	; Cookie-Jar vergrîûern
write_cookie:
		move.l	(a0),16(a0)	; NULL-Cookie verschieben
		move.l	4(a0),20(a0)
		move.l #"BLOW",(a0)	; Eigenes Cookie eintragen
		move.l #tabele,4(a0)
		move.l #"VSCR",8(a0)    ; Vscreen Cookie eintragen
		move.l #infovscr,12(a0)
		movem.l (sp)+,d0-a6	; Register restaurieren
		rts
;-----------------------------------------------------------
install:
		
		move sr,d0
		ori #$700,sr
		lea ID,a0
		lea reg_txt,a1
		lea ow_txt,a2
		move #14,d1
decode_loop:
		move.l (a0),d2
		move.l (a1)+,d3
		eor.l d3,d2
		move.l d2,(a2)+
		
		move.l 4(a0),d2
		move.l (a1)+,d3
		eor.l d3,d2
		move.l d2,(a2)+
		
		move.b 8(a0),d2
		move.b (a1)+,d3
		eor.b d3,d2
		move.b d2,(a2)+
		dbra d1,decode_loop
		move d0,sr	
		bsr install_cookie
		move.l $88,d0
		move.l #own_disp,$88
		move.l d0,old_2
		move.l $b8,d0
		move.l #xbios_new,$b8
		move.l d0,old_xbios
		dc.w $a000		; linea #0
		move.l a0,linea
		move #2,actres
if VERSION==PLL_VERSION
		move #54,c_frequ
		move #0,pll_on
		move #0,pll_mode
		bsr install_vbl
		move #200,d2		; um Anfangsloch wegzubekommen
		bsr reset_pll
		move #60,d2		; ca 32MHz
		bsr reset_pll
		move.w $ff9214,d0	; Paddleport
		cmpi.b #255,d0	; wenn nichts dranhÑngt: immer -1
		sne paddle_version	
endif
; VBL-queue virtual screen emulator install
		if 1
		move $454,d0
		subq #2,d0
		move.l $456,a0
		addq.l #4,a0		; ersten auslassen
such_loop:
		tst.l (a0)+
		beq inst_vscr
		dbra d0,such_loop
		bra no_install_vscr
inst_vscr:
		move.l #vscr_em,-(a0)
no_install_vscr:
		endif
		bsr saver_install

		bsr install_qckswtch

		rts
;--------------------------------------------------------
saver_install:
		move.l	d0,-(sp)
		move.l	$118,d0		; MFP-ACIA-Ints
		move.l	d0,old_118
		move.l	#new_118,$118
		clr.l	saver_counter
		move.l	$114,d0
		move.l	#new_400,$114
		move.l	d0,old_400
		clr		saver_flag
		clr		eckflag
		move.l	(sp)+,d0
		rts
;--------------------------------------------------------
saver_server:
		move $ff82a0,d0		; war nur wegen SM124
		cmp $ff82ac,d0
		bge mir_san_im_vbl
		cmp $ff82a6,d0
		bge nur_im_vbl
mir_san_im_vbl:
		move	$ff820a,saved_820a
		move	$ff82c0,saved_82c0
		move	#$186,$ff82c0
		move	#$101,$ff820a
		st		saver_flag
		clr		eckflag
if VERSION==PLL_VERSION
		move pll_on,saved_pll_on
		clr pll_on
		move $ff9214,d0
		andi #$ff,d0
		move d0,saved_paddle
endif
nur_im_vbl:
		rts
;--------------------------------------------------------
xbra_400:
		dc.b	"XBRA"
		dc.b	"BLOW"
old_400:
		dc.l	0
new_400:
		movem.l	a0/d0/d1,-(sp)
		tst.b	saver_active
		beq		keinen_vbl_simul1
		tst.b	saver_flag
		bne		vscr_weiter1
		tst.b	eckflag
		bne		nu_mal_weiter
		move.l	linea,a0
		cmpi 	#0,-$25a(a0)
		bgt 	nu_mal_weiter
		move.l 	max_saver_counter,d0
		sub.l 	#50*4,d0
		move.l 	d0,saver_counter
		st 		eckflag

nu_mal_weiter:
		addi.l	#1,saver_counter
		move.l	max_saver_counter,d0
		cmp.l	saver_counter,d0
		bge		vscr_weiter
save_it:
		bsr		saver_server
vscr_weiter:
		movem.l	(sp)+,d0-d1/a0
		jmp		([old_400.l])
	
vscr_weiter1:
		addi.l	#1,saver_counter
		move	2+saver_counter,d0
		andi	#3,d0
		bne		keinen_vbl_simul1	

einen_vbl_simul:
if VERSION==PLL_VERSION
		tst paddle_version
		beq doch_kein_paddle
		move saved_paddle,d0	; evtl. Åber paddle-wert
		moveq #1,d1				; Hysterese
		bsr paddle_adjust		; Auslaufen korrigieren
endif	
doch_kein_paddle:
		move	#$0070,-(sp)
		move.l	#keinen_vbl_simul1,-(sp)	; Returnadr.
		move	sr,-(sp)
		jmp		([$70.l])		; vbls ausfÅhren
keinen_vbl_simul1:	
		movem.l	(sp)+,d0-d1/a0
		jmp		([old_400.l])
;--------------------------------------------------------	
xbra_118:
		dc.b	"XBRA"
		dc.b	"BLOW"
old_118:
		dc.l	0	
	
new_118:
		btst.b #7,$fffc00		; int-Bit IKBD-ACIA
		beq no_keyb_int
		bsr saver_deactivate
no_keyb_int:
		jmp		([old_118.l])
;--------------------------------------------------------
saver_deactivate:
		tst.b	saver_flag
		beq		saver_Weiter
		move	saved_820a,$ff820a
		move	saved_82c0,$ff82c0
if VERSION==PLL_VERSION
		move saved_pll_on,pll_on
		move #10,l_delta
endif
saver_Weiter:
		clr		eckflag
		clr.l	saver_counter
		clr		saver_flag
		rts
;--------------------------------------------------------
super:
		; XBRA-Protokoll (mit stolzgeschwellter Brust!)
		dc.b	"XBRA"
		dc.b	"BLOW"
old_2:	dc.l	0	
own_disp:
		cmp #115,d0		; AES oder VDI ?
		beq	do_new
do_old:		
		move.l old_2,a0
		jmp (a0)		; AES !
do_new:
		move.l 	d1,a0
		move.l 	(a0),a0 ; contrl
;		move 	(a0),d2	; Funktionsnummer
		cmpi 	#1,(a0)	; v_opnwk ?
		beq.s do_new1
		cmpi 	#2,(a0)	; v_clswk ?
		beq do_new2
		bra do_old
;--------------------------------------------------------------
do_new1:
if 0
		move.l a1,-(sp)
		move.l #vopen,a1
		bsr text_ausg
		move.l (sp)+,a1
endif
		move.l $45e,old_screen
		move.l d1,pb			; d1 sichern	
		move.l d1,a0
		move.l 4(a0),a0
			
		cmpi #10,(a0)		; nur screens verdrehen
		bgt do_old
;		clr		d2
;		bsr	pieps
		move #1,vsetflag
		clr vsetflag1
		movem.l d1/d2/a1,-(sp)	; sichern ist immer gut ...
		bsr trap2_emul			; orig. v_opnwk ausfÅhren
		movem.l (sp),d1/d2/a1
;		bsr	pieps
;		bsr extsyn_off				; extsync erst mal wieder aus
		move.l pb,d1
		move.l d1,a0
		move.l (a0),a0
		move 12(a0),d0				; handle
		move d0,old_handle
		
; ERST JETZT haben wir die richtige Planeanzahl in 0(linea)
; 
		tst actres
		bge	weiter			; Kein KompatibilitÑtsmodus
		tst Su78			; "Super78" aktiv?
		beq go_home			; Nîîîh..
if DEMO_VERSION=0
		move.w #$182,$ff82c0 ; Yo! MTV Raps
endif
		bra go_home
weiter:	move.l linea,a1		
		move (a1),d2		; Planeanzahl
		bsr get_color_mode
		move d2,actplanes
		bsr get_table_vdi
		beq mike_weiter
		tst Su78
		beq go_home
		move.w #$182,$ff82c0	; nein ... auch gut
mike_weiter:
		move actplanes,actres		
		move.l a1,actdat

; 
; jetzt fangen wir mit der richtigen Initialisierung an
;

		bsr screen_malloc
not_boot:
		move.l actdat,a1
;		bsr set_linea
;		bsr set_video
		bsr patch_intout
		
		
; die richtigen work_out Paras werden jetzt
; mit extended_inquiry eingetragen
		if 0
		move.l d1,a1
		move.l (a1),a1
		move #102,(a1)			; #ext inqu.
		move.l d1,a1
		move.l 4(a1),a1
		move #0,(a1)			; 0=normale Daten
		movem.l (sp),d1/d2/a1	
		bsr trap2_emul			; trap2 ext inqu.
		movem.l (sp),d1/d2/a1 
		endif
		move.l actdat,a1
; Fehler: A1 wurde vielleicht durch VDI zerstîrt. 

		move.l pb,a0
		move.l $c(a0),a0
		move yres(a1),2(a0)
		move xres(a1),(a0) 
		
		tst vsetflag1
		bne kein_set_video_mehr
		bsr set_video	
;		bsr set_linea
kein_set_video_mehr:
		if 1
		movem.l d0-a6,-(sp)
		move.w #-1,-(sp)
		move.l screen_mem,-(sp)	; phys
		move.l screen_mem,-(sp)	; log
		move #5,-(sp)
		trap #14			; xbios set log. screen
		lea $c(sp),sp
		movem.l (sp)+,d0-a6
		endif
		bsr set_linea
ende:
		movem.l (sp)+,d1/d2/a1 
		rte
go_home:

if VERSION==PLL_VERSION
		clr pll_on
endif
		move #-1,actres
		movem.l (sp)+,d1/d2/a1	; stack aufrÑumen
		rte
;--------------------------------------------------------
; CLOSE WK
do_new2:
		move.l d1,a0
		move.l (a0),a0
		move 12(a0),d2
		cmp old_handle,d2
		bne do_old
		cmpi #0,old_handle
		beq do_old
		bsr trap2_emul
		
		clr saver_active
		move.l #-1,max_saver_counter
		bsr extsyn_off
;		bsr screen_free
		move #0,old_handle
		clr boot		
if VERSION==PLL_VERSION
		clr pll_on
endif
		rte
;--------------------------------------------------------
trap2_emul:
		move #$88,-(sp) ; TRAP #2 Emulation
		pea cp
		move sr,-(sp)
		move.l old_2,a0
		jmp (a0)		; original VDI-Aufruf
cp:
		rts
;--------------------------------------------------------
; setmode liefert bei nicht BLOW UP-Auflîsungen
; Bit 15=1	, Rest bleibt
		dc.b "XBRA"
		dc.b "BLOW"
old_xbios:dc.l 0
xbios_new:
		move.l a7,a0
		move (a0)+,d0		; sr
		addq.l #4+2,a0		; +ret+formatcode
		btst #$D,d0
		bne	superv
		move.l usp,a0	
superv:
		move (a0),d0		; opcode
		cmp #88,d0		; setmode ?
		beq setmode_new
		cmp #91,d0		; vgetsize?
		beq vgetsize_new
		cmp #5,d0
		beq vsetscreen_new
xbios_cont:
		move.l old_xbios,a0
		jmp (a0)			; der ganze Rest
;--------------------------------------------------------	
setmode_new:
		cmpi #4,actres		; in TC Rand schwarz
		bne no_border_blanking2
		clr.l $ff9800		
no_border_blanking2:
		move 2(a0),d2		; bit15 gelîscht ?
;		bsr ausg
		cmp #-1,d2
		beq sm_query
		tst d2
		bpl new_res			; neue Auflîsungen setzen
no_config:					; alte Auflîsung setzen
		move #0,$ff820a
;		bsr   extsyn_off
if VERSION==PLL_VERSION
		clr pll_on
endif
		move 2(a0),-(sp)	; modecode
		move #88,-(sp)		; #setmode
		bsr xbios_emul
		addq.l #4,sp		
; d0=oldmodecode
		tst actres
		bpl no_bit15
		bset #15,d0			; merke: Auflîsung war nicht BLOW UP
no_bit15:
		bset #14,d0
		move #-1,actres		; keine eigene Auflîsung mehr
		rte
		
sm_query:
		move 2(a0),-(sp)	; modecode
		move #88,-(sp)		; #setmode
		bsr xbios_emul
		addq.l #4,sp		
sm_query1:
		tst actres
		bpl no_bit15_1
		bset #15,d0			; merke: Auflîsung war nicht BLOW UP
no_bit15_1:
		bset #14,d0			; aber BLOW UP ist da
		rte

new_res:
		move d2,d4
		bsr get_table
		bne	no_config		; keine Auflîsung definiert
		btst #7,d4			; ST-Komp ?
		beq sm_config		; ja, ohne uns :-)
		tst monitor_type1(a1)
		bne no_config		; Aber SM124 trotzdem Blowen
sm_config:
; jetzt muss die Hardware von der neuen Auflîsung
; Åberzeugt werden
		move.l a1,actdat
		move d4,d1
		andi #7,d1
		move d1,actplanes
		move 2(a0),-(sp)	; modecode
		move #88,-(sp)		; #setmode
		bsr xbios_emul
		addq.l #4,sp
		move.l actdat,a1
		bsr set_video
		tst actres
		bpl no_bit15_
		bset #15,d0			; merke: Auflîsung war nicht BLOW UP
no_bit15_:
		move actplanes,actres		; neue Auflîsung
;		move.l d0,d2
;		bsr ausg
		rte
;--------------------------------------------------------
vgetsize_new:
;		clr.l d2
;		bsr pieps
		move 2(a0),d2
		bpl vg_1
		bra xbios_cont
vg_1:
		bsr get_table
		bne xbios_cont				; nicht konf.
		move.l slen(a1),d0			; screenlÑnge
		cmpi #4,actres		; in TC Rand schwarz
		bne no_border_blanking1
		clr.l $ff9800		
no_border_blanking1:
		rte
;--------------------------------------------------------
vsetscreen_new:
		if 0
		move.l 2(a0),d2
		bsr ausg
		move.l 6(a0),d2
		bsr ausg
		move.l 10(a0),d2
		bsr ausg
		endif

;		clr.l d2
;		bsr pieps		
		move 10(a0),d0		; 2+4+4
		cmpi #3,d0
		bne vss2	   		; nur erweiterter setscreen

		move 12(a0),d2		; newres
		cmp #-1,d2
		beq vss_query			; Abfrage ?
		move d2,d4
		move d2,actplanes
		bsr get_table
		bne vss1			; ist keine neue Aufl.
		btst #7,d4			; ST-kompatibel ?
		beq vs_config			;   nein !
		tst.b 1+actual_monitor_type
		bne vss1			; aber SM124 trotzdem
vs_config:
		btst #15,d4			; 
		bne vss1			; b16 GESETZT? kein blowen
		move.l a1,actdat
		tst vsetflag
		bne no_malloc
		tst.l 6(a0)
		bne no_malloc
		tst.l 2(a0)
		bne no_malloc

		bsr screen_malloc
		move.l a0,-(sp)
		move 12(a0),-(sp)
		move #3,-(sp)
		move.l screen_mem,-(sp)
		move.l screen_mem,-(sp)
		move #5,-(sp)
		move #$00,$ff820a
		bsr xbios_emul
		lea $e(sp),sp
;		bsr screen_malloc
		move.l screen_mem,$45e
		move.l screen_mem,$44e
		move.l (sp)+,a0
		bra vset_scr_cont1
		
no_malloc:
		move.l a0,-(sp)
		move 12(a0),-(sp)
		move #3,-(sp)
		move.l 6(a0),-(sp)
		move.l 2(a0),-(sp)
vset_scr_cont:
		move #5,-(sp)
		move #$00,$ff820a
		bsr xbios_emul
		lea $e(sp),sp
		move.l (sp)+,a0
vset_scr_cont1:
		move 12(a0),d2
		move actplanes,actres
		btst #14,d2
		beq dont_set_linea
		tas boot
		beq dont_set_linea		; workaround fÅrs Desktop
		bsr set_linea
dont_set_linea:
		bsr set_video
;		clr.l d2
;		bsr pieps
		clr vsetflag
		tas vsetflag1			; Merke: set_video gemacht
		rte
vss1:						; ST komp.
		bsr extsyn_off
if VERSION==PLL_VERSION
		clr pll_on			; PLL ab
endif

		move #-1,actres
vss2:
		bra xbios_cont
vss_query:
		tst boot
		move 12(a0),-(sp)
		move #3,-(sp)
		move.l 6(a0),-(sp)
		move.l 2(a0),-(sp)
		move #5,-(sp)
		bsr xbios_emul
		lea $e(sp),sp
		bra sm_query1
;--------------------------------------------------------
xbios_emul:
		subq.l #4,sp		; und jetzt eine kleine
		move.l 4(sp),2(sp)	; Stackzauberei
		move #$00b8,6(sp)
		move sr,(sp)
		move.l old_xbios,a0
		jmp (a0)			; und das wars		
;--------------------------------------------------------
get_table:
		and.l #7,d2
if DEMO_VERSION
		cmpi #2,d2
		beq gtt1
		cmpi #4,d2
		beq gtt1
		moveq #2,d2
		rts
endif
gtt1:
		movem.l d7/a2,-(sp)
		move.l $4f2,a2
		move.l $24(a2),a2
		move.b (a2),d7		; Kbshift
		move d7,keyb_status
		bra gtt
get_table_vdi:
		if DEMO_VERSION
		cmpi #2,d2
		beq gtt2
		cmpi #4,d2
		beq gtt2
		moveq #2,d2
		rts
endif
gtt2:
		movem.l d7/a2,-(sp)
if 0
		move keyb_status,d7
else
		clr d7
endif
gtt:
		bchg #0,d7
		btst #0,d7			; rechte shifttaste?
		beq get_table_return	; ja->abbruch
		lea res1_2,a1
		btst #3,d7
		beq get_tab_normal
		tst.b 0(a1,d2)
		beq use_tab2
		bra get_tab1_inv
get_tab_normal:
		tst.b 0(a1,d2)
		bne use_tab2		; Bank2 abtesten
get_tab1_inv:
		lsl.l #8,d2
		add.l #tabele,d2
		clr actbank
		bra gt1
use_tab2:
		lsl.l #8,d2
		add.l #tabele2,d2
		move #1,actbank
gt1:
		move.l d2,a1
		tst flag1(a1)		; und gleich testen
		bne get_table_return
		move monitor_type1(a1),d2
		cmpi #1,d2
		beq this_is_tv
		cmpi #3,d2
		beq this_is_tv
		cmp actual_monitor_type,d2
		movem.l (sp)+,d7/a2
		rts
this_is_tv:
		cmpi #1,actual_monitor_type
		beq get_table_return
		cmpi #3,actual_monitor_type
get_table_return:
		movem.l (sp)+,d7/a2
		rts
;--------------------------------------------------------
set_video:
		movem.l d0-d7/a0-a6,-(sp)
if VERSION==PLL_VERSION
		bsr set_pll
endif
		move.l #$ff82a2,a0
		move.l actdat,a1

		add.l #$a2,a1
		clr.w d0
		bra vc_1
vc_2:
		move.w (a1,d0.w*2),(a0)+
		addq #1,d0
vc_1:
		cmp #6,d0
		blt vc_2
		
		move.l actdat,a1
		add.l #$82,a1
		
		movea.l #$ff8282,a0
		clr.w d0
		bra xc_1
xc_2:
		move.w (a1,d0.w*2),(a0)+
		addq #1,d0
xc_1:
		cmp #6,d0
		blt xc_2
					
		move.l actdat,a1	
		move.w $e(a1),$ff820e		; offset
		move.w $10(a1),$ff8210 		; ZeilenlÑnge in W	
		move.w $c0(a1),$ff82c0		; B-)
		move.w $c2(a1),$ff82c2		; Interlace
		
		cmpi #4,actres		; in TC Rand schwarz
		bne no_border_blanking
		move.l #0,$ff9800		
no_border_blanking:	
if (VERSION==SOFT_VERSION)
		cmpi #1,monitor_type
		beq set_for_genlock
		cmpi #3,monitor_type
		bne no_genlock
endif
set_for_genlock:
		move.w $a(a1),$ff820a
no_genlock:
		
if VERSION==XTAL_VERSION
		move.b #%10010110,$fffffc00.w
		tst.w $a(a1)
		beq no_ext_clock_set
		move.b #%11010110,$fffffc00.w
no_ext_clock_set:
endif


		tst critical_flag(a1)
		beq no_slow_down
		
if VERSION==PLL_VERSION		
		tst $a(a1)
		bne pll_critical
endif
		bra hard1_critical
pll_critical:
if VERSION==PLL_VERSION
		tst paddle_version
		beq dann_eben_nicht_2		; ohne paddle ÅberflÅssig
		move #$a6,d0
		move #3,d1				; Hysterese
		bsr paddle_adjust		; mit dem paddle voreinstellen
dann_eben_nicht_2:
		move c_cfrequ(a1),d2
		sub  #1000,d2
		
		 
	  	move d2,c_frequ
		move #2000,l_delta
		move #248,own_vbl_count
wait_loop:
		cmp  #40,l_delta
		bpl  wait_loop		; warten bis Frequenz fast erreicht
		move	#1,l_delta	; Tempolimit fÅr PLL setzen
		move c_cfrequ(a1),c_frequ
								; richtige Frequenz vorgeben; fertig!	
		bra no_slow_down
endif

hard1_critical:
		move $ff8282,d2
		move $ff828c,d4
		move d4,d5
		move d2,d3
		lsr #1,d3
		lsr #1,d5
h1_critical_loop:
		move d3,$ff8282
		move d5,$ff828c
		move #-1,d1
h1_wait_loop:		
		nop
		nop
		nop
		dbra d1,h1_wait_loop
		addq #1,d3
		cmp d2,d3
		bne h1_critical_loop
		move d2,$ff8282
		move d4,$ff828c
no_slow_down:

if VERSION==PLL_VERSION
		move c_cfrequ(a1),c_frequ
		move #200,l_delta
endif
		movem.l (sp)+,d0-d7/a0-a6
		rts
;---------------------------------------------------------
set_linea:
		movem.l d0-d7/a0-a6,-(sp)
;		dc.w $a000
		
		move.l linea,a0
		move.l actdat,a1
		
		move yres(a1),d2
		move d2,-$2b2(a0)		; workout[1] in linea
		addq.w #1,d2
		move  d2,-4(a0)			; Bildschirmhîhe
		
		move xres(a1),d2
		move d2,-$2b4(a0)		; workout[0] in linea
		addq.w #1,d2
		move d2,-$c(a0)			; Bildschirmbreite in Pix.
		
		move bpl(a1),-2(a0)		; Bytes pro Zeile
		move planes(a1),(a0)
		move planes(a1),-$306(a0)	; workout[4] bei vq_extnd
		move bpl(a1),2(a0)		; dito
		
		move xres(a1),d2
		asr #3,d2
		move #100,-$1e6(a0) 		; ex d2 workout[51] in linea
		
		move celwr(a1),d2		; Charakterzeilenbreite
		cmpi #$10,-$2e(a0)
		beq no_div
		lsr #1,d2			; kleiner Zeichensatz
no_div:
		move d2,-$28(a0)
		
		
		move xres(a1),d2
		lsr #3,d2
		move d2,-$2c(a0)		; max Cursor-w
		
		move yres(a1),d2
		ext.l d2
		divu -$2e(a0),d2		; Zeichenhîhe
		move d2,-$2a(a0)		; max curs-h

		clr v_curx
		clr v_cury
		move vscr_rx(a1),_vscr_rx
		move vscr_ry(a1),_vscr_ry
		move xres(a1),_vscr_x
		move yres(a1),_vscr_y
		
		move vscr_flag(a1),vscr_enable
		beq do_disable
		bsr enable_vscr_cookie		; cookie richtig
		bra sla1
do_disable:
		bsr disable_vscr_cookie
sla1:
		move bpl(a1),_bpl
		move col_mode(a1),_col_mode
			
		move.l max_s_c(a1),max_saver_counter
		addi.l #200*2,max_saver_counter
		move sav_act(a1),saver_active
;		bne sl_rts	
;		move.l #-1,max_saver_counter

sl_rts:
		movem.l (sp)+,d0-d7/a0-a6
		rts	
;-------------------------------------------------------
patch_intout:
		move.l pb,a0
		move.l 12(a0),a0
		move.l actdat,a1
		move xres(a1),(a0)
		move yres(a1),2(a0)
		move planes(a1),d2
		move #1,d3
		lsl d2,d3
		bne keine_TC_korr
		move #256,d3
keine_TC_korr:
		move d3,26(a0)
		rts		
;-------------------------------------------------------
; a1:zeiger auf actdat
if VERSION==PLL_VERSION
set_pll:
		movem.l d2,-(sp)
		move.l actdat,a1
		clr pll_on
		tst pll_flag(a1)		; brauchen wir PLL
		beq no_pll				; nein
		move c_cfrequ(a1),d2
;		cmp c_frequ,d2
;		beq no_pll_reset

		tst paddle_version
		beq dann_eben_nicht		; ohne paddle ÅberflÅssig
		move pll_r1(a1),d0
		move #3,d1				; Hysterese
		bsr paddle_adjust		; mit dem paddle noch feiner
		bra kein_reset	
dann_eben_nicht:		
		move pll_res(a1),d2		; schon mal mit pi*Daumen
		bsr reset_pll			; grob vorladen
kein_reset:
		move c_cfrequ(a1),c_frequ	; Sollwert setzen
no_pll_reset:
		clr old_av
		clr pll_lc
		clr pll_lc_flag
		move #200,l_delta
		move #240,own_vbl_count
		move #1,pll_on			; und anschalten und jetzt ganz genau
ex_pll:
		movem.l (sp)+,d2
		rts
no_pll:
	move #60,d2	; ca 32MHz
	bsr reset_pll
	bra ex_pll		
endif
;-------------------------------------------------------
extsyn_off:
		movem.l d2/a0-a1,-(sp)
if VERSION==PLL_VERSION
		clr pll_on
		move #0,c_frequ		
endif
		clr vscr_enable
		tst actres
		bmi ext_ret
		cmpi #1,actual_monitor_type
		blt ext_syn_SM124
		beq ext_syn_TV
		cmpi #2,actual_monitor_type
		bgt ext_syn_TV

		move.w #0,$ff820a

		move #$186,$ff82c0
		move #8,$ff82c2
		cmpi #1,actplanes
		bne el00
		lea reset_tab_VGA2,a1
		bra el0
el00:
		lea reset_tab_VGA1,a1
el0:
		lea $ff82a2,a0
		move #5,d2
el1:
		move (a1)+,(a0)+
		dbra d2,el1
		lea $ff8282,a0
		move #5,d2
el2:
		move (a1)+,(a0)+
		dbra d2,el2

if VERSION==PLL_VERSION
		move #15,d2
		bsr reset_pll
endif

ext_ret:		
		move #0,vscr_enable
		movem.l (sp)+,d2/a0-a1
		rts
ext_syn_SM124:
		move #0,$ff820a
		move #$182,$ff82c0
		move #8,$ff82c2
		lea reset_tab_SM,a1
		bra el0
ext_syn_TV:
		move #0,$ff820a
		move #$182,$ff82c0
		move #6,$ff82c2
		cmpi #1,actplanes
		bne el3
		lea reset_tab_TV2,a1; 4farben	
		bra el0			; vorerst
el3:
		lea reset_tab_TV1,a1; 2/16/256/tc farben
		bra el0	
;-------------------------------------------------------
screen_malloc:
		movem.l d0-d7/a0-a6,-(sp)
		if 1
		move.l 	actdat,a0
		move.l slen(a0),d0
		add.l 	#512,d0	
		move.l 	d0,-(sp)
		move 	#21,-(sp)
		trap 	#1			; gemdos Srealloc
		addq.l 	#6,sp
		endif
;		move.l d0,d2
;		bsr ausg		
;		clr d2
;		bsr pieps
		if 0
		move.l 	actdat,a0
		move.l slen(a0),d0
		add.l 	#512,d0	
		move   #$20,-(sp)		
		move.l 	d0,-(sp)
		move 	#68,-(sp)
		trap 	#1			; gemdos Mxalloc
		addq.l 	#8,sp
		endif
not_zero:
;		move.l d0,screen_mem
		add.l 	#256,d0
		andi.l 	#$ffffff00,d0
		move.l 	d0,screen_mem
		move.l actdat,a0
		move.l d0,real_screen
		movem.l (sp)+,d0-d7/a0-a6
		rts
;--------------------------------------------------------------
screen_free:
		rts
		movem.l d0-d7/a0-a6,-(sp)
		move.l 	screen_mem,d0
		beq 	no_free				; schon benÅtzt
		move.l 	d0,-(sp)
		move.w 	#$49,-(sp)
		trap 	#1					; mfree
		addq.l 	#6,sp
		cmp #-40,d0
		bne no_free
		move #3,d2
;		bsr pieps
no_free:
		move.l #0,screen_mem
		movem.l (sp)+,d0-d7/a0-a6
		rts	
;--------------------------------------------------------------
;--------------------------------------------------------------
; d0: farbe
; d1: 0/1/2/-1: ab/anschalten/lesen
;  -2/-3 fÅr Saver
		ds.b 10			; fÅr Kopierschutz
set_modes:
		cmpi #-2,d1
		beq saver_config
		cmpi #-3,d1
		beq saver_config1
		move.l #res1_2,a2
		move d0,d2
		move d1,d3
		andi.l #7,d2
		lsl.l #8,d2
		move.l d2,d4
		add.l #tabele,d2
		add.l #tabele2,d4
		move.l d2,a0
		move.l d4,a1
		tst d1
		bmi read
		andi #7,d0
		cmp #1,d1
		beq bank1_an
		bgt  bank2_an
		
		cmpi #2,flag1(a0)
		beq sm1
		move #1,flag1(a0)
sm1:
		cmpi #2,flag1(a1)
		beq sm2
		move #1,flag1(a1)
sm2:
		rts
bank1_an:
		cmpi #2,flag1(a0)
		beq sm2
		move.b #0,0(a2,d0)
		move #0,flag1(a0)
		cmpi #2,flag1(a1)
		beq sm2
		move #1,flag1(a1)
		bra sm2
bank2_an:
		cmpi #2,flag1(a1)
		beq sm2
		move.b #1,0(a2,d0)
		move #0,flag1(a1)
		cmpi #2,flag1(a0)
		beq sm2
		move #1,flag1(a0)
		bra sm2
read:
		btst #3,d0
		bne read_bank2
		move flag1(a0),d2
		cmpi #2,d2
		beq rb1		
		andi #7,d0
		move #1,d2
		tst.b 0(a2,d0)
		bne rb1
		move flag1(a0),d2
rb1:
		move xres(a0),d0
		move yres(a0),d1
		move #42,d3
		rts
read_bank2:
		move flag1(a1),d2 
		cmpi #2,d2
		beq rb2
		andi #7,d0
		move #1,d2
		tst.b 0(a2,d0)
		beq rb2
		move flag1(a1),d2
		
rb2:
		move xres(a1),d0
		move yres(a1),d1
		move #42,d3
		rts
;--------------------------------------------------------------	
saver_config:
	move.b saver_active,d0
	move max_saver_counter,d1
	move max_saver_counter+2,d2
	rts	
saver_config1:
	cmpi.l #-1,max_saver_counter	; wenn er gar nicht an ist...
	beq sa_rts
	move.b d0,saver_active		; ab oder an
	tst d0
	beq saver_deactivate		; und bei ab evtl. wieder herstellen
	clr.l saver_counter
sa_rts:
	rts 
;--------------------------------------------------------------	
get_color_mode:
		cmp #4,d2
		bgt m8_16
		blt m1_2
		moveq.l #2,d2
		rts
m8_16:
		cmp #8,d2
		bne m_16
		moveq.l #3,d2
		rts
m_16:
		moveq.l #4,d2
		rts
m1_2:
		cmp #1,d2
		beq m_1
		moveq.l #1,d2
		rts
m_1:
		moveq.l #0,d2
		rts
		
		if 0
pieps:
		movem.l d0-a6,-(sp)
out_loop:
		move.l d2,-(sp)
		move #7,-(sp)
		move #2,-(sp) 
		move #3,-(sp)
		trap #13
		addq.l #6,sp
		move.l (sp)+,d2
		move.l #4000000,d3
loop_wait:
		subq.l #1,d3
		bne loop_wait
		dbra d2,out_loop
		movem.l (sp)+,d0-a6
		rts
ausg:
		movem.l d0-a6,-(sp)
		move #7,d3
		move.l d2,d4
outloop:
		rol.l #4,d4
		move.l d4,d1
		and.l #$f,d1
		add #48,d1
		cmp #$3a,d1
		blt no_add
		addq #7,d1
no_add:
		move d1,-(sp)
		move #2,-(sp)
		trap #1
		addq.l #4,sp
		dbra d3,outloop
		move #10,-(sp)
		move #2,-(sp)
		trap #1
		addq.l #4,sp
		move.l #2000000,d0
waitl:
		subq.l #1,d0
		bne waitl
		movem.l (sp)+,d0-a6
		rts
		endif
text_ausg:
		movem.l d0-a6,-(sp)
		move.l a1,-(sp)
		move #9,-(sp)
		trap #1
		addq.l #6,sp
		if 0
		move.l #500000,d0
waitl1:
		subq.l #1,d0
		bne waitl1
		endif
		movem.l (sp)+,d0-a6
		rts
		
;--------------------------------------------------------------
		data
infovscr:		; fÅr das VSCR-Cookie
ivscr_cookie:
		dc.l	'VSCx'	; EnthÑlt 'VSCR', wenn Struktur gÅltig
ivscr_product:
		dc.l	'BLOW'	; Kennung des Vscreen-Verwalters
ivscr_version:
		dc.w	$100		; Version des Vscreen-Protokolls
ivscr_x:
		dc.w	0	 ; Sichtbarer Ausschnitt des Bildschirms
ivscr_y:
		dc.w	0
ivscr_w:
		dc.w	0
ivscr_h:
		dc.w	0
;--------------------------------------------------------------
		data
vopen:
	dc.b "Open",13,10,0
welcome: 
if FRANCAISE==0
		dc.b	13,10,27,"pBlowUP030 V1.7i for the ATARI Falcon030"
else
		dc.b 27,"pBlowUP030 V1.7a pour ATARI Falcon030"
endif
if VERSION==SOFT_VERSION
		dc.b " SOFT"
else
if VERSION==XTAL_VERSION
		dc.b " HARD 1"
else
		dc.b " HARD 2"
endif
endif
		dc.b    27,"q"
		dc.b	13,10,"(c) by Georg Acher and Michael Eberl"
		dc.b	13,10,0
if FRANCAISE==0
error_msg:
		dc.b    "Install BlowUP030 (Y/n)? ",13,10,0
error_msg1:
		dc.b	7,"The configured resolutions can't run on",13,10,
		dc.b 	"this monitor type! BlowUP030 not installed!",13,10,0
error_msg2:
		dc.b 	"BlowUP030 not installed!",13,10,0
else
error_msg:
		dc.b    "Install BlowUP030 (Y/n)? ",13,10,0
error_msg2:
		dc.b    "BlowUP030 pas install",130," !",13,10,0
error_msg1:
		dc.b	7,"Les fr",130,"quences de ce r",130,"glage ne peuvent pas",13,10,
		dc.b 	"fonctionner sur cet ",130,"cran ! BlowUP030 pas install",130," !",13,10,0
endif

		even
reset_tab_VGA1:
		dc.w $419,$3ff,$3f,$3f,$3ff,$415
		dc.w $c6,$8d,$15,$273,$50,$96
reset_tab_VGA2:
		dc.w $419,$3ff,$3f,$3f,$3ff,$415
		dc.w $17,$12,1,$20e,$d,$11		; 4 Farben
reset_tab_SM:
		dc.w $3e9,$0,$0,$43,$363,$3e7
		dc.w $1a,$0,$0,$20f,$c,$14
reset_tab_TV1:
; HIER MUSS WAS REIN (aber nicht dc.w WAS)
		dc.w $270,$265,$2f,$7e,$20e,$268		
		dc.w $1fe,$199,$40,$4d,$fe,$182

reset_tab_TV2:
		dc.w $270,$265,$2f,$7e,$20e,$268
		dc.w $3e,$38,$8,$2,$20,$34

		bss
old_handle: ds.w 1
old_c_frequ: ds.w 1
pll_on:		ds.w 1
pll_mode:	ds.w 1
pb:			ds.l 1
linea:		ds.l 1
success:	ds.w 1
proglen:	ds.l 1
screen:		ds.l 1
real_screen:	ds.l 1
screen_mem:	ds.l 1
old_screen:	ds.l 1
actdat:		ds.l 1
actres:		ds.w 1
actplanes:	ds.w 1
actbank:	ds.w 1
boot:		ds.w 1
vsetflag:	ds.w 1
vsetflag1:  ds.w 1
actual_monitor_type: ds.w 1
ow_txt:		ds.b 150
saved_820a:	ds.w 1
saved_82c0: ds.w 1
saver_flag: ds.w 1
saved_pll_on: ds.w 1
saved_paddle: ds.w 1
paddle_version: ds.w 1	; 0 keine paddleversion 
eckflag:	ds.w 1
keyb_status: ds.w 1
;---------------------
		ds.l 128
stack:		
		end