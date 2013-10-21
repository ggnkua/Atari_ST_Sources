/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 *
 *    This little program fakes a N.Aes cookie.
 *    It doesnt enjoy doing such a thing, but some programs
 *    will only use the (AES > 4) functions or the N.Aes
 *    compatible functions when this cookie exists.
 *    The use of such programs under XaAES ia competely at the
 *    users risc, as is the use of this program.
 *
 */

#include <osbind.h>
#include <mintbind.h>
#include <ssystem.h>
#include <string.h>

typedef struct
{
	unsigned
	short version,
	      date,
	      time,
	      flags;
	void *config;
	long unused;
} N_AESINFO;

#define MX_GLOBAL		((1 << 3) | (2 << 4))
#define MX_PREFTTRAM 		3


short main(void)
{
	/* Check that MiNT is actually installed */
	/* Tried to use mintlibs Getcookie, but failed */
	if (Ssystem(-1, 0, 0) == 0)
	{
		N_AESINFO *cook;
		
		if (Ssystem(S_GETCOOKIE, 'nAES', 0) == -1)
		{
			cook = Mxalloc(sizeof(*cook), MX_GLOBAL | MX_PREFTTRAM);
			if (!cook)
				Cconws("Not enough memory\r\n");
			else
			{
				memset(cook, 0, sizeof(*cook));
				Ssystem(S_SETCOOKIE, 'nAES', (long)cook);	
				Cconws("\r\n\r\nXA_CHEAT: fake 'nAES' cookie.\r\n");
				Cconws("The use of this program is completely\r\n");
				Cconws("at your own risc.\r\n");
				Cconws("Any program accessing the pointer in this\r\n");
				Cconws("cookie will crash hopelessly.\r\n");
				Cconws("So do not use any N.Aes utilities!!!\r\n");
				Cconws("\r\n");
				Cconws("\r\n'nAES' cookie now faked.\r\n\r\n");
				Ptermres(2048, 0);
			}
		}
		else
			Cconws("nAES cookie already exists\r\n");
	}
	else
	{
		Cconws("XaCHEAT requires MiNT\r\n");
		bios(2,2);
	}
	return 0;
}