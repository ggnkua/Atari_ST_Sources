; PARSE PARAMETERS: `php parseObject.php test_07.blend.json.txt 0`
; OBJ NAME: Cube
number_of_faces		dc.w		44
number_of_vertices_env		dc.w		24
; source vertices data:
;	format (dc.w): visible,x,y,z
currentVertices
	dc.w	0,-18*4,-18*4,-23*4		;	0
	dc.w	0,-18*4,-23*4,-18*4		;	8
	dc.w	0,-23*4,-18*4,-18*4		;	16
	dc.w	0,-18*4,-23*4,18*4		;	24
	dc.w	0,-18*4,-18*4,23*4		;	32
	dc.w	0,-23*4,-18*4,18*4		;	40
	dc.w	0,-18*4,18*4,-23*4		;	48
	dc.w	0,-23*4,18*4,-18*4		;	56
	dc.w	0,-18*4,23*4,-18*4		;	64
	dc.w	0,-18*4,18*4,23*4		;	72
	dc.w	0,-18*4,23*4,18*4		;	80
	dc.w	0,-23*4,18*4,18*4		;	88
	dc.w	0,18*4,-18*4,-23*4		;	96
	dc.w	0,23*4,-18*4,-18*4		;	104
	dc.w	0,18*4,-23*4,-18*4		;	112
	dc.w	0,18*4,-18*4,23*4		;	120
	dc.w	0,18*4,-23*4,18*4		;	128
	dc.w	0,23*4,-18*4,18*4		;	136
	dc.w	0,18*4,18*4,-23*4		;	144
	dc.w	0,18*4,23*4,-18*4		;	152
	dc.w	0,23*4,18*4,-18*4		;	160
	dc.w	0,18*4,18*4,23*4		;	168
	dc.w	0,23*4,18*4,18*4		;	176
	dc.w	0,18*4,23*4,18*4		;	184
; source normals for vertices data:
;	format (dc.w): x,y,z
currentNormals
	dc.w	-12647,-12647,-32420
	dc.w	-12647,-32420,-12647
	dc.w	-32420,-12647,-12647
	dc.w	-12647,-32420,12647
	dc.w	-12647,-12647,32420
	dc.w	-32420,-12647,12647
	dc.w	-12647,12647,-32420
	dc.w	-32420,12647,-12647
	dc.w	-12647,32420,-12647
	dc.w	-12647,12647,32420
	dc.w	-12647,32420,12647
	dc.w	-32420,12647,12647
	dc.w	12647,-12647,-32420
	dc.w	32420,-12647,-12647
	dc.w	12647,-32420,-12647
	dc.w	12647,-12647,32420
	dc.w	12647,-32420,12647
	dc.w	32420,-12647,12647
	dc.w	12647,12647,-32420
	dc.w	12647,32420,-12647
	dc.w	32420,12647,-12647
	dc.w	12647,12647,32420
	dc.w	32420,12647,12647
	dc.w	12647,32420,12647
; points definitions, basically Projected Vertices and their UV
;	format: (dc.w): x_projected,y_projected,u,v
points
point0		dc.w	0,0,0,0
point1		dc.w	0,0,0,0
point2		dc.w	0,0,0,0
point3		dc.w	0,0,0,0
point4		dc.w	0,0,0,0
point5		dc.w	0,0,0,0
point6		dc.w	0,0,0,0
point7		dc.w	0,0,0,0
point8		dc.w	0,0,0,0
point9		dc.w	0,0,0,0
point10		dc.w	0,0,0,0
point11		dc.w	0,0,0,0
point12		dc.w	0,0,0,0
point13		dc.w	0,0,0,0
point14		dc.w	0,0,0,0
point15		dc.w	0,0,0,0
point16		dc.w	0,0,0,0
point17		dc.w	0,0,0,0
point18		dc.w	0,0,0,0
point19		dc.w	0,0,0,0
point20		dc.w	0,0,0,0
point21		dc.w	0,0,0,0
point22		dc.w	0,0,0,0
point23		dc.w	0,0,0,0
; source faces structure
;	format:
;	- vertex of face, for culling (dc.w): x,y,z
;	- normal value of face, for culling (dc.w): x,y,z
;	- pointers source vertices for visibility marking: (dc.l): ptr1,ptr2,ptr3
sourceFaces
	dc.w	18*4,-23*4,18*4
	dc.w	0,-32767,0
	dc.l	currentVertices+128	;	-> point16
	dc.l	currentVertices+8	;	-> point1
	dc.l	currentVertices+112	;	-> point14

	dc.w	23*4,18*4,18*4
	dc.w	32767,0,0
	dc.l	currentVertices+176	;	-> point22
	dc.l	currentVertices+104	;	-> point13
	dc.l	currentVertices+160	;	-> point20

	dc.w	-18*4,18*4,23*4
	dc.w	0,0,32767
	dc.l	currentVertices+72	;	-> point9
	dc.l	currentVertices+120	;	-> point15
	dc.l	currentVertices+168	;	-> point21

	dc.w	-23*4,-18*4,18*4
	dc.w	-32767,0,0
	dc.l	currentVertices+40	;	-> point5
	dc.l	currentVertices+56	;	-> point7
	dc.l	currentVertices+16	;	-> point2

	dc.w	-18*4,23*4,18*4
	dc.w	0,32767,0
	dc.l	currentVertices+80	;	-> point10
	dc.l	currentVertices+152	;	-> point19
	dc.l	currentVertices+64	;	-> point8

	dc.w	-18*4,-18*4,-23*4
	dc.w	-18918,-18918,-18918
	dc.l	currentVertices+0	;	-> point0
	dc.l	currentVertices+8	;	-> point1
	dc.l	currentVertices+16	;	-> point2

	dc.w	-18*4,-23*4,18*4
	dc.w	-18918,-18918,18918
	dc.l	currentVertices+24	;	-> point3
	dc.l	currentVertices+32	;	-> point4
	dc.l	currentVertices+40	;	-> point5

	dc.w	-18*4,18*4,-23*4
	dc.w	-18918,18918,-18918
	dc.l	currentVertices+48	;	-> point6
	dc.l	currentVertices+56	;	-> point7
	dc.l	currentVertices+64	;	-> point8

	dc.w	-18*4,18*4,23*4
	dc.w	-18918,18918,18918
	dc.l	currentVertices+72	;	-> point9
	dc.l	currentVertices+80	;	-> point10
	dc.l	currentVertices+88	;	-> point11

	dc.w	18*4,-18*4,-23*4
	dc.w	18918,-18918,-18918
	dc.l	currentVertices+96	;	-> point12
	dc.l	currentVertices+104	;	-> point13
	dc.l	currentVertices+112	;	-> point14

	dc.w	18*4,-18*4,23*4
	dc.w	18918,-18918,18918
	dc.l	currentVertices+120	;	-> point15
	dc.l	currentVertices+128	;	-> point16
	dc.l	currentVertices+136	;	-> point17

	dc.w	18*4,18*4,-23*4
	dc.w	18918,18918,-18918
	dc.l	currentVertices+144	;	-> point18
	dc.l	currentVertices+152	;	-> point19
	dc.l	currentVertices+160	;	-> point20

	dc.w	18*4,18*4,23*4
	dc.w	18918,18918,18918
	dc.l	currentVertices+168	;	-> point21
	dc.l	currentVertices+176	;	-> point22
	dc.l	currentVertices+184	;	-> point23

	dc.w	-18*4,-18*4,-23*4
	dc.w	-23170,0,-23170
	dc.l	currentVertices+0	;	-> point0
	dc.l	currentVertices+56	;	-> point7
	dc.l	currentVertices+48	;	-> point6

	dc.w	-18*4,-23*4,18*4
	dc.w	-23170,-23170,0
	dc.l	currentVertices+24	;	-> point3
	dc.l	currentVertices+16	;	-> point2
	dc.l	currentVertices+8	;	-> point1

	dc.w	-18*4,18*4,23*4
	dc.w	-23170,0,23170
	dc.l	currentVertices+72	;	-> point9
	dc.l	currentVertices+40	;	-> point5
	dc.l	currentVertices+32	;	-> point4

	dc.w	-18*4,23*4,-18*4
	dc.w	-23170,23170,0
	dc.l	currentVertices+64	;	-> point8
	dc.l	currentVertices+88	;	-> point11
	dc.l	currentVertices+80	;	-> point10

	dc.w	-18*4,18*4,-23*4
	dc.w	0,23170,-23170
	dc.l	currentVertices+48	;	-> point6
	dc.l	currentVertices+152	;	-> point19
	dc.l	currentVertices+144	;	-> point18

	dc.w	18*4,18*4,23*4
	dc.w	0,23170,23170
	dc.l	currentVertices+168	;	-> point21
	dc.l	currentVertices+80	;	-> point10
	dc.l	currentVertices+72	;	-> point9

	dc.w	23*4,18*4,-18*4
	dc.w	23170,23170,0
	dc.l	currentVertices+160	;	-> point20
	dc.l	currentVertices+184	;	-> point23
	dc.l	currentVertices+176	;	-> point22

	dc.w	18*4,18*4,-23*4
	dc.w	23170,0,-23170
	dc.l	currentVertices+144	;	-> point18
	dc.l	currentVertices+104	;	-> point13
	dc.l	currentVertices+96	;	-> point12

	dc.w	18*4,-18*4,23*4
	dc.w	23170,0,23170
	dc.l	currentVertices+120	;	-> point15
	dc.l	currentVertices+176	;	-> point22
	dc.l	currentVertices+168	;	-> point21

	dc.w	18*4,-23*4,-18*4
	dc.w	23170,-23170,0
	dc.l	currentVertices+112	;	-> point14
	dc.l	currentVertices+136	;	-> point17
	dc.l	currentVertices+128	;	-> point16

	dc.w	18*4,-18*4,-23*4
	dc.w	0,-23170,-23170
	dc.l	currentVertices+96	;	-> point12
	dc.l	currentVertices+8	;	-> point1
	dc.l	currentVertices+0	;	-> point0

	dc.w	-18*4,-18*4,23*4
	dc.w	0,-23170,23170
	dc.l	currentVertices+32	;	-> point4
	dc.l	currentVertices+128	;	-> point16
	dc.l	currentVertices+120	;	-> point15

	dc.w	18*4,18*4,-23*4
	dc.w	0,0,-32767
	dc.l	currentVertices+144	;	-> point18
	dc.l	currentVertices+0	;	-> point0
	dc.l	currentVertices+48	;	-> point6

	dc.w	18*4,-23*4,18*4
	dc.w	0,-32767,0
	dc.l	currentVertices+128	;	-> point16
	dc.l	currentVertices+24	;	-> point3
	dc.l	currentVertices+8	;	-> point1

	dc.w	23*4,18*4,18*4
	dc.w	32767,0,0
	dc.l	currentVertices+176	;	-> point22
	dc.l	currentVertices+136	;	-> point17
	dc.l	currentVertices+104	;	-> point13

	dc.w	-18*4,18*4,23*4
	dc.w	0,0,32767
	dc.l	currentVertices+72	;	-> point9
	dc.l	currentVertices+32	;	-> point4
	dc.l	currentVertices+120	;	-> point15

	dc.w	-23*4,-18*4,18*4
	dc.w	-32767,0,0
	dc.l	currentVertices+40	;	-> point5
	dc.l	currentVertices+88	;	-> point11
	dc.l	currentVertices+56	;	-> point7

	dc.w	-18*4,23*4,18*4
	dc.w	0,32767,0
	dc.l	currentVertices+80	;	-> point10
	dc.l	currentVertices+184	;	-> point23
	dc.l	currentVertices+152	;	-> point19

	dc.w	-18*4,-18*4,-23*4
	dc.w	-23170,0,-23170
	dc.l	currentVertices+0	;	-> point0
	dc.l	currentVertices+16	;	-> point2
	dc.l	currentVertices+56	;	-> point7

	dc.w	-18*4,-23*4,18*4
	dc.w	-23170,-23170,0
	dc.l	currentVertices+24	;	-> point3
	dc.l	currentVertices+40	;	-> point5
	dc.l	currentVertices+16	;	-> point2

	dc.w	-18*4,18*4,23*4
	dc.w	-23170,0,23170
	dc.l	currentVertices+72	;	-> point9
	dc.l	currentVertices+88	;	-> point11
	dc.l	currentVertices+40	;	-> point5

	dc.w	-18*4,23*4,-18*4
	dc.w	-23170,23170,0
	dc.l	currentVertices+64	;	-> point8
	dc.l	currentVertices+56	;	-> point7
	dc.l	currentVertices+88	;	-> point11

	dc.w	-18*4,18*4,-23*4
	dc.w	0,23170,-23170
	dc.l	currentVertices+48	;	-> point6
	dc.l	currentVertices+64	;	-> point8
	dc.l	currentVertices+152	;	-> point19

	dc.w	18*4,18*4,23*4
	dc.w	0,23170,23170
	dc.l	currentVertices+168	;	-> point21
	dc.l	currentVertices+184	;	-> point23
	dc.l	currentVertices+80	;	-> point10

	dc.w	23*4,18*4,-18*4
	dc.w	23170,23170,0
	dc.l	currentVertices+160	;	-> point20
	dc.l	currentVertices+152	;	-> point19
	dc.l	currentVertices+184	;	-> point23

	dc.w	18*4,18*4,-23*4
	dc.w	23170,0,-23170
	dc.l	currentVertices+144	;	-> point18
	dc.l	currentVertices+160	;	-> point20
	dc.l	currentVertices+104	;	-> point13

	dc.w	18*4,-18*4,23*4
	dc.w	23170,0,23170
	dc.l	currentVertices+120	;	-> point15
	dc.l	currentVertices+136	;	-> point17
	dc.l	currentVertices+176	;	-> point22

	dc.w	18*4,-23*4,-18*4
	dc.w	23170,-23170,0
	dc.l	currentVertices+112	;	-> point14
	dc.l	currentVertices+104	;	-> point13
	dc.l	currentVertices+136	;	-> point17

	dc.w	18*4,-18*4,-23*4
	dc.w	0,-23170,-23170
	dc.l	currentVertices+96	;	-> point12
	dc.l	currentVertices+112	;	-> point14
	dc.l	currentVertices+8	;	-> point1

	dc.w	-18*4,-18*4,23*4
	dc.w	0,-23170,23170
	dc.l	currentVertices+32	;	-> point4
	dc.l	currentVertices+24	;	-> point3
	dc.l	currentVertices+128	;	-> point16

	dc.w	18*4,18*4,-23*4
	dc.w	0,0,-32767
	dc.l	currentVertices+144	;	-> point18
	dc.l	currentVertices+96	;	-> point12
	dc.l	currentVertices+0	;	-> point0

; destination faces
;	format:
;	- visibility (dc.w)
;	- pointers to destination points: (dc.l) * 3
destFaces
	dc.w	0
	dc.l	point16
	dc.l	point1
	dc.l	point14

	dc.w	0
	dc.l	point22
	dc.l	point13
	dc.l	point20

	dc.w	0
	dc.l	point9
	dc.l	point15
	dc.l	point21

	dc.w	0
	dc.l	point5
	dc.l	point7
	dc.l	point2

	dc.w	0
	dc.l	point10
	dc.l	point19
	dc.l	point8

	dc.w	0
	dc.l	point0
	dc.l	point1
	dc.l	point2

	dc.w	0
	dc.l	point3
	dc.l	point4
	dc.l	point5

	dc.w	0
	dc.l	point6
	dc.l	point7
	dc.l	point8

	dc.w	0
	dc.l	point9
	dc.l	point10
	dc.l	point11

	dc.w	0
	dc.l	point12
	dc.l	point13
	dc.l	point14

	dc.w	0
	dc.l	point15
	dc.l	point16
	dc.l	point17

	dc.w	0
	dc.l	point18
	dc.l	point19
	dc.l	point20

	dc.w	0
	dc.l	point21
	dc.l	point22
	dc.l	point23

	dc.w	0
	dc.l	point0
	dc.l	point7
	dc.l	point6

	dc.w	0
	dc.l	point3
	dc.l	point2
	dc.l	point1

	dc.w	0
	dc.l	point9
	dc.l	point5
	dc.l	point4

	dc.w	0
	dc.l	point8
	dc.l	point11
	dc.l	point10

	dc.w	0
	dc.l	point6
	dc.l	point19
	dc.l	point18

	dc.w	0
	dc.l	point21
	dc.l	point10
	dc.l	point9

	dc.w	0
	dc.l	point20
	dc.l	point23
	dc.l	point22

	dc.w	0
	dc.l	point18
	dc.l	point13
	dc.l	point12

	dc.w	0
	dc.l	point15
	dc.l	point22
	dc.l	point21

	dc.w	0
	dc.l	point14
	dc.l	point17
	dc.l	point16

	dc.w	0
	dc.l	point12
	dc.l	point1
	dc.l	point0

	dc.w	0
	dc.l	point4
	dc.l	point16
	dc.l	point15

	dc.w	0
	dc.l	point18
	dc.l	point0
	dc.l	point6

	dc.w	0
	dc.l	point16
	dc.l	point3
	dc.l	point1

	dc.w	0
	dc.l	point22
	dc.l	point17
	dc.l	point13

	dc.w	0
	dc.l	point9
	dc.l	point4
	dc.l	point15

	dc.w	0
	dc.l	point5
	dc.l	point11
	dc.l	point7

	dc.w	0
	dc.l	point10
	dc.l	point23
	dc.l	point19

	dc.w	0
	dc.l	point0
	dc.l	point2
	dc.l	point7

	dc.w	0
	dc.l	point3
	dc.l	point5
	dc.l	point2

	dc.w	0
	dc.l	point9
	dc.l	point11
	dc.l	point5

	dc.w	0
	dc.l	point8
	dc.l	point7
	dc.l	point11

	dc.w	0
	dc.l	point6
	dc.l	point8
	dc.l	point19

	dc.w	0
	dc.l	point21
	dc.l	point23
	dc.l	point10

	dc.w	0
	dc.l	point20
	dc.l	point19
	dc.l	point23

	dc.w	0
	dc.l	point18
	dc.l	point20
	dc.l	point13

	dc.w	0
	dc.l	point15
	dc.l	point17
	dc.l	point22

	dc.w	0
	dc.l	point14
	dc.l	point13
	dc.l	point17

	dc.w	0
	dc.l	point12
	dc.l	point14
	dc.l	point1

	dc.w	0
	dc.l	point4
	dc.l	point3
	dc.l	point16

	dc.w	0
	dc.l	point18
	dc.l	point12
	dc.l	point0

