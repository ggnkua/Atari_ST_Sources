;----------------------------------------------------------------------------
;File name:	LEDPANEL.SH		Revision date:	1995.06.25
;Creator:	Ulf Ronald Andersson	Creation date:	1995.06.24
;(c)1995 by:	Ulf Ronald Andersson	All rights reserved
;Released as:	FREEWARE		(NB: commercial sales forbidden!)
;----------------------------------------------------------------------------
;
;	LEDPANEL.H - Kontroll-Struktur fr das LED-Panel
;
;	Die folgende C-Struktur dient gleichzeitig als Patch-Area
;	fr die Voreinstellungen und zur Kontrolle des LED-Panels
;	durch externe Programme, etwa ein Accessory oder CPX-Modul.
;	Der 'LEDP'-Cookie enth„lt einen Zeiger auf diese Struktur.
;
LEDP_MAGIC	=	'LEDP'
LEDP_VERSION	=	$0300
LEDP_VERDATE	=	$26041995
LEDP_VARLEN	=	$20
;
	RSRESET
;
lp_magic	rs.l	1
lp_version	rs.w	1
lp_verdate	rs.l	1
lp_varlen	rs.w	1
lp_light	rs.w	1
lp_headsize	=	__RS
lp_active	rs.w	1	;0 => passive  $8001 => active
lp_ledbits	rs.l	1
lp_alldrvs	rs.w	1
lp_delay	rs.w	1
lp_marg_top	rs.w	1
lp_marg_right	rs.w	1
lp_color	rs.w	1
lp_setup	rs.w	1
lp_lines	rs.w	1
lp_dtverb_year	rs.b	1
lp_dtverb_sec	rs.b	1
lp_zero_date	rs.b	1
lp_zero_time	rs.b	1
lp_clock_off	rs.b	1
lp_clock_on	rs.b	1
lp_caps_off	rs.b	1
lp_caps_on	rs.b	1
lp_keymask_caps	rs.b	1
lp_keymask_shft	rs.b	1
lp_fstdrv_hrd	rs.b	1
lp_fstdrv_ram	rs.b	1
lp_lstrect	rs.w	4
lp_lstrect_x	=	lp_lstrect+0
lp_lstrect_y	=	lp_lstrect+2
lp_lstrect_w	=	lp_lstrect+4
lp_lstrect_h	=	lp_lstrect+6
lp_watch	rs.b	14
lp_chrsize	rs.w	2
;	struct
;	{
;		char *pointer; /* Zeiger auf zu berwachendes Byte */
;		char check; /* Default fr zu berprfendes Byte */
;		char last; /* letzter Wert des Bytes */
;		char andmask; /* Und-Maske zum Zurcksetzen */
;		char ormask; /* Oder-Maske zum Zurcksetzen */
;		char restime; /* Zeit zum Zurcksetzen */
;		char counter; /* Z„hler dafr */
;		char bit0; /* Zeichen fr 0-Bit */
;		char bit1; /* Zeichen fr 1-Bit */
;		char bytelft; /* Zeichen links vom Byte */
;		char bytergt; /* Zeichen links vom Byte */
;	}	watch;
;	Offsets (dezimal)
;	-----------------
;
;	0 header			34 dtverb
;		0 magic			36 zero
;		4 version		38 clock
;		6 verdate		40 caps
;		10 varlen		42 keymask
;		12 light		44 fstdrv
;	14 active			46 lstrect
;	16 ledbits			54 watch
;	20 alldrvs				54 pointer
;	22 delay				58 check
;	24 margin				60 andmask
;		24 top				62 resttime
;		26 right			64 bit0
;	28 color				66 bytelft
;	30 setup			68 chrsize
;	32 lines
;
;	Hinweise
;	--------
;
;	magic: XBRA-Kennung des LED-Panels
;	version: Hi-Byte: Version, Lo-Byte: Unterversion
;	varlen: L„nge der zu speichernden Variablen ab Header
;	active:	Bit 0: Anzeige ein/ausschalten,
;			Bit 15: Anzeige auffrischen
;	dtverb: Die "two in one"-Funktion zum Einblenden des
;		Datums anstelle der Zeit wird aktiviert durch L”schen
;		des "date"-Flags und Setzen des "year"-Flags
;	lastrect: Letztes zur Anzeige benutztes Grafik-Rechteck
;	watch: Fr Programmierer zu Debugging-Zwecken,
;			hiermit kann ein Byte berwacht werden
;		pointer: Zeiger auf das Byte, man mu natrlich	global
;			(im Supervisor-Modus) darauf zugreifen k”nnen
;		check: Unbenutzt, man kann den obigen Zeiger darauf
;			zeigen lassen (Zugriff garantiert erlaubt)
;		andmask: Nachdem ein Z„hler abgelaufen ist, wird
;			eine Und-Operation mit dieser Maske durchgefhrt,
;		ormask: zus„tzlich auch noch eine Oder-Operation
;		restime: Startwert fr den Z„hler in VBLs (falls 0,
;			dann wird das Byte nie ver„ndert)
;		bit0/bit1: Zeichen fr 0-Bit und 1-Bit
;		bytelft/bytergt: Zeichen fr Umrahmung des Bytes
;	chrsize: wird ab Version 3.0 vom CPX-Modul gesetzt
;	
;	Vorgehensweise beim Ver„ndern von Parametern:
;
;	1. Header berprfen (magic, version)
;	2. LED-Panel abschalten (active=0)
;	3. nderungen an der Konfiguration vornehmen
;	4. Grafik-Rechteck (lstrect) l”schen
;	5. LED-Panel einschalten und auffrischen (active=0x8001)
;
;----------------------------------------------------------------------------
;End of file:	LEDPANEL.SH
;----------------------------------------------------------------------------
