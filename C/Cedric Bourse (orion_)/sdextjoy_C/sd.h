#ifndef	_SD_H_
#define	_SD_H_

#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

enum
{
	SD_CARD_TYPE_NONE,
	SD_CARD_TYPE_SD1,
	SD_CARD_TYPE_SD2,
	SD_CARD_TYPE_SDHC
};

char	*SD_Init(void);	// Return NULL if ok, else, error string
bool	SD_ReadData(__reg("d0") uint32_t block, __reg("a0") uint8_t *dst);

#endif
