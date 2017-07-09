; +======================================================================+
; | Main include file                                                    |
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

	; Turn all optimising on
	OPT	O+
	; Causes multiple includes of the same file to be ignored
	OPT	INCONCE

	;---------------
	; Outout format
	;---------------

	IFEQ	PROD-0
	IFD	@KERNEL
	; KERNEL with System
	OPT	D-,X-
	OUTPUT	.SYS
	ELSE
	; DEV  Environment
	OPT	D+,X+
	OUTPUT	.PRG
	ENDC
	ELSE
	; PROD Environment
	OPT	D-,X-
	OUTPUT	.BIN
	ENDC

	;----------------------
	; Constants and macros
	;----------------------

	INCLUDE	MACRO.S

	;------------------
	; Fillers Overscan
	;------------------

	INCLUDE	MACROVER.S

	;------------------------------------
	; Development/Production environment
	;------------------------------------

	IFD	@KERNEL
	INCLUDE	ENV_PRD.S
	ELSE
	IFEQ	PROD-0
	INCLUDE	ENV_DEV.S
	ELSE
	INCLUDE	ENV_PRD.S	
	ENDC
	ENDC

	;---------------
	; Sinus routine
	;---------------

	INCLUDE	SINUS.S

	;---------------
	; VSync routine
	;---------------

	INCLUDE	VSYNC.S

	;---------------
	; Sound routine
	;---------------

	INCLUDE	SOUND.S
