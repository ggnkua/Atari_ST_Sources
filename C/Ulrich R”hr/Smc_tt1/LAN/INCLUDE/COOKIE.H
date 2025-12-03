/********************************************************************/
/*																	*/
/*	Packet driver for AMD LANCE ethernet controller					*/
/*																	*/
/*	Copyleft by H. Wieser, 1992 TU-Vienna IAEE						*/
/*	All rights reserved												*/
/*																	*/
/********************************************************************/

/* cookie jar */


typedef struct
{
	long	id;
	long	val;
} COOKIE;

#define ENDCOOKIE	0L
#define NETENVCOOKIE 0x4e455443L			/* "NETC" */

COOKIE *new_cookiejar(long n);			/* create cookiejar,		*/
										/* if a bigger one exists,	*/
										/* get old one 				*/
COOKIE *get_cookiejar(void);			/* find start of cookijar 	*/
COOKIE *add_cookie(long id ,long val);	/* add a cookie, 			*/
										/* if no jar exists, 		*/
										/* create a new one and 	*/
										/* then add cookie			*/
COOKIE *get_cookie(long id);			/* find a specific cookie 	*/

