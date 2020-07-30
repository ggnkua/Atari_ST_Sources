/*
  VT52 Emulator Steuerbefehle fÅr C
  Ω1985 K.Ullmann & CCD-Walluf
*/
/*
#define _print(c)    Bconout(2,c)             /* Output to Console  */
*/
#define _print(c)    Cconout(c)             /* Output to Console  */
#define _prtesc(c)   _print(0x1b),_print(c)   /* Print ESC Sequence */
#define cls()        _prtesc('E')
#define clrrest()    _prtesc('J')
#define clrtop()     _prtesc('d')
#define clrline()    _prtesc('l')
#define clrleft()    _prtesc('o')
#define clrright()   _prtesc('K')
#define pos(x,y)     _prtesc('Y'),_print((y)+32),_print((x)+32)
#define home()       _prtesc('H')
#define crs_up()     _prtesc('A')
#define crs_down()   _prtesc('B')
#define crs_right()  _prtesc('C')
#define crs_left()   _prtesc('D')
#define crss_up()    _prtesc('I')
#define crss_down()  _print(LF)
#define crs_save()   _prtesc('j')
#define crs_put()    _prtesc('k')
#define ins_line()   _prtesc('L')
#define del_line()   _prtesc('M')
#define c_color(x)   _prtesc('b'),_print(x)
#define b_mode(x)    _prtesc('c'),_print(x)
#define crs_on()     _prtesc('e')
#define crs_off()    _prtesc('f')
#define rev_on()     _prtesc('p')
#define rev_off()    _prtesc('q')
#define wrap_on()    _prtesc('v')
#define wrap_off()   _prtesc('w')

