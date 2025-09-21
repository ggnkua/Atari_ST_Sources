#include <stdio.h>
#include <aes.h>

#include "menukeys.h"
#include "aprintf.h"


int main(void)
{
  char symbuf[20], longbuf[40];
  int keycode, kbdcode;

  appl_init();
  do{
    kbdcode = evnt_keybd();
    keycode = key_decode(kbdcode);
    key_text(KT_SYMBOL, keycode, symbuf);
    key_text(KT_LONG, keycode, longbuf);
    aprintf_prepare(symbuf);
    aprintf_prepare(longbuf);
  }while (1 == aprintf(1,  "[1][|evnt_keybd() = $%04x |"
				"key_decode() = $%04x |"
				"Symbol: %s |"
				"Text: %s ][ Weiter |Abbruch]",
			kbdcode, keycode, symbuf, longbuf));
  appl_exit();
  return 0;
}
