 		opt O+	 optimises code 
;###############################################
;This is a MONO version, with NO perspective!!
;This version uses the larger, 128k Trig. table..
;Needs a special CAP file: no radius information held
;this one has squish for smaller files..
;And the squish works!! (If I remember to run the 2 GFA progs too..)
;And squash for speeeed!!!  (squish alters size, but squash should 
;remain the same..  Thanx to Jose for the suggestion about adding to 
;D regs, rather than A regs.  And the moral support
;################################################
	include	d:\3d.s\macro.s
maxpoints	equ 435		; Max for 50Hz=408
hoz		equ 8500
scx             EQU 159         ; Screen center X.
scy             EQU 99          ; Screen center Y.
squit		equ 2		;IE squish=2^squit
squish		equ 4
squat		equ 1		;ie Squash=2^squat
squash		equ 2
;########################################
	vsync
	super_on
	low_rez
	set_pal

                lea     screens,A0
                move.l  A0,D0
                add.l   #256,D0
                move.b  #0,D0
                move.l  D0,scrnpos
                add.l   #32000,D0
                move.l  D0,scrn2		* Set up 2 screen^

                movea.l scrnpos,A0
                move.w  #4000-1,D0
clean:          move.l  #0,(A0)+
                move.l  #0,(A0)+
                move.l  #0,(A0)+
                move.l  #0,(A0)+
                dbra    D0,clean        	* Clear screen.

;	bra.s	key
	move.w	#$2700,sr
	move.b	$fffffa07.w,sa1
	move.b	$fffffa09.w,sa2
	move.b	$fffffa1b.w,sa3
	move.b	$fffffa21.w,sa4
	move.b	$fffffa13.w,sa5
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	move.l	$70.w,oldvbl
	move.l	#vbl,$70.w
	clr.b	$fffffa1b.w
        move.l  $120.w,oldhbl
	move.l  #hbl,$120.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
        move.w  #$2300,sr

;######################## main loop ###############
key:
                tst.b   flip
                bne.s   poo
                move.b  #1,flip
                bra.s   scour
poo:            move.b  #0,flip
		bra.s	scour
flip:		dc.w	0
scour:  
                moveq   #0,D0
                movea.l scrnpos,A0  * Initialise screen address.
                tst.b   flip
                bne   clrrts2

clrrts:         REPT maxpoints
                move.w D0,2(A0)
                ENDR
                bra  goon
clrrts2:        REPT maxpoints
                move.w D0,2(A0)
                ENDR

goon:           tst.b   flip
                beq.s   seccy
                lea     clrrts2(pc),A3 * To save LEA'ing.
                bra.s   pand
seccy:
                lea     clrrts(pc),A3 * To save LEA'ing.
pand:
		lea	xinc(pc),a6
		jsr	rots
space:      
	move.w	#-1,-(sp)
	move.l	scrnpos,-(sp)
	pea	-1.w
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp
        move.l  scrnpos,D0
        move.l  scrn2,scrnpos
        move.l  D0,scrn2

	move.b	lcount,d0
sync:	
	cmp.b	lcount,d0
	beq.s	sync

	move.l  scrnpos,d0
	move.l  d0,hscrnpos

	move.w  #$2300,sr
	cmpi    #57,$fffffc02.w
	blt     key

;############################################
end
	move.w	#$2700,sr
	move.l	oldvbl,$70.w
	move.l  oldhbl,$120.w
	move.b	sa1,$fffffa07.w
	move.b	sa2,$fffffa09.w
	move.b	sa3,$fffffa1b.w
	move.b	sa4,$fffffa21.w
	move.b	sa5,$fffffa13.w
	move.w	#$2300,sr

flush:	btst.b	#0,$fffffc00.w
	beq.s	fl_done
	move.b	$fffffc02.w,d0
	bra.s	flush
fl_done:
	
	move.w	#$777,$ffff8246.w	;set up screen color for editor
	super_off
	vsync
	med_rez
	exit

hbl:	        rte
vbl:            addq.b  #1,lcount       * Signal flyback has occured.
                rte
tempa		ds.l 1
hscrnpos	ds.l 1
;############################################################
rots            

	lea	 matrix,a0
        movem.w  (a6)+,d0-d2     ;add x,y,z increments to angles
	add.w	 (a6),d0
	add.w	 2(a6),d1
	add.w	 4(a6),d2
	move.w	 #$ffff/squish,d3
	and.w	 d3,d0
	and.w	 d3,d1
	and.w	 d3,d2
	movem.w	 d0-d2,(a6)
	
	move.w	 (a6)+,d1
	move.w	 (a6)+,d3
	move.w	 (a6)+,d5

	lea	sin,A1	; SET UP MATRIX (old method still..)
	lea	cos,a6

	move.w	0(a6,D1.w),D0	; Cos X into D0
	move.w	0(A1,D1.w),D1	; Sin X into D1
	move.w	0(a6,D3.w),D2	; Cos Y into D2
	move.w	0(A1,D3.w),D3	; Sin Y into D3
	move.w	0(a6,D5.w),D4	; Cos Z into D4
	move.w	0(A1,D5.w),D5	; Sin Z into D5

* Cy*Cz,Cy*Sz,Sy
* !Sx*Sy!*Cz+Cx*-Sz,!Sx*Sy!*Sz+Cx*Cz,-Sx*Cy
* ;Cx*-Sy;*Cz+Sx*-Sz,;Cx*-Sy;*Sz+Sx*Cz,Cx*Cy

gen_mat_x:
	move.w	D4,D6		; Store CosZ.
	muls	D2,D4		; CosY * CosZ.
	lsl.l	#squat+1,d4
	swap	D4
	move.w	D4,(A0)+	; > M1,1
	move.w	D6,D4		; Restore Cos Z.
	move.w	D5,D6		; Store SinZ.
	muls	D2,D5		; CosY * SinZ.
	lsl.l	#squat+1,d5
	swap	D5
	move.w	D5,(A0)+	; > M2,1
	move.w	D6,D5
	move.w	D3,(A0)+	; > M3,1 = SinY. Also stores d3!
	move.w	D3,D7		; Store for later use.

gen_mat_y:
	muls	D1,D3		; SinX * SinY
	lsl.l	#squat+1,d3
	swap	D3
	movea.w D3,A4		; Store for later.
	muls	D4,D3		; * CosZ.
	move.w	D5,D6		; Store SinZ.
	neg.w	D5		; SinZ = -SinZ.
	muls	D0,D5		; CosX * -SinZ.
	add.l	D5,D3
	lsl.l	#squat+1,d3
	swap	D3
	move.w	D3,(A0)+	; > M1,2.
	move.w	A4,D3		; Fetch SinX * SinY.
	move.w	D6,D5		; Restore SinZ.
	muls	D5,D3		; * SinZ.
	move.w	D4,D6		; Store CosZ.
	muls	D0,D4		; CosX * CosZ.
	add.l	D4,D3
	lsl.l	#squat+1,d3
	swap	D3
	move.w	D6,D4		; Restore CosZ.
	move.w	D3,(A0)+	; > M2,2
	move.w	D7,D3		; Restore SinY.
	move.w	D1,D6		; Store SinX.
	neg.w	D1		; SinX = -SinX.
	muls	D2,D1		; -SinX * CosY.
	lsl.l	#squat+1,d1
	swap	D1
	move.w	D1,(A0)+	; > M3,2.
	move.w	D6,D1		; Restore SinX.

gen_mat_z:
	neg.w	D3		; SinY = -SinY.
	muls	D0,D3		; CosX * -SinY.
	lsl.l	#squat+1,d3
	swap	D3
	movea.w D3,A4		; Store for later.
	muls	D4,D3		; * CosZ.
	move.w	D5,D6		; Store SinZ.
	neg.w	D5		; SinZ = -SinZ.
	muls	D1,D5		; SinX * -SinZ.
	add.l	D5,D3
	lsl.l	#squat+1,d3
	swap	D3
	move.w	D3,(A0)+	; > M1,3
	move.w	A4,D3		; Get CosX * -SinY.
	muls	D6,D3		; * SinZ.
	muls	D1,D4		; SinX * CosZ.
	add.l	D4,D3
	lsl.l	#squat+1,d3
	swap	D3
	move.w	D3,(A0)+	; > M2,3
	muls	D0,D2		; CosX * CosY.
	lsl.l	#squat+1,d2
	swap	D2
	move.w	D2,(A0)+	; > M3,3

	lea	-18(a0),a0
	lea	acos,a1
	lea	m11P,a5
	move.w	#$fffc,d6

	move.l	#$322a0000,d1	; move.w 0(a2),d1
	move.l	#$342a0000,d2	; move.w 0(a2),d2
	move.w	(a0)+,d1
	asr.w	#squit,d1
	and.w	d6,d1
	move.w	0(a1,d1.w),d1
	move.l	d1,(a5)+
	swap	d1
	move.w	#$d26a,d1	;add.w 0(a4),d1
	swap	d1
	neg.w	d1
	move.l	d1,(a5)+	;move.w n(a2),d1
	move.w	(a0)+,d2
	asr.w	#squit,d2
	and.w	d6,d2
	move.w	0(a1,d2.w),d2
	move.l	d2,(a5)+
	swap	d2
	move.w	#$d46a,d2	;add.w 0(a4),d2
	swap	d2
	neg.w	d2
	move.l	d2,(a5)+         ;move.w n(a2),d2
	move.w	(a0)+,d2

	move.l	#$d26c0000,d1	;add.w 0(a4),d1
	move.l	#$d46c0000,d2	;add.w 0(a4),d2
	move.w	(a0)+,d1
	asr.w	#squit,d1
	and.w	d6,d1
	move.w	0(a1,d1.w),d1
	move.l	d1,(a5)+
	neg.w	d1
	move.l	d1,(a5)+	;move.w n(a4),d1 done
	move.w	(a0)+,d2
	asr.w	#squit,d2
	and.w	d6,d2
	move.w	0(a1,d2.w),d2
	move.l	d2,(a5)+
	neg.w	d2
	move.l	d2,(a5)+         ;move.w n(a4),d2 done
	move.w	(a0)+,d2	 ;dummy z value 

	move.l	#$d26E0000,d1	;add.w 0(a6),d1
	move.l	#$d46E0000,d2	;add.w 0(a6),d2
	move.w	(a0)+,d1
	asr.w	#squit,d1
	and.w	d6,d1
	move.w	0(a1,d1.w),d1
	move.l	d1,(a5)+
	neg.w	d1
	move.l	d1,(a5)+	;2*move.w n(a2),d1
	move.w	(a0)+,d2
	asr.w	#squit,d2
	and.w	d6,d2
	move.w	0(a1,d2.w),d2
	move.l	d2,(a5)+
	neg.w	d2
	move.l	d2,(a5)+         ;2*move.w n(a2),d2
	move.w	(a0)+,d2	 ;dummy z value..

;now matrix is set up proper..??!

	lea	points(pc),a1	;cos is in a6
;	lea	yoffs(pc),a0
     	move.l	scrnpos(pc),a5
	move.l	(a3),d2		;self-mod. CLS (mono only)
	move.w	(a1)+,d7	;points - 1
	moveq.l	#-2,d5		;word mask..
	moveq.l	#7,d0		;shift reg
	move.l	a6,d4

nexp:	
	move.l	a6,a2
	move.l	a6,a4
	add.w	(a1)+,a2
	add.w	(a1)+,a4
	add.w	(a1)+,a6
	
m11p	ds.l	12		;12 * add.w  $xxxx(a2/4/6),d1/2
	move.l	d4,a6		; Restore point.
	asr.w	d0,d1		
	asr.w	d0,d2
	add.w	#2*scx,d1
	add.w	#(yoffs-xoffs)+2*scy,d2
	and.w	d5,d1
	add.w	d1,d1
	and.w	d5,d2
        move.l  xoffs(pc,d1.w),d1		;the x words and masks..
        move.w  xoffs(pc,d2.w),d2   		;the y offs
        add.w   d1,d2
        move.l  d2,(a3)+			;store the screen word..
        swap    d1
	or.w	d1,(a5,d2.w)
clipit:	dbra	d7,nexp
	rts
;########################
;END OF THE ROAD FOR A0,A1,A2,A3,A4,A5,A6,D0,D1,D2,D3,D4,D5,D6,D7
xoffs:
xoff            SET 0
                REPT 20
                DC.W %1000000000000000,xoff
                DC.W %100000000000000,xoff
                DC.W %10000000000000,xoff
                DC.W %1000000000000,xoff
                DC.W %100000000000,xoff
                DC.W %10000000000,xoff
                DC.W %1000000000,xoff
                DC.W %100000000,xoff
                DC.W %10000000,xoff
                DC.W %1000000,xoff
                DC.W %100000,xoff
                DC.W %10000,xoff
                DC.W %1000,xoff
                DC.W %100,xoff
                DC.W %10,xoff
                DC.W %1,xoff
xoff            SET xoff+8
                ENDR

yoffs:          EVEN
yoff            SET 0
                REPT 200
                DC.W yoff
yoff            SET yoff+160
                ENDR

scrnpos:        DS.L 1          * Screen position (crafty place!).

pal:            DC.W $000,$777,$667,$557,$447,$337,$227,$117
                DC.W $007,$006,$005,$004,$003,$002,$002,$001

xinc:		dc.w	23*4
zinc:		dc.w    31*4
yinc:		dc.w	19*4
xrot:		dc.w	0*4
yrot:		dc.w	0*4
zrot:		dc.w	0*4

points: 
	include	d:\3d.s\newspir.cap
pobjs:	ds.w	maxpoints*3


;Trigonometric table

trig:	incbin	d:\3d.s\newtrig.dat
sin:	equ	trig+(3*16384)/squish
cos:	equ	trig+(4*16384)/squish 
acos:	equ	trig+(2*16384)/squish+2	;use a 2 offset..

	BSS

matrix		ds.w 	9	;for +ve/-ve values..

scrn2:          DS.L 1

oldsp:          DS.L 1          * Space for old stack address.
oldhbl:	        ds.l 1          * Space for HBL space telescope
oldvbl:         DS.L 1          * Space for old VBL address.
lcount:         DS.W 1          * Space for beam flyback signal.

sa1:            DS.B 1
sa2:            DS.B 1
sa3:            DS.B 1
sa4:            DS.B 1
sa5:            DS.B 1
sa6:            DS.B 1
sa7:            DS.B 1
sa8:            DS.B 1
sa9:            DS.B 1
sa10:           DS.B 1

screens:        DS.L 3*8000
	end
