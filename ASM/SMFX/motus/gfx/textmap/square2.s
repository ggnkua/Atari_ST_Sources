; PARSE PARAMETERS: `php parseObject.php square.blend.json.txt 0` and size: 30
; OBJ NAME: Square
number_of_faces_Square		dc.w		48
number_of_vertices_Square		dc.w		24
; source vertices data:
;	format (dc.w): visible,x,y,z
currentVertices_Square
	dc.w	0,42*4,0*4,0*4		;	0
	dc.w	0,36*4,0*4,10*4		;	8
	dc.w	0,24*4,0*4,10*4		;	16
	dc.w	0,18*4,0*4,0*4		;	24
	dc.w	0,24*4,0*4,-10*4		;	32
	dc.w	0,36*4,0*4,-10*4		;	40
	dc.w	0,0*4,42*4,0*4		;	48
	dc.w	0,0*4,36*4,10*4		;	56
	dc.w	0,0*4,24*4,10*4		;	64
	dc.w	0,0*4,18*4,0*4		;	72
	dc.w	0,0*4,24*4,-10*4		;	80
	dc.w	0,0*4,36*4,-10*4		;	88
	dc.w	0,-42*4,0*4,0*4		;	96
	dc.w	0,-36*4,0*4,10*4		;	104
	dc.w	0,-24*4,0*4,10*4		;	112
	dc.w	0,-18*4,0*4,0*4		;	120
	dc.w	0,-24*4,0*4,-10*4		;	128
	dc.w	0,-36*4,0*4,-10*4		;	136
	dc.w	0,0*4,-42*4,0*4		;	144
	dc.w	0,0*4,-36*4,10*4		;	152
	dc.w	0,0*4,-24*4,10*4		;	160
	dc.w	0,0*4,-18*4,0*4		;	168
	dc.w	0,0*4,-24*4,-10*4		;	176
	dc.w	0,0*4,-36*4,-10*4		;	184
currentVertices_Square_end
; source normals for vertices data:
;	format (dc.w): x,y,z
currentNormals_Square
	dc.w	21451,21451,12385
	dc.w	0,0,32767
	dc.w	-21451,-21451,12385
	dc.w	-21451,-21451,-12385
	dc.w	0,0,-32767
	dc.w	21451,21451,-12385
	dc.w	-21451,21451,12385
	dc.w	0,0,32767
	dc.w	21451,-21451,12385
	dc.w	21451,-21451,-12385
	dc.w	0,0,-32767
	dc.w	-21451,21451,-12385
	dc.w	-21451,-21451,12385
	dc.w	0,0,32767
	dc.w	21451,21451,12385
	dc.w	21451,21451,-12385
	dc.w	0,0,-32767
	dc.w	-21451,-21451,-12385
	dc.w	21451,-21451,12385
	dc.w	0,0,32767
	dc.w	-21451,21451,12385
	dc.w	-21451,21451,-12385
	dc.w	0,0,-32767
	dc.w	21451,-21451,-12385
	dc.w	21451,21451,12385
	dc.w	0,0,32767
	dc.w	-21451,-21451,12385
	dc.w	-21451,-21451,-12385
	dc.w	0,0,-32767
	dc.w	21451,21451,-12385
	dc.w	-21451,21451,12385
	dc.w	0,0,32767
	dc.w	21451,-21451,12385
	dc.w	21451,-21451,-12385
	dc.w	0,0,-32767
	dc.w	-21451,21451,-12385
	dc.w	-21451,-21451,12385
	dc.w	0,0,32767
	dc.w	21451,21451,12385
	dc.w	21451,21451,-12385
	dc.w	0,0,-32767
	dc.w	-21451,-21451,-12385
	dc.w	21451,-21451,12385
	dc.w	0,0,32767
	dc.w	-21451,21451,12385
	dc.w	-21451,21451,-12385
	dc.w	0,0,-32767
	dc.w	21451,-21451,-12385
currentNormals_Square_end
; points definitions, basically Projected Vertices and their UV
;	format: (dc.w): x_projected,y_projected,u,v
points_Square
point_Square0		dc.w	0,0,0,0,0
point_Square1		dc.w	0,0,0,0,0
point_Square2		dc.w	0,0,0,0,0
point_Square3		dc.w	0,0,0,0,0
point_Square4		dc.w	0,0,0,0,0
point_Square5		dc.w	0,0,0,0,0
point_Square6		dc.w	0,0,0,0,0
point_Square7		dc.w	0,0,0,0,0
point_Square8		dc.w	0,0,0,0,0
point_Square9		dc.w	0,0,0,0,0
point_Square10		dc.w	0,0,0,0,0
point_Square11		dc.w	0,0,0,0,0
point_Square12		dc.w	0,0,0,0,0
point_Square13		dc.w	0,0,0,0,0
point_Square14		dc.w	0,0,0,0,0
point_Square15		dc.w	0,0,0,0,0
point_Square16		dc.w	0,0,0,0,0
point_Square17		dc.w	0,0,0,0,0
point_Square18		dc.w	0,0,0,0,0
point_Square19		dc.w	0,0,0,0,0
point_Square20		dc.w	0,0,0,0,0
point_Square21		dc.w	0,0,0,0,0
point_Square22		dc.w	0,0,0,0,0
point_Square23		dc.w	0,0,0,0,0
points_Square_end
; source faces structure
;	format:
;	- vertex of face, for culling (dc.w): x,y,z
;	- normal value of face, for culling (dc.w): x,y,z
;	- pointers source vertices for visibility marking: (dc.l): ptr1,ptr2,ptr3
sourceFaces_Square
	dc.w	0*4,42*4,0*4
	dc.w	21451,21451,12385
	dc.l	currentVertices_Square+48	;	-> point6
	dc.l	currentVertices_Square+8	;	-> point1
	dc.l	currentVertices_Square+0	;	-> point0

	dc.w	0*4,36*4,10*4
	dc.w	0,0,32767
	dc.l	currentVertices_Square+56	;	-> point7
	dc.l	currentVertices_Square+16	;	-> point2
	dc.l	currentVertices_Square+8	;	-> point1

	dc.w	24*4,0*4,10*4
	dc.w	-21451,-21451,12385
	dc.l	currentVertices_Square+16	;	-> point2
	dc.l	currentVertices_Square+72	;	-> point9
	dc.l	currentVertices_Square+24	;	-> point3

	dc.w	0*4,18*4,0*4
	dc.w	-21451,-21451,-12385
	dc.l	currentVertices_Square+72	;	-> point9
	dc.l	currentVertices_Square+32	;	-> point4
	dc.l	currentVertices_Square+24	;	-> point3

	dc.w	0*4,24*4,-10*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Square+80	;	-> point10
	dc.l	currentVertices_Square+40	;	-> point5
	dc.l	currentVertices_Square+32	;	-> point4

	dc.w	0*4,36*4,-10*4
	dc.w	21451,21451,-12385
	dc.l	currentVertices_Square+88	;	-> point11
	dc.l	currentVertices_Square+0	;	-> point0
	dc.l	currentVertices_Square+40	;	-> point5

	dc.w	-42*4,0*4,0*4
	dc.w	-21451,21451,12385
	dc.l	currentVertices_Square+96	;	-> point12
	dc.l	currentVertices_Square+56	;	-> point7
	dc.l	currentVertices_Square+48	;	-> point6

	dc.w	0*4,36*4,10*4
	dc.w	0,0,32767
	dc.l	currentVertices_Square+56	;	-> point7
	dc.l	currentVertices_Square+112	;	-> point14
	dc.l	currentVertices_Square+64	;	-> point8

	dc.w	-24*4,0*4,10*4
	dc.w	21451,-21451,12385
	dc.l	currentVertices_Square+112	;	-> point14
	dc.l	currentVertices_Square+72	;	-> point9
	dc.l	currentVertices_Square+64	;	-> point8

	dc.w	-18*4,0*4,0*4
	dc.w	21451,-21451,-12385
	dc.l	currentVertices_Square+120	;	-> point15
	dc.l	currentVertices_Square+80	;	-> point10
	dc.l	currentVertices_Square+72	;	-> point9

	dc.w	-24*4,0*4,-10*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Square+128	;	-> point16
	dc.l	currentVertices_Square+88	;	-> point11
	dc.l	currentVertices_Square+80	;	-> point10

	dc.w	-36*4,0*4,-10*4
	dc.w	-21451,21451,-12385
	dc.l	currentVertices_Square+136	;	-> point17
	dc.l	currentVertices_Square+48	;	-> point6
	dc.l	currentVertices_Square+88	;	-> point11

	dc.w	0*4,-42*4,0*4
	dc.w	-21451,-21451,12385
	dc.l	currentVertices_Square+144	;	-> point18
	dc.l	currentVertices_Square+104	;	-> point13
	dc.l	currentVertices_Square+96	;	-> point12

	dc.w	0*4,-36*4,10*4
	dc.w	0,0,32767
	dc.l	currentVertices_Square+152	;	-> point19
	dc.l	currentVertices_Square+112	;	-> point14
	dc.l	currentVertices_Square+104	;	-> point13

	dc.w	0*4,-24*4,10*4
	dc.w	21451,21451,12385
	dc.l	currentVertices_Square+160	;	-> point20
	dc.l	currentVertices_Square+120	;	-> point15
	dc.l	currentVertices_Square+112	;	-> point14

	dc.w	0*4,-18*4,0*4
	dc.w	21451,21451,-12385
	dc.l	currentVertices_Square+168	;	-> point21
	dc.l	currentVertices_Square+128	;	-> point16
	dc.l	currentVertices_Square+120	;	-> point15

	dc.w	0*4,-24*4,-10*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Square+176	;	-> point22
	dc.l	currentVertices_Square+136	;	-> point17
	dc.l	currentVertices_Square+128	;	-> point16

	dc.w	0*4,-36*4,-10*4
	dc.w	-21451,-21451,-12385
	dc.l	currentVertices_Square+184	;	-> point23
	dc.l	currentVertices_Square+96	;	-> point12
	dc.l	currentVertices_Square+136	;	-> point17

	dc.w	42*4,0*4,0*4
	dc.w	21451,-21451,12385
	dc.l	currentVertices_Square+0	;	-> point0
	dc.l	currentVertices_Square+152	;	-> point19
	dc.l	currentVertices_Square+144	;	-> point18

	dc.w	36*4,0*4,10*4
	dc.w	0,0,32767
	dc.l	currentVertices_Square+8	;	-> point1
	dc.l	currentVertices_Square+160	;	-> point20
	dc.l	currentVertices_Square+152	;	-> point19

	dc.w	24*4,0*4,10*4
	dc.w	-21451,21451,12385
	dc.l	currentVertices_Square+16	;	-> point2
	dc.l	currentVertices_Square+168	;	-> point21
	dc.l	currentVertices_Square+160	;	-> point20

	dc.w	0*4,-18*4,0*4
	dc.w	-21451,21451,-12385
	dc.l	currentVertices_Square+168	;	-> point21
	dc.l	currentVertices_Square+32	;	-> point4
	dc.l	currentVertices_Square+176	;	-> point22

	dc.w	24*4,0*4,-10*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Square+32	;	-> point4
	dc.l	currentVertices_Square+184	;	-> point23
	dc.l	currentVertices_Square+176	;	-> point22

	dc.w	36*4,0*4,-10*4
	dc.w	21451,-21451,-12385
	dc.l	currentVertices_Square+40	;	-> point5
	dc.l	currentVertices_Square+144	;	-> point18
	dc.l	currentVertices_Square+184	;	-> point23

	dc.w	0*4,42*4,0*4
	dc.w	21451,21451,12385
	dc.l	currentVertices_Square+48	;	-> point6
	dc.l	currentVertices_Square+56	;	-> point7
	dc.l	currentVertices_Square+8	;	-> point1

	dc.w	0*4,36*4,10*4
	dc.w	0,0,32767
	dc.l	currentVertices_Square+56	;	-> point7
	dc.l	currentVertices_Square+64	;	-> point8
	dc.l	currentVertices_Square+16	;	-> point2

	dc.w	24*4,0*4,10*4
	dc.w	-21451,-21451,12385
	dc.l	currentVertices_Square+16	;	-> point2
	dc.l	currentVertices_Square+64	;	-> point8
	dc.l	currentVertices_Square+72	;	-> point9

	dc.w	0*4,18*4,0*4
	dc.w	-21451,-21451,-12385
	dc.l	currentVertices_Square+72	;	-> point9
	dc.l	currentVertices_Square+80	;	-> point10
	dc.l	currentVertices_Square+32	;	-> point4

	dc.w	0*4,24*4,-10*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Square+80	;	-> point10
	dc.l	currentVertices_Square+88	;	-> point11
	dc.l	currentVertices_Square+40	;	-> point5

	dc.w	0*4,36*4,-10*4
	dc.w	21451,21451,-12385
	dc.l	currentVertices_Square+88	;	-> point11
	dc.l	currentVertices_Square+48	;	-> point6
	dc.l	currentVertices_Square+0	;	-> point0

	dc.w	-42*4,0*4,0*4
	dc.w	-21451,21451,12385
	dc.l	currentVertices_Square+96	;	-> point12
	dc.l	currentVertices_Square+104	;	-> point13
	dc.l	currentVertices_Square+56	;	-> point7

	dc.w	0*4,36*4,10*4
	dc.w	0,0,32767
	dc.l	currentVertices_Square+56	;	-> point7
	dc.l	currentVertices_Square+104	;	-> point13
	dc.l	currentVertices_Square+112	;	-> point14

	dc.w	-24*4,0*4,10*4
	dc.w	21451,-21451,12385
	dc.l	currentVertices_Square+112	;	-> point14
	dc.l	currentVertices_Square+120	;	-> point15
	dc.l	currentVertices_Square+72	;	-> point9

	dc.w	-18*4,0*4,0*4
	dc.w	21451,-21451,-12385
	dc.l	currentVertices_Square+120	;	-> point15
	dc.l	currentVertices_Square+128	;	-> point16
	dc.l	currentVertices_Square+80	;	-> point10

	dc.w	-24*4,0*4,-10*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Square+128	;	-> point16
	dc.l	currentVertices_Square+136	;	-> point17
	dc.l	currentVertices_Square+88	;	-> point11

	dc.w	-36*4,0*4,-10*4
	dc.w	-21451,21451,-12385
	dc.l	currentVertices_Square+136	;	-> point17
	dc.l	currentVertices_Square+96	;	-> point12
	dc.l	currentVertices_Square+48	;	-> point6

	dc.w	0*4,-42*4,0*4
	dc.w	-21451,-21451,12385
	dc.l	currentVertices_Square+144	;	-> point18
	dc.l	currentVertices_Square+152	;	-> point19
	dc.l	currentVertices_Square+104	;	-> point13

	dc.w	0*4,-36*4,10*4
	dc.w	0,0,32767
	dc.l	currentVertices_Square+152	;	-> point19
	dc.l	currentVertices_Square+160	;	-> point20
	dc.l	currentVertices_Square+112	;	-> point14

	dc.w	0*4,-24*4,10*4
	dc.w	21451,21451,12385
	dc.l	currentVertices_Square+160	;	-> point20
	dc.l	currentVertices_Square+168	;	-> point21
	dc.l	currentVertices_Square+120	;	-> point15

	dc.w	0*4,-18*4,0*4
	dc.w	21451,21451,-12385
	dc.l	currentVertices_Square+168	;	-> point21
	dc.l	currentVertices_Square+176	;	-> point22
	dc.l	currentVertices_Square+128	;	-> point16

	dc.w	0*4,-24*4,-10*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Square+176	;	-> point22
	dc.l	currentVertices_Square+184	;	-> point23
	dc.l	currentVertices_Square+136	;	-> point17

	dc.w	0*4,-36*4,-10*4
	dc.w	-21451,-21451,-12385
	dc.l	currentVertices_Square+184	;	-> point23
	dc.l	currentVertices_Square+144	;	-> point18
	dc.l	currentVertices_Square+96	;	-> point12

	dc.w	42*4,0*4,0*4
	dc.w	21451,-21451,12385
	dc.l	currentVertices_Square+0	;	-> point0
	dc.l	currentVertices_Square+8	;	-> point1
	dc.l	currentVertices_Square+152	;	-> point19

	dc.w	36*4,0*4,10*4
	dc.w	0,0,32767
	dc.l	currentVertices_Square+8	;	-> point1
	dc.l	currentVertices_Square+16	;	-> point2
	dc.l	currentVertices_Square+160	;	-> point20

	dc.w	24*4,0*4,10*4
	dc.w	-21451,21451,12385
	dc.l	currentVertices_Square+16	;	-> point2
	dc.l	currentVertices_Square+24	;	-> point3
	dc.l	currentVertices_Square+168	;	-> point21

	dc.w	0*4,-18*4,0*4
	dc.w	-21451,21451,-12385
	dc.l	currentVertices_Square+168	;	-> point21
	dc.l	currentVertices_Square+24	;	-> point3
	dc.l	currentVertices_Square+32	;	-> point4

	dc.w	24*4,0*4,-10*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Square+32	;	-> point4
	dc.l	currentVertices_Square+40	;	-> point5
	dc.l	currentVertices_Square+184	;	-> point23

	dc.w	36*4,0*4,-10*4
	dc.w	21451,-21451,-12385
	dc.l	currentVertices_Square+40	;	-> point5
	dc.l	currentVertices_Square+0	;	-> point0
	dc.l	currentVertices_Square+144	;	-> point18

sourceFaces_Square_end
; destination faces
;	format:
;	- visibility (dc.w)
;	- pointers to destination points: (dc.l) * 3
destFaces_Square
	dc.w	0
	dc.l	point_Square6
	dc.l	point_Square1
	dc.l	point_Square0
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square7
	dc.l	point_Square2
	dc.l	point_Square1
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square2
	dc.l	point_Square9
	dc.l	point_Square3
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square9
	dc.l	point_Square4
	dc.l	point_Square3
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square10
	dc.l	point_Square5
	dc.l	point_Square4
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square11
	dc.l	point_Square0
	dc.l	point_Square5
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square12
	dc.l	point_Square7
	dc.l	point_Square6
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square7
	dc.l	point_Square14
	dc.l	point_Square8
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square14
	dc.l	point_Square9
	dc.l	point_Square8
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square15
	dc.l	point_Square10
	dc.l	point_Square9
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square16
	dc.l	point_Square11
	dc.l	point_Square10
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square17
	dc.l	point_Square6
	dc.l	point_Square11
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square18
	dc.l	point_Square13
	dc.l	point_Square12
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square19
	dc.l	point_Square14
	dc.l	point_Square13
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square20
	dc.l	point_Square15
	dc.l	point_Square14
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square21
	dc.l	point_Square16
	dc.l	point_Square15
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square22
	dc.l	point_Square17
	dc.l	point_Square16
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square23
	dc.l	point_Square12
	dc.l	point_Square17
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square0
	dc.l	point_Square19
	dc.l	point_Square18
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square1
	dc.l	point_Square20
	dc.l	point_Square19
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square2
	dc.l	point_Square21
	dc.l	point_Square20
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square21
	dc.l	point_Square4
	dc.l	point_Square22
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square4
	dc.l	point_Square23
	dc.l	point_Square22
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square5
	dc.l	point_Square18
	dc.l	point_Square23
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square6
	dc.l	point_Square7
	dc.l	point_Square1
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square7
	dc.l	point_Square8
	dc.l	point_Square2
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square2
	dc.l	point_Square8
	dc.l	point_Square9
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square9
	dc.l	point_Square10
	dc.l	point_Square4
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square10
	dc.l	point_Square11
	dc.l	point_Square5
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square11
	dc.l	point_Square6
	dc.l	point_Square0
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square12
	dc.l	point_Square13
	dc.l	point_Square7
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square7
	dc.l	point_Square13
	dc.l	point_Square14
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square14
	dc.l	point_Square15
	dc.l	point_Square9
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square15
	dc.l	point_Square16
	dc.l	point_Square10
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square16
	dc.l	point_Square17
	dc.l	point_Square11
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square17
	dc.l	point_Square12
	dc.l	point_Square6
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square18
	dc.l	point_Square19
	dc.l	point_Square13
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square19
	dc.l	point_Square20
	dc.l	point_Square14
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square20
	dc.l	point_Square21
	dc.l	point_Square15
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square21
	dc.l	point_Square22
	dc.l	point_Square16
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square22
	dc.l	point_Square23
	dc.l	point_Square17
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square23
	dc.l	point_Square18
	dc.l	point_Square12
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square0
	dc.l	point_Square1
	dc.l	point_Square19
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square1
	dc.l	point_Square2
	dc.l	point_Square20
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square2
	dc.l	point_Square3
	dc.l	point_Square21
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square21
	dc.l	point_Square3
	dc.l	point_Square4
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square4
	dc.l	point_Square5
	dc.l	point_Square23
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Square5
	dc.l	point_Square0
	dc.l	point_Square18
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

destFaces_Square_end



init_Square
	move.w	number_of_faces_Square,current_number_of_faces
	move.w	number_of_vertices_Square,current_number_of_vertices
	lea	currentVertices_Square,a0
	move.l	a0,a5
	move.l	currentVerticesPointer,a1
	move.l	a1,a4					; save this address for later use, target base
	move.l	#currentVertices_Square_end,d7
	sub.l	a0,d7						; number of bytes
	lsr.w	#3,d7
	subq.w	#1,d7
.cpv
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	dbra	d7,.cpv


	lea		currentNormals_Square,a0
	move.l	currentNormalsPointer,a1
	move.l	#currentNormals_Square_end,d7
	sub.l	a0,d7
	lsr.w	d7
	subq.w	#1,d7
.cpn	
		move.w	(a0)+,(a1)+
	dbra	d7,.cpn


	lea		points_Square,a0
	move.l	a0,a6					; save this address for later use
	move.l	currentPointsPointer,a1
	move.l	a1,a3					; target base
	move.l	#points_Square_end,d7
	sub.l	a0,d7
	lsr.w	d7
	subq.w	#1,d7
.cpp
		move.w	(a0)+,(a1)+
	dbra	d7,.cpp


	lea		sourceFaces_Square,a0				;3*2 + 3*2 + 3*4 = 6 * 4 = 24
	move.l	currentSourceFacesPointer,a1
	move.l	#sourceFaces_Square_end,d7
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


	lea		destFaces_Square,a0
	move.l	currentDestFacesPointer,a1
	move.l	#destFaces_Square_end,d7
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
