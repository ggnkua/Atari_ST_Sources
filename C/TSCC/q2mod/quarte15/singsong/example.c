#include	<stdio.h>
#include	<osbind.h>


unsigned long *prog ;

unsigned long	*song,*voice ;
void	(*play)() ;

char	null[2] = {0,0} ;
main()
{
int	fd ;
	song = (unsigned long *)Malloc(10000L) ;		/* allocate song space */
	voice = (unsigned long *)Malloc(200000L) ;	/* allocate voice space */

	prog = (unsigned long *)Pexec(3,"singsong.prg",null,null) ;
	fd = Fopen("a:\demo1.4v",0) ;
	Fread(fd,9999L,song) ;
    Fclose(fd) ;
	fd = Fopen("a:\voice.set",0) ;
	Fread(fd,199999L,voice) ;
    Fclose(fd) ;

	play = &prog[64] ;
	prog[64+3] = (unsigned long)song ;
	prog[64+4] = (unsigned long)voice ;

	(*play)() ;

	printf("Well It got to here \n") ;
	gemdos(0x7) ;
}
