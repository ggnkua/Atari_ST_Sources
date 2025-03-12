/* This program read a character file
 * and inserts all words, separated by spaces
 * into a skip list;
 * Then all words are printed on a new line
 *
 * Klaus Elsbernd
 * TURBOC
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Information is a string: */
#define Information char

#include <skiplist.h>

/* define german characters: */
#define ae (unsigned char)'\204'
#define Ae (unsigned char)'\216'
#define oe (unsigned char)'\224'
#define Oe (unsigned char)'\231'
#define ue (unsigned char)'\201'
#define Ue (unsigned char)'\232'
#define ss (unsigned char)'\236'

void    sortcharupcase(unsigned char * pointer);
int     eqlchupper(unsigned char ch1,
                   unsigned char ch2);
int     cmp_str(char *x, char *y);

void    /* -- prepares character for comparing */
sortcharupcase (ptr)
unsigned char *ptr;
{
   unsigned char c;

   if ((c = *ptr) >= 'a') {
       if (c <= 'z')
           *ptr -= 'a'-'A';
         else
           *ptr = (c == ae || c == Ae)
             ? 'A' :
               (c == oe || c == Oe) ? 'O' :
               (c == ue || c == Ue) ? 'U' :
               (c == ss) ? 'S' : *ptr;
    }
} /* sortcharupcase */

int  /* compares 2 characters, if they are eql */
eqlchupper (ch1,ch2)
unsigned char ch1, ch2;
{
    sortcharupcase(&ch1);
    sortcharupcase(&ch2);
    return(ch1 - ch2);
} /* eqlchupper */

int
cmp_str (x, y) /* ------- compares two strings */
register char *x, *y;
{
    /* compare strings ignoring
     * upper/lower-case differences */
    while (*x && *y &&
           (!(*x - *y) || !eqlchupper(*x,*y))) {
      x++; y++;}
  return(eqlchupper(*x,*y));
} /* cmp_str */

void
free_str (x)  /* --------- free an information */
char *x;
{
  return;
} /* free_str */

int
main (argc,argv)
int argc;
char *argv[];
{
  skip_list l;
  FILE *file;
  long size;
  char *buffer, *str;
  register node p, q;
  int i, k;
  long no;

  if ((argc != 2)           /* argument given? */
      || (file = fopen(argv[1],"r")) == NULL) {
      printf(
         "parameter <existing file> required\n");
      return(-1);
  }

  init_skiplists();    /* initialize skip list */
  l = new_skiplist(cmp_str,skip_free_default);

  /* determine the length of the file */
  if (fseek(file,0l,SEEK_END) != 0) {
      printf("error at positioning at end\n");
      return(-1);
  }
  size = ftell(file);      /* size of the file */
  fseek(file,0l,SEEK_SET);

  /* allocate enough buffer for the file */
  str = buffer =(char *)malloc((size_t)(size+1));

  /* read all lines, and separate them by ' ' */
  while (fgets(str,(int)size,file) != NULL) {
    str += strlen(str)-1;
    *str++ = ' ';
  }
  fclose(file);

  /* tokenize the input file and put the token
   * in the tree */
  no = 0;   /* number of insert operations */
  for (str = strtok(buffer," ");
       str != NULL;
       str = strtok(NULL," ")) {
    /* skip most of non literal characters */
    for (; *str != '\0'
           && ((unsigned)(*str) < 'A');
         str++);
    for (i = (int)strlen(str)-1;
         i > 0
         && ((unsigned)(*(str+i)) < 'A');
         i--) 
      *(str+i) = 0;
    no++;
    skip_insert(l,str,FALSE);
  }

  /* provide same statistic information */
  for (k = l->level; k >= 0; k--) {
    p = l->header;
    i = 0;
    while (q = p->forward[k], q != NULL) {
      p = q;
      i++;
    }
    printf("No of nodes in level %d: %d\n",k,i);
  }
  if (i != l->no)
      printf("illegal number of nodes\n");
  printf("Number of inserted strings: %ld\n",no);
  
  /* delete all strings
     beginning with an 'm' or 'M' */
  if ((p = skip_search(l,"M")) == NULL)
      p = skip_next(l);
  for (; p != NULL
         && cmp_str(p->inf,"N") < 0;
       p = q) {
    q = skip_next(l);
    skip_delete(l,p->inf);
  }

  /* print the contents of the skip list
   * in sorted order */
  p = l->header->forward[0];  /* first element */
  while (p != NULL) {
    printf("%s\n",p->inf);
    p = p->forward[0];
  }
  free_skiplist(l);                 /* obvious */
  return(0);
} /* main */

