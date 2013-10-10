#ifndef __PROTECT
#define __PROTECT

/* Les fonctions sont dans les fichiers     */
/* PROTECT.S, POKE0.S, STFAULT.S et RESET.S */
/* Key =                           %00000SSSS00KKKKKKKKKKKKKKKKKKKKK */
#define KEY_MIN     0x00021000L /* %00000000000000100001000000000000 */
#define KEY_MAX     0x00100000L /* %00000000000100000000000000000000 */
#define SKEY_MASK   0x0FL
#define SKEY_LSHIFT 26

void poke0(void) ;
void stack_fault(void) ;
void reset(void) ;
void sfault(void) ;
int  chk_code(void) ;

long KeyEncrypt(long key) ;
long KeyDecrypt(long key) ;
int CountNbBits(long x, char value) ;
int IsSKeyOK(long key) ;
long s_key(long key) ;

#endif
