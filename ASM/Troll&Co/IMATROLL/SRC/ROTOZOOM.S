	Section	Text
;
; Create a texture for the rotozoomer
;
Init_rotozoomer:	 

	lea	tex,a0	; load texture
	
	move.w	#255,d0	; for d0=0 to 255

.loopX:	move.w	#255,d1	; for d1=0 to 255
.loopY:	move.w	d0,d2	; save d0
	eor.w	d1,d2	; d2 = d1 XOR d0	
	;lsr.w      #3,d2	; shit right 3 bits -> get only blue pixels
	lsl.w	#8,d2	; shift left 8 bits -> exchange bytes	
	andi.w	#%1111100000000000,d2	; only get red pixels
	
	move.w      d2,(a0)+	
	
	dbra	d1,.loopY	; next d1
	dbra	d0,.loopX	; next d0

	rts
;
; Main rotozoomer routine
;
Main_RZ:	move.w	angle,d0		; input for rotozoomer

	move.l	seed,d2		; get a rnd number		
	rol.l       d2,d2		; and generate a new one
	addq.l      #5,d2

	move.l	d2,seed		; save it

	cmpi.w	#4<<11,d2		; compare this rnd number to  4 shl 11 (8192)
	bhi.s	.greater		; if is not greater
	neg.b	angleinc		; then negate angle increment (change direction)

.greater	add.b	angleinc,d0 	; in all cases then add angle increment to the current angle 
	move.w	d0,angle		; save angle 

	move.w	zoomfactor,d1	; get zoomfactor
	
	tst.w	d1		; if zoomfactor < 0 
	bpl.s	.positive		; then negate zoom increment to have a  positive zoom factor
	neg.w	zoominc	

.positive:	cmpi.w	#200,d1		; in all cases 
	blt	.below		; if > 200 then 
	neg.w	zoominc		; negate zoom inc to have a zoom factor < 200

.below:
	add.w       zoominc,d1		; in all cases, add zoomfactor to current zoom value
	move.w	d1,zoomfactor	; and save it

	bsr	RotoZoom		; call rotozoom routine (d0)
;	addq.b	#1,angle+1		; used for normal angle increment (not for rnd)
	
	rts	
;
; Rotozoom routine
; d0 = angle
;
;

blurtbl:	dc.w 0,2,640,642		; blur table

RotoZoom:	move.w	d0,d1		; save angle value in d1
	and.w	#3,d1		; get 2 lower bits (d1=0,1,2 or 3) = angle mod 3
	
	move.l	screen_adr,a0	; a0 = screen_adr
	lea	20*640(a0),a0	; start display on the 20th line (faster)
	adda.w      (blurtbl,pc,d1.w*2),a0 	; + (0,2,640,642) depending on angle mod 3  
				; this will do a blur effect as previous column will not be erased

	lea	SinCos+256,a1	; a1=middle of sincos table
	lea	tex+65536,a2	; a2=end of texture 
	;lea	logo1+32768,a2

	move.w	(a1,d0.w*2),d1	; get sin value in d1 
	move.w	(128,a1,d0.w*2),d2	; get cos value in d1 (sin+128) 

	muls.w	zoomfactor,d1	; d1=sin(angle)*zoomfactor -> longword
	muls.w	zoomfactor,d2	; d2=cos(angle)*zoomfactor -> longword

	asr.l	#5,d1		; shift right d1 from 5 bits : divide by 2^5=32   
	asr.l	#5,d2		; idem for d2

	move.w	d1,dx		; save d1=dx*zf in dx (faster to use registers first)
	move.w	d2,dy		; save d2 in dy

; rotozoom formulas
; u = -160*(dx*zf)-100*(dy*zf) for the whole screen of -80...-50 for halfof the screen dims (blur effect)
; v = -160*(dy*zf)+100*(dx*zf)

	move.w	dx,d3		 
	muls.w	#-80,d3		; d3=-80dx -> .L
	move.w	dy,d1
	muls.w	#-50,d1		; d1=-50dy -> .L

	add.l	d1,d3		; d3=-80dx-50dy

	move.w	dy,d4
	muls.w	#-80,d4		; d4=-80dy -> .L
	move.w	dx,d1
	muls.w	#50,d1		; d1=50dx	-> .L
	
	add.l	d1,d4		; d4=-80dy+50dx

	move.w	dx,a3		; put dx in a3 (faster)
	move.w	dy,a4		; put dy in a4

	move.w	#99,d1		; for y=0 to 99 (half of the screen height)

.loopY:	move.w	d3,d5		; save d3 : u1=u
	move.w	d4,d6		; save d4 : v1=v
	
	move.w	#159,d2		; for x=0 to 159 (half of screen width)
	
.loopX:	move.w	d5,d7		; save u1 in d7
	move.w	d6,d0		; save v1
	lsr.w	#8,d0		; divide v1 by 256 : get integer value for 8.8 fixed point nb
	
	move.b	d0,d7		; put v1 integer value in d7 lower byte
				; so d7 contains int(u1,v1) in d7

	move.w	(a2,d7.w*2),(a0)+ 	; d5=tex[d6]=tex[hi(u)*256 OR hi(v)]
	
	addq.l	#2,a0		; skip a word (a column)
	add.w	a3,d5		; add dx to u1
	add.w	a4,d6		; add dy to v1	
	
	dbra	d2,.loopX		; next x

	add.w	a4,d3		; add dy to u
	sub.w	a3,d4 		; sub dx to v
	
	lea         640(a0),a0		; skip a line

	dbra	d1,.loopY		; next y

	rts

	section 	DATA

SinCos:     
		dc.w 0,6,13,19,25,31,38,44,50,56
		dc.w 62,68,74,80,86,92,98,104,109,115
		dc.w 121,126,132,137,142,147,152,157,162,167
		dc.w 172,177,181,185,190,194,198,202,206,209
		dc.w 213,216,220,223,226,229,231,234,237,239
		dc.w 241,243,245,247,248,250,251,252,253,254
		dc.w 255,255,256,256,256,256,256,255,255,254
		dc.w 253,252,251,250,248,247,245,243,241,239
		dc.w 237,234,231,229,226,223,220,216,213,209
		dc.w 206,202,198,194,190,185,181,177,172,167
		dc.w 162,157,152,147,142,137,132,126,121,115
		dc.w 109,104,98,92,86,80,74,68,62,56
		dc.w 50,44,38,31,25,19,13,6,0,-6
		dc.w -13,-19,-25,-31,-38,-44,-50,-56,-62,-68
		dc.w -74,-80,-86,-92,-98,-104,-109,-115,-121,-126
		dc.w -132,-137,-142,-147,-152,-157,-162,-167,-172,-177
		dc.w -181,-185,-190,-194,-198,-202,-206,-209,-213,-216
		dc.w -220,-223,-226,-229,-231,-234,-237,-239,-241,-243
		dc.w -245,-247,-248,-250,-251,-252,-253,-254,-255,-255
		dc.w -256,-256,-256,-256,-256,-255,-255,-254,-253,-252
		dc.w -251,-250,-248,-247,-245,-243,-241,-239,-237,-234
		dc.w -231,-229,-226,-223,-220,-216,-213,-209,-206,-202
		dc.w -198,-194,-190,-185,-181,-177,-172,-167,-162,-157
		dc.w -152,-147,-142,-137,-132,-126,-121,-115,-109,-104
		dc.w -98,-92,-86,-80,-74,-68,-62,-56,-50,-44
		dc.w -38,-31,-25,-19,-13,-6
		dc.w 0,6,13,19,25,31,38,44,50,56
		dc.w 62,68,74,80,86,92,98,104,109,115
		dc.w 121,126,132,137,142,147,152,157,162,167
		dc.w 172,177,181,185,190,194,198,202,206,209
		dc.w 213,216,220,223,226,229,231,234,237,239
		dc.w 241,243,245,247,248,250,251,252,253,254
		dc.w 255,255,256,256,256,256,256,255,255,254
		dc.w 253,252,251,250,248,247,245,243,241,239
		dc.w 237,234,231,229,226,223,220,216,213,209
		dc.w 206,202,198,194,190,185,181,177,172,167
		dc.w 162,157,152,147,142,137,132,126,121,115
		dc.w 109,104,98,92,86,80,74,68,62,56
		dc.w 50,44,38,31,25,19,13,6,0,-6
		dc.w -13,-19,-25,-31,-38,-44,-50,-56,-62,-68
		dc.w -74,-80,-86,-92,-98,-104,-109,-115,-121,-126
		dc.w -132,-137,-142,-147,-152,-157,-162,-167,-172,-177
		dc.w -181,-185,-190,-194,-198,-202,-206,-209,-213,-216
		dc.w -220,-223,-226,-229,-231,-234,-237,-239,-241,-243
		dc.w -245,-247,-248,-250,-251,-252,-253,-254,-255,-255
		dc.w -256,-256,-256,-256,-256,-255,-255,-254,-253,-252
		dc.w -251,-250,-248,-247,-245,-243,-241,-239,-237,-234
		dc.w -231,-229,-226,-223,-220,-216,-213,-209,-206,-202
		dc.w -198,-194,-190,-185,-181,-177,-172,-167,-162,-157
		dc.w -152,-147,-142,-137,-132,-126,-121,-115,-109,-104
		dc.w -98,-92,-86,-80,-74,-68,-62,-56,-50,-44
		dc.w -38,-31,-25,-19,-13,-6

zoomfactor:		dc.w 1	
zoominc:		dc.w 2
seed:		dc.l 0344864426
angleinc:		dc.b 1			
		even

	section 	BSS

tex:		ds.w	256*256
angle:		ds.w	1
dx:		ds.w	1
dy:		ds.w	1

	Section 	Text