/********************************************************************************/
/* REMARK: set tab width to 4 spaces for best format							*/
/********************************************************************************/
/********************************************************************************/
/* 																				*/
/* Copyright (C) 1993	All Rights Reserved										*/
/* Centre de Recherche Public Henri Tudor (CRP-HT)								*/
/* 6, rue Coudenhove-Kalergi													*/
/* L1359 Luxembourg-Kirchberg													*/
/* 																				*/
/* Author			: Schmit Rene												*/
/* Internet			: Rene.Schmit@crpht.lu										*/
/* Creation Date	: Tuesday, June 29, 1993									*/
/* File name		: Test.C for memdebug.c										*/
/* Project			: Tools														*/
/* 																				*/
/* No responsibility is assumed for any damages that may result 				*/
/* from any defect in this software.											*/
/* 																				*/
/********************************************************************************/
/********************************************************************************/

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef MEMDEBUG
#define MEMDEBUG
#endif

#include "memdebug.h"

/********************************************************************************/
/******************************* Constants **************************************/
/********************************************************************************/

#define D_TableSize 13

/********************************************************************************/
/******************************* Data types *************************************/
/********************************************************************************/

enum t_CallKind {c_Malloc, c_Calloc};

typedef enum t_CallKind t_CallKind ;

/********************************************************************************/
/**************************** File global data **********************************/
/********************************************************************************/

/********************************************************************************/
/*********************** Local function prototypes ******************************/
/********************************************************************************/

int main (void);

void check_OrdinaryStuff		( void );

void loose_Memory	  			( void );

void free_Twice		  			( void );
void realloc_UnallocatedBlock	( void );

void fill_Table	  	  (	int			p_LeftBound,
						int			p_RightBound,
						t_CallKind	p_Allocator);
						
void test_reallocOK	  				(void);
void test_realloc_FirstLeftBad	  	(void);
void test_realloc_FirstRightBad	  	(void);
void test_realloc_SecondLeftBad	  	(void);
void test_realloc_SecondRightBad  	(void);

void test_NullMalloc				(void);
void test_NullCalloc				(void);
void test_realloc_as_Malloc			(void);
void test_realloc_as_Free			(void);

void allocate_HugeBlock				(void);
void generate_MallocError			(void);
void generate_ReallocError			(void);
	
/********************************************************************************/
/**************************** Local functions ***********************************/
/********************************************************************************/

void check_OrdinaryStuff(void)

{
char * l_OrdinaryPointer;
	
	l_OrdinaryPointer = malloc (D_TableSize);
	free (l_OrdinaryPointer);
	
	l_OrdinaryPointer = calloc(1,D_TableSize);
	free(l_OrdinaryPointer);
	
	l_OrdinaryPointer = malloc(D_TableSize);
	l_OrdinaryPointer = realloc(l_OrdinaryPointer, D_TableSize * 2);
	free(l_OrdinaryPointer);

	l_OrdinaryPointer = malloc(D_TableSize);
	l_OrdinaryPointer = realloc(l_OrdinaryPointer,D_TableSize / 2);
	free(l_OrdinaryPointer);

/* no need to test free any further!	*/	
}

/********************************************************************************/

void loose_Memory(void)

{
char * l_Text;
	l_Text = malloc (255* sizeof (char));
	strcpy(l_Text,"Lost memory!");
}

/********************************************************************************/

void free_Twice		  ( void )

{
char * l_Char;
	l_Char = malloc(sizeof(char));
	free(l_Char);
	free(l_Char);
}

/********************************************************************************/

void realloc_UnallocatedBlock	( void )

{
double * l_Double;
	l_Double = malloc(sizeof(double));
	free(l_Double);
	
	l_Double = realloc(l_Double,2 * sizeof(double));
}

/********************************************************************************/

void fill_Table	  (	int			p_LeftBound,
					int			p_RightBound,
					t_CallKind	p_Allocator)

{
char  *	l_Table;
int 	l_i;
	switch (p_Allocator)
	{
		case c_Malloc : l_Table = malloc(D_TableSize *	sizeof(char));
						break;
						
		case c_Calloc : l_Table = calloc(D_TableSize,	sizeof(char));
						break;
						
		default		  :	l_Table = NULL;
						fprintf(stderr,"Very fatal ERROR\n");
						abort();
						break;
	}
	
	for (l_i = p_LeftBound; l_i < p_RightBound; l_i++)
		*(l_Table + l_i) = (char) ('a' + l_i);
	free (l_Table);
}

/********************************************************************************/

void test_reallocOK	  (	void)

{
int	  *	l_OKTable;
int 	l_i;
	l_OKTable = malloc(D_TableSize *	sizeof(int));

	for (l_i = 0; l_i < D_TableSize; 		l_i++)
		l_OKTable[l_i] = l_i;

	l_OKTable = realloc(l_OKTable,	D_TableSize *	sizeof(int) *	2);
	
	for (l_i = 0; l_i < D_TableSize * 2; 	l_i++)
		l_OKTable[l_i] = l_i;

	free (l_OKTable);	
}

/********************************************************************************/

void test_realloc_FirstLeftBad	  (	void)

{
int	  *	l_FirstLeftTable;
int 	l_i;
	l_FirstLeftTable = malloc(D_TableSize *	sizeof(int));

	for (l_i = -1; l_i < D_TableSize; 		l_i++)
		l_FirstLeftTable[l_i] = l_i;

	l_FirstLeftTable = realloc(l_FirstLeftTable,	D_TableSize *	sizeof(int) *	2);
	
	for (l_i = 0; l_i < D_TableSize * 2; 	l_i++)
		l_FirstLeftTable[l_i] = l_i;

	free (l_FirstLeftTable);	
}

/********************************************************************************/

void test_realloc_FirstRightBad	  (	void)

{
int	  *	l_FirstRightTable;
int 	l_i;
	l_FirstRightTable = malloc(D_TableSize *	sizeof(int));

	for (l_i = 0; l_i < D_TableSize + 1; 	l_i++)
		l_FirstRightTable[l_i] = l_i;

	l_FirstRightTable = realloc(l_FirstRightTable,	D_TableSize *	sizeof(int) *	2);
	
	for (l_i = 0; l_i < D_TableSize * 2; 	l_i++)
		l_FirstRightTable[l_i] = l_i;

	free (l_FirstRightTable);	
}

/********************************************************************************/

void test_realloc_SecondLeftBad	  (	void)

{
int	  *	l_SecondLeftTable;
int 	l_i;
	l_SecondLeftTable = malloc(D_TableSize *	sizeof(int));

	for (l_i = 0; l_i < D_TableSize; 		l_i++)
		l_SecondLeftTable[l_i] = l_i;

	l_SecondLeftTable = realloc(l_SecondLeftTable,	D_TableSize *	sizeof(int) *	2);
	
	for (l_i = -1; l_i < D_TableSize * 2; 	l_i++)
		l_SecondLeftTable[l_i] = l_i;

	free (	l_SecondLeftTable		);	
}

/********************************************************************************/

void test_realloc_SecondRightBad	  (	void)

{
int	  *	l_SecondRightTable;
int 	l_i;
	l_SecondRightTable = malloc(D_TableSize *	sizeof(int));

	for (l_i = 0; l_i < D_TableSize; 		l_i++)
		l_SecondRightTable[l_i] = l_i;

	l_SecondRightTable = realloc(l_SecondRightTable,	D_TableSize *	sizeof(int) *	2);
	
	for (l_i = 0; l_i < D_TableSize * 2 + 1; l_i++)
		l_SecondRightTable[l_i] = l_i;
		
	free (l_SecondRightTable	);	
}

/********************************************************************************/

void test_NullMalloc				(void)

{
int * l_EmptyTable;
	l_EmptyTable = malloc(0);
	free(l_EmptyTable);
}


/********************************************************************************/

void test_NullCalloc				(void)

{
int * l_EmptyTable;
	l_EmptyTable = calloc(0,0);
	free(l_EmptyTable);
}


/********************************************************************************/

void test_realloc_as_Malloc			(void)

{
int * l_Table;
	l_Table = realloc(NULL,sizeof(int));
	free(l_Table);
}

/********************************************************************************/

void test_realloc_as_Free			(void)

{
int * l_Table;
	l_Table = malloc(sizeof(int));
	l_Table = realloc(l_Table,0);
	if (l_Table != 0)
		free(l_Table);
}

/********************************************************************************/

void allocate_HugeBlock(void)

{
int * l_HugeBlock;

#ifndef _MSDOS
#ifndef __MSDOS__
l_HugeBlock = malloc(LONG_MAX); /* should be large enough...	*/
	if (l_HugeBlock != NULL)
		free (l_HugeBlock);
#endif
#endif
}

/********************************************************************************/

void generate_MallocError			(void)

{
short * l_Short;
	l_Short = malloc(sizeof(short));
	if (l_Short != NULL)
		free (l_Short);
}
	
/********************************************************************************/

void generate_ReallocError			(void)

{
short * l_Short;
	l_Short = malloc(sizeof		(	short	)	);
	generate_MemdebugError();
	l_Short = realloc(l_Short,2*sizeof(l_Short)	);
	if (l_Short != NULL)
		free (l_Short);
}
	
/********************************************************************************/
/**************************** Global functions **********************************/
/********************************************************************************/

int main (void)

{
/*
**	Check conventionnal calls
*/

	check_OrdinaryStuff();
	
/*
**	Memory Leaks
*/
	loose_Memory();

/*
**	Illegal or dubious function calls
*/
	free_Twice();
	free((void *)1);
	realloc_UnallocatedBlock();

/*
**	Bound debuging
*/
	fill_Table(0,	D_TableSize,	c_Malloc);	/* ok				*/
	fill_Table(0,	D_TableSize,	c_Calloc);

	fill_Table(-1,	D_TableSize,	c_Malloc);	/* 1 of at left		*/
	fill_Table(-1,	D_TableSize,	c_Calloc);

	fill_Table(0,	D_TableSize+1,	c_Malloc);	/* 1 of at right	*/
	fill_Table(0,	D_TableSize+1,	c_Calloc);

	test_reallocOK	  				();
	test_realloc_FirstLeftBad	  	();
	test_realloc_FirstRightBad	  	();
	test_realloc_SecondLeftBad	  	();
	test_realloc_SecondRightBad  	();

/*
**	Strange ways to call realloc: as malloc or free!
*/
	test_realloc_as_Malloc();
	test_realloc_as_Free();

/*
**	Strange ways to call malloc & calloc: malloc(0), calloc(0,0)
*/

	test_NullMalloc();
	test_NullCalloc();
/*
*/

/*
**	Out of memory error simulation
*/
	allocate_HugeBlock();
	generate_ReallocError();
	generate_MallocError();
		
	return EXIT_SUCCESS;
}

/* Test output


File test.c         ; Line 128   # Freeing unallocated block : l_Char
File test.c         ; Line 377   # Freeing unallocated block : (void *)1
File test.c         ; Line 140   # Reallocating unallocated block : l_Double
Memory block corrupted at start: l_Table
Memory block corrupted at start: l_Table
Memory block corrupted at end  : l_Table
Memory block corrupted at end  : l_Table
Memory block corrupted at start: l_FirstLeftTable
Memory block corrupted at end  : l_FirstRightTable
Memory block corrupted at start: l_SecondLeftTable
Memory block corrupted at end  : l_SecondRightTable
File test.c         ; Line 299   # Realloc used with NULL initial pointer. 
Potential portability problem, calling malloc() instead
File test.c         ; Line 310   # Realloc used with new block size 0. 
Potential portability problem, calling free() instead
File test.c         ; Line 277   # Malloc used with block size 0. 
Potential portability problem, calling malloc(1) instead
File test.c         ; Line 288   # Calloc used to allocate 0 bytes. 
Potential portability problem, calling as calloc(1,1) instead
File test.c         ; Line 324   # Out of memory while allocating LONG_MAX
File test.c         ; Line 350   # Out of memory while reallocating 2*sizeof(l_Short) for l_Short
File test.c         ; Line 337   # Out of memory while allocating sizeof(short)

************************************
**  Memory usage statistics:   1  **
************************************

Calls to Malloc                   20
Calls to Calloc                    5
Calls to Realloc                   9
Calls to Free                     23

Total blocks allocated            23
Currently allocated blocks         2
Same time allocated blocks         2

Total memory allocated           932
Currently allocated memory       257
Same time allocated memory       359

Unsuccessful malloc calls          2
Unsuccessful realloc calls         1

Realloc of unallocated blocks      1
Free of unallocated blocks         2
Spurious free calls                0
Non-portable malloc calls          1
Non-portable calloc calls          1
Non-portable realloc calls         2
Corrupted blocks                   8

***************************************
** Alphabetic pointer variable list  **
***************************************
Identifier                           Blocks   Size   Average Size
l_Char                             :      1      1     1.00
l_Double                           :      1      8     8.00
l_EmptyTable                       :      2      2     1.00
l_FirstLeftTable                   :      1    104   104.00
l_FirstRightTable                  :      1    104   104.00
l_OKTable                          :      1    104   104.00
l_OrdinaryPointer                  :      4     58    14.50
l_SecondLeftTable                  :      1    104   104.00
l_SecondRightTable                 :      1    104   104.00
l_Table                            :      8     86    10.75

****************************************
** List of currently allocated blocks **
****************************************
                                     Size  Size Expression     Content String
File test.c         ; Line 348   #      2  sizeof ( short )    
File test.c         ; Line 116   #    255  255* sizeof (char)  Lost memory!


2 pointers have not been freed.

*/

