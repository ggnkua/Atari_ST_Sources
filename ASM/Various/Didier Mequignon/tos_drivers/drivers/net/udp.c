/*
 * File:        udp.c
 * Purpose:     User Datagram Protocol driver
 *
 * Notes:
 *
 * Modifications:
 *
 */
#include <osbind.h>
#include "config.h"
#include "net.h"

#ifdef NETWORK
#ifndef LWIP

/********************************************************************/
typedef struct
{
    uint16 port;
    void (*handler)(NIF *, NBUF *);

} UDP_BOUND_PORT;

/********************************************************************/

#define UDP_MAX_PORTS   (5)     /* plenty for this implementation */


static UDP_BOUND_PORT
udp_port_table[UDP_MAX_PORTS];

static uint16
udp_port;

/********************************************************************/
void
udp_init (void)
{
    int index;

    for (index = 0; index < UDP_MAX_PORTS; ++index)
    {
        udp_port_table[index].port = 0;
    }

    udp_port = DEFAULT_UDP_PORT;    /* next free port */
}
/********************************************************************/
void
udp_prime_port (uint16 init_port)
{
    udp_port = init_port;
}
/********************************************************************/
void
udp_bind_port (uint16 port, void (*handler)(NIF *, NBUF *))
{
    int index;

    for (index = 0; index < UDP_MAX_PORTS; ++index)
    {
        if (udp_port_table[index].port == 0)
        {
            udp_port_table[index].port = port;
            udp_port_table[index].handler = handler;
            return;
        }
    }
}
/********************************************************************/
void
udp_free_port (uint16 port)
{
    int index;

    for (index = 0; index < UDP_MAX_PORTS; ++index)
    {
        if (udp_port_table[index].port == port)
        {
            udp_port_table[index].port = 0;
            return;
        }
    }
}
/********************************************************************/
static void *
udp_port_handler (uint16 port)
{
    int index;

    for (index = 0; index < UDP_MAX_PORTS; ++index)
    {
        if (udp_port_table[index].port == port)
        {
            return (void *)udp_port_table[index].handler;
        }
    }
    return NULL;
}
/********************************************************************/
uint16
udp_obtain_free_port (void)
{
    uint16 port;

    port = udp_port;
    if (--udp_port <= 255)
        udp_port = DEFAULT_UDP_PORT;

    return port;
}
/********************************************************************/
int
udp_send ( NIF *nif, uint8 *dest, int sport, int dport, NBUF *pNbuf)
{
    /*
     * This function takes data and creates a UDP frame and
     * passes it onto the IP layer
     */
    udp_frame_hdr   *udpframe;

    udpframe = (udp_frame_hdr *)&pNbuf->data[UDP_HDR_OFFSET];

    /* Set UDP source port */
    udpframe->src_port = (uint16)sport;

    /* Set UDP destination port */
    udpframe->dest_port = (uint16)dport;

    /* Set length */
    udpframe->length = (uint16)(pNbuf->length + UDP_HDR_SIZE);

    /* No checksum calcualation needed */
    udpframe->chksum = (uint16)0;

    /* Add the length of the UDP packet to the total length of the packet */
    pNbuf->length += 8;

    return (ip_send(nif,
                    dest,
                    ip_get_myip(nif_get_protocol_info(nif,ETH_FRM_IP)),
                    IP_PROTO_UDP,
                    pNbuf));
}
/********************************************************************/
void
udp_handler (NIF *nif, NBUF *pNbuf)
{
    /*
     * This function handles incoming UDP packets
     */
    udp_frame_hdr   *udpframe;
    void (*handler)(NIF *, NBUF *);

    udpframe = (udp_frame_hdr *)&pNbuf->data[pNbuf->offset];

    /*
     * Adjust the length and valid data offset of the packet we are
     * passing on
     */
    pNbuf->length -= UDP_HDR_SIZE;
    pNbuf->offset += UDP_HDR_SIZE;

    /*
     * Traverse the list of bound ports to see if there is a higher
     * level protocol to pass the packet on to
     */
    if ((handler = (void(*)(NIF*,NBUF*))udp_port_handler(UDP_DEST(udpframe))) != NULL)
        handler(nif, pNbuf);
    else
    {
        #ifdef DEBUG_PRINT
            Cconws("Received UDP packet for non-supported port\r\n");
        #endif
        nbuf_free(pNbuf);
    }

    return;
}
/********************************************************************/

#endif /* LWIP */
#endif /* NETWORK */
