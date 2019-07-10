/*
 * Transfer protocol constants
 */

#ifndef _PROTOCOL_H
#define _PROTOCOL_H

#define ASCII 	0
#define VANILLA	1	/* "vanilla ascii" -- terminated by CAN-CAN */
#define XMODEM	2
#define	YMODEM	3
#define WXMODEM	4
#define KERMIT	5	/* Maybe */
#define	ZMODEM	6	/* Maybe */
#define	CAPTURE	7	/* capture to held message buffer */
#define	TODISK	8	/* archive to disk */

/*
 * modem stuff
 */
#define ERRORMAX       10	/* How many errors to suffer through	*/
#define STARTUP        YES	/* start a WC transfer			*/
#define FINISH	       NO	/* end a WC transfer			*/

#endif
