/*******************************************************************
 *
 *  filehead.h		gebiet : xcfile		projekt : xcarpet
 *------------------------------------------------------------------
 *  definition des dateikopfs eines ascii-datenfiles + makros
 *
 ******************************************************************/
 
 /*   2. 6.88  stock  */

#ifndef _FILEHEAD

#if COMPILER==MEGAMAX
	overlay "xcfile"
#endif

typedef struct fileheader 
{
  int    format,		/*   formatkennung	*/
         xres, yres, zres; 	/*    aufl”sungen	*/
  double xmin, xmax,		/*    extremwerte	*/
         ymin, ymax;
} fileheader;

#define HEADERLINES	4

#define FORMAT	head->format
#define XRES	head->xres
#define YRES	head->yres
#define ZRES	head->zres
	
#define XMIN	head->xmin
#define YMIN	head->ymin
#define XMAX	head->xmax
#define YMAX	head->ymax

#endif

/*******************************************************************/
