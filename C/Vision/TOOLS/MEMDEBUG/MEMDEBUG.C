/********************************************************************************/
/* REMARK: set tab width to 4 spaces for best format							*/
/********************************************************************************/
/********************************************************************************/
/* 																				*/
/* Copyright (C) 1992															*/
/* Centre de Recherche Public Henri Tudor (CRP-HT)								*/
/* 6, rue Coudenhove-Kalergi													*/
/* L1359 Luxembourg-Kirchberg													*/
/* 																				*/
/* Authors : Schmit Rene 														*/
/* 																				*/
/* This software may be copied, distributed, ported and modified in source or	*/
/* object format as long as :													*/
/* 																				*/
/* 	1) No distribution for commercial purposes is made.							*/
/* 	2) No third-party copyrights (such as runtime licenses) are involved		*/
/* 	3) This copyright notice is not removed or changed.							*/
/* 																				*/
/* No responsibility is assumed for any damages that may result 				*/
/* from any defect in this software.											*/
/* 																				*/
/********************************************************************************/

/* 
	CURRENT IMPLEMENTATION LIMITS AND WISH-LIST:
		* Restrictions with VAX C, as DECs pre-processor is not ANSI-compliant
		


		* MEMDEBUG++
		
		* Machine/OS-specific stuff
				DOS:	far pointers
						block size limits
				Mac:	Mac-specific routines
							NewPtr
							NewHandle
							...
							
		* check_ValidPointer(): pass it a pointer, returns FALSE if not
				inside a user_allocated block (would be cool, eh)
				
		* External option setting
		
		* register_Pointer(): no error message when pointer is freed
			(useful for memory allocated by non-MEMDEBUGed library)
			
		* Use own random function, so rand() is not disturbed
		
		* Change tree library to more general version
		
		? variable sized watchdog
		
		? Print-out of pointer value (== address)
		
*/


/*
	Modifications:
	
	6/14/1993:
	
		* Check memdebug disabling on memory error (in check_XXX() functions)
			-->	Added!
				
		* #include <stdlib.h> twice in memdebug.h file 
			-->	was already done before

		*limit # of chars to be printed out as string
			-->	limited to D_MaxRawDataStringLength

		* open_XXXFile() -> transform to a single function!!!
			-->	one global function open_File() replaces two old functions
			
	6/30/1993:
	
		* Add off-by-one watchdog option
			-->	Added!
		
		* add two underscores to check_XXX() functions
			-->	Added!

	7/1/1993:
	
		* Check for realloc() with special parameters passed
			-> NULL pointer : call malloc
			-> 0-size		: call free

		* Raw data printing
			-> only up to first \0
			
	7/8/1993:
		
		* Correction in detab_String: was moving one character too much
		
	8/19/1993:
		
		* changed memcheck to memdebug
		
		* Added segmentation pragma for macintosh
		
		* fflush() after printout of general statistics
		
		* set error file to line buffering
		
	10/4/93:
	
		* added C++ C linkage specification to memdebug.h
		
		* added new and delete overloaded operator to memdebug.h
		
	10/5/93:
		
		* overloaded operators new and delete moved to file memdebug.cp
		
		* changed memdebug.h file to reflect C++ modifications
		
	10/6/93

		* added macro VarInfo for use with new and delete, as we can't get this info
			automatically like with malloc() et al.
			
	1/26/94
	
		* bug in init: compared result of atexit() to NULL, now to 0
		
	1/27/94
	
		* bug in set & check sentinel functions: memory alignment error on access
			to end sentinel
			
			applied patch provided by Wilfred Mollenvanger and John Borst
			
		* added #include's for Sun

		* in memdebug.h: changed macro definitions of malloc() et al. for VAX compilers
			 
			applied patch provided by David M. Stone

	2/1/94
		
		* Replaced function name max() by find_MaxValue(), as some compilers define
			a macro called max
			
	2/11/94
		
		* added definition for RAND_MAX for SUNs
		
		* malloc(0)/calloc(0,0) may be a potential portability problem.
			Added test in __check_malloc() and __check_calloc(),
			call them with size 1 instead
			
		* in memdebug.h :define __MSDOS__ when _MSDOS defined
		
	2/15/94
		
		* added a cast to long in memory alignment patch (cf 1/27/94) to support
			 boundary checks on machines with 2 byte integers
	
	2/16/94
	
		* changed portability strategy for size_t type: using now unsigned long for
			all internal size-related data
			
		* added Col80 symbol: if defined, MEMDEBUG will TRY to limit line length to
			80 characters
			
	3/3/94
		
		* Close output files upon termination, if != from standard streams
*/

#ifdef macintosh
#pragma segment memdebug
#endif

#ifndef MEMDEBUG
#define MEMDEBUG
#endif

#include <limits.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef sun
#define		atexit	on_exit
#include	<memory.h>      /* for memset proto */
#ifndef RAND_MAX
#define RAND_MAX INT_MAX
#endif
#endif

#include "memdebug.h"

/*
#define Col80
*/

#ifdef Col80
#define D_RawDataMaxSize			14
#define print_80ColLineFeed(FILE)	fprintf(FILE,"\n    ")
#else
#define print_80ColLineFeed(FILE)	
#endif

/**************************************************************************/
/**************************** Utility Include *****************************/
/**************************************************************************/

#include "memfree.h"
#include "memalpha.h"

/**************************************************************************/

/*
	We have to undefine our allocation and free macros, as well as the memdebug functions
		because we use or define 'The Right Stuff' in this file.
*/

#undef malloc
#undef calloc
#undef realloc
#undef free

#undef generate_MemdebugError
#undef print_MemdebugStatistics
#undef set_MemdebugOptions
#undef check_MemdebugError


#define D_InternalMallocError			1
#define D_InternalFreeError				2
#define D_InternalOutOfMemoryError		3
#define D_ExitNotInstallable			4
#define D_CouldNotOpenStatisticsFile	5
#define D_CouldNotOpenErrorFile			6

#define D_MaxRawDataStringLength		80

/*
Here come some old macros used for VERY primitive memory checking. They were used
to check whether memdebug itself is more or less memory error free.

int g_malloc	= 0;
int g_free		= 0;

#define malloc(a)	(fprintf(stdout,"malloc %lu\n",	g_malloc++),	malloc(a)		)
#define free(a)		(fprintf(stdout,"free %lu %p\n",g_free++,a),	free(a),	a=0	)
*/


#define wrap_Pointer(p)				p = (void *) (((long *) (p)) + 1)
#define unwrap_Pointer(p)			p = (void *) (((long *) (p)) - 1)

/**************************************************************************/
/**************************** File global data ****************************/
/**************************************************************************/

static	FILE		  * g_StatisticsFile;				/* output text files							*/
static	FILE		  * g_ErrorFile;

static	t_OptionRecord	g_OptionRecord;					/* record containing options given with set_memdebugOptions */

static	unsigned long	g_CurrentNumber;				/* number of currently allocated blocks(using malloc() & calloc() )	*/
static	unsigned long	g_TotalNumber;
static	unsigned long	g_MaxNumber;

static	unsigned long	g_MallocCalls;					/* number of calls to given routine				*/
static	unsigned long	g_CallocCalls;
static	unsigned long	g_ReallocCalls;
static	unsigned long	g_FreeCalls;

static	unsigned long	g_CurrentSize;					/* currently allocated amount of memory			*/
static	unsigned long	g_TotalSize;					/* memory allocated since program start			*/
static	unsigned long	g_MaxSize;						/* max. memory allocated since program start	*/

static	unsigned long	g_UnsuccessfulMallocs;			/* contain number of unsuccessful calls to given routine	*/
static	unsigned long	g_UnsuccessfulCallocs;
static	unsigned long	g_UnsuccessfulReallocs;

static	unsigned long	g_IllegalReallocs;				/* number of reallocs of illegal pointers			*/
static	unsigned long	g_IllegalFrees;					/* number of frees of unallocated pointers			*/
static	unsigned long	g_SpuriousFrees;				/* number of free(NULL) calls						*/
static	unsigned long	g_NonPortableMalloc;			/* number of non-portable mallocs 					*/
static	unsigned long	g_NonPortableCalloc;			/* number of non-portable callocs					*/
static	unsigned long	g_NonPortableRealloc;			/* number of non-portable reallocs (malloc/free)	*/
static	unsigned long	g_CorruptedBlock;				/* number of corrupted blocks (bound check failed)	*/

static	unsigned int	g_WatchdogSize;					/* size needed by watchdog's head and tail	*/

static	t_CallSequenceLink	  *	g_CallSequenceList;		/* sequence list descriptors					*/
static 	t_CallSequenceLink	  *	g_CallSequenceListEnd;

static	t_biState	g_StatisticsPrinted;				/* statistics are printed at least once			*/
static	t_biState	g_memdebugDeactivated;				/* package deactivated if REAL memory problems	*/

/*************************************************************************/
/*********************** Local function prototypes ***********************/
/*************************************************************************/

static void detab_String	  (	char * p_String);

static void	init 			  (	void);

static unsigned long find_MaxValue	  (	unsigned	long	p1,
										unsigned	long	p2
									  );
				  
static void set_Watchdog	  (	t_BlockDescriptor	  * p_BlockDescriptor 	);

static void check_Watchdog 	  ( t_BlockDescriptor	  * p_BlockDescriptor,
							 	char				  * p_NameString		);


static void open_File		  (	FILE ** p_FileDescriptor,
								char  * p_FileName,
								int		p_ErrorCode
							  );

static void insert_BlockDes_into_SeqList  (	t_BlockDescriptor	  *	p_BlockDescriptor,
											t_CallKind				p_CallKind,
											unsigned long			p_Size,
											char				  *	p_SizeExpression,
											char				  * p_FileName,
											long					p_LineNumber
										  );
														  
static void print_CallSequenceList			  (	void);
static void remove_CallSequence_from_List	  (	t_CallSequenceLink	  *	p_Link );
static void delete_CallSequenceList			  (	void);
		
static void print_NotFreeList	  (void);
								
static void print_RawData	  	  (	void			  * p_Data,
									unsigned long 		p_DataLength);
									
static void		account_alloc	  (	void		  * p_Pointer,
									unsigned long	p_Size,
									t_CallKind		p_CallKind,
									char		  *	p_SizeExpression,
									char		  * p_FileName,
									long			p_LineNumber
								  );
		
static void	  * account_realloc	  ( void		  * p_Pointer,
									unsigned long	p_Size,
									char		  *	p_NameString,
									char		  *	p_SizeExpression,
									char		  * p_FileName,
									long			p_LineNumber
								  );
									
static t_ObjectState account_free (	void	  * p_Pointer,
									char	  *	p_NameString,
									char	  * p_FileName,
									long		p_LineNumber
								  );
		
static void	print_Location		  (	FILE	  * p_TargetFile,
									char	  * p_FileName,
									long		p_LineNumber
								  );

static void	print_GeneralStatistics(void);

static void print_FinalStatistics	  (void);
static void check_MallocFreeBalance	  (void);
static void cleanup_Data			  (void);

static void print_AlphaList	 		 (void);

/**************************************************************************/
/**************************** Local functions *****************************/
/**************************************************************************/

int	compare_BlockPointers	(	t_BlockDescriptor	  *	p_Block1,
								t_BlockDescriptor	  *	p_Block2)

/*
	DESCRIPTION:
		Compares the numerical value (== adress) of two pointers
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Simple substraction. Casts used to prevent warnings or other problems...

	WARNING:
		This routine is a potential portability problem, so beware when porting!
		
	REMARK:	
		Used to store and retrieve the pointer in the trees

*/

{
long l_difference;
	l_difference = ((unsigned long) (p_Block1->f_Pointer)) - ((unsigned long) (p_Block2->f_Pointer));
	if (l_difference == 0)
		return 0;
	else
		if (l_difference > 0)
			return 1;
		else
			return -1;
}

/**************************************************************************/

int	compare_Identifiers		(	t_BlockDescriptor	  *	p_Block1,
								t_BlockDescriptor	  *	p_Block2)
								
/*
	DESCRIPTION:
		Compares the identifiers denoting two blocks
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Trivial. Function is kind of a short notation
*/

{
	return( strcmp(p_Block1->f_Identifier,p_Block2->f_Identifier));
}

/**************************************************************************/

static void detab_String(char * p_String)

/*
	DESCRIPTION:
		delete all horizontal tabs in a string
		
	CLASS:
		String Manipulation
		
	ALGORITHM USED:
		Look for tabs.
		Move trailing sub_string forward by one character (replacing the tab)

	REMARK:
		Uses strchr() function from string.h to find tabs
		Uses memmove to move substring.
		
*/

{
char * l_TabPosition;

	while ((l_TabPosition = strchr(p_String,'\t')) != NULL)
		memmove(l_TabPosition,l_TabPosition+1,strlen(l_TabPosition));
}


/**************************************************************************/

void treat_InternalError	(	int	p_ErrorCode	)

/*
	DESCRIPTION:
		memdebug's error treatment routine.
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Prints a final error message to the error file, cleans up all data and sets a global
			variable that deactivates all calls to memdebug routines.
			
	REMARK:		
		This routine deactivates also all further calls to itself.
		
		The first two errors are used by the tree routines.
			During normal operation, these errors should never occur, however.
	
*/

{
	if (g_memdebugDeactivated)	/* once is enough	*/
		return;
		
	switch (p_ErrorCode)
	{
		case D_InternalMallocError		  :	fprintf(g_ErrorFile,"memdebug deactivated. Malloc returned same pointer twice.\n");
											break;
					
		case D_InternalFreeError		  :	fprintf(g_ErrorFile,"memdebug deactivated. Internal free error.\n");
											break;
					
		case D_InternalOutOfMemoryError	  :	fprintf(g_ErrorFile,"memdebug deactivated. Internal out of memory.\n");
											break;

		case D_ExitNotInstallable		  :	fprintf(g_ErrorFile,"memdebug deactivated. Could not install exit function.\n");
											break;
											
		case D_CouldNotOpenStatisticsFile :	fprintf(g_ErrorFile,"memdebug deactivated. Could not open statistics file.\n");
											break;
											
		case D_CouldNotOpenErrorFile	  :	fprintf(g_ErrorFile,"memdebug deactivated. Could not open error file.\n");
											break;
											
	}
			
	print_FinalStatistics();
	cleanup_Data();
	
	g_memdebugDeactivated = c_Yes;
}

/**************************************************************************/

static void close_Files (void)

/*
	DESCRIPTION:
		Closes all output files
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Checks if output streams are stdout or stderr and closes them if not so
		
*/

{
	if (g_StatisticsFile != stdout)
		fclose(g_StatisticsFile);

	if (g_ErrorFile != stderr)
		fclose(g_ErrorFile);
}

/**************************************************************************/

static void exit_memdebug (void)

/*
	DESCRIPTION:
		Calls routines to print out final statistics and to make data clean-up
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Trivial.
		
	REMARK:		
		This routine is installed as exit function during program initialisation. It
			uses one exit() slot!
*/

{
	print_FinalStatistics	();
	check_MallocFreeBalance	();
	cleanup_Data			();
	close_Files				();
}

/**************************************************************************/

static void init (void)

/*
	DESCRIPTION:
		Initialises all program globals.
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Set all variables to program default value (0, stdout, stderr....)
		Call initialisation routines for the two trees
		Install exit routine
		
		This routine is called for each user function call, but executes only once.
			s_AlreadyCalled is used as a flag at the first call
*/

{
static t_biState s_AlreadyCalled = c_No;

	if (s_AlreadyCalled)
		return;

	s_AlreadyCalled = c_Yes;

	g_CurrentNumber			= 0;
	g_TotalNumber			= 0;
	g_MaxNumber				= 0;

	g_MallocCalls			= 0;
	g_CallocCalls			= 0;
	g_ReallocCalls			= 0;
	g_FreeCalls				= 0;

	g_CurrentSize			= 0;
	g_TotalSize				= 0;
	g_MaxSize				= 0;
			
	g_UnsuccessfulMallocs	= 0;
	g_IllegalReallocs		= 0;
	g_IllegalFrees			= 0;
	g_SpuriousFrees			= 0;
	g_NonPortableMalloc		= 0;
	g_NonPortableCalloc		= 0;
	g_NonPortableRealloc	= 0;
	g_CorruptedBlock		= 0;
	
	g_StatisticsFile		= stdout;
	g_ErrorFile				= stderr;
	
	g_StatisticsPrinted		= c_No;
	g_memdebugDeactivated	= c_No;
	
	g_OptionRecord.f_GeneralStatistics		= c_Yes,
	g_OptionRecord.f_AlphaList				= c_Yes;
	g_OptionRecord.f_NotFreeList			= c_Yes;
	g_OptionRecord.f_CallSequenceList		= c_No;

	g_OptionRecord.f_PrintContents			= c_Yes;
	g_OptionRecord.f_DestroyContents		= c_Yes;
	
	g_OptionRecord.f_SpuriousFreeList		= c_Yes;

	g_OptionRecord.f_GenerateErrorCount		= 0;
	g_OptionRecord.f_MaximalMemoryAvailable	= LONG_MAX;
	
	g_OptionRecord.f_StatisticsFileName 	= "stdout";
	g_OptionRecord.f_ErrorFileName			= "stderr";

	g_WatchdogSize			= 2 * sizeof (long);

	g_CallSequenceList		= NULL;
	g_CallSequenceListEnd	= NULL;
		
	create_NotFreeBlockTree	();
	create_AlphaBlockTree	();
	
	if (atexit(exit_memdebug) != 0) 
		treat_InternalError(D_ExitNotInstallable);
}

/**************************************************************************/

static void insert_BlockDes_into_SeqList  (	t_BlockDescriptor	  *	p_BlockDescriptor,
											t_CallKind				p_CallKind,
											unsigned long			p_Size,
											char				  *	p_SizeExpression,
											char				  * p_FileName,
											long					p_LineNumber
										  )
/*
	DESCRIPTION:
		Add a block descriptor to the seuence cal list
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Create and fill the new block descriptor
		If list empty, new block is entire list, else append it at end of existing list.
		
		The backlink in the list is updated according to the memory function called.
		
		For more informstion, see documentation (TOOL-PM-1, page 8 and 9)

	REMARK:		
		An error might occur during memory allocation for the new link
		
*/

{
t_CallSequenceLink	  *	l_NewSequenceLink;
		
	l_NewSequenceLink = (t_CallSequenceLink *) malloc(sizeof(t_CallSequenceLink));
	
	if (l_NewSequenceLink == NULL)
	{
		treat_InternalError(D_InternalOutOfMemoryError);
		return;
	}
	
	l_NewSequenceLink->f_Next 				= NULL;
	l_NewSequenceLink->f_Previous 			= g_CallSequenceListEnd;
	l_NewSequenceLink->f_BlockDescriptor	= p_BlockDescriptor;
	l_NewSequenceLink->f_CallKind			= p_CallKind;
	
	l_NewSequenceLink->f_SizeExpression		= p_SizeExpression;
	l_NewSequenceLink->f_Size				= p_Size;
	l_NewSequenceLink->f_FileName			= p_FileName;
	l_NewSequenceLink->f_LineNumber			= p_LineNumber;

	if (g_CallSequenceList == NULL)
		g_CallSequenceList = l_NewSequenceLink;
	else
		g_CallSequenceListEnd->f_Next = l_NewSequenceLink;
	
	g_CallSequenceListEnd = l_NewSequenceLink;
	
	switch	(p_CallKind)
	{
		case	c_Malloc	  :	
		case	c_Calloc	  :	l_NewSequenceLink->f_MallocLink	= NULL;
								p_BlockDescriptor->f_BackLink	= l_NewSequenceLink;
								break;
								
		case	c_Realloc	  :	l_NewSequenceLink->f_MallocLink	= p_BlockDescriptor->f_BackLink;
								p_BlockDescriptor->f_BackLink	= l_NewSequenceLink;
								break;
								
		case	c_Free		  :	l_NewSequenceLink->f_MallocLink	= p_BlockDescriptor->f_BackLink;
								p_BlockDescriptor->f_BackLink	= NULL;
								break;
	}
}

/**************************************************************************/

static void print_CallSequenceList		(void)

/*
	DESCRIPTION:
		Prints the sequence list of memory function calls
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Print a header
		Iterate through list, printing the following information
			* Source File name
			* Source line number
			* Memory function name (malloc, calloc, realloc, free)
			* pointer identifier	(if known)
			* block size in bytes	
			* size expression		
*/

{
t_CallSequenceLink	  *	l_Link;
	fprintf(g_StatisticsFile,"*************************************\n");
	fprintf(g_StatisticsFile,"** Malloc/Free Call Sequence List  **\n");
	fprintf(g_StatisticsFile,"*************************************\n");
/*								123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890*/
	fprintf(g_StatisticsFile,  "                                   Call   Identifier                              Size  Size Expression\n");

	l_Link = g_CallSequenceList;
	while (l_Link)
	{
		fprintf(g_StatisticsFile,"File %-15s; Line %-5lu # ",l_Link->f_FileName,l_Link->f_LineNumber);

		switch (l_Link->f_CallKind)
		{
			case c_Malloc	  :	fprintf(g_StatisticsFile,"Malloc  ");
								break;
								
			case c_Calloc	  : fprintf(g_StatisticsFile,"Calloc  ");
								break;
								
			case c_Realloc	  : fprintf(g_StatisticsFile,"Realloc ");
								break;
								
			case c_Free		  : fprintf(g_StatisticsFile,"Free    ");
								break;
								
		}
		
		if (l_Link->f_BlockDescriptor->f_Identifier)
			fprintf(g_StatisticsFile,"%-35.35s : ",l_Link->f_BlockDescriptor->f_Identifier);
		else
			fprintf(g_StatisticsFile,"??????                              : ");	/* 21 spaces! */

		fprintf(g_StatisticsFile,"%6lu  %s",l_Link->f_Size,l_Link->f_SizeExpression);

		fprintf(g_StatisticsFile,"\n");
		l_Link = l_Link->f_Next;
	}

	fprintf(g_StatisticsFile,  "\n");
}

/**************************************************************************/

static void remove_CallSequence_from_List	(t_CallSequenceLink	  *	p_Link)

/*
	DESCRIPTION:
		Removes a sequence descriptor from the call sequence list.
		
	CLASS:
		List manipulation
		
	ALGORITHM USED:
		Standard list ooperation. Deallocates memory of block when done.

*/

{
 	if (p_Link->f_Previous	!= NULL)
		p_Link->f_Previous->f_Next 	= p_Link->f_Next;
	else
		g_CallSequenceList			= p_Link->f_Next;
		
 	if (p_Link->f_Next		!= NULL)
		p_Link->f_Next->f_Previous	= p_Link->f_Previous;
	else
		g_CallSequenceListEnd 		= p_Link->f_Previous;
	
	free(p_Link);
}

/**************************************************************************/

static void delete_CallSequenceList	(void)

/*
	DESCRIPTION:
		Frees the whole call sequnece list
	
	CLASS:
		List manipulation
		
	ALGORITHM USED:
		Standard list operation. Deallocates all memory used by list.
*/

{
t_CallSequenceLink	  *	l_Link;
t_CallSequenceLink	  *	l_NextLink;
	l_Link = g_CallSequenceList;
	while (l_Link)
	{
		l_NextLink = l_Link->f_Next;
		free(l_Link);
		l_Link = l_NextLink;
	}
}

/**************************************************************************/

static void open_File	  (	FILE ** p_FileDescriptor,
							char  * p_FileName,
							int		p_ErrorCode
						  )

/*
	DESCRIPTION:
		Opens a file
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Close old  file (allows for multiple such files, resetable with set_memdebugOptions)
		Open new file.
		
		stdout and stderr are treated separately (never opened or closed, file descriptor simply copied)		
		
	REMARK:
		Should the open not be successful, stderr is reused for a final message...
*/

{
int l_success;
	
	if (* p_FileDescriptor != stdout)
		l_success = fclose(* p_FileDescriptor);
	l_success++;
		
	if (!strcmp(p_FileName,"stdout"))
		* p_FileDescriptor = stdout;
	else
		if (!strcmp(p_FileName,"stderr"))
			g_ErrorFile = stderr;
		else
			* p_FileDescriptor = fopen(p_FileName,"w");
	
	if (* p_FileDescriptor == NULL)
	{
		g_ErrorFile = stderr;
		treat_InternalError (p_ErrorCode);
		* p_FileDescriptor = stdout;
	}
}

/**************************************************************************/

static void set_Watchdog  (	t_BlockDescriptor	  * p_BlockDescriptor )

/*
	DESCRIPTION:
		Set a blocks sentinels
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Create a long random number
		store this value at:
			start of block
			end of block
			block-descriptor

	REMARK:
		The end sentinel value is written byte by byte to avoid memory alignment problems
		
*/

{
long			l_RandomNumber;
long		  * l_Pointer;
unsigned long	l_Size;

	l_RandomNumber	= rand() * RAND_MAX + rand();
	l_Pointer		= (long *) p_BlockDescriptor->f_Pointer;
	l_Size			= p_BlockDescriptor->f_BackLink->f_Size;
	
	*((l_Pointer ) - 1) 					= l_RandomNumber;
	*((char *) (l_Pointer ) + l_Size    )   = (unsigned char) ((l_RandomNumber >> (3*8)) & 255);
	*((char *) (l_Pointer ) + l_Size + 1)   = (unsigned char) ((l_RandomNumber >> (2*8)) & 255);
	*((char *) (l_Pointer ) + l_Size + 2)   = (unsigned char) ((l_RandomNumber >> (1*8)) & 255);
	*((char *) (l_Pointer ) + l_Size + 3)   = (unsigned char) ((l_RandomNumber >> (  0)) & 255);

#if 0 
	*((long*) ((char *) (l_Pointer ) + l_Size))	= l_RandomNumber;
#endif
	
	p_BlockDescriptor->f_WatchdogValue		= l_RandomNumber;
}

/**************************************************************************/

static void check_Watchdog 	( 	t_BlockDescriptor * p_BlockDescriptor,
							 	char			  * p_NameString		)

/*
	DESCRIPTION:
		Tests via sentinels if block has not been corrupted
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Retrieve value at begin and end of block, as well as from block_descriptor
		If the start or end value have changed, print out an error message
		
	REMARK:
		The end sentinel value is read byte by byte to avoid memory alignment problems
		
*/

{
long		 	l_WatchdogHead;
long		 	l_WatchdogTail;
long		 	l_WatchdogValue;

long		  * l_Pointer;
unsigned long	l_Size;

	l_Pointer		= (long *) p_BlockDescriptor->f_Pointer;
	l_Size			= p_BlockDescriptor->f_BackLink->f_Size;

	l_WatchdogHead	  = *((l_Pointer) - 1);
	l_WatchdogTail    = ((long)*((unsigned char *) (l_Pointer) + l_Size    ) << (3*8)) +
						((long)*((unsigned char *) (l_Pointer) + l_Size + 1) << (2*8)) +
						((long)*((unsigned char *) (l_Pointer) + l_Size + 2) << (1*8)) +
						((long)*((unsigned char *) (l_Pointer) + l_Size + 3) << (  0));

#if 0
	l_WatchdogTail	= *((long*) ((char *) (l_Pointer ) + l_Size));
#endif

	l_WatchdogValue = p_BlockDescriptor->f_WatchdogValue;
	
	if	(l_WatchdogHead	!= l_WatchdogValue)
	{
		g_CorruptedBlock++;
		fprintf(g_ErrorFile,"Memory block corrupted at start: %s\n", p_NameString);
	}
						
	if	(l_WatchdogTail	!= l_WatchdogValue)
	{
		g_CorruptedBlock++;
		fprintf(g_ErrorFile,"Memory block corrupted at end  : %s\n", p_NameString);
	}
}

/**************************************************************************/

static	unsigned long	find_MaxValue	  ( unsigned	long	p1,
											unsigned	long	p2)

/*
	DESCRIPTION:
		Returns the largest of two input values
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Trivial
		
	REMARK:		
		If performance were important, we would (and could) use a macro...
*/

{
	return ( (p1 > p2) ? p1 : p2);
}

/**************************************************************************/

static void print_Location	  (	FILE	  * p_TargetFile,
								char	  * p_FileName,
								long		p_LineNumber
							  )

/*
	DESCRIPTION:
		Print file name and line number to target file
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Trivial. Used for simplification.
*/

{
	fprintf(p_TargetFile,"File %-15s; Line %-5lu # ",p_FileName,p_LineNumber);
}

/**************************************************************************/

void print_AlphaBlock	(t_BlockDescriptor	 *	p_data)

/*
	DESCRIPTION:
		Prints the content of an alphabetical block descriptor
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Prints to the statistics file (on one line)
			* The pointer identifier
			* The number of times this identifier was used
			* The total number of bytes allocated for this identifier
			* The average size of this block
	
	REMARK:
		Called by the alphabetic tree iteration function
*/

{
	fprintf(g_StatisticsFile,  "%-35.35s: ",p_data->f_Identifier);

	fprintf(g_StatisticsFile,  "%6lu ",p_data->f_TimesUsed);
	fprintf(g_StatisticsFile,  "%6lu ",p_data->f_TotalAllocated);
	fprintf(g_StatisticsFile,  "%8.2f",(float)p_data->f_TotalAllocated / (float)p_data->f_TimesUsed);

	fprintf(g_StatisticsFile,  "\n");
}

/**************************************************************************/

static void print_AlphaList	(void)

/*
	DESCRIPTION:
		Print an alphabetically odered list of all blocks
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Print a header
		Call the alphabetic tree iteration function 
*/

{
	fprintf(g_StatisticsFile,"***************************************\n");
	fprintf(g_StatisticsFile,"** Alphabetic pointer variable list  **\n");
	fprintf(g_StatisticsFile,"***************************************\n");
/*								123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890*/
	fprintf(g_StatisticsFile,  "Identifier                           Blocks   Size   Average Size\n");
	
	print_AlphaBlockTree();

	fprintf(g_StatisticsFile,  "\n");
}

/**************************************************************************/

static void print_RawData	  (	void		  * p_Data,
								unsigned long	p_DataLength)

/*
	DESCRIPTION:
		Prints out all printable characters up to \0 in a raw data block

	CLASS:
		Printing
	
	ALGORITHM USED:
		For all bytes in the data block
			Check whether byte is a printable ASCII character
				YES: 	print it
				NO:		print a '.' instead

*/
{
int		l_i;
char	l_Character;

#ifdef Col80
	if (p_DataLength > D_RawDataMaxSize)
		p_DataLength = D_RawDataMaxSize;
#endif
	for (l_i = 0; l_i < p_DataLength; l_i++)
	{
		if (l_i > D_MaxRawDataStringLength)
			break;
		l_Character = *((char *)p_Data + l_i);
		if (l_Character == '\0')
			break;
		if (isprint(l_Character))
			fprintf(g_StatisticsFile,"%1c",l_Character);
		else
			fprintf(g_StatisticsFile,".");
	}
}

/**************************************************************************/

void print_NotFreeBlock	(t_BlockDescriptor	 *	p_data)

/*
	DESCRIPTION:
		Print the content of a not free block to the statistics file
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Print to the statistics file (one per line)
			* the source file name &
			* the source line number of the allocation site of the block
			* the size
			* the size expression
			* the memory content as a string, terminated at the end by an \0
			
	REMARK:		
		Used by the notFree tree iteration function

*/

{
	fprintf(g_StatisticsFile,	"File %-15s; Line %-5lu # ",
								p_data->f_BackLink->f_FileName,
								p_data->f_BackLink->f_LineNumber);

	fprintf(g_StatisticsFile,	"%6lu  %-20s",
								p_data->f_BackLink->f_Size,
								p_data->f_BackLink->f_SizeExpression);

	if (g_OptionRecord.f_PrintContents)
		print_RawData(p_data->f_Pointer,p_data->f_BackLink->f_Size);
	
	fprintf(g_StatisticsFile,  "\n");
}

/**************************************************************************/

static void print_NotFreeList		(void)

/*
	DESCRIPTION:
		Print a list of all blocks not yet freed
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Print a header
		Call NotFree tree iteration function for printing NotFree blocks

*/

{
	if (g_CurrentNumber == 0)	/* won't print out an empty list	*/
			return;
	
	fprintf(g_StatisticsFile,"****************************************\n");
	fprintf(g_StatisticsFile,"** List of currently allocated blocks **\n");
	fprintf(g_StatisticsFile,"****************************************\n");
/*								123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890*/
	fprintf(g_StatisticsFile,  "                                     Size  Size Expression     Content String\n");
	
	print_NotFreeBlockTree();

	fprintf(g_StatisticsFile,  "\n");
}

/**************************************************************************/

void delete_Descriptor	(t_BlockDescriptor	 *	p_data)

/*
	DESCRIPTION:
		Deletes a block descriptor
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Another name for free(). Used by the free iterator functions of the two trees
*/

{
	free (p_data);
}


/**************************************************************************/

static 	void account_alloc	  (	void		  * p_Pointer,
								unsigned long	p_Size,
								t_CallKind		p_CallKind,
								char		  *	p_SizeExpression,
								char		  * p_FileName,
								long			p_LineNumber
							  )
					  
/*
	DESCRIPTION:
		Registers a call to malloc() or calloc()
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Update global statistics
		Create a block descriptor and fill it up
		Insert this block descriptor into
			* the call sequence list
			* the NotFree tree 

	REMARK:		
		Low real memory disables memdebug
*/

{
t_BlockDescriptor	  *	l_BlockDescriptor;

	g_TotalNumber	++;
	g_CurrentNumber	++;
	
	g_TotalSize		+= p_Size;
	g_CurrentSize	+= p_Size;
	
	g_MaxNumber		= find_MaxValue(g_CurrentNumber,g_MaxNumber);
	g_MaxSize		= find_MaxValue(g_CurrentSize,	g_MaxSize);
	
	
	l_BlockDescriptor = (t_BlockDescriptor *) malloc(sizeof(t_BlockDescriptor));

	if (l_BlockDescriptor == NULL)
	{
		treat_InternalError(D_InternalOutOfMemoryError);
		return;
	}

	l_BlockDescriptor->f_Pointer		= p_Pointer;
	l_BlockDescriptor->f_Identifier		= NULL;
	
	insert_BlockDes_into_SeqList  (	l_BlockDescriptor,
									p_CallKind,
									p_Size,
									p_SizeExpression,
									p_FileName,
									p_LineNumber
								  );
	
	insert_NotFreeBlock_into_Tree(l_BlockDescriptor);
	
	set_Watchdog(l_BlockDescriptor);

	if ( check_NotFreeBlockFull() )
		treat_InternalError(D_InternalOutOfMemoryError);
}


/**************************************************************************/

static void  * account_realloc	  ( void		  * p_Pointer,
									unsigned long	p_Size,
									char		  *	p_NameString,
									char		  *	p_SizeExpression,
									char		  * p_FileName,
									long			p_LineNumber
								  )
								  
/*
	DESCRIPTION:
		Registers a call to realloc()
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Check if reallocation is legal (pointer exists in NotFree tree)
		
		Test if out of memory simulation limit not reached
		
		Do a real realloc() and check if sucessful
		
		Remove old pointer from NotFree tree
		Update globl statistics
		Insert descriptor into sequence call list and NotFree tree
		
	REMARK:		
		memdebug aborts if no internal memory available, else realloc() behaves normally
*/

{
void				  * l_NewPointer;
t_BlockDescriptor	  	l_OldBlock;			/* Temporary memory for search call	*/
t_BlockDescriptor	  *	l_BlockDescriptor;
unsigned long			l_SizeDifference;

	l_OldBlock.f_Pointer	= p_Pointer;
	l_BlockDescriptor		= &l_OldBlock;
	if (!search_NotFreeBlock_in_Tree(&l_BlockDescriptor))
	{
		print_Location(g_ErrorFile,p_FileName,p_LineNumber);
		fprintf(g_ErrorFile,"Reallocating unallocated block : %s\n",p_NameString);
		g_IllegalReallocs++;
		return(NULL);
	}
	else
	{
		if ((g_TotalSize - l_BlockDescriptor->f_BackLink->f_Size + p_Size) > g_OptionRecord.f_MaximalMemoryAvailable)
		{
			print_Location(g_ErrorFile,p_FileName,p_LineNumber);
			fprintf(g_ErrorFile,"Out of memory while reallocating %s for %s\n",p_SizeExpression,p_NameString);
			g_UnsuccessfulReallocs++;
			return (NULL);
		}
		else
		{
			check_Watchdog (l_BlockDescriptor,p_NameString);
			unwrap_Pointer (p_Pointer);
			l_NewPointer = realloc(p_Pointer,(size_t) p_Size + g_WatchdogSize);
			if (l_NewPointer == NULL)
			{
				print_Location(g_ErrorFile,p_FileName,p_LineNumber);
				fprintf(g_ErrorFile,"System out of memory while reallocating %s for %s\n",p_SizeExpression,p_NameString);
				g_UnsuccessfulReallocs++;
			}
			else
			{
				wrap_Pointer(l_NewPointer);
				remove_NotFreeBlock_from_Tree(l_BlockDescriptor);
				
				l_SizeDifference 					 = p_Size - l_BlockDescriptor->f_BackLink->f_Size;
				l_BlockDescriptor->f_TotalAllocated	+= l_SizeDifference;
				g_CurrentSize 						+= l_SizeDifference;
				g_MaxSize							 = find_MaxValue(g_CurrentSize,	g_MaxSize);
				if ((l_SizeDifference) > 0)
					g_TotalSize 					+= l_SizeDifference;
				
				l_BlockDescriptor->f_Pointer	= l_NewPointer;
				l_BlockDescriptor->f_Identifier	= NULL;
				
				insert_BlockDes_into_SeqList  (	l_BlockDescriptor,
												c_Realloc,
												p_Size,
												p_SizeExpression,
												p_FileName,
												p_LineNumber
											  );
				insert_NotFreeBlock_into_Tree(l_BlockDescriptor);
				if ( check_NotFreeBlockFull() )
					treat_InternalError(D_InternalOutOfMemoryError);
					
				set_Watchdog(l_BlockDescriptor);
			}
		}
	}
	return (l_NewPointer);
}

/**************************************************************************/

static t_ObjectState account_free	  (	void	  * p_Pointer,
										char	  *	p_NameString,
										char	  * p_FileName,
										long		p_LineNumber
									  )

/*
	DESCRIPTION:
		Registers a call to free()
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Search block in NotFree tree and remove it if found (else error returned)
		Fill in missing data
		
		Check if block already known (in alphabetic tree)
			yes:	free block descriptor
					increase local statistics
			no:		init local statistics
					insert block descriptor into tree
		
		Update global statistics
		
		Either remove block from sequence list, or add free sequence block to this list
		
		Fill released memory with a "@@@" string (NULL-terminated)
		
	REMARK:		
		Out of real memory terminates memdebug
*/

{
t_BlockDescriptor	  	l_FreeBlock;
t_BlockDescriptor	  *	l_BlockDescriptor;
t_BlockDescriptor	  *	l_UnlinkedBlock;
t_CallSequenceLink	  * l_MallocSequenceCall;
unsigned long			l_Size;

	l_FreeBlock.f_Pointer	= p_Pointer;
	l_UnlinkedBlock			= &l_FreeBlock;
	if (!search_NotFreeBlock_in_Tree(&l_UnlinkedBlock))
		return(c_Bad);

	check_Watchdog(l_UnlinkedBlock,p_NameString); /* do it here, we need pointer	*/

	remove_NotFreeBlock_from_Tree(l_UnlinkedBlock);

	l_MallocSequenceCall 	= l_UnlinkedBlock->f_BackLink;
	l_Size					= l_MallocSequenceCall->f_Size;
	
	l_BlockDescriptor					= l_UnlinkedBlock;
	l_BlockDescriptor->f_Pointer		= NULL;
	l_BlockDescriptor->f_Identifier		= p_NameString;
	
	if (! search_AlphaBlock_in_Tree(&l_BlockDescriptor))
	{	/* not found	*/
		l_UnlinkedBlock->f_TimesUsed		= 1;
		l_UnlinkedBlock->f_TotalAllocated	= l_Size;

		insert_AlphaBlock_into_Tree(l_UnlinkedBlock);
		if ( check_AlphaBlockFull() )
			treat_InternalError(D_InternalOutOfMemoryError);
	}
	else
	{	/* found	*/
		l_MallocSequenceCall->f_BlockDescriptor = l_BlockDescriptor;
		free(l_UnlinkedBlock);

		l_BlockDescriptor->f_TimesUsed		++;
		l_BlockDescriptor->f_TotalAllocated	+= l_Size;
	}
	
	l_BlockDescriptor->f_BackLink		= NULL;

	g_CurrentNumber	--;
	g_CurrentSize 	-=  l_Size;
	
	if (g_OptionRecord.f_CallSequenceList)
		insert_BlockDes_into_SeqList  (	l_BlockDescriptor,
										c_Free,
										l_Size,
										l_MallocSequenceCall->f_SizeExpression,
										p_FileName,
										p_LineNumber
									  );
	else
	{
	t_CallSequenceLink	* l_DeleteSequenceCall;
		l_DeleteSequenceCall = l_MallocSequenceCall;
		while (l_DeleteSequenceCall != NULL)
		{
			l_MallocSequenceCall = l_MallocSequenceCall->f_MallocLink;
			remove_CallSequence_from_List(l_DeleteSequenceCall);
			l_DeleteSequenceCall = l_MallocSequenceCall;
		}
	}
	
	if (g_OptionRecord.f_DestroyContents)
	{
		memset(p_Pointer,'@',(size_t)l_Size-1);
		*( (char*) p_Pointer + l_Size - 1) = '\0';
	}

	return(c_Ok);
}
/**************************************************************************/

static void	print_GeneralStatistics(void)

/*
	DESCRIPTION:
		Print global statistics
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Trivial.
*/

{
static int s_TimesCalled = 0;

	fprintf(g_StatisticsFile,"\n");
	fprintf(g_StatisticsFile,"************************************\n");
	fprintf(g_StatisticsFile,"**  Memory usage statistics: %3d  **\n",++s_TimesCalled);
	fprintf(g_StatisticsFile,"************************************\n");
	fprintf(g_StatisticsFile,"\n");

	fprintf (g_StatisticsFile,"Calls to Malloc               %6lu\n",	g_MallocCalls			);
	fprintf (g_StatisticsFile,"Calls to Calloc               %6lu\n",	g_CallocCalls			);
	fprintf (g_StatisticsFile,"Calls to Realloc              %6lu\n",	g_ReallocCalls			);
	fprintf (g_StatisticsFile,"Calls to Free                 %6lu\n",	g_FreeCalls				);
	fprintf (g_StatisticsFile,"\n");

	fprintf	(g_StatisticsFile,"Total blocks allocated        %6lu\n",	g_TotalNumber			);
	fprintf	(g_StatisticsFile,"Currently allocated blocks    %6lu\n",	g_CurrentNumber			);
	fprintf	(g_StatisticsFile,"Same time allocated blocks    %6lu\n",	g_MaxNumber				);
	fprintf (g_StatisticsFile,"\n");


	fprintf	(g_StatisticsFile,"Total memory allocated      %8lu\n",		g_TotalSize				);
	fprintf	(g_StatisticsFile,"Currently allocated memory  %8lu\n",		g_CurrentSize			);
	fprintf	(g_StatisticsFile,"Same time allocated memory  %8lu\n",		g_MaxSize				);
	fprintf (g_StatisticsFile,"\n");


	fprintf	(g_StatisticsFile,"Unsuccessful malloc calls     %6lu\n",	g_UnsuccessfulMallocs	);
	fprintf	(g_StatisticsFile,"Unsuccessful realloc calls    %6lu\n",	g_UnsuccessfulReallocs	);
	fprintf	(g_StatisticsFile,"\n");

	fprintf	(g_StatisticsFile,"Realloc of unallocated blocks %6lu\n",	g_IllegalReallocs		);
	fprintf	(g_StatisticsFile,"Free of unallocated blocks    %6lu\n",	g_IllegalFrees			);
	fprintf	(g_StatisticsFile,"Spurious free calls           %6lu\n",	g_SpuriousFrees			);
	fprintf	(g_StatisticsFile,"Non-portable malloc calls     %6lu\n",	g_NonPortableMalloc		);
	fprintf	(g_StatisticsFile,"Non-portable calloc calls     %6lu\n",	g_NonPortableCalloc		);
	fprintf	(g_StatisticsFile,"Non-portable realloc calls    %6lu\n",	g_NonPortableRealloc	);
	fprintf	(g_StatisticsFile,"Corrupted blocks              %6lu\n",	g_CorruptedBlock		);
	fprintf	(g_StatisticsFile,"\n");
}

/**************************************************************************/

static void print_FinalStatistics	  ( void )

/*
	DESCRIPTION:
		Print final statistics
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		If not yet printed, this function launches the printing of the statistics
		
	REMARK:		
		Called by exit function
*/

{
	if (g_memdebugDeactivated)
		return;

	if (g_StatisticsPrinted == c_No)
		print_MemdebugStatistics();
}

/**************************************************************************/

static void check_MallocFreeBalance	  ( void )

/*
	DESCRIPTION:
		Prints an erro messag eif not all memory allocations have been matched by a free
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Trivial

*/

{
	if (g_memdebugDeactivated)
		return;

	if (g_CurrentNumber)
		fprintf(g_ErrorFile,"\n%lu pointers have not been freed.\n",g_CurrentNumber);
}

/**************************************************************************/

static void cleanup_Data	( void )

/*
	DESCRIPTION:
		Cleans up all data structures at end of program
		
	CLASS:
		Application specific
		
	ALGORITHM USED:
		Call clean-up functions of all data structures
		
*/

{
	if (g_memdebugDeactivated)
		return;

	delete_CallSequenceList			();
	
	free_NotFreeBlockTree			();
	delete_NotFreeBlockTree			();
	
	free_AlphaBlockTree				();
	delete_AlphaBlockTree			();
}
	
/**************************************************************************/
/**************************** Global functions ****************************/
/**************************************************************************/

void  * __check_malloc(	size_t		p_Size,
						char	  *	p_SizeExpression,
						char	  * p_FileName,
						long		p_LineNumber
					  )

/*
	DESCRIPTION:
		Replaces (and calls) standard malloc()
		
	CLASS:
		memdebug
		
	ALGORITHM USED:
		Init tool
		Update global statistics
		Call real malloc()
			adjust for watchdog
			account call and/or return error if not successful
		
*/

{
void * l_NewBlock;

	init();
	g_MallocCalls++;
	
	if (p_Size == 0)
	{
		g_NonPortableMalloc++;
		p_Size = 1;
		print_Location(g_ErrorFile,p_FileName,p_LineNumber);
		fprintf(g_ErrorFile,"Malloc used with block size 0. ");
		print_80ColLineFeed(g_ErrorFile);
		fprintf(g_ErrorFile,"Potential portability problem, calling malloc(1) instead\n");
	}

	if (g_memdebugDeactivated)
	{
		l_NewBlock = malloc (p_Size + g_WatchdogSize);
		if (l_NewBlock)
			wrap_Pointer(l_NewBlock);
		return (l_NewBlock);
	}
	
	detab_String(p_SizeExpression);

	if ((g_TotalSize + p_Size) <= g_OptionRecord.f_MaximalMemoryAvailable)
	{
		l_NewBlock = malloc (p_Size + g_WatchdogSize);
		
		if (l_NewBlock)
		{
			wrap_Pointer(l_NewBlock);

			account_alloc(l_NewBlock,p_Size,c_Malloc,p_SizeExpression,p_FileName,p_LineNumber);
			return (l_NewBlock);
		}
		else
		{
			print_Location(g_ErrorFile,p_FileName,p_LineNumber);
			fprintf(g_ErrorFile,"System out of memory while allocating %s\n",p_SizeExpression);
			g_UnsuccessfulMallocs++;
			return (NULL);
		}
	}
	else
	{
		print_Location(g_ErrorFile,p_FileName,p_LineNumber);
		fprintf(g_ErrorFile,"Out of memory while allocating %s\n",p_SizeExpression);
		g_UnsuccessfulMallocs++;
		return (NULL);
	}
}

/**************************************************************************/

void  * __check_calloc(	size_t		p_Number,
						size_t		p_Size,
						char	  *	p_SizeExpression,
						char	  * p_FileName,
						long		p_LineNumber
					  )

/*
	DESCRIPTION:
		Replaces (and calls) standard calloc()
		
	CLASS:
		memdebug
		
	ALGORITHM USED:
		Init tool
		Update global statistics
		Call malloc,
		set watchdog
		init to '0's with memset
		account call and/or return error if not successful

*/

{
void * l_NewBlock;

	init();
	g_CallocCalls++;

	if	(	(p_Number == 0)
		||	(p_Size   == 0)
		)
	{
		g_NonPortableCalloc++;
		p_Size		= 1;
		p_Number	= 1;
		print_Location(g_ErrorFile,p_FileName,p_LineNumber);
		fprintf(g_ErrorFile,"Calloc used to allocate 0 bytes. ");
		print_80ColLineFeed(g_ErrorFile);
		fprintf(g_ErrorFile,"Potential portability problem, calling as calloc(1,1) instead\n");
	}

	if (g_memdebugDeactivated)
	{
		l_NewBlock = malloc((p_Number * p_Size) + g_WatchdogSize);
		if (l_NewBlock)
		{
			wrap_Pointer(l_NewBlock);
			l_NewBlock = memset(l_NewBlock,'\0',(p_Number * p_Size));
		}
		return (l_NewBlock);
	}
	
	detab_String(p_SizeExpression);
	
	if ((g_TotalSize + (p_Size * p_Number) ) <= g_OptionRecord.f_MaximalMemoryAvailable)
	{
		l_NewBlock = malloc((p_Number * p_Size) + g_WatchdogSize);
		if (l_NewBlock)
		{
			wrap_Pointer(l_NewBlock);
			l_NewBlock = memset(l_NewBlock,'\0',(p_Number * p_Size));
			
			account_alloc(l_NewBlock,(p_Size * p_Number),c_Calloc,p_SizeExpression,p_FileName,p_LineNumber);
			return (l_NewBlock);
		}
		else
		{
			print_Location(g_ErrorFile,p_FileName,p_LineNumber);
			fprintf(g_ErrorFile,"System out of memory while allocating %s\n",p_SizeExpression);
			g_UnsuccessfulCallocs++;
			return (NULL);
		}
	}
	else
	{
		print_Location(g_ErrorFile,p_FileName,p_LineNumber);
		fprintf(g_ErrorFile,"Out of memory reached while allocating %s\n",p_SizeExpression);
		g_UnsuccessfulCallocs++;
		return (NULL);
	}
}

/********************************************************************************/
						
void  *	__check_realloc	  ( void	  * p_Pointer,
							size_t		p_Size,
							char	  *	p_NameString,
							char	  *	p_SizeExpression,
							char	  * p_FileName,
							long		p_LineNumber)
						
/*
	DESCRIPTION:
		Replaces (and calls) standard realloc()
		
	CLASS:
		memdebug
		
	ALGORITHM USED:
		Init tool
		Update global statistics
		Call account_realloc which takes over all action
		
	REMARKS:
		if used as malloc() or free(), an error is posted and the right function is called

		account_realloc does its own internal wrapping and unwrapping of the pointer
*/

{
void * l_NewPointer;
	init();				/* needed if realloc used as malloc (i.e. pointer passed == NULL)	*/
	
	if (p_Pointer == NULL)
	{
		g_NonPortableRealloc++;
		print_Location(g_ErrorFile,p_FileName,p_LineNumber);
		fprintf(g_ErrorFile,"Realloc used with NULL initial pointer. ");
		print_80ColLineFeed(g_ErrorFile);
		fprintf(g_ErrorFile,"Potential portability problem, calling malloc() instead\n");
		return (__check_malloc(p_Size,p_SizeExpression,p_FileName,p_LineNumber));
	}
	
	if (p_Size == 0)
	{
		g_NonPortableRealloc++;
		print_Location(g_ErrorFile,p_FileName,p_LineNumber);
		fprintf(g_ErrorFile,"Realloc used with new block size 0. ");
		print_80ColLineFeed(g_ErrorFile);
		fprintf(g_ErrorFile,"Potential portability problem, calling free() instead\n");
		__check_free(p_Pointer,p_NameString,p_FileName,p_LineNumber);
		return (NULL);
	}
	
	g_ReallocCalls++;
	
	if (g_memdebugDeactivated)
	{
		unwrap_Pointer(p_Pointer);
		l_NewPointer = realloc(p_Pointer,p_Size);
		wrap_Pointer(l_NewPointer);
		return (l_NewPointer);
	}
	
	detab_String(p_NameString		);
	detab_String(p_SizeExpression	);
	l_NewPointer = account_realloc	  (	p_Pointer,
										p_Size,
										p_NameString,
										p_SizeExpression,
										p_FileName,
										p_LineNumber
									  );
	return (l_NewPointer);
}

/********************************************************************************/
						
void __check_free	  ( void	  * p_Pointer,
						char	  *	p_NameString,
						char	  * p_FileName,
						long		p_LineNumber)
						
/*
	DESCRIPTION:
		Replaces (and calls) standard free()
		
	CLASS:
		memdebug
		
	ALGORITHM USED:
		Init tool
		Update global statistics
		Call real free(), account call and/or return error if not successful
*/

{
t_ObjectState l_BlockStatus;

	init();
	g_FreeCalls++;
	
	if ( g_memdebugDeactivated )
	{
		unwrap_Pointer(p_Pointer);
		free(p_Pointer);
		return;
	}

	detab_String(p_NameString);

	if (p_Pointer != NULL)
	{
		l_BlockStatus = account_free(p_Pointer,p_NameString,p_FileName,p_LineNumber);

		unwrap_Pointer(p_Pointer);
		
		if (l_BlockStatus == c_Ok)
			free(p_Pointer);
		else
		{
			print_Location(g_ErrorFile,p_FileName,p_LineNumber);
			fprintf(g_ErrorFile,"Freeing unallocated block : %s\n",p_NameString);
			g_IllegalFrees++;
		}
	}
	else 
		if (g_OptionRecord.f_SpuriousFreeList)
		{
			print_Location(g_ErrorFile,p_FileName,p_LineNumber);
			fprintf(g_ErrorFile,"Spurious free : %s\n",p_NameString);
			g_SpuriousFrees++;
		}
}

/********************************************************************************/
void generate_MemdebugError		  ( void )

/*
	DESCRIPTION:
		Enables the generation of memory allocation errors
		
	CLASS:
		memdebug
		
	ALGORITHM USED:
		Simply set available memory to 0 bytes (errors will then occur automatically...).
*/

{
	init();
	if ( g_memdebugDeactivated )
		return;
		
	if (g_OptionRecord.f_GenerateErrorCount-- <= 0)
		g_OptionRecord.f_MaximalMemoryAvailable = 0;	/* it's as simple as that	*/
}

/********************************************************************************/

void print_MemdebugStatistics	  ( void )

/*
	DESCRIPTION:
		Explicitly prints memory usage statistics
		
	CLASS:
		memdebug
		
	ALGORITHM USED:
		According to options used, call print functions of the different data structures 
		
	REMARK:
		Once called, no more automatic final statistics will be printed.
*/

{
	init();

	if ( g_memdebugDeactivated )
		return;

	g_StatisticsPrinted = c_Yes;
	
	if (g_OptionRecord.f_GeneralStatistics)
		print_GeneralStatistics();
	
	if (g_OptionRecord.f_AlphaList)
		print_AlphaList();

	if (g_OptionRecord.f_NotFreeList)
		print_NotFreeList();

	if (g_OptionRecord.f_CallSequenceList)
		print_CallSequenceList();
		
	fflush(g_StatisticsFile);
}

/********************************************************************************/

int check_memdebugError		  ( void )

/*
	DESCRIPTION:
		Behind-the-scenes error check function
		
	CLASS:
		memdebug
		
	ALGORITHM USED:
		Set p_Error to sum of
			g_IllegalReallocs
			g_IllegalFrees
			g_SpuriousFrees
		
	REMARK:
		Once called, no more automatic final statistics will be printed.

	ATTENTION:
		When memdebug is not defined, the macro will always return 0 (== no error!)
		
	SUGGESTION:
		This function should be used for behind-the-scenes test programs.
		No final memory usage statistics are printed, but print_MemdebugStatistics()
		may be used to do so explicitly.
*/

{
	init();

	if ( g_memdebugDeactivated )
		return 0;

	g_StatisticsPrinted = c_Yes;
	
	return (  g_IllegalReallocs
			+ g_IllegalFrees
			+ g_SpuriousFrees
			+ g_CorruptedBlock
			+ g_NonPortableMalloc
			+ g_NonPortableCalloc
			+ g_NonPortableRealloc
		   );

}

/********************************************************************************/

void set_MemdebugOptions  ( t_biState		p_GeneralStatistics,
							t_biState		p_AlphaList,
							t_biState		p_NotFreeList,
							t_biState		p_CallSequenceList,

							t_biState		p_SpuriousFreeList,
							
							t_biState		p_PrintContents,
							t_biState		p_DestroyContents,
							
							long			p_GenerateErrorCount,
							unsigned long	p_MaximalMemoryAvailable,
							
							char		  * p_StatisticsFileName,
							char		  * p_ErrorFileName
						  )

/*
	DESCRIPTION:
		Allows user to configure MEMCKECK
		
	CLASS:
		memdebug
		
	ALGORITHM USED:
		Copies parameters to global variables.
		Opens the given statistics and error file
		Set error file to line buffering 
*/

{
	init();
	
	if ( g_memdebugDeactivated )
		return;

	g_OptionRecord.f_GeneralStatistics	= p_GeneralStatistics,
	g_OptionRecord.f_AlphaList			= p_AlphaList;
	g_OptionRecord.f_NotFreeList		= p_NotFreeList,
	g_OptionRecord.f_CallSequenceList	= p_CallSequenceList,

	g_OptionRecord.f_PrintContents		= p_PrintContents;
	g_OptionRecord.f_DestroyContents	= p_DestroyContents;
	
	g_OptionRecord.f_SpuriousFreeList	= p_SpuriousFreeList;

	g_OptionRecord.f_GenerateErrorCount = p_GenerateErrorCount;
	
	if 	(	(p_MaximalMemoryAvailable)
		&&	(g_OptionRecord.f_MaximalMemoryAvailable == (unsigned long) LONG_MAX)
		)
		g_OptionRecord.f_MaximalMemoryAvailable	= p_MaximalMemoryAvailable;
	else
		g_OptionRecord.f_MaximalMemoryAvailable	= (unsigned long) LONG_MAX;

	
	if (*p_StatisticsFileName)
		g_OptionRecord.f_StatisticsFileName	=	p_StatisticsFileName;
	else
		g_OptionRecord.f_StatisticsFileName =	"stdout";
	open_File(&g_StatisticsFile,g_OptionRecord.f_StatisticsFileName,D_CouldNotOpenStatisticsFile);

	if (*p_ErrorFileName)
		g_OptionRecord.f_ErrorFileName		=	p_ErrorFileName;
	else
		g_OptionRecord.f_ErrorFileName		=	"stderr";
	open_File(&g_ErrorFile,g_OptionRecord.f_ErrorFileName,D_CouldNotOpenErrorFile);
	setvbuf(g_ErrorFile ,NULL,_IOLBF,255);
}

/********************************************************************************/
