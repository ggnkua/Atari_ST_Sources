/*         DISCUS tools             (C) Martin Liesen 1992
		the not discus-dependent tools which might be used
		in other applications later on.
		
		but manily because I wish to reduce compiling time :-)
*/

#if  !defined( __DISCUS_TOOLS__ )
#define __DISCUS_TOOLS__



/***************************************** Get adress to an object */
long gaddr(int re_gtype,int re_gindex);

/*************************** Get address to a tree specific object */
long g_obj_addr(int tree,int obj);

/********************* Get address to the TEDINFO within an object */
long g_tedinfo_addr(int tree,int obje);

/******************************* Check if two rectangles Intercept */
int Intercept( int x1,int y1,int w1,int h1,
					int x2,int y2,int w2,int h2);

/************************************************ Clip a rectangle */
int Make_Clip( int *x1,int *y1,int *w1,int *h1,
					int x2,int y2,int w2,int h2);

/***************************************** Packed filename to long */
int Extend_Filename(char *filename);

/******************************************* CHECK IF A PATH EXIST */
int exist_path(const char *p);



#endif