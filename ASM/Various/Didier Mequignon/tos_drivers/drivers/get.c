#include "config.h"
#include <mint/osbind.h>
#include <string.h>
#include "ct60.h"
#include "get.h"
#include "../include/ramcf68k.h"

#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP)
extern void board_printf(const char *fmt, ...);
#else
#define board_printf
#endif

#define mac_addr *(unsigned long *)(mac_address)
#define client_ip_addr *(unsigned long *)(ip_address)
#define server_ip_addr *(unsigned long *)(server_ip_address)

#ifdef NETWORK

unsigned char *board_get_ethaddr(unsigned char *ethaddr)
{
	int i = 0;
	if((mac_addr != 0xFFFFFFFF) && (mac_addr != 0))
	{
		ethaddr[0] = 0x00;
		ethaddr[1] = 0xCF;
		ethaddr[2] = 0x54;
		ethaddr[3] = (unsigned char)((mac_addr >> 16) & 0xFF);
		ethaddr[4] = (unsigned char)((mac_addr >> 8) & 0xFF);
		ethaddr[5] = (unsigned char)(mac_addr & 0xFF);
	}
	else
	{
		for(i = 0; i < 6; i++)
			ethaddr[i] = ((PARAM *)PARAMS_ADDRESS)->ethaddr[i];
	}	
	board_printf("ethaddr from %s", i ? "dBUG set" : "flash params");
	for(i = 0; i < 6; board_printf(":%02X", ethaddr[i++]));
	board_printf("\r\n");
	return ethaddr;
}

unsigned char *board_get_client(unsigned char *client)
{
	int i = 0;
	if((client_ip_addr != 0xFFFFFFFF) && (client_ip_addr & 0xFFFF0000))
		memcpy(client, &client_ip_addr, 4);	
	else
	{
		for(i = 0; i < 4; i++)
			client[i] = ((PARAM *)PARAMS_ADDRESS)->client[i];
	}
	board_printf("board IP from %s: ", i ? "dBUG set" : "flash params");
	for(i = 0; i < 4; i++)
	{
		board_printf("%d", client[i]);
		if(i < 3)
			board_printf(".");	
	}
	board_printf("\r\n");
	return client;
}

unsigned char *board_get_server(unsigned char *server)
{
	int i = 0;
	if((server_ip_addr != 0xFFFFFFFF) && (server_ip_addr & 0xFFFF0000))
		memcpy(server, &server_ip_addr, 4);	
	else
	{
		for(i = 0; i < 4; i++)
			server[i] = ((PARAM *)PARAMS_ADDRESS)->server[i];
	}
	board_printf("host IP from %s: ", i ? "dBUG set" : "flash params");
	for(i = 0; i < 4; i++)
	{
		board_printf("%d", server[i]);
		if(i < 3)
			board_printf(".");	
	}
	board_printf("\r\n");
	return server;
}

unsigned char *board_get_gateway(unsigned char *gateway)
{
	if((client_ip_addr != 0xFFFFFFFF) && (client_ip_addr & 0xFFFF0000))
		gateway[0] = gateway[1] = gateway[2] = gateway[3] = 0;
	else
	{
		int i;
		for(i = 0; i < 4; i++)
			gateway[i] = ((PARAM *)PARAMS_ADDRESS)->gateway[i];
	}
	return gateway;
}

unsigned char *board_get_netmask(unsigned char *netmask)
{
	int i = 0;
	if((client_ip_addr != 0xFFFFFFFF) && (client_ip_addr & 0xFFFF0000))
	{
		netmask[0] = 0xFF;
		if(client_ip_addr <= 0x80000000)
		{
			if((client_ip_addr & 0xFF000000) == 0x0A000000)
			{
				netmask[1] = 0xFF;
				netmask[2] = 0xFF;
			}
			else
			{
				netmask[1] = 0x00;
				netmask[2] = 0x00;
			}
		}
		else if(client_ip_addr <= 0xC0000000)
		{
			netmask[1] = 0xFF;
			netmask[2] = 0x00;
		}
		else
		{
			netmask[1] = 0xFF;
			netmask[2] = 0xFF;
		}
		netmask[3] = 0x00;
	}
	else
	{
		for(i = 0; i < 4; i++)
			netmask[i] = ((PARAM *)PARAMS_ADDRESS)->netmask[i];
	}
	board_printf("netmask from %s: ", i ? "dBUG set" : "host IP");
	for(i = 0; i < 4; i++)
	{
		board_printf("%d", netmask[i]);
		if(i < 3)
			board_printf(".");	
	}
	board_printf("\r\n");
	return netmask;
}

char *board_get_filename(char *filename)
{
	int i = 0;
	char c;
	if((client_ip_addr != 0xFFFFFFFF) && (client_ip_addr & 0xFFFF0000))
	 	strcpy(filename, "/home/firetos.hex");
	else
	{
		while(i < FILENAME_SIZE)
		{
			c = ((PARAM *)PARAMS_ADDRESS)->filename[i];
			filename[i++] = c;
			if(c == '\0')
				i = FILENAME_SIZE;
		}
		filename[i] = '\0';
	}
	board_printf("filename from %s: %s\r\n", i ? "dBUG set" : "default", filename);
	return filename;
}

#endif /* NETWORK */

