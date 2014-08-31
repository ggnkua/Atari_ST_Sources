;----------------------------------------------------------------------------
; File name:	L_STRUCT.S			Revised:	1994.09.06
; Author:	Ulf Ronald Andersson		Created:	1994.07.02
; Purpose:	Screen parameter structure
;----------------------------------------------------------------------------
	IFND	lpt_sizeof	;ensures single pass 1 inclusion
;----------------------------------------------------------------------------
;	SCREEN table structure & constants
;
rezfixed	= 3		;number of 'Normal' resolution slots
rezlimit	= 16		;total number of resolution slots
interface_ver	= $0209		;LaceScan version of interface update
;
emu_slot	= rezlimit-1	;slot for external emulator
fail_slot	= rezlimit-2	;slot to handle overscan switching
;
	rsreset
;
sc_Xrez		rs.w	1	; 0:w  Useful pixels horizontally
sc_Yrez		rs.w	1	; 2:w  Useful pixels vertically
sc_bytewidth	rs.w	1	; 4:w  all bytes incl garbage for one line
sc_reen_lines	rs.w	1	; 6:w  all lines incl garbage for one screen
sc_reen_bytes	rs.l	1	; 8:l  all bytes incl garbage for one screen
sc_log_offs	rs.l	1	;12:l  logbase - membase  (always positive)
sc_def_mark	rs.w	1	;16:w  marks valid screen defs unless zero
sc_rez		rs.w	1	;18:w  hardware rez for "hw_rez"
sc_emu_rez	rs.b	1	;20:b  GEM rez for "sshiftmd"
sc_hardc_f	rs.b	1	;21:b  flags ALT-HELP => print file
sc_backg_f	rs.b	1	;22:b  flags border colour
sc_intfx_f	rs.b	1	;23:b  flags border auto-erase interrupt
sc_emu_mark	rs.b	0	;marks beginning of Emu-specific area
sc_emu_Xrez	rs.w	1	;24:w  Emu Xrez for GEM
sc_emu_Yrez	rs.w	1	;26:w  Emu Yrez for GEM
sc_emu_planes	rs.w	1	;28:w  Emu bitplanes for GEM
sc_emu_bytewid	rs.w	1	;30:w  Emu bytes incl garbage for one line
sc_sizeof	rs.b	0	;end marker for structure
sc_log2size	= 5
;
;NB:	sc_reen_bytes = (sc_bytewidth * sc_Yrez) + sc_log_offs + 1024
;
;slot_pos	slot_code	Resolution
;---------	---------	---------------------------------------
;  -1		   --		Current or latest resolution 
;   0		   13		Normal Low
;   1		   14		Normal Medium
;   2		   15		Normal High
;   3		    0		Overscan Low
;   4		    1		Overscan Medium
;   5		    2		Overscan High
;   6		    3		Normalized Overscan Low
;   7		    4		Normalized Overscan Medium
;   8		    5		Normalized Overscan High
; 9 - 12	  6 - 9		User Defined Overscan Sizes
;13 - 15	 10 - 12	Emulator slots
;
;----------------------------------------------------------------------------
;	LaceScan Parameter Table structure
;
	rsreset
;
;-------------------------------------
; Constants for compatibility test
;-------------------------------------
lpt_version	rs.w	1	;running version of LaceScan
lpt_interface	rs.w	1	;oldest version with same interface
lpt_parm_size	rs.w	1	;structure size excluding SCD areas
lpt_total_size	rs.w	1	;total structure size
;-------------------------------------
; Variables of LaceScan
;-------------------------------------
lpt_screen_lock	rs.w	1	;1 locks LaceScan bases, 0 allows change
lpt_phys_mask	rs.w	1	;1 masks LaceScan physbase, 0 unmasks
lpt_setup_mask	rs.w	1	;low 6 bits mask LaceScan setup keys
lpt_setup_keys	rs.w	1	;low 6 bits test LaceScan setup keys
;-------------------------------------
; Pointers of LaceScan
;-------------------------------------
lpt_lockbase_p	rs.l	1	;->locked LaceScan screen base
lpt_physbase_p	rs.l	1	;->LaceScan physbase (Normally locked)
lpt_fix_screen	rs.l	1	;->LaceScan subroutine for Emu
lpt_refix	rs.l	1	;->LaceScan subroutine for Emu
;-------------------------------------
; Constants/Variables of Lace_Emu
;-------------------------------------
lpt_emu_id:	rs.w	1	;high byte = emu id, low byte = version
lpt_slot_req	rs.w	1	;v_opnwk slot request from Emu, -1 = none
lpt_emu_type_ix	rs.w	1	;emu_type_ix in Emu, 0 = no emulation
lpt_emu_ypos	rs.w	1	;next physical line number for emulation
;-------------------------------------
; Pointers of Lace_Emu
;-------------------------------------
lpt_emu_lock_p	rs.l	1	;->locked emulation physbase of Emu
lpt_emu_phys_p	rs.l	1	;->active emulation physbase of Emu
lpt_emu_block_p	rs.l	1	;->block flag, bits 0 & 1 for LaceScan use
lpt_opnwk_lk_1	rs.l	1	;->Emu subroutine called at start of v_opnwk
lpt_opnwk_lk_2	rs.l	1	;->Emu subroutine called at end of v_opnwk
lpt_emu_command	rs.l	1	;->Emu 'command' subroutine for 'Set_Lace'
lpt_emu_reload	rs.l	1	;->Emu subroutine to reload INF file
lpt_emu_sethome	rs.l	1	;->Emu subroutine to reset & home screen
lpt_emu_home	rs.l	1	;->Emu subroutine to home screen (top left)
lpt_emu_center	rs.l	1	;->Emu subroutine to center screen
lpt_emu_left	rs.l	1	;->Emu subroutine to pull screen left
lpt_emu_right	rs.l	1	;->Emu subroutine to pull screen right
lpt_emu_up	rs.l	1	;->Emu subroutine to pull screen up
lpt_emu_down	rs.l	1	;->Emu subroutine to pull screen down
lpt_emu_newmode	rs.l	1	;->Emu subroutine to control scroll mode
lpt_emu_recalc	rs.l	1	;->Emu subroutine to recalc display area
;-------------------------------------
; Structures for screen control
;-------------------------------------
lpt_SCD		rs.b	sc_sizeof
lpt_screen_tab	rs.b	sc_sizeof*rezlimit
lpt_sizeof	rs.b	0
;
;----------------------------------------------------------------------------
	ENDC	;ensures single pass 1 inclusion
;----------------------------------------------------------------------------
;End of file:	L_STRUCT.S
;----------------------------------------------------------------------------
