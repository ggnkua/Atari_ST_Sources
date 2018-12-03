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
 * MERCURY UUCP SOURCECODE [define.h]
 */

#ifndef DEFINED /* Already passed define.h ? */
#define DEFINED 1

#include <stdio.h>
#include <ctype.h>

#define FLASH		1	/* Flashing cursor? */
#define DEBUG		0	/* Debug? */
#define OLDFS		0	/* Old filesystem? */
#define LOG		0	/* Log every action? */
#define RTX		0	/* Use Beckmeyer's RTX? */
#define BELL		0	/* Fancy bell one/off */
#define COLOUR		0	/* Use Colours? */
#define SCR		0	/* Screen design? Graphical boxes? */

#define NEWSANZ		1024
#define LONGLEN		512
#define LLEN		255
#define FILEMODE	"0666"
#define CONFIG		"config.sys"
#define USER		"current.usr"

/*
   Please, if you compile your own Versions; don't change the first three
   digits of the Version number. Call your version something like
   Mercury Super-Mega-Blaster-UUCP V1.17.foobar.

   Thank you.
*/
#define VERSION		"Rodney's UUCP modules 02/11/90 V1.18"

#ifndef TRUE
#define TRUE		1
#endif

#ifndef FALSE
#define FALSE		0
#endif

#define exist(a)	((sfirst(a) < 0) ? FALSE : TRUE)
#define val(a)		(int)atoi(a)
#define lval(a)		(unsigned long)atol(a)
#define str(a,b)	sprintf(b,"%d",a)
#define strl(a,b)	sprintf(b,"%ld",a)
#define uu_getline(a,b)	getline(a,b)
#define uu_putline(a,b)	lineput(a,b,0)
#define putline(a,b)	lineput(a,b,1)
#define getprof(a,b)	_getinfo(USER,a,b,0)
#define getconf(a,b)	_getinfo(CONFIG,a,b,3)
#define sfirst(s)	(int)gemdos(78,s,55)
#define malloc(n)	ownmalloc(n)
#define valid(s)	(strlen((char *)trim(s)) > 1)
#define strchr		index

#define ROT	0
#define GELB	1
#define WEISS	2
#define BLAU	3


extern char *index();
extern char quiet;	/* Definition for sozobon C */

static char *envsearch[] =
{
	"LOGNAME","HOME","FULLNAME",
	"DRIVE","SITENAME","ORGA",
	"DOMAIN","LOGDIR","POSTMASTER",
	"UUCICO","COMPRESS","PASSWD",
	"REDIAL","MAILER","ACTIVE",
	"SYSFILE","MAILQ","HOSTS",
	"SPOOLDIR","RELAY","NEWSDIR",
	"DOMAINFILE","EDITOR","TEMP",
	"PATHSFILE","DES","UUENC",
	"UUDEC","PNEWS","SERVER",
	"SERVDIR",NULL
};



/* NEWS or MAIL article header */

struct header {
	char	file[80];		/* Mail-file name	*/
	char	from[80];		/* From: (Address)	*/
	char	fromfull[80];		/* From: (Fullname)	*/
	char	to[80];			/* To: (Address)	*/
	char	tofull[80];		/* To: (Fullname)	*/
	char	cc[80];			/* Cc:			*/
	char	path[LONGLEN];		/* Path:		*/
	char	nbuf[LLEN];		/* Newsgroups:		*/
	char	subject[80];		/* Subject:		*/
	char	id[80];			/* Message-ID:		*/
	char	replyto[80];		/* Reply-To: (Addresse)	*/
	char	replytofull[80];	/* Reply-To: (Fullname)	*/
	char	refer[LONGLEN];		/* References:		*/
	char	date[80];		/* Date: (submission)	*/
	char	expire[80];		/* Expires:		*/
	char	posted[80];		/* Posted:		*/
	char	control[80];		/* Control:		*/
	char	sender[80];		/* Sender: (addresse)	*/
	char	senderfull[80];		/* Sender: (Fullname)	*/
	char	followto[LLEN];		/* Followup-to:		*/
	char	distribution[80];	/* Distribution:	*/
	char	organization[80];	/* Organization:	*/
	char	lines[16];		/* Lines:		*/
	char	keywords[80];		/* Keywords:		*/
	char	summary[80];		/* Summary:		*/
	char	apparent[80];		/* Apparently-from:	*/
	char	apparentfull[80];	/* Apparently-from: (full) */
	char	approved[80];		/* Approved:		*/
	char	approvedfull[80];	/* Approved: (Fullname)	*/
	char	nf_id[80];		/* Nf-ID:		*/
	char	nf_from[80];		/* Nf-From:		*/
	char 	supersedes[80];		/* Supersedes:		*/
	char 	xref[80];		/* Xref:		*/
};

struct dta {
	char reserved[21];
	char atr;
	int time;
	int date;
	long length;
	char fname[14];
};

struct passwd {
	char pw_name[20];
	char pw_passwd[20];
	int pw_uid;
	int pw_gid;
	char pw_gecos[80];
	char pw_dir[80];
	char pw_shell[80];
};

#if SCR
#else
#undef SCR
#endif


/* DO NOT DEFINE THIS! */
#if RTX
#else
#undef RTX
#endif

#endif DEFINED
