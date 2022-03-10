#include <stdio.h>
#include "bm.h"
#include "Extern.h"
extern char * malloc();
/* makes a pattern descriptor */
struct PattDesc *MakeDesc(Pattern)
char *Pattern;
{
	struct PattDesc *Desc;
	Desc = (struct PattDesc *) malloc(sizeof(struct PattDesc));
	if (!(Desc->Skip1 = (unsigned short int *)
	malloc( sizeof(int) * (MAXCHAR + 1)))){
		fprintf(stderr,"bm: can't allocate space\n");
		exit(2);
	} /* if */
	if (!(Desc->Skip2 = (unsigned short int *)
	malloc(sizeof(int) * strlen(Pattern)))){
		fprintf(stderr,"bm: can't allocate space\n");
		exit(2);
	} /* if */
	Desc->Pattern=Pattern;
	Desc->PatLen = strlen(Desc->Pattern);
	MakeSkip(Desc->Pattern,Desc->Skip1,
	Desc->Skip2,Desc->PatLen);
	return(Desc);
} /* main */
