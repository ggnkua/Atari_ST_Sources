#include "config.h"
#include "smi.h"
#include "relocate.h"
#include "edid.h"

#ifdef CONFIG_VIDEO_SMI_LYNXEM

#define SMI_DDC 	0x50

extern void mdelay(long msec);
extern void udelay(long usec);

static void lynx_gpio_setscl(void *data, int state)
{
	struct smi_i2c_chan *chan = data;
	struct smifb_info *smiinfo = chan->smiinfo;
	unsigned char val = VGAIN8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, chan->ddc_reg);
	val &= ~(VGA_DDC_CLK_OUT_EN);
	if(!state)
		val |= VGA_DDC_CLK_OUT_EN;
	VGAOUT8(smiinfo, chan->ddc_reg, val);
	(void)VGAIN8(smiinfo, chan->ddc_reg);
}

static void lynx_gpio_setsda(void *data, int state)
{
	struct smi_i2c_chan *chan = data;
	struct smifb_info *smiinfo = chan->smiinfo;
	unsigned char val = VGAIN8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, chan->ddc_reg);
	val &= ~(VGA_DDC_DATA_OUT_EN);
	if(!state)
		val |= VGA_DDC_DATA_OUT_EN;
	VGAOUT8(smiinfo, chan->ddc_reg, val);
	(void)VGAIN8(smiinfo, chan->ddc_reg);
}

static int lynx_gpio_getscl(void *data)
{
	struct smi_i2c_chan *chan = data;
	struct smifb_info *smiinfo = chan->smiinfo;
	unsigned char val = VGAIN8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, chan->ddc_reg);
	return (val & VGA_DDC_CLK_INPUT) ? 1 : 0;
}

static int lynx_gpio_getsda(void *data)
{
	struct smi_i2c_chan *chan = data;
	struct smifb_info *smiinfo = chan->smiinfo;
	unsigned char val = VGAIN8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, chan->ddc_reg);
	return (val & VGA_DDC_DATA_INPUT) ? 1 : 0;
}

static int lynx_setup_i2c_bus(struct smi_i2c_chan *chan)
{
	int rc;
	chan->adapter.algo_data = &chan->algo;
	chan->algo.setsda = lynx_gpio_setsda;
	chan->algo.setscl = lynx_gpio_setscl;
	chan->algo.getsda = lynx_gpio_getsda;
	chan->algo.getscl = lynx_gpio_getscl;
	chan->algo.udelay = 40;
	chan->algo.timeout = 20;
	chan->algo.data = chan;	
	/* Raise SCL and SDA */
	lynx_gpio_setsda(chan, 1);
	lynx_gpio_setscl(chan, 1);
	udelay(20);
	rc = i2c_bit_add_bus(&chan->adapter);
	return rc;
}

void lynx_create_i2c_busses(struct smifb_info *smiinfo)
{
	smiinfo->i2c[0].smiinfo	= smiinfo;
	smiinfo->i2c[0].ddc_reg	= 0x72;
	lynx_setup_i2c_bus(&smiinfo->i2c[0]);
	smiinfo->i2c[1].smiinfo	= smiinfo;
	smiinfo->i2c[1].ddc_reg	= 0x73;
	lynx_setup_i2c_bus(&smiinfo->i2c[1]);
}

#if 0
void lynx_delete_i2c_busses(struct smifb_info *smiinfo)
{
	if(smiinfo->i2c[0].smiinfo)
		i2c_bit_del_bus(&smiinfo->i2c[0].adapter);
	smiinfo->i2c[0].smiinfo = NULL;
	if(smiinfo->i2c[1].smiinfo)
		i2c_bit_del_bus(&smiinfo->i2c[1].adapter);
	smiinfo->i2c[1].smiinfo = NULL;
}
#endif

static unsigned char *lynx_do_probe_i2c_edid(struct smi_i2c_chan *chan)
{
	unsigned char start = 0x0;
	struct i2c_msg msgs[] =
	{
		{
			.addr	= SMI_DDC,
			.len	= 1,
			.buf	= &start,
		}, {
			.addr	= SMI_DDC,
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

int lynx_probe_i2c_connector(struct smifb_info *smiinfo, int conn, unsigned char **out_edid)
{
	if((conn < 1) || (conn > 2))
		return 0;
	else
	{
		unsigned char reg = smiinfo->i2c[conn-1].ddc_reg;
		unsigned char *edid = NULL;
		int i, j;
	  DPRINTVAL("lynxfb: lynx_probe_i2c_connector ", conn);
		DPRINT("\r\n");
		VGAOUT8(smiinfo, reg, VGAIN8_INDEX(smiinfo, VGA_SEQ_INDEX, VGA_SEQ_DATA, reg) & ~(VGA_DDC_DATA_OUTPUT | VGA_DDC_CLK_OUTPUT));
		VGAOUT8(smiinfo, reg, VGAIN8(smiinfo, reg) & ~(VGA_DDC_CLK_OUT_EN));
		(void)VGAIN8(smiinfo, reg);
		for(i = 0; i < 3; i++)
		{
			/* For some old monitors we need the
			 * following process to initialize/stop DDC
			 */
			VGAOUT8(smiinfo, reg, VGAIN8(smiinfo, reg) & ~(VGA_DDC_DATA_OUT_EN));
			(void)VGAIN8(smiinfo, reg);
			mdelay(13);
			VGAOUT8(smiinfo, reg, VGAIN8(smiinfo, reg) & ~(VGA_DDC_CLK_OUT_EN));
			(void)VGAIN8(smiinfo, reg);
			for(j = 0; j < 5; j++)
			{
				mdelay(10);
				if(VGAIN8(smiinfo, reg) & VGA_DDC_CLK_INPUT)
					break;
			}
			if(j == 5)
				continue;
			VGAOUT8(smiinfo, reg, VGAIN8(smiinfo, reg) | VGA_DDC_DATA_OUT_EN);
			(void)VGAIN8(smiinfo, reg);
			mdelay(15);
			VGAOUT8(smiinfo, reg, VGAIN8(smiinfo, reg) | VGA_DDC_CLK_OUT_EN);
			(void)VGAIN8(smiinfo, reg);
			mdelay(15);
			VGAOUT8(smiinfo, reg, VGAIN8(smiinfo, reg) & ~(VGA_DDC_DATA_OUT_EN));
			(void)VGAIN8(smiinfo, reg);
			mdelay(15);
			/* Do the real work */
			edid = lynx_do_probe_i2c_edid(&smiinfo->i2c[conn-1]);
			VGAOUT8(smiinfo, reg, VGAIN8(smiinfo, reg) | (VGA_DDC_DATA_OUT_EN | VGA_DDC_CLK_OUT_EN));
			(void)VGAIN8(smiinfo, reg);
			mdelay(15);
			VGAOUT8(smiinfo, reg, VGAIN8(smiinfo, reg) & ~(VGA_DDC_CLK_OUT_EN));
			(void)VGAIN8(smiinfo, reg);
			for (j = 0; j < 10; j++)
			{
				mdelay(10);
				if(VGAIN8(smiinfo, reg) & VGA_DDC_CLK_INPUT)
					break;
			}
			VGAOUT8(smiinfo, reg, VGAIN8(smiinfo, reg) & ~(VGA_DDC_DATA_OUT_EN));
			(void)VGAIN8(smiinfo, reg);
			mdelay(15);
			VGAOUT8(smiinfo, reg, VGAIN8(smiinfo, reg) | (VGA_DDC_DATA_OUT_EN | VGA_DDC_CLK_OUT_EN));
			(void)VGAIN8(smiinfo, reg);
			if(edid)
				break;
		}
		/* Release the DDC lines when done or the Apple Cinema HD display
		 * will switch off */
		VGAOUT8(smiinfo, reg, VGAIN8(smiinfo, reg) & ~(VGA_DDC_CLK_OUT_EN | VGA_DDC_DATA_OUT_EN));
		(void)VGAIN8(smiinfo, reg);
		if(out_edid)
			*out_edid = edid;
		if(!edid)
			return 0;
		if(edid[0x14] & 0x80)
			return 1;
		return 2;
	}
}	

#endif /* CONFIG_VIDEO_SMI_LYNXEM */
