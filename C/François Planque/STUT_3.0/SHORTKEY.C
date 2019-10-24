/*
 * ShortKeys.c
 *
 * S'occupe de g‚rer les raccourcis claviers
 *
 * 20.11.94: Created
 */

 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"SHORTKEY.C v1.00 - 03.95"
 
/*
 * System headers:
 */
	#include	<stdio.h>
	#include <string.h>
	#include <aes.h>
          
/*
 * Custom headers:
 */
	#include "SPEC_PU.H"
	#include "WIN_PU.H"

	#include	"DEBUG_PU.H"	
	#include "SHORT_PU.H"	

/*
 * ------------------------ CONSTANTS -------------------------
 */

#define	NB_CTRL_SHORTCUTS		20
#define	NB_ALT_SHORTCUTS		20

/*
 * ------------------------ STRUCTURES -------------------------
 */
typedef
	struct
	{
		char	c_KeyCode;
		char	c_EqTitle;
		char	c_EqEntry;
	}
	SHORTKEY;

/*
 * ------------------------ PROTOTYPES -------------------------
 */

/*
 * EXTernal prototypes:
 */
	static	void	maptree( OBJECT *tree, int this, int last, int (*routine)( OBJECT *tree, int tmp1 ) );


/*
 * PRIVate INTernal prototypes:
 */

	static	int	ExtractShortKey( 			/* Out: TRUE */
							OBJECT *	pObj_Tree, 	/* In: Arbre ds lequel on se trouve */
							int		n_Obj );		/* In: No de l'objet … examiner */


/*
 * ---------------------------- VARIABLES -------------------------------
 */

/*
 * Variables internes priv‚es:
 */
	/* 
	 * Tables de raccourcis claviers:
	 */
	static	SHORTKEY	M_TShort_CtrlMap[ NB_CTRL_SHORTCUTS ];
	static	SHORTKEY	M_TShort_AltMap[ NB_ALT_SHORTCUTS ];
	/*
	 * Nbre de raccourcis claviers pour menu ppal:
	 */
	static	int	M_nb_CtrlShorts = 0;
	static	int	M_nb_AltShorts = 0;
	/* 
	 * Compteur du titre de menu correspondant … l'entr‚e courament visit‚e:
	 */
	static	int	M_n_CurrentTitle = 1;

/*
 * ---------------------------- METHODES -------------------------------
 */

/*
 * Create_KeyMap(-)
 *
 * Cr‚e table de raccourcis calviers en parcourant le menu
 *
 * 20.11.94: fplanque: created
 */
void	Create_KeyMap(
			OBJECT	*	pObj_Menu )	/* In: Arbre Menu … analyser */
{
	maptree( pObj_Menu, ROOT, NIL, ExtractShortKey );
}



/*
 * ExtractShortKey(-)
 * 
 * Extrait le raccourci clavier qui correspond … une entr‚e de menu
 * et le suave ds un tableau
 *
 * 20.11.94: fplanque: Created
 */
int	ExtractShortKey( 			/* Out: TRUE */
			OBJECT *	pObj_Tree, 	/* In: Arbre ds lequel on se trouve */
			int		n_Obj )		/* In: No de l'objet … examiner */
{
	if( M_nb_CtrlShorts >= NB_CTRL_SHORTCUTS || M_nb_AltShorts >= NB_ALT_SHORTCUTS )
	{
		signale( "Short Key Map Full!" );
		return FALSE0;		/* Je ne suis pas bien sur de l'utilisation de FALSE ici */
	}
	
	if( pObj_Tree[ n_Obj ] .ob_type == G_BOX )
	{
		M_n_CurrentTitle ++;		
	}
	else if( pObj_Tree[ n_Obj ] .ob_type == G_STRING )
	{
		char * psz_entry 	= pObj_Tree[ n_Obj ] .ob_spec.free_string;
		size_t size_entry = strlen( psz_entry );

		switch( psz_entry[ size_entry - 3 ] )
		{
			case	'^':
				M_TShort_CtrlMap[ M_nb_CtrlShorts ] .c_KeyCode = psz_entry[ size_entry - 2 ];
				M_TShort_CtrlMap[ M_nb_CtrlShorts ] .c_EqTitle = M_n_CurrentTitle;
				M_TShort_CtrlMap[ M_nb_CtrlShorts++ ] .c_EqEntry = n_Obj;
				break;
						
			case	ALT_SIGN:
				M_TShort_AltMap[ M_nb_AltShorts ] .c_KeyCode = psz_entry[ size_entry - 2 ];
				M_TShort_AltMap[ M_nb_AltShorts ] .c_EqTitle = M_n_CurrentTitle;
				M_TShort_AltMap[ M_nb_AltShorts++ ] .c_EqEntry = n_Obj;
				break;
		}
	}

	return	TRUE_1;
}


/*
 * Lookup_Shortkey(-)
 *
 * Trouve l'ent‚e de menu associ‚e … un raccourci clavier
 *
 * 22.11.94: fplanque: Created
 */
int	Lookup_Shortkey(			/* Out: no de l'entr‚e menu ‚quivalente; NIL si pas trouv‚ */
			int	n_kbd_state, 	/* In:  Etat du clavier lors de l'appui de touche */
			int	n_ScanCode, 	/* In:  Scancode de la touche press‚e */
			char	c_car,			/* In:  Code ascii de la touche */
			int *	pn_Title )		/* Out: Idx du titre de menu concern‚ */
{
	int	n;

	FAKE_USE( n_ScanCode );
	*pn_Title = NIL_1;

	/*
	 * Raccourcis avec touche control:
	 */
	if( n_kbd_state & K_CTRL )
	{
		for( n=0; n<M_nb_CtrlShorts; n++ )
		{
			if( M_TShort_CtrlMap[ n ] .c_KeyCode == c_car )
			{
				*pn_Title = M_TShort_CtrlMap[ n ] .c_EqTitle;
				return	M_TShort_CtrlMap[ n ] .c_EqEntry;
			}
		}
		return	NIL_1;
	}

	/*
	 * Raccourcis avec touche Alternate:
	 */
	if( n_kbd_state & K_ALT )
	{
		for( n=0; n<M_nb_AltShorts; n++ )
		{
			if( M_TShort_AltMap[ n ] .c_KeyCode == c_car )
			{
				*pn_Title = M_TShort_AltMap[ n ] .c_EqTitle;
				return	M_TShort_AltMap[ n ] .c_EqEntry;
			}
		}
		return	NIL_1;
	}

	
	return	NIL_1;
}
