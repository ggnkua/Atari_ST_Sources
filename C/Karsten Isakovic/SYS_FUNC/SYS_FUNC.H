/* -=-=-=-=-=-=-=-=-=-  SysMon  -=-=-=-=-=-=-=-=-=-=-=-

    Macro definitions for the SysMon debugging functions

     sys_func.h      (c) Karsten Isakovic, Berlin 04.94

   -=-=-=-=-=-=-  (ki@cs.tu-berlin.de)  -=-=-=-=-=-=-=- */

#ifndef SYS_FUNC_H
#define SYS_FUNC_H

#ifdef SYS_DEBUG

#define SYS_BREAK()                        gemdos(4200)
#define SYS_PRINTF1(str,a)                 gemdos(4201,str,a)
#define SYS_PRINTF2(str,a,b)               gemdos(4201,str,a,b)
#define SYS_PRINTF3(str,a,b,c)             gemdos(4201,str,a,b,c)
#define SYS_PRINTF4(str,a,b,c,d)           gemdos(4201,str,a,b,c,d)
#define SYS_PRINTF5(str,a,b,c,d,e)         gemdos(4201,str,a,b,c,d,e)
#define SYS_PRINTF6(str,a,b,c,d,e,f)       gemdos(4201,str,a,b,c,d,e,f)
#define SYS_PRINTF7(str,a,b,c,d,e,f,g)     gemdos(4201,str,a,b,c,d,e,f,g)
#define SYS_PRINTF8(str,a,b,c,d,e,f,g,h)   gemdos(4201,str,a,b,c,d,e,f,g,h)
#define SYS_PRINTF9(str,a,b,c,d,e,f,g,h,i) gemdos(4201,str,a,b,c,d,e,f,g,h,i)

#else

#define SYS_BREAK()
#define SYS_PRINTF1(str,a)
#define SYS_PRINTF2(str,a,b)
#define SYS_PRINTF3(str,a,b,c)
#define SYS_PRINTF4(str,a,b,c,d)
#define SYS_PRINTF5(str,a,b,c,d,e)
#define SYS_PRINTF6(str,a,b,c,d,e,f)
#define SYS_PRINTF7(str,a,b,c,d,e,f,g)
#define SYS_PRINTF8(str,a,b,c,d,e,f,g,h)
#define SYS_PRINTF9(str,a,b,c,d,e,f,g,h,i)

#endif

#endif /* SYS_FUNC_H */