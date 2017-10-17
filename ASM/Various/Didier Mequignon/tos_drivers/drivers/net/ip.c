/*
 * File:        ip.c
 * Purpose:     Internet Protcol device driver
 *
 * Notes:
 *
 * Modifications:
 */
#include <osbind.h>
#include "config.h"
#include "net.h"

#ifdef NETWORK
#ifndef LWIP

extern void ltoa(char *buf, long n, unsigned long base);

/********************************************************************/
void
ip_init(IP_INFO *info,
        IP_ADDR_P myip,
        IP_ADDR_P gateway,
        IP_ADDR_P netmask)
{
    int index;

    for (index = 0; index < sizeof(IP_ADDR); index++)
    {
        info->myip[index] = myip[index];
        info->gateway[index] = gateway[index];
        info->netmask[index] = netmask[index];
        info->broadcast[index] = 0xFF;
    }

    info->rx = 0;
    info->rx_unsup = 0;
    info->tx = 0;
    info->err = 0;
}
/********************************************************************/
uint8 *
ip_get_myip (IP_INFO *info)
{
    if (info != 0)
    {
        return (uint8 *)&info->myip[0];
    }
    return 0;
}
/********************************************************************/
int
ip_addr_compare (IP_ADDR_P addr1, IP_ADDR_P addr2)
{
    int i;

    for (i = 0; i < sizeof(IP_ADDR); i++)
    {
        if (addr1[i] != addr2[i])
            return 0;
    }
    return 1;
}
/********************************************************************/
uint8 *
ip_resolve_route (NIF *nif, IP_ADDR_P destip)
{
    /*
     * This function determines whether or not an outgoing IP
     * packet needs to be transmitted on the local net or sent
     * to the router for transmission.
     */
    IP_INFO *info;
    IP_ADDR mask,result;
    int i;

    info = nif_get_protocol_info(nif,ETH_FRM_IP);

    /* create mask for local IP */
    for (i = 0; i < sizeof(IP_ADDR); i++)
    {
        mask[i] = info->myip[i] & info->netmask[i];
    }

    /* apply mask to the destination IP */
    for (i = 0; i < sizeof(IP_ADDR); i++)
    {
        result[i] = mask[i] & destip[i];
    }

    /* See if destination IP is local or not */
    if (ip_addr_compare(mask,result))
    {
        /* The destination IP is on the local net */
        return arp_resolve(nif,ETH_FRM_IP,destip);
    }
    else
    {
        /* The destination IP is not on the local net */
        return arp_resolve(nif,ETH_FRM_IP,info->gateway);
    }
}
/******************************************************************/
int
ip_send (NIF *nif, uint8 *dest, uint8 *src, uint8 protocol, NBUF *pNbuf)
{
    /*
     * This function assembles an IP datagram and passes it
     * onto the hardware to be sent over the network.
     */
    uint8 *route;
    ip_frame_hdr *ipframe;

    /*
     * Construct the IP header
     */
    ipframe = (ip_frame_hdr*)&pNbuf->data[IP_HDR_OFFSET];

    /* IP version 4, Internet Header Length of 5 32-bit words */
    ipframe->version_ihl = 0x45;

    /* Type of Service == 0, normal and routine */
    ipframe->service_type = 0x00;

    /* Total length of data */
    ipframe->total_length = (uint16)(pNbuf->length + IP_HDR_SIZE);

    /* User defined identification */
    ipframe->identification = 0x0000;

    /* Fragment Flags and Offset -- Don't fragment, last frag */
    ipframe->flags_frag_offset = 0x0000;

    /* Time To Live */
    ipframe->ttl = 0xFF;

    /* Protocol */
    ipframe->protocol = protocol;

    /* Checksum, computed later, zeroed for computation */
    ipframe->checksum = 0x0000;

    /* source IP address */
    ipframe->source_addr[0] = src[0];
    ipframe->source_addr[1] = src[1];
    ipframe->source_addr[2] = src[2];
    ipframe->source_addr[3] = src[3];

    /* dest IP address */
    ipframe->dest_addr[0] = dest[0];
    ipframe->dest_addr[1] = dest[1];
    ipframe->dest_addr[2] = dest[2];
    ipframe->dest_addr[3] = dest[3];
    
    /* Compute checksum */
    ipframe->checksum = ip_chksum((uint16 *)ipframe,IP_HDR_SIZE);

    /* Increment the packet length by the size of the IP header */
    pNbuf->length += IP_HDR_SIZE;

    /*
     * Determine the hardware address of the recipient
     */
    route = ip_resolve_route(nif, dest);
    if (route == NULL)
    {
        char buf[10];
        int i;
        Cconws("Unable to locate ");
        for (i = 0; i < 4; i++)
        {
            ltoa(buf, dest[i], 10);
            Cconws(buf);
            if(i < 3)
                Cconout('.');
        }
        Cconws("\r\n");
        return 0;
    }

    return nif->send(route,
                     &nif->hwa[0],
                     ETH_FRM_IP,
                     pNbuf
                     );
}
/******************************************************************/
#if defined(DEBUG_PRINT)
void
dump_ip_frame (ip_frame_hdr *ipframe)
{
    char buf[10];
    int i;
    Cconws("Version:  0x");
    ltoa(buf, ((ipframe->version_ihl & 0x00f0) >> 4), 16);
    Cconws(buf);
    Cconws("IHL:      0x");
    ltoa(buf, ipframe->version_ihl & 0x000f, 16);
    Cconws(buf);
    Cconws("Service:  0x");
    ltoa(buf, ipframe->service_type, 16);
    Cconws(buf);
    Cconws("Length:   0x");
    ltoa(buf, ipframe->total_length, 16);
    Cconws(buf);
    Cconws("Ident:    0x");
    ltoa(buf, ipframe->identification, 16);
    Cconws(buf);
    Cconws("Flags:    0x");
    ltoa(buf, ((ipframe->flags_frag_offset & 0xC000) >> 14), 16);
    Cconws(buf);
    Cconws("Frag:     0x");
    ltoa(buf, ipframe->flags_frag_offset & 0x3FFF, 16);
    Cconws(buf);
    Cconws("TTL:      0x");
    ltoa(buf, ipframe->ttl, 16);
    Cconws(buf);
    Cconws("Protocol: 0x");
    ltoa(buf, ipframe->protocol, 16);
    Cconws(buf);
    Cconws("Chksum:   0x");
    ltoa(buf, ipframe->checksum, 16);
    Cconws(buf);
    Cconws("Source  : ");
    for (i = 0; i < 4; i++)
    {
        ltoa(buf, ipframe->source_addr[i], 10);
        Cconws(buf);
        if(i < 3)
            Cconout('.');
    }
    Cconws("\r\n");
    Cconws("Dest    : ");
    for (i = 0; i < 4; i++)
    {
        ltoa(buf, ipframe->dest_addr[i], 10);
        Cconws(buf);
        if(i < 3)
            Cconout('.');
    }
    Cconws("\r\n");
    Cconws("Options: 0x");
    ltoa(buf, ipframe->options, 16);
    Cconws(buf); 
}
#endif
/******************************************************************/
uint16
ip_chksum (uint16 *data, int num)
{
    int chksum, ichksum;
    uint16 temp;

    chksum = 0;
    num = num >> 1; /* from bytes to words */
    for (; num; num--, data++)
    {
        temp = *data;
        ichksum = chksum + temp;
        ichksum = ichksum & 0x0000FFFF;
        if ((ichksum < temp) || (ichksum < chksum))
        {
            ichksum += 1;
            ichksum = ichksum & 0x0000FFFF;
        }
        chksum = ichksum;
    }
    return (uint16)~chksum;
}
/******************************************************************/
static int
validate_ip_hdr (NIF *nif, ip_frame_hdr *ipframe)
{
    int index, chksum;
    IP_INFO *info;

    /*
     * Check the IP Version
     */
    if (IP_VERSION(ipframe) != 4)
        return 0;

    /*
     * Check Internet Header Length
     */
    if (IP_IHL(ipframe) < 5)
        return 0;

    /*
     * Check the destination IP address
     */
    info = nif_get_protocol_info(nif,ETH_FRM_IP);
    for (index = 0; index < sizeof(IP_ADDR); index++)
        if (info->myip[index] != ipframe->dest_addr[index])
            return 0;

    /*
     * Check the checksum
     */
    chksum = (int)((uint16)IP_CHKSUM(ipframe));
    IP_CHKSUM(ipframe) = 0;

    if (ip_chksum((uint16 *)ipframe,IP_IHL(ipframe)*4) != chksum)
        return 0;

    IP_CHKSUM(ipframe) = (uint16)chksum;

    return 1;
}
/******************************************************************/
void
ip_handler (NIF *nif, NBUF *pNbuf)
{
    /*
     * IP packet handler
     */
    ip_frame_hdr *ipframe;

    ipframe = (ip_frame_hdr *)&pNbuf->data[pNbuf->offset];

    /*
     * Verify valid IP header and destination IP
     */
    if (!validate_ip_hdr(nif,ipframe))
    {
        nbuf_free(pNbuf);
        return;
    }

    pNbuf->offset += (IP_IHL(ipframe) * 4);
    pNbuf->length = (uint16)(IP_LENGTH(ipframe) - (IP_IHL(ipframe) * 4));

    /*
     * Call the appriopriate handler
     */
    switch (IP_PROTOCOL(ipframe))
    {
        case IP_PROTO_ICMP:
            icmp_handler(nif,pNbuf);
            break;
        case IP_PROTO_UDP:
            udp_handler(nif,pNbuf);
            break;
        default:
            nbuf_free(pNbuf);
            break;
    }
    return;
}
/******************************************************************/

#endif /* LWIP */
#endif /* NETWORK */
