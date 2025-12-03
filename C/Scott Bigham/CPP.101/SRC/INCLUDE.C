
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "global.h"

unsigned long include_level = 0;

/*
   find_include_file() -- look for the include file |fnam| in the list of
   include paths.  If |relative==1|, also check the current directory.  Note:
   |fnam| must be a pointer to malloc()'ed space, which is freed by the
   function.
*/
static char *find_include_file(fnam, relative)
  char *fnam;
  int relative;
{
  char **I = I_list, *buf;
  static size_t buf_len = 20;
  int len;
  register char *s, *t;

  if (!relative)
    I++;
  buf = mallok(buf_len);
  for (; *I; I++) {
    len = strlen(*I) + strlen(fnam) + 2;
    if (len > buf_len) {
      buf_len = len;
      buf = reallok(buf, buf_len);
    }
    s = buf;
    t = *I;
    while (*s++ = *t++) ;
    s[-1] = PATH_SEP;
    t = fnam;
    while (*s++ = *t++) ;
    if (access(buf, R_OK) == 0)
      break;
  }
  free(fnam);
  return (I ? reallok(buf, len) : NULL);
}

/* do_include() -- handle an #include directive */
void do_include()
{
  char *u;
  TokenP T;

  change_mode(INCLUDE_LINE, 0);
  _tokenize_line();
  T = exp_token();
  change_mode(0, INCLUDE_LINE);
  if (T->type != INC_NAM && T->type != STR_CON)
    fatal("argument %s to #include not a valid filespec", T->txt);
  u = copy_filename(T->txt + 1, strlen(T->txt) - 2);
  u = find_include_file(u, (T->type == STR_CON));
  if (!u)
    fatal("cannot find include file %s", T->txt);
  free_token(T);
  T = exp_token();
  if (T->type != EOL)
    warning("garbage after #include");
  free_token(T);
  include_level++;
  process_file(u);
  free(u);
  include_level--;
  sync_line(2);
}
