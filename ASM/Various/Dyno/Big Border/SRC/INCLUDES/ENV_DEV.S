; +======================================================================+
; | Development environment                                              |
; +======================================================================+
; | Copyright (c) 2015-2017 Frederic Poeydomenge <dyno@aldabase.com>     |
; +----------------------------------------------------------------------+
; | This program is free software: you can redistribute it and/or modify |
; | it under the terms of the GNU General Public License as published by |
; | the Free Software Foundation, either version 3 of the License, or    |
; | (at your option) any later version.                                  |
; |                                                                      |
; | This program is distributed in the hope that it will be useful,      |
; | but WITHOUT ANY WARRANTY; without even the implied warranty of       |
; | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the         |
; | GNU General Public License for more details.                         |
; |                                                                      |
; | You should have received a copy of the GNU General Public License    |
; | along with this program. If not, see <http://www.gnu.org/licenses/>. |
; +======================================================================+

;#===============#
;# Runs the demo #
;#===============#

dev_run_demo:
	SUPER
	bsr.s	dev_save
	bsr	dev_set_defaults
	bsr	run_demo
	bsr	dev_restore
	USER
	PTERM
	
;#=============================#
;# Save all hardware registers #
;#=============================#

dev_save:
	move.w	#$2700,sr		; Mask all interrupts
	SAVE_SYNC
	SAVE_RES
	SAVE_PALETTE
	SAVE_PHYSBASE
	SAVE_MFP
	move.w	#$2300,sr		; Enable interrupts
	rts

;#================================#
;# Restore all hardware registers #
;#================================#

dev_restore:
	move.w	#$2700,sr		; Mask all interrupts
	clr.l	K_QVBL.w		; Clear QVBL
	move.l	#default_vbl,VBL.w	; Set default VBL
	move.l	#default_hbl,TB_HBL.w	; Set default HBL
	move.w	#$2300,sr		; Enable interrupts
	; Reset shifter, to resolve sync-errors :
	; 50Hz => 60 Hz => Old sync value
	bsr	vsync
	SET_SYNC	#SIXTY_HZ
	bsr	vsync
	SET_SYNC	#FIFTY_HZ
	bsr	vsync
	SET_SYNC	#SIXTY_HZ
	bsr	vsync
	move.w	#$2700,sr		; Mask all interrupts
	RESTORE_SYNC
	RESTORE_RES
	RESTORE_PALETTE
	RESTORE_PHYSBASE
	RESTORE_MFP
	move.w	#$2300,sr		; Enable interrupts
	MOUSE_ON
	rts

;#====================================#
;# Initializes all hardware registers #
;#====================================#

dev_set_defaults:
	CLR_PALETTE
	MOUSE_OFF
	move.w	#$2700,sr		; Mask all interrupts
	CLR_MFP
	clr.l	K_QVBL.w		; Clear QVBL
	clr.w	K_NB_VBL.w		; Clear number of VBL routines
	move.l	#default_vbl,VBL.w	; Set default VBL
	move.l	#default_hbl,TB_HBL.w	; Set default HBL
	move.w	#$2300,sr		; Enable interrupts
	bsr	reset_ym_registers
	bsr.s	vsync
	SET_SYNC	#FIFTY_HZ
	bsr.s	vsync
	SET_RES	#LOW_RES
	bsr.s	vsync
	rts
