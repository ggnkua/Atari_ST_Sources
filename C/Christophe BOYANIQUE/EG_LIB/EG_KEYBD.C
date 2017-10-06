/******************************************************************************/
/*	"Easy Gem" library Copyright (c)1994 by		Christophe BOYANIQUE				*/
/*																29 Rue R‚publique					*/
/*																37230 FONDETTES					*/
/*																FRANCE								*/
/*						*small* mail at email adress:	cb@spia.freenix.fr				*/
/******************************************************************************/
/*	This program is free software; you can redistribute it and/or modify it		*/
/*	under the terms of the GNU General Public License as published by the Free	*/
/*	Software Foundation; either version 2 of the License, or any later version.*/
/*	This program is distributed in the hope that it will be useful, but WITHOUT*/
/*	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or		*/
/* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for	*/
/*	more details.																					*/
/*	You should have received a copy of the GNU General Public License along		*/
/*	with this program; if not, write to the Free Software Foundation, Inc.,		*/
/*	675 Mass Ave, Cambridge, MA 02139, USA.												*/
/******************************************************************************/
/*																										*/
/*	THIS MODULE TRANSFORMS AN ASCII+SCAN CODES TO A NORMALIZED CODE.				*/
/*																										*/
/******************************************************************************/
/*	TABULATION: 3 CARACTERES																	*/
/******************************************************************************/

#include		"EG_MAIN.H"

/******************************************************************************/
/*	Transform a scan+ascii code to standard code											*/
/******************************************************************************/
int _traiteKey(int shift,int key)
{
	KEYTAB	*kt;
	int		scan,asc;
	int		std=0;

	asc=key&0xFF;
	scan=key>>8;

	if ( (asc!=0) && (scan==0) && (shift==0) )			/*	case of TOS intern	*/
		std=asc;						/*	handling with ALT+ascii or TSR like ACCENT	*/
	else
	{
		if (shift&0x01)			std|=KF_RSH;
		if (shift&0x02)			std|=KF_LSH;
		if (shift&0x04)			std|=KF_CTRL;
		if (shift&0x08)			std|=KF_ALT;
		if (Kbshift(-1)&0x10)	std|=KF_CAPS;

		switch	(scan)
		{
			case	0x3b:		case	0x54:		std|=K_F1|KF_FUNC;		break;
			case	0x3c:		case	0x55:		std|=K_F2|KF_FUNC;		break;
			case	0x3d:		case	0x56:		std|=K_F3|KF_FUNC;		break;
			case	0x3e:		case	0x57:		std|=K_F4|KF_FUNC;		break;
			case	0x3f:		case	0x58:		std|=K_F5|KF_FUNC;		break;
			case	0x40:		case	0x59:		std|=K_F6|KF_FUNC;		break;
			case	0x41:		case	0x5A:		std|=K_F7|KF_FUNC;		break;
			case	0x42:		case	0x5B:		std|=K_F8|KF_FUNC;		break;
			case	0x43:		case	0x5C:		std|=K_F9|KF_FUNC;		break;
			case	0x44:		case	0x5D:		std|=K_F10|KF_FUNC;		break;
			case	0x62:		std|=K_HELP|KF_FUNC;							break;
			case	0x61:		std|=K_UNDO|KF_FUNC;							break;
			case	0x52:		std|=K_INS|KF_FUNC;							break;
			case	0x77:
			case	0x47:		std|=K_CLRHOME|KF_FUNC;						break;
			case	0x48:		std|=K_UP|KF_FUNC;							break;
			case	0x50:		std|=K_DOWN|KF_FUNC;							break;
			case	0x74:
			case	0x4D:		std|=K_RIGHT|KF_FUNC;						break;
			case	0x73:
			case	0x4B:		std|=K_LEFT|KF_FUNC;							break;
		}
		if ( ((scan>=0x63)&&(scan<=0x71)) || (scan==0x4A) || (scan==0x4E) || (scan==0x72) ) std|=KF_NUM;
		if ((std&0xFF)==0)
		{
			kt=Keytbl((void *)-1,(void *)-1,(void *)-1);
			if ( (std&KF_ALT) && (asc!=0) )
				std|=asc;
			else if (std&KF_SHIFT)
				std|=(int)(kt->shift[scan])&0xFF;
			else if (std&KF_CAPS)
				std|=(int)(kt->capslock[scan])&0xFF;
			else
				std|=(int)(kt->unshift[scan])&0xFF;
		}
		switch	(std&0xFF)
		{
			case	K_BS:
			case	K_TAB:
			case	K_RET:
			case	K_ESC:
				case	K_DEL:
				std|=KF_FUNC;
				break;
		}
	}
	return std;
}
