***********************************************************************
** 3D POLYGON CLIPPER - the following routine will clip a 4 sided    **
** polygon against the screen (z=0), the result will be a 3,4 or     **
** 5 sided polygon, or if all the points are off the screen nothing  **
** a jump to notvis is made. The last line must copy the fist set of **
** valid vertices to the end to 'join' the polygon together.         **
** Written by T.A.King 8/7/91			         **
***********************************************************************

nx1 = 0
ny1 = 2
nz1 = 4
nx2 = 6
ny2 = 8
nz2 = 10
zclippoly	lea vertices,a3	;Vertices for 4 sided polygon
		move.l a2,a4
		addq #6,a4
		moveq #0,d0	  	;Number of visible vertices
		moveq #4-1,d1	 	;Clip 4 sides
clip_lp		tst	nz1(a3)	
		bge.s	first_off	
		move	nx1(a3),(a4)+ 	;1st point on screen, so save
		move	ny1(a3),(a4)+ 	;the vertices.
		addq	#1,d0
		tst	nz2(a3)
		blt.s	end_clip	;1st point on screen and
		bra.s	clip_3d	  	;2nd point off screen, so clip
first_off	tst	nz2(a3)	;Both points off screen,
		bge.s	end_clip	;don't save vertices
clip_3d		move	nz2(a3),d2	;Calculate intersection
		sub	nz1(a3),d2	;z2-z1
		move	nx2(a3),d3
		sub	nx1(a3),d3	;x2-x1
		muls	nz2(a3),d3	;(x2-x1)*z2
		divs	d2,d3	  	;((x2-x1)*z2)/(z2-z1)
		move	nx2(a3),d4
		sub	d3,d4	  	;x2-((x2-x1)*z2)/(z2-z1)
		move	d4,(a4)+	;Save clipped x
	
		move	ny2(a3),d3
		sub	ny1(a3),d3	;y2-y1
		muls	nz2(a3),d3	;(y2-y1)*z2
		divs	d2,d3	 	;((y2-y1)*z2)/(z2-z1)
		move	ny2(a3),d4
		sub	d3,d4	 	;y2-((y2-y1)*z2)/(z2-z1)
		move	d4,(a4)+	;Save clipped y
		addq	#1,d0

end_clip	addq	#6,a3	  	;Next set of vertices
		dbf	d1,clip_lp
		tst	d0	  	;Any visible vertices ?
		beq	notvis		;nope
		move	6(a2),(a4)+	;Store first visible vertices
		move	8(a2),(a4)	;to join polygon
	
		move	pz1,d1	  	;Add all z's together
		add	pz2,d1
		add	pz3,d1
		add	pz4,d1
		asr	#2,d1	  	;and divide by four
		move	d1,0(a2)	;Store average z
		move	d5,2(a2)	;Colour
		move	d0,4(a2)	;Number of sides
		add.l	#1,nvf	  	;Increase visible facets
		lea	32(a2),a2	;Next polygon entry
notvis		dbf	d7,nextf
		move.l	a2,facetpos
		rts
	
facetpos	dc.l	drawfacets
drawfacets	ds.b	32*100
