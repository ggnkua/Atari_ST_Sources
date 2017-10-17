/*
 * File:        net_timer.c
 * Purpose:     Provide a timer use by the dBUG network as a timeout
 *              indicator
 *
 * Notes:
 */
#include <osbind.h>
#include "config.h"
#include "net.h"

#ifdef NETWORK
#ifndef LWIP

static uint32 start_timer[4];
static uint32 timeout[4];

uint32 read_hz_200(void)
{
	return(*(uint32 *)0x4BA); /* _hz_200 */
}

uint32 timer_set_secs(uint8 ch, uint32 secs)
{
	ch &=3;
	timeout[ch] = secs * 200;
	start_timer[ch] = read_hz_200(); // Supexec(read_hz_200);
	return TRUE;
}

uint32 timer_get_reference(uint8 ch)
{   
	uint32 val_timer;
	ch &= 3;
	val_timer = read_hz_200(); // Supexec(read_hz_200);
	if(val_timer >= (start_timer[ch]+timeout[ch]))
		return FALSE; /* the desired seconds have expired */
	return TRUE;
}

#endif /* LWIP */
#endif /* NETWORK */
