* PROGRAM TO CONVERT STANDARD ATARI FORMATTED DISCS TO FAST FORMAT *
* BY PHIL LAWSON FOR ATARI ST USER (C)1989 *
* IT WILL ALSO KILL ANY VIRUS PRESENT *

***************************************
* TO CALL THE PRINT ROUTINE:          *
*	A6=ADDRESS OF STRING TO PRINT *
***************************************

***************************************
* TO CALL THE GET KEY ROUTINE:        *
*    D6=SCANCODE VALUE OF KEY1        *
*    D7=SCANCODE VALUE OF KEY2        *
* THE PRESSED KEY IS RETURNED IN D5   *
***************************************

	jmp start

cls	dc.b 27,'H',27,'E'
	dc.b 0
mess1	dc.b 'Which disc drive [A] or [B]?',10,13
	dc.b 0
	even
driva	dc.b 'Insert disc into drive A',10,13
	dc.b 0
	even
drivb	dc.b 'Insert disc into drive B',10,13
	dc.b 0
	even
spbar	dc.b 'Press the spacebar to continue.',10,13
	dc.b 0
	even
vir	dc.b 'This disc may have a VIRUS on it.',10,13
	dc.b 'Shall I get rid of it for you? [Y] or [N]',13,10
	dc.b 0
	even
final	dc.b 10,13,'About to convert disc.',10,13
	dc.b 'Continue or Return? [C] or [R]',10,13
	dc.b 0
	even
done	dc.b 10,13,'Finished. Returning to desktop',10,13
	dc.b 0
	even
error	dc.b 'An error has occurred while reading the disc.',10,13
	dc.b 'Returning to the desktop',10,13
	dc.b 0
	even
wrong	dc.b 'The drive is single sided,',10,13
	dc.b 'and the disc is double sided.',10,13
	dc.b 'Returning to desktop.',10,13
	dc.b 0
	even
strd	dc.b 'This disc is not 9 sectors, or',10,13
	dc.b 'not 80 or 81 or 82 tracks.',10,13
	dc.b 'Returning to desktop.',10,13
	dc.b 0
	even

drivs	dc.b 0;		How many drives 0 or 1
	even
sides	dc.b 0;		How many sides on disc
	even
virus	dc.b 0;		=1 if a virus is to be killed
	even
tracks	dc.b 79;	=79,80 or 81 tracks (+1)
	even
sects	dc.b 9;		=9 sectors
	even

sperd	dc.w 0;		Sectors per disc
	even

***************************************
*     FIND THE END OF THE PROGRAM     *
*                                     *
*     SET THE FOLLOWING REGISTERS     *
*  A4=BUFFER FOR READ/WRITE SECTORS   *
*   A5=BUFFER FOR FORMATTING DISC     *
***************************************
start
	move.l a7,a5
	move.l 4(a5),a5
	move.l 12(a5),d0
	add.l 20(a5),d0
	add.l 28(a5),d0
	add.l #$400+$100,d0
	move.l d0,d1
	add.l a5,d1
	and.l #-2,d1
	move.l d1,a4
	move.l d1,a5
	add.l #10000,a5
	add.l #20000,d1
	move.l d1,a7


***************************************
*        NOW CLEAR THE SCREEN	      *
***************************************

	move.l #cls,a6
	jsr print_it


***************************************
*  FIND OUT HOW MANY DRIVES ATTACHED  *
***************************************

	move.w #10,-(a7)
	trap #13
	add.l #2,a7

	add.b #-1,d0
	lsr.b #1,d0
	move.b d0,(drivs);	If one drive (%01) else if two (%11)
	cmp.b #0,d0
	beq put_in_disc;	If one drive dont ask which one


***************************************
*      ASK WHICH DRIVE TO USE         *
***************************************

	move.l #mess1,a6
	jsr print_it

	move.b #30,d6;	scancode for A
	move.b #48,d7;	scancode for B
	jsr get_key

	move.b d5,(drivs);		Drive A=0, Drive B=1


***************************************
*       PUT DISC IN DRIVE A/B         *
***************************************
put_in_disc
	move.l #driva,a6
	move.b (drivs),d0;	Which drive 0 or 1
	cmp.b #0,d0
	beq got_it;		Already pointing to DRIVE A message
	move.l #drivb,a6
got_it	jsr print_it;		Put disc in drive A/B
	move.l #spbar,a6
	jsr print_it;		Press spacebar
	move.b #57,d6;		Scancode for spacebar
	move.b #57,d7;		   "      "      "
	jsr get_key

***************************************
***************************************
** THE DISC IS NOW IN THE RIGHT DRIVE**
***************************************
***************************************


***************************************
*    CHECK IF EVERYTHING IS CORRECT   *
***************************************

;get the number of sectors per track

	move.w #0,d7;		Side number zero
	move.w #0,d6;		Track number zero
	move.l a4,a6;		Buffer to store data
	move.l #0,d3
	move.b (drivs),d3
	jsr read_track

;Now get the number of tracks on disc

get_tracks
	move.l #0,d0;		Make sure these are
	move.l d0,d1;		completely zero.
	move.b 19(a6),d0;	Sectors per disc are stored
	move.b 20(a6),d1;	in bytes 19 and 20 of boot sector.
	lsl.w #8,d1;		x256
	add.w d1,d0;		D0=SECTORS PER DISC
	move.w d0,(sperd)

***************************************
*get sides of disc from no. of sectors*
***************************************
	move.l d0,d2
	divu.w #1000,d2
	move.b d2,(sides)

	move.w #0,d1
	move.b (sects),d1;	Sectors per track
	divu.w d1,d0;		Sectors per disc
	move.b (sides),d2
	lsr.w d2,d0
	add.b #-1,d0
	move.b d0,(tracks);	TRACKS PER DISC  = D0/D1


***************************************
* ONLY WORKS ON DISCS WITH 80,81 OR 82*
*               TRACKS                *
***************************************
	cmp.b #79,d0
	beq check_disc
	cmp.b #80,d0
	beq check_disc
	cmp.b #81,d0
	beq check_disc
	bne not_standard


***************************************
*   ONLY WORKS ON DISCS WITH 9 OR 10  *
*          SECTORS PER TRACK          *
***************************************
check_disc
	move.b (sects),d0
	cmp.b #9,d0
	bne not_standard

so_far_so_good

;Try reading first track of disc from specified drive
;If double sided then read from side two

	move.b (sides),d7
	move.w #0,d6
	move.l a4,a6
	move.l #0,d3
	move.b (drivs),d3
	jsr read_track
	cmp.l #0,d0
	bne wrong_selections


***************************************
*           CHECK FOR VIRUS           *
***************************************
check_virus
	move.w (a6),d0
	cmp.w #0,d0;	If these bytes are not zero
	beq convert;	the disc may have a virus on it.
	jsr found_virus


***************************************
***************************************
*        NOW CONVERT THE DISC         *
***************************************
***************************************
convert
	move.l #final,a6
	jsr print_it
	move.b #46,d6;		scancode for C
	move.b #19,d7;		Scancode for R
	jsr get_key
	cmp #0,d5
	beq go_ahead
	move.w #0,-(a7);	Pressed R for return
	trap #1;		so return to desktop


go_ahead
	move.l a5,a3
	move.l a4,a6
	move.b (tracks),d6
	move.l #0,d3
	move.b (drivs),d3
loop1	move.w #0,d7
	move.b (sides),d7
loop2	jsr read_track
	cmp.l #0,d0;		If a read error has occurred
	bne read_error;		tell the user and return to desktop

	cmp.b #0,d6;		Track zero is the one containing the
	beq track_zero;		offset to any virus present
back2	jsr format_track
	jsr write_track
	dbra d7,loop2
	dbra d6,loop1	

***************************************
*    CONVERSION PROCESS COMPLETED     *
***************************************

;return to desktop
	move.l #done,a6
	jsr print_it
out	move.l #spbar,a6
	jsr print_it
	move.b #57,d6
	move.b #57,d7
	jsr get_key;		wait until spacebar pressed
	move.w #0,-(a7)
	trap #1;		back to desktop


read_error
	move.l #error,a6
	jsr print_it
	bra out


***************************************
*    GET RID OF THE VIRUS OFFSET      *
***************************************
track_zero
	cmp.b #0,d7;		Are we on side zero?
	bne back2
	move.w (a6),d0;		get first two bytes of sector
	cmp.w #0,d0; 		If zero then no virus present
	beq back2
	move.b (virus),d0;	If zero then get rid of virus
	cmp.b #1,d0;		else if 1 then dont
	beq back2

	move.w #0,d0
	move.w d0,(a6);		Remove virus offset
	bra back2

	

***************************************
* TO USE THE READ TRACK ROUTINE:      *
*    A6=ADDRESS OF BUFFER             *
*    D7=SIDE 0 or 1                   *
*    D6=TRACK NUMBER                  *
***************************************
read_track
	move.w #9,-(a7);	nine sectors
	move.w d7,-(a7);	which side
	move.w d6,-(a7);	which track
	move.w #1,-(a7);	start at sector 1
	move.w d3,-(a7);	which drive 0 or 1
	move.l #0,-(a7);	unused bytes
	move.l a6,-(a7);	buffer to store data
	move.w #8,-(a7);	function number
	trap #14
	add.w #20,a7
	rts

***************************************
* TO USE THE FORMAT TRACK ROUTINE:    *
*    A3=ADDRESS OF BUFFER             *
*    D7=SIDE 0 or 1                   *
*    D6=TRACK NUMBER                  *
***************************************
format_track
	move.w #$E5E5,-(a7);		Format code
	move.l #$87654321,-(a7);	Magic number
	move.w #11,-(a7);		Interleave factor
	move.w d7,-(a7)
	move.w d6,-(a7)
	move.w #9,-(a7);		Sectors to format
	move.w d3,-(a7);		Which drive to format
	move.l #0,-(a7);		Unused bytes
	move.l a3,-(a7);		Buffer for formatting
	move.w #10,-(a7);		function number
	trap #14
	add.w #26,a7
	rts

***************************************
* TO USE THE WRITE TRACK ROUTINE:     *
*    A6=ADDRESS OF BUFFER             *
*    D7=SIDE 0 or 1                   *
*    D6=TRACK NUMBER                  *
***************************************
write_track
	move.w #9,-(a7);	nine sectors
	move.w d7,-(a7);	which side
	move.w d6,-(a7);	which track
	move.w #1,-(a7);	start at sector 1
	move.w d3,-(a7);	which drive 0 or 1
	move.l #0,-(a7);	unused bytes
	move.l a6,-(a7);	buffer to get data from
	move.w #9,-(a7);	function number
	trap #14
	add.w #20,a7
	rts

***************************************
***************************************	

wrong_selections
	move.l #wrong,a6
	jsr print_it
	move.l #spbar,a6
	move.b #57,d6
	move.b #57,d7
	jsr get_key
	move.w #0,-(a7)
	trap #1

***************************************
***************************************
not_standard
	move.l #strd,a6
	jsr print_it
	move.l #spbar,a6
	jsr print_it
	move.b #57,d6
	move.b #57,d7
	jsr get_key
	move.w #0,-(a7)
	trap #1






***************************************
*    ROUTINE TO PRINT STRING AT A6    *
***************************************
print_it
	move.l a6,-(a7)
	move.w #9,-(a7)
	trap #1
	add.w #6,a7
	rts

***************************************
*  FOUND A VIRUS. GET RID OF IT Y/N   *
***************************************
found_virus
	move.l #vir,a6;		Found virus message
	jsr print_it
	move.b #21,d6;		Scancode for Y
	move.b #49,d7;		Scancode for N
	jsr get_key
	move.b d5,(virus)
	rts


***************************************
*    GET A KEYPRESS FROM KEYBOARD     *
* KEYS TO LOOK FOR STORED IN D6 & D7  *
*                                     *
*    KEY PRESSED IS RETURNED IN D5    *
***************************************
get_key
	move.l #255,d2
loop3	move.w #255,-(a7);	Wait until
	move.w #6,-(a7);	the user
	trap #1;		is not
	add.w #4,a7;		pressing the
	swap d0;		keyboard
	and d2,d0
	cmp.l #0,d0
	bne loop3

loop4	move.w #255,-(a7)
	move.w #6,-(a7)
	trap #1
	add.w #4,a7
	swap d0
	and d2,d0;		Wait until
	cmp.l #0,d0;		a key has
	beq loop4;		been pressed

; check if pressed key is one of those wanted

; The required keys are stored in D6 and D7

	cmp.b d6,d0
	beq got_the_key
	cmp.b d7,d0
	bne loop4

got_the_key

; if the pressed key is D6 then return value of zero
; in d5, otherwise the pressed key was in D7, so
; return the value of one

	move.b #0,d5
	cmp.b d6,d0
	beq return
	add.b #1,d5
return	rts
