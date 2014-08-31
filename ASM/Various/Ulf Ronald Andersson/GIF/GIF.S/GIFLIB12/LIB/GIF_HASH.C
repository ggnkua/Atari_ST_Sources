/*****************************************************************************
*   "Gif-Lib" - Yet another gif library.				     *
*									     *
* Written by:  Gershon Elber			IBM PC Ver 0.1,	Jun. 1989    *
******************************************************************************
* Module to support the following operations:				     *
*									     *
* 1. InitHashTable - initialize hash table.				     *
* 2. ClearHashTable - clear the hash table to an empty state.		     *
* 2. InsertHashTable - insert one item into data structure.		     *
* 3. ExistsHashTable - test if item exists in data structure.		     *
*									     *
* This module is used to hash the GIF codes during encoding.		     *
******************************************************************************
* History:								     *
* 14 Jun 89 - Version 1.0 by Gershon Elber.				     *
*****************************************************************************/

#ifdef __MSDOS__
#include <io.h>
#include <alloc.h>
#include <sys\stat.h>
#else
#include <sys/types.h>
#include <sys/stat.h>
#endif /* __MSDOS__ */

#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include "gif_lib.h"
#include "gif_hash.h"

#define PROGRAM_NAME	"GIF_LIBRARY"

/* #define  DEBUG_HIT_RATE    Debug number of misses per hash Insert/Exists. */

#ifdef	DEBUG_HIT_RATE
static long NumberOfTests = 0,
	    NumberOfMisses = 0;
#endif	/* DEBUG_HIT_RATE */

#ifdef SYSV
static char *VersionStr =
        "Gif library module,\t\tGershon Elber\n\
	(C) Copyright 1989 Gershon Elber, Non commercial use only.\n";
#else
static char *VersionStr =
	PROGRAM_NAME
	"	IBMPC "
	GIF_LIB_VERSION
	"	Gershon Elber,	"
	__DATE__ ",   " __TIME__ "\n"
	"(C) Copyright 1989 Gershon Elber, Non commercial use only.\n";
#endif /* SYSV */

static int KeyItem(unsigned long Item);

/******************************************************************************
* Initialize HashTable - allocate the memory needed and clear it.	      *
******************************************************************************/
GifHashTableType *_InitHashTable(void)
{
    GifHashTableType *HashTable;

    if ((HashTable = (GifHashTableType *) malloc(sizeof(GifHashTableType)))
	== NULL)
	return NULL;

    _ClearHashTable(HashTable);

    return HashTable;
}

/******************************************************************************
* Routine to clear the HashTable to an empty state.			      *
* This part is a little machine depended. Use the commented part otherwise.   *
******************************************************************************/
void _ClearHashTable(GifHashTableType *HashTable)
{
    memset(HashTable -> HTable, 0xFF, HT_SIZE * sizeof(long));
}

/******************************************************************************
* Routine to insert a new Item into the HashTable. The data is assumed to be  *
* new one.								      *
******************************************************************************/
void _InsertHashTable(GifHashTableType *HashTable, unsigned long Key, int Code)
{
    int HKey = KeyItem(Key);
    unsigned long *HTable = HashTable -> HTable;

#ifdef DEBUG_HIT_RATE
	NumberOfTests++;
	NumberOfMisses++;
#endif /* DEBUG_HIT_RATE */

    while (HT_GET_KEY(HTable[HKey]) != 0xFFFFFL) {
#ifdef DEBUG_HIT_RATE
	    NumberOfMisses++;
#endif /* DEBUG_HIT_RATE */
	HKey = (HKey + 1) & HT_KEY_MASK;
    }
    HTable[HKey] = HT_PUT_KEY(Key) | HT_PUT_CODE(Code);
}

/******************************************************************************
* Routine to test if given Key exists in HashTable and if so returns its code *
* Returns the Code if key was found, -1 if not.				      *
******************************************************************************/
int _ExistsHashTable(GifHashTableType *HashTable, unsigned long Key)
{
    int HKey = KeyItem(Key);
    unsigned long *HTable = HashTable -> HTable, HTKey;

#ifdef DEBUG_HIT_RATE
	NumberOfTests++;
	NumberOfMisses++;
#endif /* DEBUG_HIT_RATE */

    while ((HTKey = HT_GET_KEY(HTable[HKey])) != 0xFFFFFL) {
#ifdef DEBUG_HIT_RATE
	    NumberOfMisses++;
#endif /* DEBUG_HIT_RATE */
	if (Key == HTKey) return HT_GET_CODE(HTable[HKey]);
	HKey = (HKey + 1) & HT_KEY_MASK;
    }

    return -1;
}

/******************************************************************************
* Routine to generate an HKey for the hashtable out of the given unique key.  *
* The given Key is assumed to be 20 bits as follows: lower 8 bits are the     *
* new postfix character, while the upper 12 bits are the prefix code.	      *
* Because the average hit ratio is only 2 (2 hash references per entry),      *
* evaluating more complex keys (such as twin prime keys) does not worth it!   *
******************************************************************************/
static int KeyItem(unsigned long Item)
{
    return ((Item >> 12) ^ Item) & HT_KEY_MASK;
}

#ifdef	DEBUG_HIT_RATE
/******************************************************************************
* Debugging routine to print the hit ratio - number of times the hash table   *
* was tested per operation. This routine was used to test the KeyItem routine *
******************************************************************************/
void HashTablePrintHitRatio(void)
{
    printf("Hash Table Hit Ratio is %ld/%ld = %ld%%.\n",
	NumberOfMisses, NumberOfTests,
	NumberOfMisses * 100 / NumberOfTests);
}
#endif	/* DEBUG_HIT_RATE */
