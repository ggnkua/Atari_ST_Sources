#ifndef H_DEFINES
#define H_DEFINES
/*--------------------------------------------------------------------------*/
/*                                                                          */
/*                                                                          */
/*      ------------         Bit-Bucket Software, Co.                       */
/*      \ 10001101 /         Writers and Distributors of                    */
/*       \ 011110 /          Freely Available<tm> Software.                 */
/*        \ 1011 /                                                          */
/*         ------                                                           */
/*                                                                          */
/*  (C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*                                                                          */
/*                                                                          */
/*                 Major definitions used in BinkleyTerm                    */
/*                                                                          */
/*                                                                          */
/*    For complete  details  of the licensing restrictions, please refer    */
/*    to the License  agreement,  which  is published in its entirety in    */
/*    the MAKEFILE and BT.C, and also contained in the file LICENSE.240.    */
/*                                                                          */
/*    USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE    */
/*    BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF    */
/*    THIS  AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,  OR IF YOU DO    */
/*    NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET    */
/*    SOFTWARE CO.  AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT    */
/*    SHOULD YOU  PROCEED TO USE THIS FILE  WITHOUT HAVING  ACCEPTED THE    */
/*    TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER    */
/*    AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.      */
/*                                                                          */
/*                                                                          */
/* You can contact Bit Bucket Software Co. at any one of the following      */
/* addresses:                                                               */
/*                                                                          */
/* Bit Bucket Software Co.        FidoNet  1:104/501, 1:132/491, 1:141/491  */
/* P.O. Box 460398                AlterNet 7:491/0                          */
/* Aurora, CO 80046               BBS-Net  86:2030/1                        */
/*                                Internet f491.n132.z1.fidonet.org         */
/*                                                                          */
/* Please feel free to contact us at any time to share your comments about  */
/* our software and/or licensing policies.                                  */
/*                                                                          */
/*--------------------------------------------------------------------------*/

#undef SUCCESS
#define SUCCESS 0
#define SUCCESS_EOT -1
#define OPEN_ERR -1
#define GETBLOCK_ERR -2
#define SENDBLOCK_ERR -3
#define SEND_TIMEOUT -4
#define END_OF_FILE -5
#define SEND_RETRY_ERR -6
#define SYSTEM_ERR -7
#define DATA_STREAM_ERR -8
#define CARRIER_ERR -9
#define FNAME_ERR -10
#define BUSY_ERR -11
#define BAD_LINE_ERR -12
#define VOICE_ERR -13
#define DIAL_TONE_ERR -14
#define MODEM_ERR -15
#define TIME_ERR -16
#define WHACK_CR_ERR -17
#define XMODEM_ERR -18
#define SENDFILE_ERR -19
#define STREAM_ERR -20
#define XMODEM_REC_ERR -21
#define NO_CR_ERR -22
#define EOT_RECEIVED -23
#define STAT_ERR -24
#define START_TIMEOUT -25
#define NO_CARRIER_ERR -26
#define CONN_COUNT_ERR -27
#define NO_CONN_COUNT_ERR -28
#define NO_CALL -29
#define READ_ERR -30
#define OUR_MSG_ERR -31
#define MSG_SENT_ERR -32
#define MLO_ERR -33
#define PICKUP_DONE -34
#define DEV_ERR -35
#define KBD_ERR -36
#define CRC_ERR -37
#define RESYNC_ERR -38
#define TOO_MANY_ERRORS -39

#define STREAM_CHARS 12000
#define CRC 1
#define CHECKSUM 0
#define UNKNOWN -1
#define WANTCRC	'C'

#define EOT_BLOCK 1
#define TELINK_BLOCK 2
#define DATA_BLOCK 3
#define XMODEM_BLOCK 3
#define BAD_BLOCK 4
#define SHORT_BLOCK 5
#define DUP_BLOCK 6
#define SEALINK_BLOCK 7
#define NO_BLOCK 10

#define XS0 2
#define XS0T 3
#define XS1 4
#define XS2 5
#define XS3 6
#define MS0 2
#define MS1 3
#define MS2 4
#define S0 1
#define S1 2
#define S2 3
#define S3 4
#define S4 5
#define S5 6
#define S6 7
#define S7 8
#define S8 9
#define XR0 2
#define XR0B 3
#define XR1 4
#define XR2 5
#define XR3 6
#define XR4 7
#define XR5 8
#define MR0 2
#define MR1 3
#define MR2 4
#define MR3 5
#define R0 1
#define R1 2
#define R2 3
#define R3 4
#define R4 5
#define R5 6
#define R6 7
#define R7 8
#define BS0 2
#define BS1 3
#define BS2 4
#define BS3 5
#define BS4 6
#define BR0 2
#define BR1 3
#define BR2 4
#define BR3 5
#define BR4 6
#define W0 1
#define W1 2
#define W2 3
#define W3 4
#define W4 5
#define W5 6
#define SR0 1
#define SR1 2
#define SR2 3
#define AC0 2
#define AC1 3
#define AC2 4
#define AC3 5
#define AC4 6
#define AC5 7
#define AC6 8
#define AC7 9
#define AC8 10
#define AC9 11
#define AC10 12
#define SB0 2
#define SB1 3
#define SB2 4
#define SB3 5
#define RB0 2
#define RB1 3
#define RB2 4
#define RB3 5
#define RB4 6
#define SA0 2
#define SA1 3
#define SA2 4
#define SA3 5
#define SN0 2
#define SN1 3
#define SN2 4
#define SN3 5


#define ONE_MINUTE 60000L

#define SEND_ONLY 1
#define RECEIVE_ONLY 2

#define INITIALIZE   0
#define TEST_AND_SET 1
#define CLEAR_FLAG   2
#define SET_SESSION_FLAG 3
#define CLEAR_SESSION_FLAG 4

#define QFAX_MAGIC	"QFAX"
#define SIERRA		0
#define PROMODEM	1
#define	CL2			10
#define	EXAR		0


#endif	/* H_DEFINES */
