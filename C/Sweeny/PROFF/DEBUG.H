/*
#define DEBUG
#define PROFILE
*/

#ifdef PROFILE
#define dprintf(str)	printf((str));
#else
#define dprintf(str)
#endif

