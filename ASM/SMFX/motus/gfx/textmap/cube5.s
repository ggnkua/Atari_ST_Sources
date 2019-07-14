; PARSE PARAMETERS: `php parseObject.php test_20.blend.json.txt 0` and size: 25
; OBJ NAME: Cube
number_of_faces_Cube		dc.w		12
number_of_vertices_Cube		dc.w		8
; source vertices data:
;	format (dc.w): visible,x,y,z
currentVertices_Cube
	dc.w	0,70*2,70*2,-70*2		;	0
	dc.w	0,70*2,-70*2,-70*2		;	8
	dc.w	0,-70*2,-70*2,-70*2		;	16
	dc.w	0,-70*2,70*2,-70*2		;	24
	dc.w	0,70*2,70*2,70*2		;	32
	dc.w	0,70*2,-70*2,70*2		;	40
	dc.w	0,-70*2,-70*2,70*2		;	48
	dc.w	0,-70*2,70*2,70*2		;	56
currentVertices_Cube_end


; source normals for vertices data:
;	format (dc.w): x,y,z
currentNormals_Cube
	dc.w	18918,18918,-18918
	dc.w	18918,-18918,-18918
	dc.w	-18918,-18918,-18918
	dc.w	-18918,18918,-18918
	dc.w	18918,18918,18918
	dc.w	18918,-18918,18918
	dc.w	-18918,-18918,18918
	dc.w	-18918,18918,18918
currentNormals_Cube_end
; points definitions, basically Projected Vertices and their UV
;	format: (dc.w): x_projected,y_projected,u,v
points_Cube
point_Cube0		dc.w	0,0,0,8<<7,8<<7
point_Cube1		dc.w	0,0,0,8<<7,8<<7
point_Cube2		dc.w	0,0,0,8<<7,8<<7
point_Cube3		dc.w	0,0,0,8<<7,108<<7
point_Cube4		dc.w	0,0,0,108<<7,108<<7
point_Cube5		dc.w	0,0,0,108<<7,108<<7
point_Cube6		dc.w	0,0,0,108<<7,108<<7
point_Cube7		dc.w	0,0,0,8<<7,108<<7
points_Cube_end
; source faces structure
;	format:
;	- vertex of face, for culling (dc.w): x,y,z
;	- normal value of face, for culling (dc.w): x,y,z
;	- pointers source vertices for visibility marking: (dc.l): ptr1,ptr2,ptr3
sourceFaces_Cube
	dc.w	4*4,-22*4,24*4									
	dc.w	0,0,-32767
	dc.l	currentVertices_Cube+8	;	-> point1
	dc.l	currentVertices_Cube+24	;	-> point3
	dc.l	currentVertices_Cube+0	;	-> point0

	dc.w	1*4,11*4,24*4
	dc.w	0,0,32767
	dc.l	currentVertices_Cube+56	;	-> point7
	dc.l	currentVertices_Cube+40	;	-> point5
	dc.l	currentVertices_Cube+32	;	-> point4

	dc.w	13*4,8*4,24*4
	dc.w	32767,0,-0
	dc.l	currentVertices_Cube+32	;	-> point4
	dc.l	currentVertices_Cube+8	;	-> point1
	dc.l	currentVertices_Cube+0	;	-> point0

	dc.w	5*4,3*4,24*4
	dc.w	-0,-32767,-0
	dc.l	currentVertices_Cube+40	;	-> point5
	dc.l	currentVertices_Cube+16	;	-> point2
	dc.l	currentVertices_Cube+8	;	-> point1

	dc.w	-7*4,-14*4,24*4
	dc.w	-32767,0,-0
	dc.l	currentVertices_Cube+16	;	-> point2
	dc.l	currentVertices_Cube+56	;	-> point7
	dc.l	currentVertices_Cube+24	;	-> point3

	dc.w	12*4,-13*4,24*4
	dc.w	0,32767,0
	dc.l	currentVertices_Cube+0	;	-> point0
	dc.l	currentVertices_Cube+56	;	-> point7
	dc.l	currentVertices_Cube+32	;	-> point4

	dc.w	4*4,-22*4,24*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Cube+8	;	-> point1
	dc.l	currentVertices_Cube+16	;	-> point2
	dc.l	currentVertices_Cube+24	;	-> point3

	dc.w	1*4,11*4,24*4
	dc.w	0,0,32767
	dc.l	currentVertices_Cube+56	;	-> point7
	dc.l	currentVertices_Cube+48	;	-> point6
	dc.l	currentVertices_Cube+40	;	-> point5

	dc.w	13*4,8*4,24*4
	dc.w	32767,-0,0
	dc.l	currentVertices_Cube+32	;	-> point4
	dc.l	currentVertices_Cube+40	;	-> point5
	dc.l	currentVertices_Cube+8	;	-> point1

	dc.w	5*4,3*4,24*4
	dc.w	-0,-32767,0
	dc.l	currentVertices_Cube+40	;	-> point5
	dc.l	currentVertices_Cube+48	;	-> point6
	dc.l	currentVertices_Cube+16	;	-> point2

	dc.w	-7*4,-14*4,24*4
	dc.w	-32767,0,-0
	dc.l	currentVertices_Cube+16	;	-> point2
	dc.l	currentVertices_Cube+48	;	-> point6
	dc.l	currentVertices_Cube+56	;	-> point7

	dc.w	12*4,-13*4,24*4
	dc.w	0,32767,0
	dc.l	currentVertices_Cube+0	;	-> point0
	dc.l	currentVertices_Cube+24	;	-> point3
	dc.l	currentVertices_Cube+56	;	-> point7

sourceFaces_Cube_end
; destination faces
;	format:
;	- visibility (dc.w)
;	- pointers to destination points: (dc.l) * 3

;0	+,+,-
;1	+,-,-
;2	-,-,-
;3	-,+,-
;4	+,+,+
;5	+,-,+
;6	-,-,+
;7	-,+,+

destFaces_Cube
	dc.w	0													;0
	dc.l	point_Cube1		;	+,-,-			--> done		;2	
	dc.l	point_Cube3		;	-,+,-							;6
	dc.l	point_Cube0		;	+,+,-							;10
	IFEQ SEP_UV
	dc.w	104<<7,52<<7,55<<7,3<<7,104<<7,3<<7					;14,16,18,20,22,24			; 26 total
	ENDC

	dc.w	0
	dc.l	point_Cube7		; -,+,+				--> f
	dc.l	point_Cube5		; +,-,+
	dc.l	point_Cube4		; +,+,+
	IFEQ SEP_UV
	dc.w	55<<7,156<<7,104<<7,107<<7,104<<7,156<<7			; this needs to be changed		26+14		
	ENDC

	dc.w	0
	dc.l	point_Cube4		; +,+,+				--> g			;2*26+14
	dc.l	point_Cube1		; +,-,-	
	dc.l	point_Cube0		; +,+,-
	IFEQ SEP_UV
	dc.w	156<<7,104<<7,107<<7,55<<7,156<<7,55<<7
	ENDC

	dc.w	0
	dc.l	point_Cube5		; +,-,+				--> c
	dc.l	point_Cube2		; -,-,-
	dc.l	point_Cube1		; +,-,-
	IFEQ SEP_UV
	dc.w	104<<7,104<<7,55<<7,55<<7,104<<7,55<<7
	ENDC

	dc.w	0
	dc.l	point_Cube2		; -,-,-				--> i			;4*26+14
	dc.l	point_Cube7		; -,+,+
	dc.l	point_Cube3		; -,+,-
	IFEQ SEP_UV
	dc.w	52<<7,55<<7,3<<7,104<<7,3<<7,55<<7
	ENDC

	dc.w	0
	dc.l	point_Cube0		; +,+,-				--> l
	dc.l	point_Cube7		; -,+,+
	dc.l	point_Cube4		; +,+,+
	IFEQ SEP_UV
	dc.w	159<<7,55<<7,208<<7,104<<7,159<<7,104<<7
	ENDC

	dc.w	0
	dc.l	point_Cube1		; +,-,-				--> b
	dc.l	point_Cube2		; -,-,-
	dc.l	point_Cube3		; -,+,-
	IFEQ SEP_UV
	dc.w	104<<7,52<<7,55<<7,52<<7,55<<7,3<<7
	ENDC

	dc.w	0
	dc.l	point_Cube7		; -,+,+				--> e					; this needs to be changed	7*26+14
	dc.l	point_Cube6		; -,-,+
	dc.l	point_Cube5		; +,-,+	
	IFEQ SEP_UV
	dc.w	55<<7,156<<7,55<<7,107<<7,104<<7,107<<7
	ENDC

	dc.w	0
	dc.l	point_Cube4		; 					--> h
	dc.l	point_Cube5
	dc.l	point_Cube1
	IFEQ SEP_UV
	dc.w	156<<7,104<<7,107<<7,104<<7,107<<7,55<<7
	ENDC

	dc.w	0
	dc.l	point_Cube5				;			--> d					9*26+14
	dc.l	point_Cube6
	dc.l	point_Cube2
	IFEQ SEP_UV
	dc.w	104<<7,104<<7,55<<7,104<<7,55<<7,55<<7
	ENDC

	dc.w	0
	dc.l	point_Cube2				;			--> j					10*26+14
	dc.l	point_Cube6
	dc.l	point_Cube7
	IFEQ SEP_UV
	dc.w	52<<7,55<<7,52<<7,104<<7,3<<7,104<<7
	ENDC

	dc.w	0
	dc.l	point_Cube0				;			--> k
	dc.l	point_Cube3
	dc.l	point_Cube7
	IFEQ SEP_UV
	dc.w	159<<7,55<<7,208<<7,55<<7,208<<7,104<<7
	ENDC

destFaces_Cube_end



init_Cube
	move.w	number_of_faces_Cube,current_number_of_faces
	move.w	number_of_vertices_Cube,current_number_of_vertices
	lea	currentVertices_Cube,a0
	move.l	a0,a5
	move.l	currentVerticesPointer,a1
	move.l	a1,a4					; save this address for later use, target base
	move.l	#currentVertices_Cube_end,d7
	sub.l	a0,d7						; number of bytes
	lsr.w	#3,d7
	subq.w	#1,d7
.cpv
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	dbra	d7,.cpv


	lea		currentNormals_Cube,a0
	move.l	currentNormalsPointer,a1
	move.l	#currentNormals_Cube_end,d7
	sub.l	a0,d7
	lsr.w	d7
	subq.w	#1,d7
.cpn	
		move.w	(a0)+,(a1)+
	dbra	d7,.cpn


	lea		points_Cube,a0
	move.l	a0,a6					; save this address for later use
	move.l	currentPointsPointer,a1
	move.l	a1,a3					; target base
	move.l	#points_Cube_end,d7
	sub.l	a0,d7
	lsr.w	d7
	subq.w	#1,d7
.cpp
		move.w	(a0)+,(a1)+
	dbra	d7,.cpp


	lea		sourceFaces_Cube,a0				;3*2 + 3*2 + 3*4 = 6 * 4 = 24
	move.l	currentSourceFacesPointer,a1
	move.l	#sourceFaces_Cube_end,d7
	sub.l	a0,d7
	divs	#24,d7
	subq.w	#1,d7
.cpf
		move.l	(a0)+,(a1)+	; vertex x,y
		move.l	(a0)+,(a1)+ ; vertex z, normal x
		move.l	(a0)+,(a1)+ ; normal y, normal z


		REPT 3				; do 3 face points
		move.l	(a0)+,d0	; currentVerticesP
		sub.l	a5,d0		; subtract source base
		add.l	a4,d0		; add target base
		move.l	d0,(a1)+
		ENDR
	dbra	d7,.cpf


	lea		destFaces_Cube,a0
	move.l	currentDestFacesPointer,a1
	move.l	#destFaces_Cube_end,d7
	sub.l	a0,d7
	divs	#26,d7
	subq.w	#1,d7
.cpdf
		move.w	(a0)+,(a1)+
		REPT 3
		move.l	(a0)+,d0			; currentPoint
		sub.l	a6,d0				; subtract source base point
		add.l	a3,d0				; add target base point
		move.l	d0,(a1)+
		ENDR
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	dbra	d7,.cpdf
	rts
