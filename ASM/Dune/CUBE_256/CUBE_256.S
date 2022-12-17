; 256 bytes demo
; Tridi engine
; Thadoss / Dune 2K22

			opt	p=68030/68882,NOCASE,W+,O+		; Optimized compilation
		;	opt	p=68030/68882,NOCASE,D+,X+		; Compilation with symbols
			comment 	HEAD=%111
			output		CUBE_256.PRG



VPLANES         	equ             0
VWRAP           	equ             2
CONTRL          	equ             4
INTIN           	equ             8
PTSIN           	equ             12
INTOUT          	equ             16
PTSOUT          	equ             20
COLBIT0         	equ             24
COLBIT1         	equ             26
COLBIT2         	equ             28
COLBIT3         	equ             30
LSTLIN          	equ             32
LNMASK          	equ             34
WMODE           	equ             36
X1              	equ             38
Y1              	equ             40
X2              	equ             42
Y2              	equ             44
PATPTR          	equ             46
PATMSK          	equ             50
MFILL           	equ             52
CLIP            	equ             54


LINEA_INIT      	equ             $A000
POLYFILL        	equ             LINEA_INIT+6



; --------------------------------------------------------------
			section	text
; --------------------------------------------------------------


			; Set cube vertexes : d7 ends with value $ffffffff
			; ------------------------------------------------
			move.l		#%11111111110100101111010000001011,d7			; = $ffd2f40b

			; Compute sin table (amp=16384, len=1024)
			; When starting the program, d0 = 0
			; https://eab.abime.net/showthread.php?t=106304&page=4

			move.w		#511+2,a0
loop_compute_sin_cos:
			; Compute cube vertexes
			moveq		#30,d6
			asr.l		d7
			bcs.s		.no_neg
			neg.w		d6
.no_neg:		move.w		d6,(1024+512)*2(a4)					; vertexes_3D

			; Compute sin table
			subq.l		#2,a0
			move.l		d0,d1
			asr.l		#2,d1
			move.w		d1,2048(a4)						; recopy sin value at the end of the cos table
			move.w		d1,(a4)+
			neg.w		d1
			move.w		d1,1024-2(a4)
			add.l		a0,d0
			bne.s		loop_compute_sin_cos


			; Init LineA polygone
			dc.w		LINEA_INIT						; Init the Line-A.
			move.l		a0,a2

			; Set 4 vertices per face
			move.l		CONTRL(a0),a6
			addq.l		#4,(a6)							; it was move.l	before

			; Set the motif #$ffff to line_A
			lea.l		$4ee.w,a6						; $ffff,$0
			move.l		a6,PATPTR(a0)


mainloop:
			; Swap the physical and the logical screen
			; ----------------------------------------
			movea.l		a5,a6							; Phy

			move.l		(a6)+,a4						; get_phy
			move.l		(a6),(a5)						; save new phy screen
			move.l		a4,(a6)+						; save new log screen

			; Vsync
			move.w		#37,-(sp)
			trap		#14
		;	addq.l		#2,sp

			; Setscr
			move.l		d7,-(sp)						; -1
			move.l		(a5),-(sp)
			move.l		a4,-(sp)
			move.w		#5,-(sp)
			trap		#14
		;	lea.l		$e(sp),sp


			; Clr screen
			; ----------
			lsr.w		#3,d7							; d7 = 8191 instead of 8000
.loop_clr_scr:		;clr.l		(a4)+							; background white
			move.l		d7,(a4)+						; d7 = background motif
			dbf		d7,.loop_clr_scr					; d7 = -1


			; The tridi engine
			; ----------------

			; Rotate angles by 1 (alpha++ ; beta = alpha ; gamma = 0)
			addq.b		#1,d5

			lea.l		vertexes_2D(pc),a3
			lea.l		vertexes_3D(pc),a4
			moveq		#8-1,d0

.loop_rotate_vertexes:
			bsr.s		rotate_axe_x

			; project the vertex
			add.w		d2,d6							; add z_pos
			divs.w		d6,d1							; x 2D
			divs.w		d6,d4							; y 2D

			add.w		d2,d1
			add.w		d2,d4
			move.w		d1,(a3)+						; save X proj
			move.w		d4,(a3)+						; save Y proj
			dbf		d0,.loop_rotate_vertexes


			; Display faces
			; -------------
		;	lea.l		vertexes_linea(pc),a3
		;	lea.l		vertexes_2D(pc),a4
		;	lea.l		faces_object(pc),a6
			move.l		a3,PTSIN(a2)

.loop_manage_faces:
			; Current vertexes_linea ptr
			move.l		a3,a0

			; Get and save face vertexes [x;y]
			; And set polygon color (careful: it overwrites unused Linea LSTLIN parameter or PTSOUT if I use -2)
			move.w		(a6)+,d0						; Face mask definition
			beq.s		mainloop						; 0 ==> end of the mask definition (no more faces to display)

			lea.l		COLBIT0-2(a2),a1
.loop_copy_face_vtx:
			moveq		#7,d1
			and.w		d0,d1
			move.l		(a4,d1.l*4),(a0)+					; [x,y]
			move.w		d1,(a1)+						; color bit
			lsr.w		#3,d0
			bne.s		.loop_copy_face_vtx					; the loop ends when the face mask = 0

			subq.w		#3,-(a1)						; 5 different colors for the cube faces

			; Compute the normal (face visibility)
			movem.w		(a3),d0-d4/d6						; [xa;ya] , [xb;yb] , [xc;yc]
			sub.w		d2,d0							; XA-XB
			sub.w		d2,d4							; XC-XB
			sub.w		d3,d6							; YC-YB
			sub.w		d1,d3							; YB-YA
			muls.w		d4,d3							; (XC-XB)*(YB-YA)
			muls.w		d0,d6							; (XA-XB)*(YC-YB)
			add.l		d3,d6
			bge.s		.loop_manage_faces

			; Loop to draw the polygon
			move.w		#199,Y1(a2)						; y_max

.loop_display_poly:	; Draw polygon (line A)
			dc.w		POLYFILL						; Draw H-LINE for Y1
			subq.w		#1,Y1(a2)						; Previous Y1 line
			bge.s		.loop_display_poly

			bra.s		.loop_manage_faces



			; Rotate around x-axis (Alpha)
			; y'  = y*cos(A) - z*sin(A)
			; z'  = y*sin(A) + z*cos(A)
			;
			; Input :
			;	d5.l : angle


rotate_axe_x:		lea.l		(sin_cos_tab,pc,d5.l*8),a0				; Sin angle
			lea.l		256(a0),a1						; cos alpha ; 256 only makes a free Z zoomer
			movem.w		(a4)+,d1/d4/d6						; x, y, z
			bsr.s		rotate_axe_y						; d4 = y ; d6 = z
			exg.l		d1,d4							; d4 = save y' ; d4 = x

rotate_axe_y:		move.w		d4,d2
			muls.w		(a1),d4							; y*cos(A)
			move.w		d6,d3
			muls.w		(a0),d3							; z*sin(A)
			sub.l		d3,d4
			asr.l		#6,d4

			muls.w		(a0),d2							; y*sin(A)
			muls.w		(a1),d6							; z*cos(A)
			add.l		d2,d6
			asl.l		#2,d6
			swap		d6							; z'

			moveq		#127,d2
			rts



; --------------------------------------------------------------
			section	data
; --------------------------------------------------------------
phy:			dc.l	$40000
log:			dc.l	$50000
faces_object:		dc.w	3<<12+2<<9+1<<6+0<<3+3
			dc.w	3<<12+0<<9+4<<6+7<<3+3
			dc.w	3<<12+7<<9+6<<6+2<<3+3
			dc.w	6<<12+5<<9+1<<6+2<<3+6
			dc.w	5<<12+4<<9+0<<6+1<<3+5
		;	dc.w	5<<12+6<<9+7<<6+4<<3+5						; Never visible


;vertexes_3D:		dc.b	100,100,-100
;			dc.b	100,-100,-100
;			dc.b	-100,-100,-100
;			dc.b	-100,100,-100
;			dc.b	100,100,100
;			dc.b	100,-100,100
;			dc.b	-100,-100,100
;			dc.b	-100,100,100
;			even

; --------------------------------------------------------------
			section	bss
; --------------------------------------------------------------
sin_cos_tab:		ds.w	1024
cos_tab_end:		ds.w	512

vertexes_3D:		ds.w	24
vertexes_2D:		ds.w	16								; Projected vertexes
vertexes_linea:		ds.w	20

