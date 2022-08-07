
#define LEN	0	/*field for length of an *act (in # of WORDs...) */
#define OP	1	/*field for type of *act	*/
#define PL	2	/*field for poly ix in an *act 	*/
#define PT	3	/*field for point ix in *act (not in all acts...) */

#define INSERT_OP	0
#define KILL_OP		1
#define MOVE_OP		2
#define ROT_OP	3
#define SIZE_OP		4
#define XCOLOR_OP	5
#define XTYPE_OP        6
#define SAMPLE_OP	7
/*defines used to classify the function type of an *act */

#define POINTS	0
#define SEGMENT	1
#define POLYS	2
#define FRAME	3
#define POLY_PTS 4
/*defines used in to classify the address type of an *act  */

#define S_POINT		0
#define S_POINTS	1
#define S_SEGMENT	2
#define S_POLY		3
#define S_POLYS		4
#define S_FRAME		5
/*defines used by vroutines and sroutines to select objects*/
extern WORD s_mode;  /*definitely  = one of above defines*/


#ifdef EDITOR
extern WORD op_matrix[][5];
#endif EDITOR
extern WORD function_length[], address_length[];
extern WORD function_type[], address_type[];



