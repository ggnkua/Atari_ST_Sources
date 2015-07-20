;+-------------------------------------------------------+
;| Lump/Chunk Loader for Automation Packer v5.01         |
;|                                                       |
;| Re-assembled for a readable source listing by IWWWTTI |
;|                                                       |
;| Update no. 4 - 4th February 1992                      |
;|                                                       |
;| (I hereby apologise for the cocked up source in my    |
;| revision 3 in October 1991 !!!                        |
;|                                                       |
;| Extra thanks must go to MUG U.Kø for writing the much |
;| better Lumpfile Generator - thanks mate !!            |
;+-------------------------------------------------------+
;
; Seeing as my last revision was totally cocked up I decided to redo it all
; from scratch!  This source was based on a lump-loader from a naughty game
; packed by TBE.  Therefore you knew it worked ...... and then I got near it !!
;
; It took me over two hours to tidy this source up from it's .PRG format
; via EasyRider 4 and then to Devpac (including porting across variable names !!)
; and re-instating my conditional bits and pieces (oo-er missus !!).
;
; All the options from revision 3 are still here, plus the option to test
; the end users machine for the availability of 1 Meg or not.  It's up to
; you to alter the warning that 512K owners get if they load a 1 Meg only lump !!
;
; Improvements on original v5.01 lump/chunk routine;

; 1) The source listing is readable (but not as readable as revision 3 - but what the hell !!)
; 2) Text ON/OFF
; 3) Wait for key ON/OFF
; 4) Set Low resolution ON/OFF
; 5) Restore TRAP #1 original address after quitting (no bombs !!)
;    Ideal for GEM-based programs !!
; 6) Colour Flash ON/OFF (now there are 5 different flashes - oo-er!!)
; 7) Test for 1 Megabyte only programs
; 8) It works (unlike revision 3 !!!)
;
; If you don't want to do a lump file, set the 'lump' equ to
; be 'no' and you will have a chunk-loader.  I worked out Devpacs' "elseif"
; command !!
;

	opt	o+,ow-		; lots of optimisations, but don't tell me !!

yes	equ	1
no	equ	0

buff_len	equ	8192	; put chunk size used or 0
max_files	equ	10	; max. number of files open +6
buffhead	equ	"AU5$"
normhead	equ	"AU5!"
chnkhead	equ	"AU5C"

;
; Conditional Assembly Bits - change to 'yes' or 'no'
;

lump	equ	yes	; yes = lump load /  no = chunk load
;chunk	equ	no	; chunk depack files only

text_on	equ	yes	; print text ??
wait_on	equ	yes	; wait for key ??
low_res	equ	no	; low resolution
restore84	equ	no	; upon quit $84 is restored ??
flash	equ	yes	; colour flashes while depacking
meg_only	equ	no	; yes = prog needs 1 Meg to run !!


; If you look at the 'flash' section, you will find five F/X options
; and four of them are REMmed out.  Use your own or one of these
; five pre-prepared ones - it's up to you !!!!

	bra	main

; The following table SHOULD contain all the possible lump files
; on a disk.  Eg. if you have a two disk game, and both disks are
; in seperate files, then enter each filename here.  Make sure that
; they are exactly 16 characters in length !!
;

	ifne	lump
srchs	dc.b	"balls.lnk",0,0,0,0,0,0,0	; lump files
	elseif
srchs	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; chunk files
	endc

endsrch	dc.w	0

;
; The original loader goes in here
;
execfile	dc.b "balls.dat",0
	even
;
; Text message
;
	ifne text_on
		;1234567890123456789012345678901234567890 - 40 chars

text	dc.b	27,'E'
	dc.b	27,'Y',32+10,32+05,"Adrenalin of T.B.A. presents"
	dc.b	27,'Y',32+13,32+16,"BALLS"
	dc.b	27,'Y',32+16,32+06,"Packed and Linked by Mookie"
	dc.b	27,'Y',32+18,32+08,"Press a key to continue."
	dc.b	0
	even
	endc

main	movea.l   4(A7),A5
	move.l    12(A5),D0 
	ADD.L     20(A5),D0 
	ADD.L     28(A5),D0 
	ADDI.L    #$200,D0
	ADDI.L    #buff_len,D0	; add chunk length
	move.l    D0,-(A7)
	move.l    A5,-(A7)
	move.l    #$4A0000,-(A7)
	trap      #1
	lea       12(A7),A7 

	ifne	low_res
	clr.w	-(a7)
	pea	-1
	pea	-1
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	endc

	ifne	text_on
	dc.w	$a00a
	pea	text
	move.w	#9,-(A7)
	trap	#1
	addq.l	#6,A7 
	dc.w	$a009
	endc
	
	ifne	wait_on
	move.w	#7,-(a7)
	trap	#1		;wait for key
	addq.l	#2,a7
	endc

	move.l    #buff_start,buff_add
	move.l    #srchs,ftablestrt
	move.l    #endsrch,ftableend 

	clr.l     -(A7) 
	move.w    #$20,-(A7)
	trap      #1
	addq.l    #6,A7 
	lea       old_sp(PC),A6 
	move.l    D0,(A6) 

;
; Has user only got 512K ????
;
	ifne	meg_only
	move.l	$42e,d0		; Top of user RAM
	cmp.l	#$00080000,d0	; if it equals $80000
	beq	half_meg		; then get an upgrade !!
	endc	

	move.l    $84.L,old_84
	move.l    #new_84,$84.L 

	move.l    old_sp(PC),-(A7)
	move.w    #$20,-(A7)
	trap      #1
	addq.l    #6,A7 

stkk	clr.l     in_use 
	movea.l   #stkk,A7 
	move.l    #srchs,file_found
	move.l    #-22,file_locn
	clr.l     $60000
	pea       $60000
	pea       $60000
	move.l    #execfile,-(A7)
	move.l    #$4B0000,-(A7)
	trap      #1
	lea       16(A7),A7 

;
; Ensure programs do not bomb out when you quit them !!
; eg. GEM-based programs/utilities etc. by turning the 'restore84'
; flag to 'yes', else leave it at 'no' if the program does not
; have a quit feature - other than the reset-button !!
;

	ifne	restore84		; Yes we want to restore $84
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	lea	old_sp(pc),a6
	move.l	d0,(a6)

	move.l	old_84(pc),$84.w	; reinstall old $84 vector

	move.l	old_sp(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	endc

	move.w	#$4c,-(sp)		; back to desktop via pterm = quit even when called
	trap 	#1			; from a menu !!

;
; trap 512K owners when program requires 1 Meg+ to run !!
;
	ifne	meg_only
half_meg	pea	more_mem(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	move.w	#$4c,-(sp)
	trap	#1

more_mem	dc.b	27,"E",27,"p"
	dc.b	"NOT ENOUGH MEMORY !!",27,"q",13,10
	dc.b	"--------------------",13,10,10
	dc.b	"You require 1 megabyte or",13,10
	dc.b	"more to run this program !",13,10,10
	dc.b	"Press any key !!",13,10
	dc.b	0
	even
	endc



new_84	tst.w     inside 
	bne       bye_bye 
	movem.l   A0-A6/D0-D7,registers 
	movea.l   A7,A1 
	addq.l    #6,A1 
	move.w    (A7),D0
	BTST      #13,D0	; are we in supervisor
	bne.s     super
	MOVE      USP,A1

super	cmpi.w    #$3D,(A1) 
	beq       F_OPEN
	cmpi.w    #$3F,(A1) 
	beq       F_READ
	cmpi.w    #$3E,(A1) 
	beq       F_CLOSE 
	cmpi.w    #$3C,(A1) 
	beq       F_CREATE
	cmpi.w    #$40,(A1) 
	beq       F_WRITE 
	cmpi.w    #$42,(A1) 
	beq       F_SEEK
	cmpi.w    #$4E,(A1) 
	beq       F_SFIRST
	cmpi.w    #$4F,(A1) 
	beq       F_SNEXT 
	cmpi.w    #$45,(A1) 
	beq       F_DUP 
	cmpi.w    #$46,(A1) 
	beq       F_FORCE 

L0008:            movem.l   registers(PC),A0-A6/D0-D7 

bye_bye		dc.w	$4ef9
old_84		dc.l	0

F_OPEN:           move.w    #1,inside
		bsr	emptyone
                  move.l    D0,D7 
                  move.l    D0,D6 
                  movea.l   A0,A5 
                  movea.l   2(A1),A6
                  move.w    6(A1),-(A7) 
                  move.l    A6,-(A7)
                  move.w    #$3D,-(A7)
                  trap      #1
                  addq.l    #8,A7 
                  tst.l     D0
                  bpl	what_error
******************************************************************
*insert for lump load
*input	d7=fake handle
*	a6=filename
*trashes almost everything
*output	d0=error or fake filehandle
*lets rockkkkkkkkkkkkkkkkkkkkkkkkkkkkkk!
******************************************************************

                  clr.l     D6
                  movea.l   A6,A0 
                  movea.l   ftablestrt,A4
                  bsr       L0057 
                  tst.l     D0
                  bmi       L0041 
                  lea       real_hand,A1
                  move.l    D7,D6 
                  lsl.l     #2,D6 
                  move.l    D0,0(A1,D6.W) 
                  lea       so_read,A1
                  clr.l     0(A1,D6.W)
                  lea       chunked,A1
                  move.l    A4,0(A1,D6.W) 
                  lea       f_lengths,A1
                  move.l    14(A0),0(A1,D6.W) 
                  lea       offsets,A1
                  move.l    18(A0),0(A1,D6.W) 
                  clr.l     D0
                  movea.l   buff_add,A0
                  move.w    200(A0),D0
                  mulu      #$16,D0 
                  addq.l    #2,D0 
                  ANDI.L    #$FFFF,D0 
                  ADD.L     D0,0(A1,D6.W) 
                  move.l    D7,D6 
                  lsl.l     #5,D7 
                  lea       f_names,A0
                  adda.l    D7,A0 
                  movea.l   A6,A2 
L000C:            move.b    (A2)+,(A0)+ 
                  bne.s     L000C 
                  bra       not_good 

what_error:            move.l    D0,D4 
                  clr.l     i_buff 
                  pea       i_buff 
                  move.l    #8,-(A7)
                  move.w    D4,-(A7)
                  move.w    #$3F,-(A7)
                  trap      #1
                  lea       12(A7),A7 
                  clr.w     -(A7) 
                  move.w    D4,-(A7)
                  clr.l     -(A7) 
                  move.w    #$42,-(A7)
                  trap      #1
                  lea       10(A7),A7 
                  movea.l   A6,A4 
                  move.l    #$1F,D0 
c_loop            move.b    (A6)+,(A5)+ 
                  dbf       D0,c_loop
                  
                  lsl.l     #2,D7 
                  lea       so_read,A0
                  move.l    #0,0(A0,D7.W) 
                  lea       offsets,A0
                  move.l    #0,0(A0,D7.W) 
                  cmpi.l    #buffhead,i_buff
                  beq.s     L000F 
                  lea       real_hand,A0
                  move.l    D4,0(A0,D7.W) 
                  lea       chunked,A0
                  move.l    #0,0(A0,D7.W) 
                  cmpi.l    #chnkhead,i_buff
                  bne       not_good 
                  move.l    #-1,0(A0,D7.W) 
                  lea       f_lengths,A0
                  move.l    i_len,0(A0,D7.W)
                  bra       chk_same 

L000F:            lea       f_lengths,A0
                  move.l    i_len,0(A0,D7.W)
                  lea       real_hand,A0
                  move.l    #-1,0(A0,D7.W) 
                  lea       chunked,A0
                  move.l    #0,0(A0,D7.W) 

                  move.w    D4,-(A7)
                  move.w    #$3E,-(A7)
                  trap      #1
                  addq.l    #4,A7 

chk_same	lea       file_loaded_name,A5
still_same	tst.b	(a4)
		beq.s	same_file
		cmpm.b	(a4)+,(a5)+ 
		beq.s	still_same
		bra.s     not_good 
same_file	tst.b     (A5)
		bne.s     not_good 
		move.l    D6,in_use
not_good	clr.w     inside 
                  move.l    D6,-(A7)
                  movem.l   registers,A0-A6/D0-D7 
                  move.l    (A7)+,D0
                  rte 

F_READ:           clr.l     D0
                  move.w    2(A1),D0
                  tst.w     D0
                  bmi       L0015 
                  move.w    D0,D1 
                  lsl.l     #2,D1 
                  lea       real_hand,A0
                  move.l    0(A0,D1.W),D2 
                  CMP.W     #$FFFF,D2 
                  beq       L0019 
                  lea       chunked,A0
                  move.l    0(A0,D1.W),D3 
                  tst.l     D3
                  bne       L001F 
L0015:            move.w    #1,inside
                  move.l    8(A1),D7
                  move.l    D7,-(A7)
                  move.l    4(A1),-(A7) 
                  move.w    D2,-(A7)
                  move.w    #$3F,-(A7)
                  trap      #1
                  lea       12(A7),A7 
                  move.l    D0,D5 
                  movea.l   D7,A0 
                  clr.l     D0
                  move.b    (A0),D0 
                  lsl.w     #8,D0 
                  move.b    1(A0),D0
                  swap      D0
                  move.b    2(A0),D0
                  lsl.w     #8,D0 
                  move.b    3(A0),D0
                  cmp.l     #normhead,D0 
                  bne       L0031 
                  lea       -200(A0),A1 
                  movea.l   A1,A2 
                  lea       tmp_sav,A3
                  move.l    #$C7,D1 
L0016:            move.b    (A2)+,(A3)+ 
                  dbf       D1,L0016
L0017:            move.b    (A0)+,(A1)+ 
                  subq.l    #1,D5 
                  bne.s     L0017 
                  movea.l   A2,A1 
                  lea       -200(A1),A0 
                  move.l    A0,-(A7)
                  bsr       ice_depack
                  movea.l   (A7)+,A0
                  lea       tmp_sav,A1
                  move.l    #$C7,D1 
L0018:            move.b    (A1)+,(A0)+ 
                  dbf       D1,L0018
                  bra       L0031 
L0019:            cmp.l     in_use,D0
                  beq       L001B 
                  movea.l   A1,A5 
                  move.w    #1,inside
                  move.l    D0,in_use
                  lsl.l     #5,D0 
                  lea       f_names,A0
                  adda.l    D0,A0 
                  movea.l   A0,A1 
                  lea       file_loaded_name,A2
                  move.w    #$1F,D0 
L001A:            move.b    (A1)+,(A2)+ 
                  dbf       D0,L001A
                  clr.w     -(A7) 
                  move.l    A0,-(A7)
                  move.w    #$3D,-(A7)
                  trap      #1
                  addq.l    #8,A7 
                  move.w    D0,D6 
                  move.l    buff_add,-(A7) 
                  move.l    #$2008,-(A7)
                  move.w    D0,-(A7)
                  move.w    #$3F,-(A7)
                  trap      #1
                  lea       12(A7),A7 
                  move.w    D6,-(A7)
                  move.w    #$3E,-(A7)
                  trap      #1
                  addq.l    #4,A7 
                  clr.w     inside 
                  movea.l   buff_add,A0
                  lea       200(A0),A1
                  move.l    4(A0),D7
                  bsr       ice_depack
                  movea.l   A5,A1 
L001B:            move.l    4(A1),D0
                  move.l    D0,D5 
                  movea.l   8(A1),A0
                  move.l    in_use,D1
                  lsl.l     #2,D1 
                  lea       so_read,A2
                  lea       f_lengths,A3
                  move.l    0(A2,D1.W),D2 
                  move.l    0(A3,D1.W),D3 
                  movea.l   buff_add,A1
                  lea       200(A1),A1
                  adda.l    D2,A1 
L001C:            move.b    (A1)+,(A0)+ 
                  addq.l    #1,D2 
                  cmp.l     D2,D3 
                  blt.s     L001D 
                  subq.l    #1,D0 
                  bne.s     L001C 
                  bra.s     L001E 
L001D:            move.l    D3,D2 
L001E:            move.l    D2,0(A2,D1.W) 
                  sub.l     D0,D5 
                  bra       L0031 
L001F:            move.w    #1,inside
                  cmp.l     in_use,D0
                  beq       L0021 
                  move.l    D0,in_use
                  lea       chunked,A0
                  movea.l   0(A0,D1.W),A5 
                  cmpa.l    file_loaded_name,A5
                  beq       L0021 
                  movea.l   A1,A5 
                  lsl.l     #5,D0 
                  lea       f_names,A1
                  adda.l    D0,A1 
                  lea       file_loaded_name,A2
                  move.w    #$1F,D0 
L0020:            move.b    (A1)+,(A2)+ 
                  dbf       D0,L0020
                  move.l    D2,D7 
                  clr.w     -(A7) 
                  move.w    D7,-(A7)
                  clr.l     -(A7) 
                  move.w    #$42,-(A7)
                  trap      #1
                  lea       10(A7),A7 
                  pea       i_buff 
                  move.l    #$400,-(A7) 
                  move.w    D7,-(A7)
                  move.w    #$3F,-(A7)
                  trap      #1
                  lea       12(A7),A7 
                  move.l    i_len,D0
                  move.l    L00A7,D2
                  subq.l    #1,D2 
                  eori.l    #-1,D2 
                  and.l     D2,D0 
                  move.l    D0,L00A4
                  move.l    #-1,mini
                  movea.l   A5,A1 
                  move.l    D7,D2 
                  move.l    in_use,D0
                  move.l    D0,D1 
                  lsl.l     #2,D1 
L0021:            lea       so_read,A0
                  move.l    0(A0,D1.W),D4 
                  move.l    4(A1),D5
                  move.l    D4,D7 
                  ADD.L     D5,D7 
                  cmp.l     D4,D7 
                  blt.s     L0022 
                  lea       f_lengths,A0
                  cmp.l     0(A0,D1.W),D7 
                  blt       L0023 
L0022:            move.l    0(A0,D1.W),D7 
L0023:            sub.l     D4,D7 
                  move.l    D7,D5 
                  movea.l   8(A1),A4
                  movea.l   A4,A5 
                  adda.l    D5,A5 
                  suba.l    #1,A5 
                  tst.l     D5
                  beq       L0031 
                  lea       so_read,A0
                  lea       offsets,A1
                  move.l    0(A1,D1.W),D0 
                  ADD.L     D0,0(A0,D1.W) 
                  move.w    D2,L009C
                  move.l    D5,D2 
                  lea       so_read,A0
                  move.l    0(A0,D1.W),D0 
                  movea.l   D0,A2 
                  movea.l   A2,A3 
                  move.l    L00A7,D3
                  subq.l    #1,D3 
                  and.l     D3,D0 
                  move.l    D3,D7 
                  move.l    D0,D6 
                  eori.l    #-1,D3 
                  move.l    A2,D0 
                  and.l     D3,D0 
                  move.l    D0,D4 
                  adda.l    D5,A3 
                  move.l    A3,D5 
                  and.l     D7,D5 
                  move.l    A3,D0 
                  and.l     D3,D0 
                  move.l    D0,D3 
                  sub.l     D4,D0 
                  move.l    L00A7,D7
                  divu      D7,D0 
                  move.l    D0,D7 
                  move.l    D4,D0 
                  move.l    L00A7,D2
                  lea       L00A8,A0
                  cmp.l     L00A4,D0
                  bne.s     L0024 
                  divu      D2,D0 
                  lsl.l     #2,D0 
                  move.l    i_len,D1
                  bra.s     L0025 
L0024:            divu      D2,D0 
                  lsl.l     #2,D0 
                  move.l    4(A0,D0.W),D1 
L0025:            move.l    0(A0,D0.W),D2 
                  move.l    D1,D0 
                  sub.l     D2,D0 
                  cmp.l     mini,D4
                  beq       L0026 
                  move.l    D4,mini
                  clr.w     -(A7) 
                  move.w    L009C,-(A7) 
                  move.l    D2,-(A7)
                  move.l    D0,D2 
                  move.w    #$42,-(A7)
                  trap      #1
                  lea       10(A7),A7 
                  move.l    buff_add,-(A7) 
                  move.l    D2,-(A7)
                  move.w    L009C,-(A7) 
                  move.w    #$3F,-(A7)
                  trap      #1
                  lea       12(A7),A7 
                  movea.l   buff_add,A0
                  lea       200(A0),A1
                  bsr       chunk_up 
                  bra       L0027 
L0026:            tst.l     D7
                  beq       L002C 
                  clr.w     -(A7) 
                  move.w    L009C,-(A7) 
                  move.l    D1,-(A7)
                  move.w    #$42,-(A7)
                  trap      #1
                  lea       10(A7),A7 
L0027:            cmp.l     #1,D7 
                  BLE       L002C 
                  move.l    D7,-(A7)
                  lsl.l     #2,D7 
                  move.l    D4,D0 
                  move.l    L00A7,D2
                  lea       L00A8,A0
                  divu      D2,D0 
                  lsl.l     #2,D0 
                  move.l    4(A0,D0.W),D1 
                  adda.l    D7,A0 
                  move.l    0(A0,D0.W),D2 
                  move.l    D2,D0 
                  sub.l     D1,D0 
                  movea.l   A4,A6 
                  adda.l    L00A7,A6
                  suba.l    D6,A6 
                  lea       -200(A6),A3 
                  move.l    A3,D7 
                  move.l    #$C7,D1 
                  BTST      #0,D7 
                  beq.s     L0028 
                  addq.l    #1,A3 
                  subq.l    #1,D1 
L0028:            move.l    (A7),D7 
                  move.l    D6,-(A7)
                  move.l    L00A7,D6
                  mulu      D6,D7 
                  move.l    (A7)+,D6
                  adda.l    D7,A6 
                  move.l    (A7)+,D7
                  lea       tmp_sav,A0
                  movea.l   A3,A1 
                  move.l    D1,D2 
L0029:            move.b    (A1)+,(A0)+ 
                  dbf       D1,L0029
                  move.l    A3,-(A7)
                  move.l    D0,-(A7)
                  move.w    L009C,-(A7) 
                  move.w    #$3F,-(A7)
                  trap      #1
                  lea       12(A7),A7 
                  lea       L00A8,A2
                  move.l    D4,D0 
                  move.l    D6,-(A7)
                  move.l    L00A7,D6
                  divu      D6,D0 
                  move.l    (A7)+,D6
                  lsl.l     #2,D0 
                  addq.l    #4,D0 
                  adda.l    D0,A2 
                  move.l    D7,-(A7)
                  lsl.l     #2,D7 
                  subq.l    #4,D7 
                  suba.l    L00A7,A6
L002A:            suba.l    L00A7,A6
                  subq.l    #4,D7 
                  movea.l   A3,A0 
                  move.l    0(A2,D7.W),D0 
                  sub.l     (A2),D0 
                  adda.l    D0,A0 
                  movea.l   A6,A1 
                  bsr       chunk_up 
                  tst.w     D7
                  bne.s     L002A 
                  move.l    (A7)+,D7
                  lea       tmp_sav,A0
                  movea.l   A3,A1 
                  move.l    D2,D1 
L002B:            move.b    (A0)+,(A1)+ 
                  dbf       D1,L002B
L002C:            movea.l   buff_add,A0
                  lea       200(A0),A0
                  addq.l    #1,A5 
                  adda.l    D6,A0 
                  movea.l   A4,A1 
L002D:            cmpa.l    A1,A5 
                  beq.s     L002E 
                  cmp.l     L00A7,D6
                  beq.s     L002E 
                  move.b    (A0)+,(A1)+ 
                  addq.l    #1,D6 
                  bra.s     L002D 
L002E:            subq.l    #1,A5 
                  tst.l     D7
                  beq.s     L0030 
                  tst.l     D5
                  beq.s     L0030 
                  move.l    D3,mini
                  move.l    L00A7,D3
                  mulu      D3,D7 
                  move.l    mini,D3
                  move.l    buff_add,-(A7) 
                  move.l    L00A7,-(A7) 
                  move.w    L009C,-(A7) 
                  move.w    #$3F,-(A7)
                  trap      #1
                  lea       12(A7),A7 
                  movea.l   buff_add,A0
                  lea       200(A0),A1
                  bsr       chunk_up 
                  movea.l   buff_add,A0
                  lea       200(A0),A0
                  movea.l   A5,A1 
                  addq.l    #1,A1 
                  suba.l    D5,A1 
                  subq.l    #1,D5 
L002F:            move.b    (A0)+,(A1)+ 
                  dbf       D5,L002F
L0030:            suba.l    A4,A5 
                  addq.l    #1,A5 
                  move.l    A5,D5 
                  move.l    in_use,D0
                  lsl.l     #2,D0 
                  lea       offsets,A0
                  move.l    0(A0,D0.W),D1 
                  lea       so_read,A0
                  sub.l     D1,0(A0,D0.W) 
                  ADD.L     D5,0(A0,D0.W) 
L0031:            clr.w     inside 
                  move.l    D5,-(A7)
                  movem.l   registers,A0-A6/D0-D7 
                  move.l    (A7)+,D0
                  rte 
F_CLOSE:          clr.l     D0
                  clr.l     D7
                  move.w    2(A1),D7
                  move.l    D7,D6 
                  move.l    D7,D5 
                  move.l    D7,D4 
                  lsl.l     #2,D6 
                  lea       real_hand,A5
                  tst.w     D7
                  bmi.s     L0034 
                  lsl.l     #5,D4 
                  lea       f_names,A4
                  tst.b     0(A4,D4.W)
                  bne.s     L0033 
                  move.l    #$FFFFFFDB,D0 
                  bra       L0038 
L0033:            move.l    0(A5,D6.W),D5 
                  cmp.l     #-1,D5 
                  beq.s     L0035 
L0034:            move.w    #1,inside
                  move.w    D5,-(A7)
                  move.w    #$3E,-(A7)
                  trap      #1
                  addq.l    #4,A7 
                  clr.w     inside 
                  tst.l     D0
                  bmi.s     L0038 
L0035:            tst.w     D7
                  bmi.s     L0038 
                  cmp.l     in_use,D7
                  bne.s     L0036 
                  move.l    #-1,in_use
L0036:            clr.w     D5
                  swap      D5
                  tst.w     D5
                  beq.s     L0037 
                  CMP.W     #$FFFF,D5 
                  beq.s     L0037 
                  move.l    D5,0(A5,D6.W) 
                  bra       L0038 
L0037:            lsl.l     #5,D7 
                  lea       f_names,A5
                  move.b    #0,0(A5,D7.W) 
L0038:            move.l    D0,-(A7)
                  movem.l   registers,A0-A6/D0-D7 
                  move.l    (A7)+,D0
                  rte 
F_SEEK:           lea       so_read,A2
                  lea       f_lengths,A3
                  clr.l     D0
                  move.w    6(A1),D0
                  lsl.l     #2,D0 
                  clr.l     D1
                  move.w    8(A1),D1
                  move.l    2(A1),D2
                  tst.w     D1
                  bne.s     L003A 
                  move.l    D2,D3 
                  bra.s     L003D 
L003A:            CMP.W     #1,D1 
                  bne.s     L003B 
                  move.l    0(A2,D0.W),D3 
                  ADD.L     D2,D3 
                  bra.s     L003D 
L003B:            tst.l     D2
                  bpl.s     L003C 
                  neg.l     D2
L003C:            move.l    0(A3,D0.W),D3 
                  sub.l     D2,D3 
L003D:            move.l    0(A3,D0.W),D4 
                  cmp.l     D3,D4 
                  bgt.s     L003E 
                  move.l    D4,D3 
L003E:            tst.l     D3
                  bgt.s     L003F 
                  clr.l     D3
L003F:            move.l    D3,0(A2,D0.W) 
                  lea       real_hand,A0
                  move.l    0(A0,D0.W),D4 
                  cmp.l     #-1,D4 
                  beq.s     L0040 
                  lea       chunked,A0
                  move.l    0(A0,D0.W),D5 
                  tst.l     D5
                  bne.s     L0040 
                  move.w    #1,inside
                  move.w    D1,-(A7)
                  move.w    D4,-(A7)
                  move.l    D2,-(A7)
                  move.w    #$42,-(A7)
                  trap      #1
                  lea       10(A7),A7 
                  move.l    D0,D3 
                  clr.w     inside 
L0040:            move.l    D3,-(A7)
                  movem.l   registers,A0-A6/D0-D7 
                  move.l    (A7)+,D0
                  rte 
L0041:            clr.w     inside 
                  move.l    D0,-(A7)
                  movem.l   registers,A0-A6/D0-D7 
                  move.l    (A7)+,D0
                  rte 
F_CREATE:         move.w    #1,inside
                  bsr       emptyone 
                  move.l    D0,D7 
                  movea.l   A0,A5 
                  move.w    6(A1),-(A7) 
                  move.l    2(A1),-(A7) 
                  move.w    #$3C,-(A7)
                  trap      #1
                  addq.l    #8,A7 
                  tst.w     D0
                  bmi       L0044 
L0043:            move.b    #$49,(A5) 
                  lea       real_hand,A0
                  move.l    D7,D6 
                  lsl.l     #2,D7 
                  move.l    D0,0(A0,D7.W) 
                  move.l    D6,D0 
L0044:            clr.w     inside 
                  move.l    D0,-(A7)
                  movem.l   registers,A0-A6/D0-D7 
                  move.l    (A7)+,D0
                  rte 
F_WRITE:          clr.l     D0
                  move.w    2(A1),D0
                  tst.w     D0
                  bmi       L0008 
                  lsl.l     #2,D0 
                  lea       real_hand,A0
                  move.l    0(A0,D0.W),D1 
                  move.w    D1,2(A1)
                  bra       L0008 
F_SFIRST:         move.l    2(A1),D5
                  move.w    6(A1),D6
                  move.w    #1,inside
                  lea       file_mask,A0
                  movea.l   D5,A1 
                  move.l    #$D,D0
L0047:            move.b    (A1)+,(A0)+ 
                  dbf       D0,L0047
                  move.l    #$FFFFFFEA,file_locn
                  move.l    #srchs,file_found
                  move.w    D6,-(A7)
                  move.l    D5,-(A7)
                  move.w    #$4E,-(A7)
                  trap      #1
                  addq.l    #8,A7 
                  clr.l     D6
                  tst.w     D0
                  beq.s     L004A 
                  movea.l   D5,A0 
                  movea.l   ftablestrt,A4
L0048:            bsr       L0057 
                  tst.w     D0
                  bmi       L0050 
                  move.l    A4,file_found
                  lea       -202(A0),A6 
                  suba.l    buff_add,A6
                  move.l    A6,file_locn
                  movea.l   A0,A6 
                  move.w    D0,-(A7)
                  move.w    #$3E,-(A7)
                  trap      #1
                  addq.l    #4,A7 
                  move.w    #$2F,-(A7)
                  trap      #1
                  addq.l    #2,A7 
                  movea.l   D0,A0 
                  lea       26(A0),A0 
                  move.l    14(A6),(A0)+
                  moveq     #$D,D0
L0049:            move.b    (A6)+,(A0)+ 
                  dbf       D0,L0049
                  moveq     #0,D0 
                  bra       L0050 
L004A:            move.w    #$2F,-(A7)
                  trap      #1
                  addq.l    #2,A7 
                  move.l    D0,D7 
                  addi.l    #$1E,D0 
                  movea.l   D0,A0 
                  move.l    D0,D4 
                  lea       srchs,A1
                  lea       endsrch,A2 
                  addq.l    #1,A1 
                  addq.l    #1,A2 
L004B:            clr.l     D0
L004C:            move.b    0(A1,D0.W),D1 
                  cmp.b     0(A0,D0.W),D1 
                  bne.s     L004D 
                  addq.l    #1,D0 
                  tst.b     D1
                  bne.s     L004C 
                  move.l    #$FFFFFFDF,D0 
                  tst.l     D6
                  bra       F_SNEXT 
L004D:            lea       16(A1),A1 
                  cmpa.l    A2,A1 
                  bne.s     L004B 
                  clr.w     -(A7) 
                  move.l    D4,-(A7)
                  move.w    #$3D,-(A7)
                  trap      #1
                  addq.l    #8,A7 
                  tst.l     D0
                  bmi.s     L004F 
                  move.w    D0,D6 
                  clr.l     L009C 
                  pea       L009C 
                  move.l    #8,-(A7)
                  move.w    D0,-(A7)
                  move.w    #$3F,-(A7)
                  trap      #1
                  lea       12(A7),A7 
                  move.w    D6,-(A7)
                  move.w    #$3E,-(A7)
                  trap      #1
                  addq.l    #4,A7 
                  lea       L009C,A0
                  cmpi.l    #buffhead,(A0) 
                  beq.s     L004E 
                  cmpi.l    #normhead,(A0) 
                  bne.s     L004F 
L004E:            movea.l   D7,A1 
                  move.l    4(A0),26(A1)
L004F:            clr.l     D0
L0050:            clr.w     inside 
                  move.l    D0,-(A7)
                  movem.l   registers,A0-A6/D0-D7 
                  move.l    (A7)+,D0
                  rte 
F_SNEXT:          move.w    #1,inside
                  move.l    file_locn,D6
                  addi.l    #$16,D6 
                  move.w    #$4F,-(A7)
                  trap      #1
                  addq.l    #2,A7 
                  tst.l     D0
                  beq       L004A 
                  lea       file_mask,A0
                  movea.l   file_found,A4
                  bra       L0048 
F_DUP:            move.w    #1,inside
                  bsr       emptyone 
                  move.l    D0,D7 
                  movea.l   A0,A5 
                  move.w    2(A1),D5
                  move.w    D5,-(A7)
                  move.w    #$45,-(A7)
                  trap      #1
                  addq.l    #4,A7 
                  tst.w     D0
                  bmi       L0041 
                  neg.l     D5
                  swap      D5
                  move.w    D0,D5 
                  move.l    D5,D0 
                  bra       L0043 
F_FORCE:          clr.l     D0
                  move.w    4(A1),D0
                  lea       real_hand,A5
                  tst.w     D0
                  bmi.s     L0054 
                  lsl.l     #2,D0 
                  move.l    0(A5,D0.W),D0 
                  move.w    D0,4(A1)
L0054:            clr.l     D1
                  move.w    2(A1),D1
                  lsl.l     #2,D1 
                  move.l    D0,0(A5,D1.W) 
                  bra       L0008 
emptyone lea       f_names,A0
	lea       160(A0),A0
	move.l    #5,D0 
L0056	addq.l    #1,D0 
	lea       32(A0),A0 
	tst.b     (A0)
	bne.s     L0056 
	rts 

L0057:            move.l    D0,D5 
                  bsr       L0060 
                  movea.l   A0,A6 
                  movea.l   ftableend,A5
L0058:            cmpa.l    A4,A5 
                  beq       L005C 
L0059:            bsr       L005A 
                  move.l    D0,D4 
                  tst.l     D0
                  bmi       L005E 
                  pea       i_buff 
                  move.l    #$400,-(A7) 
                  move.w    D4,-(A7)
                  move.w    #$3F,-(A7)
                  trap      #1
                  lea       12(A7),A7 
                  move.l    #-1,mini
                  move.l    A4,file_loaded_name
                  move.l    i_len,D0
                  move.l    L00A7,D2
                  subq.l    #1,D2 
                  eori.l    #-1,D2 
                  and.l     D2,D0 
                  move.l    D0,L00A4
                  clr.w     -(A7) 
                  move.w    D4,-(A7)
                  move.l    L00A8,-(A7) 
                  move.w    #$42,-(A7)
                  trap      #1
                  lea       10(A7),A7 
                  move.l    buff_add,-(A7) 
                  move.l    L00A7,-(A7) 
                  move.w    D4,-(A7)
                  move.w    #$3F,-(A7)
                  trap      #1
                  lea       12(A7),A7 
                  movea.l   buff_add,A0
                  lea       200(A0),A1
                  bsr       chunk_up 
                  bsr       L005B 
                  tst.l     D0
                  bmi.s     L005E 
                  movea.l   D0,A0 
                  move.l    D4,D0 
                  rts 
L005A:            clr.w     -(A7) 
                  move.l    A4,-(A7)
                  move.w    #$3D,-(A7)
                  trap      #1
                  addq.l    #8,A7 
                  rts 
L005B:            movea.l   A6,A0 
                  clr.l     D0
                  move.w    (A1),D0 
                  mulu      #$16,D0 
                  addq.l    #2,A1 
                  movea.l   A1,A2 
                  adda.l    D0,A2 
                  adda.l    D6,A1 
                  bsr       L0064 
                  rts 
L005C:            cmpa.l    #endsrch,A5
                  bne.s     L005D 
                  cmpi.l    #srchs,ftablestrt
                  beq.s     L005D 
                  movea.l   ftablestrt,A5
                  movea.l   #srchs,A4 
                  bra       L0059 
L005D:            move.l    D5,D0 
                  rts 
L005E:            tst.w     D4
                  bmi.s     L005F 
                  move.w    D4,-(A7)
                  move.w    #$3E,-(A7)
                  trap      #1
                  addq.l    #4,A7 
L005F:            lea       16(A4),A4 
                  bra       L0058 
L0060:            cmpi.b    #$3A,1(A0)
                  bne.s     L0061 
                  addq.l    #2,A0 
L0061:            movea.l   A0,A1 
L0062:            cmpi.b    #$5C,(A1)+
                  bne.s     L0063 
                  movea.l   A1,A0 
L0063:            tst.b     (A1)
                  bne.s     L0062 
                  rts 
L0064:            clr.w     D1
                  clr.w     D2
L0065:            move.b    0(A0,D1.W),D0 
                  cmp.b     #$61,D0 
                  blt.s     L0066 
                  cmp.b     #$7A,D0 
                  bgt.s     L0066 
                  andi.b    #$DF,D0 
L0066:            cmp.b     #$3F,D0 
                  bne.s     L0067 
                  tst.b     0(A1,D2.W)
                  beq.s     L006E 
                  cmpi.b    #$2E,0(A1,D2.W) 
                  beq.s     L006E 
                  bra.s     L0069 
L0067:            cmp.b     0(A1,D2.W),D0 
                  bne.s     L006A 
L0068:            tst.b     D0
                  beq.s     L006F 
L0069:            addq.b    #1,D1 
                  addq.b    #1,D2 
                  bra.s     L0065 
L006A:            cmp.b     #$2A,D0 
                  bne.s     L006E 
                  addq.b    #1,D1 
                  move.b    0(A0,D1.W),D0 
                  cmp.b     #$61,D0 
                  blt.s     L006B 
                  cmp.b     #$7A,D0 
                  bgt.s     L006B 
                  andi.b    #$DF,D0 
L006B:            tst.b     D0
                  beq.s     L006D 
L006C:            addq.b    #1,D2 
                  cmp.b     0(A1,D2.W),D0 
                  beq.s     L0068 
                  cmpi.b    #$2E,0(A1,D2.W) 
                  beq.s     L0068 
                  tst.b     0(A1,D2.W)
                  bne.s     L006C 
                  bra.s     L006E 
L006D:            addq.b    #1,D2 
                  cmpi.b    #$2E,0(A1,D2.W) 
                  beq.s     L006E 
                  tst.b     0(A1,D2.W)
                  bne.s     L006D 
                  bra.s     L006F 
L006E:            lea       22(A1),A1 
                  cmpa.l    A1,A2 
                  bgt       L0064 
                  movea.l   #-1,A1 
L006F:            move.l    A1,D0 
                  rts 

******************************************************************
*depacks a file if it is packed to a1
*if unpacked then copies CHNKSIZE bytes
*to a1 (assume a1>a0)
*what goes in comes out
*a0=source
*a1=dest
******************************************************************

chunk_up	movem.l   A0-A6/D0-D7,-(A7) 
	clr.l     D0
	move.b    (A0),D0 
	lsl.w     #8,D0 
	move.b    1(A0),D0
	swap      D0
	move.b    2(A0),D0
	lsl.w     #8,D0 
	move.b    3(A0),D0
	cmp.l     #normhead,D0 
	beq       throw1
	cmp.l     #buffhead,D0 
	bne       throw
throw1	bsr       ice_depack
	bra       get_out
throw	move.l    L00A7,D0
	adda.l    D0,A0 
	adda.l    D0,A1 
	subq.l    #1,D0 
do_loop	move.b    -(A0),-(A1) 
	dbf       D0,do_loop
get_out	movem.l   (A7)+,A0-A6/D0-D7 
	rts 

;
;---------------------------------------
; Ice Depacker Routine by Axe of Delight
;---------------------------------------
;
ice_depack
	move.w	$ffff8240.w,-(a7)
	bsr.s	getinfo		; ein Langwort holen
	cmpi.l	#'AU5!',d0	; Kennung gefunden?
	bne	not_packed	; nein: nicht gepackt
	bsr.s	getinfo		; gepackte LÑnge holen
	lea.l	-8(a0,d0.l),a5	; a5 = Ende der gepackten Daten
	bsr.s	getinfo		; ungepackte LÑnge holen (original)
;	move.l	d0,(sp)		; OriginallÑnge: spÑter nach d0
	move.l	a1,a4		; a4 = Zielpuffer
	move.l	a1,a6
	adda.l	d0,a6		; a6 = Ende entpackte Daten
	move.l	a6,a3		; merken fÅr Picture decrunch
	move.b	-(a5),d7		; erstes Informationsbyte
	bsr	normal_bytes

	bsr	get_1_bit 	;; Picture decrunch!
	bcc.s	not_packed	;; These marked lines may be
	move.w	#$0f9f,d7 	;; removed in your own sources
ice_00:	moveq	#3,d6		;; if you do not use the
ice_01:	move.w	-(a3),d4		;; additional algorithm.
	moveq	#3,d5		;;
ice_02:	add.w	d4,d4		;;
	addx.w	d0,d0		;;
	add.w	d4,d4		;;
	addx.w	d1,d1		;;
	add.w	d4,d4		;;
	addx.w	d2,d2		;;
	add.w	d4,d4		;;
	addx.w	d3,d3		;;
	dbra	d5,ice_02 	;;
	dbra	d6,ice_01 	;;
	movem.w	d0-d3,(a3)	;;
	dbra	d7,ice_00 	;;

not_packed:
	rts

getinfo:	moveq	#3,d1		; ein Langwort vom Anfang
getbytes: lsl.l	#8,d0		; der Daten lesen
	move.b	(a0)+,d0
	dbf	d1,getbytes
	rts

normal_bytes:	
	bsr.s	get_1_bit
	bcc.s	test_if_end	; Bit %0: keine Daten
	moveq.l	#0,d1		; falls zu copy_direkt
	bsr.s	get_1_bit
	bcc.s	copy_direkt	; Bitfolge: %10: 1 Byte direkt kop.
	lea.l	direkt_tab+20(pc),a1
	moveq.l	#4,d3
nextgb:	move.l	-(a1),d0		; d0.w Bytes lesen
	bsr.s	get_d0_bits
	swap.w	d0
	cmp.w	d0,d1		; alle gelesenen Bits gesetzt?
	dbne	d3,nextgb 	; ja: dann weiter Bits lesen
no_more:	add.l	20(a1),d1 	; Anzahl der zu Åbertragenen Bytes
copy_direkt:	

	ifne	flash		; flash colours if required !!
;	move.w	d0,$ffff8240.w	; Standard Auto v5.01 flash
;	move.w	d7,$ffff8240.w	; Greenies (not the nasal variety !!)

	not.w	$ffff8240.w
	not.w	$ffff8240.w	; Black & White Minstrels !!
;	move.b	(a6),$ffff8240.w	; Medway Boys F/X
;	eori.w	#$201,$ffff8240.w	; Dream Warriors F/X
	endc

	move.b	-(a5),-(a6)	; Daten direkt kopieren
	dbf	d1,copy_direkt	; noch ein Byte
test_if_end:	
	cmpa.l	a4,a6		; Fertig?
	bgt.s	strings		; Weiter wenn Ende nicht erreicht
	move.l	d7,d5
	move.l	(a7)+,d0
	move.w	(a7)+,$ffff8240.w
	rts	

;************************** Unterroutinen: wegen Optimierung nicht am Schluû

get_1_bit:add.b	d7,d7		; hole ein bit
	bne.s	bitfound		; quellfeld leer
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
bitfound:	rts	

get_d0_bits:	
	moveq.l	#0,d1		; ergebnisfeld vorbereiten
hole_bit_loop:	
	add.b	d7,d7		; hole ein bit
	bne.s	on_d0		; in d7 steht noch Information
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
on_d0:	addx.w	d1,d1		; und Åbernimm es
	dbf	d0,hole_bit_loop	; bis alle Bits geholt wurden
	rts	

;************************************ Ende der Unterroutinen


strings:	lea.l	length_tab(pc),a1	; a1 = Zeiger auf Tabelle
	moveq.l	#3,d2		; d2 = Zeiger in Tabelle
get_length_bit:	
	bsr.s	get_1_bit
	dbcc	d2,get_length_bit	; nÑchstes Bit holen
no_length_bit:	
	moveq.l	#0,d4		; d4 = öberschuû-LÑnge
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0	; d2: zw. -1 und 3; d3+1: Bits lesen
	ext.w	d0		; als Wort behandeln
	bmi.s	no_Åber		; kein öberschuû nîtig
get_Åber: bsr.s	get_d0_bits
no_Åber:	move.b	6(a1,d2.w),d4	; Standard-LÑnge zu öberschuû add.
	add.w	d1,d4		; d4 = String-LÑnge-2
	beq.s	get_offset_2	; LÑnge = 2: Spezielle Offset-Routine


	lea.l	more_offset(pc),a1	; a1 = Zeiger auf Tabelle
	moveq.l	#1,d2
getoffs:	bsr.s	get_1_bit
	dbcc	d2,getoffs
	moveq.l	#0,d1		; Offset-öberschuû
	move.b	1(a1,d2.w),d0	; request d0 Bits
	ext.w	d0		; als Wort
	bsr.s	get_d0_bits
	add.w	d2,d2		; ab jetzt: Pointer auf Worte
	add.w	6(a1,d2.w),d1	; Standard-Offset zu öberschuû add.
	bpl.s	depack_bytes	; keine gleiche Bytes: String kop.
	sub.w	d4,d1		; gleiche Bytes
	bra.s	depack_bytes


get_offset_2:	
	moveq.l	#0,d1		; öberschuû-Offset auf 0 setzen
	moveq.l	#5,d0		; standard: 6 Bits holen
	moveq.l	#-1,d2		; Standard-Offset auf -1
	bsr.s	get_1_bit
	bcc.s	less_40		; Bit = %0
	moveq.l	#8,d0		; quenty fourty: 9 Bits holen
	moveq.l	#$3f,d2		; Standard-Offset: $3f
less_40:	bsr.s	get_d0_bits
	add.w	d2,d1		; Standard-Offset + öber-Offset

depack_bytes:			; d1 = Offset, d4 = Anzahl Bytes
	lea.l	2(a6,d4.w),a1	; Hier stehen die Originaldaten
	adda.w	d1,a1		; Dazu der Offset
	move.b	-(a1),-(a6)	; ein Byte auf jeden Fall kopieren
dep_b:	move.b	-(a1),-(a6)	; mehr Bytes kopieren
	dbf	d4,dep_b	; und noch ein Mal
	bra	normal_bytes	; Jetzt kommen wieder normale Bytes


direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001	; Anzahl 1-Bits
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1	; Anz. Bytes

length_tab:
	dc.b 9,1,0,-1,-1	; Bits lesen
	dc.b 8,4,2,1,0		; Standard-LÑnge - 2 (!!!)

more_offset:
	dc.b	  11,4,7,0	; Bits lesen
	dc.w	$11f,-1,$1f	; Standard Offset
	dc.b	0


real_hand	dc.l	0,1,2,3,4,5,6
		ds.l	8


	section	bss

old_sp		ds.l	1
file_mask	ds.b	16
file_locn	ds.l	1
file_found	ds.l	1
ftablestrt	ds.l	1
ftableend	ds.l	1
in_use		ds.l	1
inside		ds.w	1
buff_add	ds.l	1
mini		ds.l	1
registers	ds.l	16
L009C:            DCB.W     10,0
file_loaded_name	ds.b	32
so_read		ds.l	8
f_lengths	ds.l	8
f_names		rept	max_files
		ds.b	8
		ds.b	8
		ds.b	8
		ds.b	8
		endr
offsets		ds.l	8
chunked		ds.l	8
tmp_sav		ds.b	200
L00A4		ds.l	1
i_buff		ds.l	1
i_len		ds.l	1
L00A7		ds.l	1
L00A8:            DCB.W     506,0 
buff_start	ds.l	1

***********************************************************
**                                                       **
** Instructions                                          **
**                                                       **
** Read the accompanying INSTRUX.501, which were typed   **
** by 'I Wonder Who Wrote This Trash Industries'.        **
**                                                       **
** This is the fourth update that I've done to this code **
** and although my additions are mostly superficial      **
** please credit me, and don't forget that the workhorse **
** part of this code was done by DACK and the Automation **
** Packer v5.01 was done by EGB.  So don't forget to     **
** credit them also !!                                   **
**                                                       **
** Bye - IWWWTTI, 28th January 1992                      **
***********************************************************
