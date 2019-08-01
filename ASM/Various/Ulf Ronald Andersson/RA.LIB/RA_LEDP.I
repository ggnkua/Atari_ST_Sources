;----------------------------------------------------------------------------
;File name:	LEDPANEL.I			Revision date:	1998.08.30
;Creator:	Ulf Ronald Andersson		Creation date:	1995.06.24
;(c)1995 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE			(commercial sales forbidden!)
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	LEDPANEL_defined
LEDPANEL_defined	set	1
;----------------------------------------------------------------------------
	include	RA_JAR.I
;
;NB: Since this lib uses the RA_JAR lib, you must use the macro call
;	make	JAR_links
;    after you have used the 'find_LEDPANEL' macro. That will expand
;    into all the subroutines from the RA_JAR lib which are needed.
;----------------------------------------------------------------------------
;The following constants and structures define the patch area of LEDPANEL,
;which is accessible through the 'LEDP' cookie.  Macros defined further on
;in this file use these to simplify control of LEDPANEL.  The Macros are:
;
;find_LEDPANEL	areg	=> areg -> LEDP cookie data, or is NULL on failure
;clr_LEDP_act	areg	=> LEDPANEL off, d0 = old state \/ These both need
;set_LEDP_act	areg	=> LEDPANEL on,  d0 = old state /\ areg -> LEDP data
;----------------------------------------------------------------------------
;NB:	Some of the remarks in the structure definitions below were copied
;	from the original docs of the LEDPANEL author.  Thus they should
;	be authoritative. Hope you don't mind language mixing... I don't  ;-)
;----------------------------------------------------------------------------
LEDP_MAGIC	=	'LEDP'
LEDP_VERSION	=	$0300
LEDP_VERDATE	=	$26041995
LEDP_VARLEN	=	$20
;----------------------------------------------------------------------------
;LEDP_WATCH is a substructure inside the main LEDP cookie structure
;
	struct	LEDP_WATCH	;FÅr Programmierer zu Debugging-Zwecken
	void_p	LEDW_pointer	;00;  Zeiger auf zu Åberwachendes Byte
	char check		;04;  Default fÅr zu ÅberprÅfendes Byte
	char last		;05;  letzter Wert des Bytes
	char andmask		;06;  Und-Maske zum ZurÅcksetzen
	char ormask		;07;  Oder-Maske zum ZurÅcksetzen
	char restime		;08;  Zeit zum ZurÅcksetzen
	char counter		;09;  ZÑhler dafÅr
	char bit0		;10;  Zeichen fÅr 0-Bit
	char bit1		;11;  Zeichen fÅr 1-Bit
	char bytelft		;12;  Zeichen links vom Byte
	char bytergt		;13;  Zeichen rechts vom Byte
	d_end	LEDP_WATCH	;14;
;----------------------------------------------------------------------------
;LEDP is the main cookie structure of LEDPANEL.
;
	struct	LEDP
	long	lp_magic	;00; XBRA-Kennung des LED-Panels
	word	lp_version	;04; Hi-Byte: Version, Lo-Byte: Unterversion
	long	lp_verdate	;06;
	word	lp_varlen	;10; LÑnge der zu speichernden Variablen ab Header
	word	lp_light	;12;
	d_alias	lp_headsize	;14;
	d_alias	lp_active	;14; word  $0000 => turn_off  $8001 => turn_on
	byte	lp_act_refresh	;14; Bit 7: Anzeige auffrischen (bit 15 as word)
	byte	lp_act_display	;15; Bit 0: Anzeige ein/ausschalten,
	long	lp_ledbits	;16;
	word	lp_alldrvs	;20;
	word	lp_delay	;22;
	word	lp_marg_top	;24;
	word	lp_marg_right	;26;
	word	lp_color	;28;
	word	lp_setup	;30;
	word	lp_lines	;32;
	word	lp_dtverb	;34;
	d_alias	lp_zero		;36;
	byte	lp_zero_date	;36; Ascii index of '0' for date display
	byte	lp_zero_time	;37; Ascii index of '0' for time display
	d_alias	lp_clock	;38;
	byte	lp_clock_off	;38;
	byte	lp_clock_on	;39;
	byte	lp_caps_off	;40;
	byte	lp_caps_on	;41;
	byte	lp_keymask_caps	;42;
	byte	lp_keymask_shft	;43;
	byte	lp_fstdrv_hrd	;44;
	byte	lp_fstdrv_ram	;45;
	d_alias	lp_lstrect	;46; Letztes zur Anzeige benutztes Grafik-Rechteck
	word	lp_lstrect_x	;46;
	word	lp_lstrect_y	;48;
	word	lp_lstrect_w	;50;
	word	lp_lstrect_h	;52;
	d_s	lp_watch,sizeof_LEDP_WATCH	;54; substructure (see above)
	word	lp_chrsize,2	;68;
	d_end	LEDP		;72;
;----------------------------------------------------------------------------
;	Here are some more remarks by the LEDPANEL author:
;
;	dtverb: Die "two in one"-Funktion zum Einblenden des
;		Datums anstelle der Zeit wird aktiviert durch Lîschen
;		des "date"-Flags und Setzen des "year"-Flags
;	watch: FÅr Programmierer zu Debugging-Zwecken,
;			hiermit kann ein Byte Åberwacht werden
;		pointer: Zeiger auf das Byte, man muû natÅrlich	global
;			(im Supervisor-Modus) darauf zugreifen kînnen
;		check: Unbenutzt, man kann den obigen Zeiger darauf
;			zeigen lassen (Zugriff garantiert erlaubt)
;		andmask: Nachdem ein ZÑhler abgelaufen ist, wird
;			eine Und-Operation mit dieser Maske durchgefÅhrt,
;		ormask: zusÑtzlich auch noch eine Oder-Operation
;		restime: Startwert fÅr den ZÑhler in VBLs (falls 0,
;			dann wird das Byte nie verÑndert)
;		bit0/bit1: Zeichen fÅr 0-Bit und 1-Bit
;		bytelft/bytergt: Zeichen fÅr Umrahmung des Bytes
;	chrsize: wird ab Version 3.0 vom CPX-Modul gesetzt
;	
;	Vorgehensweise beim VerÑndern von Parametern:
;
;	1. Header ÅberprÅfen (magic, version)
;	2. LED-Panel abschalten (active=0)
;	3. énderungen an der Konfiguration vornehmen
;	4. Grafik-Rechteck (lstrect) lîschen
;	5. LED-Panel einschalten und auffrischen (active=0x8001)
;----------------------------------------------------------------------------
;	Macro definitions
;----------------------------------------------------------------------------
find_LEDPANEL	MACRO	areg
	eval_cookie	#LEDP_MAGIC
	bmi.s	.error_\@
	btst	#0,d0
	bne.s	.error_\@
	move.l	d0,\1
	cmp.l	#LEDP_MAGIC,lp_magic(\1)
	beq.s	.exit_\@
.error_\@:
	suba.l	\1,\1
.exit_\@:
	move.l	\1,d0
	ENDM	;find_LEDPANEL
;----------------------------------------------------------------------------
clr_LEDP_act	MACRO	areg
	move.l	\1,d0
	ble.s	.error_\@
	move	lp_active(\1),d0
	move	#$0000,lp_active(a0)
.error_\@:
	ENDM	;set_LEDP_act
;----------------------------------------------------------------------------
set_LEDP_act	MACRO	areg
	move.l	\1,d0
	ble.s	.error_\@
	move	lp_active(\1),d0
	move	#$8001,lp_active(a0)
.error_\@:
	ENDM	;clr_LEDP_act
;----------------------------------------------------------------------------
	endc	;LEDPANEL_defined
;----------------------------------------------------------------------------
;End of file:	LEDPANEL.I
;----------------------------------------------------------------------------
