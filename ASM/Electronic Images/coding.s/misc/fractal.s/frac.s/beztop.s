bze     equ     2
bzf     equ     4
wait4it equ     12000        ;6300
switch	equ	-1	;-1 for single first, 0 for multiple first
scx             EQU 159
scy             EQU 99
horizon         equ 18000
;#########################################
tosuper         clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.w  #6,SP
                move.l  D0,oldsp
;##########################################
setvids         lea     screens,A0
                adda.w  #256,A0
                move.l  A0,D0
                clr.b   D0
                move.l  D0,scrn1
                add.l   #32000,D0
                move.l  D0,scrn2
                add.l   #32000,D0
                move.l  D0,scrn3

                movea.l scrn1(PC),A0
                move.w  #5999,D0
                moveq   #0,D1
clean:          move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                dbra    D0,clean

                move.w  #37,-(SP)
                trap    #14
                addq.w  #2,SP
                clr.b   $FFFF8260.w
                lea     $FFFF8240.w,A0
                move.w  #$0,(A0)+      ; 0
                move.w  #$102,(a0)+    ; 1/2 !! (no colour 12)
                move.w  #$112,(A0)+    ; 1
                move.w  #$212,(A0)+    ; 2
                move.w  #$222,(A0)+    ; 3
                move.w  #$322,(A0)+    ; 4
                move.w  #$332,(A0)+    ; 5
                move.w  #$432,(A0)+    ; 6
                move.w  #$442,(A0)+    ; 7
                move.w  #$542,(A0)+    ; 8
                move.w  #$552,(A0)+    ; 9
                move.w  #$652,(A0)+    ; 10
                move.w  #$662,(A0)+    ; 11
                move.w  #$772,(A0)+    ; 13
                move.w  #$773,(A0)+    ; 14
                move.w  #$775,(A0)+    ; 15

                move    #$2700,SR
                move.l  $70.w,oldvbl
                move.l  #vbl,$70.w
                move.b  $FFFFFA07.w,sa1
                move.b  $FFFFFA09.w,sa2
                clr.b   $FFFFFA07.w
                clr.b   $FFFFFA09.w
                move    #$2300,SR
                moveq   #1,d0
                jsr     mus+28  ;turn it ON

;############ THE PROGRAM LOOP STARTS HERE (AT KEY)
key:
                move.b  lcount(PC),D0
                bne.s   over
sync:           cmp.b   lcount(PC),D0
                beq.s   sync

over:           clr.b   lcount
                move.l  scrn2(PC),D0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                move.l  scrn1(PC),-(SP)
                move.l  scrn2(PC),scrn1
                move.l  scrn3(PC),scrn2
                move.l  (SP)+,scrn3

		cmp.w	#0,bgflg
		beq	nowipe
                movea.l scrn2(PC),A0
                lea     32000(A0),A0
                moveq   #0,D0
                move.l  D0,D1
                move.l  D0,D2
                move.l  D0,D3
                move.l  D0,D4
                move.l  D0,D5
                move.l  D0,D6
                movea.l D1,A1
                movea.l D1,A2
                movea.l D1,A3
                movea.l D1,A4
                movea.l #%10000000111000101000,A5
                movea.l #1,A6
                moveq   #29-1,D7
wipe:
                REPT 21
                movem.l D0-D6/A1-A6,-(A0)
                ENDR
                dbra    D7,wipe
                REPT 6
                movem.l D0-D6/A1-A6,-(A0)
                ENDR
                movem.l D0-D4,-(A0)
nowipe:
;Now comes a load of rotations..  (the 9 source points)
;###################################################
                lea     lightsource,a2
                lea     lvert(pc),a1
                moveq   #0,d7
                lea     lix(pc),a6
                jsr     rots
                jsr     setlight


		lea	pyro(pc),a2	;destination data address
		lea	pyrs(pc),a1	;source data
		move.w	#3,d7		;no. of points - 1
		lea	pix(pc),a6	;rotation/translation data..
		lea	pvcs(pc),a5
		jsr	rots
		lea	pyro(pc),a2
		move.w	4(a2),d0
		ble.s	wait		

		jsr	doobj

                lea     beza(PC),A2     ; Get destination address.
                lea     bezv1(PC),A1    ; Get object address.
                move.w  #8,D7           ; Get number of points -1.
                lea     incx1(pc),a6    ;rotation & trans data.
                jsr     dobezo

                lea     beza(pc),a2
                lea     bezv2(pc),a1
                move.w  #8,d7
                lea     incx2(pc),a6
                jsr     dobezo
		bra.s	cont
wait		

                lea     beza(PC),A2     ; Get destination address.
                lea     bezv1(PC),A1    ; Get object address.
                move.w  #8,D7           ; Get number of points -1.
                lea     incx1(pc),a6    ;rotation & trans data.
                jsr     dobezo

                lea     beza(pc),a2
                lea     bezv2(pc),a1
                move.w  #8,d7
                lea     incx2(pc),a6
                jsr     dobezo
		
		lea	pyro(pc),a2	;destination data address
		lea	pyrs(pc),a1	;source data
		lea	pix(pc),a6	;rotation/translation data..
		lea	pvcs(pc),a5
		jsr	doobj
;################################################
cont            cmpi.b  #57,$FFFFFC02.w
                beq.s   quit
                bra     key
;####################################################
quit:
                move    #$2700,SR
                move.l  oldvbl(PC),$70.w
                move.b  sa1(PC),$FFFFFA07.w
                move.b  sa2(PC),$FFFFFA09.w
                move    #$2300,SR

flush:          btst    #0,$FFFFFC00.w
                beq.s   fl_done
                move.b  $FFFFFC02.w,D0
                bra.s   flush
fl_done:

                move.w  #$00,$FFFF8240.w
                move.w  #$47,$FFFF8242.w
                move.w  #$47,$FFFF8244.w
                move.w  #$77,$FFFF8246.w

                moveq   #0,d0
                jsr     mus+28

                move.l  oldsp(PC),-(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.w  #6,SP

                clr.w   -(SP)
                trap    #1
;#####################################################
dobezo
                jsr     rots
                jsr     dogrid
                jsr     drawgrid
                rts
;############################################################
doobj		
		move.w	(a5)+,d7	;pvcs in this case..
plnlp1		lea	poly(pc),a0
		move.w  (a5)+,d6	;no. of points..
		move.w	(a5)+,(a0)+	;colour
		move.w	d6,(a0)+	;no. of points - 1
plnlp2		move.w	(a5)+,d0	;data pointer..
		move.l	0(a2,d0.w),(a0)+  ;x and y
		move.w	4(a2,d0.w),(a0)+  ;z
		dbra	d6,plnlp2
		lea	poly(pc),a0
		movem.l d7/a2/a5,-(sp)
		jsr	dopoly
		movem.l	(sp)+,d7/a2/a5
		dbra	d7,plnlp1
		rts               
;############################################################
rots            
                move.w  0(a6),d0        ;add x,y,z increments to angles
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

* D0=CosX
* D1=SinX
* D2=CosY
* D3=SinY
* D4=CosZ
* D5=SinZ


* Cy*Cz,Cy*Sz,Sy
* !Sx*Sy!*Cz+Cx*-Sz,!Sx*Sy!*Sz+Cx*Cz,-Sx*Cy
* ;Cx*-Sy;*Cz+Sx*-Sz,;Cx*-Sy;*Sz+Sx*Cz,Cx*Cy

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


* Egg & Bacon

* A1 now contains pointer to xyzlist.

* d5=x
* d4=y
* d3=z

nexp:           move.w  (A1)+,D5        ; X
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

* That bit above has to be done because if it is included with the
* 4 channel player then it cannot use D6 or D7.


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


                move.w  D5,(A2)+        ; Store x.
                move.w  D4,(A2)+        ; Store y.
                move.w  D3,(A2)+        ; Store z. 

                dbra    D7,nexp         ; Next point.
                rts

;############################################################
vbl:            addq.b  #1,lcount
                movem.l d0-d4/a0,-(sp)

;##### ch a
chaon           moveq   #0,d0
                moveq   #0,d1
                lea     bezv1(pc),a0
chaok           move.b  #$1,$ffff8800.w
                move.b  $ffff8800.w,d0  ;coarse tuning
                and.b   #7,d0
                lsl.w   #8,d0
                move.b  #0,$ffff8800.w  ;fine tuning
                move.b  $ffff8800.w,d0
                lsl.w   #2,d0
                bne     suma
                move.w  #$523,d0
suma            neg.w   d0
                and.w   #$1fff,d0
                sub.w   d0,d1
                neg.w   d1
                move.w  d1,8(a0)
                move.w  d1,20(a0)
                move.w  d1,32(a0)
                move.w  d1,44(a0)
                move.w  d1,26(a0)
;#### ch b 
                moveq   #0,d0
                moveq   #0,d1
                lea     bezv2(pc),a0
                move.b  #$3,$ffff8800.w
                move.b  $ffff8800.w,d0  ;coarse..
                and.b   #7,d0
                lsl.w   #8,d0
                move.b  #2,$ffff8800.w
                move.b  $ffff8800.w,d0
                lsl.w   #2,d0
                bne     sumb
                move.w  #$523,d0
sumb            neg.w   d0
                and.w   #$1fff,d0
                sub.w   d0,d1
                move.w  d1,8(a0)
                move.w  d1,20(a0)
                move.w  d1,32(a0)
                move.w  d1,44(a0)
                move.w  d1,26(a0)
                jsr     mus+6+28
                movem.l (sp)+,d0-d4/a0
		subq.w	#1,longcnt
		bne	nexthi
		not.w	bgflg
		move.w	#wait4it,longcnt 
nexthi          cmp.w	#0,scrlflag
                bne.s	doscr
                rte
doscr		include vbl3232s.s
                rte
;###############################################
oldsp:          DS.L 1
oldvbl:         DS.L 1
sa1:            DS.B 1
sa2:            DS.B 1

lcount:         DS.B 1
longcnt:	dc.w wait4it	;no. of vblanks...
bgflg:		dc.w switch

                EVEN
scrn1:          DS.L 1
scrn2:          DS.L 1
scrn3:          DS.L 1
;##########################       ;scroll data
scrlflag:       dc.w 1
scrlpos:        DS.L 1
cbuff:          DC.W 0
whichbuf:       DC.L 0
inlet:          DS.W 1
buffptr:        DC.W (bufwd/2)+2
scrlcnt:        DC.W 0
textptr:        DC.L text
text:		dc.b ' '
		include  mesg.s
                DC.L 0
;##########################
lvert   dc.w    0,0,-108       ;source data.

lix     dc.w    13	;-5
liy     dc.w    7
liz     dc.w    0	;-7 

lrx     dc.w    312
lry     dc.w    0
lrz     dc.w    0

ltx     dc.w    0       \
lty     dc.w    0        |as this is normalised, it does shit.
ltz     dc.w    0       /

;##########################
;source data for triangles..
pix     dc.w     13	;-5
piy     dc.w     7
piz     dc.w     0	;-7 

prx     dc.w    312
pry     dc.w    0
prz     dc.w    0

ptx     dc.w    0       \
pty     dc.w    0        
ptz     dc.w    0       /

pyrs	dc.w	-500,-500,9000
	dc.w	 500,-500,9000
	dc.w	 0,500,9000
	dc.w	 0,0,9700	 ;four points


pvcs	dc.w	3		;planes - 1
	dc.w	2,5,6*2,6*3,6*0	;points, colour, pi, pj, pk... pn
	dc.w	2,4,6*3,6*1,6*0
	dc.w	2,3,6*3,6*2,6*1
	dc.w	2,15,6*1,6*2,6*0  

pyro	ds.w	3*4		;object data
;##########################
incx1:           DC.W  7
incy1:           DC.W  -5
incz1:           DC.W  -3

xang1:           DC.W 127
yang1:           DC.W 323
zang1:           DC.W -211

tx1:            dc.w    0
ty1:            dc.w    0
tz1:            dc.w    0

incx2:           DC.W  7
incy2:           DC.W  -5
incz2:           DC.W  -3

xang2:           DC.W 127
yang2:           DC.W 323
zang2:           DC.W -211

tx2:            dc.w    0
ty2:            dc.w    0
tz2:            dc.w    0
;###################
bezv1           dc.w     2000,-100,2000
                dc.w     2000,-100,0
                dc.w     2000,-100,-2000     ;left side done
                
                dc.w     0,-100,2000
                dc.w     0,6000,0
                dc.w     0,-100,-2000
                
                dc.w    -2000,-100,2000
                dc.w    -2000,-100,0
                dc.w    -2000,-100,-2000
;#####################
bezv2           dc.w     2000,-100,-2000
                dc.w     2000,-100,0
                dc.w     2000,-100,2000     ;left side done
                
                dc.w     0,-100,-2000
                dc.w     0,-6000,0
                dc.w     0,-100,2000
                
                dc.w    -2000,-100,-2000
                dc.w    -2000,-100,0
                dc.w    -2000,-100,2000
;#####################
beza            ds.w    3*3     ;9 rotated points
bezb            ds.w    3*3     ;x,y,z
bezc		ds.w	3*3     ;this has the rotted answers..
;####################
        include sintab.s
        include bezier1.s
        include 64polydr.s
        include polyclip.s
        include light5.s
mus:    incbin  'frac.s\go.czi'
font:   incbin  'frac.s\font.fe1'
;######################################################
        section  BSS
buff:
                REPT 4
                DS.B bufsize
                ENDR
screens:        DS.L 1
                END
