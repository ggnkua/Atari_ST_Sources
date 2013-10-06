* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*Copyright A.Tyler 1991		bss_06.s                              *
* 		Variables for Chapter 11                              *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	include bss_05.s
* variables for rotating the view frame
iv	ds.w	3	view frame base vector components in world frame
jv	ds.w	3
kv	ds.w	3
vxangle	ds.w	1	rotation angles about these axes
vyangle	ds.w	1
vzangle	ds.w	1
vrot_matx	ds.w	9	rotation matx. about an arbitrary axis
* visibility
viewflag	ds.w	1
Vox	ds.w	1	object centre in view frame
Voy	ds.w	1
Voz	ds.w	1
