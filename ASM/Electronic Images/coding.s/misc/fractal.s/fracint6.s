;-----------------------------------------------------------------------;
; Griff's little fractal proggy... 					;
; This is another part of the lots of different things in one demo...   ;
; Generates fractal ferns,trees etc etc....				;
;-----------------------------------------------------------------------;

start		clr -(sp)
		pea -1.w
		pea -1.w
		move #5,-(sp)
		trap #14			; lowres
		lea 12(sp),sp
		clr.l -(sp)
		move #$20,-(sp)
		trap #1				; supervisor
		addq.l #6,sp

		bsr initscreens
		bsr set_ints

.lp		bra.s .lp

;
; Generate Fractal (155 points) from 'frac_ptr'. This is 1 frames worth!
;

; Data Structure Format for fractal arrays.

		rsreset
xscle		rs.w 1			; x scale
yscle		rs.w 1			; y scale
xoff		rs.w 1			; x offset
yoff		rs.w 1			; y offset
fraca		rs.w 4
fracb		rs.w 4
fracc		rs.w 4			; constants for shape defination
fracd		rs.w 4
frace		rs.w 4
fracf		rs.w 4
fracp		rs.w 4			; weighted probabilities

Fractal_gen	move.l frac_ptr(pc),a3
		moveq #11,d3
		move #155,-(sp)

		lea.l mulu_160(pc),a2		; *160 table
		move.l log_base(pc),a4		; screen base
		moveq.l #0,d4			; x%=0
		moveq.l #0,d5			; y%=0
		movem.w (a3),d0-d1/a0-a1
		lea xscale+2(pc),a5
		move.w d0,(a5)			; set up scaling
		move.w d1,yscale-xscale(a5)	; factors(SM code)
fracgen		lea (a3),a5
fracrand	move.l	fracrndseed(pc),d1
		add.l d1,d0
		mulu #$4731,d0
		add.l d6,d0			; psuedo random
		ror.l #1,d0			; number
		addi.l	#715136305,d0
		move.l	d0,fracrndseed		; in d0
		and.l #$7ff,d0			; pk%=int(rnd(512)
		cmp.w fracp(a5),d0
		ble.s .cont
.1		cmp.w fracp+2(a5),d0
		bgt.s .2
		addq #2,a5
		bra.s .cont			; choose array
.2		cmp.w fracp+4(a5),d0		; based on cum prob. 
		bgt.s .3
		addq #4,a5
		bra.s .cont
.3		addq #6,a5
.cont		move.w fraca(a5),d0		; a%(k)
		muls d4,d0			; a%(k)*x%
		move.w fracb(a5),d6		; b%(k)
		muls d5,d6			; b%(k)*y%
		add.l d0,d6
		asr.l d3,d6			
		add.w frace(a5),d6		; +e%(k)
		move.w fracc(a5),d7		; c%(k)
		muls d4,d7			; c%(k)*x%
		move.w fracd(a5),d0		; d%(k)
		muls d5,d0			; d%(k)*y%
		add.l d0,d7
		asr.l d3,d7			
		add.w fracf(a5),d7		; +f%(k)
		move.w d6,d4			; x%=nx% 	
		move.w d7,d5 			; y%=ny%
		move.w d4,d1			; x%
xscale		muls #7,d1			' x%*xscale
		asr.l d3,d1
		move.w d5,d2			; y%
yscale		muls #7,d2
		asr.l d3,d2	
		add a0,d1			; x+xoffset
		add a1,d2			; y+yoffset
.dofracplot	cmp #319,d1			; clip on x
		bcc .cont
		cmp #199,d2			; clip on y					
		bcc .cont
		move.w d1,d0
		lsr #1,d1
		and #$fff8,d1
		add d2,d2
		add (a2,d2),d1			; add screen line
		clr d2
		not d0
		and #15,d0
		bset d0,d2			; pixel mask
		move.w (a4,d1.w),d6
		not.w d6
		move.w d2,d7
		and.w d6,d7
		bne.s .ok
		addq #2,d1
.ok		or.w d2,(a4,d1.w)		; plot it!
.cont		subq #1,(sp)
		bne fracgen
		addq.l #2,sp
		rts		

fracrndseed 	dc.l $17935785
frac_ptr: 	dc.l fracfern4

; The vbl..

frac_vbl	movem.l d0-d7/a0-a6,-(sp)
		movem.l frac_pal1(pc),d0-d7
		movem.l d0-d7,$ffff8240.w
		bsr Fractal_gen
		movem.l (sp)+,d0-d7/a0-a6

		btst.b #0,$fffffc00.w
		beq.s .nokey
		cmp.b #$39+$80,$fffffc02.w
		bne.s .nokey
		move.l #exitfrac,2(sp)
.nokey		addq #1,vbl_timer
		rte


; Fractal Objects - Ferns,'Sierpinski Triangle', tree

fracfern1	dc.w 25*1
		dc.w 16*1
		dc.w 160,0
.a		dc.w $0000/32
		dc.w $3333/32
		dc.w $ffffd999/32
		dc.w $d999/32
.b1		dc.w $0000
		dc.w $ffffbd70/32
		dc.w $47ae/32
		dc.w $0a3d/32
.c		dc.w $0000/32
		dc.w $3ae1/32
		dc.w $428f/32
		dc.w $fffff5c2/32
.d		dc.w $28f5/32
		dc.w $3851/32
		dc.w $3d70/32
		dc.w $d999/32
.e		dc.w $0000/32
		dc.w $0000/32
		dc.w $0000/32
		dc.w $0000/32
.f		dc.w $0000/32
		dc.w $00019999/32
		dc.w $70a3/32
		dc.w $00019999/32
.p		dc.w $028f/32
		dc.w $147a/32
		dc.w $2665/32
		dc.w $fffe/32

fracfern2	dc.w 25*3/2
		dc.w 16*3/2
		dc.w 160,0
.a		dc.w $0000/32
		dc.w $3333/32
		dc.w $ffffd999/32
		dc.w $d999/32
.b1		dc.w $0000
		dc.w $ffffbd70/32
		dc.w $47ae/32
		dc.w $0a3d/32
.c		dc.w $0000/32
		dc.w $3ae1/32
		dc.w $428f/32
		dc.w $fffff5c2/32
.d		dc.w $28f5/32
		dc.w $3851/32
		dc.w $3d70/32
		dc.w $d999/32
.e		dc.w $0000/32
		dc.w $0000/32
		dc.w $0000/32
		dc.w $0000/32
.f		dc.w $0000/32
		dc.w $00019999/32
		dc.w $70a3/32
		dc.w $00019999/32
.p		dc.w $028f/32
		dc.w $147a/32
		dc.w $2665/32
		dc.w $fffe/32

fracfern3	dc.w 25*2
		dc.w 16*2
		dc.w 160,0
.a		dc.w $0000/32
		dc.w $3333/32
		dc.w $ffffd999/32
		dc.w $d999/32
.b1		dc.w $0000	
		dc.w $ffffbd70/32
		dc.w $47ae/32
		dc.w $0a3d/32
.c		dc.w $0000/32
		dc.w $3ae1/32
		dc.w $428f/32
		dc.w $fffff5c2/32
.d		dc.w $28f5/32
		dc.w $3851/32
		dc.w $3d70/32
		dc.w $d999/32
.e		dc.w $0000/32
		dc.w $0000/32
		dc.w $0000/32
		dc.w $0000/32
.f		dc.w $0000/32
		dc.w $00019999/32
		dc.w $70a3/32
		dc.w $00019999/32
.p		dc.w $028f/32
		dc.w $147a/32
		dc.w $2665/32
		dc.w $fffe/32

fracfern4	dc.w 25*3
		dc.w 16*3
		dc.w 160,-50
.a		dc.w $0000/32
		dc.w $3333/32
		dc.w $ffffd999/32
		dc.w $d999/32
.b1		dc.w $0000	
		dc.w $ffffbd70/32
		dc.w $47ae/32
		dc.w $0a3d/32
.c		dc.w $0000/32
		dc.w $3ae1/32
		dc.w $428f/32
		dc.w $fffff5c2/32
.d		dc.w $28f5/32
		dc.w $3851/32
		dc.w $3d70/32
		dc.w $d999/32
.e		dc.w $0000/32
		dc.w $0000/32
		dc.w $0000/32
		dc.w $0000/32
.f		dc.w $0000/32
		dc.w $00019999/32
		dc.w $70a3/32
		dc.w $00019999/32
.p		dc.w $028f/32
		dc.w $147a/32
		dc.w $2665/32
		dc.w $fffe/32

tree1		dc.w 370*2,265*2 
		dc.w 160,-50
.a		dc.w 0     ;0.00*2048
		dc.w 20    ;0.01*2048
		dc.w 860   ;0.42*2048
		dc.w 860   ;0.42*2048
.b1		dc.w 0     ;0.00*2048
		dc.w 0     ;0.00*2048
		dc.w -860  ;-0.42*2048
		dc.w 860   ;0.42*2048
.c		dc.w 0     ;0.00*2048
		dc.w 0     ;0.00*2048
		dc.w 860   ;0.42*2048
		dc.w -860  ;-0.42*2048
.d		dc.w 1024  ;0.50*2048
		dc.w 205   ;0.10*2048
		dc.w 860   ;0.42*2048
		dc.w 860   ;0.42*2048
.e		dc.w 0     ;0.00*2048
		dc.w 0     ;0.00*2048
		dc.w 0     ;0.00*2048
		dc.w 0     ;0.00*2048
.f		dc.w 0     ;0.00*2048
		dc.w 410   ;0.20*2048
		dc.w 410   ;0.20*2048
		dc.w 410   ;0.20*2048
.p		dc.w 103              ;0.05*2048
		dc.w 307+103          ;0.15*2048
		dc.w 819+307+103      ;0.40*2048
		dc.w 819+819+307+103  ;0.40*2048

triang1		dc.w 120,110
		dc.w 50,50
.a		dc.w 1024 ;0.50*2048
		dc.w 1024 ;0.50*2048
		dc.w 1024 ;0.50*2048
		dc.w 0    ;0.00*2048
.b1		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
.c		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
.d		dc.w 1024 ;0.50*2048
		dc.w 1024 ;0.50*2048
		dc.w 1024 ;0.50*2048
		dc.w 0    ;0.00*2048
.e		dc.w 0    ;0.00*2048
		dc.w 2048 ;1.00*2048
		dc.w 1024 ;0.50*2048
		dc.w 0    ;0.00*2048
.f		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 1024  ;0.50*2048
		dc.w 0     ;0.00*2048
.p		dc.w 682   ;0.33*2048
		dc.w 682*2 ;0.33*2048
		dc.w (682*2)+683 ;0.34*2048
		dc.w 0     ;0.00*2048

triang2		dc.w 120*2,110*2
		dc.w -75,20
.a		dc.w 1024 ;0.50*2048
		dc.w 1024 ;0.50*2048
		dc.w 1024 ;0.50*2048
		dc.w 0    ;0.00*2048
.b1		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
.c		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
.d		dc.w 1024 ;0.50*2048
		dc.w 1024 ;0.50*2048
		dc.w 1024 ;0.50*2048
		dc.w 0    ;0.00*2048
.e		dc.w 0    ;0.00*2048
		dc.w 2048 ;1.00*2048
		dc.w 1024 ;0.50*2048
		dc.w 0    ;0.00*2048
.f		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 1024  ;0.50*2048
		dc.w 0     ;0.00*2048
.p		dc.w 682   ;0.33*2048
		dc.w 682*2 ;0.33*2048
		dc.w (682*2)+683 ;0.34*2048
		dc.w 0     ;0.00*2048

frac_pal1	dc.w $000,$020,$040,$040,$000,$000,$000,$000,$000
		dc.w $000,$000,$000,$000,$000,$000,$000,$000,$000

log_base	dc.l 0
phy_base	dc.l 0
switch		dc.w 0
i		set 0
mulu_160	rept 50
		dc.w i,i+160,i+320,i+480
i		set i+640
		endr


; Initialisation and restore interrupt routs.

set_ints	move #$2700,sr
		lea old_stuff(pc),a0
		move.l $70.w,(a0)+
		lea frac_vbl(pc),a1
		move.l a1,$70.w
		lea $fffffa00.w,a1
		movep.w 7(a1),d0
		move.w d0,(a0)+
		movep.w 13(a1),d0
		move.w d0,(a0)+
		moveq #0,d0
		movep.w d0,7(a1)
		movep.w d0,13(a1)
		move #$2300,sr
		rts

rest_ints	move #$2700,sr
		lea old_stuff(pc),a0
		move.l (a0)+,$70.w
		lea $fffffa00.w,a1
		move.w (a0)+,d0
		movep.w d0,7(a1)
		move.w (a0)+,d0
		movep.w d0,13(a1)
		move #$2300,sr
		rts

; Little old vbl.


vbl_timer	dc.w 0
old_stuff	ds.l 10

initscreens	lea log_base(pc),a1
		move.l #screens+256,d0
		clr.b d0
		move.l d0,(a1)+
		add.l #32000,d0
		move.l d0,(a1)+
		move.l log_base(pc),a0
		bsr clear_screen
		move.l phy_base(pc),a0
		bsr clear_screen
		move.l log_base(pc),d0
		lsr #8,d0
		move.l d0,$ffff8200.w
		rts

; Clear screen ->A0

clear_screen	moveq #0,d0
		move #1999,d1
.cls		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		dbf d1,.cls
		rts

exitfrac	bsr rest_ints
		move.l #$00000777,$ffff8240.w
		move.l #$07770777,$ffff8244.w
		clr -(sp)			; bye
		trap #1

		section bss
screens		ds.b 256
		ds.b 32000
		ds.b 32000
