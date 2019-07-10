/*
 * msg.h
 *
 * 91Apr29 AA	Extracted from ctdl.h and elsewhere.
 */

#ifndef _MSG_H
#define _MSG_H

/*
 * message stuff
 */
#define MAXTEXT		10000	/* maximum chars in edit buffer 	*/
#define MAXWORD		256	/* maximum length of a word		*/
#define	ORGSIZE		40	/* length of an org field		*/

struct msgB {			/* This is what a msg looks like	*/
    long    mbid;		/* local number of message		*/
    LABEL   mbdate;		/* `D'-creation date			*/
    LABEL   mbtime;		/* `C'-creation time			*/
    LABEL   mbroom;		/* `R'-creation room			*/

    NETADDR mbauth;		/* `A'-name of author			*/
    NETADDR mbto;		/* `T'-private message to		*/
    char    mborg[ORGSIZE];	/* `I'-organisation field		*/
    char    mbsub[ORGSIZE];	/* `J'-subject field			*/

    long    flags;		/* `7F'-various `bits' of information	*/

    char    mbroute[NAMESIZE+2];/* `Z'-routing code of message		*/
    LABEL   mboname;		/* `N'-system name			*/
    LABEL   mborig;		/* `O'-US xxx xxx xxxx style ID		*/
    LABEL   mbdomain;		/* `X'-domain of originating system	*/
    long    mbsrcid;		/* `S'-ID on source system; for C-86	*/

    char    mbtext[MAXTEXT];	/* buffer text is edited in		*/
} ;

/*
 * message flags
 */
#define mIMPERVIOUS	0x0001L	/* Is this msg impervious to [S]top/etc.? */
#define mNETMESSAGE	0x0002L	/* Is this a networked message?		*/ 
#define mUUCPMESSAGE	0x0004L	/* Is this a message from UUCP?		*/
#define mMULTIMAIL	0x0008L	/* Does this mail msg have >1 recipient?*/
#define mANONMESSAGE	0x0010L	/* Is this an anonymous message?	*/
#define mTWITMESSAGE	0x0020L	/* Was this message entered by a TWIT?	*/
#define mSYSOPMESSAGE	0x0040L	/* Was this message entered by **GOD**?	*/
#define mPREFORMATTED	0x0080L	/* Was this message preformatted (& thus*/
				/* should not go thru the formatter)?	*/


#endif
