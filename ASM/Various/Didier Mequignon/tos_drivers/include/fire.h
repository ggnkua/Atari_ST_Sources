/* TOS 4.04 Xbios for Coldfire boards
*  Didier Mequignon 2006-2010, e-mail: aniplay@wanadoo.fr
*
*  This library is free software; you can redistribute it and/or
*  modify it under the terms of the GNU Lesser General Public
*  License as published by the Free Software Foundation; either
*  version 2.1 of the License, or (at your option) any later version.
*
*  This library is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
*  Lesser General Public License for more details.
*
*  You should have received a copy of the GNU Lesser General Public
*  License along with this library; if not, write to the Free Software
*  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#ifndef	_FIRE_H
#define	_FIRE_H

#define DEFAULT_LANG_KEYB 0x202  /* 0: english, 0x202: french */

#include "ramcf68k.h"         // offsets in memory

#ifdef MCF5445X

#include "mcf5445x.h"

#define BOOT_FLASH_BASE       0xC0000000
#define BOOT_FLASH_SIZE       0x01000000  // 16MB
#define FLASH_TOS_FIRE_ENGINE 0xC0000000  // first 1.2MB

/*
 * Flash Boot 1
 * Sectors 0 through 127 are 128 KBytes
 */
#define FLASH_UNLOCK1 (FLASH_TOS_FIRE_ENGINE-BOOT_FLASH_BASE+FLASH_SIZE-PARAM_SIZE)
#define FLASH_UNLOCK2 (FLASH_TOS_FIRE_ENGINE-BOOT_FLASH_BASE+FLASH_SIZE-PARAM_SIZE)

#define __MMU_BASE            0xFF040000   // 64KB

#define SDRAM_BASE            0x00000000
#define SDRAM_SIZE            0x10000000   // 256MB
#define SDRAM_RESERVED        0x00600000   // 4MB + 1MB + 1MB
#define SRAM_BASE             0x80000000   // 32KB
#define SRAM_SIZE             0x00004000   // 16KB normal, 16KB remapped by the MMU
#define PHYSICAL_OFFSET_SDRAM 0x40000000   // remapped for TOS to 0

#define RAM_BASE_FEC          SRAM_BASE

#define CPLD_BASE             0xC1000000

#define CPLD_VERSION          (CPLD_BASE+0)
#define CPLD_CONTROL          (CPLD_BASE+1)
#define CPLD_SDODT            (CPLD_BASE+2)
#define CPLD_MODE             (CPLD_BASE+3)
#define CPLD_FLASHCFG         (CPLD_BASE+4)
#define CPLD_LEDS             (CPLD_BASE+5)

#define CONTROL_ULPI_PHY_MODE 0x01 // 0 for ULPI PHY in normal mode
#define CONTROL_ATA_FEC1_MODE 0x02 // 0 for ATA enable
#define CONTROL_FEC0_PHY_MODE 0x04 // 0 FEC0 PHY in normal mode
#define FLASH_WP              0x01 // 0 for write protected

#define FPGA_BASE             0xC2000000

#define FPGA_IRQEN            (FPGA_BASE+0x00)
#define FPGA_IRQSTATUS        (FPGA_BASE+0x04)
#define FPGA_PCICLKCFG        (FPGA_BASE+0x08)
#define FPGA_IRQROUTE         (FPGA_BASE+0x0C)
#define FPGA_VERSION          (FPGA_BASE+0x10)
#define FPGA_7SEGMENT         (FPGA_BASE+0x14)
#define FPGA_LEDS             (FPGA_BASE+0x18)

#define IRQEN_PCI             0x0000000F // 4 sources, 1 for enabled
#define IRQEN_SW6             0x00000010 // 1 for SW6 interrupt enabled
#define IRQEN_SW7             0x00000020 // 1 for SW7 interrupt enabled

#define IRQSTATUS_PCI         0x0000000F // 4 sources, 1 for asserted
#define IRQSTATUS_SW6         0x00000010 // 1 for SW6 interrupt asserted
#define IRQSTATUS_SW7         0x00000020 // 1 for SW7 interrupt asserted

#define IRQCLKCFG_CLKGENS2EN  0x00000001 // assert S2: 0 for input clock and PCI clocks operating at 33 MHz
#define IRQCLKCFG_CLKGENS2    0x00000002 // state of S2: 0 for input clock and PCI clocks operating at 33 MHz
#define IRQCLKCFG_M66EN       0x00000004 // 0 if 33 MHz card is on PCI slot

#define IRQROUTE_PCI_IRQ1     0x00000000 // PCI IRQ selection IRQ1
#define IRQROUTE_PCI_IRQ3     0x00000001 // PCI IRQ selection IRQ3 *
#define IRQROUTE_PCI_IRQ4     0x00000002 // PCI IRQ selection IRQ4
#define IRQROUTE_PCI_IRQ7     0x00000003 // PCI IRQ selection IRQ7 
#define IRQROUTE_SW6_IRQ1     0x00000000 // SW6 IRQ selection IRQ1
#define IRQROUTE_SW6_IRQ3     0x00000004 // SW6 IRQ selection IRQ3
#define IRQROUTE_SW6_IRQ4     0x00000008 // SW6 IRQ selection IRQ4 *
#define IRQROUTE_SW6_IRQ7     0x0000000C // SW6 IRQ selection IRQ7
#define IRQROUTE_SW7_IRQ1     0x00000000 // SW7 IRQ selection IRQ1
#define IRQROUTE_SW7_IRQ3     0x00000010 // SW7 IRQ selection IRQ3
#define IRQROUTE_SW7_IRQ4     0x00000020 // SW7 IRQ selection IRQ4
#define IRQROUTE_SW7_IRQ7     0x00000030 // SW7 IRQ selection IRQ7 * (* for default settings)

#define LEDS_LED1             0x00000001
#define LEDS_LED2             0x00000002

#define SYSTEM_CLOCK 132    // system bus frequency in MHz

#define CFG_SDRAM_CFG1        0x65311610
#define CFG_SDRAM_CFG2        0x59670000
#define CFG_SDRAM_CTRL        0xEA0B2000
#define CFG_SDRAM_EMOD        0x40010000
#define CFG_SDRAM_MODE        0x00010033

#define CFG_RTC_OSCILLATOR    32000

/* Intel Flash */
#define CFG_CS0_BASE          0x00000000
#define CFG_CS0_MASK          0x01FF0001
#define CFG_CS0_CTRL          0x00000D60
 /* Atmel Flash */
#define CFG_CS1_BASE		      0x04000000
#define CFG_CS1_MASK		      0x00070001
#define CFG_CS1_CTRL		      0x00001140
/* CPLD */
#define CFG_CS2_BASE		      0x08000000
#define CFG_CS2_MASK		      0x00070001
#define CFG_CS2_CTRL		      0x003f1140
/* FPGA */
#define CFG_CS3_BASE		      0x09000000
#define CFG_CS3_MASK		      0x00070001
#define CFG_CS3_CTRL		      0x00000020

#define MCF_FBCS_CSAR0        MCF_FBCS0_CSAR

#define MCF_UART_UMR0         MCF_UART0_UMR
#define MCF_UART_USR0         MCF_UART0_USR
#define MCF_UART_UCSR0        MCF_UART0_UCSR
#define MCF_UART_UCR0         MCF_UART0_UCR
#define MCF_UART_URB0         MCF_UART0_URB
#define MCF_UART_UTB0         MCF_UART0_UTB
#define MCF_UART_UIPCR0       MCF_UART0_UIPCR
#define MCF_UART_UACR0        MCF_UART0_UACR 
#define MCF_UART_UISR0        MCF_UART0_UISR
#define MCF_UART_UIMR0        MCF_UART0_UIMR 
#define MCF_UART_UBG10        MCF_UART0_UBG1 
#define MCF_UART_UBG20        MCF_UART0_UBG2
#define MCF_UART_UIP0         MCF_UART0_UIP  
#define MCF_UART_UOP10        MCF_UART0_UOP1 
#define MCF_UART_UOP00        MCF_UART0_UOP0  
#define MCF_UART_UMR1         MCF_UART1_UMR
#define MCF_UART_USR1         MCF_UART1_USR
#define MCF_UART_UCS01        MCF_UART1_UCSR
#define MCF_UART_UCR1         MCF_UART1_UCR
#define MCF_UART_URB1         MCF_UART1_URB
#define MCF_UART_UTB1         MCF_UART1_UTB
#define MCF_UART_UIPCR1       MCF_UART1_UIPCR
#define MCF_UART_UACR1        MCF_UART1_UACR
#define MCF_UART_UISR1        MCF_UART1_UISR
#define MCF_UART_UIMR1        MCF_UART1_UIMR
#define MCF_UART_UBG11        MCF_UART1_UBG1
#define MCF_UART_UBG21        MCF_UART1_UBG2
#define MCF_UART_UIP1         MCF_UART1_UIP  
#define MCF_UART_UOP11        MCF_UART1_UOP1 
#define MCF_UART_UOP01        MCF_UART1_UOP0
#define MCF_UART_UMR2         MCF_UART2_UMR
#define MCF_UART_USR2         MCF_UART2_USR
#define MCF_UART_UCSR2        MCF_UART2_UCSR
#define MCF_UART_UCR2         MCF_UART2_UCR
#define MCF_UART_URB2         MCF_UART2_URB
#define MCF_UART_UTB2         MCF_UART2_UTB
#define MCF_UART_UIPCR2       MCF_UART2_UIPCR
#define MCF_UART_UACR2        MCF_UART2_UACR
#define MCF_UART_UISR2        MCF_UART2_UISR
#define MCF_UART_UIMR2        MCF_UART2_UIMR
#define MCF_UART_UBG12        MCF_UART2_UBG1
#define MCF_UART_UBG22        MCF_UART2_UBG2
#define MCF_UART_UIP2         MCF_UART2_UIP
#define MCF_UART_UOP12        MCF_UART2_UOP1
#define MCF_UART_UOP02        MCF_UART2_UOP0

#define MCF_UART_UMR_PT       UART_UMR_PT
#define MCF_UART_UMR_ERR      UART_UMR_ERR
#define MCF_UART_UMR_RXIRQ    UART_UMR_RXIRQ
#define MCF_UART_UMR_RXRTS    UART_UMR_RXRTS
#define MCF_UART_UMR_TXCTS    UART_UMR_TXCTS
#define MCF_UART_UMR_TXRTS    UART_UMR_TXRTS
#define MCF_UART_UMR_PM_MULTI_ADDR UART_UMR_PM_MULTI_ADDR
#define MCF_UART_UMR_PM_MULTI_DATA UART_UMR_PM_MULTI_DATA
#define MCF_UART_UMR_PM_NONE  UART_UMR_PM_NONE
#define MCF_UART_UMR_PM_FORCE_HI UART_UMR_PM_FORCE_HI
#define MCF_UART_UMR_PM_FORCE_LO UART_UMR_PM_FORCE_LO
#define MCF_UART_UMR_PM_ODD   UART_UMR_PM_ODD
#define MCF_UART_UMR_PM_EVEN  UART_UMR_PM_EVEN
#define MCF_UART_UMR_BC_5     UART_UMR_BC_5
#define MCF_UART_UMR_BC_6     UART_UMR_BC_6
#define MCF_UART_UMR_BC_7     UART_UMR_BC_7
#define MCF_UART_UMR_BC_8     UART_UMR_BC_8
#define MCF_UART_UMR_CM_NORMAL UART_UMR_CM_NORMAL
#define MCF_UART_UMR_CM_ECHO  UART_UMR_CM_ECHO
#define MCF_UART_UMR_CM_LOCAL_LOOP UART_UMR_CM_LOCAL_LOOP
#define MCF_UART_UMR_CM_REMOTE_LOOP UART_UMR_CM_REMOTEL_LOOP
#define MCF_UART_UMR_SB_STOP_BITS_1 UART_UMR_SB_STOP_BITS_1
#define MCF_UART_UMR_SB_STOP_BITS_15 UART_UMR_SB_STOP_BITS_15
#define MCF_UART_UMR_SB_STOP_BITS_2 UART_UMR_SB_STOP_BITS_2	

#define MCF_UART_USR_RXRDY    UART_USR_RXRDY
#define MCF_UART_USR_TXRDY    UART_USR_TXRDY
#define MCF_UART_USR_TXEMP    UART_USR_TXEMP
#define MCF_UART_USR_OE       UART_USR_OE
#define MCF_UART_USR_PE       UART_USR_PE
#define MCF_UART_USR_FE       UART_USR_FE
#define MCF_UART_USR_RB       UART_USR_RB

#define MCF_UART_UCSR_RCS_SYS_CLK UART_UCSR_RCS_SYS_CLK
#define MCF_UART_UCSR_RCS_CTM16 UART_UCSR_RCS_CTM16
#define MCF_UART_UCSR_RCS_CTM UART_UCSR_RCS_CTM
#define MCF_UART_UCSR_TCS_SYS_CLK UART_UCSR_TCS_SYS_CLK
#define MCF_UART_UCSR_TCS_CTM16 UART_UCSR_TCS_CTM16
#define MCF_UART_UCSR_TCS_CTM UART_UCSR_TCS_CTM

#define MCF_UART_UCR_NONE     UART_UCR_NONE
#define MCF_UART_UCR_STOP_BREAK UCR_STOP_BREAK 
#define MCF_UART_UCR_START_BREAK UCR_START_BREAK  
#define MCF_UART_UCR_BKCHGINT UART_UCR_BKCHGINT
#define MCF_UART_UCR_RESET_ERROR UART_UCR_RESET_ERROR
#define MCF_UART_UCR_RESET_TX	UART_UCR_RESET_TX
#define MCF_UART_UCR_RESET_RX	UART_UCR_RESET_RX
#define MCF_UART_UCR_RESET_MR	UART_UCR_RESET_MR
#define MCF_UART_UCR_TX_DISABLED UART_UCR_TX_DISABLED
#define MCF_UART_UCR_TX_ENABLED UART_UCR_TX_ENABLED
#define MCF_UART_UCR_RX_DISABLED UART_UCR_RX_DISABLED
#define MCF_UART_UCR_RX_ENABLED UART_UCR_RX_ENABLED

#define MCF_UART_UIPCR_CTS    UART_UIPCR_CTS 
#define MCF_UART_UIPCR_COS    MCF_UART_UIPCR_COS

#define MCF_UART_UACR_IEC     UART_UACR_IEC

#define MCF_UART_UIMR_TXRDY   UART_UIMR_TXRDY
#define MCF_UART_UIMR_RXRDY_FU UART_UIMR_RXRDY_FU
#define MCF_UART_UIMR_DB      UART_UIMR_DB
#define MCF_UART_UIMR_COS	    UART_UIMR_COS

#define MCF_UART_UISR_TXRDY   UART_UISR_TXRDY
#define MCF_UART_UISR_RXRDY_FU UART_UISR_RXRDY_FU
#define MCF_UART_UISR_DB      UART_UISR_DB
#define MCF_UART_UISR_RXFTO   UART_UISR_RXFTO
#define MCF_UART_UISR_TXFIFO  UART_UISR_TXFIFO
#define MCF_UART_UISR_RXFIFO  UART_UISR_RXFIFO
#define MCF_UART_UISR_COS     UART_UISR_COS

#define MCF_UART_UIP_CTS      UART_UIP_CTS  

#define MCF_UART_UOP1_RTS     UART_UOP1_RTS

#define MCF_UART_UOP0_RTS     UART_UOP0_RTS

#define MCF_PCI_PCICAR_E      PCI_CAR_E

#define ATA_DATA            MCF_ATA_DRIVE_DATA
#define ATA_ERROR_REGISTER  MCF_ATA_DRIVE_FEATURES
#define ATA_SECTOR_COUNT    MCF_ATA_DRIVE_SECTOR_COUNT
#define ATA_SECTOR_NUM      MCF_ATA_DRIVE_LBA_LOW  // LBA bits 0-7
#define ATA_CYLINDER_LOW    MCF_ATA_DRIVE_LBA_MID  // LBA bits 7-15
#define ATA_CYLINDER_HIGH   MCF_ATA_DRIVE_LBA_HIGH // LBA bits 16-23
#define ATA_DEVICE_HEAD     MCF_ATA_DRIVE_DEV_HEAD // LBA bits 24-27
#define ATA_STATUS_COMMAND  MCF_ATA_DRIVE_COMMAND
#define ATA_CONTROL_DEVICE  MCF_ATA_DRIVE_CONTROL

#define FALCON_ATA_DATA           0xFFF00000
#define FALCON_ATA_ERROR_REGISTER 0xFFF00005
#define FALCON_ATA_SECTOR_COUNT   0xFFF00009
#define FALCON_ATA_SECTOR_NUM     0xFFF0000D // LBA bits 0-7
#define FALCON_ATA_CYLINDER_LOW   0xFFF00011 // LBA bits 7-15
#define FALCON_ATA_CYLINDER_HIGH  0xFFF00015 // LBA bits 16-23
#define FALCON_ATA_DEVICE_HEAD    0xFFF00019 // LBA bits 24-27
#define FALCON_ATA_STATUS_COMMAND 0xFFF0001D
#define FALCON_ATA_CONTROL_DEVICE 0xFFF00039

#define CF_CACR_DEC         (0x80000000) /* Data Cache Enable                */
#define CF_CACR_DW          (0x40000000) /* Data default Write-protect       */
#define CF_CACR_DESB        (0x20000000) /* Data Enable Store Buffer         */
#define CF_CACR_DDPI        (0x10000000) /* Data Disable CPUSHL Invalidate   */
#define CF_CACR_DHLCK       (0x08000000) /* 1/2 Data Cache Lock Mode         */
#define CF_CACR_DDCM_00     (0x00000000) /* Cacheable writethrough imprecise */
#define CF_CACR_DDCM_01     (0x02000000) /* Cacheable copyback               */
#define CF_CACR_DDCM_10     (0x04000000) /* Noncacheable precise             */
#define CF_CACR_DDCM_11     (0x06000000) /* Noncacheable imprecise           */
#define CF_CACR_DCINVA      (0x01000000) /* Data Cache Invalidate All        */
#define CF_CACR_DDSP        (0x00800000) /* Data Default Supervisor Protect  */
#define CF_CACR_IVO         (0x00100000) /* Invalidate Only                  */
#define CF_CACR_BEC         (0x00080000) /* Branch Cache Enable              */
#define CF_CACR_BCINVA      (0x00040000) /* Branch Cache Invalidate All      */
#define CF_CACR_IEC         (0x00008000) /* Instruction Cache Enable         */
#define CF_CACR_SPA         (0x00004000) /* Search by Physical Address       */
#define CF_CACR_DNFB        (0x00002000) /* Default cache-inhibited fill buf */
#define CF_CACR_IDPI        (0x00001000) /* Instr Disable CPUSHL Invalidate  */
#define CF_CACR_IHLCK       (0x00000800) /* 1/2 Instruction Cache Lock Mode  */
#define CF_CACR_IDCM        (0x00000400) /* Noncacheable Instr default mode  */
#define CF_CACR_ICINVA      (0x00000100) /* Instr Cache Invalidate All       */
#define CF_CACR_IDSP        (0x00000080) /* Instr Default Supervisor Protect */
#define CF_CACR_EUSP        (0x00000020) /* Switch stacks in user mode       */

#define DCACHE_LINE_SIZE 0x0010     /* bytes per line        */
#define DCACHE_WAY_SIZE  0x1000     /* words per cache block */
#define CACHE_DISABLE_MODE (CF_CACR_DCINVA+CF_CACR_BCINVA+CF_CACR_ICINVA+CF_CACR_EUSP)
#define CACHE_ENABLE_MODE (CF_CACR_DEC+CF_CACR_DESB+CF_CACR_BEC+CF_CACR_IEC+CF_CACR_EUSP)

#define _DCACHE_SIZE (2*8192)
#define _ICACHE_SIZE (2*8192)

#define _SET_SHIFT 4

/* Masks for cache sizes, because the set size is a power of two, the mask is also the last address in the set */
#define _DCACHE_SET_MASK ((_DCACHE_SIZE/64-1)<<_SET_SHIFT)
#define _ICACHE_SET_MASK ((_ICACHE_SIZE/64-1)<<_SET_SHIFT)
#define LAST_DCACHE_ADDR _DCACHE_SET_MASK
#define LAST_ICACHE_ADDR _ICACHE_SET_MASK

#else /* MCF547X - MCF548X */

#ifdef MCF547X /* FIREBEE */

#define USE_ATARI_IO          // IDE, SCSI

#define __MBAR                0xFF000000  // - 0xFF81FFFF 128KB (256KB if SEC)

#define __MMU_BASE            0xFF040000  // 64KB

#define BOOT_FLASH_BASE       0xE0000000
#define BOOT_FLASH_SIZE       0x00800000  // 8MB
#define FLASH_TOS_FIRE_ENGINE 0xE0400000  // 1MB

#define DATA_FPGA             0xE0700000
#define SIZE_FPGA             0x00100000

/*
 * Flash 
 * Sectors 0 through 7 are 8 KBytes
 * Sectors 8 through 134 are 64 KBytes
 */
#define FLASH_UNLOCK1 (0xAAA)
#define FLASH_UNLOCK2 (0x554)

/* FALCON I/O 1MB */
#define FPGA_CS1_BASE  0xFFF00000
#define FPGA_CS1_SIZE  0x00100000
#define FPGA_CS1_ACCESS (MCF_FBCS_CSCR_AA + MCF_FBCS_CSCR_RDAH(1) + MCF_FBCS_CSCR_WS(16) + MCF_FBCS_CSCR_PS_16)
/* ACP I/O 128MB */ 
#define FPGA_CS2_BASE  0xF0000000
#define FPGA_CS2_SIZE  0x08000000
#define FPGA_CS2_ACCESS (MCF_FBCS_CSCR_AA + MCF_FBCS_CSCR_RDAH(1) + MCF_FBCS_CSCR_WS(4) + MCF_FBCS_CSCR_PS_32)
/* SRAM 256Kx16 */
#define FPGA_CS3_BASE  0xF8000000
#define FPGA_CS3_SIZE  0x04000000
#define FPGA_CS3_ACCESS (MCF_FBCS_CSCR_AA + MCF_FBCS_CSCR_RDAH(1) + MCF_FBCS_CSCR_WS(0) + MCF_FBCS_CSCR_PS_16)
/* VIDEO RAM 128MB */ 
#define FPGA_CS4_BASE  0x40000000
#define FPGA_CS4_SIZE  0x40000000
#define FPGA_CS4_ACCESS (MCF_FBCS_CSCR_BSTW + MCF_FBCS_CSCR_BSTR + MCF_FBCS_CSCR_PS_32)

#define ACP_VIDEO_RAM          (FPGA_CS4_BASE)
#define ACP_VIDEO_CFG          (FPGA_CS4_BASE + 0x20000000)
#define ACP_VIDEO_CLUT         (FPGA_CS2_BASE)
#define ACP_VIDEO_CONTROL      (FPGA_CS2_BASE + 0x400)
#define ACP_VIDEO_BORDER_COLOR (FPGA_CS2_BASE + 0x404)
#define ACP_ST_MODES           (FPGA_CS2_BASE + 0x410)
#define ACP_BORDER_ON          0x02000000
#define ACP_FIFO_ON            0x01000000
#define ACP_CONFIG_ON          0x00080000
#define ACP_REFRESH_ON         0x00040000
#define ACP_VCS                0x00020000
#define ACP_VCKE               0x00010000
#define ACP_SYNC               0x00008000
#define ACP_CLK25              0x00000000
#define ACP_CLK33              0x00000100
#define ACP_CLK_PLL            0x00000200
// old hardware
#define ACP_CLK48              0x00000200
#define ACP_CLK55              0x00000300
#define ACP_CLK60              0x00000400
#define ACP_CLK69              0x00000500
#define ACP_CLK75              0x00000600
#define ACP_CLK83              0x00000700
#define ACP_CLK92              0x00001000
#define ACP_CLK100             0x00001100
#define ACP_CLK109             0x00001200
#define ACP_CLK120             0x00001300
#define ACP_CLK137             0x00001400
#define ACP_CLK150             0x00001500
#define ACP_CLK166             0x00001600
// end old hardware
#define ACP_ST_SHIFT_MODE      0x00000080
#define ACP_FALCON_SHIFT       0x00000040
#define ACP_COLOR_1            0x00000020
#define ACP_COLOR_8            0x00000010
#define ACP_COLOR_16           0x00000008
#define ACP_COLOR_24           0x00000004
#define ACP_VIDEO_DAC_ON       0x00000002
#define ACP_VIDEO_ON           0x00000001
#define ACP_VIDEO_PLL_CONFIG   (FPGA_CS2_BASE + 0x600)
#define ACP_VIDEO_PLL_CLK      (FPGA_CS2_BASE + 0x604)
#define ACP_VIDEO_PLL_RECONFIG (FPGA_CS2_BASE + 0x800)
#define ACP_INTERRUPT_CONTROL  (FPGA_CS2_BASE + 0x10000)
#define ACP_INTERRUPT_ENABLE   (FPGA_CS2_BASE + 0x10004)
#define ACP_INTERRUPT_CLEAR    (FPGA_CS2_BASE + 0x10008)
#define ACP_INTERRUPT_PENDING  (FPGA_CS2_BASE + 0x1000C)
#define ACP_INT_IRQ7           0x80000000
#define ACP_INT_MFP_IRQ6       0x40000000
#define ACP_INT_ACP_IRQ5       0x20000000
#define ACP_INT_VSYNC_IRQ4     0x10000000
#define ACP_INT_CTR0_IRQ3      0x08000000
#define ACP_INT_HSYNC_IRQ2     0x04000000
#define ACP_INT_HSYNC          0x00000200
#define ACP_INT_VSYNC          0x00000100
#define ACP_INT_DSP            0x00000080
#define ACP_INT_PCI_INTD       0x00000040
#define ACP_INT_PCI_INTC       0x00000020
#define ACP_INT_PCI_INTB       0x00000010
#define ACP_INT_PCI_INTA       0x00000008
#define ACP_INT_DVI            0x00000004
#define ACP_INT_ETHERNET       0x00000002
#define ACP_INT_PIC            0x00000001
#define ACP_MFP_INTACK_VECTOR  (FPGA_CS2_BASE + 0x20000)
#define ACP_DMA_MODE           (FPGA_CS2_BASE + 0x20100)
#define ACP_DMA_ADDRESS        (FPGA_CS2_BASE + 0x20104)
#define ACP_DMA_COUNTER        (FPGA_CS2_BASE + 0x20108)
#define ACP_DMA_CONTROL        (FPGA_CS2_BASE + 0x2010C)
#define ACP_FIFO_PSEUDO_DMA    (FPGA_CS2_BASE + 0x20110)
#define ACP_CONFIG             (FPGA_CS2_BASE + 0x40000)
#define ACP_CF_IDE             0xC0000000
#define ACP_DD_HD              0x20000000
#define ACP_IDE_INT_ENABLE     0x10000000
#define ACP_SCSI_INT_ENABLE    0x08000000

#else /* Fire Engine (M5484LITE/M5485EVB) only */

#define __MBAR                 0xFF000000  // - 0xFF01FFFF 128KB (256KB if SEC)

#define __MMU_BASE             0xFF040000  // 64KB

#define BOOT_FLASH_BASE        0xFF800000
#define BOOT_FLASH_SIZE        0x00200000  // 2MB (the M5484LITE has 4MB)
#define FLASH_TOS_FIRE_ENGINE  0xFF900000  // one 1MB (last MB on M5485EVB who has 2MB, the M5484LITE has 4MB)

/*
 * Flash Boot M5484LITE
 * Sectors 0 through 7 are 8 KBytes
 * Sectors 8 through 70 are 64 KBytes
 */
#define FLASH_UNLOCK1 (FLASH_TOS_FIRE_ENGINE-BOOT_FLASH_BASE+FLASH_SIZE-PARAM_SIZE)
#define FLASH_UNLOCK2 (FLASH_TOS_FIRE_ENGINE-BOOT_FLASH_BASE+FLASH_SIZE-PARAM_SIZE)


#define FIRE_ENGINE_CS4_BASE  0xC0000000
#define FIRE_ENGINE_CS4_SIZE  0x10000000
#define FIRE_ENGINE_CS4_ACCESS \
        (MCF_FBCS_CSCR_ASET(1) + MCF_FBCS_CSCR_WS(25) + MCF_FBCS_CSCR_AA + MCF_FBCS_CSCR_PS_16) // 0x106580
#define FIRE_ENGINE_CS5_BASE  0xE0000000
#define FIRE_ENGINE_CS5_SIZE  0x10000000
#define FIRE_ENGINE_CS5_ACCESS \
        (MCF_FBCS_CSCR_ASET(1) + MCF_FBCS_CSCR_WS(10) + MCF_FBCS_CSCR_AA + MCF_FBCS_CSCR_PS_16) // 0x102980

#define FIRE_ENGINE_CPLD_HW_REVISION (FIRE_ENGINE_CS5_BASE+0x08000000)
#define FIRE_ENGINE_CPLD_SW_REVISION (FIRE_ENGINE_CS5_BASE+0x07000000)
#define FIRE_ENGINE_CPLD_PWRMGT (FIRE_ENGINE_CS5_BASE+0x04000000)

#define COMPACTFLASH_BASE   (FIRE_ENGINE_CS5_BASE+0x0A000000)

#define COMPACTFLASH_CIS    COMPACTFLASH_BASE
#define COMPACTFLASH_CONFIG (COMPACTFLASH_BASE+0x200)
#define ATA_ERROR_REGISTER  (COMPACTFLASH_BASE+0x180C)
#define ATA_SECTOR_COUNT    (COMPACTFLASH_BASE+0x1803)
#define ATA_SECTOR_NUM      (COMPACTFLASH_BASE+0x1802) // LBA bits 0-7
#define ATA_CYLINDER_LOW    (COMPACTFLASH_BASE+0x1805) // LBA bits 7-15
#define ATA_CYLINDER_HIGH   (COMPACTFLASH_BASE+0x1804) // LBA bits 16-23
#define ATA_DEVICE_HEAD     (COMPACTFLASH_BASE+0x1807) // LBA bits 24-27
#define ATA_STATUS_COMMAND  (COMPACTFLASH_BASE+0x1806)
#define ATA_DATA            (COMPACTFLASH_BASE+0x1808)
#define ATA_CONTROL_DEVICE  (COMPACTFLASH_BASE+0x180F)

#endif /* MCF547X */

#define FALCON_ATA_DATA           0xFFF00000
#define FALCON_ATA_ERROR_REGISTER 0xFFF00005
#define FALCON_ATA_SECTOR_COUNT   0xFFF00009
#define FALCON_ATA_SECTOR_NUM     0xFFF0000D // LBA bits 0-7
#define FALCON_ATA_CYLINDER_LOW   0xFFF00011 // LBA bits 7-15
#define FALCON_ATA_CYLINDER_HIGH  0xFFF00015 // LBA bits 16-23
#define FALCON_ATA_DEVICE_HEAD    0xFFF00019 // LBA bits 24-27
#define FALCON_ATA_STATUS_COMMAND 0xFFF0001D
#define FALCON_ATA_CONTROL_DEVICE 0xFFF00039

#define SDRAM_BASE                0x00000000
#ifdef MCF547X
#define SDRAM_SIZE                0x20000000 // 512MB
#else /* MCF548X */
#define SDRAM_SIZE                0x04000000 // 64MB
#endif /* MCF547X */
#define SDRAM_RESERVED            0x00600000 // 4MB + 1MB + 1MB
                            
#ifdef MCF547X

#define SRAM_BASE                 0xFF100000 // 4096
#define SRAM_BASE2                0xFF101000 // 4096

#define SYSTEM_CLOCK  132   // system bus frequency in MHz
#define SYSTEM_PERIOD_X10 75   // system bus period in nS * 10
#define SDRAM_TWR  2        // clocks
#define SDRAM_CASL 5        // clocks * 2
#define SDRAM_TRCD 20       // nS
#define SDRAM_TRP  20       // nS
#define SDRAM_TRFC 75       // nS
#define SDRAM_TREFI 7800    // nS

#else /* MCF548X */

#define SRAM_BASE                 0xFFF00000 // 4096 IDE F030
#define SRAM_BASE2                0xFFFFF000 // 4096 some I/O F030

#define SYSTEM_CLOCK 100    // system bus frequency in MHz
#define SYSTEM_PERIOD 10    // system bus period in nS
#define SDRAM_TWR  2        // clocks
#define SDRAM_CASL 5        // clocks * 2
#define SDRAM_TRCD 20       // nS
#define SDRAM_TRP  20       // nS
#define SDRAM_TRFC 75       // nS
#define SDRAM_TREFI 7800    // nS

#endif /* MCF547X */

#define CF_CACR_DEC         (0x80000000) /* Data Cache Enable                */
#define CF_CACR_DW          (0x40000000) /* Data default Write-protect       */
#define CF_CACR_DESB        (0x20000000) /* Data Enable Store Buffer         */
#define CF_CACR_DDPI        (0x10000000) /* Data Disable CPUSHL Invalidate   */
#define CF_CACR_DHLCK       (0x08000000) /* 1/2 Data Cache Lock Mode         */
#define CF_CACR_DDCM_00     (0x00000000) /* Cacheable writethrough imprecise */
#define CF_CACR_DDCM_01     (0x02000000) /* Cacheable copyback               */
#define CF_CACR_DDCM_10     (0x04000000) /* Noncacheable precise             */
#define CF_CACR_DDCM_11     (0x06000000) /* Noncacheable imprecise           */
#define CF_CACR_DCINVA      (0x01000000) /* Data Cache Invalidate All        */
#define CF_CACR_DDSP        (0x00800000) /* Data Default Supervisor Protect  */
#define CF_CACR_BEC         (0x00080000) /* Branch Cache Enable              */
#define CF_CACR_BCINVA      (0x00040000) /* Branch Cache Invalidate All      */
#define CF_CACR_IEC         (0x00008000) /* Instruction Cache Enable         */
#define CF_CACR_DNFB        (0x00002000) /* Default cache-inhibited fill buf */
#define CF_CACR_IDPI        (0x00001000) /* Instr Disable CPUSHL Invalidate  */
#define CF_CACR_IHLCK       (0x00000800) /* 1/2 Instruction Cache Lock Mode  */
#define CF_CACR_IDCM        (0x00000400) /* Noncacheable Instr default mode  */
#define CF_CACR_ICINVA      (0x00000100) /* Instr Cache Invalidate All       */
#define CF_CACR_IDSP        (0x00000080) /* Instr Default Supervisor Protect */
#define CF_CACR_EUSP        (0x00000020) /* Switch stacks in user mode       */
#define CF_CACR_DF          (0x00000010) /* Disable FPU                      */

#define DCACHE_LINE_SIZE 0x0010     /* bytes per line        */
#define DCACHE_WAY_SIZE  0x2000     /* words per cache block */
#define CACHE_DISABLE_MODE (CF_CACR_DCINVA+CF_CACR_BCINVA+CF_CACR_ICINVA+CF_CACR_EUSP)
#define CACHE_ENABLE_MODE (CF_CACR_DEC+CF_CACR_DESB+CF_CACR_BEC+CF_CACR_IEC+CF_CACR_EUSP)

#define _DCACHE_SIZE (2*16384)
#define _ICACHE_SIZE (2*16384)

#define _SET_SHIFT 4

/* Masks for cache sizes, because the set size is a power of two, the mask is also the last address in the set */
#define _DCACHE_SET_MASK ((_DCACHE_SIZE/64-1)<<_SET_SHIFT)
#define _ICACHE_SET_MASK ((_ICACHE_SIZE/64-1)<<_SET_SHIFT)
#define LAST_DCACHE_ADDR _DCACHE_SET_MASK
#define LAST_ICACHE_ADDR _ICACHE_SET_MASK

#include "mcf548x_siu.h"    // System Integration Unit
#include "mcf548x_gpio.h"   // General Purpose I/O
#include "mcf548x_eport.h"  // Edge Port Module
#include "mcf548x_uart.h"   // Programmable Serial Controller
#include "mcf548x_psc.h"    // Programmable Serial Controller
#ifndef MCF547X
#include "mcf548x_can.h"    // FlexCAN Module
#endif
#include "mcf548x_gpt.h"    // General Purpose Timers
#include "mcf548x_slt.h"    // Slice Timers
#include "mcf548x_fbcs.h"   // FlexBus Chip Selects
#include "mcf548x_sdramc.h" // SDRAM Controller
#include "mcf548x_xarb.h"   // XL Bus Arbiter
#include "mcf548x_pci.h"    // PCI Bus Controller
#include "mcf548x_pciarb.h" // PCI Arbiter Module
#include "mcf548x_intc.h"   // Interrupt Controller
#include "mcf548x_dspi.h"   // DSPI
#include "mcf548x_i2c.h"    // I2C
#include "mcf548x_pll.h"    // PLL

#endif /* MCF5445X */

#endif
