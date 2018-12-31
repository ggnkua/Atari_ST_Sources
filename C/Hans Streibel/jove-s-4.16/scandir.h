/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

extern int
	jscandir proto((char *dir, char ***nmptr,
		bool (*qualify) ptrproto((char *)),
		int (*sorter) ptrproto((UnivConstPtr, UnivConstPtr))));

extern void
	freedir proto((char ***nmptr,int nentries));

#ifdef MSFILESYSTEM
extern bool	MatchDir;
#endif
