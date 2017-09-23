#ifndef __FBUYME
#define __FBUYME

#ifndef __REGISTER
#include "register.h"
#endif

void buy_me(void) ;

#define shareware_reminder(x)\
{\
  static char another_chance = 0 ;\
  char        modulo ;\
\
  modulo = x % 10 ;\
  if ( !IsRegistered && ( ( ++another_chance % modulo ) == 0 ) ) buy_me() ;\
}\


#endif
