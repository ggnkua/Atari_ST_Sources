* key definitions
* BIT NUMBERS!
* for use with SHIFT key status
* and for keys as passed back from the go_sub routine!
* (interpreted from AES codes)

* bits!
r_shift	equ	0
l_shift	equ	1
control	equ	2
alternate	equ	3

* values!
r_shft	equ	1
l_shft	equ	2
cntrl	equ	4
alt	equ	8

enter	equ	13
esc	equ	$1b
backspace	equ	8
tab	equ	9


del	equ	$7f+$80


* now the "dodgy" ones!
* negative values, because no real values

help	equ	$62+$80
undo	equ	$61+$80

ins	equ	$52+$80
clr_home	equ	$47+$80

up_arr	equ	$48+$80
down_arr	equ	$50+$80
left_arr	equ	$4b+$80
right_arr	equ	$4d+$80

f1	equ	$3b+$80
f2	equ	$3c+$80
f3	equ	$3d+$80
f4	equ	$3e+$80
f5	equ	$3f+$80
f6	equ	$40+$80
f7	equ	$41+$80
f8	equ	$42+$80
f9	equ	$43+$80
f10	equ	$44+$80


