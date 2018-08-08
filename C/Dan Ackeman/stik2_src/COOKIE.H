/* cookie jar */


typedef struct
{
	long	id;
	long	val;
} COOKIE;

#define ENDCOOKIE	0L

#define STIK_COOKIE 0x5354694BL

#define MACHINECOOKIE	0x5f4d4348L		/* "_MCH" */
#define TRAP_1 			33				/* GEMDOS TRAP */
#define TRAP_5 			37				/* GEMDOS TRAP */

COOKIE *new_cookiejar(long n);			/* create cookiejar,		*/
										/* if a bigger one exists,	*/
										/* get old one 				*/
COOKIE *get_cookiejar(void);			/* find start of cookijar 	*/
COOKIE *add_cookie(long id ,long val);	/* add a cookie, 			*/
										/* if no jar exists, 		*/
										/* create a new one and 	*/
										/* then add cookie			*/
COOKIE *get_cookie(long id);			/* find a specific cookie 	*/

