; Author: Benoit 'RATI' Durand and Herve 'Janek' Durand
; Demo Group: Overlanders
; Organization: The Union
; Date (dd/mm/yyyy): 07/10/2023
;
; Type: Main program
;
; Usage:
; . Include (INCLUDE or INCBIN) the source code to integrate in '_source' label in DATA section
;   Note that you can had additional code before/after the INCBIN in case its required (eg. initialising some variables for the integrated routine --> eg. setting the screen address in An)
; . Assemble and Run this code
; . The integrated code is saved in a binary file who's name is defined in '_file_name'
; . You can define whatever line's model you want:
; 	. line's model --> ref _FS_LINE_DEFAULT in data section for instance
; 	. lines_list: pointers to each lines --> default is a fullscreen starting in line 0
;
; Notes:
; . You can define whatever line's model you want:
; 	. it must be defined in the MAIN program
; 	. line's model --> ref _FS_LINE_DEFAULT in data section for instance
; 	. lines_list: pointers to each lines --> default is a fullscreen starting in line 0
; . Your source code must:
; 	. Use linear code --> no multiple paths
; 	. not use registers a0,a1 and d0: they are used by the fullscreen code to switch resolution/frequency.
; 	. Unsupported instructions:
; 	  illegal, trap, link, unlk, reset, stop, rte, rtr, rts, trapv, jsr, jmp, DBcc, bra, bsr, Bcc
; 	. Rotation instructions for which duration is always the same:
; 	   lsr #, lsl #, rol #, ror #, roxl #, roxr #
; 	.  Not supported : lsr Dn, lsl Dn, rol Dn, ror Dn, roxl Dn, roxr Dn
; 	.  Not supported : mulu, muls, divu, divs
; . Notice that 'Prefetch' is not supported by this tool as it uses the trace exception
;
; How does it work:
; . Refer to "FCI.S" library description to get more insights on how that works

; ===========================================================
; Variables section
; ===========================================================

FCI_color_indicators		EQU 	1			; 0 = do not display colors (red, green) when instructions are being analyzed
								; 1 = uses color codes to let know when instruction are being analyzed

; ===========================================================
			SECTION TEXT
; ===========================================================

	opt 	x+

	jmp	_Start						; Go to the real start of the program after includes section

	nop
; ===========================================================
;			SECTION INCLUDES
; ===========================================================

	INCLUDE 	"TOOLS.S"
	INCLUDE 	"FCI.S"

; ===========================================================
			SECTION TEXT
; ===========================================================

		opt	o-

; ------------------------------------------------------
; MACROS
; ------------------------------------------------------

; Display statistics messages
; \1 = value (in BCD) to display --> xyzt (4 decimals digits)
; \2 = message to display
; \3 = position of thousands in the message
_DISPLAY_MSG:	MACRO
	move.b 	\1,d0						; [100-9999] --> d0=xy
	move.b 	d0,d1						; d1=xy
	and.b 	#$0F,d1						; d1=y
	move.b 	d1,\2+\3+1
	add.b 	#'0',\2+\3+1					; converts to ASCII
	lsr.b 	#4,d0						; d0=x
	move.b 	d0,\2+\3
	add.b 	#'0',\2+\3						; converts to ASCII
	move.b 	\1+1,d0						; [0-99] --> d0=zt
	move.b 	d0,d1						; d1=zt
	and.b 	#$0F,d1						; d1=t
	move.b 	d1,\2+\3+3
	add.b 	#'0',\2+\3+3					; converts to ASCII
	lsr.b 	#4,d0						; d0=z
	move.b 	d0,\2+\3+2
	add.b 	#'0',\2+\3+2					; converts to ASCII
	pea 	\2						; points on message to display
	bsr 	TOOLS_DisplayText
	ENDM

; ----------------------------------------------------
; Start routine
; ----------------------------------------------------
_Start:
	; Initialization
	move.l  4(sp),a5              		  		; address to basepage
    	move.l  $0c(a5),d0              			; length of text segment
    	add.l   $14(a5),d0              			; length of data segment
	add.l   $1c(a5),d0              			; length of bss segment
    	add.l   #$1000,d0               			; length of stackpointer
	add.l   #$100,d0                			; length of basepage
	move.l  a5,d1                  				; address to basepage
	add.l   d0,d1                   			; end of program
	and.l   #-2,d1                  			; make address even
	move.l  d1,sp                   			; new stackspace
	move.l  d0,-(sp)                			; mshrink()
	move.l  a5,-(sp)
	move.w  d0,-(sp)
	move.w  #$4a,-(sp)
	trap    #1
	lea 	12(sp),sp

	; Set resolution to med (STf, STe, Mega-STe)
	clr.w	-(a7)
	move.w 	#1,-(a7)
	moveq	#-1,d0
	move.l	d0,-(a7)
	move.l	d0,-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7

	bsr	TOOLS_Super					; Enter Super mode
	bsr	TOOLS_Mouse_Hide				; Hide Mouse pointer
	bsr	TOOLS_Context_Backup				; Backup Context

	; Display a text
	move.w 	#$000,$ffff8246.w				; set text color
	pea 	_Intro_Text
	bsr 	TOOLS_DisplayText

	; Init Fulscreen code generator (FCI)
	bsr 	FCI_Inits

	; Integrate code in _Main
	bsr 	_Main_Prg

	; Restore
	bsr 	FCI_DeInit					; restore Trace/Timer B
	bsr	TOOLS_Context_Restore				; Restore Context
	bsr	TOOLS_Mouse_Show				; Restore mouse pointer
	bsr	TOOLS_Super					; Quit Super mode

	; Quit program
	clr.w	-(sp)
	trap	#1

; ----------------------------------------------------
; Init section
; ----------------------------------------------------

; ----------------------------------------------------
; File section
; ----------------------------------------------------

; Save integrated code to external file --> binary
_save_file:
	; fcreate
	move.w 	#0,-(sp)					; attribute
	pea 	_file_name					; pointer to name of the file to create
	move.w 	#60,-(sp)					; FCREATE
	trap	#1						; GEMDOS
	addq.l 	#8,sp						; corrects stack
	cmp.l 	#0,d0
	blt.s 	.fcreate_error
	move.w 	d0,_file_handle					; store file handle
	; fwrite
	move.l 	FCI_end_generated_code,d0
	sub.l 	#_generated_code,d0				; number of bytes to write to file
	pea	_generated_code					; points on start address of buffer to save from
	move.l	d0,-(sp)					; number of bytes to write
	move.w	_file_handle,-(sp)				; file handle
	move.w 	#64,-(sp)					; FWRITE
	trap	#1						; GEMDOS
	lea 	12(sp),sp					; correct stack
	cmp.l 	#0,d0
	blt.s 	.fwrite_error
	; fclose
	move.w 	_file_handle,-(sp)
	move.w 	#62,-(sp)
	trap 	#1
	addq.l 	#4,sp
	cmp.l 	#0,d0
	blt.s 	.fclose_error
	; display file svaed successfully
	pea 	_Msg_file_saved
	bsr 	TOOLS_DisplayText
	pea 	_file_name
	bsr 	TOOLS_DisplayText
	pea 	_Msg_reset_color
	bsr 	TOOLS_DisplayText
	rts
.fcreate_error:
	pea 	_Msg_error_fcreate
	bsr 	TOOLS_DisplayText
	bsr 	_display_error_code
	rts
.fwrite_error:
	pea 	_Msg_error_fwrite
	bsr 	TOOLS_DisplayText
	bsr 	_display_error_code
	rts
.fclose_error:
	pea 	_Msg_error_fclose
	bsr 	TOOLS_DisplayText
	bsr 	_display_error_code
	rts

; Display error message
; . d0.w=error code
_display_error_code:
	; Search error code in Gemdos_Errors table
	lea 	_GEMDOS_Errors(pc),a0
.search:
	; compare error code
	cmp.w 	(a0)+,d0
	beq.s 	.found
	; pass message if that's not the one
.pass:	tst.b 	(a0)+
	bne.s 	.pass
	bra.s 	.search
.found: pea 	(a0)
	bsr 	TOOLS_DisplayText
	rts

; ----------------------------------------------------
; Interrupt section
; ----------------------------------------------------

; ----------------------------------------------------
; Main Program section
; ----------------------------------------------------

_Main_Prg:
	; Generates the fullscreen code
	lea 	_source,a0					; a0=points on first instruction of the code to integrate
	lea 	_generated_code,a3				; a3=where the code is generated
	move.l 	_lines_list_ptr,a1				; a1=points on list of the lines structures to use for generating the code
	bsr 	FCI_generate_fullscreen_code			; integrate the code into line's models
	; Is there an error due to using an unauthorized instruction
	tst.b 	FCI_unsupported_instruction
	beq.s 	.display_stats
	moveq 	#0,d0
	move.b 	FCI_instID,d0
	add.l 	d0,d0
	add.l 	d0,d0
	lea 	_Unauthorized_Instructions_Msg_ptr,a0
	move.l 	(a0,d0.w),a0					; a0=points on the message refering the unauthorized instruction
	move.l 	a0,-(sp)					; points on message to display
	bsr 	TOOLS_DisplayText
	bra 	.quit
	; Display statistics
.display_stats:
	; . nb analyzed instructions = xyzt
	_DISPLAY_MSG	FCI_nb_analyzed_instructions_bcd,_Msg_nb_instructions,24
	; . nb retained NOPs = xyzt
	_DISPLAY_MSG	FCI_nb_retained_NOPs_bcd,_Msg_nb_retained_NOPs,16
	; . nb NOPs in last line = xyzt
	_DISPLAY_MSG	FCI_nb_NOPs_in_last_line_bcd,_Msg_nb_NOPs_last_line,20
	; . nb fullscreen lines generated = xyzt
	_DISPLAY_MSG	FCI_nb_generated_fullscreen_lines_bcd,_Msg_nb_generated_fullscreen_lines,29
	; Save to file
	bsr 	_save_file
	; In case space bar is pressed, we quit the program
.quit:	pea 	_Msg_Press_Space
	bsr	TOOLS_DisplayText
.wait_space_key:
	cmp.b	#$39,$FFFFFC02.w				; spacebar pressed
;	bne.s	_Main_Prg					; uncomment to watch the time to decode on screen
	bne.s	.wait_space_key
	rts

; ===========================================================
			SECTION DATA
; ===========================================================

; Source for which the full screen code must be generated (INCLUDE or INCBIN)
; Note that you can include some code manually before or after the INCBIN if you want.
; This can be usefull if you want to initialize variables used in your pre generated code (eg. initailizing screen address in a6).
		opt o-
_source
		move.l 		$12345678,a6			; will be replaced by address to ScreenAddress later on via SMC
		lea 		15*230+204(a6),a6		; +204 because of very first line that is not 230 bytes long
		;INCBIN		"draw_09.bin"
		INCLUDE 	"source.s"
		rts						; End Mark - Notice that 'END ' (4 bytes) is also supported
;		dc.b 		"END "				; End mark - Notice that 'RTS' (2 bytes) is also supported
		opt o+

; File where the integrated code is saved --> binary
_file_name	dc.b 		"RESULT.BIN",0
		even
_file_handle	dc.w 		0

; Messages
_Intro_Text:		dc.b 	27,'E',27,'p'
			dc.b 	'********************************************************************************',$D,$A
			dc.b	'*                                                                              *',$D,$A
			dc.b	'*                          FULLSCREEN CODE INTEGRATOR                          *',$D,$A
			dc.b	'*                       by RATI and Janek / Overlanders                        *',$D,$A
			dc.b	'*                                                                              *',$D,$A
			dc.b	'*                              October 7th, 2023                               *',$D,$A
			dc.b	'*                                                                              *',$D,$A
			dc.b 	'*==============================================================================*',$D,$A
			dc.b	'* . #instructions analyzed = number of opcodes analyzed in the source code     *',$D,$A
			dc.b	'* . #retained NOPs = NOPs that could not be replaced by an instruction         *',$D,$A
			dc.b	'* . #NOPs in last line = NOPs following the very last integrated instruction   *',$D,$A
			dc.b	'*                        in the last generated fullscreen line                 *',$D,$A
			dc.b	'* . #fullscreen lines generated = number of scanlines consumed                 *',$D,$A
			dc.b 	'********************************************************************************',$D,$A
			dc.b 	27,'q',$D,$A
			dc.b 	0

			even

_Msg_nb_instructions	dc.b 	'#instructions analyzed: 0000',$D,$A
			dc.b 	0
			even
_Msg_nb_retained_NOPs	dc.b 	'#retained NOPs: 0000',$D,$A
			dc.b 	0
			even
_Msg_nb_NOPs_last_line	dc.b 	'#NOPs in last line: 0000',$D,$A
			dc.b 	0
			even
_Msg_nb_generated_fullscreen_lines
			dc.b 	'#fullscreen lines generated: 0000',$D,$A
			dc.b 	0
			even
_Msg_file_saved		dc.b	27,'b',2,$D,$A,'File saved successfully --> '
			dc.b 	0
			even
_Msg_reset_color	dc.b	27,'b',3,$D,$A
			dc.b 	0
_Msg_Press_Space	dc.b	$D,$A,$D,$A,'                              '
			dc.b 	'Press space to quit'
			dc.b 	0
			even
_Msg_error_fcreate	dc.b	27,'b',1,$D,$A,'File Create error --> '
			dc.b 	0
			even
_Msg_error_fwrite	dc.b	27,'b',1,$D,$A,'File Write error --> '
			dc.b 	0
			even
_Msg_error_fclose	dc.b	27,'b',1,$D,$A,'File Close error --> '
			dc.b 	0
			even
; All Gemdos error --> found in Atari's compendium (can be found in our Tools/Documents folder in our git repository)
; .w: Error code
; .b: Error message
_GEMDOS_Errors:
			dc.w 	-32
			dc.b 	"EINVFN: Invalid function",27,'b',3,$D,$A,0
			dc.w 	-33
			dc.b 	"EFILNF: File not found",27,'b',3,$D,$A,0
			dc.w 	-34
			dc.b 	"EPTHNF: Path not found",27,'b',3,$D,$A,0
			dc.w 	-35
			dc.b 	"ENHNDL: No more handles ",27,'b',3,$D,$A,0
			dc.w 	-36
			dc.b 	"EACCDN: Access denied ",27,'b',3,$D,$A,0
			dc.w 	-37
			dc.b 	"EIHNDL: Invalid handle",27,'b',3,$D,$A,0
			dc.w 	-39
			dc.b 	"ENSMEM: Insufficient memory ",27,'b',3,$D,$A,0
			dc.w 	-40
			dc.b 	"EIMBA: Invalid memory block address ",27,'b',3,$D,$A,0
			dc.w 	-46
			dc.b 	"EDRIVE: Invalid drive specification ",27,'b',3,$D,$A,0
			dc.W 	-48
			dc.b 	"ENSAME: Cross device rename ",27,'b',3,$D,$A,0
			dc.w 	-49
			dc.b 	"ENMFIL: No more files ",27,'b',3,$D,$A,0
			dc.w 	-58
			dc.b 	"ELOCKED: Record is already locked ",27,'b',3,$D,$A,0
			dc.w 	-59
			dc.b 	"ENSLOCK: Invalid lock removal request ",27,'b',3,$D,$A,0
			dc.w 	-64
			dc.b 	"ERANGE or ENAMETOOLONG: Range error ",27,'b',3,$D,$A,0
			dc.w 	-65
			dc.b 	"EINTRN: Internal error",27,'b',3,$D,$A,0
			dc.w 	-66
			dc.b 	"EPLFMT: Invalid program load format ",27,'b',3,$D,$A,0
			dc.w 	-67
			dc.b 	"EGSBF: Memory block growth failure",27,'b',3,$D,$A,0
			dc.w 	-80
			dc.b 	"ELOOP: Too many symbolic links",27,'b',3,$D,$A,0
			dc.w 	-200
			dc.b 	"EMOUNT: Mount point crossed (indicator) ",27,'b',3,$D,$A,0

_Unauthorized_Instructions_Msg_ptr:
			dc.l 	0,0,0,0,0,0,0,0,0
			dc.l 	_Unauth_Inst_09,_Unauth_Inst_10,_Unauth_Inst_11
			dc.l 	_Unauth_Inst_12,_Unauth_Inst_13,_Unauth_Inst_14,_Unauth_Inst_15
			dc.l 	_Unauth_Inst_16,_Unauth_Inst_17,_Unauth_Inst_18,_Unauth_Inst_19
			dc.l 	_Unauth_Inst_20,_Unauth_Inst_21,_Unauth_Inst_22,_Unauth_Inst_23
			dc.l 	_Unauth_Inst_24,_Unauth_Inst_25
_Unauth_Inst_09: 	dc.b 	27,'b',1,$D,$A,"Unauthorized instruction: ILLEGAL",27,'b',3,$D,$A,0
_Unauth_Inst_10: 	dc.b 	27,'b',1,$D,$A,"Unauthorized instruction: TRAP ",27,'b',3,$D,$A,0
_Unauth_Inst_11: 	dc.b 	27,'b',1,$D,$A,"Unauthorized instruction: LINK/UNLK",27,'b',3,$D,$A,0
_Unauth_Inst_12: 	dc.b 	27,'b',1,$D,$A,"Unauthorized instruction: RESET",27,'b',3,$D,$A,0
_Unauth_Inst_13: 	dc.b 	27,'b',1,$D,$A,"Unauthorized instruction: STOP ",27,'b',3,$D,$A,0
_Unauth_Inst_14: 	dc.b 	27,'b',1,$D,$A,"Unauthorized instruction: RTE",27,'b',3,$D,$A,0
_Unauth_Inst_15: 	dc.b 	27,'b',1,$D,$A,"Unauthorized instruction: RTS",27,'b',3,$D,$A,0
_Unauth_Inst_16: 	dc.b 	27,'b',1,$D,$A,"Unauthorized instruction: TRAPV",27,'b',3,$D,$A,0
_Unauth_Inst_17: 	dc.b 	27,'b',1,$D,$A,"Unauthorized instruction: RTR",27,'b',3,$D,$A,0
_Unauth_Inst_18: 	dc.b 	27,'b',1,$D,$A,"Unauthorized instruction: JSR",27,'b',3,$D,$A,0
_Unauth_Inst_19: 	dc.b 	27,'b',1,$D,$A,"Unauthorized instruction: JMP",27,'b',3,$D,$A,0
_Unauth_Inst_20: 	dc.b 	27,'b',1,$D,$A,"Unauthorized instruction: DBcc ",27,'b',3,$D,$A,0
_Unauth_Inst_21: 	dc.b 	27,'b',1,$D,$A,"Unauthorized instruction: BRA",27,'b',3,$D,$A,0
_Unauth_Inst_22: 	dc.b 	27,'b',1,$D,$A,"Unauthorized instruction: BSR",27,'b',3,$D,$A,0
_Unauth_Inst_23: 	dc.b 	27,'b',1,$D,$A,"Unauthorized instruction: Bcc",27,'b',3,$D,$A,0
_Unauth_Inst_24: 	dc.b 	27,'b',1,$D,$A,"Unauthorized instruction: DIVU or DIVS",27,'b',3,$D,$A,0
_Unauth_Inst_25: 	dc.b 	27,'b',1,$D,$A,"Unauthorized instruction: MULU or MULS",27,'b',3,$D,$A,0

; Fullscreen line models to apply for generating code
; 212 x _FS_LINE_DEFAULT
; + 1 x _FS_LINE_BOTTOM_OLD_SHIFTER
; + 15 x _FS_LINE_DEFAULT
; + 1 x _FS_LINE_BOTTOM_NEW_SHIFTER
; + 45 x _FS_LINE_DEFAULT
; + 1 x _FS_LINE_LAST_LINE

; Pointers to lines to insert code in
; Note: you can change the structure of lines (eg. put less feault lines at the top if you want to integrate code that will be executed later in the frame)
_lines_list_ptr	dc.l 	_lines_list
_lines_list
	rept 	212
		dc.l 	_FS_LINE_DEFAULT
	endr
		dc.l 	_FS_LINE_BOTTOM_OLD_SHIFTER
	rept 	15
		dc.l 	_FS_LINE_DEFAULT
	endr
		dc.l 	_FS_LINE_BOTTOM_NEW_SHIFTER
	rept 	45
		dc.l 	_FS_LINE_DEFAULT
	endr
		dc.l 	_FS_LINE_LAST_LINE
	dc.l 	-1

_FS_LINE_DEFAULT:
	; Stabilizer
	move.w	a0,(a1)						; High Rez
	nop
	move.b	d0,(a1)						; Low Rez
	dcb.w	12,$4E71
	; Left
	move.w	a0,(a1)						; High Rez
	nop
	move.b	d0,(a1)						; Low Rez
	dcb.w	89,$4E71
	; Right
	move.b	d0,(a0)						; 60Hz
	move.w	a0,(a0)						; 50Hz
	dcb.w	13,$4E71
	dc.w 	-1						; End Mark

_FS_LINE_BOTTOM_OLD_SHIFTER:
	; Bottom old shifter
	; Stabilizer
	move.w	a0,(a1)						; High Rez
	nop
	move.b	d0,(a1)						; Low Rez
	; Bottom Border
	move.b	d0,(a0)						; 60 Hz
	dcb.w	12-2,$4E71
	; Left
	move.w	a0,(a1)						; High Rez
	nop
	move.b	d0,(a1)						; Low Rez
	; Bottom border : Restore Low Rez
	move.w	a0,(a0)						; 50Hz: bottom removed properly and we're back to 50Hz for 512 cycles lines
	dcb.w	89-2,$4E71
	; Right
	move.b	d0,(a0)						; 60Hz
	move.w	a0,(a0)						; 50Hz
	dcb.w	13,$4E71
	dc.w 	-1						; End Mark

_FS_LINE_BOTTOM_NEW_SHIFTER:
	; Stabilizer
	move.w	a0,(a1)						; High Rez
	nop
	move.b	d0,(a1)						; Low Rez
	; Bottom Border
	move.b	d0,(a0)						; 60 Hz
	dcb.w	12-2,$4E71
	; Left
	move.w	a0,(a1)						; High Rez
	nop
	move.b	d0,(a1)						; Low Rez
	; Bottom border : Restore Low Rez
	move.w	a0,(a0)						; 50Hz: bottom removed properly and we're back to 50Hz for 512 cycles lines
	dcb.w	89-2,$4E71
	; Right
	move.b	d0,(a0)						; 60Hz
	move.w	a0,(a0)						; 50Hz
	dcb.w	13,$4E71
	dc.w 	-1						; End Mark

_FS_LINE_LAST_LINE:
	; Stabilizer
	move.w	a0,(a1)						; High Rez
	nop
	move.b	d0,(a1)						; Low Rez
	dcb.w	12,$4E71
	; Left
	move.w	a0,(a1)						; High Rez
	nop
	move.b	d0,(a1)						; Low Rez
	dcb.w	89,$4E71
	; Right
	move.b	d0,(a0)						; 60Hz
	move.w	a0,(a0)						; 50Hz
	dc.w 	-1						; End Mark

; ===========================================================
			SECTION BSS
; ===========================================================

	even
TOOLS_BkpFA25:		ds.b	1		; MFP_TimerD_Data
TOOLS_BkpFA21:		ds.b	1		; MFP_TimerB_Data
TOOLS_BkpFA1F:		ds.b	1		; MFP_TimerA_Data
TOOLS_BkpFA1D:		ds.b	1		; MFP_TimerC&D_Control
TOOLS_BkpFA1B:		ds.b	1		; MFP_TimerB_Control
TOOLS_BkpFA19:		ds.b	1		; MFP_TimerA_Control
TOOLS_BkpFA17:		ds.b	1		; MFP_VR
TOOLS_BkpFA15:		ds.b	1		; MFP_IMRB
TOOLS_BkpFA13:		ds.b	1		; MFP_IMRA
TOOLS_BkpFA09:		ds.b	1		; MFP_IERB
TOOLS_BkpFA07:		ds.b	1		; MFP_IERA
TOOLS_BkpKeyMode	ds.b 	1		; Keymode
	even
TOOLS_BkpSR:		ds.w	1		; Status Register. Bits 8, 9, 10 fo rmask of interrupt
TOOLS_BkpUSP:		ds.l	1		; User Stack Pointer
TOOLS_BkpUser:		ds.l	1		; Required to come back to non-super
TOOLS_BkpVBL:		ds.l	1		; $70
TOOLS_BkpHBL:		ds.l	1		; $68
TOOLS_BkpTimerD:	ds.l	1		; $110
TOOLS_BkpTimerC:	ds.l	1		; $114
TOOLS_BkpACIA:		ds.l	1		; $118
TOOLS_BkpTimerB:	ds.l	1		; $120
TOOLS_BkpTimerA:	ds.l	1		; $134
TOOLS_BkpFDC:		ds.l	1		; $11C
TOOLS_BkpFA06:		ds.l	1		; MFP
TOOLS_BkpFA00:		ds.w	1		; I/O port du MFP
TOOLS_Bkp820A:		ds.b	1		; Fr�quence de l'�cran - 2=50Hz, 0=60Hz
TOOLS_Bkp8260:		ds.b	1		; R�solution de l'�cran - 0=Low;1=Mid;2=High
TOOLS_BkpColors:	ds.w	16		; 1 word per color and 16 colors
TOOLS_BkpScreenAddress:	ds.l	1		; Screen address. Low byte is always 0
						; (High byte in $FFFF8201, Medium in $FFFF8203, Low byte in $FFFF8205 = $00)
TOOLS_BkpBusError:	ds.l	1		; $8 Bus error vector
TOOLS_BkpAddressError:	ds.l 	1		; $C Address error vector
TOOLS_BkpDivideBy0Error: ds.l	1		; $14 Divide by zero error vector
		; WakeState variables
TOOLS_WakeState:	ds.b	1		; 0=STE, 1=WS1, 2=WS2, 3=WS3, 4=WS4
TOOLS_BkpPSGPortA	ds.b 	1		; PSG Port A
	even
TOOLS_BkpIllegal	ds.l 	1
TOOLS_BkpPrivilege	ds.l 	1
TOOLS_BkpLineA		ds.l 	1
TOOLS_BkpLineF		ds.l 	1
TOOLS_BkpTrap0		ds.l 	1

_generated_code		ds.b 	200000			; space where the code is generated

	END