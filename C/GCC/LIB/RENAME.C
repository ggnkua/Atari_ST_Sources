
#include "file.h"
#include "osbind.h"

#ifdef DEBUG
extern int stderr;
#endif

int rename(old, new)
char * old, * new;
{
  int result;
#ifdef DEBUG
  fprintf(stderr, "  rename('%s', '%s')", old, new);
#endif
  Fdelete(new);			/* necessary? */
  result = Frename(0, old, new);
#ifdef DEBUG
  fprintf(stderr, " -> %d\n");
#endif
  if (result > 0) result = 0;	/* what does this mean??? */
  return (result);
}
