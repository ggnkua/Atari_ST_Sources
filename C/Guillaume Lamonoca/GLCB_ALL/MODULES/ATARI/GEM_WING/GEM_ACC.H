/* gem_acc.h : Necessaire pour realiser un parfait accessoire GEM

	Add '#include "gem_acc.h"' BEHIND '#include "header.h"'
	in your initsystem() call module if you want a GEM program
	that can be changed into accessory (rename *.PRG into *.ACC)!!!

	Ajoutez '#include "gem_acc.h"' DERRIERE '#include "header.h"'
	dans le module contenant votre appel a la fonction initsystem()
	si vous voulez que votre programme GEM puisse etre transforme en
	vrai accessoire GEM (cad qui redemarre juste avant l'appel a
	la fonction initsystem() quand il le faut : c-a-d, a chaque
	lancement de programme si Multitos est inactif, ou a chaque
	changement de resolution du bureau, ou a chaque fermeture de la
	fenetre de l'accessoire si la constante KILLED_WHEN_CLOSED est
	definie dans gem_wing.c)
*/

int initacc(void);

#include <setjmp.h>

extern jmp_buf glcb_jmpb;

#define initsystem()	(setjmp(glcb_jmpb)+initacc())
