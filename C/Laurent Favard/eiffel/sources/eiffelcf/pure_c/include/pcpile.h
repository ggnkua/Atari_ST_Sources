/*
 *
 *				Stack Unit.
 *	
 *	Author	: FunShip	  
 *	File	: PCPile.h
 *	Date	: 8 February 1992
 *	Revision: 28 Juillet 1997
 *	Version	: 1.50
 *	Language: Pure-C Version 1.1
 *	Origine : France
 *  
 */

#ifndef	__PILE__
#define	__PILE__		__PILE__

/*
 * -------------------- D‚finitions des types ---------------------------
 */

typedef struct Tposte_Pile
					{
						void			*PtrDonnee;
						struct Tposte_Pile	*PtrSuivant;
						struct Tposte_Pile	*PtrPrecedent;
					} Type_PilePoste;


typedef struct	{
						Type_PilePoste	*Entree;
						unsigned long		Taille;
					} Type_Pile;

/*
 * -------------------- Prototypes des fonctions ------------------------
 */

extern	Type_Pile		*CreerPile(unsigned long size);
extern	void			KillPile(Type_Pile *pile);
extern	int				EstPileVide(Type_Pile *pile);
extern	void			*PileSommet(Type_Pile *pile);
extern	int				Empiler(Type_Pile *pile,void *ptr_donnee);
extern	int				Depiler(Type_Pile *pile);
extern	Type_PilePoste *PileFirst(Type_Pile *File);
extern	Type_PilePoste *PileNext(Type_PilePoste *Ptr_poste);
extern	Type_PilePoste *PilePrevious(Type_PilePoste *Ptr_poste);
extern	int 			PileDelete(Type_Pile *pile, Type_PilePoste *Ptr_poste);

#endif
