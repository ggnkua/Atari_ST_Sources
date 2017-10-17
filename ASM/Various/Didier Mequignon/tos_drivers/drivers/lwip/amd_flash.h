
#ifndef	_AMD_FLASH_H_
#define	_AMD_FLASH_H_

#define	FLASH_UNLOCK1	(0xAAA)
#define	FLASH_UNLOCK2	(0x554)

typedef struct
{
  vuint32 offset;
  vuint32 unlock1;
  vuint32 unlock2;
} t_sector;

#define CMD_UNLOCK1	0xAA
#define CMD_UNLOCK2	0x55
#define CMD_SECTOR_ERASE1	0x80
#define CMD_SECTOR_ERASE2	0x30
#define CMD_SECTOR_ERASE_SUSPEND 0xB0
#define CMD_SECTOR_ERASE_RESUME 0x30
#define CMD_PROGRAM	0xA0
#define CMD_AUTOSELECT 0x90
#define CMD_READ 0xF0

#define PASS    0
#define SUCCESS 0
#define FAIL    1

unsigned long FlashIdentify(void);
void UnprotectCSBOOT(void);
void ProtectCSBOOT(void);
unsigned long EraseFlash(unsigned long begin, unsigned long end);
unsigned long ResetFlash(void);
unsigned long ProgFlash(unsigned long begin, unsigned long end, void *code);

#endif /* _AMD_FLASH_H */
