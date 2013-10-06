* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Copyright A.Tyler 1991 data_02.s                                  *           
*	A data file for chapter 6.                                  *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

* Here is the matrix for the perspective transform. The
* distance to the viewpoint along the -z axis in the viewframe
* is 100.
* The elements are given a row at a time.
persmatx:
	dc.w	100,0,0,0,0,100,0,0,0,0,0,0,0,0,1,100
