
overlay "player"

#include "..\\include\\lists.h"

WORD *
clone_tube(tube)
WORD tube[];
{
return((WORD *)clone_structure(tube, tube[0]*sizeof(WORD) )  );
}


print_tube(name,tube)
char *name;
WORD *tube;
{
WORD i;

lprintf("%s: ", name);
i = *(tube);
while (--i >= 0)
	{
	lprintf("%ld ",*(tube++));
	}
lprintf("\n");
}


#ifdef SLUFFED
WORD **
tlist(list, str_count)
WORD **list;
WORD *str_count;
{
WORD **clone;
WORD **clone_pt;
WORD count;

#ifdef DEBUG
lprintf("tlist(%lx %d)\n",list, *str_count);
#endif DEBUG

count = *str_count;

clone_pt = clone = (WORD **)clone_structure( list, count * sizeof(WORD *) );
while (--count >= 0)
	{
	*(clone_pt++) = (WORD *)
	clone_structure( *(list), **(list) * sizeof(WORD) );
	list++;
	}
return(clone);
}
#endif SLUFFED

free_tube(tube)
WORD *tube;
{
#ifdef DEBUG
lprintf("free_tube(%lx)\n",tube);
#endif DEBUG

mfree( tube, tube[0] * sizeof(WORD) );
}

/********************************************************************
*
*	clean_tube_list()
*	remove NULL pointers from tube list
**********************************************************************/
WORD **
clean_tube_list(list, count)
WORD **list;
register WORD *count;
{
register WORD **llist, **olist, *tube;
register WORD lcount, ocount, i;

lcount = 0;
i = ocount = *count;
llist = list;
while (--i >= 0)
	{
	if ( *llist++)
	lcount++;
	}
/*count up non-null tubes*/

if (lcount == ocount)
	return(list);  /*nothing to clean*/

llist = (WORD **)alloc(lcount * sizeof(WORD *) );
olist = list;
i = ocount;
while (--i >= 0)
	if (  tube = *olist++ )
	*llist++ = tube;
/* yer basic zero suppressed copy **/

mfree(list, ocount * sizeof(WORD *));
*count = lcount;
return( llist - lcount);
}


WORD **
rm_from_tube_list(list, count, element)
WORD **list;
WORD *count;
WORD *element;
{
WORD **new_list, **pt1, **pt2;
WORD i;

#ifdef DEBUG
lprintf("remove_frome_tube_list(%lx %d %lx)\n",list, *count, element);
#endif DEBUG

pt1 = list;
i = *count;
while (--i >= 0)
	{
	if (tube_compare( *pt1, element) )
	{
	free_tube(*pt1);
	*pt1 = NULL;
	break;
	}
	pt1++;
	}


new_list = (WORD **)alloc( (*count-1) * sizeof(WORD *) );

i = *count;
pt1 = list;
pt2 = new_list;
while (--i >= 0)
	{
	if ( *pt1 )
	*(pt2++) = *pt1;
	pt1++;
	}
mfree(list, *count * sizeof(WORD) );
--(*count);
return(new_list);
}

WORD **
add_to_tube_list(list, count, new_tube)
WORD **list;
WORD *count;
WORD *new_tube;
{
WORD **new_list;

#ifdef DEBUG
lprintf("add_to_tube_list(%lx %d %lx)\n",list, *count, new_tube);
#endif DEBUG
new_list = (WORD **)alloc( (*count+1) * sizeof(WORD *) );
copy_structure(list, new_list, *count * sizeof(WORD *) );
new_list[*count] = new_tube;
mfree(list, *count * sizeof(WORD) );
(*count)++;
return(new_list);
}

free_tube_list(list, count)
WORD **list;
WORD count;
{
register WORD **tubes, i;
register WORD *tube;

#ifdef DEBUG
lprintf("free_tube_list(%lx %d)\n",list, count);
#endif DEBUG

tubes = list;
i = count;
while (--i >= 0)
	{
	tube = *(tubes++);
	mfree( tube, *tube * sizeof(WORD) );
	}
mfree( list, count * sizeof(WORD *) );
}

tube_compare(s1, s2)
register WORD *s1, *s2;
{
register WORD count;

#ifdef DEBUG
lprintf("tube_compare(%lx %lx)\n", s1, s2);
#endif DEBUG

count = *(s1);
while (--count >= 0)
	{
	if ( *(s1++) != *(s2++) )
	return(0);
	}
return(1);
}

in_tube_list(list, count, element)
register WORD **list;
register int count;
register WORD *element;
{
while (--count >= 0)
	if ( tube_compare( *(list++), element))
	return(1);
return(0);
}


/**
**a little bubble sort on an tube of WORDs
**/
tube_sort(list)
WORD *list;
{
WORD count;
WORD swapped;
WORD swapper;
WORD i;
register WORD *list_pt, *next_list_pt;

#ifdef DEBUG
lprintf("WORD_sort(%lx)\n",list);
#endif DEBUG

#ifdef DEBUG
print_tube("sort", list);
#endif DEBUG
swapped = 1;

count = *list - 2;  /*since go one past*/
while (swapped)
	{
	list_pt = list+1;
	next_list_pt = list_pt+1;
	swapped = 0;
	for (i=0; i<count; i++)
	{
	if ( *list_pt > *next_list_pt )
		{
		swapped++;
		swapper = *list_pt;
		*list_pt = *next_list_pt;
		*next_list_pt = swapper;
		}
	list_pt++;
	next_list_pt++;
	}
	}
#ifdef DEBUG
print_tube("sorted",list);
#endif DEBUG
}

