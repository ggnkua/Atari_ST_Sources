/* play lists */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>

#include "PROTO.H"

extern int 	shuffle;		/* random play! */


/* defs */

#define		BIGBLOCK	1000
#define		EVEN(addr)	(((addr)+1L) & -2L)

/* struct */

typedef struct filename_block
{
	size_t		len,			/* how many bytes can data[] hold... */
				pos;			/* next free position in block */
	long		entries,		/* total records */
				play;			/* doing this number */

	char		data[];			/* complete path + name */
} filename_block_t;

typedef struct					/* reasonable string */
{
	int			flag;
	int			siz;			/* total size of the struct */
	char		str[];
} string_t;


/* vars */
PRIVATE filename_block_t	*listmemory;
									/* Zeiger auf gemerkte Namen */
PRIVATE long	*listentries;		/* */



/* L”sche eine Liste aus dem Speicher.
 * Param:	keine
 * Return:	nichts
 * Global:	listentries und listmemory werden auf Null gesetzt, der
 *			allozierte Speicher freigegeben.
 */
void clear_modfile_list( void )
{
	if (listmemory) Mfree(listmemory);
	listmemory	= NULL;
	listentries = 0;
}

/*
 *
 *
 *
 *
 */
BOOL add_modfile_to_list( const char *name )
{
	string_t	*s;
	size_t		req;
	void		*p;
	filename_block_t *new;

	req = EVEN(sizeof(string_t) + strlen(name) + 1);	/* required storage */

	if (listmemory==NULL)
	{
		new = (filename_block_t)acc_malloc( sizeof(filename_block_t)
					+ BIGBLOCK );

		if (new==NULL) return FALSE;
		memset(new, 0, sizeof(filename_block_t)+BIGBLOCK );
		new->len = BIGBLOCK;
		Mfree(listmemory);
		listmemory = new;
	}
							
	if (listmemory->len - listmemory->pos < req)
	{
		/* allocate more space! */
		new = (filename_block_t)acc_malloc( sizeof(filename_block_t)
					+ listmemory->len + BIGBLOCK );
		if (new==NULL) return FALSE;
		memcpy(new, listmemory,
				sizeof(filename_block_t)+listmemory->len);
		new->len = listmemory->len + BIGBLOCK;
		/* new->entries = listmemory->entries; */
		Mfree(listmemory);
		listmemory = new;
	}	

	p = &((listmemory->data)[listmemory->pos]);	/* ptr to next free position */
	if (listmemory->len - listmemory->pos < req)
	{
		puts("internal error in add_modfile_to_list()");
		return FALSE;
	}
	s = (string_t *)p;
	s->flag = 0;
	s->siz = (int)req;
	strcpy ( s->str, name );

	return TRUE;
}


/* Kopiere den ersten MODFile-namen in modpath.
 * Param:	keine
 * Return:	TRUE bei Erfolg.
 * Global:	'modpath' wird ver„ndert.
 */
BOOL get_first_mod( void )
{
	if (listmemory==NULL) return FALSE;

	listmemory->play = 0;			/* reset position variable */

	return get_next_mod();
}


/* Kopiere den n„chsten abzuspielenden MODfile-namen in die globale
 * variable 'modpath'. Wenn in der Liste NUR ein Name angegeben ist,
 * wird der Pfad, der noch in MODPATH liegt, benutzt.
 * Param:	keine
 * Return:	TRUE bei Erfolg.
 * Global:	'modpath' wird ver„ndert.
 */
BOOL get_next_mod( void )
{
	char		*p;
	long 		i;
	string_t	*s;

	if (listmemory == NULL) return FALSE;

	if (listmemory->play >= listmemory->entries)	return FALSE;

	if (shuffle)
	{
		do {
			i=(int)(((long)rand()*listmemory->entries)>>15);
			s = (string_t*)listmemory->data;	/* first position */
			while (i-- > 0) s += s->siz;		/* next pos */
		} while (s->flag != 0);
	}
	else
	{
		i = listmemory->play++;
		s = (string_t*)listmemory->data;		/* first position */
		while (i-- > 0) s += s->siz;			/* next pos */
	}
	p = s->str;					/* point to file name */
	s->flag ++;					/* selected once more */

	if (strpbrk(p, ":\\"))			/* Backslash od. ':'	*/
		strcpy( modpath, p );		/* return path...		*/
	else
	{
		trim_path(modpath, NULL);	/* rest abschneiden!	*/
		strcat(modpath,p);			/* anh„ngen!			*/
	}
	return TRUE;
}


/* eof */