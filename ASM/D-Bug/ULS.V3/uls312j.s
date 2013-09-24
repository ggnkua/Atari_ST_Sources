;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Universal Loading System: v3.12(j)
;; ----------------------------------
;;
;; Started:    04/10/08
;; This build: 17/03/09  
;;
;; (c) 2005-2009 D-Bug
;;
;; Concept and core code by Cyrano Jones / D-Bug 
;; MFP and PMMU code by Defjam / Checkpoint
;; Additional code by GGN / D-Bug
;; 
;; I would also like to thank Klapauzius for the field testing and additional input
;;
;; The RAMdisk is Dead! Long live ULS!
;; 
;; Universal Loading System v3 (c) 2005-2008 D-Bug. All Rights Reserved.
;; This software is released as Open Source and may be used, viewed or modified
;; by anyone.
;;
;; D-Bug accept no responsibility for any loss of data or damage to your equipment from using
;; this code or any of our patches (Although, of course, we don't expect there ever to be any!)
;;
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Defines (Sorry, it still needs some)
;;


; Moved to stubloader source for easier access while debugging
;
;max_filesize		equ 142*1024		; Size of biggest file to be read/written via ULS
;adv_debug					; Define for debugging screen


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; ULS jmp offsets
;;

uls_setup	equ $0			; Call to initialize the ULS system
					;
					; ULS Parameters:
					;
					; A0.L: RAMTop for ULS
					; D0.W: CPU Clock Control (-1: 8mhz / 1: 16mhz)
					; D1.W: CPU Cache Control (-1: Off / 1: on)
					;
					; RAMDisk Parameters:
					;
					; D6.L: 4 char ASCII of initial folder to make ramdisk from
					; D7.L: Ramdisk Creation Flag (D7.L="RAMD" for create)
					; A6.L: Size of RAMDISK in bytes (Size of Data+(20*No of files))+8
					; A5.L: Pointer to a filespec to use to build the ramdisk
					;
					; Returns:
					;
					; A0=JMP Table address
					; A1=Filebuffer address
					; A2=Highest address saved
					; A3=Low memory address during ULS
					; D0.L=Machine type
					; D1.L=!HD! flag
					; D2.W=VGA (1) / RGB (2)
		
uls_file_io	equ $4			; Call for file_io
					;
					; A0.L: address of filename  
					; A1.L: address to transfer to/from
					; D0.L: bytes to IO ($ffffffff = all - if write, as much as was in overwritten file)
					; D1.L: seek offset ($00000000 = start of file) NB: Can't seek and overwrite in WRITE MODE
					; D7.L: READ MODE:  Load to ULS_buffer flag (0=normal, -1=Load to ULS_buffer)
					;       WRITE MODE: -1 = f_create, otherwise file already exists.
					;
					; Returns:
					;
					; D0.L: UNPACKED length of file from Pack Header (If known packer)
					; D1.L: Actual length bytes written/read
					; D0.L: -1 if File Not Found

uls_terminate	equ $c			; Call to put system back to init
					;
					; D0.L: set to #'RTS!' to not exit to system (P_TERM/TRAP #1)
					; A0.L: Address to JMP to if D0=#'RTS!'
					;

uls_setread	equ $10			; Call to put ULS in read mode
uls_setwrite	equ $14			; Call to put ULS in write mode
uls_dumpscreen	equ $18			; Call to grab screenshot as PI1
uls_execute	equ $1c			; call to execute user code under TOS

uls_statesave	equ $20			; Call to snapshot system to disk for later resume	
					;
					; D0.L: Ramtop for dump file
					; D1.L: return JMP address for resume
					; ULS_Filebuffer must be loaded with a register dump (See function for details)

uls_stateload	equ $24			; Call to resume system from a previously created statesave

uls_setpath	equ $28			; Call to change the DATA name
					;
					; D0.L: 4 byte ascii for new folder name.

uls_req_rd_addr	equ $2c			; Call to get the address of a file in the RAMdisk
					;
					; A0.L: address of filename
					;
					; Returns:
					;
					; A0.L: address of file header in RAMdisk
					;       File is at 20(a0)


uls_F30set200	equ $30			; Call to set the VIDEL to 320x200x16 (RGB/VGA detected from INIT)

uls_F30set240	equ $34			; Call to set the VIDEL to 320x240x16 (RGB/VGA detected from INIT)

uls_F30set200TC	equ $38			; Call to set the VIDEL to 320x200xTC (RGB/VGA detected from INIT)

uls_update_rdsk	equ $3c			; Call to update the RAMdisk
					;
					; D0.L: 4 char ASCII of initial folder to make ramdisk from
					; D1.W: -1 = replace ramdisk
					;       +1 = append to ramdisk
					; A0.L: pointer to filespec for ramdisk (eg *.*)
					;
					;
					; NOTE: The new ramdisk *MUST* fit inside the paramters passed to "uls_setup"
					;

uls_search	equ $40			; Call to search / replace a byte sequence between 2 memory ranges
					;
					; A0.L: address to start searching
					; A1.L: address to end searching
					; A2.L: pointer to bytes to match
					; A3.L: pointer to bytes to overwrite
					; D0.L: length of search string
					; D1.L: length of replace string


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Universal Loading System
;;
;; (c) 2005-2008 D-Bug
;;
;; 

uls	bra uls_init			; +$00 	
	bra uls_core			; +$04
	bra uls_post_relocate_init	; +$08
	bra uls_restore_launch_env	; +$0c
	bra uls_read_mode		; +$10
	bra uls_write_mode		; +$14
	bra uls_screenshot		; +$18
	bra uls_usercode_exec		; +$1c
	bra uls_suspend_disk		; +$20
	bra uls_resume_disk		; +$24
	bra uls_change_data_folder	; +$28
	bra uls_get_ramdisk_address	; +$2c
	bra uls_F30set320x200		; +$30
	bra uls_F30set320x240		; +$34
	bra uls_F30set320x200TC		; +$38
	bra uls_update_rd		; +$3c
	bra uls_search_replace		; +$40

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Variables
;;
;;

;;
;; Variables *NOT* saved to statefile (There should be a lot more of these and I will tidy this up in the future!)
;;

TOS_rambase		ds.l 1			; base address of loader stored here (End of GEMDOS copy)
ULS_SYS_mem		ds.l 1			; Game env. memory dump starts here
SYS_stack		ds.l 1			; system stack
ramdisk_enable		ds.l 1			; Ramdisk flag
ramdisk_base		ds.l 1			; address of RAMdisk base
ramdisk_spec		ds.l 1			; pointer to filespec for ramdisk pre-loader
SYS_sr			ds.w 1			; SR on entry
TOS_pal			ds.w 16			; pallette from application
TOS_res			ds.w 1			; resolution on entry
ikbd_SYS		ds.l 1			; the original IKBD vector
request_16mhz		ds.w 1			; flag used by init to see if you want 16mhz
ULS_scr			ds.l 1			; debug/pi1 workspace
ULS_TOS_mem		ds.l 1			; GEMDOS env. memory dump starts here
ULS_filebuffer		ds.l 1			; workspace for load/save data
TOS_ramtop		ds.l 1			; Physical system RAMtop
SYS_PSG			ds.w 1			; psg on init (ffff8800 Port a/b)
GEM_fa0d		ds.b 1			; additional MFP data
GEM_fa11		ds.b 1
			ds.b 8
GEMta_control     	ds.b 1			; GEMDOS MFP state
GEMtb_control     	ds.b 1
GEMtcd_control    	ds.b 1
GEMta_data        	ds.b 1
GEMtb_data        	ds.b 1
GEMtc_data        	ds.b 1
GEMtd_data        	ds.b 1
	               	even
GEMmfp_save       	ds.b 64
SYS_484			ds.w 1			; keyclick
ULS_on_hd		ds.l 1			; Set to '!HD!' during ULS_init if not A/B
ULS_drive		ds.w 1			; Number of launch drive
machine			ds.w 1			; 0=st 1=ste 2=mste 3=falcon 4=tt
old_mhz			ds.w 1			; speed on entry to ULS core
SYS_VBR			ds.l 2			* location of original VBR
SYS_cacr		ds.l 1			* state of cache control register before init
SYS_PMMU		ds.l 3			* state of tc/tt0/tt1 MMU registers
sys_FCPUC		ds.w 1			; Falcon CPU Control
falc_scr		ds.w 1			; Falcon Screen Mode
TOS_screen		ds.l 1			; desktop screen base
initial_rd_folder	ds.l 1			; Initial 4-char ASCII folder name passed to init

;;
;; Variables saved to statefile
;;

top_of_variable_table



read_write_flag		ds.w 1			; +vs read / -ve write
SYS_screen		ds.l 1			; game env. screen address
copy_data		ds.w 1			; flag for read to buffer only/read to load address (useful if skewing tracks)
			ds.w 1			; degas header
SYS_pal			ds.w 16			; pallette on entry

APP_PSG			ds.w 1			; psg for application
APP_sr			ds.w 1			; sr for application
SYS_res			ds.w 1			; system resolution
fnf_flag		ds.l 1			; file not found flag
user_code_addr		ds.l 1			; address of user routine

sys_filename		ds.l 1			; address of filename in RAW or F_OPEN format
ULS_fn_header		dc.b "DATA\"
ULS_filename		ds.b 14			; filename re-built here 
			even
ULS_load_addr		ds.l 1			; org load address
ULS_bytes_loaded	ds.l 1			; returned byte count (From pack header)
ULS_bytes_loaded2	ds.l 1			; returned byte count (Actual size)
ULS_bytes_io		ds.l 1			; bytes to read/write(!)
ULS_seek_offset		ds.l 1			; offset to seek
ULS_ret_add		ds.l 1			; where ULS was called from
ULS_registers		ds.l 64			; system register storage
write_tick		ds.w 1			; used for "write cooldown" after file save
ikbd_key		ds.w 1			; used by dummy IKBD
APP_fa17		ds.w 1
APPta_control     	ds.b 1			; Game env. MFP state
APPtb_control 	    	ds.b 1
APPtcd_control 	   	ds.b 1
APPta_data     	   	ds.b 1
APPtb_data        	ds.b 1
APPtc_data        	ds.b 1
APPtd_data        	ds.b 1
                	even
APPmfp_save       	ds.b 64
scr_fn			dc.b "ULS_0000.PI1",0	; screendump filename
			even
scr_count		ds.w 1			; screendump counter
uls_cpus		ds.w 1
my_vecs			ds.l 11			; Used during falcon IDE delay
falc_frame		ds.w 1			; Used during falcon IDE delay
ULS_handle		ds.w 1			; ULS file handle
current_a7		ds.l 1
composite		ds.w 1			; 1=VGA 2=RGB

bot_of_variable_table	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Put ULS in read mode
;;

uls_read_mode

	move.l a5,-(a7)
	lea read_write_flag(pc),a5
	move.w #1,(a5)	
	move.l (a7)+,a5
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Put ULS in write mode
;;

uls_write_mode

	move.l a5,-(a7)
	lea read_write_flag(pc),a5
	move.w #-1,(a5)
	move.l (a7)+,a5	
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Change the name of the data folder
;;

uls_change_data_folder
	move.l a5,-(a7)
	lea ULS_fn_header(pc),a5
	move.l d0,(a5)
	move.l (a7)+,a5
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Restore the system
;;


uls_restore_launch_env
	lea uls(pc),a7

	lea term_mode(pc),a6
	move.l d0,(a6)+
	move.l a0,(a6)

	move.w #$2700,SR
	clr.b   $FFFFFA19.w		; timers stop
        clr.b   $FFFFFA1B.w
        clr.b   $FFFFFA1D.w

	lea $8.w,a1			; destination
	lea ULS_TOS_mem(pc),a0
	move.l (a0),a0			; source
	lea TOS_rambase(pc),a2		; last byte
	move.l (a2),d7
	bsr block_move			; restore GEMDOS memory

	lea machine(pc),a6		; Falcon / TT test
	cmp.w #3,(a6)
	beq.s .re_pmmu
	cmp.w #4,(a6)			* restore stuff on the TT too
	beq.s .re_pmmu
	bra.s .no_pmmu
.re_pmmu
	lea machine(pc),a5
	cmp.w #3,(a5)			; Falc Test
	bne.s .ftt			* restore CPU mode only on falcon

	lea 	sys_FCPUC(pc),a0	; restore CPU mode
	move.b (a0),d0
	or.b #%00100101,d0
	move.b 	d0,$ffff8007.w
.ftt
	dc.l	$f0002400		* pflusha - flush caches
	lea	SYS_cacr(pc),a0		* restore cache
	move.l	(a0),d0
	dc.l	$4e7b0002		* movec d0,cacr

	lea	SYS_VBR(pc),a0
	dc.l	$f0104c00		* pmove (a0),VBR *restore VBR*

	lea	SYS_PMMU(pc),a0		* restore tc/tt0/tt1
	dc.w	$f028,$4000,$0000	* pmove (a0),tc
	dc.w	$f028,$0800,$0004	* pmove 4(a0),tt0
	dc.w	$f028,$0c00,$0008	* pmove 8(a0),tt1

.no_pmmu
	bsr flush_acia
	
	lea $ffff8800.w,a0		; kill sound
	move.l #$08080000,(a0)
	move.l #$09090000,(a0)
	move.l #$0a0a0000,(a0)

	lea GEMta_data(PC),A3		; restore GEMDOS timers
	lea GEMta_control(PC),A4
	bsr restore_timers
	lea GEMmfp_save(pc),a1
	bsr restore_mfp

	lea GEM_fa0d(pc),a0
	move.b (a0)+,$fffffa0d.w	; fix up MFP a bit
	move.b (a0)+,$fffffa11.w

	lea SYS_sr(pc),a0		; restore SR
	move.w (a0),sr

	lea ikbd_SYS(pc),a0
	move.l (a0),$118.w		; restore system keyboard vector

	move.b #$80,d0			; reset ikbd
	bsr .sikbd
	move.b #$1,d0
	bsr .sikbd

	lea SYS_484(pc),a0		; restore keyclick
	move.b (a0),$484.w

	lea SYS_PSG(pc),a0		; restore psg
	bsr load_PSG

	lea TOS_screen(pc),a5		; restore screen
	move.b 1(a5),$ffff8201.w
	move.b 2(a5),$ffff8203.w
	move.b 3(a5),$ffff820d.w

	lea TOS_pal(pc),a5		; restore pallette
	movem.l (a5),d0-7
	movem.l d0-7,$ffff8240.w

	lea SYS_stack(pc),a0		; restore stack
	move.l (a0),a7

	moveq #0,d0
	lea machine(pc),a5
	cmp.w #3,(a5)
	bne.s .ok1
	move.w #3,d0
	move.l #14,d7
	move.w falc_scr(pc),-(a7)
	bra.s .ok2
.ok1	lea TOS_res(pc),a5		; restore resolution
	move.b (a5),d0
	move.l #12,d7
.ok2	move.w d0,-(a7)
	lea TOS_screen(pc),a5
	move.l (a5),-(a7)
	move.l (a5),-(a7)
	move.w #5,-(a7)
	trap #14
	add.l d7,a7

	lea term_mode(pc),a0
	cmp.l #'RTS!',(a0)+
	bne.s .pterm
	move.l (a0)+,a0
	jmp (a0)

.pterm	clr.l -(a7)			; sayonara!
	trap #1

.sikbd	btst #1,$fffffc00.w
	beq.s .sikbd
	move.l #$600,d1
.hang1	subq.l #1,d1
	bne.s .hang1
	move.b d0,$fffffc02.w
	rts


term_mode	dc.l 0
term_add	dc.l 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Write "cooldown" (Allow drives to flush cache after a write operation)
;;


write_cooldown
	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_wrcd(pc),a1
	bsr info			
	movem.l (a7)+,d0-7/a0-6
	endc

	movem.l d0-7/a0-6,-(a7)
	lea write_vbl_old(pc),a0	; store system VBL
	move.l $70.w,(a0)
	lea write_vbl(pc),a0		; set up my own
	move.l a0,$70.w

	lea write_tick(pc),a0		; tick counter
	
	move.w #49,d7			; 50 frames=1 second
.onesec	bsr write_hold_vbl	
	dbra d7,.onesec

	lea write_vbl_old(pc),a0
	move.l (a0),$70.w		; system vbl back

	move.w sr,-(a7)
	move.w #$2700,sr		; kill all interupts
	lea $808.w,a0			; refresh gemdos shadow memory (But not the base/vectors)
	lea ULS_TOS_mem(pc),a1
	move.l (a1),a1			; destination
	lea $800(a1),a1
	lea TOS_rambase(pc),a2		; last byte
	move.l (a2),d7
	sub.l #$800,d7
	bsr block_move
	move.w (a7)+,sr

	movem.l (a7)+,d0-7/a0-6
	rts

write_hold_vbl
	clr.w (a0)			; wait 1 vbl
	move.w (a0),d0
.hold	cmp.w (a0),d0
	beq.s .hold
	rts

write_vbl
	move.l a0,-(a7)
	lea write_tick(pc),a0
	add.w #1,(a0)
	move.l (a7)+,a0
	dc.w $4ef9
write_vbl_old	dc.l 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; C_CONWS Debug Output (Used during init)
;;

i_prnt	movem.l d0-a6,-(a7)		; if you need this routine explained, then this source
	move.l a4,-(a7)			; file is NOT for you :-)
	move.w #9,-(a7)
	trap #1
	lea 6(a7),a7
	move.l #$ffff,d0
.wank	nop
	subq.l #1,d0
	bne.s .wank
	movem.l (a7)+,d0-a6
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Call with:
;;
;; A0.L:RAMTOP
;; D0.L:16mhz Request        (-ve = 8mhz)
;; D1.L:Cache Request (030)  (-ve = off!)
;;
;; D6.L: 4 char ASCII of initial folder to make ramdisk from
;; D7.L: Ramdisk Creation Flag (D7.L="RAMD" for create)
;; A6.L: Size of RAMDISK in bytes (Size of Data+(17*No of files))
;; A5.L: Pointer to a filespec to use to build the ramdisk
;;
;; Returns:
;;
;; A0=JMP Table address
;; A1=Filebuffer address
;; A2=Highest address saved
;; A3=Low memory address during ULS
;;
;; D0.L=Machine type
;; D1.L=!HD! flag
;; D2.W=VGA (1) / RGB (2)

uls_init
	ifd adv_debug
	lea i_init(pc),a4
	bsr i_prnt
	endc

	bsr detect_hardware

	ifd adv_debug
	lea i_cvars(pc),a4
	bsr i_prnt
	endc
	lea SYS_stack(pc),a1
	move.l a7,(a1)

	sub.l #(ULS_TRASH_RAM-uls),a0
	move.l a0,-(a7)			; relocate ULS to desired address

	lea ramdisk_enable(pc),a1
	move.l d7,(a1)

	lea ramdisk_spec(pc),a1
	move.l a5,(a1)

	lea ramdisk_base(pc),a1
	move.l a6,(a1)

	lea initial_rd_folder(pc),a1
	move.l d6,(a1)			; set ramdisk-builder to correct default folder

	lea ULS_fn_header(pc),a1	
	move.l d6,(a1)			; point ULS at default directory

	lea SYS_sr(pc),a1		; save SR
	move.w sr,(a1)

	movem.l d0-7,-(a7)
	lea TOS_pal(pc),a1		; save pallette
	movem.l $ffff8240.w,d0-7
	movem.l d0-7,(a1)
	movem.l (a7)+,d0-7

	lea TOS_res(pc),a1		; save resolution
	move.b $ffff8260.w,(a1)

	ifd adv_debug
	lea i_reloc(pc),a4
	bsr i_prnt
	endc

	lea uls(pc),a1			; top of ULS code
	lea ULS_TRASH_RAM(pc),a2	; end of ULS code
.movuls	move.b (a1)+,(a0)+
	cmp.l a1,a2
	bne.s .movuls
	move.l (a7)+,a0
	lea 8(a0),a0

	jmp (a0)			; init ULS!

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Init debug text
;;

	ifd adv_debug
i_init	dc.b 27,"EULS init called....",13,10
	dc.b 13,10
	dc.b "Detecting Hardware...",13,10,0
i_cac_o	dc.b "68030 caches disabled...",13,10,0
i_cvars	dc.b "Storing ULS base variables...",13,10,0
i_cbuff	dc.b "Calculating buffers...",13,10,0
i_reloc	dc.b "Relocating ULS to High Memory...",13,10,0
i_snap	dc.b "Creating Low Memory snapshot...",13,10,0
i_hw	dc.b "Configuring hardware...",13,10,0
i_rd	dc.b "Building RAMdisk...",13,10,0
i_lfcr	dc.b 13,10,0
i_exit	dc.b "Exit ULS_init",13,10,0
	even

	endc

uls_post_relocate_init
	sub.l #8,a0			; start of ULS below RAMTOP
	move.l a0,-(a7)

	lea ikbd_SYS(pc),a1		; save system ikbd vector and install my own dummy one
	move.l $118.w,(a1)
	lea uls_ikbd(pc),a1
	move.l a1,$118.w

	lea request_16mhz(pc),a6	; store cpu speed requested
	move.w d0,(a6)

	tst.w d1	
	bmi.s .cac_off
	lea nop_me_out(pc),a6
	move.l #$4e714e71,(a6)		; if cache=on, disable the cache off command
.cac_off
	ifd adv_debug
	lea i_cbuff(pc),a4
	bsr i_prnt
	endc

	move.l a0,d1			; RAMTop
	sub.l #32512,d1
	clr.b d1
	lea ULS_scr(pc),a5
	move.l d1,(a5)			; ULS debug/pi1 buffer
	
	lea ramdisk_enable(pc),a5
	cmp.l #'RAMD',(a5)
	bne .no_rd

	lea ramdisk_base(pc),a5
	move.l (a5),d0			; get ramdisk size
	add.l #512,d0
	sub.l d0,d1
	bclr #0,d1
	move.l d1,(a5)			; base of ramdisk

.no_rd	sub.l #uls,d1
	sub.l #128,d1			
	bclr #0,d1
	lea ULS_TOS_mem(pc),a5
	move.l d1,(a5)			; TOS saved here

	move.l #uls,d0
	lea TOS_rambase(pc),a5
	move.l d0,(a5)			; GEMDOS highest byte

	sub.l d0,d1
	sub.l #128,d1
	lea ULS_SYS_mem(pc),a5
	move.l d1,(a5)			; Application saved here

	sub.l #1024,d1			; overflow clearance

	sub.l #max_filesize,d1
	sub.l #128,d1
	bclr #0,d1
	lea ULS_filebuffer(pc),a5	
	move.l d1,(a5)			; filebuffer here

	move.l $42e.w,d0
	lea TOS_ramtop(pc),a5
	move.l d0,(a5)			; store Physical RAMtop

	lea ULS_TRASH_RAM(pc),a5
	move.l a5,d0
	cmp.l d1,d0			; ran out of memory?
	bge.s .all_ok

.memerr	neg.w $ffff8240.w
	bra.s .memerr
.all_ok
	lea ULS_on_hd(pc),a0
	clr.l (a0)
	move.w #$19,-(a7)
	trap #1				; get drive
	add.l #2,a7
	lea ULS_on_hd(pc),a0
	tst.w d0
	beq.s .flop
	cmp.w #1,d0
	beq.s .flop
	move.l #'!HD!',(a0)
.flop	lea ULS_drive(pc),a0
	move.w d0,(a0)			; store launch drive

	nop
	lea SYS_PSG(pc),a0		; save PSG
	bsr save_PSG

	move.w #$2700,sr		; save gemdos timers
	lea GEMmfp_save(pc),a1
        bsr save_mfp
        lea GEMta_control(PC),A0
        lea GEMta_data(PC),A3
        bsr save_timers
	lea GEMta_data(pc),a3
	lea GEMta_control(pc),a4
	bsr restore_timers
	lea GEMmfp_save(pc),a1
	bsr restore_mfp

	bsr uls_read_mode		; put ULS in read mode

	lea TOS_screen(pc),a6		; store desktop screen base
	move.b $ffff8201.w,d0
	move.b $ffff8203.w,d1
	move.b $ffff820d.w,d2
	move.b d0,1(a6)
	move.b d1,2(a6)
	move.b d2,3(a6)

	lea GEM_fa0d(pc),a0
	move.b $fffffa0d.w,(a0)+	; save extra MFP
	move.b $fffffa11.w,(a0)+

	lea SYS_484(pc),a0		; save keyclick
	move.b $484.w,(a0)
	clr.b $484.w			; kill keyclick

	ifd adv_debug
	lea i_cac_o(pc),a4
	bsr i_prnt
	endc
	bsr core_cache_off

	ifd adv_debug
	lea i_snap(pc),a4
	bsr i_prnt
	endc
	
	lea $8.w,a0			; source
	lea ULS_TOS_mem(pc),a1
	move.l (a1),a1			; destination
	lea TOS_rambase(pc),a2		; last byte
	move.l (a2),d7
	bsr block_move

	bsr flush_acia			; flush ikbd

	lea ramdisk_enable(pc),a5	; pre-build the RAMdisk automagically
	cmp.l #'RAMD',(a5)
	bne.s .no_rd2

	ifd adv_debug
	lea i_rd(pc),a4
	bsr i_prnt
	endc
	bsr init_ramdisk
.no_rd2
	ifd adv_debug
	lea i_hw(pc),a4
	bsr i_prnt
	endc

	bsr core_cache_on

	bsr setup_hardware		; set video hardware
	bsr kill_f030			; PMMU and cache settings
	bsr info_init			; init text pointers

	bsr proc_16mhz_req

	lea $4ce.w,a0			; shut down ICDtools vbl-queue driver
	moveq #7,d0			; (ULS will re-init it on copy-back for IO)
.killchain
	clr.l (a0)+
	dbra d0,.killchain

	lea machine(pc),a1	
	move.w (a1),d0			; machine type in d0

	lea ULS_on_hd(pc),a1		; #!HD! if on HD in d1
	move.l (a1),d1

	lea composite(pc),a1		; 1=VGA
	moveq #0,d2			; 2=RGB
	move.w (a1),d2

	lea TOS_rambase(pc),a1
	move.l (a1),a2			; return highest byte in a2

	lea ULS_SYS_mem(pc),a1		; return address of low-memory during ULS
	move.l (a1),a3

	lea ULS_filebuffer(pc),a1
	move.l (a1),a1			; return address of ULS filebuffer

	move.l (a7)+,a0			; return address of ULS jmp table

	rts


proc_16mhz_req
	lea request_16mhz(pc),a5
	lea machine(pc),a6
	cmp.w #2,(a6)
	beq .mste
	cmp.w #3,(a6)
	beq .falc
	rts

.mste	lea nop_me_out(pc),a6
	cmp.l #$4e714e71,(a6)		; check cache enable request
	bne .mcoff
.mcon	or.b #%11111110,$ffff8e21.w	; enable MSTe cache
	bra.s .mgo
.mcoff	and.b #%00000001,$ffff8e21.w	; disable MSTe cache
.mgo	tst.w (a5)			; now test CPU speed
	bpl .mset16
.mset8	bclr.b #0,$ffff8e21.w		; set 8mhz
	rts
.mset16	bset.b #0,$ffff8e21.w		; set 16mhz
	rts

.falc	tst.w (a5)
	bpl .fset16
.fset8	bclr.b #0,$ffff8007.w
	rts
.fset16	bset.b #0,$ffff8007.w
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Videl set 320x200 
;;

uls_F30set320x200
	move.l a0,-(a7)
	lea composite(pc),a0
	cmp.w #2,(a0)
	beq .rgb
.vga	move.l (a7)+,a0
	bsr vga200
	rts
.rgb	move.l (a7)+,a0
	bsr rgb200
	rts

vga200	move.l	#$170012,$ffff8282.w		;falcon 60Hz vga
	move.l	#$1020e,$ffff8286.w		;
	move.l	#$d0012,$ffff828a.w		;
	move.l	#$41903ff,$ffff82a2.w		;
	move.l	#$3f008d,$ffff82a6.w		;
	move.l	#$3ad0415,$ffff82aa.w		;
	move.w	#$200,$ffff820a.w		;
	move.w	#$186,$ffff82c0.w		;
	clr.w	$ffff8266.w			;
	clr.b	$ffff8260.w			;
	move.w	#$5,$ffff82c2.w			;
	move.w	#$50,$ffff8210.w		;
	rts

rgb200	move.l	#$300027,$ffff8282.w		;falcon 50Hz rgb
	move.l	#$70229,$ffff8286.w		;
	move.l	#$1e002a,$ffff828a.w		;
	move.l	#$2710265,$ffff82a2.w		;
	move.l	#$2f0081,$ffff82a6.w		;
	move.l	#$211026b,$ffff82aa.w		;
	move.w	#$200,$ffff820a.w		;
	move.w	#$185,$ffff82c0.w		;
	clr.w	$ffff8266.w			;
	clr.b	$ffff8260.w			;
	clr.w	$ffff82c2.w			;
	move.w	#$50,$ffff8210.w		;
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Videl set 320x240 
;;

uls_F30set320x240
	move.l a0,-(a7)
	lea composite(pc),a0
	cmp.w #2,(a0)
	beq .rgb
.vga	move.l (a7)+,a0
	bsr vga240
	rts
.rgb	move.l (a7)+,a0
	bsr rgb240
	rts

vga240	move.l #$170012,$ffff8282.w
	move.l #$02020e,$ffff8286.w
	move.l #$0d0012,$ffff828a.w
	move.l #$041903fd,$ffff82a2.w
	move.l #$3f003d,$ffff82a6.w
	move.l #$03fd0415,$ffff82aa.w
	move.w #$200,$ffff820a.w
	move.w #$186,$ffff82c0.w
	clr.w $ffff8266.w
	clr.b $ffff8260.w
	move.w #$5,$ffff82c2.w
	move.w #$50,$ffff8210.w
	rts

rgb240	move.l #$c7009f,$ffff8282.w
	move.l #$1f02b9,$ffff8286.w
	move.l #$8800ab,$ffff828a.w
	move.l #$020d0201,$ffff82a2.w
	move.l #$17001b,$ffff82a6.w
	move.l #$01fb0207,$ffff82aa.w
	move.w #$200,$ffff820a.w
	move.w #$185,$ffff82c0.w
	clr.w $ffff8266.w
	clr.b $ffff8260.w
	move.w #$10,$ffff82c2.w
	move.w #$0,$ffff8210.w
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Videl set 320x200xTC 
;;

uls_F30set320x200TC
	move.l a0,-(a7)
	lea composite(pc),a0
	cmp.w #2,(a0)
	beq .rgb
.vga	move.l (a7)+,a0
	bsr vgaTC
	rts
.rgb	move.l (a7)+,a0
	bsr rgbTC
	rts

vgaTC	MOVE.L   #$C6008D,$FFFF8282.W		; falcon VGA
        MOVE.L   #$1502AC,$FFFF8286.W
        MOVE.L   #$8D0097,$FFFF828A.W
        MOVE.L   #$4190385,$FFFF82A2.W
        MOVE.L   #$650065,$FFFF82A6.W
        MOVE.L   #$3850415,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$186,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$100,$FFFF8266.W
        MOVE.W   #$5,$FFFF82C2.W
        MOVE.W   #$140,$FFFF8210.W
	rts

rgbTC	MOVE.L   #$FE00CB,$FFFF8282.W		; falcon TV 320x200xTC@50Hz
        MOVE.L   #$27002E,$FFFF8286.W
        MOVE.L   #$8F00D9,$FFFF828A.W
        MOVE.L   #$2710265,$FFFF82A2.W
        MOVE.L   #$2F007F,$FFFF82A6.W
        MOVE.L   #$20F026B,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$183,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$100,$FFFF8266.W
        MOVE.W   #$0,$FFFF82C2.W
        MOVE.W   #$140,$FFFF8210.W
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; ULS Dummy IKBD Routine
;;

uls_ikbd
	move.l a0,-(a7)
	lea ikbd_key(pc),a0
	move.b $fffffc02.w,(a0)
	move.l (a7)+,a0
	bclr.b #6,$ffffffa11.w
	rte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; ULS Ramdisk Updater 
;;
;; D0.L: 4 char ASCII of initial folder to make ramdisk from
;; D1.W: -1 = replace ramdisk
;;       +1 = append to ramdisk
;;
;; A0.L: pointer to filespec for ramdisk (eg *.*)
;;

uls_update_rd
	move.l a0,-(a7)
	lea new_rd_filespec(pc),a6
	move.l a0,(a6)			; store new filespec pointer

	lea new_rd_dir(pc),a0
	move.l d0,(a0)			; store new RAMdisk folder name

	lea rd_update_type(pc),a0	; store RAMdisk update mode
	move.w d1,(a0)

	lea read_write_flag(pc),a6	; store ULS access mode
	move.w (a6),-(a7)
	move.w #'RU',(a6)		; put ULS in RAMdisk Update mode
	lea user_code_addr(pc),a6
	move.l a0,(a6)
	bsr uls_core
	lea read_write_flag(pc),a6
	move.w (a7)+,(a6)		; restore ULS access mode

	lea new_rd_dir(pc),a0
	clr.l (a0)
	lea rd_update_type(pc),a0
	clr.w (a0)
	move.l (a7)+,a0
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; ULS_search
;; 
;; Call to search / replace a byte sequence between 2 memory ranges
;;
;; A0.L: address to start searching
;; A1.L: address to end searching
;; A2.L: pointer to bytes to match
;; A3.L: pointer to bytes to overwrite
;; D0.L: length of search string
;; D1.L: length of replace string
;;

uls_search_replace
	
	move.l a2,-(a7)			; store search sequence pointer

.search	cmp.l a0,a1
	beq .end_search
	move.b (a2),d6
	cmp.b (a0)+,d6
	bne.s .search			; find first byte

	move.l a0,-(a7)

	move.l d0,d7
	subq.l #1,d7
	move.b (a2)+,d6
.find	move.b (a2)+,d6
	cmp.b (a0)+,d6
	bne.s .nomatch
	subq.l #1,d7
	bne.s .find

.found	move.l (a7)+,a0			; address of pattern
	subq.l #1,a0
	move.l (a7)+,a2			; pop search sequence address
.write	move.b (a3)+,(a0)+
	subq.l #1,d1
	bne.s .write
	rts
	
.nomatch
	move.l (a7)+,a0			; continue from next byte
	move.l (a7),a2			; restore sequence pointer
	bra.s .search

.end_search
	move.l (a7)+,a2
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; User Code Execute
;;
;; Call with A0=address of code to execute under TOS (RTS terminated)
;;

uls_usercode_exec
	lea read_write_flag(pc),a6	; store ULS access mode
	move.w (a6),-(a7)
	move.w #'UC',(a6)		; put ULS in usercode mode
	lea user_code_addr(pc),a6
	move.l a0,(a6)
	bsr uls_core
	lea read_write_flag(pc),a6
	move.w (a7)+,(a6)		; restore ULS access mode
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; State Save
;;
;; Call with:
;;
;; ULS filebuffer with register/sr dump using the following code from the stub:
;;
;;
;;	move.l a0,-(a7)
;;	lea uls_fb(pc),a0
;;	move.l (a0),a0
;;	add.l #4,a7			; correct the stack for reg-dump
;;	movem.l d0-7/a1-7,(a0)
;;	sub.l #4,a7			; and put it back
;;	lea 60(a0),a0
;;	move.w sr,(a0)+
;;	move.l (a7),(a0)+
;;	move.l (a7)+,a0
;;
;; D0.L: RAMtop for Dump File
;; D1.L: return JMP address for resume
;;


uls_suspend_disk
	lea resuming(pc),a6	
	move.l #'NOPE',(a6)
	lea ULS_on_hd(pc),a0
	cmp.l #'!HD!',(a0)
	beq.s .go
	rts				; No suspend on Floppy!!!

.go	lea state_menu(pc),a0
	move.l #'SAVE',(a0)

	lea read_write_flag(pc),a6	; store ULS access mode
	move.w (a6),-(a7)
	move.w #'SD',(a6)		; put ULS in suspend mode
	bsr uls_core
	lea read_write_flag(pc),a6
	move.w (a7)+,(a6)		; restore ULS access mode
	rts

suspend_code
	move.w #$2300,sr		; ok we need timer-c at least!

	lea $ffff8800.w,a0		; kill sound
	move.l #$08080000,(a0)
	move.l #$09090000,(a0)
	move.l #$0a0a0000,(a0)

	lea machine(pc),a0
	cmp.w #3,(a0)
	beq.s .mc30
	cmp.w #4,(a0)
	bne.s .mc00
.mc30
	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_flshc(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	dc.l	$f0002400		* pflusha - flush caches
.mc00	bsr falcon_delay


	move.l $ffff8240.w,-(a7)
	bsr state_menuscreen		; user interface!
	move.l (a7)+,$ffff8240.w
	
	tst.b d0			; esc or a file?
	bpl.s .yay

	lea resuming(pc),a6		; esc	
	move.l #'NOPE',(a6)

	rts

.yay	lea susp_fn+7(pc),a0		; correct the filename
	add.b #'0',d0
	move.b d0,(a0)

	lea ULS_RAMDUMP_HEADER(pc),a0
	move.l #'ULS3',(a0)+
	move.l #'RAMS',(a0)+
	move.l #'AVE!',(a0)+
	clr.l (a0)			; re-write the header

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_rdta(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	bsr reset_DTA

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_ssfc(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	clr.w -(a7)
	pea susp_fn(pc)
	move.w #$3c,-(a7)
	trap #1
	lea 8(a7),a7
	move.l d0,d7

	lea ULS_bytes_io(pc),a0
	move.l (a0),d0			
	subq.l #8,d0			; length of contiguous memory dump
	lea rd_size(pC),a0
	move.l d0,(a0)	

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_ssdh(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea ULS_RAMDUMP_HEADER(pc),a0
	move.l #16,d0
	bsr write_disk

	lea input_buff(pc),a0		; save comment
	move.l #34,d0
	bsr write_disk

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_ssdl(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea ULS_SYS_mem(pc),a0
	move.l (a0),a0			; start of low memory buffer
	lea TOS_rambase(pc),a1
	move.l (a1),d0			; length of data
	bsr write_disk

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_ssdn(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc
	
	lea ULS_bytes_io(pc),a0
	move.l (a0),d0			; end of ramdump
	lea TOS_rambase(pc),a0		; start of "normal memory"
	move.l (a0),a0
	sub.l a0,d0			; size
	sub.l #8,d0
	bsr write_disk

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_ssdv(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea top_of_variable_table(pc),a0
	lea bot_of_variable_table(pc),a1
	sub.l a0,a1
	move.l a1,d0	
	bsr write_disk

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_ssdr(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea ULS_filebuffer(pc),a0	
	move.l (a0),a0			
	move.l #66,d0			; dump registers and SR
	bsr write_disk

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_sscf(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	move.w d7,-(a7)
	move.w #$3e,-(a7)
	trap #1
	add.l #4,a7

	bsr write_cooldown

	rts

write_disk
	move.l a0,-(a7)
	move.l d0,-(a7)
	move.w d7,-(a7)
	move.w #$40,-(a7)
	trap #1
	lea 12(a7),a7
	rts

ULS_RAMDUMP_HEADER
	dc.b "ULS3RAMSAVE!"
rd_size	dc.l 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; State Resume
;;
;; Returns: 
;;
;; Resumes savestate if successful
;; Returns to call if fail
;;


state_menu	dc.l 0
resuming	dc.l 0			; am I resuming? (exit core flag)
resume_fail	dc.l 0			; did I fail? (exit core flag)
resume_a7	dc.l 0			; err a7!
resume_sr	dc.w 0			; err sr!
local_DTA	ds.b 44
local_DRV_BUFF	ds.l 4

uls_resume_disk
	lea resuming(pc),a6	
	move.l #'NOPE',(a6)
	lea ULS_on_hd(pc),a0
	cmp.l #'!HD!',(a0)
	beq.s .go
	rts				; No resume on Floppy!!!

.go	lea state_menu(pc),a0
	move.l #'LOAD',(a0)
	lea resume_fail(pc),a6
	move.l #'NOPE',(a6)
	lea resuming(pc),a6	
	move.l #'YES!',(a6)
	lea read_write_flag(pc),a6	; store ULS access mode
	move.w (a6),-(a7)
	move.w #'RD',(a6)		; put ULS in resume mode
	bsr uls_core
	lea read_write_flag(pc),a6
	move.w (a7)+,(a6)		; restore ULS access mode
	rts


reset_DTA
	movem.l d0-7/a0-6,-(a7)
	pea local_DTA(pc)
	move.w #$1a,-(a7)
	trap #1				; set the DTA to local memory (Just in case)
	lea 6(a7),a7
	bsr falcon_delay
	lea ULS_drive(pc),a0
	move.w (a0),-(a7)
	pea local_DRV_BUFF(pc)
	move.w #$36,-(a7)
	trap #1				; force some arbitrary gemdos function (D_free)
	lea 8(a7),a7
	bsr falcon_delay
	movem.l (a7)+,d0-7/a0-6
	rts

resume_code
	move.w #$2300,sr

	lea $ffff8800.w,a0		; kill sound
	move.l #$08080000,(a0)
	move.l #$09090000,(a0)
	move.l #$0a0a0000,(a0)

	lea machine(pc),a0
	cmp.w #3,(a0)
	beq.s .mc30
	cmp.w #4,(a0)
	bne.s .mc00
.mc30
	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_flshc(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	dc.l	$f0002400		* pflusha - flush caches
.mc00	move.l #'TIMC',d7
	bsr falcon_delay

	move.l $ffff8240.w,-(a7)
	bsr state_menuscreen		; user interface
	move.l (a7)+,$ffff8240.w

	tst.b d0			; esc or a filename?
	bpl.s .yay

	lea resuming(pc),a6		; esc	
	move.l #'NOPE',(a6)

	rts

.yay	lea susp_fn+7(pc),a0		; correct the filename
	add.b #'0',d0
	move.b d0,(a0)

	lea ULS_RAMDUMP_HEADER(pc),a0
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)			; clear the header

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_rdta(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	bsr reset_DTA

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_ssfo(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	clr.w -(a7)
	pea susp_fn(pc)
	move.w #$3d,-(a7)
	trap #1
	lea 8(a7),a7
	move.l d0,d7
	tst.w d0
	bpl.s .ok
.failed	lea resume_fail(pc),a6
	move.l #'FAIL',(a6)
	rts

.ok
	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_ssrh(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea ULS_RAMDUMP_HEADER(pc),a0
	move.l #16,d0
	bsr read_disk
	lea ULS_RAMDUMP_HEADER(pc),a0
	cmp.l #'ULS3',(a0)
	bne .failed

	lea input_buff(pc),a0		; skip comment
	move.l #34,d0
	bsr read_disk

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_ssrl(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea ULS_SYS_mem(pc),a0
	move.l (a0),a0			; start of low memory buffer
	lea TOS_rambase(pc),a1
	move.l (a1),d0			; length of data
	bsr read_disk

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_ssrn(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea ULS_RAMDUMP_HEADER+12(pc),a0
	move.l (a0),d0			; length of ramdump
	lea TOS_rambase(pc),a0
	move.l (a0),a0			; load address
	sub.l a0,d0			; bytes to load
	bsr read_disk

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_ssrv(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc
	
	lea top_of_variable_table(pc),a0
	lea bot_of_variable_table(pc),a1
	sub.l a0,a1
	move.l a1,d0	
	bsr read_disk

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_ssrr(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea ULS_filebuffer(pc),a0	
	move.l (a0),a0			
	move.l #66,d0
	bsr read_disk			; read registers and SR

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_sscf(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	move.w d7,-(a7)
	move.w #$3e,-(a7)
	trap #1
	add.l #4,a7

	lea resuming(pc),a6	
	move.l #'YES!',(a6)
	rts

read_disk
	move.l a0,-(a7)
	move.l d0,-(a7)
	move.w d7,-(a7)
	move.w #$3f,-(a7)
	trap #1
	lea 12(a7),a7
	rts


susp_fn	dc.b "RAMDUMPx.ULS",0
	even

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SaveState menu
;;
;; Returns:
;;
;; d0=$ff (esc)
;; d0=0-9 for choice
;;

state_menuscreen
	bsr .proc_headers		; scan for all 10 statefiles

	lea t_curs_off(pc),a0
	move.l #(160*9)*5,(a0)		; reset the cursor

	lea t_curs_on(pc),a0
	move.l #(160*9)*5,(a0)		; reset the cursor

	lea .kmenu(pc),a0
	clr.w (a0)			; reset menu number

	lea ikbd_key(pc),a0
	clr.b (a0)			; make sure nothing in key buffer

	bsr flush_acia			; flush it from the game
	bset.b #6,$fffffa15.w		; enable acia
	
	move.w #$7,$ffff8240.w		; blue background
	move.w #$770,$ffff8242.w	; yellow text

	lea ULS_scr(pc),a0		; clear the workscreen
	move.l (a0),a0
	move.l #($7d00/4)-1,d7
.era	clr.l (a0)+
	dbra d7,.era

	lea t_kill(pc),a1		; load or save?
	lea state_menu(pc),a0
	cmp.l #'LOAD',(a0)
	beq.s .set_ld
.set_sa	move.b #-2,(a1)			; if save, carry on printing last line of text
	bra.s .set_dn
.set_ld	move.b #-1,(a1)			; if load, terminate before last line of text

.set_dn	lea t_savestate(pc),a1		; display menu
	bsr info
	lea t_curs_on(pc),a1		; display cursor
	bsr info

.hold	lea ikbd_key(pc),a0
	cmp.b #$c8,(a0)			; cursor up?
	beq .kcurs_up
	cmp.b #$d0,(a0)			; cursor down?
	beq .kcurs_dw
	cmp.b #$9c,(a0)			; enter?
	beq .kenter

	cmp.b #$81,(a0)			; esc?
	bne.s .hold
	
	lea .kmenu(pc),a0		; esc, so set to $ff
	move.w #$ff,(a0)

.s_exit	lea .kmenu(pc),a0
	move.w (a0),d0			; return menu number (0-9)
	bclr.b #6,$fffffa15.w		; disable acia	
	rts

.kcurs_up	
	lea .kmenu(pc),a0	
	tst.w (a0)			; check if at top (0)
	beq .kupo
	sub.w #1,(a0)			; up one!

	lea t_curs_off(pc),a1		; remove cursor
	bsr info
	lea t_curs_off(pc),a1
	sub.l #160*9,(a1)		; move cursor up the screen
	lea t_curs_on(pc),a1
	sub.l #160*9,(a1)
	bsr info			; draw cursor
	lea ikbd_key(pc),a0
.kupo	clr.b (a0)			; clear buffer
	bra .hold			; loop around

.kcurs_dw
	lea .kmenu(pc),a0
	cmp.w #9,(a0)			; check if at bottom (9)
	beq .kdwo
	add.w #1,(a0)			; down one!

	lea t_curs_off(pc),a1		; remove cursor
	bsr info
	lea t_curs_off(pc),a1
	add.l #160*9,(a1)		; move cursor down the screen
	lea t_curs_on(pc),a1
	add.l #160*9,(a1)
	bsr info			; draw cursor
	lea ikbd_key(pc),a0
.kdwo	clr.b (a0)			; clear buffer
	bra .hold			; loop around

.kenter
	lea state_menu(pc),a0
	cmp.l #'LOAD',(a0)		; are we doing a LOAD or a SAVE state?
	beq .state_load_select

.state_save_select			; save
	lea .kmenu(pc),a0		; menu number
	lea t_sav0(pc),a1
	move.w (a0),d0			; get vertical
	mulu #39,d0			; offset into ASCII
	add.w d0,a1
	add.w #4,a1
	move.w #30,d0
	lea .old_input_buff(pc),a2	
.copy	move.b (a1)+,(a2)+		; backup existing description (In case of ESC)
	dbra d0,.copy

	lea input_buff(pc),a0
	move.w #32,d0
.wipe	move.b #' ',(a0)+		; enpty out text buffer
	dbra d0,.wipe
	lea input_buff+1(pc),a0
	move.b #'-',(a0)
	lea .input_pos(pc),a0
	clr.w (a0)			; move cursor to start
	lea ikbd_key(pc),a0
	clr.b (a0)
	lea t_curs_on(pc),a0
	move.l (a0),d0			; where the cursor is
	add.l #16,d0
	lea input_buff-4(pc),a1
	move.l d0,(a1)			; where on screen
	bsr info

.iloop	lea ikbd_key(pc),a0	
	cmp.b #$81,(a0)			; esc
	beq .inp_done_esc
	cmp.b #$9c,(a0)			; enter
	beq .inp_done_ok
	cmp.b #$8e,(a0)			; backspace
	beq .bkc_space
	move.b (a0),d0
	bsr .proc_char			; convert scancode to ASCII
	cmp.b #'A',d0
	blt .no_az			;
	cmp.b #'Z',d0			;
	ble .is_az			;
.no_az	cmp.b #'0',d0			; check if valid (a-z/0-9/space)
	blt .no_nm			;
	cmp.b #'9',d0			;
	ble .is_az			;
.no_nm	cmp.b #' ',d0			;
	beq .is_az		
	bra .iloop			; branch around if not

.proc_char
	lea .scan(pc),a0		; scancode buffer
.cmploo	move.b (a0)+,d6			; scancode byte
	move.b (a0)+,d7			; ascii char
	cmp.b #$ff,d7			; end of table?
	beq.s .sout
	cmp.b d0,d6			; key=scancode?
	bne.s .cmploo
.sout	move.b d7,d0			; store ascii!
	rts

.is_az	lea ikbd_key(pc),a0		; clear buffer
	clr.b (a0)

	lea .input_pos(pc),a0		; chars typed
	move.w (a0),d1
	cmp.w #31,d1			; end of line?
	beq.s .maxl
	add.w #1,d1			; next char
	move.w d1,(a0)
	lea input_buff(pc),a0
	move.b d0,(a0,d1.w)		; write to string
	move.b #'-',1(a0,d1.w)		; move cursor over one

	lea input_buff-4(pc),a1		; redisplay line
	bsr info

.maxl	bra .iloop			; around we go!

.bkc_space
	lea ikbd_key(pc),a0		; clear buffer
	clr.b (a0)

	lea .input_pos(pc),a0		; get input position
	move.w (a0),d1			
	tst.w d1			; 1st char?
	beq .minl			; if so, can't delete - exit

	sub.w #1,d1
	move.w d1,(a0)			; chars=chars-1
	lea input_buff(pc),a0
	move.b #'-',1(a0,d1.w)		; write cursor to string
	move.b #' ',2(a0,d1.w)		; erase deleted cursor
	
	lea input_buff-4(pc),a1		; redisplay line
	bsr info

.minl	bra .iloop			; around we go!
	
.inp_done_esc
	lea input_buff(pc),a0		; esc pressed
	lea .old_input_buff(pc),a1
	move.w #32,d0
.repl	move.b (a1)+,(a0)+		; copy previous line back
	dbra d0,.repl

	lea ikbd_key(pc),a0
	clr.b (a0)			; clear buffer

.inp_done_exit
	bsr .input_proc			; process line to output buffer
	bra .hold			; loop around

.inp_done_ok
	lea .input_pos(pc),a0
	move.w (a0),d1
	lea input_buff(pc),a0
	move.b #' ',1(a0,d1.w)		; write to string
	lea ikbd_key(pc),a0
	move.b #$81,(a0)
	bsr .input_proc			; process line to output buffer

.state_load_select
	bra .s_exit			; exit out if load selected (no edit!)

.old_input_buff	ds.b 33			; what was there
		even
.input_pos	ds.w 1			; char counter


.input_proc
	lea .kmenu(pc),a0		; copy what we typed/restored to the screen buffer
	lea t_sav0(pc),a1
	move.w (a0),d0			; get vertical
	mulu #39,d0
	add.w d0,a1
	add.w #4,a1
	move.w #31,d0
	lea input_buff(pc),a2
.copyx	move.b (a2)+,(a1)+
	dbra d0,.copyx

.editout
	lea t_savestate(pc),a1		; update screen
	bsr info

	lea t_curs_on(pc),a1		; redraw cursor
	bsr info
	rts

.proc_headers
	move.b #'0',d7			; start with RAMSAVE0.ULS
.loop	lea susp_fn+7(pc),a0
	move.b d7,(a0)
	bsr .read_state_header		; process it
	add.b #1,d7			; increment filename
	cmp.b #'9'+1,d7			; until all done
	bne.s .loop
	rts

.read_state_header
	lea ULS_filebuffer(pc),a0
	move.l (a0),a0			; address of filebuffer	
	clr.l $200(a0)			; offset into filebuffer (don't want to trash registers!)	

	move.l d7,-(a7)			; save filename number
	clr.w -(a7)
	pea susp_fn(pc)
	move.w #$3d,-(a7)
	trap #1				; open the file
	lea 8(a7),a7
	move.w d0,d6

	tst.w d6
	bmi .fnf_error			; branch if it wasn't there
	
	lea ULS_filebuffer(pc),a0
	move.l (a0),a0			; address of filebuffer	
	lea $200(a0),a0			; offset into filebuffer (don't want to trash registers!)	
	move.l a0,-(a7)
	move.l #16+32,-(a7)
	move.w d6,-(a7)
	move.w #$3f,-(a7)
	trap #1				; read header
	lea 12(a7),a7

.fnf_error
	move.w d6,-(a7)
	move.w #$3e,-(a7)
	trap #1				; close file anyway (even if not found)
	lea 4(a7),a7

	lea ULS_filebuffer(pc),a0
	move.l (a0),a0			; address of filebuffer	
	lea $200(a0),a0

	lea .fnf_errort(pc),a1
	cmp.l #'ULS3',(a0)		; ULS savefile?
	bne.s .f_error
	lea 16(a0),a1			; comment header
.f_error
	move.l (a7)+,d7
	move.b d7,d0			
	sub.b #'0',d0
	bsr .insert_table		; write comment to menu
	
	rts

.insert_table
	and.l #$f,d0			; get the filename number
	lea t_sav0(pc),a2
	mulu #39,d0
	add.w d0,a2
	add.w #4,a2
	move.w #31,d0
.copyy	move.b (a1)+,(a2)+		; and write header string into table
	dbra d0,.copyy
	rts

.fnf_errort
;	dc.b "0123456789012345678901234567890123"
	dc.b " MEMORY SAVE SLOT UNUSED          ",-1	; unused slot text
	even
	

.kmenu	dc.w 0				; menu number

.scan	dc.b $1e,'A',$30,'B',$2e,'C',$20,'D',$12,'E',$21,'F',$22,'G'	; scancode table
	dc.b $23,'H',$17,'I',$24,'J',$25,'K',$26,'L',$32,'M',$31,'N'	;
	dc.b $18,'O',$19,'P',$10,'Q',$13,'R',$1f,'S',$14,'T',$16,'U'	; dc.b scancode,ascii
	dc.b $2f,'V',$11,'W',$2d,'X',$15,'Y',$2c,'Z',$0b,'0',$02,'1'	;
	dc.b $03,'2',$04,'3',$05,'4',$06,'5',$07,'6',$08,'7',$09,'8'
	dc.b $0a,'9',$39,' ',$ff,$ff

		dc.l 160*180		; screen offset
input_buff	ds.b 33			; buffer to type on
		dc.b -1			; termination char
		even

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Get address of a file in ramdisk
;;


uls_get_ramdisk_address
	movem.l d0-7/a1-6,-(a7)

	lea sys_filename(pc),a6
	move.l a0,(a6)
	bsr process_filename		; convert the filename
	movem.l (a7),d0-7/a0-6

	lea ULS_fn_header(pc),a5
	move.l (a5),d4

	lea ramdisk_base(pc),a5		; get address of RAMdisk base
	move.l (a5),a5
.finder
	lea ULS_filename(pc),a6		; filename requested
	move.l a5,-(a7)

	cmp.l 16(a5),d4			; same data folder?
	bne .err	

	move.w #11,d0			; 12 chars/name
.floop	tst.b (a6)			; end of name?
	beq .foundit
	cmp.b (a5)+,(a6)+		; compare filename
	bne .err
	dbra d0,.floop			; name length overflow check
	bra .foundit			; all chars match!	
.err	move.l (a7)+,a5

	move.l 12(a5),d7
	btst #0,d7
	beq.s .notodd1
	addq.l #1,d7
	bclr #0,d7
.notodd1
	add.l d7,a5			; wrong name, get next pointer

	lea 20(a5),a5
	cmp.l #'END!',(a5)		; end of table?
	bne.s .finder

	movem.l	(a7)+,d0-7/a0-6		; file not in RAMdisk - call ULS as per normal
	bra normalio

.foundit
	cmp.b #'.',(a6)			; check if this is the end of the filename
	beq.s .noerr			; (dupe init characters check)
	tst.b (a6)
	bne .err

.noerr	move.l (a7)+,a5			; header!!
	move.l a5,a0
	movem.l (a7)+,d0-7/a1-6

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Screenshot grabber
;;

uls_screenshot
	lea ULS_on_hd(pc),a0
	cmp.l #'!HD!',(a0)
	beq.s .go
	rts				; No PI1 on Floppy!!!

.go	lea read_write_flag(pc),a6	; store ULS access mode
	move.w (a6),-(a7)
	move.w #'SC',(a6)		; put ULS in screenshot mode
	bsr uls_core
	lea read_write_flag(pc),a6
	move.w (a7)+,(a6)		; restore ULS access mode
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Process screenshot filename
;;

screenshot_filename
	lea scr_count(pc),a5		; get and increment filename counter
	add.w #1,(a5)
	move.w (a5),d1
	bsr hashing
	lea hexad+4(pc),a5		; patch counter into filename
	lea scr_fn+4(pc),a6
	move.l (a5),(a6)
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Save screenshot as PI1
;;

save_screenshot
	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_scr(pc),a1
	bsr info			
	movem.l (a7)+,d0-7/a0-6
	endc

	move.w #$2300,sr

	bsr reset_DTA

	clr.w -(a7)			; open file
	pea scr_fn(pc)
	move.w #$3c,-(a7)		; GEMDOS fwrite
	trap #1
	add.l #8,a7
	move.w d0,d7			; file handle
	bmi io_error_oops		; loop if create error

	lea SYS_res(pc),a5		; put the resolution into the PI1 header
	lea SYS_pal-2(pc),a6
	move.b (a5),1(a6)

	move.l a6,-(a7)			; address of pallette-2 (PI1 header)
	move.l #34,-(a7)		; bytes to write
	move.w d7,-(a7)
	move.w #$40,-(a7)		; GEMDOS fwrite
	trap #1
	lea 12(a7),a7
	move.l d0,d6
	bmi io_error_oops

	lea ULS_scr(pc),a6
	move.l (a6),-(a7)		; address of screen
	move.l #32000,-(a7)		; bytes to write
	move.w d7,-(a7)
	move.w #$40,-(a7)		; GEMDOS fwrite
	trap #1
	lea 12(a7),a7
	move.l d0,d6
	bmi io_error_oops

	move.w d7,-(a7)			
	move.w #$3e,-(a7)		; GEMDOS fclose
	trap #1
	addq.l #4,a7

	bsr write_cooldown

	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; ULS "Core" Cache control
;;
;; The ULS Core/Init routines will not run with cache on - these routines control caches
;; on 68030 machines (Falcon/TT)
;; 

core_cache_off
	move.l a0,-(a7)	
	lea machine(pc),a0
	cmp.w #3,(a0)			; Falcon?
	beq.s .core_off
	cmp.w #4,(a0)			; TT?
	beq.s .core_off
	move.l (a7)+,a0
	rts
.core_off
	movem.l d0/a5,-(a7)
	moveq   #0,D0
       	DC.L $4E7A0002  		; movec cacr,d0
       	lea     core_cacr(PC),A5	; Save cache state
       	move.l  D0,(A5)
	moveq   #0,D0
	DC.L $4E7B0002  		; movec d0,cacr (kill caches)
	movem.l (a7)+,d0/a5
	move.l (a7)+,a0
	rts

core_cache_on
	move.l a0,-(a7)	
	lea machine(pc),a0
	cmp.w #3,(a0)			; Falcon?
	beq.s .core_on
	cmp.w #4,(a0)			; TT?
	beq.s .core_on
	move.l (a7)+,a0
	rts
.core_on
	dc.l $f0002400			; pflusha - flush caches
	nop
	nop
	movem.l d0/a5,-(a7)
	lea core_cacr(pc),a5
	move.l (a5),d0
	dc.l $4e7b0002			; movec d0,cacr (return to whatever it was)
	nop
	nop
	dc.l $f0002400			; pflusha - flush caches
	nop
	nop
	movem.l (a7)+,d0/a5
	move.l (a7)+,a0
	rts

core_cacr	dc.l 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; "ULS Core"
;;
;; (All things have a beginning... and an end.... but they must pass through here!)
;;
;; Assumes:
;;
;; a0=pointer to filename
;; a1=load address
;; d0=bytes loaded 	-1 = all / saved
;; d1=seek offset 	0  = start of file [read only]
;; d7=0 load to RAM
;; d7=-1 load to buffer only
;;
;; Returns:
;;
;; d0=bytes loaded/saved (Packed)
;; d1=bytes loaded/saved (Actual filesize)
;; d7=ffffffff if file not found
;;

uls_core
	move.l a0,-(a7)

	lea resume_a7(pc),a0
	move.l a7,(a0)
	add.l #4,(a0)

	lea resume_sr(pc),a0
	move.w sr,(a0)

	lea ULS_bytes_io(pc),a0		; bytes to load/save
	move.l d0,(a0)

	lea ULS_seek_offset(pc),a0	; offset into file
	move.l d1,(a0)

	lea copy_data(pc),a0		; to filebuffer only flag
	move.w d7,(a0)

	lea machine(pc),a0		; get machine type
	cmp.w #1,(a0)			; STe?
	beq .blitwait
	cmp.w #2,(a0)			; MSTe?
	beq .blitwait
	cmp.w #3,(a0)			; Falcon?
	beq .blitwait
	bra .noblit

.blitwait
	btst.b #7,$ffff8a3c.w		; wait if blitter is busy
	bne.s .blitwait			

.noblit	lea read_write_flag(pc),a0	; check if "Special Operation" or normal read
	cmp.w #'SC',(a0)
	beq .do_uls			
	cmp.w #'UC',(a0)
	beq .do_uls			
	cmp.w #'SD',(a0)
	beq .do_uls
	cmp.w #'RD',(a0)
	beq .do_uls
	cmp.w #'RU',(a0)
	beq .do_uls
	tst.w (a0)
	bmi .do_uls

	lea ramdisk_enable(pc),a0	; its a normal read
	cmp.l #'RAMD',(a0)		
	bne .do_uls			; so did we init a RAMdisk?

	move.l (a7)+,a0
	bra ULS_ramdisk_handler

.do_uls	move.l (a7)+,a0
	bsr core_cache_off		; Disable caches on 68030


normalio
	move.w sr,-(a7)			; save SR

	move.l a0,-(a7)			; save registers
	lea APP_sr(pc),a0
	move.w sr,(a0)
	move.w #$2700,sr		; kill all interupts

	lea ULS_registers(pc),a0
	movem.l d0-7/a1-7,4(a0)
	move.l (a7)+,(a0)
	move.l (a0),a0

	bsr set_16			; Turbo (if possible)

	lea SYS_res(pc),a6		; save resolution
	move.b $ffff8260.w,1(a6)
	move.b #0,$ffff8260.w		; low res

	lea ULS_ret_add(pc),a6
	move.l 2(a7),(a6)		; return address

	lea sys_filename(pc),a6
	move.l a0,(a6)

	lea $ffff8240.w,a6		; save application pallette
	lea SYS_pal(pc),a5		
	move.w #15,d7
.advpax	move.w (a6)+,(a5)+
	dbra d7,.advpax

	lea SYS_screen(pc),a6		; save application screen
	move.b $ffff8201.w,1(a6)
	move.b $ffff8203.w,2(a6)
	move.b $ffff820d.w,3(a6)

	move.l (a6),a6			; save screen memory to debug workspace
	lea ULS_scr(pc),a5
	move.l a5,-(a7)
	move.l (a5),a5
	move.l #(32000/4)-1,d7
.mover	move.l (a6)+,(a5)+
	dbra d7,.mover

	move.l (a7)+,a6			; point screen to uls workspace
	move.b 1(a6),$ffff8201.w
	move.b 2(a6),$ffff8203.w
	move.b 3(a6),$ffff820d.w	
		
	lea ULS_stk(pc),a7		; local stack

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; save current screen address
	lea ULS_scr(pc),a0		; clear uls debug screen
	move.l (a0),a1
	move.l #(32000/4)-1,d7
.advwp	clr.l (a1)+
	dbra d7,.advwp
	lea $ffff8240.w,a0
	move.w #15,d7
.advpa	move.w #$777,(a0)+		; set debug pallette
	dbra d7,.advpa
	clr.w $ffff8240.w
	lea t_init(pc),a1		; "Entering ULS"
	bsr info
	lea ULS_ret_add(pc),a0
	move.l (a0),d1
	sub.l #4,d1			; correct for the JSR
	bsr hashing
	lea hexad(pc),a1
	lea t_jmpa(pc),a0
	move.l (a1)+,(a0)+
	move.l (a1),(a0)
	lea t_jmp(pc),a1
	bsr info			; print "Called from: $xxxxxxxx"

	lea t_uls(pc),a1
	bsr info

	lea uls(pc),a1			; debug: ULS Base address
	move.l a1,d1
	bsr hashing
	lea hexad(pc),a1
	lea t_ulsba(pc),a0
	move.l (a1)+,(a0)+
	move.l (a1),(a0)
	lea t_ulsb(pc),a1
	bsr info

	lea ULS_TOS_mem(pc),a1		; debug: ULS TOS copy address
	move.l (a1),d1
	bsr hashing
	lea hexad(pc),a1
	lea t_gemba(pc),a0
	move.l (a1)+,(a0)+
	move.l (a1),(a0)
	lea t_gemb(pc),a1
	bsr info

	lea ULS_SYS_mem(pc),a1		; debug: ULS APP copy address
	move.l (a1),d1
	bsr hashing
	lea hexad(pc),a1
	lea t_appba(pc),a0
	move.l (a1)+,(a0)+
	move.l (a1),(a0)
	lea t_appb(pc),a1
	bsr info

	lea TOS_rambase(pc),a1		; debug: ULS High Byte Copies
	move.l (a1),d1
	bsr hashing
	lea hexad(pc),a1
	lea t_hibya(pc),a0
	move.l (a1)+,(a0)+
	move.l (a1),(a0)
	lea t_hiby(pc),a1
	bsr info

	lea ULS_scr(pc),a5		; debug: Horizontal lines!
	move.l (a5),a5
	move.w #39,d7
.draw	move.l #$ffff,160*110(a5)
	move.l #$ffff,160*187(a5)
	lea 4(a5),a5
	dbra d7,.draw

	lea ULS_registers(pc),a5	; debug: register dump
	move.l (a5)+,d1
	lea t_a0(pc),a6
	bsr .hashing_reg
	move.l (a5)+,d1
	lea t_d0(pc),a6
	bsr .hashing_reg
	move.l (a5)+,d1
	lea t_d1(pc),a6
	bsr .hashing_reg
	move.l (a5)+,d1
	lea t_d2(pc),a6
	bsr .hashing_reg
	move.l (a5)+,d1
	lea t_d3(pc),a6
	bsr .hashing_reg
	move.l (a5)+,d1
	lea t_d4(pc),a6
	bsr .hashing_reg
	move.l (a5)+,d1
	lea t_d5(pc),a6
	bsr .hashing_reg
	move.l (a5)+,d1
	lea t_d6(pc),a6
	bsr .hashing_reg
	move.l (a5)+,d1
	lea t_d7(pc),a6
	bsr .hashing_reg
	move.l (a5)+,d1
	lea t_a1(pc),a6
	bsr .hashing_reg
	move.l (a5)+,d1
	lea t_a2(pc),a6
	bsr .hashing_reg
	move.l (a5)+,d1
	lea t_a3(pc),a6
	bsr .hashing_reg
	move.l (a5)+,d1
	lea t_a4(pc),a6
	bsr .hashing_reg
	move.l (a5)+,d1
	lea t_a5(pc),a6
	bsr .hashing_reg
	move.l (a5)+,d1
	lea t_a6(pc),a6
	bsr .hashing_reg
	move.l (a5)+,d1
	lea t_a7(pc),a6
	bsr .hashing_reg
	lea APP_sr(pc),a5
	move.w (a5),d1
	bsr hashing
	lea hexad+4(pc),a5
	lea t_sr(pc),a6
	move.l (a5),(a6)
	lea t_regi(pc),a1
	bsr info	
	bra .rout

.hashing_reg
	bsr hashing
	lea hexad(pc),a1
	move.l (a1)+,(a6)+
	move.l (a1),(a6)
	rts

.rout	movem.l (a7)+,d0-7/a0-6
	endc

	lea read_write_flag(pc),a6	; read or write! 
	cmp.w #'SC',(a6)
	beq .screenshot			; its a kodak moment
	cmp.w #'UC',(a6)
	beq .usercode			; run some user code
	cmp.w #'SD',(a6)
	beq .susdcode			; state save
	cmp.w #'RD',(a6)
	beq .resdcode			; state load
	cmp.w #'RU',(a6)		
	beq .ramucode			; ramdisk update
	tst.w (a6)
	bpl .read_file
	bra .write_file

.susdcode
	bsr restore_gemdos
	bsr suspend_code
	bsr restore_game_env
	bra .exit_core

.resdcode
	bsr restore_gemdos
	bsr resume_code
	bsr restore_game_env
	bra .exit_core
	
.usercode
	bsr restore_gemdos
	lea user_code_addr(pc),a6
	move.l (a6),a6
	jsr (a6)
	bsr restore_game_env
	bra .exit_core

.screenshot
	bsr screenshot_filename
	bsr restore_gemdos
	bsr save_screenshot
	bsr restore_game_env
	bra .exit_core

.ramucode
	bsr restore_gemdos
	bsr update_ramdisk
	bsr restore_game_env
	bra .exit_core

.read_file
	bsr process_filename
	bsr restore_gemdos
	bsr load_file
	bsr restore_game_env
	lea copy_data(pc),a6
	tst.w (a6)
	bmi.s .no_rd
	lea fnf_flag(pc),a6
	tst.l (a6)
	bmi.s .no_rd
	bsr bytecopy_file_down
.no_rd	bra .exit_core

.write_file
	bsr process_filename
	bsr bytecopy_file_up
	bsr restore_gemdos
	bsr save_file
	bsr write_cooldown
	bsr restore_game_env
	bra .exit_core


.exit_core
	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)
	lea t_done(pc),a1
	bsr info			; print "Done!"

	move.l #$4ffff,d0	
.lngwai	eor.w #$7,$ffff8240.w		; delay so you can read it
	subq.l #1,d0
	bne.s .lngwai

	lea SYS_res(pc),a6		; restore resolution
	move.b 1(a6),$ffff8260.w

	lea SYS_pal(pc),a0
	lea $ffff8240.w,a1
	move.w #15,d0
.palt2	move.w (a0)+,(a1)+		; restore pallette
	dbra d0,.palt2
	movem.l (a7)+,d0-7/a0-6
	endc
	
	lea SYS_screen(pc),a0		; restore screen
	move.b 1(a0),$ffff8201.w
	move.b 2(a0),$ffff8203.w
	move.b 3(a0),$ffff820d.w

	bsr flush_acia
	bsr set_8			; back to whatever it was on entry

	lea ULS_registers(pc),a0	; restore registers
	move.l (a0)+,-(a7)
	movem.l (a0),d0-7/a1-7

	bclr.b #3,$fffffa17.w		; enable acia	

	lea resume_fail(pc),a0
	cmp.l #'FAIL',(a0)
	beq .no_resume

	lea resuming(pc),a0
	cmp.l #'YES!',(a0)
	beq .resume_exit

.no_resume
	lea resume_fail(pc),a0
	move.l #'NOPE',(a0)

	lea ULS_bytes_loaded(pc),a0
	move.l (a0),d0			; RAW or Packed filesize

	lea ULS_bytes_loaded2(pc),a0	
	move.l (a0),d1			; RAW filesize

	lea fnf_flag(pc),a0
	move.l (a0),d7			; d7 -ve if file not found

	move.l (a7)+,a0
	move.w (a7)+,sr
	bsr core_cache_on		; restore 68030 cache values
	rts

.resume_exit
	movem.l d0-7/a0-6,-(a7)
	bsr flush_acia

	lea machine(pc),a0
	cmp.w #3,(a0)
	beq.s .mc30
	cmp.w #4,(a0)
	bne.s .mc00
.mc30	dc.l	$f0002400		* pflusha - flush caches
.mc00	bsr falcon_delay

	movem.l (a7)+,d0-7/a0-6
	move.b $fffffc02.w,d0

	lea $ffff8800.w,a0		; kill sound
	move.l #$08080000,(a0)
	move.l #$09090000,(a0)
	move.l #$0a0a0000,(a0)

	lea ULS_seek_offset(pc),a6
	move.l (a6),a0
	lea .jmp+2(pc),a6
	move.l a0,(a6)

	lea resuming(pc),a0
	move.l #'NOPE',(a0)
	bsr uls_read_mode

	lea ULS_filebuffer(pc),a0
	move.l (a0),a0			; address of filebuffer
	movem.l (a0),d0-7/a1-7
	lea 60(a0),a0

	move.w (a0)+,sr
	move.l (a0),a0			; all registers returned to dump state

	movem.l d0-7/a0-6,-(a7)
	bsr falcon_delay
	lea SYS_pal(pc),a0
	movem.l (a0),d0-7
	movem.l d0-7,$ffff8240.w
	movem.l (a7)+,d0-7/a0-6

	bsr core_cache_on		; restore 68030 cache values

.jmp	jmp $12345678

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; ULS AutoMagic Ramdisk Handler
;;

ULS_ramdisk_handler
	movem.l d0-7/a0-6,-(a7)

	lea sys_filename(pc),a6
	move.l a0,(a6)

	bsr process_filename		; convert the filename

	movem.l (a7),d0-7/a0-6

	lea ULS_fn_header(pc),a5
	move.l (a5),d4

	lea ramdisk_base(pc),a5		; get address of RAMdisk base
	move.l (a5),a5
.finder
	lea ULS_filename(pc),a6		; filename requested
	move.l a5,-(a7)

	cmp.l 16(a5),d4			; same data folder?
	bne .err	

	move.w #11,d0			; 12 chars/name
.floop	tst.b (a6)			; end of name?
	beq .foundit
	cmp.b (a5)+,(a6)+		; compare filename
	bne .err
	dbra d0,.floop			; name length overflow check
	bra .foundit			; all chars match!	
.err	move.l (a7)+,a5

	move.l 12(a5),d7
	btst #0,d7
	beq.s .notodd1
	addq.l #1,d7
	bclr #0,d7
.notodd1
	add.l d7,a5			; wrong name, get next pointer

	lea 20(a5),a5
	cmp.l #'END!',(a5)		; end of table?
	bne.s .finder

	movem.l	(a7)+,d0-7/a0-6		; file not in RAMdisk - call ULS as per normal
	bra normalio

.foundit
	cmp.b #'.',(a6)			; check if this is the end of the filename
	beq.s .noerr			; (dupe init characters check)
	tst.b (a6)
	bne .err

.noerr	move.l (a7)+,a5			; header!!
	move.l 12(a5),d0		; length

	lea 20(a5),a0			; start of data!
	move.l a0,-(a7)
	move.l d0,-(a7)

	lea ULS_bytes_io(pc),a3		; bytes to load/save
	tst.l (a3)
	bmi.s .do_seek
	move.l (a3),d0
	move.l d0,(a7)			; bytes loaded

.do_seek
	lea ULS_seek_offset(pc),a3	; offset into file
	add.l (a3),a0	

	lea copy_data(pc),a3		; load to buffer only?
	tst.w (a3)
	bpl.s .reader
	lea ULS_filebuffer(pc),a1
	move.l (a1),a1

.reader	move.b (a0)+,(a1)+		; load addr still in a1! (Amazing eh?)
	subq.l #1,d0
	bne.s .reader

	move.l (a7)+,d6
	move.l (a7)+,a6
	bsr pack_header_process	
	
	movem.l (a7)+,d0-7/a0-6

	move.l a0,-(a7)
	lea ULS_bytes_loaded(pc),a0
	move.l (a0),d0			; RAW or Packed filesize
	lea ULS_bytes_loaded2(pc),a0	
	move.l (a0),d1			; RAW filesize
	moveq #0,d7
	move.l (a7)+,a0

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Packed header processing
;;
;; Call with:
;;
;; D6.L: Size of file as loaded from disk
;; A6.L: Address of start of file
;;
;; Returns:
;;
;; ULS_bytes_loaded & ULS_bytes_loaded2 correctly for exit routine
;;

pack_header_process
	lea ULS_bytes_loaded2(pc),a5
	move.l d6,(a5)

	lea ULS_bytes_loaded(pc),a5
	move.l d6,(a5)			; save bytes loaded counter

	cmp.l #'ATM5',(a6)
	beq .its_packed4
	cmp.l #'LSD!',(a6)
	beq .its_packed4
	cmp.l #'Ice!',(a6)
	beq .its_packed
	cmp.l #'ICE!',(a6)
	beq .its_packed
	cmp.l #'FIRE',(a6)
	beq .its_packed
	cmp.l #'Fire',(a6)
	beq .its_packed
	rts

.its_packed4
	move.l 4(a6),(a5)
	rts

.its_packed
	move.l 8(a6),(a5)		; get original file length
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; 68030 cpu control
;;

;; VBR code - ok

mc68030_uls_on

	lea machine(pc),a6
	cmp.w #4,(a6)
	beq.s .dott
	cmp.w #4,(a6)
	beq.s .do30
	rts

.do30
; CPU STATE
	lea 	uls_cpus(pc),a1			; Restore its APPLICATION its state
	move.b	(a1),$ffff8007.w

.dott
; VBR
        moveq   #0,D0
        DC.L $4E7B0801  			; MOVEC     D0,VBR     Vektorbase=0 (eigentlich Standard)

; PMMU
run_tc  DC.L $F0394000,$DEADF030 		; PMOVE     pmmu_tab,TC
        DC.L $F0390800,$DEADF030 		; PMOVE     pmmu_tab,TT0
        DC.L $F0390C00,$DEADF030 		; PMOVE     pmmu_tab,TT1
skip

; Cache
    	moveq   #0,D0
	DC.L $4E7B0002  			; movec d0,cacr

	rts

mc68030_gem_on
	lea machine(pc),a6
	cmp.w #4,(a6)
	beq.s .dott
	cmp.w #4,(a6)
	beq.s .do30
	rts

.do30
; CPU STATE
	lea uls_cpus(pc),a0
	move.b $ffff8007.w,(a0)		; store current CPU state
	lea 	sys_FCPUC(pc),a0	; restore CPU mode
	move.b (a0),d0
	or.b #%00100101,d0
	move.b 	d0,$ffff8007.w

.dott
; VBR
	lea	SYS_VBR(pc),a0
	dc.l	$f0104c00		* pmove (a0),VBR *restore VBR*
; PMMU
	lea	SYS_PMMU(pc),a0		* restore tc/tt0/tt1
	dc.w	$f028,$4000,$0000	* pmove (a0),tc
	dc.w	$f028,$0800,$0004	* pmove 4(a0),tt0
	dc.w	$f028,$0c00,$0008	* pmove 8(a0),tt1
; CACHE
	dc.l	$f0002400		* pflusha - flush caches
	lea	SYS_cacr(pc),a0		* restore cache
	move.l	(a0),d0
	dc.l	$4e7b0002		* movec d0,cacr

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Memory block move 
;;
;; a0-source
;; a1-destination
;; d7-bytes to move
;;

block_move
	divu #48,d7
	swap.w d7
	move.w d7,-(a7)
	swap.w d7
	subq.w #1,d7			; itterations of 48 bytes
.mvloop	movem.l (a0)+,d0-6/a2-6
	movem.l d0-6/a2-6,(a1)
	lea 48(a1),a1
	dbra d7,.mvloop
	move.w (a7)+,d7			; overflow remainder
	beq.s .mdone
	subq.w #1,d7
.myloop	move.b (a0)+,(a1)+
	dbra d7,.myloop
.mdone	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;; *Patched for odd source address of filename
;;

force_upper
	cmp.b #'a',d0
	blt.s .don
	cmp.b #'z',d0
	bgt.s .don
	sub.b #$20,d0
.don	rts

fn_temp	dc.l 0

process_filename
	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_prfn(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea ULS_load_addr(pc),a6
	move.l a1,(a6)			; save IO address

	lea sys_filename(pc),a0
	move.l (a0),a0
	
	lea ULS_filename(pc),a1

	move.w #7,d7			; filename
.fna	move.b (a0)+,d0
	bsr force_upper
	cmp.b #' ',d0
	beq.s .space
	cmp.b #'.',d0
	beq.s .dotspace
	move.b d0,(a1)+

.space	dbra d7,.fna
	cmp.b #'.',(a0)
	bne.s .dotspace
	move.b (a0)+,d0
	
.dotspace				; if here, either 8th, dot or space
	lea fn_temp(pc),a6
	move.b (a0),(a6)
	move.b 1(a0),1(a6)
	move.b 2(a0),2(a6)
	clr.b 3(a6)			; make copy of extender
	tst.b (a0)
	beq .done			; no extender = don't '.' terminate
	cmp.l #$20202000,(a6)
	beq .done			; space extender = no extender = don't '.' terminate

	move.b #'.',(a1)+

	rept 3
	move.b (a0)+,d0
	cmp.b #' ',d0
	beq .done			; terminate on space
	tst.b d0
	beq .done			; and on null
	bsr force_upper
	move.b d0,(a1)+			; extender
	endr

.done	clr.b (a1)			; terminate with 0

	ifd adv_debug
	movem.l d0-d7/a0-a6,-(a7)	; display filename info

	lea ramdisk_enable(pc),a6
	cmp.l #'RAMD',(a6)
	beq.s .adv_dn
	lea t_proc(pc),a1
	lea prt_fn(pc),a0
	clr.l (a0)
	clr.l 4(a0)
	clr.l 8(a0)
	lea ULS_filename(pc),a2
.fncopy	move.b (a2)+,d0
	beq.s .fncopdone
	move.b d0,(a0)+
	bra.s .fncopy
.fncopdone
	move.b #-1,(a0)
	bsr info			; print filename
.adv_dn	movem.l (a7)+,d0-d7/a0-a6
	endc

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Restore GEMDOS system state
;;

restore_gemdos
	move.w #$2700,sr

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_sapp(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea $8.w,a0			; source
	lea ULS_SYS_mem(pc),a1
	move.l (a1),a1			; destination
	lea TOS_rambase(pc),a2		; last byte
	move.l (a2),d7
	bsr block_move			; save memory

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_satm1(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea APPmfp_save(pc),a1		; save MFP timer states
	bsr save_mfp

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_satm2(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea APPta_control(PC),A0
	lea APPta_data(PC),A3
	bsr save_timers

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_SPSG(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea APP_PSG(pc),a0
	bsr save_PSG

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_rgem(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea $8.w,a1			; destination
	lea ULS_TOS_mem(pc),a0
	move.l (a0),a0			; source
	lea TOS_rambase(pc),a2		; last byte
	move.l (a2),d7
	bsr block_move			; restore GEMDOS memory

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_683g(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc
	bsr mc68030_gem_on

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_retm1(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea GEMta_data(PC),A3
	lea GEMta_control(PC),A4
	bsr restore_timers

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_retm2(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea GEMmfp_save(pc),a1
	bsr restore_mfp

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_entcp(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea ULS_TimerC(pc),a0
	move.l a0,$114.w

	bclr #6,$fffffa15.w		; mask acia
 	bset.b #5,$fffffa09.w		
	bset.b #5,$fffffa15.w		
	lea APP_fa17(pc),a0	
	move.b $fffffa17.w,(a0)
	bclr.b #3,$fffffa17.w		; auto eoi!

	move.b #$c0,$fffffa23.w		; <- Timer C data (thnx Grazey)
	move.w #$2300,sr		; ok we need timer-c at least!

	move.l $4ba.w,d0
.wait	cmp.l $4ba.w,d0			; wait for a timer c tick
	beq.s .wait

	bsr falcon_delay
	
	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_LPSG(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea SYS_PSG(pc),a0
	bsr load_PSG

;	lea $ffff8800.w,a0		; Force F30 IDE enable
;	move.b #14,(a0)
;	move.b (a0),d0
;	bset #7,d0
;	move.b #14,(a0)
;	move.b d0,2(a0)

.out	rts

ULS_TimerC
	add.l #1,$4ba.w
	ifd adv_debug
	move.w $ffff8240.w,-(a7)
	move.w #$700,$ffff8240.w	
	move.w (a7)+,$ffff8240.w	
	endc

	move.b #$c0,$fffffa23.w		; <- Timer C data (thnx Grazey)
	bclr.b #5,$fffffa11.w
	rte

falcon_delay
	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_f30d(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	move.w sr,-(a7)
	move.w #$2700,sr
	movem.l d0-7/a0-6,-(a7)		; set up frame counter and delay for 7VBLS

	lea .my_rte(pc),a2		; ok now we only want the VBL running
	lea $64.w,a3
	lea my_vecs(pC),a4
	moveq #6,d0
.sa	move.l (a3),(a4)+
	move.l a2,(a3)+
	dbra d0,.sa
	move.l $110.w,(a4)+
	move.l a2,$110.w
	move.l $134.w,(a4)+
	move.l a2,$134.w
	move.l $120.w,(a4)+
	move.l a2,$120.w
	move.l $114.w,(a4)+
	move.l a2,$114.w

	lea cur_vbl+2(pc),a0		; works with 4 but i thought a "safety buffer" was a good idea
	move.l $70.w,(a0)		; (and its only 3/50ths of a second...)
	lea falc_vbl(pc),a0
	move.l a0,$70.w

	move.w #$2300,sr

	lea falc_frame(pc),a1
	move.w #24,(a1)			; re: was 6. then 12.
.hold	tst.w (a1)
	bpl.s .hold
.out	lea $64.w,a3
	lea my_vecs(pc),a4
	moveq #6,d0
.lo	move.l (a4)+,(a3)+
	dbra d0,.lo
	move.l (a4)+,$110.w
	move.l (a4)+,$134.w
	move.l (a4)+,$120.w
	move.l (a4)+,$114.w

	bclr.b #5,$fffffa11.w
	movem.l (a7)+,d0-7/a0-6
	move.w (a7)+,sr
	rts

.my_rte	rte

falc_vbl
	move.l a0,-(a7)			
	lea falc_frame(pc),a0		
	sub.w #1,(a0)
	move.l (a7)+,a0
cur_vbl	jmp $12345678


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Restore game environment
;;

restore_game_env
	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_low(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	move.w #$2700,sr

	lea $8.w,a1			; destination
	lea ULS_SYS_mem(pc),a0
	move.l (a0),a0			; source
	lea TOS_rambase(pc),a2		; last byte
	move.l (a2),d7
	bsr block_move			; put memory back

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_683a(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc
	bsr mc68030_uls_on

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_retm3(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

        lea APPta_data(PC),A3		; restore MFP timer data
        lea APPta_control(PC),A4
        bsr restore_timers

	lea APP_fa17(pc),a0	
	move.b (a0),$fffffa17.w		; restore EOI flag

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_retm4(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea APPmfp_save(pc),a1
        bsr restore_mfp

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_lpsga(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	lea APP_PSG(pc),a0
	bsr load_PSG
	
	bsr falcon_delay


	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Load file (Using GEMDOS trap #1)
;;


load_file
	move.w #$2300,sr
	bsr falcon_delay

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_3d(pc),a1
	bsr info			
	movem.l (a7)+,d0-7/a0-6
	endc

	clr.w -(a7)			; open file
	pea ULS_fn_header(pc)		; push filename
	move.w #$3d,-(a7)		; GEMDOS fopen
	trap #1
	add.l #8,a7
	lea ULS_handle(pc),a5
	move.w d0,(a5)
	bmi .file_not_found

	lea fnf_flag(pc),a6
	clr.l (a6)		

	lea ULS_filebuffer(pc),a6
	move.l (a6),-(a7)		; read file into high memory 

	lea ULS_seek_offset(pc),a6
	move.l (a6),d0
	beq.s .nosk			; skip seek if 0

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	move.l d0,d1
	bsr hashing
	lea hexad(pc),a1
	lea t_seekoff(pc),a0
	move.l (a1)+,(a0)+
	move.l (a1),(a0)
	lea t_seek(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	clr.w -(a7)			; from start of file
	lea ULS_handle(pc),a5
	move.w (a5),-(a7)
	move.l d0,-(a7)			; this many bytes
	move.w #$42,-(a7)		; f_seek
	trap #1
	lea 10(a7),a7

.nosk
	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)
	lea ULS_filebuffer(pc),a6
	move.l (a6),d1
	bsr hashing			; address ULS loads data at 
	lea hexad(pc),a1
	lea t_3fa(pc),a0
	move.l (a1)+,(a0)+
	move.l (a1),(a0)
	lea ULS_load_addr(pc),a6	; address caller wants data loaded at
	move.l (a6),d1
	bsr hashing
	lea hexad(pc),a1
	lea t_3fb(pc),a0
	move.l (a1)+,(a0)+
	move.l (a1),(a0)
	lea t_3f(pc),a1
	bsr info			; print load address
	movem.l (a7)+,d0-7/a0-6
	endc

	lea ULS_bytes_io(pc),a6
	move.l (a6),d0			; get bytes to load
	bpl.s .shrtrd			; if 
	move.l #$400000,d0		; if -ve, set to 4mb (Practical file limit!)
.shrtrd	move.l d0,-(a7)
	lea ULS_handle(pc),a5
	move.w (a5),-(a7)
	move.w #$3f,-(a7)		; GEMDOS fread
	trap #1
	lea 12(a7),a7
	move.l d0,d6
	bmi io_error_oops

	lea ULS_filebuffer(pc),a6
	move.l (a6),a6
	bsr pack_header_process

.exit_read
	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)
	move.l (a5),d1			; print bytes processed (unpacked length)
	bsr hashing
	lea hexad(pc),a1
	lea t_3fda(pc),a0
	move.l (a1)+,(a0)+
	move.l (a1),(a0)
	lea t_3fd(pc),a1
	bsr info			; print bytes loaded
	movem.l (a7)+,d0-7/a0-6
	endc

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_3e(pc),a1
	bsr info			
	movem.l (a7)+,d0-7/a0-6
	endc

	lea ULS_handle(pc),a5
	move.w (a5),-(a7)
	move.w #$3e,-(a7)		; GEMDOS fclose
	trap #1
	addq.l #4,a7

	rts

.file_not_found
	lea fnf_flag(pc),a5
	move.l #-1,(a5)
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; save file (Using GEMDOS trap #1)
;;

overwrite	dc.w 0

save_file
	move.w #$2300,sr

	lea overwrite(pc),a6
	clr.w (a6)			; clear overwrite flag

	lea copy_data(pc),a6
	cmp.l #-1,(a6)			; check for F_Create (New file?)
	beq .create_new

	lea ULS_bytes_io(pc),a6		; replace file?
	cmp.l #-1,(a6)
	bne.s .new_size

	movem.l d0-a6,-(a7)

	lea overwrite(pc),a6
	move.w #1,(a6)			; set overwrite flag

	pea ULS_DTA(pc)			; set DTA
	move.w #$1a,-(a7)
	trap #1
	lea 6(a7),a7

	move.w #$02,-(a7)
	pea ULS_fn_header(pc)
	move.w #$4e,-(a7)
	trap #1				; get 1st entry
	lea 8(a7),a7

	lea ULS_DTA(pc),a0
	move.l 26(a0),-(a7)		; get filesize
	lea ULS_bytes_io(pc),a0
	move.l (a7)+,(a0)		; make the written file this big

	movem.l (a7)+,d0-a6
	bra .new_size

.create_new
	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_40f(pc),a1
	bsr info			
	movem.l (a7)+,d0-7/a0-6
	endc

	clr.w -(a7)			; open file
	pea ULS_fn_header(pc)
	move.w #$3c,-(a7)		; GEMDOS fcreate
	trap #1
	add.l #8,a7
	move.w d0,d7			; file handle
	bmi io_error_oops		; loop if create error
	bra .nosk

.new_size
	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_40f(pc),a1
	bsr info			
	movem.l (a7)+,d0-7/a0-6
	endc

	move.w #1,-(a7)			; open file for WRITE
	pea ULS_fn_header(pc)
	move.w #$3d,-(a7)		; GEMDOS f_open
	trap #1
	add.l #8,a7
	move.w d0,d7			; file handle
	bmi io_error_oops		; loop if create error

	lea ULS_seek_offset(pc),a6
	move.l (a6),d0
	beq.s .nosk			; skip seek if 0

	lea overwrite(pc),a6
	cmp.w #1,(a6)
	beq.s .nosk			; skip seek if overwriting

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	move.l d0,d1
	bsr hashing
	lea hexad(pc),a1
	lea t_seekoff(pc),a0
	move.l (a1)+,(a0)+
	move.l (a1),(a0)
	lea t_seek(pc),a1
	bsr info
	movem.l (a7)+,d0-7/a0-6
	endc

	clr.w -(a7)			; from start of file
	move.w d7,-(a7)
	move.l d0,-(a7)			; this many bytes
	move.w #$42,-(a7)		; f_seek
	trap #1
	lea 10(a7),a7

.nosk
	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)
	lea ULS_filebuffer(pc),a6
	move.l (a6),d1
	bsr hashing			; address ULS saved data from
	lea hexad(pc),a1
	lea t_40a(pc),a0
	move.l (a1)+,(a0)+
	move.l (a1),(a0)
	lea ULS_load_addr(pc),a6	; address caller wants data saved at
	move.l (a6),d1
	bsr hashing
	lea hexad(pc),a1
	lea t_40b(pc),a0
	move.l (a1)+,(a0)+
	move.l (a1),(a0)
	lea t_40(pc),a1
	bsr info			; print save address
	movem.l (a7)+,d0-7/a0-6
	endc

	lea ULS_filebuffer(pc),a6
	move.l (a6),-(a7)		; address of filebuffer
	lea ULS_bytes_io(pc),a6
	move.l (a6),-(a7)		; bytes to write

	move.w d7,-(a7)
	move.w #$40,-(a7)		; GEMDOS fwrite
	trap #1
	lea 12(a7),a7
	move.l d0,d6
	bmi io_error_oops

	lea ULS_bytes_loaded(pc),a6
	move.l d6,(a6)			; save bytes loaded counter

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)
	move.l d6,d1			; print bytes processed
	bsr hashing
	lea hexad(pc),a1
	lea t_40da(pc),a0
	move.l (a1)+,(a0)+
	move.l (a1),(a0)
	lea t_40d(pc),a1
	bsr info			; print bytes saved
	movem.l (a7)+,d0-7/a0-6
	endc

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_3e(pc),a1
	bsr info			
	movem.l (a7)+,d0-7/a0-6
	endc

	move.w d7,-(a7)			
	move.w #$3e,-(a7)		; GEMDOS fclose
	trap #1
	addq.l #4,a7

	ifd adv_debug
	movem.l d0-7/a0-6,-(a7)		; print function status
	lea t_3e(pc),a1
	bsr info			
	movem.l (a7)+,d0-7/a0-6
	endc

	movem.l d0-7/a0-6,-(a7)
	lea ramdisk_enable(pc),a6	; if the file we just wrote is in the Ramdisk, we must now devalidate it
	cmp.l #'RAMD',(a6)
	bne.s .exit_write

	lea ULS_fn_header(pc),a5
	move.l (a5),d4

	lea ramdisk_base(pc),a5		; get address of RAMdisk base
	move.l (a5),a5
.finder
	lea ULS_filename(pc),a6		; filename requested
	move.l a5,-(a7)

	cmp.l 16(a5),d4			; same data folder?
	bne .err

	move.w #11,d0			; 12 chars/name
.floop	tst.b (a6)			; end of name?
	beq .foundit
	cmp.b (a5)+,(a6)+		; compare filename
	bne .err
	dbra d0,.floop			; name length overflow check
	bra .foundit			; all chars match!	
.err	move.l (a7)+,a5

	move.l 12(a5),d7
	btst #0,d7
	beq.s .notodd1
	addq.l #1,d7
	bclr #0,d7
.notodd1
	add.l d7,a5			; wrong name, get next pointer

	lea 20(a5),a5
	cmp.l #'END!',(a5)		; end of table?
	bne.s .finder
	bra .exit_write			; yes, file not in Ramdisk

.foundit
	cmp.b #'.',(a6)			; check if this is the end of the filename
	beq.s .noerr			; (dupe init characters check)
	tst.b (a6)
	bne .err

.noerr	move.l (a7)+,a5			; header!!
	move.l #$f0f0f0f0,(a5)+
	move.l #$0f0f0f0f,(a5)+		; trash the filename in the ramdisk table (Devalidate from Ramdisk!)

.exit_write
	movem.l (a7)+,d0-7/a0-6
	rts	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; IO Error loop
;;

io_error_oops
	add.w #1,$ffff8240.w
	bra.s io_error_oops


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Bytecopy the loaded file to correct address (allows loading to any address)
;;
;;

bytecopy_file_down
	lea ULS_bytes_loaded2(pc),a6
	move.l (a6),d6			; bytes to move

	lea ULS_filebuffer(pc),a6
	move.l (a6),a0			; where we trap loaded file at

	lea ULS_load_addr(pc),a6
	move.l (a6),a1			; where it should have loaded

;	move.l a1,d0
;	cmp.l #$100000,d0		; is it trying to load above 1mb?
;	blt.s	.fload
;	bra io_error_oops

.fload	move.b (a0)+,(a1)+		; byte copy the file (must be byte - might be odd address/length)		
	subq.l #1,d6
	bne.s .fload

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Bytecopy the save-area to protected high memory address (allows GEM to overwrite data to be saved)
;;
;;

bytecopy_file_up
	lea ULS_filebuffer(pc),a6
	move.l (a6),a0			; address to move data to (temp storage)

	lea ULS_load_addr(pc),a6
	move.l (a6),a1			; address save data stars at

	lea ULS_bytes_io(pc),a6		; bytes to save
	move.l (a6),d6
	cmp.l #-1,d6
	bne.s .fwrit
	move.l #max_filesize,d6		; fill the buffer

.fwrit	move.b (a1)+,(a0)+		; byte copy the file 		
	subq.l #1,d6
	bne.s .fwrit

	rts	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;
;; properly saving/restoring of the timer data registers
;; (hopefully)
;;
;; (w)Defjam/Checkpoint, September 2005
;; defjam_cp@gmx.net
;;

                OPT D+
flush_acia	move.w  D0,-(a7)
flush_acia_loop	btst    #0,$FFFFFC00.w
                beq.s   acia_empty
                move.b  $FFFFFC02.w,D0
                bra.s   flush_acia_loop
acia_empty	move.w  (a7)+,D0
                rts

save_mfp        lea     mfp_list(PC),A0
save_mfp_loop	movea.w (A0)+,A2
                move.b  (A2),(A1)+
                tst.w   (A0)
                bne.s   save_mfp_loop
                rts

restore_mfp     lea     mfp_list(PC),A0
restore_mfp_loop
                movea.w (A0)+,A2
                move.b  (A1)+,(A2)
                tst.w   (A0)
                bne.s   restore_mfp_loop
                rts

mfp_list        DC.W $FA07
                DC.W $FA09
                DC.W $FA13
                DC.W $FA15
                DC.W $FA17

                DC.W 0

save_timers
		move.b  $FFFFFA19.w,(A0)+ 	; ta_control - save timer control registers
                move.b  $FFFFFA1B.w,(A0)+ 	; tb_control
                move.b  $FFFFFA1D.w,(A0)+ 	; tcd_control

		move.w #$2700,sr
                clr.b   $FFFFFA19.w		; timers stop
                clr.b   $FFFFFA1B.w
                clr.b   $FFFFFA1D.w

		
                lea     timer_list(PC),A2
timer_save_loop	move.w  #$FA00,D0
                move.b  (A2)+,D0        	; tX_data
                movea.w D0,A0
                move.b  (A2)+,D0        	; tX_ctrl
                movea.w D0,A1
                move.b  (A2)+,D0        	; tX_ctrlSet
                bsr.s   evaluate_timer
                move.b  D0,(A3)+

                tst.b   (A2)
                bne.s   timer_save_loop

		clr.b   $FFFFFA19.w		; timers stop
                clr.b   $FFFFFA1B.w
                clr.b   $FFFFFA1D.w

                rts

restore_timers	
		clr.b   $FFFFFA19.w		; timers stop
                clr.b   $FFFFFA1B.w
                clr.b   $FFFFFA1D.w

                lea     timer_list(PC),A2	; restore timer_data
timer_data_restore
                move.w  #$FA00,D0
                move.b  (A2)+,D0        	; tX_data
                movea.w D0,A0
                addq.l  #2,A2           	; tX_ctrl, tX_ctrlSet

                move.b  (A3)+,D0        	; saved timer_data
                move.b  D0,(A0)
                tst.b   (A2)
                bne.s   timer_data_restore

                move.b  (A4)+,$FFFFFA19.w	; restore timer_control
                move.b  (A4)+,$FFFFFA1B.w
                move.b  (A4)+,$FFFFFA1D.w
	
                rts

timer_list
 	        DC.B $1F,$19,%00000101 		; ta_data, ta_ctrl, ta_ctrlSet 1:64
                DC.B $21,$1B,%00000101 		; tb_data, tb_ctrl, tb_ctrlSet 1:64
                DC.B $23,$1D,%01010000 		; tc_data, tc_ctrl, tc_ctrlSet 1:64
                DC.B $25,$1D,%00000101 		; td_data, td_ctrl, td_ctrlSet 1:64
                DC.B 0
                EVEN

evaluate_timer	move.w  #$1FFF,D1       	; timeout counter (if timer_data==1 !!)
		clr.l d2
                move.b  D0,(A1)         	; timer control: start
et_sync1	move.b  (A0),D0
                subq.b  #1,D0
                bne.s et_sync1
		move.w #$1fff,d1
et_sync_reload  move.b  (A0),D0
                subq.b  #1,D0
                dbne    D1,et_sync_reload
                addq.b  #1,D0
                clr.b   (A1)            	; timer control: stop
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Machine specific Video Setup routines
;;

detect_hardware
	movem.l d0-a6,-(a7)
	lea machine(pc),a5
	move.l	#"_MCH",d1			;cookie we want	
	move.l	$5a0.w,d0			;get address of cookie jar in d0
	beq.s	.nojar				;If zero, there's no jar.
	move.l	d0,a0				;move the address of the jar to a0
.search	tst.l	(a0)				;is this jar entry the last one ?
	beq.s	.nofind				;yes, the cookie was not found
	cmp.l	(a0),d1				;does this cookie match what we're looking for?
	beq.s	.foundit			;yes, it does.
	addq.l	#8,a0				;advance to the next jar entry
	bra.s	.search				;and start over
.nofind	moveq	#-1,d0				;a negative (-1) means cookie not found
	bra.s	.set_st
.nojar	moveq	#-2,d0				;a negative (-2) means there's no jar
	lea machine(pc),a5
	bra.s	.set_st				;no jar
.foundit
	cmp.l 	#$00030000,4(a0)
	beq	.set_f030
	cmp.l 	#$00010000,4(a0)
	beq	.set_ste
	cmp.l 	#$00010008,4(a0)		; this one is unofficial, NO Atari systems were released with this cookie
	beq	.set_ste			
	cmp.l	#$00010010,4(a0)
	beq	.set_mste
	cmp.l 	#$00020000,4(a0)
	beq	.set_tt
	cmp.l 	#$00010001,4(a0)
	beq	.set_stbook			

.set_st	clr.w (a5)
	movem.l (a7)+,d0-a6
	rts

.set_stbook
	move.b $ffff8260.w,d0
	cmp.b #2,d0				; HiRez Check
	bne.s .NotSTB
	bra machine_set
.NotSTB	illegal					; Pointless, but if here then Cookie Jar is fucked

.set_tt	move.w #4,(a5)
	movem.l (a7)+,d0-a6
	rts
	
.set_f030
	move.w #3,(a5)
	movem.l (a7)+,d0-a6
	rts

.set_ste
	move.w #1,(a5)
	movem.l (a7)+,d0-a6
	rts

.set_mste	
	move.w #2,(a5)
	movem.l (a7)+,d0-a6
	rts

setup_hardware
	lea machine(pc),a5
	tst.w (a5)
	beq vid_st	
	cmp.w #1,(a5)
	beq vid_ste
	cmp.w #2,(a5)
	beq vid_mste
	cmp.w #3,(a5)
	beq vid_f030
	cmp.w #4,(a5)
	beq vid_tt
error	add.w #1,$ffff8240.w
	bra.s error


vid_st
vid_tt
vid_ste
	bsr st_vidsetup
	bra machine_set

vid_mste
	bsr st_vidsetup
;	bclr #1,$ffff8e21.w
	bra machine_set

vid_f030
	bsr f030_vidsetup
	bra machine_set



st_vidsetup
	move.b #0,$ffff8260.w			; set STLOW
	rts

f030_vidsetup
	move.w	#$59,-(a7)			;check monitortype (falcon)
	trap	#14				;
	addq.l	#2,a7				;
	cmp.w	#1,d0				;if 1 = rgb
	beq.w	.rgb				;
	cmp.w	#3,d0				;if 3 = tv
	beq.w	.rgb				;otherwise assume vga (ignore mono..)

.vga60:	lea composite(pc),a0
	move.w #1,(a0)
	bsr save_videl
	move.l	#$170012,$ffff8282.w		;falcon 60Hz vga
	move.l	#$1020e,$ffff8286.w		;
	move.l	#$d0012,$ffff828a.w		;
	move.l	#$41903ff,$ffff82a2.w		;
	move.l	#$3f008d,$ffff82a6.w		;
	move.l	#$3ad0415,$ffff82aa.w		;
	move.w	#$200,$ffff820a.w		;
	move.w	#$186,$ffff82c0.w		;
	clr.w	$ffff8266.w			;
	clr.b	$ffff8260.w			;
	move.w	#$5,$ffff82c2.w			;
	move.w	#$50,$ffff8210.w		;
	bra.s	.fvideo_done

.rgb:	lea composite(pc),a0
	move.w #2,(a0)
	bsr save_videl
	move.l	#$300027,$ffff8282.w		;falcon 50Hz rgb
	move.l	#$70229,$ffff8286.w		;
	move.l	#$1e002a,$ffff828a.w		;
	move.l	#$2710265,$ffff82a2.w		;
	move.l	#$2f0081,$ffff82a6.w		;
	move.l	#$211026b,$ffff82aa.w		;
	move.w	#$200,$ffff820a.w		;
	move.w	#$185,$ffff82c0.w		;
	clr.w	$ffff8266.w			;
	clr.b	$ffff8260.w			;
	clr.w	$ffff82c2.w			;
	move.w	#$50,$ffff8210.w		;

.fvideo_done:
	rts

save_videl
	move.w #-1,-(a7)
	move.w #88,-(a7)
	trap #14
	lea 4(a7),a7				; falc screen mode
	lea falc_scr(pc),a0
	move.w d0,(a0)
	rts

machine_set
	clr.w -(a7)
	pea -1
	pea -1
	move.w #5,-(a7)
	trap #14
	lea 12(a7),a7
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Set 16Mhz (If available)
;;

set_16		lea machine(pc),a6
		cmp.w #2,(a6)
		beq .mste16
		cmp.w #3,(a6)
		beq .falc16
		rts

.mste16		lea old_mhz(pc),a6
		move.b $ffff8e21.w,(a6)
		bset.b #0,$ffff8e21.w
		rts

.falc16		lea old_mhz(pc),a6
		move.b $ffff8007.w,(a6)
		bset.b #0,$ffff8007.w
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Restore CPU speed back to entry conditions
;;

set_8		lea machine(pc),a6
		cmp.w #2,(a6)
		beq .mste8
		cmp.w #3,(a6)
		beq .falc8
		rts

.mste8		lea old_mhz(pc),a6
		move.b (a6),$ffff8e21.w
		rts

.falc8		lea old_mhz(pc),a6
		move.b (a6),$ffff8007.w	
		rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Read/Write PSG Port A/B status
;;

load_PSG	lea $ffff8800.w,a5   	; (Restore from A0)
		move.b #14,(a5)
		move.b (a0)+,d0
		bclr #7,d0		; enable falcon IDE
		move.b d0,2(a5)
		move.b #15,(a5)
		move.b (a0),2(a5)
		rts
	
save_PSG
		lea $ffff8800.w,a5   	; (Save to a0)
		move.b #14,(a5)
		move.b (a5),(a0)+
		move.b #15,(a5)
		move.b (a5),(a0)
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Falcon & TT  CPU / Cache / PMMU settings
;;

kill_f030
		lea machine(pc),a0			; check for falcon / tt
		cmp.w #4,(a0)
		beq.s .do_it
		cmp.w #3,(a0)
		beq.s .do_it
		rts
.do_it
		move    SR,-(a7)
        	move    #$2700,SR

		lea SYS_VBR(pc),a0			*
		dc.l $f0104e00				* pmove vbr,(a0) (Get VBR address)

		lea	SYS_PMMU(pc),a0			*save TC/TT0/TT1
		dc.w	$f028,$4200,$0000		*pmove tc,(a0)
		dc.w	$f028,$0a00,$0004		*pmove tt0,4(a0)
		dc.w	$f028,$0e00,$0008		*pmove tt1,8(a0)

        	lea     pmmu_table(PC),A0
		lea	run_tc+4(pc),a1
        	move.l  A0,(A1)         		; TC_access+4
        	move.l  A0,8(A1)        		; TT0_access+4
        	move.l  A0,16(A1)       		; TT1_access+4
		lea     TC_access+4(PC),A1
        	move.l  A0,(A1)         		; TC_access+4
        	move.l  A0,8(A1)        		; TT0_access+4
        	move.l  A0,16(A1)       		; TT1_access+4


        	movea.l $00000010.w,A6
        	pea     no_cacr(PC)			; disable CACHE
        	move.l  (a7)+,$00000010.w
        	moveq   #0,D0
        	DC.L $4E7A0002  			; movec cacr,d0
        	lea     SYS_cacr(PC),A5			*Save cache state
        	move.l  D0,(A5)
       	 	moveq   #0,D0
nop_me_out      DC.L $4E7B0002  			; movec d0,cacr

no_cacr 	nop
                pea     no_pmmu(PC)			; move the PMMU
                move.l  (a7)+,$00000010.w
                moveq   #0,D0
                DC.L $4E7B0801  			; MOVEC     D0,VBR     Vektorbase=0 (eigentlich Standard)

TC_access       DC.L $F0394000,$DEADF030 		; PMOVE     pmmu_tab,TC
TT0_access      DC.L $F0390800,$DEADF030 		; PMOVE     pmmu_tab,TT0
TT1_access      DC.L $F0390C00,$DEADF030 		; PMOVE     pmmu_tab,TT1

no_pmmu         nop
                move.l  A6,$00000010.w  		;restore old $10

		lea machine(pc),a6
		cmp.w #4,(a6)				; test for TT
		beq no_f030_proc_control

                movea.l $00000008.w,A6
                pea     no_f030_proc_control(PC)
                move.l  (a7)+,$00000008.w
                lea     $FFFF8007.w,A0  		; Falcon Processor Control
                move.b  (A0),D0
		lea 	sys_FCPUC(pc),a1		* Save its state
		move.b	d0,(a1)				*
                bclr    #5,D0           		; STe Bus Emulation  ON
                bclr    #2,D0           		; Blitter Speed      8 MHz
                move.b  D0,(A0)

no_f030_proc_control
		nop
                move.l  A6,$00000008.w  		;restore old $8
                move    (a7)+,SR
                rts
               
pmmu_table	DCB.W     4,0 				; F030 StartUp(boot) PMMU Table
      		DC.B      $79,$FF,$3C,$00,$00,$00,$00,$00 
		DCB.W     2,0 
	        DC.B      $79,$FF,$3C,$00,$00,$00,$00,$00 
	        DCB.W     2,0 
	        DC.B      $79,$FF,$3C,$00,$00,$00,$00,$00 
	        DCB.W     2,0 
	        DC.B      $79,$FF,$3C,$00,$00,$00,$00,$00 
	        DCB.W     2,0 
	        DC.B      $79,$FF,$3C,$00,$00,$00,$00,$00 
	        DCB.W     2,0 
	        DC.B      $79,$FF,$3C,$00,$00,$00,$00,$00 
	        DCB.W     2,0 
 	        DC.B      $79,$FF,$3C,$00,$00,$00,$00,$00 
	        DCB.W     2,0 
	        DC.B      $79,$FF,$3C,$00,$00,$00,$00,$00 
	        DCB.W     2,0 
	        DC.B      $79,$FF,$3C,$00,$00,$00,$00,$00 
	        DCB.W     2,0 
 	        DC.B      $79,$FF,$3C,$00,$00,$00,$00,$00 
	        DCB.W     2,0 
	        DC.B      $79,$FF,$3C,$00,$00,$00,$00,$00 
	        DCB.W     2,0 
	        DC.B      $79,$FF,$3C,$00,$00,$00,$00,$00 
	        DCB.W     2,0 
	        DC.B      $79,$FF,$3C,$00,$00,$00,$00,$00 
	        DCB.W     2,0 
	        DC.B      $79,$FF,$3C,$00,$00,$00,$00,$00 
	        DCB.W     2,0 
	        DC.B      $79,$FF,$3C,$00,$00,$00,$00,$00 
	        DCB.W     2,0 
	        DC.B      $79,$FF,$3C,$00,$00,$00,$00,$00 
	        DCB.W     2,0 
	        DC.B      $F9,$FF,$3E,$00,$00,$00,$00,$00 
	        DCB.W     2,0 
	        DC.B      $F9,$FF,$3E,$00,$00,$00,$00,$00 
	        DCB.W     2,0 
	        DC.B      $F9,$FF,$3E,$00,$00,$00,$00,$00 
	        DCB.W     2,0 
	        DC.B      $F9,$FF,$3E,$00,$00,$00,$00,$00 
 	        DCB.W     2,0 
	        DC.B      $F9,$FF,$3E,$00,$00,$00,$00,$00 
  
		EVEN



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; call with long to convert in d1
;; string placed at hexad
;;

hashing	moveq #0,d0
	lea .table(pc),a0
	lea hexad+8(pc),a2
	bsr.s .first
	moveq.w #5,d3
.loop	bsr.s .next
	dbra d3,.loop
.next	ror.l #4,d1
.first	move.b d1,d0
	and #$f,d0
	move.b (a0,d0),-(a2)
	rts


.table	dc.b "0123456789ABCDEF"
hexad	ds.l 2
	dc.l $ffffffff
	even

font_x	DC.B      $00,$38,$66,$00,$00,$00,$00,$18 		; the debug screen font
      	DC.B      $1E,$78,$00,$00,$00,$00,$00,$00 
      	DC.B      $7C,$38,$7C,$FE,$1C,$FE,$7E,$FE 
      	DC.B      $7C,$7C,$00,$00,$00,$00,$00,$7C 
      	DC.B      $00,$7C,$FC,$7E,$FC,$FE,$FE,$7E 
      	DC.B      $00,$38,$EE,$00,$00,$00,$00,$18 
      	DC.B      $3E,$7C,$00,$00,$00,$00,$00,$00 
      	DC.B      $FE,$78,$FE,$FC,$3C,$FE,$FE,$FE 
      	DC.B      $FE,$FE,$00,$00,$00,$00,$00,$EE 
      	DC.B      $00,$FE,$FE,$FE,$FE,$FE,$FE,$FE 
      	DC.B      $00,$38,$CC,$00,$00,$00,$00,$30 
      	DC.B      $38,$1C,$00,$00,$00,$00,$FC,$00 
      	DC.B      $0E,$00,$00,$00,$0C,$00,$00,$00 
      	DC.B      $06,$86,$60,$30,$00,$00,$00,$0E 
      	DC.B      $00,$06,$0E,$00,$06,$00,$00,$00 
      	DC.B      $00,$38,$00,$00,$00,$00,$00,$30 
      	DC.B      $38,$1C,$00,$00,$00,$00,$FC,$00 
      	DC.B      $C6,$38,$1C,$1C,$CC,$FC,$FC,$38 
      	DC.B      $7C,$7E,$60,$30,$00,$00,$00,$1C 
      	DC.B      $00,$FE,$FC,$C0,$E6,$FC,$FC,$EE 
      	DCB.W     4,0 
      	DC.B      $38,$1C,$00,$00,$30,$00,$00,$00 
      	DC.B      $E6,$38,$38,$0E,$FE,$0E,$EE,$70 
      	DC.B      $C6,$0E,$00,$00,$00,$00,$00,$30 
      	DC.B      $00,$FE,$C6,$C0,$E6,$E0,$E0,$E6 
      	DC.B      $00,$38,$00,$00,$00,$00,$00,$00 
      	DC.B      $3E,$7C,$00,$00,$60,$30,$00,$00 
      	DC.B      $FE,$FE,$7E,$EE,$1C,$EE,$EE,$70 
      	DC.B      $FE,$1C,$60,$30,$00,$00,$00,$00 
      	DC.B      $00,$EE,$FE,$FE,$FE,$FE,$E0,$FE 
      	DC.B      $00,$38,$00,$00,$00,$00,$00,$00 
      	DC.B      $1E,$78,$00,$00,$00,$30,$00,$00 
      	DC.B      $7C,$FE,$FE,$FC,$1C,$FC,$7C,$70 
      	DC.B      $7C,$78,$60,$60,$00,$00,$00,$30 
      	DC.B      $00,$EE,$FC,$7E,$FC,$FE,$E0,$7E 
      	DCB.W     20,0
      	DC.B      $EE,$7C,$0E,$EE,$E0,$EE,$C6,$7C 
      	DC.B      $FC,$7C,$FC,$7E,$FE,$EE,$EE,$C6 
      	DC.B      $C6,$EE,$FE,$00,$00,$00,$00,$00 
      	DCB.W     8,0 
      	DC.B      $EE,$7C,$0E,$FE,$E0,$FE,$E6,$FE 
      	DC.B      $FE,$FE,$FE,$FE,$FE,$EE,$EE,$C6 
      	DC.B      $EE,$EE,$FE,$00,$00,$00,$00,$00 
      	DCB.W     10,0
      	DC.B      $E0,$7E,$76,$0E,$0E,$0E,$0E,$00 
      	DC.B      $00,$EE,$00,$D6,$7C,$00,$00,$00 
      	DCB.W     10,0
      	DC.B      $FE,$38,$0E,$FC,$E0,$BE,$BE,$EE 
      	DC.B      $FE,$EE,$FC,$7C,$38,$EE,$EE,$BE 
      	DC.B      $38,$7C,$38,$00,$00,$00,$00,$00 
      	DCB.W     8,0 
      	DC.B      $EE,$38,$EE,$FE,$00,$D6,$DE,$EE 
      	DC.B      $FC,$EE,$FC,$0E,$38,$00,$EE,$7E 
      	DC.B      $7C,$38,$70,$00,$00,$00,$00,$00 
      	DCB.W     8,0 
      	DC.B      $EE,$7C,$EE,$EE,$FE,$C6,$CE,$FE 
      	DC.B      $E0,$FC,$EE,$FE,$38,$FE,$7C,$FE 
      	DC.B      $EE,$38,$FE,$00,$00,$00,$00,$00 
      	DCB.W     8,0 
      	DC.B      $EE,$7C,$7C,$E6,$FE,$C6,$C6,$7C 
      	DC.B      $E0,$7E,$EE,$FC,$38,$7E,$38,$EE 
      	DC.B      $C6,$38,$FE,$00,$00,$00,$00,$00 
      	DCB.W     48,0
	even

info_init
	lea font_x(pc),a0			; Font offsets for plotter
	move.l a0,d0
	move.l d0,d1
	add.l #40*8,d1
	lea ascii(pc),a1
	move.w #39,d2
.adder	move.l d0,(a1)
	move.l d1,160(a1)
	addq.l #1,d0
	addq.l #1,d1
	lea 4(a1),a1
	dbra d2,.adder
	rts

ascii	ds.l 80

next_add	dc.l 0
n1		dc.l 1
n2		dc.l 7
old_pal		ds.w 16

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Text plotting routine
;;
;; call with a1 pointing at text
;;       

info	lea ULS_scr(pc),a0
	move.l (a0),a0
	add.l (a1)+,a0
	lea next_add(pc),a3
	move.l a0,(a3)
	move.l #1,4(a3)		; n1
	move.l #7,8(a3)		; n2
.loop	moveq.l #0,d0
	move.b (a1)+,d0
	bpl.s .write
	cmp.b #-1,d0
	beq.s .wrap
.nextline
	move.l #1,4(a3)		; n1
	move.l #7,8(a3)		; n2
	move.l (a3),a0
	add.l #160*9,a0
	move.l a0,(a3)
	bra.s .loop
.wrap	rts
.write	cmp.b #'.',d0		; '.' and '-' are swapped in the font. cheap hack :P
	bne.s .nodot
	move.b #'-',d0
	bra.s .ch_ok
.nodot	cmp.b #'-',d0
	bne.s .ch_ok
	move.b #'.',d0
.ch_ok	sub.b #' ',d0
	add d0,d0
	add d0,d0
	lea ascii(pc),a2
	move.l (a2,d0),a2
	bsr.s .plotit
	bra .loop
.plotit	
x	set 0
y	set 0
	rept 8
	move.b x(a2),y(a0)
x	set x+40
y	set y+160
	endr
	add.l 4(a3),a0
	move.l 4(a3),-(a7)
	move.l 8(a3),4(a3)
	move.l (a7)+,8(a3)
	rts

	ifd adv_debug

;	dc.b "0123456789012345678901234567890123456789"

t_regi	dc.l 114*160
	dc.b "D0: "
t_d0	ds.b 8
	dc.b "  A0: "
t_a0	ds.b 8
	dc.b "  SR: "
t_sr	dc.b "    "
	dc.b " ",-2
	dc.b "D1: "
t_d1	ds.b 8
	dc.b "  A1: "
t_a1	ds.b 8
	dc.b " ",-2
	dc.b "D2: "
t_d2	ds.b 8
	dc.b "  A2: "
t_a2	ds.b 8
	dc.b " ",-2
	dc.b "D3: "
t_d3	ds.b 8
	dc.b "  A3: "
t_a3	ds.b 8
	dc.b " ",-2
	dc.b "D4: "
t_d4	ds.b 8
	dc.b "  A4: "
t_a4	ds.b 8
	dc.b " ",-2
	dc.b "D5: "
t_d5	ds.b 8
	dc.b "  A5: "
t_a5	ds.b 8
	dc.b " ",-2
	dc.b "D6: "
t_d6	ds.b 8
	dc.b "  A6: "
t_a6	ds.b 8
	dc.b " ",-2
	dc.b "D7: "
t_d7	ds.b 8
	dc.b "  A7: "
t_a7	ds.b 8

	dc.b -1

	even

t_uls	dc.l (132*160)+112
	dc.b "UNIVERSAL",-2,"LOADING",-2,"SYSTEM",-2,"2005-2008",-2,"D-BUG",-1
	even

t_read	dc.l 010*160
	dc.b "ULS FUNCTION: READ",-1
	even

t_save	dc.l 010*160
	dc.b "ULS FUNCTION: WRITE",-1
	even

t_proc	dc.l 020*160
	dc.b "PROCESSING FILE: ",-2
prt_fn	ds.b 12
	dc.b -1
	even

t_ulsb	dc.l (0*160)+80
	dc.b "ULS BASE: " 
t_ulsba	ds.b 8
	dc.b -1
	even

t_gemb	dc.l (10*160)+80
	dc.b "GEM BASE: "
t_gemba	ds.b 8
	dc.b -1
	even

t_appb	dc.l (20*160)+80
	dc.b "APP BASE: "
t_appba	ds.b 8
	dc.b -1     

t_hiby	dc.l (30*160)+80
	dc.b "STUB ADD: "
t_hibya	ds.b 8
	dc.b -1  

t_init	dc.l 192*160
	dc.b "ULS EXECUTION:    "  
	dc.b "ENTERING ULS!        ",-1
	even	even

t_done	dc.l (192*160)+64
	dc.b "ALL DONE.            ",-1
	even

t_wrcd	dc.l (192*160)+64
	dc.b "WRITE COOLDOWN       ",-1
	even

t_f30d	dc.l (192*160)+64
	dc.b "FALCON IDE DELAY     ",-1
	even

t_scr	dc.l (192*160)+64
	dc.b "SCREENSHOT FUNCTION  ",-1
	even

t_seek	dc.l (192*160)+64
	dc.b "SEEK OFFSET "
t_seekoff	dc.b "        ",-1
	even

t_683a	dc.l (192*160)+64
	dc.b "RESTORING ULS 68030  ",-1
	even

t_683g	dc.l (192*160)+64
	dc.b "RESTORING APP 68030  ",-1
	even

t_rgem	dc.l (192*160)+64
	dc.b "RESTORING GEMDOS RAM ",-1
	even

t_prfn	dc.l (192*160)+64
	dc.b "PROCESS FILENAME     ",-1
	even

t_sapp	dc.l (192*160)+64
	dc.b "SAVING APP RAM       ",-1
	even

t_entcp	dc.l (192*160)+64
	dc.b "ENABLE ULS TIMER C   ",-1
	even

t_lpsga	dc.l (192*160)+64
	dc.b "LOADING APP PSG      ",-1
	even

t_satm1	dc.l (192*160)+64
	dc.b "SAVING APP MPF (RAW) ",-1
	even

t_satm2	dc.l (192*160)+64
	dc.b "SAVING APP MFP (TIM) ",-1
	even

t_retm1	dc.l (192*160)+64
	dc.b "LOADING GEM MFP (RAW)",-1
	even

t_retm2	dc.l (192*160)+64
	dc.b "LOADING GEM MFP (TIM)",-1
	even

t_retm3	dc.l (192*160)+64
	dc.b "LOADING APP MFP (RAW)",-1
	even

t_retm4	dc.l (192*160)+64
	dc.b "LOADING APP MFP (TIM)",-1
	even

t_LPSG	dc.l (192*160)+64
	dc.b "LOADING GEM PSG      ",-1
	even

t_SPSG	dc.l (192*160)+64
	dc.b "SAVING APP PSG       ",-1
	even

t_low	dc.l (192*160)+64
	dc.b "RESTORING LOW MEMORY ",-1
	even	

t_flshc	dc.l (192*160)+64
	dc.b "FLUSH 68030 CACHES   ",-1
	even

t_rdta	dc.l (192*160)+64
	dc.b "RESET DTA POINTER    ",-1
	even

t_ssfc	dc.l (192*160)+64
	dc.b "CREATE STATE FILE    ",-1
	even

t_ssfo	dc.l (192*160)+64
	dc.b "OPEN STATE FILE      ",-1
	even

t_ssdh	dc.l (192*160)+64
	dc.b "DUMPING HEADER INFO  ",-1
	even

t_ssrh	dc.l (192*160)+64
	dc.b "READING HEADER INFO  ",-1
	even

t_ssdl	dc.l (192*160)+64
	dc.b "DUMP RAM (LOW COPY)  ",-1
	even

t_ssrl	dc.l (192*160)+64
	dc.b "READ RAM (LOW COPY)  ",-1
	even

t_ssdn	dc.l (192*160)+64
	dc.b "DUMP RAM (MAIN)      ",-1
	even

t_ssrn	dc.l (192*160)+64
	dc.b "READ RAM (MAIN)      ",-1
	even

t_ssdv	dc.l (192*160)+64
	dc.b "DUMP ULS VARIABLES   ",-1
	even

t_ssrv	dc.l (192*160)+64
	dc.b "READ ULS VARIABLES   ",-1
	even

t_ssrr	dc.l (192*160)+64
	dc.b "READ APP REGISTERS   ",-1
	even

t_ssdr	dc.l (192*160)+64
	dc.b "DUMP APP REGISTERS   ",-1
	even

t_sscf	dc.l (192*160)+64
	dc.b "CLOSE STATE FILE     ",-1
	even

t_3e	dc.l 100*160
	dc.b "CLOSING FILE     ",-1
	even

t_40f	dc.l 100*160
	dc.b "WRITE FILE       ",-1
	even

t_3d	dc.l 050*160
	dc.b "OPENING FILE     ",-1
	even

t_jmp	dc.l (000*160)
	dc.b "CALLED FROM:     ",-2
t_jmpa	ds.b 8
	dc.b -1
	even

t_3f	dc.l 060*160
	dc.b "READING FILE AT: ",-2
t_3fa	ds.b 8
	dc.b "   ("
t_3fb	ds.b 8
	dc.b ")"
	dc.b -1
	even

t_3fd	dc.l 080*160
	dc.b "NUMBER OF BYTES: ",-2
t_3fda	ds.b 8
	dc.b -1
	even

t_40	dc.l 060*160
	dc.b "WRITING FILE AT: ",-2
t_40a	ds.b 8
	dc.b "   ("
t_40b	ds.b 8
	dc.b ")"
	dc.b -1
	even

t_40d	dc.l 080*160
	dc.b "NUMBER OF BYTES: ",-2
t_40da	ds.b 8
	dc.b -1
	even
	endc

t_curs_on	dc.l (160*9)*5
		dc.b " -",-1
		even

t_curs_off	dc.l (160*9)*5
		dc.b "  ",-1
		even

t_savestate
;	dc.b "012345678901234567890123456789123456789"
	dc.l 160*9
	dc.b " -------------------------------------",-2
	dc.b "  ULS V3.1 MEMORY SNAPSHOT MANAGEMENT ",-2
	dc.b " -------------------------------------",-2
	dc.b -2
t_sav0	dc.b "  0  NO FILE FOUND                    ",-2
	dc.b "  1  NO FILE FOUND                    ",-2
	dc.b "  2  NO FILE FOUND                    ",-2
	dc.b "  3  NO FILE FOUND                    ",-2
	dc.b "  4  NO FILE FOUND                    ",-2
	dc.b "  5  NO FILE FOUND                    ",-2
	dc.b "  6  NO FILE FOUND                    ",-2
	dc.b "  7  NO FILE FOUND                    ",-2
	dc.b "  8  NO FILE FOUND                    ",-2
	dc.b "  9  NO FILE FOUND                    ",-2
	dc.b -2
	dc.b " USE CURSOR UP AND DOWN TO MOVE AND",-2
	dc.b " ENTER TO SELECT.",-2
	dc.b " PRESS ESC TO EXIT BACK TO GAME",-2
t_kill	dc.b -2
	dc.b " YOU CAN TYPE UP TO 31 CHARS FOR A",-2
	dc.b " COMMENT FOR EACH SAVE SLOT.",-1
	even

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; ULS Auto-Ramdisk Pre-Builder 
;;

init_ramdisk
	move.w sr,-(a7)
	move.w #$2300,sr

	lea initial_rd_folder(pc),a0
	move.l (a0),-(a7)
	lea local_fn(pc),a0
	move.l (a7)+,(a0)		; copy initial folder to ramdisk creation

	lea ULS_DTA(pc),a0		; clear local DTA buffer
	lea 44(a0),a1
.ww	clr.b (a0)+
	cmp.l a0,a1
	bne.s .ww

	lea ramdisk_spec(pc),a0
	move.l (a0),a0
	lea local_fn+5(pc),a1
	moveq #11,d0
.qq	move.b (a0)+,(a1)+
	dbra d0,.qq

	pea ULS_DTA(pc)		; set DTA
	move.w #$1a,-(a7)
	trap #1
	lea 6(a7),a7

	lea ramdisk_base(pc),a6
	move.l (a6),a6		; base of ramdisk

	move.w #$02,-(a7)
	lea local_fn(pc),a0
	move.l a0,-(a7)
	move.w #$4e,-(a7)
	trap #1			; get 1st entry
	lea 8(a7),a7

	bsr .proc_ramdisk

.rdloop	move.w #79,-(a7)
	trap #1			; get next
	add.l #2,a7
	tst.w d0
	bmi.s .out
	bsr .proc_ramdisk
	bra .rdloop

.out	lea end_of_ramdisk(pc),a0
	move.l a6,(a0)		; store end-of-ramdisk (for append)

	move.l #'END!',(a6)+	; end of table marker
	move.l #'END!',(a6)+
	clr.l (a6)+
	clr.l (a6)+
	
	move.w (a7)+,sr

	rts

.proc_ramdisk
	lea ULS_DTA+30(pc),a5
	move.l a6,a4		 ; pointer to next entry
	moveq #11,d7
.fnm	move.b (a5)+,d0
	beq.s .done
	move.b d0,(a4)+		 ; filename
	dbra d7,.fnm
.done	move.l a6,a4
	move.l ULS_DTA+26(pc),d6
	move.l d6,d7
	add.l #1,d7
	bclr #0,d7
	move.l d7,-(a7)
;	add.l #1,d6
;	bclr #0,d6
	move.l d6,12(a4) 	; length

	move.l a6,d6
	lea local_fn+5(pc),a5
	move.w #11,d5
.fn	move.b (a6)+,(a5)+
	dbra d5,.fn
	lea -12(a6),a6

	clr.w -(a7)
	pea local_fn(pc)	; push filename
	move.w #$3d,-(a7)
	trap #1
	move.w d0,d7
	lea 8(a7),a7

	add.l #20,d6
	move.l d6,-(a7)		; address to start at
	move.l #$f0000,-(a7)	; bytes to load
	move.w d7,-(a7)		; handle
	move.w #$3f,-(a7)	; read
	trap #1
	lea 12(a7),a7

	move.w d7,-(a7)
	move.w #$3e,-(a7)
	trap #1			; close
	lea 4(a7),a7
	
	ifd adv_debug
	move.l a4,-(a7)
	lea local_fn(pc),a4
killadb	bsr i_prnt
	lea i_lfcr,a4
killadc	bsr i_prnt
	move.l (a7)+,a4
	endc

	lea local_fn(pc),a5
	move.l (a5),16(a4)	; 4 char DIR name to ramdisk

	add.l (a7)+,a6
;	add.l 12(a4),a6
	add.l #20,a6
		
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; ULS Auto-Ramdisk Updater 
;;

end_of_ramdisk	dc.l 0		; end of ramdisk (where End of Table markers are)
new_rd_dir	dc.l 0		; 4 char ascii of foldername
rd_update_type	dc.w 0		; -1 = refresh / 1 = append
new_rd_filespec	dc.l 0		; pointer to new filespec

update_ramdisk
	ifd adv_debug
	lea killadb(pc),a0
	move.l #$4e714e71,(a0)	; disable CONOUT (as game is now running no terminal screen)
	lea killadc(pc),a0
	move.l #$4e714e71,(a0)
	endc

	lea new_rd_filespec(pc),a0
	move.l (a0),-(a7)
	lea ramdisk_spec(pc),a0
	move.l (a7)+,(a0)

	lea rd_update_type(pc),a0
	cmp.w #-1,(a0)
	beq .rebuild_ramdisk
.append_ramdisk
	lea ramdisk_base(pc),a0
	move.l (a0),-(a7)	; store RAMdisk base address
	lea end_of_ramdisk(pc),a1
	move.l (a1),(a0)	; store End pointer as start (append)
	lea new_rd_dir(pc),a0
	move.l (a0),d0
	lea initial_rd_folder(pc),a0
	move.l d0,(a0)		; change the folder name
	bsr init_ramdisk
	lea ramdisk_base(pc),a0
	move.l (a7)+,(a0)	; restore RAMdisk base
	rts

.rebuild_ramdisk
	lea new_rd_dir(pc),a0
	move.l (a0),d0		; change the folder name
	lea initial_rd_folder(pc),a0
	move.l d0,(a0)
	bsr init_ramdisk	; rebuild the RAMdisk
	rts

local_fn
	dc.b "DATA\"
	ds.b 12
	even

ULS_DTA	ds.b 44

	even
	ds.b 2048		; some local stack space, can probably be reduced.
ULS_stk	ds.b 2

	ds.b 512		; "just in case"
ULS_TRASH_RAM


