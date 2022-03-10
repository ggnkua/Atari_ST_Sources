#ifndef H_WAZOO
#define H_WAZOO
/*
 * wazoo.h
 */

#ifndef ACK
#define ACK    0x06
#endif

#ifndef NAK
#define NAK    0x15
#endif

#ifndef ENQ
#define ENQ    0x05
#endif

#ifndef YOOHOO
#define YOOHOO 0x00f1
#endif

#ifndef  TSYNC
#define  TSYNC 0x00ae
#endif

struct _Hello
{
   MWORD signal;								 /* always 'o'	   (0x6f)					*/
   MWORD hello_version;							 /* currently 1    (0x01)					*/
   MWORD product;								 /* product code							*/
   MWORD product_maj;							 /* major revision of the
												  * product 		  */
   MWORD product_min;							 /* minor revision of the
												  * product 		  */
   char my_name[60];							 /* Other end's name						*/
   char sysop[20];								 /* sysop's name							*/
   MWORD my_zone;								 /* 0== not supported						*/
   MWORD my_net;								 /* out primary net number					*/
   MWORD my_node;								 /* our primary node number 				*/
   MWORD my_point;								 /* 0== not supported						*/
   byte my_password[8]; 						 /* ONLY 6 CHARACTERS ARE
												  * SIGNIFICANT !!!!! */
   byte reserved2[8];							 /* reserved by Opus						*/
   MWORD capabilities;							 /* see below								*/
   byte reserved3[12];							 /* available to non-Opus
												  * systems by prior  */
   /* "approval" of 124/108.				  */
};												 /* size 128 bytes */


/*--------------------------------------------------------------------------*/
/* YOOHOO<tm> CAPABILITY VALUES 											*/
/*--------------------------------------------------------------------------*/
#define Y_DIETIFNA 0x0001
#define FTB_USER   0x0002
#define ZED_ZIPPER 0x0004
#define ZED_ZAPPER 0x0008
#define DOES_IANUS 0x0010
#define Bit_5	   0x0020
#define Bit_6	   0x0040
#define Bit_7	   0x0080
#define Bit_8	   0x0100
#define Bit_9	   0x0200
#define Bit_a	   0x0400
#define Bit_b	   0x0800
#define Bit_c	   0x1000
#define Bit_d	   0x2000
#define DO_DOMAIN  0x4000
#define WZ_FREQ    0x8000


/*
 * Function prototypes
 */

void WaZOO (int);
int YooHoo_Sender (void);
int YooHoo_Receiver (void);
int send_WaZOO (void);
int WaZOO_callback (char *reqs);
int respond_to_file_requests (int, int (*)(char *));


#endif	/* H_WAZOO */
