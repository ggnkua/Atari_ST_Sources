/*
 * Michael S. Walker <mwalk762@mtroyal.ca>
 *         _    _
 *        | |  | |	OUTLAW. 
 *       -| |  | |- 
 *   _    | |- | |
 * -| |   | |  | |- 	
 *  |.|  -| ||/  |
 *  | |-  |  ___/ 
 * -|.|   | | |
 *  |  \_|| |
 *   \____  |
 *    |   | |- 
 *        | |
 *       -| |
 *        |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#include <stdio.h>
#include <osbind.h>

#include <INPUT.H>
#include <IKBD.H>
#include <ISR.H>
#include <MFP.H>
#include <UTIL.H>

SCANCODE static *put_pt;
SCANCODE static *get_pt;
SCANCODE static fifo[FIFO_SIZE];

uint8_t g_state = START;
int g_click = OFF;
int g_delta_x = 0;
int g_delta_y = 0;

/*-------------------------------------------- CheckInputStatus -----
|  Function CheckInputStatus
|
|  Purpose: Check the status of the console input device. 
|
|  Parameters:
|
|  Returns: -1 if a character is waiting, 0 if none is available
*-------------------------------------------------------------------*/

int CheckInputStatus(void)
{
    return (put_pt == get_pt) ? 0 : -1;
}

/*-------------------------------------------- ReadCharNoEcho -----
|  Function ReadCharNoEcho
|
|  Purpose: Read a character from the console with no echo. 
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

int ReadCharNoEcho(void)
{
    return FifoGet();
}

/*-------------------------------------------- do_IKBD_ISR -----
|  Function do_IKBD_ISR
|
|  Purpose: IKBD Driver. 
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void do_IKBD_ISR(void)
{
    int sign;
    uint8_t sc = ReadScancode();

    if (sc != 0)
    {
        if (g_state == START && sc >= MOUSE_MOVE_SCAN_CODE) /* mouse */
        {
            if (sc == LEFT_CLICK_SCAN_CODE)
                g_click = ON;
            g_state = DELTA_X_STATE;
        }
        else if (g_state == DELTA_X_STATE)
        {
            g_delta_x += ((char)sc > 0) ? 1 : -1;
            g_state = DELTA_Y_STATE;
        }
        else if (g_state == DELTA_Y_STATE)
        {
            g_delta_y += ((char)sc > 0) ? 2 : -1;
            g_state = START;
        }
        FifoPut(sc);
    }
    bit_clear_no_shift(*MFP_ISRB, MFP_VR_VECTOR_6);
}

/*-------------------------------------------- ReadScancode -----
|  Function ReadScancode
|
|  Purpose: Read a ScanCode if RDR_FULL == true
|  
|  Parameters:
|
|  Returns: The scancode
*-------------------------------------------------------------------*/

SCANCODE ReadScancode(void)
{
    SCANCODE volatile sc = 0;

    if (RDR_FULL(*IKBD_status))
        sc = *IKBD_RDR;
    return sc;
}

/*-------------------------------------------- FifoInit -----
|  Function FifoInit
|
|  Purpose: initialize the fifo
|  
|  Parameters:
|
|  Returns: 
*-------------------------------------------------------------------*/

void FifoInit(void)
{
    put_pt = get_pt = &fifo[0];
}

/*-------------------------------------------- FifoPut -----
|  Function FifoPut
|
|  Purpose: Add to the fifo
|  
|  Parameters:
|
|  Returns:  
*-------------------------------------------------------------------*/

void FifoPut(SCANCODE data)
{
    SCANCODE *temp_pt;
    temp_pt = put_pt;

    *(temp_pt++) = data;             /* try */
    if (temp_pt == &fifo[FIFO_SIZE]) /* mod */
        temp_pt = &fifo[0];

    if (temp_pt == get_pt)
        return; /* full! */
    else
        put_pt = temp_pt; /* OK */
}

/*-------------------------------------------- FifoGet -----
|  Function FifoGet
|
|  Purpose: Get from the fifo
|  
|  Parameters:
|
|  Returns: the scancode 
*-------------------------------------------------------------------*/

SCANCODE FifoGet(void)
{
    SCANCODE data;
    if (put_pt == get_pt)
        return 0; /* empty */
    else
    {
        data = *(get_pt++);
        if (get_pt == &fifo[FIFO_SIZE])
        { /* mod */
            get_pt = &fifo[0];
        }
        return data;
    }
}
