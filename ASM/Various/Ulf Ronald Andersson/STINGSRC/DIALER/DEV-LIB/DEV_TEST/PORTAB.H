/*****************************************************************************/
/*                                                                           */
/* PORTAB.H                                                                  */
/*                                                                           */
/*****************************************************************************/

/*****************************************************************************/
/* ENVIRONMENT                                                               */
/*****************************************************************************/

#ifndef __PORTAB__
#define __PORTAB__

/*****************************************************************************/
/* STANDARD TYPE DEFINITIONS                                                 */
/*****************************************************************************/

#define BYTE    char                          /* Signed byte                 */
#define CHAR    char                          /* Signed byte                 */
#define UBYTE   unsigned char                 /* Unsigned byte               */
#define UCHAR   unsigned char                 /* Unsigned byte               */

#define WORD    int                           /* Signed word (16 bits)       */
#define SHORT   int                           /* Signed word (16 bits)       */
#define UWORD   unsigned int                  /* Unsigned word               */
#define USHORT  unsigned int                  /* Signed word (16 bits)       */
#define LONG    long                          /* Signed long (32 bits)       */
#define ULONG   unsigned long                 /* Unsigned long               */

#define BOOLEAN WORD                          /* 2 valued (true/false)       */
#define BOOL    BOOLEAN                       /* 2 valued (true/false)       */

#define FLOAT   float                         /* Single precision float      */
#define DOUBLE  double                        /* Double precision float      */

#define INT     int                           /* A machine dependent int     */
#define UINT    unsigned int                  /* A machine dependent uint    */

#define REG     register                      /* Register variable           */
#define AUTO    auto                          /* Local to function           */
#define EXTERN  extern                        /* External variable           */
#define LOCAL   static                        /* Local to module             */
#define MLOCAL  LOCAL                         /* Local to module             */

/*****************************************************************************/
/* COMPILER DEPENDENT DEFINITIONS                                            */
/*****************************************************************************/

#define CONST    const
#define VOLATILE volatile
#define CDECL    cdecl
#define PASCAL   pascal

#define SIZE_T   size_t

#ifndef VOID
#define VOID     void
#endif

/*****************************************************************************/
/* OPERATING SYSTEM DEPENDENT DEFINITIONS                                    */
/*****************************************************************************/

/*****************************************************************************/
/* MISCELLANEOUS DEFINITIONS                                                 */
/*****************************************************************************/

#ifndef FALSE
#define FALSE   (BOOLEAN)0                    /* Function FALSE value        */
#define TRUE    (BOOLEAN)1                    /* Function TRUE  value        */
#endif

#define FAILURE (-1)                          /* Function failure return val */
#define SUCCESS 0                             /* Function success return val */
#define FOREVER for(;;)                       /* Infinite loop declaration   */
#define EOS     '\0'                          /* End of string value         */

#ifndef NULL
#define NULL    0L                            /* Null long value             */
#endif

#ifndef EOF
#define EOF     (-1)                          /* EOF value                   */
#endif

#endif /* __PORTAB__ */

