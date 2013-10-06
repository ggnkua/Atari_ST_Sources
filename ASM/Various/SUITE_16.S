		********************
		*     SUITE_16     *
		* Margaret  Clarke *
		* (c)Atari ST User *
		********************
		
gemdos		EQU	1
C_Rawio		EQU	6
C_Conws		EQU	9
Smode		EQU	$20
P_Termres	EQU	$31
M_Shrink	EQU	$4A

bios		EQU	13
kbshift		EQU	11

xbios		EQU	14
physbase	EQU	2
setscreen	EQU	5
setcolor	EQU	7
IOrec		EQU	14
xbtimer		EQU	31
dosound		EQU	32
kbdvbas		EQU	34

A_Timer		EQU	0
timer_data	EQU	96
timer_control	EQU	5
timerA		EQU	5
isra		EQU	$FFFFFA0F
keyboard	EQU	1
savptr		EQU	$4A2
varptr		EQUR	A6
all_reg		REG	D0-D7/A0-A6
RTS		EQU	$4E75

STORAGE	MACRO           Eg STORAGE.W label,40
	IFEQ NARG=2
	 FAIL : I need two parameters 
	 MEXIT
	ENDC
	IFND	bug	Without this a phasing error occurs
bug	SET	-$8000	Allows a potential 64K block	
space	SET	bug
	ENDC
	OFFSET space
\1	DS.\0	\2
\@	EVEN
space	SET	space+\@-\1
	ENDM

* In PUSH & POP below a null \2 results in MOVE
* whereas \2=M results in MOVEM

PUSH	MACRO		Eg PUSH.L savptr or PUSH.L D0-D2/A0-A2,M
	MOVE\2.\0  \1,-(SP)
	ENDM
	
POP	MACRO
	MOVE\2.\0  (SP)+,\1
	ENDM
	
CALL	MACRO           Eg CALL gemdos,M_Shrink,12
	PUSH.W	#\2
	TRAP	#\1
	IFLE	\3-8
	 ADDQ.L	#\3,SP
	ELSEIF
	 LEA	\3(SP),SP
	ENDC
	ENDM
	
PRINT	MACRO
	IFC	'','\1'
	 FAIL : Print what?
	 MEXIT
	ENDC
	PEA	\1(PC)
	CALL gemdos,C_Conws,6
	ENDM
	
start

* Size memory required and
* return unused to GEMDOS

	MOVEA.L	4(A7),A5		Get base page
	MOVE.L	$C(A5),D5		Get Text area length
	ADD.L	$14(A5),D5		Add Data area length 
	ADD.L	$1C(A5),D5		Add BSS area length
	ADDI.L	#$100,D5		Add the base page offset
	LEA	variables(PC),varptr	BSS pointer
	ADDA.L	#$8000,varptr		STORAGE offset
	MOVE.L	D5,reserve_area(varptr)	Make a note for later
	LEA	lstk(varptr),A7		Use local stack
	PUSH.L	D5			Area to be reserved
	PUSH.L	A5			Start address ie base page
	PUSH	#0
	CALL	gemdos,M_Shrink,12	Return unused to GEMDOS
	
	STORAGE.L reserve_area,1
	SECTION TEXT

save_area

* save_area-start must be >= 46 to avoid corrupting base page

* Call main program and any isr initialisation
* Do not use A6 except as varptr!

	BSR.W	main_initialise
	BSR.W	timer1_initialise

* Initialise timer A
* Working frequency of 2457600/64 (Delay mode 5) ie 38400Hz
* Interrupting at 38400/96 (Data value) ie 400Hz 
	
	PEA	timer_A(PC)
	PUSH.W	#timer_data
	PUSH.W	#timer_control
	PUSH.W	#A_Timer
	CALL	xbios,xbtimer,12

* Terminate and stay resident

	PUSH.W	#0
	PUSH.L	reserve_area(varptr)	Keep all that was reserved
	CALL	gemdos,P_Termres,8
	RTS

* Call here at 400Hz intervals
	
timer_A	PUSH.L	all_reg,M		Save registers
	LEA	variables(PC),varptr	BSS pointer
	ADDA.L	#$8000,varptr		STORAGE offset
	MOVE.L	A7,entry_sp(varptr)	Save stack pointer
	LEA	lstk(varptr),A7		and provide a local stack
	PUSH.L	savptr			Save contents of savptr
	MOVE.L	#save_area,savptr	then change to save_area
	BSR.S	timer_events		Execute timer events
	LEA	divisor(PC),A0
	ROL.W	(A0)
	BCC.S	out
* Call here at 25Hz intervals		ie at 400/16
	BSR.S	keyboard_events		Execute keyboard events
out	POP.L	savptr			Restore contents of savptr
	MOVE.L	entry_sp(varptr),A7	Restore stack pointer
	POP.L	all_reg,M		Restore registers
	BCLR.B	#timerA,isra		| Allow interrupts
	RTE				| <= to this level
	
	SECTION DATA
divisor DC.W 1
	STORAGE.L entry_sp,1	

	SECTION TEXT	
timer_events
	ANDI.W	#7,count(varptr)	circular 0 to 7
	MOVE.W	count(varptr),D0	timer number
	BTST.B	D0,timer_flag(varptr)	D0th timer on?
	BEQ.S	not_active		No
	LEA	isr_vector(PC),A3
	LSL.W	#2,D0			Long word skip
	MOVEA.L	0(A3,D0.W),A3		Get D0th address
	JSR	(A3)			Execute D0th timer
not_active
	ADDQ.W	#1,count(varptr)	Prepare for next timer
	RTS
	
	STORAGE.W count,1
	STORAGE.B timer_flag,1
	
	SECTION TEXT
keyboard_events
	BSR.S	get_char		
	BEQ.S	non_event		Nothing of interest
	LEA	isr_keys(PC),A0		Array of selection keys
	MOVE.W	#8-1,D7			Of which there are 8
key_test
	CMP.B	0(A0,D7.W),D0		Is the D7th key pressed?
	DBEQ	D7,key_test		No
	BNE.S	non_event		No relevant key pressed
	LEA	isr_vector(PC),A3	
	LSL.W	#2,D7			Long word skip
	SWAP	D0			Kbd status to lower word
	ANDI.B	#%1100,D0		Control & Alternate
	CMPI.B	#%1100,D0		Both pressed?
	BNE.S	onoff			ie Control only
	ORI.W	#32,D7			Point to key events
	MOVEA.L	0(A3,D7.W),A3		Get D7th key address
	CMPI.W	#RTS,(A3)		A wasted journey?
	BEQ.S	non_event		It would have been
	JSR	(A3)			Execute D7th k'bd ISR
cleek	BSR.S	ping			Acknowledge selection
non_event
	RTS				Thats me done for a while			
onoff	BCHG.B	D7,timer_flag(varptr)	Toggle D7th timer
	BNE.S	non_event		If D7th timer was on
	BRA.S	cleek			Advise timer is now on
	
	SECTION DATA
* Numeric keypad scancodes 0 to 7
isr_keys DC.B $70,$6D,$6E,$6F
         DC.B $6A,$6B,$6C,$67
isr_vector DC.L cisr0,cisr1,cisr2,cisr3,cisr4,cisr5,cisr6,cisr7
           DC.L caisr0,caisr1,caisr2,caisr3,caisr4,caisr5,caisr6
           DC.L caisr7
	
	SECTION TEXT
get_char
	MOVE.L	iorec(varptr),A4	Keyboard record buffer
	MOVE.W	8(A4),D4		Tail index
	CMP.W	tail_index(varptr),D4	| Has tail index moved
*					| since we last looked?
	BEQ.S	no_read			No (Z flag set)
	MOVE.W	D4,tail_index(varptr)	Save current tail index
	PUSH.W	#-1			Inquire
	CALL	bios,kbshift,4		keyboard status
	BTST.L	#2,D0			Control key pressed?
	BEQ.S	no_read			No (Z flag set)
	SWAP	D0			Kbd status to upper word
	MOVEA.L	(A4),A4			Buffer address
	MOVE.W	0(A4,D4.W),D0		Put scancode in lower word
no_read	RTS				 & reset Z flag
	
	STORAGE.L iorec,1
	STORAGE.W tail_index,1

	SECTION TEXT
ping	PEA	sound(PC)
	CALL	xbios,dosound,6
	RTS
	
	SECTION DATA
sound DC.B 0,36,1,0,2,0,3,0,4,0,5,0,6,0,7
      DC.B $FE,8,$10,9,0,10,0,11,0,12,22,13,9,$FF,0
	EVEN
	
*** Intialisation of main program ***

	SECTION TEXT
main_initialise
	PRINT	boot_message
	PUSH.W	#keyboard
	CALL	xbios,IOrec,4		Get record buffer for
	MOVE.L	D0,iorec(varptr)	get_char routine
	RTS
	
	SECTION DATA
boot_message
	DC.B 13,10,"SUITE_16 Copyright ",189
	DC.B " Atari ST User 1989",13,10,0
	EVEN
	
*** End of main program initialisation ***

*** Initialisation of ISR routines, if any ***

	SECTION TEXT
timer1_initialise
	PRINT	screen_time		Ask for screen off delay
time	PUSH.W	#$FF			Wait for a character
	CALL	gemdos,C_Rawio,4	from the keyboard
	TST.W	D0			Is one ready?
	BEQ.S	time			No
	CMP.B	#$31,D0			< "1"
	BCS.S	time			Yes
	CMP.B	#$39,D0			> "9"
	BHI.S	time			Yes
	PUSH.W	D0			Note character
	PUSH.W	D0			Stack for C_Rawio
	PRINT	cursor_off
	CALL	gemdos,C_Rawio,4	Print character
	POP.W	D0			Remember character
	ANDI.W	#$F,D0			Remove $30 offset
	MULU	#60*50,D0		D0 cycles delay
	MOVE.W	D0,count_start(varptr)	Fix the counter
	MOVE.W	D0,count_down(varptr)	Initialise the count down 
	MOVE.B	#1,timer_flag(varptr)	Switch on timer 1
	LEA	screen_space(varptr),A0	Set up the dead screen
	ADDA.L	#256,A0			area.  Must be on a page
	EXG	D0,A0			boundary
	ANDI.L	#$FFFF00,D0		
	MOVE.L	D0,dead_screen(varptr)	Make a note

	SECTION DATA
screen_time
	DC.B "Screen off time delay (1-9 mins): ",27,"e",0
	EVEN
cursor_off
	DC.B 27,"f",0
	EVEN
	
	STORAGE.L dead_screen,1
	STORAGE.B screen_space,$8000
	
* Revector keyboard interrupt

	SECTION TEXT
	CLR.L	-(SP)
	CALL	gemdos,Smode,6		Supervisor mode
	MOVE.L	D0,ssp(varptr)		Save super stack pointer
	MOVE.W	#$2700,SR		Disable interrupts
	CALL	xbios,kbdvbas,2		Get keyb'd vector table
	ADDI.L	#$20,D0			Point to keyb'd interrupt
	MOVEA.L	D0,A0			pointer and save the
	MOVE.L	(A0),ikbd_vec(varptr)	interrupt's address
	MOVE.L	#our_ikbd_vec,(A0)	Revector
	MOVE.W	#$2300,SR		Enable interrupts
	PUSH.L	ssp(varptr)		Restore supervisor
	CALL	gemdos,Smode,6		stack pointer
	RTS
	
	STORAGE.L ssp,1
	STORAGE.L ikbd_vec,1

* A6 is not used within the OS keyboard routine and is not
* preserved on entry - A0 is one that is preserved.
	
	SECTION TEXT
our_ikbd_vec
	LEA	variables(PC),A0	BSS pointer
	ADDA.L	#$8000,A0		STORAGE offset
	MOVE.W	count_start(A0),count_down(A0)	Reset count_down
	MOVE.L	ikbd_vec(A0),A0		Back to original
	JMP	(A0)			keyboard interrupt
	
	STORAGE.W count_start,1
	STORAGE.W count_down,1

*** End of ISR initialisations ***

*** Interrupt Service Routines ***
* Do not use A6 except as varptr!

* timer routines

	SECTION TEXT
cisr0	MOVE.W	count_down(varptr),D0
	BMI	do_nowt			If minus then screen dead
	BEQ.S	off_screen		Make screen dead
	CMP.W	count_start(varptr),D0	count_down=count_start ?
	BNE.S	dec_count		Must be counting down
* To be here we must be on our first visit or there has been
* a recent keyboard event (including the mouse, of course)
	LEA	screen_status(varptr),A0 
	TST.B	(A0)			Is the screen dead?
	BEQ.S	dec_count		Screen not dead
	CLR.B	(A0)			Screen to be made undead
	PUSH.W	#-1			Retain resolution
	PUSH.L	phys_screen(varptr)
	PUSH.L	#-1			Retain Logical base
	CALL	xbios,setscreen,12	Screen to undead position
	PUSH.W	screen_colour(varptr)
	PUSH.W	#0
	CALL	xbios,setcolor,6	Restore original colour 0
	BRA.S	dec_count
off_screen
	LEA	screen_status(varptr),A0
	ADDQ.B	#1,(A0)			Screen to be made dead
	CALL	xbios,physbase,2	Get undead position
	MOVE.L	D0,phys_screen(varptr)	and make a note
	PUSH.W	#-1			Retain resolution
	PUSH.L	dead_screen(varptr)
	PUSH.L	#-1			Retain Logical base
	CALL	xbios,setscreen,12	Screen to dead position
	PUSH.W	#-1			Inquire
	PUSH.W	#0
	CALL	xbios,setcolor,6	Get colour 0
	MOVE.W	D0,screen_colour(varptr) and make a note
	MOVE.W	#0,$FF8240		Colour 0 to black
* If here via off_screen then count_down becomes negative
dec_count
	SUBQ.W	#1,count_down(varptr)	Closer to a blackout!
do_nowt	RTS

	STORAGE.B screen_status,1
	STORAGE.W screen_colour,1
	STORAGE.L phys_screen,1
	
* Your masterpieces go here
	
	SECTION TEXT
cisr1	RTS
cisr2	RTS
cisr3	RTS
cisr4	RTS
cisr5	RTS
cisr6	RTS
cisr7	RTS

* key routines

* screen_toggle
caisr0	MOVE.W	#-1,D0			Inquire
	BSR.S	chgcolor		Get colour 0
	EORI.W	#1,D0			and toggle
	BSR.S	chgcolor
	RTS
chgcolor
	PUSH.W	D0			Toggled value
	PUSH.W	#0			Colour 0
	CALL	xbios,setcolor,6
	RTS

* key_repeat_toggle	
caisr1	EORI.B	#2,$484			That's worn me out!
	RTS
* And yet more of your masterpieces go here
caisr2	RTS
caisr3	RTS
caisr4	RTS
caisr5	RTS
caisr6	RTS
caisr7	RTS

*** End of ISRs ***

	STORAGE.L dummy,100		Watch this space
	STORAGE.L lstk,1		Your work may need more

	SECTION BSS
variables DS.B space+$8000
	END
