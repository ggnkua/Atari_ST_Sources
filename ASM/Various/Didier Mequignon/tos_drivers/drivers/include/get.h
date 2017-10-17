/*
 * File:        get.h
 * Purpose:     Definitions for common parameters
 *
 * Notes:
 */

#ifndef _SETGET_H_
#define _SETGET_H_

#define FILENAME_SIZE   (40)

extern unsigned char __PARAMS[];

/* 
 * Structure definition for the Parameters 
 */
typedef struct
{
    unsigned long  baud;
    unsigned char   client[4];
    unsigned char   server[4];
    unsigned char   gateway[4];
    unsigned char   netmask[4];
    unsigned char   netcfg[4];
    unsigned char   ethaddr[6];
    char    filename[FILENAME_SIZE];
} PARAM;

#define PARAMS_ADDRESS (PARAM *)__PARAMS

unsigned char *board_get_ethaddr(unsigned char *ethaddr);
unsigned char *board_get_client(unsigned char *client);
unsigned char *board_get_server(unsigned char *server);
unsigned char *board_get_gateway(unsigned char *gateway);
unsigned char *board_get_netmask(unsigned char *netmask);
char *board_get_filename (char *filename);
int board_get_filetype(void);
int board_get_autoboot(void);

#endif /* _SETGET_H_ */

