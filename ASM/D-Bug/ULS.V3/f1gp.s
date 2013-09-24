;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; F1GP ULSv3.0 Stubloader
;;
;; CJ / Oct 2008
;;
;;

max_filesize equ 83*1024			; largest file is 83k
;adv_debug					; debug mode off

	clr.l -(a7)
	move.w #$20,-(a7)			; supervisor
	trap #1
	lea 6(a7),a7
	move.l d0,usr_stack

	bra my_loader

	dc.b "ARSE"				; some text so I can find this code in Steem's Boiler Room


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Relocate code to just under Ramtop
;;

my_loader
	lea relocat,a0				; relocate code
	lea ULS_stk,a1
	move.l $44e.w,a2
	sub.l #(ULS_TRASH_RAM-my_loader)*2,a2
	move.l a2,-(a7)
.move	move.b (a0)+,(a2)+
	cmp.l a0,a1
	bne.s .move
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Install ULS and patch initial loader
;;


relocat	lea relocat(pc),a7
	lea relocat(pc),a0
	sub.l #ULS_TRASH_RAM-my_loader,a0	; pass to ULS as RAMTOP
	move.l #1,d0				; clock (-1=8mhz)
	move.l #1,d1				; cache (-1=off!)
	
	move.l $42e.w,d7
	cmp.l #$400000,d7			; automagic ramdisk if 4mb+
	blt.s .noramd
	move.l #'RAMD',d7 			; instruct ULS to create a ramdisk
.noramd	move.l #1400000,a6			; this big
	lea ram_spec(pc),a5			; from this filespec.
	bsr uls

	lea uls_base(pc),a2
	move.l a0,(a2)				; ULS JMP table here
	lea uls_fb(pc),a2
	move.l a1,(a2)				; ULS filebuffer here

	clr.w -(a7)				; set screen base to $78000 (512k)
	pea $78000
	pea $78000
	move.w #5,-(a7)
	trap #14
	lea 12(a7),a7
	
	lea uls_base(pc),a6
	move.l (a6),a6
	jsr uls_setread(a6)			; set READ

	lea fmain1(pc),a0			; filename
	lea $ACEE,a1				; load address
	move.l #-1,d0				; bytes to load
	move.l #0,d1				; seek offset
	moveq #0,d7				; do not load to filebuffer only
	lea uls_base(pc),a6
	move.l (a6),a6				; ULS JMP table
	jsr uls_file_io(a6)			; call IO

	lea fmain2(pc),a0			; filename
	lea $20000,a1				; load address
	move.l #-1,d0				; bytes to load
	move.l #0,d1				; seek offset
	moveq #0,d7				; do not load to filebuffer only
	lea uls_base(pc),a6
	move.l (a6),a6				; ULS JMP table
	jsr uls_file_io(a6)			; call IO

	move.w #$4e71,d0			; patch the original loader to not load the 1st data file
	move.w d0,$ad00	; 3d
	move.w d0,$ad16 ; 3f

	lea uls_handler(pc),a0			; install the ULS handler (1st loader)
	move.w #$4ef9,$af2e
	move.l a0,$af30

	lea pre_run(pc),a0			; install post-depack code
	move.l a0,$ad4c

.run	jmp $ACEE				; call the loader!

usr_stack	ds.l 1

ram_spec	dc.b "*.",0			; ignore files with .ext as these are saves (IE, never cache them)
		even

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Code to patch the next stages as they load
;;


pre_run	
	move.l a0,-(a7)
	lea uls_handler(pc),a0			; install the ULS handler again (2nd loader)
	move.w #$4ef9,$50402
	move.l a0,$50404

	lea pre_run2(pc),a0			; patch after depack so we can patch the third loader
	move.l a0,$501cc
	move.l (a7)+,a0

	jmp $50000

pre_run2
	move.l a0,-(a7)
	lea uls_handler(pc),a0			; install the ULS handler again (3rd loader)
	move.w #$4ef9,$6510c
	move.l a0,$6510e
	move.l (a7)+,a0
	jmp $64000

pre_run3
	move.l a0,-(a7)
	lea uls_handler(pc),a0			; install the ULS hander again (4th loader - main for game)
	move.w #$4ef9,$2a3fc
	move.l a0,$2a3fe

	lea menu_grab(pc),a0			; install code to grab the menu number selected (used for save/load)
	move.w #$4ef9,$33ed2
	move.l a0,$33ed4

	move.w #7,$2e5d8			; remove "Disk Utilities" from main menu
 	move.w #$601a,$32b3c			; fix up "file overwrite" error (always overwrite)

	lea fnf_error(pc),a0			; patch in our File Not Found code
	move.w #$4ef9,$32ab6
	move.l a0,$32ab8

	lea write_flag(pc),a0			; now we're in the game, allow WRITE operations
	move.w #-1,(a0)

	lea .cockpit_ikbd(pc),a0		; patch in the keyboard handler for the game (cockpit)
	move.w #$4ef9,$5ed4
	move.l a0,$5ed6

	lea .menu_ikbd(pc),a0			; patch in the keyboard handler for the game (menus)
	move.w #$4eb9,$3b624
	move.l a0,$3b626

	move.l (a7)+,a0
	jmp $400				; Gentlemen, Start your engines!


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; ACIA handler for game when in the menus
;;

.menu_ikbd
	move.b $fffffc02.w,d0
	cmp.b #$44,d0				; F10?
	beq .gf10
	cmp.b #$43,d0				; F09?
	beq .mf09
	cmp.b #$42,d0				; F08?
	beq .mf08
	cmp.b #$41,d0				; F07?
	beq .mf07
.mexit	rts					; return to game (Menu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Stateload from menu (f8)
;;

.mf08	movem.l d0-a6,-(a7)
	lea uls_base(pc),a6
	move.l (a6),a6				; ULS JMP table
	jsr uls_stateload(a6)			; Call loadstate
	movem.l (a7)+,d0-a6			; we get here if no statefile
	bra .mexit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Statesave from menu (f7)
;;

.mf07	move.l a0,-(a7)
	lea uls_fb(pc),a0
	move.l (a0),a0
	add.l #4,a7				; correct the stack for reg-dump
	movem.l d0-7/a1-7,(a0)
	sub.l #4,a7				; and put it back
	lea 60(a0),a0
	move.w sr,(a0)+
	move.l (a7),(a0)+
	move.l (a7)+,a0

	movem.l d0-a6,-(a7)			; we now trash these
	lea .mexit(pc),a6
	move.l a6,d1				; return address
	move.l #$f0000,d0			; dump ram end
	lea uls_base(pc),a6
	move.l (a6),a6				; ULS JMP table
	jsr uls_statesave(a6)			; Call savestate
	movem.l (a7)+,d0-a6			; and restore them

	bra .mexit				; exit back to game

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Screendump from menu (f9)
;;

.mf09	move.l a0,-(a7)
	lea .scrflip(pc),a0			; check this is the "released f9" so we don't
	add.w #1,(a0)				; flood the folder with PI1 files!
	cmp.w #2,(a0)
	bne.s .nope

	move.l a6,-(a7)
	lea uls_base(pc),a6
	move.l (a6),a6				; ULS JMP table
	jsr uls_dumpscreen(a6)			; Call PI1 Dumper
	move.l (a7)+,a6
	lea .scrflip(pc),a0
	clr.w (a0)

.nope	move.l (a7)+,a0
	bra .mexit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; ACIA handler for game when in the cockpit
;;

.cockpit_ikbd
	move.b $fffffc02.w,d0
	cmp.b #$44,d0				; F10?
	beq .gf10
	cmp.b #$43,d0				; F09?
	beq .gf09
	cmp.b #$42,d0				; F08?
	beq .gf08
	cmp.b #$41,d0				; F07?
	beq .gf07

.exit	tst.b $6067				; return to game (Cockpit)
	jmp $5ee0.w

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Stateload from cockpit (f8)
;;

.gf08	movem.l d0-a6,-(a7)
	lea uls_base(pc),a6
	move.l (a6),a6				; ULS JMP table
	jsr uls_stateload(a6)			; Call loadstate
	movem.l (a7)+,d0-a6			; we get here if no statefile
	bra .exit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Statesave from cockpit (f8)
;;

.gf07	move.l a0,-(a7)
	lea uls_fb(pc),a0
	move.l (a0),a0
	add.l #4,a7				; correct the stack for reg-dump
	movem.l d0-7/a1-7,(a0)
	sub.l #4,a7				; and put it back
	lea 60(a0),a0
	move.w sr,(a0)+
	move.l (a7),(a0)+
	move.l (a7)+,a0

	movem.l d0-a6,-(a7)			; we now trash these
	lea .exit(pc),a6
	move.l a6,d1				; return address
	move.l #$f0000,d0			; dump ram end
	lea uls_base(pc),a6
	move.l (a6),a6				; ULS JMP table
	jsr uls_statesave(a6)			; Call savestate
	movem.l (a7)+,d0-a6			; and restore them

	bra .exit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Screendump from cockpit (f9)
;;

.gf09	move.l a0,-(a7)				; check this is the "released f9" so we don't
	lea .scrflip(pc),a0			; flood the folder with PI1 files!
	add.w #1,(a0)
	cmp.w #2,(a0)
	bne.s .nope2

	move.l a6,-(a7)
	lea uls_base(pc),a6
	move.l (a6),a6				; ULS JMP table
	jsr uls_dumpscreen(a6)			; Call PI1 Dumper
	move.l (a7)+,a6
	lea .scrflip(pc),a0
	clr.w (a0)

.nope2	move.l (a7)+,a0				; and back to the game
	bra .exit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Return to desktop (Common to both) (f10)
;;	

.gf10	lea .gf10(pc),a7			; move the stack somewhere safe!
	move.w #$2700,sr			; all stop!
	lea uls_base(pc),a6			; ULS JMP table
	move.l (a6),a6
	jmp uls_terminate(a6)			; Call quit! 


.scrflip	dc.w 0				; Screenshot toggle (only do every other)

fnf_local	dc.w 0				; file not found flag

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Handle FnF errors so we can process the load game correctly 
;;

fnf_error
	move.l a0,-(a7)
	lea fnf_local(pc),a0			; test if file not found after load
	tst.w (a0)
	bpl.s .ok
.error	clr.w (a0)
	move.l (a7)+,a0
	jmp $32abc				; jump to Load Error (in game)
.ok	move.l (a7)+,a0
	cmp.l d0,d0				; jump to Load OK (in game) - set sr correct :)
	rts


fmain1	dc.b "ACEE",0				; initial binary 
	even

fmain2	dc.b "PLOADER1",0			; file loaded by initial binary (Trap #1's patched out)
	even

uls_base	dc.l 0				; ULS jumptable address
uls_fb		dc.l 0				; ULS filebuffer address
write_flag	dc.w 0				; flag so we know if we're in 4th (final) loader

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Store the menu number selected on the Load/Save game menu so we can patch the filename extender 
;;

menu_grab
	move.l a0,-(a7)

	lea m_opt(pc),a0
	move.b d0,(a0)				; store the menu number locally so we can check it later

	move.l (a7)+,a0

.out	cmpi.w #$7,d0				; original code to be executed that our patch overwrote
	bcc.s .outjmp
	move.w d0,d1
	jmp $33edc
.outjmp	jmp $33ee8

m_opt	dc.w 0					; local copy of menu selected

m_tabl	dc.w 0
	dc.b ".GAM"				; load game extender  (Menu Option 1)
	dc.w 1
	dc.b ".LAP"				; load laps extender  (Menu Option 2)
	dc.w 2
	dc.b ".LAP"				; save laps extender  (Menu Option 3)
	dc.w 3
	dc.b ".NAM"				; load names extender (Menu Option 4)
	dc.w 4
	dc.b ".NAM"				; save names extender (Menu Option 5)
	dc.w 5
	dc.b ".CAR"				; load car extender   (Menu Option 6)
	dc.w 6
	dc.b ".CAR"				; save car extender   (Menu Option 7)
	dc.w 7
	dc.b "EXIT"				; exit to main menu

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Process the game's directory request by using ULS_execute to read the HD directory and
;; patch the results back into the game
;;

proc_dir
	movem.l (a7)+,a0-1/d0			; correct the stack from the game	
	movem.l d1-7/a0-6,-(a7)			; save registers

	move.l a1,-(a7)

	lea uls_base(pc),a6
	move.l (a6),a6				; ULS JMP table
	lea directory(pc),a0
	jsr uls_execute(a6)			; Call ULS User Code Execute to create a directory listing

	move.l (a7),a2
	move.l #2043,d0
.blag	clr.b (a2)+
	dbra d0,.blag				; fix chinese chars bug :P

	lea output(pc),a0
	lea eot(pc),a1
	move.l (a1),a1
	move.l (a7)+,a2


.shove	move.b (a0)+,(a2)+			; "load" the directory from the table we made in the ULS execute call
	cmp.l a0,a1
	bne.s .shove

	movem.l (a7)+,d1-7/a0-6			; correct the stack
	move.w #$0000,d0
	rts					; back to the game

local	dc.l 0					; we build the start of the filename requested here

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Main ULS file request handler
;;

uls_handler
	movem.l a0-1/d0,-(a7)			; save registers
	lea local(pc),a1			 
	move.b (a0)+,(a1)			; grab the first 4 chars of filename
	move.b (a0)+,1(a1)			; end ensure they are on an even boundary
	move.b (a0)+,2(a1)			; for compare below
	move.b (a0),3(a1)

	cmp.l #$62697200,(a1)			; was this a directory request?
	beq proc_dir				; yes, then go and do that!

	movem.l (a7)+,a0-1/d0			; restore registers

	cmp.l #$400,$64a14			; check if we need to patch the post-depack code for the 4th loader
	bne.s .n2

	move.l a0,-(a7)				; if so then install patch code
	lea pre_run3(pc),a0
	move.l a0,$64a14
	move.l (a7)+,a0


.n2	movem.l d1-7/a0-6,-(a7)			; save registers
	lea uls_base(pc),a6
	move.l (a6),a6				; ULS JMP table

	lea write_flag(pc),a5			
	tst.w (a5)
	bpl .read				; write only in 4th(game) loader

	tst.b $ff				; write requested?
	bpl .read

.write	jsr uls_setwrite(a6)			; Put ULS in WRITE MODE

	bsr save_filext				; calculate file extender based on menu selection
	lea my_fn(pc),a0
  
	move.l $2b644,d0			; bytes to write	
	moveq #0,d1				; seek offset
	moveq #0,d7				; unused for write but wtf :)
	lea uls_base(pc),a6
	move.l (a6),a6				; ULS JMP table
	jsr uls_file_io(a6)			; Call ULS
	bra .norm				

.read	jsr uls_setread(a6)			; Put ULS in READ MODE
	move.l #-1,d0				; read all the file
	move.l #0,d1				; from the start
	moveq #0,d7
	cmp.w #$5555,$96			; header request?
	bne.s .ok
	move.l #-1,d7				; if yes, read to buffer only
.ok
	lea uls_base(pc),a6
	move.l (a6),a6				; ULS JMP table
	jsr uls_file_io(a6)			; Call ULS
	tst.l d7				; test for File Not Found
	bmi .error

	lea fnf_local(pc),a0			; clear FnF error because file was ok
	clr.w (a0)

	cmp.w #$5555,$96			; header request?
	bne.s .norm
	lea uls_fb(pc),a0
	move.l (a0),a0
	move.l #11,d0
.loop	move.b (a0)+,(a1)+			; copy 12 bytes (Pack header) from ULS filebuffer
	dbra d0,.loop

.norm	movem.l (a7)+,d1-7/a0-6
	move.w #$0000,d0			; return to game
	rts

.error	lea fnf_local(pc),a0			; read error
	move.w #-1,(a0)				; set flag
	movem.l (a7)+,d1-7/a0-6			; return to game
	clr.w d0
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Put the correct file extender into the filename for save 
;;

my_fn	ds.b 14					; re-build filename here
	even

save_filext
	movem.l d0-7/a0-6,-(a7)			; clear the filename buffer
	lea my_fn(pc),a1
	moveq #13,d7
w	clr.b (a1)+
	dbra d7,w
	lea my_fn(pc),a1

	moveq #7,d7				; filename is 8 chars long (extender not allowed!)
.byte	move.b (a0)+,d0
	cmp.b #' ',d0
 	beq.s .don				; end of filename if space
	cmp.b #'.',d0
	beq.s .don				; end of filename if '.'
	cmp.b #0,d0
	beq.s .don				; end of filename if 8th char
	move.b d0,(a1)+
	dbra d7,.byte
.don	lea m_opt(pc),a0
	lea m_tabl(pc),a2
	moveq #0,d0
	move.b (a0),d0				; get the menu number
.where	move.w (a2)+,d1
	cmp.b d0,d1				; search thru table for match
	beq.s .got
	move.l (a2)+,d1				; skip to next
	bra.s .where
.got	move.b (a2)+,(a1)+			; add the extender to the name
	move.b (a2)+,(a1)+
	move.b (a2)+,(a1)+
	move.b (a2),(a1)
	movem.l (a7)+,d0-7/a0-6
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; TOS user code to process disk directory (Runs under ULS_execute in TOS environment) 
;;

directory
	lea m_opt(pc),a0			; get the menu number
	lea m_tabl(pc),a1
	moveq #0,d0	
	move.b (a0),d0
.where	move.w (a1)+,d1	; option
	move.l (a1)+,d2	; extender
	cmp.b d0,d1				; correct?
	bne.s .where
	lea fileext(pc),a0
	move.l d2,(a0)				; store file extender into s_first mask

	lea DTA(pc),a0
	lea output(pc),a1
.ww	clr.b (a0)+				; clear out our local DTA buffer
	cmp.l a0,a1
	bne.s .ww

	lea ostart(pc),a0
	lea oend(pc),a1
.www	clr.b (a0)+				; clear out our "directory" buffer
	cmp.l a0,a1
	bne.s .www

	pea DTA(pc)				; set DTA
	move.w #$1a,-(a7)
	trap #1
	lea 6(a7),a7

	lea output+26(pc),a6			; where we start storing the filenames+info

	move.w #$02,-(a7)
	pea filespc(pc)
	move.w #$4e,-(a7)
	trap #1					; get the first entry
	lea 8(a7),a7

	bsr .move_dir				; process it!

.rdloop	move.w #79,-(a7)
	trap #1					; get the next entry
	add.l #2,a7
	tst.w d0
	bmi.s .out				; all done?
	bsr .move_dir				; process it!
	bra .rdloop				; loop around!

.out
	move.l #$20202020,(a6)+			; mark the end of the table with what F1GP expects
	move.l #$00000000,(a6)+			; as an End Of Directory marker
	move.l #$00000000,(a6)+
	move.l #$00000000,(a6)+
	move.l #$00000000,(a6)+
	move.l #$00000000,(a6)+
	move.w #$0000,(a6)+	
	
	lea eot(pc),a0				; tell our code where the end of the table is
	move.l a6,(a0)
	rts


.move_dir
	lea DTA+30(pc),a5
	move.l a6,a4			; pointer to next entry
	moveq #11,d7
.fnm	move.b (a5)+,d0		
	beq.s .done
	move.b d0,(a4)+			; store the filename
	dbra d7,.fnm
.done	lea DTA+26(pc),a5
	move.l #$00a90133,12(a6)	; marker for F1 to display this file
	move.l #$00000400,22(a6)	; (we are using extenders, F1 uses special file markers in the index table)
	move.l (a5),16(a6)	  	; filesize
	lea 26(a6),a6			; next entry!
	rts

eot	dc.l 0

filespc	dc.b "DATA\*"			; where we're saving to
fileext	dc.b ".SAV",0
	even

DTA	ds.b 44				; local DTA buffer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; F1GP directory header format
;;

output	
	dc.b $66,$31,$67,$70,$00,$00,$00,$00
	dc.b $80,$00,$08,$8b,$00,$05,$00,$a4
	dc.b $00,$00,$05,$e0,$00,$00,$00,$00
	dc.b $04,$00
ostart	ds.b 26*80
oend
	even

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; The Magic Code!
;;

	include "uls3.s"