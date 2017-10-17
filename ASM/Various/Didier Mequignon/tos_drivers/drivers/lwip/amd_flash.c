/* TOS 4.04 FIREBEE AMD/MX flash programming
 * Didier Mequignon 2010, e-mail: aniplay@wanadoo.fr
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "mcf548x.h"
#include "net.h"
#include "amd_flash.h"

t_sector mx_29lv640_sectors[] =  /* bottom boot */
{
  {0x0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA0 */
  {0x2000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA1 */
  {0x4000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA2 */
  {0x6000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA3 */
  {0x8000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA4 */
  {0xA000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA5 */
  {0xC000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA6 */
  {0xE000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA7 */
  {0x10000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA8 */
  {0x20000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA9 */
  {0x30000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA10 */
  {0x40000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA11 */
  {0x50000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA12 */
  {0x60000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA13 */
  {0x70000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA14 */
  {0x80000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA15 */
  {0x90000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA16 */
  {0xA0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA17 */
  {0xB0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA18 */
  {0xC0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA19 */
  {0xD0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA20 */
  {0xE0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA21 */
  {0xF0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA22 */
  {0x100000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA23 */
  {0x110000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA24 */
  {0x120000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA25 */
  {0x130000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA26 */
  {0x140000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA27 */
  {0x150000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA28 */
  {0x160000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA29 */
  {0x170000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA30 */
  {0x180000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA31 */
  {0x190000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA32 */
  {0x1A0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA33 */
  {0x1B0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA34 */
  {0x1C0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA35 */
  {0x1D0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA36 */
  {0x1E0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA37 */
  {0x1F0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA38 */
  {0x200000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA39 */
  {0x210000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA40 */
  {0x220000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA41 */
  {0x230000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA42 */
  {0x240000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA43 */
  {0x250000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA44 */
  {0x260000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA45 */
  {0x270000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA46 */
  {0x280000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA47 */
  {0x290000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA48 */
  {0x2A0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA49 */
  {0x2B0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA50 */
  {0x2C0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA51 */
  {0x2D0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA52 */
  {0x2E0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA53 */
  {0x2F0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA54 */
  {0x300000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA55 */
  {0x310000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA56 */
  {0x320000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA57 */
  {0x330000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA58 */
  {0x340000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA59 */
  {0x350000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA60 */
  {0x360000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA61 */
  {0x370000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA62 */
  {0x380000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA63 */
  {0x390000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA64 */
  {0x3A0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA65 */
  {0x3B0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA66 */
  {0x3C0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA67 */
  {0x3D0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA68 */
  {0x3E0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA69 */
  {0x3F0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA70 */
  {0x400000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA71 */
  {0x410000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA72 */
  {0x420000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA73 */
  {0x430000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA74 */
  {0x440000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA75 */
  {0x450000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA76 */
  {0x460000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA77 */
  {0x470000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA78 */
  {0x480000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA79 */
  {0x490000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA80 */
  {0x4A0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA81 */
  {0x4B0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA82 */
  {0x4C0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA83 */
  {0x4D0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA84 */
  {0x4E0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA85 */
  {0x4F0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA86 */
  {0x500000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA87 */
  {0x510000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA88 */
  {0x520000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA89 */
  {0x530000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA90 */
  {0x540000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA91 */
  {0x550000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA92 */
  {0x560000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA93 */
  {0x570000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA94 */
  {0x580000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA95 */
  {0x590000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA96 */
  {0x5A0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA97 */
  {0x5B0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA98 */
  {0x5C0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA99 */
  {0x5D0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA100 */
  {0x5E0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA101 */
  {0x5F0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA102 */
  {0x600000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA103 */
  {0x610000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA104 */
  {0x620000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA105 */
  {0x630000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA106 */
  {0x640000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA107 */
  {0x650000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA108 */
  {0x660000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA109 */
  {0x670000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA110 */
  {0x680000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA111 */
  {0x690000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA112 */
  {0x6A0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA113 */
  {0x6B0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA114 */
  {0x6C0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA115 */
  {0x6D0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA116 */
  {0x6E0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA117 */
  {0x6F0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA118 */
  {0x700000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA119 */
  {0x710000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA120 */
  {0x720000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA121 */
  {0x730000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA122 */
  {0x740000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA123 */
  {0x750000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA124 */
  {0x760000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA125 */
  {0x770000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA126 */
  {0x780000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA127 */
  {0x790000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA128 */ 
  {0x7A0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA129 */
  {0x7B0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA130 */
  {0x7C0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA131 */
  {0x7D0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA132 */
  {0x7E0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA133 */
  {0x7F0000, FLASH_UNLOCK1, FLASH_UNLOCK2}, /* SA134 */
  {0x800000, 0, 0}
};

struct
{
  vuint32 device;
  t_sector *sectors;
} supported_devices[] = { {0x00C222CB, mx_29lv640_sectors}, {0, NULL} };

static vuint32 GetFlashDevice(void)
{
  vuint32 device;
  unsigned long base = MCF_FBCS0_CSAR & 0xFFFF0000;
  vuint16 *unlock1 = (vuint16 *)(base + FLASH_UNLOCK1);
  vuint16 *unlock2 = (vuint16 *)(base + FLASH_UNLOCK2);
  *unlock1 = CMD_UNLOCK1;      // unlock
  *unlock2 = CMD_UNLOCK2;
  *unlock1 = CMD_AUTOSELECT;   // Autoselect command
  device = *(vuint32 *)base;   // Manufacturer code / Device code
  *(vuint16 *)base = CMD_READ; // Read/Reset command
  return(device);
}

unsigned long FlashIdentify(void)
{
  t_sector *sectors = NULL;
  vuint32 device = GetFlashDevice();
  int i = 0;
  while(supported_devices[i].sectors != NULL)
  {
    if(device == supported_devices[i].device)
      sectors = supported_devices[i].sectors;
    i++;
  }
  if(sectors == NULL)
    return(FAIL);
  return(SUCCESS);
}

void UnprotectCSBOOT(void)
{
  MCF_FBCS0_CSMR &= ~MCF_FBCS_CSMR_WP;
} 

void ProtectCSBOOT(void)
{
  MCF_FBCS0_CSMR |= MCF_FBCS_CSMR_WP;
}

unsigned long EraseFlash(unsigned long begin, unsigned long end)
{
  t_sector *sectors = NULL;
  vuint32 address, size;
  vuint32 device = GetFlashDevice();
  unsigned long base = MCF_FBCS0_CSAR & 0xFFFF0000;
  vuint16 status;
  int i = 0;
  while(supported_devices[i].sectors != NULL)
  {
    if(device == supported_devices[i].device)
      sectors = supported_devices[i].sectors;
    i++;
  }
  if(sectors == NULL)
    return(FAIL);
  while(sectors->unlock1 && sectors->unlock2)
  {
    address = base + sectors->offset;  
    size = sectors[1].offset - sectors[0].offset;
    if((address >= (begin & ~(size-1))) && (address < end))
    {
      vuint16 *unlock1 = (vuint16 *)(base + sectors->unlock1);
      vuint16 *unlock2 = (vuint16 *)(base + sectors->unlock2);
      *unlock1 = CMD_UNLOCK1;      // unlock
      *unlock2 = CMD_UNLOCK2;
      *(vuint16 *)address = CMD_SECTOR_ERASE1;
      *unlock1 = CMD_UNLOCK1;      // unlock
      *unlock2 = CMD_UNLOCK2;
      *(vuint16 *)address = CMD_SECTOR_ERASE2; // Erase sector command
      while(!((status = *(vuint16 *)address) & 0x00A0)); // wait
      if((status & 0x0020) && !(*(vuint16 *)address & 0x0080))
      {
        ResetFlash();
        return(FAIL); // erase error
      }
    }    
    address += size;
    sectors++;
  }
  return(ResetFlash());
}

unsigned long ResetFlash(void)
{
  vuint32 base = MCF_FBCS0_CSAR & 0xFFFF0000;
  *(vuint16 *)base = CMD_READ; // Read/Reset command
  return(SUCCESS);
}

unsigned long ProgFlash(unsigned long begin, unsigned long end, void *code)
{
  vuint16 *data = (vuint16 *)code;  
  t_sector *sectors = NULL;
  vuint32 address, size;
  vuint32 device = GetFlashDevice();
  unsigned long base = MCF_FBCS0_CSAR & 0xFFFF0000;
  vuint16 status, flag;
  int i = 0;
  while(supported_devices[i].sectors != NULL)
  {
    if(device == supported_devices[i].device)
      sectors = supported_devices[i].sectors;
    i++;
  }
  if(sectors == NULL)
    return(FAIL);
  while(sectors->unlock1 && sectors->unlock2)
  {
    address = base + sectors->offset;  
    size = sectors[1].offset - sectors[0].offset;
    if((address >= (begin & ~(size-1))) && (address < end))
    { 
      vuint16 *unlock1 = (vuint16 *)(base + sectors->unlock1);
      vuint16 *unlock2 = (vuint16 *)(base + sectors->unlock2);
      address = begin & ~1;
      while(begin < end)
      {
        int j = 15;    
        *unlock1 = CMD_UNLOCK1; // unlock
        *unlock2 = CMD_UNLOCK2;
        *unlock1 = CMD_PROGRAM; // Program command
        do
        {
          flag = *(vuint16 *)address = *data;
          flag &= 0x0080;
          while(((((status = *(vuint16 *)address) ^ flag) & 0x0080) != 0) && !(status & 0x0020)); // wait
          if(!((status & 0x0020) && (((*(vuint16 *)address ^ flag) & 0x0080) != 0)))
            break;
        }
        while(--j > 0); // retry
        if((j < 0) || (*(vuint16 *)address != *data)) // verify
        {
          ResetFlash();
          return(FAIL); // write error
        }
        address += 2;
        data++;
      }
    }
    sectors++;
  }
  return(ResetFlash());
}

