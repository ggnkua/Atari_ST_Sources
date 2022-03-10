#ifndef H_VIDEO
#define H_VIDEO
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
/*      IBM PC Line Drawing character definitions used in BinkleyTerm       */
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


/* single line boxes */
#define VBAR1  179
#define VLINE  179
#define HBAR1  196
#define HLINE  196
#define ULC11  218
#define URC11  191
#define LLC11  192
#define LRC11  217
#define TL11   195
#define TR11   180
#define TT11   194
#define TB11   193
#define X11    197

/* double line boxes */
#define VBAR2  186
#define HBAR2  205
#define ULC22  201
#define URC22  187
#define LLC22  200
#define LRC22  188
#define TL22   204
#define TR22   185
#define TT22   203
#define TB22   202
#define X22    206

/* single line horizontal and double line vertical boxes */
#define ULC12  214
#define URC12  183
#define LLC12  211
#define LRC12  189
#define TL12   199
#define TR12   182
#define TT12   210
#define TB12   208
#define X12    215

/* double line horizontal and single line vertical boxes */
#define ULC21  213
#define URC21  184
#define LLC21  212
#define LRC21  190
#define TL21   198
#define TR21   181
#define TT21   209
#define TB21   207
#define X21    216

/* full and partial blocks */
#define BLOCK  219
#define VBAR   219
#define VBARL  221
#define VBARR  222
#define HBART  223
#define HBARB  220

/* special graphic symbols */
#define BLANK  32
#define DIAMOND   4
#ifndef __TOS__
#define UPARROW   24
#define DOWNARROW 25
#define RIGHTARROW   26
#define LEFTARROW 27
#endif
#define SLASH  47

#endif	/* VIDEO */
