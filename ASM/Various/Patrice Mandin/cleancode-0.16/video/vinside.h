/*
	Videl Inside 2 definitions

	Copyright (C) 2002	Patrice Mandin

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*/

#ifndef _VINSIDE_H
#define _VINSIDE_H

/*--- Types ---*/

typedef struct {
	unsigned short freqh_mini;
	unsigned short freqh_maxi;
	unsigned short freqv_mini;	/* Value*10 */
	unsigned short freqv_maxi;	/* Value*10 */
} vi_limits_t;

/* VI2 cookie points to this structure */

typedef struct {
	unsigned char version[2];
	unsigned char length[2];
	unsigned char dummy[(0x46)-4];	/* 0x46 is the value of length field */
	unsigned char setmode[4];		/* Function to set a new mode */
} vi_cookie_t;

/* VI2.DAT file definition */

typedef struct {
	unsigned char name[8];			/* "DATFILE\0" */
	unsigned char version[2];		/* 0x0103 */

	unsigned char freqh_mini[2];	/* Freq limits for a multisync monitor */
	unsigned char freqh_maxi[2];	/*  The freqh stored are divided by 100 */
	unsigned char freqv_mini[2];	/*  The freqv stored are multiplied by 10 */
	unsigned char freqv_maxi[2];

	unsigned char multisync[2];		/* Multisync monitor ? */
									/*  bit 0: 0=no, 1=yes */

	unsigned char num_modes[2];		/* Number of video modes in this file */

	unsigned char intfreq1[2];		/* Videl clocks defined */
	unsigned char intfreq2[2];		/*  Freqs stored are divided by 100000 */
	unsigned char extfreq[2];
} vi_header_t;

typedef struct {
	unsigned char modecode[2];		/* Video mode definition */
									/*  bit 1: interlaced mode */ 
									/*   0=no, 1=yes */
									/*  bits 3,2: pixel clock predivisor */ 
									/*   0=divide by 4 */
									/*   1=divide by 2 */
									/*   2=divide by 1 */
									/*  bits 6,5,4: bits per pixel */ 
									/*   0=1 bpp */
									/*   1=2 bpp */
									/*   2=4 bpp */
									/*   3=8 bpp */
									/*   4=16 bpp */
									/*  bits 8,7: videl clock to use */
									/*   0=internal 1 */
									/*   1=internal 2 */
									/*   2=external */
									/*  bits 11,10,9: index for 0xffff8266.w value */ 
	unsigned char freqh_div[2];		/* Horizontal frequency divisor */
	unsigned char width[2];			/* Horizontal resolution */
	unsigned char dummy2[2];
	unsigned char freqv_div[2];		/* Vertical frequency divisor */
	unsigned char height[2];		/* Vertical resolution */
	unsigned char dummy3[38];
} vi_mode_t;

/*--- Variables ---*/

extern const vi_limits_t vi_limits[4];

/*--- Functions prototypes ---*/

vi_header_t *VI_LoadModes(void);

#endif /* _VINSIDE_H */
