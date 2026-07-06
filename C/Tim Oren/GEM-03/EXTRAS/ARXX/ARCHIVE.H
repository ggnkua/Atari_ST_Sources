/*   archive.h
 *
 *   headerfile for arxx
 *
 *   Author:	Ton van Overbeek
 *		TPC862@ESTEC.BITNET
 *		1986-10-05
 */


#define WORD	int			/* 16bit = int for ALCYON */
#ifdef LATTICE
#define WORD	short			/* 16bit = short for LATTICE */
#endif

struct objfhead {			/* object file header */
   WORD	objtyp;
   long	textsize;
   long	datasize;
   long	bsssize;
   long symtsize;
   long reserv1;
   long reserv2;
   WORD reserv3;
};

struct armodhead {			/* library module header */
   char	fname[12];
   long res1[2];
   WORD flags;
   long fsize;
   WORD	res2;
};

struct symbtab {			/* symboltable */
   char symname[8];
   WORD symtype;
   long symvalue;
};

#define OBJTYP	0x601a			/* first word in .o file */
#define ARCHTYP	0xff65			/* first word in library */

#define LIST	1			/* arxx operations */
#define REPLACE	2
#define DELETE	4
#define EXTRACT	8
#define WRITE	16

#define AFTER	1			/* flagvalues for aftbef */
#define BEFORE	2
#define NOCOPY	4
