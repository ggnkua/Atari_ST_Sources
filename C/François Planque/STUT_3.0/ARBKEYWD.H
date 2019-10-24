/*
 * Arbo_Keyword_Public.h
 */

#ifndef _ARBKEYWD_H_ 
#define _ARBKEYWD_H_

/*
 * Actions suite … un mot clef:
 */
	#define		ACTION_NONE				0
	#define		ACTION_CLS				100		/* Efface ‚cran */
	#define		ACTION_FULLCLS			102		/* Efface ‚cran + status line */
	#define		ACTION_GETTIME			200		/* Donne date */
	#define		ACTION_SETTIME			250		/* Fixe date */
	#define		ACTION_2BOMBES			902		/* Plantage 2 bombes */
	#define		ACTION_DEL_RECORD		1000		/* Effacement d'un record */


/*
 * KEYWORD_LIST
 *
 * History:
 * --------
 * 18.05.94: Created by fplanque
 * 29.03.95: Extended
 */
typedef
	struct		keyword_linklist
	{
		struct keyword_linklist	*	next;				/* Pointeur sur elt suivant */
		int								n_Event;			/* Code de l'‚venement */
		int								n_Action1;		/* No de l'action … entreprendre */
		int								n_Action2;		/* No d'une autre action … entreprendre */
		UINT								u_flags;
		char							*	psz_KeyWord;	/* Ptr sur mot clef */
		char							*	psz_DestPage;	/* Ptr sur nom page destination */
	}
	KEYWORD_LIST;


#endif