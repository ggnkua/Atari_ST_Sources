#include <osbind.h>

int main()
{
	volatile char *PSG_reg_select = 0xFF8800;
	volatile char *PSG_reg_write = 0xFF8802;

	long old_ssp = Super(0);

	*PSG_reg_select = 6;
	*PSG_reg_write = 0x0f;

	*PSG_reg_select = 7;
	*PSG_reg_write = 0x07;

	*PSG_reg_select = 8;
	*PSG_reg_write = 0x10;

	*PSG_reg_select = 9;
	*PSG_reg_write = 0x10;

	*PSG_reg_select = 0xa;
	*PSG_reg_write = 0x10;

	*PSG_reg_select = 0xc;
	*PSG_reg_write = 0x38;

	*PSG_reg_select = 0xd;
	*PSG_reg_write = 0x00;

	while (!Cconis()) /* tone now playing, await key */
		;

	Cnecin();
	Super(old_ssp);
	return 0;
}
