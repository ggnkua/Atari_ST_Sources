;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; HD-Bug U.L.S. - 0.004					            (WHDload for the Atari ST Series)
;; Possible way to convert DMA loaders to HD
;;
;; Requires:
;;  A clean boot to GEM with the HD Driver loaded
;;  Atari ST with 1 MB+ memory (Required to swap out OS/driver memory)  
;;
;; Cyrano Jones & Showaddywaddy
;; D-Bug
;;
;; 28/07/05 - original code
;;
;; 08/08/05 - revised after Moonshine Racers (non existant file caused memory wipe [length=-1])
;;
;; 09/08/05 - revised after Speedball II (cleaner code - added comments)
;;	    - code is now 'A3' free (so it can be used as a Dynamic Table Pointer)
;;
;;
;; 05/09/05 - Set up own Timer C and Force it to Enabled (Thanks DefJam)
;;	    - Fixes Speedball II, Resolution 101
;;	    - *BREAKS* Leavin' Teramis
;;

;debugging		; enable this comment to have the background colours change
			; during the U.L.S. code - makes debugging easier
			;

;save_mfp_status		; enable to save/restore the MFP hardware registers before and
			; after the load takes place
			; required for some (eg, Leavin' Teramis)
			; not required for others (eg, Speedball II)
			;

;;
;; Enable filename support for correct DMA fileloader
;;
;; NOTE: Only enable ONE of these
;;		     ---
;;
;; This patches the filename handler function in the loader to the correct source format
;; I will add other options (eg, Ozz's / RobC's) when I get one of their titles working!
;;

;bbc_dma_loader		; Andy The Arfling's BBC DMA fileloader
neil_dma_loader	; Neil of CB's DMA fileloader

;;
;; U.L.S. Constants (Need to change this to a pointer to a table so its dynamic)
;;

base_ramtop	equ $82000	; save up to this address
shadow_tos	equ $82004	; save TOS at this address
shadow_ram	equ $82008	; save RAM at this address 
HD_filename	equ $8200c	; copy filename
HD_loadadd	equ $82020	; copy load address
HD_bytes_loaded	equ $82024	; return length
HD_filebuffer	equ $82028	; address of filebuffer
HD_Bug_loader	equ $8202c	; address of dbug loader
HD_status_reg	equ $8202e	; dump of status register
HD_status_regl	equ $82030	; dump of executing SR
HD_registers	equ $82040	; register dump
HD_MFP_LOW	equ $82600	; MFP status dump (running app)
HD_MFP		equ $82700	; MFP status dump (TOS)
memtop_base	equ $82800	; where to start dumping


	pea code			; execute supervisor mode
	move.w #$26,-(a7)
	trap #14
	addq.l #6,a7
	clr.w -(a7)
	trap #1

code
	movem.l $ffff8240.w,d0-d7
	movem.l d0-d7,-(a7)		; save pallette
	move.l #$80000,$42e.w		; set "ramtop" to 512k

 	move.l #'DBUG',$80000		; test enough memory
	cmp.l #'DBUG',$80000
	beq enough_ram
	pea .not_enough_ram(pc)		; display error
	move.w #9,-(a7)
	trap #1
	lea 6(a7),a7
	move.w #7,-(a7)
	trap #1
	addq.l #2,a7

	movem.l (a7)+,d0-d7		; clean exit out
	movem.l d0-d7,$ffff8240.w

	rts


.not_enough_ram
	dc.b "Requires 1MB+",0
	even


scanline	equ 193		; vertical line to put scrolly on


enough_ram	
	clr.b $484.w			; Disable Keyclick

	clr.w -(a7)			; screen to $78000
	pea $78000
	pea $78000
	move.w #5,-(a7)
	trap #14
	add.l #12,a7

	jsr tiny_menu

	clr.w $ffff8240.w

	bsr HD_Bug_Init		; Init High RAM

;;
;; set up loader
;;
;; This is where we set up the gameloader and patch in the U.L.S. 
;;

	lea loader_shell,a0
	lea loader_shell_end,a1
	move.l HD_Bug_loader,a2
.copyto	move.b (a0)+,(a2)+
	cmp.l a0,a1
	bne.s .copyto

	move.w #$2700,sr
	lea r_main,a0
	lea $d5b1a,a1
	lea r_main_end,a2
.xxxlo	move.b (a0)+,(a1)+
	cmp.l a0,a2
	bne.s .xxxlo

	move.w #$4ef9,$d5d5a
	move.l HD_Bug_loader,$d5d5a+2
	
	move.l #$e260e,$d5b1a+2
	move.l #$d6382,$d5b62+2

	jmp $d5b1a

;;
;; HD_Loader Init routine
;;

HD_Bug_Init
	move.l #code,d0			; U.L.S. stub load address
	add.l #512,d0
	move.l d0,base_ramtop		; last byte to need saving

	move.l #memtop_base,d1
	move.l d1,shadow_tos		; address of TOS copy
	add.l d0,d1
	move.l d1,shadow_ram		; address of RAM copy
	add.l d0,d1
	move.l d1,HD_filebuffer		; address of FILE buffer
	move.l #loader_shell_end,d0
	sub.l #loader_shell,d0
	move.l #$ffffe,d1
	sub.l d0,d1
	move.l d1,HD_Bug_loader		; address of HD Bug loader


	move.w sr,HD_status_reg		; save SR
	move.w #$2700,sr		; kill everything

	lea	$fffffa01.w,a4		; save the MFP
	lea 	$fffffa31.w,a6		; registers
	lea	HD_MFP,a5		; (All of them!)
.mfp	move.b	(a4),(a5)+
	lea 	2(a4),a4
	cmp.l	a4,a6
	bne.s	.mfp
	
	move.w #$2700,sr		; kill all timers

	lea $8,a0			; save lowmem ram
	move.l base_ramtop,a1
	move.l shadow_tos,a2
.save	move.l (a0)+,(a2)+
	cmp.l a0,a1
	bgt.s .save		

	rts

;;
;; U.L.S. Shellcode (To patch into game)
;;

loader_shell
	move.w sr,-(a7)			; save SR

	movem.l d0-7/a0-7,HD_registers	; save registers
	lea loader_shell(pc),a7		 
 	lea -$100(a7),a7		; our stack (below load code)
	move.l a7,usp

	bsr .process_file		; process filename & load address
					
	bsr .restore_gemdos		; swap memory back in

	bsr .load_file			; gemdos fileload

	bsr .restore_lowmem		; put it all back

	bsr .bytecopy_file		; insert file at correct address

	movem.l HD_registers,d0-7/a0-7	; restore registers

	ifd debugging
	clr.w	$ffff8240.w		; *****BLACK*****
	endc

	cmp.l #$4cdf7fff,$6980		; "Crack" Speedball II
	bne.s .out			; Damn lazy Law of BBC!
	move.w #$4e75,$6984
	move.l #$508d0200,$112d4
	move.l #$000f6700,$112d8
.out

	rte				; and back we go

;;
;;
;; Process the filename & load address
;;
;; BBC DMA loader does not contain the '.' in the filename and is in RAW 11 byte format
;; Neil's loader does contain the '.' in the filename and is in 8.3 format
;;
;; expects:
;;	a0 - pointer to filename
;;	a1 - address to load at
;;

.process_file
	move.l (a0)+,HD_filename	; hard copy filename (8 bytes)
	move.l (a0)+,HD_filename+4	

	ifd bbc_dma_loader
	move.b #'.',HD_filename+8	; add the '.' (bbc fileloader)
	move.b (a0)+,HD_filename+9	; add extender
	move.b (a0)+,HD_filename+10
	move.b (a0)+,HD_filename+11
	endc 

	ifd neil_dma_loader		
	move.l (a0)+,HD_filename+8	; copy the '.ext' (neil's fileloader)
	endc

	clr.b HD_filename+12		; terminate with 0

	move.l	a1,HD_loadadd		; Original load address
	rts

;;
;;
;; Restore GEMDOS (& possibly the MFP if title requires it)
;;
;;

.restore_gemdos
	move.w	#$2700,sr		; kill all timers

	ifd debugging
	move.w #$700,$ffff8240.w	; *****RED*****
	endc

	lea $8,a0			; save lowmem ram
	move.l base_ramtop,a1
	move.l shadow_ram,a2
.save	move.l (a0)+,(a2)+
	cmp.l a0,a1
	bgt.s .save		

	ifd save_mfp_status
	lea	$fffffa01.w,a4		; save current MFP data
	lea 	$fffffa31.w,a6		; and restore original data
	lea	HD_MFP_LOW,a5
	lea	HD_MFP,a2
.mfp	move.b	(a4),(a5)+
	move.b  (a2)+,(a4)
	lea 	2(a4),a4
	cmp.l	a4,a6
	bne.s	.mfp
	endc

	ifd debugging
	move.w #$70,$ffff8240.w		; *****GREEN*****
	endc
	
	move.l shadow_tos,a0		; move GEM lowmemory back
	lea $8,a1
	move.l shadow_ram,a2
.rest	move.l (a0)+,(a1)+
	cmp.l a0,a2
	bgt.s .rest
	rts

;;
;;
;; GEMDos trap #1 load the file
;;
;;

.timerc	add.l #1,$4ba.w			; custom Timer-C rout
	bclr.b #5,$fffffa11.w		; can't always rely on the GEM
	ifd debugging			; Timer-C being there
	neg.w $ffff8240.w
	endc
	rte

.load_file
	pea .timerc(pc)
	move.l (a7)+,$114.w

	move.w #$2300,sr

	bset.b #5,$fffffa09.w		; <- Timer C enable (thnx DefJam)
	bset.b #5,$fffffa15.w		; <- Timer C enable (thnx DefJam)
	move.b #$c0,$fffffa23.w		; <- Timer C data (thnx Grazey)
	
	ifd debugging
	move.w #$777,$ffff8240.w	; *****WHITE*****
	endc

	clr.w -(a7)			; open file
	move.l #HD_filename,-(a7)
	move.w #$3d,-(a7)		; GEMDOS fopen
	trap #1
	add.l #8,a7
	move.w d0,d7			; file handle
	bmi.s	.crud			; loop if file not found

	ifd debugging
	sub.w #$333,$ffff8240.w
	endc

	move.l HD_filebuffer,-(a7)	; read file into high memory (in case it wanted to load low)
	move.l #$7ffff,-(a7)
	move.w d7,-(a7)
	move.w #$3f,-(a7)		; GEMDOS fread
	trap #1
	lea 12(a7),a7
	move.l d0,d6
	bpl.s .okyeah
.crud	addq.w #1,$ffff8240.w		; loop here on error (read failed)
	bra.s .crud
.okyeah	move.l d6,HD_bytes_loaded	; save bytes loaded counter

	ifd debugging
	sub.w #$333,$ffff8240.w
	endc

	move.w d7,-(a7)			
	move.w #$3e,-(a7)		; GEMDOS fclose
	trap #1
	addq.l #4,a7

	bclr.b #5,$fffffa09.w		; Timer-C disable
	bclr.b #5,$fffffa15.w

	rts

;;
;;
;; Put original low memory back
;;
;;

.restore_lowmem
	ifd debugging
	move.w #$7,$ffff8240.w		; ******BLUE*****
	endc

	move.w #$2700,sr		; kill timers

	move.l shadow_ram,a0		; put lowmem back
	lea $8,a1
	move.l base_ramtop,a2
.back	move.l (a0)+,(a1)+
	cmp.l a1,a2
	bgt.s .back
	rts

;;
;;
;; Bytecopy the loaded file to correct address (allows loading to any address)
;;
;;

.bytecopy_file
	ifd debugging
	move.w #$77,$ffff8240.w		; *****CYAN*****
	endc

	move.l HD_filebuffer,a0		; address we traploaded file at
	move.l HD_loadadd,a1		; address file required to be loaded at
	move.l a1,d0
	cmp.l #$80000,d0		; is it trying to load above 512k?
	blt.s	.fload
.feck	neg.w $ffff8240.w		; yes - attempt to load too high (neg background loop)
	bra.s .feck

.fload	move.b (a0)+,(a1)+		; byte copy the file 		
	subq.l #1,d6
	bne.s .fload

	ifd debugging
	move.w #$707,$ffff8240.w	; *****PURPLE*****
	endc

	ifd save_mfp_status
	lea	$fffffa01.w,a4		; restore original low memory
	lea 	$fffffa31.w,a6		; MFP status
	lea	HD_MFP_LOW,a5
.mfp2	move.b	(a5)+,(a4)
	lea 	2(a4),a4
	cmp.l	a4,a6
	bne.s	.mfp2
	endc

	rts

loader_shell_end			; end of shellcode
	dc.b "2005 D-Bug!"	
	even

r_main	incbin "25b1a"			; dump of loader code
r_main_end
	even

.HD_text
message DC.B 13,13,13,13,13,13
	DC.B 13,13,13
	DC.B " ()()()()()()()()()()()()()()()()()()()()()()()()()()",13
	DC.B " ()                                                ()",13
	DC.B " ()                                                ()",13
	DC.B " ()  TITLE:                      (RESOLUTION 101)  ()",13
	DC.B " ()  COMPANY:                              (XXXX)  ()",13
	DC.B " ()  SOURCE DISK:              (AUTOMATION CD XX)  ()",13
	DC.B " ()  CRACKER:                           (THE LAW)  ()",13
	DC.B " ()                                                ()",13
	DC.B " ()  STUB AUTHOR:                  (CYRANO JONES)  ()",13
	DC.B " ()  HD-BUG VERSION:                       (0.02)  ()",13
	DC.B " ()                                                ()",13
	DC.B " ()  NOTES:                                        ()",13
	DC.B " ()                                                ()",13
	DC.B " ()  THE GAME STILL SAVES ALL ITS DATA TO A DISK.  ()",13
	DC.B " ()  I ALSO FOUND AN UNCRACKED COPYLOCK2 SHELL!    ()",13                                  ()",13
	DC.B " ()                                                ()",13
	DC.B " ()     PRESS (SPACE BAR) TO CONTINUE LOADING      ()",13
	DC.B " ()                                                ()",13
	DC.B " ()()()()()()()()()()()()()()()()()()()()()()()()()()",13
	DC.B -1

	even	
text
wrapos
	DC.B "    "
	DC.B "THIS STUB LOADER WAS CODED BY CYRANO JONES OF D-BUG! "
	DC.B "LOOK OUT FOR MORE HD-BUG STUBLOADER DISK RELEASES "
	DC.B "COMING SOON FROM THE GOOD FOLK AT D-BUG AND THE REST "
	DC.B "OF THE U.L.S. COMMUNITY.    GREETINGS TO EVERYONE "
	DC.B "FROM THE ATARI FORUM (WWW.ATARI-FORUM.COM)       "
	DC.B "   "
	DC.B $FF,$FF
	EVEN	

;
; A really crappy micro-intro
;
; Coded by The Law (but I won't admit to it!)
;


tiny_menu
	bra	supercode

********************************************************************
* The new (faster than os) keyboard routines...................... *
********************************************************************

key_del	move.b d0,$fffffc02.w		; keyboard 'poke' routine
	move.w #$ffff,d0
lab1	dbra d0,lab1
	rts

my_key	move.b $fffc02,key		; keyboard 'scanner'
	bclr.b #6,$fffffa11.W
	rte

supercode
	move.b $ffff8201.w,oldscreen+1
	move.b $ffff8203.w,oldscreen+2

	bsr pre_define
	bsr make_dot_table
	bsr convert_text	

	move.l #$78000,a0		; Erase screen ram
blank	clr.l (a0)+
	cmp.l #$80000,a0
	bne.s blank

	lea message(pc),a4
	moveq.l #0,d5
	move.l #160,d6
	bsr prop

	movem.l font+2,d0-7
	movem.l d0-7,$ffff8240.w	

	lea font+34,a0
	lea font+34+(160*60),a1
	lea $78000,a2
logo	move.l (a0)+,(a2)+
	cmp.l a0,a1
	bne.s logo


	move.b #$12,d0			; no mouse
	bsr key_del
	move.b #$1a,d0			; no joystick
	bsr key_del

	move.b #$07,$ffff8201.w		; Screen at $78000
	move.b #$80,$ffff8203.w
	move.b #0,$ffff8260.w		; in low resolution

	lea mfp(pc),a0
	move.l $120.w,(a0)+
	move.b $fffffa07.w,(a0)+
	move.b $fffffa13.w,(a0)+
	move.b $fffffa09.w,(a0)+
	move.b $fffffa1b.w,(a0)+

	move.l #hbl,$120.w		; set up null raster
	move.b #1,$fffffa07.w
	bset #0,$fffffa13.w
	move.b #2,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.b #$40,$fffffa09.w

	move.L $70.w,-(a7)		; save 'n' set vbl
	move.l #vbl,$70.w

	move.l $118.w,-(a7)		; save 'n' set ikbd
	move.l #my_key,$118.w

loop	cmp.b #$39,key
	bne.s loop

getout	move.l (a7)+,$118.W		; restore vbl & ikbd
	move.l (a7)+,$70.W

	move.l #$8080000,$ffff8800.W	; Switch off the sound-chip
	move.l #$9090000,$ffff8800.W
	move.l #$a0a0000,$ffff8800.W

	move.l #$78000,a0		; Erase screen ram
.blank	clr.l (a0)+
	cmp.l #$80000,a0
	bne.s .blank

	clr.w $ffff8240.w		; make sure there is a readable
	lea $ffff8242.w,a0		; pallette for when I drop back
	moveq.l #14,d0			; into GenST!!!!
white	move.w #$777,(a0)+
	dbra d0,white

	lea mfp(pc),a0
	move.l (a0)+,$120.w
	move.b (a0)+,$fffffa07.w
	move.b (a0)+,$fffffa13.w
	move.b (a0)+,$fffffa09.w
	move.b (a0)+,$fffffa1b.w

	move.b #$80,d0
	bsr key_del
	move.b #$1,d0
	bsr key_del

	move.b oldscreen+1,$ffff8201.w
	move.b oldscreen+2,$ffff8203.w

	rts				; exit starfield intro

mfp	ds.l 2

hbl	move.l a0,-(a7)
	move.l colptr,a0
	move.w (a0)+,$ffff8240.w
	move.l a0,colptr
	move.l (a7)+,a0
	bclr.b #0,$fffffa0f.w
	rte

colptr	dc.l colours
colours
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0,0,0,0,0,0
	dc.w 0,0
	dc.w $1,$2,$3,$4,$5,$6,$7,$6,$5,$4,$3,$2,$1,$0
	dc.w $101,$202,$303,$404,$505,$606,$707,$606,$505,$404,$303
	dc.w $202,$101
	dc.w $000,$100,$200,$300,$400,$500,$600,$700
	dc.w $600,$500,$400,$300,$200,$100,$000
	dc.w $10,$20,$30,$40,$50,$60,$70
	dc.w $60,$50,$40,$30,$20,$10,$00
	dc.w $1,$2,$3,$4,$5,$6,$7,$6,$5,$4,$3,$2,$1,$0
	dc.w $0,$0,$0,$0,$0,$0,$0,$0,$0
endcol	dc.w $ffff		
	dc.w $ffff
	dc.w $ffff	
********************************************************************
* Vertical Blank Interupt......................................... *
********************************************************************

vbl	movem.l d0-a6,-(a7)
	move.w #$2700,sr
	move.l #colours,colptr

	bsr.s scroll		

	move.w #1,done_vbl 	
	movem.l (a7)+,d0-a6	

	rte

scroll	move.w #1,d4
faster	subq.w #1,scrl
	bne.s go_scrl

get2	move.w #6,scrl
	moveq.l #0,d1
	move.l tpnt,a0

back	move.b (a0),d1
	move.b d1,d3
	sub.w #$20,d1
	cmp.b #$ff,d3
	bne.s next

wrap	move.l #wrapos,tpnt
	bra.s get2

next	addq.l #1,tpnt

next_ch	asl #2,d1
	lea ptable,a1
	move.l (a1,d1),d1	

	move.l ststart,A0
	add.l d1,a0
	lea chbuff,a1
	moveq.l #5,d5

fillbuf	move.w (a0),(a1)+
	lea 160(a0),a0
	dbra d5,fillbuf

go_scrl	lea chbuff,a0
	move.l scrladd,a1
	moveq.l #5,d2
rows	lea 160(a1),a1
	lsl.w (a0)+
	roxl.w $98(a1)
	roxl.w $90(a1)
	roxl.w $88(a1)
	roxl.w $80(a1)
	roxl.w $78(a1)
	roxl.w $70(a1)
	roxl.w $68(a1)
	roxl.w $60(a1)
	roxl.w $58(a1)
	roxl.w $50(a1)
	roxl.w $48(a1)
	roxl.w $40(a1)
	roxl.w $38(a1)
	roxl.w $30(a1)
	roxl.w $28(a1)
	roxl.w $20(a1)
	roxl.w $18(a1)
	roxl.w $10(a1)
	roxl.w $8(A1)
	roxl.w (A1)

	dbra d2,rows
	dbra d4,faster
outg	rts

scrl		dc.w 1
tpnt		dc.l 1

*********************************
* calc start addresses of chars *
*********************************
* used in fast offset routines. *
*********************************

pre_define
	move.l #$78000,scrladd
	add.l #scanline*160,scrladd
	move.l #text,tpnt
	move.l #font+34+4,ststart

	moveq.l #$1f,d0
	lea ptable,a3
def_1	addq.l #1,d0
	move.l d0,d1
	bsr.s which_line
	sub.l #$20,d1
	asl #4,d1
	add.l offset,d1
	move.l d1,(a3)+
	cmp.l #$5e,d0
	bne.s def_1
	rts

which_line
	cmp.b #'R',d1
	blt.s gruff1
	move.l #(91*160),offset
	rts
gruff1	cmp.b #'H',d1
	blt.s gruff2
	move.l #(85*160),offset
	rts
gruff2	cmp.b #'>',d1
	blt.s gruff3
	move.l #(79*160),offset
	rts
gruff3	cmp.b #'4',d1
	blt.s gruff4
	move.l #(73*160),offset
	rts
gruff4	cmp.b #'*',d1
	blt.s gruff5
	move.l #(67*160),offset
	rts
gruff5	move.l #(61*160),offset
	rts


prop	move.w d5,curr_x
	move.w d6,curr_y

prt	move.l #160,d7
	lea $78000-(320),a2
	moveq.l #0,d0
	moveq #15,d3
print	move.b (a4)+,d0
	cmp.b #$ED,d0
	bne.s ntest
	move.w curr_x,d5
	move.w curr_y,d6
	add.w #7*160,d6
	move.w d6,curr_y
	bra.s prt
ntest	cmp.b #-1,d0
	beq out
	add d0,d0
	add d0,d0
	lea dot_pnt,a1
	move.l (a1,d0),a3
	moveq #5,d4
all5	move.w d6,a6
	move.w d5,d0
	move.l a2,a1		; base of screen
	move.w d0,d1
	and d3,d0
	eor d0,d1
	lsr #1,d1
	add.l a6,a1
	add d1,a1
	eor d3,d0
	move.l a1,a6
	move.w d0,d2
	tst.b (a3)
	bmi.s .off1
	move.w (a6),d1		; pull screen contents into d0
	bset d2,d1		; set bit
	move.w d1,(a6)
.off1	add.w d7,a6
	tst.b 6(a3)
	bmi.s .off2
	move.w (a6),d1		; pull screen contents into d0
	bset d2,d1		; set bit
	move.w d1,(a6)
.off2	add.w d7,a6
	tst.b 12(a3)
	bmi.s .off3
	move.w (a6),d1		; pull screen contents into d0
	bset d2,d1		; set bit
	move.w d1,(a6)
.off3	add.w d7,a6
	tst.b 18(a3)
	bmi.s .off4
	move.w (a6),d1		; pull screen contents into d0
	bset d2,d1		; set bit
	move.w d1,(a6)
.off4	add.w d7,a6
	tst.b 24(a3)
	bmi.s .off5
	move.w (a6),d1		; pull screen contents into d0
	bset d2,d1		; set bit
	move.w d1,(a6)
.off5	add.w d7,a6
	tst.b 30(a3)
	bmi.s .off6
	move.w (a6),d1		; pull screen contents into d0
	bset d2,d1		; set bit
	move.w d1,(a6)
.off6	add.w d7,a6
	tst.b 36(a3)
	bmi.s .off7
	move.w (a6),d1		; pull screen contents into d0
	bset d2,d1		; set bit
	move.w d1,(a6)
.off7	addq.w #1,a3
 	addq.w #1,d5
	subq.w #1,d4
	bne.s all5
	addq.w #1,d5
	bra print
out	rts

make_dot_table
	moveq #0,d7
	move.b #' ',d7			; d7 keeps current char
	lea dot_pnt(pc),a3
	lea dot_font,a4
.make	move.l a4,(a3)			; save character posn in table	
	addq.l #1,(a3)+
	bsr.s .create_matrix
	addq.l #1,d7
	cmp.b #'Z'+1,d7
	bne.s .make
	rts

.create_matrix
	move.l d7,d6
	sub.b #$20,d6
	add d6,d6
	add d6,d6
	lea ptable,a5
	move.l (a5,d6),a0
	add.l #font+34+160+2,a0
	move.w #15,d1
.rows	move.w (a0),d0
	bsr.s test_bits
	lea 160(a0),a0
	dbra d1,.rows
	rts

test_bits
	btst #15,d0
	bsr.s .well
	btst #14,d0
	bsr.s .well
	btst #13,d0
	bsr.s .well
	btst #12,d0
	bsr.s .well
	btst #11,d0
	bsr.s .well
	btst #10,d0
	bsr.s .well
	rts

.well	beq.s .off
	move.b #1,(a4)+
	rts
.off	move.b #-1,(a4)+
	rts

convert_text
	lea message(pc),a0
.loop	cmp.b #-1,(a0)
	beq.s .outa
	sub.b #$20,(a0)+
	bra.s .loop
.outa	rts



font	incbin "hd2.pi1"		; ULS Logo + Font
	even

	section bss

oldscreen	ds.l 1
curr_x		ds.w 1
curr_y		ds.w 1
dot_pnt		ds.l $3f
offset		ds.l 1 
ptable		ds.l $3f
chbuff		ds.w 16
key		ds.l 1
scrladd		ds.l 1
stchar		ds.l 1
ststart		ds.l 1
done_vbl	ds.w 1
filename	ds.l 1
ct		ds.l 1
dot_font	ds.b (7*7)*$3f
