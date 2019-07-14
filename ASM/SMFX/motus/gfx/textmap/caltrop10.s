; PARSE PARAMETERS: `php parseObject.php caltrop_005_50pct.blend.json.txt 0` and size: 15
; OBJ NAME: Caltrop2
number_of_faces_Caltrop2		dc.w		24
number_of_vertices_Caltrop2		dc.w		17
; source vertices data:
;	format (dc.w): visible,x,y,z
currentVertices_Caltrop2
	dc.w	0,-0*4,-0*4,-0*4		;	0
	dc.w	0,-21*4,-30*4,-9*4		;	8
	dc.w	0,0*4,-60*4,0*4		;	16
	dc.w	0,0*4,-30*4,22*4		;	24
	dc.w	0,20*4,-32*4,-13*4		;	32
	dc.w	0,-21*4,-1*4,31*4		;	40
	dc.w	0,0*4,16*4,58*4		;	48
	dc.w	0,-0*4,29*4,23*4		;	56
	dc.w	0,20*4,-4*4,34*4		;	64
	dc.w	0,-30*4,-15*4,-16*4		;	72
	dc.w	0,-53*4,14*4,-24*4		;	80
	dc.w	0,-16*4,17*4,-28*4		;	88
	dc.w	0,-34*4,19*4,7*4		;	96
	dc.w	0,14*4,-4*4,-35*4		;	104
	dc.w	0,41*4,23*4,-38*4		;	112
	dc.w	0,36*4,4*4,-6*4		;	120
	dc.w	0,12*4,34*4,-17*4		;	128
currentVertices_Caltrop2_end
; source normals for vertices data:
;	format (dc.w): x,y,z
currentNormals_Caltrop2
	dc.w	-24858,-12502,17304
	dc.w	26931,11119,14991
	dc.w	-3428,-11425,-30519
	dc.w	26145,-11512,16051
	dc.w	-24803,12700,17240
	dc.w	-2239,10754,-30871
	dc.w	-24858,19950,7598
	dc.w	26938,11614,-14598
	dc.w	-3428,-26522,18935
	dc.w	26145,18483,6965
	dc.w	-24798,13359,-16740
	dc.w	-2239,-32603,-2395
	dc.w	-2955,-10485,-30903
	dc.w	16729,27317,6900
	dc.w	-24286,-14158,16835
	dc.w	-2817,32472,-3362
	dc.w	19331,-16421,-20744
	dc.w	-4813,-18540,26586
	dc.w	21272,-22579,-10553
	dc.w	3420,13713,29562
	dc.w	-14678,11960,-26743
	dc.w	19523,21242,15534
	dc.w	4128,-32068,5316
	dc.w	-29976,4690,-12375
currentNormals_Caltrop2_end
; points definitions, basically Projected Vertices and their UV
;	format: (dc.w): x_projected,y_projected,u,v
points_Caltrop2
point_Caltrop20		dc.w	0,0,0,36<<7,190<<7
point_Caltrop21		dc.w	0,0,0,119<<7,186<<7
point_Caltrop22		dc.w	0,0,0,35<<7,159<<7
point_Caltrop23		dc.w	0,0,0,68<<7,157<<7
point_Caltrop24		dc.w	0,0,0,103<<7,153<<7
point_Caltrop25		dc.w	0,0,0,102<<7,224<<7
point_Caltrop26		dc.w	0,0,0,34<<7,224<<7
point_Caltrop27		dc.w	0,0,0,115<<7,254<<7
point_Caltrop28		dc.w	0,0,0,66<<7,220<<7
point_Caltrop29		dc.w	0,0,0,4<<7,115<<7
point_Caltrop210		dc.w	0,0,0,86<<7,147<<7
point_Caltrop211		dc.w	0,0,0,54<<7,146<<7
point_Caltrop212		dc.w	0,0,0,19<<7,148<<7
point_Caltrop213		dc.w	0,0,0,3<<7,186<<7
point_Caltrop214		dc.w	0,0,0,85<<7,218<<7
point_Caltrop215		dc.w	0,0,0,53<<7,217<<7
point_Caltrop216		dc.w	0,0,0,18<<7,220<<7
points_Caltrop2_end
; source faces structure
;	format:
;	- vertex of face, for culling (dc.w): x,y,z
;	- normal value of face, for culling (dc.w): x,y,z
;	- pointers source vertices for visibility marking: (dc.l): ptr1,ptr2,ptr3
sourceFaces_Caltrop2
	dc.w	-21*4,-30*4,-9*4
	dc.w	-24858,-12502,17304
	dc.l	currentVertices_Caltrop2+8	;	-> point1
	dc.l	currentVertices_Caltrop2+16	;	-> point2
	dc.l	currentVertices_Caltrop2+24	;	-> point3

	dc.w	20*4,-32*4,-13*4
	dc.w	26931,11119,14991
	dc.l	currentVertices_Caltrop2+32	;	-> point4
	dc.l	currentVertices_Caltrop2+0	;	-> point0
	dc.l	currentVertices_Caltrop2+24	;	-> point3

	dc.w	20*4,-32*4,-13*4
	dc.w	-3428,-11425,-30519
	dc.l	currentVertices_Caltrop2+32	;	-> point4
	dc.l	currentVertices_Caltrop2+16	;	-> point2
	dc.l	currentVertices_Caltrop2+8	;	-> point1

	dc.w	0*4,-30*4,22*4
	dc.w	26145,-11512,16051
	dc.l	currentVertices_Caltrop2+24	;	-> point3
	dc.l	currentVertices_Caltrop2+16	;	-> point2
	dc.l	currentVertices_Caltrop2+32	;	-> point4

	dc.w	0*4,-30*4,22*4
	dc.w	-24803,12700,17240
	dc.l	currentVertices_Caltrop2+24	;	-> point3
	dc.l	currentVertices_Caltrop2+0	;	-> point0
	dc.l	currentVertices_Caltrop2+8	;	-> point1

	dc.w	-21*4,-30*4,-9*4
	dc.w	-2239,10754,-30871
	dc.l	currentVertices_Caltrop2+8	;	-> point1
	dc.l	currentVertices_Caltrop2+0	;	-> point0
	dc.l	currentVertices_Caltrop2+32	;	-> point4

	dc.w	-21*4,-1*4,31*4
	dc.w	-24858,19950,7598
	dc.l	currentVertices_Caltrop2+40	;	-> point5
	dc.l	currentVertices_Caltrop2+48	;	-> point6
	dc.l	currentVertices_Caltrop2+56	;	-> point7

	dc.w	20*4,-4*4,34*4
	dc.w	26938,11614,-14598
	dc.l	currentVertices_Caltrop2+64	;	-> point8
	dc.l	currentVertices_Caltrop2+0	;	-> point0
	dc.l	currentVertices_Caltrop2+56	;	-> point7

	dc.w	20*4,-4*4,34*4
	dc.w	-3428,-26522,18935
	dc.l	currentVertices_Caltrop2+64	;	-> point8
	dc.l	currentVertices_Caltrop2+48	;	-> point6
	dc.l	currentVertices_Caltrop2+40	;	-> point5

	dc.w	-0*4,29*4,23*4
	dc.w	26145,18483,6965
	dc.l	currentVertices_Caltrop2+56	;	-> point7
	dc.l	currentVertices_Caltrop2+48	;	-> point6
	dc.l	currentVertices_Caltrop2+64	;	-> point8

	dc.w	-0*4,29*4,23*4
	dc.w	-24798,13359,-16740
	dc.l	currentVertices_Caltrop2+56	;	-> point7
	dc.l	currentVertices_Caltrop2+0	;	-> point0
	dc.l	currentVertices_Caltrop2+40	;	-> point5

	dc.w	-21*4,-1*4,31*4
	dc.w	-2239,-32603,-2395
	dc.l	currentVertices_Caltrop2+40	;	-> point5
	dc.l	currentVertices_Caltrop2+0	;	-> point0
	dc.l	currentVertices_Caltrop2+64	;	-> point8

	dc.w	-30*4,-15*4,-16*4
	dc.w	-2955,-10485,-30903
	dc.l	currentVertices_Caltrop2+72	;	-> point9
	dc.l	currentVertices_Caltrop2+80	;	-> point10
	dc.l	currentVertices_Caltrop2+88	;	-> point11

	dc.w	-34*4,19*4,7*4
	dc.w	16729,27317,6900
	dc.l	currentVertices_Caltrop2+96	;	-> point12
	dc.l	currentVertices_Caltrop2+0	;	-> point0
	dc.l	currentVertices_Caltrop2+88	;	-> point11

	dc.w	-34*4,19*4,7*4
	dc.w	-24286,-14158,16835
	dc.l	currentVertices_Caltrop2+96	;	-> point12
	dc.l	currentVertices_Caltrop2+80	;	-> point10
	dc.l	currentVertices_Caltrop2+72	;	-> point9

	dc.w	-16*4,17*4,-28*4
	dc.w	-2817,32472,-3362
	dc.l	currentVertices_Caltrop2+88	;	-> point11
	dc.l	currentVertices_Caltrop2+80	;	-> point10
	dc.l	currentVertices_Caltrop2+96	;	-> point12

	dc.w	-16*4,17*4,-28*4
	dc.w	19331,-16421,-20744
	dc.l	currentVertices_Caltrop2+88	;	-> point11
	dc.l	currentVertices_Caltrop2+0	;	-> point0
	dc.l	currentVertices_Caltrop2+72	;	-> point9

	dc.w	-30*4,-15*4,-16*4
	dc.w	-4813,-18540,26586
	dc.l	currentVertices_Caltrop2+72	;	-> point9
	dc.l	currentVertices_Caltrop2+0	;	-> point0
	dc.l	currentVertices_Caltrop2+96	;	-> point12

	dc.w	14*4,-4*4,-35*4
	dc.w	21272,-22579,-10553
	dc.l	currentVertices_Caltrop2+104	;	-> point13
	dc.l	currentVertices_Caltrop2+112	;	-> point14
	dc.l	currentVertices_Caltrop2+120	;	-> point15

	dc.w	12*4,34*4,-17*4
	dc.w	3420,13713,29562
	dc.l	currentVertices_Caltrop2+128	;	-> point16
	dc.l	currentVertices_Caltrop2+0	;	-> point0
	dc.l	currentVertices_Caltrop2+120	;	-> point15

	dc.w	12*4,34*4,-17*4
	dc.w	-14678,11960,-26743
	dc.l	currentVertices_Caltrop2+128	;	-> point16
	dc.l	currentVertices_Caltrop2+112	;	-> point14
	dc.l	currentVertices_Caltrop2+104	;	-> point13

	dc.w	36*4,4*4,-6*4
	dc.w	19523,21242,15534
	dc.l	currentVertices_Caltrop2+120	;	-> point15
	dc.l	currentVertices_Caltrop2+112	;	-> point14
	dc.l	currentVertices_Caltrop2+128	;	-> point16

	dc.w	36*4,4*4,-6*4
	dc.w	4128,-32068,5316
	dc.l	currentVertices_Caltrop2+120	;	-> point15
	dc.l	currentVertices_Caltrop2+0	;	-> point0
	dc.l	currentVertices_Caltrop2+104	;	-> point13

	dc.w	14*4,-4*4,-35*4
	dc.w	-29976,4690,-12375
	dc.l	currentVertices_Caltrop2+104	;	-> point13
	dc.l	currentVertices_Caltrop2+0	;	-> point0
	dc.l	currentVertices_Caltrop2+128	;	-> point16

sourceFaces_Caltrop2_end
; destination faces
;	format:
;	- visibility (dc.w)
;	- pointers to destination points: (dc.l) * 3
destFaces_Caltrop2
	dc.w	0
	dc.l	point_Caltrop21
	dc.l	point_Caltrop22
	dc.l	point_Caltrop23
	IFEQ SEP_UV
	dc.w	54<<7,69<<7,36<<7,97<<7,69<<7,98<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop24
	dc.l	point_Caltrop20
	dc.l	point_Caltrop23
	IFEQ SEP_UV
	dc.w	103<<7,102<<7,87<<7,72<<7,69<<7,98<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop24
	dc.l	point_Caltrop22
	dc.l	point_Caltrop21
	IFEQ SEP_UV
	dc.w	18<<7,70<<7,36<<7,97<<7,54<<7,69<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop23
	dc.l	point_Caltrop22
	dc.l	point_Caltrop24
	IFEQ SEP_UV
	dc.w	4<<7,102<<7,36<<7,97<<7,18<<7,70<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop23
	dc.l	point_Caltrop20
	dc.l	point_Caltrop21
	IFEQ SEP_UV
	dc.w	69<<7,98<<7,87<<7,72<<7,54<<7,69<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop21
	dc.l	point_Caltrop20
	dc.l	point_Caltrop24
	IFEQ SEP_UV
	dc.w	120<<7,70<<7,87<<7,72<<7,103<<7,102<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop25
	dc.l	point_Caltrop26
	dc.l	point_Caltrop27
	IFEQ SEP_UV
	dc.w	18<<7,2<<7,34<<7,32<<7,51<<7,4<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop28
	dc.l	point_Caltrop20
	dc.l	point_Caltrop27
	IFEQ SEP_UV
	dc.w	66<<7,36<<7,84<<7,5<<7,51<<7,4<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop28
	dc.l	point_Caltrop26
	dc.l	point_Caltrop25
	IFEQ SEP_UV
	dc.w	2<<7,35<<7,34<<7,32<<7,18<<7,2<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop27
	dc.l	point_Caltrop26
	dc.l	point_Caltrop28
	IFEQ SEP_UV
	dc.w	51<<7,4<<7,34<<7,32<<7,66<<7,36<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop27
	dc.l	point_Caltrop20
	dc.l	point_Caltrop25
	IFEQ SEP_UV
	dc.w	116<<7,2<<7,84<<7,5<<7,103<<7,32<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop25
	dc.l	point_Caltrop20
	dc.l	point_Caltrop28
	IFEQ SEP_UV
	dc.w	103<<7,32<<7,84<<7,5<<7,66<<7,36<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop29
	dc.l	point_Caltrop210
	dc.l	point_Caltrop211
	IFEQ SEP_UV
	dc.w	71<<7,138<<7,87<<7,108<<7,54<<7,109<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop212
	dc.l	point_Caltrop20
	dc.l	point_Caltrop211
	IFEQ SEP_UV
	dc.w	19<<7,107<<7,38<<7,137<<7,54<<7,109<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop212
	dc.l	point_Caltrop210
	dc.l	point_Caltrop29
	IFEQ SEP_UV
	dc.w	107<<7,134<<7,87<<7,108<<7,71<<7,138<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop211
	dc.l	point_Caltrop210
	dc.l	point_Caltrop212
	IFEQ SEP_UV
	dc.w	119<<7,101<<7,87<<7,108<<7,107<<7,134<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop211
	dc.l	point_Caltrop20
	dc.l	point_Caltrop29
	IFEQ SEP_UV
	dc.w	54<<7,109<<7,38<<7,137<<7,71<<7,138<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop29
	dc.l	point_Caltrop20
	dc.l	point_Caltrop212
	IFEQ SEP_UV
	dc.w	5<<7,141<<7,38<<7,137<<7,19<<7,107<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop213
	dc.l	point_Caltrop214
	dc.l	point_Caltrop215
	IFEQ SEP_UV
	dc.w	69<<7,67<<7,86<<7,38<<7,53<<7,38<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop216
	dc.l	point_Caltrop20
	dc.l	point_Caltrop215
	IFEQ SEP_UV
	dc.w	18<<7,36<<7,36<<7,66<<7,53<<7,38<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop216
	dc.l	point_Caltrop214
	dc.l	point_Caltrop213
	IFEQ SEP_UV
	dc.w	106<<7,63<<7,86<<7,38<<7,69<<7,67<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop215
	dc.l	point_Caltrop214
	dc.l	point_Caltrop216
	IFEQ SEP_UV
	dc.w	118<<7,30<<7,86<<7,38<<7,106<<7,63<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop215
	dc.l	point_Caltrop20
	dc.l	point_Caltrop213
	IFEQ SEP_UV
	dc.w	53<<7,38<<7,36<<7,66<<7,69<<7,67<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Caltrop213
	dc.l	point_Caltrop20
	dc.l	point_Caltrop216
	IFEQ SEP_UV
	dc.w	3<<7,69<<7,36<<7,66<<7,18<<7,36<<7	;x,y,z: 0,0,0
	ENDC

destFaces_Caltrop2_end



init_Caltrop2
	move.w	number_of_faces_Caltrop2,current_number_of_faces
	move.w	number_of_vertices_Caltrop2,current_number_of_vertices
	lea	currentVertices_Caltrop2,a0
	move.l	a0,a5
	move.l	currentVerticesPointer,a1
	move.l	a1,a4					; save this address for later use, target base
	move.l	#currentVertices_Caltrop2_end,d7
	sub.l	a0,d7						; number of bytes
	lsr.w	#3,d7
	subq.w	#1,d7
.cpv
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	dbra	d7,.cpv


	lea		currentNormals_Caltrop2,a0
	move.l	currentNormalsPointer,a1
	move.l	#currentNormals_Caltrop2_end,d7
	sub.l	a0,d7
	lsr.w	d7
	subq.w	#1,d7
.cpn	
		move.w	(a0)+,(a1)+
	dbra	d7,.cpn


	lea		points_Caltrop2,a0
	move.l	a0,a6					; save this address for later use
	move.l	currentPointsPointer,a1
	move.l	a1,a3					; target base
	move.l	#points_Caltrop2_end,d7
	sub.l	a0,d7
	lsr.w	d7
	subq.w	#1,d7
.cpp
		move.w	(a0)+,(a1)+
	dbra	d7,.cpp


	lea		sourceFaces_Caltrop2,a0				;3*2 + 3*2 + 3*4 = 6 * 4 = 24
	move.l	currentSourceFacesPointer,a1
	move.l	#sourceFaces_Caltrop2_end,d7
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


	lea		destFaces_Caltrop2,a0
	move.l	currentDestFacesPointer,a1
	move.l	#destFaces_Caltrop2_end,d7
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
