#ifndef	__RDWRS__
#define	__RDWRS__

#include	<string.h>

#include	"types.h"

#define STARTREAD    0L
#define ENDREAD      1L
#define STARTWRITE   2L
#define ENDWRITE     3L

#define WINRDWR    0x00000000L
#define APPRDWR    0x00010000L
#define MENRDWR    0x00020000L

#define ASTARTREAD  (STARTREAD | APPRDWR)
#define AENDREAD    (ENDREAD | APPRDWR)
#define ASTARTWRITE (STARTWRITE | APPRDWR)
#define AENDWRITE   (ENDWRITE | APPRDWR)

#define WSTARTREAD    (STARTREAD | WINRDWR)
#define WENDREAD      (ENDREAD | WINRDWR)
#define WSTARTWRITE   (STARTWRITE | WINRDWR)
#define WENDWRITE     (ENDWRITE | WINRDWR)

#define MSTARTREAD  (STARTREAD | MENRDWR)
#define MENDREAD    (ENDREAD | MENRDWR)
#define MSTARTWRITE (STARTWRITE | MENRDWR)
#define MENDWRITE   (ENDWRITE | MENRDWR)

typedef struct /* count semaphore */ {
	LONG id;
	WORD pid;
	WORD apid;
	WORD count;
	WORD mode;	
}CSEMA;

/****************************************************************************
 * Rdwrs_init_module                                                        *
 *  Initialization of the mutual exclusion module in oAESis.                *
 ****************************************************************************/
void                     /*                                                 */
Rdwrs_init_module(void); /*                                                 */
/****************************************************************************/

/****************************************************************************
 * Rdwrs_exit_module                                                        *
 *  Shutdown of the mutual exclusion module in oAESis.                      *
 ****************************************************************************/
void                     /*                                                 */
Rdwrs_exit_module(void); /*                                                 */
/****************************************************************************/

/****************************************************************************
 * Rdwrs_quick                                                              *
 *  Quick try to grab/release monitor.                                      *
 ****************************************************************************/
WORD                    /* 0 if monitor successful, or 1.                   */
Rdwrs_quick(            /*                                                  */
LONG mode);             /* Monitor to grab/release.                         */
/****************************************************************************/

/****************************************************************************
 * Rdwrs_operation                                                          *
 *  Grab/release monitor.                                                   *
 ****************************************************************************/
void                    /*                                                  */
Rdwrs_operation(        /*                                                  */
LONG mode);             /* Monitor to grab/release.                         */
/****************************************************************************/

/****************************************************************************
 * Rdwrs_create_sem                                                         *
 *  Create semaphore and release it.                                        *
 ****************************************************************************/
LONG                    /* Id of semaphore.                                 */
Rdwrs_create_sem(void); /*                                                  */
/****************************************************************************/

WORD Rdwrs_get_sem(CSEMA *sem);
WORD Rdwrs_rel_sem(CSEMA *sem);

/****************************************************************************
 * Rdwrs_destroy_sem                                                        *
 *  Get semaphore and destroy it.                                           *
 ****************************************************************************/
void                     /*                                                 */
Rdwrs_destroy_sem(       /*                                                 */
LONG id);                /* Id of semaphore.                                */
/****************************************************************************/

#endif
