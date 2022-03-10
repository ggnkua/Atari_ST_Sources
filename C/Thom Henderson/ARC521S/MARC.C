/*
 * $Header: marc.c,v 1.5 88/08/01 14:19:19 hyc Exp $
 */

/*  MARC - Archive merge utility

    Version 5.21, created on 04/22/87 at 15:05:10

(C) COPYRIGHT 1985-87 by System Enhancement Associates; ALL RIGHTS RESERVED

    By:	 Thom Henderson

    Description:
	 This program is used to "merge" archives.  That is, to move
	 files from one archive to another with no data conversion.
	 Please refer to the ARC source for a description of archives
	 and archive formats.

    Instructions:
	 Run this program with no arguments for complete instructions.

    Language:
	 Computer Innovations Optimizing C86
*/
#include <stdio.h>
#include "arc.h"

#if	UNIX
#include <sys/types.h>
#include <sys/stat.h>
#endif

FILE *src;			       /* source archive */
char srcname[STRLEN];		       /* source archive name */

static char **lst;		       /* files list */
static int lnum;		       /* length of files list */


main(nargs,arg)			       /* system entry point */
int nargs;			       /* number of arguments */
char *arg[];			       /* pointers to arguments */
{
    char *makefnam();		       /* filename fixup routine */
#ifndef __STDC__
    char *calloc();		       /* memory manager */
    char *envfind();
#endif
#if	!MTS
    char *arctemp2;
#ifndef __STDC__
    char *mktemp();		/* temp file stuff */
#endif
#endif
#if	GEMDOS
    void exitpause();
#endif
    int n;			       /* index */
#if	UNIX
    struct	stat	sbuf;
#endif


    if(nargs<3)
    {	 printf("MARC - Archive merger, Version 5.21, created on 04/22/87 at 15:05:10\n");
/*	 printf("(C) COPYRIGHT 1985,86,87 by System Enhancement Associates;");
	 printf(" ALL RIGHTS RESERVED\n\n");
	 printf("Please refer all inquiries to:\n\n");
	 printf("	System Enhancement Associates\n");
	 printf("	21 New Street, Wayne NJ 07470\n\n");
	 printf("You may copy and distribute this program freely,");
	 printf(" provided that:\n");
	 printf("    1)	  No fee is charged for such copying and");
	 printf(" distribution, and\n");
	 printf("    2)	  It is distributed ONLY in its original,");
	 printf(" unmodified state.\n\n");
	 printf("If you like this program, and find it of use, then your");
	 printf(" contribution will\n");
	 printf("be appreciated.  You may not use this product in a");
	 printf(" commercial environment\n");
	 printf("or a governmental organization without paying a license");
	 printf(" fee of $35.  Site\n");
	 printf("licenses and commercial distribution licenses are");
	 printf(" available.  A program\n");
	 printf("disk and printed documentation are available for $50.\n");
	 printf("\nIf you fail to abide by the terms of this license, ");
	 printf(" then your conscience\n");
	 printf("will haunt you for the rest of your life.\n\n");
*/
	 printf("Usage: MARC <tgtarc> <srcarc> [<filename> . . .]\n");
	 printf("Where: <tgtarc> is the archive to add files to,\n");
	 printf("	<srcarc> is the archive to get files from, and\n");
	 printf("	<filename> is zero or more file names to get.\n");
	 printf("\nAdapted from MSDOS by Howard Chu\n");
#if	GEMDOS
	 exitpause();
#endif
	 return 1;
    }

	/* see where temp files go */
#if	!MTS
	arctemp = calloc(1, STRLEN);
	if (!(arctemp2 = envfind("ARCTEMP")))
		arctemp2 = envfind("TMPDIR");
	if (arctemp2) {
		strcpy(arctemp, arctemp2);
		n = strlen(arctemp);
		if (arctemp[n - 1] != CUTOFF)
			arctemp[n] = CUTOFF;
	}
#if	UNIX
	else	strcpy(arctemp, "/tmp/");
#endif
#if	!MSDOS
	{
		static char tempname[] = "AXXXXXX";
		strcat(arctemp, mktemp(tempname));
	}
#else
	strcat(arctemp, "$ARCTEMP");
#endif
#else
	guinfo("SHFSEP	", gotinf);
	sepchr[0] = gotinf[0];
	guinfo("SCRFCHAR", gotinf);
	tmpchr[0] = gotinf[0];
	arctemp = "-$$$";
	arctemp[0] = tmpchr[0];
#endif

#if	UNIX
	if (!stat(arg[1],&sbuf))
		strcpy(arcname,arg[1]);
	else
		makefnam(arg[1],".arc",arcname);
	if (!stat(arg[2],&sbuf))
		strcpy(srcname,arg[2]);
	else
		makefnam(arg[2],".arc",srcname);
#else
    makefnam(arg[1],".ARC",arcname);   /* fix up archive names */
    makefnam(arg[2],".ARC",srcname);
/*	makefnam(".$$$",arcname,newname);*/
	sprintf(newname,"%s.arc",arctemp);
#endif

    arc = fopen(arcname,OPEN_R);	       /* open the archives */
    if(!(src=fopen(srcname,OPEN_R)))
	 abort("Cannot read source archive %s",srcname);
    if(!(new=fopen(newname,OPEN_W)))
	 abort("Cannot create new archive %s",newname);

    if(!arc)
	 printf("Creating new archive %s\n",arcname);

    /* get the files list set up */

    lnum = nargs-3;		       /* initial length of list */
    if(lnum<1)			       /* phoney for default case */
    {	 lnum = 1;
	 lst = (char **) calloc(1,sizeof(char *));
	 lst[0] = "*.*";
    }
    else			       /* else use filenames given */
    {	 lst = (char **) calloc(lnum,sizeof(char *));
	 for(n=3; n<nargs; n++)
	      lst[n-3] = arg[n];

	 for(n=0; n<lnum; )	       /* expand indirect references */
	 {    if(*lst[n] == '@')
		   expandlst(n);
	      else n++;
	 }
    }

    merge(lnum,lst);		       /* merge desired files */

    if(arc) fclose(arc);	       /* close the archives */
    fclose(src);
    fclose(new);

    if(arc)			       /* make the switch */
	 if(unlink(arcname))
	      abort("Unable to delete old copy of %s",arcname);
    if(move(newname,arcname))
	 abort("Unable to rename %s to %s",newname,arcname);

    setstamp(arcname,arcdate,arctime);     /* new arc matches newest file */

#if	GEMDOS
    exitpause();
#endif
    return nerrs;
}

merge(nargs,arg)		       /* merge two archives */
int nargs;			       /* number of filename templates */
char *arg[];			       /* pointers to names */
{
    struct heads srch;		       /* source archive header */
    struct heads arch;		       /* target archive header */
    int gotsrc, gotarc;		       /* archive entry versions (0=end) */
    int copy;			       /* true to copy file from source */
    int n;			       /* index */

    gotsrc = gethdr(src,&srch);	       /* get first source file */
    gotarc = gethdr(arc,&arch);	       /* get first target file */

    while(gotsrc || gotarc)	       /* while more to merge */
    {	 if(strcmp(srch.name,arch.name)>0)
	 {    copyfile(arc,&arch,gotarc);
	      gotarc = gethdr(arc,&arch);
	 }

	 else if(strcmp(srch.name,arch.name)<0)
	 {    copy = 0;
	      for(n=0; n<nargs; n++)
	      {	   if(match(srch.name,arg[n]))
		   {	copy = 1;
			break;
		   }
	      }
	      if(copy)		       /* select source or target */
	      {	   printf("Adding file:	  %s\n",srch.name);
		   copyfile(src,&srch,gotsrc);
	      }
	      else fseek(src,srch.size,1);
	      gotsrc = gethdr(src,&srch);
	 }

	 else			       /* duplicate names */
	 {    copy = 0;
	      {	   if((srch.date>arch.date)
		   || (srch.date==arch.date && srch.time>arch.time))
		   {	for(n=0; n<nargs; n++)
			{    if(match(srch.name,arg[n]))
			     {	  copy = 1;
				  break;
			     }
			}
		   }
	      }
	      if(copy)		       /* select source or target */
	      {	   printf("Updating file: %s\n",srch.name);
		   copyfile(src,&srch,gotsrc);
		   gotsrc = gethdr(src,&srch);
		   if(gotarc)
		   {	fseek(arc,arch.size,1);
			gotarc = gethdr(arc,&arch);
		   }
	      }
	      else
	      {	   copyfile(arc,&arch,gotarc);
		   gotarc = gethdr(arc,&arch);
		   if(gotsrc)
		   {	fseek(src,srch.size,1);
			gotsrc = gethdr(src,&srch);
		   }
	      }
	 }
    }

    hdrver = 0;			       /* end of archive marker */
    writehdr(&arch,new);	       /* mark the end of the archive */
}

int gethdr(f,hdr)		       /* special read header for merge */
FILE *f;			       /* file to read from */
struct heads *hdr;		       /* storage for header */
{
    char *i = hdr->name;	       /* string index */
    int n;			       /* index */

    for(n=0; n<FNLEN; n++)	       /* fill name field */
	 *i++ = 0176;		       /* impossible high value */
    *--i = '\0';		       /* properly end the name */

    hdrver = 0;			       /* reset header version */
    if(readhdr(hdr,f))		       /* use normal reading logic */
	 return hdrver;		       /* return the version */
    else return 0;		       /* or fake end of archive */
}

copyfile(f,hdr,ver)		       /* copy a file from an archive */
FILE *f;			       /* archive to copy from */
struct heads *hdr;		       /* header data for file */
int ver;			       /* header version */
{
    hdrver = ver;		       /* set header version */
    writehdr(hdr,new);		       /* write out the header */
    filecopy(f,new,hdr->size);	       /* copy over the data */
}

static expandlst(n)		       /* expand an indirect reference */
int n;				       /* number of entry to expand */
{
    FILE *lf;				/* list file */
#ifndef __STDC__
    FILE *fopen();		       /* opener */
    char *malloc(), *realloc();	       /* memory managers */
#endif
    char buf[100];		       /* input buffer */
    int x;			       /* index */
    char *p = lst[n]+1;		       /* filename pointer */

    if(*p)			       /* use name if one was given */
    {	 makefnam(p,".CMD",buf);
	 upper(buf);
	 if(!(lf=fopen(buf,"r")))
	      abort("Cannot read list of files in %s",buf);
    }
    else lf = stdin;		       /* else use standard input */

    for(x=n+1; x<lnum; x++)	       /* drop reference from the list */
	 lst[x-1] = lst[x];
    lnum--;

    while(fscanf(lf,"%99s",buf)>0)     /* read in the list */
    {	 if(!(lst=(char **) realloc(lst,(lnum+1)*sizeof(char *))))
	      abort("too many file references");

	 lst[lnum] = malloc(strlen(buf)+1);
	 strcpy(lst[lnum],buf);	       /* save the name */
	 lnum++;
    }

    if(lf!=stdin)		       /* avoid closing standard input */
	 fclose(lf);
}
