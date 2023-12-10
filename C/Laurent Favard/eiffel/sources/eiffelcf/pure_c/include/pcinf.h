/*
 * ----------------------------------------------------------------------------------------------
 *			Module de gestion du fichier de configuration INF de l'application.
 *
 * 	Author  : 	FAVARD Laurent, FunShip (c)
 *	File    : 	TOOLS.H
 *	Date    : 	15 Mai 1997
 *	Release : 	03 Juin 1997
 *	Version : 	1.0
 *	Country : 	FRANCE
 *			
 *
 *				- Copyright Atari FunShip (c) 1994-97 -
 * ----------------------------------------------------------------------------------------------
 */

#ifndef		__PROFILEINF__
#define		__PROFILEINF__	__PROFILEINF__

extern	void	GetProfileString(char *FileNameINF, char *Chapter, char *Entry, char *ValeurChamp, char *Default);
extern	long	GetLongProfile(char *FileNameINF, char *Chapter, char *Entry, long Default);

extern	void 	SetProfileString(char *FileNameINF, char *Chapter, char *Entry, char *Value);
extern	void 	SetLongProfile(char *FileNameINF, char *Chapter, char *Entry, long Value);

extern	void	SaveProfile(void);
extern	void	CloseProfile(void);

#endif