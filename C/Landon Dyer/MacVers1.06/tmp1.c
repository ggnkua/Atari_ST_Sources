#include "as.h"
#include "sect.h"


D_byte(b)
     register VALUE b;
{
  *chptr++ = (char)b;
  ++sloc;
  ++chsize;
}


D_word(w)
     register VALUE w;
{
  *chptr++ = (char)(w>>8);
  *chptr++ = (char)w;
  sloc += 2;
  chsize += 2;
}


D_long(lw)
     register VALUE lw;
{
  *chptr++ = (char)(lw>>24);
  *chptr++ = (char)(lw>>16);
  *chptr++ = (char)(lw>>8);
  *chptr++ = (char)lw;
  sloc += 4;
  chsize += 4;
}
