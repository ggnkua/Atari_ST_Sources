#define ONE_PLAYER	1
#define TWO_PLAYER	2
#define MAX_PLAYERS	TWO_PLAYER

/****************************************************************/
/*  These will eventually be part of the Falcon 030 library.	*/
/****************************************************************/
#define JOYSTICK	0xFF9202L
#define FIREBUTTONS	0xFF9200L

#define JOY1_UP        0xFEFE
#define JOY1_DOWN      0xFDFE
#define JOY1_LEFT      0xFBFE
#define JOY1_RIGHT     0xF7FE
#define JOY1_UPRIGHT   0xF6FE
#define JOY1_UPLEFT    0xFAFE
#define JOY1_DOWNRIGHT 0xF5FE
#define JOY1_DOWNLEFT  0xF9FE

#define JOY2_UP        0xEFEF
#define JOY2_DOWN      0xDFEF
#define JOY2_LEFT      0xBFEF
#define JOY2_RIGHT     0x7FEF
#define JOY2_UPRIGHT   0x6FEF
#define JOY2_UPLEFT    0xAFEF
#define JOY2_DOWNRIGHT 0x5FEF
#define JOY2_DOWNLEFT  0x9FEF

#define JOYBIT_UP        0x01
#define JOYBIT_DOWN      0x02
#define JOYBIT_LEFT      0x04
#define JOYBIT_RIGHT     0x08
#define JOYBIT_UPRIGHT   0x09
#define JOYBIT_UPLEFT    0x05
#define JOYBIT_DOWNRIGHT 0x0A
#define JOYBIT_DOWNLEFT  0x06

#define FIRE1_0		0xBFFD
#define FIRE1_1		0xBFFD
#define FIRE1_2		0xBFFD
#define PAUSE1		0xBFFE
#define OPTION1		0xBFFD

#define FIRE2_0		0xBFF7
#define FIRE2_1		0xBFF7
#define FIRE2_2		0xBFF7
#define PAUSE2		0xBFFB
#define OPTION2		0xBFF7

#define FIREBIT_0	0x01
#define FIREBIT_1	0x02
#define FIREBIT_2	0x04
#define FIREBIT_PAUSE	0x08
#define FIREBIT_OPTION	0x10

#define KEY1_POUND	0xFEF7
#define KEY1_0		0xFEFB
#define KEY1_STAR	0xFEFD
#define KEY1_9		0xFDF7
#define KEY1_8		0xFDFB
#define KEY1_7		0xFDFD
#define KEY1_6		0xFBF7
#define KEY1_5		0xFBFB
#define KEY1_4		0xFBFD
#define KEY1_3		0xF7F7
#define KEY1_2		0xF7FB
#define KEY1_1		0xF7FD

#define KEY2_POUND	0xEF7F
#define KEY2_0		0xEFBF
#define KEY2_STAR	0xEFDF
#define KEY2_9		0xDF7F
#define KEY2_8		0xDFBF
#define KEY2_7		0xDFDF
#define KEY2_6		0xBF7F
#define KEY2_5		0xBFBF
#define KEY2_4		0xBFDF
#define KEY2_3		0x7F7F
#define KEY2_2		0x7FBF
#define KEY2_1		0x7FDF

#define KEYBIT_POUND	0x0800		/* 00001000 00000000 */
#define KEYBIT_0	0x0400		/* 00000100 00000000 */
#define KEYBIT_STAR	0x0200		/* 00000010 00000000 */
#define KEYBIT_9	0x0100		/* 00000001 00000000 */
#define KEYBIT_8	0x0080		/* 00000000 10000000 */
#define KEYBIT_7	0x0040		/* 00000000 01000000 */
#define KEYBIT_6	0x0020		/* 00000000 00100000 */
#define KEYBIT_5	0x0010		/* 00000000 00010000 */
#define KEYBIT_4	0x0008		/* 00000000 00001000 */
#define KEYBIT_3	0x0004		/* 00000000 00000100 */
#define KEYBIT_2	0x0002		/* 00000000 00000010 */
#define KEYBIT_1	0x0001		/* 00000000 00000001 */
