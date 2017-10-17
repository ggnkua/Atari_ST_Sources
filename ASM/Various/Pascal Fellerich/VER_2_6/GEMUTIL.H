/*
 * some utility def's for gemapps
 */

#define EXTERN extern
#define FALSE 0
#define TRUE !FALSE
#define NIL -1			/* pointer to nothing (in object-trees) */

#define MAX(a,b)		(((a)>(b)) ? (a) : (b))
#define MIN(a,b)		(((a)<(b)) ? (a) : (b))
#define ABS(a)			((a)>0?(a):(-(a)))

/* New MULTITOS AES Messages: */
/* see MultiTOS DOC's		  */
#define WM_UNTOPPED 	30
#define WM_ONTOP		31
#define AP_TERM 		50		   /* sent before resolution change */
#define CH_EXIT 		80

/* Shorthand macro to pass parameters for objc_draw() */
#define PTRS(r) r->g_x, r->g_y, r->g_w, r->g_h
#define ELTS(r) r.g_x, r.g_y, r.g_w, r.g_h

/* -- eof -- */
