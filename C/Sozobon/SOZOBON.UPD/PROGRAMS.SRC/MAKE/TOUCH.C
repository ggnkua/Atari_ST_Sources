
#define MEGAMAX		/* Define if using Megamax C */

            /*******************************\
            *        Touch.c                *
            *                               *
            *     Change last mod time      *
            *        of args. to present.   *
            *                               *
            *    Jwahar R. Bammi            *
            *                               *
            \*******************************/

#include <osbind.h>

#ifdef MEGAMAX
#undef Fdatime			/* Megamax has it incorrectly defined */
#define Fdatime(a,b,c)	gemdos(0x57,a,b,c)
#endif /* MEGAMAX */


main(argc, argv)
register int argc;
register char **argv;
{
    while(--argc)
        touch(*++argv);
}

touch(file)
register char *file;
{
    register int	fd;

    if ((fd = Fopen(file, 0)) < 0)
    {
        Cconws("Touch: '");
        Cconws(file);
        Cconws("' not touched - non-existant\r\n");
    }
    else
    {
        long tim;

        tim = Gettime();
        FlipWords(&tim);
        if (Fdatime( &tim, fd,  1) < 0)
        {
            Cconws("Touch: '");
            Cconws(file);
            Cconws("' not touched - disk write protected ?\r\n");
        }
        Fclose(fd);

    }
}

FlipWords(i)
#ifdef MEGAMAX
unsigned i[];
#else
unsigned int i[];
#endif /* MEGAMAX */
{
#ifdef MEGAMAX
    register unsigned  temp;
#else
    register unsigned int temp;
#endif /* MEGAMAX */

    temp = i[0];
    i[0] = i[1];
    i[1] = temp;
}
