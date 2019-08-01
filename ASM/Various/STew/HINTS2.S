
**************************************************************************

;HITS AND TIPS II FOR STAMPEDE ATARI ST JUNE ISSUE 1990.
;Compiled by Stew.

;This requires a full working version of Devpac to run

;the following code is aimed at new comers to the 68000.
;all the routines below may be freely used and we hope that
;you find the comments very useful.

;This months stampede is a routine which allows you to load up
;a standard degas PI1 file in medium resolution and display it. The
;program, when run prompts you for a file name. Enter the name of you
;picture and press return. The disk drive should start up and the
;picture will be loaded in. All going well, the picture will be
;displayed and the program will way for you to press a key. Control
;will then be passed to GEM.
;As a example, try entering GUABTITL.PI1 and see the picture load up.
;Don't forget to specify the drive "A:GUABTITL.PI1".

;If you don't fully understand the code but are trying to learn, I
;would suggest purchasing books like the ATARI ST INTERNALS published
;by Abacus Software, and/or SYBEX Programming The 68000.


;first lets assign some variables using the EQUate function.

lowres	equ	0
medres	equ	1
hires	equ	2

;now the code begins. the entire program has been split up
;into routines which are called using BSR (branch to subroutine)
;and the routine is finished using RTS (return from subroutine)

codego	dc.w	$a00a	;turn off mouse
	bsr	mypalette	;set screen colors
	bsr	savemode	;save current screen mode
	bsr	setmode	;low res screen
	bsr	inputname	;get the filename
	bsr	loadfile	;get the data into a file
	bsr	displayfile	;show what has been loaded
	bsr	waitkey	;wait for user response
	bsr	restorepalette	;restore gem palette
	bsr	restoremode	;back to old screen mode
exittogem	clr.w	-(sp)	;function 0-terminate program
	trap	#1	;now go back to gem

;now that the main routines have been executed we tell the
;program to halt and wait for the user to press a key. this
;is done via the trap #1 call.

waitkey	move.w	#$0001,-(sp)	;function 1-conin
	trap	#1	;wait for a key
	addq.l	#2,sp
	rts

;the following routines simply set the st's screen
;colours using trap #14, function 6. the colours are
;actually placed into the hardware locations $ffff8240.

restorepalette	move.l	#gempal,-(sp)	;address of palette in memory
	move.w	#$0006,-(sp)	;function 6-setpalette
	trap	#14	;set the palette
	addq.l	#6,sp
	rts

;as the st has more than 1 mode and we wish to use mode 0, low res,
;we must save the current screen mode (a number between 0 and 2)
;in a variable for resetting later. Trap 14, function 4, gets the
;mode number and returns it in d0

savemode	move.w	#4,-(sp)
	trap	#14
	addq.w	#2,sp
	move.w	d0,oldrez
	rts

;now we set the screen mode using function 5-trap 14. this also
;allows us to set where the st fetches the data for the screen.

setmode	move.w	#lowres,-(sp)	;place mode required on stack
	move.l	#-1,-(sp)	;dont effect screen address
	move.l	#-1,-(sp)	;dont effect screen address
	move.w	#$0005,-(sp)	;function 5-setscreen
	trap	#14	;set the screen resolution
	add.l	#12,sp
	rts

;now that the program has finished we must restore the screenmode
;to its original mode using trap 14, function 5, setscreen.
;the mode is pulled from the variable oldscreenmode.

restoremode	move.w	oldrez,-(sp)
	pea	-1
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp
	rts

;firstly we prompt the user to enter a filename

inputname	pea	introtext
	move.w	#$09,-(sp)
	trap	#1
	addq.w	#6,sp

	pea	filename
	move.w	#$0a,-(sp)
	trap	#1
	addq.w	#6,sp
	rts

;now we load the file specified in introtext into picturebuffer
;we know where the file is, what it is called and that it is 32066
;bytes long.
;to load a file into memory we must first open the file, then read
;all the data and finally close the file. because gem can handle
;more than 1 file being open at once it must be able to recognise
;the individual files. this is done using the file handle. when
;a file is open or created it is given a unique filehandle and to
;access the file for read/write/close the filehandle must be given.

loadfile	move.w	#0,-(sp)	;read file only
	pea	filestart	;name of file
	move.w	#$3d,-(sp)	;function
	trap	#1	;open the file
	addq.w	#8,sp
	tst.l	d0	;error occured ?
	bmi	errorreturn	;yes, quit load
	move.w	d0,filehandle

	pea	loadingmessage	;start of text
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp

	pea	picturebuffer	;start of where to load
	pea	32066	;size of file
	move.w	filehandle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.w	#12,sp
	tst.l	d0	;error occured in load?
	bmi	errorreturn	;yes, quit load

	move.w	filehandle,-(sp)
	move.w	#$3e,-(sp)	;close file
	trap	#1
	addq.w	#4,sp
errorreturn	rts

;now we display the file. this is done through 3 routines, getscreenbase,
;setpalette and drawpicture.

displayfile	bsr	getscreenbase
	bsr	setpalette
	bsr	drawpicture
	rts

;now that the file has been loaded, we can display the data on the
;screen. the first thing to do is to get the address in memory
;of the screen. this is not fixed. 520 st's have a different
;screen location to 1040 st's. trap #14 function 2 returns the
;screen address in d0

getscreenbase	move.w	#2,-(sp)
	trap	#14
	addq.w	#2,sp
	move.l	d0,screenbase
	rts

;the palette for a degas screen is stored 2 bytes into the picture
;and is 32 bytes long.

setpalette	move.l	#picturebuffer+2,-(sp)	;address of palette in memory
	move.w	#$0006,-(sp)	;function 6-setpalette
	trap	#14	;set the palette
	addq.l	#6,sp
	rts

;degas stores the actual screen data 34 bytes into the file. to display
;this we must copy the data up to the screen location.

drawpicture	lea	picturebuffer+34,a0 ;get the data from here
	move.l	screenbase,a1	;put the data here
	move.w	#32000-1,d7	;loop counter
copyiton	move.b	(a0)+,(a1)+	;copy data up
	dbra	d7,copyiton	;do all screen data
	rts

;change the palette to out own colours

mypalette	pea	mypal	;palette address
	move.w	#6,-(sp)
	trap	#14
	addq.w	#6,sp
	rts

**************************************************************************

;reserved space for variables

loadingmessage	dc.b	13,10,10,"Loading file....",0

introtext	dc.b	"Screen displayer",13,10,10
	dc.b	"Please enter a filename",13,10
	dc.b	"Maximum of 40 characters",13,10,10
	dc.b	0

filename	dc.b	40	;40 characters long
	dc.b	0	;length of string input
filestart	ds.b	40	;the data starts here
	even

oldrez	dc.w	0
screenbase	dc.l	0
filehandle	dc.w	0

gempal	dc.w	$777,$700,$070,$000,$111,$222,$333,$444
	dc.w	$555,$000,$001,$010,$100,$200,$020,$002
mypal	dc.w	$777,$007,$007,$007,$007,$007,$007,$007
	dc.w	$007,$007,$007,$007,$007,$007,$007,$007

;the following buffer is used to store the picture before it is
;drawn onto the screen. the section bss is a special command
;used on devpac which tells the program to reserve the memory
;allocated in the ds. sections on loading the assembled program.
;this simply saves disk space.


	section	bss
picturebuffer	ds.b	32066	;save for piccy
