/* 
 * A test file for PUNSSi IKBD packet handling (w) 1997 by Eero Tamminen
 *
 * Prints last mapped IKBD key/joy event once a second for twenty times.
 */

#include <stdio.h>	/* printf */
#include <unistd.h>	/* sleep */
#ifdef __SOZOBONX__
#include <bios.h>
typedef KBDVECS _KBDVECS;
#else
#include <ostruct.h>	/* OS structures (_KBDVECS) */
#endif
#include <osbind.h>	/* OS calls */


/* assembly code for receiving IKBD packets */
extern long KeyISR(void);
/* received packet header and bytes left */
extern unsigned char Pheader, Pleft;

volatile long InputValue[2] = {0, 0};

static void (*key_handler);


int main()
{
  _KBDVECS *table_addr;
  int idx;

  printf("IKBD handler / key mapper test program (w) 1997 by Eero Tamminen\n\n");

  /* Install new joystick packet handler into keyboard vector table.  Tell
   * IKBD to send joystick packets.
   */
  table_addr = Kbdvbase();
  key_handler = table_addr->ikbdsys;
  table_addr->ikbdsys = KeyISR;
  Ikbdws(1, "\022\024");

  printf("key handler %p => %p\n", key_handler, KeyISR);
  for (idx = 0; idx < 20; idx++)
  {
	  printf("%x, %x (%d<-%d)\n",
		  InputValue[0], InputValue[1],
		  Pheader, Pleft);
	  sleep(1);
  }
  table_addr->ikbdsys = key_handler;
  Ikbdws(1, "\025\010");
  return 0;
}
