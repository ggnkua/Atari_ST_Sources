#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <aesbind.h>
#include <vdibind.h>
#include "ps.h"

#define MAXLEN	80
#define MIN(x, y) ((x <= y) ? x : y)

extern struct document *docinfo;

/* Pathfind(path, file, sep) searches for 'file' in the path given
 * by the envionment variable named in 'env'. Sep specifies the
 * path separator. It returns a pointer to the filename if it is
 * found, and a NULL if not.
 */

char *pathfind(char *env, char *file, char *sep)
{
    FILE *fp;

    char path[2*MAXLEN];
    static char name[MAXLEN];

    char *ptr;
    char *presub();

    if ((fp = fopen(file, "r")) == NULL) {

	if ((ptr = getenv(env)) != NULL) {
	    strcpy(path, ptr);
	}
	else {
	    return NULL;
	}

	if ((ptr = presub(path, sep)) == NULL) {
	    return NULL;
	}

	do {
	    strcpy(name, ptr);

	    if (name[strlen(name)-1] != '\\' ||
		name[strlen(name)-1] != '/') strcat(name, "\\");

	    strcat(name, file);

	    if ((fp = fopen(name, "r")) != NULL) {
		fclose(fp);
		return name;
	    }

	} while ((ptr = presub(NULL, sep)) != NULL);

    }
    else {
	fclose(fp);
	return file;
    }
}

/* Presub(s, subs) searches the string s for the substring subs. Presub
 * returns a pointer to the NULL terminated substring which immediately
 * preceeds subs. If presub is called again with a NULL pointer for s, 
 * it returns a pointer to the substring between the previous subs and
 * the current subs. If subs is a null character, presub returns a pointer
 * to the portion of s between the previous subs and the end of s.
 */

char *presub(s, subs)
char *s, *subs;
{
	int sublen;
	char *mptr;
	static int count;
	static char match[MAXLEN], *ptr;

	if (s != NULL) {
		ptr = s;
		count = 0;
	}

	mptr = match + count;
	if ((sublen = strlen(subs)) == 0) {
		strcpy(mptr, ptr);
		return (mptr);
	}

	while (*ptr != '\0') {
		if (strncmp(ptr, subs, sublen) == 0) {
			match[count] = '\0';
			ptr += sublen;
			++count;
			return (mptr);
		}
		match[count] = *ptr;
		++ptr;
		++count;
		
	}

	if ((match + count) > mptr) {
		match[count] = *ptr;
		++count;
		return (mptr);

	}

	return (NULL);

}

int page_filter(char* input, char *pagestr, char *output)
{
    void pscopy();

    char *strptr1, *strptr2;
    char *presub();

    int num_list=0, num_pages, page_order, count;
    int	pagelist[40][2];

    FILE *infp, *outfp;

    struct page *pageptr1, *pageptr2;

    if ((strptr1 = pathfind("GS_LIB", input, ",")) == NULL) {
	return -1;
    }
    if ((infp = fopen(strptr1, "r")) == NULL) {
	return -1;
    }
    if ((outfp = fopen(output, "wb")) == NULL) {
	return -1;
    }

    if ((strptr1 = presub(pagestr, ",")) == NULL) {
	return -1;
    }

    do {

	if ((strptr2 = strchr(strptr1, '-')) == NULL) {
	    pagelist[num_list][1] = atoi(strptr1);
	    pagelist[num_list++][2] = atoi(strptr1);
	}
	else {
	    *strptr2 = '\0';
	    pagelist[num_list][1] = atoi(strptr1);
	    pagelist[num_list++][2] = atoi(strptr2+1);
	}

    } while ((strptr1 = presub(NULL, ",")) != NULL);

    num_pages = docinfo->numpages;
    page_order = docinfo->pageorder;

    /* Copy to the beginning of the first page into PAGEFILE. */

    pageptr1 = &docinfo->pages[0];
    pscopy(infp, outfp, 0, pageptr1->begin - 1);

    /* Copy the requested pages into PAGEFILE. */

    for (count=0; count < num_list; count++) {
	pagelist[count][2] = MIN(pagelist[count][2], num_pages);

	if (pagelist[count][1] <= pagelist[count][2]) {

	    if (page_order == ASCEND) {
		pageptr1 = &docinfo->pages[pagelist[count][1] - 1];
		pageptr2 = &docinfo->pages[pagelist[count][2] - 1];
	    }
	    else if (page_order == DESCEND) {
		pageptr2 = &docinfo->pages[num_pages - pagelist[count][1]];
		pageptr1 = &docinfo->pages[num_pages - pagelist[count][2]];
	    }
	    else {
		return -1;
	    }

	    pscopy(infp, outfp, pageptr1->begin, pageptr2->end);
	}

    }

    /* Copy from the end of the last page to EOF into PAGEFILE. */

    pageptr1 = &docinfo->pages[num_pages - 1];
    pscopy(infp, outfp, pageptr1->end + 1, docinfo->endtrailer);

    fclose(infp);
    fclose(outfp);
}


/* Routine itoa(s, num) converts an integer, num, to an ascii string 
 * representation of the integer, pointed to by s. The integer 100 is 
 *  converted to the string "100", etc.
 */

char *itoa(s, number)
int number;
char *s;
{

/* Local variables:
 *	i:		loop counter,
 *	j:		number of loops needed to transpose the string in s,
 *	body:		integer part of num/10,
 *	remain:		remainder of num/10,
 *	sign:		sign of the integer,
 *	count:		number of times num is divisible by 10,
 *	temp:		temporary character storage.
 */

	int i, j, num, body, remain, sign, count;
	char temp;

	count = 0;
	num = number;
	sign = 1;

	if (num == 0) {
		s[count] = '0';
		++count;
	} else {

		if (num < 0) {
			sign = -1;
			num = -num;
		}

		while (num > 0) {		/* Divide by 10, convert */
			body = (num/10);	/* remainder to ascii    */
			remain = num - body*10;
			s[count] = remain + '0';
			num = body;
			++count;
		}

		if (sign < 0) {
			s[count] = '-';
			++count;
		}

		/* Ascii representation is transposed in s, so put it in 
		 * the right order. */

		j = count/2;	

		for (i = 0; i < j; ++i) {
			temp = s[i];
			s[i] = s[count-(i+1)];
			s[count-(i+1)] = temp;
		}

	}

	s[count] = '\0';
	return(s);

}
