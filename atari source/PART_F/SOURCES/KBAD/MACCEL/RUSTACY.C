/*** RUStacy.c
 *
 *   R U Stacy?  -- Bob's Quest for Stacy, his one true love
 *
 *	compile with ST TurboC Version 1.1:
 *	    tcc rustacy.c
 *	then link with tlink:
 *	    tlink -C=rustacy.tl
 *      where rustacy.tl contains:
 *	    -O=rustacy.tos
 *	    d:\turboc\library\tcstart.o
 *	    rustacy.o
 *	    d:\turboc\library\tctoslib.lib
 *	    d:\turboc\library\tcstdlib.lib
 *
 *	11Jan90  JWTittsler
 */

#include <stdio.h>
#include <tos.h>

#define	BDEV_RAW	5
#define BOBULEFT	0x1C
#define BOBURIGHT	0x1D
#define BOBLLEFT	0x1E
#define BOBLRIGHT	0x1F

unsigned int *SHADOW = (unsigned int *)0xFFFF827EL;
int *pOldStack;
unsigned int bResult=1;	/* exit code=0 for non-Stacy */

#define NPATTERNS	6
unsigned int wPattern[NPATTERNS] = {0x01, 0x02, 0x04, 0x08, 0x05, 0x0A};
int main(){
int wOriginalValue;
int i;

    pOldStack = (int *)Super(0L);

    wOriginalValue = *SHADOW;		/* save the original value */

    for(i=0; (i<NPATTERNS)&&(bResult); ++i){
	*SHADOW = wPattern[i];
	bResult = ((*SHADOW & 0xF) == wPattern[i]);
    }

    *SHADOW = wOriginalValue;		/* restore original value */

    pOldStack = (int *)Super(pOldStack);

    Bconout(BDEV_RAW, ' ');
    Bconout(BDEV_RAW, BOBULEFT);  Bconout(BDEV_RAW, BOBURIGHT);
    puts("");
    Bconout(BDEV_RAW, ' ');
    Bconout(BDEV_RAW, BOBLLEFT);  Bconout(BDEV_RAW, BOBLRIGHT);
    if (bResult) puts(" Bob says, 'Stacy, my darling!'");
    else puts(" Bob exclaims, 'You are not Stacy!'");

    (void)getchar();			/* wait for a key */
    return (bResult);
}
