/*
 * ArboFile.c
 *
 * Purpose:
 * --------
 * Traitement des fichiers arbo (.ARB)
 */

	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"ARBOFILE.C v1.00 - 03.95"
          
/*
 * System headers:
 */
	#include	<stdio.h>
	#include <stdlib.h>					/* Malloc etc... */
	#include	<string.h>					/* Memcpy etc... */
	
/*
 * Custom headers:
 */
	#include	"ARB_OUT.H"

	#include "SPEC_PU.H"					/* Listes... */	
	#include	"DEBUG_PU.H"	
	#include	"DEF_ARBO.H"	/* this */
	#include	"AFILE_PU.H"	/* this */
	#include "WIN_PU.H"

/*
 * Types:
 */
typedef
	struct
	{
		int				n_int;
		unsigned long	dw_dword;
	}
	INT_DWORD;


/*
 * Variables:
 */
	/*
	 * Correspondances entre champs d'‚dition et identifiants de champs 
	 * pour base de donn‚es:
	 * Sert uniquement … la mise … jour des fichiers de version 0.02
	 */
	static	INT_DWORD	M_FieldFnctVsId[]=
	{
		FEI_USERNAME,		'USER',
		FEI_FIRSTNAME,		'1STN',
		FEI_LASTNAME,		'LSTN',
		FEI_PASSWORD,		'PASS',

		FEI_OFFICE,			'OFFC',

		FEI_ADDRESS1,		'ADR1',
		FEI_ADDRESS2,		'ADR2',
		FEI_ZIP,				'ZIPC',
		FEI_TOWN,			'TOWN',
		FEI_STATE,			'ETAT',
		FEI_COUNTRY,		'PAYS',

		FEI_PHONE,			'PHON',
		FEI_FAX,				'FAXN',
		FEI_MODEM,			'MODM',

		FEI_TITLE,			'MTIT',
		FEI_TEXT,			'MTXT',
		NIL_1,				0
	};

	static	INT_DWORD	M_OutFieldFnctVsId[]=
	{
		FO_USERNAME,		'USER',
		FO_FIRSTNAME,		'1STN',
		FO_LASTNAME,		'LSTN',
		FO_TITLE,			'MTIT',
		FO_TEXT,				'MTXT',
		FO_DSTA,				'DSTA',
		FO_MPSE,				'MPSE',
		NIL_1,				0
	};



/*
 * get_InFieldCode(-)
 *
 * pour maj fichiers v 0.02 uniquement
 * 
 * 23.01.95: created
 */ 
ULONG	get_InFieldCode(		/* Out: code correspondant au champ */
			int	n_fnct )		/* In: no de fonction */
{
	int	i;	

	for( i=0; M_FieldFnctVsId[ i ] .n_int != NIL_1; i++ )
	{
		if( M_FieldFnctVsId[ i ] .n_int == n_fnct )
		{
			return	M_FieldFnctVsId[ i ] .dw_dword;
		}
	}

	/*
	 * Not Accurate
	 */	
	return	'N.A.';
}



/*
 * get_OutFieldCode(-)
 *
 * pour maj fichiers v 0.02 uniquement
 * 
 * 24.01.95: created
 */ 
ULONG	get_OutFieldCode(		/* Out: code correspondant au champ */
			int	n_fnct )		/* In: no de fonction */
{
	int	i;	

	for( i=0; M_OutFieldFnctVsId[ i ] .n_int != NIL_1; i++ )
	{
		if( M_OutFieldFnctVsId[ i ] .n_int == n_fnct )
		{
			return	M_OutFieldFnctVsId[ i ] .dw_dword;
		}
	}

	/*
	 * Not Accurate
	 */	
	return	'N.A.';
}
