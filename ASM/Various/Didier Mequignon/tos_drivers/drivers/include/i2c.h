/* ------------------------------------------------------------------------- */
/*                                                                           */
/* i2c.h - definitions for the i2c-bus interface                             */
/*                                                                           */
/* ------------------------------------------------------------------------- */
/*   Copyright (C) 1995-2000 Simon G. Vogl

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.		     */
/* ------------------------------------------------------------------------- */

/* With some changes from Kyösti Mälkki <kmalkki@cc.hut.fi> and
   Frodo Looijaard <frodol@dds.nl> */

/* $Id: i2c.h,v 1.68 2003/01/21 08:08:16 kmalkki Exp $ */

#ifndef _I2C_H
#define _I2C_H

/* --- General options ------------------------------------------------	*/

struct i2c_msg;
struct i2c_algorithm;
struct i2c_adapter;

/* Transfer num messages.
 */
extern int i2c_transfer(struct i2c_adapter *adap, struct i2c_msg *msgs, int num);

/*
 * The following structs are for those who like to implement new bus drivers:
 * i2c_algorithm is the interface to a class of hardware solutions which can
 * be addressed using the same bus algorithms - i.e. bit-banging or the PCF8584
 * to name two of the most common.
 */
struct i2c_algorithm {
	unsigned int id;
	int (*master_xfer)(struct i2c_adapter *adap,struct i2c_msg *msgs, int num);
	/* --- ioctl like call to set div. parameters. */
	int (*algo_control)(struct i2c_adapter *, unsigned int, unsigned long);
};

/*
 * i2c_adapter is the structure used to identify a physical i2c bus along
 * with the access algorithms necessary to access it.
 */
struct i2c_adapter {
	struct i2c_algorithm *algo;/* the algorithm to access the bus	*/
	void *algo_data;
	int timeout;
	int retries;
	int nr;
};

/*
 * I2C Message - used for pure i2c transaction, also from /dev interface
 */
struct i2c_msg {
	unsigned short addr;	/* slave address			*/
 	unsigned short flags;		
#define I2C_M_TEN	0x10	/* we have a ten bit chip address	*/
#define I2C_M_RD	0x01
#define I2C_M_NOSTART	0x4000
#define I2C_M_REV_DIR_ADDR	0x2000
#define I2C_M_IGNORE_NAK	0x1000
#define I2C_M_NO_RD_ACK		0x0800
 	unsigned short len;		/* msg length				*/
 	unsigned char *buf;		/* pointer to msg data			*/
};

#endif /* _I2C_H */
