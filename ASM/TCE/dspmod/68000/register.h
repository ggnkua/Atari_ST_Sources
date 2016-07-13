; 26/08/93

iera			equ $fffffa07 			 ;Interrupt-Enable-Register A
ierb			equ $fffffa09 			 ; 								 B
imra			equ $fffffa13
isra			equ $fffffa0f
isrb			equ $fffffa11
tacr			equ $fffffa19
tbcr			equ $fffffa1b
tadr			equ $fffffa1f
tbdr			equ $fffffa21
tccr			equ $fffffa1d
tcdr			equ $fffffa23
aer				equ $fffffa03
STColor			equ $ffff8240
FColor			equ $ffff9800	
vbl 			equ $00000070
timer_int		equ $00000120
timer_c_int 	equ $00000114

ym_select		equ $ffff8800
ym_write		equ $ffff8802
ym_read			equ $ffff8800

vbaselow		equ $ffff820d
vbasemid		equ $ffff8203
vbasehigh		equ $ffff8201
vcountlow		equ $ffff8209
vcountmid		equ $ffff8207
vcounthigh		equ $ffff8205
linewid			equ $ffff820f
hscroll			equ $ffff8265

keyctl			equ $fffffc00
keybd 			equ $fffffc02

DspHost			equ $ffffa200
HostIntVec		equ $03fc

PCookies		equ $5a0

hop				equ $ffff8a3a
op				equ $ffff8a3b
line_nr			equ $ffff8a3c
mode			equ $ffff8a3c
skew			equ $ffff8a3d
endmask1		equ $ffff8a28
endmask2		equ $ffff8a2a
endmask3		equ $ffff8a2c
x_count			equ $ffff8a36
y_count			equ $ffff8a38
dest_x_inc		equ $ffff8a2e
dest_y_inc		equ $ffff8a30
dest_adr		equ $ffff8a32
src_x_inc		equ $ffff8a20
src_y_inc		equ $ffff8a22
src_adr			equ $ffff8a24

mpx_src			equ $ffff8930
mpx_dst			equ	$ffff8932
