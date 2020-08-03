**********************************************************
**							**
**	Scan-4-Pic - Written by Stuart Coates		**
**							**
**		    Version 1.01			**
**							**
**********************************************************

* some keycodes - a few of these aren't actually used...!

UP	EQU	$480000
DOWN	EQU	$500000
RIGHT	EQU	$4d0000
LEFT	EQU	$4b0000
SHIFT_UP	EQU	$480038
SHIFT_DOWN	EQU	$500032
SHIFT_RIGHT	EQU	$4d0036
SHIFT_LEFT	EQU	$4b0034
RETURN	EQU	$1c000d
ENTER	EQU	$72000d
HELP	EQU	$620000
UNDO	EQU	$610000
ESCAPE	EQU	$01001b
TAB	EQU	$f0009
ALT_S	EQU	$1F0000
ALT_E	EQU	$120000
ALT_C	EQU	$2E0000
ALT_F	EQU	$210000
ALT_N	EQU	$310000
ALT_T	EQU	$140000
ALT_B	EQU	$300000
ALT_L	EQU	$260000
ALT_P	EQU	$190000
ALT_W	EQU	$110000
ALT_Q	EQU	$100000
ALT_H	EQU	$230000
ALT_X	EQU	$2d0000
ALT_G	EQU	$220000
ALT_M	EQU	$320000
ALT_A	EQU	$1E0000
ALT_R	EQU	$130000
CTRL_T	EQU	$140014
CTRL_G	EQU	$220007
CTRL_S	EQU	$1F0013
SPACE	EQU	$390020

	move.l	a7,a5		* do Mshrink()
	move.l	#stack,a7	* to free memory.
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	#0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp
	move.w	#4,-(sp)	* Getrez()
	trap	#14
	addq.l	#2,sp
	move.w	d0,rez
	cmpi.w	#2,d0
	bne.s	colour
	move.l	#amount1+2,a0	* mod for hi-rez
	move.l	#80,(a0)
	move.l	#amount2+2,a0	
	move.l	#80,(a0)
colour
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,ssp
	move.l	#$ffff8240,a0
	move.l	#colours,a1
	move.w	#15,d0
set
	move.w	(a0)+,(a1)+
	dbra	d0,set
	move.l	ssp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
start	
	move.l	#title,a0	* Display title
	bsr	cconws
	move.l	#getname,a0	* Ask user for filename
	bsr	cconws
	move.l	#filename,-(sp)	* get filename
	move	#$0A,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	#filename,a0
	add.w	d0,a0
	addq.l	#2,a0
	clr.b	(a0)
	move.l	#filename+2,a6	* Address of filename in a6.
	move.w	#$2f,-(sp)	* get current dta
	trap	#1
	addq.l	#2,sp
	move.l	d0,old_dta	* store it
	move.l	#new_dta,-(sp)	* set up new dta
	move.w	#$1a,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#0,-(sp)	* do Fsfirst()
	move.l	a6,-(sp)
	move.w	#$4e,-(sp)
	trap	#1
	addq.l	#8,sp
	move.l	d0,d7		* store result code
	move.l	old_dta,-(sp)	* restore old dta
	move.w	#$1a,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.w	d7
	beq.s	load_file
	move.l	#file_not_found,a0	* produce error msg
	bsr	cconws
	move.l	#$00020002,-(sp)
	trap	#13
	addq.l	#4,sp
	bra	start
load_file
	move.l	new_dta+26,d7		* Length of file in d7
	addq.l	#1,d7
	move.l	d7,size
	move.l	d7,-(sp)		* Malloc() memory
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	bgt.s	do_load
error	
	move.l	#out_of_memory,a0
	bsr	cconws
	move.l	#$00020002,-(sp)
	trap	#13
	addq.l	#4,sp
	bra	start
do_load
	move.l	d0,buffer		* store allocated RAM	
	move.l	#loading,a0
	bsr	cconws
	move.l	#new_dta+30,a0
	bsr	cconws
	move.w	#0,-(sp)
	move.l	#filename+2,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,handle		*store file handle
	tst	d0
	bpl.s	read_file
Fread_error
	move.l	buffer,-(sp)		* Mfree()
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	#read_error,a0
	bsr	cconws
	move.l	#$00020002,-(sp)
	trap	#13
	addq.l	#4,sp
	bra	start	
read_file
	move.l	buffer,-(sp)		* Fread()
	move.l	size,-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	addq.l	#1,d0	
	cmp.l	size,d0
	bne.s	Fread_error
	move.w	handle,-(sp)		* Fclose()
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	move.w	#3,-(sp)		* Logbase()
	trap	#14
	addq.l	#2,sp
	move.l	d0,logbase	
	move.l	#0,shifted
	move.l	buffer,a5
	move.l	a5,a6
display_loop	
	cmp.l	a6,a5
	blt.s	ok1
	move.l	a5,a6
ok1
	move.l	a5,d1
	add.l	size,d1
	cmp.l	d1,a6
	ble.s	ok2
	bclr.l	#0,d1
	move.l	d1,a6
ok2	move.l	a6,a0
	bsr	display_screen
	move.l	#$00020002,-(sp)	* Bconin()
	trap	#13
	addq.l	#4,sp
	cmpi.l	#UP,d0
	bne.s	not_up
amount1	sub.l	#160,a6
	bra.s	display_loop
not_up	
	cmpi.l	#DOWN,d0
	bne.s	not_down
amount2	add.l	#160,a6
	bra.s	display_loop
not_down
	cmpi.l	#RIGHT,d0
	bne.s	not_right
	subq.l	#2,a6
	bra.s	display_loop
not_right
	cmpi.l	#LEFT,d0
	bne.s	not_left
	addq.l	#2,a6
	bra.s	display_loop
not_left
	cmpi.l	#SHIFT_UP,d0
	bne.s	not_shift_up
	sub.l	#16000,a6
	bra.s	display_loop
not_shift_up	
	cmpi.l	#SHIFT_DOWN,d0
	bne.s	not_shift_down
	add.l	#16000,a6
	bra.s	display_loop
not_shift_down
	cmpi.l	#ALT_B,d0
	bne.s	not_alt_b
	move.l	shifted,d1
	cmpi.l	#0,d1
	beq.s	move_down
	move.l	#0,shifted
	move.l	buffer,a1
	add.l	size,a1
	move.l	a1,a0
	subq.l	#1,a0
	move.l	size,d1
.move_up
	move.b	-(a0),-(a1)
	subq.l	#1,d1
	bne.s	.move_up
	bra.s	done_shift
move_down
	move.l	#1,shifted
	move.l	buffer,a1
	move.l	a1,a0
	addq.l	#1,a0
	move.l	size,d1
.move_down
	move.b	(a0)+,(a1)+
	subq.l	#1,d1
	bne.s	.move_down
done_shift
	bra	display_loop
not_alt_b
	cmpi.l	#ALT_R,d0
	bne.s	not_alt_r
	bsr	restore_colours
	bra	display_loop
not_alt_r
	cmpi.l	#ALT_C,d0
	bne.s	not_alt_c
	move.l	a6,a4
	sub.l	#32,a4
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,ssp
	move.l	#$ffff8240,a0
	move.w	#15,d1
.setcols
	move.w	(a4)+,(a0)+
	dbra	d1,.setcols
	move.l	ssp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
not_alt_c
	cmpi.l	#HELP,d0
	bne.s	not_help
	bsr	restore_colours
	move.l	#help_screen,a0
	bsr	cconws
	move.l	#$00020002,-(sp)	* Bconin()
	trap	#13
	addq.l	#4,sp
	bra	display_loop
not_help	
	cmpi.l	#ALT_S,d0
	bne	not_alt_s
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,ssp
	move.l	#$ffff8240,a0
	move.l	#pal,a1
	move.w	#15,d0
get_curr
	move.w	(a0)+,(a1)+
	dbra	d0,get_curr
	move.l	ssp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	bsr	restore_colours
	move.l	#title,a0
	bsr	cconws
	move.l	#savename,a0
	bsr	cconws
	move.l	#filename,-(sp)	* get filename
	move	#$0A,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	#filename,a0
	add.w	d0,a0
	addq.l	#2,a0
	clr.b	(a0)
	move.w	#0,-(sp)		* Fcreate()
	move.l	#filename+2,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	tst	d0
	bmi	write_error
	move.w	d0,handle
	move.l	a6,a5
	move.l	#rez,-(sp)		* Fwrite()
	move.l	#2,-(sp)		* rez flag
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	cmp.l	#2,d0
	bne.s	write_error
	move.l	#pal,-(sp)		* Fwrite()
	move.l	#32,-(sp)		* Palette
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	cmp.l	#32,d0
	bne.s	write_error
	move.l	a6,-(sp)		* Fwrite()
	move.l	#32000,-(sp)		* Screen image
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	cmp.l	#32000,d0
	bne.s	write_error
	move.w	handle,-(sp)		* Fclose()
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst	d0
	bmi.s	write_error
	bra	display_loop
not_alt_s
	cmpi.l	#ALT_L,d0
	bne.s	not_alt_l
	bsr	restore_colours
	bra	start
not_alt_l
	cmpi.l	#UNDO,d0
	beq.s	quit
	bra	display_loop
	
write_error
	move.l	#write_err,a0
	bsr.s	cconws
	move.l	#$00020002,-(sp)
	trap	#13
	addq.l	#4,sp
	move.w	handle,-(sp)		* Fclose()
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	bra	display_loop
quit
	bsr	restore_colours
	move.l	buffer,-(sp)		* Mfree()
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.w	-(sp)
	trap	#1
cconws
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

display_screen
	movem.l	d0-d7/a1-a6,-(sp)
	move.l	logbase,a1
	REPT	615
	movem.l	(a0)+,d0-d7/a2-a6
	movem.l	d0-d7/a2-a6,(a1)
	add.l	#52,a1
	ENDR
	movem.l	(a0)+,d0-d4
	movem.l	d0-d4,(a1)
	movem.l	(sp)+,d0-d7/a1-a6
	rts

restore_colours
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,ssp
	move.l	#$ffff8240,a0
	move.l	#colours,a1
	move.w	#15,d0
.restore
	move.w	(a1)+,(a0)+
	dbra	d0,.restore
	move.l	ssp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

	section data

title	dc.b	27,"E",27,"p Scan-4-Pic - Written by Stuart Coates ",27,"q",10,10,13,0
getname	dc.b	"Enter filename: ",0
savename
	dc.b	"Save filename: ",0
filename
	dc.b	60
	dc.b	0
	ds.b	80
	
new_dta	ds.b	44
old_dta	ds.l	1

file_not_found
	dc.b	10,10,13,7,"ERROR :- File not found, Press any key.",0
out_of_memory
	dc.b	10,10,13,7,"ERROR :- Not enought memory, Press any key.",0
read_error
	dc.b	10,10,13,7,"ERROR :- Error reading file, Press any key.",0
write_err
	dc.b	10,10,13,7,"ERROR :- Error writing file, Press any key.",0
help_screen
	dc.b	27,"E"
	dc.b	27,"p Scan-4-Pic - Written by Stuart Coates ",27,"q",10,10,13
	dc.b	"Control keys:",10,10,13
	dc.b	"Up/Down Cursors - Scroll Up/Down Line",10,13
	dc.b	"Cursors+Shift   - Scroll Up/Down Block",10,13
	dc.b	"Left/Right      - Move by word",10,13
	dc.b	"ALT C           - Grab Palette",10,13
	dc.b	"ALT R           - Reset Palette",10,13
	dc.b	"ALT B           - Force Odd Address",10,13
	dc.b	"ALT S           - Save as Degas",10,13
	dc.b	"ALT L           - Load another File",10,13
	dc.b	"UNDO            - Quit",10,10,10,13
	dc.b	"Press any Key...",0



loading
	dc.b	10,10,13,"Loading: ",27,"f",0

	even

	ds.l	100
stack	ds.l	1

buffer	ds.l	1

handle	ds.w	1

size	ds.l	1

logbase	ds.l	1

shifted	ds.l	1

colours	ds.w	16
pal	ds.w	16

ssp	ds.l	1

rez	ds.w	1
