;----------------------------------------------------------------
;----------------------------------------------------------------
;----------------------------------------------------------------
cubeNrEdges					equ	36
;cubeNrCullVertices 			equ cubeNrEdges*2
cubeNrVertices 				equ 24
cubeNrFaces 				equ 14		;14

morphopt					equ 1

;a equ 54/2		
;b equ 62/2

ax equ 47
b equ 47				; 48

;-------------[ settings ]------------------
vertexSize equ 4

setCubeObject
	; then we set some pointers
	move.w	#cubeNrVertices,number_of_vertices				; set number of vertices, deprecated
	move.w	#cubeNrFaces,number_of_faces					; set number of faces, could be deprecated, wins 4 cycles per face
	move.w	#cubeNrEdges,number_of_edges					; required for cleaning the edge coloring
;	move.w	#cubeNrCullVertices,number_of_cullvertices		;

	move.w	#ax,_morphSize
	move.w	#b,_morphSize_max
	move.l	#setCubeMorphSize,currentMorphRout

	move.l	#cubeVertices,sourceVerticesPointer						; set source vertices
	move.l	#cubeEorFaces,currentEorFacesPointer
	move.l	#cubeFaceNormals,currentFaceNormalsPointer			; set face normals
	move.l	#cubeEorEdges,currentEorLinesPointer
;	move.l	#cubeCullVertices,currentCullVerticesPointer

	; this is generic
;	jsr		copyCullVerticesToLower
	jsr		copyCurrentEorEdgesToLower							; copy edges to lower
	jsr		fixFaceNormals
	rts







setCubeMorphSize
	move.l	explog_logpointer,d6
	move.l	d6,d7

	move.w	_morphSize,d6
	add.w	d6,d6
	move.w	d6,d7
	neg.w	d7

	move.l	d6,a0
	move.w	(a0),d0
	add.w	#pivotexp,d0
	move.l	d7,a0
	move.w	(a0),d1
	add.w	#pivotexp,d1

	lea		currentVertices,a0

 	move.w	d0,6*0(a0)
 	move.w	d0,6*1+4(a0)
 	move.w	d0,6*2+2(a0)
 	move.w	d0,6*3+2(a0)
 	move.w	d0,6*4+4(a0)
 	move.w	d1,6*5(a0)
 	move.w	d1,6*6(a0)
 	move.w	d0,6*7+4(a0)
 	move.w	d1,6*8+2(a0)
 	move.w	d1,6*9+2(a0)
 	move.w	d0,6*10+4(a0)
 	move.w	d0,6*11(a0)
 	move.w	d0,6*12(a0)
 	move.w	d0,6*13+2(a0)
 	move.w	d1,6*14+4(a0)
 	move.w	d1,6*15+4(a0)
 	move.w	d0,6*16+2(a0)
 	move.w	d1,6*17(a0)
 	move.w	d1,6*18+4(a0)
 	move.w	d1,6*19(a0)
 	move.w	d1,6*20+2(a0)
 	move.w	d1,6*21+2(a0)
 	move.w	d0,6*22(a0)
 	move.w	d1,6*23+4(a0)

 	rts




;cubeScanFaces
;  dc.w 0,0,0,3-1,pps+0,pps+4,pps+8,pps+0
;  dc.w 0,0,0,3-1,pps+12,pps+16,pps+20,pps+12
;  dc.w 0,0,0,3-1,pps+24,pps+28,pps+32,pps+24
;  dc.w 0,0,0,3-1,pps+36,pps+40,pps+44,pps+36
;  dc.w 0,0,0,3-1,pps+48,pps+52,pps+56,pps+48
;  dc.w 0,0,0,3-1,pps+60,pps+64,pps+68,pps+60
;  dc.w 0,0,0,3-1,pps+72,pps+76,pps+80,pps+72
;  dc.w 0,0,0,3-1,pps+84,pps+88,pps+92,pps+84
;  dc.w 0,0,0,8-1,pps+36,pps+44,pps+24,pps+32,pps+12,pps+20,pps+0,pps+8,pps+36
;  dc.w 0,0,0,8-1,pps+80,pps+64,pps+60,pps+16,pps+12,pps+32,pps+28,pps+72,pps+80
;  dc.w 0,0,0,8-1,pps+56,pps+52,pps+84,pps+92,pps+40,pps+36,pps+8,pps+4,pps+56
;  dc.w 0,0,0,8-1,pps+72,pps+28,pps+24,pps+44,pps+40,pps+92,pps+88,pps+76,pps+72
;  dc.w 0,0,0,8-1,pps+76,pps+88,pps+84,pps+52,pps+48,pps+68,pps+64,pps+80,pps+76
;  dc.w 0,0,0,8-1,pps+0,pps+20,pps+16,pps+60,pps+68,pps+48,pps+56,pps+4,pps+0
 


cubeEorEdges:
	dc.w	0
	dc.w	pps+0*vertexSize
	dc.w	pps+1*vertexSize

	dc.w	0
	dc.w	pps+1*vertexSize
	dc.w	pps+2*vertexSize

	dc.w	0
	dc.w	pps+2*vertexSize
	dc.w	pps+0*vertexSize

	dc.w	0
	dc.w	pps+3*vertexSize
	dc.w	pps+4*vertexSize

	dc.w	0
	dc.w	pps+4*vertexSize
	dc.w	pps+5*vertexSize

	dc.w	0
	dc.w	pps+5*vertexSize
	dc.w	pps+3*vertexSize

	dc.w	0
	dc.w	pps+6*vertexSize
	dc.w	pps+7*vertexSize

	dc.w	0
	dc.w	pps+7*vertexSize
	dc.w	pps+8*vertexSize

	dc.w	0
	dc.w	pps+8*vertexSize
	dc.w	pps+6*vertexSize

	dc.w	0
	dc.w	pps+9*vertexSize
	dc.w	pps+10*vertexSize

	dc.w	0
	dc.w	pps+10*vertexSize
	dc.w	pps+11*vertexSize

	dc.w	0
	dc.w	pps+11*vertexSize
	dc.w	pps+9*vertexSize

	dc.w	0
	dc.w	pps+12*vertexSize
	dc.w	pps+13*vertexSize

	dc.w	0
	dc.w	pps+13*vertexSize
	dc.w	pps+14*vertexSize

	dc.w	0
	dc.w	pps+14*vertexSize
	dc.w	pps+12*vertexSize

	dc.w	0
	dc.w	pps+15*vertexSize
	dc.w	pps+16*vertexSize

	dc.w	0
	dc.w	pps+16*vertexSize
	dc.w	pps+17*vertexSize

	dc.w	0
	dc.w	pps+17*vertexSize
	dc.w	pps+15*vertexSize

	dc.w	0
	dc.w	pps+18*vertexSize
	dc.w	pps+19*vertexSize

	dc.w	0
	dc.w	pps+19*vertexSize
	dc.w	pps+20*vertexSize

	dc.w	0
	dc.w	pps+20*vertexSize
	dc.w	pps+18*vertexSize

	dc.w	0
	dc.w	pps+21*vertexSize
	dc.w	pps+22*vertexSize

	dc.w	0
	dc.w	pps+22*vertexSize
	dc.w	pps+23*vertexSize

	dc.w	0
	dc.w	pps+23*vertexSize
	dc.w	pps+21*vertexSize

	dc.w	0
	dc.w	pps+11*vertexSize
	dc.w	pps+6*vertexSize

	dc.w	0
	dc.w	pps+8*vertexSize
	dc.w	pps+3*vertexSize

	dc.w	0
	dc.w	pps+5*vertexSize
	dc.w	pps+0*vertexSize

	dc.w	0
	dc.w	pps+2*vertexSize
	dc.w	pps+9*vertexSize

	dc.w	0
	dc.w	pps+20*vertexSize
	dc.w	pps+16*vertexSize

	dc.w	0
	dc.w	pps+15*vertexSize
	dc.w	pps+4*vertexSize

	dc.w	0
	dc.w	pps+7*vertexSize
	dc.w	pps+18*vertexSize

	dc.w	0
	dc.w	pps+13*vertexSize
	dc.w	pps+21*vertexSize

	dc.w	0
	dc.w	pps+23*vertexSize
	dc.w	pps+10*vertexSize

	dc.w	0
	dc.w	pps+1*vertexSize
	dc.w	pps+14*vertexSize

	dc.w	0
	dc.w	pps+22*vertexSize
	dc.w	pps+19*vertexSize

	dc.w	0
	dc.w	pps+12*vertexSize
	dc.w	pps+17*vertexSize





;cubeCullVertices:
;	dc.w	pps+0*vertexSize		;0
;	dc.w	eorEdgesLower+0	
;
;	dc.w	pps+1*vertexSize		;1
;	dc.w	eorEdgesLower+6	
;
;	dc.w	pps+2*vertexSize		;2
;	dc.w	eorEdgesLower+12	
;
;	dc.w	pps+3*vertexSize		;3
;	dc.w	eorEdgesLower+18	
;
;	dc.w	pps+4*vertexSize		;4
;	dc.w	eorEdgesLower+24	
;
;	dc.w	pps+5*vertexSize		;5
;	dc.w	eorEdgesLower+30	
;
;	dc.w	pps+6*vertexSize		;6
;	dc.w	eorEdgesLower+36	
;
;	dc.w	pps+7*vertexSize		;7
;	dc.w	eorEdgesLower+42	
;
;	dc.w	pps+8*vertexSize		;8
;	dc.w	eorEdgesLower+48	
;
;	dc.w	pps+9*vertexSize		;9
;	dc.w	eorEdgesLower+54	
;
;	dc.w	pps+10*vertexSize		;10
;	dc.w	eorEdgesLower+60	
;
;	dc.w	pps+11*vertexSize		;11
;	dc.w	eorEdgesLower+66	
;
;	dc.w	pps+12*vertexSize		;12
;	dc.w	eorEdgesLower+72	
;
;	dc.w	pps+13*vertexSize		;13
;	dc.w	eorEdgesLower+78	
;
;	dc.w	pps+14*vertexSize		;14
;	dc.w	eorEdgesLower+84	
;
;	dc.w	pps+15*vertexSize		;15
;	dc.w	eorEdgesLower+90	
;
;	dc.w	pps+16*vertexSize		;16
;	dc.w	eorEdgesLower+96	
;
;	dc.w	pps+17*vertexSize		;17
;	dc.w	eorEdgesLower+102	
;
;	dc.w	pps+18*vertexSize		;18
;	dc.w	eorEdgesLower+108	
;
;	dc.w	pps+19*vertexSize		;19
;	dc.w	eorEdgesLower+114	
;
;	dc.w	pps+20*vertexSize		;20
;	dc.w	eorEdgesLower+120	
;
;	dc.w	pps+21*vertexSize		;21
;	dc.w	eorEdgesLower+126	
;
;	dc.w	pps+22*vertexSize		;22
;	dc.w	eorEdgesLower+132	
;
;	dc.w	pps+23*vertexSize		;23
;	dc.w	eorEdgesLower+138	
;
;	dc.w	pps+9*vertexSize		;24
;	dc.w	eorEdgesLower+66	
;
;	dc.w	pps+11*vertexSize		;25
;	dc.w	eorEdgesLower+144	
;
;	dc.w	pps+6*vertexSize		;26
;	dc.w	eorEdgesLower+48	
;
;	dc.w	pps+8*vertexSize		;27
;	dc.w	eorEdgesLower+150	
;
;	dc.w	pps+3*vertexSize		;28
;	dc.w	eorEdgesLower+30	
;
;	dc.w	pps+5*vertexSize		;29
;	dc.w	eorEdgesLower+156	
;
;	dc.w	pps+0*vertexSize		;30
;	dc.w	eorEdgesLower+12	
;
;	dc.w	pps+2*vertexSize		;31
;	dc.w	eorEdgesLower+162	
;
;	dc.w	pps+20*vertexSize		;32
;	dc.w	eorEdgesLower+168	
;
;	dc.w	pps+16*vertexSize		;33
;	dc.w	eorEdgesLower+90	
;
;	dc.w	pps+15*vertexSize		;34
;	dc.w	eorEdgesLower+174	
;
;	dc.w	pps+4*vertexSize		;35
;	dc.w	eorEdgesLower+18	
;
;	dc.w	pps+3*vertexSize		;36
;	dc.w	eorEdgesLower+150	
;
;	dc.w	pps+8*vertexSize		;37
;	dc.w	eorEdgesLower+42	
;
;	dc.w	pps+7*vertexSize		;38
;	dc.w	eorEdgesLower+180	
;
;	dc.w	pps+18*vertexSize		;39
;	dc.w	eorEdgesLower+120	
;
;	dc.w	pps+14*vertexSize		;40
;	dc.w	eorEdgesLower+78	
;
;	dc.w	pps+13*vertexSize		;41
;	dc.w	eorEdgesLower+186	
;
;	dc.w	pps+21*vertexSize		;42
;	dc.w	eorEdgesLower+138	
;
;	dc.w	pps+23*vertexSize		;43
;	dc.w	eorEdgesLower+192	
;
;	dc.w	pps+10*vertexSize		;44
;	dc.w	eorEdgesLower+54	
;
;	dc.w	pps+9*vertexSize		;45
;	dc.w	eorEdgesLower+162	
;
;	dc.w	pps+2*vertexSize		;46
;	dc.w	eorEdgesLower+6	
;
;	dc.w	pps+1*vertexSize		;47
;	dc.w	eorEdgesLower+198	
;
;	dc.w	pps+18*vertexSize		;48
;	dc.w	eorEdgesLower+180	
;
;	dc.w	pps+7*vertexSize		;49
;	dc.w	eorEdgesLower+36	
;
;	dc.w	pps+6*vertexSize		;50
;	dc.w	eorEdgesLower+144	
;
;	dc.w	pps+11*vertexSize		;51
;	dc.w	eorEdgesLower+60	
;
;	dc.w	pps+10*vertexSize		;52
;	dc.w	eorEdgesLower+192	
;
;	dc.w	pps+23*vertexSize		;53
;	dc.w	eorEdgesLower+132	
;
;	dc.w	pps+22*vertexSize		;54
;	dc.w	eorEdgesLower+204	
;
;	dc.w	pps+19*vertexSize		;55
;	dc.w	eorEdgesLower+108	
;
;	dc.w	pps+19*vertexSize		;56
;	dc.w	eorEdgesLower+204	
;
;	dc.w	pps+22*vertexSize		;57
;	dc.w	eorEdgesLower+126	
;
;	dc.w	pps+21*vertexSize		;58
;	dc.w	eorEdgesLower+186	
;
;	dc.w	pps+13*vertexSize		;59
;	dc.w	eorEdgesLower+72	
;
;	dc.w	pps+12*vertexSize		;60
;	dc.w	eorEdgesLower+210	
;
;	dc.w	pps+17*vertexSize		;61
;	dc.w	eorEdgesLower+96	
;
;	dc.w	pps+16*vertexSize		;62
;	dc.w	eorEdgesLower+168	
;
;	dc.w	pps+20*vertexSize		;63
;	dc.w	eorEdgesLower+114	
;
;	dc.w	pps+0*vertexSize		;64
;	dc.w	eorEdgesLower+156	
;
;	dc.w	pps+5*vertexSize		;65
;	dc.w	eorEdgesLower+24	
;
;	dc.w	pps+4*vertexSize		;66
;	dc.w	eorEdgesLower+174	
;
;	dc.w	pps+15*vertexSize		;67
;	dc.w	eorEdgesLower+102	
;
;	dc.w	pps+17*vertexSize		;68
;	dc.w	eorEdgesLower+210	
;
;	dc.w	pps+12*vertexSize		;69
;	dc.w	eorEdgesLower+84	
;
;	dc.w	pps+14*vertexSize		;70
;	dc.w	eorEdgesLower+198	
;
;	dc.w	pps+1*vertexSize		;71
;	dc.w	eorEdgesLower+0	


cubeEorFaces:			; 
	IFNE old
	;0
	dc.w	-6,eorEdgesLower+0,eorEdgesLower+6,eorEdgesLower+12
	;6
	dc.w	-6,eorEdgesLower+108,eorEdgesLower+114,eorEdgesLower+120
	;1
	dc.w	-6,eorEdgesLower+18,eorEdgesLower+24,eorEdgesLower+30
	;7
	dc.w	-6,eorEdgesLower+126,eorEdgesLower+132,eorEdgesLower+138
	;2
	dc.w	-6,eorEdgesLower+36,eorEdgesLower+42,eorEdgesLower+48
	;4
	dc.w	-6,eorEdgesLower+72,eorEdgesLower+78,eorEdgesLower+84
	;3
	dc.w	-6,eorEdgesLower+54,eorEdgesLower+60,eorEdgesLower+66
	;5
	dc.w	-6,eorEdgesLower+90,eorEdgesLower+96,eorEdgesLower+102
	;8			;66,144,48,150,30,156,12,162
	dc.w	-16,eorEdgesLower+66,eorEdgesLower+144,eorEdgesLower+48,eorEdgesLower+150,eorEdgesLower+30,eorEdgesLower+156,eorEdgesLower+12,eorEdgesLower+162
	;12			;204,126,186,72,210,96,168,114
	dc.w	-16,eorEdgesLower+204,eorEdgesLower+126,eorEdgesLower+186,eorEdgesLower+72,eorEdgesLower+210,eorEdgesLower+96,eorEdgesLower+168,eorEdgesLower+114
	;9
	dc.w	-16,eorEdgesLower+168,eorEdgesLower+90,eorEdgesLower+174,eorEdgesLower+18,eorEdgesLower+150,eorEdgesLower+42,eorEdgesLower+180,eorEdgesLower+120
	;10
	dc.w	-16,eorEdgesLower+78,eorEdgesLower+186,eorEdgesLower+138,eorEdgesLower+192,eorEdgesLower+54,eorEdgesLower+162,eorEdgesLower+6,eorEdgesLower+198
	;11
	dc.w	-16,eorEdgesLower+180,eorEdgesLower+36,eorEdgesLower+144,eorEdgesLower+60,eorEdgesLower+192,eorEdgesLower+132,eorEdgesLower+204,eorEdgesLower+108
	;13
	dc.w	-16,eorEdgesLower+156,eorEdgesLower+24,eorEdgesLower+174,eorEdgesLower+102,eorEdgesLower+210,eorEdgesLower+84,eorEdgesLower+198,eorEdgesLower+0

	ELSE
; assumption is that if I use everything with cullVerticesLower, that we can then save stuff in the coloring of stuff
	;0
	dc.w	-6,cullVerticesLower+0,cullVerticesLower+4,cullVerticesLower+8
	;6
	dc.w	-6,cullVerticesLower+72,cullVerticesLower+76,cullVerticesLower+80
	;1
	dc.w	-6,cullVerticesLower+12,cullVerticesLower+16,cullVerticesLower+20
	;7
	dc.w	-6,cullVerticesLower+84,cullVerticesLower+88,cullVerticesLower+92
	;2
	dc.w	-6,cullVerticesLower+24,cullVerticesLower+28,cullVerticesLower+32
	;4
	dc.w	-6,cullVerticesLower+48,cullVerticesLower+52,cullVerticesLower+56
	;3
	dc.w	-6,cullVerticesLower+36,cullVerticesLower+40,cullVerticesLower+44
	;5
	dc.w	-6,cullVerticesLower+60,cullVerticesLower+64,cullVerticesLower+68
	;8
	dc.w	-16,cullVerticesLower+44,cullVerticesLower+96,cullVerticesLower+32,cullVerticesLower+100,cullVerticesLower+20,cullVerticesLower+104,cullVerticesLower+8,cullVerticesLower+108
	;12
	dc.w	-16,cullVerticesLower+136,cullVerticesLower+84,cullVerticesLower+124,cullVerticesLower+48,cullVerticesLower+140,cullVerticesLower+64,cullVerticesLower+112,cullVerticesLower+76
	;9
	dc.w	-16,cullVerticesLower+128,cullVerticesLower+132,cullVerticesLower+136,cullVerticesLower+12,cullVerticesLower+100,cullVerticesLower+28,cullVerticesLower+120,cullVerticesLower+80
	;10
	dc.w	-16,cullVerticesLower+160,cullVerticesLower+164,cullVerticesLower+168,cullVerticesLower+128,cullVerticesLower+36,cullVerticesLower+108,cullVerticesLower+4,cullVerticesLower+132
	;11
	dc.w	-16,cullVerticesLower+192,cullVerticesLower+196,cullVerticesLower+200,cullVerticesLower+40,cullVerticesLower+128,cullVerticesLower+88,cullVerticesLower+136,cullVerticesLower+72
	;13
	dc.w	-16,cullVerticesLower+256,cullVerticesLower+260,cullVerticesLower+264,cullVerticesLower+68,cullVerticesLower+140,cullVerticesLower+56,cullVerticesLower+132,cullVerticesLower+0
	ENDC





cubeVertices
  dc.w ax,b,b			;0
  dc.w b,b,ax			;1
  dc.w b,ax,b			;2
  dc.w -b,ax,b			;3
  dc.w -b,b,ax			;4
  dc.w -ax,b,b			;5
  dc.w -ax,-b,b			;6
  dc.w -b,-b,ax			;7
  dc.w -b,-ax,b			;8
  dc.w b,-ax,b			;9
  dc.w b,-b,ax			;10
  dc.w ax,-b,b			;11
  dc.w ax,b,-b			;12
  dc.w b,ax,-b			;13
  dc.w b,b,-ax			;14
  dc.w -b,b,-ax			;15
  dc.w -b,ax,-b			;16
  dc.w -ax,b,-b			;17
  dc.w -b,-b,-ax			;18
  dc.w -ax,-b,-b			;19
  dc.w -b,-ax,-b			;20
  dc.w b,-ax,-b			;21
  dc.w ax,-b,-b			;22		+,-,-
  dc.w b,-b,-ax			;23		+,-,-
	;9		0,	3,	20,		6,	9,	14,		12,	15,	18,		18,	21,	19,		0


cubeFaceNormals:
	;0
	dc.l	cubeVertices+0
	dc.w	0
	dc.w	-18918,-18918,-18918
	;6
	dc.l	cubeVertices+108
	dc.w	0
	dc.w	18918,18918,18918
	;1
	dc.l	cubeVertices+18
	dc.w	0
	dc.w	18918,-18918,-18918
	;7
	dc.l	cubeVertices+126
	dc.w	0
	dc.w	-18918,18918,18918
	;2
	dc.l	cubeVertices+36
	dc.w	0
	dc.w	18918,18918,-18918
	;4
	dc.l	cubeVertices+72
	dc.w	0
	dc.w	-18918,-18918,18918
	;3
	dc.l	cubeVertices+54
	dc.w	0
	dc.w	-18918,18918,-18918
	;5
	dc.l	cubeVertices+90
	dc.w	0
	dc.w	18918,-18918,18918
	;8
	dc.l	cubeVertices+54
	dc.w	0
	dc.w	0,0,-32767
	;12
	dc.l	cubeVertices+114
	dc.w	0
	dc.w	0,0,32767
	;9
	dc.l	cubeVertices+120
	dc.w	0
	dc.w	32767,0,0
	;10
	dc.l	cubeVertices+84
	dc.w	0
	dc.w	-32767,0,0
	;11
	dc.l	cubeVertices+108
	dc.w	0
	dc.w	0,32767,0
	;13
	dc.l	cubeVertices+0
	dc.w	0
	dc.w	0,-32767,0

	dc.l	-1


;cubeFaceNormals:
	;	0
	dc.w	ax,b,b
	dc.w	-18918,-18918,-18918
	;	6
	dc.w	-b,-b,-ax
	dc.w	18918,18918,18918
	;	1
	dc.w	-b,ax,b
	dc.w	18918,-18918,-18918
	;	7
	dc.w	b,-ax,-b
	dc.w	-18918,18918,18918
	;	2
	dc.w	-ax,-b,b
	dc.w	18918,18918,-18918
	;	4
	dc.w	ax,b,-b
	dc.w	-18918,-18918,18918
	;	3
	dc.w	b,-ax,b
	dc.w	-18918,18918,-18918
	;	5
	dc.w	-b,b,-ax
	dc.w	18918,-18918,18918
	;	8
	dc.w	b,-ax,b
	dc.w	0,0,-32767
	;	12
	dc.w	-ax,-b,-b
	dc.w	0,0,32767
	;	9
	dc.w	-b,-ax,-b
	dc.w	32767,0,0
	;	10
	dc.w	b,b,-ax
	dc.w	-32767,0,0
	;	11
	dc.w	-b,-b,-ax
	dc.w	0,32767,0
	;	13
	dc.w	ax,b,b
	dc.w	0,-32767,0
	dc.l	-1
