; +======================================================================+
; | SINUS TABLE GENERATOR - Based on trigonometric identities:           |
; |   > sin(alpha + beta) = sin(alpha)*cos(beta) + sin(beta)*cos(alpha)  |
; |   > cos(alpha + beta) = cos(alpha)*cos(beta) - sin(alpha)*sin(beta)  |
; +======================================================================+
; | Copyright (c) 2016-2017 Frederic Poeydomenge <dyno@aldabase.com>     |
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

;#======================#
;# Generate sinus table #
;#======================#
; Input :
;     a0 = sinus table (period * .w)
;     d0 = amplitude
;     d1 = offset

period	equ	1024
amplitude	equr	d0
divisor	equr	d1
sin	equr	d2
sin_a	equr	d3
cos_a	equr	d4
sin_b	equ	201		; sin(2*PI/period) ~ 0.006
cos_b	equ	32766		; cos(2*PI/period) ~ 0.999
tmp_0	equr	d5
tmp_1	equr	d6
counter	equr	d7
table12	equr	a0
table34	equr	a1
offset	equr	a2

generate_sinus:

	move.l	d1,offset

				; table12 = 1st & 2nd quadrant
	lea	period(table12),table34	; table34 = 3rd & 4th quadrant

	move.l	#$7FFF,divisor
	divu	amplitude,divisor

	move.w	#period/2-1,counter

	; Initial values
	clr.w	sin_a		; sin(0)=0
	move.w	#$7FFF,cos_a	; cos(0)=1

.singen:	; Apply divisor
	move.w	sin_a,sin
	ext.l	sin
	divu	divisor,sin

	; Save current sinus value
	move.w	sin,(table12)+
	neg.w	sin
	move.w	sin,(table34)+

	; tmp_0 = cos(a+b) = cos(a)cos(b)-sin(a)sin(b)
	move.w	cos_a,tmp_0		; cos(a)
	muls	#cos_b,tmp_0	;   * cos(b)
	move	sin_a,tmp_1		; sin(a)
	muls	#sin_b,tmp_1	;   * sin(b)
	sub.l	tmp_1,tmp_0
	
	; sin_a = sin(a+b) = sin(a)cos(b)+sin(b)cos(a)
	muls	#cos_b,sin_a	; sin(a)*cos(b)
	muls	#sin_b,cos_a	; sin(b)*cos(a)
	add.l	cos_a,sin_a

	; cos_a = cos(a+b)
	move.l	tmp_0,cos_a

	; Normalize values
	add.l	sin_a,sin_a
	swap	sin_a
	add.l	cos_a,cos_a
	swap	cos_a
	
	; Next loop
	dbra	counter,.singen

	; Apply offset
	move.w	#period-1,counter
.offset:	move.w	-(table34),tmp_0
	add.w	offset,tmp_0
	move.w	tmp_0,(table34)
	dbra	counter,.offset

	rts
