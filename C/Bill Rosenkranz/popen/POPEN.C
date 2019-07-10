#include "config.h"

/*
 *	popen, pclose functions for TOS (Alcyon 4.14 flavor...)
 *
 *	#include <stdio.h>
 *
 *	FILE *popen (char *command, char *type)
 *	int pclose (FILE *stream)
 *
 *	Atari TOS version by Bill Rosenkranz (rosenkra%c1yankee@convex.com)
 *	14 Oct 1990. Based in part on MS-DOS version but heavily hacked for
 *	TOS (copyright at bottom of file).
 *
 *	thing changed include:
 *
 *	- malloc space for names in struct _TODO list (command string
 *	  should be allocated by caller)
 *	- relink list before freeing memory (free name, too)
 *	- add decent system(3) call (_psystem for gulam is flakey, though)
 *	- comment the whole thing and add debugging output
 *	- copious error checking and code restructuring
 *	- more or less POSIX/ANSI
 *	- should be portable to most ST compilers (developed with Alcyon)
 *	- all "local" variables, functions, etc. start with underscore (_)
 */

#include <stddef.h>
#include <stdlib.h>			/* for malloc, etc */
#include <stdio.h>


/*
 *	Possible actions on an popened file
 */
#define DELETE		0
#define EXECUTE		1

#ifdef ALCYON
# ifndef void
#  define void		int
# endif
#endif


/*
 *	helpful macros...
 */
#define lastchar(s)	((s)[strlen(s)-1])	/* last char in a string */
#define plastchar(s)	&((s)[strlen(s)-1])	/* ptr to it */


/*
 *	Linked list of things to do at pclose time...
 */
struct _TODO
{
	FILE	       *_td_f;		/* File we are working on (to fclose) */
	char	       *_td_name;	/* Name of the tmp file (to unlink) */
	char	       *_td_command;	/* Command to execute */
	int		_td_what;	/* What to do (EXECUTE or DELETE) */
	struct _TODO   *_td_next;	/* Next structure in linked list */
};


/*
 *	globals
 */
static struct _TODO    *_todolist = 0L;	/* ptr to start of linked list */


/*
 *	functions
 */
#ifdef HAVE_ONEXIT
static int	_close_pipes ();	/* Clean up function (LOCAL) */
#endif
static int	_pipadd ();		/* add to todo list (LOCAL) */
FILE	       *popen ();
int		pclose ();
int		SYSTEM ();		/* this should go in libc seperately */



/*------------------------------*/
/*	_pipadd			*/
/*------------------------------*/
static int _pipadd (f, command, name, what)
FILE   *f;
char   *command;
char   *name;
int	what;
{

/*
 *	add a file "f" running the command "command" on file "name" to the
 *	list of actions to be done at the end. the action is specified in
 *	what. return -1 on failure, 0 if ok.
 *
 *	the tree looks like this (after successive calls):
 *
 *	initial:	first call:	second call:	third call:	etc...
 *				
 *	_todolist	_todolist	_todolist	_todolist
 *	 |		 | 		 | 		 | 
 *	 |		 |     NULL	 |     NULL	 |     NULL
 *	 |		 |      ^	 |      ^	 |      ^
 *	 |		 |      |	 |      |	 |      |
 *	 |		 |      \----\	 |      \----\	 |      \----\
 *	 |		 |     ____  |	 |     ____  |	 |     ____  |
 *	 \--->NULL	 \--->|1st | |	 | /->|1st | |	 | /->|1st | |
 *			      |____| |	 | |  |____| |	 | |  |____| |
 *			      |next|-/	 | |  |next|-/	 | |  |next|-/
 *			       ----	 | |   ----	 | |   ----
 *				^	 | |		 | |
 *				|	 | \---------\	 | \---------\
 *				|	 |     ____  |	 |     ____  |
 *				|	 \--->|2nd | |	 | /->|2nd | |
 *				|	      |____| |	 | |  |____| |
 *			  struct _TODO	      |next|-/	 | |  |next|-/
 *					       ----	 | |   ----
 *							 | |
 *							 | \---------\
 *							 |     ____  |
 *							 \--->|3rd | |
 *							      |____| |
 *							      |next|-/
 *							       ----
 *
 *	when we go to search for an object in the list, we start at _todolist
 *	and work our way backwards, up the tree. _todolist always points to
 *	the bottom of the tree, usually the last one added. pclose will free
 *	these objects, so the tree must be relinked, just in case we do more
 *	than 1 or 2 popens.
 */

	struct _TODO   *p;

#ifdef DEBUG
	if (_pipdebugging)
	{
		fprintf (stderr,
			"_pipadd: f=%08lx, command=|%s|, name=|%s|, what=%d\n",
			f, command, name, what);
	}
#endif

	/*
	 *   get some memory for this object in the linked list...
	 */
	p = (struct _TODO *) malloc ((unsigned) sizeof (struct _TODO));
	if (p == (struct _TODO *) NULL)
	{
#ifdef DEBUG
		if (_pipdebugging)
		{
			fprintf (stderr,
				"_pipadd: malloc of _TODO struct failed.\n");
		}
#endif
		return (-1);
	}

#ifdef DEBUG
	if (_pipdebugging)
	{
		fprintf (stderr, "_pipadd: malloc ret p=%08lx\n", (long) p);
	}
#endif

	/*
	 *   fill in the blanks with the things we need to undo later...
	 */
	p->_td_f       = f;
	p->_td_command = command;
	p->_td_name    = name;
	p->_td_what    = what;
	p->_td_next    = _todolist;
	_todolist      = p;

#ifdef DEBUG
	if (_pipdebugging)
	{
		fprintf (stderr, "_pipadd: p=%08lx\n", (long) p);
		fprintf (stderr, "_pipadd: p->_td_f=%08lx\n", (long) p->_td_f);
		fprintf (stderr, "_pipadd: p->_td_command=|%s|\n", p->_td_command);
		fprintf (stderr, "_pipadd: p->_td_name=|%s|\n", p->_td_name);
		fprintf (stderr, "_pipadd: p->_td_what=%d\n", p->_td_what);
		fprintf (stderr, "_pipadd: p->_td_next=%08lx\n", (long) p->_td_next);
		fprintf (stderr, "_pipadd: _todolist=%08lx\n", (long) _todolist);
	}
#endif
	return (0);
}



/*------------------------------*/
/*	popen			*/
/*------------------------------*/
FILE *popen (command, t)
char   *command;
char   *t;
{
/*
 *	open a pipe for command "command" of type "t" (r or w).
 *	ret ptr to stream or null ptr if error.
 */

	char		buff[256];
	char	       *name;
	char	       *ptmp;
	FILE	       *f;
	static int	init = 0;


#ifdef DEBUG
	if (_pipdebugging)
	{
		fprintf (stderr, "popen: command=|%s|, type=|%s|, init=%d\n",
			command, t, init);
	}
#endif

	/*
	 *   initialize. on first entry, set up call for onexit which
	 *   cleans up the pipes in case user did not pclose. increment
	 *   static variable init. if onexit() does not exist, just bump
	 *   counter and forget about it.
	 */
#ifdef HAVE_ONEXIT
	if (!init)
	{
		if (!onexit (_close_pipes))
			return ((FILE *) NULL);
		else
			init++;
	}
#else
	init++;
#endif /*HAVE_ONEXIT*/


	/*
	 *   make a temporary file. there are better ways, but this is fine.
	 *   check env for TMP directory, else use cwd. we use successive
	 *   numbers from 0 to create files of the form "__pipe__.000", etc.
	 */
	if ((ptmp = getenv ("TMP")) == (char *) NULL)
	{
		if ((name = malloc (16)) == (char *) 0)
		{
#ifdef DEBUG
			if (_pipdebugging)
			{
				fprintf (stderr, "popen: name malloc failed\n");
			}
#endif
			return ((FILE *) NULL);
		}
#ifdef DEBUG
		if (_pipdebugging)
		{
			fprintf (stderr, "popen: name malloc ret p=%08lx\n",
				(long) name);
		}
#endif
		sprintf (name, "__pipe__.%03d", init-1);
	}
	else
	{
		if ((name = malloc (strlen (ptmp) + 16)) == (char *) 0)
		{
#ifdef DEBUG
			if (_pipdebugging)
			{
				fprintf (stderr, "popen: name malloc failed\n");
			}
#endif
			return ((FILE *) NULL);
		}
#ifdef DEBUG
		if (_pipdebugging)
		{
			fprintf (stderr, "popen: name malloc ret p=%08lx\n",
				(long) name);
		}
#endif
		if (lastchar (ptmp) == '\\')
			sprintf (name, "%s__pipe__.%03d", ptmp, init-1);
		else
			sprintf (name, "%s\\__pipe__.%03d", ptmp, init-1);
	}
#ifdef DEBUG
	if (_pipdebugging)
	{
		fprintf (stderr, "popen: name=|%s|\n", name);
	}
#endif

	/*
	 *   which action (read or write)?
	 */
	switch (*t)
	{
	case 'r':
		/*
		 *   read. set up command to pipe its output to tmp file.
		 *   then execute it. then open the "pipe" file.
		 */
		sprintf (buff, "%s >%s", command, name);

#ifdef DEBUG
		if (_pipdebugging)
		{
			fprintf (stderr, "popen: read: SYSTEM(%s)\n", buff);
		}
#endif

		if (SYSTEM (buff) || ((f = fopen (name, "r")) == (FILE *) NULL))
		{
#ifdef DEBUG
			if (_pipdebugging)
			{
				fprintf (stderr,
					"popen: read: SYSTEM or open fail\n");
			}
#endif
			return ((FILE *) NULL);
		}


		/*
		 *   add file to _todolist. since this is read, action will
		 *   be to delete in pclose. if _pipadd bombs, we consider
		 *   this an error and return NULL. it only bombs if malloc
		 *   fails...
		 */
		if (_pipadd (f, command, name, DELETE))
		{
			fclose (f);
#ifdef DEBUG
			if (!_pipdebugging)
				unlink (name);
#else
			unlink (name);
#endif
			return ((FILE *) NULL);
		}


		/*
		 *   if we get this far, everything probably worked ok.
		 *   return the stream representing the output of command
		 */
#ifdef DEBUG
		if (_pipdebugging)
		{
			fprintf (stderr, "popen: read: f=%08lx\n", (long) f);
		}
#endif
		return ((FILE *) f);


	case 'w':
		/*
		 *   write. note that we don't execute anything yet until pipe
		 *   is closed so you MUST pclose to get the desired result!
		 *
		 *   first open the tmp file...
		 */
#ifdef DEBUG
		if (_pipdebugging)
		{
			fprintf (stderr, "popen: write: fopen (%s)\n", name);
		}
#endif
		if ((f = fopen (name, "w")) == (FILE *) NULL)
		{
#ifdef DEBUG
			if (_pipdebugging)
			{
				fprintf (stderr, "popen: write: open fail\n");
			}
#endif
			return ((FILE *) NULL);
		}


		/*
		 *   add it to the _todolist. since this is write, action will
		 *   be to execute in pclose.
		 */
		if (_pipadd (f, command, name, EXECUTE))
		{
			fclose (f);
#ifdef DEBUG
			if (!_pipdebugging)
				unlink (name);
#else
			unlink (name);
#endif

			return ((FILE *) NULL);
		}


		/*
		 *   return the stream
		 */
#ifdef DEBUG
		if (_pipdebugging)
		{
			fprintf (stderr, "popen: write: f=%08lx\n", (long) f);
		}
#endif
		return ((FILE *) f);


	default:
		/*
		 *   error...
		 */
#ifdef DEBUG
		if (_pipdebugging)
		{
			fprintf (stderr, "popen: default: wrong type\n");
		}
#endif
		return ((FILE *) NULL);
	}
}



/*------------------------------*/
/*	pclose			*/
/*------------------------------*/
int pclose (f)
FILE   *f;
{

/*
 *	close an open pipe. ret 0 if ok, else ret -1
 */

	struct _TODO   *p,
		       *prev;
	char		buff[256];
	char		name[256];
	int		status;


#ifdef DEBUG
	if (_pipdebugging)
	{
		fprintf (stderr, "pclose: f=%08lx\n", (long) f);
	}
#endif

	/*
	 *   walk the list, looking for the correct stream to free. note
	 *   that _todolist points to the last pipe. we need prev to relink
	 *   the list when something is deleted. first time is an exception
	 *   during the relink. loop ends when we reach last (first allocated)
	 *   pipe, whose next points to NULL. if we close all pipes, we
	 *   should have _todolist point to NULL.
	 */
	for (p = _todolist; p; prev = p, p = p->_td_next)
	{
		/*
		 *   is this the one to close???
		 */
		if (p->_td_f == f)
		{
			strcpy (name, p->_td_name);

			switch (p->_td_what)
			{
			case DELETE:
				/*
				 *   we DELETE read pipes...
				 */
#ifdef DEBUG
				if (_pipdebugging)
				{
					fprintf (stderr,
						"pclose: delete: p=%08lx\n",
						(long) p);
				}
#endif
				/*
				 *   free space allocated for struct. we
				 *   should relink the list first!
				 */
				if (p == _todolist)	/* first one... */
					_todolist      = p->_td_next;
				else
					prev->_td_next = p->_td_next;
#ifdef DEBUG
				if (_pipdebugging)
				{
					fprintf (stderr,
						"pclose: name free (%08lx)\n",
						(long) p->_td_name);
					fprintf (stderr,
						"pclose: struct free (%08lx)\n",
						(long) p);
				}
#endif
				free (p->_td_name);
				free (p);

				/*
				 *   close the file...
				 */
				if (fclose (f) == EOF)
				{
#ifdef DEBUG
					if (!_pipdebugging)
						unlink (name);
#else
					unlink (name);
#endif
					status = EOF;
				}
#ifdef DEBUG
				else if (!_pipdebugging && unlink (name) < 0)
					status = EOF;
#else
				else if (unlink (name) < 0)
					status = EOF;
#endif
				else
					status = 0;

				return (status);

			case EXECUTE:
				/*
				 *   we EXECUTE write pipes when closed
				 *
				 *   set up command...
				 */
				sprintf (buff, "%s <%s",
					p->_td_command, p->_td_name);
#ifdef DEBUG
				if (_pipdebugging)
				{
					fprintf (stderr,
						"pclose: execute: SYSTEM (%s)\n",
						buff);
				}
#endif
				/*
				 *   free space allocated for struct. we
				 *   should relink the list first!
				 */
				if (p == _todolist)	/* first one... */
					_todolist      = p->_td_next;
				else
					prev->_td_next = p->_td_next;
#ifdef DEBUG
				if (_pipdebugging)
				{
					fprintf (stderr,
						"pclose: name free (%08lx)\n",
						(long) p->_td_name);
					fprintf (stderr,
						"pclose: struct free (%08lx)\n",
						(long) p);
				}
#endif
				free (p->_td_name);
				free (p);

				/*
				 *   execute the command and close file
				 */
/*!!!*/				if (SYSTEM (buff))
				{
					fclose (f);
#ifdef DEBUG
					if (!_pipdebugging)
						unlink (name);
#else
					unlink (name);
#endif
					status = EOF;
				}
				else if (fclose (f) == EOF)
				{
#ifdef DEBUG
					if (!_pipdebugging)
						unlink (name);
#else
					unlink (name);
#endif
					status = EOF;
				}
#ifdef DEBUG
				else if (!_pipdebugging && unlink (name) < 0)
					status = EOF;
#else
				else if (unlink (name) < 0)
					status = EOF;
#endif
				else
					status = 0;

				return (status);

			default:
				/*
				 *   error (no stream)
				 */
				return (EOF);
			}
		}
	}

	/*
	 *   error (no stream)
	 */
	return (EOF);
}



/*------------------------------*/
/*	_close_pipes		*/
/*------------------------------*/
static int _close_pipes ()
{

/*
 *	Clean up at the end.  Called by the onexit handler, if available...
 */

	extern int	pclose ();

	struct _TODO   *p;

#ifdef DEBUG
	if (_pipdebugging)
	{
		fprintf (stderr, "_close_pipes: enter...\n");
	}
#endif
	for (p = _todolist; p; p = p->_td_next)
		pclose (p->_td_f);

	return (0);
}








#ifdef STANDALONE

/*
 *	this is a test program to read and write pipes, "simultaneously".
 *	note we are restricted to 16 (_NBUF) pipes maximum.
 */

#include <stdio.h>

char   *read_cmd = READCMD;		/* cmd issued to read pipe */
char   *writ_cmd = WRITCMD;		/* cmd issued to write pipe */

main (argc, argv)
int	argc;
char   *argv[];
{
	extern FILE    *popen ();
	extern int	pclose ();

	FILE	       *pip_read;	/* stream for reading */
	FILE	       *pip_writ;	/* stream for writing */
	char		buf[1024];	/* buffer for read */
	int		ret_status;	/* for pclose check */


	/*
	 *   open a pipe for reading. here we just do an "ls".
	 *   the FILE returned we can then read from.
	 */
	fprintf (stderr, "main: call popen(%s, \"r\")\n", read_cmd);
	if ((pip_read = popen (read_cmd, "r")) == (FILE *) NULL)
	{
		fprintf (stderr, "could not open read pipe\n");
		exit (1);
	}


	/*
	 *   open a pipe for writing. here we do a "grep".
	 *   the FILE returned we can then write to.
	 */
	fprintf (stderr, "main: call popen(%s, \"w\")\n", writ_cmd);
	if ((pip_writ = popen (writ_cmd, "w")) == (FILE *) NULL)
	{
		fprintf (stderr, "could not open write pipe\n");
		exit (1);
	}


	/*
	 *   in this loop, we read from the read pipe (ls command) and
	 *   write to the write pipe (grep command). note that the write
	 *   pipe does not really happen until we pclose the pipe later.
	 *   all that happens here is the tmp file for the write pipe gets
	 *   filled.
	 */
	fprintf (stderr, "main: start reading pipe...\n");fflush (stderr);
	while (1)
	{
		fgets (buf, 1023, pip_read);
		if (feof (pip_read))
			break;
		fprintf (stderr, "pip_read: %s", buf);	fflush (stderr);
		fprintf (pip_writ, "%s", buf);		fflush (pip_writ);
	}


	/*
	 *   close the pipes. when we close the write pipe, it then does
	 *   its thing...
	 */
	ret_status = pclose (pip_read);
	fprintf (stderr, "main: pclose (pip_read) ret %d\n", ret_status);

	fprintf (stderr, "main: start writing pipe...\n");fflush (stderr);
	ret_status = pclose (pip_writ);
	fprintf (stderr, "main: pclose (pip_writ) ret %d\n", ret_status);


	fputs ("done...\n\n", stderr);

	exit (0);
}





/*------------------------------*/
/*	_psystem		*/
/*------------------------------*/

#include <osbind.h>

#define SHELLP		((char **) 0x04f6L)	/* system variable */
#define G_MAGIC		0x0135			/* LSW of gulam magic */
#define G_LMAGIC	0x420135L		/* full gulam magic */

int _psystem (cmdstr)
char   *cmdstr;
{

/*
 *	this is a system call which uses gulam to execute the command in
 *	input string. this (presumably) gives us aliases, path, etc.
 */

	long		save_ssp;	/* for Super (saved ssp) */
	short		sh_magic;	/* short magic */
	long		sh_lmagic;	/* long magic */
	char	       *tgptr;		/* storage for togu_ */
					/* if you really would like to have */
					/* it right, then tgptr should be a */
					/* pointer to void a bit of overkill*/
 					/* on ST :-) */
	int		(*cgp)();	/* pointer to callgulam()    */
					/* also contains togu_, but  */
					/* a type is different       */
	void		(*glp)();	/* pointer to getlineviaue() */
	int		cgp_ret;	/* return from cgp */


#ifdef DEBUG
	if (_pipdebugging)
	{
		fprintf (stderr, "_psystem: cmdstr=|%s|\n", cmdstr);
	}
#endif

	/*
	 *   get shell pointer (in super mode!)
	 */
	save_ssp = Super (0L);
	tgptr    = *SHELLP;
	Super (save_ssp);
#ifdef DEBUG
	if (_pipdebugging)
	{
		fprintf (stderr, "_psystem: tgptr=%08lx\n", (long) tgptr);
	}
#endif

	/*
	 *   check magic number...
	 */
	sh_magic   = *((short *)(tgptr - 8));
	sh_lmagic  = *((long *)(tgptr - 10));
	sh_lmagic &= 0x00FFFFFFL;
	if (sh_magic != G_MAGIC || sh_lmagic != G_LMAGIC)
	{
#ifdef DEBUG
		if (_pipdebugging)
		{
			fprintf (stderr, "_psystem: wrong magic value %04x %08lx\n",
				sh_magic, sh_lmagic);
		}
#endif
		return (-1);
	}


	/*
	 *   now make the functions
	 */
/*!!!	cgp = *((int (*)()) tgptr);*/
/*!!!	glp = *((void (*)()) (tgptr - 6));*/
	cgp = (int (*)()) tgptr;
	glp = (void (*)()) (tgptr - 6);

#ifdef DEBUG
	if (_pipdebugging)
	{
		fprintf (stderr, "_psystem: cgp=%08lx, glp=%08lx\n",
			(long) cgp, (long) glp);
	}
#endif

	/*
	 *   call gulam with command...
	 */
	cgp_ret = (*cgp)(cmdstr);

#ifdef DEBUG
	if (_pipdebugging)
	{
		fprintf (stderr, "_psystem: cgp_ret=%d\n", cgp_ret);
	}
#endif

	/*
	 *   return what gulam did (exit condition, presumably)
	 */
	return (cgp_ret);
}




/*------------------------------*/
/*	_xsystem		*/
/*------------------------------*/

static char   *_pthext[] = {".ttp",".prg",".tos",0L};	/* execute file extn */

int _xsystem (str)
char   *str;
{
	extern char    *getenv ();
	extern char    *index ();
	extern char    *rindex ();
	extern int	_system ();

	char           *ppp[256];
	char		pth[1024];
	char		cmd[256];
	char		name[128];
	char		tail[128];
	register char  *ptail;
	register char  *ppth;
	register char  *ps;
	register char  *ps1;
	register int	i;
	register int	j;
	int		type = 0;
	

	/*
	 *   zero out space for copy of path
	 */
	for (i = 0, ppth = pth; i < 1024; i++)
		*ppth++ = '\0';

	/*
	 *   get path from environment
	 */
	if ((ppth = getenv ("PATH")) == (char *) 0)
	{
		return (127);
	}

	/*
	 *   copy to our buffer
	 */
	strcpy (pth, ppth);
#ifdef DEBUG
	if (_pipdebugging)
	{
		fprintf (stderr, "_xsystem: PATH=|%s|\n", pth);
	}
#endif
	/*
	 *   fill in the argv-like array of pointers to the strings
	 */
	for (i = 0, ps = pth, ps1 = pth; *ps; ps++)
	{
		if (*ps == ',' || *ps == ';' || *ps == ' ')
		{
			*ps = '\0';
			ppp[i] = ps1;
			ps1 = ps + 1;
#ifdef DEBUG
			if (_pipdebugging)
			{
				fprintf (stderr, "_xsystem: ppp[%2d]=|%s|\n",
					i, ppp[i]);
			}
#endif
			i++;
		}
	}
	ppp[i] = (char *) 0;


	/*
	 *   get command name from input string
	 */
	strcpy (name, str);
	for (ps = name; *ps; ps++)
	{
		if (*ps == ' ' || *ps == '\t' || *ps == '\n' || *ps == '\r')
		{
			*ps = '\0';
			ptail = ++ps;
			break;
		}
	}

	/*
	 *   see if it might already have full path and .ext
	 */
	ps = &name[strlen (name) - 4];

#ifdef DEBUG
	if (_pipdebugging)
	{
		fprintf (stderr, "_xsystem: name=|%s|\n", name);
		fprintf (stderr, "_xsystem: ps  =|%s|\n", ps);
	}
#endif
	if ((*ps == '.'
	&& (!strcmp (ps, ".ttp") || !strcmp (ps, ".prg") || !strcmp (ps, ".tos")))
	&& index (name, '\\'))
	{
		/*
		 *   ext and path given. do it here...
		 */
		type = 1;

#ifdef DEBUG
		if (_pipdebugging)
		{
			fprintf (stderr, "_xsystem: type %d\n", type);
		}
#endif
		strcpy (cmd, name);
		strcat (cmd, " ");
		strcat (cmd, ptail);

		return (_system (cmd));
	}
	else if ((*ps == '.'
	&& (!strcmp (ps, ".ttp") || !strcmp (ps, ".prg") || !strcmp (ps, ".tos")))
	&& !index (name, '\\'))
	{
		/*
		 *   ext and NO path given
		 */
		type = 2;
	}
	else if (*ps != '.' && index (name, '\\'))
	{
		/*
		 *   NO ext but path given
		 */
		type = 3;
	}
#ifdef DEBUG
	if (_pipdebugging)
	{
		fprintf (stderr, "_xsystem: type %d\n", type);
	}
#endif

	/*
	 *   cycle through each path entry
	 */
	for (i = 0; ppp[i]; i++)
	{
		/*
		 *   build name
		 */
		for (j = 0; _pthext[j]; j++)
		{
			if (type != 3)
			{
				strcpy (cmd, ppp[i]);
				strcat (cmd, "\\");
				strcat (cmd, name);
			}
			else
				strcpy (cmd, name);
			if (type != 2)
				strcat (cmd, _pthext[j]);

#ifdef DEBUG
			if (_pipdebugging)
			{
				fprintf (stderr, "_xsystem: access (%s, 0)\n",
					cmd);
			}
#endif
			if (access (cmd, 0) == 0)
			{
#ifdef DEBUG
				if (_pipdebugging)
				{
					fprintf (stderr, "----- it exists -----\n");
				}
#endif
				strcat (cmd, " ");
				strcat (cmd, ptail);

#ifdef DEBUG
				if (_pipdebugging)
				{
					fprintf (stderr, "_xsystem: _system (%s)\n",
						cmd);
				}
#endif
				return (_system (cmd));
			}
		}
	}


	return (127);
}



/*------------------------------*/
/*	_system			*/
/*------------------------------*/

#include <ctype.h>
#include <osbind.h>

#define NULL		0L
#define MAXTAIL		127

int _system (cmd)
char   *cmd;
{

/*
 *	executes a command. returns command exit status or -127 if error
 *	in this routine.
 *
 *	takes a string and puts it into a form Pexec understands:
 *
 *		_system ("c:\\bin\\cp.prg file1 file2");
 *
 *	becomes
 *
 *		Pexec (0, "c:\\bin\\cp.prg", "xfile1 file2", 0L);
 *
 *	where x is a byte containing the length of the command tail (file1...)
 *	the full path to the command MUST be given.
 *
 *	calls Pexec, strlen, strcpy, isspace (ctype macro).
 */

	extern int	strlen ();
	extern char    *strcpy ();

	char    	command[128],	/* holds command name */
	        	tail[256];	/* holds command tail */
	register char  *p;
	register int    len;
	int		ret;


	/*
	 *   break up command into command and command tail.
	 *
	 *   start by copying command from input string...
	 */
	for (p = command; *cmd && !isspace (*cmd); *p++ = *cmd++)
		;
	*p = '\0';

	/*
	 *   now skip blanks in input string to get args, if any...
	 */
	while (*cmd && isspace (*cmd))
		cmd++;

	/*
	 *   check tail length...
	 */
	if ((len = strlen (cmd)) >= MAXTAIL)
	{
#ifdef DEBUG
		if (_pipdebugging)
		{
			fprintf (stderr, "_system: tail too long (%d)\n",
				(int) len);
		}
#endif
		return (-127);		/* too long! */
	}

	/*
	 *   set tail length in first byte then copy tail...
	 */
	tail[0] = (char) len;
	strcpy (&tail[1], cmd);
#ifdef DEBUG
	if (_pipdebugging)
	{
		fprintf (stderr, "_system: command:  |%s|\n", command);
		fprintf (stderr, "_system: tail:     |%s|\n", &tail[1]);
		fprintf (stderr, "_system: tail len: %d\n", (int) tail[0]);
	}
#endif

	/*
	 *   do it! child inherits our environment...
	 */
	ret = (int) Pexec (0, command, tail, (char *) NULL);

	return (ret);
}

#endif /*STANDALONE*/

/*	based in part on some software for MS-DOS by:
 *
 *	(C) Copyright 1988, 1990 Diomidis Spinellis. All rights reserved. 
 *
 *	Redistribution and use in source and binary forms are permitted
 *	provided that the above copyright notice and this paragraph are
 *	duplicated in all such forms and that any documentation,
 *	advertising materials, and other materials related to such
 *	distribution and use acknowledge that the software was developed
 *	by Diomidis Spinellis.
 *	THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 *	IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 *	WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 *	since this now bears little resemblence to the original, and since
 *	this relys on my own stuff, i don't know if this copyright is really
 *	of use to the original author. however, credit where credit is due...
 */
