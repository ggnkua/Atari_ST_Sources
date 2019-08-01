#include "xbios301.h"

int main()
{
  struct bconmap *tosbconmap;
  long *newmaptab,*tosmaptab;
  int s,e;

	tosbconmap = (struct bconmap *)Bconmap(-2);	/* get bconmap structure */

	/* --- install new driver */

	newmaptab = Malloc((++tosbconmap->maptabsize)*6);	/* alloc new space */
	for (s = 0, e = (tosbconmap->maptabsize-1)*6; s < e; s++)
		newmaptab[s] = tosbconmap->maptab[s];	/* copy old entries */
	/* insert new driver procedure pointers here... */

	tosmaptab = tosbconmap->maptab;	/* save old ptr */
	tosbconmap->maptab = newmaptab;	/* install new ptr */


	/* now do your work... */


	/* --- kill new driver */

	tosbconmap->maptab = tosmaptab;
	tosbconmap->maptabsize--;
	Mfree(newmaptab);

	return 0;
}
