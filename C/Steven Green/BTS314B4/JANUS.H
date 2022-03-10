#ifndef H_JANUS
#define H_JANUS
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
/*                   Janus definitions for BinkleyTerm                      */
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


/* Misc. Constants */
#define BUFMAX 2048          /* Max packet contents length                   */
#define NUM_FLAGS 4          /* Number of mail-type flag characters (O,D,C,H)*/
#define JANUS_EFFICIENCY 95  /* Estimate Janus xfers at 95% throughput       */

/* Positions of transfer status line fields */
#define POS_X 21
#define LEN_X 30
#define ETA_X 40
#define MSG_X 50

/* File Transmission States */
#define XDONE        0       /* All done, no more files to transmit          */
#define XSENDFNAME   1       /* Send filename packet                         */
#define XRCVFNACK    2       /* Wait for filename packet ACK                 */
#define XSENDBLK     3       /* Send next block of file data                 */
#define XRCVEOFACK   4       /* Wait for EOF packet ACK                      */
#define XSENDFREQNAK 5       /* Send file request NAK (no matches found)     */
#define XRCVFRNAKACK 6       /* Wait for ACK to file request NAK             */

/* File Reception States */
#define RDONE      0         /* All done, nothing more to receive            */
#define RRCVFNAME  1         /* Wait for filename packet                     */
#define RRCVBLK    2         /* Wait for next block of file data             */

/* Packet Types */
#define NOPKT        0       /* No packet received yet; try again later      */
#define BADPKT      '@'      /* Bad packet received; CRC error, overrun, etc.*/
#define FNAMEPKT    'A'      /* Filename info packet                         */
#define FNACKPKT    'B'      /* Filename packet ACK                          */
#define BLKPKT      'C'      /* File data block packet                       */
#define RPOSPKT     'D'      /* Transmitter reposition packet                */
#define EOFACKPKT   'E'      /* EOF packet ACK                               */
#define HALTPKT     'F'      /* Immediate screeching halt packet             */
#define HALTACKPKT  'G'      /* Halt packet ACK for ending batch             */
#define FREQPKT     'H'      /* File request packet                          */
#define FREQNAKPKT  'I'      /* File request NAK (no matches for your req)   */
#define FRNAKACKPKT 'J'      /* ACK to file request NAK                      */

/* Non-byte values returned by rcvbyte() */
#define BUFEMPTY  (-1)
#define PKTSTRT   (-2)
#define PKTEND    (-3)
#define NOCARRIER (-4)
#define PKTSTRT32 (-5)

/* Bytes we need to watch for */
#define PKTSTRTCHR   'a'
#define PKTENDCHR    'b'
#define PKTSTRTCHR32 'c'

/* Various action flags */
#define GOOD_XFER    0
#define FAILED_XFER  1
#define INITIAL_XFER 2
#define ABORT_XFER   3

#define DELETE_AFTER '-'
#define TRUNC_AFTER  '#'

/* Protocol capability flags */
#define CANCRC32 0x80
#define CANFREQ  0x40

#define OURCAP (CANCRC32 | CANFREQ)

#endif	/* H_JANUS */
