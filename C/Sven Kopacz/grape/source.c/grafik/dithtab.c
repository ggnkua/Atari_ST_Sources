#include "dithtab.h"

void make_fifdith(void)
{
	int a, b, c;
	
	r_dither[0].field[0]=0;
	r_dither[0].field[1]=0;
	r_dither[0].field[2]=0;
	r_dither[0].field[3]=0;
	r_dither[0].field[4]=0;
	r_dither[0].field[5]=0;
	r_dither[0].field[6]=0;
	r_dither[0].field[7]=0;

	r_dither[1].field[0]=0x88;
	r_dither[1].field[1]=0;
	r_dither[1].field[2]=0;
	r_dither[1].field[3]=0;
	r_dither[1].field[4]=0x8;
	r_dither[1].field[5]=0;
	r_dither[1].field[6]=0;
	r_dither[1].field[7]=0;

	r_dither[2].field[0]=0x88;
	r_dither[2].field[1]=0;
	r_dither[2].field[2]=0;
	r_dither[2].field[3]=0;
	r_dither[2].field[4]=0x8;
	r_dither[2].field[5]=0;
	r_dither[2].field[6]=0;
	r_dither[2].field[7]=0;

	r_dither[3].field[0]=0x88;
	r_dither[3].field[1]=0;
	r_dither[3].field[2]=0;
	r_dither[3].field[3]=0;
	r_dither[3].field[4]=0x88;
	r_dither[3].field[5]=0;
	r_dither[3].field[6]=0;
	r_dither[3].field[7]=0;

	r_dither[4].field[0]=0x88;
	r_dither[4].field[1]=0;
	r_dither[4].field[2]=0x20;
	r_dither[4].field[3]=0;
	r_dither[4].field[4]=0x88;
	r_dither[4].field[5]=0;
	r_dither[4].field[6]=0x2;
	r_dither[4].field[7]=0;

	r_dither[5].field[0]=0x88;
	r_dither[5].field[1]=0;
	r_dither[5].field[2]=0x22;
	r_dither[5].field[3]=0;
	r_dither[5].field[4]=0x88;
	r_dither[5].field[5]=0;
	r_dither[5].field[6]=0x2;
	r_dither[5].field[7]=0;

	r_dither[6].field[0]=0x88;
	r_dither[6].field[1]=0;
	r_dither[6].field[2]=0x22;
	r_dither[6].field[3]=0;
	r_dither[6].field[4]=0x88;
	r_dither[6].field[5]=0;
	r_dither[6].field[6]=0x22;
	r_dither[6].field[7]=0;

	r_dither[7].field[0]=0xa8;
	r_dither[7].field[1]=0;
	r_dither[7].field[2]=0x22;
	r_dither[7].field[3]=0;
	r_dither[7].field[4]=0x88;
	r_dither[7].field[5]=0;
	r_dither[7].field[6]=0x22;
	r_dither[7].field[7]=0;

	r_dither[8].field[0]=0xaa;
	r_dither[8].field[1]=0;
	r_dither[8].field[2]=0x22;
	r_dither[8].field[3]=0;
	r_dither[8].field[4]=0x8a;
	r_dither[8].field[5]=0;
	r_dither[8].field[6]=0x22;
	r_dither[8].field[7]=0;

	r_dither[9].field[0]=0xaa;
	r_dither[9].field[1]=0;
	r_dither[9].field[2]=0x22;
	r_dither[9].field[3]=0;
	r_dither[9].field[4]=0xaa;
	r_dither[9].field[5]=0;
	r_dither[9].field[6]=0x22;
	r_dither[9].field[7]=0;
	
	r_dither[10].field[0]=0xaa;
	r_dither[10].field[1]=0;
	r_dither[10].field[2]=0xa2;
	r_dither[10].field[3]=0;
	r_dither[10].field[4]=0xaa;
	r_dither[10].field[5]=0;
	r_dither[10].field[6]=0x22;
	r_dither[10].field[7]=0;

	r_dither[11].field[0]=0xaa;
	r_dither[11].field[1]=0;
	r_dither[11].field[2]=0xa2;
	r_dither[11].field[3]=0;
	r_dither[11].field[4]=0xaa;
	r_dither[11].field[5]=0;
	r_dither[11].field[6]=0x2a;
	r_dither[11].field[7]=0;

	r_dither[12].field[0]=0xaa;
	r_dither[12].field[1]=0;
	r_dither[12].field[2]=0xaa;
	r_dither[12].field[3]=0;
	r_dither[12].field[4]=0xaa;
	r_dither[12].field[5]=0;
	r_dither[12].field[6]=0xaa;
	r_dither[12].field[7]=0;

	r_dither[13].field[0]=0xaa;
	r_dither[13].field[1]=0x40;
	r_dither[13].field[2]=0xaa;
	r_dither[13].field[3]=0;
	r_dither[13].field[4]=0xaa;
	r_dither[13].field[5]=0;
	r_dither[13].field[6]=0xaa;
	r_dither[13].field[7]=0;

	r_dither[14].field[0]=0xaa;
	r_dither[14].field[1]=0x40;
	r_dither[14].field[2]=0xaa;
	r_dither[14].field[3]=0;
	r_dither[14].field[4]=0xaa;
	r_dither[14].field[5]=0;
	r_dither[14].field[6]=0xaa;
	r_dither[14].field[7]=0;

	r_dither[15].field[0]=0xaa;
	r_dither[15].field[1]=0x44;
	r_dither[15].field[2]=0xaa;
	r_dither[15].field[3]=0;
	r_dither[15].field[4]=0xaa;
	r_dither[15].field[5]=0;
	r_dither[15].field[6]=0xaa;
	r_dither[15].field[7]=0;

	r_dither[16].field[0]=0xaa;
	r_dither[16].field[1]=0x44;
	r_dither[16].field[2]=0xaa;
	r_dither[16].field[3]=0;
	r_dither[16].field[4]=0xaa;
	r_dither[16].field[5]=0x4;
	r_dither[16].field[6]=0xaa;
	r_dither[16].field[7]=0;

	r_dither[17].field[0]=0xaa;
	r_dither[17].field[1]=0x44;
	r_dither[17].field[2]=0xaa;
	r_dither[17].field[3]=0x10;
	r_dither[17].field[4]=0xaa;
	r_dither[17].field[5]=0x44;
	r_dither[17].field[6]=0xaa;
	r_dither[17].field[7]=0;

	r_dither[18].field[0]=0xaa;
	r_dither[18].field[1]=0x44;
	r_dither[18].field[2]=0xaa;
	r_dither[18].field[3]=0x10;
	r_dither[18].field[4]=0xaa;
	r_dither[18].field[5]=0x44;
	r_dither[18].field[6]=0xaa;
	r_dither[18].field[7]=0x1;

	r_dither[19].field[0]=0xaa;
	r_dither[19].field[1]=0x44;
	r_dither[19].field[2]=0xaa;
	r_dither[19].field[3]=0x11;
	r_dither[19].field[4]=0xaa;
	r_dither[19].field[5]=0x44;
	r_dither[19].field[6]=0xaa;
	r_dither[19].field[7]=0x1;

	r_dither[20].field[0]=0xaa;
	r_dither[20].field[1]=0x44;
	r_dither[20].field[2]=0xaa;
	r_dither[20].field[3]=0x11;
	r_dither[20].field[4]=0xaa;
	r_dither[20].field[5]=0x44;
	r_dither[20].field[6]=0xaa;
	r_dither[20].field[7]=0x11;

	r_dither[21].field[0]=0xaa;
	r_dither[21].field[1]=0x54;
	r_dither[21].field[2]=0xaa;
	r_dither[21].field[3]=0x11;
	r_dither[21].field[4]=0xaa;
	r_dither[21].field[5]=0x45;
	r_dither[21].field[6]=0xaa;
	r_dither[21].field[7]=0x11;

	r_dither[22].field[0]=0xaa;
	r_dither[22].field[1]=0x55;
	r_dither[22].field[2]=0xaa;
	r_dither[22].field[3]=0x11;
	r_dither[22].field[4]=0xaa;
	r_dither[22].field[5]=0x45;
	r_dither[22].field[6]=0xaa;
	r_dither[22].field[7]=0x11;

	r_dither[23].field[0]=0xaa;
	r_dither[23].field[1]=0x55;
	r_dither[23].field[2]=0xaa;
	r_dither[23].field[3]=0x11;
	r_dither[23].field[4]=0xaa;
	r_dither[23].field[5]=0x55;
	r_dither[23].field[6]=0xaa;
	r_dither[23].field[7]=0x11;

	r_dither[24].field[0]=0xaa;
	r_dither[24].field[1]=0x55;
	r_dither[24].field[2]=0xaa;
	r_dither[24].field[3]=0x51;
	r_dither[24].field[4]=0xaa;
	r_dither[24].field[5]=0x55;
	r_dither[24].field[6]=0xaa;
	r_dither[24].field[7]=0x11;
	
	r_dither[25].field[0]=0xaa;
	r_dither[25].field[1]=0x55;
	r_dither[25].field[2]=0xaa;
	r_dither[25].field[3]=0x55;
	r_dither[25].field[4]=0xaa;
	r_dither[25].field[5]=0x55;
	r_dither[25].field[6]=0xaa;
	r_dither[25].field[7]=0x15;

	r_dither[26].field[0]=0xaa;
	r_dither[26].field[1]=0x55;
	r_dither[26].field[2]=0xaa;
	r_dither[26].field[3]=0x55;
	r_dither[26].field[4]=0xaa;
	r_dither[26].field[5]=0x55;
	r_dither[26].field[6]=0xaa;
	r_dither[26].field[7]=0x55;
	
	/* Auf 50 Ausweiten */
	for(a=27; a < 51; ++a)
	{
		r_dither[a].field[0]=255-r_dither[52-a].field[1];
		r_dither[a].field[1]=255-r_dither[52-a].field[2];
		r_dither[a].field[2]=255-r_dither[52-a].field[3];
		r_dither[a].field[3]=255-r_dither[52-a].field[4];
		r_dither[a].field[4]=255-r_dither[52-a].field[5];
		r_dither[a].field[5]=255-r_dither[52-a].field[6];
		r_dither[a].field[6]=255-r_dither[52-a].field[7];
		r_dither[a].field[7]=255-r_dither[52-a].field[0];
	}
	
	/* Auf 255 ausweiten */
	for(b=1; b < 5; ++b)
	{
		for(a=0; a < 51; ++a)
		{
			c=b*51+a;
			r_dither[c].field[0]=r_dither[a].field[0];
			r_dither[c].field[1]=r_dither[a].field[1];
			r_dither[c].field[2]=r_dither[a].field[2];
			r_dither[c].field[3]=r_dither[a].field[3];
			r_dither[c].field[4]=r_dither[a].field[4];
			r_dither[c].field[5]=r_dither[a].field[5];
			r_dither[c].field[6]=r_dither[a].field[6];
			r_dither[c].field[7]=r_dither[a].field[7];
		}
	}
	r_dither[255].field[0]=r_dither[0].field[0];
	r_dither[255].field[1]=r_dither[0].field[1];
	r_dither[255].field[2]=r_dither[0].field[2];
	r_dither[255].field[3]=r_dither[0].field[3];
	r_dither[255].field[4]=r_dither[0].field[4];
	r_dither[255].field[5]=r_dither[0].field[5];
	r_dither[255].field[6]=r_dither[0].field[6];
	r_dither[255].field[7]=r_dither[0].field[7];
	
	/* Auf G und B kopieren */
	for(a=0; a < 256; ++a)
	{
		g_dither[a].field[0]=r_dither[a].field[0];
		g_dither[a].field[1]=r_dither[a].field[1];
		g_dither[a].field[2]=r_dither[a].field[2];
		g_dither[a].field[3]=r_dither[a].field[3];
		g_dither[a].field[4]=r_dither[a].field[4];
		g_dither[a].field[5]=r_dither[a].field[5];
		g_dither[a].field[6]=r_dither[a].field[6];
		g_dither[a].field[7]=r_dither[a].field[7];

		b_dither[a].field[0]=r_dither[a].field[0];
		b_dither[a].field[1]=r_dither[a].field[1];
		b_dither[a].field[2]=r_dither[a].field[2];
		b_dither[a].field[3]=r_dither[a].field[3];
		b_dither[a].field[4]=r_dither[a].field[4];
		b_dither[a].field[5]=r_dither[a].field[5];
		b_dither[a].field[6]=r_dither[a].field[6];
		b_dither[a].field[7]=r_dither[a].field[7];
	}
}