/* Insert keypresses by Lloyd Patton */

#include <local.h>
#include <osbind.h>

main()
  {

  long UpperA = 0x001e0041; /* 'A' */
  long Number0 = 0x000b0030; /* '0' */
  long ch;

  appl_init();
  insert_char(UpperA);
  ch = evnt_keybd();  /* test GEM call */
  printf("\nkeystroke should be 0x1e41 and is 0x%lx\n",
ch);
  insert_char(Number0);
  ch = Bconin(2);   /* test BIOS call */
  printf("\nkeystroke should be 0x000b0030 and is
0x%08lx\n", ch);
  evnt_keybd();
  appl_exit();
  }

insert_char(keycode)
  long keycode;
  {

  iorec *keybuf;
  long stack;

  keybuf = Iorec(1);  /* get Iorec address */
  stack = Super(0L);  /* supervisor mode to access Iorec
 */

    /* loop around buffer */
  if ((keybuf->ibuftl += 4) >= keybuf->ibufsiz)
    keybuf->ibuftl = 0;

    /* if room in buffer store keystroke */
  if (keybuf->ibuftl != keybuf->ibufhd)
    *(long *)&keybuf->ibuf[keybuf->ibuftl] = keycode;

  Super(stack);   /* back to user mode */
  }
