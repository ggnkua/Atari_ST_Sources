/* gestionnaire m‚moire */
#include <stdio.h>
#include <osbind.h>
#include "ldg.h"
int gl_exception_error(long num_error);
typedef struct memory_alloc{
	void *next; /* prochain bloc CAD cette entˆte puis … la suite le bloc allou‚ */
	void *alloue; /* m‚moire retourn‚e pour l'utilisation*/
} memory_alloc;
void *memoire_allouee=NULL;
char smallalloc[10000];
long possmallalloc=0;
void *petitealloc(long size) /* pour alleger le nombre de blocs alloues */
{
	if(possmallalloc+size<10000)
	{ long old=possmallalloc;
		possmallalloc+=size;
		return((void *)&smallalloc[old]);
	}
	return(NULL);
}
void *my_Malloc(taille)	/* pour Garbage collecting de la m‚moire allou‚e */
long taille;
{ void *pt=NULL;
  memory_alloc *pt2;
  if(taille<100) pt=petitealloc(taille);
  if(pt!=NULL) return(pt);
	pt=(void *)ldg_Malloc(taille+sizeof(memory_alloc));
	if(pt!=NULL)
	{
		pt2=(memory_alloc *) pt;
		pt2->next=memoire_allouee;
		pt2->alloue=(void *)((long)pt+(long)sizeof(memory_alloc));
		memoire_allouee=(void *)pt;
		pt=(void *)((long)pt+(long)sizeof(memory_alloc));
		if(Malloc(-1L)<32200L) gl_exception_error(100L);
	}
	else
	{
			gl_exception_error(13L);
			/* Cconws("Fatal Memory Error in Tiny_gl.ldg exit of the client program\015\012");
			exit(1);*/
	}
	return(pt);
}
void my_Free(pt_mem)   /* d‚sallouer une m‚moire allou‚e pas my_Malloc */
void *pt_mem;           /* addresse a d‚sallouer */
{ memory_alloc *pt,*pt2,*ex_pt=NULL;
	if(pt_mem!=NULL)
	{
		pt=(memory_alloc*)memoire_allouee;
		while(pt!=NULL)
		{
			if(pt->alloue==pt_mem)
			{
				pt2=(memory_alloc *)pt->next;
				ldg_Free((void *)pt);
				if(ex_pt!=NULL) ex_pt->next=(void *)pt2;
				else memoire_allouee=(void *)pt2;
				return;
			}
			else
			{
				ex_pt=pt;
				pt=pt->next;
			}
		}
	}
}
void Freeall() /* d‚salloue tous les blocs m‚moire allou‚s par my_Malloc()! ()
					tous les allocs sauf pour l'image RVB c'est le client charg‚ de 
					d‚sallouer ce bloc si il veut faire mumuse aprŠs avec l'image*/
{
	
	memory_alloc *pt,*pt2;
	pt=(memory_alloc *)memoire_allouee;
	while(pt!=NULL)
	{
		pt2=(memory_alloc *)pt->next;
		ldg_Free((void *)pt);
		pt=pt2;	
	}
	memoire_allouee=NULL;
	possmallalloc=0L;
}
void *my_calloc(unsigned int t1, unsigned int t2)
{ long size,i; char *pos,*pt;
	size=(long)t1*(long)t2;
	pos=my_Malloc(size);
	pt=pos;
	if(pos!=NULL)
		for(i=0L;i<size;i++)
		{
			*pt++=0;
		}
	return((void *)pos);
}
