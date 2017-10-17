#include "radeonfb.h"
#include "relocate.h"
#include "edid.h"

#ifdef CONFIG_FB_RADEON_I2C

#define RADEON_DDC 	0x50

extern void mdelay(long msec);
extern void udelay(long usec);

static void radeon_gpio_setscl(void* data, int state)
{
	struct radeon_i2c_chan *chan = data;
	struct radeonfb_info *rinfo = chan->rinfo;
	unsigned long val;
	val = INREG(chan->ddc_reg) & ~(VGA_DDC_CLK_OUT_EN);
	if(!state)
		val |= VGA_DDC_CLK_OUT_EN;
	OUTREG(chan->ddc_reg, val);
	(void)INREG(chan->ddc_reg);
}

static void radeon_gpio_setsda(void* data, int state)
{
	struct radeon_i2c_chan *chan = data;
	struct radeonfb_info *rinfo = chan->rinfo;
	unsigned long val;
	val = INREG(chan->ddc_reg) & ~(VGA_DDC_DATA_OUT_EN);
	if(!state)
		val |= VGA_DDC_DATA_OUT_EN;
	OUTREG(chan->ddc_reg, val);
	(void)INREG(chan->ddc_reg);
}

static int radeon_gpio_getscl(void* data)
{
	struct radeon_i2c_chan *chan = data;
	struct radeonfb_info *rinfo = chan->rinfo;
	unsigned long val;
	val = INREG(chan->ddc_reg);
	return(val & VGA_DDC_CLK_INPUT) ? 1 : 0;
}

static int radeon_gpio_getsda(void* data)
{
	struct radeon_i2c_chan *chan = data;
	struct radeonfb_info *rinfo = chan->rinfo;
	unsigned long val;
	val = INREG(chan->ddc_reg);
	return(val & VGA_DDC_DATA_INPUT) ? 1 : 0;
}

static int radeon_setup_i2c_bus(struct radeon_i2c_chan *chan)
{
	int rc;
	chan->adapter.algo_data = &chan->algo;
	chan->algo.setsda = radeon_gpio_setsda;
	chan->algo.setscl = radeon_gpio_setscl;
	chan->algo.getsda = radeon_gpio_getsda;
	chan->algo.getscl = radeon_gpio_getscl;
	chan->algo.udelay = 40;
	chan->algo.timeout = 20;
	chan->algo.data = chan;	
	/* Raise SCL and SDA */
	radeon_gpio_setsda(chan, 1);
	radeon_gpio_setscl(chan, 1);
	udelay(20);
	rc = i2c_bit_add_bus(&chan->adapter);
	return rc;
}

void radeon_create_i2c_busses(struct radeonfb_info *rinfo)
{
	rinfo->i2c[0].rinfo	= rinfo;
	rinfo->i2c[0].ddc_reg	= GPIO_MONID;
	radeon_setup_i2c_bus(&rinfo->i2c[0]);
	rinfo->i2c[1].rinfo	= rinfo;
	rinfo->i2c[1].ddc_reg	= GPIO_DVI_DDC;
	radeon_setup_i2c_bus(&rinfo->i2c[1]);
	rinfo->i2c[2].rinfo	= rinfo;
	rinfo->i2c[2].ddc_reg	= GPIO_VGA_DDC;
	radeon_setup_i2c_bus(&rinfo->i2c[2]);
	rinfo->i2c[3].rinfo	= rinfo;
	rinfo->i2c[3].ddc_reg	= GPIO_CRT2_DDC;
	radeon_setup_i2c_bus(&rinfo->i2c[3]);
}

#if 0
void radeon_delete_i2c_busses(struct radeonfb_info *rinfo)
{
	if(rinfo->i2c[0].rinfo)
		i2c_bit_del_bus(&rinfo->i2c[0].adapter);
	rinfo->i2c[0].rinfo = NULL;
	if(rinfo->i2c[1].rinfo)
		i2c_bit_del_bus(&rinfo->i2c[1].adapter);
	rinfo->i2c[1].rinfo = NULL;
	if(rinfo->i2c[2].rinfo)
		i2c_bit_del_bus(&rinfo->i2c[2].adapter);
	rinfo->i2c[2].rinfo = NULL;
	if(rinfo->i2c[3].rinfo)
		i2c_bit_del_bus(&rinfo->i2c[3].adapter);
	rinfo->i2c[3].rinfo = NULL;
}
#endif

static unsigned char *radeon_do_probe_i2c_edid(struct radeon_i2c_chan *chan)
{
	unsigned char start = 0x0;
	struct i2c_msg msgs[] =
	{
		{
			.addr	= RADEON_DDC,
			.len	= 1,
			.buf	= &start,
		}, {
			.addr	= RADEON_DDC,
			.flags	= I2C_M_RD,
			.len	= EDID_LENGTH,
		},
	};
	unsigned char *buf;
	buf = Funcs_malloc(EDID_LENGTH, 3);
	if(!buf)
		return NULL;
	msgs[1].buf = buf;
	if(i2c_transfer(&chan->adapter, msgs, 2) == 2)
		return buf;
	Funcs_free(buf);
	return NULL;
}

int radeon_probe_i2c_connector(struct radeonfb_info *rinfo, int conn, unsigned char **out_edid)
{
	unsigned long reg = rinfo->i2c[conn-1].ddc_reg;
	unsigned char *edid = NULL;
	int i, j;
//  DPRINTVAL("radeonfb: radeon_probe_i2c_connector ", conn);
//	DPRINT("\r\n");
	OUTREG(reg, INREG(reg) & ~(VGA_DDC_DATA_OUTPUT | VGA_DDC_CLK_OUTPUT));
	OUTREG(reg, INREG(reg) & ~(VGA_DDC_CLK_OUT_EN));
	(void)INREG(reg);
	for(i = 0; i < 3; i++)
	{
		/* For some old monitors we need the
		 * following process to initialize/stop DDC
		 */
		OUTREG(reg, INREG(reg) & ~(VGA_DDC_DATA_OUT_EN));
		(void)INREG(reg);
		mdelay(13);
		OUTREG(reg, INREG(reg) & ~(VGA_DDC_CLK_OUT_EN));
		(void)INREG(reg);
		for(j = 0; j < 5; j++)
		{
			mdelay(10);
			if(INREG(reg) & VGA_DDC_CLK_INPUT)
				break;
		}
		if(j == 5)
			continue;
		OUTREG(reg, INREG(reg) | VGA_DDC_DATA_OUT_EN);
		(void)INREG(reg);
		mdelay(15);
		OUTREG(reg, INREG(reg) | VGA_DDC_CLK_OUT_EN);
		(void)INREG(reg);
		mdelay(15);
		OUTREG(reg, INREG(reg) & ~(VGA_DDC_DATA_OUT_EN));
		(void)INREG(reg);
		mdelay(15);
		/* Do the real work */
		edid = radeon_do_probe_i2c_edid(&rinfo->i2c[conn-1]);
		OUTREG(reg, INREG(reg) | (VGA_DDC_DATA_OUT_EN | VGA_DDC_CLK_OUT_EN));
		(void)INREG(reg);
		mdelay(15);
		OUTREG(reg, INREG(reg) & ~(VGA_DDC_CLK_OUT_EN));
		(void)INREG(reg);
		for(j = 0; j < 10; j++)
		{
			mdelay(10);
			if(INREG(reg) & VGA_DDC_CLK_INPUT)
				break;
		}
		OUTREG(reg, INREG(reg) & ~(VGA_DDC_DATA_OUT_EN));
		(void)INREG(reg);
		mdelay(15);
		OUTREG(reg, INREG(reg) | (VGA_DDC_DATA_OUT_EN | VGA_DDC_CLK_OUT_EN));
		(void)INREG(reg);
		if(edid)
			break;
	}
	/* Release the DDC lines when done or the Apple Cinema HD display
	 * will switch off */
	OUTREG(reg, INREG(reg) & ~(VGA_DDC_CLK_OUT_EN | VGA_DDC_DATA_OUT_EN));
	(void)INREG(reg);
	if(out_edid)
		*out_edid = edid;
	if(!edid)
		return MT_NONE;
	if(edid[0x14] & 0x80)
	{
		/* Fix detection using BIOS tables */
		if(rinfo->is_mobility /*&& conn == ddc_dvi*/ && (INREG(LVDS_GEN_CNTL) & LVDS_ON))
			return MT_LCD;
		else
			return MT_DFP;
	}
	return MT_CRT;
}

#endif /* CONFIG_FB_RADEON_I2C */
