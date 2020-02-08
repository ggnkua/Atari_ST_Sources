/*... I2C ...*/

# define I2Caddr		((byte *)(0xf78001L))

/*... V-DATA/-CTRL ...*/

# define INportYC		((uword *)0xf60000L)
# define INport555		((uword *)0xf68000L)
# define INport332		INport555

# if HWzoom
# define INportZoomX2	0x004000L			
# define INportYCzx2	((uword *)(0xf60000L|INportZoomX2))	/* use only Y in YC mode	*/
# define INport555zx2	((uword *)(0xf68000L|INportZoomX2))
# endif

# define GRABcntrlReg		((byte  *)0xf70001L)	/* s.a. yc_fast.s	*/

# define GRABstart			0x01
# define GRABodd			0x00
# define GRABeven			0x02
# define GRABshiftEnable	0x04
# define GRABzoomXG8		0x08
# define GRABshiftDisable	0x00

# define RESETread			0x02	/* write : FIFO - RSTR	*/
# define GRABactive			0x02	/* read  : mdf grabbing	*/

/*... LCA load ...*/

# define MATDIGIFaddress	((unsigned char *)0xf00000L)
# define LCAdataOffset	0x60001L
# define LCActrlOffset	0x40001L

