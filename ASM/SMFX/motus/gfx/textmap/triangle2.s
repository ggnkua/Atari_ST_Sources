; PARSE PARAMETERS: `php parseObject.php triangle2.blend.json.txt 0` and size: 34
; OBJ NAME: Triangle
number_of_faces_Triangle		dc.w		72
number_of_vertices_Triangle		dc.w		36
; source vertices data:
;	format (dc.w): visible,x,y,z
currentVertices_Triangle
	dc.w	0,43*4,0*4,0*4		;	0
	dc.w	0,41*4,0*4,4*4		;	8
	dc.w	0,38*4,0*4,7*4		;	16
	dc.w	0,34*4,0*4,9*4		;	24
	dc.w	0,30*4,0*4,7*4		;	32
	dc.w	0,27*4,0*4,4*4		;	40
	dc.w	0,26*4,0*4,0*4		;	48
	dc.w	0,27*4,0*4,-4*4		;	56
	dc.w	0,30*4,0*4,-7*4		;	64
	dc.w	0,34*4,0*4,-9*4		;	72
	dc.w	0,38*4,0*4,-7*4		;	80
	dc.w	0,41*4,0*4,-4*4		;	88
	dc.w	0,-21*4,37*4,0*4		;	96
	dc.w	0,-21*4,36*4,4*4		;	104
	dc.w	0,-19*4,33*4,7*4		;	112
	dc.w	0,-17*4,29*4,9*4		;	120
	dc.w	0,-15*4,26*4,7*4		;	128
	dc.w	0,-13*4,23*4,4*4		;	136
	dc.w	0,-13*4,22*4,0*4		;	144
	dc.w	0,-13*4,23*4,-4*4		;	152
	dc.w	0,-15*4,26*4,-7*4		;	160
	dc.w	0,-17*4,29*4,-9*4		;	168
	dc.w	0,-19*4,33*4,-7*4		;	176
	dc.w	0,-21*4,36*4,-4*4		;	184
	dc.w	0,-21*4,-37*4,0*4		;	192
	dc.w	0,-21*4,-36*4,4*4		;	200
	dc.w	0,-19*4,-33*4,7*4		;	208
	dc.w	0,-17*4,-29*4,9*4		;	216
	dc.w	0,-15*4,-26*4,7*4		;	224
	dc.w	0,-13*4,-23*4,4*4		;	232
	dc.w	0,-13*4,-22*4,0*4		;	240
	dc.w	0,-13*4,-23*4,-4*4		;	248
	dc.w	0,-15*4,-26*4,-7*4		;	256
	dc.w	0,-17*4,-29*4,-9*4		;	264
	dc.w	0,-19*4,-33*4,-7*4		;	272
	dc.w	0,-21*4,-36*4,-4*4		;	280
currentVertices_Triangle_end
; source normals for vertices data:
;	format (dc.w): x,y,z
currentNormals_Triangle
	dc.w	16238,28126,4351
	dc.w	14654,25381,14654
	dc.w	7739,13404,28881
	dc.w	-7739,-13404,28881
	dc.w	-14654,-25381,14654
	dc.w	-16238,-28126,4351
	dc.w	-16238,-28126,-4351
	dc.w	-14654,-25381,-14654
	dc.w	-7739,-13404,-28881
	dc.w	7739,13404,-28881
	dc.w	14654,25381,-14654
	dc.w	16238,28126,-4351
	dc.w	-32477,0,4351
	dc.w	-29308,0,14654
	dc.w	-15477,0,28881
	dc.w	15477,0,28881
	dc.w	29308,0,14654
	dc.w	32477,0,4351
	dc.w	32477,0,-4351
	dc.w	29308,0,-14654
	dc.w	15477,0,-28881
	dc.w	-15477,0,-28881
	dc.w	-29308,0,-14654
	dc.w	-32477,0,-4351
	dc.w	16238,-28126,4351
	dc.w	14654,-25381,14654
	dc.w	7739,-13404,28881
	dc.w	-7739,13404,28881
;	herp: 1
	dc.w	-14654,25381,14654
	dc.w	-16238,28126,4351
	dc.w	-16238,28126,-4351
;	herp: 1
	dc.w	-14654,25381,-14654
	dc.w	-7739,13404,-28881
	dc.w	7739,-13404,-28881
	dc.w	14654,-25381,-14654
	dc.w	16238,-28126,-4351
	dc.w	16238,28126,4351
	dc.w	14654,25381,14654
	dc.w	7739,13404,28881
	dc.w	-7739,-13404,28881
;	herp: 1
	dc.w	-14654,-25381,14654
	dc.w	-16238,-28126,4351
	dc.w	-16238,-28126,-4351
;	herp: 1
	dc.w	-14654,-25381,-14654
	dc.w	-7739,-13404,-28881
	dc.w	7739,13404,-28881
	dc.w	14654,25381,-14654
	dc.w	16238,28126,-4351
	dc.w	-32477,0,4351
	dc.w	-29308,0,14654
	dc.w	-15477,0,28881
	dc.w	15477,0,28881
	dc.w	29308,0,14654
	dc.w	32477,0,4351
	dc.w	32477,0,-4351
	dc.w	29308,0,-14654
	dc.w	15477,0,-28881
	dc.w	-15477,0,-28881
	dc.w	-29308,0,-14654
	dc.w	-32477,0,-4351
	dc.w	16238,-28126,4351
	dc.w	14654,-25381,14654
	dc.w	7739,-13404,28881
	dc.w	-7739,13404,28881
	dc.w	-14654,25381,14654
	dc.w	-16238,28126,4351
	dc.w	-16238,28126,-4351
	dc.w	-14654,25381,-14654
	dc.w	-7739,13404,-28881
	dc.w	7739,-13404,-28881
	dc.w	14654,-25381,-14654
	dc.w	16238,-28126,-4351
currentNormals_Triangle_end
; points definitions, basically Projected Vertices and their UV
;	format: (dc.w): x_projected,y_projected,u,v
points_Triangle
point_Triangle0		dc.w	0,0,0,0,0
point_Triangle1		dc.w	0,0,0,0,0
point_Triangle2		dc.w	0,0,0,0,0
point_Triangle3		dc.w	0,0,0,0,0
point_Triangle4		dc.w	0,0,0,0,0
point_Triangle5		dc.w	0,0,0,0,0
point_Triangle6		dc.w	0,0,0,0,0
point_Triangle7		dc.w	0,0,0,0,0
point_Triangle8		dc.w	0,0,0,0,0
point_Triangle9		dc.w	0,0,0,0,0
point_Triangle10		dc.w	0,0,0,0,0
point_Triangle11		dc.w	0,0,0,0,0
point_Triangle12		dc.w	0,0,0,0,0
point_Triangle13		dc.w	0,0,0,0,0
point_Triangle14		dc.w	0,0,0,0,0
point_Triangle15		dc.w	0,0,0,0,0
point_Triangle16		dc.w	0,0,0,0,0
point_Triangle17		dc.w	0,0,0,0,0
point_Triangle18		dc.w	0,0,0,0,0
point_Triangle19		dc.w	0,0,0,0,0
point_Triangle20		dc.w	0,0,0,0,0
point_Triangle21		dc.w	0,0,0,0,0
point_Triangle22		dc.w	0,0,0,0,0
point_Triangle23		dc.w	0,0,0,0,0
point_Triangle24		dc.w	0,0,0,0,0
point_Triangle25		dc.w	0,0,0,0,0
point_Triangle26		dc.w	0,0,0,0,0
point_Triangle27		dc.w	0,0,0,0,0
point_Triangle28		dc.w	0,0,0,0,0
point_Triangle29		dc.w	0,0,0,0,0
point_Triangle30		dc.w	0,0,0,0,0
point_Triangle31		dc.w	0,0,0,0,0
point_Triangle32		dc.w	0,0,0,0,0
point_Triangle33		dc.w	0,0,0,0,0
point_Triangle34		dc.w	0,0,0,0,0
point_Triangle35		dc.w	0,0,0,0,0
points_Triangle_end
; source faces structure
;	format:
;	- vertex of face, for culling (dc.w): x,y,z
;	- normal value of face, for culling (dc.w): x,y,z
;	- pointers source vertices for visibility marking: (dc.l): ptr1,ptr2,ptr3
sourceFaces_Triangle
	dc.w	43*4,0*4,0*4
	dc.w	16238,28126,4351
	dc.l	currentVertices_Triangle+0	;	-> point0
	dc.l	currentVertices_Triangle+104	;	-> point13
	dc.l	currentVertices_Triangle+8	;	-> point1

	dc.w	-21*4,36*4,4*4
	dc.w	14654,25381,14654
	dc.l	currentVertices_Triangle+104	;	-> point13
	dc.l	currentVertices_Triangle+16	;	-> point2
	dc.l	currentVertices_Triangle+8	;	-> point1

	dc.w	-19*4,33*4,7*4
	dc.w	7739,13404,28881
	dc.l	currentVertices_Triangle+112	;	-> point14
	dc.l	currentVertices_Triangle+24	;	-> point3
	dc.l	currentVertices_Triangle+16	;	-> point2

	dc.w	-17*4,29*4,9*4
	dc.w	-7739,-13404,28881
	dc.l	currentVertices_Triangle+120	;	-> point15
	dc.l	currentVertices_Triangle+32	;	-> point4
	dc.l	currentVertices_Triangle+24	;	-> point3

	dc.w	-15*4,26*4,7*4
	dc.w	-14654,-25381,14654
	dc.l	currentVertices_Triangle+128	;	-> point16
	dc.l	currentVertices_Triangle+40	;	-> point5
	dc.l	currentVertices_Triangle+32	;	-> point4

	dc.w	27*4,0*4,4*4
	dc.w	-16238,-28126,4351
	dc.l	currentVertices_Triangle+40	;	-> point5
	dc.l	currentVertices_Triangle+144	;	-> point18
	dc.l	currentVertices_Triangle+48	;	-> point6

	dc.w	-13*4,22*4,0*4
	dc.w	-16238,-28126,-4351
	dc.l	currentVertices_Triangle+144	;	-> point18
	dc.l	currentVertices_Triangle+56	;	-> point7
	dc.l	currentVertices_Triangle+48	;	-> point6

	dc.w	27*4,0*4,-4*4
	dc.w	-14654,-25381,-14654
	dc.l	currentVertices_Triangle+56	;	-> point7
	dc.l	currentVertices_Triangle+160	;	-> point20
	dc.l	currentVertices_Triangle+64	;	-> point8

	dc.w	30*4,0*4,-7*4
	dc.w	-7739,-13404,-28881
	dc.l	currentVertices_Triangle+64	;	-> point8
	dc.l	currentVertices_Triangle+168	;	-> point21
	dc.l	currentVertices_Triangle+72	;	-> point9

	dc.w	34*4,0*4,-9*4
	dc.w	7739,13404,-28881
	dc.l	currentVertices_Triangle+72	;	-> point9
	dc.l	currentVertices_Triangle+176	;	-> point22
	dc.l	currentVertices_Triangle+80	;	-> point10

	dc.w	38*4,0*4,-7*4
	dc.w	14654,25381,-14654
	dc.l	currentVertices_Triangle+80	;	-> point10
	dc.l	currentVertices_Triangle+184	;	-> point23
	dc.l	currentVertices_Triangle+88	;	-> point11

	dc.w	-21*4,36*4,-4*4
	dc.w	16238,28126,-4351
	dc.l	currentVertices_Triangle+184	;	-> point23
	dc.l	currentVertices_Triangle+0	;	-> point0
	dc.l	currentVertices_Triangle+88	;	-> point11

	dc.w	-21*4,-37*4,0*4
	dc.w	-32477,0,4351
	dc.l	currentVertices_Triangle+192	;	-> point24
	dc.l	currentVertices_Triangle+104	;	-> point13
	dc.l	currentVertices_Triangle+96	;	-> point12

	dc.w	-21*4,-36*4,4*4
	dc.w	-29308,0,14654
	dc.l	currentVertices_Triangle+200	;	-> point25
	dc.l	currentVertices_Triangle+112	;	-> point14
	dc.l	currentVertices_Triangle+104	;	-> point13

	dc.w	-19*4,-33*4,7*4
	dc.w	-15477,0,28881
	dc.l	currentVertices_Triangle+208	;	-> point26
	dc.l	currentVertices_Triangle+120	;	-> point15
	dc.l	currentVertices_Triangle+112	;	-> point14

	dc.w	-17*4,-29*4,9*4
	dc.w	15477,0,28881
	dc.l	currentVertices_Triangle+216	;	-> point27
	dc.l	currentVertices_Triangle+128	;	-> point16
	dc.l	currentVertices_Triangle+120	;	-> point15

	dc.w	-15*4,-26*4,7*4
	dc.w	29308,0,14654
	dc.l	currentVertices_Triangle+224	;	-> point28
	dc.l	currentVertices_Triangle+136	;	-> point17
	dc.l	currentVertices_Triangle+128	;	-> point16

	dc.w	-13*4,-23*4,4*4
	dc.w	32477,0,4351
	dc.l	currentVertices_Triangle+232	;	-> point29
	dc.l	currentVertices_Triangle+144	;	-> point18
	dc.l	currentVertices_Triangle+136	;	-> point17

	dc.w	-13*4,-22*4,0*4
	dc.w	32477,0,-4351
	dc.l	currentVertices_Triangle+240	;	-> point30
	dc.l	currentVertices_Triangle+152	;	-> point19
	dc.l	currentVertices_Triangle+144	;	-> point18

	dc.w	-13*4,-23*4,-4*4
	dc.w	29308,0,-14654
	dc.l	currentVertices_Triangle+248	;	-> point31
	dc.l	currentVertices_Triangle+160	;	-> point20
	dc.l	currentVertices_Triangle+152	;	-> point19

	dc.w	-15*4,-26*4,-7*4
	dc.w	15477,0,-28881
	dc.l	currentVertices_Triangle+256	;	-> point32
	dc.l	currentVertices_Triangle+168	;	-> point21
	dc.l	currentVertices_Triangle+160	;	-> point20

	dc.w	-17*4,-29*4,-9*4
	dc.w	-15477,0,-28881
	dc.l	currentVertices_Triangle+264	;	-> point33
	dc.l	currentVertices_Triangle+176	;	-> point22
	dc.l	currentVertices_Triangle+168	;	-> point21

	dc.w	-19*4,-33*4,-7*4
	dc.w	-29308,0,-14654
	dc.l	currentVertices_Triangle+272	;	-> point34
	dc.l	currentVertices_Triangle+184	;	-> point23
	dc.l	currentVertices_Triangle+176	;	-> point22

	dc.w	-21*4,-36*4,-4*4
	dc.w	-32477,0,-4351
	dc.l	currentVertices_Triangle+280	;	-> point35
	dc.l	currentVertices_Triangle+96	;	-> point12
	dc.l	currentVertices_Triangle+184	;	-> point23

	dc.w	43*4,0*4,0*4
	dc.w	16238,-28126,4351
	dc.l	currentVertices_Triangle+0	;	-> point0
	dc.l	currentVertices_Triangle+200	;	-> point25
	dc.l	currentVertices_Triangle+192	;	-> point24

	dc.w	-21*4,-36*4,4*4
	dc.w	14654,-25381,14654
	dc.l	currentVertices_Triangle+200	;	-> point25
	dc.l	currentVertices_Triangle+16	;	-> point2
	dc.l	currentVertices_Triangle+208	;	-> point26

	dc.w	-19*4,-33*4,7*4
	dc.w	7739,-13404,28881
	dc.l	currentVertices_Triangle+208	;	-> point26
	dc.l	currentVertices_Triangle+24	;	-> point3
	dc.l	currentVertices_Triangle+216	;	-> point27

	dc.w	-17*4,-29*4,9*4
	dc.w	-7739,13404,28881
	dc.l	currentVertices_Triangle+216	;	-> point27
	dc.l	currentVertices_Triangle+32	;	-> point4
	dc.l	currentVertices_Triangle+224	;	-> point28

	dc.w	-15*4,-26*4,7*4
	dc.w	-14654,25381,14654
	dc.l	currentVertices_Triangle+224	;	-> point28
	dc.l	currentVertices_Triangle+40	;	-> point5
	dc.l	currentVertices_Triangle+232	;	-> point29

	dc.w	27*4,0*4,4*4
	dc.w	-16238,28126,4351
	dc.l	currentVertices_Triangle+40	;	-> point5
	dc.l	currentVertices_Triangle+240	;	-> point30
	dc.l	currentVertices_Triangle+232	;	-> point29

	dc.w	-13*4,-22*4,0*4
	dc.w	-16238,28126,-4351
	dc.l	currentVertices_Triangle+240	;	-> point30
	dc.l	currentVertices_Triangle+56	;	-> point7
	dc.l	currentVertices_Triangle+248	;	-> point31

	dc.w	27*4,0*4,-4*4
	dc.w	-14654,25381,-14654
	dc.l	currentVertices_Triangle+56	;	-> point7
	dc.l	currentVertices_Triangle+256	;	-> point32
	dc.l	currentVertices_Triangle+248	;	-> point31

	dc.w	30*4,0*4,-7*4
	dc.w	-7739,13404,-28881
	dc.l	currentVertices_Triangle+64	;	-> point8
	dc.l	currentVertices_Triangle+264	;	-> point33
	dc.l	currentVertices_Triangle+256	;	-> point32

	dc.w	34*4,0*4,-9*4
	dc.w	7739,-13404,-28881
	dc.l	currentVertices_Triangle+72	;	-> point9
	dc.l	currentVertices_Triangle+272	;	-> point34
	dc.l	currentVertices_Triangle+264	;	-> point33

	dc.w	38*4,0*4,-7*4
	dc.w	14654,-25381,-14654
	dc.l	currentVertices_Triangle+80	;	-> point10
	dc.l	currentVertices_Triangle+280	;	-> point35
	dc.l	currentVertices_Triangle+272	;	-> point34

	dc.w	-21*4,-36*4,-4*4
	dc.w	16238,-28126,-4351
	dc.l	currentVertices_Triangle+280	;	-> point35
	dc.l	currentVertices_Triangle+0	;	-> point0
	dc.l	currentVertices_Triangle+192	;	-> point24

	dc.w	43*4,0*4,0*4
	dc.w	16238,28126,4351
	dc.l	currentVertices_Triangle+0	;	-> point0
	dc.l	currentVertices_Triangle+96	;	-> point12
	dc.l	currentVertices_Triangle+104	;	-> point13

	dc.w	-21*4,36*4,4*4
	dc.w	14654,25381,14654
	dc.l	currentVertices_Triangle+104	;	-> point13
	dc.l	currentVertices_Triangle+112	;	-> point14
	dc.l	currentVertices_Triangle+16	;	-> point2

	dc.w	-19*4,33*4,7*4
	dc.w	7739,13404,28881
	dc.l	currentVertices_Triangle+112	;	-> point14
	dc.l	currentVertices_Triangle+120	;	-> point15
	dc.l	currentVertices_Triangle+24	;	-> point3

	dc.w	-17*4,29*4,9*4
	dc.w	-7739,-13404,28881
	dc.l	currentVertices_Triangle+120	;	-> point15
	dc.l	currentVertices_Triangle+128	;	-> point16
	dc.l	currentVertices_Triangle+32	;	-> point4

	dc.w	-15*4,26*4,7*4
	dc.w	-14654,-25381,14654
	dc.l	currentVertices_Triangle+128	;	-> point16
	dc.l	currentVertices_Triangle+136	;	-> point17
	dc.l	currentVertices_Triangle+40	;	-> point5

	dc.w	27*4,0*4,4*4
	dc.w	-16238,-28126,4351
	dc.l	currentVertices_Triangle+40	;	-> point5
	dc.l	currentVertices_Triangle+136	;	-> point17
	dc.l	currentVertices_Triangle+144	;	-> point18

	dc.w	-13*4,22*4,0*4
	dc.w	-16238,-28126,-4351
	dc.l	currentVertices_Triangle+144	;	-> point18
	dc.l	currentVertices_Triangle+152	;	-> point19
	dc.l	currentVertices_Triangle+56	;	-> point7

	dc.w	27*4,0*4,-4*4
	dc.w	-14654,-25381,-14654
	dc.l	currentVertices_Triangle+56	;	-> point7
	dc.l	currentVertices_Triangle+152	;	-> point19
	dc.l	currentVertices_Triangle+160	;	-> point20

	dc.w	30*4,0*4,-7*4
	dc.w	-7739,-13404,-28881
	dc.l	currentVertices_Triangle+64	;	-> point8
	dc.l	currentVertices_Triangle+160	;	-> point20
	dc.l	currentVertices_Triangle+168	;	-> point21

	dc.w	34*4,0*4,-9*4
	dc.w	7739,13404,-28881
	dc.l	currentVertices_Triangle+72	;	-> point9
	dc.l	currentVertices_Triangle+168	;	-> point21
	dc.l	currentVertices_Triangle+176	;	-> point22

	dc.w	38*4,0*4,-7*4
	dc.w	14654,25381,-14654
	dc.l	currentVertices_Triangle+80	;	-> point10
	dc.l	currentVertices_Triangle+176	;	-> point22
	dc.l	currentVertices_Triangle+184	;	-> point23

	dc.w	-21*4,36*4,-4*4
	dc.w	16238,28126,-4351
	dc.l	currentVertices_Triangle+184	;	-> point23
	dc.l	currentVertices_Triangle+96	;	-> point12
	dc.l	currentVertices_Triangle+0	;	-> point0

	dc.w	-21*4,-37*4,0*4
	dc.w	-32477,0,4351
	dc.l	currentVertices_Triangle+192	;	-> point24
	dc.l	currentVertices_Triangle+200	;	-> point25
	dc.l	currentVertices_Triangle+104	;	-> point13

	dc.w	-21*4,-36*4,4*4
	dc.w	-29308,0,14654
	dc.l	currentVertices_Triangle+200	;	-> point25
	dc.l	currentVertices_Triangle+208	;	-> point26
	dc.l	currentVertices_Triangle+112	;	-> point14

	dc.w	-19*4,-33*4,7*4
	dc.w	-15477,0,28881
	dc.l	currentVertices_Triangle+208	;	-> point26
	dc.l	currentVertices_Triangle+216	;	-> point27
	dc.l	currentVertices_Triangle+120	;	-> point15

	dc.w	-17*4,-29*4,9*4
	dc.w	15477,0,28881
	dc.l	currentVertices_Triangle+216	;	-> point27
	dc.l	currentVertices_Triangle+224	;	-> point28
	dc.l	currentVertices_Triangle+128	;	-> point16

	dc.w	-15*4,-26*4,7*4
	dc.w	29308,0,14654
	dc.l	currentVertices_Triangle+224	;	-> point28
	dc.l	currentVertices_Triangle+232	;	-> point29
	dc.l	currentVertices_Triangle+136	;	-> point17

	dc.w	-13*4,-23*4,4*4
	dc.w	32477,0,4351
	dc.l	currentVertices_Triangle+232	;	-> point29
	dc.l	currentVertices_Triangle+240	;	-> point30
	dc.l	currentVertices_Triangle+144	;	-> point18

	dc.w	-13*4,-22*4,0*4
	dc.w	32477,0,-4351
	dc.l	currentVertices_Triangle+240	;	-> point30
	dc.l	currentVertices_Triangle+248	;	-> point31
	dc.l	currentVertices_Triangle+152	;	-> point19

	dc.w	-13*4,-23*4,-4*4
	dc.w	29308,0,-14654
	dc.l	currentVertices_Triangle+248	;	-> point31
	dc.l	currentVertices_Triangle+256	;	-> point32
	dc.l	currentVertices_Triangle+160	;	-> point20

	dc.w	-15*4,-26*4,-7*4
	dc.w	15477,0,-28881
	dc.l	currentVertices_Triangle+256	;	-> point32
	dc.l	currentVertices_Triangle+264	;	-> point33
	dc.l	currentVertices_Triangle+168	;	-> point21

	dc.w	-17*4,-29*4,-9*4
	dc.w	-15477,0,-28881
	dc.l	currentVertices_Triangle+264	;	-> point33
	dc.l	currentVertices_Triangle+272	;	-> point34
	dc.l	currentVertices_Triangle+176	;	-> point22

	dc.w	-19*4,-33*4,-7*4
	dc.w	-29308,0,-14654
	dc.l	currentVertices_Triangle+272	;	-> point34
	dc.l	currentVertices_Triangle+280	;	-> point35
	dc.l	currentVertices_Triangle+184	;	-> point23

	dc.w	-21*4,-36*4,-4*4
	dc.w	-32477,0,-4351
	dc.l	currentVertices_Triangle+280	;	-> point35
	dc.l	currentVertices_Triangle+192	;	-> point24
	dc.l	currentVertices_Triangle+96	;	-> point12

	dc.w	43*4,0*4,0*4
	dc.w	16238,-28126,4351
	dc.l	currentVertices_Triangle+0	;	-> point0
	dc.l	currentVertices_Triangle+8	;	-> point1
	dc.l	currentVertices_Triangle+200	;	-> point25

	dc.w	-21*4,-36*4,4*4
	dc.w	14654,-25381,14654
	dc.l	currentVertices_Triangle+200	;	-> point25
	dc.l	currentVertices_Triangle+8	;	-> point1
	dc.l	currentVertices_Triangle+16	;	-> point2

	dc.w	-19*4,-33*4,7*4
	dc.w	7739,-13404,28881
	dc.l	currentVertices_Triangle+208	;	-> point26
	dc.l	currentVertices_Triangle+16	;	-> point2
	dc.l	currentVertices_Triangle+24	;	-> point3

	dc.w	-17*4,-29*4,9*4
	dc.w	-7739,13404,28881
	dc.l	currentVertices_Triangle+216	;	-> point27
	dc.l	currentVertices_Triangle+24	;	-> point3
	dc.l	currentVertices_Triangle+32	;	-> point4

	dc.w	-15*4,-26*4,7*4
	dc.w	-14654,25381,14654
	dc.l	currentVertices_Triangle+224	;	-> point28
	dc.l	currentVertices_Triangle+32	;	-> point4
	dc.l	currentVertices_Triangle+40	;	-> point5

	dc.w	27*4,0*4,4*4
	dc.w	-16238,28126,4351
	dc.l	currentVertices_Triangle+40	;	-> point5
	dc.l	currentVertices_Triangle+48	;	-> point6
	dc.l	currentVertices_Triangle+240	;	-> point30

	dc.w	-13*4,-22*4,0*4
	dc.w	-16238,28126,-4351
	dc.l	currentVertices_Triangle+240	;	-> point30
	dc.l	currentVertices_Triangle+48	;	-> point6
	dc.l	currentVertices_Triangle+56	;	-> point7

	dc.w	27*4,0*4,-4*4
	dc.w	-14654,25381,-14654
	dc.l	currentVertices_Triangle+56	;	-> point7
	dc.l	currentVertices_Triangle+64	;	-> point8
	dc.l	currentVertices_Triangle+256	;	-> point32

	dc.w	30*4,0*4,-7*4
	dc.w	-7739,13404,-28881
	dc.l	currentVertices_Triangle+64	;	-> point8
	dc.l	currentVertices_Triangle+72	;	-> point9
	dc.l	currentVertices_Triangle+264	;	-> point33

	dc.w	34*4,0*4,-9*4
	dc.w	7739,-13404,-28881
	dc.l	currentVertices_Triangle+72	;	-> point9
	dc.l	currentVertices_Triangle+80	;	-> point10
	dc.l	currentVertices_Triangle+272	;	-> point34

	dc.w	38*4,0*4,-7*4
	dc.w	14654,-25381,-14654
	dc.l	currentVertices_Triangle+80	;	-> point10
	dc.l	currentVertices_Triangle+88	;	-> point11
	dc.l	currentVertices_Triangle+280	;	-> point35

	dc.w	-21*4,-36*4,-4*4
	dc.w	16238,-28126,-4351
	dc.l	currentVertices_Triangle+280	;	-> point35
	dc.l	currentVertices_Triangle+88	;	-> point11
	dc.l	currentVertices_Triangle+0	;	-> point0

sourceFaces_Triangle_end
; destination faces
;	format:
;	- visibility (dc.w)
;	- pointers to destination points: (dc.l) * 3
destFaces_Triangle
	dc.w	0
	dc.l	point_Triangle0
	dc.l	point_Triangle13
	dc.l	point_Triangle1
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle13
	dc.l	point_Triangle2
	dc.l	point_Triangle1
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle14
	dc.l	point_Triangle3
	dc.l	point_Triangle2
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle15
	dc.l	point_Triangle4
	dc.l	point_Triangle3
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle16
	dc.l	point_Triangle5
	dc.l	point_Triangle4
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle5
	dc.l	point_Triangle18
	dc.l	point_Triangle6
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle18
	dc.l	point_Triangle7
	dc.l	point_Triangle6
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle7
	dc.l	point_Triangle20
	dc.l	point_Triangle8
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle8
	dc.l	point_Triangle21
	dc.l	point_Triangle9
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle9
	dc.l	point_Triangle22
	dc.l	point_Triangle10
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle10
	dc.l	point_Triangle23
	dc.l	point_Triangle11
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle23
	dc.l	point_Triangle0
	dc.l	point_Triangle11
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle24
	dc.l	point_Triangle13
	dc.l	point_Triangle12
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle25
	dc.l	point_Triangle14
	dc.l	point_Triangle13
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle26
	dc.l	point_Triangle15
	dc.l	point_Triangle14
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle27
	dc.l	point_Triangle16
	dc.l	point_Triangle15
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle28
	dc.l	point_Triangle17
	dc.l	point_Triangle16
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle29
	dc.l	point_Triangle18
	dc.l	point_Triangle17
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle30
	dc.l	point_Triangle19
	dc.l	point_Triangle18
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle31
	dc.l	point_Triangle20
	dc.l	point_Triangle19
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle32
	dc.l	point_Triangle21
	dc.l	point_Triangle20
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle33
	dc.l	point_Triangle22
	dc.l	point_Triangle21
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle34
	dc.l	point_Triangle23
	dc.l	point_Triangle22
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle35
	dc.l	point_Triangle12
	dc.l	point_Triangle23
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle0
	dc.l	point_Triangle25
	dc.l	point_Triangle24
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle25
	dc.l	point_Triangle2
	dc.l	point_Triangle26
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle26
	dc.l	point_Triangle3
	dc.l	point_Triangle27
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle27
	dc.l	point_Triangle4
	dc.l	point_Triangle28
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle28
	dc.l	point_Triangle5
	dc.l	point_Triangle29
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle5
	dc.l	point_Triangle30
	dc.l	point_Triangle29
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle30
	dc.l	point_Triangle7
	dc.l	point_Triangle31
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle7
	dc.l	point_Triangle32
	dc.l	point_Triangle31
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle8
	dc.l	point_Triangle33
	dc.l	point_Triangle32
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle9
	dc.l	point_Triangle34
	dc.l	point_Triangle33
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle10
	dc.l	point_Triangle35
	dc.l	point_Triangle34
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle35
	dc.l	point_Triangle0
	dc.l	point_Triangle24
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle0
	dc.l	point_Triangle12
	dc.l	point_Triangle13
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle13
	dc.l	point_Triangle14
	dc.l	point_Triangle2
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle14
	dc.l	point_Triangle15
	dc.l	point_Triangle3
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle15
	dc.l	point_Triangle16
	dc.l	point_Triangle4
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle16
	dc.l	point_Triangle17
	dc.l	point_Triangle5
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle5
	dc.l	point_Triangle17
	dc.l	point_Triangle18
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle18
	dc.l	point_Triangle19
	dc.l	point_Triangle7
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle7
	dc.l	point_Triangle19
	dc.l	point_Triangle20
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle8
	dc.l	point_Triangle20
	dc.l	point_Triangle21
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle9
	dc.l	point_Triangle21
	dc.l	point_Triangle22
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle10
	dc.l	point_Triangle22
	dc.l	point_Triangle23
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle23
	dc.l	point_Triangle12
	dc.l	point_Triangle0
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle24
	dc.l	point_Triangle25
	dc.l	point_Triangle13
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle25
	dc.l	point_Triangle26
	dc.l	point_Triangle14
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle26
	dc.l	point_Triangle27
	dc.l	point_Triangle15
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle27
	dc.l	point_Triangle28
	dc.l	point_Triangle16
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle28
	dc.l	point_Triangle29
	dc.l	point_Triangle17
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle29
	dc.l	point_Triangle30
	dc.l	point_Triangle18
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle30
	dc.l	point_Triangle31
	dc.l	point_Triangle19
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle31
	dc.l	point_Triangle32
	dc.l	point_Triangle20
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle32
	dc.l	point_Triangle33
	dc.l	point_Triangle21
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle33
	dc.l	point_Triangle34
	dc.l	point_Triangle22
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle34
	dc.l	point_Triangle35
	dc.l	point_Triangle23
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle35
	dc.l	point_Triangle24
	dc.l	point_Triangle12
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle0
	dc.l	point_Triangle1
	dc.l	point_Triangle25
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle25
	dc.l	point_Triangle1
	dc.l	point_Triangle2
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle26
	dc.l	point_Triangle2
	dc.l	point_Triangle3
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle27
	dc.l	point_Triangle3
	dc.l	point_Triangle4
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle28
	dc.l	point_Triangle4
	dc.l	point_Triangle5
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle5
	dc.l	point_Triangle6
	dc.l	point_Triangle30
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle30
	dc.l	point_Triangle6
	dc.l	point_Triangle7
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle7
	dc.l	point_Triangle8
	dc.l	point_Triangle32
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle8
	dc.l	point_Triangle9
	dc.l	point_Triangle33
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle9
	dc.l	point_Triangle10
	dc.l	point_Triangle34
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle10
	dc.l	point_Triangle11
	dc.l	point_Triangle35
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Triangle35
	dc.l	point_Triangle11
	dc.l	point_Triangle0
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

destFaces_Triangle_end



init_Triangle
	move.w	number_of_faces_Triangle,current_number_of_faces
	move.w	number_of_vertices_Triangle,current_number_of_vertices
	lea	currentVertices_Triangle,a0
	move.l	a0,a5
	move.l	currentVerticesPointer,a1
	move.l	a1,a4					; save this address for later use, target base
	move.l	#currentVertices_Triangle_end,d7
	sub.l	a0,d7						; number of bytes
	lsr.w	#3,d7
	subq.w	#1,d7
.cpv
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	dbra	d7,.cpv


	lea		currentNormals_Triangle,a0
	move.l	currentNormalsPointer,a1
	move.l	#currentNormals_Triangle_end,d7
	sub.l	a0,d7
	lsr.w	d7
	subq.w	#1,d7
.cpn	
		move.w	(a0)+,(a1)+
	dbra	d7,.cpn


	lea		points_Triangle,a0
	move.l	a0,a6					; save this address for later use
	move.l	currentPointsPointer,a1
	move.l	a1,a3					; target base
	move.l	#points_Triangle_end,d7
	sub.l	a0,d7
	lsr.w	d7
	subq.w	#1,d7
.cpp
		move.w	(a0)+,(a1)+
	dbra	d7,.cpp


	lea		sourceFaces_Triangle,a0				;3*2 + 3*2 + 3*4 = 6 * 4 = 24
	move.l	currentSourceFacesPointer,a1
	move.l	#sourceFaces_Triangle_end,d7
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


	lea		destFaces_Triangle,a0
	move.l	currentDestFacesPointer,a1
	move.l	#destFaces_Triangle_end,d7
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
