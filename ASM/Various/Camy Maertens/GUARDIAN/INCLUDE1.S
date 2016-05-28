*----------------- include1.s ----- October 26, 1989
* BLOAD		file loading system
* F_WRITE	file writing system
* OPENFILE/READFILE/WRITEFILE/CLOSEFILE  chiefly used by macros
* M_FREE	relinquish obsolete memory space
* GETLIN	input a string
* PRINTLINE	trap call to print string (now in macro form)
* CURSORON/OFF  MOUSEON/OFF  various system calls
* GETKEY/VTSYNC now completely replaced with macros
* RAWCONIO	read k/board and carry on (basic INKEY$)
* SUPERIN/OUT	supervisor mode
* GETREZ	resolution
* QUIT		proper return to desktop
* QUIT_STAY	stay resident
* BINDEC	binary to decimal
* BINHEX	not checked  Use MURRAY'S routine instead
* BINASCII	not checked
* PRINTN	Janice Murray's universal number routine
* DELAY		use wait macro instead
* RANDOM/	trap call
* INITJOY/RESMOUSE  switch joystick on/off
* INITMOUS/RESMOUS  switch mouse on/off
* SCROL  	Simon Rush's vertical scroll  see macro
* SETPAL	see macro (palette)
* REVEAL/REVEAL_REGS  Camy's revelations
* REVEAL_QUICK  more revealing
* FROMTO/FROM_TWO  Camy's memory transfers (see various macros)
* BLANKEN	used by blank macro to draw a blank box
* DEGAS_LOAD	Camy's file loading, using macros
* SETLOWRES etc  trap calls
* DOSOUND	trap call   see sound macro
* SORT		Camy's bubble sort
* ENABLE_VBI/ DISABLE_VBI  standard routine
* RST_HORIZONTAL_BLANK	   standard routine
* SPECIFY1/  rebuilds a screen at random
 
********************************************************************
* IMPORTANT NOTE. A lot of these routines are now replaced         *
* with MACROS. See macros file. It is virtually unneccesary	   *
* to study how these routines work. Unless you want to modify them.*
* Just use the MACROS instead					   *
* ex: no need to say  lea default,a0   jsr setpal		   *
*     just say        palette default				   *
* Finally, the INCLUDE files don't work without the SHELL,	   *
* and the SHELL doesn't work without the INCLUDE files.		   *
* They are part of the same package: all or nothing.		   *
********************************************************************
* Load routine
* >> see MACROS <<
* IN	filename in A0(L)   
*	file_ptr in A6(L)
* and possibly a  direct load address in A3(L)
* in which case set 'load_address' to 1
* OUT	handle is D0 (L) 
* save any important register before calling.
* virtuall ALL disk operations use macros! See macro list.
* 'load' macro uses bload
* 'read' macro on the other hand, uses routines further on
* see degas_load routine further on as an example..
* Full example in Budgie shell.s

* * * * * * * * EXAMPLES * * * * * * * * * * * * * * * * * 
*	bset 	#0,load_address		flag: precise load address
*	move.l	#jenny,a0		file name on disk	
*	move.l	lady_screen,a3		where to load it in memory
*	sub.l 	#34,a3			deduct palette and res
*	bsr	bload
*	bclr	#0,load_address		all done: clear bit zero
*  >>>>>   ANOTHER better EXAMPLE  using macros <<<<<<<<<<<<<<<
*	reserve	32034
*	move.l	d0,lady_screen 		save start address given by gem
*	open	jenny			file name
*	read	my_palette,34		read 34 bytes in palette loc 
*	read	lady_screen,32000	read 32000 at this address
*	close
* lady_screen dc.l 0
* jenny	    dc.b "jenny.pi1",0
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* whatever follows is now purely irrelevant. 
* Anyone trying to work out what it does would struggle
* So would we.
bload     
	move.l 	a0,a4		save that name
	bsr 	get_size
	tst.w	d0
	bmi 	getsize_error	can't find this file:exit
	bsr	dta		size returned in d3
	move.l	d3,file_size	added 10/89
	btst 	#0,load_address if set: load at specified address
	bne 	bl_1		and no need to reserve memory
	bsr 	mmalloc		reserve memory
bl_1	move.l 	a4,a0		get that name again
	bsr 	f_open_read	open file
	tst.w	d0
	bmi	open_error	if negative:error. Exit
	bsr 	f_read		read that block. If error, Close
	bsr 	f_close		close file in any case
bl_exit 	rts
er_exit   
	bset 	#0,loaderror
	string	< E R R O R >
	move.w	#$222,$ff8240
	rts
getsize_error
	home 
	string	<getsize/press key>
	move.w	#$700,$ff8240
	getkey
	rts		exit bload
open_error
	home
	string	<open E>
	move.w	#$070,$ff8240
	rts		exit bload
read_error string <read error>
	home
	move.w	#$007,$ff8240
	getkey
	rts
close_error string <close error>
	home
	move.w	#$077,$ff8240
	getkey
	rts
gemdos_error
	home
	string	<gemdos error>
	getkey
	rts
	
* GET SIZE of a file
* 	in A0 address of filename (L)
* 	out D3 size of file (L)
* 	D0 error channel (W)
get_size 
	CLR.W 	-(SP)		check for file and get size
	MOVE.L 	A0,-(SP) 	filename
	MOVE.W 	#$4E,-(SP)       
	TRAP 	#1
	ADDQ.L 	#8,SP
	rts
file_size	
	dc.l 0
dta	MOVE.W 	#$2F,-(SP)
	TRAP 	#1      	get Data Transfer Address
	ADDQ.L 	#2,SP
	MOVE.L 	D0,A0    	put addr of DTA into A0
	MOVE.L 	26(A0),D3  	put file size into D3
	MOVE.L 	#1,D0 		26th byte of data
	RTS
mmalloc
	MOVE.L	d3,-(A7)	# of bytes to allocate
	MOVE.W	#$48,-(A7)
	TRAP	#1		
	ADDQ.L	#6,A7
	TST.L	D0		
	BEQ	malloc_error
	BTST	#0,D0		even address?
	BEQ	storemmalloc
	ADDQ.L	#1,D0		make pointer addr even
storemmalloc
	MOVE.L	D0,A3		store start address
	move.l 	d0,(a6)		also in pointer	
	RTS
malloc_error
	string <malloc error>
	getkey
	rts
*----------
* OPEN A FILE TO READ
* 	A0 points to file name
* 	out: handle/error returned in D0 then put in D2
f_open_read 
	MOVE.W 	#0,-(SP)	open file  (#2 if read/write)
	MOVE.L 	A0,-(SP)	filename
	MOVE.W 	#$3D,-(SP)
	TRAP #1
	addq.l 	#8,SP
	MOVE.W 	D0,D2
	MOVE.W 	D0,handle
	RTS
* READ BLOCK sequentially from disk to memory buffer
*    D2 file handle    A3 address of buffer to read to
*    D3 number of bytes to read
f_read	MOVE.L 	A3,-(SP)		read a buffer full at A3
	MOVE.L 	D3,-(SP)		read D3 bytes
	MOVE.W 	handle,-(SP)	handle
	MOVE.W 	#$3F,-(SP)
	TRAP 	#1
	ADD.L 	#12,SP
	tst.l	d0	test length (L)
	bmi	read_error
	rts
* CLOSE FILE with D2 handle
f_close	MOVE.W 	handle,-(SP)
	MOVE.W 	#$3E,-(SP)
	TRAP 	#1
	ADDQ.L 	#4,SP
	tst.w	d0
	bmi	close_error
	rts
	
notfound  DC.B "file not found",10,13,0
	even
handle	DS.W 1
loaderror DC.W 0
load_address DC.W 0


* BSAVE (open, write, then close)
* IN : A0 address of filename (L)  A3 save from this address (L)
* IN : D3 length (number of bytes)

bsave
	BSR 	f_create
	TST.W 	D0
	BMI 	erw_exit     
	BSR 	f_write  		write it
	MOVE.W 	D0,-(SP) 		preserve file status
	BSR 	f_close
	MOVE.W 	(SP)+,D0
	tst.w	d0
	bmi	erw_er
	RTS
erw_exit  
	string	<ERROR. creating file..>
	rts
erw_er	string <write error>	
	rts
*------------
* CREATE a file to write
*	A0 points to file name
*	out: handle/error returned in D0 then put in D2
f_create  
	MOVE.W 	#0,-(SP)   
	MOVE.L 	A0,-(SP)    	filename
	MOVE.W 	#$3c,-(SP)  	3c is actually create a file
	TRAP 	#1
	ADD.L 	#8,SP
	MOVE.W 	D0,D2
	move.w 	d0,handle
	bsr	dta		size returned in d3 added 10/89
	move.l	d3,file_size
	RTS
*----------

* WRITE BLOCK to disk
*    D2 file handle    A3 address of buffer
*    D3 number of bytes to write
f_write	MOVE.L 	A3,-(SP)	buffer to write from 
	MOVE.L 	D3,-(SP)	number of bytes 
	MOVE.W 	handle,-(SP) 	handle
	MOVE.W 	#$40,-(SP)
	TRAP 	#1
	ADD.L 	#12,SP
	RTS
* OPEN existing FILE to READ/WRITE
* IN A0 address of filename
* OUT D0 handle
openfile
open_file
	move.w	#0,-(sp)	0=read  2=read/ write
	move.l	a0,-(sp)	file name
	move.w	#$3d,-(sp)
	trap	#1
	addq.l 	#8,sp
	tst.w d0 		added 11/89 
	bmi open_exit
	bsr	dta		size returned in d3 added 10/89
	move.l	d3,file_size
open_exit
	rts
* calling routine should check for a negative D0 (error) 
* (tst.w d0   bmi error)
*----------

* ALLOCATE MEMORY
* Expect file_ptr in A6
m_malloc
	MOVE.L	F_SIZE(PC),-(A7)	# of bytes to allocate
	MOVE.W	#$48,-(A7)
	TRAP	#1		
	ADDQ.L	#6,A7
	TST.L	D0		
	BEQ	GEMDOS_ERROR
	BTST	#0,D0		even address?
	BEQ	STOREM_MALLOC
	ADDQ.L	#1,D0		make pointer addr even
storem_malloc
	MOVE.L	D0,(A6)		store pointer address
	RTS
f_size	dc.l 0
*-----------------------------------------------
readfile
	move.l	a0,-(sp)		;used by read macro
	move.l	d0,-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	rts
writefile
	move.l	a0,-(sp)		;used by write macro
	move.l	d0,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	rts
closefile
	move.w	handle,-(sp)		;used by close macro
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	rts
*------------
* final version
* >>>>> ex:move.l welcome_ptr,a6: bsr mfree <<<<<
* >>>>> use MACRO instead :  mfree welcome_ptr  <<<<<
mfree
	MOVE.L	a6,-(A7)	
	MOVE.W	#$49,-(A7)
	TRAP	#1		
	ADDQ.L	#6,A7
	TST.L	D0	
	BMI	GEMDOS_ERROR
	RTS
*-----------
* EXPECTS FILE POINTER ADDRESS IN A6	
* >>>>> ex:move.l #welcome_ptr,a6: bsr m_free	 <<<<<
* still occasionally used  7/89
m_free
	MOVE.L	(A6),-(A7)
	MOVE.W	#$49,-(A7)
	TRAP	#1		
	ADDQ.L	#6,A7
	TST.L	D0	
	BMI	GEMDOS_ERROR
	RTS
*-------------
* vertical sync
* >>>>> use 'vsync' macro instead <<<<<  
vtsync	MOVEM.L	D0-D2/A0-A2,-(SP)
	MOVE.W	#37,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVEM.L	(SP)+,D0-D2/A0-A2
	RTS
*----------
* INPUT  returns result in a buffer pointed at by A0
*        and length of input in D0
* prompt has  be printed seeeparately
* calling getlin gives a clean empty buffer for the string
* calling getline lives the previous entry in (ideal for repeats)
* >>> see examples in Final Lap and Speculator (enter name) <<<<
getlin    
clearkeybuff
	move.l	#keybuff+2,a0
	move.w	#15,d0
clkb	move.b	#0,(a0)+
	dbra	d0,clkb
getline
	move.l	#keybuff,A0
	MOVE.L	A0,-(SP)
	MOVE.B	#20,(A0)+		20max in 1st byte
	MOVE.B	#0,(A0)+		blank 2nd byte
	MOVE.W	#$A,-(SP)		call gemdos
	TRAP	#1
	ADDQ.L	#6,SP
	move.l	#keybuff,A0
	MOVE.B	(A0),D0
	ADD.W	D0,A0
	MOVE.W	#0,(A0)
	RTS			no problems so far
* >>>>> to recall name: MOVE.L #keybuff+2,A0  BSR printline <<<<<
keybuff    	DS.B 32 
inbuff   	DS.B 32 
*--------------------
* print a line of text
* now superseded by macros: print, printat, string (all calling this routine)
* in A0: address of string ending with a zero byte
printline 
	movem.l	d0-d3/a0-a3,-(sp)
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts
cursor  DC.B 27,"Y",32,32,0
	EVEN
* * * * * * * *  EXAMPLE  * * * * * * * * * * * * * * * * * 
* 	lea	message,a0
*	bsr	printline
* message dc.b "hello",13,10,0
* or using a macro : print message
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*-----------------
cursoron	
	MOVE.W	#1,-(SP)
	MOVE.W	#21,-(SP)
	TRAP	#14
	ADDQ.L	#4,SP
	RTS
*------------
cursoroff
	MOVEM.L	D0-D3/A0-A3,-(SP)
	CLR.W	-(SP)
	MOVE.W	#21,-(SP)
	TRAP	#14
	MOVEM.L	(SP)+,A0-A3/D0-D3
	RTS
*------------
mouseon	DC.W	$A000		initialize A line
	MOVE.L	4(A0),A1	get address of control array
	MOVE.L	8(A0),A2	get address of intin array
	CLR.W	2(A1)
	MOVE.W	#1,6(A1)
	DC.W 	$A009		line A showmouse routine
	RTS
*------------
mouseoff
	DC.W	$A000		initialize A line 
	DC.W	$A00A       
	RTS
*------------
getkey	move.w	#$07,-(sp)
	trap	#1
	addq.l	#2,sp
	andi.w	#$df,d0		force upper case
	rts		answer in D0.  Swap D0 to get scan code
* use 'getkey' macro instead
*------------
* this one looks up the keyboard buffer but doesn't wait
* same as INKEYS in Basic
* Again, there is a macro to do this.
rawconio
	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	rts
*----------------------------------------------
* other possible way is to read the acia direct.
* as soon as the acia has signalled the 68901 mfp that a key
* has been detected, the resulting mfp interrupt should be acknowledged
* tested 31/10/89  works with all interrupts off (move.w #$2700,sr)
* see macro calle 'acia'
get_acia
.a	clr.b	d0	
	move.b	$fffc02,d0 	fffc02 k/board acia data....
	tst.b	d0		
	beq	.a
	bclr	#6,$fffa11	acknowledge key press interrupt
	rts
* then cmpi.b #$01, d0 ... or whatever key is tested

*----------
* As soon as all unnecessary memory has been given back
* to Gem, we go supervisor.  Ex: jsr superin
superin 
	movem.l	d0-d5/a0-a5,-(sp)
	move.l	#$1,-(sp)  
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.l	-(sp)  		enter supervisor mode
	move.w	#32,-(sp) 
	trap	#1
	addq.l	#6,sp
	move.l	d0,savestk	save old stack pointer
	movem.l	(sp)+,d0-d5/a0-a5
	rts
savestk  	DS.L 1
*----------
* Next routine is activately automatically on exit from shell.
* jsr kwit   is the proper way to exit the shell
superout 
	movem.l	d0-d5/a0-a5,-(sp) 
	move.l	savestk,-(sp) 	exit supervisor
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d0-d5/a0-a5
	rts
*----------
** get screen rez into D0
getrez	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	rts
*----------
* this routine is for Budgie games only
* the shell does a 'jsr kwit' which then comes here
quith	bsr	rst_horizontal_blank  if there was one
quit	bsr	resmouse
	bsr	clearbuf
quits	
	move.l	physbase,$45e	call this exit label if no..
	move.l	#atari_palette,A0	..interrupts were used
	BSR	setpal
	btst	#7,$fffa01	monochrome ?
	beq	qu2
	bsr	setmedrez
qu2	move.w	#$007,$ff8244	blue background 
	move.w	#$005,$ff8246	blue ink
	bset	#1,$484		key repeat  still supervisor
	bsr	superout
	move.w	#2,-(sp)		default values
	move.w	#15,-(sp)		key repeat  rate
	move.w	#35,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	#0,-(sp)
	move.w	#$4c,-(sp)
	trap	#1

* to quit and stay resident :
quit_stay
	clr.w -(sp)
	move.l proglength,-(sp)
	move.w $31,-(sp)
	trap #1
	even
atari_palette 
	DC.W	$777,$700,$007,$005,$007,$707,$77,$555,$333
	DC.W	$733,$373,$773,$337,$737,$377,$0
proglength	dc.l 0
prog_start	dc.l 0
*-----------

* BINDEC   binary to decimal ascii    
* enter with D0 as binary number
* and A0 as address of 6-byte buffer for string
* >>>>> examples in Speculator and Final Lap <<<<<<<<<
* also in shell.s under k_star (reveal all registers)
* there is now a macro called 'bindec' which will return 
* a given binary number (L) in A0
bindec 	movem.l	d0-d1/a0,-(sp) 
	MOVE.B	#' ',D1
	TST.W	D0
	BPL.S	notneg
	MOVE.B	#"-",D1
	NEG.W	D0
notneg	MOVE.B	D1,(A0)+
	ADDA.L	#4,A0		this figure previously 5 but some
	MOVE.W	#4,D1	failure on display caused a change to 4...
binloop EXT.L	D0
	DIVS	#10,D0
	SWAP	D0
	MOVE.B	D0,-(A0)
	ADD.B	#"0",(A0)
	SWAP	D0
	DBRA	D1,binloop
	movem.l	(sp)+,d0-d1/a0
	RTS
*----------
* PRINTN [ Janice Murray  March 1989 ]
* will print any L number in D0 (max 652000 approx)
* in base specified in D1 (2-10-16) Default 10 (decimal)
* the result is stored in a 20 byte-long string, starting from the end!
* leading nulls will force gemdos $09 to home position
* and only real digits towards the end of the string will be printed.
* I have therefore substituted nulls with spaces
* to recall: printat 11,12,0,num_buff+14 which will print on screen
* at location 12-0  in ink 11  a number 6 digit long (20-14=6)
* printat 11,12,0,num_buff+16 will only print the last 4 digits, and so on
* ex: >>> move.l physbase,d0  move.l #16,d1  bsr printn <<<<< 
* ex >>>>> in shell.s (under k_star) <<<<<
printn
	and.l	#$ff,d1
	cmp.l	#16,d1		hex?
	beq	.go
	cmp.l	#2,d1		binary?
	beq	.go
	move.l	#10,d1		ok decimal
.go	lea	num_buff(pc),a0 we'll put result her 
	move.w	#19,d7		clean up 20 byte- buffer
.cl	move.b	#" ",(a0)+	spaces (originally clr.b)
	dbra	d7,.cl
.lp1	divu	d1,d0		number is continuously divided by base right down to 1	
	swap	d0		d0 low is remainder
	addi.w	#"0",d0		make into digit
	cmpi.w	#"9",d0		digit or letter?
	ble	.ok
	addq.w	#7,d0		letter!
.ok	move.b	d0,-(a0)	store character (staring from end)
	clr.w	d0		
	swap	d0		d0 low: quotient
	bne	.lp1		another one?
	rts
num_buff
	ds.b	20		20 digit buffer
	dc.b 	0		end marker
	ds.l	6		safety	
	even
*-----------
* time delay	expects a figure in D5 **
* note: D5 is NOT saved. Save if necessary prior to calling
delay	
	move.l	d0,-(sp)
outer	move.w	#5000,D0	inner loops
inner	tst.w	D0
	dbeq	D0,inner                         
	tst.w	D5
	dbeq	D5,outer
	move.l	(sp)+,d0
	rts
*------------
* gemdos random
random
	movem.l	d1-d3/a0-a3,-(sp)
	move.w	#17,-(sp)		answer in D0 (L)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d1-d3/a0-a3
	rts
*----------
* Joysticks *  [ ST World ]
* call initjoy once to initialize
* see full example in Budgie shell.s
* there is now a macro (getjoy) that waits for a button press
* and another one (joystick) that merely peeks the state of joystick
initjoy 
	MOVE.W	#$14,-(SP)	IKBDcommand to send joystick
	MOVE.W	#4,-(SP)	packages to IKBD
	MOVE.W	#3,-(SP)
	TRAP	#13
	ADDQ.L	#6,SP
	MOVE.W	#34,-(SP)	get address of IKBD vector table
	TRAP	#14
	ADDQ.L	#2,SP
	MOVEA.L	D0,A0
	ADDA.L	#24,A0	move to joy vector address in table
	LEA	oldpack(PC),A1
	MOVE.L	(A0),(A1)	save original packet handler address
	LEA	joypacket(PC),A1	address of new packet handler
	MOVE.L	A1,(A0)		modify joystick vector to point
	RTS			to our routine
*----------
* Joystick packet handler   (called by o/s) *
joypacket
	MOVEM.L	A0/A1,-(SP)	A0 points to addr of joy data
	LEA	joyport0(PC),A1	load addr of our new register
	MOVE.B	1(A0),(A1)	move joystick data to our loc
	MOVE.B	2(A0),1(A1)	and the same for port 1
	MOVEM.L	(SP)+,A0/A1
	RTS
* return to normal mouse control *
resmouse
	MOVE.W	#34,-(SP)	address of IKBD vector table
	TRAP	#14
	ADDQ.L	#2,SP
	MOVEA.L	D0,A0
	ADDA.L	#24,A0	move to joy vector address in table (24)
	MOVE.L	oldpack(PC),(A0)	restore original pack hndler
	MOVE.W	#128,-(SP)	reset keyboard processor to
	MOVE.W	#4,-(SP)	power up state
	MOVE.W	#3,-(SP)
	TRAP	#13
	ADDQ.L	#6,SP
	MOVE.W	#1,-(SP)
	MOVE.W	#4,-(SP)	and again
	MOVE.W	#3,-(SP)
	TRAP	#13
	ADDQ.L	#6,SP
	RTS
oldpack   DC.L	0	storage for old packet handler address
joyport0  DC.B	0
joyport1  DC.B	0
*------------
* call initmous once ONLY to initialize
* example in >>>>> MONEYSPINNER  <<<<<
initmous 	
	MOVE.W	#$08,-(SP)	IKBD command to send relative mouse
	MOVE.W	#4,-(SP)	packages from now on
	MOVE.W	#3,-(SP)
	TRAP	#13
	ADDQ.L	#6,SP
	MOVE.W	#34,-(SP)	get address of IKBD vector table
	TRAP	#14
	ADDQ.L	#2,SP
	MOVEA.L	D0,A0
	ADDA.L	#16,A0		mouse vector address in table
	LEA	oldpak(PC),A1
	MOVE.L	(A0),(A1)	save original packet handler address
	LEA	mouspacket(PC),A1	address of new packet handler
	MOVE.L	A1,(A0)		modify vector to point
	RTS			to our routine
*----------
* Mouse packet handler   (called by o/s) *
* see MONEYSPINNER for details
mouspacket
	movem.l	a0/a1,-(sp)	A0 points to addr of packet received
	lea	mse_packet(pc),a1	 A1 is where we store it
	clr	d0
	move.b	(a0),(a1)	header (buttons)
	move.b	1(a0),d0	x movement
	ext	d0   		make it a word (added nov 88)
	add.w	d0,2(a1) 	new x position (lateral 0-320)
	tst.w	2(a1)		below 0 ?
	bpl	.m1		ok
	clr.w	2(a1)		keep it at 0
.m1	cmp.w	#302,2(a1)	too large? off screen
	bmi	.m2		no  ok
	move.w	#302,2(a1)	hold it there
.m2	clr	d0
	move.b	2(a0),d0	y movement
	ext	d0	
	add.w 	d0,4(a1) 	new y position (vertical 0-200)
	tst.w	4(a1)		below 0 ?
	bpl	.m3		ok
	clr.w	4(a1)		keep it at 0
.m3	cmp.w	#186,4(a1)	too large? off bottom?
	bmi	.m4		no  ok
	move.w	#186,4(a1)	hold it there
.m4	movem.l	(sp)+,a0/a1
	rts

* return to normal mouse control *
resmous	
	MOVE.W	#34,-(SP)	address of IKBD vector table
	TRAP	#14
	ADDQ.L	#2,SP
	MOVEA.L	D0,A0
	ADDA.L	#16,a0		mouse vector
	MOVE.L	oldpak(PC),(A0)	restore original pack hndler
	MOVE.W	#128,-(SP)	reset keyboard processor to
	MOVE.W	#4,-(SP)	power up state
	MOVE.W	#3,-(SP)
	TRAP	#13
	ADDQ.L	#6,SP		and again
	MOVE.W	#1,-(SP)	data to write 128 and 1 = reset
	MOVE.W	#4,-(SP)	4 is ikbd
	MOVE.W	#3,-(SP)	3 is chr out
	TRAP	#13
	ADDQ.L	#6,SP
	RTS
oldpak 	DC.L	0	storage for old packet handler address
mse_packet
	DC.B	0	button
	dc.b  	0 	empty byte (not used)
	dc.w 	160     x 	0 to 320 max
	dc.w 	20 	y	0 to 200 max	
	dc.b	0,0,0,0,0,0
	even
*-----------
* VERTICAL SCROLL [ Simon Rush ]  May 20, 1987 
* there is a macro to call it (called 'scroll')
* see full example in shell.s  under 'opening sequence'
* this routine merely scrolls a block on itself.
* for scenery scrolling, see the example inside shell.s
* by pressing V 

* expects times in D2, width in D3,
* left corner + margin in D4 and height in D5
* macro example in all budgie shells under 'opening sequence'
* modified aug 89  (B is now L) ~~ much faster

scrol	move.w	d3,d6		width
	lsr	#2,d3		divide by 4
.scrol
	MOVE.L	$44e,A1		origin
	ADD.W	D4,A1		bottom left corner
	MOVE.L	$44e,A2		destination
	add.l	#160,A2
	ADD.W	D4,A2		bottom left 
	MOVE.W	D5,D1		height
.a 	MOVE.W	D3,D0
.lp 	MOVE.l (A1)+,(A2)+  
	DBRA	D0,.lp	loop
	SUB.L	#164,A1	
	SUB.W	D6,A1  
	SUB.L	#164,A2	
	SUB.W	D6,A2
	DBRA	D1,.a
	MOVE.L	$44e,A2
	adda.w	#160,A2
	ADD.W	D4,A2 
	MOVE.W	D3,D0
	ADD.L	#160,A1
.s 	MOVE.l	(A2)+,(A1)+
	DBRA	D0,.s          
	DBRA	D2,.scrol
	RTS
*------------
* increment palette color register 0 (border)  [ Rik Haynes ] Jul 87
* 	expects a number in D3 (10000 = 2 seconds approx)
* Again, we now have a macro, called 'flash'
flashes
	movem.l	d0-d3/a0,-(sp)
	lea	$ff8240,a0	register address
	move.w	#0,(a0)		start with black
fla1 	ADD	#61,(A0)	increment contents 
	CMP.W 	#$770,(A0)                
	BMI	fla2
	MOVE.W	#0,(A0)		reset color
fla2	MOVE.L	#256,D1
fla3	DBRA	D1,fla3
	DBRA	D3,fla1
	movem.l	(sp)+,d0-d3/a0
	rts
*------------
flashes_b
	movem.l	d0-d3/a0,-(sp)
	lea	$ff8240,a0	register address
	move.l	(a0),-(sp)	save original color
fla00	move.w	#0,(a0)		start with black
	move.l	#200,d1
fla11	dbra	d1,fla11	delay
	move.w	#$777,(a0)
	move.l	#200,d1
fla22	dbra	d1,fla22	delay
	dbra	d3,fla00	number of iterations required
	move.l	(sp)+,(a0)	restore original color
	movem.l	(sp)+,d0-d3/a0
	rts
*------------
* new palette expects address in A0
* see macro called 'palette'  
setpal  
	movem.l	d0-d2/a0-a2,-(sp)
	move.l	a0,-(sp)
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	movem.l	(sp)+,d0-d2/a0-a2
	rts
*----------
* here is how to save a palette
	movem.l	$ff8240,d0-d7
	movem.l	d0-d7,palet
*---------------------------
* here is how to quickly turn screen black
	movem.l	blanks(pc),d0-d7	; all nulls
	movem.l	d0-d7,$ff8240		; all colors are now black
blanks	ds.w	16
*----------------
*	REVEAL	[ Camy Maertens ]  July 1 1987
* will reveal the contents of D0
* >>> see 'r`  
  (       Œ          /<  
?< 	NA\*O.|  *m  - Ð­ Ð­ €   / /Bg?< JNAOï /<   è/<   èHy   î?<  ?< KNAßü   ?<  ?< LNA                                                                                                                                      a:\music\lisa_14.prg                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  GET_BUTT¢   PINITIALI¢    0MESSAGEB¡    RLOADED_¢    jSET_BUTT¢   GET_TEDI¢   LEAD_ZER¢   dSET_TEDI¢   âBADRSC_A¤    2DEINITIA¢   rRSC_FILE¤     GEM_CTRL¤    vVOLUME_B¢   ,________¢   â________¢   j   2$

À


,

0 (


 &&


P$


Ê







$&20220
šŠ










&








Žd                   ?ð ?ÿÿþà    à  ÿÀÿÿþ        àþàþÿÿþ                                     ?ð ÿÿþà    ð  ÿÀÿÿþ        àþÿÿþÿÿþ                                     ?ð ÿÿþÿà   ø ÿÿÀÿÿþ        ÿÿþÿÿþàþ                                     ?ð ÿÿþÿà   ü ÿÿÀÿÿþ        ÿÿþÿÿþàþ                                     ?ð ÿÿþÿà   þ ÿÿÀÿÿü        ÿÿþ?ÿÿüàþ                                     ?ð ÿÿþÿà    ÿ ÿÿÀÿÿü        ?ÿÿü?ÿÿüàþ                                     ?ð ÿÿþÿà      ÿÿÀÿÿø        ÿÿøÿÿøàþ                                     ?ð ÿÿþÿà      ÿÿÀÿÿà        ÿÿàÿÿààþ                                                        à                    þ                                                                                                                                                                                                                                                                                                                                                                     8ü    88pl0   xøø8øxüxx88 px xø|øüü|Ìxl`ÌÌxøxø|üÌÌÌÌÌü|à|                   8ü    8p880   8Ü8xÀÀÌÌ888|8Ü ÌÌÀÌÀÀÀÌ0x`üìÌÌÌÌÀ0ÌÌÌxÌpp                   8Ø    pp8|ü | püxxØøøx|  p 8 üøÀÌøøÜü0p`üüÌøÌøx0ÌÌü0x0p8                   8      p8808 8àìÀüÌ0Ì888|88 ÌÌÀÌÀÀÌÌ0Ìx`ÌÜÌÀÌð0Ìxüx0`p                          8pl08 8Àxüøøx0xx8 p  Ìø|øüÀ|Ìxxl|ÌÌxÀxÜø0|0ÌÌ0ü||ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   