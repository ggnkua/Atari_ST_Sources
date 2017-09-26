/* ASSERT macro */

#ifndef NDEBUG
#define ASSERT(expr) {if(!(expr)) printf("assertion failed: expr\n");}
#else
#define ASSERT(expr)	/**/
#endif 
