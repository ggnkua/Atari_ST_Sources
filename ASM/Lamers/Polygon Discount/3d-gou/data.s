		cnop 0,4
points3d_gou	
		dc.w -50,-50,50	;0
		dc.w 50,-50,50	;1
		dc.w 0,-50,-50	;2
		dc.w 0,90,0		;3
		cnop 0,4

gouFaces3d
		dc.w  2,3,0	;0
		dc.w  0,3,1	;1
		dc.w  1,3,2	;2
		dc.w  0,1,2	;3
		cnop 0,4

gouPointsColor3d
		dc.w 0		;0
		dc.w 80		;1
		dc.w 160	;2
		dc.w 240	;3
		cnop 0,4

		ifeq	GOU_ZBUFF
gouColor3d	incbin	'3d-gou/color.dat'
		endif
		ifne	GOU_ZBUFF
gouColor3d	incbin	'3d-gou/color2bw.dat'
		endif

gouPoints3dCnt	dc.l	4-1
gouFaces3dCnt	dc.l	4-1
