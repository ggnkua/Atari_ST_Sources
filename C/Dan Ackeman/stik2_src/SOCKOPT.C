/* 
 * Socket Options routines
 *
 * version 	0.1 
 * date		august 18, 1997
 * author	Dan Ackerman (baldrick@zeus.netset.com)
 *
 */

#include "lattice.h"
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "globdefs.h"
#include "globdecl.h"
#include "krmalloc.h"

extern CCB ctn[];  /* Connection Control Block list */

/*
 * OPTIONS That 'should' be implemented (partial list of ones in front of me atm)
 *
 * IP_TOS		- ip_send now uses this, So this is now needed
 * IP_TTL		- ip_send now uses this, So this is now needed
 *
 * There are many others for routing, ip_options etc that are not needed
 * 		at the moment.
 * 
 *  Dan Ackerman
 */

/* Option defines are in IP.H 
 * 
 * Note: Need to get IP_HDRINCL in here as well for RAW_IP.C 
 */

int16 cdecl 
CN_setopt(int16 cn, int16 optname, const void *optval, int16 optlen)
{
	(void) optlen;
	/* Check if cn is valid and in use 
	 *
	 * NOTE: We need to look at protocol = 0 being unused
	 *
	 * We could move this to the IS_CONNECTED flag in the ctn[cn].flags
	 *
	 */

    if (cn < 0 || cn >= CNMAX || ctn[cn].protocol == 0)
        return (E_BADHANDLE);

	/* Check if optname is in range */

	if (optname < IP_HDRINCL || optname > IP_TTL)
		return (E_PARAMETER);

	switch(optname)
		{
			case IP_HDRINCL:
				if (ctn[cn].protocol == IPPROTO_RAW)
					{
						if (ctn[cn].inp_flags & IP_HDRINCL)
							ctn[cn].inp_flags &= ~IP_HDRINCL; /* clear it */
						else
							ctn[cn].inp_flags |= IP_HDRINCL; /* set it */
					
						return(E_NORMAL);
					}
				else
					return (E_PARAMETER); /* Only RAW CCB's can handle this option */
		
			case IP_TOS:
				ctn[cn].ip.tos = (uint8)optval;
				return(E_NORMAL);
			
			case IP_TTL:
				ctn[cn].ip.ttl = (uint8)optval;
				return(E_NORMAL);
			
			default:
				return (E_PARAMETER);
		}

	/* Should never get here */
}

int16 cdecl
CN_getopt(int16 cn, int16 optname, void *optval, int16 *optlen)
{
	/* Check if cn is valid and in use 
	 *
	 * NOTE: We need to look at protocol = 0 being unused
	 * 			This negates IP CCB's which could be useful
	 */

    if (cn < 0 || cn >= CNMAX || ctn[cn].protocol == 0)
        return (E_BADHANDLE);

	/* Check if optname is in range */

	if (optname < IP_HDRINCL || optname > IP_TTL)
		return (E_PARAMETER);

	switch(optname)
		{
			case IP_HDRINCL:
				if (ctn[cn].protocol == IPPROTO_RAW)
					{
						*optlen = (int16)sizeof(int16);
						
						*((int16 *)optval) = ctn[cn].inp_flags & IP_HDRINCL;

						return(E_NORMAL);
					}
				else
					return (E_PARAMETER); /* Only RAW CCB's can handle this option */
		
			case IP_TOS:
				*optlen = (int16)sizeof(uint8);
				*((uint8 *)optval) = ctn[cn].ip.tos;
				return(E_NORMAL);
			
			case IP_TTL:
				*optlen = (int16)sizeof(uint8);
				*((uint8 *)optval) = ctn[cn].ip.ttl;
				return(E_NORMAL);
			
			default:
				return (E_PARAMETER);
		}

	/* Should never get here */
}
