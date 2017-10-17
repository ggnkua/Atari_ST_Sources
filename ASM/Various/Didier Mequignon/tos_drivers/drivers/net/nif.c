/*
 * File:		nif.c
 * Purpose:		Network InterFace routines
 *
 * Notes:
 *
 * Modifications:
 *
 */

#include "config.h"
#include "net.h"

#ifdef NETWORK
#ifndef LWIP

/********************************************************************/

/*
 * Declare two network interfaces
 */
NIF nif[2];

/********************************************************************/
int
nif_protocol_exist (NIF *nif, uint16 protocol)
{
	/*
	 * This function searches the list of supported protocols
	 * on the particular NIF and if a protocol handler exists,
	 * TRUE is returned.  This function is useful for network cards
	 * that needn't read in the entire frame but can discard frames
	 * arbitrarily.
	 */
	int index;

	for (index = 0; index < nif->num_protocol; ++index)
	{
		if (nif->protocol[index].protocol == protocol)
		{
			return TRUE;
		}
	}
	return FALSE;
}

/********************************************************************/
void
nif_protocol_handler (NIF *nif, uint16 protocol, NBUF *pNbuf)
{
	/*
	 * This function searches the list of supported protocols
	 * on the particular NIF and if a protocol handler exists,
	 * the protocol handler is invoked.  This routine called by
	 * network device driver after receiving a frame.
	 */
	int index;

	for (index = 0; index < nif->num_protocol; ++index)
	{
		if (nif->protocol[index].protocol == protocol)
			nif->protocol[index].handler(nif,pNbuf);
	}
}

/********************************************************************/
void *
nif_get_protocol_info (NIF *nif, uint16 protocol)
{
	/*
	 * This function searches the list of supported protocols
	 * on the particular NIF and returns a pointer to the
	 * config info for 'protocol', otherwise NULL is returned.
	 */
	int index;

	for (index = 0; index < nif->num_protocol; ++index)
	{
		if (nif->protocol[index].protocol == protocol)
			return (void *)nif->protocol[index].info;
	}
	return (void *)0;
}

/********************************************************************/
int
nif_bind_protocol (NIF *nif, uint16 protocol,
                   void (*handler)(NIF *,NBUF *),
                   void *info)
{
	/*
	 * This function registers 'protocol' as a supported
	 * protocol in 'nif'.  
	 */
	if (nif->num_protocol < (MAX_SUP_PROTO - 1))
	{
		nif->protocol[nif->num_protocol].protocol = protocol;
		nif->protocol[nif->num_protocol].handler = (void(*)(NIF*,NBUF*))handler;
		nif->protocol[nif->num_protocol].info = info;
		++nif->num_protocol;
		return TRUE;
	}
	return FALSE;
}

/********************************************************************/
NIF *
nif_init (NIF *nif)
{
	int i;

	for (i = 0; i < ETH_ADDR_LEN; ++i)
	{
		nif->hwa[i] = 0;
		nif->broadcast[i] = 0xFF;
	}

	for (i = 0; i < MAX_SUP_PROTO; ++i)
	{
		nif->protocol[i].protocol = 0;
		nif->protocol[i].handler = 0;
		nif->protocol[i].info = 0;
	}
	nif->num_protocol = 0;

	nif->mtu = 0;

    return nif;
}
/********************************************************************/

#endif /* LWIP */
#endif /* NETWORK */
