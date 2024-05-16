; Vertices
	dc.w 20
	dc.w 10
	dc.w -63,4,-64
	dc.w 159,19,-64
	dc.w 159,19,73
	dc.w -63,4,73
	dc.w -64,64,73
	dc.w 159,64,73
	dc.w 159,64,-64
	dc.w -64,64,-64
	dc.w 23,-18,73
	dc.w 23,-18,-64

; Normal List
	dc.w 86,65,68
	dc.w -86,65,68
	dc.w -86,65,-68
	dc.w 86,65,-68
	dc.w 73,-73,-73
	dc.w -73,-73,-73
	dc.w -73,-73,73
	dc.w 73,-73,73
	dc.w 0,113,-58
	dc.w 0,113,58

	dc.w (.end-.start)/4	; texture vertices
.start:.end:

; Face List
	dc.w 7
	dc.w 4<<Primitive.TYPESHIFT|Polygon.ENVMAPPED|0,8,2,5,4,3,18,12,15,14,13
	dc.w 3<<Primitive.TYPESHIFT|Polygon.ENVMAPPED|0,6,5,2,1,16,15,12,11
	dc.w 3<<Primitive.TYPESHIFT|Polygon.ENVMAPPED|0,3,0,9,8,13,10,19,18
	dc.w 3<<Primitive.TYPESHIFT|Polygon.ENVMAPPED|0,9,1,2,8,19,11,12,18
	dc.w 3<<Primitive.TYPESHIFT|Polygon.ENVMAPPED|0,4,5,6,7,14,15,16,17
	dc.w 3<<Primitive.TYPESHIFT|Polygon.ENVMAPPED|0,0,3,4,7,10,13,14,17
	dc.w 4<<Primitive.TYPESHIFT|Polygon.ENVMAPPED|0,1,9,0,7,6,11,19,10,17,16
