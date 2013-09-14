/*
 * client.c
 *
 */

#include <osbind.h>
#include "fsm.h"
#include "afsm.h"

#define MyErrorWrite        101L /* "Error writing file %s" */
#define MyErrorClose        102L /* "Error closing file %s" */
#define MyErrorSizes        103L /* "Sizes selected are unreasonable" */
#define MyErrorWidth        104L /* "Width selected is to large" */

#define NULL 0L

extern char *lcalloc();

/*---------------------------------------------------------------------------*/
bool MyAlloc(bytes, memKind, ptrRefP)
long                          bytes;
long                          memKind;
register fsm_PointerRef_t   *ptrRefP;
{
     ptrRefP->ptr = lcalloc( bytes, 1L /*, memKind */);
     return(ptrRefP->ptr != NULL);
}
/*---------------------------------------------------------------------------*/
void MyRelease(ptrRefP)
register fsm_PointerRef_t       *ptrRefP;
{
     free(ptrRefP->ptr);
}
/*---------------------------------------------------------------------------*/
/*
 * A no-op procedure.
 */
void MyNoop(ptrRefP) 
fsm_PointerRef_t       *ptrRefP;
{
}
/*---------------------------------------------------------------------------*/
/*
 * Report an error.
 */
void MyError(errnum, a, b, c)
long      errnum;
long      a, b, c;
{

     char      buffer[80];
     char      *nChar = "Symbol %D not found in %s";
     char      *fRead = "[3][Error reading file |%s][OK]";
     char      *fOpen = "[3][Error opening file |%s][OK]";
     char      *bForm = "[3][Bad file format for |%s][OK]";
     char      *noMem = "[3][Not enough memory][OK]";
     char      *sysEr = "[3][System error][OK]";
     char      *fWrite = "[3][Error writing file |%s][OK]";
     char      *fClose = "[3][Error closing file |%s][OK]";
     char      *somEr = "[3][Unknown error][OK]";
     char      *sizes = "[3][Sizes slected are unreasonable][OK]";
     char      *width = "[3][Width selected is to large][OK]";


     switch( (int) errnum ) {
          case fsm_errNoChar:
               sprintf(buffer, nChar, a, b);
               form_alert(1, buffer);
               break;

          case fsm_errFileRead:
               sprintf(buffer, fRead, a);
               form_alert(1, buffer);
               break;

          case fsm_errFileOpen:
               sprintf(buffer, fOpen, a);
               form_alert(1, buffer);
               break;

          case fsm_errFileFormat:
               sprintf(buffer, bForm, a);
               form_alert(1, buffer);
               break;

          case fsm_errNoMem:
               form_alert(1, noMem);
               break;

          case fsm_errMisc:
               form_alert(1, sysEr);
               break;

          case MyErrorWrite:
               sprintf(buffer, fWrite, (char *) a);
               form_alert(1, buffer);
               break;

          case MyErrorClose:
               sprintf(buffer, fClose, (char *) a);
               form_alert(1, buffer);
               break;

          case MyErrorSizes:
               form_alert(1, sizes);
               break;

          case MyErrorWidth:
               form_alert(1, width);
               break;

          default:
               form_alert(1, somEr);
               break;
     }
}
/*---------------------------------------------------------------------------*/
char *MyFopen(fname)
char      *fname;
{
              char      newName[80];
     register long      *handle;

     if ((handle = lcalloc(4L, 1L)) == NULL)/* allocate space for handle */
          return(NULL);

     *handle = Fopen(fname, 0);               /* open for read only */

     if (*handle < 0)
          return(NULL);
     else
          return((char *) handle);
}

/*---------------------------------------------------------------------------*/
void MyFclose(fp)
short      *fp;
{
     Fclose(fp[1]);
     free(fp,1L);
}
/*---------------------------------------------------------------------------*/
long MyFseek(fp, offset, origin)
short     *fp;
long      offset;
long      origin;
{
     return (Fseek(offset, fp[1], (short) origin));
}
/*---------------------------------------------------------------------------*/
long MyFread(buffer, size, n, fp)
char      *buffer;
long      size;
long      n;
short     *fp;
{
     n = Fread(fp[1], size * n, buffer);
     return(n / size); 
}
/*---------------------------------------------------------------------------*/
