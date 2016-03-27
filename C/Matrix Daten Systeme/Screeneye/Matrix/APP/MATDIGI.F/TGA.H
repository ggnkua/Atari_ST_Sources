/* tga.h / 14.10.93	/	wa	*/

typedef unsigned intlh ;

typedef struct
{
	byte tab[12] ;
	intlh w, h ;
	byte bpp, res ;
} TTgaHeader ;

# define REVint(i) ((((unsigned)i)>>8) | (((unsigned)i)<<8))

# if sizeof (TTgaHeader ) != 18
*** error
# endif

/*
test.tga :

            |  0:0   |   0:1  |  0:2   |  0:3   | 1:0 ..     
0010 : 18,20
links schwarzer Strich
                                          | 4   *  8  |24|32|
0000 : 00,00,02,00,00,00,00,00,00,00,00,00,04,00,08,00?18,20
            |  0:0   |   0:1  |  0:2   |  0:3   | 1:0 ..     
0010 : 18,20*00,00,00,ff,ff,ff,ff,ff,ff,ff,ff,ff*00,00
*/

/* from test.tga ( pholab )	*/

# define DEFtga24 \
{	{ 0x00,0x00,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00, 0x00 },\
	REVint(4), REVint(8), 24, 32 }

/*
apples.tga :
	0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f 10 11
0000 : 00,00,02,00 00,00 00,00 00,00 00,00,80,01,e0,01,10,00
              2                           |  384| 480 |16,00 |
*/

/* from apples.tga ( falcon )	*/
# define DEFtga16 \
{ { 0x00,0x00,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 },\
	REVint(384), REVint(480), 16, 0 }
