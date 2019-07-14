; PARSE PARAMETERS: `php parseObject.php torus7.blend.json.txt 0` and size: 30
; OBJ NAME: Torus
number_of_faces_Torus		dc.w		72
number_of_vertices_Torus		dc.w		36
; source vertices data:
;	format (dc.w): visible,x,y,z
currentVertices_Torus
	dc.w	0,39*4,0*4,0*4		;	0
	dc.w	0,34*4,0*4,8*4		;	8
	dc.w	0,26*4,0*4,8*4		;	16
	dc.w	0,21*4,0*4,0*4		;	24
	dc.w	0,25*4,0*4,-8*4		;	32
	dc.w	0,34*4,0*4,-8*4		;	40
	dc.w	0,19*4,34*4,0*4		;	48
	dc.w	0,17*4,30*4,8*4		;	56
	dc.w	0,13*4,22*4,8*4		;	64
	dc.w	0,10*4,18*4,0*4		;	72
	dc.w	0,13*4,22*4,-8*4		;	80
	dc.w	0,17*4,30*4,-8*4		;	88
	dc.w	0,-19*4,34*4,0*4		;	96
	dc.w	0,-17*4,30*4,8*4		;	104
	dc.w	0,-13*4,22*4,8*4		;	112
	dc.w	0,-10*4,18*4,0*4		;	120
	dc.w	0,-13*4,22*4,-8*4		;	128
	dc.w	0,-17*4,30*4,-8*4		;	136
	dc.w	0,-39*4,0*4,0*4		;	144
	dc.w	0,-34*4,0*4,8*4		;	152
	dc.w	0,-26*4,0*4,8*4		;	160
	dc.w	0,-21*4,0*4,0*4		;	168
	dc.w	0,-25*4,0*4,-8*4		;	176
	dc.w	0,-34*4,0*4,-8*4		;	184
	dc.w	0,-19*4,-34*4,0*4		;	192
	dc.w	0,-17*4,-30*4,8*4		;	200
	dc.w	0,-13*4,-22*4,8*4		;	208
	dc.w	0,-10*4,-18*4,0*4		;	216
	dc.w	0,-13*4,-22*4,-8*4		;	224
	dc.w	0,-17*4,-30*4,-8*4		;	232
	dc.w	0,19*4,-34*4,0*4		;	240
	dc.w	0,17*4,-30*4,8*4		;	248
	dc.w	0,13*4,-22*4,8*4		;	256
	dc.w	0,10*4,-18*4,0*4		;	264
	dc.w	0,13*4,-22*4,-8*4		;	272
	dc.w	0,17*4,-30*4,-8*4		;	280
currentVertices_Torus_end
; source normals for vertices data:
;	format (dc.w): x,y,z
currentNormals_Torus
	dc.w	25381,14654,14654
	dc.w	0,0,32767
	dc.w	-25381,-14654,14654
	dc.w	-25381,-14654,-14654
	dc.w	0,0,-32767
	dc.w	25381,14654,-14654
	dc.w	0,29308,14654
	dc.w	0,0,32767
	dc.w	-0,-29308,14654
	dc.w	-0,-29308,-14654
	dc.w	0,0,-32767
	dc.w	0,29308,-14654
	dc.w	-25381,14654,14654
	dc.w	0,0,32767
	dc.w	25381,-14654,14654
	dc.w	25381,-14654,-14654
	dc.w	0,0,-32767
	dc.w	-25381,14654,-14654
	dc.w	-25381,-14654,14654
	dc.w	0,0,32767
	dc.w	25381,14654,14654
	dc.w	25381,14654,-14654
	dc.w	0,0,-32767
	dc.w	-25381,-14654,-14654
	dc.w	0,-29308,14654
	dc.w	0,0,32767
	dc.w	-0,29308,14654
	dc.w	-0,29308,-14654
	dc.w	0,0,-32767
	dc.w	0,-29308,-14654
	dc.w	25381,-14654,14654
	dc.w	0,0,32767
	dc.w	-25381,14654,14654
	dc.w	-25381,14654,-14654
	dc.w	0,0,-32767
	dc.w	25381,-14654,-14654
	dc.w	25381,14654,14654
	dc.w	0,0,32767
	dc.w	-25381,-14654,14654
	dc.w	-25381,-14654,-14654
	dc.w	0,0,-32767
	dc.w	25381,14654,-14654
	dc.w	0,29308,14654
	dc.w	0,0,32767
	dc.w	-0,-29308,14654
	dc.w	-0,-29308,-14654
	dc.w	0,0,-32767
	dc.w	0,29308,-14654
	dc.w	-25381,14654,14654
	dc.w	0,0,32767
	dc.w	25381,-14654,14654
	dc.w	25381,-14654,-14654
	dc.w	0,0,-32767
	dc.w	-25381,14654,-14654
	dc.w	-25381,-14654,14654
	dc.w	0,0,32767
	dc.w	25381,14654,14654
	dc.w	25381,14654,-14654
	dc.w	0,0,-32767
	dc.w	-25381,-14654,-14654
	dc.w	0,-29308,14654
	dc.w	0,0,32767
	dc.w	-0,29308,14654
	dc.w	-0,29308,-14654
	dc.w	0,0,-32767
	dc.w	0,-29308,-14654
	dc.w	25381,-14654,14654
	dc.w	0,0,32767
	dc.w	-25381,14654,14654
	dc.w	-25381,14654,-14654
	dc.w	0,0,-32767
	dc.w	25381,-14654,-14654
currentNormals_Torus_end
; points definitions, basically Projected Vertices and their UV
;	format: (dc.w): x_projected,y_projected,u,v
points_Torus
point_Torus0		dc.w	0,0,0,0,0
point_Torus1		dc.w	0,0,0,0,0
point_Torus2		dc.w	0,0,0,0,0
point_Torus3		dc.w	0,0,0,0,0
point_Torus4		dc.w	0,0,0,0,0
point_Torus5		dc.w	0,0,0,0,0
point_Torus6		dc.w	0,0,0,0,0
point_Torus7		dc.w	0,0,0,0,0
point_Torus8		dc.w	0,0,0,0,0
point_Torus9		dc.w	0,0,0,0,0
point_Torus10		dc.w	0,0,0,0,0
point_Torus11		dc.w	0,0,0,0,0
point_Torus12		dc.w	0,0,0,0,0
point_Torus13		dc.w	0,0,0,0,0
point_Torus14		dc.w	0,0,0,0,0
point_Torus15		dc.w	0,0,0,0,0
point_Torus16		dc.w	0,0,0,0,0
point_Torus17		dc.w	0,0,0,0,0
point_Torus18		dc.w	0,0,0,0,0
point_Torus19		dc.w	0,0,0,0,0
point_Torus20		dc.w	0,0,0,0,0
point_Torus21		dc.w	0,0,0,0,0
point_Torus22		dc.w	0,0,0,0,0
point_Torus23		dc.w	0,0,0,0,0
point_Torus24		dc.w	0,0,0,0,0
point_Torus25		dc.w	0,0,0,0,0
point_Torus26		dc.w	0,0,0,0,0
point_Torus27		dc.w	0,0,0,0,0
point_Torus28		dc.w	0,0,0,0,0
point_Torus29		dc.w	0,0,0,0,0
point_Torus30		dc.w	0,0,0,0,0
point_Torus31		dc.w	0,0,0,0,0
point_Torus32		dc.w	0,0,0,0,0
point_Torus33		dc.w	0,0,0,0,0
point_Torus34		dc.w	0,0,0,0,0
point_Torus35		dc.w	0,0,0,0,0
points_Torus_end
; source faces structure
;	format:
;	- vertex of face, for culling (dc.w): x,y,z
;	- normal value of face, for culling (dc.w): x,y,z
;	- pointers source vertices for visibility marking: (dc.l): ptr1,ptr2,ptr3
sourceFaces_Torus
	dc.w	19*4,34*4,0*4
	dc.w	25381,14654,14654
	dc.l	currentVertices_Torus+48	;	-> point6
	dc.l	currentVertices_Torus+8	;	-> point1
	dc.l	currentVertices_Torus+0	;	-> point0

	dc.w	17*4,30*4,8*4
	dc.w	0,0,32767
	dc.l	currentVertices_Torus+56	;	-> point7
	dc.l	currentVertices_Torus+16	;	-> point2
	dc.l	currentVertices_Torus+8	;	-> point1

	dc.w	13*4,22*4,8*4
	dc.w	-25381,-14654,14654
	dc.l	currentVertices_Torus+64	;	-> point8
	dc.l	currentVertices_Torus+24	;	-> point3
	dc.l	currentVertices_Torus+16	;	-> point2

	dc.w	21*4,0*4,0*4
	dc.w	-25381,-14654,-14654
	dc.l	currentVertices_Torus+24	;	-> point3
	dc.l	currentVertices_Torus+80	;	-> point10
	dc.l	currentVertices_Torus+32	;	-> point4

	dc.w	13*4,22*4,-8*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Torus+80	;	-> point10
	dc.l	currentVertices_Torus+40	;	-> point5
	dc.l	currentVertices_Torus+32	;	-> point4

	dc.w	17*4,30*4,-8*4
	dc.w	25381,14654,-14654
	dc.l	currentVertices_Torus+88	;	-> point11
	dc.l	currentVertices_Torus+0	;	-> point0
	dc.l	currentVertices_Torus+40	;	-> point5

	dc.w	-19*4,34*4,0*4
	dc.w	0,29308,14654
	dc.l	currentVertices_Torus+96	;	-> point12
	dc.l	currentVertices_Torus+56	;	-> point7
	dc.l	currentVertices_Torus+48	;	-> point6

	dc.w	-17*4,30*4,8*4
	dc.w	0,0,32767
	dc.l	currentVertices_Torus+104	;	-> point13
	dc.l	currentVertices_Torus+64	;	-> point8
	dc.l	currentVertices_Torus+56	;	-> point7

	dc.w	13*4,22*4,8*4
	dc.w	-0,-29308,14654
	dc.l	currentVertices_Torus+64	;	-> point8
	dc.l	currentVertices_Torus+120	;	-> point15
	dc.l	currentVertices_Torus+72	;	-> point9

	dc.w	-10*4,18*4,0*4
	dc.w	-0,-29308,-14654
	dc.l	currentVertices_Torus+120	;	-> point15
	dc.l	currentVertices_Torus+80	;	-> point10
	dc.l	currentVertices_Torus+72	;	-> point9

	dc.w	-13*4,22*4,-8*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Torus+128	;	-> point16
	dc.l	currentVertices_Torus+88	;	-> point11
	dc.l	currentVertices_Torus+80	;	-> point10

	dc.w	-17*4,30*4,-8*4
	dc.w	0,29308,-14654
	dc.l	currentVertices_Torus+136	;	-> point17
	dc.l	currentVertices_Torus+48	;	-> point6
	dc.l	currentVertices_Torus+88	;	-> point11

	dc.w	-39*4,0*4,0*4
	dc.w	-25381,14654,14654
	dc.l	currentVertices_Torus+144	;	-> point18
	dc.l	currentVertices_Torus+104	;	-> point13
	dc.l	currentVertices_Torus+96	;	-> point12

	dc.w	-34*4,0*4,8*4
	dc.w	0,0,32767
	dc.l	currentVertices_Torus+152	;	-> point19
	dc.l	currentVertices_Torus+112	;	-> point14
	dc.l	currentVertices_Torus+104	;	-> point13

	dc.w	-13*4,22*4,8*4
	dc.w	25381,-14654,14654
	dc.l	currentVertices_Torus+112	;	-> point14
	dc.l	currentVertices_Torus+168	;	-> point21
	dc.l	currentVertices_Torus+120	;	-> point15

	dc.w	-21*4,0*4,0*4
	dc.w	25381,-14654,-14654
	dc.l	currentVertices_Torus+168	;	-> point21
	dc.l	currentVertices_Torus+128	;	-> point16
	dc.l	currentVertices_Torus+120	;	-> point15

	dc.w	-25*4,0*4,-8*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Torus+176	;	-> point22
	dc.l	currentVertices_Torus+136	;	-> point17
	dc.l	currentVertices_Torus+128	;	-> point16

	dc.w	-34*4,0*4,-8*4
	dc.w	-25381,14654,-14654
	dc.l	currentVertices_Torus+184	;	-> point23
	dc.l	currentVertices_Torus+96	;	-> point12
	dc.l	currentVertices_Torus+136	;	-> point17

	dc.w	-19*4,-34*4,0*4
	dc.w	-25381,-14654,14654
	dc.l	currentVertices_Torus+192	;	-> point24
	dc.l	currentVertices_Torus+152	;	-> point19
	dc.l	currentVertices_Torus+144	;	-> point18

	dc.w	-17*4,-30*4,8*4
	dc.w	0,0,32767
	dc.l	currentVertices_Torus+200	;	-> point25
	dc.l	currentVertices_Torus+160	;	-> point20
	dc.l	currentVertices_Torus+152	;	-> point19

	dc.w	-13*4,-22*4,8*4
	dc.w	25381,14654,14654
	dc.l	currentVertices_Torus+208	;	-> point26
	dc.l	currentVertices_Torus+168	;	-> point21
	dc.l	currentVertices_Torus+160	;	-> point20

	dc.w	-10*4,-18*4,0*4
	dc.w	25381,14654,-14654
	dc.l	currentVertices_Torus+216	;	-> point27
	dc.l	currentVertices_Torus+176	;	-> point22
	dc.l	currentVertices_Torus+168	;	-> point21

	dc.w	-25*4,0*4,-8*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Torus+176	;	-> point22
	dc.l	currentVertices_Torus+232	;	-> point29
	dc.l	currentVertices_Torus+184	;	-> point23

	dc.w	-17*4,-30*4,-8*4
	dc.w	-25381,-14654,-14654
	dc.l	currentVertices_Torus+232	;	-> point29
	dc.l	currentVertices_Torus+144	;	-> point18
	dc.l	currentVertices_Torus+184	;	-> point23

	dc.w	19*4,-34*4,0*4
	dc.w	0,-29308,14654
	dc.l	currentVertices_Torus+240	;	-> point30
	dc.l	currentVertices_Torus+200	;	-> point25
	dc.l	currentVertices_Torus+192	;	-> point24

	dc.w	-17*4,-30*4,8*4
	dc.w	0,0,32767
	dc.l	currentVertices_Torus+200	;	-> point25
	dc.l	currentVertices_Torus+256	;	-> point32
	dc.l	currentVertices_Torus+208	;	-> point26

	dc.w	13*4,-22*4,8*4
	dc.w	-0,29308,14654
	dc.l	currentVertices_Torus+256	;	-> point32
	dc.l	currentVertices_Torus+216	;	-> point27
	dc.l	currentVertices_Torus+208	;	-> point26

	dc.w	-10*4,-18*4,0*4
	dc.w	-0,29308,-14654
	dc.l	currentVertices_Torus+216	;	-> point27
	dc.l	currentVertices_Torus+272	;	-> point34
	dc.l	currentVertices_Torus+224	;	-> point28

	dc.w	13*4,-22*4,-8*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Torus+272	;	-> point34
	dc.l	currentVertices_Torus+232	;	-> point29
	dc.l	currentVertices_Torus+224	;	-> point28

	dc.w	17*4,-30*4,-8*4
	dc.w	0,-29308,-14654
	dc.l	currentVertices_Torus+280	;	-> point35
	dc.l	currentVertices_Torus+192	;	-> point24
	dc.l	currentVertices_Torus+232	;	-> point29

	dc.w	39*4,0*4,0*4
	dc.w	25381,-14654,14654
	dc.l	currentVertices_Torus+0	;	-> point0
	dc.l	currentVertices_Torus+248	;	-> point31
	dc.l	currentVertices_Torus+240	;	-> point30

	dc.w	34*4,0*4,8*4
	dc.w	0,0,32767
	dc.l	currentVertices_Torus+8	;	-> point1
	dc.l	currentVertices_Torus+256	;	-> point32
	dc.l	currentVertices_Torus+248	;	-> point31

	dc.w	26*4,0*4,8*4
	dc.w	-25381,14654,14654
	dc.l	currentVertices_Torus+16	;	-> point2
	dc.l	currentVertices_Torus+264	;	-> point33
	dc.l	currentVertices_Torus+256	;	-> point32

	dc.w	21*4,0*4,0*4
	dc.w	-25381,14654,-14654
	dc.l	currentVertices_Torus+24	;	-> point3
	dc.l	currentVertices_Torus+272	;	-> point34
	dc.l	currentVertices_Torus+264	;	-> point33

	dc.w	25*4,0*4,-8*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Torus+32	;	-> point4
	dc.l	currentVertices_Torus+280	;	-> point35
	dc.l	currentVertices_Torus+272	;	-> point34

	dc.w	34*4,0*4,-8*4
	dc.w	25381,-14654,-14654
	dc.l	currentVertices_Torus+40	;	-> point5
	dc.l	currentVertices_Torus+240	;	-> point30
	dc.l	currentVertices_Torus+280	;	-> point35

	dc.w	19*4,34*4,0*4
	dc.w	25381,14654,14654
	dc.l	currentVertices_Torus+48	;	-> point6
	dc.l	currentVertices_Torus+56	;	-> point7
	dc.l	currentVertices_Torus+8	;	-> point1

	dc.w	17*4,30*4,8*4
	dc.w	0,0,32767
	dc.l	currentVertices_Torus+56	;	-> point7
	dc.l	currentVertices_Torus+64	;	-> point8
	dc.l	currentVertices_Torus+16	;	-> point2

	dc.w	13*4,22*4,8*4
	dc.w	-25381,-14654,14654
	dc.l	currentVertices_Torus+64	;	-> point8
	dc.l	currentVertices_Torus+72	;	-> point9
	dc.l	currentVertices_Torus+24	;	-> point3

	dc.w	21*4,0*4,0*4
	dc.w	-25381,-14654,-14654
	dc.l	currentVertices_Torus+24	;	-> point3
	dc.l	currentVertices_Torus+72	;	-> point9
	dc.l	currentVertices_Torus+80	;	-> point10

	dc.w	13*4,22*4,-8*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Torus+80	;	-> point10
	dc.l	currentVertices_Torus+88	;	-> point11
	dc.l	currentVertices_Torus+40	;	-> point5

	dc.w	17*4,30*4,-8*4
	dc.w	25381,14654,-14654
	dc.l	currentVertices_Torus+88	;	-> point11
	dc.l	currentVertices_Torus+48	;	-> point6
	dc.l	currentVertices_Torus+0	;	-> point0

	dc.w	-19*4,34*4,0*4
	dc.w	0,29308,14654
	dc.l	currentVertices_Torus+96	;	-> point12
	dc.l	currentVertices_Torus+104	;	-> point13
	dc.l	currentVertices_Torus+56	;	-> point7

	dc.w	-17*4,30*4,8*4
	dc.w	0,0,32767
	dc.l	currentVertices_Torus+104	;	-> point13
	dc.l	currentVertices_Torus+112	;	-> point14
	dc.l	currentVertices_Torus+64	;	-> point8

	dc.w	13*4,22*4,8*4
	dc.w	-0,-29308,14654
	dc.l	currentVertices_Torus+64	;	-> point8
	dc.l	currentVertices_Torus+112	;	-> point14
	dc.l	currentVertices_Torus+120	;	-> point15

	dc.w	-10*4,18*4,0*4
	dc.w	-0,-29308,-14654
	dc.l	currentVertices_Torus+120	;	-> point15
	dc.l	currentVertices_Torus+128	;	-> point16
	dc.l	currentVertices_Torus+80	;	-> point10

	dc.w	-13*4,22*4,-8*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Torus+128	;	-> point16
	dc.l	currentVertices_Torus+136	;	-> point17
	dc.l	currentVertices_Torus+88	;	-> point11

	dc.w	-17*4,30*4,-8*4
	dc.w	0,29308,-14654
	dc.l	currentVertices_Torus+136	;	-> point17
	dc.l	currentVertices_Torus+96	;	-> point12
	dc.l	currentVertices_Torus+48	;	-> point6

	dc.w	-39*4,0*4,0*4
	dc.w	-25381,14654,14654
	dc.l	currentVertices_Torus+144	;	-> point18
	dc.l	currentVertices_Torus+152	;	-> point19
	dc.l	currentVertices_Torus+104	;	-> point13

	dc.w	-34*4,0*4,8*4
	dc.w	0,0,32767
	dc.l	currentVertices_Torus+152	;	-> point19
	dc.l	currentVertices_Torus+160	;	-> point20
	dc.l	currentVertices_Torus+112	;	-> point14

	dc.w	-13*4,22*4,8*4
	dc.w	25381,-14654,14654
	dc.l	currentVertices_Torus+112	;	-> point14
	dc.l	currentVertices_Torus+160	;	-> point20
	dc.l	currentVertices_Torus+168	;	-> point21

	dc.w	-21*4,0*4,0*4
	dc.w	25381,-14654,-14654
	dc.l	currentVertices_Torus+168	;	-> point21
	dc.l	currentVertices_Torus+176	;	-> point22
	dc.l	currentVertices_Torus+128	;	-> point16

	dc.w	-25*4,0*4,-8*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Torus+176	;	-> point22
	dc.l	currentVertices_Torus+184	;	-> point23
	dc.l	currentVertices_Torus+136	;	-> point17

	dc.w	-34*4,0*4,-8*4
	dc.w	-25381,14654,-14654
	dc.l	currentVertices_Torus+184	;	-> point23
	dc.l	currentVertices_Torus+144	;	-> point18
	dc.l	currentVertices_Torus+96	;	-> point12

	dc.w	-19*4,-34*4,0*4
	dc.w	-25381,-14654,14654
	dc.l	currentVertices_Torus+192	;	-> point24
	dc.l	currentVertices_Torus+200	;	-> point25
	dc.l	currentVertices_Torus+152	;	-> point19

	dc.w	-17*4,-30*4,8*4
	dc.w	0,0,32767
	dc.l	currentVertices_Torus+200	;	-> point25
	dc.l	currentVertices_Torus+208	;	-> point26
	dc.l	currentVertices_Torus+160	;	-> point20

	dc.w	-13*4,-22*4,8*4
	dc.w	25381,14654,14654
	dc.l	currentVertices_Torus+208	;	-> point26
	dc.l	currentVertices_Torus+216	;	-> point27
	dc.l	currentVertices_Torus+168	;	-> point21

	dc.w	-10*4,-18*4,0*4
	dc.w	25381,14654,-14654
	dc.l	currentVertices_Torus+216	;	-> point27
	dc.l	currentVertices_Torus+224	;	-> point28
	dc.l	currentVertices_Torus+176	;	-> point22

	dc.w	-25*4,0*4,-8*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Torus+176	;	-> point22
	dc.l	currentVertices_Torus+224	;	-> point28
	dc.l	currentVertices_Torus+232	;	-> point29

	dc.w	-17*4,-30*4,-8*4
	dc.w	-25381,-14654,-14654
	dc.l	currentVertices_Torus+232	;	-> point29
	dc.l	currentVertices_Torus+192	;	-> point24
	dc.l	currentVertices_Torus+144	;	-> point18

	dc.w	19*4,-34*4,0*4
	dc.w	0,-29308,14654
	dc.l	currentVertices_Torus+240	;	-> point30
	dc.l	currentVertices_Torus+248	;	-> point31
	dc.l	currentVertices_Torus+200	;	-> point25

	dc.w	-17*4,-30*4,8*4
	dc.w	0,0,32767
	dc.l	currentVertices_Torus+200	;	-> point25
	dc.l	currentVertices_Torus+248	;	-> point31
	dc.l	currentVertices_Torus+256	;	-> point32

	dc.w	13*4,-22*4,8*4
	dc.w	-0,29308,14654
	dc.l	currentVertices_Torus+256	;	-> point32
	dc.l	currentVertices_Torus+264	;	-> point33
	dc.l	currentVertices_Torus+216	;	-> point27

	dc.w	-10*4,-18*4,0*4
	dc.w	-0,29308,-14654
	dc.l	currentVertices_Torus+216	;	-> point27
	dc.l	currentVertices_Torus+264	;	-> point33
	dc.l	currentVertices_Torus+272	;	-> point34

	dc.w	13*4,-22*4,-8*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Torus+272	;	-> point34
	dc.l	currentVertices_Torus+280	;	-> point35
	dc.l	currentVertices_Torus+232	;	-> point29

	dc.w	17*4,-30*4,-8*4
	dc.w	0,-29308,-14654
	dc.l	currentVertices_Torus+280	;	-> point35
	dc.l	currentVertices_Torus+240	;	-> point30
	dc.l	currentVertices_Torus+192	;	-> point24

	dc.w	39*4,0*4,0*4
	dc.w	25381,-14654,14654
	dc.l	currentVertices_Torus+0	;	-> point0
	dc.l	currentVertices_Torus+8	;	-> point1
	dc.l	currentVertices_Torus+248	;	-> point31

	dc.w	34*4,0*4,8*4
	dc.w	0,0,32767
	dc.l	currentVertices_Torus+8	;	-> point1
	dc.l	currentVertices_Torus+16	;	-> point2
	dc.l	currentVertices_Torus+256	;	-> point32

	dc.w	26*4,0*4,8*4
	dc.w	-25381,14654,14654
	dc.l	currentVertices_Torus+16	;	-> point2
	dc.l	currentVertices_Torus+24	;	-> point3
	dc.l	currentVertices_Torus+264	;	-> point33

	dc.w	21*4,0*4,0*4
	dc.w	-25381,14654,-14654
	dc.l	currentVertices_Torus+24	;	-> point3
	dc.l	currentVertices_Torus+32	;	-> point4
	dc.l	currentVertices_Torus+272	;	-> point34

	dc.w	25*4,0*4,-8*4
	dc.w	0,0,-32767
	dc.l	currentVertices_Torus+32	;	-> point4
	dc.l	currentVertices_Torus+40	;	-> point5
	dc.l	currentVertices_Torus+280	;	-> point35

	dc.w	34*4,0*4,-8*4
	dc.w	25381,-14654,-14654
	dc.l	currentVertices_Torus+40	;	-> point5
	dc.l	currentVertices_Torus+0	;	-> point0
	dc.l	currentVertices_Torus+240	;	-> point30

sourceFaces_Torus_end
; destination faces
;	format:
;	- visibility (dc.w)
;	- pointers to destination points: (dc.l) * 3
destFaces_Torus
	dc.w	0
	dc.l	point_Torus6
	dc.l	point_Torus1
	dc.l	point_Torus0
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus7
	dc.l	point_Torus2
	dc.l	point_Torus1
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus8
	dc.l	point_Torus3
	dc.l	point_Torus2
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus3
	dc.l	point_Torus10
	dc.l	point_Torus4
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus10
	dc.l	point_Torus5
	dc.l	point_Torus4
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus11
	dc.l	point_Torus0
	dc.l	point_Torus5
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus12
	dc.l	point_Torus7
	dc.l	point_Torus6
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus13
	dc.l	point_Torus8
	dc.l	point_Torus7
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus8
	dc.l	point_Torus15
	dc.l	point_Torus9
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus15
	dc.l	point_Torus10
	dc.l	point_Torus9
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus16
	dc.l	point_Torus11
	dc.l	point_Torus10
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus17
	dc.l	point_Torus6
	dc.l	point_Torus11
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus18
	dc.l	point_Torus13
	dc.l	point_Torus12
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus19
	dc.l	point_Torus14
	dc.l	point_Torus13
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus14
	dc.l	point_Torus21
	dc.l	point_Torus15
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus21
	dc.l	point_Torus16
	dc.l	point_Torus15
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus22
	dc.l	point_Torus17
	dc.l	point_Torus16
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus23
	dc.l	point_Torus12
	dc.l	point_Torus17
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus24
	dc.l	point_Torus19
	dc.l	point_Torus18
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus25
	dc.l	point_Torus20
	dc.l	point_Torus19
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus26
	dc.l	point_Torus21
	dc.l	point_Torus20
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus27
	dc.l	point_Torus22
	dc.l	point_Torus21
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus22
	dc.l	point_Torus29
	dc.l	point_Torus23
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus29
	dc.l	point_Torus18
	dc.l	point_Torus23
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus30
	dc.l	point_Torus25
	dc.l	point_Torus24
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus25
	dc.l	point_Torus32
	dc.l	point_Torus26
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus32
	dc.l	point_Torus27
	dc.l	point_Torus26
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus27
	dc.l	point_Torus34
	dc.l	point_Torus28
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus34
	dc.l	point_Torus29
	dc.l	point_Torus28
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus35
	dc.l	point_Torus24
	dc.l	point_Torus29
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus0
	dc.l	point_Torus31
	dc.l	point_Torus30
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus1
	dc.l	point_Torus32
	dc.l	point_Torus31
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus2
	dc.l	point_Torus33
	dc.l	point_Torus32
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus3
	dc.l	point_Torus34
	dc.l	point_Torus33
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus4
	dc.l	point_Torus35
	dc.l	point_Torus34
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus5
	dc.l	point_Torus30
	dc.l	point_Torus35
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus6
	dc.l	point_Torus7
	dc.l	point_Torus1
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus7
	dc.l	point_Torus8
	dc.l	point_Torus2
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus8
	dc.l	point_Torus9
	dc.l	point_Torus3
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus3
	dc.l	point_Torus9
	dc.l	point_Torus10
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus10
	dc.l	point_Torus11
	dc.l	point_Torus5
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus11
	dc.l	point_Torus6
	dc.l	point_Torus0
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus12
	dc.l	point_Torus13
	dc.l	point_Torus7
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus13
	dc.l	point_Torus14
	dc.l	point_Torus8
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus8
	dc.l	point_Torus14
	dc.l	point_Torus15
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus15
	dc.l	point_Torus16
	dc.l	point_Torus10
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus16
	dc.l	point_Torus17
	dc.l	point_Torus11
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus17
	dc.l	point_Torus12
	dc.l	point_Torus6
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus18
	dc.l	point_Torus19
	dc.l	point_Torus13
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus19
	dc.l	point_Torus20
	dc.l	point_Torus14
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus14
	dc.l	point_Torus20
	dc.l	point_Torus21
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus21
	dc.l	point_Torus22
	dc.l	point_Torus16
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus22
	dc.l	point_Torus23
	dc.l	point_Torus17
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus23
	dc.l	point_Torus18
	dc.l	point_Torus12
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus24
	dc.l	point_Torus25
	dc.l	point_Torus19
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus25
	dc.l	point_Torus26
	dc.l	point_Torus20
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus26
	dc.l	point_Torus27
	dc.l	point_Torus21
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus27
	dc.l	point_Torus28
	dc.l	point_Torus22
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus22
	dc.l	point_Torus28
	dc.l	point_Torus29
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus29
	dc.l	point_Torus24
	dc.l	point_Torus18
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus30
	dc.l	point_Torus31
	dc.l	point_Torus25
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus25
	dc.l	point_Torus31
	dc.l	point_Torus32
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus32
	dc.l	point_Torus33
	dc.l	point_Torus27
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus27
	dc.l	point_Torus33
	dc.l	point_Torus34
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus34
	dc.l	point_Torus35
	dc.l	point_Torus29
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus35
	dc.l	point_Torus30
	dc.l	point_Torus24
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus0
	dc.l	point_Torus1
	dc.l	point_Torus31
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus1
	dc.l	point_Torus2
	dc.l	point_Torus32
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus2
	dc.l	point_Torus3
	dc.l	point_Torus33
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus3
	dc.l	point_Torus4
	dc.l	point_Torus34
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus4
	dc.l	point_Torus5
	dc.l	point_Torus35
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

	dc.w	0
	dc.l	point_Torus5
	dc.l	point_Torus0
	dc.l	point_Torus30
	IFEQ SEP_UV
	dc.w	0<<7,256<<7,0<<7,256<<7,0<<7,256<<7	;x,y,z: 0,0,0
	ENDC

destFaces_Torus_end



init_Torus
	move.w	number_of_faces_Torus,current_number_of_faces
	move.w	number_of_vertices_Torus,current_number_of_vertices
	lea	currentVertices_Torus,a0
	move.l	a0,a5
	move.l	currentVerticesPointer,a1
	move.l	a1,a4					; save this address for later use, target base
	move.l	#currentVertices_Torus_end,d7
	sub.l	a0,d7						; number of bytes
	lsr.w	#3,d7
	subq.w	#1,d7
.cpv
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	dbra	d7,.cpv


	lea		currentNormals_Torus,a0
	move.l	currentNormalsPointer,a1
	move.l	#currentNormals_Torus_end,d7
	sub.l	a0,d7
	lsr.w	d7
	subq.w	#1,d7
.cpn	
		move.w	(a0)+,(a1)+
	dbra	d7,.cpn


	lea		points_Torus,a0
	move.l	a0,a6					; save this address for later use
	move.l	currentPointsPointer,a1
	move.l	a1,a3					; target base
	move.l	#points_Torus_end,d7
	sub.l	a0,d7
	lsr.w	d7
	subq.w	#1,d7
.cpp
		move.w	(a0)+,(a1)+
	dbra	d7,.cpp


	lea		sourceFaces_Torus,a0				;3*2 + 3*2 + 3*4 = 6 * 4 = 24
	move.l	currentSourceFacesPointer,a1
	move.l	#sourceFaces_Torus_end,d7
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


	lea		destFaces_Torus,a0
	move.l	currentDestFacesPointer,a1
	move.l	#destFaces_Torus_end,d7
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
