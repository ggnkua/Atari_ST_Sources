
/****** type defs for acts*/



#define MOVE_POINT 	0
#define ROT_POINT 	1
#define INSERT_POINT 	2
#define KILL_POINT 	3
/*point addresses*/

#define MOVE_POLY_PTS    4
#define ROT_SEGMENT  5
/*segment addresses*/

#define MOVE_POLY 	6
#define ROT_POLY 	7
#define INSERT_POLY 	8
#define KILL_POLY 	9
#define CHANGE_COLOR 	10
/*poly addresses*/
	
#define MOVE_POLYS 	11
#define ROT_POLYS 	12
#define SIZE_POLYS	13
#define REDO_POLYS 	14
/*start poly, #of polys addresses (poly segments) */

#define SIZE_POINT 15
#define SIZE_SEGMENT 16
#define SIZE_POLY 17

#define CHANGE_TYPE 18
#define MOVE_SEGMENT 19

#define PATH_POINT 20
#define PATH_POLY 21
#define PATH_POLY_PTS 22
#define PATH_SEGMENT 23
#define PATH_POLYS 24

#define INIT_COLORS 25
#define INSERT_RASTER 26
#define INSERT_STENCIL 27

#define LOAD_BACKGROUND 28
#define REMOVE_BACKGROUND 29
#define TWEEN_COLOR	30
#define CYCLE_COLORS	31

#define INSERT_CBLOCK	32
#define TWEEN_TO_COLORS 33
#define INSERT_STRIP	34
#define CHANGE_OCOLOR	35
#define CHANGE_FCOLOR	36

