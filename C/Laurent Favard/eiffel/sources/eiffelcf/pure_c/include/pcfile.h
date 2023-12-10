/*
 *
 *				File Unit prototypes's functions.
 *	
 *	Author	: FunShip	  
 *	File	: PCFile.h
 *	Date	: 10 February 1992
 *	Revision: 9 November 1994
 *	Version	: 1.00
 *	Language: Pure-C Version 1.1
 *	Origine : France
 *  
 */


#ifndef __MYFILE__
#define __MYFILE__	__MYFILE__

/*
 * -------------------- D‚finitions des types ---------------------------
 */

typedef struct Tposte_File
        {
          void			*Ptr_donnee;		/* ptr sur les donnees */
          struct Tposte_File	*Ptr_precedent;		/* chainage arriere */
          struct Tposte_File	*Ptr_suivant;		/* chainage avant */
        } Type_FilePoste;

typedef struct
        {
          Type_FilePoste	*Ptr_tete;		/* entree sur la tete */
          Type_FilePoste	*Ptr_queue;		/* entree sur la fin  */
          unsigned long		Taille;			/* taille des donnees */
        } Type_File;

/*
 * -------------------- Prototypes des fonctions ------------------------
 */

Type_File	*CreerFile(unsigned long Size);
/*
	Alloue une nouvelle file et l'initialise … vide.
	
	Entr‚e:	taille en octets des donn‚es … emfiler
	Sortie: retourne le pointeur sur la file ou NULL si echec
*/

void		KillFile(Type_File *File);
/*
	LibŠre tous les postes de la file si ils existent et d‚truit
	l'objet file.
	
	Entr‚e:	pointeur sur la file
	Sortie:	rien
*/

int		EstFileVide(Type_File *File);
/*
	Indique si la file est vide ou non.
	
	Entr‚e:	pointeur sur la file
	Sortie:	retourne 1 si vide 0 sinon
*/

void		*FileSommet(Type_File *File);
/*
	Retourne un pointeur sur la zone de donn‚e du poste en
	tete de file. Si la file est vide la valeur NULL est renvoy‚e.
	
	Entr‚e:	pointeur sur la file
	Sortie:	pointeur (void *) sur la donn‚e ou NULL si file vide
*/

int		Emfiler(Type_File *File, void *Ptr_sdonnee);
/*
	Ajoute un nouvel ‚l‚ment dans la file si assez de m‚moire.
	
	Entr‚e:	pointeur sur la file
		pointeur sur la donn‚e
	Sortie:	retourne 1 si ajout‚ 0 sinon
*/

int		Defiler(Type_File *File);
/*
	Supprime le premier ‚l‚ment de la file. Si la file est vide
	aucune op‚ration n'est effectu‚e.
	
	Entr‚e:	pointeur sur la file
	Sortie:	retourne 1 si supprim‚e 0 sinon
*/

int		FileEchange(Type_File *File);
/*
	Echange les positions de la premiŠre et derniŠre donn‚e dans
	la file.
	Si la file est vide ou ne possŠde qu'une seule donn‚e la fonction
	n'effectue aucune op‚ration.
	
	Entr‚e:	pointeur sur la file
	Sortie:	retourne 1 si ‚change effectu‚ 0 sinon
*/

int		FileTourne(Type_File *File);
/*
	D‚place la donn‚e en tete de file vers la queue de file.
	Si la file est vide ou ne possŠde qu'une seule donn‚e la fonction
	n'effectue aucune op‚ration.
	
	Entr‚e:	pointeur sur la file
	Sortie:	retourne 1 si d‚placement effectu‚ 0 sinon
*/

Type_FilePoste	*FileFirst(Type_File *File);
/*
	Renvoit l'adresse du poste en tee de la file. Si la file
	est vide l'adresse sera NULL.
	
	Entr‚e:	pointeur sur la file
	Sortie:	pointeur sur le poste ou NULL
*/

Type_FilePoste	*FileNext(Type_FilePoste *Ptr_poste);
/*
	Renvoit l'adresse du poste qui suit celui dont l'adresse est
	pass‚e en paramŠtre, si il existe.
	
	Entr‚e:	pointeur sur le poste actuel
	Sortie:	pointeur sur le poste suivant ou NULL
*/

Type_FilePoste	*FilePrevious(Type_FilePoste *Ptr_poste);
/*
	Renvoit l'adresse du poste qui pr‚cŠde celui dont l'adresse est
	pass‚e en paramŠtre, si il existe.
	
	Entr‚e:	pointeur sur le poste actuel
	Sortie:	pointeur sur le poste pr‚c‚dent ou NULL
*/

#endif