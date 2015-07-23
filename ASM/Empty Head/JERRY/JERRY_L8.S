MAXPOINTS: equ 2000 ;maximum points in this 3d system is 200
LINEWIDTH: equ 160 ;width of line in bytes

;MhzST	;fast as ST (8 Mhz 68000 & Blitter & Cache Off)
;DEBU	;debuging mode off / on
;OLDST	;OLD ST routs for trigons
;INF4BA	;information about lenght of time loop
;STE	;STE hardware used
;TOS404	;New XBIOS
;FPU68882	;Floating point unite in CPU mode

	output jerry.prg
;Copyright (c)1995 Empty Head
;Trigon (Trojuhelnik) v 1.0
;Written by Charlie Rous
;Copyright (c)1994,95 Empty Head
;tento program ma jako vstupni hodnoty
;Polyx1 ..x2..x3 a Polyy1 ..y2 ..y3
;Pole promennych zacina na VARIABLE

;TEST1	;testovani funkce pro mazani obrazovky
;TEST2	;testovani nejake instrukce

;only computing 2501 /200 sec    (16 Mhz 030)
;only computing 7999 /200 sec    (8 Mhz Cache off 030)
;computing & OLD ST 8666/200 sec 
;computing & OLD STE 9073/200 sec
;computing & Painting OLD STE HOG 8 MHZ 26189/200 SEC
;computing & Painting OLD ST 8 MHZ 25729/200 SEC

;07.02.96
;first remake ;-) (optimization)
;hidden surface algorhitm (I call it Z-buffering), but
;real I used a middle z-axis of every trigon & Radix sort
;for 16 bit numbers (4x4 bits)
;computing & Painting OLD STE HOG 8 MHZ 14389/200 SEC
;computing & Painting OLD ST 8 MHZ 15823/200 SEC
;computing & OLD ST 8 MHZ 7596/200 sec :-ooo 
;only computing 2535 /200 sec   :-(( (16 Mhz cache 030)

;evening
;only computing 2200 /200 sec   :-)) (16 Mhz cache 030)
;computing & OLD ST 8 MHZ 6606/200 sec :-ooo 

;computing & Painting OLD STE HOG 8 MHZ 13985/200 SEC

;7628 - 8 Mhz STE, absolutely differen object
;6972 - 8 Mhz New version of line painting
;7062

	include releasem.s
	include gxb.s
;supervisor
	clr.l -(a7)
	move.w #32,-(a7)
	trap #1
	addq.l #6,a7
	move.l d0,SAVE_STACK
TROJU	bra MAIN
SAVE_STACK: ds.l 1 ;uschovat STACK
VARIABLE: ds.w 250
x1 	equ 0
x2 	equ 2
Mezi 	equ 4
y1	equ 6
y2	equ 8
Yincr	equ 10
Aincr	equ 12
Bincr	equ 14 		 
d	equ 16
;volnych 14 word

a	equ 30
a1_a0	equ 32
Line	equ 34
Coltab	equ 36	;16*4 byte pro tabulku full masked polygon
		;4*4 byte pro plane polygon table, non-masked
Coljump	equ 116
Color	equ 120	;barva polygonu
Init	equ 122	;testovani, jestli se bude inicializovat
SCREEN	equ 124	;obrazova pamet 1
Triscr	equ 128	;obrazova pamet pro trojuhelnik 2
Triscr2	equ 132	;obrazova pamet pro trojuhelniky 3
AddOtocXZ	equ 136	;posun v ose Xz
AddOtocYZ	equ 138	;posun v ose Yz
AddZ	equ 140	;pribytek Z
TextX	equ 142	;souradnice X pro text
TextY	equ 144	;souradnice Y pro text
RotateX	equ 146 	;souradnice kolem ktere se budou objekty rotovat
RotateY	equ 148
RotateZ	equ 150
Deg	equ 152	;uhel (docasne pro otoceni)	
Text	equ 154	;pointer pro text
RotSmy	equ 158     ;smyckove pocitadlo
ObjField	equ 160	;ukazatatel na prave aktivni objekt
DegXZ	equ 164	;otoceni objektu v souradnici xz
DegYZ	equ 168	;otoceni objektu v souradnici YZ
Steps	equ 170	;kolikrat opakovat urcite otaceni
Cekat_VBL	equ 172	;flag pro cekani na VBL
DegXY	equ 176     ;rotation of objects in axis XY
AddOtocXY	equ 178	;one step in rot. XY
Counter	equ 180	;pocitadlo pro cekani
Cekani	equ 182	;pocet cekani pri vyjezdu pismene
Polyx1	equ 184	;souradncie x1...x3,y1...y3
Polyy1	equ 186
Polyx2	equ 188
Polyy2	equ 190
Polyx3	equ 192
Polyy3	equ 194
Polyx4	equ 196
Polyy4	equ 198
Polyx5	equ 200
Polyy5	equ 202
Polyx6	equ 204
Polyy6	equ 206


;kopie pole promennych, ale aby byla viditelna
;tento system nam pomuze pri odladovani
V_X1: 	equ VARIABLE+0
V_X2: 	equ VARIABLE+2
V_Mezi: 	equ VARIABLE+4
V_Y1: 	equ VARIABLE+6
V_Y2: 	equ VARIABLE+8
Y_Aincr:	equ VARIABLE+10
A_Bincr:	equ VARIABLE+12
B_Yincr:	equ VARIABLE+14
V_d:	equ VARIABLE+16
;volnych 14 word

V_A:	equ VARIABLE+30
V_A1_A0:	equ VARIABLE+32
V_Line:	equ VARIABLE+34
V_Coltab:	equ VARIABLE+36
V_Coljump:	equ VARIABLE+116
V_Color:	equ VARIABLE+120
V_Init:	equ VARIABLE+122
V_Screen	equ VARIABLE+124
V_Triscr:	equ VARIABLE+128
V_Triscr2	equ VARIABLE+132	;obrazova pamet pro trojuhelniky 3
V_AddOtocXZ	equ VARIABLE+136	;posun v ose Xz
V_AddOtocYZ	equ VARIABLE+138	;posun v ose Yz
V_AddZ	equ VARIABLE+140	;pribytek Z
V_TextX	equ VARIABLE+142	;souradnice X pro text
V_TextY	equ VARIABLE+144	;souradnice Y pro text
V_RotateX	equ VARIABLE+146
V_RotateY	equ VARIABLE+148
V_RotateZ	equ VARIABLE+150
V_Deg	equ VARIABLE+152	;uhel (docasne pro otoceni)	
V_Text	equ VARIABLE+154
V_RotSmy	equ VARIABLE+158
V_ObjField	equ VARIABLE+160	;ukazatatel na prave aktivni objekt
V_DegXZ	equ VARIABLE+164	;otoceni objektu v souradnici xz
V_DegYZ	equ VARIABLE+168	;otoceni objektu v souradnici YZ
V_Steps	equ VARIABLE+170	;kolikrat opakovat urcite otaceni
V_Cekat_VBL	equ VARIABLE+172        ;flag pro cekani na VBL
V_DegXY	equ VARIABLE+176	;rotation of objects in axis XY
V_AddOtocXY	equ VARIABLE+178	;one step in rot. XY
V_Counter	equ VARIABLE+180
V_Cekani	equ VARIABLE+182
V_Polyx1	equ VARIABLE+184	
V_Polyy1	equ VARIABLE+186
V_Polyx2	equ VARIABLE+188
V_Polyy2	equ VARIABLE+190
V_Polyx3	equ VARIABLE+192
V_Polyy3	equ VARIABLE+194
V_Polyx4	equ VARIABLE+196
V_Polyy4	equ VARIABLE+198
V_Polyx5	equ VARIABLE+200
V_Polyy5	equ VARIABLE+202
V_Polyx6	equ VARIABLE+204
V_Polyy6	equ VARIABLE+206
	
INICIAL:	lea Coltab(a6),a0	;sem budeme zapisovat hodnoty do tabulky
	ifd OLDST
	lea FILL_LINE0(pc),a1	;rutina pro barvu 0 - $ff8240
	move.l a1,(a0)+
	lea FILL_LINE1(pc),a1	;rutina pro barvu 1 - $ff8242
	move.l a1,(a0)+
	lea FILL_LINE2(pc),a1	;rutina pro barvu 2 - $ff8244
	move.l a1,(a0)+
	lea FILL_LINE3(pc),a1	;rutina pro barvu 3 - $ff8246
	move.l a1,(a0)+
	lea FILL_LINE4(pc),a1   ;rutina pro barvu 4 - $ff8248
	move.l a1,(a0)+
	lea FILL_LINE5(pc),a1   ;rutina pro barvu 5 - $ff824a
	move.l a1,(a0)+
	lea FILL_LINE6(pc),a1   ;rutina pro barvu 6 - $ff824c
	move.l a1,(a0)+
	lea FILL_LINE7(pc),a1   ;rutina pro barvu 7 - $ff824e
	move.l a1,(a0)+
	lea FILL_LINE8(pc),a1   ;rutina pro barvu 8 - $ff8250
	move.l a1,(a0)+
	lea FILL_LINE9(pc),a1   ;rutina pro barvu 9 - $ff8252
	move.l a1,(a0)+
	lea FILL_LINE10(pc),a1   ;rutina pro barvu 10 - $ff8254
	move.l a1,(a0)+
	lea FILL_LINE11(pc),a1   ;rutina pro barvu 11 - $ff8256
	move.l a1,(a0)+
	lea FILL_LINE12(pc),a1   ;rutina pro barvu 12 - $ff8258
	move.l a1,(a0)+
	lea FILL_LINE13(pc),a1   ;rutina pro barvu 13 - $ff825a
	move.l a1,(a0)+
	lea FILL_LINE14(pc),a1   ;rutina pro barvu 14 - $ff825c
	move.l a1,(a0)+
	lea FILL_LINE15(pc),a1   ;rutina pro barvu 15 - $ff825e
	move.l a1,(a0)+
	endc
	st Init(a6)		;priste uz nevolat inicializaci nastavi na 255
	rts

	include macros.s ;all switch macros
MAIN:	
	lea VARIABLE(pc),a6	;nastaveni na nase promenne
	;move.w #14,Color(a6)	;barva Trigonu
	tst.b Init(a6)
	bne.s NO_INIT
	bsr INICIAL
	
	ifd TEST2
	move.l $4ba,-(a7)
	lea $200000,a6
	lea $200000,a5
	move.w #200,d0
.TEST:	tst.b (a5)+ ;testovana instrukce
	subq.w #1,a6
	cmp.l #0,a6
	bne.s .TEST
	move.l $4ba.w,d0
	sub.l (a7)+,d0
	illegal
	endc	


	ifd TEST1
	move.l $44e,Triscr(a6)
	move.l $4ba,-(a7)
	move.w #200,d0
.TEST:	move.w d0,-(a7)
	bsr NEW
	move.w (a7)+,d0
	dbf d0,.TEST
	move.l $4ba.w,d0
	sub.l (a7)+,d0
	illegal
	endc	
	
NO_INIT:	bsr C
	bra SVERSIONJ
C:	ComputerTest
;BARVY:	
	dc.w $777,$666,$555,$fff,$eee,$bbb,$444,$333
	dc.w $777,$666,$555,$fff,$eee,$bbb,$444,$333
	
SVERSIONJ:	Sversion
	STlowon
	

DURING_MUSIC:
	move.w #0,DegXZ(a6)	;uhly jsou 0
	move.w #90,DegYZ(a6)
	move.w #0,DegXY(a6)

	ifnd DEBU
 	movem.l JERRY_COL,d0-d7
	movem.l d0-d7,$ffff8240.w
	move.l #JERRY_COL,$45a.w
	endc
	
	ifd INF4BA
	move.l $4ba,TIME4BA	;the lenght of loop in 1/200 sec
	endc




;CHAOS
	lea CHAOS(pc),a0
	;movem.l BARVY,d0-d7
	;movem.l d0-d7,$ffff8240.w
	move.w #0,d0 ;stred x
	move.w #0,d1 ;stred y
	move.w #0,AddOtocXZ(a6)
	move.w #4,AddOtocYZ(a6)
	move.w #4,AddOtocXY(a6)
	move.w #300,Steps(a6)
	bsr OBJECT_UP
 

	;movem.l CLR_BUF,d0-d7
	;movem.l d0-d7,$ffff8240.w

;set rozliseni
	STlowoff

;USER MOD & TIME RESULTS
	ifd INF4BA
	move.l $4ba,d0
	sub.l TIME4BA,d0
	illegal
	endc
	
	move.l SAVE_STACK,-(a7)
	move.w #32,-(a7)
	trap #1
	addq.l #6,a7
	
	clr.w -(a7)
	trap #1

ENDPRG:	;jmp (a6)
	clr.w -(a7)
	trap #1
gem_video:	ds.w 1

;CEKAT urcity pocet vbl, parametr v d0
CEKEJ_VBLS: move.w d0,d7
.CEKEJ:	move.w #37,-(a7)
	trap #14
	addq.l #2,a7
	dbf d7,.CEKEJ
	rts




;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ MAIN LOOP FOR COMPUTING OF 3D OBJECTS        ~
;~ START: IN 95         LAST UPDATE: 12.02.96   ~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


OBJECT_UP:
	lea CHAOS,a0
	lea STARFIELD,a1 ;decode POINTS
	move.w (a0)+,d7 ;points
	move.w d7,(a1)+
	move.w d7,d6
	subq.w #1,d7 ;dBF
	lsl.w #3,d6	;8bytes per one point
	lea (a0,d6.w),a5 ;adress of vertices of faces


	move.w #0,RotateX(a6) ;rotacni stred x je 0
	move.w #0,RotateY(a6) ;rotacni stred Y je 0
	move.w #1340,RotateZ(a6) ;1500,RotateZ(a6) ;z=0
	move.l a0,ObjField(a6) ;zapsat adresu objektu
	move.w d0,-(a7) ;stred X (pro odecet kvuli rotaci kolem stredu)	
	move.w d1,-(a7) ;stred y (pro odecet kvuli rotaci)
	move.l ObjField(a6),a0
	move.w (a7)+,d1 ;x stred realny v d0
	;sub.w #900,d1 ;puvodni y stred obrazovky
	move.w (a7)+,d0 ;y stred realny v d1
	;sub.w #160,d0 ;puvodni stred obrazovky
.NEXT_TRI:	;rept 3	
	move.w (a0)+,d3 ;x
	sub.w d0,d3
	move.w (a0)+,d4 ;y
	sub.w d1,d4
	move.w (a0)+,d5 ;z
	addq.l #2,a0    ;free place
	add.w #1340,d5 ;1500,d5 ;posunout stred Z o 300 do prostoru
	move.w d3,(a1)+ ;zapis x
	move.w d4,(a1)+ ;zapis y
	move.w d5,(a1)+ ;zapis z
	;clr.w (a1)+	;clear 
	;endr	
	dbf d7,.NEXT_TRI
	move.l a5,VERTICES	;addr of VERTICES

OBJECT_AGA:
			
	jsr ROTATEOBJECT
	bsr Z_BUFFERING	
	jsr D3_TO_D2OBJ
	;move.w #7,-(a7)
	;trap #1
	;addq.l #2,a7
	;cmp.b #'Q',d0
	;beq.s AAAA
	bsr CHANGE_SCR
	bsr NEW
	bsr JOYPAD

	
;rotace objektu
ADD_OBJ:	;lea VARIABLE(pc),a6
	move.w DegYZ(a6),d2 ;aktualni otoceni XZ do pameti
.XZCOUNT:	add.w AddOtocYZ(a6),d2
.NOXZ_CO:	tst.w d2
	bpl.s .NOT_MINUS
	add.w #360,d2
.NOT_MINUS:	cmp.w #359,d2
	bls.s .NOT_BIG
	sub.w #360,d2
.NOT_BIG:   move.w d2,DegYZ(a6)
ADDXZ:
	move.w DegXZ(a6),d2 ;XZ do pameti
.YZCOUNT:	add.w AddOtocXZ(a6),d2
.NOYZ_CO:	tst.w d2
	bpl.s .NOT_MINUS
	add.w #360,d2
.NOT_MINUS:	cmp.w #359,d2
	bls.s .NEXT_ADDIN
	sub.w #360,d2
.NEXT_ADDIN: move.w d2,DegXZ(a6)

ADDXY:
	move.w DegXY(a6),d2 ;XY do pameti
.YZCOUNT:	add.w AddOtocXY(a6),d2
.NOYZ_CO:	tst.w d2
	bpl.s .NOT_MINUS
	add.w #360,d2
.NOT_MINUS:	cmp.w #359,d2
	bls.s .NEXT_ADDIN
	sub.w #360,d2
.NEXT_ADDIN: move.w d2,DegXY(a6)

	btst #Fire_0,EXITFIRE+1 ;tst Fire 0 to exit
	beq.s EXIT

;cekej, dokud pocet kroku nedosahl pozadovaneho poctu
	;subq.w #1,Steps(a6)
	bra OBJECT_AGA
EXIT:	rts

	include JOYPAD.s

;trojuhelnik ma 
;data pro vektory, format je
;barva, x, y, x1,y1, x2, y2
;$ffff je konec

;CHAOS:
	dc.w 4,0,0,100,100,100,100,0,100,100
	dc.w 1,0,0,0,100,100,0,0,100,0
	dc.w $ffff

CHAOS:	incbin RAKETA.POV
	dc.w $ffff



;CHAOS:	dc.w 4,50,0,50,100,100,0,0,100,0
	dc.w 3,50,0,50,0,100,0,50,100,100
	dc.w 1,0,100,5,100,100,5,50,100,95
	dc.w 2,50,0,50,50,100,100,100,100,0
	dc.w $ffff
	


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ THIS PART COME WITH SOLUTION OF Z-BUFFERING  ~
;~ START: 21.01.96      LAST UPDATE: 12.02.96   ~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~ field for table z middle ~~~~~~~~~~~~~
MINSORT_L:
NOTHING set 0
	rept 16
	dc.l NOTHING*MAXPOINTS*4
NOTHING set NOTHING+1
	endr

;~~~~~~~~~ field for template offset table ~~~~~
TEMSORT_L:	
NOTHING set 0
	rept 16
	dc.l NOTHING*MAXPOINTS*4
NOTHING set NOTHING+1
	endr

;~~~ field for remake offset table with movem ~~~
OFFSET_BACKUP:
NOTHING set 8
	rept 8
	dc.l NOTHING*MAXPOINTS*4
NOTHING set NOTHING+1
	endr

NOTHING set 0
	rept 8
	dc.l NOTHING*MAXPOINTS*4
NOTHING set NOTHING+1
	endr

;~~ field for counting of real lenght of Radix ~~
OFFSET_BACKUP2:	
NOTHING set 0
	rept 16
	dc.l NOTHING*MAXPOINTS*4
NOTHING set NOTHING+1
	endr



Z_TRIGONS:	ds.w 1 ;number of trigons (existing) in world
FEFE_BUFFER: dcb.w 26,$ffff ;buffer for clearing of indication area
;Z MAX ponts is 2000
;Z MIN points is 2000 too

;we used a classical RADIX SORT
;FFF8         FFF8      F8 FE 
;FFF2	  FFF2	F2 F8
;FFFE  	  FFFE	FE F2
;0022	  0022	22 44
;0044	  0044	44 22

Z_BUFFERING:  ;I hope it will be

;~~~~~~~~     CLEAR MIN & MAX FIELD     ~~~~~~~~~

					
;~~~~~~~~     THE FIRST ARE EXTREMES    ~~~~~~~~~
	clr.w d0 ;number of trigon
	clr.l d1 ;clear, will be used as long (some people told, that it is faster)
	clr.l d2
	clr.l d3
	clr.w Z_TRIGONS
	lea -10(a7),a7	;local variables
	suba.l a6,a6
	lea MINIMUM_SORT,a4 ;set bank
	lea ROTFIELD,a2
	move.l VERTICES,a5 ;address of vertices
	move.w (a5),8(a7)  ;loop for all vertices
	addq.l #2,a5 ;jump belong counting
PREPARE_Z:	
	move.w (a5)+,d0	;first vertice
	lsl.w #3,d0	;8x
vx1	equr a0
vy1	equr a1
vz1	equr a3
vx	equr d1
vy	equr d2
vz	equr d3
wx	equr d4
wy	equr d5
wz	equr d6

	movem.w (a2,d0.w),vx1/vy1/vz1 ;x1
	move.w d0,(a7)	;we will need first vertice again
	
	move.w (a5)+,d0	;second vertice
	lsl.w #3,d0
	movem.w (a2,d0.w),d1-d3

	move.w (a5)+,d0	;third vertice
	lsl.w #3,d0
	movem.w (a2,d0.w),d4-d6

	movem.w d3/d6/a3,2(a7)	;Z axises back up
	
	sub.w vx1,vx
	sub.w vy1,vy
	sub.w vz1,vz
	sub.w vx1,wx
	sub.w vy1,wy
	sub.w vz1,wz

result1	equr d7
result2	equr d0
result_px	equr a0
result_py	equr a1
result_pz	equr a3

;now we finished a computing of vectors w & v :)
;now coming vector P= v*w

;px	
	move.w vy,result2
	muls.w wz,result2
	move.w vz,result1
	muls.w wy,result1
	move.l result2,result_px
	sub.l result1,result_px
;py
	move.w vz,result2
	muls.w wx,result2
	move.w vx,result1
	muls.w wz,result1
	move.l result2,result_py
	sub.l result1,result_py
;pz
	move.w vx,result2
	muls.w wy,result2
	move.w wx,result1
	muls.w vy,result1
	move.l result2,result_pz
	sub.l result1,result_pz

sx	equr d0
sy	equr d1
sz	equr d2
px	equr d3
py	equr d4
pz	equr d5
	
	move.w (a7),d7 ;offset to first vertice
	movem.w (a2,d7.w),sx/sy/sz
COPR:
	ifd FPU68882
	fmove.w sx,fp1
	fmove.w sy,fp2
	fmove.w sz,fp3
	;fmove sx,fp1
	
	fsub.w #22000,fp3
	move.l result_px,px
	move.l result_py,py
	move.l result_pz,pz
	fmove.l px,fp1
	fmove.l py,fp2
	fmove.l pz,fp3

	fmul fp1,fp4
	fmul fp2,fp5
	fmul fp3,fp6

q	equr d5	;computing of q
	fadd.x fp6,fp4
	fadd.x fp5,fp4
	fmove.l fp4,q ;tst fp4
	elseif

	sub.w #22000,sz
	move.l result_px,px
	move.l result_py,py
	move.l result_pz,pz
	asr.l #6,px	;precision (how much big is vector)
	asr.l #6,py
	asr.l #6,pz
	muls.w sx,px
	muls.w sy,py
	muls.w sz,pz

q	equr d5	;computing of q
	add.l py,q
	add.l px,q
	
	endc

	bpl .NONVISIBLE	
	beq .NONVISIBLE


	movem.w 2(a7),d1-d3 ;all z axis into d

.EXTREMES:	
	add.w d1,d2 ;compute the middle z_sum=sum_z/(faces-1)
	add.w d3,d2 ;well (z1+z2+z3)/2
	asr.w d2
	move.w a6,(a4)+ ;number of trigon face
	move.w d2,(a4)+ ;Z minimum to Z MIN_SORT
	addq.w #1,Z_TRIGONS
.NONVISIBLE:
	addq.l #2,a5    ;to next faces, belong color
	addq.w #1,a6     ;computing of trigons
	subq.w #1,8(a7) ;vertice down
	bne PREPARE_Z    ;next vertice

	lea 10(a7),a7    ;local variable back

;~~~~~~~~ THE SECOND IS SORT OF EXTREMES ~~~~~~~~
;~~~~~~~~ AND WRITE Z TRIGONS INTO       ~~~~~~~~
Z_PREPARED: ;subq.w #1,a6
	subq.w #1,Z_TRIGONS ;write a number of in DBF convention
	lea MINIMUM_SORT,a4 ;set fields
	lea TEMPLAT_SORT,a6

LSORT_CLR	macro \1	;CLR SORT (for one area)
	lea \1+64(pc),a2
	lea OFFSET_BACKUP(pc),a6
	rept 2
	movem.l (a6)+,d0-d7
	movem.l d0-d7,-(a2)
	endr
	endm
	

RADIX4BIT:	 macro \1,\2,\3,\4,\5
	move.w #\4,d7 ;logical and
	move.w #\3,d5 ;logical shifts
	lea \2,a6 ;destination
	lea \1,a4 ;source
	lea \5(pc),a2 ;lenght table
	move.w Z_TRIGONS,d6 ;number of trigons into d6		
.SORT4BIT:	move.l (a4)+,d0
	move.w d0,d1
	and.w d7,d1
	\6 d5,d1
	move.l (a2,d1.w),d3 ;offset to field for this one
	move.l d0,(a6,d3.l)  ;update new one
	addq.l #4,(a2,d1.w)  ;update lenght
	dbf d6,.SORT4BIT	
	endm

RADIX4BITGROUP: macro \1,\2,\3,\4,\5,\6,\7
	clr.l d1
	move.w #\4,d7 ;logical and
	move.w #\3,d5 ;logical shifts
	lea \2,a6 ;destination
	lea \1,a3 ;source
	lea \5(pc),a2 ;lenght table
	lea OFFSET_BACKUP2(pc),a0 ;this register I need for compute of lenght of offset
	lea \7(pc),a1 ;lenght table source
	move.w #15,d2 ;number of trigons into d6		
.NEXT_GROUPB:
	move.l (a1)+,d4 ;end of offset do d4
	move.l (a0)+,d1 ;base offset in d1
	sub.l d1,d4 ;lenght in d4
	lsr.w #2,d4
	subq.w #1,d4 ;dbf convention
	bmi.s .NEXT_DBFGROUP
	move.l a3,a4
	add.l d1,a4
.SORT4BIT:	move.l (a4)+,d0
	move.w d0,d1
	and.w d7,d1
	\6 d5,d1
	move.l (a2,d1.w),d3  ;lenght of this one
	addq.l #4,(a2,d1.w)  ;update lenght
	move.l d0,(a6,d3.l)  ;update new one
	dbf d4,.SORT4BIT	
.NEXT_DBFGROUP:
	dbf d2,.NEXT_GROUPB
	endm


GROUPS_TO_Z_BUFFER macro \1,\2
	lea \1,a5 ;source
	lea \2,a2 ;lenght table
	lea OFFSET_BACKUP2,a4 ;this register I need for compute of lenght of offset
	clr.l d2
	clr.l d0
	move.w #15,d1  ;count of groups 16
.NEXT_GROUP:
	move.l (a2)+,d0 ;read end of offset
	move.l d0,d2 ;to d2
	move.l (a4)+,d2 ;substract base offset
	sub.l d2,d0 ;in d0 is lenght
	lsr.w #2,d0
	subq.w #1,d0
	bmi.s .NEXT_DBFG
	move.l a5,a0
	add.l d2,a0
.COPY:	
	move.w (a0)+,(a3)+
	addq.l #2,a0
	dbf d0,.COPY
.NEXT_DBFG: 
	dbf d1,.NEXT_GROUP			
	endm

A1SORT:
	LSORT_CLR TEMSORT_L
	RADIX4BIT MINIMUM_SORT,TEMPLAT_SORT,2,$000f,TEMSORT_L,lsl.w
A2SORT:
	LSORT_CLR MINSORT_L
	RADIX4BITGROUP TEMPLAT_SORT,MINIMUM_SORT,2,$00f0,MINSORT_L,lsr.w,TEMSORT_L
A3SORT:
	LSORT_CLR TEMSORT_L
	RADIX4BITGROUP MINIMUM_SORT,TEMPLAT_SORT,6,$0f00,TEMSORT_L,lsr.w,MINSORT_L
A4SORT:
	LSORT_CLR MINSORT_L
	RADIX4BITGROUP TEMPLAT_SORT,MINIMUM_SORT,10,$f000,MINSORT_L,lsr.w,TEMSORT_L

	lea Z_BUFFER,a3
GROUPOUT:	GROUPS_TO_Z_BUFFER MINIMUM_SORT,MINSORT_L


WHOLE_Z_BUFFER:
;~~~~~~~~     CLEAR MIN FOR 200 FACES   ~~~~~~~~~
	lea MINIMUM_SORT+MAXPOINTS,a4 ;all this crap will in cache :-)
	move.w #(MAXPOINTS/40)-1,d0
	movem.l FEFE_BUFFER(pc),d1-d7/a0-a2
.CLR_SORTS:	
	movem.l d1-d7/a0-a2,-(a4)
	dbf d0,.CLR_SORTS

	rts


;tato cast je pro vykresleni znaku z 2DFIELD
;parametry pro TRIGON se ukladaji do
;Triscr(a6) , obrazovka, kam kresli trigon
;Color(a6), jeho barva 0-15
;Polyx1(a6)
;Polyx2(a6)
;Polyx3(a6) SOURADNICE
;Polyy1(a6)
;Polyy2(a6)
;Polyy3(a6)

;Vykresleni znaku z 2D field na obrazovku
		 

;po inicializaci promennych zacina samotne kresleni	
	ifnd OLDST
TRIGON:	
	
	include LINEREG7.S
	else
TRIGON:
	ifd CEKEJKEY ;pred kazdym trojuhelnikem cekat na klavesu
	ifnd DEBU
	move.w d0,-(a7)
	move.w #7,-(a7)
	trap #1
	addq.l #2,a7
	cmp.b #' ',d0
	beq BACK_UP
	move.w (a7)+,d0
	endc 
	endc

	lea Polyx1(a6),a1	;ukazatel na pole bodu trojuhleniku
	movem.w (a1),d0-d5	;naplneni poli o bodech trojuhelnik do d0-d6
	cmp.w d3,d1
	bls.s TEST_Y2
	exg d2,d0		;Srovnani bodu polygonu podle Y od nejvyssiho bodu po nejnizsi
	exg d1,d3
TEST_Y2:	cmp.w d5,d3
	bls.s ALL_OK
	exg d4,d2
	exg d5,d3
	cmp.w d3,d1
	bls.s ALL_OK
	exg d2,d0
	exg d1,d3

ALL_OK:	

X2_X3OK:	SF Line(a6)		;zrusit Line, mozna bude mozna ne ;-)
;budeme testovat jeste, jestli nejsou vsechny Y stejny, byla by to potom jen cara
	cmp.w d3,d1
	bne.s S_TRIPOI1
	move.b #1,Line(a6)		;je to jen cara, druhou cast Polygonu zrus
	cmp.w d5,d3
	bne.s S_TRIPOI1	;vsechny body jsou jen v jedne rade, prima
	ST Line(a6)		;je to jen cara, druhou cast Polygonu zrus
	cmp.w d0,d2		;v d0 bude bod nejvice vpravo
	bhs.s NOCHGD0	;jestli je d0 vetsi na d2, tak je vymenime
	exg d0,d2		;prohodit X1 a X2
NOCHGD0:	cmp.w d2,d4		;jestli je d
	bhi.s NOCHGD2	;nemenit d2
	exg d2,d4		;prohodit X2 a X3
NOCHGD2:	cmp.w d0,d2		;posledni srovnani
	bhs.s NOCHGD4	;posledni moznost prohozeni
	exg d0,d2		;prohodit X3 a X1
NOCHGD4:    move.w d0,d2
	bra A1_A0_S	
;pokud se bude jednat o dvoustranny trojuhelnik, jedna strana je pak zbytecna pouzijeme toho
S_TRIPOI1:	
	cmp.w d5,d3
	bne.s .TEST		;vsechny body jsou jen v jedne rade, prima
	move.b #2,Line(a6)	;hahaha, dvousouradnicove kresleni je taky vylouceno
.TEST:	tst.b Line(a6)	;Testovani, jestli nejsou nejake Y souradnice stejne
	beq.s S_TRIPOI		
	cmp.b #1,Line(a6)	;jestli je Y1 a Y2 stejny, musime to udelat tak,
	bne.s .TEST2	;ze X1 bude nejmensi a X2 ta vetsi hodnota
	cmp.w d0,d2
	bhs.w S_TRIPOI
	exg d2,d0		;kopirovat Y1 X1 do Y2 X2
	exg d1,d3
	bra.s S_TRIPOI
.TEST2	cmp.b #2,Line(a6)
	bne.s S_TRIPOI
	cmp.w d2,d4
	bhs.w S_TRIPOI
	exg d2,d4		;kopirovat Y1 X1 do Y2 X2
	exg d3,d5
S_TRIPOI:	clr.l d6
	clr.l d7
	movem.w d0-d5,(a1)	;ulozit serazene hodnoty, ted budeme pocitat, natvrdo ;-)
	SF a1_a0(a6)	;navestidlo pro poradi a1 a a0
;tento vzorec urcuje, jakym zpusobem budeme vykreslovat souradnice
;AB a AC, protoze v zavislosti na tom, jestli je bod B pod ci nad
;odvesnou je nutne zmenit offsetovaci tabulky A0 (AB) a A1(AC), tj.
;je vymenit
	move.w d5,d6	;Y3 do d6
	sub.w d1,d6		;v d6 je Y3-Y1(dy)
	move.w d4,d7	;x3 do d7
	sub.w d0,d7		;v d7 je X3-X1(dx)
	clr.l d5
	clr.l d4
	move.w d3,d5	;Y2 do d5
	sub.w d1,d5		;v d1 je Y2-Y1(fy)
	move.w d2,d4	;x2 do d4
	sub.w d0,d4		;odecist X1, v d4 je porovnavaci hodnota pro Fx
	muls d5,d7		;d7=fy*dx
	divs d6,d7		;d7=d7/dy
	cmp.w d7,d4		;
	ble.s A1_A0_S	;ponech kdyz je mensi nebo rovno
 	ST a1_a0(a6)	;budeme kreslit ctverec naopak
A1_A0_S:	
	cmp.b #1,Line(a6)
	beq.s ONLY_TWO_SIDES
	move.w Polyx1(a6),x1(a6)	;ulozit informace o prvnim bodu
	move.w Polyy1(a6),y1(a6)
	move.w Polyx2(a6),x2(a6)	;informace o primce AB ulozeny
	move.w Polyy2(a6),y2(a6)
	lea LINEAB(pc),a0	;budeme zapisovat sem
	bsr LINE		;a 'kresli'
	move.w Polyx1(a6),x1(a6)	;ulozit informace o prvnim bodu
	move.w Polyy1(a6),y1(a6)
	move.w Polyx3(a6),x2(a6)	;informace o primce AC ulozeny
	move.w Polyy3(a6),y2(a6)
	lea LINEAC(pc),a0
	bsr LINE
	move.w Polyx2(a6),x1(a6)	;ulozit informace o prvnim bodu
	move.w Polyy2(a6),y1(a6)
	move.w Polyx3(a6),x2(a6)	;informace o primce BC ulozeny
	move.w Polyy3(a6),y2(a6)
	lea LINEBC(pc),a0
	bsr LINE
;informace o carach vypocitany
	lea LINEAC(pc),a1
	lea LINEAB(pc),a0
	bra.s KLADNE

ONLY_TWO_SIDES:
	sf a1_a0(a6)		;to jestli je zpusob kresleni spravny urcuji ja :-/
	move.w Polyx1(a6),x1(a6)	;ulozit informace o prvnim bodu
	move.w Polyy1(a6),y1(a6)
	move.w Polyx3(a6),x2(a6)	;informace o primce AC ulozeny
	move.w Polyy3(a6),y2(a6)
	lea LINEAB(pc),a0
	bsr LINE
	move.w Polyx2(a6),x1(a6)	;ulozit informace o prvnim bodu
	move.w Polyy2(a6),y1(a6)
	move.w Polyx3(a6),x2(a6)	;informace o primce BC ulozeny
	move.w Polyy3(a6),y2(a6)
	lea LINEAC(pc),a0
	bsr LINE


;informace o carach vypocitany
	lea LINEAC(pc),a1
	lea LINEAB(pc),a0
			
KLADNE:	
;nakonec zmenit, toto je jen pro nase pouziti
;****************************
	move.l Triscr(a6),a2	;adresa obrazove pameti
	lea TAB_PAR2(pc),a3	;tabulka pro hodnotu 0-15
	;lea TAB_LINE(pc),a4	;Inverzni tabulka
	move.w (a0)+,d0
	move.w (a0)+,d0	;pocet radku ulozit
	bpl.s .TA1
	moveq.w #0,d0	;kdyby ta hodnota byla nahodou FFFF
.TA1:	move.w (a1)+,d1		
	move.w (a1)+,d1	;pocet radku BC ulozit
	bpl.s .TA2
	moveq.w #0,d1
.TA2:	cmp.w d0,d1		;zmena kvuli poradi, kratsi pocet radku bude pouzit
	bhs.s KLADNE2
	exg d0,d1
KLADNE2:	tst.b a1_a0(a6)
	beq.s FILL_VZ
	exg a0,a1
FILL_VZ:	move.w Color(a6),d1	;barva
	lsl.w #2,d1		;4 x vynasobit, tabulka pro jednotlive barvy
	move.l Coltab(a6,d1.w),Coljump(a6)
	move.l Coljump(a6),a5
	jsr (a5)	;odskok na kresleni
	tst.b Line(a6)	;polygon je jen cara, ihned ukonci
	bne.s THAT_ALL
	tst.b a1_a0(a6)
	bne.s TAKE_A1
A0SHORT:	lea LINEBC(pc),a0
	move.w (a0)+,d0		
	move.w (a0)+,d0	;pocet radku BC ulozit
.CONT2:	
	move.l Coljump(a6),a5
	jsr (a5)	;odskok na kresleni

THAT_ALL:	
	move.w #0,d0	;na zaver vzdy jeste jeden radek pridat, je tam, ale neni zaznamenan
	move.l Coljump(a6),a5
	jsr (a5)	;odskok na kresleni
	rts

TAKE_A1:	lea LINEBC(pc),a1
	move.w (a1)+,d0
	move.w (a1)+,d0
	move.l Coljump(a6),a5
	jsr (a5)	;odskok na kresleni
	move.w #0,d0	;na zaver vzdy jeste jeden radek pridat, je tam, ale neni zaznamenan
	move.l Coljump(a6),a5
	jsr (a5)	;odskok na kresleni
	rts



FILL_TRIGON  macro \1,\2,\3,\4,\5,\6,\7,\8,\9,\A      
FILL_LINE\A:
	movem.l \1(pc),d6-d7 ;vzorek pro polygon	
.FILL_LINE:	move.l a2,a5	;obnovit adresu obrazove pameti
	movem.w (a0)+,d2-d3	;d2 offset, d3 bod ve dvoubajtu
	movem.w (a1)+,d4-d5	;d3 offset, d4 dvoubajt
	sub.l d2,d4		;pocet byte plnenych stejnou barvou
	beq .ZERO_FILL	;vyplnovani trochu jinak
	bmi .FUCK_FILL
;vypocet je nasledujici 8 byte zacatek, rozdil mezi offsety, 8 bajtu konec
	add.w d3,d3		;vynasobit, vybirame z tabulky
	add.w d5,d5		;2x
	move.w (a3,d3.w),d3	;ulozit skutecnou hodnotu
	move.w 32(a3,d5.w),d5	;ulozit druhou masku
	add.l d2,a5		;pricti ho k obrazove pameti
	not.w d3
	and.w d3,(a5)+	;nejdriv si oblast peclive zmaskujeme
	and.w d3,(a5)+
	and.w d3,(a5)+
	and.w d3,(a5)+
	not.w d3
	\2or.w d3,\3(a5)
	\4or.w d3,\5(a5)
	\6or.w d3,\7(a5)
	\8or.w d3,\9(a5)
	sub.w #16,d4	;snizit o osm, jelikoz atd.
	bmi.s .NOT_COPY
	beq.s .SMALL
	;illegal
	ror.l #5,d4		;budeme pracovat s tabulkou pro kopirovani (filling) vnitrku trojuhelniku
	tst.w d4
	beq.s .JEN_MALE
	subq.w #1,d4
.BIG:	move.l d6,(a5)+
	move.l d7,(a5)+
	move.l d6,(a5)+
	move.l d7,(a5)+
	move.l d6,(a5)+
	move.l d7,(a5)+
	move.l d6,(a5)+
	move.l d7,(a5)+
	dbf d4,.BIG
	clr.w d4
.JEN_MALE:	
	rol.l #2,d4
	;subq.w #1,d4
.SMALL:	move.l d6,(a5)+
	move.l d7,(a5)+
	dbf d4,.SMALL
.NOT_COPY:not.w d5
	and.w d5,(a5)+	;nejdriv si oblast peclive zmaskujeme
	and.w d5,(a5)+
	and.w d5,(a5)+
	and.w d5,(a5)+
	not.w d5
	\2or.w d5,\3(a5)	;dokreslit bok
	\4or.w d5,\5(a5)
	\6or.w d5,\7(a5)
	\8or.w d5,\9(a5)	;a hotovo
	dbf d0,.FILL_LINE	;dalsi radek
	rts

;timto zpusobem budeme vyplnovat pouze v pripade, ze je vzdalenost obou offset rovna 0 byte
.FUCK_FILL:	;zbavili jsme se nepochopitelneho poskoceni o 8 bodu
	moveq.w #15,d5	;jelikoz je nastaveny prvni bit v predchazejicim byte a mi ho ignorujeme, musi byt nastaveny posledni v tom dalsim, aby to bylo O.K.
.ZERO_FILL:  
	
	add.l d2,a5		;abychom mohli pouzivat syntaxi -(a0)
	sub.w d5,d3
	bpl.s .OK
	neg.w d3
.OK:
	add.w d3,d3
	move.w (a3,d3.w),d3	;ulozit skutecnou hodnotu
	lsl.w d5,d3
	not.w d3
	and.w d3,(a5)+	;nejdriv si oblast peclive zmaskujeme
	and.w d3,(a5)+
	and.w d3,(a5)+
	and.w d3,(a5)+
	not.w d3
	\2or.w d3,\3(a5)
	\4or.w d3,\5(a5)
	\6or.w d3,\7(a5)
	\8or.w d3,\9(a5)
	dbf d0,.FILL_LINE	;dalsi radek
	rts
	endm



VZOREK15:	dc.l $ffffffff,$ffffffff		

	FILL_TRIGON VZOREK15,,-2,,-4,,-6,,-8,15
;$ff8240
VZOREK0:	dc.l 0,0	
	FILL_TRIGON VZOREK0,;,,;,,;,,;,,0

;ff8242
VZOREK1:	dc.l $ffff0000,$00000000	
	FILL_TRIGON VZOREK1,,-8,;,,;,,;,,1

;ff8244
VZOREK2:	dc.l $0000ffff,$00000000	
	FILL_TRIGON VZOREK2,;,,,-6,;,,;,,2

;ff8246
VZOREK3:	dc.l $ffffffff,$00000000	
	FILL_TRIGON VZOREK3,,-8,;,,,-6,;,,3

;$ff8248
VZOREK4:	dc.l $00000000,$ffff0000	

	FILL_TRIGON VZOREK4,;,,;,,;,,,-4,4
	
;$ff824a
VZOREK5:	dc.l $ffff0000,$ffff0000

	FILL_TRIGON VZOREK5,,-8,;,,,-4,;,,5


;ff824a
VZOREK6:	dc.l $0000ffff,$ffff0000

	FILL_TRIGON VZOREK6,,-6,;,,,-4,;,,6

;$ff824e
VZOREK7:	dc.l $ffffffff,$ffff0000

	FILL_TRIGON VZOREK7,,-8,,-6,,-4,;,,7


;$ff8250
VZOREK8:	dc.l $00000000,$0000ffff
	FILL_TRIGON VZOREK8,,-2,;,,;,,;,,8


;$ffff8252
VZOREK9:	dc.l $ffff0000,$0000ffff
	FILL_TRIGON VZOREK9,,-2,;,,;,,,-8,9

;$ff8254
VZOREK10:	dc.l $0000ffff,$0000ffff
	FILL_TRIGON VZOREK10,,-2,;,,;,,,-6,10


;$ff8256
VZOREK11:	dc.l $ffffffff,$0000ffff
	FILL_TRIGON VZOREK11,,-2,;,,,-8,,-6,11

;$ff8258
VZOREK12:	dc.l $00000000,$ffffffff
	FILL_TRIGON VZOREK12,,-2,;,,;,,,-4,12

;$ff825a
VZOREK13:	dc.l $ffff0000,$ffffffff
	FILL_TRIGON VZOREK13,,-2,;,,,-4,,-8,13

;$FF825C
VZOREK14:	dc.l $0000ffff,$ffffffff
	FILL_TRIGON VZOREK14,,-2,;,,,-4,,-6,14
	

TAB_PAR2:   ;dc.w %0000000000000000
	dc.w %0000000000000001
	dc.w %0000000000000011
	dc.w %0000000000000111
	dc.w %0000000000001111
	dc.w %0000000000011111
	dc.w %0000000000111111
	dc.w %0000000001111111
	dc.w %0000000011111111
	dc.w %0000000111111111
	dc.w %0000001111111111
	dc.w %0000011111111111
	dc.w %0000111111111111
	dc.w %0001111111111111
	dc.w %0011111111111111
	dc.w %0111111111111111
	dc.w %1111111111111111




	
TAB_PAR:	
	dc.w %1111111111111111
	dc.w %1111111111111110
	dc.w %1111111111111100
	dc.w %1111111111111000
	dc.w %1111111111110000
	dc.w %1111111111100000
	dc.w %1111111111000000
	dc.w %1111111110000000
	dc.w %1111111100000000
	dc.w %1111111000000000
	dc.w %1111110000000000
	dc.w %1111100000000000
	dc.w %1111000000000000
	dc.w %1110000000000000
	dc.w %1100000000000000
	dc.w %1000000000000000
	dc.w %0000000000000000


LINE:		
	move.w x2(a6),d1
	cmp.w x1(a6),d1	;porovnani, ktere cislo je vetsi
	bhi.s OK
	move.l x1(a6),d7	;x1.w a x2.w jsou hned za sebou
	swap d7		;swapnuti
	move.l d7,x1(a6)	;ulozit
	move.l y1(a6),d7	;y1 a y2.w jsou taky za sebou
	swap d7
	move.l d7,y1(a6)
OK:	move.w y2(a6),d1
	move.w x2(a6),d7	;vypocitat dx, ktere umistime do reg d7
	sub.w x1(a6),d7
	move.w y2(a6),d6	;vypocitat dy, ktere umistime do reg d6
	sub.w y1(a6),d6
	bpl.s .OK3
	neg.w d6		;zmenit ze zaporneho na kladne (ABS)
	
.OK3	cmp.w d6,d7		;testuji, zda-li nebudeme muset pouzit druhou metodu, tj. dx/dy<1 =>dy>dx	
	blo OBRACENE
;vypocet d, Aincr a Bincr a Yincr
	cmp.w y1(a6),d1
	bhi.s .OK2
	move.w #-160,Yincr(a6)
	bra.s .DAL
.OK2:	move.w #160,Yincr(a6)
.DAL:
	move.w d6,d5	;d= 2*dy-dx ; d je v reg d5
	lsl.w d5	
	sub.w d7,d5
	move.w d5,d(a6)

	move.w d6,d4	;Aincr = 2* (dy - dx); Aincr je v reg. d4
	sub.w d7,d4
	lsl.w d4
	move.w d4,Aincr(a6)
	
	lsl.w d6		;Bincr=2*dy
	move.w d6,Bincr(a6)	;ulozit

;nastaveni souradnic pro vypocet prvniho bodu
	move.w x1(a6),d3	;nastavit pocatecni souradnice 
	move.w y1(a6),d2
	
	bsr SETPIXEL	;nastav bod a souradnici Y (d2)
;nastaveni dulezitych parametru potrebnych pro vykresleni

;do d1 konstantu pro pricitani y
;Aincr do d3
;Bincr do d4
	moveq.w #1,d7	;konstanta urcena na pomoc instrukci ROR
	
	movem.w Yincr(a6),d1/d3-d4
	tst.w d1		;testujeme, jestli budeme radky pridavat nebo ubirat
	bmi.s UBIRAT	;budeme ubirat	

	move.w y2(a6),d0
	sub.w y1(a6),d0		;v d0 bude smycka, ktera se pocita
	bpl ...
	neg.w d0
...:	
	subq.w #1,d0
	move.w d0,(a0)+
	move.w x2(a6),d0
	sub.w x1(a6),d0		;v d0 bude smycka, ktera se pocita
	beq.s RETURN2
	subq.w #1,d0
	move.w d2,(a0)+	;zapsat informace o offsetu
	move.w d6,(a0)+	;zapsat informace o X ve dvoubajtu
			
PAINT:	tst.w d5		
	bpl.s .CHANGE
	add.w d4,d5		;pricti Bincr k d
	bra.s .NO_CHANGE	
.CHANGE:	add.w d1,d2		;pricti Yincr k y
;toto je zde 2x, protoze musime dosahnout stejneho efektu pri kresleni vsech car, jinak se nam blbe posunou souradnice a je to v prd.
	subq.w #1,d6	;snizit bod o jednu
	bcs.s .SET2
	move.w d2,(a0)+
	move.w d6,(a0)+	;pozici v radku (offset od pocatku obrazovky
	add.w d3,d5		;pricti Aincr k d
	dbf d0,PAINT	;uz jsem to jednou nastavil, dalsi bod
	rts
;tady probiha samotne nastaveni bodu	
.NO_CHANGE:	subq.w #1,d6	;snizit bod o jednu
	bcs.s .SET
.DBF:	dbf d0,PAINT
	rts

.SET:	addq.w #8,d2	;jestlize nedochazi k prechodu na dalsi plane, tak nezvysuj adresu
	moveq #15,d6	;posun na dalsi plane
	dbf d0,PAINT
	rts

.SET2:	addq.w #8,d2	;jestlize nedochazi k prechodu na dalsi plane, tak nezvysuj adresu
	moveq #15,d6	;posun na dalsi plane
	move.w d2,(a0)+
	move.w d6,(a0)+	;pozici v radku (offset od pocatku obrazovky
	add.w d3,d5		;pricti Aincr k d
	dbf d0,PAINT	;uz jsem to jednou nastavil, dalsi bod
RETURN2:	rts


;kdyz budeme radky ubirat, skocime sem
UBIRAT:	move.w y2(a6),d0
	sub.w y1(a6),d0
	bpl.s ..
	neg.w d0
..:	
	subq.w #1,d0
	move.w d0,(a0)+
	addq.w #2,d0
	lsl.w #2,d0		;vynasobit 4x, pote se posunem na konec pole pro tento polygon
	ext.l d0
	add.w d0,a0
	move.w d2,-4(a0)	;zapsat informace o offsetu
	move.w d6,-2(a0)	;zapsat informace o X ve dvoubajtu
	
	move.w x2(a6),d0
	sub.w x1(a6),d0		;v d0 bude smycka, ktera se pocita
	beq.s RETURN2Q
	subq.w #1,d0		

PAINTQ:	tst.w d5		
	bpl.s .CHANGEQ
	add.w d4,d5		;pricti Bincr k d
	bra.s .NO_CHANGEQ	
.CHANGEQ:	
	add.w d1,d2		;pricti Yincr k y
	subq.l #4,a0	;posunout se na predchazejici prvek pole
	add.w d3,d5		;pricti Aincr k d
;tady probiha samotne nastaveni bodu	
.NO_CHANGEQ:
	subq.w #1,d6	;snizit bod o jednu
	bcs.s .SETQ		;jestlize nedochazi k prechodu na dalsi plane, tak nezvysuj adresu
	move.w d2,-4(a0)	;pozici bodu
	move.w d6,-2(a0)	;pozici v radku (offset od pocatku obrazovky
.DBFQ:	dbf d0,PAINTQ
	rts

.SETQ:	moveq #15,d6
	addq.w #8,d2	;posun na dalsi plane
	move.w d2,-4(a0)	;pozici bodu
	move.w d6,-2(a0)	;pozici v radku (offset od pocatku obrazovky
	dbf d0,PAINTQ
RETURN2Q:	rts


;Tato rutina pro kresleni cary je pouzita, jestlize je dy>dx, potom se
;totiz musi pocitat v prevracenych hodnotach, tj. automaticky se pokazde
;zvysi dy a jenom obcas dx
OBRACENE:
	exg d6,d7		;prohodit dx a dy, jinak vse totozne
	move.w y2(a6),d6	;testuji jestli neni zaporny dy
	sub.w y1(a6),d6
	bpl.s .ALL_RIGHT
	move.l x1(a6),d7	;x1.w a x2.w jsou hned za sebou
	swap d7		;swapnuti
	move.l d7,x1(a6)	;ulozit
	move.l y1(a6),d7	;y1 a y2.w jsou taky za sebou
	swap d7
	move.l d7,y1(a6)
;opetovne prepocitani dx,dy	
.ALL_RIGHT:	
	move.w x2(a6),d1
	move.w y2(a6),d6	;vypocitat dy, ktere umistime do reg d6
	sub.w y1(a6),d6
	move.w x2(a6),d7	;vypocitat dx, ktere umistime do reg d7
	sub.w x1(a6),d7
	bpl.s ALL_RIGHT
	neg.w d7
	
	
ALL_RIGHT:	cmp.w x1(a6),d1
	bhi.s .OK2
	move.w #-1,Yincr(a6)
	bra.s .DAL
.OK2:	move.w #1,Yincr(a6)
.DAL:	move.w d7,d5	;d= 2*dx-dy ; d je v reg d5
	lsl.w d5	
	sub.w d6,d5
	move.w d5,d(a6)

	move.w d7,d4	;Aincr = 2* (dx - dy); Aincr je v reg. d4
	sub.w d6,d4
	lsl.w d4
	move.w d4,Aincr(a6)
	
	lsl.w d7		;Bincr=2*dx
	move.w d7,Bincr(a6)	;ulozit nazpet

;inicializovani souradnic	
	move.w x1(a6),d3	;nastavit pocatecni souradnice 
	move.w y1(a6),d2
	bsr SETPIXEL	;nastav bod, v d2 bude po ukonceni spravna souradnice Y
	move.w y2(a6),d0
	sub.w y1(a6),d0	;v d0 bude smycka, ktera se pocita
	beq.s RETURN
	subq.w #1,d0	;konverze DBF
	move.w d0,(a0)+	;jako druhy parametr zapsat pocet radku-1 kvuli DBF
	
;zapis parametru potrebnych pri kresleni cary
	move.w Aincr(a6),d7	;dalsi parametr potrebny pri vypoctu cary
	move.w Bincr(a6),d1	;potrebujeme pri vypoctu souradnice
	move.w #160,d4	;nastavit pocitadlo Y
	moveq.w #1,d3	;poslouzi pri rolovani a rorovani, pomocna konstanta (setri 4 takty :-)

;zapis prvni informace o offsetu bodu
	move.w d2,(a0)+	;zapsat informace o offsetu
	move.w d6,(a0)+	;zapsat informace o X ve dvoubajtu

	tst.w Yincr(a6)	;testujem pribyvani, tj. bude kladna - ci zaporna. Pro kazdou z nich mame zvlastni rutinu
	bmi.s PAINT_SUBX	;pri care budeme x snizovat
PAINT_ADDX:	tst.w d5		
	bpl.s .CHANGE2
	add.w d1,d5		;Bincr k d, udela d kladny (snad uz priste :-))
	bra.s .NO_CHANGE
;Vypocet bodu, tentokrat se urcite zvysi
.CHANGE2:	
	add.w d7,d5		;pricti Aincr k d
;umisteni bodu  je reseno v zavislosti na Yincr, bud se souradnice x snizi, nebo zvysi
	subq.w #1,d6	;snizit bod o jednu
	bcs.s .WAS_CHANGE
.NO_CHANGE:	add.w d4,d2		;zvys y, posun se na dalsi radek
	move.w d2,(a0)+	;zapsat informace o offsetu
	move.w d6,(a0)+	;zapsat informace o X ve dvoubajtu
.DBF	dbf d0,PAINT_ADDX
	rts

.WAS_CHANGE:
	add.w d4,d2		;zvys y, posun se na dalsi radek
	addq.w #8,d2
	moveq #15,d6	;a opet nastavit
	move.w d2,(a0)+	;zapsat informace o offsetu
	move.w d6,(a0)+	;zapsat informace o X ve dvoubajtu
	dbf d0,PAINT_ADDX
RETURN:	rts

PAINT_SUBX:	tst.w d5		
	bpl.s .CHANGE2
	add.w d1,d5		;Bincr k d, udela d kladny (snad uz priste :-))
	bra.s .NO_CHANGE2
;Vypocet bodu, tentokrat se urcite zvysi
.CHANGE2:	
			;ale aby to bylo jednodussi se jmeny ;-) k x, jelikoz tentokrat vyuzivame obraceny postup dx<dy
	add.w d7,d5		;pricti Aincr k d
	addq.w #1,d6	;zvys X ovou souradnici
	cmp.w #16,d6
	beq.s .WAS_CHANGE2
	
.NO_CHANGE2:
	add.w d4,d2		;zvys y, posun se na dalsi radek
	move.w d2,(a0)+	;zapsat informace o offsetu
	move.w d6,(a0)+	;zapsat informace o X ve dvoubajtu
.DBF	dbf d0,PAINT_SUBX
	rts

.WAS_CHANGE2:	
	clr.w d6		;vynulovat souradnici a posunout se
	subq.w #8,d2
	add.w d4,d2		;zvys y, posun se na dalsi radek
	move.w d2,(a0)+	;zapsat informace o offsetu
	move.w d6,(a0)+	;zapsat informace o X ve dvoubajtu
	dbf d0,PAINT_SUBX
	rts
	

;procedura nastaveni bodu
SETPIXEL:	
	move.w d3,d4	;souradnice x i do d4
	lsr.w #1,d4		;v d4 pocatecni cislo souradnice 
	and.w #%1111111111111000,d4 ;upravuju na cislo delitelne 8 pro umisteni na screenu
	clr.w d6		;smazat, zde bude vzorek cary, potrebujeme
	and.w #15,d3	;(d6=15) v d2 pocatecni cislo bajtu
	eor.b #15,d3	;(d6=15) obratit hodnotu, abychom mohli umistit, jako bset
	move.w d3,d6	;cislo nastaveneho bodu do barvy 0-15
.NIC	move.w d2,(a0)+	;zapsat informace o prvnim radku do pole pro Polygon
	move.w d2,d7	;v d2 je cislo radku
	add.w d7,d7	
	add.w d7,d7
	add.w d2,d7
	lsl.w #5,d7
	add.w d4,d7
	move.w d7,d2	;oddted mame v d2, tj. souradnci y natrvalo zanesenou i souradnici x ve dvoubajtech 
	rts
	endc
		
;hlavicka pole LINE je nasledujici
;1 word Pocatecni radek hranicici primky polygonu (normalni cislo)
;2 word Pocet radku teto hranicni primce polygonu
;a dale vzdy 1 word oznacuje cislo bodu ve dvoubajtu
;a dalsi word je offset na tento dvoubajt
;pole jednotlivych primek u trojuhelniku
LINEAB: ds.w 404
LINEAC: ds.w 404
LINEBC: ds.w 404




;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ SPACE ROTATION AROUND ALL AXIS               ~
;~ START: IN 95      LAST UPDATE: 25.01.96      ~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;SPACE v 2.0

;  /----/ 
; /----/Z
; |   |
;Y|   | /
; |   |/
; -----
;   X

;~~~~~~~~~~~~ Rotation for whole object ~~~~~~~~~
;a6 is pointer to VARIABLE Field
;after whole object jump there
W_OBJECT: rts
ROTATEOBJECT:
	lea STARFIELD,a5 ;pointer to main field
	lea ROTFIELD,a4 ;pointer to rotated field
	lea COS_TABLE(pc),a2 ;Sinus table (0-359)
	lea D2_FIELD,a1 ;Cosinu table (0-359)
	movem.w  RotateX(a6),d7/a0/a3 ;Rotate X,Y,Z (middle point)
	swap d7	;need d7 half 
	move.w (a5)+,d7 ;loop for points
.NEXT_ROT:	
.DALSIBOD:	
	swap d7	;need d7 second half 
	movem.w (a5)+,d2-d4	;copy points X,Y,Z
	sub.w d7,d2		;dx differen between middle and main point
	sub.w a0,d3		;dy
	sub.w a3,d4		;dz

;~~~ now coming rotation XZ                   ~~~
	move.w DegXZ(a6),d0	;in d1 is angle
	beq.s .YZ	;no rotation no counting
	add.w d0,d0		;2x (cos & sin tables are in words)

	move.w (a2,d0.w),d1     ;cos of angle
	add.w #720,d0	;to sin table
	move.w (a2,d0.w),d0	;sin of angle
	move.w d0,d5	;sin copy
	move.w d1,d6 	;cos copy

 	muls d2,d0 ;sin*x
	muls d1,d2 ;cos*x in d2 will be result again I'm quite happy ;-)
	muls d4,d5 ;sin*z
	muls d6,d4 ;cos*z

;Xt=-Z*sin()[d5]+X*cos()[d2]
	sub.l d5,d2
;Zt=X*sin()[d0]+Z*cos()[d4]
	add.l d0,d4 ;Zt again in d4

;the numbers of sinus was from -32767 to 32767
;now we give it back, so 2x number & swap
;is same as asr.l #15 ;-)
	add.l d4,d4
	add.l d2,d2
	swap d4
	swap d2

;~~~ in d2 we got rotated X and in d4 is it Y ~~~
;~~~ that's right :-)                         ~~~
;~~~ now coming rotation YZ                   ~~~

.YZ:	move.w DegYZ(a6),d0	;in d1 is angle
	beq.s .XY	;no rotation no counting
	add.w d0,d0		;2x (cos & sin tables are in words)

	move.w (a2,d0.w),d1     ;cos of angle
	add.w #720,d0	;to sin table
	move.w (a2,d0.w),d0	;sin of angle
	move.w d0,d5	;sin copy
	move.w d1,d6 	;cos copy

 	muls d3,d0 ;sin*y
	muls d1,d3 ;cos*y
	muls d4,d5 ;sin*z
	muls d6,d4 ;cos*z

;Yt=-Z*sin()[d5]+Y*cos()[d3]
	sub.l d5,d3
;Zt=Y*sin()[d0]+Z*cos()[d4]
	add.l d0,d4

;the numbers of sinus was from -32767 to 32767
;now we give it back, so 2x number & swap
;is same as asr.l #15 ;-)
	add.l d4,d4
	add.l d3,d3
	swap d4
	swap d3


;~~~ in d3 we rotated Y and in d4 it is Z     ~~~
;~~~ that's right :-)                         ~~~
;~~~ now coming rotation XY                   ~~~
.XY:
	move.w DegXY(a6),d0	;in d1 is angle
	beq.s .BACK	;no rotation no counting
	add.w d0,d0		;2x (cos & sin tables are in words)

	move.w (a2,d0.w),d1     ;cos of angle
	add.w #720,d0	;to sin table
	move.w (a2,d0.w),d0	;sin of angle
	move.w d0,d5	;sin copy
	move.w d1,d6 	;cos copy

 	muls d2,d0 ;sin*x
	muls d1,d2 ;cos*x
	muls d3,d5 ;sin*y
	muls d6,d3 ;cos*y

;Xt=-Y*sin()[d3]+X*cos()[d1]
	sub.l d5,d2
;Yt=X*sin()[d0]+Y*cos()[d6]
	add.l d0,d3

;the numbers of sinus was from -32767 to 32767
;now we give it back, so 2x number & swap
;is same as asr.l #15 ;-)
	add.l d2,d2
	add.l d3,d3
	swap d2
	swap d3

;~~~ in d2 we rotated X and in d3 it is Y     ~~~
;~~~ that's right :-)                         ~~~
	

;back original position
.BACK:
	add.w d7,d2 ;xr+dx
	add.w a0,d3 ;yr+dy
	add.w a3,d4 ;zr+dz


	move.w d2,(a4)+ ;x
	move.w d3,(a4)+ ;y
	move.w d4,(a4)+ ;z
	addq.w #2,a4 ;eight byte per every point

	tst.w d4
	bmi.s .CLR_RRR ;radical, if z is less than zero, so, X is negative, dont paint & trigon
	beq.s .CLR_RRR
	
;compute a 2d points
	sub.w #2047,d4
	neg.w d4
	asl.w #4,d4 ;really crazy 3d (11 bit precison for Z)
	muls d4,d2
	muls d4,d3
	swap d2	;dividing for perspective
	swap d3
	add.w #160,d2 ;add, make a perspective middle axis system
	add.w #100,d3	
	add.w D2X,d2
	add.w D2Y,d3
	move.w d2,(a1)+ ;x screen
	move.w d3,(a1)+ ;y screen

	swap d7 ;back loop counting
	dbf d7,.NEXT_ROT ;next point of 3D system
	rts

.CLR_RRR:	move.w #-1,(a1)+ ;x screen
	move.w d3,(a1)+ ;y screen

	swap d7 ;back loop counting
	dbf d7,.NEXT_ROT ;next point of 3D system
	rts


;************************************************
;* Table for cos, numbers are as signed         *
;* int and for angles 0-359                     *
;************************************************
COS_TABLE: incbin "COSFFFF.dat"
;sin(a)*32767 0-359 words
;************************************************
;* Table for sinus, numbers are as signed       *
;* int and for angles 0-359                     *
;************************************************
SIN_TABLE:incbin "SINFFFF.DAT"
;0 - 359 words
;1/sin(a)*32767


	

;kopirovani 1 plane obrazovky z naseho PLANEBUF
COPYPLANE:	
	move.w #37,-(a7)		;waiting VBL
	trap #14
	addq.l #2,a7
	move.l Triscr(a6),a0
	lea PLANEBUF,a1
	move.w #99,d0 ;kopirovat 100 dvouradku


.CLR:
temp	set 0
	rept 40
	move.w (a1)+,temp(a0)
temp	set temp+8	
	endr 
	lea 320(a0),a0
	dbf d0,.CLR	
	rts

;kopirovani z obrazovky do plane BUF
COPYTOPLANE:	
	move.w #37,-(a7)		;waiting VBL
	trap #14
	addq.l #2,a7
	move.l SCREEN(a6),a0
	lea PLANEBUF,a1
	move.w #99,d0 ;kopirovat 100 dvouradku


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~    PAINTING 3D OBJECTS TO 2D SCREEN          ~
;~ START: IN 95         LAST UPDATE: 18.02.96   ~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ztobj equ 550
D3_TO_D2OBJ:	
; a3 field with numbers of trigons (order)

	lea VARIABLE,a6 ;variable field
.AGA_TRI:	
	move.l VERTICES,a5 ;field with faces
	lea D2_FIELD,a2 ;rotated field
	addq.l #2,a5 ;jump to first vertice

.LOOK_FOR_Z:	
	clr.l d0	;zero, we must add to ROTFIELD as long
	move.w -(a3),d0 ;number of face into a3 in against order
	move.l d0,d1
	lsl.w #3,d0 ;8x byte (o bytes per one face)
	add.l d0,a5	;in rotfield is right trigon
	
	
.PAINT:	move.w (a5)+,d6 ;first vertice
	lsl.w #2,d6
	move.l a3,-(a7) ;backup this registers
	move.w (a2,d6.w),Polyx1(a6)
	move.w 2(a2,d6.w),Polyy1(a6)

	move.w (a5)+,d6 ;second vertice
	lsl.w #2,d6
	move.w (a2,d6.w),Polyx2(a6)
	move.w 2(a2,d6.w),Polyy2(a6)

	move.w (a5)+,d6 ;third vertice
	lsl.w #2,d6
	move.w (a2,d6.w),Polyx3(a6)
	move.w 2(a2,d6.w),Polyy3(a6)
	move.l a2,-(a7)

	move.w (a5)+,Color(a6) ;color of face
	bsr TRIGON ;kresli trojuhelnik
	move.l (a7)+,a2
	move.l (a7)+,a3
	subq.w #1,Z_TRIGONS
	bpl .AGA_TRI
.END:	
	rts	;back to main loop

OVER:	move.l d0,-(a7)
	move.l 8(a7),d0
	swap d0
	cmp.w #$ffff,d0
	bne.s .TEST2
	move.l (a7)+,d0
	rts
.TEST2:	tst.w d0
	bne.s .ILL
	move.l (a7)+,d0
	rts
.ILL:	illegal
	

	section text

HPL_LOAD:
;makro pro nahrati a rozpakovani
LOAD	macro \1,\2
	lea	\1,a0	;NAZEV SOUBORU KTERY MAM NAHRAVAT- POINTER DO A0
	lea	\2,A4	;KAM MAM ROZPAKOVAT - POINTER
;ALOKUJI PAMETI
	BSR	OPEN_F		
	MOVE.L	A4,A1	;ULOZENI POINTERU
	MOVE.L	#$FFFFFF,D1	;NAHRAT CELY SOUBOR
	BSR	LOAD_F
	BSR	CLOSEF
	MOVE.L	A4,A0	;UKAZATEL NA A0
	BSR	ice_decrunch_2
	endm

	
;********************************************* Unpacking routine of PACK-ICE
; a0 = Adress of packed data
; "bsr" or "jsr" to ice_decrunch_2 with register a0 prepared.
ice_decrunch_2:
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4
	move.l	a4,a6
	bsr	.getinfo
	cmpi.l	#'AXEP',d0
	bne	.not_packed
	bsr.s	.getinfo
	lea.l	-8(a0,d0.l),a5
	bsr.s	.getinfo
	move.l	d0,(sp)
	adda.l	d0,a6
	move.l	a6,a1

	moveq	#119,d0
.save:	move.b	-(a1),-(a3)
	dbf	d0,.save
	move.l	a6,a3
	move.b	-(a5),d7
	bsr.s	.normal_bytes
	move.l	a3,a5


	bsr	.get_1_bit
	bcc.s	.no_picture
	move.w	#$0f9f,d7
	bsr	.get_1_bit
	bcc.s	.ice_00
	moveq	#15,d0
	bsr	.get_d0_bits
	move.w	d1,d7
.ice_00:	moveq	#3,d6
.ice_01:	move.w	-(a3),d4
	moveq	#3,d5
.ice_02:	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.ice_02
	dbra	d6,.ice_01
	movem.w	d0-d3,(a3)
	dbra	d7,.ice_00
.no_picture
	movem.l	(sp),d0-a3

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0
.rest	move.b	-(a3),-(a5)
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	rts

.getinfo: moveq	#3,d1
.getbytes: lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts

.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end
	moveq.l	#0,d1
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1
	dbne	d3,.nextgb
.no_more: add.l	20(a1),d1
.copy_direkt:	
	move.b	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end:	
	cmpa.l	a4,a6
	bgt.s	.strings
	rts	

.get_1_bit:
	add.b	d7,d7
	bne.s	.bitfound
	move.b	-(a5),d7
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1
.hole_bit_loop:	
	add.b	d7,d7
	bne.s	.on_d0
	move.b	-(a5),d7
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1
	dbf	d0,.hole_bit_loop
	rts	


.strings: lea.l	.length_tab(pc),a1
	moveq.l	#3,d2
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit:	
	moveq.l	#0,d4
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.no_ber
.get_ber:
	bsr.s	.get_d0_bits
.no_ber:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.get_offset_2


	lea.l	.more_offset(pc),a1
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.get_d0_bits
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	.depack_bytes
	sub.w	d4,d1
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1
	moveq.l	#5,d0
	moveq.l	#-1,d2
	bsr.s	.get_1_bit
	bcc.s	.less_40
	moveq.l	#8,d0
	moveq.l	#$3f,d2
.less_40: bsr.s	.get_d0_bits
	add.w	d2,d1

.depack_bytes:
	lea.l	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.dep_b:	move.b	-(a1),-(a6)
	dbf	d4,.dep_b
	bra	.normal_bytes


.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1

.length_tab:
	dc.b 9,1,0,-1,-1
	dc.b 8,4,2,1,0

.more_offset:
	dc.b	  11,   4,   7,  0	; Bits lesen
	dc.w	$11f,  -1, $1f	; Standard Offset

ende_ice_decrunch_2:
;************************************************** end of unpacking routine




OPEN_F	MOVE.W	#0,-(A7)		;TATO FUNKCE SLOUZI K NACTENI FILE
	PEA	(A0)			;NYNI OTEVIRAM FILE
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	ADDQ.L	#8,A7
	LEA	HANDLE(PC),A5	;NEEXISTUJE PRIKAZ MOVE.W D0,HANDLE(PC)
	MOVE.W	D0,(A5)
	RTS

HANDLE:	DS.W	1			;HANDLE DAVAM SEM, ABY TO MOHLO VOLNO MOHLO VOLNE ADRESOVATELNY	
CLOSEF	MOVE.W	HANDLE(PC),-(A7)		;NYNI ZAVIRAM FILE
	MOVE.W	#$3E,-(A7)
	TRAP	#1
	ADDQ.L	#4,A7
	RTS

LOAD_F	MOVE.L	A1,-(A7)	;V A1 BUDE ADRESA UKLADANEHO BUFFERU
	MOVE.L	D1,-(A7)	;V D1 BUDE POCET BYTE
	MOVE.W	HANDLE(PC),-(A7)
	MOVE.W	#$3F,-(A7)	;FUNKCE WRITE DATA TO FILE
	TRAP	#1
	ADD.L	#12,A7		;UKONCIT A NAVRATIT STACK
	RTS
	

	section data
;tady je pole hvezd, ktere maji souradnice x,y,z zapisovane presne takhle v rade, toto pole se naplnuje jizotom rotuje do zblbnuti :-)
;PROSTOR A JEHO PUVODNI BODY
VERTICES:	ds.l	1 ;pointer to vertices

JERRY_COL:	
	dc.w 0,$777,$666,$555,$444,$333,$222,$111
	dc.w 0,$777,$666,$555,$444,$333,$222,$111

	ifd INF4BA ;only if we test the speed of whole algorhytm
TIME4BA:	dc.l 0
	endc
	
 	section bss
STARFIELD:	ds.w MAXPOINTS*4

;SPACE AND HIS ROTATED POINTS 3D
ROTFIELD:   ds.w MAXPOINTS*4
;D2_FIELD, POINTS FOR SCREEN WILL BE TAKE FROM THIS PLACE
D2_FIELD:	ds.w MAXPOINTS*2


;~~~~~~~~~~ ONLY NUMBER OF TRIGONS HERE ~~~~~~~~~
Z_BUFFER: ds.w MAXPOINTS*2 ;Z buffering

;~~~~~~~~~~~ FIELDS FOR SORTING Z AXIS ~~~~~~~~~~
;Z axis will run at 0 and maximum is 2000 
MINIMUM_SORT: ds.w MAXPOINTS*2*16 ;field of Z from MINIMUM to MAXIMUM
TEMPLAT_SORT: ds.w MAXPOINTS*2*16 ;field of TEMPLATE SORT

;every sixteen words are for lenght of sorting area per every number

	SECTION BSS
;plane buffer
PLANEBUF:	ds.b 8000
