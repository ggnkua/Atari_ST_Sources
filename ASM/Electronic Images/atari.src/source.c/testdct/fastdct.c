/*
 *
 */

#define CONST_SCALE (256)
#define FIX(x) ((int) ((x*CONST_SCALE)+0.5))

#define c1 FIX(1.0)
#define c2 FIX(0.541196100)
#define c3 -FIX(1.847759065)
#define c4  FIX(0.765366865)
#define c10 FIX(0.298631336)
#define c11 FIX(2.053119869)
#define c12 FIX(3.072711026)
#define c13  FIX(1.501321110)
#define c20 -FIX(0.899976223)
#define c21 -FIX(2.562915447)
#define c22 -FIX(1.961570560)
#define c23 -FIX(0.390180644)
#define c24 FIX(1.175875602)

static int dct_const[] =
{ 	c1,c13+c20+c23+c24,c2+c4,c24,c1,c23+c24,c2,c20+c24,
 	c1,c24,c2,c12+c21+c22+c24,-c1,c21+c24,c2+c3,c22+c24,
	c1,c23+c24,-c2,c21+c24,-c1,c11+c21+c23+c24,-(c2+c3),c24,
	c1,c20+c24,-(c2+c4),c22+c24,c1,c24,-c2,c10+c20+c22+c24,
};

static int pre_const[32][4096];

void init_dct(void)
{	int i,j;
	for (i=0;i<32;i++)
	{	int c = dct_const[i];
		for (j=0;j<4096;j++)
			pre_const[i][j] = (j-2048) * c;
		
	}
}

static short temp[8][8];

void fastdct(short *blk)
{	int i;
	register *tmp=temp;
	for (i=0;i<8;i++)
	{	register int x1,x2;
		x1 = pre_const[0][blk[0]];
		x2 = pre_const[1][blk[1]];
		x1+= pre_const[2][blk[2]];
		x2+= pre_const[3][blk[3]];
		x1+= pre_const[4][blk[4]];
		x2+= pre_const[5][blk[5]];
		x1+= pre_const[6][blk[6]];
		x2+= pre_const[7][blk[7]];
		tmp[0] = x1+x2;
		tmp[7] = x2-x1;		
		x1 = pre_const[8][blk[0]];
		x2 = pre_const[9][blk[1]];
		x1+= pre_const[10][blk[2]];
		x2+= pre_const[11][blk[3]];
		x1+= pre_const[12][blk[4]];
		x2+= pre_const[13][blk[5]];
		x1+= pre_const[14][blk[6]];
		x2+= pre_const[15][blk[7]];
		tmp[1] = x1+x2;
		tmp[6] = x2-x1;		
		x1 = pre_const[16][blk[0]];
		x2 = pre_const[17][blk[1]];
		x1+= pre_const[18][blk[2]];
		x2+= pre_const[19][blk[3]];
		x1+= pre_const[20][blk[4]];
		x2+= pre_const[21][blk[5]];
		x1+= pre_const[22][blk[6]];
		x2+= pre_const[23][blk[7]];
		tmp[2] = x1+x2;
		tmp[5] = x2-x1;		
		x1 = pre_const[24][blk[0]];
		x2 = pre_const[25][blk[1]];
		x1+= pre_const[26][blk[2]];
		x2+= pre_const[27][blk[3]];
		x1+= pre_const[28][blk[4]];
		x2+= pre_const[29][blk[5]];
		x1+= pre_const[30][blk[6]];
		x2+= pre_const[31][blk[7]];
		tmp[3] = x1+x2;
		tmp[4] = x2-x1;		
		tmp+=8;
		blk+=8;
	}

}

