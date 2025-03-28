; +======================================================================+
; | Production environment                                               |
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

prd_run_demo:
	bsr.s	prd_set_defaults
	bra	run_demo

;#====================================#
;# Initializes all hardware registers #
;#====================================#

prd_set_defaults:
	CLR_PALETTE
	move.w	#$2700,sr		; Mask all interrupts
	CLR_MFP
	move.l	#default_vbl,VBL.w	; Set default VBL
	move.l	#default_hbl,TB_ITR.w	; Set default HBL
	move.w	#$2300,sr		; Enable interrupts
	SET_SYNC	#FIFTY_HZ
	SET_RES	#LOW_RES
	rts
