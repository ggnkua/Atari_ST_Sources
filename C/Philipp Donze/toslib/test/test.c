#include <stdio.h>
/*#define NO_MULTITHREADING 1*/
#include "..\tos.h"


int main(int argc, char *argv[]) {
	long *ptr=NULL;

	if(argc == 1) {
		printf("Enter address:");
		scanf("%ld",&ptr);
	}
	else if(argc == 2) {
		int c;
		printf("Enter: 1 - for Malloc()\n"
				"       2 - for Mxalloc(...,0)\n"
				"       3 - for Mxalloc(...,MX_GLOBAL)\n"
				"       4 - for Mxalloc(...,MX_GLOBAL|1)\n");
		scanf("%d",&c);
		switch(c)
		{
			case 1:
				printf("Malloc(4) => ");
				ptr=(long *)Malloc(4);
				break;
			case 2:
				printf("Mxalloc(4,0) => ");
				ptr=(long *)Mxalloc(4,0);
				break;
			case 3:
				printf("Mxalloc(4,MX_GLOBAL) => ");
				ptr=(long *)Mxalloc(4,MX_GLOBAL);
				break;
			case 4:
				printf("Mxalloc(4,MX_GLOBAL|1) => ");
				ptr=(long *)Mxalloc(4,MX_GLOBAL|1);
				break;
		}
		*ptr = 0xDEADBEEFL;
	}
	printf("ptr=%ld\nvalue=%lx",(long)ptr,*ptr);
	Cnecin();

	return 0;
}

