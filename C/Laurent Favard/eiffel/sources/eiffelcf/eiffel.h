/*
 *	--------------------------------------------------------------
 *	Eiffel Control Pannel.
 *
 * 	Author  :	Laurent Favard, Didier Mequignon
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *	
 *	--------------------------------------------------------------
 */

#ifndef	__EIFFEL_INTERFACE__
#define	__EIFFEL_INTERFACE__

#define	__EIFFEL_VERSION__		0x010A

/*	--------------------------------------------------------------	*/
/*	Eiffel IKBD command supported									*/

#define		IKBD_RESET			0x80
#define		IKBD_GETTEMP		0x03
#define		IKBD_PROGTEMP		0x04
#define		IKBD_PROGKB			0x05
#define		IKBD_PROGMS			0x06
#define		IKBD_LCD			0x23
/*	--------------------------------------------------------------	*/
#define		SZ_EIFRESET			2
#define		SZ_PROGTEMP			3
#define		SZ_PROGMS			3
#define		SZ_PROGKB			3

/*	--------------------------------------------------------------	*/
/*	 Sub-command for Eiffel Program Temp Flash Data */

#define		IDX_LEVELHTEMP		0x00 /* maxi level temperature */
#define		IDX_LEVELLTEMP		0x01 /* mini level temperature */
#define		IDX_TAB_CTN			0x02 /* Eiffel 1.0.6 2*12 values (Rctn/100, temperature) */

/*	--------------------------------------------------------------	*/
/*	Sub-command for Eiffel Program Mouse Flash Data */

#define		IDX_WHEELUP			0x00
#define		IDX_WHEELDN			0x01
#define		IDX_WHEELLT			0x02
#define		IDX_WHEELRT			0x03
#define		IDX_BUTTON3			0x04
#define		IDX_BUTTON4			0x05
#define		IDX_BUTTON5			0x06
#define		IDX_WHREPEAT		0x07

/*	--------------------------------------------------------------	*/
/*	Sub-command for Eiffel Program Keyboard Flash Data */
/*	Range value must be between [ 0x00, 0x8F ] 						*/

#define		IDX_F11				0x56
#define		IDX_F12				0x5E
#define		IDX_PRNTSCREEN		0x57
#define		IDX_SCROLL			0x5F
#define		IDX_PAUSE           0x62
#define		IDX_WLEFT           0x8B
#define		IDX_WRIGHT          0x8C
#define		IDX_WAPP            0x8D
#define		IDX_VERRN           0x76
#define		IDX_ALTGR           0x39
#define		IDX_PAGEUP          0x6F
#define		IDX_PAGEDN          0x6D
#define		IDX_END				0x65
#define		IDX_RUSSE			0x0E

/*	--------------------------------------------------------------	*/
/*	default values temperature */

#define		DEF_LEVELHTEMP		40
#define		DEF_LEVELLTEMP		35
#define		DEF_RCTN1			2700
#define		DEF_TEMP1			64 /* 63.6 deg C */
#define		DEF_RCTN2			3300
#define		DEF_TEMP2			57 /* 57.5 deg C */
#define		DEF_RCTN3			3900
#define		DEF_TEMP3			52 /* 52.3 deg C */
#define		DEF_RCTN4			4700
#define		DEF_TEMP4			47 /* 46.7 deg C */
#define		DEF_RCTN5			5600
#define		DEF_TEMP5			41 /* 41.5 deg C */
#define		DEF_RCTN6			6800
#define		DEF_TEMP6			36 /* 35.7 deg C */
#define		DEF_RCTN7			8200
#define		DEF_TEMP7			30 /* 30.5 deg C */
#define		DEF_RCTN8			10000
#define		DEF_TEMP8			25 /* 25.1 deg C */
#define		DEF_RCTN9			12000
#define		DEF_TEMP9			20 /* 20.1 deg C */
#define		DEF_RCTN10			15000
#define		DEF_TEMP10			15 /* 14.7 deg C */
#define		DEF_RCTN11			18000
#define		DEF_TEMP11			11 /* 10.6 deg C */
#define		DEF_RCTN12			22000
#define		DEF_TEMP12			6  /* 5.6 deg C */

/*	--------------------------------------------------------------	*/
/*	default values scan-code mouse */

#define		DEF_WHEELUP			0x59
#define		DEF_WHEELDN			0x5A
#define		DEF_WHEELLT			0x5C
#define		DEF_WHEELRT			0x5D
#define		DEF_BUTTON3			0x37
#define		DEF_BUTTON4			0x5E
#define		DEF_BUTTON5			0x5F
#define		DEF_WHREPEAT		0x03

/*	--------------------------------------------------------------	*/
/*	default values scan-code keyboard */

#define		DEF_SCROLL			0x4C
#define		DEF_PAGEUP          0x45
#define		DEF_PAGEDN          0x46
#define		DEF_END				0x55
#define		DEF_PRINTSCREEN		0x49
#define		DEF_PAUSE           0x4F
#define		DEF_VERRNUM         0x54
#define		DEF_WINLEFT         0x56
#define		DEF_WINRIGHT        0x57
#define		DEF_WINAPP          0x58
#define		DEF_RUSSE	        0x5B
#define		DEF_ALTGR           0x38		/*	Alt atari  */
#define		DEF_F11				0x62		/*	Help atari */
#define		DEF_F12				0x61		/*	Undi atari */

#define		DEF_POWER			0x73		/* Eiffel 1.0.5 set 2 */
#define		DEF_SLEEP			0x74		/* Eiffel 1.0.5 */
#define		DEF_WAKE			0x75		/* Eiffel 1.0.5 set 2 */

/*	--------------------------------------------------------------	*/

#define		PATH_LEN			2048
#define		FILENAME_LEN		256
#define		EXT_LEN				256

/*	--------------------------------------------------------------	*/

typedef struct
{
	long ident;
	union
	{
		long l;
		short i[2];
		char c[4];
	} v;
} COOKIE;


#endif
