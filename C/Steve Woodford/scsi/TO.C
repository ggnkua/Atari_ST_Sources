/*
 * to.c - Copyright Steve Woodford, August 1993.
 *
 * Table of default timeouts for 8 possible SCSI targets.
 * There's probably an easier way to do this....
 */

#include <sys/types.h>
#include <sys/scsi.h>
#include "libscsi.h"

PUBLIC  Sc_Timeout  _Scsi_Timeouts[MAX_SCSI_ID + 1] = {
    {2,     /* Normal    */ /* Target 0 */
     10,    /* Rezero    */
     4,     /* Read      */
     4,     /* Write     */
     4,     /* Seek      */
     120,   /* Load      */
     120,   /* Unload    */
     240,   /* Retension */
     1600,  /* Space     */
     1600}, /* Erase     */

    {2,     /* Normal    */ /* Target 1 */
     10,    /* Rezero    */
     4,     /* Read      */
     4,     /* Write     */
     4,     /* Seek      */
     120,   /* Load      */
     120,   /* Unload    */
     240,   /* Retension */
     1600,  /* Space     */
     1600}, /* Erase     */

    {2,     /* Normal    */ /* Target 2 */
     10,    /* Rezero    */
     4,     /* Read      */
     4,     /* Write     */
     4,     /* Seek      */
     120,   /* Load      */
     120,   /* Unload    */
     240,   /* Retension */
     1600,  /* Space     */
     1600}, /* Erase     */

    {2,     /* Normal    */ /* Target 3 */
     10,    /* Rezero    */
     4,     /* Read      */
     4,     /* Write     */
     4,     /* Seek      */
     120,   /* Load      */
     120,   /* Unload    */
     240,   /* Retension */
     1600,  /* Space     */
     1600}, /* Erase     */

    {2,     /* Normal    */ /* Target 4 */
     10,    /* Rezero    */
     4,     /* Read      */
     4,     /* Write     */
     4,     /* Seek      */
     120,   /* Load      */
     120,   /* Unload    */
     240,   /* Retension */
     1600,  /* Space     */
     1600}, /* Erase     */

    {2,     /* Normal    */ /* Target 5 */
     10,    /* Rezero    */
     4,     /* Read      */
     4,     /* Write     */
     4,     /* Seek      */
     120,   /* Load      */
     120,   /* Unload    */
     240,   /* Retension */
     1600,  /* Space     */
     1600}, /* Erase     */

    {2,     /* Normal    */ /* Target 6 */
     10,    /* Rezero    */
     4,     /* Read      */
     4,     /* Write     */
     4,     /* Seek      */
     120,   /* Load      */
     120,   /* Unload    */
     240,   /* Retension */
     1600,  /* Space     */
     1600}, /* Erase     */

    {2,     /* Normal    */ /* Target 7 */
     10,    /* Rezero    */
     4,     /* Read      */
     4,     /* Write     */
     4,     /* Seek      */
     120,   /* Load      */
     120,   /* Unload    */
     240,   /* Retension */
     1600,  /* Space     */
     1600}  /* Erase     */
};
