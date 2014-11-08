/* programme minimal pour appeler une fonction du TRAP 10
 par exemple la fonction 05/06 (qui ne correspond encore … rien!)
 Guillaume TELLO, gtello@wanadoo.fr */

#include "trap_10.h"

main()
{
	int fn,subfn;
	long retour;
	void *buffer;

	fn=5;           /* num‚ro de fonction */
	subfn=6;				/* et de sous-fonction */
	buffer=1000;    /* l'adresse du tableau de paramŠtres */

	retour=trap_10(fn,subfn,buffer);	/* l'appel */
}

