/*
 *	Fontlibrary program.
 *
 *		used for our TeX-system to save disk space and for
 *		speed up the loading of fonts for "showdvi" and "dviprint".
 *
 *	This program is freely redistributable. You may modify and use this
 *	program to your heart's content, so long as you send modifications
 *	to Georg Hessmann or Robert Stabl. It can be included in any 
 *	distribution, commercial or otherwise, so long as the banner string
 *	defined in the constant HEADER is not modified (except for the version
 *	number and the machine type) and this banner is printed on programs
 *	invocation, or can be printed on programs invocation with the -? option.
 *
 *	For further information read the README file.
 *
 *      31.01.90        (C) Copyright Georg Hessmann.
 *
 *      12.02.90 v1.01	new flib-format, rename command
 *
 *      14.02.90  (rbs) ported to Atari ST
 *
 *      25.04.90  (jrb) fixed up for Atari ST gcc
 *
 *	05.06.90 v1.02	little bug fixes, add flib links (hes/rbs)
 *
 *	10.06.90  (rbs) fixed bug for Turbo_C argv[0]
 *
 *	23.08.90 v1.03	bug fix in adding files to existing lib
 *		  (rbs)	(only in version for Turbo C)
 */


/* Is the compiler a ANSI-C compiler */
#ifdef AMIGA
#  ifdef LATTICE
#    define ANSI
#  endif
#  ifdef AZTEC_C
#    undef ANSI
#  endif /* AZTEC_C */
#  ifdef _DCC
#    define ANSI
#  endif /* _DCC */
#else
#  ifdef ATARI
#    ifdef __GNUC__
#      define ANSI
#    endif /* __GNUC__ */
#  endif /* ATARI */
#endif /* AMIGA */

/* standard includes */
#include <stdio.h>
#ifdef ANSI
#  include <stdlib.h>
#  include <string.h>
#  ifdef AMIGA
#    ifndef _DCC
#      include <dos.h>
#    endif /* !_DCC */
#  endif /* AMIGA */
#  ifdef ATARI
#    ifndef __GNUC__
#        include <tos.h>
#        include <ext.h>
#    else
#        include <unixlib.h>
#        include <fcntl.h>
#        define S_IWRITE    W_OK
#        define S_IREAD     R_OK
#    endif /* __GNUC__ */
#  endif /* ATARI */
#endif /* ANSI */

#ifndef ANSI
char *strchr();
char *strrchr();
#endif

/* open mode for files */
#ifdef ATARI
#  define OPEN_FOR_READING "rb"
#  define OPEN_FOR_WRITING "wb"
#  define OPEN_FOR_APPEND  "rb+"
#  ifndef __GNUC__
     extern int access(char *, int);
#  endif /* __GNUC__ */
#else
#  define OPEN_FOR_READING "r"
#  define OPEN_FOR_WRITING "w"
#  define OPEN_FOR_APPEND  "r+"
#endif

/* prototyping on/off */
#ifdef ANSI
#  define Args(x)	x
#else
#  define Args(x)	()
#endif /* ANSI */


#ifdef AZTEC_C
   void *malloc		Args((unsigned));
   void free		Args((char *));
   char *strchr();
   char *strrchr();
#endif /* AZTEC_C */


#ifdef AMIGA
#  ifdef LATTICE
#    define perror(x)	poserr(x)
#  endif /* LATTICE */
#  ifdef AZTEC_C
#    define remove(x)	unlink(x)
     /* warning: AztecC seems to have problems with the returncode from fseek */
#  endif /* AZTEC_C */
#else AMIGA
#  ifndef ANSI
#    define remove(x)	unlink(x)
#  endif /* ANSI */
#endif /* AMIGA */

#ifdef ATARI
#  include <errno.h>
#else
extern int errno;
#endif

/*	Structure of a fontlibrary :
 *	+---------------------------------------+
 *	|   magic number		4 Bytes	|
 *	|   number of direntries	4 Bytes	|
 *	|   [flib_dirent]*			|
 *	|   [modules]*				|
 *	+---------------------------------------+
 */



/* important constants */
#define OLD_LIBMAGIC	0xA797F033L		/* magic number */
#define LIBMAGIC	(((long)'F'<<24) | ((long)'L'<<16) | ((long)'I'<<8) | (long)'B')
#define LNKMAGIC	(((long)'F'<<24) | ((long)'L'<<16) | ((long)'N'<<8) | (long)'K')
#define FILENAMELEN	14
#define NEWFILENAMELEN	22
#define TMPFLIB		"tmpflib.tmp"
#define BUFSIZE		20480
#define DOSNAMESIZE	100
#define MAXLINKLEVELS	20

#ifdef AMIGA
#  define MACHINE	"AMIGA"
#else
#  ifdef ATARI
#    define MACHINE	"ATARI"
#  else
#    define MACHINE	"UNIX"
#    include <sys/file.h>
#    define S_IWRITE	W_OK
#    define S_IREAD	R_OK
#  endif /* ATARI */
#endif /* AMIGA */

#define VERSION		"1.03"
#ifdef ATARI
#  define HEADER		"FontLib Manager - Version %s for %s \275 1990 Georg Hessmann/Robert Stabl\n"
#else
#  define HEADER		"FontLib Manager - Version %s for %s (c) 1990 Georg Hessmann\n"
#endif

#define	OLD_VERSION	0
#define NEW_VERSION	1


static char buffer[BUFSIZE];	/* used to copy modules */


#ifndef FALSE
#  define FALSE		0
#endif /* FALSE */
#ifndef TRUE
#  define TRUE		(!FALSE)
#endif /* TRUE */

#define offset(ptr,member)	((long)(&((ptr)->member))-(long)(ptr))


/************ structure definitions ***************/
/* fontlib directory structures */
struct flib_dirent { char mname[FILENAMELEN];		/* old version */
                     long size;		/* size of pk-module in bytes */
                     long where;	/* position in flib-file */
                   };

struct new_flib_dirent { char  mname[NEWFILENAMELEN];	/* new version */
			 unsigned short checksum;
			 long  size;		/* size of pk-module in bytes */
			 long  where;		/* position in flib-file */
                       };

union direntry { struct flib_dirent	old;
		 struct new_flib_dirent	new;
	       };


/* internal representation of the flib-directory */
struct dirlist { struct new_flib_dirent dirent;
                 struct dirlist *next;
	       };

struct dir { long	    total;
	     long	    alloc;
	     int	    version;	/* old or new flib */
	     int	    is_link;
             struct dirlist *dirlist;
             char	    real_name[DOSNAMESIZE];
	   };


/*********   P R O T O T Y P E S   ********/

	/* main function						*/
void main				Args((int argc, char *argv[]));


/********* local functions **********/
	/* print the help						*/
static void  usage			Args((char *pname));
	/* parse the first argument					*/
static int   decode_args		Args((int argc, char **argv,
					      int *table,
					      int *extract,
					      int *create,
					      int *delete,
					      int *compress,
					      int *verbose,
					      int *rename,
					      int *test,
					      int *link,
					      int *term_input));
	/* delete flib with the name "name" and rename the tmpflib to "name" */
	/* nr is the number of modules in the flib => nr == 0 --> no flib    */
static int   insert_name_into_dir	Args((char *name,
					      struct dirlist **dirl,
					      int version));
	/* is module from "test" in "inp1" or "inp2" ? */
static struct dirlist *exist_entry	Args((struct dirlist *inp1,
					      struct dirlist *inp2,
					      struct dirlist *test));
	/* create a dirlist structure entry whith the module-name "name"    */
static int   read_new_modules		Args((int term_input,
					      int argc,
					      char **argv,
					      struct dir *directory,
					      struct dirlist **start_dirl,
					      int verbose));
	/* read a list of modules from argv or from stdin		*/
static FILE *open_flib			Args((char *name,
					      char *mode,
					      struct dir *directory,
					      short levels));
	/* open a flib and test the magic-number			*/
static int   read_dir			Args((FILE *f,
					      struct dir *directory));
	/* read the directory from the flib (file-pointer must be on the first dir)       */
	/* only this directory entries a correct where "where != 0" the others are unused */
static void  print_dir			Args((struct dir *directory,
					      char *lib_name,
					      int verbose));
	/* print the contents of the directory				*/
static int   ex_module			Args((struct dir *directory,
					      char *mname,
					      FILE *flib, int verbose));
	/* search a module in the flib and copy it to a new file	*/
static int   create_new_flib		Args((struct dir *directory,
					      char *name,
					      int verbose));
	/* create a complete (new) flib, copy only files into the flib	*/
static int   copy_module		Args((char *name,
					      FILE *flib,
					      long *size,
					      long *where,
					      unsigned short *check));
	/* create a new flib and prepare the directory part		*/
static FILE *copy_directory		Args((struct dir *directory,
					      char *name,
					      int verbose));
	/* copy a module (file) to the actual position in flib		*/
static FILE *copy_old_flib		Args((struct dir *directory,
					      FILE *flib,
					      char *name,
					      int verbose));
	/* copy the modules (from flib) with "where != 0" to flib (tmplib) */
static int   append_modules_to_flib	Args((struct dir *directory,
					      FILE *flib,
					      int verbose));
	/* copy the modules (files) with "where == 0" to flib (tmplib)     */
static int   del_module_from_dir	Args((struct dir *directory,
					      char *name,
					      int verbose));
	/* find a module and delete it from the directory list		*/
static void  copy_tmpflib		Args((char *name,
					      long nr));
	/* copy file source to file drain 				*/
static int   copy_file			Args((char *source,
					      char *drain));
	/* save directory to file					*/
static int   update_dir			Args((struct dir *directory,
					      FILE *flib,
					      int verbose));
	/* change module-names in directory				*/
static int   rename_entries		Args((struct dir *directory,
					      struct dirlist *dirl,
					      int verbose));
	/* test all checksums of the fontlibrary			*/
static void  test_flib			Args((FILE *flib,
					      struct dir *directory,
					      int verbose));
	/* read the directory structure					*/
static int   freaddir			Args((union direntry *dir,
					      int version,
					      FILE *f));
	/* read a four byte number <hihi lohi hilo lolo>		*/
static int   freadlong			Args((long *buf,
					      FILE *f));
	/* read a two byte number <hi lo>				*/
static int   freadshort			Args((unsigned short *buf,
					      FILE *f));
	/* write the directory structure				*/
static int   fwritedir			Args((union direntry *dir,
					      int version,
					      FILE *f));
	/* write a four byte number <hihi lohi hilo lolo>		*/
static int   fwritelong			Args((long buf,
					      FILE *f));
	/* write a two byte number <hi lo>				*/
static int   fwriteshort		Args((unsigned short buf,
					      FILE *f));



/********************   M A I N   ********************/
void main(argc, argv)
  int argc;
  char *argv[];
{
  FILE *flib;
  struct dir directory;
  char input[256];
  int table, extract, create, delete, compress, verbose, rename, test, link, term_input;
  int i;
#ifdef ATARI
# ifndef __GNUC__
  char progname [] = "flib";

  argv[0] = (char *)progname;
# endif
#endif

  if (argc < 3) {
	usage(argv[0]);
	exit(5);
  }
  directory.total   = directory.alloc = 0;
  directory.dirlist = NULL;
  directory.version = NEW_VERSION;	/* default version */
  flib = NULL;

  if (!decode_args(argc, argv, &table, &extract, &create, &delete, &compress,
		&verbose, &rename, &test, &link, &term_input)) {
	usage(argv[0]);
	exit(5);
  }

  if (verbose) {
	printf(HEADER,VERSION,MACHINE);
  }

  /**************** extract **************/
  if (extract) {
	if ((flib = open_flib(argv[2],OPEN_FOR_READING,&directory,(short)0)) == NULL) {
		exit(5);
	}
	if (!read_dir(flib,&directory)) {
		exit(5);
	}
	if (term_input) {
		while (!feof(stdin)) {
			if (gets(input) != NULL) {
				(void)ex_module(&directory,input,flib,verbose);
			}
		}
	}
	else {
	        if(argc == 3) { /* extract all if no modules specified ++jrb */
		    struct dirlist *dl;
		    for(dl = directory.dirlist; dl != NULL; dl = dl->next)
			(void)ex_module(&directory,dl->dirent.mname,flib,
					verbose);
		}
		else { /* extract only modules specified */
		    for (i=3; i<argc; i++) {
			(void)ex_module(&directory,argv[i],flib,verbose);
		    }
		}
	}
	fclose(flib);
	flib = NULL;
  }
  /**************** create **************/
  if (create) {
#if defined(AMIGA)
	if (access(argv[2],6) == 0) {	/* read + write */
#else
	if (access(argv[2],S_IWRITE | S_IREAD) == 0) {	/* read + write */
#endif
		struct dirlist *dirl, *start_dirl;
		FILE *tmplib;
		int nr;

		if ((flib = open_flib(argv[2],OPEN_FOR_READING,&directory,(short)0)) == NULL) {
			exit(5);
		}
		if (!read_dir(flib,&directory)) {
			exit(5);
		}
		/* append the rest */
		/* internal directory */
		for (dirl = directory.dirlist;
			dirl != NULL && dirl->next != NULL;
			dirl = dirl->next);
		nr = read_new_modules(term_input,argc,argv,
					&directory,&start_dirl,verbose);
		if (dirl == NULL) {
			directory.dirlist = start_dirl;
			directory.total = nr;
		}
		else {
			dirl->next = start_dirl;
			directory.total += nr;
		}
		directory.alloc += nr;
		/* copy old flib with the new directory */
		if ((tmplib = copy_old_flib(&directory,flib,argv[2],verbose)) == NULL) {
			exit(5);
		}
		/* append the new modules */
		if (!append_modules_to_flib(&directory,tmplib,verbose)) {
			exit(5);
		}
		fclose(tmplib);
		fclose(flib);
		flib = NULL;
		copy_tmpflib(directory.real_name,directory.total);
	}
	else {
		directory.total = read_new_modules(term_input,argc,argv,
				&directory,&(directory.dirlist),verbose);
		if (!create_new_flib(&directory,argv[2],verbose)) {
			exit(5);
		}
	}
  }
  /**************** delete **************/
  if (delete) {
	FILE *tmplib;

	if ((flib = open_flib(argv[2],OPEN_FOR_READING,&directory,(short)0)) == NULL) {
		exit(5);
	}
	if (directory.version == OLD_VERSION) {
		if (verbose) {
			printf("This option only works with the new flib-version!\n");
			printf("Convert first the flib with \"flib z %s\"\n",argv[2]);
		}
		else {
			fprintf(stderr,"Wrong flib-version!\n");
		}
	}
	if (!read_dir(flib,&directory)) {
		exit(5);
	}
	if (term_input) {
		while (!feof(stdin)) {
			if (gets(input) != NULL) {
				(void)del_module_from_dir(&directory,input,verbose);
			}
		}
	}
	else {
		if (argc==3) {
			if (verbose) {
				printf("No module to delete!?!\n");
			}
			fclose(flib);
			flib = NULL;
			exit(0);
		}
		else {
			for (i=3; i<argc; i++) {
				(void)del_module_from_dir(&directory,argv[i],verbose);
			}
		}
	}
	/* copy old flib with the new directory */
	if ((tmplib = copy_old_flib(&directory,flib,argv[2],verbose)) == NULL) {
		exit(5);
	}
	/* append the new modules */
	if (!append_modules_to_flib(&directory,tmplib,verbose)) {
		exit(5);
	}
	fclose(tmplib);
	fclose(flib);
	flib = NULL;
	copy_tmpflib(directory.real_name,directory.total);
  }
  /**************** compress **************/
  if (compress) {
	FILE *tmplib;

	if ((flib = open_flib(argv[2],OPEN_FOR_READING,&directory,(short)0)) == NULL) {
		exit(5);
	}
	if (!read_dir(flib,&directory)) {
		exit(5);
	}
	if (directory.version != NEW_VERSION) {
		directory.version = NEW_VERSION;
		if (verbose) {
			printf("Converting old to new version.\n");
		}
	}
	if (verbose) {
		printf("Old directory size: %ld, new directory size: %ld.\n",
			directory.alloc, directory.total);
	}
	/* copy old flib */
	if ((tmplib = copy_old_flib(&directory,flib,argv[2],verbose)) == NULL) {
		exit(5);
	}
	update_dir(&directory, tmplib, verbose);
	fclose(tmplib);
	fclose(flib);
	flib = NULL;
	copy_tmpflib(directory.real_name,directory.total);
  }
  /**************** rename **************/
  if (rename) {
	struct dirlist *dirl;
	int nr;

	if ((flib = open_flib(argv[2],OPEN_FOR_APPEND,&directory,(short)0)) == NULL) {
		exit(5);
	}
	if (directory.version == OLD_VERSION) {
		if (verbose) {
			printf("This option only works with the new flib-version!\n");
			printf("Convert first the flib with \"flib z %s\"\n",argv[2]);
		}
		else {
			fprintf(stderr,"Wrong flib-version!\n");
		}
	}
	nr = read_new_modules(term_input,argc,argv,&directory,&dirl,verbose);
	if (!read_dir(flib,&directory)) {
		exit(5);
	}
	if (!rename_entries(&directory,dirl,verbose)) {
		exit(5);
	}
	update_dir(&directory, flib, verbose);
	fclose(flib);
	flib = NULL;
  }
  /**************** test ***************/
  if (test) {
	if ((flib = open_flib(argv[2],OPEN_FOR_READING,&directory,(short)0)) == NULL) {
		exit(5);
	}
	if (directory.version == OLD_VERSION) {
		if (verbose) {
			printf("This option only works with the new flib-version!\n");
			printf("Convert first the flib with \"flib z %s\"\n",argv[2]);
		}
		else {
			fprintf(stderr,"Wrong flib-version!\n");
		}
	}
	else {
		if (directory.alloc == 0 && !read_dir(flib,&directory)) {
			exit(5);
		}
		test_flib(flib,&directory,verbose);
	}
	fclose(flib);
	flib = NULL;
  }
  /**************** link ***************/
  if (link) {
	char link_name[DOSNAMESIZE];

	if ((flib = fopen(argv[2],OPEN_FOR_WRITING)) == NULL) {
	}
	else {
		if (!fwritelong(LNKMAGIC,flib)) {
			perror("*** ");
			fprintf(stderr,"*** Can't write to LNK-flib \"%s\"!\n",
				argv[2]);
			exit(5);
		}
		link_name[0] = '<';
		link_name[1] = '\0';
		strcat(link_name,argv[3]);
		strcat(link_name,">");
		if (fwrite(link_name,sizeof(char),strlen(link_name),flib) != strlen(link_name)) {
			perror("*** ");
			fprintf(stderr,"*** Can't write to LNK-flib \"%s\"!\n",
				argv[2]);
			exit(5);
		}
		fclose(flib);
		flib = NULL;
	}
  }
  /**************** table **************/
  if (table) {
	if (flib == NULL) {
		if ((flib = open_flib(argv[2],OPEN_FOR_READING,&directory,(short)0)) == NULL) {
			exit(5);
		}
		if (directory.alloc == 0 && !read_dir(flib,&directory)) {
			exit(5);
		}
	}
	print_dir(&directory,argv[2],verbose);
	fclose(flib);
  }
}	/* main */


/* print the help */
static void usage(pname)
  char *pname;
{
  fprintf(stderr,HEADER,VERSION,MACHINE);
  fprintf(stderr,"usage: %s c|a|x|d|z|p|l|t[v] library [-|[modules]*]\n",pname);
  fprintf(stderr,"\tc,a : create library / add (replace) module(s) to (in) library,\n");
  fprintf(stderr,"\tx   : extract module(s) from library,\n");
  fprintf(stderr,"\td   : delete module(s) in library,\n");
  fprintf(stderr,"\tt   : print table,\n");
  fprintf(stderr,"\tr   : rename module(s) in library,\n");
  fprintf(stderr,"\tz   : create new flib from old flib,\n");
  fprintf(stderr,"\tp   : test checksums of all modules,\n");
  fprintf(stderr,"\tl   : create a flib link (second arg is the link destination),\n");
  fprintf(stderr,"\tv   : verbose mode,\n");
  fprintf(stderr,"\t?   : print this help,\n");
  fprintf(stderr,"\t-   : read module name(s) from stdin.\n");
}

/* parse the first argument */
static int decode_args(argc, argv, table, extract, create,
		delete, compress, verbose, rename, test, link, term_input)
  int argc;
  char **argv;
  int *table, *extract, *create, *delete, *compress, *verbose,
		*rename, *test, *link, *term_input;
{
  char *flags;
  int c;

  *table = *extract = *create = *delete = *compress = *verbose =
		*rename = *test = *link = *term_input = FALSE;
  flags = argv[1];
  if (*flags == '-') {
	flags++;
  }
  c = 0;
  for (; *flags != '\0'; flags++) {
	switch (*flags) {
		case 'c':
		case 'a': *create   = TRUE; c++; break;
		case 'x': *extract  = TRUE; c++; break;
		case 'd': *delete   = TRUE; c++; break;
		case 'z': *compress = TRUE; c++; break;
		case 'r': *rename   = TRUE; c++; break;
		case 'l': *link     = TRUE; c++; break;
		case 'p': *test     = TRUE; break;
		case 't': *table    = TRUE; break;
		case 'v': *verbose  = TRUE; break;
		case '?': return FALSE;
		default : fprintf(stderr, "*** Unknown flag '%c'!\n",*flags);
			  return FALSE;
	}
  }
  if (c >= 2) {
	fprintf(stderr,"*** The flags 'c' 'x' 'd' 'z' 'r' 'l' are mutual exclusive!\n");
	return FALSE;
  }
  if (!(*extract || *create || *delete || *table || *compress || *rename || *test || *link)) {
	fprintf(stderr,"*** Missing one of the flags 'c' 'x' 'd' 'z' 't' 'p' 'l'!\n");
	return FALSE;
  }
  if (*link && argc != 4) {
	fprintf(stderr,"*** Incorrect number of arguments!\n");
	return FALSE;
  }
  if (argc > 3 && strcmp(argv[3],"-") == 0) {
	*term_input = TRUE;
	if (*verbose && (*create || *extract || *delete || *rename)) {
		printf("Reading module names from standard input.\n");
	}
  }
  return TRUE;
}

/* delete flib with the name "name" and rename the tmpflib to "name" */
/* nr is the number of modules in the flib => nr == 0 --> no flib */
static void copy_tmpflib(name, nr)
  char *name;
  long nr;
{
  if (remove(name) != 0) {
	perror("*** ");
	fprintf(stderr,"*** Can't remove flib \"%s\"!\n",name);
  }
  if (nr > 0) {
	if (rename(TMPFLIB,name) != 0) {
		if (!copy_file(TMPFLIB,name)) {
			perror("*** ");
			fprintf(stderr,"*** Can't rename temporary flib \"%s\" to \"%s\"!\n",
				TMPFLIB,name);
		}
		if (remove(TMPFLIB) != 0) {
			perror("*** ");
			fprintf(stderr,"*** Can't remove temporary flib \"%s\"!\n",TMPFLIB);
		}
	}
  }
  else {
	if (remove(TMPFLIB) != 0) {
		perror("*** ");
		fprintf(stderr,"*** Can't remove temporary flib \"%s\"!\n",TMPFLIB);
	}
  }
}

/* copy file source to file drain 				*/
static int copy_file(source, drain)
  char *source;
  char *drain;
{
  FILE *sf, *df;
  long len;

  if ((sf = fopen(source,OPEN_FOR_READING)) == NULL) {
	return FALSE;
  }
  if ((df = fopen(drain,OPEN_FOR_WRITING)) == NULL) {
	fclose(sf);
	return FALSE;
  }
  while ((len = fread(buffer,sizeof(char),BUFSIZE,sf)) == BUFSIZE) {
	if (fwrite(buffer,sizeof(char),BUFSIZE,df) != BUFSIZE) {
		fclose(sf);
		fclose(df);
		return FALSE;
	}
  }
  if (len > 0) {
	if (fwrite(buffer,sizeof(char),len,df) != len) {
		fclose(sf);
		fclose(df);
		return FALSE;
	}
  }
  fclose(sf);
  fclose(df);
  
  return TRUE;
}

/* create a dirlist structure entry with the module-name "name" */
static int insert_name_into_dir(name,dirl,version)
  char *name;
  struct dirlist **dirl;
  int version;
{
  int j;

  if ((version == NEW_VERSION && strlen(name) > NEWFILENAMELEN-1) ||
		(version == OLD_VERSION && strlen(name) > FILENAMELEN-1)) {
	fprintf(stderr,"*** Module name \"%s\" too long!\n",name);
	return FALSE;
  }
  if ((*dirl = (struct dirlist *)
		malloc(sizeof(struct dirlist))) == NULL) {
	fprintf(stderr,"*** No memory for internal flib directory!\n");
	exit(5);
  }
  for (j=0; j<NEWFILENAMELEN; j++) {	/* clear the string */
	(*dirl)->dirent.mname[j] = '\0';
  }
  strcpy((*dirl)->dirent.mname,name);
  (*dirl)->dirent.size  = 0L;
  (*dirl)->dirent.where = 0L;
  (*dirl)->next = NULL;
  return TRUE;
}

/* is module from "test" in "inp1" or "inp2" ? */
static struct dirlist *exist_entry(inp1, inp2, test)
  struct dirlist *inp1, *inp2;
  struct dirlist *test;		/* only one entry in list */
{
  char *name = test->dirent.mname;

  for (; inp1 != NULL && strcmp(name,inp1->dirent.mname) != 0; inp1 = inp1->next);
  if (inp1 != NULL) {
	return inp1;
  }
  for (; inp2 != NULL && strcmp(name,inp2->dirent.mname) != 0; inp2 = inp2->next);
  if (inp2 != NULL) {
	return inp2;
  }
  return NULL;
}

/* read a list of modules from argv or from stdin */
static int read_new_modules(term_input,argc,argv,directory,start_dirl,verbose)
  int term_input;
  int argc;
  char **argv;
  struct dir *directory;
  struct dirlist **start_dirl;
  int verbose;
{
  int nr_modules, i;
  struct dirlist *dirl, *old_dirl, *find_old;
  char input[256];

  old_dirl = dirl = NULL;
  nr_modules = 0;
  *start_dirl = NULL;

  if (term_input) {
	while (!feof(stdin)) {
		if (gets(input) != NULL) {
			if (insert_name_into_dir(input, &dirl,directory->version)) {
				if ((find_old = exist_entry(directory->dirlist,
						*start_dirl,dirl)) != NULL) {
					/* the module is already in the lib */
					/* replace it */
					find_old->dirent.where = 0L;
					/* now it must new inserted */
					if (verbose) {
						printf("Replacing module \"%s\".\n",
							find_old->dirent.mname);
					}
				}
				else {
					nr_modules++;
					if (old_dirl == NULL) {
						*start_dirl = dirl;
					}
					else {
						old_dirl->next = dirl;
					}
					old_dirl = dirl;
				}
			}
		}
	}
  }
  else {
	for (i=3; i<argc; i++) {
		if (insert_name_into_dir(argv[i], &dirl, directory->version)) {
			if ((find_old = exist_entry(directory->dirlist,
						*start_dirl,dirl)) != NULL) {
				/* the module is already in the lib */
				/* replace it */
				find_old->dirent.where = 0L;
				/* now it must new inserted */
				if (verbose) {
					printf("Replacing module \"%s\".\n",
						find_old->dirent.mname);
				}
			}
			else {
				nr_modules++;
				if (old_dirl == NULL) {
					*start_dirl = dirl;
				}
				else {
					old_dirl->next = dirl;
				}
				old_dirl = dirl;
			}
		}
	}
  }
  if (dirl != NULL) {
	dirl->next = NULL;
  }
  return nr_modules;
}


/* open a flib and test the magic-number */
static FILE *open_flib(name,mode,directory,levels)
  char *name;
  char *mode;
  struct dir *directory;
  short levels;
{
  static char link_name[DOSNAMESIZE];
  char *ptr;
  FILE *f;
  long magic;

  directory->is_link = FALSE;
  directory->real_name[0] = '\0';

  if ((f = fopen(name,mode)) == NULL) {
	fprintf(stderr,"*** Can't open library \"%s\"!\n",name);
	return NULL;
  }
  if (!freadlong(&magic,f) ||
	(magic != LIBMAGIC && magic != OLD_LIBMAGIC && magic != LNKMAGIC)) {
		fclose(f);
		fprintf(stderr,"*** File \"%s\" isn't a font library!\n",name);
		return NULL;
  }
  if (magic == LNKMAGIC) {
	(void)fread(link_name,sizeof(char),DOSNAMESIZE,f);
	fclose(f);
	if (link_name[0] != '<') {
		fprintf(stderr,"*** Illegal flib-link \"%s\"!\n",name);
		return NULL;
	}
	ptr = strrchr(link_name,'>');
	if (ptr == NULL) {
		fprintf(stderr,"*** Illegal flib-link \"%s\"!\n",name);
		return NULL;
	}
	levels++;
	if (levels > MAXLINKLEVELS) {
		fprintf(stderr,"*** To many link levels!\n");
		return NULL;
	}
	*ptr = '\0';
	ptr = link_name;
	ptr++;
	f = open_flib(ptr,mode,directory,levels);
	directory->is_link = TRUE;
  }
  else {
	if (magic == LIBMAGIC) {
		directory->version = NEW_VERSION;
	}
	else {
		directory->version = OLD_VERSION;
	}
	strcpy(directory->real_name,name);
  }

  return f;
}

/* read the directory from the flib (file-pointer must be on the first dir) */
/* only this directory entries a correct where "where != 0" the others are unused */
static int read_dir(f,directory)
  FILE *f;
  struct dir *directory;
{
  long alloc;
  union direntry dir;
  struct dirlist *direntr, *old_direntry;
  int i, j, nr;

  if (!freadlong(&alloc,f)) {
	fprintf(stderr,"*** Error while reading internal flib directory!\n");
	return FALSE;
  }
  direntr = old_direntry = NULL;
  for (i=0, nr=0; i<alloc && !feof(f); i++) {
	if (!freaddir(&dir,directory->version,f)) {
		fprintf(stderr,"*** Error while reading internal flib directory!\n");
		return FALSE;
	}
	if ((directory->version == NEW_VERSION && dir.new.where != 0) ||	/* used entry */
		(directory->version == OLD_VERSION && dir.old.where != 0)) {
		nr++;
		if ((direntr = (struct dirlist *)
				malloc(sizeof(struct dirlist))) == NULL) {
			fprintf(stderr,"*** No memory for internal flib directory!\n");
			return FALSE;
		}
		for (j=0; j<NEWFILENAMELEN; j++) {	/* clear the string */
			direntr->dirent.mname[j] = '\0';
		}
		if (old_direntry == NULL ) {
			directory->dirlist = direntr;
		}
		else {
			old_direntry->next = direntr;
		}
		if (directory->version == NEW_VERSION) {
			direntr->dirent = dir.new;
		}
		else {
			strncpy(direntr->dirent.mname,dir.old.mname,FILENAMELEN);
			direntr->dirent.size     = dir.old.size;
			direntr->dirent.where    = dir.old.where;
			direntr->dirent.checksum = 0;
		}
		old_direntry = direntr;
	}
  }
  if (direntr != NULL) {
	direntr->next = NULL;
  }
  directory->total    = nr;
  directory->alloc    = alloc;
  if (nr == 0) {
	directory->dirlist = NULL;
  }
  return TRUE;
}

/* print the contents of the directory */
static void print_dir(directory, lib_name, verbose)
  struct dir *directory;
  char *lib_name;
  int verbose;
{ 
  struct dirlist *temp;

  if (verbose) {
	if (directory->total == 1) {
		printf ("Library contains one module. ");
	}
	else {
		printf ("Library contains %ld modules. ",directory->total);
	}
	if (directory->alloc == 1) {
		printf ("Directory size is one module.\n");
	}
	else {
		printf ("Directory size is %ld modules.\n",directory->alloc);
	}
	if (directory->is_link) {
		printf ("The library \"%s\" is a link to \"%s\"!\n",
				lib_name, directory->real_name);
	}
	if (directory->version == OLD_VERSION) {
		printf ("WARNING: That's an old library-version!\n");
	}
	printf ("\n  Module name           Size   Position\n");
	printf ("  --------------------- ------ --------\n");
	for (temp = directory->dirlist; temp != NULL; temp = temp->next) {
		printf ("  %-21s %6ld %8ld\n", temp->dirent.mname,
			temp->dirent.size, temp->dirent.where);
	}
	printf("\n");
  }
  else {
	for (temp = directory->dirlist; temp != NULL; temp = temp->next) {
		puts(temp->dirent.mname);
	}
  }
  
}

/* search a module in the flib and copy it to a new file */
static int ex_module(directory, mname, flib, verbose)
  struct dir *directory;
  char *mname;
  FILE *flib;
  int verbose;
{
  struct dirlist *temp;
  FILE *module;
  int i, j, count;
  unsigned short check;

  if (directory == NULL || flib == NULL) {
	fprintf(stderr,"*** Internal error!\n");
	return FALSE;
  }

  /* find the module */
  for (temp = directory->dirlist; temp != NULL
	&& strcmp(temp->dirent.mname,mname) != 0; temp = temp->next);

  if (temp == NULL) {
	fprintf(stderr,"*** Can't find module \"%s\"!\n",mname);
	return FALSE;
  }

  if (verbose) {
	printf("Extracting module %s \t(%ld bytes).\n",mname, temp->dirent.size);
  }

  if (fseek(flib,temp->dirent.where,0) != 0) {
	perror("*** ");
	fprintf(stderr,"*** Error during fseek!\n");
	return FALSE;
  }
  if ((module = fopen(mname,OPEN_FOR_WRITING)) == NULL) {
	fprintf(stderr,"*** Can't create file \"%s\"!\n",mname);
	return FALSE;
  }

  count = temp->dirent.size / BUFSIZE;
  check = 0;
  for (i=0; i<count; i++) {
	if (fread(buffer,sizeof(char),BUFSIZE,flib)!=BUFSIZE) {
		fclose(module);
		fprintf(stderr,"*** Can't read from flib!\n");
		return FALSE;
	}
	for (j=0; j<BUFSIZE; j++) {
		check += (unsigned short)buffer[j];
	}
	if (fwrite(buffer,sizeof(char),BUFSIZE,module) != BUFSIZE) {
		fclose(module);
		fprintf(stderr,"*** Can't write to module %s!\n",mname);
		return FALSE;
	}
  }
  i = temp->dirent.size - count * BUFSIZE;	/* copy rest */
  if (i > 0) {
	if (fread(buffer,sizeof(char),i,flib) != i) {
		fclose(module);
		fprintf(stderr,"*** Can't read from flib!\n");
		return FALSE;
	}
	for (j=0; j<i; j++) {
		check += buffer[j];
	}
	if (fwrite(buffer,sizeof(char),i,module) != i) {
		fclose(module);
		fprintf(stderr,"*** Can't write to module %s!\n",mname);
		return FALSE;
	}
  }

  fclose(module);
  if (directory->version != OLD_VERSION && check != temp->dirent.checksum) {
	fprintf(stderr,"*** WARNING: Module \"%s\" extracted with wrong checksum!\n",
				mname);
  }

  return TRUE;
}

/* create a complete (new) flib, copy only files into the flib */
static int create_new_flib(directory, name, verbose)
  struct dir *directory;
  char *name;
  int verbose;
{
  FILE *flib;
  struct dirlist *dirl;
  long size=0, where=0;
  unsigned short check;

  if ((flib = copy_directory(directory, name, verbose)) == NULL) {
	return FALSE;
  }

  /* module abspeichern */
  for (dirl = directory->dirlist; dirl != NULL; dirl = dirl->next) {
	if (verbose) {
		printf("Copying module \"%s\"\t... ",dirl->dirent.mname);
	}
	if (!copy_module(dirl->dirent.mname,flib,&size,&where,&check)) {
		fprintf(stderr,"\n*** Can't copy module \"%s\" to library!\n",
				dirl->dirent.mname);
		return FALSE;
	}
	if (verbose) {
		printf("ok. \t(%ld bytes at %ld)\n",size,where);
	}
	dirl->dirent.size     = size;
	dirl->dirent.where    = where;
	dirl->dirent.checksum = check;
  }
  update_dir(directory, flib, verbose);

  return TRUE;
}


/* create a new flib and prepare the directory part */
static FILE *copy_directory(directory, name, verbose)
  struct dir *directory;
  char *name;
  int verbose;
{
  FILE *flib;
  long magic = (directory->version == NEW_VERSION) ? LIBMAGIC : OLD_LIBMAGIC;
  struct dirlist *dirl;
  union direntry dir;

  if ((flib = fopen(name,OPEN_FOR_WRITING)) == NULL) {
	fprintf(stderr,"*** Can't open destination library!\n");
	return NULL;
  }
  if (!fwritelong(magic,flib) || !fwritelong(directory->total,flib)) {
	fprintf(stderr,"*** Can't write to destination library!\n");
	return NULL;
  }
  /* directory anlegen */
  if (verbose) {
	printf("Creating internal flib directory\t... ");
  }
  for (dirl = directory->dirlist; dirl != NULL; dirl = dirl->next) {
	if (directory->version == NEW_VERSION) {
		dir.new = dirl->dirent;
	}
	else {
		strncpy(dir.old.mname,dirl->dirent.mname,FILENAMELEN);
		dir.old.size  = dirl->dirent.size;
		dir.old.where = dirl->dirent.where;
	}
	if (!fwritedir(&dir,directory->version,flib)) {
		fprintf(stderr,"*** Can't write to destination library!\n");
		return NULL;
	}
  }
  if (verbose) {
	printf("ok.\n");
  }
  return flib;
}

/* copy a module (file) to the actual position in flib */
static int copy_module(name, flib, size, where, check)
  char *name;
  FILE *flib;
  long *size, *where;
  unsigned short *check;
{
  FILE *module;
  int len, i;

  if ((module = fopen(name,OPEN_FOR_READING)) == NULL) {
	return FALSE;
  }
  *size = 0;
  *where = ftell(flib);
  *check = 0;
  while ((len = fread(buffer,sizeof(char),BUFSIZE,module)) == BUFSIZE) {
	if (fwrite(buffer,sizeof(char),BUFSIZE,flib) != BUFSIZE) {
		fclose(module);
		return FALSE;
	}
	*size += BUFSIZE;
	for (i=0; i<BUFSIZE; i++) {
		*check += (unsigned short)buffer[i];
	}
  }
  if (len > 0) {
	if (fwrite(buffer,sizeof(char),len,flib) != len) {
		fclose(module);
		return FALSE;
	}
	*size += len;
	for (i=0; i<len; i++) {
		*check += (unsigned short)buffer[i];
	}
  }
  fclose(module);

  return TRUE;
}

/* copy the modules (from flib) with "where != 0" to flib (tmplib) */
static FILE *copy_old_flib(directory, flib, name, verbose)
  struct dir *directory;
  FILE *flib;
  char *name;
  int verbose;
{
  FILE *tmplib;
  struct dirlist *dirl;
  long where;
  int i, j;
  long len ,count;
  unsigned short check;

  if ((tmplib = copy_directory(directory, TMPFLIB, verbose)) == NULL) {
	return NULL;
  }

  /* module copy */
  for (dirl = directory->dirlist; dirl != NULL;	dirl = dirl->next) {
	if (dirl->dirent.where != 0L) {
		if (verbose) {
			printf("Copying module \"%s\"\t... ",dirl->dirent.mname);
		}
		if (fseek(flib,dirl->dirent.where,0) != 0) {
			perror("*** ");
			fprintf(stderr,"*** Error during fseek!\n");
			return NULL;
		}
		where = ftell(tmplib);
		count = dirl->dirent.size / BUFSIZE;
		check = 0;
		for (i=0; i<count; i++) {
			if (fread(buffer,sizeof(char),BUFSIZE,flib)!=BUFSIZE) {
				fclose(tmplib);
				fprintf(stderr,"*** Can't read from flib!\n");
				return NULL;
			}
			for (j=0; j<BUFSIZE; j++) {
				check += (unsigned short)buffer[j];
			}
			if (fwrite(buffer,sizeof(char),BUFSIZE,tmplib) != BUFSIZE) {
				fclose(tmplib);
				fprintf(stderr,"*** Can't write to temporary flib!\n");
				return NULL;
			}
		}
		len = dirl->dirent.size - count * BUFSIZE;
		if (len > 0) {
			if (fread(buffer,sizeof(char),(int)len,flib) != len) {
				fclose(tmplib);
				fprintf(stderr,"*** Can't read from flib!\n");
				return NULL;
			}
			for (j=0; j<len; j++) {
				check += (unsigned short)buffer[j];
			}
			if (fwrite(buffer,sizeof(char),(int)len,tmplib) != len) {
				fclose(tmplib);
				fprintf(stderr,"*** Can't write to temporary flib!\n");
				return NULL;
			}
		}
		dirl->dirent.where = where;
		dirl->dirent.checksum = check;
		if (verbose) {
			printf("ok.\n");
		}
	}
  }
  return tmplib;
}

/* copy the modules (files) with "where == 0" to flib (tmplib) */
static int append_modules_to_flib(directory, flib, verbose)
  struct dir *directory;
  FILE *flib;
  int verbose;
{
  struct dirlist *dirl;
  long size, where;
  unsigned short check;

  /* module abspeichern */
  if (fseek(flib,0L,2) != 0) {		/* end of file */
	perror("*** ");
	fprintf(stderr,"*** Error during fseek!\n");
	return 0;
  }
  for (dirl = directory->dirlist; dirl != NULL; dirl = dirl->next) {
	if (dirl->dirent.where == 0L) {
		if (verbose) {
			printf("Copying module \"%s\"\t... ",dirl->dirent.mname);
		}
		if (!copy_module(dirl->dirent.mname,flib,&size,&where,&check)) {
			fprintf(stderr,"\n*** Can't copy module \"%s\" to library!\n");
			return FALSE;
		}
		if (verbose) {
			printf("ok. \t(%ld bytes at %ld)\n",size,where);
		}
		dirl->dirent.size     = size;
		dirl->dirent.where    = where;
		dirl->dirent.checksum = check;
	}
  }
  return update_dir(directory, flib, verbose);
}

/* find a module and delete it from the directory list */
static int del_module_from_dir(directory, name, verbose)
  struct dir *directory;
  char *name;
  int verbose;
{
  struct dirlist *temp, *parent;

  if (directory == NULL) {
	fprintf(stderr,"*** Internal error!\n");
	return FALSE;
  }

  /* find the module */
  for (temp = directory->dirlist, parent = NULL; temp != NULL
	&& strcmp(temp->dirent.mname,name) != 0;
	parent = temp, temp = temp->next);

  if (temp == NULL) {
	fprintf(stderr,"*** Can't find module \"%s\"!\n",name);
	return FALSE;
  }
  /* delete module from directory-list */
  if (parent == NULL) {
	directory->dirlist = temp->next;
  }
  else {
	parent->next = temp->next;
  }
  free(temp);
  directory->alloc = --directory->total;

  return TRUE;
}

/* save directory to file */
static int update_dir(directory, flib, verbose)
  struct dir *directory;
  FILE *flib;
  int verbose;
{
  struct dirlist *dirl;
  union direntry dir;

  /* directory size-where */
  if (verbose) {
	printf("Updating internal flib directory\t... ");
  }
  if (fseek(flib,8L,0) != 0) {
	perror("*** ");
	fprintf(stderr,"*** Can't fseek?!\n");
	return FALSE;
  }
  for (dirl = directory->dirlist; dirl != NULL; dirl = dirl->next) {
	if (directory->version == NEW_VERSION) {
		dir.new = dirl->dirent;
	}
	else {
		strncpy(dir.old.mname,dirl->dirent.mname,FILENAMELEN);
		dir.old.size  = dirl->dirent.size;
		dir.old.where = dirl->dirent.where;
	}
	if (!fwritedir(&dir,directory->version,flib)) {
		fprintf(stderr,"*** Can't write to destination library!\n");
		return FALSE;
	}
  }
  if (verbose) {
	printf("ok.\n");
  }
  return TRUE;
}


/* change module-names in directory				*/
/* if dirl empty then change all names in directory		*/
static int rename_entries(directory,dirl,verbose)
  struct dir	 *directory;
  struct dirlist *dirl;
  int		 verbose;
{
  struct dirlist *entry, *found;
  char str[256];
  int allowed_length = (directory->version == NEW_VERSION)
				? NEWFILENAMELEN
				: FILENAMELEN;


  if (dirl == NULL) {		/* no modules -> change all names */
	for (entry = directory->dirlist; entry != NULL; entry = entry->next) {
		do {
			printf("Old name: %s, change it to: ",entry->dirent.mname);
			if (gets(str) == NULL) {
				fprintf(stderr,"\nUnexpected end of \"stdin\"!?\n");
				return FALSE;
			}
			if (strlen(str) > allowed_length) {
				fprintf(stderr,"New name too long!\n");
			}
		} while (strlen(str) > allowed_length);
		if (str[0] != '\0') {
			if (verbose) {
				printf("%s ---> %s\n",entry->dirent.mname,str);
			}
			strcpy(entry->dirent.mname,str);
		}
	}
  }
  else {			/* change only the names of the given modules */
	for (entry = dirl; entry != NULL; entry = entry->next) {
		if ((found = exist_entry(NULL,directory->dirlist,entry)) != NULL) {
			do {
				printf("Old name: %s, change it to: ",
						found->dirent.mname);
				if (gets(str) == NULL) {
					fprintf(stderr,"\nUnexpected end of \"stdin\"!?\n");
					return FALSE;
				}
				if (strlen(str) > allowed_length) {
					fprintf(stderr,"New name too long!\n");
				}
			} while (strlen(str) > allowed_length);
			if (str[0] != '\0') {
				if (verbose) {
					printf("%s ---> %s\n",found->dirent.mname,str);
				}
				strcpy(found->dirent.mname,str);
			}
		}
	}
  }
  return TRUE;
}


/* test all checksums of the fontlibrary			*/
static void test_flib(flib, directory, verbose)
  FILE *flib;
  struct dir *directory;
  int verbose;
{
  int i, j;
  struct dirlist *dirl;
  unsigned short check;
  long count, len;

  for (dirl = directory->dirlist; dirl != NULL;	dirl = dirl->next) {
	if (dirl->dirent.where != 0L) {
		if (verbose) {
			printf("Checking module \"%s\"\t... ",dirl->dirent.mname);
		}
		if (fseek(flib,dirl->dirent.where,0) != 0) {
			perror("*** ");
			fprintf(stderr,"*** Error during fseek!\n");
			return;
		}
		count = dirl->dirent.size / (long)BUFSIZE;
		check = 0;
		for (i=0; i<count; i++) {
			if (fread(buffer,sizeof(char),BUFSIZE,flib)!=BUFSIZE) {
				fprintf(stderr,"*** Can't read from flib!\n");
				return;
			}
			for (j=0; j<BUFSIZE; j++) {
				check += (unsigned short)buffer[j];
			}
		}
		len = dirl->dirent.size - count * (long)BUFSIZE;
		if (len > 0) {
			if (fread(buffer,sizeof(char),(int)len,flib) != len) {
				fprintf(stderr,"*** Can't read from flib!\n");
				return;
			}
			for (j=0; j<len; j++) {
				check += (unsigned short)buffer[j];
			}
		}
		if (dirl->dirent.checksum == check) {
			if (verbose) {
				printf("ok.\n");
			}
		}
		else {
			if (verbose) {
				printf("ERROR (expected %u, found %u)\n",
					dirl->dirent.checksum, check);
			}
			else {
				fprintf(stderr,
			          "ERROR: module \"%s\" (expected %u, found %u)\n",
				  dirl->dirent.mname, dirl->dirent.checksum, check);
			}
		}
	}
  }
}


/* read the directory structure					*/
static int freaddir(dir,version,f)
  union direntry *dir;
  int version;
  FILE *f;
{
  if (version == OLD_VERSION) {
	if (fread(dir->old.mname,FILENAMELEN,1,f) != 1) {
		return FALSE;
	}
	dir->new.mname[FILENAMELEN] = '\0';
	if (!freadlong(&(dir->old.size),f)) {
		return FALSE;
	}
	if (!freadlong(&(dir->old.where),f)) {
		return FALSE;
	}
  }
  else {
	if (fread(dir->new.mname,1,NEWFILENAMELEN,f) != NEWFILENAMELEN) {
		return FALSE;
	}
	if (!freadshort(&(dir->new.checksum),f)) {
		return FALSE;
	}
	if (!freadlong(&(dir->new.size),f)) {
		return FALSE;
	}
	if (!freadlong(&(dir->new.where),f)) {
		return FALSE;
	}	
  }
  return TRUE;
}


/* read a four byte number <hihi lohi hilo lolo> */
static int freadlong(buf,f)
  long *buf;
  FILE *f;
{
  unsigned char b[4];

  if (fread((char *)b,1,4,f) != 4) {
	return FALSE;
  }
  *buf = (long)(((unsigned long)b[0]) << 24) | (((unsigned long)b[1]) << 16) | 
			(((unsigned long)b[2]) << 8) | ((unsigned long)b[3]);

  return TRUE;
}

/* read a two byte number <hi lo> */
static int freadshort(buf,f)
  unsigned short *buf;
  FILE *f;
{
  unsigned char b[2];

  if (fread((char *)b,1,2,f) != 2) {
	return FALSE;
  }
  *buf = (unsigned short) (((unsigned short)b[0]) << 8) | ((unsigned short)b[1]);

  return TRUE;
}


/* write the directory structure				*/
static int fwritedir(dir,version,f)
  union direntry *dir;
  int version;
  FILE *f;
{
  if (version == OLD_VERSION) {
	if (fwrite(dir->new.mname,NEWFILENAMELEN,1,f) != 1) {
		return FALSE;
	}
	if (!fwritelong(dir->new.size,f)) {
		return FALSE;
	}
	if (!fwritelong(dir->new.where,f)) {
		return FALSE;
	}
  }
  else {
	if (fwrite(dir->new.mname,NEWFILENAMELEN,1,f) != 1) {
		return FALSE;
	}
	if (!fwriteshort(dir->new.checksum,f)) {
		return FALSE;
	}
	if (!fwritelong(dir->new.size,f)) {
		return FALSE;
	}
	if (!fwritelong(dir->new.where,f)) {
		return FALSE;
	}	
  }
  return TRUE;
}

/* write a four byte number <hihi lohi hilo lolo> */
static int fwritelong(buf,f)
  long buf;
  FILE *f;
{
  unsigned char b[4];

  b[0] = (unsigned char)(((unsigned long)buf & 0xFF000000L) >> 24);
  b[1] = (unsigned char)(((unsigned long)buf & 0x00FF0000L) >> 16);
  b[2] = (unsigned char)(((unsigned long)buf & 0x0000FF00L) >> 8);
  b[3] = (unsigned char) ((unsigned long)buf & 0x000000FFL);
  if (fwrite((char *)b,1,4,f) != 4) {
	return FALSE;
  }
  return TRUE;
}

/* write a two byte number <hi lo> */
#ifdef ANSI
static int fwriteshort(unsigned short buf, FILE *f)
#else
static int fwriteshort(buf,f)
  unsigned short buf;
  FILE *f;
#endif /* ANSI */
{
  unsigned char b[2];

  b[0] = (unsigned char)(((unsigned long)buf & 0x0000FF00L) >> 8);
  b[1] = (unsigned char) ((unsigned long)buf & 0x000000FFL);
  if (fwrite((char *)b,1,2,f) != 2) {
	return FALSE;
  }
  return TRUE;
}

