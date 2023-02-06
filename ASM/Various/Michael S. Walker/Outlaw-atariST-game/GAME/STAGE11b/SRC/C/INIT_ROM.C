/*
 * Michael S. Walker <mwalk762@mtroyal.ca>
 *	    _    _
 *       | |  | |	OUTLAW. 
 *      -| |  | |- 
 *  _    | |- | |
 *-| |   | |  | |- 	
 * |.|  -| ||/  |
 * | |-  |  ___/ 
 *-|.|   | | |
 * |  \_|| |
 *  \____  |
 *   |   | |- 
 *       | |
 *      -| |
 *       |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#include <INIT_ROM.H>

#define OS_ROM_START ((Vector)0xFC0030)
#define TRAP_1 33

typedef void (*Vector)();

Vector *const vector_table = 0x000000;

volatile char *const MFP_VR = 0xFFFA17;
volatile char *const IKBD_ACIA_CR = 0xFFFC00;
volatile char *const MIDI_ACIA_CR = 0xFFFC04;

/*-------------------------------------------- init -----
|  Function init
|
|  Purpose:
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void init()
{
	init_IO();
	init_vector_table();
}

/*-------------------------------------------- init_IO -----
|  Function init_IO
|
|  Purpose: 
|
|  Parameters: 
|
|  Returns:
*-------------------------------------------------------------------*/

void init_IO()
{
	/* note: memory & video already configured (in start.s) */

	*MFP_VR = 0x48;

	*IKBD_ACIA_CR = 0x57;
	*IKBD_ACIA_CR = 0x56;

	*MIDI_ACIA_CR = 0x57;
	*MIDI_ACIA_CR = 0x55;
}

/*-------------------------------------------- init_vector_table -----
|  Function init_vector_table
|
|  Purpose:  
|
|  Parameters: 
|
|  Returns:
*-------------------------------------------------------------------*/

void init_vector_table()
{
	/* note: first 2 vectors are ROM */

	int vect_num;

	for (vect_num = 2; vect_num < 256; vect_num++)
		vector_table[vect_num] = OS_ROM_START;

	vector_table[TRAP_1] = do_super;
}