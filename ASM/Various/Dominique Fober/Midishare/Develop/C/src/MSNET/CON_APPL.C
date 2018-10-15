/********************************************************************************/
/*                     MIDI SHARE Application Midi Connecte                     */
/*------------------------------------------------------------------------------*/
/*		CON_APPL.C												*/
/*		Module de gestion des applications MidiShare						*/
/*------------------------------------------------------------------------------*/
/*		@ GRAME 1989/90, Yann Orlarey et Herv‚ Lequay 					*/
/*					  Dominique Fober (Atari ST)						*/
/********************************************************************************/

#include <stdio.h>
#include <msh_unit.h>

#ifdef MWC
# include <osbind.h>
#endif

#ifdef TURBO_C
# include <tos.h>
#endif

#include "con_defs.h"


#define MEM_RES	5000

extern int handle;

/* Les variables du module */
/*---------------------------------------------------------------*/
APPL *FreeList, *mem;
struct GEST gest;



/*__________________________________________________________________*/
Boolean init_mem()
{
	register APPL *tmp;
	register long size;
	register short i;

	gest.appl= (APPL *)nil;
	size= sizeof( APPL) * MAX_APPLS;
	if( size > ( (long)Malloc( -1L) - MEM_RES) )
		return FALSE;
	if( FreeList= (APPL *)Malloc( size))
	{
		mem= tmp= FreeList;
		for( i=0; i<MAX_APPLS-1; i++, tmp++)
			tmp->next= tmp+1;
		tmp->next= (APPL *)nil;
	}
	else return FALSE;
	return TRUE;
}

/*__________________________________________________________________*/
APPL *newAppl()
{
	register APPL *tmp;
	
	if( FreeList)
	{
		tmp= FreeList;
		FreeList= tmp->next;
		return tmp;
	}
	else return (APPL *)nil;
}

/*__________________________________________________________________*/
void freeAppl( appl)
register APPL *appl;
{
	appl->next= FreeList;
	FreeList= appl;
}

/*__________________________________________________________________*/
short getIndAppl( appl)
register APPL *appl;
{
	register APPL *tmp;
	register short i=0;
	
	tmp= gest.appl;
	while( tmp)
	{
		if( tmp== appl)
			return i;
		tmp= tmp->next;
		i++;
	}
	return 0;
}

/*__________________________________________________________________*/
APPL *getApplPtr( refnum)
register short refnum;
{
	register APPL *tmp;
	
	tmp= gest.appl;
	while( tmp)
	{
		if( tmp->refnum== refnum)
			return tmp;
		tmp= tmp->next;
	}
	return (APPL *)nil;
}

/*__________________________________________________________________*/
void chgeNameAppl( appl)
register APPL *appl;
{
	if( !appl) return;
	appl->name= MidiGetName( appl->refnum);
}

/*__________________________________________________________________*/
Boolean delAppl( appl)
register APPL *appl;
{
	register APPL *tmp;
	register short i;
	
	if( !appl) return FALSE;
	tmp= gest.appl;
	if( tmp== appl)
		gest.appl= appl->next;
	else
	{
		while( tmp->next != appl)
			if( !(tmp= tmp->next)) 
				return FALSE;
		tmp->next= appl->next;
	}
	for( i=0; i<NBRE_SF; i++)
	{
		if( gest.aff[i]== appl)
			gest.aff[i]= tmp;
	}
	freeAppl( appl);
	return TRUE;
}

/*__________________________________________________________________*/
APPL *addAppl( refnum)
register short refnum;
{
	register APPL *appl, *tmp;
	
	if( !(appl= newAppl()))				/* on alloue une nouvelle application 	*/
		return (APPL *)nil;
	appl->refnum= refnum;				/* et son refNum					*/
	appl->name= MidiGetName(refnum);		/* on range son nom					*/
	if( tmp= gest.appl)					/* si ce n'est pas la premiŠre		*/
	{
		while( tmp->next)				/* on la chaine					*/
			tmp= tmp->next;
		tmp->next= appl;				/* en fin de liste 					*/
	}
	else gest.appl= appl;				/* sinon on range en tete de liste		*/
	appl->next= (APPL *)nil;				/* et on signale que c'est la derniŠre	*/
	return appl;
}

/*__________________________________________________________________*/
void getConnections( appl)
register APPL * appl;
{
	register APPL *tmp;
	register short refnum, i=0;

	if( !appl) return;
	tmp= gest.appl;
	refnum= appl->refnum;
	while( tmp)
	{
		if( MidiIsConnected( tmp->refnum, refnum))
			AcceptBit( appl->in, i);
		else
			RejectBit( appl->in, i);

		if( MidiIsConnected( refnum, tmp->refnum))
			AcceptBit( appl->out, i);
		else
			RejectBit( appl->out, i);
		tmp= tmp->next;
		i++;
	}
}

/*__________________________________________________________________*/
void getAllConnect()
{
	register APPL *appl;
	
	appl= gest.appl;					/* appl pte la liste des appl. trouv‚es */
	while( appl)						/* pour chaque application de liste	*/
	{
		getConnections( appl);			/* on collecte l'‚tat de ses connexions */
		appl= appl->next;
	}
}

/*__________________________________________________________________*/
void getStateAppls()
{
	register short refnum, n, i;
	
	n= MidiCountAppls();				/* on compte le nombre d'applications	*/
	for( i=1; i<=n; i++)				/* et pour chacune :				*/
	{
		if( (refnum= MidiGetIndAppl( i))>=0)	/* on collecte son refnum		*/
			if( !addAppl( refnum))		/* on l'ajoute … la liste des applications */
			{
				AlertUser( ERR_FULL);
				break;
			}
	}
	getAllConnect();
}

/*__________________________________________________________________*/
void free_mem()
{
	if( mem) Mfree( mem);
}

/*---------------------------- fin ------------------------------*/
