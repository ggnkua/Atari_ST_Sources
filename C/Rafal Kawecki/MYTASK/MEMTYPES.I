#include "memdebug.h"

#ifndef	__memdebug_Types__
#define __memdebug_Types__

/**************************************************************************/
/******************************* Data Types *******************************/
/**************************************************************************/

struct t_OptionRecord
{
	t_biState		f_GeneralStatistics;
	t_biState		f_AlphaList;
	t_biState		f_NotFreeList;
	t_biState		f_CallSequenceList;
	
	t_biState		f_SpuriousFreeList;
	
	t_biState		f_PrintContents;
	t_biState		f_DestroyContents;
	
	long			f_GenerateErrorCount;
	unsigned long	f_MaximalMemoryAvailable;
	
	char		  * f_StatisticsFileName;
	char		  * f_ErrorFileName;
};

typedef struct t_OptionRecord t_OptionRecord;

/**************************************************************************/

enum t_CallKind
{
	c_Malloc,
	c_Calloc,
	c_Realloc,
	c_Free
};

typedef enum t_CallKind t_CallKind;

/**************************************************************************/

struct t_CallSequenceLink
{
	struct t_CallSequenceLink	  * f_Next;
	struct t_CallSequenceLink	  * f_Previous;
	struct t_CallSequenceLink	  * f_MallocLink;
	struct t_BlockDescriptor	  * f_BlockDescriptor;
	t_CallKind						f_CallKind;

	char						  *	f_SizeExpression;
	unsigned long					f_Size;
	char						  * f_FileName;
	long							f_LineNumber;
};

typedef struct t_CallSequenceLink	t_CallSequenceLink;

/**************************************************************************/

struct t_BlockDescriptor
{
	void 				  *	f_Pointer;
	char				  * f_Identifier;

	t_CallSequenceLink	  * f_BackLink;
	
	long					f_WatchdogValue;
	
	long					f_TimesUsed;
	unsigned long			f_TotalAllocated;
};

typedef struct t_BlockDescriptor t_BlockDescriptor;

/**************************************************************************/

enum t_ObjectState
{
	c_Bad = 0,
	c_Ok
};

typedef enum t_ObjectState t_ObjectState;

/**************************************************************************/
/*************************** Utility Prototype ****************************/
/**************************************************************************/

int	compare_BlockPointers	(	t_BlockDescriptor	  *	p_Block1,
								t_BlockDescriptor	  *	p_Block2);

int	compare_Identifiers		(	t_BlockDescriptor	  *	p_Block1,
								t_BlockDescriptor	  *	p_Block2);

void treat_InternalError	(	int	p_ErrorCode	);


#endif

