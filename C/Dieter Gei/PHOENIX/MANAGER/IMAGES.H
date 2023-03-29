/* desktop buttons */

#include "newn1.h"
#include "newn4.h"
#include "newd4.h"

#include "openn1.h"
#include "openn4.h"

#include "saven1.h"
#include "saven4.h"

#include "printn1.h"
#include "printn4.h"

#include "execn1.h"
#include "execn4.h"

#include "qben1.h"
#include "qben4.h"

#include "repdefn1.h"
#include "repdefn4.h"

#include "caldefn1.h"
#include "caldefn4.h"

#include "batdefn1.h"
#include "batdefn4.h"

#include "tablen1.h"
#include "tablen4.h"

#include "maskn1.h"
#include "maskn4.h"

/* list buttons */

#include "ascn1.h"
#include "ascn4.h"
#include "ascs4.h"

#include "descn1.h"
#include "descn4.h"
#include "descs4.h"

#include "searchn1.h"
#include "searchn4.h"
#include "searchd4.h"

/* qbe buttons */

#include "sortn1.h"
#include "sortn4.h"

#include "compn1.h"
#include "compn4.h"

/* report buttons */

#include "daten1.h"
#include "daten4.h"

#include "timen1.h"
#include "timen4.h"

#include "tstampn1.h"
#include "tstampn4.h"

#include "countn1.h"
#include "countn4.h"

#include "branchn1.h"
#include "branchn4.h"

#include "returnn1.h"
#include "returnn4.h"

#include "addn1.h"
#include "addn4.h"

/* account buttons */

#include "arrown1.h"
#include "arrown4.h"
#include "arrowc4.h"

#include "textn1.h"
#include "textn4.h"
#include "textc4.h"

#include "fieldn1.h"
#include "fieldn4.h"
#include "fieldc4.h"

#include "linen1.h"
#include "linen4.h"
#include "linec4.h"

#include "boxn1.h"
#include "boxn4.h"
#include "boxc4.h"

#include "rbuttn1.h"
#include "rbuttn4.h"
#include "rbuttc4.h"

#include "checkn1.h"
#include "checkn4.h"
#include "checkc4.h"

#include "groupn1.h"
#include "groupn4.h"
#include "groupc4.h"

#include "grafn1.h"
#include "grafn4.h"
#include "grafc4.h"

#include "subn1.h"
#include "subn4.h"
#include "subc4.h"

#include "ffn1.h"
#include "ffn4.h"
#include "ffc4.h"

#include "lockn1.h"
#include "lockn4.h"
#include "lockc4.h"

#include "bwn1.h"
#include "bwn4.h"
#include "bwc4.h"

/* page format buttons */

#include "basen1.h"
#include "basen4.h"

#include "pagen1.h"
#include "pagen4.h"

/* mask buttons */

#include "firstn1.h"
#include "firstn4.h"
#include "firstd4.h"

#include "prevn1.h"
#include "prevn4.h"
#include "prevd4.h"

#include "nextn1.h"
#include "nextn4.h"
#include "nextd4.h"

#include "lastn1.h"
#include "lastn4.h"
#include "lastd4.h"

#include "insn1.h"
#include "insn4.h"
#include "insd4.h"

#include "updn1.h"
#include "updn4.h"
#include "updd4.h"

#include "calcn1.h"
#include "calcn4.h"
#include "calcd4.h"

#include "deleten1.h"
#include "deleten4.h"
#include "deleted4.h"

LOCAL BMBUTTON bmbutton [] =
{
  {"new",    0, 0, {newn1,    NULL}, {NULL, NULL}, {NULL, NULL}, {newn4,    NULL}, {NULL,    NULL}, {newd4,    NULL}},
  {"open",   0, 0, {openn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {openn4,   NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"save",   0, 0, {saven1,   NULL}, {NULL, NULL}, {NULL, NULL}, {saven4,   NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"print",  0, 0, {printn1,  NULL}, {NULL, NULL}, {NULL, NULL}, {printn4,  NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"exec",   0, 0, {execn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {execn4,   NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"qbe",    0, 0, {qben1,    NULL}, {NULL, NULL}, {NULL, NULL}, {qben4,    NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"repdef", 0, 0, {repdefn1, NULL}, {NULL, NULL}, {NULL, NULL}, {repdefn4, NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"caldef", 0, 0, {caldefn1, NULL}, {NULL, NULL}, {NULL, NULL}, {caldefn4, NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"batdef", 0, 0, {batdefn1, NULL}, {NULL, NULL}, {NULL, NULL}, {batdefn4, NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"table",  0, 0, {tablen1,  NULL}, {NULL, NULL}, {NULL, NULL}, {tablen4,  NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"mask",   0, 0, {maskn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {maskn4,   NULL}, {NULL,    NULL}, {NULL,     NULL}},

  {"asc",    0, 0, {ascn1,    NULL}, {NULL, NULL}, {NULL, NULL}, {ascn4,    NULL}, {ascs4,   NULL}, {NULL,     NULL}},
  {"desc",   0, 0, {descn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {descn4,   NULL}, {descs4,  NULL}, {NULL,     NULL}},
  {"search", 0, 0, {searchn1, NULL}, {NULL, NULL}, {NULL, NULL}, {searchn4, NULL}, {NULL,    NULL}, {searchd4, NULL}},

  {"date",   0, 0, {daten1,   NULL}, {NULL, NULL}, {NULL, NULL}, {daten4,   NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"time",   0, 0, {timen1,   NULL}, {NULL, NULL}, {NULL, NULL}, {timen4,   NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"tstamp", 0, 0, {tstampn1, NULL}, {NULL, NULL}, {NULL, NULL}, {tstampn4, NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"count",  0, 0, {countn1,  NULL}, {NULL, NULL}, {NULL, NULL}, {countn4,  NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"branch", 0, 0, {branchn1, NULL}, {NULL, NULL}, {NULL, NULL}, {branchn4, NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"return", 0, 0, {returnn1, NULL}, {NULL, NULL}, {NULL, NULL}, {returnn4, NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"add",    0, 0, {addn1,    NULL}, {NULL, NULL}, {NULL, NULL}, {addn4,    NULL}, {NULL,    NULL}, {NULL,     NULL}},

  {"arrow",  0, 0, {arrown1,  NULL}, {NULL, NULL}, {NULL, NULL}, {arrown4,  NULL}, {arrowc4, NULL}, {NULL,     NULL}},
  {"text",   0, 0, {textn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {textn4,   NULL}, {textc4,  NULL}, {NULL,     NULL}},
  {"field",  0, 0, {fieldn1,  NULL}, {NULL, NULL}, {NULL, NULL}, {fieldn4,  NULL}, {fieldc4, NULL}, {NULL,     NULL}},
  {"line",   0, 0, {linen1,   NULL}, {NULL, NULL}, {NULL, NULL}, {linen4,   NULL}, {linec4,  NULL}, {NULL,     NULL}},
  {"box",    0, 0, {boxn1,    NULL}, {NULL, NULL}, {NULL, NULL}, {boxn4,    NULL}, {boxc4,   NULL}, {NULL,     NULL}},
  {"rbutt",  0, 0, {rbuttn1,  NULL}, {NULL, NULL}, {NULL, NULL}, {rbuttn4,  NULL}, {rbuttc4, NULL}, {NULL,     NULL}},
  {"check",  0, 0, {checkn1,  NULL}, {NULL, NULL}, {NULL, NULL}, {checkn4,  NULL}, {checkc4, NULL}, {NULL,     NULL}},
  {"group",  0, 0, {groupn1,  NULL}, {NULL, NULL}, {NULL, NULL}, {groupn4,  NULL}, {groupc4, NULL}, {NULL,     NULL}},
  {"graf",   0, 0, {grafn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {grafn4,   NULL}, {grafc4,  NULL}, {NULL,     NULL}},
  {"sub",    0, 0, {subn1,    NULL}, {NULL, NULL}, {NULL, NULL}, {subn4,    NULL}, {subc4,   NULL}, {NULL,     NULL}},
  {"ff",     0, 0, {ffn1,     NULL}, {NULL, NULL}, {NULL, NULL}, {ffn4,     NULL}, {ffc4,    NULL}, {NULL,     NULL}},
  {"lock",   0, 0, {lockn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {lockn4,   NULL}, {lockc4,  NULL}, {NULL,     NULL}},

  {"bw",     0, 0, {bwn1,     NULL}, {NULL, NULL}, {NULL, NULL}, {bwn4,     NULL}, {bwc4,    NULL}, {NULL,     NULL}},

  {"sort",   0, 0, {sortn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {sortn4,   NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"comp",   0, 0, {compn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {compn4,   NULL}, {NULL,    NULL}, {NULL,     NULL}},

  {"base",   0, 0, {basen1,   NULL}, {NULL, NULL}, {NULL, NULL}, {basen4,   NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"sort",   0, 0, {sortn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {sortn4,   NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"page",   0, 0, {pagen1,   NULL}, {NULL, NULL}, {NULL, NULL}, {pagen4,   NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"date",   0, 0, {daten1,   NULL}, {NULL, NULL}, {NULL, NULL}, {daten4,   NULL}, {NULL,    NULL}, {NULL,     NULL}},
  {"time",   0, 0, {timen1,   NULL}, {NULL, NULL}, {NULL, NULL}, {timen4,   NULL}, {NULL,    NULL}, {NULL,     NULL}},

  {"first",  0, 0, {firstn1,  NULL}, {NULL, NULL}, {NULL, NULL}, {firstn4,  NULL}, {NULL,    NULL}, {firstd4,  NULL}},
  {"prev",   0, 0, {prevn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {prevn4,   NULL}, {NULL,    NULL}, {prevd4,   NULL}},
  {"next",   0, 0, {nextn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {nextn4,   NULL}, {NULL,    NULL}, {nextd4,   NULL}},
  {"last",   0, 0, {lastn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {lastn4,   NULL}, {NULL,    NULL}, {lastd4,   NULL}},
  {"ins",    0, 0, {insn1,    NULL}, {NULL, NULL}, {NULL, NULL}, {insn4,    NULL}, {NULL,    NULL}, {insd4,    NULL}},
  {"upd",    0, 0, {updn1,    NULL}, {NULL, NULL}, {NULL, NULL}, {updn4,    NULL}, {NULL,    NULL}, {updd4,    NULL}},
  {"search", 0, 0, {searchn1, NULL}, {NULL, NULL}, {NULL, NULL}, {searchn4, NULL}, {NULL,    NULL}, {searchd4, NULL}},
  {"calc",   0, 0, {calcn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {calcn4,   NULL}, {NULL,    NULL}, {calcd4,   NULL}},
  {"trash",  0, 0, {deleten1, NULL}, {NULL, NULL}, {NULL, NULL}, {deleten4, NULL}, {NULL,    NULL}, {deleted4, NULL}},
};
