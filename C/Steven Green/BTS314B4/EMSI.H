#ifndef H_EMSI
#define H_EMSI
/*
 * emsi.h
 *
 * Function prototypes and constants for EMSI implementation
 */

/*
 * Return values from TxEmsiInit and RxEmsiInit
 */

#define SESSION_FAIL	0
#define SESSION_BBS     1
#define SESSION_FTSC    2
#define SESSION_WAZOO   3
#define SESSION_EMSI    4
#define SESSION_EXTERN  5

/*
 * Return values from read_emsi_dat
 */

#define EMSI_SUCCESS 0
#define EMSI_ABORT -1
#define EMSI_RETRY -2

/*
 * Emsi capabilities and options
 */

typedef UWORD EMSI_CAPABILITY;
#define EMSI_P_DZA	0x0001		/* DirectZAP */
#define EMSI_P_ZAP	0x0002		/* ZedZap */
#define EMSI_P_ZMO	0x0004		/* Zmodem [ZedZip] */
#define EMSI_P_JAN	0x0008		/* Janus */
#define EMSI_P_KER	0x0010		/* Kermit */
#define EMSI_P_NCP	0x0020		/* No compatibility (failure) */
#define EMSI_P_NRQ	0x0040		/* No file requests */
#define EMSI_P_ARC	0x0080		/* ARCmail */
#define EMSI_P_XMA	0x0100		/* Other compression methods */
#define EMSI_P_FNC	0x0200		/* MSDOS Filenames */

#define EMSI_O_HAT	0x2000		/* Hold ALL traffic */
#define EMSI_O_HXT	0x4000		/* Hold compressed mail */
#define EMSI_O_HRQ	0x8000		/* Hold file requests */

typedef enum { PUA, PUP, NPU } EMSI_CALL_OPTIONS;

/*
 * Variables
 */


/*
 * Prototypes
 */

int TxEmsiInit(void);				/* Sender initiation */
int RxEmsiInit(void);				/* Receiver initiation */
int EMSI_sender(void);				/* Do sender session */
int EMSI_receiver(void);			/* Do Receiver session */

#endif	/* H_EMSI */
