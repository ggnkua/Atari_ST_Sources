/*      SCREEN.H

        VT52 Macro Includes

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/


#if !defined( __VT52 )
#define __VT52

#if !defined( __TOS )
#include <tos.h>        /* tos.h already included ? */
#endif

/**** Strings ***********************************************************/

#define NEXT_LINE       "\r\n"
#define CUR_UP          "\33A"
#define CUR_DOWN        "\33B"
#define CUR_RIGHT       "\33C"
#define CUR_LEFT        "\33D"
#define CLEAR_HOME      "\33E"
#define CUR_HOME        "\33H"
#define SCROLL_UP       "\33I"
#define CLEAR_DOWN      "\33J"
#define CLEAR_EOL       "\33K"
#define INS_LINE        "\33L"
#define DEL_LINE        "\33M"
#define GOTO_POS        "\33Y"
#define INK             "\33b"
#define PAPER           "\33c"
#define CLEAR_UP        "\33d"
#define CUR_ON          "\33e"
#define CUR_OFF         "\33f"
#define SAVE_POS        "\33j"
#define LOAD_POS        "\33k"
#define CLEAR_LINE      "\33l"
#define CLEAR_SOL       "\33o"
#define REV_ON          "\33p"
#define REV_OFF         "\33q"
#define WRAP_ON         "\33v"
#define WRAP_OFF        "\33w"

/**** Functionmacros ****************************************************/

#define Bell()          Cconout('\a')
#define Tab()           Cconout('\t')
#define Return()        Cconout('\r')
#define Line_feed()     Cconout('\n')
#define Next_line()     Cconws(NEXT_LINE)
#define Cur_up()        Cconws(CUR_UP)
#define Cur_down()      Cconws(CUR_DOWN)
#define Cur_right()     Cconws(CUR_RIGHT)
#define Cur_left()      Cconws(CUR_LEFT)
#define Clear_home()    Cconws(CLEAR_HOME)
#define Cur_home()      Cconws(CUR_HOME)
#define Scroll_up()     Cconws(SCROLL_UP)
#define Clear_down()    Cconws(CLEAR_DOWN)
#define Clear_eol()     Cconws(CLEAR_EOL)
#define Ins_line()      Cconws(INS_LINE)
#define Del_line()      Cconws(DEL_LINE)
#define Goto_pos(x,y)   (Cconws(GOTO_POS),  Cconout(' ' + x), Cconout(' ' + y))
#define Ink(c)          (Cconws(INK),   Cconout(c))
#define Paper(c)        (Cconws(PAPER), Cconout(c))
#define Clear_up()      Cconws(CLEAR_UP)
#define Cur_on()        Cursconf(1, 0)
#define Cur_off()       Cursconf(0, 0)

#define Blink_on()      Cursconf(2, 0)
#define Blink_off()     Cursconf(3, 0)
#define Set_blink(rate) Cursconf(4, rate)
#define Get_blink()     Cursconf(5, 0)

#define Save_pos()      Cconws(SAVE_POS)
#define Load_pos()      Cconws(LOAD_POS)
#define Clear_line()    Cconws(CLEAR_LINE)
#define Clear_sol()     Cconws(CLEAR_SOL)
#define Rev_on()        Cconws(REV_ON)
#define Rev_off()       Cconws(REV_OFF)
#define Wrap_on()       Cconws(WRAP_ON)
#define Wrap_off()      Cconws(WRAP_OFF)

#endif

/************************************************************************/
