;
; Copyright 1990-2006 Alexandre Lemaresquier, Raphael Lemoine
;                     Laurent Chemla (Serial support), Daniel Verite (AmigaOS support)
;
; This file is part of Adebug.
;
; Adebug is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; Adebug is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with Adebug; if not, write to the Free Software
; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
;

;  #[ Section Data:
start_of_data:
;	data
	IFNE	AMIGA
	include	"amigdata.s"
	ENDC
;	 #[ accessoire stuff:

 IFNE accessoire
 even
Aes_params:
 dc.l Control
 dc.l Global
 dc.l Int_in
 dc.l Int_out
 dc.l Addr_in
 dc.l Addr_out

adebug_menu: dc.b "  Adebug!   ",0

Gem_appl_init: dc.b 3,$a,0,1,0
Gem_menu_register: dc.b 3,$23,1,1,1
Gem_event_mesage: dc.b 3,$17,0,1,1
Gem_form_alert: dc.b 3,$34,1,1,1
Gem_evnt_multi: dc.b 3,25,16,7,1

form_alert_text: dc.b "[3][ | Not enough memory...][ Exit ]",0
 ELSEIF
form_alert_text:
 IFNE ATARIST
 dc.b	27,'E'
 ENDC ; de ATARIST
 dc.b	"Not enough memory...",13,10,0
 ENDC ; de accessoire
;	 #] accessoire stuff:
;	 #[ Windows:

;	types	of windows: 0=registers
;	1=disassemble
;	2=memory dump
;	3=source file
;	4=no type
;	-1=sleeping window (when reg. window is off)

	even

; 0=curseur interdit, 1=curseur autorise en hexa, -1=curseur autorise en ascii
alt_e_table1:	dc.b 0,0,0,0,0,0,0,0,0,1,1,1,1,0,1,1,1,1,0,0,-1,-1,-1,-1,0,0
alt_e_table2:	dc.b 0,0,0,0,0,0,0,0,0,1,1,0,1,1,1,1,0,1,1,0,-1,-1,-1,-1,0,0
alt_e_table3:	dc.b 0,0,0,0,0,0,0,0,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0
alt_e_table4:	dc.b 0,0,0,0,0,0,0,0,0,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0
alt_e_table5:	dc.b 0,0,0,0,0,0,0,0,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0
alt_e_table6:	dc.b 0,0,0,0,0,0,0,0,0,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0
alt_e_table7:	dc.b 0,0,0,0,0,0,0,0,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,0,-1,-1,-1,-1,-1,-1,-1,-1,0
alt_e_table8:	dc.b 0,0,0,0,0,0,0,0,0,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,0,-1,-1,-1,-1,-1,-1,-1,-1,0
alt_e_table9:
	dc.b 0,0,0,0,0,0,0,0,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,0
	dc.b -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
alt_e_table10:
	dc.b 0,0,0,0,0,0,0,0,0,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,0
	dc.b -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
alt_e_table11:
	dc.b 0,0,0,0,0,0,0,0,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
alt_e_table12:
	dc.b 0,0,0,0,0,0,0,0,0,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

even_reg_window_format_pointer:
 dc.l even_reg_window_format
 dc.l odd_reg_window_format
 dc.l even_reg_window_format2
 dc.l even_reg_window_format2

even_reg_window_format:	dc.b "D%bc:%bc%lx  %lc  A%bc:%bc%lx %[8%x@ %] %lc",0
odd_reg_window_format:	dc.b "D%bc:%bc%lx  %lc  A%bc:%bc%lx %bx@ %[7%x@ %]%bx@ %lc",0

even_reg_window_format2:	dc.b "D%bc:%bc%lx  %lc  A%bc:%bc%lx %s  %lc",0

even_sr_ssp_format:	dc.b "SR:%bc%x %s SSP:%bc%lx %[8%x@ %] %lc",0
odd_sr_ssp_format:	dc.b "SR:%bc%x %s SSP:%bc%lx %bx@ %[7%x@ %]%bx@ %lc",0

pc_format:	dc.b "PC:%bc%lx  %s",0

isp_cacr_format:	dc.b "ISP:%bc%lx        CACR:%bc%lx %s",0
msp_caar_format:	dc.b "MSP:%bc%lx        CAAR:%bc%lx",0
vbr_sfc_dfc_format:	dc.b "VBR:%bc%lx         SFC:%bc%01bx DFC:%bc%01bx",0
pmmu_message_format:	dc.b "%s",0
pmmu_message_text:	dc.b "                                 MMU Registers:",0
mmusr_tc_format:	dc.b "MMUSR:%bc%x %lc%lc   TC:%bc%lx %s",0
tt0_crp_format:		dc.b "TT0:%bc%lx         CRP:%bc%lx%lx %s",0
tt1_srp_format:		dc.b "TT1:%bc%lx         SRP:%bc%lx%lx %s",0
crp_tree_address_text:	dc.b "USER TREE Address: ",0
srp_tree_address_text:	dc.b "SUPER TREE Address: ",0
fpu_message_format:	dc.b "%s",0
fpu_message_text:	dc.b "                                 FPU Registers:",0
fph_fph_format:		dc.b "FP% bc:%bc%lx%lx%lx         FP%bc:%bc%lx%lx%lx",0
fph_fpp_format:		dc.b "FP% bc:%bc%lx%lx%lx         FP%bc:%bc%24p",0
fpp_fph_format:		dc.b "FP% bc:%bc%24p         FP%bc:%bc%lx%lx%lx",0
fpp_fpp_format:		dc.b "FP% bc:%bc%24p         FP%bc:%bc%24p",0
fpsr_fpcr_fpiar_format:	dc.b "FPSR:%bc%lx     FPCR:%bc%wx       FPIAR:%bc%lx",0
 even
fpx_format_table:
 dc.l fph_fph_format
 dc.l fph_fpp_format
 dc.l fpp_fph_format
 dc.l fpp_fpp_format

;  #[ Misc dat:

	IFNE ATARIST
	IFNE ATARITT
misc_dat:
	dc.b 'IPL',0
	dc.b 'SA:',0
	dc.b 'SB:',0
	dc.b 'SC:',0
	dc.b 'SD:',0
	dc.b 'TA:',0
	dc.b 'TB:',0
	dc.b 'TC:',0
	dc.b 'TD:',0
	ELSEIF
misc_dat:
	dc.b 'IPL',0
	dc.b 'MC:',0
	dc.b 'TA:',0
	dc.b 'TB:',0
	dc.b 'TC:',0
	dc.b 'TD:',0
	dc.b 0,0,0,0
	dc.b 0,0,0,0
	dc.b 0,0,0,0
	ENDC	; d'ATARITT
	ENDC	; d'ATARIST
	IFNE AMIGA
misc_dat:
	dc.b 'IPL',0
	dc.b 'INTS'
	dc.b 0,0,0,0
	dc.b 'MC:',0
	dc.b 'AA:',0
	dc.b 'AB:',0
	dc.b 'BA:',0
	dc.b 'BB:',0
	dc.b 0,0,0,0
	ENDC	;d'AMIGA
	IFNE	MAC
misc_dat:
	dc.b 'IPL',0
	dc.b 'MC:',0
	dc.b 'TA:',0
	dc.b 'TB:',0
	dc.b 'TC:',0
	dc.b 'TD:',0
	dc.b 0,0,0,0
	dc.b 0,0,0,0
	dc.b 0,0,0,0
	ENDC	;de MAC
;  #] Misc dat:

;	 #] Windows:
;	 #[ Exception message table:
	EVEN
exception_message_table:
	dc.l	prg_halted_text
	dc.l	pterm_text
	dc.l	bus_error_text
	dc.l	address_error_text
	dc.l	illegal_instruction_text
	dc.l	zero_divide_text
	dc.l	chk_exception_text
	dc.l	trapv_exception_text
	dc.l	privilege_violation_text
	dc.l	traced_text
	dc.l	linea_exception_text
	dc.l	linef_exception_text

	dc.l	r1_exception_text

	dc.l	cp_protocol_violation_text
	dc.l	format_error_exception_text

	dc.l	uninitialized_interrupt_text

	dc.l	r2_exception_text
	dc.l	r3_exception_text
	dc.l	r4_exception_text
	dc.l	r5_exception_text
	dc.l	r6_exception_text
	dc.l	r7_exception_text
	dc.l	r8_exception_text
	dc.l	r9_exception_text

	dc.l	spurious_interrupt_text

	dc.l	ipl_exception_text
	dc.l	ipl_exception_text
	dc.l	ipl_exception_text
	dc.l	ipl_exception_text
	dc.l	ipl_exception_text
	dc.l	ipl_exception_text
	dc.l	ipl_exception_text

	dc.l	trap_exception_text
	dc.l	trap_exception_text
	dc.l	trap_exception_text
	dc.l	trap_exception_text
	dc.l	trap_exception_text
	dc.l	trap_exception_text
	dc.l	trap_exception_text
	dc.l	trap_exception_text
	dc.l	trap_exception_text
	dc.l	trap_exception_text
	dc.l	trap_exception_text
	dc.l	trap_exception_text
	dc.l	trap_exception_text
	dc.l	trap_exception_text
	dc.l	trap_exception_text
	dc.l	trap_exception_text

	dc.l	fpu_branch_text
	dc.l	fpu_config_text
	dc.l	fpu_div0_text
	dc.l	fpu_underflow_text

	dc.l	fpu_operand_text
	dc.l	fpu_overflow_text
	dc.l	fpu_NAN_text
	dc.l	r10_exception_text

	dc.l	pmmu_config_text
	dc.l	pmmu_illegal_text
	dc.l	pmmu_access_text

	dc.l	r11_exception_text
	dc.l	r12_exception_text
	dc.l	r13_exception_text
	dc.l	r14_exception_text
	dc.l	r15_exception_text

	dc.l	0
;	 #] Exception message table:
;	 #[ Preferences tables and miscellaneous tables:
	even

	;marqueur de debut de table
	dc.l	-1
	dc.w	-1
ask_value_table:
	dc.l	ask_tab_text
	dc.w	'ld'
	dc.l	ask_line_len_text
	dc.w	'ld'
	dc.l	ask_def_break_vec_text
	dc.w	'lx'
	dc.l	ask_def_ipl_level_text
	dc.w	'ld'
	dc.l	ask_serial_speed_text
	dc.w	'ld'
	dc.l	ask_serial_parity_text
	dc.w	'lx'
	dc.l	ask_break_nb_text
	dc.w	'ld'
	dc.l	ask_block_nb_text
	dc.w	'ld'
	dc.l	ask_sto_size_text
	dc.w	'ld'
	dc.l	ask_var_size_text
	dc.w	'ld'
	dc.l	ask_la_size_text
	dc.w	'ld'
	dc.l	ask_lr_size_text
	dc.w	'ld'
	dc.l	ask_bl_size_text
	dc.w	'ld'
	dc.l	ask_ex_size_text
	dc.w	'ld'
	dc.l	ask_mac_size_text
	dc.w	'ld'
	dc.l	ask_his_size_text
	dc.w	'ld'
	IFNE	AMIGA
	dc.l	ask_color0_text
	dc.w	'lx'
	dc.l	ask_color1_text
	dc.w	'lx'
	ENDC
	dc.l	0
	dc.w	0

	;marqueur de debut de table
	dc.l	-1
ask_yesno_table:
	dc.l	ask_trace_exceptions_text
	dc.l	ask_reinstall_trace_text
	dc.l	ask_log_ctrla_text
	dc.l	ask_log_trap_text
	dc.l	ask_log_lineaf_text
	dc.l	ask_relative_offset_text
	dc.l	ask_symbols_text
	dc.l	ask_case_sensitive_text
	dc.l	ask_debug_symbols_text
	dc.l	ask_offset_symbols_text
	IFNE	ATARIST
	dc.l	ask_abssym_text
	dc.l	ask_defsym_text
	dc.l	ask_modtime_text
	dc.l	ask_chkcode_text
	dc.l	ask_untilmain_text
	ENDC
	dc.l	ask_line_wrap_text
	dc.l	ask_show_inv_text
	dc.l	ask_save_prinfo_text
	dc.l	ask_inverse_text
	dc.l	ask_real_time_text
	dc.l	ask_real_time_window_text
	dc.l	ask_real_time_lock_text
	dc.l	ask_minitel_text
	dc.l	ask_rs232_output_text
	IFNE	ATARIST
	dc.l	ask_electronic_switch_text
	ENDC
	dc.l	ask_hard_ipl7_text
	IFNE	ATARIST
	dc.l	ask_disk_vectors_text
	ENDC
	dc.l	ask_system_print_text
	dc.l	ask_follow_sr_text
	IFNE	AMIGA
	dc.l	ask_follow_intena_text
	ENDC
	IFNE	ATARIST
	dc.l	ask_catch_div0_text
	dc.l	ask_catch_linef_text
	dc.l	ask_catch_priv_text
	ENDC
	IFNE	AMIGA
	dc.l	ask_multitasking
	dc.l	ask_tasktrap_text
	dc.l	ask_create_sections_labels
	ENDC
	dc.l	ask_profile_text
	dc.l	ask_profclip_text
	dc.l	0

	even
help_vars_table:
	dc.l	help_breaks_text
	dc.l	help_blocks_text
	dc.l	help_sto_text
	dc.l	help_var_text
	dc.l	help_la_text
	dc.l	help_lr_text
	dc.l	help_bl_text
	dc.l	help_ex_text
	dc.l	help_mac_text
	dc.l	help_his_text
	dc.l	0

	IFEQ	cartouche
	SET_ID	PREF_MAGIC
	ENDC

	even
def_pref_values_table:
	dc.l	8	;tab value
	dc.l	255	;ASCII line length
	IFNE	debug
	dc.l	35	;def break vec
	ELSEIF	;debug
	dc.l	32	;def break vec
	ENDC	;debug
	IFNE	ATARIST
	dc.l	3	;def ipl level
	ENDC	;ATARIST
	IFNE	AMIGA
	dc.l	0	;def ipl level
	ENDC	;AMIGA
	dc.l	2	;rs 232 speed
	dc.l	$be	;rs 232 parity (default is 4800 bauds for minitel)
	dc.l	64	;breaks max
	dc.l	30	;blocks max
	dc.l	8	;story:
	dc.l	3000	;VAR
	dc.l	40000	;LA
	dc.l	1000	;lr
	dc.l	15000	;bl
	dc.l	100	;ex
	dc.l	5000	;mac
	dc.l	200	;history
	IFNE	AMIGA
	dc.l	0	;couleur fond
	dc.l	$fff	;couleur premier plan
	ENDC
	dc.l	-1	;fin de la table des values

;flags:
	dc.b	0	;trace exceptions
	dc.b	-1	;reinstall trace
	dc.b	-1	;log_ctrla
	dc.b	-1	;log_ctrlr
	dc.b	0	;log_trapaf
	dc.b	-1	;relative offset
	dc.b	-1	;symbols off/on
	dc.b	-1	;case_sensitive_flag
	dc.b	0	;debug_symbols_flag
	dc.b	-1	;offset_symbols_flag
	IFNE	ATARIST
	dc.b	0	;DRI abs sym
	dc.b	0	;DRI def sym
	dc.b	-1	;check mod time
	dc.b	-1	;check code
	dc.b	-1	;until main
	ENDC
	dc.b	0	;auto line feed
	dc.b	0	;show invisibles
	dc.b	0	;save PRI
	dc.b	-1	;inverse on
	dc.b	-1	;real_time
	dc.b	0	;real_time_window
	dc.b	0	;real_time_lock
	dc.b	-1	;Minitel
	dc.b	0	;RS232 output
	IFNE	ATARIST
	dc.b	0	;electronic switch
	ENDC
	dc.b	-1	;check hard disk ipl7
	IFNE	ATARIST
	dc.b	0	;check disk vectors
	ENDC
	dc.b	-1	;system print
	dc.b	-1	;follow ipl
	IFNE	AMIGA
	dc.b	-1	;follow intena
	ENDC
	IFNE	ATARIST
	dc.b	0	;catch zero divide
	dc.b	0	;catch line f
	dc.b	-1	;catch priv
	ENDC
	IFNE	AMIGA
	dc.b	-1	;trace task
	dc.b	-1	;leave exceptions to trap handler
	dc.b	-1	;create sections labels
	ENDC
	dc.b	-1	;profiler on
	dc.b	0	;profile all symbols
end_pref_table:
	dc.b	1	;fin de la table des flags
PREF_FILE_SIZE	equ	end_pref_table-def_pref_values_table-4

	;preferences + petites pour la version residante
	even
small_pref_values_table:
	dc.l	8	;tab value
	dc.l	255	;ASCII line length
	dc.l	32	;def break vec
	IFNE	ATARIST
	dc.l	3	;def ipl level
	ENDC
	IFNE	AMIGA
	dc.l	0	;def ipl level
	ENDC
	dc.l	2	;rs 232 speed
	dc.l	$be	;rs 232 parity (default is 4800 bauds for minitel)
	dc.l	64	;breaks max
	dc.l	15	;blocks max
	dc.l	8	;story
	dc.l	400	;VAR
	dc.l	4000	;LA
	dc.l	100	;lr
	dc.l	2000	;bl
	dc.l	0	;ex
	dc.l	500	;mac
	dc.l	200	;history
	IFNE	AMIGA
	dc.l	0	;couleur fond
	dc.l	$fff	;couleur premier plan
	ENDC
	dc.l	-1	;fin de la table des values

;flags:
	dc.b	0	;trace exceptions
	dc.b	-1	;reinstall trace
	dc.b	-1	;log_ctrla
	dc.b	-1	;log_ctrlr
	dc.b	0	;log_trapaf
	dc.b	-1	;relative offset
	dc.b	-1	;symbols off/on
	dc.b	-1	;case_sensitive_flag
	dc.b	0	;debug_symbols_flag
	dc.b	0	;offset_symbols_flag
	IFNE	ATARIST
	dc.b	0	;DRI abs sym
	dc.b	0	;DRI def sym
	dc.b	-1	;check mod time
	dc.b	-1	;check code
	dc.b	-1	;until main
	ENDC
	dc.b	0	;auto line feed
	dc.b	0	;show invisibles
	dc.b	0	;save windows
	dc.b	-1	;inverse on
	dc.b	-1	;real_time
	dc.b	0	;real_time_window
	dc.b	0	;real_time_lock
	dc.b	-1	;Minitel
	dc.b	0	;RS232 output
	IFNE	ATARIST
	dc.b	0	;electronic switch
	ENDC
	dc.b	-1	;check hard disk ipl7
	IFNE	ATARIST
	dc.b	0	;check disk vectors
	ENDC
	dc.b	-1	;system print
	dc.b	-1	;follow ipl
	IFNE	AMIGA
	dc.b	-1	;follow intena
	ENDC
	IFNE	ATARIST
	dc.b	0	;catch zero divide
	dc.b	0	;catch line f
	dc.b	0	;catch priv
	ENDC
	IFNE	AMIGA
	dc.b	-1	;trace task
	dc.b	-1	;leave exceptions to trap handler
	dc.b	-1	;create sections labels
	ENDC
	dc.b	-1	;profile on
	dc.b	-1	;profile all symbols

opt_var_table:
	dc.b	'd','D','o',0

	IFEQ	cartouche
	SET_ID	SWIM_MAGIC
	ENDC
exception_routine_text:	dc.b	"Something_Wrong_In_My_System",0

	;debut de pproc_term_table
	dc.b	0,-1
pproc_term_table:
	dc.b	' ',9,13,10
	;fin de pproc_term_table
	dc.b	-1,0
mac_preproc_table:
	;traiter:
	;f F force
	;t T trace
	;p pause
	;s stop
	;r record
	;c <comment>
	;b branch if <expr>
	;l <label>
	dc.b	'f','F','t','T','p','s','r','c','b','l',0
mac_sep_table:	dc.b	';',' ',9
mac_eol_table:	dc.b	13,10,-1,0
	even
ro_magics_table:
	dc.l	'PHYS'
	dc.b	0,-1
	dc.l	'USER'
	IFNE	ATARIST
	dc.b	-1,0
	ENDC
	IFNE	AMIGA
	dc.b	0,-1
	ENDC
	dc.l	'TRAP'
	dc.b	0,-1
	dc.l	'FREE'
	dc.b	0,-1
	dc.l	0

;	 #] Preferences tables and miscellaneous tables:
;	 #[ Messages:
;		#[ Constant expressions:
	IFNE	sourcedebug
src_line_format_text:	dc.b	"% 0ld%c",0
_src_line_format_end:
decimal_format_text:	dc.b	"%=ld",0
	ENDC	;de sourcedebug
two_spaces_text:	dc.b	' '
one_space_text:	dc.b	' ',0
right_arrow_text:	dc.b	3,0
left_arrow_text:	dc.b	4,0
print_result_format_text:	dc.b	" %s.",0
get_expression_format_text:	dc.b	"%bc %s: ",0
menu_format_text:	dc.b	"%bc %s",0
expression_format_text:	dc.b	"$%=lx \%ld %%%0lb %lC",0
expression_low_format_text:	dc.b	"$%=lx \%ld %lC",0
	IFNE	ATARIST
dir_format_text:	dc.b	"%bc%12s % ld",0
	ENDC	;d'ATARIST
	IFNE	AMIGA
dir_format_text:	dc.b	"%bc%32s % ld",0
dir_dir_format_text:	dc.b	"%bc%32s    <dir>",0
	ENDC 	;d'AMIGA
header_format_text:
	IFNE	ATARIST
	dc.b	"%s %0lx % lx (%=ld)",0
mch_fmt_txt:	dc.b	"Atari %s ",0
st_txt:	dc.b	"ST",0
ste_txt:	dc.b	"STe",0
tt_txt:	dc.b	"TT030",0
fa_txt:	dc.b	"Falcon 030",0
nb_txt:	dc.b	"STBook",0
un_txt:	dc.b	"Unknown",0
mste_txt:	dc.b	"Mega STe",0
tos_fmt_txt:	dc.b	"(TOS v%d.%2d) ",0
	ENDC	;d'ATARIST
	IFNE	AMIGA
	dc.b 	"%8s   %0lx   %0lx    %0lx",0
amiga_section_format:	dc.b	"%s%=d",0
	ENDC 	;d'AMIGA
mpu_format_text:	dc.b	"MPU:%=lx (%d.%d MHz) ",0
fpu_format_text:	dc.b	"FPU:%=lx ",0
break_format_text:
	;#,type,v#
	dc.b	"% 4x %bc % bx",0
general_break_format_text:
	;@,instruction
	dc.b	"%0lx %s",0
max_var_format_text:	dc.b	"%s % ld % ld",0
la_format_text:	dc.b	"%s,%=c=$%lx",0
lr_format_text:	dc.b	"%s,%=c=%s",0
bl_format_text:	dc.b	"%s,%=c: sob=$%lx, eob=$%lx, lob=\%ld bytes",0
	IFNE	ATARIST
ex_format_text:	dc.b	"%s,%=c=%bC$%lx ;=$%lx",0
	ENDC
	IFNE	AMIGA
ex_text_format_text: dc.b	"%s,%=c=TEXT%d%bc$%lx ;$%lx",0
ex_data_format_text: dc.b	"%s,%=c=DATA%d%bc$%lx ;$%lx",0
ex_bss_format_text:  dc.b	"%s,%=c=BSS%d%bc$%lx ;$%lx",0
	ENDC

story_format_reg_text:	dc.b	"%0bc : %{%[8%lx %]%}",0
story_format_srssppc_text:	dc.b	"SR: %0x SSP:%lx PC:%lx %s",0
story_number_format:	dc.b	"#%=ld",0
ipl_exception_text:	dc.b	"IPL%=bx",0
trap_exception_text:	dc.b	"Trap #%=bd",0
ask_values_format:	dc.b	"%bc%%=%=wc",0
two_strings_format:	dc.b	"%s"
one_string_format:	dc.b	"%s",0
form_do_filename_format:	dc.b	"; %s",0
editeur_text:	dc.b	"19 bis rue de Cotte F-75012 Paris",0
present_adebug_format:
	IFNE	atarifrance
	dc.b	" Adebug Reloaded v Atari Fr"
	ELSEIF
	IFNE	bridos
	dc.b	" Adebug Reloaded demo v"
	ELSEIF
	IFNE	debug
	dc.b	" Adebug Reloaded debug v"
	ELSEIF
	IFNE	stmag
	dc.b	" Adebug Reloaded stmag v"
	ELSEIF
	IFNE	residant
	dc.b	" Rdebug Reloaded v %=bx.%0bx"
	ELSEIF
	IFNE	cartouche
	dc.b	" Cdebug Reloaded v %=bx.%0bx"
	ELSEIF
	IFNE	diagnostic
	dc.b	" Ddebug Reloaded v %=bx.%0bx"
	ELSEIF
	IFNE	amigarevue
	dc.b	"Adebug Reloaded Amiga Revue"
	ELSEIF
	dc.b	" Adebug Reloaded v %=bx.%0bx"
	ENDC	;de amigarevue
	ENDC	;de diagnostic
	ENDC	;de cartouche
	ENDC	;de residant
	ENDC	;de stmag
	ENDC	;de debug
	ENDC	;de bridos
	ENDC	;de atarifrance
	IFNE	ATARIST!MAC
	dc.b	" ",$bd
	ENDC
	IFNE	AMIGA
	dc.b	" ",$a9
	ENDC
	dc.b	"1990-94 Brainstorm. %s",0
auteurs_text:	dc.b	"All rights reserved.",0
reset_exception_text:	dc.b	"Reset",0
ssw_text:	dc.b	"%s. SSW:%=lc @:%lx Op:%x",0
	IFEQ	_68000
adebug_68030_only_text:
	IFNE	french_text
	dc.b	"Cette version d'Adebug fonctionne uniquement sur 68030.",0
	ELSEIF
	dc.b	"This version of Adebug is 68030 only.",0
	ENDC
	ENDC
	IFEQ	_68030
adebug_68000_only_text:
	IFNE	french_text
	dc.b	"Cette version d'Adebug fonctionne uniquement sur 68000.",0
	ELSEIF
	dc.b	"This version of Adebug is 68000 only.",0
	ENDC
	ENDC
;		#] Constant expressions:
	IFNE	english_text!german_text
;		#[ English messages:
;		#[ Asking messages:
	IFNE	sourcedebug
ask_source_line_nb_text:	dc.b	"Goto line # <#>",0
ask_inspect_text:		dc.b	"Inspect <@>",0
	ENDC	;de sourecdebug
load_prg_vars_text:	dc.b	"Load symbols <f,@>",0
ask_var_file_text:	dc.b	"Load VAR file",0
reserve_from_text:	dc.b	"Restart and reserve from <@>",0
;watchdog_text:	dc.b	"Watchdog <e>",0
ask_system_break_text:	dc.b	"TRAP catch <trap[,func][,aes|vdi][,mode]>",0
call_subroutine_text:	dc.b	"JSR to <@>",0
call_shell_text:	dc.b	"Command",0
ask_any_dir_text:	dc.b	"Selection",0
run_until_text:	dc.b	"Run until <@>",0
jump_to_text:	dc.b	"JMP to <@>",0
	IFEQ bridos
new_variable_text:	dc.b	"Var <name,type=eval>",0
	ENDC
update_sr_text:	dc.b	"Internal IPL <0~7>",0
ask_fill_memory_text:	dc.b	"Fill <s,l,w>",0
ask_copy_memory_text:	dc.b	"Copy <s,l,d>",0
ask_new_addr_text:	dc.b	"Address <@>",0
ask_lock_window_text:	dc.b	"Lock expression <e>",0
ask_break_text:	dc.b	"Break <[@],[e],[0~1][,#]>",0
ask_kill_break_text:	dc.b	"Kill break <#>",0
ask_expression_text:	dc.b	"Expression <e>",0
	IFEQ	bridos
	IFEQ	residant
ask_load_reloc_text:	dc.b	"Load prg <f[,s]>",0
	ENDC	; de residant
ask_load_binary_text:	dc.b	"Load binary <f[,@]>",0
ask_save_binary_text:	dc.b	"Save binary <f,s,l>",0
ask_load_source_text:	dc.b	"Load ASCII <f>",0
ask_save_text:	dc.b	"Save <f>",0
ask_load_mac_text:	dc.b	"Load MAC file <f>",0
print_bloc_address_text:	dc.b	"Disassemble <s,l>",0
print_bloc_labels_text:	dc.b	"Labels buffer <@>",0
	ENDC	; de bridos
ask_cd_text:	dc.b	"New directory <p>",0
ask_search2_text:	dc.b	"Search <e>",0
ask_even_aligned_search:	dc.b	"Word aligned",0
ask_catch_exceptions2_text:	dc.b	"Exception # to catch <2~3F>",0
trace_until_text:	dc.b	"Until <e>",0
trace_instruc_text:	dc.b	"Instruction <i>",0
	IFNE	debug
monkeytest_text:	dc.b	"Monkey test azertyuiopqsdfghjklmwxcvbn,;AZERTYUIOPQSDFGHJKLMWXCVBN?",0
	ENDC
;		#] Asking messages:
;		#[ Menus messages:
menu_output_to_text:	dc.b	"Output to S)creen R)S232",0
menu_print_bloc_text:	dc.b	"Print to D)isk P)rinter",0
menu_trace_text:	dc.b	"Trace U)ntil I)nstruction S)low 6)8020",0
menu_search_text:	dc.b	"Search B)yte W)ord L)ong A)scii I)nst.",0
menu_mac_text:	dc.b	"Macro R)ecord P)lay L)oad W)atch",0
menu_rec_mac_text:	dc.b	"R)ecord T)race B)ack S)kip C)lr",0
menu_play_mac_text:	dc.b	"P)lay T)race B)ack S)kip W)atch H)ome",0
menu_manual_prinfo_text:	dc.b	"L)oad S)ave PRogram Info",0
;menu_timer_text:	dc.b	"Timer A) B) C) D)",0
;menu_frequency_text:	dc.b	"M)ode:C. I)cr: YYYY. T)cr: $00|$00->$0000 Hz. S)et C)alc frequency.",0
;		#] Menus messages:
;		#[ Yes/no messages:
yesno_format_text:	dc.b	"%bc %s? Y)es/N)o",0
kill_all_var_text:	dc.b	"Kill all VAR(s)",0
continue_text:	dc.b	"Continue play",0
disk_pb_text:	dc.b	"Disk vectors may be damaged. Continue",0
new_var_reset_text:	dc.b	"Var %s already exists. Reset it",0
kill_all_text:	dc.b	"Kill all breakpoints",0
watch_text:	dc.b	"Watch",0
keep_registers_text:	dc.b	"Keep registers",0
restore_registers_text:	dc.b	"Restore registers",0
catch_exceptions_text:	dc.b	"Catch all exceptions",0

;		#] Yes/no messages:
;		#[ Result messages:
	IFNE	switching_debug
fasttrace_text:	dc.b	"Fast trace",0
break_emulated_text:	dc.b	"Returned from break emulation",0
emulating_break_text:	dc.b	"Break will be emulated",0
emulating_dbcc_text:	dc.b	"Dbcc will be emulated",0
emulating_trap_lineaf_text:	dc.b	"Trap Linea-f will be emulated",0
continue_from_p1p0_text:	dc.b	"Continuing from p1p0",0
justonce_text:	dc.b	"Emulating justonce in trace",0
return_fromp0p1_top0p1:	dc.b	"Return from p0p1 to p0p1",0
rombreak_emulated_text:	dc.b	"Rom break will be emulated",0
break_evaluated_text:	dc.b	"Break evaluated",0
break_removed_text:	dc.b	"Break removed",0
instr_type_text:	dc.b	"Instr type:%=bd",0
trace_on_permanent_text:	dc.b	"Trace on permanent breakpoint",0
;out_of_service_text:	dc.b	"Temporarily out of service",0
	ENDC	;de switching_debug
	IFNE	ATARIST
shell_result_text:	dc.b	"Shell result: %=d",0
	ENDC
prg_vars_loaded_text:	dc.b	"%=ld symbols loaded in file <%s>",0
profiler_reset_text:	dc.b	"Profiler reset",0
not_implemented_wtype_text:	dc.b	"Not implemented window type",0
search_found_text:	dc.b	"Found",0
search_not_found_text:	dc.b	"Not found",0
;ask_for_function_text:	dc.b	"Waiting for function",0
;F1
mark_set_text:	dc.b	"Mark set",0
;F2
mark_exchanged_text:	dc.b	"Mark exchanged",0
;F3
;block_cancelled_text:	dc.b	"Block cancelled",0
;F4
;block_copied_text:	dc.b	"Block copied",0
;F5
;block_pasted_text:	dc.b	"Block pasted",0
loading_file_text:	dc.b	"Loading file <%s>",0
file_loaded_text:	dc.b	"File <%s> loaded in %=ld bytes",0
	IFEQ	bridos
saving_file_text:	dc.b	"Saving file <%s>",0
file_saved_text:	dc.b	"File <%s> saved in %=ld/%ld bytes",0
file_saved2_text:	dc.b	"File <%s> saved",0
disk_full_text:	dc.b	"Disk full while saving <%s>",0
	ENDC	; de bridos
prt_finished_text:	dc.b 	"Print completed",0
rm_var_text:	dc.b	"Var %s removed",0
new_var_set_text:	dc.b	"Var %s set",0
exceptions_catched_text:	dc.b	"Exceptions caught",0
breaks_killed_text:	dc.b	"Killed all breakpoints",0
copy_done_text:	dc.b	"Memory copy completed",0
fill_done_text:	dc.b	"Memory fill completed",0
sr_updated_text:	dc.b	"Internal IPL set to %=d",0
free_memory_text:	dc.b	"Free memory: ",0
free_1_memory_text:	dc.b	"%s\%=ld bytes",0
free_2_memory_text:	dc.b	"%sBoth: \%=ld, Slow: \%=ld, Fast: \%=ld bytes",0
registers_kept_text:	dc.b	"Registers kept",0
registers_restored_text:	dc.b	"Registers restored",0
break_reach_text:	dc.b	"Breakpoint #%=lx reached",0
print_break_set_unset_format:	dc.b	"Breakpoint #%=lx %s",0
catch_all_funcs_text:	dc.b	"Will catch all functions of Trap $%=bx (%s)",0
catch_one_func_text:	dc.b	"Will catch function $%=x (%s) of Trap $%bx (%s)",0
set_text:	dc.b	"set",0
killed_text:	dc.b	"killed",0
skipped_text:	dc.b	"Skipped",0
ctrl_r_text:	dc.b	"Running..",0
dsetpath_done_text:	dc.b	"Current path changed",0
current_path_text:	dc.b	"Current path: %s",0
search_text:	dc.b	"Searching..",0
mac_play_stopped_text:	dc.b	"Macro stopped",0
;mac_ended_text:	dc.b	"End of macro",0
mac_rec_text:	dc.b	"Recording macro..",0
mac_play_text:	dc.b	"Playing macro..",0
mac_rec_ended_text:	dc.b	"Record ended",0
mac_cleared_text:	dc.b	"Macro cleared",0
mac_play_home_text:	dc.b	"Macro pointer reset to start",0
output_to_screen_text:	dc.b	"Switched to screen output",0
output_to_rs232_text:	dc.b	"Switched to serial output",0
rs232_switching_text:	dc.b	"Switching to serial output..",0
waiting_high_text:	dc.b	"Switching to monochrome..",0
waiting_med_text:	dc.b	"Switching to color..",0
low_rez_text:	dc.b	"Low resolution",0
mid_rez_text:	dc.b	"Med resolution",0
high_rez_text:	dc.b	"High resolution",0

var_loaded_text:	dc.b	"%=ld Var(s),%ld line(s),%ld error(s)",0
page_nb_text:	dc.b	" ;page #%=ld",0
;		#] Result messages:
;		#[ Present messages:
present_breaks_text:	dc.b	"   # T  V Info",0
present_story_text:	dc.b	"       0        1        2        3        4        5        6        7",0
present_infos_text:	dc.b	"%s informations",0
present_internal_text:	dc.b	"Internal",0
name_text:	dc.b	"Name:   ",0
maximum_text:	dc.b	"Maximum:",0
current_text:	dc.b	"Current:",0
help_breaks_text:	dc.b	" BREAK#",0
help_blocks_text:	dc.b	" BLOCK#",0
help_sto_text:	dc.b	" STORY#",0
help_var_text:	dc.b	"  VARS#",0
help_la_text:	dc.b	"     LA",0
help_lr_text:	dc.b	"     LR",0
help_bl_text:	dc.b	"     BL",0
help_ex_text:	dc.b	"     EX",0
help_mac_text:	dc.b	"  MACRO",0
help_his_text:	dc.b	" HISTRY",0
static_number_format:	dc.b	"% 7ld",0
start_end_format:	dc.b	"Starting: $%0lx, Ending: $%lx",0
present_sys_text:	dc.b	"System",0
;screenbase_text:	dc.b	"SCREEN: $%lx ",0
	IFNE	ATARIST
;resolution_text:	dc.b	"RES: %%%03b ",0
	ENDC
present_soft_text:	dc.b	"Program",0
present_exec_name_text:	dc.b	"Loaded program: %s, %=ld symbols, cmd:%s.",0
	IFNE	sourcedebug
present_source_name_text:	dc.b	"Current module: %s, %=ld lines, %ld bytes",0
present_stack_text:	dc.b	"Stack dump",0
source_stack_format:	dc.b	"%s, %s, #%=ld",0
	ENDC	;de sourcedebug
	IFNE	ATARIST
present_reloc_text:
	dc.b	"Name Address  Length",0
	ENDC	;d'ATARIST
	IFNE	_68030
present_frame_text:	dc.b	"Stack frame type $%01bx info on vector $%bx (%s)",0
offset_stack_text:	dc.b	"<offset $%02x>",0
sr_stack_text:	dc.b	"SR: %0x %s",0
pc_stack_text:	dc.b	"PC: $%0lx %s",0
instr_address_stack_text:	dc.b	"Instruction address: $%0lx",0
effective_address_stack_text:	dc.b	"Effective address: $%0lx",0
internal_reg_stack_text:	dc.b	"Internal register %=d: $%0x",0
long_internal_reg_stack_text:	dc.b	"Internal register %=d: $%0lx",0
ssr_stack_text:
	;	CCFRWSD
	;	BBRWLUP
	;	--.MB.I
	dc.b	"SSR: %lc%bc%c = %%%0wb",0
stage_pipe_stack_text:	dc.b	"Stage %bc pipe: $%0x",0
fault_add_stack_text:	dc.b	"Data cycle fault address: $%0lx",0
data_outbuff_stack_text:	dc.b	"Data output buffer: $%0lx",0
stage_b_add_stack_text:	dc.b	"Stage B address: $%0lx",0
data_inbuff_stack_text:	dc.b	"Data input buffer: $%0lx",0
version_stack_text:	dc.b	"Version #: $%01x",0
	ENDC
;		#] Present messages:
;		#[ Error messages:
;		#[	System error messages:
	even
	IFNE	ATARIST
system_messages_table:
	dc.l	system_m0
	dc.l	system_m1
	dc.l	system_m2
	dc.l	system_m3
	dc.l	system_m4
	dc.l	system_m5
	dc.l	system_m6
	dc.l	system_m7
	dc.l	system_m8
	dc.l	system_m9
	dc.l	system_m10
	dc.l	system_m11
	dc.l	system_m12
	dc.l	system_m13
	dc.l	system_m14
	dc.l	system_m15
	dc.l	system_m16
	dc.l	system_m17

	dc.l	system_unknown	;-18
	dc.l	system_unknown	;-19
	dc.l	system_unknown	;-20
	dc.l	system_unknown	;-21
	dc.l	system_unknown	;-22
	dc.l	system_unknown	;-23
	dc.l	system_unknown	;-24
	dc.l	system_unknown	;-25
	dc.l	system_unknown	;-26
	dc.l	system_unknown	;-27
	dc.l	system_unknown	;-28
	dc.l	system_unknown	;-29
	dc.l	system_unknown	;-30
	dc.l	system_unknown	;-31

	dc.l	system_m32
	dc.l	system_m33
	dc.l	system_m34
	dc.l	system_m35
	dc.l	system_m36
	dc.l	system_m37
	dc.l	system_unknown	;-38
	dc.l	memory_error_text	;-39
	dc.l	system_m40
	dc.l	memory_error_text	;-41
	dc.l	memory_error_text	;-42
	dc.l	system_unknown	;-43
	dc.l	system_unknown	;-44
	dc.l	system_unknown	;-45
	dc.l	system_m46
	dc.l	system_m47
	dc.l	system_unknown	;-48
	dc.l	system_m49
	dc.l	system_unknown	;-50
	dc.l	system_unknown	;-51
	dc.l	system_unknown	;-52
	dc.l	system_unknown	;-53
	dc.l	system_unknown	;-54
	dc.l	system_unknown	;-55
	dc.l	system_unknown	;-56
	dc.l	system_unknown	;-57
	dc.l	system_unknown	;-58
	dc.l	system_unknown	;-59
	dc.l	system_unknown	;-60
	dc.l	system_unknown	;-61
	dc.l	system_unknown	;-62
	dc.l	system_unknown	;-63
	dc.l	system_m64
	dc.l	system_m65
	dc.l	system_m66
	dc.l	system_m67

system_m0:	dc.b	"Ok",0
system_m1:	dc.b	"System error",0
system_m2:	dc.b	"Drive not ready",0
system_m3:	dc.b	"Unknown command",0
system_m4:	dc.b	"CRC error",0
system_m5:	dc.b	"Bad request",0
system_m6:	dc.b	"Seek error",0
system_m7:	dc.b	"Unknown media",0
system_m8:	dc.b	"Sector not found",0
system_m9:	dc.b	"No paper",0
system_m10:	dc.b	"Write fault",0
system_m11:	dc.b	"Read fault",0
system_m12:	dc.b	"General mishap",0
system_m13:	dc.b	"Write protect",0
system_m14:	dc.b	"Media change",0
system_m15:	dc.b	"Unknown device",0
system_m16:	dc.b	"Bad sectors",0
system_m17:	dc.b	"Insert disk",0
system_m32:	dc.b	"Invalid function number",0
system_m33:	dc.b	"File not found",0
system_m34:	dc.b	"Path not found",0
system_m35:	dc.b	"No handles left",0
system_m36:	dc.b	"Access denied",0
system_m37:	dc.b	"Invalid handle",0

system_m40:	dc.b	"Invalid memory block address",0
system_m46:	dc.b	"Invalid drive specified",0
system_m47:	dc.b	"Invalid operation",0
system_m49:	dc.b	"No more files",0
system_m64:	dc.b	"Range error",0
system_m65:	dc.b	"Gemdos internal error",0
system_m66:	dc.b	"Invalid program load format",0
system_m67:	dc.b	"Setblock failure due to growth restrictions",0
	ENDC	; de ATARIST
;		#]	System error messages:
no_shell_error_text:	dc.b	"No shell",0
shell_general_error:	dc.b	"Shell general error",0
	IFNE	ATARIST 
rdebug_already_installed_text:	dc.b	27,"ERdebug already installed. Press a key.",0
vbl_error_text:	dc.b	"No more space in vblqueue",0
	ENDC
reload_prg_error_text:	dc.b	"There is already one program loaded",0
system_unknown:	dc.b	"Unknown system error code number",0
option_forbid_textf:	dc.b	"Unknown option:-%bc",0
fatal_memory_error_text:	dc.b	"FATAL memory error in config file",0
internal_error_text:	dc.b	"Internal error #%=bx Offset %lx",0
bad_magic_file_error_text:	dc.b	"File may be corrupted",0
bad_version_file_error_text:	dc.b	"This version of ADEBUG cannot use this file",0

no_story_error_text:	dc.b	"No instructions recorded",0
prt_not_ready_text:	dc.b 	"Printer not ready",0
alt_e_error_text:	dc.b	"Memory not readable",0
copy_done_2_text:	dc.b	"Warning! Couldn't copy all",0
fill_done_2_text:	dc.b	"Warning! Couldn't fill all",0
sctrl_areg_error_text:	dc.b	"Odd or unreadable address",0
;syntax_error_text:	dc.b	"Syntax error",0
restore_registers_error_text:	dc.b	"No registers kept",0
no_next_text:	dc.b	"Search not set",0

print_bloc_error_text: 	dc.b	"Bad buffer address",0
print_bloc_text:	dc.b	"Disk error",0
	IFNE	ATARIST
acia_ikbd_error_text:	dc.b	"No hard disk operation allowed in IPL>5",0
	ENDC
dgetpath_error_text:
dsetpath_error_text:	dc.b	"Invalid path",0
fnf_error_text:	dc.b	"File <%s> not found",0
read_error_text:	dc.b	"Read error #%=d in file <%s>",0
seek_error_text:	dc.b	"Seek error #%=d in file <%s>",0
	IFEQ	bridos
create_error_text:	dc.b	"Create error",0
write_error_text:	dc.b	"Write error #%=d in file <%s>",0
write_error2_text:	dc.b	"Write error",0
;close_error_text:	dc.b	"Close error",0
executable_error_text:	dc.b	"Not an executable file",0
reloc_error_text:	dc.b	"Relocation error",0
unknown_sym_error_text:	dc.b	"Unknown symbols type",0
;ascii_error_text:	dc.b	"Not an ascii file",0
	ENDC	;de bridos
memory_error_text:	dc.b	"Memory error",0

	;--- BREAKPOINTS ---
no_breaks_error_text:	dc.b	"No breakpoints",0
break_general_error_text:	dc.b	"Cannot set breakpoint",0
break_full_error_text:	dc.b	"No more breakpoint",0
break_address_error_text:	dc.b	"Bad breakpoint address",0
break_vector_error_text:	dc.b	"Bad breakpoint vector number",0
break_bad_eval_error_text:	dc.b	"Bad breakpoint eval",0
break_bad_number_error_text:	dc.b	"Bad breakpoint number",0
break_eval_full_error_text:	dc.b	"Breakpoint eval buffer full",0

	;--- CONTEXT SWITCHING ---
bad_run_until_eval_text:	dc.b	"Bad eval in Trace Until",0
bad_stack_error_text:	dc.b	"Bad stack for tracing",0
bad_pc_error_text:	dc.b	"Odd or unreadable pc",0
unknown_tasking_text:	dc.b	"Uninitialised switching event",0

	;--- MACROS ---
preproc_error_text:	dc.b	"Unknown MAC directive",0
mac_memory_error_text:	dc.b	"MAC buffer full",0
no_mac_error_text:	dc.b	"No MAC",0
missing_back_text:	dc.b	"Missing ` in macro",0
fnf_mac_error_text:	dc.b	"Unknown function",0

	;--- VARIABLES ---
no_vars_error_text:	dc.b	"No VAR",0
var_full_text:	dc.b	"VAR buffer full",0
la_full_text:	dc.b	"LA buffer full",0
lr_full_text:	dc.b	"LR buffer full",0
bl_full_text:	dc.b	"BL buffer full",0
syntax_error_var_text:	dc.b	"Error #%=bd,VAR %ld,line %ld:%s",0
blnf_error_text:	dc.b	"%c <%s> not found",0
press_key_text:	dc.b	". Press a key",0
debug2_var_format:	dc.b	"VAR %=ld,line %ld,%ld error(s):%s",0
;		#] Error messages:
;		#[ Exception messages:
prg_halted_text:	dc.b	"Program halted",0
pterm_text:	dc.b	"Program ended. Result: $%=lx \%ld %%%0lb %lC",0
bus_error_text:	dc.b	"Bus error",0
address_error_text:	dc.b	"Odd @ error",0
illegal_instruction_text:	dc.b	"Illegal instruction",0
zero_divide_text:	dc.b	"Zero divide",0
	IFNE	_68020!_68030!68040
chk_exception_text:	dc.b	"CHK or CHK2",0
trapv_exception_text:	dc.b	"TRAPV, TRAPcc or FTRAPcc",0
	ELSEIF
chk_exception_text:	dc.b	"CHK",0
trapv_exception_text:	dc.b	"TRAPV",0
	ENDC	; de _68020!30!40
privilege_violation_text:	dc.b	"Privilege violation",0
traced_text:	dc.b	"Trace exception",0
traced2_text:	dc.b	"Traced",0
traced3_text:	dc.b	"Trace interrupted",0
ctrla_text:	dc.b	"Run and break",0
faux_ctrla_text:	dc.b	"Exception emulated",0
linea_exception_text:	dc.b	"Line 1010 emulator (line A)",0
linef_exception_text:	dc.b	"Line 1111 emulator (line F)",0

r1_exception_text:	dc.b	"R1",0

cp_protocol_violation_text:	dc.b	"Coprocessor protocol violation",0
format_error_exception_text:	dc.b	"Format error",0
uninitialized_interrupt_text:	dc.b	"Uninitialized interrupt",0

r2_exception_text:	dc.b	"R2",0
r3_exception_text:  	dc.b	"R3",0
r4_exception_text:	dc.b	"R4",0
r5_exception_text:	dc.b	"R5",0
r6_exception_text:	dc.b	"R6",0
r7_exception_text:	dc.b	"R7",0
r8_exception_text:	dc.b	"R8",0
r9_exception_text:	dc.b	"R9",0

spurious_interrupt_text:	dc.b	"Spurious interrupt",0

fpu_branch_text:	dc.b	"FPU branch or set on unordered condition",0
fpu_config_text:	dc.b	"FPU inexact result",0
fpu_div0_text:	dc.b	"FPU divide by zero",0
fpu_underflow_text:	dc.b	"FPU underflow",0

fpu_operand_text:	dc.b	"FPU operand error",0
fpu_overflow_text:	dc.b	"FPU overflow",0
fpu_NAN_text:	dc.b	"FPU signaling NAN",0
r10_exception_text:	dc.b	"RA",0


pmmu_config_text:	dc.b	"PMMU configuration error",0
pmmu_illegal_text:	dc.b	"PMMU illegal operation",0
pmmu_access_text:	dc.b	"PMMU access level",0

r11_exception_text:	dc.b	"RB",0
r12_exception_text:	dc.b	"RC",0
r13_exception_text:	dc.b	"RD",0
r14_exception_text:	dc.b	"RE",0
r15_exception_text:	dc.b	"RF",0

user_vector_format_text:	dc.b	"User vector $%=x",0
;		#] Exception messages:
;		#[ Preferences stuff:
	;VALUES
ask_tab_text:	dc.b	"Tab value",0
ask_lensym_text:	dc.b	"Symbol length",0
ask_line_len_text:	dc.b	"Maximum ASCII line length",0
ask_def_break_vec_text:	dc.b	"VEC #",0
ask_def_ipl_level_text:	dc.b	"Default internal IPL",0
ask_serial_speed_text:	dc.b	"Serial port speed",0
ask_serial_parity_text:	dc.b	"Serial port parity",0
ask_break_nb_text:	dc.b	"Maximum breaks number",0
ask_block_nb_text:	dc.b	"Maximum blocks number",0
ask_sto_size_text:	dc.b	"STO number",0
ask_var_size_text:	dc.b	"VAR number",0
ask_la_size_text:	dc.b	"LA size",0
ask_lr_size_text:	dc.b	"LR size",0
ask_bl_size_text:	dc.b	"BL size",0
ask_ex_size_text:	dc.b	"EX size",0
ask_mac_size_text:	dc.b	"MAC size",0
ask_his_size_text:	dc.b	"HIS size",0

	;ASCII
;ask_def_break_eval_text:	dc.b	"Default break eval",0

	;FLAGS
ask_trace_exceptions_text:	dc.b	"Trace exceptions",0
ask_reinstall_trace_text:	dc.b	"Reinstall trace",0
ask_log_ctrla_text:	dc.b	"See logic screen in [Ctrl_A]",0
ask_log_trap_text:	dc.b	"See logic screen in [Ctrl_R]",0
ask_log_lineaf_text:	dc.b	"See logic screen in Trap & Line A/F",0
ask_relative_offset_text:	dc.b	"Relative register offset",0
ask_symbols_text:	dc.b	"Display symbols",0
ask_case_sensitive_text:	dc.b	"Symbols case sensitive",0
ask_debug_symbols_text:	dc.b	"Debug symbols only",0
ask_offset_symbols_text:	dc.b	"Display symbol+offset",0
ask_line_wrap_text:	dc.b	"ASCII line wrap",0
ask_show_inv_text:	dc.b	"Show ASCII invisibles",0
ask_save_prinfo_text:	dc.b	"Save program info",0
ask_inverse_text:	dc.b	"Inverse video",0
ask_real_time_text:	dc.b	"Real time",0
ask_real_time_window_text:	dc.b	"Real time only in current window",0
ask_real_time_lock_text:	dc.b	"Real time lock",0
ask_minitel_text:	dc.b	"Minitel",0
ask_rs232_output_text:	dc.b	"Default serial output",0
ask_system_print_text:	dc.b	"System print",0
ask_follow_sr_text:	dc.b	"Follow IPL",0
	IFNE	ATARIST
ask_abssym_text:	dc.b	"Load absolute DRI symbols",0
ask_defsym_text:	dc.b	"Load undefined DRI symbols",0
ask_modtime_text:	dc.b	"Check module time/date",0
ask_chkcode_text:	dc.b	"Display code marks in source",0
ask_untilmain_text:	dc.b	"Run until main at load",0
ask_electronic_switch_text:	dc.b	"Electronic switch",0
ask_hard_ipl7_text:	dc.b	"Forbid hard disk use in IPL>5",0
ask_disk_vectors_text:	dc.b	"Check disk vectors",0
ask_catch_div0_text:	dc.b	"Catch Zero divide",0
ask_catch_linef_text:	dc.b	"Catch Line F",0
ask_catch_priv_text:	dc.b	"Catch Privilege violation",0
	ENDC
	IFNE	AMIGA
ask_multitasking:	dc.b	"Debug program as a separate task",0
ask_create_sections_labels: dc.b "Create labels at beginning of sections",0
ask_color0_text:	dc.b	"Background color",0
ask_color1_text:	dc.b 	"Foreground color",0
ask_follow_intena_text:	dc.b	"Follow Intena",0
ask_hard_ipl7_text:	dc.b	"Forbid disk use in IPL>0 or low Intena",0
ask_tasktrap_text:	dc.b	"Leave exceptions to trap handler when present",0
	ENDC
ask_profile_text:	dc.b	"Profiler on",0
ask_profclip_text:	dc.b	"Profile all symbols",0
	IFEQ	bridos
ask_savep_text:	dc.b	"Save preferences",0
	ENDC	;de bridos
;		#] Preferences stuff:
;		#[ Title messages:
frame_title_text:	dc.b	"STACK FRAMES",0
;help_title_text:	dc.b	"MISCELLANEOUS INFORMATIONS",0
help_title_text:	dc.b	"HELP",0
breaks_title_text:	dc.b	"BREAKPOINTS",0
vars_title_text:	dc.b	"VARIABLES",0
story_title_text:	dc.b	"STORY",0
macro_title_text:	dc.b	"MACRO",0
	IFNE	sourcedebug
stack_title_text:	dc.b	"STACK DUMP",0
	ENDC	;de sourcedebug
	IFNE	ATARIST
traps_title_text:	dc.b	"AES/VDI NAMES",0
	ENDC	;d'ATARIST
	IFNE	AMIGA
task_title_text:	dc.b	"TASKS",0
	ENDC
;		#] Title messages:
;		#] English messages:
	ENDC	;de english_text
	IFNE	french_text
;		#[ French messages:
;		#[ Asking messages:
	IFNE	sourcedebug
ask_source_line_nb_text:	dc.b	"Ligne # <#>",0
ask_inspect_text:		dc.b	"Inspecte <@>",0
	ENDC	;de sourcedebug
load_prg_vars_text:	dc.b	"Charger symboles <f,@>",0
ask_var_file_text:	dc.b	"Charger fichier VAR",0
reserve_from_text:	dc.b	"Red‚marrer et r‚server de <@>",0
ask_system_break_text:	dc.b	"TRAP catch <trap[,func][,aes|vdi][,mode]>",0
call_subroutine_text:	dc.b	"JSR … <@>",0
call_shell_text:	dc.b	"Commande",0
ask_any_dir_text:	dc.b	"S‚lection",0
run_until_text:	dc.b	"Lancer jusqu'… <@>",0
jump_to_text:	dc.b	"JMP … <@>",0
	IFEQ	bridos
new_variable_text:	dc.b	"Var <nom,type=eval>",0
	ENDC
update_sr_text:	dc.b	"IPL interne <0~7>",0
ask_fill_memory_text:	dc.b	"Remplir <s,l,a>",0
ask_copy_memory_text:	dc.b	"Copier <s,l,d>",0
ask_new_addr_text:	dc.b	"Adresse <@>",0
ask_lock_window_text:	dc.b	"Lier … <e>",0
ask_break_text:	dc.b	"Point d'arrˆt <[@],[e],[0~1][,#]>",0
ask_kill_break_text:	dc.b	"Enlever point d'arrˆt <#>",0
ask_expression_text:	dc.b	"Expression <e>",0
	IFEQ	bridos
	IFEQ	residant
ask_load_reloc_text:	dc.b	"Charger prg <f[,s]>",0
	ENDC	;de residant
ask_load_binary_text:	dc.b	"Charger binaire <f[,@]>",0
ask_save_binary_text:	dc.b	"Sauver binaire <f,s,l>",0
ask_load_source_text:	dc.b	"Charger ASCII <f>",0
ask_save_text:	dc.b	"Sauver <f>",0
ask_load_mac_text:	dc.b	"Charger fichier MAC <f>",0
print_bloc_address_text:	dc.b	"D‚sassembler <s,l>",0
print_bloc_labels_text:	dc.b	"Tampon d'‚tiquettes <@>",0
	ENDC	;de bridos
ask_cd_text:	dc.b	"Nouveau r‚pertoire <d>",0
ask_search2_text:	dc.b	"Chercher <e>",0
ask_even_aligned_search:	dc.b	"Align‚ au mot",0
ask_catch_exceptions2_text:	dc.b	"Nø d'exception … d‚tourner <2~63>",0
trace_until_text:	dc.b	"Jusqu'… <e>",0
trace_instruc_text:	dc.b	"Instruction <s>",0
;		#] Asking messages:
;		#[ Menus messages:
menu_output_to_text:	dc.b	"Sortie sur E)cran R)S232",0
menu_print_bloc_text:	dc.b	"D‚sassembler sur D)isque I)mprimante",0
menu_trace_text:	dc.b	"Trace J)usqu'… I)nstruction R)ien 6)8020",0
menu_search_text:	dc.b	"Chercher O)ctet M)ot L)ong mot A)scii I)nst.",0
menu_mac_text:	dc.b	"Macro E)nregistrer J)ouer C)harger V)oir",0
menu_rec_mac_text:	dc.b	"E)nregistrer T)race A)rriŠre P)asser C)lr",0
menu_play_mac_text:	dc.b	"J)ouer T)race A)rriŠre P)asser V)oir D)‚but",0
menu_manual_prinfo_text:	dc.b	"C)harger S)auver PRogram Info",0
;		#] Menus messages:
;		#[ Yes/no messages:
yesno_format_text:	dc.b	"%bc %s? Y)es/N)o",0
kill_all_var_text:	dc.b	"D‚truire toutes VAR(s)",0
continue_text:	dc.b	" Continuer … jouer",0
	IFNE	ATARIST
disk_pb_text:	dc.b	"Vecteurs disks corrompus. Continuer",0
	ENDC
new_var_reset_text:	dc.b	"Var %s existe d‚j…. Ecraser",0
kill_all_text:	dc.b	"Effacer tous les points d'arrˆt",0
watch_text:	dc.b	"Voir",0
keep_registers_text:	dc.b	"Sauver registres",0
restore_registers_text:	dc.b	"Restaurer registres",0
catch_exceptions_text:	dc.b	"D‚tourner toutes les exceptions",0
;		#] Yes/no messages:
;		#[ Result messages:
prg_vars_loaded_text:	dc.b	"%=ld symboles charg‚s dans <%s>",0
shell_result_text:	dc.b	"R‚sultat: %=d",0
not_implemented_wtype_text:	dc.b	"Type de fenˆtre non impl‚ment‚",0
search_found_text:	dc.b	"Trouv‚",0
search_not_found_text:	dc.b	"Non trouv‚",0
;ask_for_function_text:		dc.b	"J'attends une fonction",0
;F1
mark_set_text:	dc.b	"Marque pos‚e",0
;F2
mark_exchanged_text:	dc.b	"Marque ‚chang‚e",0
;F3
;block_cancelled_text:	dc.b	"Block cancelled",0
;F4
;block_copied_text:	dc.b	"Block copied",0
;F5
;block_pasted_text:	dc.b	"Block pasted",0
loading_file_text:	dc.b	"Fichier <%s> en cours de chargement",0
file_loaded_text:	dc.b	"Fichier <%s> charg‚ en %=ld octets",0
	IFEQ	bridos
saving_file_text:	dc.b	"Fichier <%s> en cours de sauvegarde",0
file_saved_text:	dc.b	"Fichier <%s> sauv‚ en %=ld/%=ld octets",0
file_saved2_text:	dc.b	"Fichier <%s> sauv‚",0
disk_full_text:	dc.b	"Disque plein pendant la sauvegarde de <%s>",0
	ENDC
prt_finished_text:	dc.b 	"Impression termin‚e",0
rm_var_text:	dc.b	"Var %s effac‚e",0
new_var_set_text:	dc.b	"Var %s cr‚‚e",0
exceptions_catched_text:	dc.b	"Exceptions d‚tourn‚es",0
breaks_killed_text:	dc.b	"Tous points d'arrˆt effac‚s",0
copy_done_text:	dc.b	"Copie de m‚moire termin‚e",0
fill_done_text:	dc.b	"Remplissage de m‚moire termin‚",0
sr_updated_text:	dc.b	"IPL interne mis … %=d",0
free_memory_text:	dc.b	"M‚moire libre: ",0
free_1_memory_text:	dc.b	"%s\%=ld bytes",0
free_2_memory_text:	dc.b	"%s2: \%=ld, Lente: \%=ld, Rapide: \%=ld bytes",0
registers_kept_text:	dc.b	"Registres sauv‚s",0
registers_restored_text:	dc.b	"Registres restaur‚s.",0
break_reach_text:	dc.b	"Point d'arrˆt nø%=lx atteint",0
print_break_set_unset_format:	dc.b	"Point d'arrˆt nø%=lx %s",0
catch_all_funcs_text:	dc.b	"Toutes fonctions du Trap $%=bx d‚tourn‚es (%s)",0
catch_one_func_text:	dc.b	"Fonction $%=x (%s) du Trap $%bx d‚tourn‚e (%s)",0
set_text:	dc.b	"mis",0
killed_text:	dc.b	"enlev‚",0
skipped_text:	dc.b	"Pass‚",0
ctrl_r_text:	dc.b	"Lanc‚",0
dsetpath_done_text:	dc.b	"Chemin courant modifi‚",0
current_path_text:	dc.b	"Chemin courant: %s",0
search_text:	dc.b	"Recherche..",0
mac_play_stopped_text:	dc.b	"Macro arrˆt‚e",0
;mac_ended_text:	dc.b	"Fin de macro",0
mac_rec_text:	dc.b	"Enregistre macro..",0
mac_play_text:	dc.b	"Joue macro..",0
mac_rec_ended_text:	dc.b	"Enregistrement termin‚",0
mac_cleared_text:	dc.b	"Macro effac‚e",0
mac_play_home_text:	dc.b	"Pointeur de macro mis au d‚but",0
output_to_screen_text:	dc.b	"Pass‚ en sortie ‚cran",0
output_to_rs232_text:	dc.b	"Pass‚ en sortie s‚rie",0
rs232_switching_text:	dc.b	"Passe en sortie s‚rie..",0
waiting_high_text:	dc.b	"Passe en monochrome..",0
waiting_med_text:	dc.b	"Passe en couleur..",0
low_rez_text:	dc.b	"Basse r‚solution",0
mid_rez_text:	dc.b	"Moyenne r‚solution",0
high_rez_text:	dc.b	"Haute r‚solution",0

var_loaded_text:	dc.b	"%=ld Var(s),%ld ligne(s),%ld erreur(s)",0
page_nb_text:	dc.b	" ;page nø%=ld",0
profiler_reset_text:	dc.b	"Profiler remis … z‚ro",0
;		#] Result messages:
;		#[ Present messages:
present_breaks_text:	dc.b	"   # T  V Info",0
present_story_text:	dc.b	"       0        1        2        3        4        5        6        7",0
present_infos_text:	dc.b	"Informations %s",0
present_internal_text:	dc.b	"Internes",0
name_text:	dc.b	"Nom:   ",0
maximum_text:	dc.b	"Maximum:",0
current_text:	dc.b	"Courant:",0
help_breaks_text:	dc.b	" BREAK#",0
help_blocks_text:	dc.b	" BLOCK#",0
help_sto_text:	dc.b	" STORY#",0
help_var_text:	dc.b	"  VARS#",0
help_la_text:	dc.b	"     LA",0
help_lr_text:	dc.b	"     LR",0
help_bl_text:	dc.b	"     BL",0
help_ex_text:	dc.b	"     EX",0
help_mac_text:	dc.b	"  MACRO",0
help_his_text:	dc.b	" HISTRY",0
static_number_format:	dc.b	"% 7ld",0
start_end_format:	dc.b	"D‚but: $%0lx, Fin: $%lx",0
present_sys_text:	dc.b	"SystŠme",0
;screenbase_text:	dc.b	"SCREEN: $%lx ",0
	IFNE	ATARIST
;resolution_text:	dc.b	"RES: %%%03b ",0
	ENDC
present_soft_text:	dc.b	"Programme",0
present_exec_name_text:	dc.b	"Programme courant: %s, %=ld symboles, cmd:%s.",0
	IFNE	sourcedebug
present_source_name_text:	dc.b	"Module courant: %s",0
present_stack_text:	dc.b	"Affichage pile",0
source_stack_format:	dc.b	"%s, %s, #%=ld",0
	ENDC	;de sourcedebug
	IFNE	ATARIST
present_reloc_text:
	dc.b	"Nom  Adresse  Longueur",0
	ENDC	;d'ATARIST
	IFNE	_68030
present_frame_text:	dc.b	"Stack frame type $%01bx, vecteur $%bx (%s)",0
offset_stack_text:	dc.b	"<offset $%02x>",0
sr_stack_text:	dc.b	"SR: %0x %s",0
pc_stack_text:	dc.b	"PC: $%0lx %s",0
instr_address_stack_text:	dc.b	"Adresse de l'instruction: $%0lx",0
effective_address_stack_text:	dc.b	"Addresse effective: $%0lx",0
internal_reg_stack_text:	dc.b	"Registre interne %=d: $%0x",0
long_internal_reg_stack_text:	dc.b	"Register interne %=d: $%0lx",0
ssr_stack_text:
	;	CCFRWSD
	;	BBRWLUP
	;	--.MB.I
	dc.b	"SSR: %lc%bc%c = %%%0wb",0
stage_pipe_stack_text:	dc.b	"Stage %bc pipe: $%0x",0
fault_add_stack_text:	dc.b	"Data cycle fault address: $%0lx",0
data_outbuff_stack_text:	dc.b	"Data output buffer: $%0lx",0
stage_b_add_stack_text:	dc.b	"Adresse Stage B: $%0lx",0
data_inbuff_stack_text:	dc.b	"Data input buffer: $%0lx",0
version_stack_text:	dc.b	"Version nø: $%01x",0
	ENDC
;		#] Present messages:
;		#[ Error messages:
;		#[	System error messages:
	even
	IFNE	ATARIST
system_messages_table:
	dc.l	system_m0
	dc.l	system_m1
	dc.l	system_m2
	dc.l	system_m3
	dc.l	system_m4
	dc.l	system_m5
	dc.l	system_m6
	dc.l	system_m7
	dc.l	system_m8
	dc.l	system_m9
	dc.l	system_m10
	dc.l	system_m11
	dc.l	system_m12
	dc.l	system_m13
	dc.l	system_m14
	dc.l	system_m15
	dc.l	system_m16
	dc.l	system_m17

	dc.l	system_unknown	;-18
	dc.l	system_unknown	;-19
	dc.l	system_unknown	;-20
	dc.l	system_unknown	;-21
	dc.l	system_unknown	;-22
	dc.l	system_unknown	;-23
	dc.l	system_unknown	;-24
	dc.l	system_unknown	;-25
	dc.l	system_unknown	;-26
	dc.l	system_unknown	;-27
	dc.l	system_unknown	;-28
	dc.l	system_unknown	;-29
	dc.l	system_unknown	;-30
	dc.l	system_unknown	;-31

	dc.l	system_m32
	dc.l	system_m33
	dc.l	system_m34
	dc.l	system_m35
	dc.l	system_m36
	dc.l	system_m37
	dc.l	system_unknown	;-38
	dc.l	memory_error_text	;-39
	dc.l	system_m40
	dc.l	memory_error_text	;-41
	dc.l	memory_error_text	;-42
	dc.l	system_unknown	;-43
	dc.l	system_unknown	;-44
	dc.l	system_unknown	;-45
	dc.l	system_m46
	dc.l	system_m47
	dc.l	system_unknown	;-48
	dc.l	system_m49
	dc.l	system_unknown	;-50
	dc.l	system_unknown	;-51
	dc.l	system_unknown	;-52
	dc.l	system_unknown	;-53
	dc.l	system_unknown	;-54
	dc.l	system_unknown	;-55
	dc.l	system_unknown	;-56
	dc.l	system_unknown	;-57
	dc.l	system_unknown	;-58
	dc.l	system_unknown	;-59
	dc.l	system_unknown	;-60
	dc.l	system_unknown	;-61
	dc.l	system_unknown	;-62
	dc.l	system_unknown	;-63
	dc.l	system_m64
	dc.l	system_m65
	dc.l	system_m66
	dc.l	system_m67

system_m0:	dc.b	"Ok",0
system_m1:	dc.b	"System error",0
system_m2:	dc.b	"Drive not ready",0
system_m3:	dc.b	"Unknown command",0
system_m4:	dc.b	"CRC error",0
system_m5:	dc.b	"Bad request",0
system_m6:	dc.b	"Seek error",0
system_m7:	dc.b	"Unknown media",0
system_m8:	dc.b	"Sector not found",0
system_m9:	dc.b	"No paper",0
system_m10:	dc.b	"Write fault",0
system_m11:	dc.b	"Read fault",0
system_m12:	dc.b	"General mishap",0
system_m13:	dc.b	"Write protect",0
system_m14:	dc.b	"Media change",0
system_m15:	dc.b	"Unknown device",0
system_m16:	dc.b	"Bad sectors",0
system_m17:	dc.b	"Insert disk",0
system_m32:	dc.b	"Invalid function number",0
system_m33:	dc.b	"File not found",0
system_m34:	dc.b	"Path not found",0
system_m35:	dc.b	"No handles left",0
system_m36:	dc.b	"Access denied",0
system_m37:	dc.b	"Invalid handle",0

system_m40:	dc.b	"Invalid memory block address",0
system_m46:	dc.b	"Invalid drive specified",0
system_m47:	dc.b	"Invalid operation",0
system_m49:	dc.b	"No more files",0
system_m64:	dc.b	"Range error",0
system_m65:	dc.b	"Gemdos internal error",0
system_m66:	dc.b	"Invalid program load format",0
system_m67:	dc.b	"Setblock failure due to growth restrictions",0
	ENDC	; de ATARIST
;		#]	System error messages:
no_shell_error_text:	dc.b	"Pas de shell",0
shell_general_error:	dc.b	"Erreur shell g‚n‚rale",0
	IFNE	ATARIST 
rdebug_already_installed_text:	dc.b	27,"ERdebug d‚j… install‚. Pressez une touche.",0
vbl_error_text:	dc.b	"Plus de place en vblqueue",0
	ENDC
reload_prg_error_text:	dc.b	"Il y a d‚j… un programme en m‚moire",0
system_unknown:	dc.b	"Num‚ro d'erreur systŠme inconnu",0
option_forbid_textf:	dc.b	"Option non autoris‚e:-%bc",0
fatal_memory_error_text:	dc.b	"Erreur FATALE de r‚servation m‚moire dans les pr‚f‚rences",0
internal_error_text:	dc.b	"Erreur interne nø%=bx D‚calage %lx",0
bad_magic_file_error_text:	dc.b	"Fichier probablement corrompu",0
bad_version_file_error_text:	dc.b	"Fichier inutilisable par cette version d'ADEBUG",0

no_story_error_text:	dc.b	"Pas d'instructions m‚moris‚es",0
prt_not_ready_text:	dc.b 	"Imprimante non prˆte",0
alt_e_error_text:	dc.b	"M‚moire illisible",0
copy_done_2_text:	dc.b	"Attention! Copie incomplŠte",0
fill_done_2_text:	dc.b	"Attention! Remplissage incomplet",0
sctrl_areg_error_text:	dc.b	"Adresse impaire ou illisible",0
syntax_error_text:	dc.b	"Erreur de syntaxe",0
restore_registers_error_text:	dc.b	"Pas de registres sauv‚s",0
no_next_text:	dc.b	"Recherche non d‚finie",0

print_bloc_error_text: 	dc.b	"Mauvaise adresse de tampon",0
print_bloc_text:	dc.b	"Erreur disque",0
	IFNE	ATARIST
acia_ikbd_error_text:	dc.b	"Pas d'op‚ration disque dur autoris‚e en IPL>5",0
	ENDC
dgetpath_error_text:
dsetpath_error_text:	dc.b	"Chemin invalide",0
fnf_error_text:	dc.b	"Fichier <%s> non trouv‚",0
read_error_text:	dc.b	"Erreur de lecture nø%=d dans le fichier <%s>",0
seek_error_text:	dc.b	"Erreur de seek nø%=d dans le fichier <%s>",0
	IFEQ	bridos
create_error_text:	dc.b	"Erreur de cr‚ation",0
write_error_text:	dc.b	"Erreur d'‚criture nø%=d dans le fichier <%s>",0
write_error2_text:	dc.b	"Erreur d'‚criture",0
;close_error_text:	dc.b	"Erreur de fermeture",0
executable_error_text:	dc.b	"Pas un fichier ex‚cutable",0
reloc_error_text:	dc.b	"Erreur de relocation",0
;ascii_error_text:	dc.b	"Pas un fichier ASCII",0
unknown_sym_error_text:	dc.b	"Type de symboles inconnu",0
	ENDC	;de bridos
memory_error_text:	dc.b	"Plus de m‚moire",0

no_breaks_error_text:	dc.b	"Pas de points d'arrˆt",0
break_general_error_text:	dc.b	"Impossible de mettre le point d'arrˆt",0
break_full_error_text:	dc.b	"Plus de point d'arrˆt disponible",0
break_address_error_text:	dc.b	"Mauvaise adresse de point d'arrˆt",0
break_vector_error_text:	dc.b	"Mauvais num‚ro de vecteur de point d'arrˆt",0
break_bad_eval_error_text:	dc.b	"Mauvaise eval de point d'arrˆt",0
break_bad_number_error_text:	dc.b	"Mauvais num‚ro de point d'arrˆt",0
break_eval_full_error_text:	dc.b	"Tampon d'‚val des points d'arrˆt plein",0

bad_run_until_eval_text:	dc.b	"Mauvaise eval en Trace Jusqu'…",0
bad_stack_error_text:	dc.b	"Pile inutilisable pour tracer",0
bad_pc_error_text:	dc.b	"PC impair ou illisible",0
unknown_tasking_text:	dc.b	"Changement de contexte non initialis‚",0

	;--- MACROS ---
preproc_error_text:	dc.b	"Directive MAC inconnue",0
mac_memory_error_text:	dc.b	"Tampon MAC plein",0
no_mac_error_text:	dc.b	"Pas de MAC",0
missing_back_text:	dc.b	"` manquant dans macro",0
fnf_mac_error_text:	dc.b	"Fonction inconnue",0

	;--- VARIABLES ---
no_vars_error_text:	dc.b	"Pas de VAR",0
var_full_text:	dc.b	"Tampon VAR plein",0
la_full_text:	dc.b	"Tampon LA plein",0
lr_full_text:	dc.b	"Tampon LR plein",0
bl_full_text:	dc.b	"Tampon BL plein",0
syntax_error_var_text:	dc.b	"Erreur nø%=bd,VAR %ld,ligne %ld:%s",0
blnf_error_text:	dc.b	"%c <%s> non trouv‚",0
press_key_text:	dc.b	". Pressez une touche",0
debug2_var_format:	dc.b	"VAR %=ld,ligne %ld,%ld erreur(s):%s",0
;		#] Error messages:
;		#[ Exception messages:
prg_halted_text:	dc.b	"Programme arrˆt‚",0
pterm_text:	dc.b	"Program termin‚. R‚sultat: $%=lx \%ld %%%0lb %lC",0
bus_error_text:	dc.b	"Erreur de bus",0
address_error_text:	dc.b	"Adresse impaire",0
illegal_instruction_text:	dc.b	"Instruction ill‚gale",0
zero_divide_text:	dc.b	"Division par z‚ro",0
	IFNE	_68020!_68030!68040
chk_exception_text:	dc.b	"CHK ou CHK2",0
trapv_exception_text:	dc.b	"TRAPV, TRAPcc ou FTRAPcc",0
	ELSEIF
chk_exception_text:	dc.b	"CHK",0
trapv_exception_text:	dc.b	"TRAPV",0
	ENDC	; de _68020!30!40
privilege_violation_text:	dc.b	"Violation de privilŠge",0
traced_text:	dc.b	"Exception trace",0
traced2_text:	dc.b	"Trac‚",0
traced3_text:	dc.b	"Trace interrompu",0
ctrla_text:	dc.b	"Lanc‚ et stopp‚",0
faux_ctrla_text:	dc.b	"Exception ‚mul‚e",0
linea_exception_text:	dc.b	"Emulateur ligne 1010 (ligne A)",0
linef_exception_text:        	dc.b	"Emulateur ligne 1111 (ligne F)",0
r1_exception_text:	dc.b	"R1",0
cp_protocol_violation_text:	dc.b	"Violation de protocole coprocesseur",0
format_error_exception_text:	dc.b	"Erreur de format",0
uninitialized_interrupt_text:	dc.b	"Interruption non initialis‚e",0
r2_exception_text:	dc.b	"R2",0
r3_exception_text:  	dc.b	"R3",0
r4_exception_text:	dc.b	"R4",0
r5_exception_text:	dc.b	"R5",0
r6_exception_text:	dc.b	"R6",0
r7_exception_text:	dc.b	"R7",0
r8_exception_text:	dc.b	"R8",0
r9_exception_text:	dc.b	"R9",0
spurious_interrupt_text:	dc.b	"Interruption parasite",0
fpu_branch_text:	dc.b	"Mauvais branchement ou affectation du FPU",0
fpu_config_text:	dc.b	"R‚sultat erron‚ du FPU",0
fpu_div0_text:	dc.b	"Division par z‚ro du FPU",0
fpu_underflow_text:	dc.b	"Sous-calcul du FPU",0
fpu_operand_text:	dc.b	"Erreur d'op‚rande du FPU",0
fpu_overflow_text:	dc.b	"D‚passement de flux du FPU",0
fpu_NAN_text:	dc.b	"NAN signal‚ par le FPU",0
r10_exception_text:	dc.b	"RA",0
pmmu_config_text:	dc.b	"Erreur de configuration PMMU",0
pmmu_illegal_text:	dc.b	"Op‚ration PMMU ill‚gale",0
pmmu_access_text:	dc.b	"Niveau d'accŠs PMMU",0
r11_exception_text:	dc.b	"RB",0
r12_exception_text:	dc.b	"RC",0
r13_exception_text:	dc.b	"RD",0
r14_exception_text:	dc.b	"RE",0
r15_exception_text:	dc.b	"RF",0
user_vector_format_text:	dc.b	"Vecteur utilisateur $%=x",0
;		#] Exception messages:
;		#[ Preferences stuff:
	;VALUES
ask_tab_text:	dc.b	"Valeur de tabulation",0
ask_lensym_text:	dc.b	"Longueur d'un symbole",0
ask_line_len_text:	dc.b	"Longueur maximum d'une ligne ASCII",0
ask_def_break_vec_text:	dc.b	"Nø VEC",0
ask_def_ipl_level_text:	dc.b	"IPL interne par d‚faut",0
ask_serial_speed_text:	dc.b	"Vitesse du port s‚rie",0
ask_serial_parity_text:	dc.b	"Parit‚ du port s‚rie",0
ask_break_nb_text:	dc.b	"Nombre maximum de breaks",0
ask_block_nb_text:	dc.b	"Nombre maximum de blocs",0
ask_sto_size_text:	dc.b	"Nombre STO",0
ask_var_size_text:	dc.b	"Nombre VAR",0
ask_la_size_text:	dc.b	"Taille LA",0
ask_lr_size_text:	dc.b	"Taille LR",0
ask_bl_size_text:	dc.b	"Taille BL",0
ask_ex_size_text:	dc.b	"Taille EX",0
ask_mac_size_text:	dc.b	"Taille MAC",0
ask_his_size_text:	dc.b	"Taille HIS",0

	;ASCII
;ask_def_break_eval_text:	dc.b	"Default break eval",0

	;FLAGS
ask_trace_exceptions_text:	dc.b	"Trace les exceptions",0
ask_reinstall_trace_text:	dc.b	"R‚installe trace",0
ask_log_ctrla_text:	dc.b	"Voir ‚cran logique en [Ctrl_A]",0
ask_log_trap_text:	dc.b	"Voir ‚cran logique en [Ctrl_R]",0
ask_log_lineaf_text:	dc.b	"Voir ‚cran logique en Trap & Line A/F",0
ask_relative_offset_text:	dc.b	"D‚placement relatif registre",0
ask_symbols_text:	dc.b	"Affiche symboles",0
ask_case_sensitive_text:	dc.b	"Symboles diff‚renci‚ maj/min",0
ask_debug_symbols_text:	dc.b	"Symboles de d‚bogage seulement",0
ask_offset_symbols_text:	dc.b	"Affiche symbol+offset",0
ask_line_wrap_text:	dc.b	"Line wrap ASCII",0
ask_show_inv_text:	dc.b	"Affiche invisibles ASCII",0
ask_save_prinfo_text:	dc.b	"Sauver les infos programme",0
ask_inverse_text:	dc.b	"Inverse vid‚o",0
ask_real_time_text:	dc.b	"Temps r‚el",0
ask_real_time_window_text:	dc.b	"Temps r‚el seulement en fenˆtre courante",0
ask_real_time_lock_text:	dc.b	"Lien en temps r‚el",0
ask_minitel_text:	dc.b	"Minitel",0
ask_rs232_output_text:	dc.b	"Sortie s‚rie par d‚faut",0
ask_system_print_text:	dc.b	"Impression systŠme",0
ask_follow_sr_text:	dc.b	"Suivi d'IPL",0
	IFNE	ATARIST
ask_abssym_text:	dc.b	"Charger les symboles DRI en absolu",0
ask_defsym_text:	dc.b	"Charger les symboles DRI ind‚finis",0
ask_modtime_text:	dc.b	"V‚rifier date/heure module",0
ask_chkcode_text:	dc.b	"Afficher les marques de code en source",0
ask_untilmain_text:	dc.b	"Run until main au chargement",0
ask_electronic_switch_text:	dc.b	"Echangeur ‚lectronique",0
ask_hard_ipl7_text:	dc.b	"Pas de disque dur en IPL>5",0
ask_disk_vectors_text:	dc.b	"V‚rifie vecteurs disque",0
ask_catch_div0_text:	dc.b	"D‚tourner Division par z‚ro",0
ask_catch_linef_text:	dc.b	"D‚tourner Ligne F",0
ask_catch_priv_text:	dc.b	"D‚tourner Violation de privilŠge",0
	ENDC
	IFNE	AMIGA
ask_hard_ipl7_text:	dc.b	"Pas d'op‚ration disque en IPL>0 ou basse Intena",0
ask_follow_intena_text:	dc.b	"Suivi d'Intena",0
ask_color0_text:	dc.b	"Couleur de fond",0
ask_color1_text:	dc.b	"Couleur d'avant-plan",0
ask_multitasking:	dc.b	"D‚bogue le programme en tant que tache",0
ask_create_sections_labels: dc.b "Cr‚er des labels au d‚but des sections",0
ask_tasktrap_text:	dc.b	"Laisser les exceptions au trap-handler s'il existe",0
	ENDC
ask_profile_text:	dc.b	"Profiler actif",0
ask_profclip_text:	dc.b	"Profiler tous les symboles",0
	IFEQ	bridos
ask_savep_text:	dc.b	"Sauver les pr‚f‚rences",0
	ENDC	;de bridos
;		#] Preferences stuff:
;		#[ Title messages:
frame_title_text:	dc.b	"STACK FRAMES",0
;help_title_text:	dc.b	"INFORMATIONS DIVERSES",0
help_title_text:	dc.b	"AIDE",0
breaks_title_text:	dc.b	"POINTS D'ARRET",0
vars_title_text:	dc.b	"VARIABLES",0
story_title_text:	dc.b	"STORY",0
macro_title_text:	dc.b	"MACRO",0
	IFNE	sourcedebug
stack_title_text:	dc.b	"CONTENU DE LA PILE",0
	ENDC	;de sourcedebug
	IFNE	ATARIST
traps_title_text:	dc.b	"APPELS AES/VDI",0
	ENDC	;d'ATARIST
	IFNE	AMIGA
task_title_text:	dc.b	"TACHES",0
	ENDC
;		#] Title messages:
;		#] French messages:
	ENDC	;de french_text
;	 #] Messages:
;	 #[ sscanforms:
load_prg_vars_sscanform:	dc.b	"sl",0
load_reloc_sscanform:	dc.b	"ss",0
print_bloc_address_sscanform:	dc.b	"ll",0
system_break_sscanform:	dc.b	"b|swbb",0
copyfill_form:	dc.b	"lll",0
askbreak_sscanform:	dc.b	"lsbb",0
loadbin_sscanform:	dc.b	"sl",0
savebin_sscanform:	dc.b	"sll",0
sscanf_no_eval_symbols:	dc.b	's','p','f',0
;	 #] sscanforms:
;	 #[ Breaks:
	IFNE	_68020!_68030
	even
stacks_sizes:
	dc.w	4	; 4 word	format $0
	dc.w	4	; throwaway 4 word	format $1
	dc.w	6	; 6 word	format $2
	dc.w	6	; floating-point post-instruction	format $3	(68040 only)
	dc.w	0	;	format $4
	dc.w	0	;	format $5
	dc.w	0	;	format $6
	dc.w	30	; access error	format $7	(68040 only)
	dc.w	0	;	format $8
	dc.w	10	;	format $9
	dc.w	16	;	format $a
	dc.w	46	;	format $b

stacks_table:
	dc.l	stack0
	dc.l	stack1
	dc.l	stack2
	dc.l	stack3	;68040 only
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	stack7	;68040 only
	dc.l	0
	dc.l	stack9
	dc.l	stacka
	dc.l	stackb

	;'l'=long
	;'w'=word
	;'b'=byte

	;'i'=internal
	;'@'=address
	;'s'=ssr
	;'C'=pipe C
	;'B'=pipe B
	;'v'=version
	;'w'=ssw	;68040 format $7
	;'S'=Writeback Status	;68040 format $7
	;'d'=Data

stack0:	dc.b	0,0
stack1:	dc.b	0,0
stack2:	dc.b	'l','@'
	dc.l	instr_address_stack_text
	dc.b	0,0
;68040 only
stack3:	dc.b	'l','@'
	dc.l	effective_address_stack_text
	dc.b	0,0
;68040 only
stack7:	dc.b	'l','@'
	dc.l	effective_address_stack_text
;	dc.b	'w','w'	;ssw
;	dc.b	'b','W'	;Writeback status 3 (wb3s)
;	dc.b	'b','W'	;Writeback status 2 (wb2s)
;	dc.b	'b','W'	;Writeback status 1 (wb1s)
;	dc.b	'l','@'	;Fault addr
;	dc.b	fault_add_stack_text
;	dc.b	'l','@'	;Writeback 3 address
;	dc.l	writeback_address_text
;	dc.b	'w','d'	;Writeback 3 data
;	dc.l	writeback_data_text
;	dc.b	'l','@'	;Writeback 2 address
;	dc.l	writeback_address_text
;	dc.b	'w','d'	;Writeback 2 data
;	dc.l	writeback_data_text
;	dc.b	'l','@'	;Writeback 1 address
;	dc.l	writeback_address_text
;	dc.b	'w','d'	;Writeback 1 data/push data lw0 (wb1d/pd0)
;	dc.l	writeback_data_text
;	dc.b	'w','d'	;push data lw1 (pd1)
;	dc.l	writeback_data_text
;	dc.b	'w','d'	;push data lw2 (pd2)
;	dc.l	writeback_data_text
;	dc.b	'w','d'	;push data lw3 (pd3)
;	dc.l	writeback_data_text
	dc.b	0,0
stack9:	dc.b	'l','@'
	dc.l	instr_address_stack_text
	dc.b	'w','i'
	dc.b	'w','i'
	dc.b	'w','i'
	dc.b	'w','i'
	dc.b	0,0

stacka:	dc.b	'w','i'	;internal0
	dc.b	'w','s'	;ssr
	dc.b	'w','C'	;stage C
	dc.b	'w','B'	;stage B
	dc.b	'l','@'	;data fault addr
	dc.l	fault_add_stack_text
	dc.b	'w','i'	;internal1
	dc.b	'w','i'	;internal2
	dc.b	'l','@'	;data output buffer
	dc.l	data_outbuff_stack_text
	dc.b	'w','i'	;internal3
	dc.b	'w','i'	;internal4
	dc.b	0,0

stackb:	dc.b	'w','i'	;internal0
	dc.b	'w','s'	;ssr
	dc.b	'w','C'	;stage C
	dc.b	'w','B'	;stage B
	dc.b	'l','@'	;data fault addr
	dc.l	fault_add_stack_text
	dc.b	'w','i'	;internal1
	dc.b	'w','i'	;internal2
	dc.b	'l','@'	;data output buffer
	dc.l	data_outbuff_stack_text
	dc.b	'w','i'	;internal3
	dc.b	'w','i'	;internal4
	dc.b	'l','i'	;internal5-6
	dc.b	'l','@'	;stage B buffer
	dc.l	stage_b_add_stack_text
	dc.b	'l','i'	;internal7-8
	dc.b	'l','@'	;data input buffer
	dc.l	data_inbuff_stack_text
	dc.b	'w','i'	;internal9
	dc.b	'w','i'	;internal 10
	dc.b	'w','i'	;internal 11
	dc.b	'w','v'	;version #
;	dc.l	version_stack_text
	dc.b	'l','i'	;internal12
	dc.b	'l','i'
	dc.b	'l','i'
	dc.b	'l','i'
	dc.b	'l','i'
	dc.b	'l','i'
	dc.b	'l','i'
	dc.b	'l','i'
	dc.b	'l','i'
	dc.b	0,0
	ENDC	; de 68020!68030

	EVEN
breaks:
	;shift_alt_help
	dc.w	0
	dc.w	-1

	;pterm
	dc.w	0
	dc.w	-1

	;bus	error
;	clr.w	0.w
	dc.w	0
;	dc.w	$10
	dc.w	8

	;@	impaire
	dc.w	$6001
	dc.w	$c

	;illegal:
	dc.w	$4afc
	dc.w	$10

	;div	par 0
;	divu	#0,d0
	dc.w	0
	dc.w	$14

	;CHK,CHK2
	dc.w	0
	dc.w	$18

	;FTRAPcc,TRAPcc,TRAPV
	dc.w	$4e76
	dc.w	$1c

	;privilege violation
	;move	sr,d0
	dc.w	0
	dc.w	$20

	;trace
	;ori.w	#$8000,sr
	dc.w	0
	dc.w	$24

	;line	1011
	IFNE	ATARIST
	dc.w	$a000
	dc.w	-1
	ENDC
	IFNE	AMIGA
	dc.w	$a000
	dc.w	$28
	ENDC

	;line	1111
	dc.w	$fabf
	dc.w	$2c

	;r1
	dc.w	0
	dc.w	$f030

	;cp protocol violation
	dc.w	0
	dc.w	$f034

	;format error
	dc.w	0
	dc.w	$f038

	;uninitialized interrupt
	dc.w	0
	dc.w	$3c

	;r2
	dc.w	0
	dc.w	$f040

	;r3
	dc.w	0
	dc.w	$f044

	;r4
	dc.w	0
	dc.w	$f048

	;r5
	dc.w	0
	dc.w	$f04c

	;r6
	dc.w	0
	dc.w	$f050

	;r7
	dc.w	0
	dc.w	$f054

	;r8
	dc.w	0
	dc.w	$f058

	;r9
	dc.w	0
	dc.w	$f05c

	;spurious interrupt
	dc.w	0
	dc.w	$60

	IFNE	ATARIST
	;ipl1
	dc.w	0
	dc.w	$64

	;ipl2
	dc.w	0
;	dc.w	$68
	dc.w	-1

	;ipl3
	dc.w	0
	dc.w	$6c

	;ipl4
	dc.w	0
;	dc.w	$70
	dc.w	-1

	;ipl5
	dc.w	0
	dc.w	$74

	;ipl6
	dc.w	0
	dc.w	$78

	;ipl7
	dc.w	0
	dc.w	$7c

	;traps
	trap	#0
	dc.w	$80

;	trap	#1
;	dc.w	$84
	dc.w	0
	dc.w	-1

;	trap	#2
;	dc.w	$88
	dc.w	0
	dc.w	-1

	trap	#3
	dc.w	$8c

	trap	#4
	dc.w	$90

	IFNE	residant_debug
	dc.w	0
	dc.w	-1
	ELSEIF
	trap	#5
	dc.w	$94
	ENDC

	trap	#6
	dc.w	$98

	trap	#7
	dc.w	$9C

	trap	#8
	dc.w	$A0

	trap	#9
	dc.w	$A4

	trap	#10
	dc.w	$A8

	trap	#11
	dc.w	$AC

	trap	#12
	dc.w	$B0

;	trap	#13
;	dc.w	$B4
	dc.w	0
	dc.w	-1

;	trap	#14
;	dc.w	$B8
	dc.w	0
	dc.w	-1

	trap	#15
	dc.w	$BC
	ENDC	; d'ATARIST
	IFNE	AMIGA
	;ipl1
	dc.w	0
	dc.w	-1

	;ipl2
	dc.w	0
	dc.w	-1

	;ipl3
	dc.w	0
	dc.w	-1

	;ipl4
	dc.w	0
	dc.w	-1

	;ipl5
	dc.w	0
	dc.w	-1

	;ipl6
	dc.w	0
	dc.w	-1

	;ipl7
	dc.w	0
	dc.w	$7c

	;traps
	trap	#0
	dc.w	$80

	trap	#1
	dc.w	$84

	trap	#2
	dc.w	$88

	trap	#3
	dc.w	$8c

	trap	#4
	dc.w	$90

	trap	#5
	dc.w	$94

	trap	#6
	dc.w	$98

	trap	#7
	dc.w	$9C

	trap	#8
	dc.w	$A0

	trap	#9
	dc.w	$A4

	trap	#10
	dc.w	$A8

	trap	#11
	dc.w	$AC

	trap	#12
	dc.w	$B0

	trap	#13
	dc.w	$B4

	trap	#14
	dc.w	$B8

	trap	#15
	dc.w	$BC
	ENDC	; d'AMIGA
	;FPU branch or set on unordered condition
	dc.w	0
	dc.w	$f0c0

	;FPU inexact result
	dc.w	0
	dc.w	$f0c4

	;FPU divide by zero
	dc.w	0
	dc.w	$f0c8

	;FPU underflow
	dc.w	0
	dc.w	$f0cc

	;FPU operand error
	dc.w	0
	dc.w	$f0d0

	;FPU overflow
	dc.w	0
	dc.w	$f0d4

	;FPU signaling NAN
	dc.w	0
	dc.w	$f0d8

	;reserved 10
	dc.w	0
	dc.w	$f0dc

	;PMMU configuration error
	dc.w	0
	dc.w	$f0e0

	;PMMU illegal operation
	dc.w	0
	dc.w	$f0e4

	;PMMU Access Level Violation
	dc.w	0
	dc.w	$f0e8

	;r11
	dc.w	0
	dc.w	$f0ec

	;r12
	dc.w	0
	dc.w	$f0f0

	;r13
	dc.w	0
	dc.w	$f0f4

	;r14
	dc.w	0
	dc.w	$f0f8

	;r15
	dc.w	0
	dc.w	$f0fc

	;... user defined vectors
	;$100->$255
zero_text:
	dc.b	"-"
un_text:
	dc.b	"1",0

;	 #] Breaks:
;	 #[ Variables:
	even
	IFNE	ATARIST
cls_vt52_string:	dc.b	27,"E",27,"e",0
hidecur_vt52_string:	dc.b	27,"f",0
prg_text:	dc.b	".prg",0
app_text:	dc.b	".app",0
tos_text:	dc.b	".tos",0
ttp_text:	dc.b	".ttp",0
gtp_text:	dc.b	".gtp",0
	ENDC
;ro_text:	dc.b	".ro",0
text_text:	dc.b	"TEXT",0
data_text:	dc.b	"DATA",0
	IFNE	ATARIST
bss_text:	dc.b	"BSS ",0
	ENDC
	IFNE	AMIGA
bss_text:
	ENDC
bss_var_text:	dc.b	"BSS",0
end_text:	dc.b	"END",0

;table des caracteres de fin de ligne ASCII
ascii_eol_chars:	dc.b	13,10,0,-1	;(-1=fin de table)

	even
;table des fonctions dont il faut ne pas tenir compte en enregistrement
no_record_table:
	;m
	dc.w	$0027
	;ctl_p
	dc.w	$0419
	;fin de table
	dc.w	0

;table des fonctions qu'il faut echanger en enregistrement
swap_record_table:
	;espace
	dc.w	$0039
	;avec shift down
	dc.w	$0150

	;sft_espace
	dc.w	$0139
	;avec shift up
	dc.w	$0148

	;<
	dc.w	$002b
	;avec up
	dc.w	$0048

	;>
	dc.w	$002b
	;avec down
	dc.w	$0050
	;fin de table
	dc.w	0

;table des types qu'il faut updater par table_bl_addr->current_bl_addr
bl_types_table:
	dc.w	BLWORD
	dc.w	ROWORD
	dc.w	0

rez_parameters_table:
	;%000=low rez
	dc.w	200,160,39,24,font8x8_addr
	;%001=mid rez
	dc.w	200,160,79,24,font8x8_addr
	;%010=high rez
	dc.w	400,80,79,24,font8x16_addr
	IFNE	ATARITT
	;%011=nothing
	dc.w	0,0,0,0,0
	;%100=320*480
	dc.w	480,160,39,24,font8x8_addr
	;%101=640*480
	dc.w	480,320,80,24,font8x16_addr
	;%110=1280*960
	dc.w	960,160,159,59,font8x16_addr
	ENDC
	IFNE	sourcedebug
lc_main_var_text:	dc.b	"_"
tc_main_var_text:	dc.b	"main",0
tc_stack_size_text:	dc.b	"_StkSize",0
source_var_format:	dc.b	"%16s %s;",0
no_src_text:	dc.b	"No source",0
no_vars_text:	dc.b	"No variables",0
	ENDC	;de sourcedebug
;		#[ File datas:

general_name_text:
	IFNE	ATARIST
	dc.b	"*.*",0
	ENDC
	IFNE	AMIGA
	dc.b	"#?",0
	ENDC
	even
	IFEQ	cartouche
	SET_ID	FILES_MAGIC
	ENDC	; de cartouche
	IFNE	ATARIST
fichier_var:	dc.b	"ADEBUG.VAR",0,0,0
save_var:	dc.b	"ADEBUG.SAV",0,0,0
def_mac_text:	dc.b	"A_DEBUG.MAC",0,0
mac_ext_text:	dc.b	".MAC",0
win_ext_text:	dc.b	".PRI",0
	ENDC	;d'ATARIST
	even
;		#] File datas:
;	 #] Variables:
;	 #[ Evaluator:
;  #[ Operators table:
tokens_table:
.1:
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l _loop-.1,_different_not_op-.1,_string_string-.1,_breakpoint_string-.1,_hexa_string-.1,_binary_string-.1,_and_logand_op-.1,_string_string-.1
 dc.l _open_par-.1,_close_par-.1,_mulu_op-.1,_add_preinc_postinc_op-.1,_end_of_parameter-.1,_sub_predec_postdec_op-.1,_size-.1,_divu_op-.1
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,_else_op-.1,0,_inf_infeq_lsl_op-.1,_affect_equal_op-.1,_sup_supeq_lsr_op-.1,_if_then_op-.1
 dc.l _octal_string-.1,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,_decimal_string-.1,0,_eor_op-.1,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,_open_acc-.1,_or_logor_op-.1,_close_acc-.1,_not_op-.1,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
 dc.l 0,0,0,0,0,0,0,0
;  #] Operators table:
;  #[ Functions tokens:

operators_token:
 dc.l _start_of_block_op
 dc.b 'SOB',0
 even
 dc.l _end_of_block_op
 dc.b 'EOB',0
 even
 dc.l _length_of_block_op
 dc.b 'LOB',0
 even
 dc.l _previous_label_op
 dc.b 'LPREV',0
 even
 dc.l _next_label_op
 dc.b 'LNEXT',0
 even
 dc.l _modulo_op
 dc.b 'MOD',0
 even
 dc.l _while_op
 dc.b 'WHILE',0
 even
 dc.l _watch_op
 dc.b 'WATCH',0
 even
 dc.l _set_var_op
 dc.b 'SVAR',0
 IFNE sourcedebug
 even
 dc.l _source_op
 dc.b 'SOURCE',0
 even
 dc.l _sizeof_op
 dc.b 'SIZEOF',0
 ENDC ;de sourcedebug
 even
 dc.l 0

;  #] Functions tokens:
;  #[ Registers tokens:

registers_token:
d0_token:
 dc.l d0_buf
 dc.b 'D0',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_D0
 even
d1_token:
 dc.l d1_buf
 dc.b 'D1',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_D1
 even
d2_token:
 dc.l d2_buf
 dc.b 'D2',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_D2
 even
d3_token:
 dc.l d3_buf
 dc.b 'D3',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_D3
 even
d4_token:
 dc.l d4_buf
 dc.b 'D4',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_D4
 even
d5_token:
 dc.l d5_buf
 dc.b 'D5',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_D5
 even
d6_token:
 dc.l d6_buf
 dc.b 'D6',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_D6
 even
d7_token:
 dc.l d7_buf
 dc.b 'D7',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_D7
 even
a0_token:
 dc.l a0_buf
 dc.b 'A0',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_A0
 even
a1_token:
 dc.l a1_buf
 dc.b 'A1',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_A1
 even
a2_token:
 dc.l a2_buf
 dc.b 'A2',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_A2
 even
a3_token:
 dc.l a3_buf
 dc.b 'A3',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_A3
 even
a4_token:
 dc.l a4_buf
 dc.b 'A4',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_A4
 even
a5_token:
 dc.l a5_buf
 dc.b 'A5',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_A5
 even
a6_token:
 dc.l a6_buf
 dc.b 'A6',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_A6
 even
a7_token:
 dc.l a7_buf
 dc.b 'A7',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_A7
 even
usp_token:
 dc.l a7_buf
 dc.b 'USP',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_A7
 even
sr_token:
 dc.l sr_buf
 dc.b 'SR',0,Default_WORD,Eval_WORD,_SR
 even
pc_token:
 dc.l pc_buf
 dc.b 'PC',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_PC
 IFNE _68030
 even
isp_token:
 dc.l isp_buf
 dc.b 'ISP',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_ISP
 even
msp_token:
 dc.l msp_buf
 dc.b 'MSP',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_MSP
 ENDC
 even
sp_token:
 dc.l $deadbeef
 dc.b 'SP',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_SP
 even
ssp_token:
 dc.l $deadbeef
 dc.b 'SSP',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_SSP
 IFNE _68020!_68030
 even
vbr_token:
 dc.l vbr_buf
 dc.b 'VBR',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_VBR
 even
sfc_token:
 dc.l sfc_buf+1
 dc.b 'SFC',0,Default_BYTE,Eval_BYTE,_SFC
 even
dfc_token:
 dc.l dfc_buf+1
 dc.b 'DFC',0,Default_BYTE,Eval_BYTE,_DFC
 even
cacr_token:
 dc.l cacr_buf
 dc.b 'CACR',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_CACR
 even
caar_token:
 dc.l caar_buf
 dc.b 'CAAR',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_CAAR
 even
crp_token:
 dc.l crp_buf
 dc.b 'CRP',0,Default_DOUBLE,Eval_BYTE|Eval_WORD|Eval_LONG|Eval_DOUBLE,_CRP
 even
srp_token:
 dc.l srp_buf
 dc.b 'SRP',0,Default_DOUBLE,Eval_BYTE|Eval_WORD|Eval_LONG|Eval_DOUBLE,_SRP
 even
tc_token:
 dc.l tc_buf
 dc.b 'TC',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_TC
 even
tt0_token:
 dc.l tt0_buf
 dc.b 'TT0',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_TT0
 even
tt1_token:
 dc.l tt1_buf
 dc.b 'TT1',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_TT1
 even
mmusr_token:
 dc.l mmusr_buf
 dc.b 'MMUSR',0,Default_WORD,Eval_WORD,_MMUSR
 even
fp0_token:
 dc.l fp0_buf
 dc.b 'FP0',0,Default_PACKED,Eval_BYTE|Eval_WORD|Eval_LONG|Eval_SINGLE|Eval_DOUBLE|Eval_EXTENDED|Eval_PACKED,_FP0
 even
fp1_token:
 dc.l fp1_buf
 dc.b 'FP1',0,Default_PACKED,Eval_BYTE|Eval_WORD|Eval_LONG|Eval_SINGLE|Eval_DOUBLE|Eval_EXTENDED|Eval_PACKED,_FP1
 even
fp2_token:
 dc.l fp2_buf
 dc.b 'FP2',0,Default_PACKED,Eval_BYTE|Eval_WORD|Eval_LONG|Eval_SINGLE|Eval_DOUBLE|Eval_EXTENDED|Eval_PACKED,_FP2
 even
fp3_token:
 dc.l fp3_buf
 dc.b 'FP3',0,Default_PACKED,Eval_BYTE|Eval_WORD|Eval_LONG|Eval_SINGLE|Eval_DOUBLE|Eval_EXTENDED|Eval_PACKED,_FP3
 even
fp4_token:
 dc.l fp4_buf
 dc.b 'FP4',0,Default_PACKED,Eval_BYTE|Eval_WORD|Eval_LONG|Eval_SINGLE|Eval_DOUBLE|Eval_EXTENDED|Eval_PACKED,_FP4
 even
fp5_token:
 dc.l fp5_buf
 dc.b 'FP5',0,Default_PACKED,Eval_BYTE|Eval_WORD|Eval_LONG|Eval_SINGLE|Eval_DOUBLE|Eval_EXTENDED|Eval_PACKED,_FP5
 even
fp6_token:
 dc.l fp6_buf
 dc.b 'FP6',0,Default_PACKED,Eval_BYTE|Eval_WORD|Eval_LONG|Eval_SINGLE|Eval_DOUBLE|Eval_EXTENDED|Eval_PACKED,_FP6
 even
fp7_token:
 dc.l fp7_buf
 dc.b 'FP7',0,Default_PACKED,Eval_BYTE|Eval_WORD|Eval_LONG|Eval_SINGLE|Eval_DOUBLE|Eval_EXTENDED|Eval_PACKED,_FP7
 even
fpcr_token:
 dc.l fpcr_buf
 dc.b 'FPCR',0,Default_WORD,Eval_BYTE|Eval_WORD,_FPCR
 even
fpsr_token:
 dc.l fpsr_buf
 dc.b 'FPSR',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_FPSR
 even
fpiar_token:
 dc.l fpiar_buf
 dc.b 'FPIAR',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_FPIAR
 ENDC ;de _68030
 even
w1_token:
 dc.l w1_db+$a
 dc.b 'W1',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_W1
 even
w2_token:
 dc.l w2_db+$a
 dc.b 'W2',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_W2
 even
w3_token:
 dc.l w3_db+$a
 dc.b 'W3',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_W3
 even
w4_token:
 dc.l w4_db+$a
 dc.b 'W4',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_W4
 even
w5_token:
 dc.l w5_db+$a
 dc.b 'W5',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_W5
 even
current_window_token:
 dc.l w1_db+$a
 dc.b 'CW',0,Default_LONG,Eval_BYTE|Eval_WORD|Eval_LONG,_CW
 even
 dc.l 0
 dc.w 0

current_window_table:
 dc.l w1_token
 dc.l w2_token
 dc.l w3_token
 dc.l w4_token
 dc.l w5_token

;  #] Registers tokens:
;  #[ I/O tokens:

constants_tokens:
; 1.l	adresse I/O
; 1.w	format par d‚faut
; x.b	nom de la constante

 IFNE	ATARIST
; colors
color0_token:
 dc.l $ff8240
 dc.w $7f00|Default_WORD
 dc.b 'COLOR0',0
 even
color1_token:
 dc.l $ff8242
 dc.w $7f00|Default_WORD
 dc.b 'COLOR1',0
 even
color2_token:
 dc.l $ff8244
 dc.w $7f00|Default_WORD
 dc.b 'COLOR2',0
 even
color3_token:
 dc.l $ff8246
 dc.w $7f00|Default_WORD
 dc.b 'COLOR3',0
 even
colo4_token:
 dc.l $ff8248
 dc.w $7f00|Default_WORD
 dc.b 'COLOR4',0
 even
color5_token:
 dc.l $ff824a
 dc.w $7f00|Default_WORD
 dc.b 'COLOR5',0
 even
color6_token:
 dc.l $ff824c
 dc.w $7f00|Default_WORD
 dc.b 'COLOR6',0
 even
color7_token:
 dc.l $ff824e
 dc.w $7f00|Default_WORD
 dc.b 'COLOR7',0
 even
color8_token:
 dc.l $ff8250
 dc.w $7f00|Default_WORD
 dc.b 'COLOR8',0
 even
color9_token:
 dc.l $ff8252
 dc.w $7f00|Default_WORD
 dc.b 'COLOR9',0
 even
color10_token:
 dc.l $ff8254
 dc.w $7f00|Default_WORD
 dc.b 'COLOR10',0
 even
color11_token:
 dc.l $ff8256
 dc.w $7f00|Default_WORD
 dc.b 'COLOR11',0
 even
color12_token:
 dc.l $ff8258
 dc.w $7f00|Default_WORD
 dc.b 'COLOR12',0
 even
color13_token:
 dc.l $ff825a
 dc.w $7f00|Default_WORD
 dc.b 'COLOR13',0
 even
color14_token:
 dc.l $ff825c
 dc.w $7f00|Default_WORD
 dc.b 'COLOR14',0
 even
color15_token:
 dc.l $ff825e
 dc.w $7f00|Default_WORD
 dc.b 'COLOR15',0
 even

; memory

memconf_token:
 dc.l $ff8001
 dc.w $7f00|Default_BYTE
 dc.b 'MEMCONF',0
 even

; screen
dbaseh_token:
 dc.l $ff8201
 dc.w $7f00|Default_BYTE
 dc.b 'DBASEH',0
 even
dbasem_token:
 dc.l $ff8203
 dc.w $7f00|Default_BYTE
 dc.b 'DBASEM',0
 even
dbasel_token:
 dc.l $ff820d
 dc.w $7f00|Default_BYTE
 dc.b 'DBASEL',0
 even
vcounthi_token:
 dc.l $ff8205
 dc.w $7f00|Default_BYTE
 dc.b 'VCOUNTHI',0
 even
vcountmid_token:
 dc.l $ff8207
 dc.w $7f00|Default_BYTE
 dc.b 'VCOUNTMID',0
 even
vcountlo:
 dc.l $ff8209
 dc.w $7f00|Default_BYTE
 dc.b 'VCOUNTLO',0
 even
syncmode_token:
 dc.l $ff820a
 dc.w $7f00|Default_BYTE
 dc.b 'SYNCMODE',0
 even
shiftmode_token:
 dc.l $ff8260
 dc.w $7f00|Default_BYTE
 dc.b 'SHIFTMODE',0
 even
hscroll_token:
 dc.l $ff8265
 dc.w $7f00|Default_BYTE
 dc.b 'HSCROLL',0
 even
linewid_token:
 dc.l $ff820f
 dc.w $7f00|Default_BYTE
 dc.b 'LINEWID',0
 even

; blitter

halftone0_token:
 dc.l $ff8a00
 dc.w $7f00|Default_WORD
 dc.b 'HALFTONE0',0
 even
halftone1_token:
 dc.l $ff8a02
 dc.w $7f00|Default_WORD
 dc.b 'HALFTONE1',0
 even
halftone2_token:
 dc.l $ff8a04
 dc.w $7f00|Default_WORD
 dc.b 'HALFTONE2',0
 even
halftone3_token:
 dc.l $ff8a06
 dc.w $7f00|Default_WORD
 dc.b 'HALFTONE3',0
 even
halftone4_token:
 dc.l $ff8a08
 dc.w $7f00|Default_WORD
 dc.b 'HALFTONE4',0
 even
halftone5_token:
 dc.l $ff8a0a
 dc.w $7f00|Default_WORD
 dc.b 'HALFTONE5',0
 even
halftone6_token:
 dc.l $ff8a0c
 dc.w $7f00|Default_WORD
 dc.b 'HALFTONE6',0
 even
halftone7_token:
 dc.l $ff8a0e
 dc.w $7f00|Default_WORD
 dc.b 'HALFTONE7',0
 even
halftone8_token:
 dc.l $ff8a10
 dc.w $7f00|Default_WORD
 dc.b 'HALFTONE8',0
 even
halftone9_token:
 dc.l $ff8a12
 dc.w $7f00|Default_WORD
 dc.b 'HALFTONE9',0
 even
halftone10_token:
 dc.l $ff8a14
 dc.w $7f00|Default_WORD
 dc.b 'HALFTONE10',0
 even
halftone11_token:
 dc.l $ff8a16
 dc.w $7f00|Default_WORD
 dc.b 'HALFTONE11',0
 even
halftone12_token:
 dc.l $ff8a18
 dc.w $7f00|Default_WORD
 dc.b 'HALFTONE12',0
 even
halftone13_token:
 dc.l $ff8a1a
 dc.w $7f00|Default_WORD
 dc.b 'HALFTONE13',0
 even
halftone14_token:
 dc.l $ff8a1c
 dc.w $7f00|Default_WORD
 dc.b 'HALFTONE14',0
 even
halftone15_token:
 dc.l $ff8a1e
 dc.w $7f00|Default_WORD
 dc.b 'HALFTONE15',0
 even
src_xinc_token:
 dc.l $ff8a20
 dc.w $7f00|Default_WORD
 dc.b 'SCR_XINC',0
 even
src_yinc_token:
 dc.l $ff8a22
 dc.w $7f00|Default_WORD
 dc.b 'SCR_YINC',0
 even
scr_addr_token:
 dc.l $ff8a24
 dc.w $7f00|Default_LONG
 dc.b 'SRC_ADDR',0
 even
endmask1_token:
 dc.l $ff8a28
 dc.w $7f00|Default_WORD
 dc.b 'ENDMASK1',0
 even
endmask2_token:
 dc.l $ff8a2a
 dc.w $7f00|Default_WORD
 dc.b 'ENDMASK2',0
 even
endmask3_token:
 dc.l $ff8a2c
 dc.w $7f00|Default_WORD
 dc.b 'ENDMASK3',0
 even
dst_xinc_token:
 dc.l $ff8a2e
 dc.w $7f00|Default_WORD
 dc.b 'DST_XINC',0
 even
dst_yinc_token:
 dc.l $ff8a30
 dc.w $7f00|Default_WORD
 dc.b 'DST_YINC',0
 even
dst_addr_token:
 dc.l $ff8a32
 dc.w $7f00|Default_LONG
 dc.b 'DST_ADDR',0
 even
x_count_token:
 dc.l $ff8a36
 dc.w $7f00|Default_WORD
 dc.b 'X_COUNT',0
 even
y_count_token:
 dc.l $ff8a38
 dc.w $7f00|Default_WORD
 dc.b 'Y_COUNT',0
 even
hop_token:
 dc.l $ff8a3a
 dc.w $7f00|Default_BYTE
 dc.b 'HOP',0
 even
op_token:
 dc.l $ff8a3b
 dc.w $7f00|Default_BYTE
 dc.b 'OP',0
 even

; mfp
gpip_token:
 dc.l $fffa01
 dc.w $7f00|Default_BYTE
 dc.b 'GPIP',0
 even
aer_token:
 dc.l $fffa03
 dc.w $7f00|Default_BYTE
 dc.b 'AER',0
 even
ddr_token:
 dc.l $fffa05
 dc.w $7f00|Default_BYTE
 dc.b 'DDR',0
 even
iera_token:
 dc.l $fffa07
 dc.w $7f00|Default_BYTE
 dc.b 'IERA',0
 even
ierb_token:
 dc.l $fffa09
 dc.w $7f00|Default_BYTE
 dc.b 'IERB',0
 even
ipra_token:
 dc.l $fffa0b
 dc.w $7f00|Default_BYTE
 dc.b 'IPRA',0
 even
iprb_token:
 dc.l $fffa0d
 dc.w $7f00|Default_BYTE
 dc.b 'IPRB',0
 even
isra_token:
 dc.l $fffa0f
 dc.w $7f00|Default_BYTE
 dc.b 'ISRA',0
 even
isrb_token:
 dc.l $fffa11
 dc.w $7f00|Default_BYTE
 dc.b 'ISRB',0
 even
imra_token:
 dc.l $fffa13
 dc.w $7f00|Default_BYTE
 dc.b 'IMRA',0
 even
imrb_token:
 dc.l $fffa15
 dc.w $7f00|Default_BYTE
 dc.b 'IMRB',0
 even
vr_token:
 dc.l $fffa17
 dc.w $7f00|Default_BYTE
 dc.b 'VR',0
 even
tacr_token:
 dc.l $fffa19
 dc.w $7f00|Default_BYTE
 dc.b 'TACR',0
 even
tbcr_token:
 dc.l $fffa1b
 dc.w $7f00|Default_BYTE
 dc.b 'TBCR',0
 even
tcdcr_token:
 dc.l $fffa1d
 dc.w $7f00|Default_BYTE
 dc.b 'TCDCR',0
 even
tadr_token:
 dc.l $fffa1f
 dc.w $7f00|Default_BYTE
 dc.b 'TADR',0
 even
tbdr_token:
 dc.l $fffa21
 dc.w $7f00|Default_BYTE
 dc.b 'TBDR',0
 even
tcdr_token:
 dc.l $fffa23
 dc.w $7f00|Default_BYTE
 dc.b 'TCDR',0
 even
tddr_token:
 dc.l $fffa25
 dc.w $7f00|Default_BYTE
 dc.b 'TDDR',0
 even
scr_token:
 dc.l $fffa27
 dc.w $7f00|Default_BYTE
 dc.b 'SCR',0
 even
ucr_token:
 dc.l $fffa29
 dc.w $7f00|Default_BYTE
 dc.b 'UCR',0
 even
rsr_token:
 dc.l $fffa2b
 dc.w $7f00|Default_BYTE
 dc.b 'RSR',0
 even
tsr_token:
 dc.l $fffa2d
 dc.w $7f00|Default_BYTE
 dc.b 'TSR',0
 even
udr_token:
 dc.l $fffa2f
 dc.w $7f00|Default_BYTE
 dc.b 'UDR',0
 even

; keyboard

keyctl_token:
 dc.l $fffc00
 dc.w $7f00|Default_BYTE
 dc.b 'KEYCTL',0
 even
keybd_token:
 dc.l $fffc02
 dc.w $7f00|Default_BYTE
 dc.b 'KEYBD',0
 even
midictl_token:
 dc.l $fffc04
 dc.w $7f00|Default_BYTE
 dc.b 'MIDICTL',0
 even
midi_token:
 dc.l $fffc06
 dc.w $7f00|Default_BYTE
 dc.b 'MIDI',0
 even

; dma

diskctl_token:
 dc.l $ff8604
 dc.l $7f00|Default_WORD
 dc.b 'DISKCTL',0
 even
fifo_token:
 dc.l $ff8606
 dc.w $7f00|Default_WORD
 dc.b 'FIFO',0
 even
dmahigh_token:
 dc.l $ff8609
 dc.w $7f00|Default_BYTE
 dc.b 'DMAHIGH',0
 even
dmamid_token:
 dc.l $ff860b
 dc.w $7f00|Default_BYTE
 dc.b 'DMAMID',0
 even
dmalow_token:
 dc.l $ff860b
 dc.w $7f00|Default_BYTE
 dc.b 'DMALOW',0
 even

; sound

giselect_token:
 dc.l $ff8800
 dc.w $7f00|Default_WORD
 dc.b 'GISELECT',0
 even
giread_token:
 dc.l $ff8800
 dc.w $7f00|Default_WORD
 dc.b 'GIREAD',0
 even
giwrite_token:
 dc.l $ff8802
 dc.w $7f00|Default_WORD
 dc.b 'GIWRITE',0
 even

; STE joysticks

joy_fire_token:
 dc.l $ff9200
 dc.w $7f00|Default_WORD
 dc.b 'JOY_FIRE',0
 even
joy_pos_token:
 dc.l $ff9202
 dc.w $7f00|Default_WORD
 dc.b 'JOY_POS',0
 even
joy0_x_token:
 dc.l $ff9210
 dc.w $7f00|Default_WORD
 dc.b 'JOY0_X',0
 even
joy0_y_token:
 dc.l $ff9212
 dc.w $7f00|Default_WORD
 dc.b 'JOY0_Y',0
 even
joy1_x_token:
 dc.l $ff9214
 dc.w $7f00|Default_WORD
 dc.b 'JOY1_X',0
 even
joy1_y_token:
 dc.l $ff9216
 dc.w $7f00|Default_WORD
 dc.b 'JOY1_Y',0
 even
joy2_x_token:
 dc.l $ff9220
 dc.w $7f00|Default_WORD
 dc.b 'JOY2_X',0
 even
joy2_y_token:
 dc.l $ff9222
 dc.w $7f00|Default_WORD
 dc.b 'JOY2_Y',0  
 even

; STE DMA sound

dma_sound_e_token:
 dc.l $ff8900
 dc.w $7f00|Default_WORD
 dc.b 'DMA_SOUND_E',0
 even
fbasehi_token:
 dc.l $ff8902
 dc.w $7f00|Default_WORD
 dc.b 'FBASEHI',0
 even
fbasemid_token:
 dc.l $ff8904
 dc.w $7f00|Default_WORD
 dc.b 'FBASEMID',0
 even
fbaselow_token:
 dc.l $ff8906
 dc.w $7f00|Default_WORD
 dc.b 'FBASELOW',0
 even
cbasehi_token:
 dc.l $ff8908
 dc.w $7f00|Default_WORD
 dc.b 'CBASEHI',0
 even
cbasemid_token:
 dc.l $ff890a
 dc.w $7f00|Default_WORD
 dc.b 'CBASEMID',0
 even
cbaselow_token:
 dc.l $ff890c
 dc.w $7f00|Default_WORD
 dc.b 'CBASELOW',0
 even
ebasehi_token:
 dc.l $ff890e
 dc.w $7f00|Default_WORD
 dc.b 'EBASEHI',0
 even
ebasemid_token:
 dc.l $ff8910
 dc.w $7f00|Default_WORD
 dc.b 'EBASEMID',0
 even
ebaselow_token:
 dc.l $ff8912
 dc.w $7f00|Default_WORD
 dc.b 'EBASELOW',0
 even
sound_ctrl_token:
 dc.l $ff8920
 dc.w $7f00|Default_WORD
 dc.b 'SOUND_CTRL',0
 even
sound_data_token:
 dc.l $ff8922
 dc.w $7f00|Default_WORD
 dc.b 'SOUND_DATA',0
 even
sound_mask_token:
 dc.l $ff8924
 dc.w $7f00|Default_WORD
 dc.b 'SOUND_MASK',0
 ENDC	;d'ATARIST
 even
 dc.l 0

;  #] I/O tokens:
;  #[ Evaluation tokens:

; left shift*, right shift*, not*, or*, xor*, and*, div, mul*, minus*
; plus*, equal*, different*, sup equal*, inf equal*, inf*, sup*
; logical and*, logical or*, affect*, plus equal*, minus equal*, mulu equal*
; divu equal*, not equal*, lsl equal*, lsr equal*, or equal*, and equal*
; eor equal*
operators_table:
 dc.w '<<'|$0000,'>>'|$0000,' ~'|$0000,' |'|$0000,' ^'|$0000,' &'|$0000
 dc.w ' /'|$0000,' *'|$0000,' -'|$0000,' +'|$0000,' <'|$0000,' >'|$0000
 dc.w '=='|$0000,'!='|$0000,'>='|$0000,'<='|$0000,'L='|$8000,'R='|$8000
 dc.w '|='|$8000,'^='|$8000,'&='|$8000,'~='|$8000,'/='|$8000,'*='|$8000
 dc.w '-='|$8000,'+='|$8000,' ='|$8000,'&&'|$0000,'||'|$0000,0

eot_table:
 dc.b 33-1
 dc.b ' ',',',':','?','"',"'",'.',')',']','}','+','-','*','$','\',9
 dc.b '/','^','&','|','~','!','<','>','=','(','[','{',';','%','@','#',0
 even
;  #] Evaluation tokens:
;	 #] Evaluator:
;	 #[ Terminal stuff:
controls:	dc.b	0,$5e,'v><..@........................'
;	 #] Terminal stuff:
;	 #[ Key Table:
 EVEN
;  #[ Treat Instruction:
;In:
;ds d0 le code clavier :shift|scan|0|ascii
;shift|scan|0|ascii
;Out:
;d0=function result
;d1=-1->function doesn't exist
_treat_instruction:
	swap	d0
	lea	keys_table(pc),a0
	bra.s	.2
.1:
	addq.w	#4,a0
.2:
	move.w	(a0)+,d1
	beq.s	.not_found
	cmp.w	d1,d0
	bne.s	.1
.found:
	swap	d0
	move.l	a0,a5
	tst.b	rec_mac_flag(a6)
	beq.s	.no_record
	bsr	recording_mac2
.no_record:
	move.l	(a5),a0
;	add.l	start_adb_addr(a6),a0
	jsr	(a0)
	moveq	#0,d1
	bra.s	.end
.not_found:
	moveq	#-1,d1
.end:
	rts

;KEYSMAC	MACRO
;	dc.w	\1
;	dc.l	\2-A_Debug
;	ENDR
;  #] Treat Instruction:
	IFEQ	cartouche
	SET_ID	KEYS_MAGIC
	ENDC
keys_table:
;		#[ Spec keys:
	IFNE	debug
	dc.w	$0052 ;[Insert]
	dc.l	monkey_test
 ENDC ; de debug
 dc.w $0001 ;[Esc]
 dc.l esc
 dc.w $000f ;[Tab]
 dc.l tab
 dc.w $0062 ;[Help]
 dc.l help
 dc.w $0039 ;[Space]
 dc.l shift_down
 dc.w $0139 ;[Sft_Space]
 dc.l shift_up

 dc.w $0048 ;[Up]
 dc.l up
 dc.w $0060 ;[<]
 dc.l up
 dc.w $0050 ;[Down]
 dc.l down
 dc.w $0160 ;[>]
 dc.l down
 dc.w $0148 ;[Sft_Up]
 dc.l shift_up
 dc.w $0150 ;[Sft_Down]
 dc.l shift_down
 dc.w $004b ;[Left]
 dc.l left
 dc.w $004d ;[Right]
 dc.l right
 dc.w $014b ;[Sft_Left]
 dc.l shift_left
 dc.w $014d ;[Sft_Right]
 dc.l shift_right
 dc.w $0009 ;[!]
 dc.l call_shell
 dc.w $0061 ;[Undo]
 dc.l eval_help
 dc.w $0070	; [0]=reg
 dc.l set_wind_type_0
 dc.w $006D	; [1]=dis
 dc.l set_wind_type_1
 dc.w $006E	; [2]=hex
 dc.l set_wind_type_2
 dc.w $006F	; [3]=asc
 dc.l set_wind_type_3
 dc.w $006A	; [4]=log
 dc.l set_wind_type_4
 IFNE sourcedebug
 dc.w $006B	; [5]=src
 dc.l set_wind_type_5
 dc.w $006C	; [6]=var
 dc.l set_wind_type_6
 dc.w $0067	; [7]=ins
 dc.l set_wind_type_7

 dc.w $0477	; [Ctl_Home]
 dc.l begin_of_source
 dc.w $0577	; [Sft_Ctl_Home]
 dc.l end_of_source
 ENDC ;de sourcedebug
;		#] Spec keys:
;		#[ Function keys:
 dc.w $003B ;[F1]
 dc.l set_mark
 dc.w $003C ;[F2]
 dc.l exchange_mark
 IFNE ATARIST
 dc.w $0042 ;[F8]
 dc.l f8
 dc.w $0043 ;[F9]
 dc.l f9
 dc.w $0044 ;[F10]
 dc.l f10
 ENDC ; d'ATARIST
 IFNE	daniel_version
 dc.w	$0041 ;[F7]
 dc.l	change_vbl_stop_flag
 dc.w	$0042 ;[F8]
 dc.l	force_redraw_relock
 dc.w	$0043 ;[F9]
 dc.l	change_trace_task_flag
 ENDC	;de daniel_version
;		#] Function keys:
;		#[ French keyboard:
	IFNE	french_kbd
;		#[ Plain keys:
 dc.w $0010 ;[A]
 dc.l set_new_address
 dc.w $002e ;[C]
 dc.l copy_memory
 dc.w $0020 ;[D]
 dc.l cd
 dc.w $0012 ;[E]
 dc.l ask_expression
 dc.w $0021 ;[F]
 dc.l fill_memory
 dc.w $0022 ;[G]
 dc.l search
 dc.w $0023 ;[H]
 dc.l show_story
 dc.w $0017 ;[I]
 dc.l update_sr
 dc.w $0024 ;[J]
 dc.l jump_to
 dc.w $0025 ;[K]
 dc.l keep_registers
 dc.w $0026 ;[L]
 dc.l show_variables
 dc.w $0027 ;[M]
 dc.l mac_menu
 dc.w $0031 ;[N]
 dc.l next
 dc.w $0018 ;[O]
 dc.l output_to
 dc.w $0013 ;[R]
 dc.l restore_registers
 dc.w $0014 ;[T]
 dc.l trace
 dc.w $0016 ;[U]
 dc.l run_until
 dc.w $002f ;[V]
 dc.l view
 dc.w $002c ;[W]
 dc.l watch_subroutine
 dc.w $012c ;[Sft_W]
 dc.l sft_watch

 IFEQ bridos
 dc.w $0030 ;[B]
 dc.l load_binary
 dc.w $001F ;[S]
 dc.l save_binary
 dc.w $0019 ;[P]
 dc.l print_bloc
 ENDC ;de bridos
 IFNE sourcedebug
 dc.w $002B
 dc.l ask_source_line_nb
 ENDC ;de sourcedebug
;		#] Plain keys:
;		#[ Ctl keys:
 dc.w $0410 ;[Ctl_A]
 dc.l ctrl_a
 dc.w $0430 ;[Ctl_B]
 dc.l ctrl_b
 dc.w $042E ;[Ctl_C]
 dc.l ctrl_c
 IFNE ATARIST
 dc.w $0420 ;[Ctl_D]
 dc.l ask_system_break
 ENDC
 dc.w $0412 ;[Ctl_E]
 dc.l ask_catch_exceptions
 dc.w $0421 ;[Ctl_F]
 dc.l force_branch
 IFNE sourcedebug
 dc.w $0417 ;[Ctl_I]
 dc.l set_inspect
 ENDC ;de sourcedebug
 dc.w $0424 ;[Ctl_J]
 dc.l jump_to_curwind
 dc.w $0425 ;[Ctl_K]
 dc.l kill_all_breaks
 IFEQ	bridos
 IFEQ	residant
 dc.w $0426 ;[Ctl_L]
 dc.l load_prg
 ENDC	; de residant
 ENDC	; de bridos
 IFNE AMIGA
 dc.w $0427
 dc.l multitasking
 ENDC ;d'AMIGA
 IFNE ATARIST
 dc.w $0418 ;[Ctl_O]
 dc.l ctrl_o
 ENDC
 dc.w $0419 ;[Ctl_P]
 dc.l ask_preferences
 dc.w $0413 ;[Ctl_R]
 dc.l ctrl_r
 dc.w $041f ;[Ctl_S]
 dc.l ctrl_s
 dc.w $0414 ;[Ctl_T]
 dc.l fly_on
 dc.w $0416 ;[Ctl_U]
 dc.l run_until_curwind
 dc.w $042F ;[Ctl_V]
 dc.l load_all_vars
 dc.w $042d ;[Ctl_X]
 dc.l break_end
 dc.w $0411 ;[Ctl_Z]
 dc.l ctrl_z

 dc.w $0448
 dc.l ctrl_up
 dc.w $0450
 dc.l ctrl_down
 dc.w $0473
 dc.l ctrl_left
 dc.w $0474
 dc.l ctrl_right
 dc.w $044b
 dc.l ctrl_left
 dc.w $044d
 dc.l ctrl_right
 IFEQ bridos
 dc.w $0429
 dc.l load_play_mac
 ENDC

 dc.w $0470 ;[Ctl_0]
 dc.l ctrl_0
 dc.w $040B
 dc.l ctrl_0

 dc.w $046D
 dc.l ctrl_1
 dc.w $0402
 dc.l ctrl_1

 dc.w $046E
 dc.l ctrl_2
 dc.w $0403
 dc.l ctrl_2

 dc.w $046F
 dc.l ctrl_3
 dc.w $0404
 dc.l ctrl_3

 dc.w $046A
 dc.l ctrl_4
 dc.w $0405
 dc.l ctrl_4

 dc.w $046B
 dc.l ctrl_5
 dc.w $0406
 dc.l ctrl_5

 dc.w $046C
 dc.l ctrl_6
 dc.w $0407
 dc.l ctrl_6

 dc.w $0467
 dc.l ctrl_7
 dc.w $0408
 dc.l ctrl_7

 dc.w $0468
 dc.l ctrl_8
 dc.w $0409
 dc.l ctrl_8

 dc.w $0469
 dc.l ctrl_9
 dc.w $040A
 dc.l ctrl_9

 dc.w $0570
 dc.l sctrl_0
 dc.w $050B
 dc.l sctrl_0

 dc.w $056D ;[Sft_Ctl_0]
 dc.l sctrl_1
 dc.w $0502
 dc.l sctrl_1

 dc.w $056E
 dc.l sctrl_2
 dc.w $0503
 dc.l sctrl_2

 dc.w $056F
 dc.l sctrl_3
 dc.w $0504
 dc.l sctrl_3

 dc.w $056A
 dc.l sctrl_4
 dc.w $0505
 dc.l sctrl_4

 dc.w $056B
 dc.l sctrl_5
 dc.w $0506
 dc.l sctrl_5

 dc.w $056C
 dc.l sctrl_6
 dc.w $0507
 dc.l sctrl_6

 dc.w $0567
 dc.l sctrl_7
 dc.w $0508
 dc.l sctrl_7

 dc.w $0568
 dc.l sctrl_8
 dc.w $0509
 dc.l sctrl_8

 dc.w $0569
 dc.l sctrl_9
 dc.w $050A
 dc.l sctrl_9

 IFNE	ATARIST
 dc.w $052E ;[Sft_Ctl_C]
 dc.l gem_term
 ENDC	;d'ATARIST
;		#] Ctl keys:
;		#[ Alt keys:
 IFEQ bridos
 dc.w $0810 ;[Alt_A]
 dc.l load_ascii
 ENDC

 dc.w $0830 ;[Alt_B]
 dc.l ask_break
 IFNE AMIGA
 dc.w $082e ;[Alt_C]
 dc.l set_copperlist
 ENDC
 dc.w $0820 ;[Alt_D]
 dc.l show_dir
 dc.w $0812 ;[Alt_E]
 dc.l alt_e
 IFNE AMIGA
 dc.w $0817 ;[Alt_I]
 dc.l update_intena
 ENDC ;d'AMIGA
 dc.w $0826 ;[Alt_L]
 dc.l lock_window
 dc.w $0827 ;[Alt_M]
 dc.l print_memfree
 dc.w $0831 ;[Alt_N]
 dc.l previous
 dc.w $0819 ;[Alt_P]
 dc.l print_window
 dc.w $0813 ;[Alt_R]
 dc.l reset_profiler
 dc.w $081f ;[Alt_S]
 dc.l alt_s
 dc.w $0814 ;[Alt_T]
 dc.l alt_t
 IFEQ bridos
 dc.w $082F ;[Alt_V]
 dc.l new_variable
 ENDC
 dc.w $082d ;[Alt_X]
 dc.l return_fast
 dc.w $0811 ;[Alt_Z]
 dc.l alt_z

 dc.w $082b ;[Alt_@]
 dc.l copyright
 dc.w $0878 ;[Alt_1]
 dc.l alt_1
 dc.w $086D
 dc.l alt_1
 dc.w $0879
 dc.l alt_2
 dc.w $086E
 dc.l alt_2
 dc.w $087A
 dc.l alt_3
 dc.w $086F
 dc.l alt_3
 dc.w $087B
 dc.l alt_4
 dc.w $086A
 dc.l alt_4
 dc.w $087C
 dc.l alt_5
 dc.w $086B
 dc.l alt_5

 dc.w $0862 ;[Alt_Help]
 dc.l screen_dump

 dc.w $0920 ;[Sft_Alt_D]
 dc.l show_any_dir
 IFNE	AMIGA
 dc.w $092e ;[Sft_Alt_C]
 dc.l reloc_copperlist
 dc.w $0912 ;[Sft_Alt_E]
 dc.l reloc_screen
 IFNE	daniel_version
 dc.w	$0917 ;[Sft_Alt_I]
 dc.l	amiga_internal_infos
 ENDC
 ENDC	;d'AMIGA

 IFNE sourcedebug
 dc.w $091F ;[Sft_Alt_S]
 dc.l show_stack
 ENDC ;de sourcedebug
;		#] Alt keys:
;		#[ Ctl Alt keys:
 dc.w $0C30 ;[Ctl_Alt_B]
 dc.l show_breaks
 dc.w $0c20 ;[Ctl_Alt_D]
 dc.l ctrl_alt_d
 IFNE AMIGA
 dc.w $0c2e ;[Ctl_Alt_C]
 dc.l reset_copperlist
 ENDC
 IFNE _68030
 dc.w $0C21 ;[Ctl_Alt_F]
 dc.l show_frame
 ENDC ; de _68030
 IFNE sourcedebug
 dc.w $0C22 ;[Ctl_Alt_G]
 dc.l set_global_type
 ENDC
 dc.w $0C17 ;[Ctl_Alt_I]
 dc.l not_palette
 dc.w $0C24 ;[Ctl_Alt_J]
 dc.l call_user_subroutine
 dc.w $0D24 ;[Sft_Ctl_Alt_J]
 dc.l call_super_subroutine
 IFNE sourcedebug
 dc.w $0C26 ;[Ctl_Alt_L]
 dc.l set_local_type
 ENDC
 dc.w $0C19 ;[Ctl_Alt_P]
 dc.l manual_prinfo
 dc.w $0C13 ;[Ctl_Alt_R]
 dc.l reserve_from
 IFNE sourcedebug
 dc.w $0C1F ;[Ctl_Alt_S]
 dc.l set_static_type
 ENDC
 IFNE	AMIGA
 dc.w $0C14 ;[Ctl_Alt_T]
 dc.l show_tasks
 ENDC
 dc.w $0C2F ;[Ctl_Alt_V]
 dc.l load_prg_vars
 dc.w $0C11 ;[Ctl_Alt_Z]
 dc.l trace_t1
 dc.w $0c53 ;[Ctl_Alt_Del]
 dc.l warm_reset
 dc.w $0d53 ;[Sft_Ctl_Alt_Del]
 dc.l cold_reset

 dc.w $0C78
 dc.l ctl_alt_1 ;[Ctl_Alt_1]
 dc.w $0C6D
 dc.l ctl_alt_1
 dc.w $0C79
 dc.l ctl_alt_2
 dc.w $0C6E
 dc.l ctl_alt_2
 dc.w $0C7A
 dc.l ctl_alt_3
 dc.w $0C6F
 dc.l ctl_alt_3
 dc.w $0C7B
 dc.l ctl_alt_4
 dc.w $0C6A
 dc.l ctl_alt_4
 dc.w $0C7C
 dc.l ctl_alt_5
 dc.w $0C6B
 dc.l ctl_alt_5
;		#] Ctl Alt keys:
 dc.l 0
 ENDC ; de french_kbd
;		#] French keyboard:
;		#[ English keyboard:
 IFNE english_kbd
;		#[ Plain keys:
 dc.w $001e ;[A]
 dc.l set_new_address
 dc.w $002e ;[C]
 dc.l copy_memory
 dc.w $0020 ;[D]
 dc.l cd
 dc.w $0012 ;[E]
 dc.l ask_expression
 dc.w $0021 ;[F]
 dc.l fill_memory
 dc.w $0022 ;[G]
 dc.l search
 dc.w $0023 ;[H]
 dc.l show_story
 dc.w $0017 ;[I]
 dc.l update_sr
 dc.w $0024 [J]
 dc.l jump_to
 dc.w $0025 [K]
 dc.l keep_registers
 dc.w $0026 [L]
 dc.l show_variables
 dc.w $0032 [M]
 dc.l mac_menu
 dc.w $0031 [N]
 dc.l next
 dc.w $0018 [O]
 dc.l output_to
 dc.w $0013 [R]
 dc.l restore_registers
 dc.w $0014 [T]
 dc.l trace
 dc.w $0016 [U]
 dc.l run_until
 dc.w $002f [V]
 dc.l view
 dc.w $0011 [W]
 dc.l watch_subroutine
 dc.w $0111 [Sft_W]
 dc.l sft_watch

 IFEQ bridos
 dc.w $0030 ;[B]
 dc.l load_binary
 dc.w $001F ;[S]
 dc.l save_binary
 dc.w $0019 ;[P]
 dc.l print_bloc
 ENDC ;de bridos
 IFNE sourcedebug
 dc.w $0104
 dc.l ask_source_line_nb
 ENDC ;de sourcedebug
;		#] Plain keys:
;		#[ Ctl keys:
 dc.w $041e ;[Ctl_A]
 dc.l ctrl_a
 dc.w $0430 ;[Ctl_B]
 dc.l ctrl_b
 dc.w $042E ;[Ctl_C]
 dc.l ctrl_c
 IFNE ATARIST
 dc.w $0420 ;[Ctl_D]
 dc.l ask_system_break
 ENDC
 dc.w $0412 ;[Ctl_E]
 dc.l ask_catch_exceptions
 dc.w $0421 ;[Ctl_F]
 dc.l force_branch
 IFNE sourcedebug
 dc.w $0417 ;[Ctl_I]
 dc.l set_inspect
 ENDC ;de sourcedebug
 dc.w $0424 ;[Ctl_J]
 dc.l jump_to_curwind
 dc.w $0425 ;[Ctl_K]
 dc.l kill_all_breaks
 IFEQ	bridos
 IFEQ	residant
 dc.w $0426 ;[Ctl_L]
 dc.l load_prg
 ENDC
 ENDC
 IFNE AMIGA
 dc.w $0427
 dc.l multitasking
 ENDC ;d'AMIGA
 IFNE ATARIST
 dc.w $0418 ;[Ctl_O]
 dc.l ctrl_o
 ENDC
 dc.w $0419 ;[Ctl_P]
 dc.l ask_preferences
 dc.w $0413 ;[Ctl_R]
 dc.l ctrl_r
 dc.w $041f ;[Ctl_S]
 dc.l ctrl_s
 dc.w $0414 ;[Ctl_T]
 dc.l fly_on
 dc.w $0416 ;[Ctl_U]
 dc.l run_until_curwind
 dc.w $042F ;[Ctl_V]
 dc.l load_all_vars
 dc.w $042d ;[Ctl_X]
 dc.l break_end
 dc.w $042C ;[Ctl_Z]
 dc.l ctrl_z

 dc.w $0448
 dc.l ctrl_up
 dc.w $0450
 dc.l ctrl_down
 dc.w $0473
 dc.l ctrl_left
 dc.w $0474
 dc.l ctrl_right
 dc.w $044b
 dc.l ctrl_left
 dc.w $044d
 dc.l ctrl_right
 IFEQ bridos
 dc.w $0429
 dc.l load_play_mac
 ENDC

 dc.w $0470 ;[Ctl_0]
 dc.l ctrl_0
 dc.w $040B
 dc.l ctrl_0

 dc.w $046D
 dc.l ctrl_1
 dc.w $0402
 dc.l ctrl_1

 dc.w $046E
 dc.l ctrl_2
 dc.w $0403
 dc.l ctrl_2

 dc.w $046F
 dc.l ctrl_3
 dc.w $0404
 dc.l ctrl_3

 dc.w $046A
 dc.l ctrl_4
 dc.w $0405
 dc.l ctrl_4

 dc.w $046B
 dc.l ctrl_5
 dc.w $0406
 dc.l ctrl_5

 dc.w $046C
 dc.l ctrl_6
 dc.w $0407
 dc.l ctrl_6

 dc.w $0467
 dc.l ctrl_7
 dc.w $0408
 dc.l ctrl_7

 dc.w $0468
 dc.l ctrl_8
 dc.w $0409
 dc.l ctrl_8

 dc.w $0469
 dc.l ctrl_9
 dc.w $040A
 dc.l ctrl_9

 dc.w $0570
 dc.l sctrl_0
 dc.w $050B
 dc.l sctrl_0

 dc.w $056D ;[Sft_Ctl_0]
 dc.l sctrl_1
 dc.w $0502
 dc.l sctrl_1

 dc.w $056E
 dc.l sctrl_2
 dc.w $0503
 dc.l sctrl_2

 dc.w $056F
 dc.l sctrl_3
 dc.w $0504
 dc.l sctrl_3

 dc.w $056A
 dc.l sctrl_4
 dc.w $0505
 dc.l sctrl_4

 dc.w $056B
 dc.l sctrl_5
 dc.w $0506
 dc.l sctrl_5

 dc.w $056C
 dc.l sctrl_6
 dc.w $0507
 dc.l sctrl_6

 dc.w $0567
 dc.l sctrl_7
 dc.w $0508
 dc.l sctrl_7

 dc.w $0568
 dc.l sctrl_8
 dc.w $0509
 dc.l sctrl_8

 dc.w $0569
 dc.l sctrl_9
 dc.w $050A
 dc.l sctrl_9

 IFNE	ATARIST
 dc.w $052E ;[Sft_Ctl_C]
 dc.l gem_term
 ENDC	;d'ATARIST
;		#] Ctl keys:
;		#[ Alt keys:
 IFEQ bridos
 dc.w $081e ;[Alt_A]
 dc.l load_ascii
 ENDC

 dc.w $0830 ;[Alt_B]
 dc.l ask_break
 IFNE AMIGA
 dc.w $082e ;[Alt_C]
 dc.l set_copperlist
 ENDC
 dc.w $0820 ;[Alt_D]
 dc.l show_dir
 dc.w $0812 ;[Alt_E]
 dc.l alt_e
 IFNE AMIGA
 dc.w $0817 ;[Alt_I]
 dc.l update_intena
 ENDC ;d'AMIGA
 dc.w $0826 ;[Alt_L]
 dc.l lock_window
 dc.w $0832 ;[Alt_M]
 dc.l print_memfree
 dc.w $0831 ;[Alt_N]
 dc.l previous
 dc.w $0819 ;[Alt_P]
 dc.l print_window
 dc.w $081f ;[Alt_S]
 dc.l alt_s
 dc.w $0814 ;[Alt_T]
 dc.l alt_t
 IFEQ bridos
 dc.w $082F ;[Alt_V]
 dc.l new_variable
 ENDC
 dc.w $082d ;[Alt_X]
 dc.l return_fast
 dc.w $082c ;[Alt_Z]
 dc.l alt_z

 dc.w $082b ;[Alt_@]
 dc.l copyright
 dc.w $0878 ;[Alt_1]
 dc.l alt_1
 dc.w $086D
 dc.l alt_1
 dc.w $0879
 dc.l alt_2
 dc.w $086E
 dc.l alt_2
 dc.w $087A
 dc.l alt_3
 dc.w $086F
 dc.l alt_3
 dc.w $087B
 dc.l alt_4
 dc.w $086A
 dc.l alt_4
 dc.w $087C
 dc.l alt_5
 dc.w $086B
 dc.l alt_5

 dc.w $0862 ;[Sft_Alt_Help]
 dc.l screen_dump

 dc.w $0920 ;[Sft_Alt_D]
 dc.l show_any_dir
 IFNE	AMIGA
 dc.w $092e ;[Sft_Alt_C]
 dc.l reloc_copperlist
 dc.w $0912 ;[Sft_Alt_E]
 dc.l reloc_screen
 IFNE	daniel_version
 dc.w	$0917 ;[Sft_Alt_I]
 dc.l	amiga_internal_infos
 ENDC
 ENDC	;d'AMIGA

 IFNE sourcedebug
 dc.w $091F ;[Sft_Alt_S]
 dc.l show_stack
 ENDC ;de sourcedebug
;		#] Alt keys:
;		#[ Ctl Alt keys:
 dc.w $0c20 ;[Ctl_Alt_D]
 dc.l ctrl_alt_d
 dc.w $0C30 ;[Ctl_Alt_B]
 dc.l show_breaks
 IFNE AMIGA
 dc.w $0c2e ;[Ctl_Alt_C]
 dc.l reset_copperlist
 ENDC
 IFNE _68030
 dc.w $0C21 ;[Ctl_Alt_F]
 dc.l show_frame
 ENDC ; de _68030
 IFNE sourcedebug
 dc.w $0C22 ;[Ctl_Alt_G]
 dc.l set_global_type
 ENDC
 dc.w $0C17 ;[Ctl_Alt_I]
 dc.l not_palette
 dc.w $0C24 ;[Ctl_Alt_J]
 dc.l call_user_subroutine
 dc.w $0D24 ;[Sft_Ctl_Alt_J]
 dc.l call_super_subroutine
 IFNE sourcedebug
 dc.w $0C26 ;[Ctl_Alt_L]
 dc.l set_local_type
 ENDC
 dc.w $0C19 ;[Ctl_Alt_P]
 dc.l manual_prinfo
 dc.w $0C13 ;[Ctl_Alt_R]
 dc.l reserve_from
 IFNE sourcedebug
 dc.w $0C1F ;[Ctl_Alt_S]
 dc.l set_static_type
 ENDC
 IFNE	AMIGA
 dc.w $0C14 ;[Ctl_Alt_T]
 dc.l tasks
 ENDC
 dc.w $0C2F ;[Ctl_Alt_V]
 dc.l load_prg_vars
 dc.w $042C ;[Ctl_Alt_Z]
 dc.l trace_t1
 dc.w $0c53 ;[Ctl_Alt_Del]
 dc.l warm_reset
 dc.w $0d53 ;[Sft_Ctl_Alt_Del]
 dc.l cold_reset

 dc.w $0C78
 dc.l ctl_alt_1 ;[Ctl_Alt_1]
 dc.w $0C6D
 dc.l ctl_alt_1
 dc.w $0C79
 dc.l ctl_alt_2
 dc.w $0C6E
 dc.l ctl_alt_2
 dc.w $0C7A
 dc.l ctl_alt_3
 dc.w $0C6F
 dc.l ctl_alt_3
 dc.w $0C7B
 dc.l ctl_alt_4
 dc.w $0C6A
 dc.l ctl_alt_4
 dc.w $0C7C
 dc.l ctl_alt_5
 dc.w $0C6B
 dc.l ctl_alt_5
;		#] Ctl Alt keys:
 dc.l 0
 ENDC ; de english_kbd
;		#] English keyboard:
;		#[ German keyboard:
 IFNE german_kbd
;		#[ Plain keys:
 dc.w $001e ;[A]
 dc.l set_new_address
 dc.w $002e ;[C]
 dc.l copy_memory
 dc.w $0020 ;[D]
 dc.l cd
 dc.w $0012 ;[E]
 dc.l ask_expression
 dc.w $0021 ;[F]
 dc.l fill_memory
 dc.w $0022 ;[G]
 dc.l search
 dc.w $0023 ;[H]
 dc.l show_story
 dc.w $0017 ;[I]
 dc.l update_sr
 dc.w $0024 [J]
 dc.l jump_to
 dc.w $0025 [K]
 dc.l keep_registers
 dc.w $0026 [L]
 dc.l show_variables
 dc.w $0032 [M]
 dc.l mac_menu
 dc.w $0031 [N]
 dc.l next
 dc.w $0018 [O]
 dc.l output_to
 dc.w $0013 [R]
 dc.l restore_registers
 dc.w $0014 [T]
 dc.l trace
 dc.w $0016 [U]
 dc.l run_until
 dc.w $002f [V]
 dc.l view
 dc.w $0011 [W]
 dc.l watch_subroutine
 dc.w $0111 [Sft_W]
 dc.l sft_watch

 IFEQ bridos
 dc.w $0030 ;[B]
 dc.l load_binary
 dc.w $001F ;[S]
 dc.l save_binary
 dc.w $0019 ;[P]
 dc.l print_bloc
 ENDC ;de bridos
;		#] Plain keys:
;		#[ Ctl keys:
 dc.w $041e ;[Ctl_A]
 dc.l ctrl_a
 dc.w $0430 ;[Ctl_B]
 dc.l ctrl_b
 dc.w $042E ;[Ctl_C]
 dc.l ctrl_c
 IFNE ATARIST
 dc.w $0420 ;[Ctl_D]
 dc.l ask_system_break
 ENDC
 dc.w $0412 ;[Ctl_E]
 dc.l ask_catch_exceptions
 dc.w $0421 ;[Ctl_F]
 dc.l force_branch
 dc.w $0424 ;[Ctl_J]
 dc.l jump_to_curwind
 dc.w $0425 ;[Ctl_K]
 dc.l kill_all_breaks
 IFEQ	bridos
 IFEQ	residant
 dc.w $0426 ;[Ctl_L]
 dc.l load_prg
 ENDC
 ENDC
 IFNE ATARIST
 dc.w $0418 ;[Ctl_O]
 dc.l ctrl_o
 ENDC
 dc.w $0419 ;[Ctl_P]
 dc.l ask_preferences
 dc.w $0413 ;[Ctl_R]
 dc.l ctrl_r
 dc.w $041f ;[Ctl_S]
 dc.l ctrl_s
 dc.w $0414 ;[Ctl_T]
 dc.l fly_on
 dc.w $0416 ;[Ctl_U]
 dc.l run_until_curwind
 dc.w $042F ;[Ctl_V]
 dc.l load_all_vars
 dc.w $042C ;[Ctl_Z]
 dc.l ctrl_z
 dc.w $042d ;[Ctl_X]
 dc.l break_end

 dc.w $0448
 dc.l ctrl_up
 dc.w $0450
 dc.l ctrl_down
 dc.w $0473
 dc.l ctrl_left
 dc.w $0474
 dc.l ctrl_right
 dc.w $044b
 dc.l ctrl_left
 dc.w $044d
 dc.l ctrl_right

 IFEQ bridos
 dc.w $0429
 dc.l load_play_mac
 ENDC

 dc.w $0470 ;[Ctl_0]
 dc.l ctrl_0
 dc.w $040B
 dc.l ctrl_0

 dc.w $046D
 dc.l ctrl_1
 dc.w $0402
 dc.l ctrl_1

 dc.w $046E
 dc.l ctrl_2
 dc.w $0403
 dc.l ctrl_2

 dc.w $046F
 dc.l ctrl_3
 dc.w $0404
 dc.l ctrl_3

 dc.w $046A
 dc.l ctrl_4
 dc.w $0405
 dc.l ctrl_4

 dc.w $046B
 dc.l ctrl_5
 dc.w $0406
 dc.l ctrl_5

 dc.w $046C
 dc.l ctrl_6
 dc.w $0407
 dc.l ctrl_6

 dc.w $0467
 dc.l ctrl_7
 dc.w $0408
 dc.l ctrl_7

 dc.w $0468
 dc.l ctrl_8
 dc.w $0409
 dc.l ctrl_8

 dc.w $0469
 dc.l ctrl_9
 dc.w $040A
 dc.l ctrl_9

 dc.w $0570
 dc.l sctrl_0
 dc.w $050B
 dc.l sctrl_0

 dc.w $056D ;[Sft_Ctl_0]
 dc.l sctrl_1
 dc.w $0502
 dc.l sctrl_1

 dc.w $056E
 dc.l sctrl_2
 dc.w $0503
 dc.l sctrl_2

 dc.w $056F
 dc.l sctrl_3
 dc.w $0504
 dc.l sctrl_3

 dc.w $056A
 dc.l sctrl_4
 dc.w $0505
 dc.l sctrl_4

 dc.w $056B
 dc.l sctrl_5
 dc.w $0506
 dc.l sctrl_5

 dc.w $056C
 dc.l sctrl_6
 dc.w $0507
 dc.l sctrl_6

 dc.w $0567
 dc.l sctrl_7
 dc.w $0508
 dc.l sctrl_7

 dc.w $0568
 dc.l sctrl_8
 dc.w $0509
 dc.l sctrl_8

 dc.w $0569
 dc.l sctrl_9
 dc.w $050A
 dc.l sctrl_9
;		#] Ctl keys:
;		#[ Alt keys:
 IFEQ bridos
 dc.w $081e ;[Alt_A]
 dc.l load_ascii
 ENDC

 dc.w $0830 ;[Alt_B]
 dc.l ask_break
 IFNE AMIGA
 dc.w $082e ;[Alt_C]
 dc.l set_copperlist
 ENDC
 dc.w $0820 ;[Alt_D]
 dc.l show_dir
 dc.w $0812 ;[Alt_E]
 dc.l alt_e
 IFEQ bridos
 dc.w $0821 ;[Alt_F]
 dc.l ask_menu_file
 ENDC
 dc.w $0826 ;[Alt_L]
 dc.l lock_window
 dc.w $0832 ;[Alt_M]
 dc.l print_memfree
 dc.w $0831 ;[Alt_N]
 dc.l previous
 dc.w $0819 ;[Alt_P]
 dc.l print_window
 dc.w $081f ;[Alt_S]
 dc.l alt_s
 dc.w $0814 ;[Alt_T]
 dc.l alt_t
 IFEQ bridos
 dc.w $082F ;[Alt_V]
 dc.l new_variable
 ENDC
 dc.w $082d ;[Alt_X]
 dc.l return_fast
 dc.w $082c ;[Alt_Z]
 dc.l alt_z

 dc.w $082b ;[Alt_@]
 dc.l copyright
 dc.w $0878 ;[Alt_1]
 dc.l alt_1
 dc.w $086D
 dc.l alt_1
 dc.w $0879
 dc.l alt_2
 dc.w $086E
 dc.l alt_2
 dc.w $087A
 dc.l alt_3
 dc.w $086F
 dc.l alt_3
 dc.w $087B
 dc.l alt_4
 dc.w $086A
 dc.l alt_4
 dc.w $087C
 dc.l alt_5
 dc.w $086B
 dc.l alt_5

 dc.w $0862 ;[Alt_Help]
 dc.l screen_dump

 dc.w $0920 ;[Sft_Alt_D]
 dc.l show_any_dir
 IFNE sourcedebug
 dc.w $091F ;[Sft_Alt_S]
 dc.l show_stack
 ENDC ;de sourcedebug
;		#] Alt keys:
;		#[ Ctl Alt keys:
 dc.w $0c20 ;[Ctl_Alt_D]
 dc.l ctrl_alt_d
 dc.w $0C30 ;[Ctl_Alt_B]
 dc.l show_breaks
 IFNE AMIGA
 dc.w $0c2e ;[Ctl_Alt_C]
 dc.l reset_copperlist
 ENDC
 IFNE _68030
 dc.w $0C21 ;[Ctl_Alt_F]
 dc.l show_frame
 ENDC ; de _68030
 IFNE sourcedebug
 dc.w $0C22 ;[Ctl_Alt_G]
 dc.l set_global_type
 ENDC
 dc.w $0C17 ;[Ctl_Alt_I]
 dc.l not_palette
 dc.w $0C24 ;[Ctl_Alt_J]
 dc.l call_user_subroutine
 dc.w $0D24 ;[Sft_Ctl_Alt_J]
 dc.l call_super_subroutine
 IFNE sourcedebug
 dc.w $0C26 ;[Ctl_Alt_L]
 dc.l set_local_type
 ENDC
 dc.w $0C19 ;[Ctl_Alt_P]
 dc.l manual_prinfo
 dc.w $0C13 ;[Ctl_Alt_R]
 dc.l reserve_from
 IFNE sourcedebug
 dc.w $0C1F ;[Ctl_Alt_S]
 dc.l set_static_type
 ENDC
 dc.w $0C2F ;[Ctl_Alt_V]
 dc.l load_prg_vars
 dc.w $0C11 ;[Ctl_Alt_W]
 dc.l trace_t1
 dc.w $0C15 ;[Ctl_Alt_Y]
 dc.l trace_t1
 dc.w $0C2c ;[Ctl_Alt_Z]
 dc.l trace_t1
 dc.w $0c53 ;[Ctl_Alt_Del]
 dc.l warm_reset
 dc.w $0d53 ;[Sft_Ctl_Alt_Del]
 dc.l cold_reset

 dc.w $0C78
 dc.l ctl_alt_1 ;[Ctl_Alt_1]
 dc.w $0C6D
 dc.l ctl_alt_1
 dc.w $0C79
 dc.l ctl_alt_2
 dc.w $0C6E
 dc.l ctl_alt_2
 dc.w $0C7A
 dc.l ctl_alt_3
 dc.w $0C6F
 dc.l ctl_alt_3
 dc.w $0C7B
 dc.l ctl_alt_4
 dc.w $0C6A
 dc.l ctl_alt_4
 dc.w $0C7C
 dc.l ctl_alt_5
 dc.w $0C6B
 dc.l ctl_alt_5
;		#] Ctl Alt keys:
 dc.l 0
 ENDC ; de german_kbd
;		#] German keyboard:
;	 #] Key Table:
;	 #[ Cartridge manager:
	IFNE	cartouche&mmanager
Magic_start_txt:	dc.b	"Adebug Cartridge v2.00 Copyright 1993 (c)",0
TOS_txt:		dc.b	"Install TOS Y/n ? ",0
Malloc_txt:	dc.b	"      Malloc BSS Y/n ? ",0
BSS_txt:		dc.b	"      BSS Address:$",0
Yes_txt:		dc.b	"Y",0
No_txt:		dc.b	"N",0
Key_table: 	dc.b	$ff,$1B,'1','2','3','4','5','6'
		dc.b	'7','8','9','0',$3F,'_',$08,$09
		dc.b	'A','Z','E','R','T','Y','U','I'
		dc.b	'O','P',$b9,'*',$0D,$ff,'Q','S'
		dc.b	'D','F','G','H','J','K','L','M'
		dc.b	'%','|',$ff,'>','W','X','C','V'
		dc.b	'B','N','?','.','/','+',$ff,$ff
		dc.b	$ff,' ',$ff,$ff,$ff,$ff,$ff,$ff
		dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		dc.b	$ff,$ff,'-',$ff,$ff,$ff,'+',$ff
		dc.b	$ff,$ff,$ff,$7f,$ff,$ff,$ff,$ff
		dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		dc.b	$ff,$80,$81,'(',')','/','*','7'
		dc.b	'8','9','4','5','6','1','2','3'
		dc.b	'0','.',$0d,$ff,$ff,$ff,$ff,$ff
		dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	ENDC
;	 #] Cartridge manager:
;	 #[ Reserved: no de serie (en NOT+SWAP)
;serial_number:	dc.l ~$56781234	;Abr/Bern/Cany
;serial_number:	dc.l ~$00010000	;Loic
;serial_number:	dc.l ~$00020000	;Hard&Soft
;serial_number:	dc.l ~$00030000	;Cany
serial_number:	dc.l ~$00000000	;2.1
;	 #] Reserved:
end_of_data:
;  #] Section Data:
;  #[ Section Bss:
	IFEQ	cartouche
	bss
	even
start_of_bss:
;  #[ Internal & external a6: (not for cartridge version)
internal_a6:	ds.l	1
external_a6:	ds.l	1
exit_error_number:	ds.w	1
;  #] Internal & external a6:
	IFNE	MTOS
sys_stack:	ds.l	1
		ds.b	4096
mtos_stack:	ds.l	1
	ENDC
	IFNE	accessoire
;  #[ Acc_stuff:

 even
		ds.l 200
acc_stack:	ds.l 1
		ds.l 200
acc_stack2:	ds.l 1
Ap_id:		ds.w 1
Messagebuf:	ds.b 16
Control:	ds.w 11
Global:		ds.w 15
Int_in:		ds.w 128
Int_out:	ds.w 128
Addr_in:	ds.l 64
Addr_out:	ds.l 64
evnt_multi_sem:	ds.w	1
external_keyboard:	ds.l	1
io_ikbd:	ds.l	1
ksh_addr:	ds.l	1

;  #] Acc_stuff:
	ENDC	;d'accessoire
	ENDC	;de cartouche
end_of_bss:
	offset	0
	IFNE	cartouche
;  #[ External a6: (for cartridge)
cart_external_a6:	ds.l	1
;  #] External a6:
	ENDC
start_adb_addr:	ds.l	1
;  #[ Stack:
reserved_stack_addr:	ds.l	1
top_stack_addr:		ds.l	1
check_stack_addr:	ds.l	1
tri_sp:			ds.l	1
;  #] Stack:
	IFNE	AMIGA
	include	"amigbss.s"
	ENDC
;  #[ My dta:
	IFNE	ATARIST
my_dta:	ds.b	DTA_BUFFER_SIZE
	ENDC
	even
old_dta:	ds.l	1
piped_file:	ds.b	8+1+3+1
	even
;  #] My dta:
;  #[ Miscellaneous buffers:
	; #[ Source stuff:
	IFNE	sourcedebug
	IFNE	turbodebug
tcdebug_head:	ds.l	1
l1_len:	ds.l	1
l2_len:	ds.l	1
l3_len:	ds.l	1
l4_len:	ds.l	1
l5_len:	ds.l	1
l6_len:	ds.l	1
tcnames_len:	ds.l	1

tcdebug_len:	ds.l	1

tcdebug_ptr:	ds.l	1
l1_ptr:	ds.l	1
l2_ptr:	ds.l	1
l3_ptr:	ds.l	1
l4_ptr:	ds.l	1
l5_ptr:	ds.l	1
l6_ptr:	ds.l	1
tcnames_ptr:	ds.l	1

	;affichage fenetre type variables
tcfirst_info_flag:	ds.b	1
tcline_aborted_flag:	ds.b	1
tcline_ended_flag:	ds.b	1
			ds.b	1
tcvarbuffer_size:	ds.l	1

;nb max de chaque type de var
tcvars_max_table:
inners_max:	ds.l	1
locals_max:	ds.l	1
statics_max:	ds.l	1
globals_max:	ds.l	1
cdefs_max:	ds.l	1

;sous-types fonctions/cdefs
funcs_nb:	ds.l	1
funcs_array_ptr:	ds.l	1
datas_nb:	ds.l	1
datas_array_ptr:	ds.l	1
cdefs_nb:	ds.l	1
cdefs_array_ptr:	ds.l	1

	ENDC	;de TC_DEBUG

;pointeurs/nb sur les diverses structures l3 courantes
;tcvars_l3_table:
inners_l3_ptr:	ds.l	1
inners_nb:	ds.l	1
locals_l3_ptr:	ds.l	1
locals_nb:	ds.l	1
statics_l3_ptr:	ds.l	1
statics_nb:	ds.l	1
globals_nb:	ds.l	1

;ptrs sur les sections globals/statics/locals du tableau de ptrs
globals_array_ptr:	ds.l	1
statics_array_ptr:	ds.l	1
locals_array_ptr:	ds.l	1

;ptr sur le debut du tableau, taille du tableau (=Somme des max)
allvars_array_size:	ds.l	1
allvars_array_ptr:	ds.l	1

curwind_columns:	ds.l	1
sourcedebug_info_ptr:	ds.l	1
source_len:		ds.l	1
source_ptr:		ds.l	1
source_lines_nb:	ds.l	1
source_name_addr:	ds.l	1
main_source_len:	ds.l	1
main_source_ptr:	ds.l	1
source_pc_ptr:		ds.l	1
old_source_pc_ptr:	ds.l	1
old_pc_vars:		ds.l	1
source_breaks_addr:	ds.l	1
source_block_addr:	ds.l	1
end_source_block_addr:	ds.l	1
start_debug_usp:	ds.l	1
start_debug_ssp:	ds.l	1
debug_usp_size:		ds.l	1
false_internal_var:	ds.b	VAR_SIZE
src_line_format_buf:	ds.b	_src_line_format_end-src_line_format_text
not_in_block_flag:	ds.b	1
step_over_flag:		ds.b	1
;inspect_flag:	ds.b	1
	even
	ENDC	;de sourcedebug
	; #] Source stuff:
	; #[ Empty string:
	even
empty_string:	ds.b	204
	; #] Empty string:
	; #[ My header:
	even
my_header:	ds.b	$1c
	; #] My header:
	; #[ Sprintf line:
	even
sprintf_line:	ds.b	40
	; #] Sprintf line:
	IFNE accessoire
	; #[ False_basepage:
	even
false_basepage:	ds.b	$100
	; #] False_basepage:
	ENDC
	; #[ Machine name buf:
mch_name_buf:	ds.b	40
	; #] Machine name buf:
	; #[ Exec name buf:
exec_name_buf:	ds.b	200
	; #] Exec name buf:
	; #[ Line buffer:
line_buffer:	ds.b	200
tmp_buffer:	ds.b	200
	; #] Line buffer:
	; #[ Lower level buffer:
lower_level_buffer:	ds.b	200
	; #] Lower level buffer:
	; #[ My line:
	even
my_line:	ds.b	200
	; #] My line:
	; #[ Sscanf out buffer:
	even
sscanf_outbuffer:	ds.b	200
	; #] Sscanf out buffer:
	; #[ Sscanf int buffer:
	even
sscanf_intbuffer:	ds.b	200
	; #] Sscanf int buffer:
	; #[ Printm buffer:
	even
printm_buffer:	ds.b	200
	; #] Printm buffer:
	; #[ Printerror buffer:
	even
printerror_buffer:	ds.b	200
	; #] Printerror buffer:
	; #[ Print_presskey buffer:
	even
print_presskey_buffer:	ds.b	200
	; #] Print_presskey buffer:
	; #[ Get expression buffer:
	even
get_expression_buffer:	ds.b	200
	; #] Get expression buffer:
	; #[ Edit ascii undo buffer:
	even
edit_ascii_undo_buffer:	ds.b	200
	; #] Edit ascii undo buffer:
	; #[ Edit ascii undo 2 buffer:
	even
edit_ascii_undo2_buffer:	ds.b	200
	; #] Edit ascii undo 2 buffer:
	; #[ yes_no buffer:
	even
yes_no_buffer:	ds.b	200
	; #] yes_no buffer:
	; #[ File buffer:
	even
file_buffer:	ds.b	200
	; #] File buffer:
	; #[ Higher level buffer:
	even
higher_level_buffer:	ds.b	200
	; #] Higher level buffer:
	; #[ Watchdog buffer:
;watchdog_buffer:	ds.b	200
	; #] Watchdog buffer:
	; #[ Permanent break buffer:
permbreak_buffer:	ds.b	200
	; #] Permanent break buffer:
	; #[ Misc name buf:
misc_name_buf:	ds.b	200
	; #] Misc name buf:
;  #] Miscellaneous buffers:
;  #[ Miscellaneous p0 datas:
;	 #[ Rom datas:
	even
machine_type:	ds.w	1
	IFNE	(ATARIST|ATARITT)&MTOS
mint_vers:	ds.l	1
	ENDC	;ATARIST|ATARITT
screen_size:	ds.l	1
main_clock:	ds.w	1
reserve_from_addr:	ds.l	1
osnumber:	ds.w	1
v_number:	ds.w	1
my_vbl_addr:	ds.l	1
rdebug_vbl:	ds.l	1
external_cart_a6:	ds.l	1
external_vblq_nb:	ds.w	1
_404_error:	ds.w	1
_sysbase:	ds.l	1
tos_p0_basepage_addr:	ds.l	1
p0_basepage_addr:	ds.l	1
line_a_basepage:	ds.l	1
screen_size_y:	ds.w	1
line_size:	ds.w	1
line_len:	ds.w	1
column_len:	ds.w	1
line_buffer_size:	ds.w	1
kbshift_addr:	ds.l	1
keytbl_addr:	ds.l	1
keytbl_descriptor:	ds.l	3
font8x16_addr:	ds.l	1
font8x8_addr:	ds.l	1
montype:	ds.w	1
monmask:	ds.w	1
;newplan:	ds.w	1
;oldvptr:	ds.l	1
;	 #] Rom datas:
;	 #[ Initial:
	even
VIDEO_SIZE	equ	36
initial_vmode:	ds.w	1
initial_ssp:	ds.l	1
initial_ipl:	ds.w	1
initial_sr:	ds.w	1
initial_vbr:	ds.l	1
initial_trap1:	ds.l	1
initial_trap13:	ds.l	1
initial_etvcritic:	ds.l	1
initial_kbdvec:	ds.l	1
initial_path:	ds.b	256
;Initial switch
	even
initial_buffer:
initial_linef:	ds.l	1
initial_trap2:	ds.l	1
initial_planes:	ds.w	1
initial_max_x:	ds.w	1
initial_max_cell_x:	ds.w	1
initial_logbase:	ds.l	1
initial_palette:	ds.l	16
initial_rez:	ds.w	1			;or vmode
initial_video:	ds.b	VIDEO_SIZE
initial_frequency:	ds.b	1
initial_keyconf:	ds.b	1
	even
initial_mfp_ctl_struct:
	ds.b	1				;TA enable
	ds.b	1				;TB enable
	ds.b	1				;TC enable
	ds.b	1				;TD enable
	IFNE	ATARITT
initial_mfp2_ctl_struct:
	ds.b	1				;TA enable
	ds.b	1				;TB enable
	ds.b	1				;TC enable
	ds.b	1				;TD enable
	ENDC	ATARITT
	even
initial_mfp_speed_struct:
	ds.b	1				;TA
	ds.b	1				;TB
	ds.b	1				;TC
	ds.b	1				;TD
	IFNE	ATARITT
initial_mfp2_speed_struct:
	ds.b	1				;TA
	ds.b	1				;TB
	ds.b	1				;TC
	ds.b	1				;TD
	ENDC	ATARITT
initial_end:
INITIAL_SIZE	equ	initial_end-initial_buffer	;=138
;	 #] Initial:
;	 #[ External:
	even
logbase:	ds.l	1
external_tos_basepage_addr:	ds.l	1
	IFNE	ATARIST
external_palette:		ds.l	2
external_rez:		ds.w	1	;or vmode
external_low_base:		ds.b	1
external_line_width:	ds.b	1
external_hscroll:		ds.b	1
external_frequency:		ds.b	1
	even
external_trap1:		ds.l	1
external_trap13:		ds.l	1
external_kbdvec:		ds.l	1
external_etvcritic:		ds.l	1
external_trapd_buffer_addr:	ds.l	1
external_repeat_addr:	ds.l	1
external_video:		ds.b	VIDEO_SIZE
	ENDC
;buffer de contexte temporaire
;d0-a5
tmp_context_buffer:	ds.l	8+6
	
;buffer de contexte externe
external_context_buffer:
d0_buf:	ds.l 1
d1_buf:	ds.l 1
d2_buf:	ds.l 1
d3_buf:	ds.l 1
d4_buf:	ds.l 1
d5_buf:	ds.l 1
d6_buf:	ds.l 1
d7_buf:	ds.l 1
a0_buf:	ds.l 1
a1_buf:	ds.l 1
a2_buf:	ds.l 1
a3_buf:	ds.l 1
a4_buf:	ds.l 1
a5_buf:	ds.l 1
a6_buf:	ds.l 1
a7_buf:	ds.l 1
ssp_buf:	ds.l 1
sr_buf:	ds.w 1
pc_buf:	ds.l 1
	IFNE	_68030
isp_buf:	ds.l	1
msp_buf:	ds.l	1
vbr_buf:	ds.l	1
sfc_buf:	ds.w	1
dfc_buf:	ds.w	1
cacr_buf:	ds.l	1
caar_buf:	ds.l	1
crp_buf:	ds.l	2
srp_buf:	ds.l	2
tc_buf:	ds.l	1
tt0_buf:	ds.l	1
tt1_buf:	ds.l	1
mmusr_buf:	ds.w	1
fp0_buf:	ds.l	3
fp1_buf:	ds.l	3
fp2_buf:	ds.l	3
fp3_buf:	ds.l	3
fp4_buf:	ds.l	3
fp5_buf:	ds.l	3
fp6_buf:	ds.l	3
fp7_buf:	ds.l	3
fpcr_buf:	ds.l	1
fpsr_buf:	ds.l	1
fpiar_buf:	ds.l	1
	ENDC	; de _68030
	even
external_mfp_ctl_struct:
	ds.b	1				;TA enable
	ds.b	1				;TB enable
	ds.b	1				;TC enable
	ds.b	1				;TD enable
	IFNE	ATARITT
external_mfp2_ctl_struct:
	ds.b	1				;TA enable
	ds.b	1				;TB enable
	ds.b	1				;TC enable
	ds.b	1				;TD enable
	ENDC	;ATARITT
	even
external_mfp_speed_struct:
	ds.b	1				;TA
	ds.b	1				;TB
	ds.b	1				;TC
	ds.b	1				;TD
	IFNE	ATARITT
external_mfp2_speed_struct:
	ds.b	1				;TA
	ds.b	1				;TB
	ds.b	1				;TC
	ds.b	1				;TD
	ENDC
;	 #] External:
;	 #[ Internal:
internal_memory_base:	ds.l	1
initial_physbase:		ds.l	1
physbase:			ds.l	1
font_addr:		ds.l	1
internal_usp:		ds.l	1
internal_ssp:		ds.l	1
internal_sr:		ds.w	1
internal_rez:		ds.w	1
internal_palette:		ds.l	2
	IFNE	ATARIST
internal_video:		ds.b	VIDEO_SIZE
internal_frequency:		ds.b	1
	even
internal_mfp_ctl_struct:
	ds.b	1				;TA enable
	ds.b	1				;TB enable
	ds.b	1				;TC enable
	ds.b	1				;TD enable
	IFNE	ATARITT
internal_mfp2_ctl_struct:
	ds.b	1				;TA enable
	ds.b	1				;TB enable
	ds.b	1				;TC enable
	ds.b	1				;TD enable
	ENDC	; d'ATARITT
	even
internal_mfp_speed_struct:
	ds.b	1				;TA
	ds.b	1				;TB
	ds.b	1				;TC
	ds.b	1				;TD
	IFNE	ATARITT
internal_mfp2_speed_struct:
	ds.b	1				;TA
	ds.b	1				;TB
	ds.b	1				;TC
	ds.b	1				;TD
	ENDC	; d'ATARITT
	even
;---
	ds.b	46
internal_trapd_buffer:	;au-dessus
;---
internal_trap2_buffer:
	ds.b	74
internal_trap2_return_opcode:	ds.w	1
	ENDC
;	 #] Internal:
;  #] Miscellaneous p0 datas:
;  #[ Registers datas:

; flags d'etoiles
 even
save_d0_buf:	ds.l 1
save_d1_buf:	ds.l 1
save_d2_buf:	ds.l 1
save_d3_buf:	ds.l 1
save_d4_buf:	ds.l 1
save_d5_buf:	ds.l 1
save_d6_buf:	ds.l 1
save_d7_buf:	ds.l 1
save_a0_buf:	ds.l 1
save_a1_buf:	ds.l 1
save_a2_buf:	ds.l 1
save_a3_buf:	ds.l 1
save_a4_buf:	ds.l 1
save_a5_buf:	ds.l 1
save_a6_buf:	ds.l 1
save_a7_buf:	ds.l 1
save_ssp_buf:	ds.l 1
save_sr_buf:	ds.w 1
save_pc_buf:	ds.l 1
 IFNE _68030
save_isp_buf:	ds.l 1
save_msp_buf:	ds.l 1
save_vbr_buf:	ds.l 1
save_sfc_buf:	ds.w 1
save_dfc_buf:	ds.w 1
save_cacr_buf:	ds.l 1
save_caar_buf:	ds.l 1
save_crp_buf:	ds.l 2
save_srp_buf:	ds.l 2
save_tc_buf:	ds.l 1
save_tt0_buf:	ds.l 1
save_tt1_buf:	ds.l 1
save_mmusr_buf:	ds.w 1
save_fp0_buf:	ds.l 3
save_fp1_buf:	ds.l 3
save_fp2_buf:	ds.l 3
save_fp3_buf:	ds.l 3
save_fp4_buf:	ds.l 3
save_fp5_buf:	ds.l 3
save_fp6_buf:	ds.l 3
save_fp7_buf:	ds.l 3
save_fpcr_buf:	ds.l 1
save_fpsr_buf:	ds.l 1
save_fpiar_buf:	ds.l 1
 ENDC			; de _68030

; flags d'etoiles pour la(es) fenetre(s) des registres

d0_flag:	ds.b 1
d1_flag:	ds.b 1
d2_flag:	ds.b 1
d3_flag:	ds.b 1
d4_flag:	ds.b 1
d5_flag:	ds.b 1
d6_flag:	ds.b 1
d7_flag:	ds.b 1
a0_flag:	ds.b 1
a1_flag:	ds.b 1
a2_flag:	ds.b 1
a3_flag:	ds.b 1
a4_flag:	ds.b 1
a5_flag:	ds.b 1
a6_flag:	ds.b 1
a7_flag:	ds.b 1
ssp_flag:	ds.b 1
pc_flag:	ds.b 1
sr_flag:	ds.b 1
 IFNE _68030
isp_flag:	ds.b 1
msp_flag:	ds.b 1
vbr_flag:	ds.b 1
sfc_flag:	ds.b 1
dfc_flag:	ds.b 1
cacr_flag:	ds.b 1
caar_flag:	ds.b 1
crp_flag:	ds.b 1
srp_flag:	ds.b 1
tc_flag:	ds.b 1
tt0_flag:	ds.b 1
tt1_flag:	ds.b 1
mmusr_flag:	ds.b 1
fp0_flag:	ds.b 1
fp1_flag:	ds.b 1
fp2_flag:	ds.b 1
fp3_flag:	ds.b 1
fp4_flag:	ds.b 1
fp5_flag:	ds.b 1
fp6_flag:	ds.b 1
fp7_flag:	ds.b 1
fpcr_flag:	ds.b 1
fpsr_flag:	ds.b 1
fpiar_flag:	ds.b 1
 ENDC	; de _68030

a0_asc_flag:	ds.b 1
a1_asc_flag:	ds.b 1
a2_asc_flag:	ds.b 1
a3_asc_flag:	ds.b 1
a4_asc_flag:	ds.b 1
a5_asc_flag:	ds.b 1
a6_asc_flag:	ds.b 1
a7_asc_flag:	ds.b 1

 IFNE _68030
fp0_float_flag:	ds.b 1
fp1_float_flag:	ds.b 1
fp2_float_flag:	ds.b 1
fp3_float_flag:	ds.b 1
fp4_float_flag:	ds.b 1
fp5_float_flag:	ds.b 1
fp6_float_flag:	ds.b 1
fp7_float_flag:	ds.b 1
 ENDC

 even

keep_d0_buf:	ds.l 1
keep_d1_buf:	ds.l 1
keep_d2_buf:	ds.l 1
keep_d3_buf:	ds.l 1
keep_d4_buf:	ds.l 1
keep_d5_buf:	ds.l 1
keep_d6_buf:	ds.l 1
keep_d7_buf:	ds.l 1
keep_a0_buf:	ds.l 1
keep_a1_buf:	ds.l 1
keep_a2_buf:	ds.l 1
keep_a3_buf:	ds.l 1
keep_a4_buf:	ds.l 1
keep_a5_buf:	ds.l 1
keep_a6_buf:	ds.l 1
keep_a7_buf:	ds.l 1
keep_ssp_buf:	ds.l 1
keep_pc_buf:	ds.l 1
keep_sr_buf:	ds.w 1

 IFNE _68030
keep_isp_buf:	ds.l 1
keep_msp_buf:	ds.l 1
keep_vbr_buf:	ds.l 1
keep_sfc_buf:	ds.w 1
keep_dfc_buf:	ds.w 1
keep_cacr_buf:	ds.l 1
keep_caar_buf:	ds.l 1
keep_crp_buf:	ds.l 2
keep_srp_buf:	ds.l 2
keep_tc_buf:	ds.l 1
keep_tt0_buf:	ds.l 1
keep_tt1_buf:	ds.l 1
keep_mmusr_buf:	ds.w 1
keep_fp0_buf:	ds.l 3
keep_fp1_buf:	ds.l 3
keep_fp2_buf:	ds.l 3
keep_fp3_buf:	ds.l 3
keep_fp4_buf:	ds.l 3
keep_fp5_buf:	ds.l 3
keep_fp6_buf:	ds.l 3
keep_fp7_buf:	ds.l 3
keep_fpcr_buf:	ds.l 1
keep_fpsr_buf:	ds.l 1
keep_fpiar_buf:	ds.l 1
 ENDC			; de _68030

;  #] Registers datas:
;  #[ Reloc datas:
	even
exec_type:
	;EXEC_NO (Binaire)		= 0
	;EXEC_LINK (reloc type)		= 1
	;EXEC_PRG (reloc GEMDOS)	= 2
	;EXEC_ACC (reloc GEMDOS)	= 3
	;EXEC_RES (reloc GEMDOS)	= 4
	ds.w	1
reloc_type:
	;RELOC_NO (Binaire)		= 0
	;RELOC_GEMDOS			= 1
	;RELOC_DRI			= 2
	;RELOC_GST			= 3
	;RELOC_TC				= 4
	;RELOC_LC				= 5
	;RELOC_MWC			= 6
	;RELOC_MLC			= 7
	ds.w	1
source_type:
	;SOURCE_DRIH			= 0
	;SOURCE_S				= 1
	;SOURCE_PC			= 2
	;SOURCE_BSD			= 3
	;SOURCE_LC			= 4
	;SOURCE_MOD			= 5
	ds.w	1
argc:	ds.w	1
argv_buffer:
	IFNE	ATARIST
	ds.b	200
	ENDC	;d'ATARI
	IFNE	AMIGA
	ds.b	$100
	ENDC	;d'AMIGA
	even
exec_sym_nb:	ds.l	1
exec_timestamp:	ds.l	1

text_buf:	ds.l	1
data_buf:	ds.l	1
bss_buf:	ds.l	1
sym_buf:	ds.l	1
end_buf:	ds.l	1

text_size:	ds.l	1
data_size:	ds.l	1
bss_size:	ds.l	1
sym_size:	ds.l	1

p1_basepage_addr:	ds.l	1
	IFEQ	bridos
p1_disk_len:	ds.l	1
p1_mem_len:	ds.l	1
p1_prg_end:	ds.l	1
p1_dri_len:	ds.l	1
	ENDC

	ds.b	1024			;stack itself
pterm_stack:
	ds.l	1			;ssp
	ds.w	1			;sr
	ds.l	1			;pc
	ds.l	10			;d1-a2

ro_child_struct:			;child_struct:
	ds.l	1			;pc
	ds.l	1			;a0 (ro_struct/shell cmd_line)
	ds.l	1			;a1 (@ des parametres)
	ds.l	1			;d0 (nb de par)
	ds.b	1			;debug mode (0=no debug/-1=debug)
	ds.b	1			;user state (0=user/-1=super)
	ds.b	1			;use traps (0=no/-1=yes)
	ds.b	1			;free ro after use (0=no/-1=yes)

;  #] Reloc datas:
;  #[ Exceptions save buffer:
	even
exceptions_save_buffer:
;de bus error a $140 = vecteurs users
;86 vecteurs
save_exc0:	ds.l	1
save_exc1:	ds.l	1
; berr
save_exc2:	ds.l	1
; aderr
save_exc3:	ds.l	1
; illegal
save_exc4:	ds.l	1
save_exc5:	ds.l	1
save_exc6:	ds.l	1
save_exc7:	ds.l	1
; privilege violation
save_exc8:	ds.l	1
; trace
save_exc9:	ds.l	1
; le reste
	ds.l	($140-10)/4	;=78
save2_exc9:	ds.l	1	;pour reinstall trace

;  #] Exceptions save buffer:
;  #[ Print stuff:
edit_ascii_long1:	ds.l	1
edit_ascii_long2:	ds.l	1
x_pos:	ds.w 1
y_pos:	ds.w 1
upper_x:	ds.w 1		 ;top left x
upper_y:	ds.w 1		 ;top left y
lower_x:	ds.w 1
lower_y:	ds.w 1		 ;y displacement

dummy1:		ds.w 1		 ;doit etre toujours a zero
disassemble_datas:	ds.w 5
addr_buffer_1:	ds.l 1
addr_buffer_2:	ds.b 8
dummy2:		ds.w 1		 ;doit etre toujours a zero

instruction_size:	ds.w 1
internal_allowed_modes:	ds.w 1
internal_stack_value:	ds.l 1
byte_op:	ds.b 1
word_op:	ds.b 1
long_op:	ds.b 1
cmpm_flag:	ds.b 1
optimise_address:	ds.b 1
		; analyse de l'instruction pointee par le PC
 even
analyse_register:	ds.w 1
analyse_offset:		ds.l 1
analyse_s_onoff:	ds.b 1
analyse_d_onoff:	ds.b 1

analyse_s_data:	ds.l 1
s_data_size:	ds.b 1
		even
analyse_d_data:	ds.l 1
d_data_size:	ds.b 1

;  #] Print stuff:
;  #[ Rez flags:

		even
rez_flags:
low_rez:	ds.b 1			;%000
mid_rez:	ds.b 1			;%001
high_rez:	ds.b 1			;%010
		ds.b 1			;%011
ttlow_rez:	ds.b 1			;%100
ttmid_rez:	ds.b 1			;%101
meta_rez:	ds.b 1			;%110
		ds.b 1			;%111

	even
prinfo_check_buffer:
	ds.b	10
;  #] Rez flags:
;  #[ Window stuff:
	even
window_tab_table:	ds.w 6
memory_loop_value:	ds.w 1
	;sauve:
gen_wind_buf:
w1_db:	ds.l 4
w2_db:	ds.l 4
w3_db:	ds.l 4
w4_db:	ds.l 4
w5_db:	ds.l 4
w6_db:	ds.l 4
low_w1_db:	ds.l 4
low_w2_db:	ds.l 4
low_w3_db:	ds.l 4
low_w4_db:	ds.l 4
low_w5_db:	ds.l 4
low_w6_db:	ds.l 4
meta_w1_db:	ds.l 4
meta_w2_db:	ds.l 4
meta_w3_db:	ds.l 4
meta_w4_db:	ds.l 4
meta_w5_db:	ds.l 4
meta_w6_db:	ds.l 4
reg_wind_buf:	ds.w	2*6
asc_wind_buf:	ds.w	1*6
src_wind_buf:	ds.b	_SRCWIND_SIZEOF*6
	even
var_wind_buf:	ds.b	_VARWIND_SIZEOF*6
	even
window_selected:	ds.w	1
window_buffer:	ds.b	$10+6
low_window_buffer:	ds.b	$10+6
current_window_flag:	ds.b	1
window_magnified:	ds.b	1
save_window_magnified:	ds.b	1
	even
end_of_window_buffer:
WINDOWS_PREFS_SIZE	equ	end_of_window_buffer-gen_wind_buf

current_window_reg_pos:	ds.w 2
memory_parity_flag:	ds.b	1
	even
ins_wind_buf:	ds.b	_INSWIND_SIZEOF*6
	even
	;pas sauve
windows_to_redraw:	ds.b	6
window_redrawed:	ds.w	1
big_title_addr:	ds.l	1
big_window_coords:	ds.l	2
;  #] Window stuff:
;  #[ Disassemble stuff:
test_instruction:	ds.l	1
test_instruction2:	ds.l	1

offset_down_for_disassemble:	ds.l	1
offset2_down_for_disassemble:	ds.l	1
offset3_down_for_disassemble:	ds.l	1

;  #] Disassemble stuff:
;  #[ Miscellaneous byte values:
null_string:	ds.b	1
chip_type:	ds.b	1
fpu_type:		ds.b	1
line_pattern:	ds.b	1
p_number:		ds.b	1
old_p_number:	ds.b	1
exception:	ds.b	1
pc_marker:	ds.b	1
	IFNE	sourcedebug
src_pc_marker:	ds.b	1
	ENDC	;sourcedebug
;  #] Miscellaneous byte values:
;  #[ Miscellaneous flags:
valid_var_tree_flag:	ds.b	1
no_print_ro_eval_flag:	ds.b	1
crdebug_flag:	ds.b	1
ask_disk_vector_flag:	ds.b	1
no_eval_flag:	ds.b	1
default_yesno_flag:	ds.b	1
allowed_memory_flag:	ds.b	1
shift_flag:	ds.b	1
c_line:	ds.b	1
m_line:	ds.b	1
screen0_flag:	ds.b	1
v_screen1_flag:	ds.b	1
search_set_flag:	ds.b	1
word_aligned_flag:	ds.b	1
low_window_magnified:	ds.b 1
relock_flag:	ds.b	1
relock_vars_flag:	ds.b	1
relock_pc_flag:	ds.b	1
routine_trap_flag:	ds.b	1
halted_flag:	ds.b	1

opt_var_flags_table:
debug1_var_flag:	ds.b	1
debug2_var_flag:	ds.b	1
overwrite_var_flag:	ds.b	1

	IFNE	ATARIST
med_to_low_flag:	ds.b	1
	ENDC
;  #] Miscellaneous flags:
;  #[ Sprintf flags:
sprintf_long_flag:	ds.b	1
sprintf_byte_flag:	ds.b	1
sprintf_hex_flag:	ds.b	1
sprintf_dec_flag:	ds.b	1
sprintf_bin_flag:	ds.b	1
sprintf_float_flag:	ds.b	1
sprintf_ptr_flag:	ds.b	1
sprintf_vdec_flag:	ds.b	1
;sprintf_ppack_flag:	ds.b	1
sprintf_pack_count:	ds.b	1
;sprintf_char_flag:	ds.b	1
sprintf_zchar_flag:	ds.b	1
sprintf_signed_flag:	ds.b	1
	even
sprintf_pack_ptr:	ds.l	1
sprintf_ppack_ptr:	ds.l	1
;  #] Sprintf flags:
;  #[ Mac flags:
rec_mac_flag:	ds.b	1
;again_rec_mac_flag:	ds.b	1
trace_mac_flag:	ds.b	1
force_mac_flag:	ds.b	1
go_mac_flag:	ds.b	1
play_mac_flag:	ds.b	1
rec_flag:	ds.b	1
play_flag:	ds.b	1
;  #] Mac flags:
;  #[ Breaks stuff:
	even
trace_instruc_buffer:	ds.b	200
trace_until_buffer:	ds.b	200
	even
traps_caught_nb_table:	ds.l	16
ctrl_d_vector:	ds.w	1
ctrl_d_no:	ds.w	1
trace_until_pc_value:	ds.l	1
eval_breaks_addr:	ds.l	1
end_eval_breaks_addr:	ds.l	1
cur_eval_breaks_addr:	ds.l	1
virt_breaks_addr:	ds.l	1
old_watch_pc_value:	ds.l	1
old_watch_ssp_value:	ds.l	1
old_watch_a7_value:	ds.l	1
old_watch_sr_value:	ds.w	1

;a mettre dans les preferences
def_break_eval_addr:	ds.l	1
def_break_perm:	ds.l	1

;  #] Breaks stuff:
;  #[ Exceptions stuff:
exception_routine_buffer:	ds.b	50
exceptions_caught_buffer:	ds.l	64
	IFNE	residant!cartouche
	even
resident_external_trap1:	ds.l	1
resident_trap1_level:	ds.w	1
resident_trap1_buffer_addr:	ds.l	1
resident_trap1_buffer:	ds.b	INITIAL_SIZE*20
	ENDC	; de residant!cartouche
tmp_context:	ds.l	17
tmp_context_sr:	ds.w	1
tmp_context_pc:	ds.l	1

;ro_internal_ssp:	ds.l	1
;ro_internal_sr:	ds.w	1
ro_return_addr:	ds.l	1
ro_return_break_addr:	ds.l	1
p1_return_addr:	ds.l	1
p1_return_break_addr:	ds.l	1

;  #[ Context struct:
	even
;buffer de contexte interne
internal_context_buffer:
runandbreak_flag:		ds.b	1
exc_emulated_flag:		ds.b	1
run_flag:			ds.b	1
ctlz_flag:		ds.b	1
trace_flag:		ds.b	1
nostop_flag:		ds.b	1
permanent_trace_flag:	ds.b	1
trace_slow_flag:		ds.b	1
trace_instruct_flag:	ds.b	1
trace_until_flag:		ds.b	1
trace_t1_flag:		ds.b	1
nowatch_flag:		ds.b	1
trace_until_pc_flag:	ds.b	1
justonce_flag:		ds.b	1
real_break_flag:		ds.b	1
trace_source_flag:		ds.b	1
			ds.b	1
			ds.b	1
			ds.b	1
			ds.b	1
	even
;sauvegarde du buffer de contexte interne pour les breaks permanents
save_internal_context_buffer:	ds.b	INTERNAL_CONTEXT_SIZE

;sauvegarde du buffer de contexte externe pour call_child
save_external_context_buffer:	ds.b	EXTERNAL_CONTEXT_SIZE
;  #] Context struct:
	even
	IFNE	ATARIST
ro_header_addresses:
	;601a
	ds.w	1
	;text
	ds.l	1
	;data
	ds.l	1
	;bss
	ds.l	1
	;sym
	ds.l	1
	;end
	ds.l	1
	ENDC
tmp_save_8:	ds.l	1
tmp_save_c:	ds.l	1
	;exception stack frames:

	;68000
	;sp+0 (bus and odd error)
sf_super_word:	ds.w	1
sf_cycle_addr:	ds.l	1
sf_ir:	ds.w	1
	IFNE	_68030
	;stack frame type
sf_type:	ds.w	1
	;sp+0 (all others exceptions)
external_stack_frame:
	;start of $0 $1 $2 $8 $9 $a $b stack frames
sf_sr:	ds.w	1
sf_pc:	ds.l	1

	;-- end short stack frame --
sf_vector_offset:	;for $0 $1 $2 $8 $9 $A $B stack frame
	ds.w	1
	;-- end $0-$1 stack frame --
sf_instr_addr:		;for $2 $9 stack frame (1 long)
sf_status_word_8:	;for $8 stack frame (1 word)
sf_internal_ab1:	;for $A $B stack frame (1 word)
	ds.w	1
sf_fault_addr_8:	;for $8 stack frame (1 long)
sf_status_word_ab:	;for $A $B stack frame (1 word)
	ds.w	1
	;-- end $2 stack frame --
sf_internal_9:	;for $9 stack frame (4 words)
sf_pipe_c:	;for $A $B stack frame (1 word)
	ds.w	1
sf_res_81:	;for $8 stack frame (1 word)
sf_pipe_b:	;for $A $B stack frame (1 word)
	ds.w	1
sf_data_outbuff_8:	;for $8 stack frame (1 word)
sf_data_fault_addr:	;for $A $B stack frame (1 long)
	;intentionally word:
	ds.w	1
sf_res_82:	;for $8 stack frame (1 word)
	ds.w	1
	;-- end $9 stack frame --
sf_data_inpbuff:	;for $8 stack frame (1 word)
sf_internal_ab2:	;for $A $B stack frame (1 long)
	;intentionally 2 words
	ds.w	1
sf_res_83:	;for $8 stack frame (1 word)
	ds.w	1
sf_instr_inpbuff:	;for $8 stack frame (1 word)
sf_data_outbuf_ab:	;for $A $B stack frame (1 long)
	ds.w	1
sf_internal_8:	;for $8 stack frame (16 words)
	ds.w	1
sf_internal_a:	;for $A stack frame (1 long)
sf_internal_b1:	;for $B stack frame (2 longs)
	ds.w	4
sf_stage_b:	; for $B stack frame (1 long)
	ds.w	2
sf_internal_b2:	;for $B stack frame (1 long)
	ds.w	2
sf_data_inpbuff_b:	;for $B stack frame (1 long)
	ds.w	2
sf_internal_b3:	;for $B stack frame (22 words)
	ds.w	5
	;-- end $8 stack frame --
	ds.w	17
	;-- end $B stack frame --

fpu_frame:	ds.b	216
fpu_frame_end:	ds.l	1
	ENDC	;de _68030
;  #] Exceptions stuff:
;  #[ Create buffers stuff:
first_mark:	ds.l	1
var_line:	ds.b	200
;  #[ Preferences stuff:
page_values_addr:	ds.l	1
page_values2_addr:	ds.l	1
internal_trap_nb:	ds.l	1

;si on change ca il faut changer:
;preferences_table
;def_pref_values_table
;small_pref_values_table
;ask_value_table et/ou ask_yesno_table
	even
preferences_table:
;VALUES
pref_value_buf:
tab_value:	ds.l	1
line_len_max:	ds.l	1
def_break_vec:	ds.l	1
def_ipl_level:	ds.l	1
rs232_speed:	ds.l	1
rs232_parity:	ds.l	1

create_sizes_table:
breaks_max:	ds.l	1
blocks_max:	ds.l	1
story_max:	ds.l	1
table_var_max:	ds.l	1
table_la_size:	ds.l	1
table_lr_size:	ds.l	1
table_bl_size:	ds.l	1
table_ex_size:	ds.l	1
mac_size:	ds.l	1
history_size:	ds.l	1
	IFNE	AMIGA
color0_value:	ds.l	1
color1_value:	ds.l	1
	ENDC

;FLAGS
pref_yesno_buf:
follow_traps_flag:	ds.b	1
reinstall_trace_flag:	ds.b	1
log_runandbreak_flag:	ds.b	1
log_run_flag:	ds.b	1
log_trapaf_flag:	ds.b	1
relative_offset_flag:	ds.b	1
symbols_flag:	ds.b	1
case_sensitive_flag:	ds.b	1
debug_symbols_flag:	ds.b	1
offset_symbols_flag:	ds.b	1
	IFNE	ATARIST
abssym_flag:	ds.b	1
defsym_flag:	ds.b	1
src_checkmodtime_flag:	ds.b	1
src_checkcode_flag:	ds.b	1
src_untilmain_flag:	ds.b	1
	ENDC	;ATARIST
ascii_line_wrap_flag:	ds.b	1
ascii_show_inv_flag:	ds.b	1
save_prinfo_flag:	ds.b	1
inverse_video_flag:	ds.b	1
real_time_flag:	ds.b	1
real_time_window_flag:	ds.b	1
real_time_lock_flag:	ds.b	1
minitel_flag:	ds.b	1
rs232_output_flag:	ds.b	1
	IFNE	ATARIST
electronic_switch_flag:	ds.b	1
	ENDC
check_hard_ipl7_flag:	ds.b	1
	IFNE	ATARIST
check_404_trap1_flag:	ds.b	1
	ENDC
system_prt_flag:	ds.b	1
follow_sr_flag:	ds.b	1
	IFNE	AMIGA
follow_intena_flag:	ds.b	1
	ENDC
	;;;NEW
	IFNE	ATARIST
catch_div0_flag:	ds.b	1
catch_linef_flag:	ds.b	1
catch_priv_flag:	ds.b	1
	ENDC
	IFNE	AMIGA
trace_task_pref_flag:	ds.b	1
exceptions_to_handler:	ds.b	1
create_sections_var_flag: ds.b	1
	ENDC
profiler_flag:	ds.b	1
unclip_profile_flag:	ds.b	1

;en source:
;src_checkstack_flag:	ds.b	1
	even
stack_size:	ds.l	1
;  #] Preferences stuff:

create_addrs_table:
breaks_addr:
	ds.l	1
	ds.l	1
blocks_addr:
	ds.l	1
	ds.l	1
story_addr:
	ds.l	1
	ds.l	1
table_var_addr:
	ds.l	1
	ds.l	1
table_la_addr:
	ds.l	1
	ds.l	1
table_lr_addr:
	ds.l	1
	ds.l	1
table_bl_addr:
	ds.l	1
	ds.l	1
table_ex_addr:
	ds.l	1
	ds.l	1
mac_addr:
	ds.l	1
	ds.l	1
history_addr:
	ds.l	1
	ds.l	1

create_currents_table:
current_breaks_addr:	ds.l	1
current_blocks_addr:	ds.l	1
current_sto_addr:	ds.l	1
current_var_addr:	ds.l	1
current_la_addr:	ds.l	1
current_lr_addr:	ds.l	1
current_bl_addr:	ds.l	1
current_ex_addr:	ds.l	1
cur_rec_mac_addr:	ds.l	1
cur_history_addr:	ds.l	1

create_ends_table:
end_breaks_addr:
	ds.l	1
	ds.l	1
end_blocks_addr:
	ds.l	1
	ds.l	1
end_story_addr:
	ds.l	1
	ds.l	1
end_var_addr:
	ds.l	1
	ds.l	1
end_la_addr:
	ds.l	1
	ds.l	1
end_lr_addr:
	ds.l	1
	ds.l	1
end_bl_addr:
	ds.l	1
	ds.l	1
end_ex_addr:
	ds.l	1
	ds.l	1
end_rec_mac_addr:
	ds.l	1
	ds.l	1
end_history_addr:
	ds.l	1
	ds.l	1

cur_size_table:
current_breaks_nb:	ds.l	1
current_blocks_nb:	ds.l	1
cur_sto_nb:	ds.l	1
current_var_nb:	ds.l	1
current_la_size:	ds.l	1
current_lr_size:	ds.l	1
current_bl_size:	ds.l	1
current_ex_size:	ds.l	1
cur_rec_mac_size:	ds.l	1
current_his_size:	ds.l	1

before_ctrll_addr:	ds.l	1
before_ctrll_la_addr:	ds.l	1

var_tree_addr:	ds.l	1
var_tree_nb:	ds.l	1
var_tree_count:	ds.l	1
	IFNE	AMIGA
internal_ros_flag:		ds.w	1
current_internal_ro_addr:	ds.l	1
	ENDC
;  #] Create buffers stuff:
;  #[ Mac stuff:
cur_play_mac_size:	ds.l	1
cur_play_mac_addr:	ds.l	1
rec_mac_counter:	ds.w	1
page_edit_mac_addr:	ds.l	1
;  #] Mac stuff:
;  #[ History stuff:
trans_history_addr:	ds.l	1
;  #] History stuff:
;  #[ Story stuff:
cur_h_addr:	ds.l	1
page_h_addr:	ds.l	1
page_end_h_addr:	ds.l	1
draw_story_count:	ds.l	1
;  #] Story stuff:
;  #[ Timers stuff:
;timers_buf:
;	REPT	4
	;mode (stop/delay/event count/pulse width)
;	ds.b	1
	;data register
;	ds.b	1
	;enable y/n
;	ds.b	1
	;pending y/n
;	ds.b	1
	;service y/n
;	ds.b	1
	;mask y/n
;	ds.b	1
	;
;	ENDR
;  #] Timers stuff:
;  #[ Evaluator stuff:
;  #[ Global variables:

par_number:
 ds.w 1
acc_number:
 ds.w 1
bracket_number:
 ds.w 1
result_flags_buffer:
 ds.l 2
result_buffer:
 ds.l 4

evaluate_decimal_flag:
 ds.b 1
evaluate_one_string_flag:
 ds.b 1

 IFNE Compile

compile_pointer:
 ds.l 1
compile_buffer:
 ds.w 1000
compile_flag:
 ds.b 1

 even

 ENDC

;  #] Global variables:
;  #[ Local variables:

Start_of_context:
_128_bits_buffer1:
 ds.l 4
_128_bits_buffer2:
 ds.l 4
_128_bits_buffer3:
 ds.l 4
evaluator_buffer:
 ds.b 200
parameters_pointer:
 ds.l 1
parameters_buffer:
 ds.b 200
string_pointer:
 ds.l 1
string_buffer:
 ds.b 200
initial_a4:
 ds.l 1
initial_a5:
 ds.l 1
eval_tmp1:
 ds.l 1
eval_tmp2:
 ds.l 1
eval_tmp1bis:
 ds.l 1
eval_tmp2bis:
 ds.l 1
eval_ro_address:
 ds.l 1
token_number:
 ds.w 1
C_ind_counter:
 ds.w 1
preinc_flag:
 ds.b 1
predec_flag:
 ds.b 1
evaluating_pre:
 ds.b 1
evaluating_post:
 ds.b 1
evaluating_prepost:
 ds.b 1
now_op:
 ds.b 1
op_flag:
 ds.b 1
neg_flag:
 ds.b 1
not_flag:
 ds.b 1
noformat_flag:
 ds.b 1
;patch pour le tower
 even
 ds.l 1
 ds.w 1

End_of_context:

;  #] Local variables:

;  #] Evaluator stuff:
;  #[ Terminal stuff:

soulign:
 ds.b 1
souflg:
 ds.b 1
flginv:
 ds.b 1
flag0:
 ds.b 1
dont_redraw_all:
 ds.b 1

 even
output_stream:
 ds.l	1

;  #] Terminal stuff:
;  #[ Raphael stuff:

copy_memory_buffer:
 ds.b 80
fill_memory_buffer:
 ds.b 80

print_bloc_flag:			; parametres pour 'print_bloc'
 ds.b 1

pb_allowed_flag:
 ds.b 1

pc_mode:
 ds.b 1

skip_mouse_flag:
 ds.b 1

 even

alt_e_tab_value:
 ds.w 1

alt_e_key_pressed:
 ds.l 1

search_byte_buffer:
 ds.b 200

search_word_buffer:
 ds.b 200

search_long_buffer:
 ds.b 200
search_ascii_buffer:
 ds.b 200
search_instruction_buffer:
 ds.b 200

pb_label_buffer:
 ds.l 1

pb_beg_address:
 ds.l 1
pb_end_address:
 ds.l 1
pb_labels_number:
 ds.l 1
pb_buffer_address:
 ds.l 1

parameters_queue:
 ds.l 200

misc_dat_buffer:
 ds.l 4

vbl_queue_addr:
 ds.l 1

string:
 ds.b 200

offset3_down_for_disassemble_flag:
 ds.b 1

registers_kept:
 ds.b 1

illegal_instruction_flag:
 ds.b 1

printer_flag:
 ds.b 1

pc_pointer_flag:
 ds.b 1

trap_line_af_flag:
 ds.b 1
internal_trap_line_af:
 ds.b 1
trapv_chk_flag:
 ds.b 1
internal_trapv_chk_flag:
 ds.b 1

up_down_flag:
 ds.b 1

save_movem:
 ds.b 1
movem_flag:
 ds.b 1
first_movem:
 ds.b 1

btst_op:
 ds.b 1

dont_remove_break_flag:
 ds.b 1

alt_d_flag:
 ds.b 1

bsr_jsr_flag:
 ds.b 1

;operande_flag:
; ds.b 1

 even

dont_remove_break_long:
 ds.l 1
device_number:
 ds.l 1

shift_up_down_table:
 rept 5
 ds.l 2					; shift up-down
 ds.l 2					; up-down
 endr

dc_w_line_buffer:
 ds.l 1

arrow_addr:
 ds.l 1

save_alt_e_berror:
 ds.l 1

lock_m2_buffer:
 ds.l 60

readable_buffer:
 ds.b 10

 even
lock_buffer:
 ds.b 200
 ds.b 200
 ds.b 200
lock_w4_buffer:
 ds.b 200
 ds.b 200

start_address:
 ds.l 1
end_address:
 ds.l 1
copy_address:
 ds.l 1

;  #] Raphael stuff:
;  #[ Search stuff:

search_buffer:	ds.b 200
search_base:	ds.l 1
search_length:	ds.w 1
search_string_flag:	ds.b 1
search_instruction_flag:	ds.b 1
 IFNE sourcedebug
search_source_flag:	ds.b 1
 ENDC ;de sourcedebug
 even

;  #] Search stuff:
;  #[ Menu stuff:
menu_legal:	ds.b	16
;  #] Menu stuff:
;  #[ Cursor stuff:
ex_cursor:	ds.w 1
ey_cursor:	ds.w 1
old_ex_cursor:	ds.w 1
old_ey_cursor:	ds.w 1
linex_cursor:	ds.w 1
liney_cursor:	ds.w 1
old_linex_cursor:
 ds.w 1
edit_ascii_undo_cursor:
 ds.l 2
 ds.w 2
edit_ascii_undo2_cursor:
 ds.l 2
 ds.w 2

minimum_ex_cursor:	ds.w 1
tab_cursor:	ds.b 1
alt_e_flag:	ds.b 1

;  #] Cursor stuff:
;  #[ Acia stuff:

keys_byte:	ds.b 1
caps_lock_flag:	ds.b 1
 even
ikbd_buffer:	ds.l 1
keys_table1:	ds.l 1
keys_table2:	ds.l 1
keys_table3:	ds.l 1
acia_ikbd:	ds.b 1
 even

;  #] Acia stuff:
;  #[ Watch subroutine stuff:

watch_subroutine_old_value:
 ds.l 1

watch_subroutine_window:
 ds.w 1

watch_subroutine_flag:
 ds.b 1

 even
 
;  #] Watch subroutine stuff:
;  #[ Buffer de comparaison pour le redraw:

wind_save:
	IFNE ATARIST
	ds.b	58*32
	ENDC
	IFNE AMIGA
	ds.b	31*16
	ENDC
buffer_lock_pointers:
 ds.l 6

;  #] Buffer de comparaison pour le redraw:
;  #[ ro_struct:
	even
;si modif alors modif:
;execute_ro
;"rostruct.s
;toutes les ro
ro_struct:
;	int	v_number d'Adebug
	ds.w	1
*****************************
;	int	tos_number
	ds.w	1
*****************************
;	window 1
	ds.l	1
;	window 2
	ds.l	1
;	window 3
	ds.l	1
;	window 4
	ds.l	1
;	window 5
	ds.l	1
***************************************
;	long	TEXT
	ds.l	1
;	long	DATA
	ds.l	1
;	long	BSS
	ds.l	1
;	long	END
	ds.l	1
***************************************
;	long	registers[17]
	ds.l	17
;	int	sr
	ds.w	1
;	long	pc
	ds.l	1
*****************************
;	int reso
	ds.w	1
*****************************
;	char	*string_addr a afficher
	ds.l	1
;	int	coord[2]
	ds.w	2
******************************
;	long	character;
	ds.l	1
******************************
;	char	*basepage_addr
	ds.l	1
;	char	*ro_addr
	ds.l	1
;	char	*logic_screen_addr
	ds.l	1

;	flag	reput_exc
	ds.b	1
;	flag	IPL7
	ds.b	1
;	flag	timera
	ds.b	1
;	flag	timerb
	ds.b	1
;	flag	timerc
	ds.b	1
;	flag	timerd
	ds.b	1
;	flag	redraw_screen
	ds.b	1
*****************************
;	flag	rs232_output
	ds.b	1
;	flag	re_exec_ro
	ds.b	1
*****************************
;  #] ro_struct:
;  #[ ro_ssp:
	even
aes_control:	ds.w	11
aes_global:	ds.w	15
aes_intin:	ds.w	128
aes_intout:	ds.w	128
aes_addrin:	ds.l	64
aes_addrout:	ds.l	64
;	ds.b	1024
ro_ssp:
	ds.l	1
;  #] ro_ssp:
;  #[ ro_usp:
	even
	IFNE	ATARIST
	ds.b	1024
	ENDC	;d'ATARIST
	IFNE	AMIGA
	ds.b	4096
	ENDC	;d'AMIGA
ro_usp:
	ds.l	1
;  #] ro_usp:
;  #[ New disassembler:

instruction_descriptor:			; buffer descripteur d'instruction
 ds.b _I_total_size

start_of_line_buffer:			; adresse du debut du desassemblage
 ds.l 1					; dans le buffer d'ecriture

Disassemble_line_readable_buffer:
 ds.b 22

conversion_buffer:			; buffer temporaire pour
 ds.b 9					; la conversion de nombres

optimize_address: 			; flag pour l'effacement
 ds.b 1					; des zeros non significatifs

disassembly_type:
 ds.b 1
fpu_disassembly:
 ds.b 1

;  #] New disassembler:
end_of_offset_base:
;  #] Section Bss:
	IFNE	mmanager
;  #[ Section Rs:
	RSRESET
Color_flag:	rs.b	1
Yes_flag:	rs.b	1
TOS_flag:	rs.b	1
	even
Char_buff:	rs.w	1
Screen:	rs.l	1
Font_addr:	rs.l	1
Numeric_buff:	rs.l	2
;  #] Section Rs:
	ENDC	; de mmanager

