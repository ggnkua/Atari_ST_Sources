		cnop 0,4
	ifne ROT_3D_TRI
points3d	
		dc.w -50,-50,50	;0
		dc.w 50,-50,50	;1
		dc.w 0,-50,-50	;2
		dc.w 0,90,0		;3

		cnop 0,4
faces3d
		dc.w  2,3,0	;0
		dc.w  0,3,1	;1
		dc.w  1,3,2	;2
		dc.w  0,1,2	;3

		cnop 0,4

points3dCnt	dc.l	4-1
faces3dCnt	dc.l	4-1
	endif

	ifne ROT_3D_CUBE
points3d
		dc.w -50,50,-50	;0
		dc.w -50,50,50	;1
		dc.w -50,-50,50	;2
		dc.w -50,-50,-50	;3
		dc.w 50,50,-50	;4
		dc.w 50,50,50	;5
		dc.w 50,-50,50	;6
		dc.w 50,-50,-50	;7

faces3d
		dc.w  0,1,2,3	;0
		dc.w  0,4,5,1	;1
		dc.w  3,2,6,7	;2
		dc.w  1,5,6,2	;3
		dc.w  5,4,7,6	;4
		dc.w  4,0,3,7	;5

points3dCnt	dc.l	8-1
faces3dCnt	dc.l	6-1
	endif
