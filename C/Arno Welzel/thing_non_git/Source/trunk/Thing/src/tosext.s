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
 
; TOSEXT.S
; Ergaenzungen zur PCTOSLIB.LIB (Dxreaddir() u.A.)

	globl	Dxreaddir

	text

;
; Dxreaddir() - GEMDOS #322
;
; long Dxreaddir(int ln,long dirh,char *buf,XATTR *xattr,long *xr)
;
Dxreaddir:
	movem.l	a2,-(sp)
	move.l	8(sp),-(sp)	; xr
	move.l	a1,-(sp)	; xattr
	move.l	a0,-(sp)	; buf
	move.l	d1,-(sp)	; dirh
	move.w	d0,-(sp)	; ln
	move.w	#322,-(sp)	; Dxreaddir()
	trap	#1          ; GEMDOS
	lea	20(sp),sp      ; Stack korrigieren
	movem.l	(sp)+,a2
	rts			; Ergebnis ist in d0
