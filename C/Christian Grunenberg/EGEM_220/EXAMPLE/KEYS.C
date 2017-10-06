
#include <e_gem.h>
#include <string.h>
#include <stdio.h>

/* Definition der Tasten fÅr das Fensterscrolling */

MITEM scroll_keys[] = 
{{FAIL,key(CTRLLEFT,0),K_CTRL,PAGE_LEFT,FAIL},{FAIL,key(CTRLRIGHT,0),K_CTRL,PAGE_RIGHT,FAIL},
 {FAIL,key(SCANLEFT,0),0,LINE_LEFT,FAIL},{FAIL,key(SCANLEFT,0),K_SHIFT,LINE_START,FAIL},
 {FAIL,key(SCANRIGHT,0),0,LINE_RIGHT,FAIL},{FAIL,key(SCANRIGHT,0),K_SHIFT,LINE_END,FAIL},
#ifndef FONTPAL
 {FAIL,key(SCANUP,0),0,LINE_UP,FAIL},{FAIL,key(SCANUP,0),K_SHIFT,PAGE_UP,FAIL},
 {FAIL,key(SCANDOWN,0),0,LINE_DOWN,FAIL},{FAIL,key(SCANDOWN,0),K_SHIFT,PAGE_DOWN,FAIL},
 {FAIL,key(SCANHOME,0),0,WIN_START,FAIL},{FAIL,key(SCANHOME,0),K_SHIFT,WIN_END,FAIL}
#endif
};

#ifdef FONTPAL
#define SCROLL_KEYS	6
#else
#define SCROLL_KEYS	12
#endif
