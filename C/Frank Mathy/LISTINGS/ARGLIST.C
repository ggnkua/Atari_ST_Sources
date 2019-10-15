#include <stdio.h>
#include <ext.h>

int main(int argc,char *argv[])
	{
	int i;
	printf("Argumentliste:\n--------------\n");
	printf("šbergebene Argumente (incl. Dateiname): %d\n\n",argc);
	if(argc>1)
		{
		printf("Argumente:\n");
		for(i=0; i<argc; i++) printf("%s\n",argv[i]);
		}
	while(!kbhit());
	}