/*      terminal.h                                      By Jeff Koftinoff
**
**     definitions for the most used terminal functions.
**     for Atari St and VT-52
*/

#ifndef __JK_TERM_H
#define __JK_TERM_H

#include <osbind.h>

#define t_curs_u()      Bconout(2,'\033'),Bconout(2,'A')
#define t_curs_d()      Bconout(2,'\033'),Bconout(2,'B')
#define t_curs_r()      Bconout(2,'\033'),Bconout(2,'C')
#define t_curs_l()      Bconout(2,'\033'),Bconout(2,'D')

#define t_curs_home()   Bconout(2,'\033'),Bconout(2,'H')

#define t_curs_ups()    Bconout(2,'\033'),Bconout(2,'I')
       // scrolls down if line = 0 

#define t_save_curs()   Bconout(2,'\033'),Bconout(2,'j')
#define t_rest_curs()   Bconout(2,'\033'),Bconout(2,'k')

#define t_clr_scrn()    Bconout(2,'\033'),Bconout(2,'E')
#define t_clr_eop()     Bconout(2,'\033'),Bconout(2,'J')
#define t_clr_eol()     Bconout(2,'\033'),Bconout(2,'K')
#define t_clr_top()     Bconout(2,'\033'),Bconout(2,'d')
#define t_clr_line()    Bconout(2,'\033'),Bconout(2,'l')
#define t_clr_beg()     Bconout(2,'\033'),Bconout(2,'o')

#define t_ins_line()    Bconout(2,'\033'),Bconout(2,'L')
#define t_del_line()    Bconout(2,'\033'),Bconout(2,'M')

#define t_rev_on()      Bconout(2,'\033'),Bconout(2,'p')
#define t_rev_off()     Bconout(2,'\033'),Bconout(2,'q')
#define t_curs_on()     Bconout(2,'\033'),Bconout(2,'e')
#define t_curs_off()    Bconout(2,'\033'),Bconout(2,'f')
#define t_over_on()     Bconout(2,'\033'),Bconout(2,'v')
#define t_over_off()    Bconout(2,'\033'),Bconout(2,'w')

#define t_char_col(a)   Bconout(2,'\033'),Bconout(2,'b'),Bconout(2,a)
#define t_back_col(a)   Bconout(2,'\033'),Bconout(2,'c'),Bconout(2,a)

#define t_goto_xy(a,b) Bconout(2,'\033'),Bconout(2,'Y'),\
			Bconout(2,(b)+32),Bconout(2,(a)+32)


#endif


