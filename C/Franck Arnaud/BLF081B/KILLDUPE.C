/*
 * Detection of duplicate strings (Msg-ids for instance)
 *
 * Prototype:	int already_seen (char *string);
 *
 * Parameter:	a null-terminated string.
 *
 * Returns:	1 if the function "already_seen" has already been invoked
 *		with the same string (case is sensitive). 0 otherwise.
 *
 * Side effects: adds "string" to the list of the already-seen strings,
 *		provided that there is enough memory.
 *
 * Written by Thierry Bousch for the BloufGate project.
 * Poorly updated to have memory other sessions by FA.
 * This file is public domain.
 */

#include <stdlib.h>
#include <stddef.h>
#include <string.h>

#include "blouf.h"	/* BLFSTR, f(blf)gets */

#define STRINGLEN BLFSTR

/*tb*/

#define HASHSIZE 512

typedef struct _string {
	char *s;
	struct _string *n;
} String;

static int initialized = 0;
static String *hash_table [HASHSIZE];

static int hash (char *string)
{
	unsigned long h = 0L;
	char c;

	while ((c = *string++) != '\0')
		h += (h << 1) + c;

	return (int)(h % HASHSIZE);
}

/* check dupe */

int already_seen (char *string)
{
	int i;
	String *p;

	if (!initialized) {
		for (i = 0; i < HASHSIZE; i++)
			hash_table[i] = NULL;
		initialized = 1;
	}
	if (string == NULL)
		return 1;	/* We know the (nil) string */
	i = hash(string);
	for (p = hash_table[i]; p != NULL; p = p->n)
	{
		if (strcmp(p->s, string) == 0)
		{
			return 1;	/* We know this string */
		}
	}
	/* Otherwise add it to our list */
	p = (String *)malloc(sizeof(String));
	if (p != NULL) {
		p->s = (char *)malloc(strlen(string)+1);
		if (p->s) {
			strcpy(p->s, string);
			p->n = hash_table[i];
			hash_table[i] = p;
		} else	free(p);
	}
	return 0;	/* This was a new string to us */
}

/*end/tb*/

static FILE *mccoy = NULL; /* file to put */

/*
 * dupechk_open: dupe file load and initialize 
 *	file:	name of the optional dupe file (NULL for none)
 *	result: number of IDs loaded
 */

long dupechk_open(char *file)
{
	long zebulon=0;
	FILE *zork;
	char kirk[STRINGLEN+1];

	if(!file)
	{
		mccoy=NULL;
		return 0;
	}	

	zork=fopen(file,"r");
	if(zork)
	{
		while(fgets(kirk,STRINGLEN,zork)!=NULL)
		{
			if(*kirk)
			{
				if(kirk[strlen(kirk)-1]<32)	/* kill \n */
					kirk[strlen(kirk)-1]=0;
				zebulon++;
				already_seen(kirk); /* add to database, easy way, probably poor performance */
			}
		}
		fclose(zork);
	}

	/* open to append next seen by */
	mccoy=fopen(file,"a");

	return zebulon;
}

/*
 *	dupechk_seen: check if given ID has been seen, store otherwise
 *	id:	message-id string
 *	result: !0: yes, dupe; 0: not seen
 */

int dupechk_seen(char *id)
{
	int ncc1701;

	ncc1701=already_seen(id);
	if(!ncc1701)
	{ /*!seen*/
		if(mccoy)
			fputs(id,mccoy);
	}	
	return ncc1701;
}

/*
 * dupechk_close: close dupechecker, flush dupes file
 */

void dupechk_close(void )
{
	if(mccoy)
		fclose(mccoy);
	mccoy=NULL;
}

/*eof*/