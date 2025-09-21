/*

	Copyright (C) 1988 Free Software Foundation

GNU tar is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY.  No author or distributor accepts responsibility to anyone
for the consequences of using it or for whether it serves any
particular purpose or works at all, unless he says so in writing.
Refer to the GNU tar General Public License for full details.

Everyone is granted permission to copy, modify and redistribute GNU tar,
but only under the conditions described in the GNU tar General Public
License.  A copy of this license is supposed to have been given to you
along with GNU tar so you can know your rights and responsibilities.  It
should be in a file named COPYING.  Among other things, the copyright
notice and this notice must be preserved on all copies.

In other words, go ahead and share GNU tar, but don't try to stop
anyone else from sharing it farther.  Help stamp out software hoarding!
*/

/*
 * A tar(1) program.
 * 
 * Written by John Gilmore, ihnp4!hoptoad!gnu, starting 25 Aug 85.
 *
 * @(#)tar.c 1.34 11/6/87 - gnu
 */

#include <stdio.h>
#ifdef atarist
#include <types.h>		/* Needed for typedefs in tar.h */
#include <stat.h>		/* JF */
#else
#include <sys/types.h>		/* Needed for typedefs in tar.h */
#include <sys/stat.h>		/* JF */
#endif

#ifdef USG
#define rindex strrchr
#endif

#ifdef BSD42
#include <sys/dir.h>
#else
#if (defined(MSDOS) && !defined(atarist))
#include <sys/dir.h>
#else
#ifdef USG
#include <dirent.h>
#define direct dirent
#define DP_NAMELEN(x) strlen((x)->d_name)
#else
/*
 * FIXME: On other systems there is no standard place for the header file
 * for the portable directory access routines.  Change the #include line
 * below to bring it in from wherever it is.
 */
#include <dirent.h>
#define direct dirent		/* if you have POSIX routines */
#define DP_NAMELEN(x) strlen((x)->d_name)  /* ditto */
#endif
#endif
#endif

#ifndef DP_NAMELEN
#define DP_NAMELEN(x)	(x)->d_namlen
#endif

extern char 	*malloc();
extern char 	*getenv();
extern char	*strncpy();
extern char	*index();
extern char	*strcpy();	/* JF */
extern char	*strcat();	/* JF */

extern char	*optarg;	/* Pointer to argument */
extern int	optind;		/* Global argv index from getopt */

/*
 * The following causes "tar.h" to produce definitions of all the
 * global variables, rather than just "extern" declarations of them.
 */
#define TAR_EXTERN /**/
#include "tar.h"

/*
 * We should use a conversion routine that does reasonable error
 * checking -- atoi doesn't.  For now, punt.  FIXME.
 */
#define intconv	atoi
extern int	getoldopt();
extern void	read_and();
extern void	list_archive();
extern void	extract_archive();
extern void	diff_archive();
extern void	create_archive();
extern void	update_archive();
extern void	junk_archive();

/* JF */
extern time_t	getdate();
#ifdef __GNU__
extern void *init_buffer();
#else
extern char *init_buffer();
#endif
extern char *get_buffer();
extern void add_buffer();
extern void flush_buffer();

time_t new_time;

static FILE	*namef;		/* File to read names from */
static char	**n_argv;	/* Argv used by name routines */
static int	n_argc;	/* Argc used by name routines */
				/* They also use "optind" from getopt(). */

void	describe();
void	options();

#ifndef S_IFLNK
#define lstat stat
#endif

#ifndef DEFBLOCKING
#define DEFBLOCKING 20
#endif

#ifndef DEF_AR_FILE
#define DEF_AR_FILE "tar.out"
#endif

#ifdef atarist
int setmode() { return 0; } /* MSDOS compatibility cruft */
#endif

/*
 * Main routine for tar.
 */
main(argc, argv)
	int	argc;
	char	**argv;
{
#ifdef atarist
	extern char *name_next();
	extern int _unixmode;
	static char archname[NAMSIZ+2];
#endif
	/* Uncomment this message in particularly buggy versions...
	fprintf(stderr,
	 "tar: You are running an experimental PD tar, maybe use /bin/tar.\n");
	 */

#ifdef atarist
	_unixmode = 3;		/* convert filenames to/from Un*x */
	tar = *argv[0] ? argv[0] : "tar";
#else
	tar = argv[0];		/* JF: was "tar" Set program name */
#endif
	options(argc, argv);

	name_init(argc, argv);
#ifdef atarist
	if (ar_file == 0) {
		strcpy(archname, name_next(0));
		ar_file = archname;
	}
#endif
	switch(cmd_mode) {
	case CMD_CAT:
	case CMD_UPDATE:
	case CMD_APPEND:
		update_archive();
		break;
	case CMD_DELETE:
		junk_archive();
		break;
	case CMD_CREATE:
		create_archive();
		break;
	case CMD_EXTRACT:
		extr_init();
		read_and(extract_archive);
		break;
	case CMD_LIST:
		read_and(list_archive);
		break;
	case CMD_DIFF:
		diff_init();
		read_and(diff_archive);
		break;
	case CMD_NONE:
		fprintf (stderr,
#ifdef atarist
"%s: you must specify exactly one of the r, c, t, x, or d options\n", tar);
#else
"tar: you must specify exactly one of the r, c, t, x, or d options\n");
#endif
		describe();
		exit(EX_ARGSBAD);
	}
	exit(0);
	/* NOTREACHED */
}


/*
 * Parse the options for tar.
 */
void
options(argc, argv)
	int	argc;
	char	**argv;
{
	register int	c;		/* Option letter */

	/* Set default option values */
	blocking = DEFBLOCKING;		/* From Makefile */
	ar_file = getenv("TAPE");	/* From environment, or */
	if (ar_file == 0)
		ar_file = DEF_AR_FILE;	/* From Makefile */

	/* Parse options */
	while ((c = getoldopt(argc, argv, "01234567Ab:BcdDf:GhikK:lmMN:oOprRstT:uvV:wWxX:zZ")
		) != EOF) {
		switch (c) {
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
			{
				/* JF this'll have to be modified for other
				   systems, of course! */
#ifndef LOW_NUM
#define LOW_NUM 0
#define MID_NUM 8
#define HGH_NUM 16
#endif
				int d,add;
				static char buf[50];

				d=getoldopt(argc,argv,"lmh");
				if(d=='l') add=LOW_NUM;
				else if(d=='m') add=MID_NUM;
				else if(d=='h') add=HGH_NUM;
				else goto badopt;
				sprintf(buf,"/dev/rmt%d",add+c-'0');
				ar_file=buf;
			}
			break;

		case 'A':			/* Arguments are tar files,
						   just cat them onto the end
						   of the archive.  */
			if(cmd_mode!=CMD_NONE)
				goto badopt;
			cmd_mode=CMD_CAT;
			break;

		case 'b':			/* Set blocking factor */
			blocking = intconv(optarg);
			break;

		case 'B':			/* Try to reblock input */
			f_reblock++;		/* For reading 4.2BSD pipes */
			break;

		case 'c':			/* Create an archive */
			if(cmd_mode!=CMD_NONE)
				goto badopt;
			cmd_mode=CMD_CREATE;
			break;

		case 'd':			/* Find difference tape/disk */
			if(cmd_mode!=CMD_NONE)
				goto badopt;
			cmd_mode=CMD_DIFF;
			break;

		case 'D':			/* Delete in the archive */
			if(cmd_mode!=CMD_NONE)
				goto badopt;
			cmd_mode=CMD_DELETE;
			break;

		case 'f':			/* Use ar_file for the archive */
			ar_file = optarg;
			break;

		case 'G':			/* We are making a GNU dump; save
						   directories at the beginning of
						   the archive, and include in each
						   directory its contents */
			if(f_oldarch)
				goto badopt;
			f_gnudump++;
			break;

		case 'h':
			if(optind && argv[optind] && !strcmp(argv[optind],"-help")) {
				printf("This is GNU tar, the tape archiving program.\n");
				describe();
				printf("For a more complete description of how to use tar, type 'info util tar'\n");
				exit(1);
			} else
				f_follow_links++;	/* follow symbolic links */
			break;

		case 'i':
			f_ignorez++;		/* Ignore zero records (eofs) */
			/*
			 * This can't be the default, because Unix tar
			 * writes two records of zeros, then pads out the
			 * block with garbage.
			 */
			break;

		case 'k':			/* Don't overwrite files */
#ifdef NO_OPEN3
			fprintf(stderr,
				"tar: can't do -k option on this system\n");
			exit(EX_ARGSBAD);
#else
			f_keep++;
#endif
			break;

		case 'K':
			f_startfile++;
			addname(optarg);
			break;

		case 'l':			/* When dumping directories, don't
						   dump files/subdirectories that are
						   on other filesystems. */
			f_local_filesys++;
			break;

		case 'm':
			f_modified++;
			break;

		case 'M':			/* Make Multivolume archive:
						   When we can't write any more
						   into the archive, re-open it,
						   and continue writing */
			f_multivol++;
			break;

		case 'N':			/* Only write files newer than X */
			f_new_files++;
			new_time=getdate(optarg,(struct timeb *)0);
			break;

		case 'o':			/* Generate old archive */
			if(f_gnudump /* || f_dironly */)
				goto badopt;
			f_oldarch++;
			break;

		case 'O':
			f_exstdout++;
			break;

		case 'p':
			f_use_protection++;
			break;

		case 'r':			/* Append files to the archive */
			if(cmd_mode!=CMD_NONE)
				goto badopt;
			cmd_mode=CMD_APPEND;
			break;

		case 'R':
			f_sayblock++;		/* Print block #s for debug */
			break;			/* of bad tar archives */

		case 's':
			f_sorted_names++;	/* Names to extr are sorted */
			break;

		case 't':
			if(cmd_mode!=CMD_NONE)
				goto badopt;
			cmd_mode=CMD_LIST;
			f_verbose++;		/* "t" output == "cv" or "xv" */
			break;

		case 'T':
			name_file = optarg;
			f_namefile++;
			break;

		case 'u':			/* Append files to the archive that
						   aren't there, or are newer than the
						   copy in the archive */
			if(cmd_mode!=CMD_NONE)
				goto badopt;
			cmd_mode=CMD_UPDATE;
			break;

		case 'v':
			if(optind && argv[optind] && !strcmp(argv[optind],"-version")) {
				extern char version_string[];

				fprintf(stderr,"%s\n",version_string);
				while(getoldopt(argc,argv,"ersion")!='n')
					;
			} else {
				f_verbose++;
			}
			break;

		case 'V':
			f_volhdr=optarg;
			break;

		case 'w':
			f_confirm++;
			break;

		case 'W':
			f_verify++;
			break;

		case 'x':			/* Extract files from the archive */
			if(cmd_mode!=CMD_NONE)
				goto badopt;
			cmd_mode=CMD_EXTRACT;
			break;

		case 'X':
			f_exclude++;
			add_exclude(optarg);
			break;

		case 'z':		/* Easy to type */
		case 'Z':		/* Like the filename extension .Z */
			f_compress++;
			break;

		case '?':
		badopt:
			describe();
			exit(EX_ARGSBAD);

		}
	}

	blocksize = blocking * RECORDSIZE;
}


/* 
 * Print as much help as the user's gonna get.
 *
 * We have to sprinkle in the KLUDGE lines because too many compilers
 * cannot handle character strings longer than about 512 bytes.  Yuk!
 * In particular, MSDOS MSC 4.0 (and 5.0) and PDP-11 V7 Unix have this
 * problem.
 */
void
describe()
{
	fprintf(stderr,"%s: choose one of the following:\n",tar);
	fputs("\
-A	Append tar files to an archive.\n\
-c	Create a new archive.\n\
-d	Find differences between archive and file system.\n\
-D	Delete from the archive (NOT for use on mag tapes!)\n\
-r	Append files to the end of an archive.\n\
-t	List the contents of an archive.\n\
-u	Only append files that are newer than the copy in an archive.\n\
-x	Extract files from an archive.\n",stderr);

	fputs("\
Other options:\n\
-b N	blocking factor N (block size = Nx512 bytes)\n\
-B	reblock as we read (for reading 4.2BSD pipes)\n\
-C dir	change to directory DIR\n\
", stderr); /* KLUDGE */ fputs("\
-f F	read/write archive from file or device F (or hostname:/ForD)\n\
-G	create/list/extract GNU-format backup\n\
-h	don't dump symbolic links; dump the files they point to\n\
-i	ignore blocks of zeros in the archive, which normally mean EOF\n\
-k	keep existing files, don't overwrite them from the archive\n\
-K file	begin at \"file\" in the archive\n\
-l	stay in the local file system (like dump(8)) when creating an archive\n\
", stderr); /* KLUDGE */ fputs("\
-m	don't extract file modified time\n\
-M	create/list/extract multi-volume archive\n\
-N date	only store files newer than DATE\n\
-o	write an old V7 format archive, rather than ANSI [draft 6] format\n\
-O	extract files to standard output\n\
-p	do extract all protection information\n\
-R	dump record number within archive with each message\n\
-s	list of names to extract is sorted to match the archive\n\
", stderr); /* KLUDGE */ fputs("\
-T F	get names to extract or create from file F\n\
-v	verbosely list what files we process\n\
-V vnam	create archive with volume name 'vnam'\n\
-w	ask for confirmation for every action\n\
-W	attempt to verify the archive after writing it\n\
-X file	eXclude files listed in \"file\"\n\
-z or Z	run the archive through compress(1)\n\
-[0-7][lmh] specify drive and density\n\
", stderr);
}


/*
 * Set up to gather file names for tar.
 *
 * They can either come from stdin or from argv.
 */
name_init(argc, argv)
	int	argc;
	char	**argv;
{

	if (f_namefile) {
		if (optind < argc) {
			fprintf(stderr, "tar: too many args with -T option\n");
			exit(EX_ARGSBAD);
		}
		if (!strcmp(name_file, "-")) {
			namef = stdin;
		} else {
			namef = fopen(name_file, "r");
			if (namef == NULL) {
				msg_perror("can't open file %s",name_file);
				exit(EX_BADFILE);
			}
		}
	} else {
		/* Get file names from argv, after options. */
		n_argc = argc;
		n_argv = argv;
	}
}

/*
 * Get the next name from argv or the name file.
 *
 * Result is in static storage and can't be relied upon across two calls.
 */

/* C is non-zero if we should deal with -C */
char *
name_next(c)
{
	static char	buffer[NAMSIZ+2];	/* Holding pattern */
	register char	*p;
	register char	*q;
	extern char *un_quote_string();

 tryagain:
	if (namef == NULL) {
		/* Names come from argv, after options */
		if (optind < n_argc) {
			/* JF trivial support for -C option.  I don't know if
			   chdir'ing at this point is dangerous or not.
			   It seems to work, which is all I ask. */
			if(c && n_argv[optind][0]=='-' && n_argv[optind][1]=='C' && n_argv[optind][2]=='\0') {
				optind++;
				if(chdir(n_argv[optind])<0) {
					msg_perror("Can't chdir to %s",n_argv[optind]);
				}
				optind++;
			}
			/* End of JF quick -C hack */

			if(f_exclude && check_exclude(n_argv[optind])) {
				optind++;
				goto tryagain;
			}
			return un_quote_string(n_argv[optind++]);
		}
		return (char *)NULL;
	}
	while(p = fgets(buffer, NAMSIZ+1 /*nl*/, namef)) {
		q = p+strlen(p)-1;		/* Find the newline */
		if (q <= p)			/* Ignore empty lines */
			continue;
		*q-- = '\0';			/* Zap the newline */
		while (q > p && *q == '/')	/* Zap trailing /s */
			*q-- = '\0';
		if(f_exclude && check_exclude(p))
			goto tryagain;
		return un_quote_string(p);
	}
	return NULL;
}


/*
 * Close the name file, if any.
 */
name_close()
{

	if (namef != NULL && namef != stdin) fclose(namef);
}


/*
 * Gather names in a list for scanning.
 * Could hash them later if we really care.
 *
 * If the names are already sorted to match the archive, we just
 * read them one by one.  name_gather reads the first one, and it
 * is called by name_match as appropriate to read the next ones.
 * At EOF, the last name read is just left in the buffer.
 * This option lets users of small machines extract an arbitrary
 * number of files by doing "tar t" and editing down the list of files.
 */
name_gather()
{
	register char *p;
	static struct name namebuf[1];	/* One-name buffer */
	static char *chdir_name;

	if (f_sorted_names) {
		p = name_next(0);
		if (p) {
			if(*p=='-' && p[1]=='C' && p[2]=='\0') {
				chdir_name=name_next(0);
				p=name_next(0);
				if(!p) {
					fprintf(stderr,"Missing file name after -C\n");
					exit(EX_ARGSBAD);
				}
				namebuf[0].change_dir=chdir_name;
			}
			namebuf[0].length = strlen(p);
			if (namebuf[0].length >= sizeof namebuf[0].name) {
				fprintf(stderr, "Argument name too long: %s\n",
					p);
				namebuf[0].length = (sizeof namebuf[0].name) - 1;
			}
			strncpy(namebuf[0].name, p, namebuf[0].length);
			namebuf[0].name[ namebuf[0].length ] = 0;
			namebuf[0].next = (struct name *)NULL;
			namebuf[0].found = 0;
			namelist = namebuf;
			namelast = namelist;
		}
		return;
	}

	/* Non sorted names -- read them all in */
	while (p = name_next(0))
		addname(p);
}

/*
 * Add a name to the namelist.
 */
addname(name)
	char	*name;			/* pointer to name */
{
	register int	i;		/* Length of string */
	register struct name	*p;	/* Current struct pointer */
	static char *chdir_name;
	char *new_name();
#define MAXPATHLEN 1024

	if(name[0]=='-' && name[1]=='C' && name[2]=='\0') {
		chdir_name=name_next(0);
		name=name_next(0);
		if(!name) {
			fprintf(stderr,"Missing file name after -C\n");
			exit(EX_ARGSBAD);
		}
		if(chdir_name[0]!='/') {
			char path[MAXPATHLEN];
#ifdef MSDOS
			int getcwd();

			if(!getcwd(path,MAXPATHLEN))
				fprintf(stderr,"Couldn't get current dir\n");
				exit(EX_SYSTEM);
#else
			char *getwd();

			if(!getwd(path)) {
				fprintf(stderr,"Couldn't get current dir: %s\n",path);
				exit(EX_SYSTEM);
			}
#endif
			chdir_name=new_name(path,chdir_name);
		}
	}

	i = strlen(name);
	/*NOSTRICT*/
	p = (struct name *)
		malloc((unsigned)(i + sizeof(struct name) - NAMSIZ));
	if (!p) {
		fprintf(stderr,"tar: cannot allocate mem for name %s\n",name);
		exit(EX_SYSTEM);
	}
	p->next = (struct name *)NULL;
	p->length = i;
	strncpy(p->name, name, i);
	p->name[i] = '\0';	/* Null term */
	p->found = 0;
	p->regexp = 0;		/* Assume not a regular expression */
	p->firstch = 1;		/* Assume first char is literal */
	p->change_dir=chdir_name;
	p->dir_contents = 0;	/* JF */
	if (index(name, '*') || index(name, '[') || index(name, '?')) {
		p->regexp = 1;	/* No, it's a regexp */
		if (name[0] == '*' || name[0] == '[' || name[0] == '?')
			p->firstch = 0;		/* Not even 1st char literal */
	}

	if (namelast) namelast->next = p;
	namelast = p;
	if (!namelist) namelist = p;
}

add_dir_to_name(name,dirc)
char *name;
char *dirc;
{
	struct name *n;

	for(n=namelist;n;n=n->next) {
		if(!strcmp(n->name,name)) {
			n->dir_contents = dirc;
			return;
		}
	}
}

/*
 * Match a name from an archive, p, with a name from the namelist.
 */
name_match(p)
	register char *p;
{
	register struct name	*nlp;
	register int		len;

again:
	if (0 == (nlp = namelist))	/* Empty namelist is easy */
		return 1;
	len = strlen(p);
	for (; nlp != 0; nlp = nlp->next) {
		/* If first chars don't match, quick skip */
		if (nlp->firstch && nlp->name[0] != p[0])
			continue;

		/* Regular expressions */
		if (nlp->regexp) {
			if (wildmat(p, nlp->name)) {
				nlp->found = 1;	/* Remember it matched */
				if(f_startfile) {
					free((void *)namelist);
					namelist=0;
				}
				return 1;	/* We got a match */
			}
			continue;
		}

		/* Plain Old Strings */
		if (nlp->length <= len		/* Archive len >= specified */
		 && (p[nlp->length] == '\0' || p[nlp->length] == '/')
						/* Full match on file/dirname */
		 && strncmp(p, nlp->name, nlp->length) == 0) /* Name compare */
		{
			nlp->found = 1;		/* Remember it matched */
			if(f_startfile) {
				free((void *)namelist);
				namelist = 0;
			}
			return 1;		/* We got a match */
		}
	}

	/*
	 * Filename from archive not found in namelist.
	 * If we have the whole namelist here, just return 0.
	 * Otherwise, read the next name in and compare it.
	 * If this was the last name, namelist->found will remain on.
	 * If not, we loop to compare the newly read name.
	 */
	if (f_sorted_names && namelist->found) {
		name_gather();		/* Read one more */
		if (!namelist->found) goto again;
	}
	return 0;
}


/*
 * Print the names of things in the namelist that were not matched.
 */
names_notfound()
{
	register struct name	*nlp;
	register char		*p;

	for (nlp = namelist; nlp != 0; nlp = nlp->next) {
		if (!nlp->found) {
			fprintf(stderr, "tar: %s not found in archive\n",
				nlp->name);
		}
		/*
		 * We could free() the list, but the process is about
		 * to die anyway, so save some CPU time.  Amigas and
		 * other similarly broken software will need to waste
		 * the time, though.
		 */
#ifndef unix
		if (!f_sorted_names)
			free(nlp);
#endif
	}
	namelist = (struct name *)NULL;
	namelast = (struct name *)NULL;

	if (f_sorted_names) {
		while (0 != (p = name_next(1)))
			fprintf(stderr, "tar: %s not found in archive\n", p);
	}
}

/* These next routines were created by JF */

name_expand()
{
;
}
/* p is a directory.  Add all the files in P to the namelist.  If any of the
   files is a directory, recurse on the subdirectory. . . */
static
add_dir_name(p,device)
char *p;
int device;
{
	char *new_buf;
	char *p_buf;
	char *get_dir_contents();
	new_buf=get_dir_contents(p,device);

	add_dir_to_name(p,new_buf);
	{
		char namebuf[NAMSIZ+2];
		register int len;

		(void)strcpy(namebuf,p);
		len=strlen(namebuf);
		if(namebuf[len-1]!='/') {
			namebuf[len++]='/';
			namebuf[len]='\0';
		}
		for(p_buf=new_buf;*p_buf;p_buf+=strlen(p_buf)+1) {
			if(*p_buf=='D') {
				(void)strcpy(namebuf+len,p_buf+1);
				addname(namebuf);
				add_dir_name(namebuf,device);
			}
		}
	}
}

char *
get_dir_contents(p,device)
char *p;
int device;
{
	register DIR *dirp;
	register struct direct *d;
	char namebuf[NAMSIZ+2];
	register int len;
	extern int errno;

#ifdef	__GNU__
	void *the_buffer;
#else
	char *the_buffer;
#endif
		char *buf,*p_buf;
		char **vec,**p_vec;
		int n_strs,n_size;
		char *new_buf;
		int dirent_cmp();

	if(f_local_filesys && device<0) {
		struct stat hs;

		if (0 != f_follow_links ? stat(p, &hs) : lstat(p, &hs))
			msg_perror("can't stat %s",namebuf);
		else
			device=hs.st_dev;
	}
	errno=0;
	dirp=opendir(p);
	if(!dirp) {
		if(errno)
			msg_perror("can't open directory %s",p);
		else
			msg("error opening directory %s",p);
		return "\0\0\0\0";
	}
	(void) strcpy(namebuf,p);
	if(p[strlen(p)-1]!='/')
		(void) strcat(namebuf,"/");
	len=strlen(namebuf);

	the_buffer=init_buffer();
	while(d=readdir(dirp)) {
		struct stat hs;

		/* Skip . and .. */
		if(is_dot_or_dotdot(d->d_name))
			continue;
		if(DP_NAMELEN(d) + len >=NAMSIZ) {
			msg("%s%s name too long: skipped",namebuf,d->d_name);
			continue;
		}
		(void) strcpy(namebuf+len,d->d_name);
		if (0 != f_follow_links? stat(namebuf, &hs): lstat(namebuf, &hs)) {
			msg_perror("can't stat %s",namebuf);
			continue;
		}
		if((f_new_files && new_time>hs.st_mtime &&
 		    new_time>hs.st_ctime && (hs.st_mode&S_IFMT)!=S_IFDIR)
		   || (f_local_filesys && device>=0 && device!=hs.st_dev))
			add_buffer(the_buffer,"N",1);
		else if((hs.st_mode&S_IFMT)==S_IFDIR)
			add_buffer(the_buffer,"D",1);
		else
			add_buffer(the_buffer,"Y",1);
		add_buffer(the_buffer,d->d_name,(int)(DP_NAMELEN(d)+1));
	}
	add_buffer(the_buffer,"\000\000",2);
	closedir(dirp);

	/* Well, we've read in the contents of the dir, now sort them */
	buf=get_buffer(the_buffer);
	n_strs=0;
	n_size=0;
	for(p_buf=buf;*p_buf;) {
		int tmp;

		tmp=strlen(p_buf)+1;
		n_strs++;
		n_size+=tmp;
		p_buf+=tmp;
	}
	if(n_strs==0) {
		flush_buffer(the_buffer);
		return "\0\0\0\0";
	}
	vec=(char **)malloc(sizeof(char *)*(n_strs+1));
	for(p_vec=vec,p_buf=buf;*p_buf;p_buf+=strlen(p_buf)+1)
		*p_vec++= p_buf;
	*p_vec= 0;
	qsort((void *)vec,n_strs,sizeof(char *),dirent_cmp);
	new_buf=(char *)malloc(n_size+2);
	for(p_vec=vec,p_buf=new_buf;*p_vec;p_vec++) {
		char *p_tmp;

		for(p_tmp= *p_vec;*p_buf++= *p_tmp++;)
			;
	}
	*p_buf++='\0';
	free(vec);
	flush_buffer(the_buffer);
	return new_buf;
}

int dirent_cmp(p1,p2)
char **p1,**p2;
{
	char *frst,*scnd;

	frst= (*p1)+1;
	scnd= (*p2)+1;

	return strcmp(frst,scnd);
}

/* This is like name_match(), except that it returns a pointer to the name
   it matched, and doesn't set ->found  The caller will have to do that
   if it wants to.  Oh, and if the namelist is empty, it returns 0, unlike
   name_match(), which returns TRUE */

struct name *
name_scan(p)
register char *p;
{
	register struct name	*nlp;
	register int		len;

again:
	if (0 == (nlp = namelist))	/* Empty namelist is easy */
		return 0;
	len = strlen(p);
	for (; nlp != 0; nlp = nlp->next) {
		/* If first chars don't match, quick skip */
		if (nlp->firstch && nlp->name[0] != p[0])
			continue;

		/* Regular expressions */
		if (nlp->regexp) {
			if (wildmat(p, nlp->name))
				return nlp;	/* We got a match */
			continue;
		}

		/* Plain Old Strings */
		if (nlp->length <= len		/* Archive len >= specified */
		 && (p[nlp->length] == '\0' || p[nlp->length] == '/')
						/* Full match on file/dirname */
		 && strncmp(p, nlp->name, nlp->length) == 0) /* Name compare */
			return nlp;		/* We got a match */
	}

	/*
	 * Filename from archive not found in namelist.
	 * If we have the whole namelist here, just return 0.
	 * Otherwise, read the next name in and compare it.
	 * If this was the last name, namelist->found will remain on.
	 * If not, we loop to compare the newly read name.
	 */
	if (f_sorted_names && namelist->found) {
		name_gather();		/* Read one more */
		if (!namelist->found) goto again;
	}
	return (struct name *) 0;
}

/* This returns a name from the namelist which doesn't have ->found set.
   It sets ->found before returning, so successive calls will find and return
   all the non-found names in the namelist */

struct name *gnu_list_name;

char *
name_from_list()
{
	if(!gnu_list_name)
		gnu_list_name = namelist;
	while(gnu_list_name && gnu_list_name->found)
		gnu_list_name=gnu_list_name->next;
	if(gnu_list_name) {
		gnu_list_name->found++;
		if(gnu_list_name->change_dir)
			if(chdir(gnu_list_name->change_dir)<0)
				msg_perror("can't chdir to %s",gnu_list_name->change_dir);
		return gnu_list_name->name;
	}
	return (char *)0;
}

blank_name_list()
{
	struct name *n;

	gnu_list_name = 0;
	for(n=namelist;n;n=n->next)
		n->found = 0;
}

/* Collect all the names from argv[] (or whatever), then expand them into
   a directory tree, and put all the directories at the beginning. */
collect_and_sort_names()
{
	struct name *n,*n_next;
	int num_names;
	int name_cmp();
	char *merge_sort();

	name_gather();

	if(!namelist) addname(".");
	for(n=namelist;n;n=n_next) {
		n_next=n->next;
		if(n->found || n->dir_contents)
			continue;
		if(n->regexp)		/* FIXME just skip regexps for now */
			continue;
		if(n->change_dir)
			if(chdir(n->change_dir)<0) {
				msg_perror("can't chdir to %s",n->change_dir);
				continue;
			}

		if(is_a_directory(n->name)) {
			n->found++;
			add_dir_name(n->name,-1);
		}
	}

	num_names=0;
	for(n=namelist;n;n=n->next)
		num_names++;
	namelist=(struct name *)merge_sort((void *)namelist,num_names,(char *)(&(namelist->next))-(char *)namelist,name_cmp);

	for(n=namelist;n;n=n->next) {
		n->found=0;
	}
}

int name_cmp(n1,n2)
struct name *n1,*n2;
{
	if(n1->found) {
		if(n2->found)
			return strcmp(n1->name,n2->name);
		else
			return -1;
	} else if(n2->found)
		return 1;
	else
		return strcmp(n1->name,n2->name);
}

char *new_name();

gnu_restore(name)
char *name;
{
	char *current_dir;
/*	int current_dir_length; */

	char *archive_dir;
/*	int archive_dir_length; */
#ifdef __GNU__
	void *the_buffer;
#else
	char *the_buffer;
#endif
	char	*p;
	DIR	*dirp;
	struct direct *d;
	char *cur,*arc;
	extern struct stat hstat;		/* Stat struct corresponding */
	long size,copied;
	char *from,*to;

	dirp=opendir(name);

	if(!dirp) {
			/* The directory doesn't exist now.  It'll be created.
			   In any case, we don't have to delete any files out
			   of it */
		return;
	}

	the_buffer=init_buffer();
	while(d=readdir(dirp)) {
		if(is_dot_or_dotdot(d->d_name))
			continue;

		add_buffer(the_buffer,d->d_name,(int)(DP_NAMELEN(d)+1));
	}
	closedir(dirp);
	add_buffer(the_buffer,"",1);

	current_dir=get_buffer(the_buffer);
	archive_dir=(char *)malloc(hstat.st_size);
	if(archive_dir==0) {
		fprintf(stderr,"Can't allocate %d bytes for restore\n",hstat.st_size);
		return;
	}
	to=archive_dir;
	for(size=hstat.st_size;size>0;size-=copied) {
		from=findrec()->charptr;
		if(!from) {
			msg("Unexpected EOF in archive\n");
			break;
		}
		copied=endofrecs()->charptr - from;
		if(copied>size)
			copied=size;
		bcopy((void *)from,(void *)to,(int)copied);
		to+=copied;
		userec((union record *)(from+copied-1));
	}

	for(cur=current_dir;*cur;cur+=strlen(cur)+1) {
		for(arc=archive_dir;*arc;arc+=strlen(arc)+1) {
			arc++;
			if(!strcmp(arc,cur))
				break;
		}
		if(*arc=='\0') {
			p=new_name(name,cur);
			if(f_confirm && !confirm("delete",p)) {
				free(p);
				continue;
			}
			if(f_verbose)
				printf("%s: deleting %s\n",p);
			if(recursively_delete(p)) {
				msg("%s: Error while deleting\n",p);
			}
			free(p);
		}
		
	}
	flush_buffer(the_buffer);
	free(archive_dir);
}

recursively_delete(path)
char *path;
{
	struct stat sbuf;
	DIR *dirp;
	struct direct *dp;
	char *path_buf;
	/* int path_len; */

	
	if(lstat(path,&sbuf)<0)
		return 1;
	if((sbuf.st_mode &S_IFMT)==S_IFDIR) {

		/* path_len=strlen(path); */
		dirp=opendir(path);
		if(dirp==0)
			return 1;
		while(dp=readdir(dirp)) {
			if(is_dot_or_dotdot(dp->d_name))
				continue;
			path_buf=new_name(path,dp->d_name);
			if(recursively_delete(path_buf)) {
				free(path_buf);
				closedir(dirp);
				return 1;
			}
			free(path_buf);
		}
		closedir(dirp);

		if(rmdir(path)<0)
			return 1;
		return 0;
	}
	if(unlink(path)<0)
		return 1;
	return 0;
}

char *
new_name(path,name)
char *path,*name;
{
	char *path_buf;

	path_buf=(char *)malloc(strlen(path)+strlen(name)+2);
	if(path_buf==0) {
		fprintf(stderr,"Can't allocate memory for name '%s/%s\n",path,name);
		exit(EX_SYSTEM);
	}
	(void) sprintf(path_buf,"%s/%s",path,name);
	return path_buf;
}

/* return non-zero if p is the name of a directory */
is_a_directory(p)
char *p;
{
	struct stat stbuf;

	if(lstat(p,&stbuf)<0) {
		msg_perror("can't stat %s",p);
		return 0;
	}
	if((stbuf.st_mode&S_IFMT)==S_IFDIR)
		return 1;
	return 0;
}

/* Returns non-zero if p is . or ..   This could be a macro for speed. */
is_dot_or_dotdot(p)
char *p;
{
	return (p[0]=='.' && (p[1]=='\0' || (p[1]=='.' && p[2]=='\0')));
}

/* returns non-zero if the luser typed 'y' or 'Y', zero otherwise. */

int
confirm(action,file)
char *action, *file;
{
	int	c,nl;
	static FILE *confirm_file = 0;
	extern FILE *msg_file;

	fprintf(msg_file,"%s %s?", action, file);
	if(!confirm_file) {
#ifdef atarist
		confirm_file = (archive == 0) ? fopen("CON:", 0) : stdin;
#else
		confirm_file = (archive == 0) ? fopen("/dev/tty") : stdin;
#endif
		if(!confirm_file) {
			fprintf(stderr,"Can't read confirmation from user\n");
			exit(EX_SYSTEM);
		}
	}
	c=getc(confirm_file);
	for(nl = c; nl != '\n' && nl != EOF; nl = getc(confirm_file))
		;
	return (c=='y' || c=='Y');
}

char *x_buffer = 0;
int size_x_buffer;
int free_x_buffer;

char **exclude = 0;
int size_exclude = 0;
int free_exclude = 0;

char **re_exclude = 0;
int size_re_exclude = 0;
int free_re_exclude = 0;

add_exclude(file)
char *file;
{
	FILE *fp;
	char buf[1024];
	extern char *rindex();

	fp=fopen(file,"r");
	if(!fp) {
		msg_perror("can't open %s",file);
		exit(2);
	}
	while(fgets(buf,1024,fp)) {
		int size_buf;
		char *end_str;

		end_str=rindex(buf,'\n');
		*end_str='\0';

		un_quote_string(buf);
		size_buf = strlen(buf);

		if(x_buffer==0) {
			x_buffer = (char *)ck_malloc(size_buf+1024);
			free_x_buffer=1024;
		} else if(free_x_buffer<=size_buf) {
			char *old_x_buffer;
			char **tmp_ptr;

			old_x_buffer = x_buffer;
			x_buffer = (char *)ck_realloc(x_buffer,size_x_buffer+1024);
			free_x_buffer = 1024;
			for(tmp_ptr=exclude;tmp_ptr<exclude+size_exclude;tmp_ptr++)
				*tmp_ptr= x_buffer + ((*tmp_ptr) - old_x_buffer);
			for(tmp_ptr=re_exclude;tmp_ptr<re_exclude+size_re_exclude;tmp_ptr++)
				*tmp_ptr= x_buffer + ((*tmp_ptr) - old_x_buffer);
		}

		if(is_regex(buf)) {
			if(free_re_exclude==0) {
				re_exclude= (char **)(re_exclude ? ck_realloc(re_exclude,(size_re_exclude+32)*sizeof(char *)) : ck_malloc(sizeof(char *)*32));
				free_re_exclude+=32;
			}
			re_exclude[size_re_exclude]=x_buffer+size_x_buffer;
			size_re_exclude++;
			free_re_exclude--;
		} else {
			if(free_exclude==0) {
				exclude=(char **)(exclude ? ck_realloc(exclude,(size_exclude+32)*sizeof(char *)) : ck_malloc(sizeof(char *)*32));
				free_exclude+=32;
			}
			exclude[size_exclude]=x_buffer+size_x_buffer;
			size_exclude++;
			free_exclude--;
		}
		strcpy(x_buffer+size_x_buffer,buf);
		size_x_buffer+=size_buf+1;
		free_x_buffer-=size_buf+1;
	}
	fclose(fp);
}

int
is_regex(str)
char *str;
{
	return index(str,'*') || index(str,'[') || index(str,'?');
}

int
check_exclude(name)
char *name;
{
	int n;

	for(n=0;n<size_re_exclude;n++) {
		if(wildmat(name,re_exclude[n]))
			return 1;
	}
	for(n=0;n<size_exclude;n++) {
		if(strstr(name,exclude[n]))
			return 1;
	}
	return 0;
}
