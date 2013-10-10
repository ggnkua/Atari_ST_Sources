/* ubasic.c - Some basic routines, UNIX version. */

#include <ctype.h>
#include <stdio.h>
#include <string.h>

#include "ubasic.h"

extern void *malloc P((size_t size),());
extern void free P((void *block),());

void *(*basic_alloc) P((size_t size),()) = malloc;
void (*basic_free) P((void *block),()) = free;

free_fnames(fnames,count,freearr)
char **fnames; int count; int freearr;
{
	int i;

	if (fnames == NULL)
		return;
	for (i=0; i<count; i++)
		(*basic_free)(fnames[i]);
	if (freearr)
		(*basic_free)(fnames);
}

static int
extract_long(str,l)
unsigned char *str; long *l;
{
	int negative;
	long oldval;

	(*l) = 0;
	negative = (*str=='-');
	if (*str=='+' || *str=='-')
		str++;
	do {
		if (!isdigit(*str))
			return FALSE;
		oldval = (*l);
		(*l) = (*l)*10 + (*str) - '0';
		if ((*l) < oldval)
			return FALSE;
		str++;
	} while (*str != '\0');
	if (negative)
		(*l) = -(*l);
	return TRUE;
}

process_command_line(pargc,pargv,opts)
int *pargc; char **(*pargv); OPTION *opts;
{
	int argno,newargno;
	OPTION *optr;
	char **newargv;
	long larg;

	if ((*pargc) <= 0) {
		(*pargc) = 0;
		(*pargv) = NULL;
		return;
	}
	newargno = 1;
	for (argno=1; argno<(*pargc); argno++) {
		if (opts != NULL) {
			for (optr=opts; optr->op_name!=NULL; optr++)
				if (strcmp((*pargv)[argno],optr->op_name) == 0)
					break;
		}
		if (opts==NULL || optr->op_name==NULL)
			newargno++;
		else if (optr->op_type==STRARGOPT || optr->op_type==INTARGOPT
			|| optr->op_type==LONGARGOPT) {
			if (argno == (*pargc)-1)
				uhalt(("argument required for %s option\n",optr->op_name));
			else
				argno++;
		}
	}
	if ((newargv=(*basic_alloc)((size_t)newargno*sizeof(newargv[0])))==NULL
		|| (newargv[0]=(*basic_alloc)(strlen((*pargv)[0])+1))==NULL)
		uhalt(("out of memory while processing command line\n"));
	strcpy(newargv[0],(*pargv)[0]);
	argno = newargno = 1;
	for (argno=1; argno<(*pargc); argno++) {
		if (opts != NULL) {
			for (optr=opts; optr->op_name!=NULL; optr++)
				if (strcmp((*pargv)[argno],optr->op_name) == 0)
					break;
		}
		if (opts==NULL || optr->op_name==NULL) {
			newargv[newargno] = (*basic_alloc)(strlen((*pargv)[argno])+1);
			if (newargv[newargno] == NULL)
				uhalt(("out of memory while copying file names\n"));
			strcpy(newargv[newargno],(*pargv)[argno]);
			newargno++;
		} else {
			switch (optr->op_type) {
			case SWITCHONOPT:
				(*(int *)optr->op_pval) = TRUE;
				break;
			case SWITCHOFFOPT:
				(*(int *)optr->op_pval) = FALSE;
				break;
			case STRARGOPT: case INTARGOPT: case LONGARGOPT:
				argno++;
				if (optr->op_type == STRARGOPT) {
					(*((char **)optr->op_pval)) =
						(*basic_alloc)(strlen((*pargv)[argno])+1);
					if ((*((char **)optr->op_pval)) == NULL)
						uhalt(("out of memory while copying %s option",
							optr->op_name));
					strcpy((*((char **)optr->op_pval)),(*pargv)[argno]);
				} else if (!extract_long(
						(unsigned char *)((*pargv)[argno]),&larg))
					uhalt(("invalid integer for %s option\n",optr->op_name));
				else if (optr->op_type == LONGARGOPT)
					(*(long *)optr->op_pval) = larg;
				else if (larg != (long)(int)larg)
					uhalt(("integer overflow in %s option\n",optr->op_name));
				else
					(*(int *)optr->op_pval) = (int)larg;
				break;
			default:
				uhalt(("error: unknown option type %d\n",(int)optr->op_type));
				break;
			}
		}
	}
	(*pargc) = newargno;
	(*pargv) = newargv;
}

long
divup(n,m)
long n; long m;
{
	return (n+m-1)/m;
}

long
multup(n,m)
long n; long m;
{
	return m*divup(n,m);
}
