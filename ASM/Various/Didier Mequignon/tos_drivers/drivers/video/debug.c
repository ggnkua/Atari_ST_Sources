/* VDI driver for the CT60/CTPCI boards
 * Didier Mequignon 2005-2009, e-mail: aniplay@wanadoo.fr
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "fb.h"

void debug_print(const char *string)
{
	if(debug)
		Funcs_puts(string);
}

void debug_print_value(const char *string, long val)
{
	static char buf[16];
	if(debug)
	{
		Funcs_puts(string);
		Funcs_ltoa(buf,val,10);
		Funcs_puts(buf);
	}	
}

void debug_print_value_hex(const char *string, long val)
{
	static char buf[16];
	if(debug)
	{
		Funcs_puts(string);
		Funcs_puts("0x");		
		Funcs_ltoa(buf,val,16);
		Funcs_puts(buf);
	}	
}

void debug_print_value_hex_byte(const char *string, unsigned char val)
{
	static char buf[16];
	if(debug)
	{
		Funcs_puts(string);
		if(val & 0xF0)
			Funcs_ltoa(buf,(unsigned long)val,16);
		else
		{
			val += 0x10;
			Funcs_ltoa(buf,(unsigned long)val,16);
			buf[0]='0';
		}
		Funcs_puts(buf);
	}	
}

void debug_print_value_hex_word(const char *string, unsigned short val)
{
	static char buf[16];
	if(debug)
	{
		Funcs_puts(string);
		if(val & 0xF000)
			Funcs_ltoa(buf,(unsigned long)val,16);
		else
		{
			val += 0x1000;
			Funcs_ltoa(buf,(unsigned long)val,16);
			buf[0]='0';
		}
		Funcs_puts(buf);
	}	
}

void debug_print_value_hex_long(const char *string, unsigned long val)
{
	static char buf[16];
	if(debug)
	{
		Funcs_puts(string);
		if(val & 0xF0000000)
			Funcs_ltoa(buf,val,16);
		else
		{
			val += 0x10000000;
			Funcs_ltoa(buf,val,16);
			buf[0]='0';
		}
		Funcs_puts(buf);
	}	
}
