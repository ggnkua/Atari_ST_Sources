;----------------------------------------------------------------------------
;File name:	RAMUTIL.S			Revision date:	1999.01.31
;Revised by:	Ulf Ronald Andersson		Revision start:	1999.01.31
;----------------------------------------------------------------------------
Remarks:
;
;This file is DevPac source for a MagiC XFS ramdisk file system.  It was
;inspired mainly by Thomas Binder's ramdisk XFS written in Pure C, and in
;fact was originally created by translating his source to assembler.
;----------------------------------------------------------------------------
	include	RAMDISK.I
;----------------------------------------------------------------------------
M_XFS_NAME	MACRO
	dc.b	'Ramdisk '
	ENDM	;M_XFS_NAME
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
rz:
basepage	=	rz-$100
	gemdos	Mshrink,!,basepage(pc),#(bss_end-base_page)
	bra	main
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
title_mess_s:
	dc.b		CR,LF
	dc.b		"Ramdisk-XFS dated "
	M_DATE
	dc.b		CR,LF
	dc.b		"(c) 1995-1996 by Thomas Binder",CR,LF
	dc.b		"revised 1999 by Ronald Andersson",CR,LF,NUL
abort_mess_head_s:
	dc.b		'Installation failed because...:',CR,LF,NUL
abort_mess_tail_s:
	dc.b		'Nothing was installed at this time.',CR,LF
press_key_to_proceed_s:
	dc.b		'Press any key to proceed...',CR,LF,NUL
no_MagX_cookie_s:
	dc.b		'MagX cookie is missing.',CR,LF,NUL
no_free_drive_s:
	dc.b		'No drive char was free for ramdisk.',CR,LF,NUL
drive_not_free_s:
	dc.b		'Specified drive was not free for ramdisk.',CR,LF,NUL
no_kernel_s:
	dc.b		"kernel structure unavailable !",CR,LF,NUL
kernel_blocks_small_s:
	dc.b		"kernel blocks are too small !",CR,LF,NUL
kernel_refused_install_s:
	dc.b		"kernel refused to install ramdisk !",CR,LF,NUL
B_root_s:
	dc.b		"B:"
root_s:
	dc.b		"\",NUL
U_root_lettername_s:
	dc.b		"U:\"
ramdisk_drive_char:
ramdisk_drive_char_s:
	dc.b		"A",NUL
installed_head_s:
	dc.b		"Installed as U:\",NUL
rename_failed_s:
	dc.b		CR,LF
	dc.b		"Renaming this link as requested failed !"
crlf_s:
	dc.b		CR,LF,NUL
filename:
	iz_beg	128
	dc.b	'\gemsys\magic\xtension'
filename2:
	dc.b	'\'
filename3:
	dc.b	ramdisk.inf,NUL
	iz_end
ramdisk_inf_s:
	dc.b	ramdisk
ext_inf_s:
	dc.b	'.inf',NUL
;
drive_s:	dc.b	'drive',NUL
mountname_s:	dc.b	'mountname',NUL
ramtype_s:	dc.b	'ramtype',NUL
leavefree_s:	dc.b	'leavefree',NUL
_8bit_s:	dc.b	'8bit',NUL
label_s:	dc.b	'label',NUL
stonly_s:	dc.b	'stonly',NUL
altonly_s:	dc.b	'altonly',NUL
storalt_s:	dc.b	'storalt',NUL
altorst_s:	dc.b	'altorst',NUL
true_s:		dc.b	'true',NUL
false_s:	dc.b	'false',NUL
	EVEN
;----------------------------------------------------------------------------
ramdisk_dev:
	iz_beg	sizeof_MX_DEV
	ramdisk_close,ramdisk_read,ramdisk_write,ramdisk_stat,
	ramdisk_seek,ramdisk_datime,ramdisk_ioctl,ramdisk_getc,
	ramdisk_getline,ramdisk_putc
	iz_end
;----------------------------------------------------------------------------
wait_for_key:	dc.w	0				;WORD	wait_for_key;
mountname:	dcb.b	256,0				;char	mountname[256];
ramdisk_drive:	dc.w	-1				;WORD	ramdisk_drive = -1;
starttime:	dc.w	0				;WORD	starttime;
startdate:	dc.w	0				;WORD	startdate;
;
ramdisk_dmd:	dc.l	NULL				;DMD	*ramdisk_dmd;
kernel:		dc.l	NULL				;MX_KERNEL	*kernel;
;
fd:		dcb.b	MAX_FD*sizeof_RAMDISK_FD,NUL	;RAMDISK_FD	fd[MAX_FD];
dhd:		dcb.b	MAX_DHD*sizeof_RAMDISK_DHD,NUL	;RAMDISK_DHD	*dhd[MAX_DHD];
root:		dcb.b	ROOTSIZE*sizeof_DIRENTRY,NUL	;DIRENTRY	root[ROOTSIZE];
root_de:	dcb.b	sizeof_DIRENTRY,NUL		;DIRENTRY	root_de;
;
leave_free:	dc.l	LEAVE_FREE			;LONG	leave_free = LEAVE_FREE;
ram_type:	dc.w	RAM_TYPE			;WORD	ram_type = RAM_TYPE;
eight_bit:	dc.w	0				;WORD	eight_bit;
volume_label:	dcb.b	34,0				;char	volume_label[34];
Pdomain_kern_f:	dc.w	0				;use kernel Pdomain ?
MagiC_4_plus_f:	dc.w	0				;use more kernel functions
;----------------------------------------------------------------------------
main:
	gemdos		Cconws,title_mess_s(pc)
	eval_cookie	#'MagX'
	bpl		have_MagX_cookie
	lea		no_MagX_cookie_s(pc),a0
	moveq		#-1,d0
install_aborted:
	move.l		d0,d3
	move.l		a0,a3
	gemdos		Cconws,abort_mess_head_s(pc)
	gemdos		Cconws,(a3)
	gemdos		Cconws,abort_mess_tail_s(pc)
	gemdos		Cnecin
	gemdos		Pterm,d3
;-------------------------------------
have_MagX_cookie:
	bsr	read_infofile
;-------
;ZunÑchst ein/das Laufwerk fÅr die Ramdisk ermitteln. Leider bietet
;MagiC nicht die Mîglichkeit, ein Filesystem direkt zu mounten; man
;man muû also immer mindestens ein BIOS-Laufwerk belegen, ob man es
;nun braucht, oder nicht.
;-------
	tst	ramdisk_drive
	bgt	.set_specific_drive
	xbios	Supexec,get_and_set_drive(pc)
	move	d0,ramdisk_drive
	bpl.s	.drive_success
	lea	no_free_drive_s(pc),a0
	bra	install_aborted
;
.set_specific_drive:
	xbios	Supexec,set_ramdisk_drive(pc)
	tst.l	d0
	beq.s	.drive_success
	moveq	#-1,d0
	lea	drive_not_free_s(pc),a0
	bra	install_aborted
;
.drive_success:
;-------
;Die Kernelstruktur ermitteln und prÅfen, ob die per int_malloc
;angeforderten SpeicherstÅcke groû genug sind, um einen temporÑren
;Filenamen der Ramdisk aufzunehmen.
;-------
	gemdos	Dcntl,#KER_GETINFO,!,!
	move.l	d0,kernel
	bne.s	have_kernel
	moveq	#E_ERROR,d0
	lea	no_kernel_s(pc),a0
abort_release_drive:
	bsr	abort_ramdisk_drive
	bra	install_aborted
;
have_kernel:
	move.l	d0,a0			;a0 -> kernel
	cmp	#34,mxk_int_msize(a0)
	bge.s	have_ok_blocksize
	moveq	#E_ERROR,d0
	lea	kernel_blocks_small_s(pc),a0
	bra.s	abort_release_drive
;
have_ok_blocksize:
;-------
;Jetzt das XFS mit der Funktion install_xfs aus pc_xfs.h beim
;Kernel anmelden. ZurÅckgeliefert wird der Zeiger auf die
;angepaûte Kernelstruktur, die man fÅr Funktionsaufrufe benutzen
;muû. Die tatsÑchliche Struktur (wie sie schon weiter oben per
;Dcntl ermittelt wurde) findet sich jetzt im Zeiger kernel_p.
;-------
	lea	ramdisk_xfs(pc),a0
	jsr	install_xfs
	move.l	d0,kernel
	bgt	ramdisk_installed
	moveq	#-1,d0
	lea	kernel_refused_install_s(pc),a0
	bra.s	abort_release_drive
;
ramdisk_installed:
;-------
;Die Ramdisk ist jetzt beim Kernel angemeldet und kann danach nicht
;mehr entfernt werden. Sollte also bei dem Versuch, den Namen in
;U:\ zu Ñndern, etwas schiefgehen, muû der Benutzer damit leben.
;-------
	move	ramdisk_drive(pc),d0
	add	#'A',d0
	move.b	d0,ramdisk_drive_char
	cmp.b	#'B',d0
	bne.s	have_u_letter_link
;-------
;FÅr Laufwerk B: muû erst noch der Link in Laufwerk U: angelegt
;werden
;-------
	gemdos	Fsymlink,B_root_s(pc),U_root_lettername_s(pc)
have_u_letter_link:
	gemdos	Cconws,installed_head_s(pc)
	tst.b	mountname
	beq.s	.use_letter_name
	gemdos	Dsetdrv,('U' - 'A')
	gemdos	Dsetpath,root_s(pc)
	gemdos	Frename,!,ramdisk_drive_char_s(pc),mountname(pc)
	tst.l	d0
	bpl.s	.ramdisk_renamed
	move	#1,wait_for_key
	gemdos	Cconws,ramdisk_drive_char_s(pc)
	gemdos	Cconws,rename_failed_s(pc)
	bra.s	.done_mount
;
.ramdisk_renamed:
	gemdos	Cconws,mountname(pc)
	gemdos	Cconws,crlf_s(pc)
	bra.s	.done_mount
;
.use_letter_name:
	gemdos	Cconws,ramdisk_drive_char_s(pc)
	gemdos	Cconws,crlf_s(pc)
.done_mount:
;
;Startzeit und -datum fÅr das Wurzelverzeichnis merken;
;
	gemdos	Tgettime
	move	d0,starttime
	gemdos	Tgetdate
	move	d0,startdate
;
	tst	wait_for_key
	beq.s	.done_waiting
	gemdos	Cconws,press_key_to_proceed_s
	gemdos	Cnecin
.done_waiting:
	gemdos	Ptermres,#(bss_end-base_page),!
;----------------------------------------------------------------------------
stricmp:
.cmp_loop:
	move.b	(a0)+,d0
	cmp.b	#'a',d0
	blo.s	.char_s0_ok
	cmp.b	#'z',d0
	bhi.s	.char_s0_ok
	sub.b	#'a'-'A',d0
.char_s0_ok:
	move.b	(a1)+,d1
	cmp.b	#'a',d1
	blo.s	.char_s1_ok
	cmp.b	#'z',d1
	bhi.s	.char_s1_ok
	sub.b	#'a'-'A',d1
.char_s1_ok:
	cmp.b	d1,d0
	bne.s	.string_diff
	tst.b	d0
	bne.s	.cmp_loop
.s0_eq_s1:
	clr.l	d0
	rts
;
.string_diff:
	bhi.s	.s0_gt_s1
.s0_lt_s1:
	moveq	#-1,d0
	rts
;
.s0_gt_s1:
	moveq	#1,d0
	rts
;----------------------------------------------------------------------------
atol:
	clr.l	d0		;preclear d0
	clr.l	d1		;preclear high bits of d1 (for long addition)
.atol_loop:
	move.b	(a0)+,d1	;d1 = next string char,  potential digit char
	cmp.b	#'9',d1
	bhi.s	.exit
	sub.b	#'0',d1		;d1 = new_digit, or negative for illegal char
	blo.s	.exit		;go exit with d0 = old_value if char illegal
	asl.l	#1,d0		;d0 = old_value * 2
	move.l	d0,d2		;d2 = old_value * 2
	asl.l	#2,d0		;d0 = old_value * 8
	add.l	d2,d0		;d0 = old_value * 10
	add.l	d1,d0		;d0 = old_value * 10 + new_digit
	bra.s	.atol_loop	;loop back to get more digits
;
.exit:
	rts
;----------------------------------------------------------------------------
;read_infofile
;
;Liest die INF-Datei des Ramdisk-XFS und wertet sie aus. UngÅltige
;Zeilen werden gemeldet und nicht beachtet.
;
read_info_file:				;void read_infofile(void)
	SECTION	BSS
rdinf_input:	ds.b	256		;static char	input[256];
prgname:	dc.l	1		;char		*prgname;
rdinf_arg:	dc.l	1		;char		*arg;
rdinf_pos:	dc.l	1		;char		*pos;
rdinf_err:	dc.l	1		;long		err;
rdinf_handle:	dc.w	1		;word		handle
	SECTION	DATA
invalid_line_s:
	dc.b	"Invalid line in INF-file (ignored):",CR,LF,NUL
	SECTION	TEXT
	clr	wait_for_key
;
;Die Datei findet sich entweder im Ordner \gemsys\magic\xtension
;des aktuellen Laufwerks, in dessen Wurzelverzeichnis oder im
;aktuellen Verzeichnis
;
;Versuchen, den Namen des Filesystems Åber den von MagiC angelegte
;Environment-Variable _PNAM zu ermittlen. Geht das nicht, wird der
;Name der INF-Datei auf ramdisk.inf gesetzt und direkt zum ôffnen
;der Datei verzweigt (per unbeliebtem goto...)
;
	move.l	p_env+basepage(pc),a1
	lea	_PNAM_s(pc),a0
	find_env_var
	bmi.s	.done_PNAM
	move.l	d0,a0
	next_value
	bmi.s	.done_PNAM
	move.l	d0,a0
	lea	filename3(pc),a1
	cmp	#'\',(a0)
	seq	d3		;d3 = fullpath_f
	bne.s	.copy_name
	lea	filename(pc),a1
	moveq	#63,d0
.copyloop_1:
	move.b	(a0)+,d0
	beq.s	.add_inf
	cmp.b	#'.',d0
	beq.s	.add_inf
	move.b	d0,(a1)+
	dbra	d2,.copyloop_1
	bra	skip_infofile
;
.add_inf:
	lea	ext_inf_s(pc),a0
.copyloop_2:
	move.b	(a0)+,(a1)+
	bne.s	.copyloop_2
;
;Die Datei îffnen; wenn der Programmname ein absoluter Pfad war,
;wird nur dort gesucht, sonst auch im Wurzelverzeichnis und im
;aktuellen Verzeichnis
;
open_file:
	gemdos	Fopen,filename(pc),#FO_READ
	tst.l	d0
	bpl	scan_info_file
	tst.b	d3
	bne	skip_info_file
	gemdos	Fopen,filename2(pc),#FO_READ
	tst.l	d0
	bpl	scan_info_file
	gemdos	Fopen,filename3(pc),#FO_READ
	tst.l	d0
	bpl	scan_info_file
skip_info_file:
	rts
;
scan_info_file:
	move	d0,rdinf_handle
;Die Datei zeilenweise auslesen und auswerten;
scan_info_loop:
	move	rdinf_handle(pc),d0
	lea	rdinf_input(pc),a0
	bsr	readline
	tst	d0
	bgt.s	.have_line
	gemdos	Fclose,rdinf_handle(pc)
	rts
;-------------------------------------
.have_line:
;Leerzeilen werden komplett ignoriert;
	lea	rdinf_input(pc),a0
	tst.b	(a0)
	beq.s	scan_info_loop
	clr.l	rdinf_arg
scan_line_1:
	move.b	(a0)+,d0
	beq.s	invalid_line
	cmp.b	#'=',(a0)
	bne.s	scan_line_1
	move.l	a0,rdinf_arg			;rdinf_arg -> char after '='
	bra.s	try_valid_line
;
;Jede Zeile muû mindestens ein Gleichheitszeichen enthalten;
;-------------------------------------
;UngÅltige Zeilen werden gemeldet und Åbergangen; auûerdem wird
;ein Flag gesetzt, damit vor Programmende auf einen Tastendruck
;gewartet wird (sonst sind die Meldungen u.U. zu schnell wieder
;weg)
;
invalid_line:
	move.l	rdinf_arg(pc),d0
	beq.s	.done_eqsign
	move.l	d0,a0
	move.b	#'=',(a0)
.done_eqsign:
	gemdos	Cconws,invalid_line_s(pc)
	gemdos	Cconws,rdinf_input(pc)
	gemdos	Cconws,crlf_s(pc)
	move	#1,wait_for_key
	bra	scan_info_loop
;
try_valid_line:
	move.l	rdinf_arg(pc),a0		;a0 -> command arg after '='
	clr.b	-1(a0)				;reterminate command identifier at '='
	tst.b	(a0)				;any char after the '=' ?
	beq.s	invalid_line			;if not, the line is invalid
;
	lea	rdinf_input(pc),a0
	lea	drive_s(pc),a1
	bsr	stricmp			;check for 'drive=' command
	beq	cmd_drive
	lea	rdinf_input(pc),a0
	lea	mountname_s(pc),a1
	bsr	stricmp			;check for 'mountname=' command
	beq	cmd_mountname
	lea	rdinf_input(pc),a0
	lea	ramtype_s(pc),a1
	bsr	stricmp			;check for 'ramtype=' command
	beq	cmd_ramtype
	lea	rdinf_input(pc),a0
	lea	leavefree_s(pc),a1
	bsr	stricmp			;check for 'leavefree=' command
	beq	cmd_leavefree
	lea	rdinf_input(pc),a0
	lea	_8bit_s(pc),a1
	bsr	stricmp			;check for '8bit=' command
	beq	cmd_8bit
	lea	rdinf_input(pc),a0
	lea	label_s(pc),a1
	bsr	stricmp			;check for 'label=' command
	beq	cmd_label
	bra.s	invalid_line		;if none of the above fit, the line is invalid
;----------------------------------------------------------------------------
;Hinter dem Kommando drive= muû ein Laufwerksbuchstabe zwischen
;'A' und 'Z' (jeweils einschlieûlich) auûer 'U' folgen, sonst ist
;die Zeile falsch
;
cmd_drive:
	move.l	rdinf_arg(pc),a0
	clr	d0
	move.b	1(a0),d0		;more than one char in arg ?
	bne	invalid_line		;if so, the line is invalid
	cmp.b	#'a'
	blo.s	.char_ok
	cmp.b	#'z'
	bhi.s	.char_ok
	sub.b	#'a'-'A',d0
.char_ok:
	cmp.b	#'A',d0
	blo	invalid_line
	cmp.b	#'Z',d0
	bhi	invalid_line
	cmp.b	#'U',d0
	beq	invalid_line
	sub.b	#'A',d0			;convert d0 from drive letter to drive code
	move	d0,ramdisk_drive	;store specified ramdisk drive code
	bra	scan_info_loop		;loop back to scan next line
;-------------------------------------
;Der Text hinter mountname= wird ohne weitere PrÅfungen Åbernommen
;
cmd_mountname:
	lea	mountname,a0
	move.l	rdinf_arg(pc),a1
.strcpy_loop:
	move.b	(a1)+,(a0)+
	bne.s	.strcpy_loop
	bra	scan_info_loop		;loop back to scan next line
;-------------------------------------
;Hinter ramtype= dÅrfen stonly, altonly, storalt oder altorst
;folgen, alles andere macht die Zeile ungÅltig
;
cmd_ramtype:
	moveq	#0,d3			;d3 = 0  as prep for ramtype stonly
	lea	rdinf_arg(pc),a0
	lea	stonly_s(pc),a1
	bsr	stricmp			;check for 'stonly'
	beq.s	.have_ramtype
	moveq	#1,d3			;d3 = 1  as prep for ramtype altonly
	lea	rdinf_arg(pc),a0
	lea	altonly_s(pc),a1
	bsr	stricmp			;check for 'altonly'
	beq.s	.have_ramtype
	moveq	#2,d3			;d3 = 2  as prep for ramtype storalt
	lea	rdinf_arg(pc),a0
	lea	storalt_s(pc),a1
	bsr	stricmp			;check for 'storalt'
	beq.s	.have_ramtype
	moveq	#3,d3			;d3 = 3  as prep for ramtype altorst
	lea	rdinf_arg(pc),a0
	lea	altorst_s(pc),a1
	bsr	stricmp			;check for 'altorst'
	bne	invalid_line
.have_ramtype:
	move	d3,ram_type
	bra	scan_info_loop
;-------------------------------------
;Der Inhalt der Zeile hinter leavefree= wird in eine Zahl gewandelt
;und mit 1024 multipliziert. Weitere öberprÅfungen finden nicht statt.
;
cmd_leavefree:
	lea	rdinf_arg(pc),a0
	bsr	atol
	asl.l	#8,d0
	asl.l	#2,d0
	move.l	d0,leave_free
	bra	scan_info_loop
;-------------------------------------
;Hinter 8bit= muû entweder "true" oder "false" folgen;
;
cmd_8bit:
	moveq	#1,d3			;d3 = 1  as prep for 8bit=true
	lea	rdinf_arg(pc),a0
	lea	true_s(pc),a1
	bsr	stricmp			;check for 'true'
	beq.s	.have_8bit
	moveq	#0,d3			;d3 = 0  as prep for 8bit=false
	lea	rdinf_arg(pc),a0
	lea	false_s(pc),a1
	bsr	stricmp			;check for 'false'
	bne	invalid_line
.have_8bit:
	move	d3,eight_bit
	bra	scan_info_loop
;-------------------------------------
;Die ersten 32 Zeichen hinter label= werden direkt Åbernommen
;
cmd_label:
	lea	volume_label(pc),a0
	move.l	rdinf_arg(pc),a1
	moveq	#32-1,d0
.strncpy_loop:
	move.b	(a1)+,(a0)+
	dbeq	d0,.strncpy_loop
	clr.b	(a0)			;ensure string termination
	bra	scan_info_loop
;----------------------------------------------------------------------------
;readline
;
;Liest eine Zeile aus einer GEMDOS-Datei ein,
;die wahlweise mit CRLF oder nur LF enden darf.
;Beginnt sie mit einem '#', wird gleich die
;nÑchste Zeile eingelesen.
;
;Eingabe:
;handle: Zu benutzendes GEMDOS-Handle
;buffer: Zeiger auf 255 Byte groûen Zeilenpuffer
;
;RÅckgabe:
;0: Fehler beim Lesen (oder: Zeile zu lang)
;1: Alles OK
;
readline:					;WORD readline(WORD handle, char *buffer)
	lv_init		a6
	lv_var.l	rdline_count
	lv_var.l	rdline_fpos
	lv_var.l	rdline_add
	lv_var.l	rdline_bytes_read
;-------
	movem.l	d3/a4,-(sp)			;push d3/a3
	move	d0,d3				;d3 = handle
	move.l	a0,a3				;a3 = buffer
rdline_loop_1:
	gemdos	Fseek,!,d3,#1			;d0 = current file position
	move.l	d0,rdline_fpos(a6)		;rdline_fpos = current file position (or error code)
	bmi	rdline_error			;on error, go exit with error flag
	gemdos	Fread,d3,#255,(a3)		;try reading 255 bytes of file
	move.l	d0,rdline_bytes_read(a6)	;rdline_bytes_read = amount actually read (or error code)
	ble.s	rdline_error			;on error or EOF, go exit with error flag
	clr.l	rdline_count(a6)		;rdline_count = 0
	move.l	#1,rdline_add(a6)		;rdline_add = 1
rdline_loop_2:
	move.l	rdline_count(a6),d0
	cmp.l	rdline_bytes_read(a6),d0
	bne.s	.have_some_data
        clr.l	rdline_add(a6)
	bra	rdline_break_2
;
.have_some_data:
	cmp.b	#LF,(a3,d0)
	beq.s	rdline_break_2
	cmp.l	#255,d0
	beq	rdline_error
	cmp	#HT,(a3,d0)
	bne.s	.done_HT
	move.b	#' ',(a3,d0)
.done_HT:
	addq.l	#1,rdline_count(a6)
	bra	rdline_loop_2
;
rdline_break_2:
	add.l	rdline_fpos(a6),d0
	add.l	rdline_add(a6),d0		;d0 = rdline_count + rdline_fpos + rdline_add
	gemdos	Fseek,d0,d3,!			;test this file position
	bmi	rdline_error			;on error, go exit with error flag
	move.l	rdline_count(a6),d0
	beq.s	.done_CRLF_check
 	cmp	#CR,-1(a3,d0)			;was last char CR (part of CRLF) ?
 	bne.s	.done_CRLF_check
 	subq.l	#1,d0				;reduce count for string end at CRLF
.done_CRLF_check:
	clr.b	(a3,d0)				;terminate line string
	cmp.b	#'#',(a3)			;does line start with '#'  (comment)
	beq	rdline_loop_1			;if so, loop to scrap it and start over
	moveq	#1,d0				;flag success
rdline_exit
	movem.l	(sp)+,d3/a3			;clean stack
	lv_exit	a6
	rts					;return to caller
;
rdline_error:
	clr.l	d0				;flag error
	bra.s	rdline_exit
;----------------------------------------------------------------------------
;get_and_set_drive
;
;Parameterfunktion fÅr Supexec, die ein freies Laufwerk in _drvbits
;sucht und belegt. Von der Suche ausgenommen sind A, B und U.
;
;RÅckgabe:
;-1: Keine freie Laufwerkskennung mehr vorhanden.
;sonst: Belegte Laufwerksnummer (2 = C, 3 = D, etc.)
;
get_and_set_drive:			;LONG get_and_set_drive(void)
	moveq	#2,d0			;d0 = drive code for 'C:'
	moveq	#('Z'-'B')-1,d2		;d2 = dbra counter
.loop:
	cmp	#'U'-'A',d0		;is this index for 'U:' ?
	beq.s	.next			;if so, then skip to next one
	move.l	(_drvbits).w,d1		;d1 = system drive bitmask
	bset	d0,d1			;test and set indexed bit
	beq.s	.success		;if set from zero, we got it !!!
.next:
	addq	#1,d0
	dbra	d2,.loop
.failure:
	moveq	#-1,d0			;use negative code for failure
	rts				;return with error code to caller
;
.success:
	move.l	d1,(_drvbits).w		;store altered system drive bitmask
	rts				;return with drive code to caller
;----------------------------------------------------------------------------
;set_ramdisk_drive		Supexec subroutine
;
;éhnlich wie get_and_set_drive, versucht aber nur, das durch
;ramdisk_drive gebenene Laufwerk in _drvbits zu belegen.
;
;RÅckgabe:
;0L: Das gewÅnschte Laufwerk war schon belegt.
;1L: Alles OK.
;
set_ramdisk_drive:			;LONG set_ramdisk_drive(void)
	move	ramdisk_drive(pc),d0
	move.l	(_drvbits).w,d1		;d1 = system drive bit mask
	bset	d0,d1			;test and set wanted drive bit
	beq.s	.drive_free		;if it was free, go install it
	cmp	#'B'-'A',d0		;is this drive B ?
	bne.s	.drive_busy		;if not, the drive is not free
	cmp	#1,(_nflops)		;are there more than 1 floppy drives
	ble.s	.drive_free		;if not, go use B:, it is really free
.drive_busy:
	clr.l	d0			;d0 = 0 to tell caller of failure
	rts				;return to caller
;
.drive_free:
	move.l	d1,(_drvbits).w		;store new drive bit mask
	moveq	#1,d0			;d0 = 1 to tell caller of success
	rts				;return to caller
;----------------------------------------------------------------------------
abort_ramdisk_drive:
	move	ramdisk_drive(pc),d0	;d0 = aborted drive number
	move.l	(_drvbits).w,d1		;d1 = system drive bit mask
	bclr	d0,d1			;remove the aborted drive bit
	move.l	d1,(_drvbits).w		;store new drive bit mask
	rts				;return to caller
;----------------------------------------------------------------------------
;increase_refcnts
;
;Erhîht den ReferenzzÑhler eines DDs und den "ElternschaftszÑhler"
;aller seiner Vorfahren, wenn er bislang noch nicht referenziert
;wurde.
;
;Eingabe:
;dd: Zeiger auf den zu bearbeitenden RAMDISK_FD
;
increase_refcnts:			;void increase_refcnts(RAMDISK_FD *fd)
	addq.w	#1,fd_refcnt(a0)	;fd->fd_refcnt++;
	cmp	#1,fd_refcnt(a0)	;if (fd->fd_refcnt > 1)
	bgt.s	.exit
.loop:
	move.l	fd_parent(a0),a0	;for (fd = fd->fd_parent; fd != NULL; fd = fd->fd_parent)
	move.l	a0,d0
	beq.s	.break
	addq.w	#1,fd_is_parent(a0)	;fd->fd_is_parent++;
	bra	.loop
;
.break:
.exit:
	rts
;----------------------------------------------------------------------------
;prepare_dir
;
;Initialisiert ein Verzeichnis der Ramdisk. Der Speicher wird
;mit Nullen gelîscht, anschlieûend werden die PseudoeintrÑge "."
;und ".." eingerichtet.
;
;Eingabe:
;dir: Zeiger auf das Verzeichnis
;maxentries: Soviele EintrÑge soll das Verzeichnis haben
;parent: Zeiger auf das Elternverzeichnis, oder ROOT_DE, wenn
;        dir das Wurzelverzeichnis ist.
;
prepare_dir:			;void prepare_dir(DIRENTRY *dir, WORD maxentries, DIRENTRY *parent)
	movem.l	d3/a3/a4,-(sp)			;push some registers
	move.l	d0,d3				;d3 = WORD maxentries
	move.l	a0,a3				;a3 = DIRENTRY *dir
	move.l	a1,a4				;a4 = DIRENTRY *parent
;
	move.l	#sizeof_DIRENTRY*maxentries,a1
	add.l	a0,a1
	move.l	kernel,a2
	move.l	mxk_fast_clrmem(a2),a2
	jsr	(a2)				;(kernel->fast_clrmem)(dir, &dir[maxentries]);
;
	lea	de_fname(a3),a0			;\
	move.b	#'.',(a0)+			; > strcpy(dir[0].de_fname, ".");
	clr.b	(a0)				;/
;
	move.l	a3,de_faddr(a3)				;dir[0].de_faddr = (char *)dir;
	clr	de_nr(a3)				;dir[0].de_nr = 0;
	move	d3,de_maxnr(a3)				;dir[0].de_maxnr = maxentries;
	move	#S_IFDIR|$1FF,XATTR_mode+de_xattr(a3)	;dir[0].de_xattr.mode = S_IFDIR | 0777;
	move.l	a3,XATTR_index+de_xattr(a3)		;dir[0].de_xattr.index = (LONG)dir;
	move	ramdisk_drive,XATTR_dev+de_xattr(a3)	;dir[0].de_xattr.dev = ramdisk_drive;
	move	ramdisk_drive,XATTR_rdev+de_xattr(a3)	;dir[0].de_xattr.rdev = ramdisk_drive;
	move	#1,XATTR_nlink+de_xattr(a3)		;dir[0].de_xattr.nlink = 1;
	clr	XATTR_uid+de_xattr(a3)			;dir[0].de_xattr.uid = 0;
	clr	XATTR_gid+de_xattr(a3)			;dir[0].de_xattr.gid = 0;
	clr.l	XATTR_size+de_xattr(a3)			;dir[0].de_xattr.size = 0L;
;
	cmp.l	#ROOT_DE,a4
	beq.s	.parent_is_ROOT_DE_1			;if (parent != ROOT_DE)
	move.l	#1,XATTR_nblocks+de_xattr(a3)		;	dir[0].de_xattr.nblocks = 1L;
	bra.s	.done_nblocks
;
.parent_is_ROOT_DE_1:					;else
	clr.l	XATTR_nblocks+de_xattr(a3)		;	dir[0].de_xattr.nblocks = 0L;
;
	gemdos	Tgettime
	move	d0,d3					;d3 = Tgettime()
	gemdos	Tgetdate				;d0 = Tgetdate()
;
	move	d3,XATTR_mtime+de_xattr(a3)		;dir[0].de_xattr.mtime = Tgettime();
	move	d0,XATTR_mdate+de_xattr(a3)		;dir[0].de_xattr.mdate = Tgetdate();
	move	d3,XATTR_atime+de_xattr(a3)		;dir[0].de_xattr.atime = Tgettime();
	move	d0,XATTR_adate+de_xattr(a3)		;dir[0].de_xattr.adate = Tgetdate();
	move	d3,XATTR_ctime+de_xattr(a3)		;dir[0].de_xattr.ctime = Tgettime();
	move	d0,XATTR_cdate+de_xattr(a3)		;dir[0].de_xattr.cdate = Tgetdate();
;
	move	#FA_DIR,XATTR_attr+de_xattr(a3)		;dir[0].de_xattr.attr = FA_DIR;
	clr	XATTR_res2+de_xattr(a3)			;dir[0].de_xattr.reserved2 = 0;
	clr.l	XATTR_res3+de_xattr(a3)			;dir[0].de_xattr.reserved3[0] = 0L;
	clr.l	XATTR_res3+4+de_xattr(a3)		;dir[0].de_xattr.reserved3[1] = 0L;
;
	lea	sizeof_DIRENTRY(a3),a3			;from this point a3 -> second dir entry
;
	lea	de_fname(a3),a0			;\
	move.b	#'.',(a0)+			; \/ strcpy(dir[1].de_fname, "..");
	move.b	#'.',(a0)+			; /\
	clr.b	(a0)				;/
;
	cmp.l	#ROOT_DE,a4
	beq.s	.parent_is_ROOT_DE_2			;if (parent != ROOT_DE)
	gemdos	Tgettime
	move	d0,XATTR_mtime+de_xattr(a4)
	move	d0,XATTR_atime+de_xattr(a4)		;	parent[0].de_xattr.atime = parent[0].de_xattr.mtime = Tgettime();
	gemdos	Tgetdate
	move	d0,XATTR_mdate+de_xattr(a4)
	move	d0,XATTR_adate+de_xattr(a4)		;	parent[0].de_xattr.adate = parent[0].de_xattr.mdate = Tgetdate();
	move.l	a4,de_faddr(a3)				;	dir[1].de_faddr = (char *)parent;
	move	#1,de_nr(a3)				;	dir[1].de_nr = 1;
	clr	de_maxnr(a3)				;	dir[1].de_maxnr = 0;
	moveq	#sizeof_XATTR-1,d0
.loop:
	move.b	de_xattr(a4,d0),de_xattr(a3,d0)		;	dir[1].de_xattr = parent[0].de_xattr;
	bra	.exit					;	return;
;
.parent_is_ROOT_DE_2:
	lea	root_de(pc),a0
	move.l	a0,de_faddr(a3)				;dir[1].de_faddr = (char *)&root_de;
	move	#1,de_nr(a3)				;	dir[1].de_nr = 1;
	clr	de_maxnr(a3)				;	dir[1].de_maxnr = 0;
	move	#S_IFDIR|$1FF,XATTR_mode+de_xattr(a3)	;dir[1].de_xattr.mode = S_IFDIR | 0777;
	move.l	a4,XATTR_index+de_xattr(a3)		;dir[1].de_xattr.index = (LONG)parent;
	move	ramdisk_drive,XATTR_dev+de_xattr(a3)	;dir[1].de_xattr.dev = ramdisk_drive;
	move	ramdisk_drive,XATTR_rdev+de_xattr(a3)	;dir[1].de_xattr.rdev = ramdisk_drive;
	move	#1,XATTR_nlink+de_xattr(a3)		;dir[1].de_xattr.nlink = 1;
	clr	XATTR_uid+de_xattr(a3)			;dir[1].de_xattr.uid = 0;
	clr	XATTR_gid+de_xattr(a3)			;dir[1].de_xattr.gid = 0;
	clr.l	XATTR_size+de_xattr(a3)			;dir[1].de_xattr.size = 0L;
	move.l	#1,XATTR_nblocks+de_xattr(a3)		;dir[1].de_xattr.nblocks = 1L;
;
	gemdos	Tgettime
	move	d0,d3					;d3 = Tgettime()
	gemdos	Tgetdate				;d0 = Tgetdate()
;
	move	d3,XATTR_mtime+de_xattr(a3)		;dir[1].de_xattr.mtime = Tgettime();
	move	d0,XATTR_mdate+de_xattr(a3)		;dir[1].de_xattr.mdate = Tgetdate();
	move	d3,XATTR_atime+de_xattr(a3)		;dir[1].de_xattr.atime = Tgettime();
	move	d0,XATTR_adate+de_xattr(a3)		;dir[1].de_xattr.adate = Tgetdate();
;
	move	starttime(pc),XATTR_ctime+de_xattr(a3)	;dir[1].de_xattr.ctime = Tgettime();
	move	startdate(pc),XATTR_cdate+de_xattr(a3)	;dir[1].de_xattr.cdate = Tgetdate();
;
	move	#FA_DIR,XATTR_attr+de_xattr(a3)		;dir[1].de_xattr.attr = FA_DIR;
	clr	XATTR_res2+de_xattr(a3)			;dir[1].de_xattr.reserved2 = 0;
	clr.l	XATTR_res3+de_xattr(a3)			;dir[1].de_xattr.reserved3[0] = 0L;
	clr.l	XATTR_res3+4+de_xattr(a3)		;dir[1].de_xattr.reserved3[1] = 0L;
.done_parent:
.exit:
	movem.l	(sp)+,d3/a3/a4
	rts
;----------------------------------------------------------------------------
;
;findfile
;
;Funktion zum Suchen einer Datei. Hier muû das Problem angemessen
;berÅcksichtigt werden, daû Programme, die in der TOS-Domain
;laufen, mîglicherweise verstÅmmelte Filenamen liefern, die mit dem
;tatsÑchlichen nur noch sehr wenig gemeinsam haben. Besonders
;unangenehm ist das Ganze mit MagiC 3, da es dort noch kein Pdomain
;gibt. Es lÑût sich daher dort nicht feststellen, ob ein Prozeû
;lange Dateinamen versteht.
;
;Eingabe:
;dd: Zeiger auf den RAMDISK_FD des Verzeichnisses, in dem gesucht
;    werden soll.
;pathname: Name des gesuchten Files/Directories.
;spos: Nummer des Eintrags, ab dem die Suche beginnen soll (0, wenn
;      auch "." und ".." gefunden werden dÅrfen, sonst >= 2).
;s_or_e: Bestimmt, ob pathname fÅr einen Zugriff gesucht wird
;        (FF_SEARCH) oder ob fÅr eine Neuanlage des Names geprÅft
;        werden soll, ob er schon existiert (FF_EXIST). Je nach
;        Modus und aktiver Domain verhÑlt sich die Funktion anders.
;maybe_dir: Legt fest, ob pathname leer sein darf (ungleich Null)
;           oder nicht (0). Wenn ja, und pathname ist tatsÑchlich
;           leer, wird das aktuelle Verzeichnis selbst gefunden.
;           Dies ist dann nîtig, wenn ein Programm beispielsweise
;           Fxattr fÅr "c:\gemsys\" aufruft.
;
;RÅckgabe:
;Zeiger auf den gefundenen Verzeichniseintrag, oder NULL.
;
findfile:	;DIRENTRY *findfile(RAMDISK_FD *dd, char *pathname, WORD spos, WORD s_or_e, WORD maybe_dir)
;entry registers:                               a0        a1             d0         d1           d2
;
	lv_init		a6
	lv_var.w	findfile_i		;WORD		i;
	lv_var.w	findfile_max		;WORD		max;
	lv_var.l	findfile_search		;DIRENTRY	*search;
	lv_var.l	findfile_temp		;char		*temp;
	lv_var.l	findfile_dos		;char		*dos;
;-------
	movem.l	d3-d5/a3-a4,-(sp)
	move.l	a0,a3				;a3 is RAMDISK FD *dd
	move.l	a1,a4				;a4 is char *pathname
	move	d0,d3				;d3 is WORD spos
	move	d1,d4				;d4 is WORD s_or_e
	move	d2,d5				;d5 is WORD maybe_dir
;-------
;Sicherheitscheck fÅr den DD;
;;;
	move.l	fd_file(a3),a0
	is_dir	XATTR_mode+de_xattr(a0)
	bne	.return_NULL			;if (!is_dir(dd->fd_file->de_xattr.mode))  return(NULL);
;Ein leerer Suchname bedeutet u.U. das aktuelle Verzeichnis;
	tst.b	(a4)
	bne.s	.done_empty_test
	tst	d5
	bne	.return_a0			;if (!*pathname && maybe_dir)  return(dd->fd_file);
.done_empty_test:
;
;Das aktuelle Verzeichnis muû Åberschreitbar sein. Dieser Test
;erfolgt absichtlich nach der Abfrage auf leeren Suchnamen, da
;dann ja das Verzeichnis selbst gefunden werden soll, wozu keine
;öberschreitungsrechte vorhanden sein mÅssen.
;
	if (!xaccess(dd->fd_file))
		return(NULL);
;Zweimal Speicher fÅr temporÑre Filenamen anfordern;
	temp = (kernel->int_malloc)();
	dos = (kernel->int_malloc)();
	temp[32] = 0;
	strncpy(temp, pathname, 32L);
	search = (DIRENTRY *)dd->fd_file->de_faddr;
	max = search[0].de_maxnr;
;
;ZunÑchst den Filenamen mit exakten Vergleichen suchen, wenn die
;MiNT-Domain aktiv ist oder der Directoryeintrag fÅr einen Zugriff
;ermittelt werden soll
;
	if ((MagX_Pdomain(-1) == EINVFN) || (MagX_Pdomain(-1) == 1) ||
		(s_or_e == FF_SEARCH))
	{
		for (i = spos; i < max; i++)
		{
			if (search[i].de_faddr == NULL)
				continue;
			if (!strcmp(temp, search[i].de_fname))
			{
				(kernel->int_mfree)(temp);
				(kernel->int_mfree)(dos);
				return(&search[i]);
			}
		}
	}
;
;Wurde so nichts gefunden, muû NULL geliefert werden, wenn der
;Prozeû in der MiNT-Domain lÑuft, oder wenn die Domain nicht
;ermittelt werden kann _und_ nur auf Existenz geprÅft werden soll
;
	if ((MagX_Pdomain(-1) == 1) ||
		((MagX_Pdomain(-1) == EINVFN) && (s_or_e == FF_EXIST)))
	{
		(kernel->int_mfree)(temp);
		(kernel->int_mfree)(dos);
		return(NULL);
	}
;
;Sonst den Filenamen in Kleinbuchstaben wandeln und wieder suchen,
;wenn die TOS-Domain aktiv ist
;
	if (MagX_Pdomain(-1) == 0)
	{
		strlwr(temp);
		for (i = spos; i < max; i++)
		{
			if (search[i].de_faddr == NULL)
				continue;
			if (!strcmp(temp, search[i].de_fname))
			{
				(kernel->int_mfree)(temp);
				(kernel->int_mfree)(dos);
				return(&search[i]);
			}
		}
;
;Wurde immer noch nichts gefunden, ist die Suche erfolglos, wenn
;nur auf Existenz des Namens geprÅft werden soll
;
		if (s_or_e == FF_EXIST)
		{
			(kernel->int_mfree)(temp);
			(kernel->int_mfree)(dos);
			return(NULL);
		}
	}
;
;Jetzt den Suchnamen in's 8+3-Format quetschen und nochmal mit
;TOS-Gleichheit suchen
;
	tostrunc(temp, pathname, 0);
	for (i = spos; i < max; i++)
	{
		if (search[i].de_faddr == NULL)
			continue;
		tostrunc(dos, search[i].de_fname, 0);
		TRACE(("findfile: temp = %S, dos = %S\r\n", 2, temp, dos));
		if (!strcmp(temp, dos))
		{
			(kernel->int_mfree)(temp);
			(kernel->int_mfree)(dos);
			return(&search[i]);
		}
	}
;Es wurde wirklich nichts gefunden;
	(kernel->int_mfree)(temp);
	(kernel->int_mfree)(dos);
.return_NULL:
	clr.l	d0
	bra.s	.exit
;
.return_a0:
	move.l	a0,d0
.exit:
	movem.l	(sp)+,d3-d5/a3-a4
	lv_exit	a6
	rts
;----------------------------------------------------------------------------
;findfd
;
;Sucht einen FD, der entweder frei oder bereits durch einen
;bestimmten Verzeichniseintrag belegt ist.
;
;Eingabe:
;fname: Zeiger auf Verzeichniseintrag, der im zu suchenden FD
;       vorhanden sein soll, oder NULL.
;
;RÅckgabe:
;Zeiger auf den gefundenen FD, oder NULL.
;
RAMDISK_FD *findfd(DIRENTRY *fname)
{
	WORD	i;

;Ist ein Verzeichniseintrag gegeben, zunÑchst schauen, ob einer der
;FDs bereits durch ihn belegt ist. Falls ja, diesen FD liefern.
;
	if (fname != NULL)
	{
		for (i = 0; i < MAX_FD; i++)
		{
			if (fd[i].fd_file == fname)
				return(&fd[i]);
		}
	}
;War fname gleich NULL oder noch nicht vorhanden, wird jetzt ein
;freier FD gesucht, gelîscht und zurÅckgeliefert
;
	for (i = 0; i < MAX_FD; i++)
	{
		if (fd[i].fd_file == NULL)
		{
			(kernel->fast_clrmem)(&fd[i], &fd[i + 1]);
			return(&fd[i]);
		}
	}
;Sollte kein FD mehr frei sein, NULL liefern;
	return(NULL);
;----------------------------------------------------------------------------
;new_file
;
;Erstellt einen neuen Eintrag in einem Verzeichnis an und belegt
;die wichtigsten Felder vor.
;
;Eingabe:
;curr: Zeiger auf den FD des Verzeichnisses, in dem der neue
;      Eintrag angelegt werden soll.
;name: GewÅnschter Name des neuen Files.
;
;RÅckgabe:
;Zeiger auf den neuen Eintrag, oder NULL.
;
DIRENTRY *new_file(RAMDISK_FD *curr, char *name)
{
	DIRENTRY	*dir,
				*new_dir;
	WORD		i,
				max;

;Ist der Filename unzulÑssig, NULL zurÅckliefern;
	if (!check_name(name))
		return(NULL);
	dir = (DIRENTRY *)curr->fd_file->de_faddr;
;
;Zum Anlegen eines Eintrags muû das Verzeichnis Åberschreit- und
;beschreibbar sein
;
	if (!waccess(curr->fd_file) || !xaccess(curr->fd_file))
		return(NULL);
;Einen noch leeren Eintrag suchen;
	max = dir[0].de_maxnr;
	for (i = 2; i < max; i++)
	{
		if (dir[i].de_faddr == NULL)
			break;
	}
	if (i == max)
	{
;
;War kein leerer Eintrag mehr vorhanden, muû das Verzeichnis um
;einen Block erweitert werden. Klappt auch das nicht, liefert die
;Funktion NULL.
;
		new_dir = Krealloc(dir,
			dir[0].de_xattr.nblocks * DEFAULTDIR * sizeof(DIRENTRY),
			(dir[0].de_xattr.nblocks + 1L) * DEFAULTDIR *
			sizeof(DIRENTRY));
		if (new_dir == NULL)
			return(NULL);
		dir = new_dir;
		dir[0].de_maxnr += (WORD)DEFAULTDIR;
		dir[0].de_xattr.nblocks++;
		dir[0].de_faddr = (char *)new_dir;
		dir[0].de_xattr.index = (LONG)new_dir;
		curr->fd_file->de_maxnr = dir[0].de_maxnr;
		curr->fd_file->de_xattr.nblocks = dir[0].de_xattr.nblocks;
		curr->fd_file->de_faddr = (char *)new_dir;
		curr->fd_file->de_xattr.index = (LONG)new_dir;
		;** work_entry fÅr Anpassung von index ***/
	}
;Den neuen Eintrag komplett lîschen und den Namen eintragen;
	(kernel->fast_clrmem)(&dir[i], &dir[i + 1]);
	strncpy(dir[i].de_fname, name, 32L);
	if (MagX_Pdomain(-1) == 0)
	{
;
;In der TOS-Domain den Namen in Kleinbuchstaben wandeln, weil
;solche Prozesse oft Filenamen wie STGUIDE.APP liefern, die auf
;einem casesensitiven Filesystem aber nicht so toll ausehen
;
		TRACE(("new_file: Wandele Filenamen in Lowercase!\r\n", 0));
		strlwr(dir[i].de_fname);
	}
	else
		TRACE(("new_file: Filename nicht gewandelt!\r\n", 0));
;
;Die wichtigsten Felder des Eintrags belegen. Dabei wird das Feld
;de_faddr bewuût noch nicht gefÅllt, der Eintrag bleibt also bis
;zur Belegung durch die aufrufende Funktion frei.
;
	dir[i].de_nr = i;
	dir[i].de_xattr.atime = dir[i].de_xattr.mtime =
		dir[i].de_xattr.ctime = Tgettime();
	dir[i].de_xattr.adate = dir[i].de_xattr.mdate =
		dir[i].de_xattr.cdate = Tgetdate();
	dir[i].de_xattr.dev = ramdisk_drive;
	dir[i].de_xattr.rdev = ramdisk_drive;
	dir[i].de_xattr.nlink = 1;
	dir[i].de_xattr.blksize = DEFAULTFILE;
	return(&dir[i]);
;----------------------------------------------------------------------------
;dir_is_open
;
;PrÅft, ob ein gegebenes Verzeichnis per Dopendir geîffnet ist.
;
;Eingabe:
;dir: Zeiger auf den Verzeichniseintrag des Directories.
;
;RÅckgabe:
;0, wenn das Verzeichnis nicht offen ist, 1 sonst.
;
WORD dir_is_open(DIRENTRY *dir)
{
	WORD	i;

;
;Alle Directory-Handles durchgehen und prÅfen, ob sie das gesuchte
;Verzeichnis reprÑsentieren
;
	for (i = 0; i < MAX_DHD; i++)
	{
		if (dhd[i].dhd_dir == dir)
			return(1);
	}
	return(0);
;----------------------------------------------------------------------------
;check_name
;
;öberprÅft einen Filenamen auf GÅltigkeit. Erlaubt sind auf der
;Ramdisk alle ASCII-Zeichen von 32 bis 127/255 (mit Ausnahme des
;Backslash). Die Obergrenze richtet sich dabei nach dem Wert von
;eight_bit.
;
;Eingabe:
;name: Zu prÅfender Filename.
;
;RÅckgabe:
;0, wenn der Name ungÅltig ist, 1 sonst.
;
WORD check_name(char *name)
{
	WORD	i,
			max,
			check;

;Leere Namen sind auch nicht zulÑssig;
	if (!*name)
		return(0);
	max = eight_bit ? 255 : 127;
	for (i = 0; i < strlen(name); i++)
	{
		check = (WORD)name[i] & 0xff;
		if ((check < 32) || (check > max) ||
			(name[i] == '\\'))
		{
			return(0);
		}
	}
	return(1);
;----------------------------------------------------------------------------
;check_dd
;
;PrÅft einen Directory-Deskriptor auf GÅltigkeit. Zwar sollte man
;sich darauf verlassen kînnen, daû der Kernel den Funktionen eines
;XFS nur korrekte DDs liefert, aber schlieûtlich ist Vorsicht die
;Mutter der Porzellankiste...
;
;Eingabe:
;dd: Zu prÅfender DD.
;
;RÅckgabe:
;E_OK: DD ist nicht erkennbar falsch.
;EDRIVE: DD gehîrt nicht dem Ramdisk-XFS.
;EPTHNF: DD ist in Wirklichkeit ein FD, reprÑsentiert also kein
;        Verzeichnis.
;
LONG check_dd(RAMDISK_FD *dd)
{
	if (dd->fd_dmd != ramdisk_dmd)
		return(EDRIVE);
	if (!is_dir(dd->fd_file->de_xattr.mode))
		return(EPTHNF);
	return(E_OK);
;----------------------------------------------------------------------------
;check_fd
;
;Wie check_dd, nur fÅr Filedeskriptoren.
;
;Eingabe:
;fd: Zu ÅberprÅfender FD.
;
;RÅckgabe:
;E_OK: FD ist nicht erkennbar falsch.
;EDRIVE: FD gehîrt nicht dem Ramdisk-XFS.
;EFILNF: FD reprÑsentiert keine Datei.
;
LONG check_fd(RAMDISK_FD *fd)
{
	if (fd->fd_dmd != ramdisk_dmd)
		return(EDRIVE);
	if (!is_file(fd->fd_file->de_xattr.mode))
		return(EFILNF);
	return(E_OK);
;----------------------------------------------------------------------------
;work_entry
;
;Hilfsfunktion, die fÅr einen bestimmten Directoryeintrag eine
;gegebene Aktion durchfÅhrt und dabei darauf achtet, daû alle
;ReprÑsentanten dieses Eintrags (also auch die PseudoeintrÑge
;"." des gleichen und ".." der untergeordneten Verzeichnisse)
;mit angepaût werden. Damit lassen sich alle Funktionen, die sich
;auf VerzeichniseintrÑge beziehen, realisieren, ohne sich um die
;genannten Details kÅmmern zu mÅssen.
;
;Eingabe:
;dd: Zeiger auf den DD, in dessen Verzeichnis sich der zu Ñndernde
;    Eintrag befindet.
;name: Name des Eintrags.
;symlink: Zeiger auf Stringzeiger, hier wird ggf. ein Zeiger auf
;         das Ziel eines symbolischen Links eingetragen. Ist
;         symlink NULL, werden keine symbolischen Links verfolgt.
;writeflag: Wenn ungleich Null, wird der Eintrag durch die
;           Aktionsfunktion eventuell verÑndert. Dann, und nur
;           dann, werden auch die anderen ReprÑsentanten
;           bearbeitet.
;par1: Erster Parameter, den action erhalten soll.
;par2: Zweiter Parameter fÅr action.
;action: Zeiger auf die Aktionsfunktion, die als Parameter den
;        Zeiger auf den zu bearbeitenden Eintrag und par1/par2
;        bekommt. ZurÅckliefern muû die Funktionen einen GEMDOS-
;        Returncode. Ist action ein Nullzeiger, muû name ein
;        symbolischer Link sein, sonst liefert work_entry sofort
;        EINVFN.
;
;RÅckgabe:
;GEMDOS-Fehlercode, der meist der Returncode von action ist.
;
LONG work_entry(RAMDISK_FD *dd, char *name, char **symlink,
	WORD writeflag, LONG par1, LONG par2,
	LONG (*action)(DIRENTRY *entry, LONG par1, LONG par2))
{
	DIRENTRY	*found,
				*help;
	LONG		retcode;
	WORD		i,
				max;
	XATTR		new;

;DD ÅberprÅfen;
	if (check_dd(dd) < 0)
	{
		if (action == NULL)
			return(EINVFN);
		else
			return(check_dd(dd));
	}
;Eintrag suchen;
	if ((found = findfile(dd, name, 0, FF_SEARCH, 1)) == NULL)
	{
		if (action == NULL)
			return(EINVFN);
		else
			return(EFILNF);
	}
;Test auf symbolischen Link;
	if (is_link(found->de_xattr.mode) && (symlink != NULL))
	{
		TRACE(("work_entry: Folge symbolischem Link auf %S!\r\n", 1,
			&found->de_faddr[2]));
		*symlink = found->de_faddr;
		return(ELINK);
	}
	if (action == NULL)
		return(EINVFN);
;
;Sollen énderungen vorgenommen werden, obwohl sich name nicht auf
;das gleiche Verzeichnis bezieht, das auch der DD reprÑsentiert,
;mÅssen Schreibrechte vorhanden sein
;
	if (writeflag && (dd->fd_file->de_faddr != found->de_faddr) &&
		!waccess(dd->fd_file))
	{
		return(EACCDN);
	}
;
;action aufrufen und den Returncode liefern, falls es ein Fehler
;war, oder wenn keine énderungen an Eintrag vorgesehen sind
;
	retcode = (action)(found, par1, par2);
	if ((retcode < 0L) || !writeflag)
		return(retcode);
;
;Ist der Eintrag kein Verzeichnis, gibt es auch keine weiteren
;EintrÑge, die ihn ebenfalls reprÑsentieren und mitgeÑndert werden
;mÅûten
;
	if (!is_dir(found->de_xattr.mode))
		return(retcode);
;Sonst den neuen Inhalt des Eintrags zwischenspeichern;
	new = found->de_xattr;
;Den Ursprungseintrag des Verzeichnisses ermitteln;
	if (!strcmp(found->de_fname, "."))
		found = dd->fd_file;
	if (!strcmp(found->de_fname, ".."))
	{
;".." des Wurzelverzeichnisses hat keine weiteren ReprÑsentanten;
		if (dd->fd_parent == NULL)
			return(retcode);
		found = dd->fd_parent->fd_file;
	}
;
;Jetzt den Inhalt an alle nîtigen Positionen kopieren, dabei mÅssen
;auch alle Unterverzeichnisse, soweit vorhanden, berÅcksichtigt
;werden, da hier ".." geÑndert werden muû.
;
	found->de_xattr = new;
	found = (DIRENTRY *)found->de_faddr;
	found->de_xattr = new;
	max = found->de_maxnr;
	for (i = 2; i < max; i++)
	{
		if ((found[i].de_faddr != NULL) &&
			is_dir(found[i].de_xattr.mode))
		{
			help = (DIRENTRY *)found[i].de_faddr;
			help[1].de_xattr = new;
		}
	}
	return(retcode);
;----------------------------------------------------------------------------
;set_amtime
;
;Fungiert als Parameterfunktion fÅr work_entry und setzt die letzte
;Zugriffs- bzw. die letzte énderungszeit auf die aktuellen Werte.
;
;Eingabe:
;entry: Zu bearbeitender Verzeichniseintrag.
;set_amtime: Wenn 0, soll die énderungszeit geÑndert werden, sonst
;            die Zugriffszeit.
;
;RÅckgabe:
;Immer E_OK, weil nichts schieflaufen kann.
;
LONG set_amtime(DIRENTRY *entry, LONG set_atime, LONG unused)
{
	if (set_atime)
	{
		entry->de_xattr.atime = Tgettime();
		entry->de_xattr.adate = Tgetdate();
	}
	else
	{
		entry->de_xattr.mtime = Tgettime();
		entry->de_xattr.mdate = Tgetdate();
	}
	return(E_OK);
;----------------------------------------------------------------------------
;tostrunc
;
;Quetscht einen Ramdisk-Filenamen in das 8+3-Format, und zwar nach
;folgenden Regeln:
;- "." und ".." werden direkt Åbernommen
;- alle unerlaubten Zeichen werden durch "X" ersetzt
;- alle Punkte, auûer dem letzten, werden durch Kommata ersetzt;
;  ist der letzte Punkt auch das letzte Zeichen des Namens, wird
;  er gestrichen, ist er das erste Zeichen des Namens, wird er
;  doch in ein Komma gewandelt
;- alle Zeichen werden in Groûbuchstaben gewandelt
;- die ersten acht Zeichen vor dem letzten Punkt werden Åbernommen
;- die ersten drei Zeichen nach dem letzten Punkt werden Åbernommen
;  (falls es einen letzten Punkt gibt)
;
;Beispiele:
;Langer Dokumentenanme.txt -> LANGERXD.TXT
;name.mit.vielen.punkten -> NAME,MIT.PUN
;.profile -> ,PROFILE
;punkt.am.ende. -> PUNKT,AM
;
;NatÅrlich kînnen so zwei eigentlich verschiedene Dateinamen auf
;den selben TOS-Namen abgebildet werden, was mit nicht angepaûten
;Programmen durchaus Probleme bereiten kann. Der Aufwand, dieses
;Problem absolut sicher zu umgehen, Åbersteigt allerdings meiner
;Meinung nach den mîglichen Nutzen.
;
;Eingabe:
;dest: Zeiger auf den Zielnamen, hier wird also das Ergebnis der
;      Umwandlung abgelegt.
;src: Zeiger auf den Ursprungsnamen.
;wildcards: Wenn ungleich Null, werden ? und * im Ursprungsnamen
;           Åbernommen, sonst durch X ersetzt.
;
void tostrunc(char *dest, char *src, WORD wildcards)
{
	WORD	i;
	char	*lastdot,
			temp[] = "a";

	TRACE(("tostrunc: %S -> %L\r\n", 2, src, dest));
;"." und ".." unverÑndert kopieren;
	if (!strcmp(src, ".") || !strcmp(src, ".."))
	{
		strcpy(dest, src);
		return;
	}
;
;Den letzten Punkt im Namen suchen. Ist er das erste oder letzte
;Zeichen des Namens, wird er "versteckt".
;
	lastdot = strrchr(src, '.');
	if (lastdot != NULL)
	{
		if ((lastdot == src) || !lastdot[1])
			lastdot = NULL;
	}
;
;Den Zielstring vorbereiten und die ersten acht Zeichen vor dem
;letzten Punkt einsetzen
;
	strcpy(dest, "");
	for (i = 0; i < 8; i++)
	{
		if (!*src || (src == lastdot))
			break;
;Punkte als Kommas eintragen;
		if (*src == '.')
			strcat(dest, ",");
		else
		{
;
;Unerlaubte Zeichen als "X" Åbernehmen, alle anderen als
;Groûbuchstaben in den Zielstring einsetzen. "*" und "?" werden
;dabei in AbhÑngigkeit des Parameters wildcard behandelt.
;
			if (strchr("_!@#$%^&()+-=~`;\'\",<>|[]{}", *src) ||
				isalnum(*src) || (wildcards && ((*src == '*') ||
				(*src == '?'))))
			{
				*temp = toupper(*src);
				strcat(dest, temp);
			}
			else
				strcat(dest, "X");
		}
		src++;
	}
;
;Gab es einen letzten Punkt, wird er jetzt samt den ersten drei
;dahinter folgenden Zeichen (gewandelt wie oben) an den Zielstring
;angehÑngt.
;
	if (lastdot)
	{
		strcat(dest, ".");
		src = lastdot;
		src++;
		for (i = 0; i < 3; i++)
		{
			if (!*src)
				break;
			if (strchr("_!@#$%^&()+-=~`;\'\",<>|[]{}", *src) ||
				isalnum(*src) || (wildcards && ((*src == '*') ||
				(*src == '?'))))
			{
				*temp = toupper(*src);
				strcat(dest, temp);
			}
			else
				strcat(dest, "X");
			src++;
;----------------------------------------------------------------------------
;fill_tosname
;
;FÅllt einen von tostrunc gelieferten Namen auf exakt 8+3 Zeichen
;auf; tritt dabei im Namen oder in der Extension ein "*" auf, wird
;der betroffene Teil des Filenamens ab dieser Position mit "?"
;aufgefÅllt (fÅr spÑtere Vergleiche).
;
;Beispiele:
;"PC.PRG" -> "PC      .PRG"
;"FOO.C" -> "FOO     .C  "
;"AUTO" -> "AUTO    .   "
;"*.TXT" -> "????????.TXT"
;"ABC*.?X*" -> "ABC?????.?X?"
;
;Eingabe:
;dest: Zeiger auf Zielstring, der mindestens fÅr 13 Zeichen (inkl.
;      abschlieûendem Nullbyte) Platz bieten muû.
;src: Zeiger auf zu fÅllenden String, der dem von tostrunc
;     gelieferten Format entsprechen muû.
;
void fill_tosname(char *dest, char *src)
{
	WORD	i;
	char	*dot;

	TRACE(("fill_tosname...\r\n", 0));
;"." und ".." werden direkt behandelt;
	if (!strcmp(src, "."))
	{
		strcpy(dest, ".       .   ");
		return;
	}
	if (!strcmp(src, ".."))
	{
		strcpy(dest, "..      .   ");
		return;
	}
;Ansonsten den Zielstring mit einem leeren Namen belegen;
	strcpy(dest, "        .   ");
;
;Alle Zeichen bis zum Punkt werden an den Anfang von dest kopiert
;
	dot = strchr(src, '.');
	for (i = 0; *src && (src != dot); i++)
		dest[i] = *src++;
;
;Alle Zeichen nach dem Punkt (sofern es einen gab) werden hinter
;den Punkt des Zielstrings kopiert
;
	if (dot != NULL)
	{
		src = ++dot;
		for (i = 0; *src; i++)
			dest[9 + i] = *src++;
	}
;
;Jetzt noch in beiden Namensteilen nach einem "*" suchen, wird
;einer gefunden, wird der Rest des Teilnamens mit "?" gefÅllt
;(inklusive der Fundposition)
;
	for (i = 0; i < 8; i++)
	{
		if (dest[i] == '*')
		{
			memset(&dest[i], '?', (LONG)(8 - i));
			break;
		}
	}
	for (i = 9; i < 12; i++)
	{
		if (dest[i] == '*')
		{
			memset(&dest[i], '?', (LONG)(12 - i));
			break;
		}
	}
	TRACE(("fill_tosname liefert: %S\r\n", 1, dest));
;----------------------------------------------------------------------------
;match_tosname
;
;Vergleicht zwei von fill_tosname gelieferte Namen, wobei einer von
;beiden "?" als Wildcards enthalten darf (der andere darf sie auch
;enthalten, hier werden sie aber als normale Zeichen angesehen).
;Diese Funktion stellt den Maskenvergleich fÅr sfirst/snext dar und
;arbeitet zuverlÑssiger als manche GEMDOS-Version (bei denen laut
;Profibuch z.B. "A*.**" auf alle Dateien paût).
;
;Eingabe:
;to_check: Zu ÅberprÅfender Dateiname, im fill_tosname-Format.
;sample: Vergleichsname, ebenfalls im fill_tosname-Format, der "?"
;        als Wildcards enthalten darf.
;
;RÅckgabe:
;0: to_check und sample sind nicht miteinander vereinbar.
;1: to_check paût zu sample.
;
WORD match_tosname(char *to_check, char *sample)
{
	WORD	i;

	TRACE(("match_tosname: %S, %S\r\n", 2, to_check, sample));
;
;Es werden einfach der Reihe nach alle Zeichen der Namen verglichen
;(hier wird der Vorteil des von fill_tosname erzeugten Formats
;deutlich). Ist an der aktuellen Stelle in sample ein "?" zu
;finden, wird nicht verglichen, womit die Wildcardfunktion einfach
;erfÅllt ist. Beim ersten fehlgeschlagenen Vergleich wird die
;Funktion vorzeitig verlassen.
;
	for (i = 0; i < 12; i++)
	{
		if (sample[i] != '?')
			if (sample[i] != to_check[i])
			{
				TRACE(("Warnix\r\n", 0));
				return(0);
			}
	}
	TRACE(("Alles klar, paût\r\n", 0));
	return(1);
;----------------------------------------------------------------------------
;xext enthÑlt die Filenamensendungen (verkehrt herum), bei denen
;beim Anlegen in der TOS-Domain automatisch das x-Flag fÅr
;"AusfÅhrbar" gesetzt wird
;
static char	*xext[] = {"sot.", "ptt.", "grp.", "ppa.", "ptg.",
	"cca."};
;----------------------------------------------------------------------------
;has_xext
;
;Diese Funktion prÅft, ob ein Filename eine Extension hat, die
;normalerweise ein ausfÅhrbares Programm kennzeichnet. Dieser Test
;schlÑgt immer fehl, wenn gerade die MiNT-Domain aktiv ist, weil
;solche Programme die Flags fÅr "ausfÅhrbar" selbst setzen sollten.
;Die Vergleichsnamen sind oben im Array xext festgelegt.
;
;Eingabe:
;name: Zeiger auf zu ÅberprÅfenden Filenamen.
;
;RÅckgabe:
;0: name hat keine passende Extension bzw. die MiNT-Domain ist
;   aktiv
;1: Die TOS-Domain ist aktiv und name hat eine passende Endung.
;
WORD has_xext(char *name)
{
	char	*temp;
	WORD	i;

	if (MagX_Pdomain(-1) == 1)
		return(0);
	temp = (kernel->int_malloc)();
	temp[32] = 0;
	strncpy(temp, name, 32L);
	strrev(temp);
	for (i = 0; i < (sizeof(xext) / sizeof(char *)); i++)
	{
		if (!strnicmp(temp, xext[i], strlen(xext[i])))
		{
			(kernel->int_mfree)(temp);
			return(1);
		}
	}
	(kernel->int_mfree)(temp);
	return(0);
;----------------------------------------------------------------------------
;Kmalloc
;
;Funktion, die dauerhaften Speicher anfordert, der also nur durch
;ein explizites Kfree (nur ein Makro fÅr _Mfree) wieder freigegeben
;wird. GÑbe es diese Mîglichkeit in MagiC nicht, wÑre ein XFS wie
;dieses nutzlos, weil bei einem Programmende der Teil der Daten,
;der von diesem Programm angelegt wurde, wieder verschwinden wÅrde.
;Der Name ist nicht nur zufÑllig an den der Funktion aus der MiNT-
;Kernelstruktur angelehnt...
;Die Funktion achtet auûerdem darauf, daû der grîûte freie
;Speicherblock die in leave_free festgelegte Mindestgrîûe nicht
;unterschreitet und fordert immer den durch ram_type festgelegten
;Speichertyp an. Wenn mîglich, wird der neue Block am Ende des
;zur Zeit grîûten freien Blocks alloziert, um die Fragmentierung
;des freien Speichers zu entschÑrfen.
;
;Eingabe:
;len: Wieviele Bytes sollen belegt werden, bei -1L wird die LÑnge
;     des grîûten zusammenhÑngenden Speicherblocks abzÅglich der
;     freizuhaltenden Bytes geliefert (ggf. 0L).
;
;RÅckgabe:
;Zeiger auf den allozierten Speicherblock, oder NULL.
;
void *Kmalloc(LONG len)
{
	LONG	free,
			new_free;
	void	*block,
			*temp;

;LÑnge des grîûen verfÅgbaren Speicherblocks ermitteln;
	free = (LONG)MagX_Mxalloc(-1L, ram_type);
	if (len == -1)
	{
;
;Soll die Zahl der fÅr die Ramdisk noch freien Bytes geliefert
;werden, muû von der gerade ermittelten Zahl noch die Anzahl der
;mindestens freizuhaltenden Bytes abgezogen werden. Ggf. ist das
;Ergebnis Null.
;
		if (free < leave_free)
			return(0L);
		return((void *)(free - leave_free));
	}
;
;Wenn noch soviel Speicher am StÅck frei ist, daû nach Abzug des
;zu allozierenden Speichers immer noch mehr als leave_free Åbrig
;bleibt, wird versucht, den neuen Block am Ende dieses StÅcks zu
;belegen, um eine ÅbermÑûige Fragmentierung zu vermeiden. Vorsicht:
;Sehr stark auf die MagiC-Speicherverwaltung zugeschnitten und
;nicht unbedingt zur Nachahmung empfohlen.
;
	if ((free - leave_free) >= (len + 16))
	{
		temp = MagX_Mxalloc(free - len - 16, ram_type);
		if (temp != NULL)
		{
			block = MagX_Mxalloc(len, 0x4000 | ram_type);
			MagX_Mfree(temp);
			if (block != NULL)
				return(block);
		}
	}
;
;Versuchen, einen Block der gewÅnschten Grîûe anzufordern; klappt
;das nicht, muû NULL geliefert werden
;
	if ((block = MagX_Mxalloc(len, 0x4000 | ram_type)) == NULL)
		return(NULL);
;
;Sonst prÅfen, ob sich die LÑnge des grîûten verfÅgbaren
;Speicherblock geÑndert hat. Falls nicht, kann der Block so als
;Ergebnis geliefert werden. Dabei wird absichtlich nicht geprÅft,
;ob der grîûte verfÅgbare Block noch groû genug ist, da seine LÑnge
;durch unser Mxalloc ohnehin nicht beeinfluût wurde.
;
	new_free = (LONG)MagX_Mxalloc(-1L, ram_type);
	if (new_free == free)
		return(block);
;
;Hat sich die Grîûe jedoch verÑndert, muû der neue Wert noch groû
;genug sein. Falls nicht, wird der Block wieder freigegeben und
;NULL geliefert.
;
	if (new_free < leave_free)
	{
		MagX_Mfree(block);
		return(NULL);
	}
;Ansonsten ist alles OK, der Block ist damit das Ergebnis;
	return(block);
;----------------------------------------------------------------------------
;Krealloc
;
;Funktion, um einen Speicherblock auf eine neue Grîûe zu bringen.
;Dabei bleibt der alte Inhalt intakt (natÅrlich nur bis zum
;Minimum aus alter und neuer LÑnge).
;
;Eingabe:
;ptr: Bisheriger Zeiger auf den Speicherblock.
;old_len: Alte LÑnge des Blocks.
;new_len: Neue LÑnge des Blocks.
 *
;RÅckgabe:
;Entweder Zeiger auf neuen Speicherblock in gewÅnschter Grîûe, oder
;NULL. In letzterem Fall ist der alte Pointer weiterhin gÅltig,
;der Inhalt unverÑndert.
;
void *Krealloc(void *ptr, LONG old_len, LONG new_len)
{
	char *new_ptr;

;
;Versuchen, einen Speicherblock der neuen Grîûe anzufordern;
;notfalls gleich NULL liefern
;
	if ((new_ptr = Kmalloc(new_len)) == NULL)
		return(NULL);
;
;Alle Bytes des alten Blocks, die in den neuen Block passen,
;dorthin kopieren
;
	memcpy(new_ptr, ptr, (old_len < new_len) ? old_len : new_len);
;Bei Bedarf den noch freien Bereich des neuen Blocks lîschen;
	if (new_len > old_len)
	{
		(kernel->fast_clrmem)(&new_ptr[old_len],
			&new_ptr[new_len - 1L]);
	}
;Alten Pointer freigeben;
	MagX_Mfree(ptr);
	return(new_ptr);
;----------------------------------------------------------------------------
;get_cookie
;
;PrÅft, ob ein bestimmter Cookie vorhanden ist
;und liefert, wenn gewÅnscht, dessen Wert.
;
;Eingabe:
;cookie: Zu suchender Cookie (z.B. 'MiNT')
;value: Zeiger auf einen vorzeichenlosen Long,
;       in den der Wert des Cookies geschrieben
;       werden soll. Ist dies nicht gewÅnscht/
;       erforderlich, einen Nullzeiger Åber-
;       geben.
;
;RÅckgabe:
;0: Cookie nicht vorhanden, value unbeeinfluût
;1: Cookie vorhanden, Wert steht in value (wenn
;   value kein Nullpointer ist)
;
WORD get_cookie(ULONG cookie, ULONG *value)
{
    LONG    *jar,
            old_stack;
    
    ;
    ;Den Zeiger auf den Cookie-Jar ermitteln,
    ;dabei ggf. in den Supervisor-Modus
    ;wechseln.
    ;
    if (Super((void *)1L) == 0L)
    {
        old_stack = Super(0L);
        jar = *((LONG **)0x5a0L);
        Super((void *)old_stack);
    }
    else
        jar = *(LONG **)0x5a0;
    
    ;
    ;Ist die "Keksdose" leer, gleich Null zu-
    ;rÅckliefern, da ja gar kein Cookie
    ;vorhanden ist.
    ;
    if (jar == 0L)
        return(0);
    
    ;
    ;Sonst den Cookie-Jar bis zum Ende durch-
    ;suchen und im Erfolgsfall 1 zurÅckliefern.
    ;Falls value kein Nullpointer war, vorher
    ;den Wert des Cookies dort eintragen.
    ;
    while (jar[0])
    {
        if (jar[0] == cookie)
        {
            if (value != 0L)
                *value = jar[1];
            
            return(1);
        }
        
        jar += 2;
    }
    ;
    ;Bis zum Ende gesucht und nichts gefunden,
    ;also 0 zurÅckgeben.
    ;
    return(0);
;----------------------------------------------------------------------------
;End of file:	RAMUTIL.S
;----------------------------------------------------------------------------
