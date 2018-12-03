/* 
 *   Copyright (c) 1990 Rodney Volz
 *   ALL RIGHTS RESERVED 
 * 
 *   THIS SOFTWARE PRODUCT CONTAINS THE
 *   UNPUBLISHED SOURCE CODE OF RODNEY VOLZ
 *
 *   The copyright notices above do not evidence
 *   intended publication of such source code.
 *
 */

/*
 * MERCURY UUCP SOURCECODE [header.h]
 */


/* article header */
struct	hbuf {
	char	from[BUFLEN];		/* From:		*/
	char	path[PATHLEN];		/* Path:		*/
	char	nbuf[LBUFLEN];		/* Newsgroups:		*/
	char	title[BUFLEN];		/* Subject:		*/
	char	ident[BUFLEN];		/* Message-ID:		*/
	char	replyto[BUFLEN];	/* Reply-To:		*/
	char	followid[BUFLEN];	/* References:		*/
	char	subdate[DATELEN];	/* Date: (submission)	*/
	time_t	subtime;		/* subdate in secs	*/
	char	expdate[DATELEN];	/* Expires:		*/
	char	ctlmsg[PATHLEN];	/* Control:		*/
	char	sender[BUFLEN];		/* Sender:		*/
	char	followto[BUFLEN];	/* Followup-to:		*/
	char	distribution[BUFLEN];	/* Distribution:	*/
	char	organization[BUFLEN];	/* Organization:	*/
	char	numlines[8];		/* Lines:		*/
	int	intnumlines;		/* Integer version	*/
	char	keywords[BUFLEN];	/* Keywords:		*/
	char	summary[BUFLEN];	/* Summary:		*/
	char	approved[BUFLEN];	/* Approved:		*/
	char	nf_id[BUFLEN];		/* Nf-ID:		*/
	char	nf_from[BUFLEN];	/* Nf-From:		*/
	char 	supersedes[BUFLEN];	/* Supersedes:		*/
	char 	xref[BUFLEN];		/* Xref:		*/
	char	*unrec[NUNREC];		/* unrecognized lines	*/
};

