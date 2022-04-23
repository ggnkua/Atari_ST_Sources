;
; Thing
; Copyright (C) 1994-2012 Arno Welzel, Thomas Binder
;
; This program is free software: you can redistribute it and/or
; modify it under the terms of the GNU Lesser General Public
; License as published by the Free Software Foundation, either
; version 3 of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
; GNU Lesser General Public License for more details.
;
; You should have received a copy of the GNU Lesser General Public
; License along with this program. If not, see
; <http://www.gnu.org/licenses/>.
;
; @copyright  Arno Welzel, Thomas Binder 1994-2012
; @author     Arno Welzel, Thomas Binder
; @license    LGPL
;

;
; MCODE.S
;
; Thing
; Assembler-Routinen
;

	globl	long2int
	globl	int2long
	globl	boot_drv
	
	macro	Supexec name
	pea	name
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
	text

;--------------------------------------------------------------------------
;Umwandlung eines Langwortes in zwei Integer
;
;Deklaration: extern void long2int(long lword,int *iword1,int *iword2)
;--------------------------------------------------------------------------

long2int:
	move.w	d0,(a1)
	swap	d0
	move.w	d0,(a0)
	rts

;--------------------------------------------------------------------------
;Umwandlung zweier Integer in ein Langwort
;
;Deklaration: extern long int2long(int *iword1,int *iword 2)
;--------------------------------------------------------------------------

int2long:
	move.w	(a0),d0
	swap	d0
	move.w	(a1),d0
	rts

;--------------------------------------------------------------------------
;Boot-Laufwerk ermitteln
;
;Deklaration: extern int boot_drv(void)
;--------------------------------------------------------------------------

boot_drv:
	Supexec	boot_dr1
	move.w	bootdev,d0
	rts
	
boot_dr1:
	move.w	$446,bootdev
	add.w	#65,bootdev
	rts

;--------------------------------------------------------------------------
;Daten
;--------------------------------------------------------------------------

	bss
	
bootdev:
	ds.w	1
		
	end
