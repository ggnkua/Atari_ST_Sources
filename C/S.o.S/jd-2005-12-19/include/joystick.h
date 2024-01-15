#ifndef _SYS_JOYSTICK_H_
#define _SYS_JOYSTICK_H_

/*
 * FreeBSD/OpenBSD/NetBSD compatible joystick stuff
 */

struct joystick {
	long int x;
	long int y;
	long int b1;
	long int b2;
	};

#define JOY_SETTIMEOUT    ('j'<<8 | 0x41)	/* set timeout */
#define JOY_GETTIMEOUT    ('j'<<8 | 0x42)	/* get timeout */
#define JOY_SET_X_OFFSET  ('j'<<8 | 0x43)	/* set offset on X-axis */
#define JOY_SET_Y_OFFSET  ('j'<<8 | 0x44)	/* set offset on Y-axis */
#define JOY_GET_X_OFFSET  ('j'<<8 | 0x45)	/* get offset on X-axis */
#define JOY_GET_Y_OFFSET  ('j'<<8 | 0x46)	/* get offset on Y-axis */


/*
 * Linux style joystick stuff (old implementation)
 */

#define JS_RETURN               sizeof(struct JS_DATA_TYPE)
#define JS_TRUE                 1
#define JS_FALSE                0
#define JS_X_0                  0x01
#define JS_Y_0                  0x02
#define JS_X_1                  0x04
#define JS_Y_1                  0x08
#define JS_MAX                  2
 
#define JS_DEF_TIMEOUT          0x1300
#define JS_DEF_CORR             0
#define JS_DEF_TIMELIMIT        10L
 
#define JS_SET_CAL              ('j'<<8 | 0x51)
#define JS_GET_CAL              ('j'<<8 | 0x52)
#define JS_SET_TIMEOUT          ('j'<<8 | 0x53)
#define JS_GET_TIMEOUT          ('j'<<8 | 0x54)
#define JS_SET_TIMELIMIT        ('j'<<8 | 0x55)
#define JS_GET_TIMELIMIT        ('j'<<8 | 0x56)
#define JS_GET_ALL              ('j'<<8 | 0x57)
#define JS_SET_ALL              ('j'<<8 | 0x58)

struct JS_DATA_TYPE {
	long int buttons;
	long int x;
	long int y;
};

#endif