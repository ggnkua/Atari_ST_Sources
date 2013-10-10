/*
 * Compute exact number of CPU cycles taken
 * by DIVU and DIVS on a 68000 processor.
 *
 * Copyright (c) 2005 by Jorge Cwik, pasti@fxatari.com
 *
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */


/*

 The routines below take dividend and divisor as parameters.
 They return 0 if division by zero, or exact number of cycles otherwise.

 The number of cycles returned assumes a register operand.
 Effective address time must be added if memory operand.

 For 68000 only (not 68010, 68012, 68020, etc).
 Probably valid for 68008 after adding the extra prefetch cycle.


 Best and worst cases for register operand:
 (Note the difference with the documented range.)


 DIVU:

 Overflow (always): 10 cycles.
 Worst case: 136 cycles.
 Best case: 76 cycles.


 DIVS:

 Absolute overflow: 16-18 cycles.
 Signed overflow is not detected prematurely.

 Worst case: 156 cycles.
 Best case without signed overflow: 122 cycles.
 Best case with signed overflow: 120 cycles

 
 */



// Change this depending on architecture
// This code assumes long is 32 bits and short is 16 bits

typedef unsigned long DWORD;
typedef unsigned short WORD;
typedef signed long LONG;
typedef signed short SHORT;


//
// DIVU
// Unsigned division
//

unsigned getDivu68kCycles( DWORD dividend, WORD divisor)
{
	unsigned mcycles;
	DWORD hdivisor;
	int i;

	if( (WORD) divisor == 0)
		return 0;

	// Overflow
	if( (dividend >> 16) >= divisor)
		return (mcycles = 5) * 2;

	mcycles = 38;
	hdivisor = divisor << 16;

	for( i = 0; i < 15; i++)
	{
		DWORD temp;
		temp = dividend;

		dividend <<= 1;

		// If carry from shift
		if( (LONG) temp < 0)
		{
			dividend -= hdivisor;
		}

		else
		{
			mcycles += 2;
			if( dividend >= hdivisor)
			{
				dividend -= hdivisor;
				mcycles--;
			}
		}
	}

	return mcycles * 2;
}

//
// DIVS
// Signed division
//

unsigned getDivs68kCycles( LONG dividend, SHORT divisor)
{
	unsigned mcycles;
	unsigned aquot;
	int i;

	if( (SHORT) divisor == 0)
		return 0;

	mcycles = 6;

	if( dividend < 0)
		mcycles++;

	// Check for absolute overflow
	if( ((DWORD) abs( dividend) >> 16) >= (WORD) abs( divisor))
	{
		return (mcycles + 2) * 2;
	}

	// Absolute quotient
	aquot = (DWORD) abs( dividend) / (WORD) abs( divisor);

	mcycles += 55;

	if( divisor >= 0)
	{
		if( dividend >= 0)
			mcycles--;
		else
			mcycles++;
	}

	// Count 15 msbits in absolute of quotient

	for( i = 0; i < 15; i++)
	{
		if( (SHORT) aquot >= 0)
			mcycles++;
		aquot <<= 1;
	}


	return mcycles * 2;
}
