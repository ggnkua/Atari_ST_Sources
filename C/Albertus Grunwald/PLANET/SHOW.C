#include <tos.h>
#include <stdio.h>

main(int  argc, char *argv[])
{
	int fd;

	Setcolor(0,0);	   /* Farben invertieren */
	Setcolor(1,0x777);

	if((fd= Fopen(argv[1],0))<0 || Fread(fd,32000L,Physbase())<0)
		printf(" Fehler");
		
	Cconin();

	Setcolor(0,0x777); /*  Farben zurcksetzen */
	Setcolor(1,0);
}