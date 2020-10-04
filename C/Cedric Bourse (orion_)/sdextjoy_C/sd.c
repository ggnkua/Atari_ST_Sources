#include "sd.h"

//#define	SD_VIRTUAL_FS

#ifdef	SD_VIRTUAL_FS
extern	uint8_t	sd_fs[];
void	sd_read_block(__reg("a0") uint8_t *buffer, __reg("d0") uint32_t block);
#else
void	spi_cs_low(void);
void	spi_cs_high(void);
void	spi_initialise(void);
uint8_t	spi_recv_byte(void);
void	spi_fast_recv_nbytes(__reg("a0") uint8_t *buffer, __reg("d0") uint16_t size);
void	spi_send_byte(__reg("d0") uint8_t input);

#define	CMD_GO_IDLE_STATE			0
#define	CMD_SEND_IF_COND			8
#define	CMD_STOP_TRANSMISSION		12
#define	CMD_READ_SINGLE_BLOCK		17
#define	CMD_READ_MULTIPLE_BLOCK		18
#define	CMD_WRITE_BLOCK				24
#define	CMD_WRITE_MULTIPLE_BLOCK	25
#define	CMD_APP_CMD					55
#define	CMD_READ_OCR				58

#define	ACMD_SD_SEND_OP_COND		41

#define	R1_READY_STATE			0x00
#define	R1_IDLE_STATE			0x01
#define	R1_ILLEGAL_COMMAND		0x04
#define	DATA_START_BLOCK		0xFE
#define	STOP_TRAN_TOKEN			0xFD
#define	WRITE_MULTIPLE_TOKEN	0xFC
#define	DATA_RES_MASK			0x1F
#define	DATA_RES_ACCEPTED		0x05

uint8_t		sd_type;
uint8_t		sd_status;

bool	SD_waitNotBusy(void)
{
	uint16_t	cnt = 0x2000;

	while (cnt--)
		if (spi_recv_byte() == 0xFF)
			return (true);
	return (false);
}

// send command and return error code.  Return zero for OK
uint8_t	SD_cardCommand(uint8_t cmd, uint32_t arg)
{
	uint8_t	crc = 0xFF;
	int8_t	s;
	uint8_t	i;

	spi_cs_low();
	SD_waitNotBusy();
	spi_send_byte(cmd | 0x40);
	for (s = 24; s >= 0; s -= 8)
		spi_send_byte(arg >> s);
	if (cmd == CMD_GO_IDLE_STATE) crc = 0x95;  // correct crc for CMD0 with arg 0
	if (cmd == CMD_SEND_IF_COND) crc = 0x87;  // correct crc for CMD8 with arg 0X1AA
	spi_send_byte(crc);
	for (i = 0; ((sd_status = spi_recv_byte()) & 0x80) && i != 0xFF; i++);
	return (sd_status);
}

uint8_t	SD_cardAcmd(uint8_t cmd, uint32_t arg)
{
	SD_cardCommand(CMD_APP_CMD, 0);
	return (SD_cardCommand(cmd, arg));
}

bool	SD_waitStartBlock(void)
{
	uint16_t	cnt = 0x6000;

	while (cnt--)
	{
		if ((sd_status = spi_recv_byte()) != 0xFF)
			break;
	}
	if (sd_status != DATA_START_BLOCK)
	{
		spi_cs_high();
		return (false);
	}
	return (true);
}
#endif

bool	SD_ReadData(__reg("d0") uint32_t block, __reg("a0") uint8_t *dst)
{
#ifdef	SD_VIRTUAL_FS
	sd_read_block(dst, block);
	return (true);
#else
	uint16_t i, n;

	if (sd_type != SD_CARD_TYPE_SDHC)
		block <<= 9;
	spi_cs_low();
	if (SD_cardCommand(CMD_READ_SINGLE_BLOCK, block))
		goto fail;
	if (!SD_waitStartBlock())
		goto fail;
	spi_fast_recv_nbytes(dst, 512);
	spi_recv_byte();	// Skip CRC (todo, option to verify it ?)
	spi_recv_byte();
	spi_cs_high();
	return (true);
fail:
	spi_cs_high();
	return (false);
#endif
}

char	*SD_Init(void)
{
#ifndef	SD_VIRTUAL_FS
	uint8_t		i;

	spi_initialise();			// CS High
	for (i = 0; i < 10; i++)	// 80 clock cycles with CS high.
		spi_send_byte(0xFF);
	spi_cs_low();

	for (i = 0; i < 128; i++)
	{
		if ((sd_status = SD_cardCommand(CMD_GO_IDLE_STATE, 0)) == R1_IDLE_STATE)
			break;
	}
	if (i == 128)
		return ("CMD_GO_IDLE_STATE Timeout\r\n");

	if (SD_cardCommand(CMD_SEND_IF_COND, 0x1AA) & R1_ILLEGAL_COMMAND)
		sd_type = SD_CARD_TYPE_SD1;
	else
	{
		// only need last byte of r7 response
		for (i = 0; i < 4; i++)
			sd_status = spi_recv_byte();
		if (sd_status != 0xAA)
			return("CMD_SEND_IF_COND Error\r\n");
		sd_type = SD_CARD_TYPE_SD2;
	}

	for (i = 0; i < 128; i++)
	{
		if ((sd_status = SD_cardAcmd(ACMD_SD_SEND_OP_COND, (sd_type == SD_CARD_TYPE_SD2) ? 0X40000000 : 0)) == R1_READY_STATE)
			break;
	}
	if (i == 128)
		return ("ACMD_SD_SEND_OP_COND Timeout\r\n");

	if (sd_type == SD_CARD_TYPE_SD2)
	{
		if (SD_cardCommand(CMD_READ_OCR, 0))
			return ("CMD_READ_OCR Error\r\n");
		if ((spi_recv_byte() & 0xC0) == 0xC0)
			sd_type = SD_CARD_TYPE_SDHC;
		for (i = 0; i < 3; i++)
			spi_recv_byte();
	}

	spi_cs_high();
#endif
	return (NULL);
}
