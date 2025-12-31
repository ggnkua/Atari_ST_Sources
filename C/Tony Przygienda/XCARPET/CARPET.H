/********************************************************************
 *
 *  carpet.h	, alles was xcarpet so braucht
 *
 *******************************************************************/
 
 /*  april 88	bernahme der quelle 'carpet.c' von tony przygienda
  *  13. 5.	auslagerung von 'xcarpet.inc'
  *   5. 5.	V1.3	ascii-daten von/zur datei
  *	 12.10. Umbennen in carpet.h, Anpassung an TURBO-C 
  */
  
#define TURBOC				1
#define MEGAMAX			0  
#define COMPILER       TURBOC

#define SCANFERROR		1
/* Fehler in der Turbo 1.0 Version in der Floatpoint- Library	*/
/* die Funktion liefert immer 0 oder sinnlose Werte zurck beim*/
/* Einlesen der Werte!														*/		
/* Falls Borland diese 'Wanze' rausnimmt, kann dieses define 	*/
/* wieder auf 0 gesetzt werden -> šberprfen der Eingabe			*/
/* zuschalten!																	*/

#if COMPILER==1
#define FDB		MFDB		/* kleine VDI-Unp„sslichkeit */
#define max(x,y)	((x>y) ? (x) : (y))
#define min(x,y)	((x<y) ? (x) : (y))
#endif
#if COMPILER==0
#define void 	int			/* sehr, sehr gef„hrlich sonst! */
#endif

#define boolean char

#define NIL  ((void *) 0L)

#define NO_WINDOW   -1

#define  FDOODLE  0
#define  FDEGAS   1
#define  FSTAD    2
#define  FASCII   3
#define  FIMG		4   /* gem img format */

#define WIREFRAME  0
#define HIDDENMODE 1
#define SHADOW     2

#define PI   3.14159265358979323846
#define PID2 1.57079632679489661923     /* PI divided by 2 */
#define PID4 0.78539816339744830962     /* PI divided by 4 */
#define I_PI 0.31830988618379067154     /* Inverse of PI */
#define I_PID2 0.63661977236758134308   /* Inverse of PID2 */

#define LWGET(x)    ( (WORD) *((WORD *)(x)) ) /* get word pointed by word */
#define LWSET(x,y)  ( *((WORD *)(x)) = y)     /* set word pointed by word */ 
#define LLGET(x)    ( *((LONG *)(x))         /* get long pointed by long */
#define LLSET(x,y)  ( *((LONG *)(x)) = y)     /* set long pointed by long */

