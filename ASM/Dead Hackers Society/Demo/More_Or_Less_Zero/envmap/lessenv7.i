
alien_numcoord = 30
alien_numface = 24
alien_objsize = 5

alien_coords:
	dc.w	     2*alien_objsize,  -199*alien_objsize,     0*alien_objsize
	dc.w	    46*alien_objsize,   -46*alien_objsize,    44*alien_objsize
	dc.w	   -42*alien_objsize,   -46*alien_objsize,    44*alien_objsize
	dc.w	   -42*alien_objsize,   -46*alien_objsize,   -44*alien_objsize
	dc.w	    46*alien_objsize,   -46*alien_objsize,   -44*alien_objsize
	dc.w	    46*alien_objsize,   -46*alien_objsize,   -44*alien_objsize
	dc.w	  -195*alien_objsize,    -1*alien_objsize,     0*alien_objsize
	dc.w	   -42*alien_objsize,   -46*alien_objsize,    44*alien_objsize
	dc.w	   -42*alien_objsize,    42*alien_objsize,    44*alien_objsize
	dc.w	   -42*alien_objsize,    42*alien_objsize,   -44*alien_objsize
	dc.w	   -42*alien_objsize,   -46*alien_objsize,   -44*alien_objsize
	dc.w	    46*alien_objsize,    42*alien_objsize,   -44*alien_objsize
	dc.w	   200*alien_objsize,    -1*alien_objsize,     0*alien_objsize
	dc.w	    46*alien_objsize,    42*alien_objsize,    44*alien_objsize
	dc.w	    46*alien_objsize,   -46*alien_objsize,    44*alien_objsize
	dc.w	    46*alien_objsize,    42*alien_objsize,   -44*alien_objsize
	dc.w	   -42*alien_objsize,    42*alien_objsize,   -44*alien_objsize
	dc.w	     2*alien_objsize,   195*alien_objsize,     0*alien_objsize
	dc.w	   -42*alien_objsize,    42*alien_objsize,    44*alien_objsize
	dc.w	    46*alien_objsize,    42*alien_objsize,    44*alien_objsize
	dc.w	    46*alien_objsize,   -46*alien_objsize,   -44*alien_objsize
	dc.w	   -42*alien_objsize,   -46*alien_objsize,   -44*alien_objsize
	dc.w	     2*alien_objsize,    -1*alien_objsize,  -197*alien_objsize
	dc.w	   -42*alien_objsize,    42*alien_objsize,   -44*alien_objsize
	dc.w	    46*alien_objsize,    42*alien_objsize,   -44*alien_objsize
	dc.w	    46*alien_objsize,    42*alien_objsize,    44*alien_objsize
	dc.w	   -42*alien_objsize,    42*alien_objsize,    44*alien_objsize
	dc.w	     2*alien_objsize,    -1*alien_objsize,   197*alien_objsize
	dc.w	   -42*alien_objsize,   -46*alien_objsize,    44*alien_objsize
	dc.w	    46*alien_objsize,   -46*alien_objsize,    44*alien_objsize
alien_faces:
	dc.w	     0*4,     1*4,     4*4,     0*4
	dc.w	     0*4,     2*4,     1*4,     0*4
	dc.w	     0*4,     4*4,     3*4,     0*4
	dc.w	     0*4,     3*4,     2*4,     0*4
	dc.w	     6*4,     7*4,    10*4,     0*4
	dc.w	     6*4,    10*4,     9*4,     0*4
	dc.w	     6*4,     9*4,     8*4,     0*4
	dc.w	     6*4,     8*4,     7*4,     0*4
	dc.w	    12*4,    11*4,     5*4,     0*4
	dc.w	    12*4,     5*4,    14*4,     0*4
	dc.w	    12*4,    14*4,    13*4,     0*4
	dc.w	    12*4,    13*4,    11*4,     0*4
	dc.w	    17*4,    16*4,    15*4,     0*4
	dc.w	    17*4,    15*4,    19*4,     0*4
	dc.w	    17*4,    19*4,    18*4,     0*4
	dc.w	    17*4,    18*4,    16*4,     0*4
	dc.w	    22*4,    21*4,    20*4,     0*4
	dc.w	    22*4,    20*4,    24*4,     0*4
	dc.w	    22*4,    24*4,    23*4,     0*4
	dc.w	    22*4,    23*4,    21*4,     0*4
	dc.w	    27*4,    26*4,    25*4,     0*4
	dc.w	    27*4,    25*4,    29*4,     0*4
	dc.w	    27*4,    29*4,    28*4,     0*4
	dc.w	    27*4,    28*4,    26*4,     0*4
alien_ecoords:
	dc.w	     0,  2280,     0
	dc.w	 -3934,  2280, -3934
	dc.w	  3934,  2280, -3934
	dc.w	  3934,  2280,  3934
	dc.w	 -3934,  2280,  3934
	dc.w	 -2280,  3934,  3934
	dc.w	  2280,     0,     0
	dc.w	  2280,  3934, -3934
	dc.w	  2280, -3934, -3934
	dc.w	  2280, -3934,  3934
	dc.w	  2280,  3934,  3934
	dc.w	 -2280, -3934,  3934
	dc.w	 -2280,     0,     0
	dc.w	 -2280, -3934, -3934
	dc.w	 -2280,  3934, -3934
	dc.w	 -3934, -2280,  3934
	dc.w	  3934, -2280,  3934
	dc.w	     0, -2280,     0
	dc.w	  3934, -2280, -3934
	dc.w	 -3934, -2280, -3934
	dc.w	 -3934,  3934,  2280
	dc.w	  3934,  3934,  2280
	dc.w	     0,     0,  2280
	dc.w	  3934, -3934,  2280
	dc.w	 -3934, -3934,  2280
	dc.w	 -3934, -3934, -2280
	dc.w	  3934, -3934, -2280
	dc.w	     0,     0, -2280
	dc.w	  3934,  3934, -2280
	dc.w	 -3934,  3934, -2280

