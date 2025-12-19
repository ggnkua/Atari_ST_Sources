	 	opt o+

		bra	start			;Program start

		include	d:\devpac2\aes.s	;Only AES macros

start:		clr.b	file_name		;No file name
		initacc				;Init GEM
		tst.w	appid			;PRG or ACC ?
		bne.s	inst_acc		;Install ACC
		bsr.s	main			;Run PRG
		clr.w	-(sp)			;Term
		trap	#1			;Gemdos

inst_acc:	move.w	appid(pc),int_in	;Our AES ID
		move.l	#acc_name,addr_in	;Our Desk name
		aes	menu_register		;Install ACC
event_loop:	move.l	#msgbuff,addr_in	;Set buffer
		aes	evnt_mesag		;Get event
		cmpi.w	#40,msgbuff		;ACC_open ?
		bne.s	event_loop		;No, wait
		bsr.s	main			;Yes, open acc
		bra.s	event_loop		;Wait for next time
	
main:		movem.l	d0-a6,-(sp)		;Save all registers
		move.w	#3,int_in		;Disable Mouse
		aes	wind_update

		lea	file_path(pc),a5	;Adress of string
		move.w	#$19,-(sp)		;Get drive
		trap	#1			;Gemdos
		addq.l	#2,sp
		addq.w	#1,d0			;Make 1-offset drive id
		move.w	d0,-(sp)		;Push on stack
		addi.b	#64,d0			;Make ASCII
		move.b	d0,(a5)			;Save in string
		move.b	#':',1(a5)		;Save ':' in string
		pea	2(a5)			;Buffer for dir-name
		move.w	#$47,-(sp)		;Get dir
		trap	#1			;Gemdos
		addq.l	#8,sp
		lea	(a5),a4			;Start of text
check_next:	tst.b	(a4)+			;End of string ?
		beq.s	end_str			;Yes, stop scan
		bra.s 	check_next		;Check next char
end_str:	subq.l	#1,a4			;One char back
		lea	extension(pc),a5	;Data adress
move_char:	move.b	(a5),(a4)+		;Move data
		tst.b	(a5)+			;Was it $00 ?
		bne.s	move_char		;No, next char

		move.l	#file_path,addr_in	;Path for fsel
		move.l	#file_name,addr_in+4	;File name for fsel
		move.l	#fsel_message,addr_in+8	;Info message (>TOS 1.4)
		aes	fsel_exinput		;Extended file selector
		tst.w	int_out+2		;Cancel pressed ?
		beq	abort_acc		;Yes, abort
		
		dc.w	$A00A			;Hide Mouse
		clr.l	int_in			;Just border, x=0
		move.w	#19,int_in+4		;Full size
		move.w	#640,int_in+6		;Full size
		move.w  #381,int_in+8		;Full size
		aes	wind_create
		move.w	int_out(pc),w_handle	;Save handle
		move.w	w_handle(pc),int_in	;Window handle
		aes	wind_open
		
scan_image:	clr.l	-(sp)			;Super mode
		move.w	#$20,-(sp)		;Super
		trap	#1			;Gemdos
		addq.l	#6,sp
		move.l	d0,save_ssp		;Save stack
		
		movea.l $44E.w,a0		;Screen adress
		adda.l	#19*80,a0		;19 lines for menu
		move.l	a0,screen		;save screen start

		move.l	a0,a1			;Copy of start
		move.w	#7619,d7		;Counter
blank_screen:	move.l	#$FFFFFFFF,(a1)+	;Black screen
		dbf.w	d7,blank_screen		;Next long

		move.b	#8,d5			;For btst of roller
		move.b	#1,d3			;For btst of data
		move.w	#380,d7			;381 lines/screen

		lea	$FB0000,a1		;Status & Roller pos
		lea	$FB1000,a2		;Data request
		lea	$FB2001,a3		;Data receive

		move.b	#$13,$FFFFFC02.W	;Shut off Keyboard
		move.w	#$2700,sr		;Interrupts off
		tst.w	$FB4000			;Scanner light on
		
scan_line:	moveq	#79,d6			;80 bytes/line
wait_roller:	move.w	(a1),d2			;Get roller status
		btst.l	d5,d2			;Has roller moved
		bne.s	wait_roller		;No, wait for move
get_blank:	tst.w	(a2)			:Ask for data
wait_blank:	btst.b	d3,(a1)			;Data ready ?
		beq.s	wait_blank		;No, wait for blank
get_data:	tst.w	(a2)			;Ask for data
wait_data:	btst.b	d3,(a1)			;Data ready ?
		beq.s	wait_data		;No, wait for data
		move.b	(a3),(a0)+		;Move data to screen
		dbf.w	d6,get_data		;Ask for more data
		dbf.w	d7,scan_line		;Wait for next line
		
		tst.w	$FB3000			;Scanner light off
		move.w	#$2300,sr		;Interrupts on
		move.b	#$11,$FFFFFC02.W	;Keyboard on again

		move.l  save_ssp(pc),-(sp)	;User mode
		move.w	#$20,-(sp)		;Super
		trap	#1			;Gemdos
		addq.l	#6,sp

		dc.w	$A009			;Show mouse
		move.w	#1,int_in		;Default button
		move.l	#alert,addr_in		;Alert box text
		aes	form_alert		;Do alert box
		dc.w	$A00A			;Hide Mouse

		cmp.w	#1,int_out		;Scan button ?
		beq	scan_image		;Yes, Again

		cmp.w	#2,int_out		;Save button ?
		bne	close_window		;No, Close ACC

		lea	file_name(pc),a6	;Start filename
check_char:	cmp.b	#'.',(a6)		;Found '.' ?
		beq.s	name_ok			;Yes, Name OK
		tst.b	(a6)+			;End of text ?
		bne.s	check_char		;No, Check next
		subq.l	#1,a6			;Yes, One char back
		lea	extension+2(pc),a5	;Data '.PI3'
move_char2:	move.b	(a5),(a6)+		;Move data
		tst.b	(a5)+			;Was it $00 ?
		bne.s	move_char2		;No, next char

name_ok:	lea	file_path(pc),a6	;Path-name
		clr.w	d0			;Last '\' pos
		clr.w	d1			;Char counter
check_slash:	cmp.b	#'\',(a6,d1.w)		;Found new '\' ?
		bne.s	check_end
		move.w	d1,d0			;Save last '\'
check_end:	tst.b	(a6,d1.w)		;End of text
		beq.s	finished
		addq.w	#1,d1			;Next char
		bra.s	check_slash

finished:	lea	file_name(pc),a5	;Start filename
move_name:	addq.w	#1,d0			;Next char in path
		move.b	(a5),(a6,d0.w)		;Move after path
		tst.b	(a5)+			;End of name ?
		bne.s	move_name		;No, next char

		clr.w	-(sp)			;Read and Write		
		move.l	a6,-(sp)		;Full name of file
		move.w	#$3C,-(sp)		;Create file
		trap	#1			;Gemdos
		addq.l	#8,sp
		tst.w	d0			;Error ?
		bmi.s	close_window		;Yes, Abort
		move.w	d0,handle		;Save file handle
		
		pea	file_start(pc)		;Start of PI3-file
		move.l	#4,-(sp)		;4 bytes
		move.w	handle(pc),-(sp)	;File handle
		move.w	#$40,-(sp)		;Write data
		trap	#1			;Gemdos
		lea	12(sp),sp

		move.w	#14,d7			;15 empty words
		bsr.s	fill_zero		;Fill file with $0000

		move.l	screen(pc),-(sp)	;Start of screen
		move.l	#30480,-(sp)		;30480 bytes
		move.w	handle(pc),-(sp)	;File handle
		move.w	#$40,-(sp)		;Write data
		trap	#1			;Gemdos
		lea	12(sp),sp
		
		move.w	#759,d7			;760 empty words				
		bsr.s	fill_zero		;Fill file with $0000

		move.w	handle(pc),-(sp)	;File handle
		move.w	#$3E,-(sp)		;Close file
		trap	#1			;Gemdos
		addq.l	#4,sp

close_window:	move.w	w_handle(pc),int_in	;Window handle
		aes	wind_close
		aes	wind_delete
		dc.w	$A009			;Show mouse

abort_acc:	move.w	#2,int_in		;Enable Mouse
		aes	wind_update
		movem.l	(sp)+,d0-a6		;Restore registers
		rts				;End of program

fill_zero:	pea	file_start-2(pc)	;Blank word
		move.l	#2,-(sp)		;4 bytes
		move.w	handle(pc),-(sp)	;File handle
		move.w	#$40,-(sp)		;Write data
		trap	#1			;Gemdos
		lea	12(sp),sp
		dbf.w	d7,fill_zero		;Next word
		rts

extension:	dc.b	'\*.PI3',0,0		
file_start:	dc.w	$0002,$0777
acc_name:	dc.b	'  GeniScan Scanner',0
fsel_message:	dc.b	'Select file for scanned image',0
alert:		dc.b	'[0][ ½ Lars-Erik ²sterud  1991|'
	 	dc.b	'---------------------------  |'
		dc.b	' Scan complete, what now ?]'
		dc.b	'[ Scan |Save|Quit]',0

		section bss

		even
msgbuff:	ds.w	16	;Message buffer
file_path:	ds.b	80	;File path
file_name:	ds.b	14	;File name
w_handle:	ds.w	1	;Window handle
save_ssp:	ds.l	1	;Old stack adress
handle:		ds.w	1	;Place for file handle
screen:		ds.l	1	;Adress for screen start
