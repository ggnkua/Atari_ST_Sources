/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#ifdef RECOVER	/* the body is the rest of this file */

/* Format of records within the jrec file: information to allow
 * recovery from a crash.
 *
 * Note: the recovery info is
 * (1) architecture dependent -- it contains ints, among other things
 * (2) version dependent -- this format started in 4.15.16
 * (3) configuration dependent -- affected by any change to FILESIZE
 */

# define RECMAGIC	-(('J' << 8) + 1)	/* JOVE recovery file, version 1 */

struct rec_head {
	short	RecMagic;	/* (partial) compatibility check */
# ifdef UNIX
	int		Uid;		/* uid of owner */
	pid_t		Pid;		/* pid of jove process */
# endif
	char		TmpFileName[FILESIZE];	/* name of corresponding tempfile */
	time_t		UpdTime;	/* last time this was updated */
	int		Nbuffers;	/* number of buffers */
	daddr		FreePtr;	/* position of DFree */
};

struct rec_entry {
	char	r_bname[FILESIZE],
		r_fname[FILESIZE];
	int	r_nlines,
		r_dotline,	/* so we can really save the context */
		r_dotchar;
};

#endif /* RECOVER */
