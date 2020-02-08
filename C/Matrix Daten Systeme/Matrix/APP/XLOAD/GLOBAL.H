# ifndef __XGLOBAL__

# define __XGLOBAL__

/* general types from windows.h */

typedef int                 BOOL;
#define FALSE               0
#define TRUE                1

typedef unsigned char       BYTE;
typedef unsigned short      WORD;
typedef unsigned long       DWORD;

typedef unsigned int        UINT;

# ifdef LONG
# undef LONG
# endif

#ifdef STRICT
typedef signed long         LONG;
#else
#define LONG long
#endif

# define local static

/****** Common pointer types ************************************************/



#define FAR                 _far
#define NEAR                _near

#ifndef NULL
#define NULL                0
#endif

/* 

typedef char NEAR*          PSTR ;
typedef char NEAR*          NPSTR ;

typedef void FAR*			LPVOID ;
typedef char FAR*           LPSTR ;
typedef const char FAR*     LPCSTR ;

# ifndef CALLBACK
#define CALLBACK            _far _pascal

typedef void (CALLBACK*     FARPROC)(void);

typedef const void NEAR*        HANDLE;
#define DECLARE_HANDLE(name)    struct name##__ { int unused; }; \
                                typedef const struct name##__ NEAR* name
DECLARE_HANDLE(HINSTANCE);
DECLARE_HANDLE(HWND);
# endif
*/

/*........... lib extensions ...................................*/

/*

extern LPSTR DuplicateString ( LPSTR s ) ;
extern unsigned long strtoc ( const char *s ) ;
extern LPSTR ConvertString ( LPSTR s ) ;

*/

# endif __XGLOBAL__

