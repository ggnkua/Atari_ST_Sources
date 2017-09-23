#ifndef __REGISTER
#define __REGISTER

#ifndef __AES__
#include <xaes.h>
#endif

#ifndef __PROTECT
#include "protect.h"
#endif

typedef struct
{
  char magic[10] ;
  char user[20] ;
  long crypted_key ;
  long second_key ;
}
IDENTIFICATION ;

extern IDENTIFICATION ident ;


int check_user(void) ;
void crypte_ident(OBJECT *adr_baratin) ;

extern char IsRegistered ;


#endif