;
; Ben's Bezier patch!!
;

		opt O+	 optimises code 
;
; This implementation by Jose Miguel Commins and Ben Griffin.
;
;######################### just change bze,hoz.. ###########
	include	macro.s
hertz	 	equ 0		;Runs at 50Hz with 100 points..
bze		equ 3		;THIS VERSION IS FIXED to MAX = 4
	ifeq	bze-3
hoz		equ 3500
	elseif
hoz		equ 8500
	endc
scx             EQU 159         * Screen center X.
scy             EQU 99          * Screen center Y.
	ifeq    bze-4
bzf	equ	16
	elseif
bzf	equ     9		;normally 8..
	endc
;#################################################
bdiv    macro
	ifeq	bze-3
	add.l   \1,\1
	endc
	ADD.L	\1,\1
	add.l	\1,\1
	add.l	\1,\1
	endm
;#################################################
;\1 = var., \2= co-ord \3= +thresh \4 = -ve thresh \5= inc \6 = dec
bounce		macro
		move.w	\1,d0
		add.w	\2,d0
		move.w	d0,\2
		cmp.w	#\3,d0
		ble.s	a\@
		move.w  #\3,\2
		move.w	#\6,\1
a\@		cmp.w	#\4,d0
		bge.s	b\@
		move.w	#\4,\2
		move.w	#\5,\1
b\@		
		endm
;#################################################                
coli		macro
		ifne	\1
		or.w	d7,(a0)+
		elseif
		and.w	d1,(a0)+
		endc
		ifne	\2
		or.w	d7,(a0)+
		elseif
		and.w	d1,(a0)+
		endc
		ifne	\3
		or.w	d7,(a0)+
		elseif
		and.w	d1,(a0)+
		endc
		ifne	\4
		or.w	d7,(a0)
		elseif
		and.w	d1,(a0)
		endc
		
		ifeq	2-\5
		mexit
		endc
		ifeq	\5
		bra	endpnts
		elseif
		bra.s	endpnts
		nop
		endc
		nop
		nop		;for 16 bytes.. (faster)
		endm
;#################################################
plotto		macro
                movea.l scrnpos(PC),A0  * Get screen address (tee-hee!).
		move.w	d7,d1	;y
		swap	d7      ;x

		ifeq	bze-4		
                lsr.w   #5,d6
                add.w   #16*8,d6 
                elseif
                lsr.w	#4,d6
                add.w	#16*5,d6
                endc
                and.w   #$00F0,d6	;now sorted for colour!!

                add.w   #scx,d7
                cmpi.w  #320,d7
                bcc     clippit
                add.w   #scy,D1
                cmpi.w  #200,D1
                bcc     clippit
                add.w   D1,D1
                add.w   d7,d7
                add.w   d7,d7
                move.l  0(A5,d7.w),d7
                move.w  0(A4,D1.w),D1
                add.w   d7,D1
                move.w  D1,(A3)
                addq.w  #6,A3
                adda.w  D1,A0
                swap    d7
                move.w  d7,D1
                not.w   D1
docols:
                jmp     prouts(PC,d6.w) * Execute point routine.
prouts:
		coli	0,0,0,0,0
		coli	1,0,0,0,0
		coli	0,1,0,0,0
		coli	1,1,0,0,0
		coli	0,0,1,0,0
		coli	1,0,1,0,0
		coli	0,1,1,0,0
		coli	1,1,1,0,1
		coli	0,0,0,1,1
		coli	1,0,0,1,1
		coli	0,1,0,1,1
		coli	1,1,0,1,1
		coli	0,0,1,1,1
		coli	1,0,1,1,1
		coli	0,1,1,1,1
		coli	1,1,1,1,2
routend:
clippit:
endpnts:	
		endm
;#################################################
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

                movea.l scrnpos(PC),A0
                move.w  #4000-1,D0
clean:          move.l  #0,(A0)+
                move.l  #0,(A0)+
                move.l  #0,(A0)+
                move.l  #0,(A0)+
                dbra    D0,clean        	* Clear screen.

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
		ifne	hertz
		move.w  #$000,$ffff8240.w  Test for 50Hz..
		endc
                tst.b   flip
                bne.s   poo
                move.b  #1,flip
                bra.s   scour
poo:            move.b  #0,flip
		bra.s	scour
flip:		dc.w	0
scour:         
                moveq   #0,D0
                move.l  D0,D1           * Clear registers.
                movea.l scrnpos(PC),A0  * Initialise screen address.
                tst.b   flip
                bne     clrrts2

clrrts:         REPT (bzf+1)*(bzf+1)
                movem.l D0-D1,2(A0)
                ENDR
                bra    goon

clrrts2:        REPT (bzf+1)*(bzf+1)
                movem.l D0-D1,2(A0)
                ENDR

goon:           tst.b   flip
                beq.s   seccy
                lea     clrrts2+4(pc),A3 * To save LEA'ing.
                bra.s   pand
seccy:
                lea     clrrts+4(pc),A3 * To save LEA'ing.
pand:

; 6 bytes to clear routs by A6.

		lea	points,a1	;source points..
		move.w	(a1)+,d7	;no. of points
;                bra still		;miss out bouncing
		bounce  fl0p,02(a1),267,-248,111,-001
		bounce  fl1p,08(a1),690,-550,113,-001
		bounce  fl2p,14(a1),490,-720,117,-003
		bounce  fl3p,20(a1),302,-484,113,-002
		bounce  fl4p,26(a1),957,-940,117,-001
		bounce  fl5p,32(a1),135,-377,112,-007
		bounce  fl6p,38(a1),626,-665,113,-003
		bounce  fl7p,44(a1),297,-700,119,-002
		bounce  fl8p,50(a1),756,-479,111,-009
;x stretch, continuous..
		bounce  fl9p,(a1),999,-999,036,-032
		bounce  f10p,06(a1),999,-999,036,-032
		bounce  f11p,12(a1),999,-999,036,-032
		bounce  f12p,18(a1),500,-750,038,-036
		bounce  fl3p,24(a1),500,-750,038,-036
		bounce  fl4p,30(a1),500,-750,038,-036

still:	
		lea	2+pobjs(pc),a2
		lea	xinc(pc),a6
		ifne	hertz		
		move.w  #$077,$ffff8240.w
		endc
		jsr	rots
		ifne	hertz
		move.w  #$000,$ffff8240.w
		endc
		jsr	dogrid

space:      
		move.w	#-1,-(sp)
		move.l	scrnpos(pc),-(sp)
		pea	-1.w
		move.w	#5,-(sp)
		trap	#14
		add.w	#12,sp

                move.l  scrnpos(PC),D0
                move.l  scrn2(PC),scrnpos
                move.l  D0,scrn2


        ifne	hertz			;spare time !!! 
        move.w  #$007,$ffff8240.w
        endc
	move.b	lcount(pc),d0
sync:	
	cmp.b	lcount(pc),d0
	beq.s	sync
	ifne	hertz
	move.w  #$000,$ffff8240.w
	endc
	move.l  scrnpos(pc),d0
	move.l  d0,hscrnpos

	move.w  #$2300,sr
	cmpi    #57,$fffffc02.w
	blt     key

;############################################
end
	move.w	#$2700,sr
	move.l	oldvbl(pc),$70.w
	move.l  oldhbl(pc),$120.w
	move.b	sa1(pc),$fffffa07.w
	move.b	sa2(pc),$fffffa09.w
	move.b	sa3(pc),$fffffa1b.w
	move.b	sa4(pc),$fffffa21.w
	move.b	sa5(pc),$fffffa13.w
	move.w	#$2300,sr

flush:	btst.b	#0,$fffffc00.w
	beq.s	fl_done
	move.b	$fffffc02.w,d0
	bra.s	flush
fl_done:
	
	move.w	#$047,$ffff8246.w	;set up screen color for editor
	med_rez
	super_off
	exit

hbl:	        rte
vbl:            addq.b  #1,lcount       * Signal flyback has occured.
                rte
tempa		ds.l 1
hscrnpos	ds.l 1
;############################################################
rots            
;	bra	rotn
                move.w  (a6),d0        ;add x,y,z increments to angles
                add.w   d0,6(a6)
                move.w  2(a6),d0
                add.w   d0,8(a6)
                move.w  4(a6),d0
                add.w   d0,10(a6)

;input: a6 points to xinc,yinc,zinc
;                    xrot yrot zrot
;                    xtrn ytrn ztrn
;in order..
; Now we rotate all those points.
                lea     sintab(PC),A0   ; SET UP MATRIX.
xangle:         move.w  6(a6),D0
                and.w   #1023,D0
                add.w   D0,D0
                move.w  0(A0,D0.w),D1   ; Sin X into D1
                add.w   #512,D0
                move.w  0(A0,D0.w),D0   ; Cos X into D0.
yangle:         move.w  8(a6),D2
                and.w   #1023,D2
                add.w   D2,D2
                move.w  0(A0,D2.w),D3   ; Sin Y into D3
                add.w   #512,D2
                move.w  0(A0,D2.w),D2   ; Cos Y into D2.
zangle:         move.w  10(a6),D4
                and.w   #1023,D4
                add.w   D4,D4
                move.w  0(A0,D4.w),D5   ; Sin Z into D5
                add.w   #512,D4
                move.w  0(A0,D4.w),D4   ; Cos Z into D4.
x:              move.w  D4,D6           ; Store CosZ.
                muls    D2,D4           ; CosY * CosZ.
                add.l   D4,D4
                swap    D4
                move.w  D4,m11+2        ; > M1,1
                move.w  D6,D4           ; Restore Cos Z.
                move.w  D5,D6           ; Store SinZ.
                muls    D2,D5           ; CosY * SinZ.
                add.l   D5,D5
                swap    D5
                move.w  D5,m21+2        ; > M2,1
                move.w  D6,D5
                move.w  D3,m31+2        ; > M3,1 = SinY. Also stores d3!
y:              muls    D1,D3           ; SinX * SinY
                add.l   D3,D3
                swap    D3
                move.w  D3,sxsy         ; Store for later.
                muls    D4,D3           ; * CosZ.
                add.l   D3,D3
                swap    D3
                move.w  D5,D6           ; Store SinZ.
                neg.w   D5              ; SinZ = -SinZ.
                muls    D0,D5           ; CosX * -SinZ.
                add.l   D5,D5
                swap    D5
                add.w   D5,D3           ; Add to previous muls.
                move.w  D3,m12+2        ; > M1,2.
                move.w  sxsy(PC),D3     ; Fetch SinX * SinY.
                move.w  D6,D5           ; Restore SinZ.
                muls    D5,D3           ; * SinZ.
                add.l   D3,D3
                swap    D3
                move.w  D4,D6           ; Store CosZ.
                muls    D0,D4           ; CosX * CosZ.
                add.l   D4,D4
                swap    D4
                add.w   D4,D3           ; Add to previous muls.
                move.w  D6,D4           ; Restore CosZ.
                move.w  D3,m22+2        ; > M2,2
                move.w  m31+2(PC),D3    ; Restore SinY.
                move.w  D1,D6           ; Store SinX.
                neg.w   D1              ; SinX = -SinX.
                muls    D2,D1           ; -SinX * CosY.
                add.l   D1,D1
                swap    D1
                move.w  D1,m32+2        ; > M3,2.
                move.w  D6,D1           ; Restore SinX.
z:              neg.w   D3              ; SinY = -SinY.
                muls    D0,D3           ; CosX * -SinY.
                add.l   D3,D3
                swap    D3
                move.w  D3,cxsy         ; Store for later.
                muls    D4,D3           ; * CosZ.
                add.l   D3,D3
                swap    D3
                move.w  D5,D6           ; Store SinZ.
                neg.w   D5              ; SinZ = -SinZ.
                muls    D1,D5           ; SinX * -SinZ.
                add.l   D5,D5
                swap    D5
                add.w   D5,D3           ; Add to previous muls.
                move.w  D3,m13+2        ; > M1,3
                move.w  D6,D5           ; Restore SinZ.
                move.w  cxsy(PC),D3     ; Get CosX * -SinY.
                muls    D5,D3           ; * SinZ.
                add.l   D3,D3
                swap    D3
                muls    D1,D4           ; SinX * CosZ.
                add.l   D4,D4
                swap    D4
                add.w   D4,D3           ; Add to previous muls.
                move.w  D3,m23+2        ; > M2,3
                muls    D0,D2           ; CosX * CosY.
                add.l   D2,D2
                swap    D2
                move.w  D2,m33+2        ; > M3,3

rnexp:          move.w  (A1)+,D5        ; X
                move.w  (A1)+,D4        ; Y
                move.w  (A1)+,D3        ; Z  no Z..

                move.w  D5,D0           ; Store old X.

xnew:           move.w  D4,D1           ; Store old Y.
                move.w  D3,D2           ; Store old Z.
m11:            muls    #0,D5           ; X * M1,1.
m21:            muls    #0,D1           ; Y * M2,1.
m31:            muls    #0,D2           ; Z * M3,1.
                add.l   D1,D5           ; X * M1,1 + Y * M2,1.
                add.l   D2,D5           ; Above instr + Z * M3,1.
                add.l   D5,D5
                swap    D5

                move.w  D0,D1           ; Store old X.
                move.w  D4,D6           ; Store old Y.
ynew:           move.w  D3,D2           ; Store old Z.
m12:            muls    #0,D0           ; X * M1,2.
m22:            muls    #0,D4           ; Y * M2,2.
m32:            muls    #0,D2           ; Z * M3,2.
                add.l   D0,D4           ; X * M1,2 + Y * M2,2
                add.l   D2,D4           ; Above instr + Z * M3,2.
                add.l   D4,D4
                swap    D4

                move.w  D6,D0           ; Get old Y.

znew:
m13:            muls    #0,D1           ; X * M1,3.
m23:            muls    #0,D0           ; Y * M2,3.
m33:            muls    #0,D3           ; Z * M3,3.
                add.l   D1,D3           ; X * M1,3 + Y * M2,3
                add.l   D0,D3           ; Above instr + Z * M3,3.
                add.l   D3,D3           ; Adjust for fraction (X2).
                swap    D3              ; And divide by 32767 (max RAD).

                add.w   12(a6),d5       ;tx
                add.w   14(a6),d4       ;ty
                add.w   16(a6),d3       ;tz

persp:
	        move.w  d3,d2
                add.w   #hoz,D3
                ext.l   D5
                ext.l   D4
                asl.l   #8,D5
                asl.l   #8,D4
                divs    D3,D5
                divs    D3,D4

                move.w  D5,(A2)+        ; Store x.
                move.w  D4,(A2)+        ; Store y.
                move.w  D2,(A2)+        ; Store z. 

                dbra    D7,rnexp         ; Next point.
                rts

;#########                
;This version does X,Y,Z in the grid..
bzp	equ	bzf+1		;no. of points..
;########################################################
dogrid
     lea     xoffs(pc),a5
     lea     yoffs(pc),a4
     move.w  #(bzp-1)*6,d5	;no. of points -1 for dbra..

blp  lea	bez1(pc),a1
     lea	beza(pc),a0
     jsr	dobez
     move.l	d7,(a1)+		;x,y
     move.w	d6,(a1)+        	;z
     lea	bezb(pc),a0
     jsr	dobez
     move.l	d7,(a1)+	;x,y
     move.w	d6,(a1)+	;z
     lea	bezc(pc),a0
     jsr	dobez
     move.l	d7,(a1)+	;x,y
     move.w	d6,(a1)+	;z
     swap	d5
     move.w	#(bzp-1)*6,d5	;no. of points -1 for dbra
blq  lea	bez1(pc),a0
     jsr	dobez
     plotto
     subq.w	#6,d5
     bge	blq
     swap	d5
     subq.w	#6,d5
     bge	blp
     rts
;#######################################################
;Input:
;      d5: fraction, 0 - 31 (fixed point- $20 = 1)
;      A0: X',Y',X",Y",X'",Y"',Denominator(eg 16=4,32=5) (word array)
;	   0  2  4   6	8  10  12
;Otput:
;      D7: X(HIword),Y(LOword)
;      D6: Z(LOword)
;Used:
;      d0,d1,d2,d3,d4,d6,d7,a0
;wasted: d1,d2,d3,d4,d6,d7
;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
;```````````````````````````````````````
dobez	
     move.w	0+bztab(pc,d5.w),d0
     move.w	2+bztab(pc,d5.w),d1
     move.w	4+bztab(pc,d5.w),d2
     move.w    (a0)+,d7
     muls       d1,d7
     move.w    (a0)+,d6
     muls      d1,d6
     muls      (a0)+,d1
     move.w    (a0)+,d4
     muls      d0,d4
     add.l     d4,d7
     move.w    (a0)+,d4
     muls      d0,d4
     add.l     d4,d6
     muls      (a0)+,d0
     move.w    (a0)+,d4
     muls      d2,d4
     add.l     d4,d7        
     bdiv      d7	    ;Keep in High..
     move.w    (a0)+,d4     ;this puts y0,y1,y2 in d<,=,6 resp. 
     muls      d2,d4	    ;same again, but y
     add.l     d4,d6	    ;y in d6
     bdiv      d6
     swap      d6
     move.w    d6,d7	    ;now in d7 LOW
     move.w    (a0)+,d6     ;this puts z0,z1,z2 in d4,5,6 resp. 
     muls      d2,d6	    ;same again, but z
     add.l     d0,d6
     add.l     d1,d6	    ;z in d6
     bdiv      d6
     swap      d6
     rts
;########################################
bztab
bz	set   bzf
count	set   0
	rept  bzp
	dc.w  64*2*count*(bz-count),64*count*count,64*(bz-count)*(bz-count)
count	set   count+1
	endr
; THE ABOVE IS ALL ESSENTIAL TO BEZIER FN	 
;##########################################################
;END OF THE ROAD FOR A0,A1,A2,A3,A4,A5,A6,D0,D1,D2,D3,D4,D5,D6,D7


sintab:         DC.W $00,$C9,$0192,$025B,$0324,$03ED,$04B6,$057E
                DC.W $0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3
                DC.W $0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200
                DC.W $12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833
                DC.W $18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56
                DC.W $1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467
                DC.W $2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61
                DC.W $2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041
                DC.W $30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603
                DC.W $36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4
                DC.W $3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120
                DC.W $41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674
                DC.W $471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D
                DC.W $4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097
                DC.W $5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F
                DC.W $55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3
                DC.W $5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F
                DC.W $5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271
                DC.W $62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656
                DC.W $66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC
                DC.W $6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61
                DC.W $6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082
                DC.W $70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E
                DC.W $73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3
                DC.W $7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F
                DC.W $7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41
                DC.W $7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7
                DC.W $7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61
                DC.W $7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E
                DC.W $7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C
                DC.W $7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD
                DC.W $7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE
                DC.W $7FFF,$7FFE,$7FFC,$7FF9,$7FF5,$7FEF,$7FE8,$7FE0
                DC.W $7FD7,$7FCD,$7FC1,$7FB4,$7FA6,$7F96,$7F86,$7F74
                DC.W $7F61,$7F4C,$7F37,$7F20,$7F08,$7EEF,$7ED4,$7EB9
                DC.W $7E9C,$7E7E,$7E5E,$7E3E,$7E1C,$7DF9,$7DD5,$7DB0
                DC.W $7D89,$7D61,$7D38,$7D0E,$7CE2,$7CB6,$7C88,$7C59
                DC.W $7C29,$7BF7,$7BC4,$7B91,$7B5C,$7B25,$7AEE,$7AB5
                DC.W $7A7C,$7A41,$7A04,$79C7,$7989,$7949,$7908,$78C6
                DC.W $7883,$783F,$77F9,$77B3,$776B,$7722,$76D8,$768D
                DC.W $7640,$75F3,$75A4,$7554,$7503,$74B1,$745E,$740A
                DC.W $73B5,$735E,$7306,$72AE,$7254,$71F9,$719D,$7140
                DC.W $70E1,$7082,$7022,$6FC0,$6F5E,$6EFA,$6E95,$6E30
                DC.W $6DC9,$6D61,$6CF8,$6C8E,$6C23,$6BB7,$6B4A,$6ADB
                DC.W $6A6C,$69FC,$698B,$6919,$68A5,$6831,$67BC,$6745
                DC.W $66CE,$6656,$65DD,$6562,$64E7,$646B,$63EE,$6370
                DC.W $62F1,$6271,$61F0,$616E,$60EB,$6067,$5FE2,$5F5D
                DC.W $5ED6,$5E4F,$5DC6,$5D3D,$5CB3,$5C28,$5B9C,$5B0F
                DC.W $5A81,$59F3,$5963,$58D3,$5842,$57B0,$571D,$5689
                DC.W $55F4,$555F,$54C9,$5432,$539A,$5301,$5268,$51CE
                DC.W $5133,$5097,$4FFA,$4F5D,$4EBF,$4E20,$4D80,$4CE0
                DC.W $4C3F,$4B9D,$4AFA,$4A57,$49B3,$490E,$4869,$47C3
                DC.W $471C,$4674,$45CC,$4523,$447A,$43D0,$4325,$4279
                DC.W $41CD,$4120,$4073,$3FC5,$3F16,$3E67,$3DB7,$3D07
                DC.W $3C56,$3BA4,$3AF2,$3A3F,$398C,$38D8,$3824,$376F
                DC.W $36B9,$3603,$354D,$3496,$33DE,$3326,$326D,$31B4
                DC.W $30FB,$3041,$2F86,$2ECC,$2E10,$2D54,$2C98,$2BDB
                DC.W $2B1E,$2A61,$29A3,$28E5,$2826,$2767,$26A7,$25E7
                DC.W $2527,$2467,$23A6,$22E4,$2223,$2161,$209F,$1FDC
                DC.W $1F19,$1E56,$1D93,$1CCF,$1C0B,$1B46,$1A82,$19BD
                DC.W $18F8,$1833,$176D,$16A7,$15E1,$151B,$1455,$138E
                DC.W $12C7,$1200,$1139,$1072,$0FAB,$0EE3,$0E1B,$0D53
                DC.W $0C8B,$0BC3,$0AFB,$0A32,$096A,$08A1,$07D9,$0710
                DC.W $0647,$057E,$04B6,$03ED,$0324,$025B,$0192,$C9
                DC.W $00,$FF37,$FE6E,$FDA5,$FCDC,$FC13,$FB4A,$FA82
                DC.W $F9B9,$F8F0,$F827,$F75F,$F696,$F5CE,$F505,$F43D
                DC.W $F375,$F2AD,$F1E5,$F11D,$F055,$EF8E,$EEC7,$EE00
                DC.W $ED39,$EC72,$EBAB,$EAE5,$EA1F,$E959,$E893,$E7CD
                DC.W $E708,$E643,$E57E,$E4BA,$E3F5,$E331,$E26D,$E1AA
                DC.W $E0E7,$E024,$DF61,$DE9F,$DDDD,$DD1C,$DC5A,$DB99
                DC.W $DAD9,$DA19,$D959,$D899,$D7DA,$D71B,$D65D,$D59F
                DC.W $D4E2,$D425,$D368,$D2AC,$D1F0,$D134,$D07A,$CFBF
                DC.W $CF05,$CE4C,$CD93,$CCDA,$CC22,$CB6A,$CAB3,$C9FD
                DC.W $C947,$C891,$C7DC,$C728,$C674,$C5C1,$C50E,$C45C
                DC.W $C3AA,$C2F9,$C249,$C199,$C0EA,$C03B,$BF8D,$BEE0
                DC.W $BE33,$BD87,$BCDB,$BC30,$BB86,$BADD,$BA34,$B98C
                DC.W $B8E4,$B83D,$B797,$B6F2,$B64D,$B5A9,$B506,$B463
                DC.W $B3C1,$B320,$B280,$B1E0,$B141,$B0A3,$B006,$AF69
                DC.W $AECD,$AE32,$AD98,$ACFF,$AC66,$ABCE,$AB37,$AAA1
                DC.W $AA0C,$A977,$A8E3,$A850,$A7BE,$A72D,$A69D,$A60D
                DC.W $A57F,$A4F1,$A464,$A3D8,$A34D,$A2C3,$A23A,$A1B1
                DC.W $A12A,$A0A3,$A01E,$9F99,$9F15,$9E92,$9E10,$9D8F
                DC.W $9D0F,$9C90,$9C12,$9B95,$9B19,$9A9E,$9A23,$99AA
                DC.W $9932,$98BB,$9844,$97CF,$975B,$96E7,$9675,$9604
                DC.W $9594,$9525,$94B6,$9449,$93DD,$9372,$9308,$929F
                DC.W $9237,$91D0,$916B,$9106,$90A2,$9040,$8FDE,$8F7E
                DC.W $8F1F,$8EC0,$8E63,$8E07,$8DAC,$8D52,$8CFA,$8CA2
                DC.W $8C4B,$8BF6,$8BA2,$8B4F,$8AFD,$8AAC,$8A5C,$8A0D
                DC.W $89C0,$8973,$8928,$88DE,$8895,$884D,$8807,$87C1
                DC.W $877D,$873A,$86F8,$86B7,$8677,$8639,$85FC,$85BF
                DC.W $8584,$854B,$8512,$84DB,$84A4,$846F,$843C,$8409
                DC.W $83D7,$83A7,$8378,$834A,$831E,$82F2,$82C8,$829F
                DC.W $8277,$8250,$822B,$8207,$81E4,$81C2,$81A2,$8182
                DC.W $8164,$8147,$812C,$8111,$80F8,$80E0,$80C9,$80B4
                DC.W $809F,$808C,$807A,$806A,$805A,$804C,$803F,$8033
                DC.W $8029,$8020,$8018,$8011,$800B,$8007,$8004,$8002
                DC.W $8001,$8002,$8004,$8007,$800B,$8011,$8018,$8020
                DC.W $8029,$8033,$803F,$804C,$805A,$806A,$807A,$808C
                DC.W $809F,$80B4,$80C9,$80E0,$80F8,$8111,$812C,$8147
                DC.W $8164,$8182,$81A2,$81C2,$81E4,$8207,$822B,$8250
                DC.W $8277,$829F,$82C8,$82F2,$831E,$834A,$8378,$83A7
                DC.W $83D7,$8409,$843C,$846F,$84A4,$84DB,$8512,$854B
                DC.W $8584,$85BF,$85FC,$8639,$8677,$86B7,$86F8,$873A
                DC.W $877D,$87C1,$8807,$884D,$8895,$88DE,$8928,$8973
                DC.W $89C0,$8A0D,$8A5C,$8AAC,$8AFD,$8B4F,$8BA2,$8BF6
                DC.W $8C4B,$8CA2,$8CFA,$8D52,$8DAC,$8E07,$8E63,$8EC0
                DC.W $8F1F,$8F7E,$8FDE,$9040,$90A2,$9106,$916B,$91D0
                DC.W $9237,$929F,$9308,$9372,$93DD,$9449,$94B6,$9525
                DC.W $9594,$9604,$9675,$96E7,$975B,$97CF,$9844,$98BB
                DC.W $9932,$99AA,$9A23,$9A9E,$9B19,$9B95,$9C12,$9C90
                DC.W $9D0F,$9D8F,$9E10,$9E92,$9F15,$9F99,$A01E,$A0A3
                DC.W $A12A,$A1B1,$A23A,$A2C3,$A34D,$A3D8,$A464,$A4F1
                DC.W $A57F,$A60D,$A69D,$A72D,$A7BE,$A850,$A8E3,$A977
                DC.W $AA0C,$AAA1,$AB37,$ABCE,$AC66,$ACFF,$AD98,$AE32
                DC.W $AECD,$AF69,$B006,$B0A3,$B141,$B1E0,$B280,$B320
                DC.W $B3C1,$B463,$B506,$B5A9,$B64D,$B6F2,$B797,$B83D
                DC.W $B8E4,$B98C,$BA34,$BADD,$BB86,$BC30,$BCDB,$BD87
                DC.W $BE33,$BEE0,$BF8D,$C03B,$C0EA,$C199,$C249,$C2F9
                DC.W $C3AA,$C45C,$C50E,$C5C1,$C674,$C728,$C7DC,$C891
                DC.W $C947,$C9FD,$CAB3,$CB6A,$CC22,$CCDA,$CD93,$CE4C
                DC.W $CF05,$CFBF,$D07A,$D134,$D1F0,$D2AC,$D368,$D425
                DC.W $D4E2,$D59F,$D65D,$D71B,$D7DA,$D899,$D959,$DA19
                DC.W $DAD9,$DB99,$DC5A,$DD1C,$DDDD,$DE9F,$DF61,$E024
                DC.W $E0E7,$E1AA,$E26D,$E331,$E3F5,$E4BA,$E57E,$E643
                DC.W $E708,$E7CD,$E893,$E959,$EA1F,$EAE5,$EBAB,$EC72
                DC.W $ED39,$EE00,$EEC7,$EF8E,$F055,$F11D,$F1E5,$F2AD
                DC.W $F375,$F43D,$F505,$F5CE,$F696,$F75F,$F827,$F8F0
                DC.W $F9B9,$FA82,$FB4A,$FC13,$FCDC,$FDA5,$FE6E,$FF37
                DC.W $00,$C9,$0192,$025B,$0324,$03ED,$04B6,$057E
                DC.W $0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3
                DC.W $0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200
                DC.W $12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833
                DC.W $18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56
                DC.W $1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467
                DC.W $2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61
                DC.W $2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041
                DC.W $30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603
                DC.W $36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4
                DC.W $3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120
                DC.W $41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674
                DC.W $471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D
                DC.W $4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097
                DC.W $5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F
                DC.W $55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3
                DC.W $5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F
                DC.W $5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271
                DC.W $62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656
                DC.W $66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC
                DC.W $6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61
                DC.W $6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082
                DC.W $70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E
                DC.W $73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3
                DC.W $7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F
                DC.W $7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41
                DC.W $7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7
                DC.W $7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61
                DC.W $7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E
                DC.W $7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C
                DC.W $7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD
                DC.W $7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE

scrnpos:        DS.L 1          * Screen position (crafty place!).
scrn2:          DS.L 1

pal:            DC.W $000,$777,$667,$557,$447,$337,$227,$117
                DC.W $007,$006,$005,$004,$003,$002,$002,$001

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

xinc:		dc.w	4
zinc:		dc.w   2
yinc:		dc.w	5
xrot:		dc.w	56
yrot:		dc.w	24
zrot:		dc.w	276
xtrn:		dc.w	0
ytrn:		dc.w	0
ztrn:		dc.w	600
sxsy:		dc.w	159
cxsy:		dc.w	99

fl0p:		dc.w	41
fl1p:		dc.w	23
fl2p:		dc.w	23
fl3p:		dc.w	-215
fl4p:		dc.w	-11
fl5p:		dc.w	126
fl6p:		dc.w	17
fl7p:		dc.w	11
fl8p:		dc.w	23
fl9p:		dc.w	127
f10p:		dc.w	127
f11p:		dc.w	127
f12p:		dc.w	127
f13p:		dc.w	127
f14p:		dc.w	127

points:         DC.W    9-1        (x,y,z)
		dc.w    800,0,-800
		dc.w    800,0,0
		dc.w	800,0,800
		dc.w	0,0,-800
		dc.w	0,0,0
		dc.w	0,0,800
		dc.w	-800,0,-800
		dc.w	-800,0,0
		dc.w	-800,0,800
pobjs:		dc.w	9-1


section		BSS

beza		ds.w	3*3
bezb		ds.w	3*3
bezc		ds.w	3*3
bez1		ds.w	3*3

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
