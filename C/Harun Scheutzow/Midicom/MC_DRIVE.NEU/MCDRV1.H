#include "drv_type.h"

typedef enum
{
	FAIL=-1,
	FALSE,
	TRUE
} boolean;

extern	void	set_errbell(int *errbell);
extern	void	do_install(void);
extern	void	AES_install(void);
extern	int	mdstat(void);
extern	int	fil_request(void);
/* void proto_out(char *msgtyp, int sender, int empf, int weiter);*/
void err_out( int rec_err,int CRC_err);
extern	int	lese(int len,char *buff);
extern	long  SENDE(int len, char *buff);
extern	void	clear_buff(void);
