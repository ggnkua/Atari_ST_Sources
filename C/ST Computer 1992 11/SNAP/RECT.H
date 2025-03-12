/* RECT.H */

#ifndef __RECT

# define __RECT

# define NOSET      0x00
# define DOSETX     0x01
# define DOSETY     0x02
# define DOSETW     0x04
# define DOSETH     0x08
# define DOSETXYWH  (DOSETX|DOSETY|DOSETW|DOSETH)
# define TOBIGGER   0x10
# define TOSMALLER  0x20


# include <aes.h>


void RectToElement( GRECT *rect,
                    int   welm,
                    int   helm,
                    int   flag );


#endif
