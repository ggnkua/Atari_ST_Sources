/**
 * Thing
 * Copyright (C) 1994-2012 Arno Welzel, Thomas Binder
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 *
 * @copyright  Arno Welzel, Thomas Binder 1994-2012
 * @author     Arno Welzel, Thomas Binder
 * @license    LGPL
 */

#include <portab.h>
#include <string.h>
#include "..\include\thingtbx.h"


WORD getSystemLanguage(BYTE *sysLanguageCode, BYTE *sysLanguageCodeLong )
{
	WORD out[4];
	LONG value;
   
	value = 0;

	if (appl_getinfo(3, &out[0], &out[1], &out[2], &out[3]) == 1)
		value = (LONG) out[0];
  else
  {
		if (getCookie('_AKP', &value))
			value >>= 8;
	}

	switch ( (int) value )
	{
		case 0:
	   strcpy ( sysLanguageCode, "en" );
	     strcpy ( sysLanguageCodeLong, "english" );
		break;
		case 1:
	     strcpy ( sysLanguageCode, "de" );
	     strcpy ( sysLanguageCodeLong, "german" );
		break;
		case 2:
	     strcpy ( sysLanguageCode, "fr" );
	     strcpy ( sysLanguageCodeLong, "french" );
		break;
		case 5:
	     strcpy ( sysLanguageCode, "it" );
	     strcpy ( sysLanguageCodeLong, "italy" );
		break;
		default:
		  strcpy ( sysLanguageCode, "en" );
	     strcpy ( sysLanguageCodeLong, "english" );
		break;
	}

	return 1;
}
