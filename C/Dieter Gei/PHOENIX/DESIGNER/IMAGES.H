#include "arrown1.h"
#include "arrown4.h"
#include "arrowc4.h"

#include "boxn1.h"
#include "boxn4.h"
#include "boxc4.h"

#include "buttonn1.h"
#include "buttonn4.h"
#include "buttonc4.h"

#include "fieldn1.h"
#include "fieldn4.h"

#include "grafn1.h"
#include "grafn4.h"
#include "grafc4.h"

#include "linen1.h"
#include "linen4.h"
#include "linec4.h"

#include "linkn1.h"
#include "linkn4.h"
#include "linkc4.h"

#include "maskn1.h"
#include "maskn4.h"

#include "mltkeyn1.h"
#include "mltkeyn4.h"

#include "rboxn1.h"
#include "rboxn4.h"
#include "rboxc4.h"

#include "tablen1.h"
#include "tablen4.h"

#include "textn1.h"
#include "textn4.h"
#include "textc4.h"

LOCAL BMBUTTON bmbutton [] =
{
  {"arrow",    0, 0, {arrown1,  NULL}, {NULL, NULL}, {NULL, NULL}, {arrown4,  NULL}, {arrowc4,  NULL}, {NULL,  NULL}},
  {"box",      0, 0, {boxn1,    NULL}, {NULL, NULL}, {NULL, NULL}, {boxn4,    NULL}, {boxc4,    NULL}, {NULL,  NULL}},
  {"button",   0, 0, {buttonn1, NULL}, {NULL, NULL}, {NULL, NULL}, {buttonn4, NULL}, {buttonc4, NULL}, {NULL,  NULL}},
  {"field",    0, 0, {fieldn1,  NULL}, {NULL, NULL}, {NULL, NULL}, {fieldn4,  NULL}, {NULL,     NULL}, {NULL,  NULL}},
  {"graf",     0, 0, {grafn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {grafn4,   NULL}, {grafc4,   NULL}, {NULL,  NULL}},
  {"line",     0, 0, {linen1,   NULL}, {NULL, NULL}, {NULL, NULL}, {linen4,   NULL}, {linec4,   NULL}, {NULL,  NULL}},
  {"link",     0, 0, {linkn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {linkn4,   NULL}, {linkc4,   NULL}, {NULL,  NULL}},
  {"mask",     0, 0, {maskn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {maskn4,   NULL}, {NULL,     NULL}, {NULL,  NULL}},
  {"mltkey",   0, 0, {mltkeyn1, NULL}, {NULL, NULL}, {NULL, NULL}, {mltkeyn4, NULL}, {NULL,     NULL}, {NULL,  NULL}},
  {"rbox",     0, 0, {rboxn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {rboxn4,   NULL}, {rboxc4,   NULL}, {NULL,  NULL}},
  {"table",    0, 0, {tablen1,  NULL}, {NULL, NULL}, {NULL, NULL}, {tablen4,  NULL}, {NULL,     NULL}, {NULL,  NULL}},
  {"text",     0, 0, {textn1,   NULL}, {NULL, NULL}, {NULL, NULL}, {textn4,   NULL}, {textc4,  NULL},  {NULL,  NULL}},
};
