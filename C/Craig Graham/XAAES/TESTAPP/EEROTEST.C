#include <stdio.h>
#ifdef __GNUC__
  #include <aesbind.h>
#endif
#ifdef __SOZOBONX__
  #include <xgemfast.h>
#endif
#ifdef __LATTICE__
  #include <aes.h>
#endif

int main(int argc, char *argv[])
{
  short x, y, w, h;

  appl_init();
  wind_update(BEG_UPDATE);

  /* desktop work area */
  wind_get(0, WF_WORKXYWH, &x, &y, &w, &h);
  printf("x: %d, y: %d, w: %d, h: %d\n", x, y, w, h);

  /* save screen below menu */
  form_dial(FMD_START, x, y, w, h, x, y, w, h);

  form_alert(1, "[0][][Done]");

  /* redraw screen below menu */
  form_dial(FMD_FINISH, x, y, w, h, x, y, w, h);

  wind_update(END_UPDATE);
  appl_exit();
  return 0;
}