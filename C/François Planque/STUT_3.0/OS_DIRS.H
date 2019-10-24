/*
 * OS_Dirs.h
 */
 
#ifndef _OS_DIRS_H_
#define _OS_DIRS_H_

typedef struct direntry
	{
		unsigned char		uc_attrib;			/* Attributs */
	   char           	sz_fname[14];		/* Nom */
		unsigned long  	ul_length;			/* Longueur */
		time_t				time_LastChange;	/* Date de modif, format UNIX */
	}
	DIRENTRY;

#endif