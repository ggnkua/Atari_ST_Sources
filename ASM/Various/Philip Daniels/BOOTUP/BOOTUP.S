* BOOT-UP ST
* SYSTEM CONFIGURE
* ALLOWS USER TO :-
*		SET RESOLUTION
*		SET SYSTEM CLOCK
*		SET WRITE VERIFY
* ALL ON BOOTUP!

* Macro to execute routine in supervisor mode
super	MACRO
	PEA \1(PC)
	MOVE #38,-(A7)
	TRAP #14		SUPEXEC
	ADDQ.L #2,A7
	ENDM

* Macro to print a string
print	MACRO
	PEA \1(PC)		String address
	MOVE.W #9,-(A7)		Print it
	TRAP #1			GEMDOS 9 - c_conws
	ADDQ.L #6,A7		Tidy stack
	ENDM

*********************
* THE PROGRAM PROPER*
*********************

start:	
	print hello
	BSR get_char		Get character
	CMP.W #32,D0		Compare character to ASCII value of space
	BNE on_prompt		If char<>space then goto 'on_prompt'
	super verify_off	Else turn it off
	print off_text
	BRA set_clock		Goto set_clock

on_prompt:
	print on_text
	BRA set_clock		Goto 'set_clock'

verify_off:
	MOVE #0,$444		Set write_verify flag to 0
	RTS
	
set_clock:
	MOVEQ #0,D7		Fast clear of D7
	print date_text
	BSR get_number 		Get two digit number (returned in D5)
	CMP.W #80,D5		Error trapping
	BGT ok1
	BRA set_clock
ok1:
	SUB.W #80,D5		Subtract default
	AND.W #%0000000001111111,D5
	LSL.W #8,D5		Move year into position
	LSL.W #1,D5		
	OR.W D5,D7		D7 now holds the year
	print comma
get_month:
	BSR get_number		Get two digit number (returned in D5)
	CMP.W #13,D5		Error trapping
	BLT ok2
	BRA get_month
ok2:
	TST.W D5		Fast compare with 0
	BGT ok3
	BRA get_month
ok3:
	AND.W #%0000000000001111,D5
	LSL.W #5,D5		Move month into position
	OR.W D5,D7		D7 now holds year and month
	print comma
get_date:
	BSR get_number		Get two digit number (returned in D5)
	CMP.W #32,D5		Error trapping
	BLT ok4
	BRA get_date
ok4:
	TST.W D5		Fast compare with 0
	BGT ok5
	BRA get_date
ok5:
	AND.W #%0000000000011111,D5
	OR.W D5,D7		D7 now holds year, month and date
set_date:
	MOVE.W D7,-(A7)		Put date on stack
	MOVE.W #43,-(A7)	Set it
	TRAP #1			GEMDOS 43 - t_setdate
	ADDQ.L #4,A7		Tidy stack
	TST D0
	BMI error

get_time:
	print carr
	MOVEQ #0,D7		Clear D7
	MOVEQ #0,D5		Clear D5
	print hour_text
	BSR get_number		Get two digit number (returned in D5)
	TST.W D5		Fast compare to 0
	BGE ok6			Error trapping
	BRA get_time
ok6:
	CMP.W #24,D5		
	BLT ok7
	BRA get_time
ok7:
	AND.W #%0000000000011111,D5
	LSL.W #8,D5		Move into position
	LSL.W #3,D5		
	OR.W D5,D7		D7 now holds hours
	print comma
get_mins:
	BSR get_number		Get two digit number(returned in D5)
	TST.W D5		Fast compare with 0
	BGE ok8			Error trapping
	BRA get_mins
ok8:
	CMP.W #60,D5
	BLT ok9
	BRA get_mins
ok9:
	AND.W #%0000000000111111,D5
	LSL.W #5,D5		Move mins into position
	OR.W D5,D7		D7 now holds hours and mins
set_time:
	MOVE.W D7,-(A7)		Put time on stack
	MOVE.W #45,-(A7)	Set it
	TRAP #1			GEMDOS 45 - t_settime
	ADDQ.L #4,A7		Tidy stack
	TST D0			Test for error
	BMI error
	print carr
	print done_message

set_resolution:
	print carr
	print carr
	print res_prompt
res_loop:
	BSR get_char		Get character
	AND.W #$DF,D0		Force upper case
	CMP.W #'M',D0		Compare character to 'M'
	BEQ medium_res		If char='M' then goto 'medium_res'
	CMP.W #'L',D0		Compare character to 'L'
	BEQ low_res		If char='L' then goto 'low_res'
	BRA res_loop		Goto 'res_loop'
medium_res:
	MOVE.W #1,-(A7)		Set medium res screen
	BRA set_it		Goto 'exit'
low_res:
	MOVE.W #0,-(A7)		Set low res screen
set_it:
	MOVE.L #-1,-(A7)	Dummy parameter
	MOVE.L #-1,-(A7)	Dummy parameter
	MOVE.W #5,-(A7)		Set rez
	TRAP #14		XBIOS 5 - _setScreen
	ADD.L #12,A7		Tidy stack

exit:
	MOVE.W #0,-(A7)		Back to desktop at last!
	TRAP #1			GEMDOS 0 - p_term

error:
	print error_text
	BRA exit
				
get_char:
	MOVE.W #8,-(A7)		Get character
	TRAP #1			GEMDOS 8 - c_necin
	ADDQ.L #2,A7		Tidy stack
	CMP.W #27,D0		Esc pressed?
	BEQ exit		If Esc pressed then exit prog
	RTS

get_number:
	MOVEQ #0,D5		Initialise
	BSR get_char
	CMP.W #'0',D0		Compare char to '0'
	BLT get_number		If char<0 then goto 'get_number'
	CMP.W #'9',D0		Compare char to '9'
	BGT get_number		If char>9 then goto 'get number'
	MOVE.W D0,D5		D5=first digit
	MOVE.W D5,-(A7)		Put digit on stack
	MOVE.W #2,-(A7)		Print it
	TRAP #1			GEMDOS 2 - c_conout
	ADDQ.L #4,A7		Tidy stack
	SUB.W #48,D5		Extract real value
	MULU #10,D5		D5(digit)=D5*10
second:
	BSR get_char
	CMP.W #'0',D0		Compare char to '0'
	BLT second		If char<0 then goto 'second'
	CMP.W #'9',D0		Compare char to '9'
	BGT second		If char>9 then goto 'second'
	MOVE.W D0,D4		Store value
	MOVE.W D0,-(A7)		Put digit on stack
	MOVE.W #2,-(A7)		Print it
	TRAP #1			GEMDOS 2 - c_conout
	ADDQ.L #4,A7		Tidy stack
	SUB.W #48,D4		Extract real value
	ADD.W D4,D5		D5=final total
	RTS


* STRING DEFINITIONS
hello:
	DC.B "************************",13,10
	DC.B "* Welcome to BOOTUP-ST *",13,10
	DC.B "* By Philip Daniels.   *",13,10
	DC.B "************************",13,10,13,10
	DC.B ">>Write-verify toggle.",13,10
	DC.B "  Press <space> to disable write-verify,",13,10
	DC.B "  any other key to enable it.",13,10,0

off_text:
	DC.B "  Write-verify is now disabled.",13,10,13,10,0

on_text:
	DC.B "  Write-verify is now enabled.",13,10,13,10,0

carr:
	DC.B 13,10,0

date_text:
	DC.B ">>Set system clock.",13,10
	DC.B "  Please enter the date:19",0

res_prompt:
	DC.B ">>Set screen resoltuion.",13,10
	DC.B "  Press <M> for medium rez,",13,10
	DC.B "  or <L> for low rez.",13,10,0

error_text:
	DC.B ">>>>>An error has ocurred.",13,10,13,10,0
		
hour_text:
	DC.B "  Please enter the time:",0

done_message:
	DC.B "  System clock is now set.",13,10,0

comma:
	DC.B ",",0	
		