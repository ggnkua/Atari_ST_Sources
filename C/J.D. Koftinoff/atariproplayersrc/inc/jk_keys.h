/*      key.h                                           By Jeff Koftinoff
**      v1.0                                            started:5/19/87
**
**      Definitions for the special keys on the Atari St.
**      note all numbers are LONGS.
*/

#ifndef __JK_KEYS_H
#define __JK_KEYS_H

//  Function Keys 
//  Just the first 20


#define K_F1    (long)0x3b0000
#define K_F2    (long)0x3c0000
#define K_F3    (long)0x3d0000
#define K_F4    (long)0x3e0000
#define K_F5    (long)0x3f0000
#define K_F6    (long)0x400000
#define K_F7    (long)0x410000
#define K_F8    (long)0x420000
#define K_F9    (long)0x430000
#define K_F10   (long)0x440000

#define K_F11	(long)0x540000
#define K_F12	(long)0x550000
#define K_F13	(long)0x560000
#define K_F14	(long)0x570000
#define K_F15	(long)0x580000
#define K_F16	(long)0x590000
#define K_F17	(long)0x5a0000
#define K_F18	(long)0x5b0000
#define K_F19	(long)0x5c0000
#define K_F20	(long)0x5d0000

//  Cursor control keys:  

#define K_UP    (long)0x480000
#define K_SUP   (long)0x480038		//  Shift Up arrow
#define K_DOWN  (long)0x500000
#define K_SDOWN (long)0x500032		//  Shift Down
#define K_LEFT  (long)0x4b0000
#define K_SLEFT (long)0x4b0034		//  Shift Left
#define K_RIGHT (long)0x4d0000
#define K_SRIGHT (long)0x4d0036     	//  Shift Right
#define K_HOME  (long)0x470000
#define K_INS   (long)0x520000
#define K_DEL   (long)0x530000

#define K_HELP  (long)0x620000
#define K_UNDO  (long)0x610000

#endif

