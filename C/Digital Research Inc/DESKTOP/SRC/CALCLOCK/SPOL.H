/*	SPOL.H			11/09/84-06/20/85	Lee Lorenzen	*/

#define SPOOLER 0  	/* TREE */
#define SPOLBOX 1
#define F1NAME 2  	/* OBJECT in TREE #0 */
#define F12NAME 13  	/* OBJECT in TREE #0 */
#define ADDNAME 14  	/* OBJECT in TREE #0 */
#define REMNAME 15  	/* OBJECT in TREE #0 */

#define SPOL_STR 14
#define SPOL_OBS 16

BYTE *spol_str[SPOL_STR] = {
" 01______.___ ",
" 02______.___ ",
" 03______.___ ",
" 04______.___ ",
" 05______.___ ",
" 06______.___ ",
" 07______.___ ",
" 08______.___ ",
" 09______.___ ",
" 10______.___ ",
" 11______.___ ",
" 12______.___ ",
"Add Name...",
"Delete Name"
};


OBJECT the_spol[SPOL_OBS] = 
{
-1, 1, 15, G_BOX, NONE, NORMAL, 0x100L, 0,0, 20,18,
14, 2, 13, G_BOX, NONE, NORMAL, 0xFE1100L, 2,1, 16,12,
3, -1, -1, G_STRING, NONE, NORMAL, 0x0L, 1,0, 14,1,
4, -1, -1, G_STRING, NONE, NORMAL, 0x1L, 1,1, 14,1,
5, -1, -1, G_STRING, NONE, NORMAL, 0x2L, 1,2, 14,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0x3L, 1,3, 14,1,
7, -1, -1, G_STRING, NONE, NORMAL, 0x4L, 1,4, 14,1,
8, -1, -1, G_STRING, NONE, NORMAL, 0x5L, 1,5, 14,1,
9, -1, -1, G_STRING, NONE, NORMAL, 0x6L, 1,6, 14,1,
10, -1, -1, G_STRING, NONE, NORMAL, 0x7L, 1,7, 14,1,
11, -1, -1, G_STRING, NONE, NORMAL, 0x8L, 1,8, 14,1,
12, -1, -1, G_STRING, NONE, NORMAL, 0x9L, 1,9, 14,1,
13, -1, -1, G_STRING, NONE, NORMAL, 0xAL, 1,10, 14,1,
1, -1, -1, G_STRING, NONE, NORMAL, 0xBL, 1,11, 14,1,
15, -1, -1, G_BUTTON, 0x5, NORMAL, 0xCL, 2,14, 16,1,
0, -1, -1, G_BUTTON, 0x25, NORMAL, 0xDL, 2,16, 16,1
};
