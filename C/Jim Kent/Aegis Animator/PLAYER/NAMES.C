
overlay "reader"

#include "..\\include\\lists.h"

#ifdef SLUFFED
char_in(c, string)
char c;
register char *string;
{
if (string)
	{
	while (*string)
	if (*string++ == c)
		return(1);
	}
return(0);
}
#endif SLUFFED

tr_string(string, old, new)
register char *string, old, new;
{
register char this;

if (!string)
	return;
for (;;)
	{
	if ((this = *string) == 0 )
	break;
	if (this == old)
	*string = new;
	string++;
	}
}

#ifdef SLUFFED
char *
add_char(s,c)
char *s;
char c;
{
register char *ret;
register int length;

if (s)
	{
	length = strlen(s);
	if (ret = (char *)alloc( length+2 ))
	{
	strcpy(ret, s);
	ret[length] = c;
	ret[length+1] = 0;
	mfree(s, length+1);
	}
	}
else
	{
	ret = (char *)alloc(2);
	ret[0] = c;
	ret[1] = 0;
	}
return(ret);
}
#endif SLUFFED


char *
clone_string(s1)
char *s1;
{
int length;
char *clone;

if (s1 == NULL)
	return(NULL);
length = strlen(s1);
clone = (char *)alloc(length + 1);

if (clone)
	{
	strcpy(clone, s1);
	clone[length] = '\0';
	}
return(clone);
}

copy_chars(s,d,count)
register char *s,*d;
register int count;
{
while (--count >= 0)
	*(d++) = *(s++);
}

#ifdef SLUFFED
back_copy_chars(s,d,count)
register char *s,*d;
register int count;
{
d += count;
s += count;
while (--count >= 0)
	*(--d) = *(--s);
}
#endif SLUFFED

char *
cut_suffix(s,end)
char *s;
char *end;
{
WORD length;
char *ret;

length = strlen(s) - strlen(end);
ret = (char *)alloc(length+1);
if (ret)
	{
	copy_chars(s, ret, length);
	*(ret+length)=0;
	}
return(ret);
}



free_string(string)
register char *string;
{
if (string)
	mfree( string, strlen(string) + 1);
}



#ifdef NEVER
char *
str_num(num)
int num;
{
char buffer[20];
char *pt = buffer + 20;

int sign;
int limit = 20 - 2;  /*one for sign and one for zero tag*/

sign = num;
if (num < 0)
	num = -num;
if (num == 0)
	return( clone_string("0") );
	
*(--pt) = '\0';

while (num && (--limit >= 0) )
	{
	*(--pt) = num%10 + '0';
	num /= 10;
	}
if (sign < 0)
	*(--pt) = '-';

return( clone_string(pt) );
}
#endif NEVER

jstrcmp(a, b)
register char *a, *b;
{
register char aa, bb;

if (a == b)
	return(0);
if (a == NULL)
	return(1);
if (b == NULL)
	return(-1);
for (;;)
	{
	aa = *a++;
	bb = *b++;
	if (aa == bb)
		{
		if (!aa)
			return(0);
		}
	else
		return( aa - bb);
	}
}


suffix_in(name,suffix)
char *name, *suffix;
{
char *tptr;

tptr = (name + strlen(name) - strlen(suffix));
if (jstrcmp(tptr,suffix) == 0)
	return(1);
else
	return(0);
}

#ifdef SLUFFED
suffix_opt(buf, base, suffix)
char *buf, *base, *suffix;
{
if (suffix_in(base, suffix) )
	strcpy(buf, base);
else
	sprintf(buf, "%s%s",base,suffix);
}
#endif SLUFFED

#ifdef SLUFFED
printname(name)
char *name;
{
bottom_line(name);
}
#endif SLUFFED

els_in_list(list)
register Name_list *list;
{
register int count = 0;

while (list)
	{
	list = list->next;
	count++;
	}
return(count);
}


Name_list *
in_name_list(name, list)
register char *name;
register Name_list *list;
{
WORD i = 0;

#ifdef DEBUG
ldprintf("in_name_list(%s %lx)", name, list);
#endif DEBUG

while (list)
	{
	if (jstrcmp( name, list->name) == 0)
	return(list);
	list = list->next;
	}
return(NULL);
}


#ifdef NEVER
Name_list *
reverse_name_list(list)
register Name_list *list;
{
register Name_list **array, *pt, **array_pt;
register int elements, i;

elements = els_in_list(list);
array = (Name_list **)alloc( elements * sizeof(Name_list *) );
if (array)
	{
	pt = list;
	array_pt = array;
	while ( pt )
	{
	*array_pt++ = pt;
	pt = pt->next;
	}
	array_pt = array;
	list = NULL;
	i = elements;
	while (--i >= 0)
	{
	pt = *array_pt++;
	pt->next = list;
	list = pt;
	}
	mfree( array, elements * sizeof( Name_list *) );
	}
return(list);
}
#endif NEVER

Name_list *
sort_nlist(list)
register Name_list *list;
{
register Name_list **array, *pt, **array_pt;
register int elements, i;

elements = els_in_list(list);

array = (Name_list **)alloc( elements * sizeof(Name_list *) );
if (array)
	{
	pt = list;
	array_pt = array;
	while ( pt )
	{
	*array_pt++ = pt;
	pt = pt->next;
	}
	sort_narray(array, elements);
	array_pt = array;
	list = NULL;
	i = elements;
	while (--i >= 0)
	{
	pt = *array_pt++;
	pt->next = list;
	list = pt;
	}
	mfree( array, elements * sizeof( Name_list *) );
	}
return(list);
}

/*just another little bubble sort ... */
sort_narray(list, elements)
Name_list **list;
int elements;
{
int count;
WORD swapped;
register Name_list *swapper;
int i;
register Name_list **list_pt, **next_list_pt;

#ifdef DEBUG
lprintf("sort_narray(%lx %d)\n",list, elements);
#endif DEBUG

swapped = 1;
count = elements - 1;  /*since go one past*/
while (swapped)
	{
	list_pt = list;
	next_list_pt = list_pt+1;
	swapped = 0;
	for (i=0; i<count; i++)
	{
	if (jstrcmp( (*list_pt)->name, (*next_list_pt)->name) < 0 )
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
}

Name_list *
remove_name_from_list(name, list)
register char *name;
register Name_list *list;
{
register Name_list *this;
register Name_list *last;

if ( this = in_name_list(name, list) )
	{
	if (this == list)
	{
	list = list->next;
	}
	else
	{
	last = list;
	while ( last->next != this)
		last = last->next;
	last->next = this->next;
	}
	free_string(this->name);
	mfree(this, sizeof(Name_list) );
	}
return(list);
}

Item_list *
in_item_list(item, list)
register POINTER item;
register Item_list *list;
{
while (list)
	{
	if (item == list->item)
	return(list);
	list = list->next;
	}
return(NULL);
}

Item_list *
add_item(item, list)
POINTER item;
register Item_list *list;
{
register Item_list *new_list;

new_list = (Item_list *)alloc(sizeof(Item_list) );
if (new_list)
	{
	new_list->item = item;
	new_list->next = list;
	return(new_list);
	}
else
	return(list);
}


Item_list *
or_in_item(item, list)
register POINTER item;
register Item_list *list;
{
if (!in_item_list(item, list) )
	{
	list = add_item(item, list);
	}
return(list);
}


