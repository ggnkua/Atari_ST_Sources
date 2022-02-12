/*
rtl8029.c

Initialization of PCI DP8390-based ethernet cards

Created:	April 2000 by Philip Homburg <philip@cs.vu.nl>
*/

#include "kernel.h"
#include <sys/types.h>
#include <net/gen/ether.h>
#include <net/gen/eth_io.h>

#if __minix_vmd
#include "config.h"
#endif
#include "dp8390.h"
#include "pci.h"

#if ENABLE_PCI

PRIVATE struct pcitab
{
	u16_t vid;
	u16_t did;
	int checkclass;
} pcitab[]=
{
	{ 0x10ec, 0x8029, 0 },		/* Realtek RTL8029 */

	{ 0x0000, 0x0000, 0 }
};

PUBLIC int rtl_probe(dep)
struct dpeth *dep;
{
	int i, r, devind, just_one;
	u16_t vid, did;
	u32_t bar;
	u8_t ilr;
	char *dname;

	pci_init();

	if ((dep->de_pcibus | dep->de_pcidev | dep->de_pcifunc) != 0)
	{
		/* Look for specific PCI device */
		r= pci_find_dev(dep->de_pcibus, dep->de_pcidev,
			dep->de_pcifunc, &devind);
		if (r == 0)
		{
			printf("%s: no PCI found at %d.%d.%d\n",
				dep->de_name, dep->de_pcibus,
				dep->de_pcidev, dep->de_pcifunc);
			return 0;
		}
		pci_ids(devind, &vid, &did);
		just_one= TRUE;
	}
	else
	{
		r= pci_first_dev(&devind, &vid, &did);
		if (r == 0)
			return 0;
		just_one= FALSE;
	}

	for(;;)
	{
		for (i= 0; pcitab[i].vid != 0; i++)
		{
			if (pcitab[i].vid != vid)
				continue;
			if (pcitab[i].did != did)
				continue;
			if (pcitab[i].checkclass)
			{
				panic("rtl_probe: class check not implemented",
					NO_NUM);
			}
			break;
		}
		if (pcitab[i].vid != 0)
			break;

		if (just_one)
		{
			printf(
		"%s: wrong PCI device (%04X/%04X) found at %d.%d.%d\n",
				dep->de_name, vid, did,
				dep->de_pcibus,
				dep->de_pcidev, dep->de_pcifunc);
			return 0;
		}

		r= pci_next_dev(&devind, &vid, &did);
		if (!r)
			return 0;
	}

	dname= pci_dev_name(vid, did);
	if (!dname)
		dname= "unknown device";
	printf("%s: %s (%04X/%04X) at %s\n",
		dep->de_name, dname, vid, did, pci_slot_name(devind));
	pci_reserve(devind);
	/* printf("cr = 0x%x\n", pci_attr_r16(devind, PCI_CR)); */
	bar= pci_attr_r32(devind, PCI_BAR) & 0xffffffe0;
	if ((bar & 0x3ff) >= 0x100-32 || bar < 0x400)
		panic("base address is not properly configured", NO_NUM);
	dep->de_base_port= bar;

	ilr= pci_attr_r8(devind, PCI_ILR);
	dep->de_irq= ilr;
	if (debug)
	{
		printf("%s: using I/O address 0x%lx, IRQ %d\n",
			dep->de_name, (unsigned long)bar, ilr);
	}

	return TRUE;
}
#endif /* ENABLE_PCI */

/*
 * $PchId: rtl8029.c,v 1.3 2001/11/09 20:01:09 philip Exp $
 */
