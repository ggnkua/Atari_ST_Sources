/*
 *	man - on-line documentation
 *
 *	This version uses "manpager" or "less" for paging.
 *
 *	compile: cc -s -nf -o man man.c (needs stat, chdir)
 *
 *	search order (based on my manpage nomenclature):
 *
 *	man1\*.1[tcgesla]	cmds	util & text,com,graphics,edit,shell,
 *					lang, archival
 *	man0\*.0		gen
 *	man8\*.8[s]		admin	util & system
 *	man2\*.2[gbx]		syslib	system & gemdos,bios,xbios
 *	man3\*.3[msvcxg]	libs	C lib & math,stdio,sysV,compat,
 *					extra,gem(aes/vdi)
 *	man4\*.4[dkvscm]	h/w	gen & disk,keyboard,video,sound,chips,
 *					memory
 *	man5\*.5		files
 *	man7\*.7		misc
 *	man6\*.6		games
 *
 *	these are seached only if given sections "local", "new", "old":
 *
 *	manl\*.l		local
 *	mann\*.n		new
 *	mano\*.o		old
 */

static char *sccsid  = "@(#) man 2.2 91/1/27 rosenkra\0                  ";
static char *version = "man v2.2 91/1/27 rosenkra\0                      ";
static char *myname  = "man\0\0\0\0\0\0\0";

#include <stdio.h>
#include <ctype.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <string.h>


/*
 *	common (default) places. note the patch space...
 */
#define	MANDIR		"c:\\man\0\0\0                           "
#define BINDIR		"c:\\bin\0\0\0                           "
#define TMPDIR		"g:\\tmp\0\0\0                           "

#define MORE		"less.ttp\0    "/* could use -m -s also */
#ifdef HAS_CAT
# define CAT		"cat.ttp\0     "/* for '-' opt, unix uses "cat -s" */
#endif
#ifdef HAS_UL
# define UL		"ul.ttp\0      "/* for '- -ul' opt (no more) */
#endif
#ifdef HAS_APROPOS
# define APROPOS	"apropos.ttp\0 "
#endif
#ifdef HAS_WHATIS
# define WHATIS		"whatis.ttp\0  "
#endif

#define	ALLSECT		"108234576"	/* order to look through sections */
#define SUBSEC0		""		/* subsec to try in each section */
#define	SUBSEC1		"tcgesla"
#define	SUBSEC2		"gbx"
#define	SUBSEC3		"msvcxg"
#define	SUBSEC4		"dkvscm"
#define SUBSEC5		""
#define SUBSEC6		""
#define SUBSEC7		""
#define	SUBSEC8		"s"
#define SUBSEC9		""

#define ZSUFFIX		'z'		/* for compressed files */
#define ZSWITCH		"-z"		/* for MANPAGER to read compressed file */

#ifdef dbg
# undef dbg
#endif
#ifdef lastchar
# undef lastchar
#endif
#ifdef plastchar
# undef plastchar
#endif
#define dbg(x)		if(debugging_G)printf x
#define lastchar(s)	((s)[strlen(s)-1])	/* last char in a string */
#define plastchar(s)	&((s)[strlen(s)-1])	/* ptr to it */



/*
 *	globals:
 */
#ifdef HAS_UL
int		ul4cat_G  = 0;		/* use ul instead of cat */
#endif
int		debugging_G = 0;
int		hasmanpager_G = 0;	/* if pager is MANPAGER */
int		usermanpath_G = 0;	/* if -M */
int     	nopager_G  = 0;		/* if no pager of any kind */
int		pthpager_G = 0;		/* if pager has a full path */
char	       *manpath_G = 0L;
char	       *binpath_G = 0L;
char	       *tmppath_G = 0L;
char	       *pager_G   = 0L;
char		cmdbuf_G[512];
int     	section_G = 0;		/* section, ascii char */
int     	subsec_G = 0;		/* subsection, ascii char */



/*
 *	functions:
 */
extern char    *index ();
extern char    *getenv ();

int		set_section ();
int		find_manpage ();
int		do_it ();
char	       *so_line ();
int		usage ();




/*------------------------------*/
/*	main			*/
/*------------------------------*/
main (argc, argv)
int     argc;
char   *argv[];
{
	char   *ps;
	int	retcode;



	/*
	 *  must have an arg
	 */
	argc--, argv++;
	if (argc < 1)
	{
		usage (1);
	}



	/*
	 *   parse cmdline. it overrides defaults and environment...
	 */
	while (argc > 0 && argv[0][0] == '-')
	{
		switch (argv[0][1])
		{

		case 0:				/* use cat (just a "-") */
#ifdef HAS_CAT
			nopager_G++;
#else
			fprintf (stderr, "%s: cat and not supported\n");
			usage (1);
#endif
			break;

		case 'M':			/* reset path (-M path) */
			argc--, argv++;
			manpath_G     = *argv;
			usermanpath_G = 1;
			break;

		case 'u':			/* use ul(1) for cat */
#ifdef HAS_UL
			ul4cat_G++;
#else
			fprintf (stderr, "%s: ul not supported\n");
			usage (1);
#endif
			break;

		case 's': 			/* specific section */
			switch (--argc)
			{
			case 0:			/* Nothing follows -s */
				fprintf (stderr,
					"%s: must specify a section with -s\n",
					myname);
				usage (1);

			case 1: 		/* Section, but no man page */
				fprintf (stderr,
					"%s: must specify an item from section %s\n",
					myname, argv[1]);
				usage (1);

			default: 
				/*
				 *   if valid section, set_section sets section_G
				 */
				if (set_section (*++argv) == 0)
				{
					fprintf (stderr,
						"%s: unknown section: %s\n",
						myname, *argv);
					usage (1);
				}
				break;
			}
			break;

		case 'f':			/* whatis */
		case 'w':
#ifdef HAS_WHATIS
			strcpy (cmdbuf_G, binpath_G);
			if (lastchar (cmdbuf_G) != '\\')
				strcat (cmdbuf_G, "\\");
			strcat (cmdbuf_G, WHATIS);
			argc--, argv++;
			while (argc)
			{
				strcat (cmdbuf_G, " ");
				strcat (cmdbuf_G, *argv);
				argc--, argv++;
			}
			dbg(("whatis, system (%s)\n",cmdbuf_G));
			retcode = system (cmdbuf_G);

			exit (retcode);
#else
			fprintf (stderr, "%s: whatis not supported\n");
			usage (1);
#endif
			break;
			
		case 'k':			/* apropos */
		case 'a':
#ifdef HAS_APROPOS
			strcpy (cmdbuf_G, binpath_G);
			if (lastchar (cmdbuf_G) != '\\')
				strcat (cmdbuf_G, "\\");
			strcat (cmdbuf_G, APROPOS);
			argc--, argv++;
			while (argc)
			{
				strcat (cmdbuf_G, " ");
				strcat (cmdbuf_G, *argv);
				argc--, argv++;
			}
			dbg(("apropos, system (%s)\n",cmdbuf_G));
			retcode = system (cmdbuf_G);

			exit (retcode);
#else
			fprintf (stderr, "%s: apropos not supported\n");
			usage (1);
#endif
			break;
			
		case 'h':			/* help */
			usage (0);
			break;

		case 'd':			/* turn on debugging */
			debugging_G = 1;
			break;

		case 'v':			/* version */
			printf ("%s\n", version);
			exit (0);
			break;

		}
		argc--, argv++;
	}




	/*
	 *   check environment (cmdline still overrules things)
	 *
	 *   alternate pager from environment
	 */
	if (pager_G == (char *) NULL)
	{
		if ((ps = getenv ("MANPAGER")) != (char *) NULL)
		{
			hasmanpager_G = 1;
			pager_G       = ps;
		}
		else if ((ps = getenv ("PAGER")) != (char *) NULL)
			pager_G = ps;
		else
			pager_G = MORE;
	}
	if (pager_G && (index (pager_G, ':') || index (pager_G, '\\')))
		pthpager_G = 1;
	dbg(("pager_G = |%s|, pthpager_G = %d\n",(pager_G ? pager_G : "NULL"), pthpager_G));




	/*
	 *   place to find pagers
	 */
	if (binpath_G == (char *) NULL)
	{
		if ((ps = getenv ("BINDIR")) != (char *) NULL)
			binpath_G = ps;
		else
			binpath_G = BINDIR;
	}
	if (binpath_G && lastchar (binpath_G) == '\\')/* remove trailing '\' */
		lastchar (binpath_G) = '\0';
	dbg(("binpath_G = |%s|\n", binpath_G ? binpath_G : "NULL"));



	/*
	 *   place to put temp files, if needed (not needed yet...)
	 */
	if (tmppath_G == (char *) NULL)
	{
		if ((ps = getenv ("TMPDIR")) != (char *) NULL)
			tmppath_G = ps;
		else
			tmppath_G = TMPDIR;
	}
	if (tmppath_G && lastchar (tmppath_G) == '\\')/* remove trailing '\' */
		lastchar (tmppath_G) = '\0';
	dbg(("tmppath_G = |%s|\n", tmppath_G ? tmppath_G : "NULL"));




	/*
	 *   where man pages are (e.g. c:\man)
	 */
	if (manpath_G == (char *) NULL)
	{
		if ((ps = getenv ("MANPATH")) != (char *) NULL)
			manpath_G = ps;
		else
			manpath_G = MANDIR;
	}
	if (manpath_G && lastchar (manpath_G) == '\\')/* remove trailing '\' */
		lastchar (manpath_G) = '\0';
	dbg(("manpath_G = |%s|\n", manpath_G ? manpath_G : "NULL"));




	/*
	 *   If there are multiple words, no -s seen above, and the first
	 *   word is a valid section name, read the subsequent man pages
 	 *   from that section. set_section will set section_G if *argv is a
 	 *   bona fide section.
	 */
	if ((argc > 1) && (section_G == 0) && set_section (*argv))
	{
		argc--;
		argv++;
	}



	/*
	 *   move to correct directory. no need to move if it is cwd...
	 */
	if (strcmp (manpath_G, ".") && (chdir (manpath_G) < 0))
	{
		fprintf (stderr, "%s: can't chdir to %s.\n", myname, manpath_G);
		exit (1);
	}



	/*
	 *   check if stdout not a tty an no pager.
	 */
#if 0
	if (nopager_G == 0 && !isatty (1))
		nopager_G++;
#endif
	dbg(("nopager_G = %d, isatty(1) = %d\n", nopager_G, (int) isatty(1)));



	/*
	 *   do it for all remaining tokens
	 */
	while (argc-- > 0)
	{
		retcode = find_manpage (*argv++);

		if (retcode)
		{
			fprintf (stderr, "%s: failed!!!\n", myname);
			exit (retcode);
		}
	}

	exit (0);
}




/*------------------------------*/
/*	set_section		*/
/*------------------------------*/
int set_section (cptr)
char   *cptr;
{

/*
 *	routine to set section_G and subsec_G from a given section name,
 *	returning the letter of the section used or a zero if an unfamiliar
 *	keyword is used.
 */

	int	sec;
	int	sub;
	int	ret;

	if (strlen (cptr) > 2)
	{
		/*
		 *   section is 3 or more char
		 */
		if (!strcmp (cptr, "local"))
			return ((int) (section_G = 'l'));
		if (!strcmp (cptr, "new"))
			return ((int) (section_G = 'n'));
		if (!strcmp (cptr, "old"))
			return ((int) (section_G = 'o'));

		/* 
		 *   If we reach here, none of the special names match,
		 *   and we'll return a zero (error) on the other side of
		 *   the else. 
		 */
		section_G = '\0';
		subsec_G  = '\0';
		ret       = 0;
	}
	else
	{
		/*
		 *   section is 2 or less char. subsec could be 0
		 */
		section_G = (int) cptr[0];
		subsec_G  = (int) cptr[1];
		ret       = section_G;


		/*
		 *   crude check for legality: section must be 0-8, subsect
		 *   must be a letter
		 */
		sec = section_G - '0';
/*!!!*/		if (sec < 0 || sec > 9)
			ret = 0;
		if (subsec_G)
		{
			if (!isalpha (subsec_G))
				ret = 0;
		}
	}

	/*
	 *   ret is 0 if invalid section, else section number
	 */
	return (ret);
}





/*------------------------------*/
/*	find_manpage		*/
/*------------------------------*/
int find_manpage (name)
char   *name;
{

/*
 *	find the manpage file
 */

	char    	c_sectn;
	char    	c_subs;
	char    	work[256];
	struct stat     stbuf;
	int     	stflag;
	int     	last;
	char		seclist[30];
	char		sublist[30];
	char	       *psec;
	char	       *psub;
	char	       *ps;
	char	       *cp;
	int		iscompressed = 0;



	/*
	 *   set up template (we removed any trailing '\' already)
	 */
	if (usermanpath_G)
		sprintf (work,  "%s\\%s.x", manpath_G, name);
	else
		sprintf (work,  "%s\\manx\\%s.x", manpath_G, name);



	/*
	 *   index of last char in template. this should be section.
	 *   work[last+1] is subsection, and work[last+2] will be ZSUFFIX
	 *   if compressed and we are using MANPAGER.
	 */
	last = strlen (work) - 1;
	dbg(("template, work = |%s|, last = %d\n", work, last));



	/*
	 *   set up list of sections to search. either use section_G or
	 *   ALLSECT
	 */
	if (section_G)
	{
		seclist[0] = (char) section_G;
		seclist[1] = '\0';
	}
	else
	{
		strcpy (seclist, ALLSECT);
	}
	psec = seclist;
	if (subsec_G)
	{
		sublist[0] = (char) subsec_G;
		sublist[1] = '\0';
		psub = sublist;
	}
	else
		psub = (char *) NULL;
	dbg(("psec = |%s|, psub = |%s|\n", psec, (psub ? psub : "NULL")));



	/*
	 *   find manx string in template. ps points to the '\'
	 */
	if (!usermanpath_G)
	{
		for (ps = work; *ps; ps++)
		{
			if (!strncmp (ps, "\\man", 4) && *(ps+5) == '\\')
				break;
		}
	}



	/*
	 *   loop thru all sections. could be only specified section
	 */
	for (c_sectn = *psec; c_sectn; c_sectn = *++psec)
	{
		/*
		 *   fill in template: man_\xxx._\0\0 (no sub yet)
		 */
		if (!usermanpath_G)
			ps[4] = c_sectn;

		work[last]     = c_sectn;
		work[last + 1] = 0;
		work[last + 2] = 0;
		work[last + 3] = 0;


		/*
		 *   if a subsection was specified, skip past this...
		 */
		if (subsec_G)
			goto SEARCH;


		/*
		 *   does this file exist?
		 */
		dbg(("try |%s|...\n", work));
		if ((stflag = stat (work, &stbuf)) >= 0)
		{
			/*
			 *   yes...exit this for loop
			 */
			goto FOUND_ONE;
		}


		/*
		 *   no...try looking for compressed version
		 */
		if (hasmanpager_G)
		{
			dbg(("not found, try compressed file...\n"));

			work[last + 1] = ZSUFFIX;
			work[last + 2] = '\0';
			work[last + 3] = '\0';
			dbg(("try |%s|...\n", work));
			if ((stflag = stat (work, &stbuf)) >= 0)
			{
				/*
				 *   yes...
				 */
				iscompressed = 1;
				goto FOUND_ONE;
			}
			work[last + 1] = '\0';	/* reset! */

			dbg(("not found...\n"));
		}


SEARCH: 
		/*
		 *   still not found...look for subsections in manx
		 *
		 *   set up subsect string
		 */
		if (subsec_G)
			cp = psub;
		else
		{
			/*
			 *   take the default subsections for a section...
			 */
			switch (work[last])
			{
			case '0': 	cp = SUBSEC0;		break;
			case '1': 	cp = SUBSEC1;		break;
			case '2': 	cp = SUBSEC2;		break;
			case '3': 	cp = SUBSEC3;		break;
			case '4': 	cp = SUBSEC4;		break;
			case '5': 	cp = SUBSEC5;		break;
			case '6': 	cp = SUBSEC6;		break;
			case '7': 	cp = SUBSEC7;		break;
			case '8': 	cp = SUBSEC8;		break;
			case '9': 	cp = SUBSEC9;		break;
			default: 	cp = "";		break;
			}
		}
		dbg(("not found, try subsect, cp = |%s|\n", cp));


		/*
		 *   cycle thru subsections
		 */
		while (*cp)
		{
			/*
			 *   do we find one now?
			 */
			work[last + 1] = *cp++;
			work[last + 2] = '\0';
			dbg(("try |%s|...\n", work));
			if ((stflag = stat (work, &stbuf)) >= 0)
			{
				/*
				 *   yes...
				 */
				goto FOUND_ONE;
			}


			/*
			 *   still no...try compressed...
			 */
			if (hasmanpager_G)
			{
				dbg(("not found, try compressed file...\n"));

				work[last + 2] = ZSUFFIX;
				work[last + 3] = '\0';
				dbg(("try |%s|...\n", work));
				if ((stflag = stat (work, &stbuf)) >= 0)
				{
					/*
					 *   yes...
					 */
					iscompressed = 1;
					goto FOUND_ONE;
				}
				work[last + 2] = '\0';	/* reset! */

				dbg(("not found...\n"));
			}
			/* we give up. try next subsection, if any... */
		}
		/* we give up. try next section, if any... */
	}

	if (section_G == 0)
		printf ("%s: no manual entry for %s. try man local %s\n",
			myname, name, name);
	else
		printf ("%s: no entry for %s in section %c%c of the manual.\n",
			myname, name,
			(char) section_G,
			(subsec_G ? (char) subsec_G : ' '));
	return;


FOUND_ONE: 
	dbg(("Found: %s(%x), iscompressed = %d\n",work,stflag,iscompressed));

	return ((int) do_it (work, iscompressed));
}




/*------------------------------*/
/*	do_it			*/
/*------------------------------*/
int do_it (cp, iscompressed)
char   *cp;
int	iscompressed;
{
	char	cmdpath[256];
	char    cmd[256];
	char   *so;




	/*
	 *   open the file, look for ".so file" as first line. use that file
	 *   instead. only one level of this nesting is possible (the
	 *   included file can't include, too). do this only if file not
	 *   compressed!
	 */
	dbg(("enter do_it, cp = |%s|...\n", cp));
	if (!iscompressed)
	{
		so = so_line (cp);
		if (so)
		{
			cp = so;
			dbg(("so_line found something, new cp = |%s|...\n",cp));
		}
	}


	/*
	 *   set up command path (for paging)
	 */
	strcpy (cmdpath, binpath_G);
	if (lastchar (cmdpath) != '\\')
		strcat (cmdpath, "\\");
	if (!nopager_G)
	{
		/*
		 *   use pager. if compressed, add correct switch (note:
		 *   iscompressed set only if hasmanpager is true)
		 */
		if (iscompressed)
		{
			sprintf (cmd, "%s%s %s %s",
				(pthpager_G ? "" : cmdpath),
				pager_G,
				ZSWITCH,
				cp);
		}
		else
		{
			sprintf (cmd, "%s%s %s",
				(pthpager_G ? "" : cmdpath),
				pager_G,
				cp);
		}
	}
#ifdef HAS_UL
	else if (ul4cat_G)
	{
		/*
		 *   use ul rather than cat if no pager
		 */
		sprintf (cmd, "%s%s %s", cmdpath, UL, cp);
	}
#endif
#ifdef HAS_CAT
	else
	{
		/*
		 *   use cat if no pager
		 */
		sprintf (cmd, "%s%s %s", cmdpath, CAT, cp);
	}
#endif

	/*
	 *   invoke the pager (or cat or ul)
	 */
	dbg(("system (%s)\n", cmd));

	return ((int) system (cmd));
}




/*------------------------------*/
/*	so_line			*/
/*------------------------------*/
char *so_line (fname)
char   *fname;
{

/*
 *	read first line from found file, looking for ".so " followed by
 *	alternate sourced file. if found, returns ptr to the new name.
 *	otherwise, null.
 *
 *	the file name should include the path of the subsection, e.g.
 *	the file for degas.5 (in man5) contains:
 *
 *		.so man5\picture.5
 *
 *	the rest of the file (man5\degas.5) is ignored.
 */

	char	buf[256];
	char   *so;
	FILE   *stream;

	so = (char *) 0;

	if ((stream = fopen (fname, "r")) == (FILE *) 0)
	{
		printf ("%s: could not open %s to look for .so\n",
				myname, fname);
		return (so);
	}

	/*
	 *   grab first line, delete newline
	 */
	fgets (buf, 255, stream);
	fclose (stream);
	so = buf;
	while (*++so)
		;
	*--so = '\0';

	/*
	 *   is it .so?
	 */
	so = buf;
	if (!strncmp (so, ".so ", 4))
	{
		so += 4;
		while (*so == ' ' || *so == '\t')
			so++;
		dbg(("so_line returning |%s|\n", so));

		return (so);
	}
	else
	{
		dbg(("so_line returning NULL\n"));

		return ((char *) 0);
	}
}


#define FP		fprintf

/*------------------------------*/
/*	usage			*/
/*------------------------------*/
usage (excode)
int	excode;
{
#if 0
FP (stderr, "Usage: %s [-s sec[sub]] [-M dir] [- [-ul]] [-k key] [-f file] [sec[sub]] name\n", myname);
#endif
FP (stderr, "\nUsage: %s [-s sec[sub]] [-M dir] ", myname);
#ifdef HAS_CAT
# ifdef HAS_UL
FP (stderr, "[- [-ul]] ");
# else
FP (stderr, "[-] ");
# endif
#endif
#ifdef HAS_APROPOS
FP (stderr, "[-k key] ");
#endif
#ifdef HAS_WHATIS
FP (stderr, "[-f file] ");
#endif
FP (stderr, "[sec[sub]] name\n");
FP (stderr, "       -s sec[sub]        section/subsect (e.g. 2g)\n");
FP (stderr, "       -M dir             specify search dir\n");
#ifdef HAS_CAT
FP (stderr, "       -                  use cat rather than more or less\n");
# ifdef HAS_UL
FP (stderr, "       -ul                use ul rather than cat\n");
# endif
#endif
#ifdef HAS_APROPOS
FP (stderr, "       -k key             do apropos on keyword\n");
#endif
#ifdef HAS_WHATIS
FP (stderr, "       -f file            do whatis on file\n");
#endif
FP (stderr, "       sec                section, alternate for -s\n");
FP (stderr, "       sub                subsection, alternate for -s\n");
FP (stderr, "       name               desired entry (command, etc)\n");
FP (stderr, "Search order:\n");
FP (stderr, "       man1\\*.1[tcgesla]  cmds    util & text,com,graphics,edit,shell,\n");
FP (stderr, "                                  lang, archival\n");
FP (stderr, "       man0\\*.0           gen\n");
FP (stderr, "       man8\\*.8[s]        admin   util & system\n");
FP (stderr, "       man2\\*.2[gbx]      syslib  system & gemdos,bios,xbios\n");
FP (stderr, "       man3\\*.3[msvcg]    libs    C lib & math,stdio,sysV,compat,gem(aes/vdi)\n");
FP (stderr, "       man4\\*.4[dkvsc]    h/w     gen & disk,keyboard,video,sound,chips\n");
FP (stderr, "       man5\\*.5           files\n");
FP (stderr, "       man7\\*.7           misc\n");
FP (stderr, "       man6\\*.6           games\n");
FP (stderr, "Other sections:           local, new, old\n");
FP (stderr, "Environment:              MANPAGER, PAGER, MANPATH, BINDIR, TMPDIR\n");

exit (excode);
}


