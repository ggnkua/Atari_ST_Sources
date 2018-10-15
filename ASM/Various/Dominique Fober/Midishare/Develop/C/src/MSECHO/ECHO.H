/*********************************************************************

	ECHO.H

	Midi Echo		Accessoire de bureau
	d‚finitions de constantes et structures de donn‚es.

	GRAME		D. Fober
	24/10/89	
*********************************************************************/

#define NUMVERSION 	120

#ifdef TURBO_C
# define TedInfo(a,b) a[b].ob_spec.tedinfo
# define Getshift	Kbshift
# define cdecl		cdecl
#else
# define TedInfo(a,b) ((TEDINFO *)a[b].ob_spec)
# define cdecl
#endif

#define TRUE	1
#define FALSE	0

/*------------------------------------------------------------------*/
/* codes d'erreurs pour la gestion de l'application MidiShare */
#define 	MSH_OK	0		/* tout s'est bien pass‚ */
#define 	MSH_NO	(-1)		/* MidiShare n'est pas install‚ */
#define 	MSH_FULL	(-2)		/* pas d'application MidiShare libre */

/*------------------------------------------------------------------*/
/* d‚finition de structure de donn‚es */

struct echoState{		/* gestion des echos */
	int state;		/* echo on ou off */
	int delay;		/* d‚lai entre r‚p‚titions (en 1/100s.) */
	int amort;		/* amortissement= diminution de v‚locit‚ */
};

/******************************** fin *******************************/
