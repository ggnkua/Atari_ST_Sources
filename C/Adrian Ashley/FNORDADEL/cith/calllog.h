/*
 * calllog.h -- Call log stuff
 */

#ifndef _CALLLOG_H
#define _CALLLOG_H

#define BAUD		0	/* This message concerns baud rate	*/
#define L_IN		1	/*  "	   "	   "	 login		*/
#define L_OUT		2	/*  "	   "	   "	 logout 	*/
#define CARRLOSS	3	/*  "	   "	   "	 carr-loss	*/
#define FIRST_IN	4	/*  "	   "	   "	 init		*/
#define LAST_OUT	5	/*  "	   "	   "	 close-down	*/
#define EVIL_SIGNAL	6	/*  "	   "	   "	 user errors	*/
#define READ_FILE	7	/*  "      "       "     reading files  */
#define LOG_DEBUG	8	/*  "      "       "     debugging info */

#define	aEXIT	0x1		/* log system exits			*/
#define	aLOGIN	0x2		/* log logins				*/
#define	aDNLOAD	0x4		/* log downloads			*/

#endif
