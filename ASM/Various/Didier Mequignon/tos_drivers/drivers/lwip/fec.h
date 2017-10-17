/*
 * Copyright (c) 2006 Christian Walter
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 * Author: Christian Walter <wolti@sil.at>
 *
 * File: $Id: fec.h,v 1.1 2006/08/29 00:04:06 wolti Exp $
 */

#ifndef _FEC_H
#define _FEC_H

/* ------------------------ Defines --------------------------------------- */
/* MII Speed Settings */
#define FEC_MII_10BASE_T        0
#define FEC_MII_100BASE_TX      1

/* MII Duplex Settings */
#define FEC_MII_HALF_DUPLEX     0
#define FEC_MII_FULL_DUPLEX     1

/* Timeout for MII communications */
#define FEC_MII_TIMEOUT         0x10000

/* External Interface Modes */
#define FEC_MODE_7WIRE          0
#define FEC_MODE_MII            1
#define FEC_MODE_LOOPBACK       2   /* Internal Loopback */
#define FEC_MODE_RMII           3
#define FEC_MODE_RMII_LOOPBACK  4   /* Internal Loopback */

/* ------------------------ Prototypes ------------------------------------ */
int fec_mii_write(uint8, uint8, uint8, uint16);
int fec_mii_read(uint8, uint8, uint8, uint16 *);
void fec_mii_init(uint8, uint32);
void fec_duplex (uint8, uint8);

#endif
