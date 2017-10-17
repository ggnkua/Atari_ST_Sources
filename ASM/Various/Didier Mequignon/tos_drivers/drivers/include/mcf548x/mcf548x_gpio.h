/*
 * File:	mcf548x_gpio.h
 * Purpose:	Register and bit definitions for the MCF548X
 *
 * Notes:	
 *	
 */

#ifndef __MCF548X_GPIO_H__
#define __MCF548X_GPIO_H__

/*********************************************************************
*
* General Purpose I/O (GPIO)
*
*********************************************************************/

/* Register read/write macros */
#define MCF_GPIO_PODR_FBCTL         (*(vuint8 *)(void*)(&__MBAR[0x000A00]))
#define MCF_GPIO_PODR_FBCS          (*(vuint8 *)(void*)(&__MBAR[0x000A01]))
#define MCF_GPIO_PODR_DMA           (*(vuint8 *)(void*)(&__MBAR[0x000A02]))
#define MCF_GPIO_PODR_FEC0H         (*(vuint8 *)(void*)(&__MBAR[0x000A04]))
#define MCF_GPIO_PODR_FEC0L         (*(vuint8 *)(void*)(&__MBAR[0x000A05]))
#define MCF_GPIO_PODR_FEC1H         (*(vuint8 *)(void*)(&__MBAR[0x000A06]))
#define MCF_GPIO_PODR_FEC1L         (*(vuint8 *)(void*)(&__MBAR[0x000A07]))
#define MCF_GPIO_PODR_FECI2C        (*(vuint8 *)(void*)(&__MBAR[0x000A08]))
#define MCF_GPIO_PODR_PCIBG         (*(vuint8 *)(void*)(&__MBAR[0x000A09]))
#define MCF_GPIO_PODR_PCIBR         (*(vuint8 *)(void*)(&__MBAR[0x000A0A]))
#define MCF_GPIO_PODR_PSC3PSC2      (*(vuint8 *)(void*)(&__MBAR[0x000A0C]))
#define MCF_GPIO_PODR_PSC1PSC0      (*(vuint8 *)(void*)(&__MBAR[0x000A0D]))
#define MCF_GPIO_PODR_DSPI          (*(vuint8 *)(void*)(&__MBAR[0x000A0E]))
#define MCF_GPIO_PDDR_FBCTL         (*(vuint8 *)(void*)(&__MBAR[0x000A10]))
#define MCF_GPIO_PDDR_FBCS          (*(vuint8 *)(void*)(&__MBAR[0x000A11]))
#define MCF_GPIO_PDDR_DMA           (*(vuint8 *)(void*)(&__MBAR[0x000A12]))
#define MCF_GPIO_PDDR_FEC0H         (*(vuint8 *)(void*)(&__MBAR[0x000A14]))
#define MCF_GPIO_PDDR_FEC0L         (*(vuint8 *)(void*)(&__MBAR[0x000A15]))
#define MCF_GPIO_PDDR_FEC1H         (*(vuint8 *)(void*)(&__MBAR[0x000A16]))
#define MCF_GPIO_PDDR_FEC1L         (*(vuint8 *)(void*)(&__MBAR[0x000A17]))
#define MCF_GPIO_PDDR_FECI2C        (*(vuint8 *)(void*)(&__MBAR[0x000A18]))
#define MCF_GPIO_PDDR_PCIBG         (*(vuint8 *)(void*)(&__MBAR[0x000A19]))
#define MCF_GPIO_PDDR_PCIBR         (*(vuint8 *)(void*)(&__MBAR[0x000A1A]))
#define MCF_GPIO_PDDR_PSC3PSC2      (*(vuint8 *)(void*)(&__MBAR[0x000A1C]))
#define MCF_GPIO_PDDR_PSC1PSC0      (*(vuint8 *)(void*)(&__MBAR[0x000A1D]))
#define MCF_GPIO_PDDR_DSPI          (*(vuint8 *)(void*)(&__MBAR[0x000A1E]))
#define MCF_GPIO_PPDSDR_FBCTL       (*(vuint8 *)(void*)(&__MBAR[0x000A20]))
#define MCF_GPIO_PPDSDR_FBCS        (*(vuint8 *)(void*)(&__MBAR[0x000A21]))
#define MCF_GPIO_PPDSDR_DMA         (*(vuint8 *)(void*)(&__MBAR[0x000A22]))
#define MCF_GPIO_PPDSDR_FEC0H       (*(vuint8 *)(void*)(&__MBAR[0x000A24]))
#define MCF_GPIO_PPDSDR_FEC0L       (*(vuint8 *)(void*)(&__MBAR[0x000A25]))
#define MCF_GPIO_PPDSDR_FEC1H       (*(vuint8 *)(void*)(&__MBAR[0x000A26]))
#define MCF_GPIO_PPDSDR_FEC1L       (*(vuint8 *)(void*)(&__MBAR[0x000A27]))
#define MCF_GPIO_PPDSDR_FECI2C      (*(vuint8 *)(void*)(&__MBAR[0x000A28]))
#define MCF_GPIO_PPDSDR_PCIBG       (*(vuint8 *)(void*)(&__MBAR[0x000A29]))
#define MCF_GPIO_PPDSDR_PCIBR       (*(vuint8 *)(void*)(&__MBAR[0x000A2A]))
#define MCF_GPIO_PPDSDR_PSC3PSC2    (*(vuint8 *)(void*)(&__MBAR[0x000A2C]))
#define MCF_GPIO_PPDSDR_PSC1PSC0    (*(vuint8 *)(void*)(&__MBAR[0x000A2D]))
#define MCF_GPIO_PPDSDR_DSPI        (*(vuint8 *)(void*)(&__MBAR[0x000A2E]))
#define MCF_GPIO_PCLRR_FBCTL        (*(vuint8 *)(void*)(&__MBAR[0x000A30]))
#define MCF_GPIO_PCLRR_FBCS         (*(vuint8 *)(void*)(&__MBAR[0x000A31]))
#define MCF_GPIO_PCLRR_DMA          (*(vuint8 *)(void*)(&__MBAR[0x000A32]))
#define MCF_GPIO_PCLRR_FEC0H        (*(vuint8 *)(void*)(&__MBAR[0x000A34]))
#define MCF_GPIO_PCLRR_FEC0L        (*(vuint8 *)(void*)(&__MBAR[0x000A35]))
#define MCF_GPIO_PCLRR_FEC1H        (*(vuint8 *)(void*)(&__MBAR[0x000A36]))
#define MCF_GPIO_PCLRR_FEC1L        (*(vuint8 *)(void*)(&__MBAR[0x000A37]))
#define MCF_GPIO_PCLRR_FECI2C       (*(vuint8 *)(void*)(&__MBAR[0x000A38]))
#define MCF_GPIO_PCLRR_PCIBG        (*(vuint8 *)(void*)(&__MBAR[0x000A39]))
#define MCF_GPIO_PCLRR_PCIBR        (*(vuint8 *)(void*)(&__MBAR[0x000A3A]))
#define MCF_GPIO_PCLRR_PSC3PSC2     (*(vuint8 *)(void*)(&__MBAR[0x000A3C]))
#define MCF_GPIO_PCLRR_PSC1PSC0     (*(vuint8 *)(void*)(&__MBAR[0x000A3D]))
#define MCF_GPIO_PCLRR_DSPI         (*(vuint8 *)(void*)(&__MBAR[0x000A3E]))
#define MCF_GPIO_PAR_FBCTL          (*(vuint16*)(void*)(&__MBAR[0x000A40]))
#define MCF_GPIO_PAR_FBCS           (*(vuint8 *)(void*)(&__MBAR[0x000A42]))
#define MCF_GPIO_PAR_DMA            (*(vuint8 *)(void*)(&__MBAR[0x000A43]))
#define MCF_GPIO_PAR_FECI2CIRQ      (*(vuint16*)(void*)(&__MBAR[0x000A44]))
#define MCF_GPIO_PAR_PCIBG          (*(vuint16*)(void*)(&__MBAR[0x000A48]))
#define MCF_GPIO_PAR_PCIBR          (*(vuint16*)(void*)(&__MBAR[0x000A4A]))
#define MCF_GPIO_PAR_PSC3           (*(vuint8 *)(void*)(&__MBAR[0x000A4C]))
#define MCF_GPIO_PAR_PSC2           (*(vuint8 *)(void*)(&__MBAR[0x000A4D]))
#define MCF_GPIO_PAR_PSC1           (*(vuint8 *)(void*)(&__MBAR[0x000A4E]))
#define MCF_GPIO_PAR_PSC0           (*(vuint8 *)(void*)(&__MBAR[0x000A4F]))
#define MCF_GPIO_PAR_DSPI           (*(vuint16*)(void*)(&__MBAR[0x000A50]))
#define MCF_GPIO_PAR_TIMER          (*(vuint8 *)(void*)(&__MBAR[0x000A52]))

/* Bit definitions and macros for MCF_GPIO_PODR_FBCTL */
#define MCF_GPIO_PODR_FBCTL_PODR_FBCTL0              (0x01)
#define MCF_GPIO_PODR_FBCTL_PODR_FBCTL1              (0x02)
#define MCF_GPIO_PODR_FBCTL_PODR_FBCTL2              (0x04)
#define MCF_GPIO_PODR_FBCTL_PODR_FBCTL3              (0x08)
#define MCF_GPIO_PODR_FBCTL_PODR_FBCTL4              (0x10)
#define MCF_GPIO_PODR_FBCTL_PODR_FBCTL5              (0x20)
#define MCF_GPIO_PODR_FBCTL_PODR_FBCTL6              (0x40)
#define MCF_GPIO_PODR_FBCTL_PODR_FBCTL7              (0x80)

/* Bit definitions and macros for MCF_GPIO_PODR_FBCS */
#define MCF_GPIO_PODR_FBCS_PODR_FBCS1                (0x02)
#define MCF_GPIO_PODR_FBCS_PODR_FBCS2                (0x04)
#define MCF_GPIO_PODR_FBCS_PODR_FBCS3                (0x08)
#define MCF_GPIO_PODR_FBCS_PODR_FBCS4                (0x10)
#define MCF_GPIO_PODR_FBCS_PODR_FBCS5                (0x20)

/* Bit definitions and macros for MCF_GPIO_PODR_DMA */
#define MCF_GPIO_PODR_DMA_PODR_DMA0                  (0x01)
#define MCF_GPIO_PODR_DMA_PODR_DMA1                  (0x02)
#define MCF_GPIO_PODR_DMA_PODR_DMA2                  (0x04)
#define MCF_GPIO_PODR_DMA_PODR_DMA3                  (0x08)

/* Bit definitions and macros for MCF_GPIO_PODR_FEC0H */
#define MCF_GPIO_PODR_FEC0H_PODR_FEC0H0              (0x01)
#define MCF_GPIO_PODR_FEC0H_PODR_FEC0H1              (0x02)
#define MCF_GPIO_PODR_FEC0H_PODR_FEC0H2              (0x04)
#define MCF_GPIO_PODR_FEC0H_PODR_FEC0H3              (0x08)
#define MCF_GPIO_PODR_FEC0H_PODR_FEC0H4              (0x10)
#define MCF_GPIO_PODR_FEC0H_PODR_FEC0H5              (0x20)
#define MCF_GPIO_PODR_FEC0H_PODR_FEC0H6              (0x40)
#define MCF_GPIO_PODR_FEC0H_PODR_FEC0H7              (0x80)

/* Bit definitions and macros for MCF_GPIO_PODR_FEC0L */
#define MCF_GPIO_PODR_FEC0L_PODR_FEC0L0              (0x01)
#define MCF_GPIO_PODR_FEC0L_PODR_FEC0L1              (0x02)
#define MCF_GPIO_PODR_FEC0L_PODR_FEC0L2              (0x04)
#define MCF_GPIO_PODR_FEC0L_PODR_FEC0L3              (0x08)
#define MCF_GPIO_PODR_FEC0L_PODR_FEC0L4              (0x10)
#define MCF_GPIO_PODR_FEC0L_PODR_FEC0L5              (0x20)
#define MCF_GPIO_PODR_FEC0L_PODR_FEC0L6              (0x40)
#define MCF_GPIO_PODR_FEC0L_PODR_FEC0L7              (0x80)

/* Bit definitions and macros for MCF_GPIO_PODR_FEC1H */
#define MCF_GPIO_PODR_FEC1H_PODR_FEC1H0              (0x01)
#define MCF_GPIO_PODR_FEC1H_PODR_FEC1H1              (0x02)
#define MCF_GPIO_PODR_FEC1H_PODR_FEC1H2              (0x04)
#define MCF_GPIO_PODR_FEC1H_PODR_FEC1H3              (0x08)
#define MCF_GPIO_PODR_FEC1H_PODR_FEC1H4              (0x10)
#define MCF_GPIO_PODR_FEC1H_PODR_FEC1H5              (0x20)
#define MCF_GPIO_PODR_FEC1H_PODR_FEC1H6              (0x40)
#define MCF_GPIO_PODR_FEC1H_PODR_FEC1H7              (0x80)

/* Bit definitions and macros for MCF_GPIO_PODR_FEC1L */
#define MCF_GPIO_PODR_FEC1L_PODR_FEC1L0              (0x01)
#define MCF_GPIO_PODR_FEC1L_PODR_FEC1L1              (0x02)
#define MCF_GPIO_PODR_FEC1L_PODR_FEC1L2              (0x04)
#define MCF_GPIO_PODR_FEC1L_PODR_FEC1L3              (0x08)
#define MCF_GPIO_PODR_FEC1L_PODR_FEC1L4              (0x10)
#define MCF_GPIO_PODR_FEC1L_PODR_FEC1L5              (0x20)
#define MCF_GPIO_PODR_FEC1L_PODR_FEC1L6              (0x40)
#define MCF_GPIO_PODR_FEC1L_PODR_FEC1L7              (0x80)

/* Bit definitions and macros for MCF_GPIO_PODR_FECI2C */
#define MCF_GPIO_PODR_FECI2C_PODR_FECI2C0            (0x01)
#define MCF_GPIO_PODR_FECI2C_PODR_FECI2C1            (0x02)
#define MCF_GPIO_PODR_FECI2C_PODR_FECI2C2            (0x04)
#define MCF_GPIO_PODR_FECI2C_PODR_FECI2C3            (0x08)

/* Bit definitions and macros for MCF_GPIO_PODR_PCIBG */
#define MCF_GPIO_PODR_PCIBG_PODR_PCIBG0              (0x01)
#define MCF_GPIO_PODR_PCIBG_PODR_PCIBG1              (0x02)
#define MCF_GPIO_PODR_PCIBG_PODR_PCIBG2              (0x04)
#define MCF_GPIO_PODR_PCIBG_PODR_PCIBG3              (0x08)
#define MCF_GPIO_PODR_PCIBG_PODR_PCIBG4              (0x10)

/* Bit definitions and macros for MCF_GPIO_PODR_PCIBR */
#define MCF_GPIO_PODR_PCIBR_PODR_PCIBR0              (0x01)
#define MCF_GPIO_PODR_PCIBR_PODR_PCIBR1              (0x02)
#define MCF_GPIO_PODR_PCIBR_PODR_PCIBR2              (0x04)
#define MCF_GPIO_PODR_PCIBR_PODR_PCIBR3              (0x08)
#define MCF_GPIO_PODR_PCIBR_PODR_PCIBR4              (0x10)

/* Bit definitions and macros for MCF_GPIO_PODR_PSC3PSC2 */
#define MCF_GPIO_PODR_PSC3PSC2_PODR_PSC3PSC20        (0x01)
#define MCF_GPIO_PODR_PSC3PSC2_PODR_PSC3PSC21        (0x02)
#define MCF_GPIO_PODR_PSC3PSC2_PODR_PSC3PSC22        (0x04)
#define MCF_GPIO_PODR_PSC3PSC2_PODR_PSC3PSC23        (0x08)
#define MCF_GPIO_PODR_PSC3PSC2_PODR_PSC3PSC24        (0x10)
#define MCF_GPIO_PODR_PSC3PSC2_PODR_PSC3PSC25        (0x20)
#define MCF_GPIO_PODR_PSC3PSC2_PODR_PSC3PSC26        (0x40)
#define MCF_GPIO_PODR_PSC3PSC2_PODR_PSC3PSC27        (0x80)

/* Bit definitions and macros for MCF_GPIO_PODR_PSC1PSC0 */
#define MCF_GPIO_PODR_PSC1PSC0_PODR_PSC1PSC00        (0x01)
#define MCF_GPIO_PODR_PSC1PSC0_PODR_PSC1PSC01        (0x02)
#define MCF_GPIO_PODR_PSC1PSC0_PODR_PSC1PSC02        (0x04)
#define MCF_GPIO_PODR_PSC1PSC0_PODR_PSC1PSC03        (0x08)
#define MCF_GPIO_PODR_PSC1PSC0_PODR_PSC1PSC04        (0x10)
#define MCF_GPIO_PODR_PSC1PSC0_PODR_PSC1PSC05        (0x20)
#define MCF_GPIO_PODR_PSC1PSC0_PODR_PSC1PSC06        (0x40)
#define MCF_GPIO_PODR_PSC1PSC0_PODR_PSC1PSC07        (0x80)

/* Bit definitions and macros for MCF_GPIO_PODR_DSPI */
#define MCF_GPIO_PODR_DSPI_PODR_DSPI0                (0x01)
#define MCF_GPIO_PODR_DSPI_PODR_DSPI1                (0x02)
#define MCF_GPIO_PODR_DSPI_PODR_DSPI2                (0x04)
#define MCF_GPIO_PODR_DSPI_PODR_DSPI3                (0x08)
#define MCF_GPIO_PODR_DSPI_PODR_DSPI4                (0x10)
#define MCF_GPIO_PODR_DSPI_PODR_DSPI5                (0x20)
#define MCF_GPIO_PODR_DSPI_PODR_DSPI6                (0x40)

/* Bit definitions and macros for MCF_GPIO_PDDR_FBCTL */
#define MCF_GPIO_PDDR_FBCTL_PDDR_FBCTL0              (0x01)
#define MCF_GPIO_PDDR_FBCTL_PDDR_FBCTL1              (0x02)
#define MCF_GPIO_PDDR_FBCTL_PDDR_FBCTL2              (0x04)
#define MCF_GPIO_PDDR_FBCTL_PDDR_FBCTL3              (0x08)
#define MCF_GPIO_PDDR_FBCTL_PDDR_FBCTL4              (0x10)
#define MCF_GPIO_PDDR_FBCTL_PDDR_FBCTL5              (0x20)
#define MCF_GPIO_PDDR_FBCTL_PDDR_FBCTL6              (0x40)
#define MCF_GPIO_PDDR_FBCTL_PDDR_FBCTL7              (0x80)

/* Bit definitions and macros for MCF_GPIO_PDDR_FBCS */
#define MCF_GPIO_PDDR_FBCS_PDDR_FBCS1                (0x02)
#define MCF_GPIO_PDDR_FBCS_PDDR_FBCS2                (0x04)
#define MCF_GPIO_PDDR_FBCS_PDDR_FBCS3                (0x08)
#define MCF_GPIO_PDDR_FBCS_PDDR_FBCS4                (0x10)
#define MCF_GPIO_PDDR_FBCS_PDDR_FBCS5                (0x20)

/* Bit definitions and macros for MCF_GPIO_PDDR_DMA */
#define MCF_GPIO_PDDR_DMA_PDDR_DMA0                  (0x01)
#define MCF_GPIO_PDDR_DMA_PDDR_DMA1                  (0x02)
#define MCF_GPIO_PDDR_DMA_PDDR_DMA2                  (0x04)
#define MCF_GPIO_PDDR_DMA_PDDR_DMA3                  (0x08)

/* Bit definitions and macros for MCF_GPIO_PDDR_FEC0H */
#define MCF_GPIO_PDDR_FEC0H_PDDR_FEC0H0              (0x01)
#define MCF_GPIO_PDDR_FEC0H_PDDR_FEC0H1              (0x02)
#define MCF_GPIO_PDDR_FEC0H_PDDR_FEC0H2              (0x04)
#define MCF_GPIO_PDDR_FEC0H_PDDR_FEC0H3              (0x08)
#define MCF_GPIO_PDDR_FEC0H_PDDR_FEC0H4              (0x10)
#define MCF_GPIO_PDDR_FEC0H_PDDR_FEC0H5              (0x20)
#define MCF_GPIO_PDDR_FEC0H_PDDR_FEC0H6              (0x40)
#define MCF_GPIO_PDDR_FEC0H_PDDR_FEC0H7              (0x80)

/* Bit definitions and macros for MCF_GPIO_PDDR_FEC0L */
#define MCF_GPIO_PDDR_FEC0L_PDDR_FEC0L0              (0x01)
#define MCF_GPIO_PDDR_FEC0L_PDDR_FEC0L1              (0x02)
#define MCF_GPIO_PDDR_FEC0L_PDDR_FEC0L2              (0x04)
#define MCF_GPIO_PDDR_FEC0L_PDDR_FEC0L3              (0x08)
#define MCF_GPIO_PDDR_FEC0L_PDDR_FEC0L4              (0x10)
#define MCF_GPIO_PDDR_FEC0L_PDDR_FEC0L5              (0x20)
#define MCF_GPIO_PDDR_FEC0L_PDDR_FEC0L6              (0x40)
#define MCF_GPIO_PDDR_FEC0L_PDDR_FEC0L7              (0x80)

/* Bit definitions and macros for MCF_GPIO_PDDR_FEC1H */
#define MCF_GPIO_PDDR_FEC1H_PDDR_FEC1H0              (0x01)
#define MCF_GPIO_PDDR_FEC1H_PDDR_FEC1H1              (0x02)
#define MCF_GPIO_PDDR_FEC1H_PDDR_FEC1H2              (0x04)
#define MCF_GPIO_PDDR_FEC1H_PDDR_FEC1H3              (0x08)
#define MCF_GPIO_PDDR_FEC1H_PDDR_FEC1H4              (0x10)
#define MCF_GPIO_PDDR_FEC1H_PDDR_FEC1H5              (0x20)
#define MCF_GPIO_PDDR_FEC1H_PDDR_FEC1H6              (0x40)
#define MCF_GPIO_PDDR_FEC1H_PDDR_FEC1H7              (0x80)

/* Bit definitions and macros for MCF_GPIO_PDDR_FEC1L */
#define MCF_GPIO_PDDR_FEC1L_PDDR_FEC1L0              (0x01)
#define MCF_GPIO_PDDR_FEC1L_PDDR_FEC1L1              (0x02)
#define MCF_GPIO_PDDR_FEC1L_PDDR_FEC1L2              (0x04)
#define MCF_GPIO_PDDR_FEC1L_PDDR_FEC1L3              (0x08)
#define MCF_GPIO_PDDR_FEC1L_PDDR_FEC1L4              (0x10)
#define MCF_GPIO_PDDR_FEC1L_PDDR_FEC1L5              (0x20)
#define MCF_GPIO_PDDR_FEC1L_PDDR_FEC1L6              (0x40)
#define MCF_GPIO_PDDR_FEC1L_PDDR_FEC1L7              (0x80)

/* Bit definitions and macros for MCF_GPIO_PDDR_FECI2C */
#define MCF_GPIO_PDDR_FECI2C_PDDR_FECI2C0            (0x01)
#define MCF_GPIO_PDDR_FECI2C_PDDR_FECI2C1            (0x02)
#define MCF_GPIO_PDDR_FECI2C_PDDR_FECI2C2            (0x04)
#define MCF_GPIO_PDDR_FECI2C_PDDR_FECI2C3            (0x08)

/* Bit definitions and macros for MCF_GPIO_PDDR_PCIBG */
#define MCF_GPIO_PDDR_PCIBG_PDDR_PCIBG0              (0x01)
#define MCF_GPIO_PDDR_PCIBG_PDDR_PCIBG1              (0x02)
#define MCF_GPIO_PDDR_PCIBG_PDDR_PCIBG2              (0x04)
#define MCF_GPIO_PDDR_PCIBG_PDDR_PCIBG3              (0x08)
#define MCF_GPIO_PDDR_PCIBG_PDDR_PCIBG4              (0x10)

/* Bit definitions and macros for MCF_GPIO_PDDR_PCIBR */
#define MCF_GPIO_PDDR_PCIBR_PDDR_PCIBR0              (0x01)
#define MCF_GPIO_PDDR_PCIBR_PDDR_PCIBR1              (0x02)
#define MCF_GPIO_PDDR_PCIBR_PDDR_PCIBR2              (0x04)
#define MCF_GPIO_PDDR_PCIBR_PDDR_PCIBR3              (0x08)
#define MCF_GPIO_PDDR_PCIBR_PDDR_PCIBR4              (0x10)

/* Bit definitions and macros for MCF_GPIO_PDDR_PSC3PSC2 */
#define MCF_GPIO_PDDR_PSC3PSC2_PDDR_PSC3PSC20        (0x01)
#define MCF_GPIO_PDDR_PSC3PSC2_PDDR_PSC3PSC21        (0x02)
#define MCF_GPIO_PDDR_PSC3PSC2_PDDR_PSC3PSC22        (0x04)
#define MCF_GPIO_PDDR_PSC3PSC2_PDDR_PSC3PSC23        (0x08)
#define MCF_GPIO_PDDR_PSC3PSC2_PDDR_PSC3PSC24        (0x10)
#define MCF_GPIO_PDDR_PSC3PSC2_PDDR_PSC3PSC25        (0x20)
#define MCF_GPIO_PDDR_PSC3PSC2_PDDR_PSC3PSC26        (0x40)
#define MCF_GPIO_PDDR_PSC3PSC2_PDDR_PSC3PSC27        (0x80)

/* Bit definitions and macros for MCF_GPIO_PDDR_PSC1PSC0 */
#define MCF_GPIO_PDDR_PSC1PSC0_PDDR_PSC1PSC00        (0x01)
#define MCF_GPIO_PDDR_PSC1PSC0_PDDR_PSC1PSC01        (0x02)
#define MCF_GPIO_PDDR_PSC1PSC0_PDDR_PSC1PSC02        (0x04)
#define MCF_GPIO_PDDR_PSC1PSC0_PDDR_PSC1PSC03        (0x08)
#define MCF_GPIO_PDDR_PSC1PSC0_PDDR_PSC1PSC04        (0x10)
#define MCF_GPIO_PDDR_PSC1PSC0_PDDR_PSC1PSC05        (0x20)
#define MCF_GPIO_PDDR_PSC1PSC0_PDDR_PSC1PSC06        (0x40)
#define MCF_GPIO_PDDR_PSC1PSC0_PDDR_PSC1PSC07        (0x80)

/* Bit definitions and macros for MCF_GPIO_PDDR_DSPI */
#define MCF_GPIO_PDDR_DSPI_PDDR_DSPI0                (0x01)
#define MCF_GPIO_PDDR_DSPI_PDDR_DSPI1                (0x02)
#define MCF_GPIO_PDDR_DSPI_PDDR_DSPI2                (0x04)
#define MCF_GPIO_PDDR_DSPI_PDDR_DSPI3                (0x08)
#define MCF_GPIO_PDDR_DSPI_PDDR_DSPI4                (0x10)
#define MCF_GPIO_PDDR_DSPI_PDDR_DSPI5                (0x20)
#define MCF_GPIO_PDDR_DSPI_PDDR_DSPI6                (0x40)

/* Bit definitions and macros for MCF_GPIO_PPDSDR_FBCTL */
#define MCF_GPIO_PPDSDR_FBCTL_PPDSDR_FBCTL0          (0x01)
#define MCF_GPIO_PPDSDR_FBCTL_PPDSDR_FBCTL1          (0x02)
#define MCF_GPIO_PPDSDR_FBCTL_PPDSDR_FBCTL2          (0x04)
#define MCF_GPIO_PPDSDR_FBCTL_PPDSDR_FBCTL3          (0x08)
#define MCF_GPIO_PPDSDR_FBCTL_PPDSDR_FBCTL4          (0x10)
#define MCF_GPIO_PPDSDR_FBCTL_PPDSDR_FBCTL5          (0x20)
#define MCF_GPIO_PPDSDR_FBCTL_PPDSDR_FBCTL6          (0x40)
#define MCF_GPIO_PPDSDR_FBCTL_PPDSDR_FBCTL7          (0x80)

/* Bit definitions and macros for MCF_GPIO_PPDSDR_FBCS */
#define MCF_GPIO_PPDSDR_FBCS_PPDSDR_FBCS1            (0x02)
#define MCF_GPIO_PPDSDR_FBCS_PPDSDR_FBCS2            (0x04)
#define MCF_GPIO_PPDSDR_FBCS_PPDSDR_FBCS3            (0x08)
#define MCF_GPIO_PPDSDR_FBCS_PPDSDR_FBCS4            (0x10)
#define MCF_GPIO_PPDSDR_FBCS_PPDSDR_FBCS5            (0x20)

/* Bit definitions and macros for MCF_GPIO_PPDSDR_DMA */
#define MCF_GPIO_PPDSDR_DMA_PPDSDR_DMA0              (0x01)
#define MCF_GPIO_PPDSDR_DMA_PPDSDR_DMA1              (0x02)
#define MCF_GPIO_PPDSDR_DMA_PPDSDR_DMA2              (0x04)
#define MCF_GPIO_PPDSDR_DMA_PPDSDR_DMA3              (0x08)

/* Bit definitions and macros for MCF_GPIO_PPDSDR_FEC0H */
#define MCF_GPIO_PPDSDR_FEC0H_PPDSDR_FEC0H0          (0x01)
#define MCF_GPIO_PPDSDR_FEC0H_PPDSDR_FEC0H1          (0x02)
#define MCF_GPIO_PPDSDR_FEC0H_PPDSDR_FEC0H2          (0x04)
#define MCF_GPIO_PPDSDR_FEC0H_PPDSDR_FEC0H3          (0x08)
#define MCF_GPIO_PPDSDR_FEC0H_PPDSDR_FEC0H4          (0x10)
#define MCF_GPIO_PPDSDR_FEC0H_PPDSDR_FEC0H5          (0x20)
#define MCF_GPIO_PPDSDR_FEC0H_PPDSDR_FEC0H6          (0x40)
#define MCF_GPIO_PPDSDR_FEC0H_PPDSDR_FEC0H7          (0x80)

/* Bit definitions and macros for MCF_GPIO_PPDSDR_FEC0L */
#define MCF_GPIO_PPDSDR_FEC0L_PPDSDR_FEC0L0          (0x01)
#define MCF_GPIO_PPDSDR_FEC0L_PPDSDR_FEC0L1          (0x02)
#define MCF_GPIO_PPDSDR_FEC0L_PPDSDR_FEC0L2          (0x04)
#define MCF_GPIO_PPDSDR_FEC0L_PPDSDR_FEC0L3          (0x08)
#define MCF_GPIO_PPDSDR_FEC0L_PPDSDR_FEC0L4          (0x10)
#define MCF_GPIO_PPDSDR_FEC0L_PPDSDR_FEC0L5          (0x20)
#define MCF_GPIO_PPDSDR_FEC0L_PPDSDR_FEC0L6          (0x40)
#define MCF_GPIO_PPDSDR_FEC0L_PPDSDR_FEC0L7          (0x80)

/* Bit definitions and macros for MCF_GPIO_PPDSDR_FEC1H */
#define MCF_GPIO_PPDSDR_FEC1H_PPDSDR_FEC1H0          (0x01)
#define MCF_GPIO_PPDSDR_FEC1H_PPDSDR_FEC1H1          (0x02)
#define MCF_GPIO_PPDSDR_FEC1H_PPDSDR_FEC1H2          (0x04)
#define MCF_GPIO_PPDSDR_FEC1H_PPDSDR_FEC1H3          (0x08)
#define MCF_GPIO_PPDSDR_FEC1H_PPDSDR_FEC1H4          (0x10)
#define MCF_GPIO_PPDSDR_FEC1H_PPDSDR_FEC1H5          (0x20)
#define MCF_GPIO_PPDSDR_FEC1H_PPDSDR_FEC1H6          (0x40)
#define MCF_GPIO_PPDSDR_FEC1H_PPDSDR_FEC1H7          (0x80)

/* Bit definitions and macros for MCF_GPIO_PPDSDR_FEC1L */
#define MCF_GPIO_PPDSDR_FEC1L_PPDSDR_FEC1L0          (0x01)
#define MCF_GPIO_PPDSDR_FEC1L_PPDSDR_FEC1L1          (0x02)
#define MCF_GPIO_PPDSDR_FEC1L_PPDSDR_FEC1L2          (0x04)
#define MCF_GPIO_PPDSDR_FEC1L_PPDSDR_FEC1L3          (0x08)
#define MCF_GPIO_PPDSDR_FEC1L_PPDSDR_FEC1L4          (0x10)
#define MCF_GPIO_PPDSDR_FEC1L_PPDSDR_FEC1L5          (0x20)
#define MCF_GPIO_PPDSDR_FEC1L_PPDSDR_FEC1L6          (0x40)
#define MCF_GPIO_PPDSDR_FEC1L_PPDSDR_FEC1L7          (0x80)

/* Bit definitions and macros for MCF_GPIO_PPDSDR_FECI2C */
#define MCF_GPIO_PPDSDR_FECI2C_PPDSDR_FECI2C0        (0x01)
#define MCF_GPIO_PPDSDR_FECI2C_PPDSDR_FECI2C1        (0x02)
#define MCF_GPIO_PPDSDR_FECI2C_PPDSDR_FECI2C2        (0x04)
#define MCF_GPIO_PPDSDR_FECI2C_PPDSDR_FECI2C3        (0x08)

/* Bit definitions and macros for MCF_GPIO_PPDSDR_PCIBG */
#define MCF_GPIO_PPDSDR_PCIBG_PPDSDR_PCIBG0          (0x01)
#define MCF_GPIO_PPDSDR_PCIBG_PPDSDR_PCIBG1          (0x02)
#define MCF_GPIO_PPDSDR_PCIBG_PPDSDR_PCIBG2          (0x04)
#define MCF_GPIO_PPDSDR_PCIBG_PPDSDR_PCIBG3          (0x08)
#define MCF_GPIO_PPDSDR_PCIBG_PPDSDR_PCIBG4          (0x10)

/* Bit definitions and macros for MCF_GPIO_PPDSDR_PCIBR */
#define MCF_GPIO_PPDSDR_PCIBR_PPDSDR_PCIBR0          (0x01)
#define MCF_GPIO_PPDSDR_PCIBR_PPDSDR_PCIBR1          (0x02)
#define MCF_GPIO_PPDSDR_PCIBR_PPDSDR_PCIBR2          (0x04)
#define MCF_GPIO_PPDSDR_PCIBR_PPDSDR_PCIBR3          (0x08)
#define MCF_GPIO_PPDSDR_PCIBR_PPDSDR_PCIBR4          (0x10)

/* Bit definitions and macros for MCF_GPIO_PPDSDR_PSC3PSC2 */
#define MCF_GPIO_PPDSDR_PSC3PSC2_PPDSDR_PSC3PSC20    (0x01)
#define MCF_GPIO_PPDSDR_PSC3PSC2_PPDSDR_PSC3PSC21    (0x02)
#define MCF_GPIO_PPDSDR_PSC3PSC2_PPDSDR_PSC3PSC22    (0x04)
#define MCF_GPIO_PPDSDR_PSC3PSC2_PPDSDR_PSC3PSC23    (0x08)
#define MCF_GPIO_PPDSDR_PSC3PSC2_PPDSDR_PSC3PSC24    (0x10)
#define MCF_GPIO_PPDSDR_PSC3PSC2_PPDSDR_PSC3PSC25    (0x20)
#define MCF_GPIO_PPDSDR_PSC3PSC2_PPDSDR_PSC3PSC26    (0x40)
#define MCF_GPIO_PPDSDR_PSC3PSC2_PPDSDR_PSC3PSC27    (0x80)

/* Bit definitions and macros for MCF_GPIO_PPDSDR_PSC1PSC0 */
#define MCF_GPIO_PPDSDR_PSC1PSC0_PPDSDR_PSC1PSC00    (0x01)
#define MCF_GPIO_PPDSDR_PSC1PSC0_PPDSDR_PSC1PSC01    (0x02)
#define MCF_GPIO_PPDSDR_PSC1PSC0_PPDSDR_PSC1PSC02    (0x04)
#define MCF_GPIO_PPDSDR_PSC1PSC0_PPDSDR_PSC1PSC03    (0x08)
#define MCF_GPIO_PPDSDR_PSC1PSC0_PPDSDR_PSC1PSC04    (0x10)
#define MCF_GPIO_PPDSDR_PSC1PSC0_PPDSDR_PSC1PSC05    (0x20)
#define MCF_GPIO_PPDSDR_PSC1PSC0_PPDSDR_PSC1PSC06    (0x40)
#define MCF_GPIO_PPDSDR_PSC1PSC0_PPDSDR_PSC1PSC07    (0x80)

/* Bit definitions and macros for MCF_GPIO_PPDSDR_DSPI */
#define MCF_GPIO_PPDSDR_DSPI_PPDSDR_DSPI0            (0x01)
#define MCF_GPIO_PPDSDR_DSPI_PPDSDR_DSPI1            (0x02)
#define MCF_GPIO_PPDSDR_DSPI_PPDSDR_DSPI2            (0x04)
#define MCF_GPIO_PPDSDR_DSPI_PPDSDR_DSPI3            (0x08)
#define MCF_GPIO_PPDSDR_DSPI_PPDSDR_DSPI4            (0x10)
#define MCF_GPIO_PPDSDR_DSPI_PPDSDR_DSPI5            (0x20)
#define MCF_GPIO_PPDSDR_DSPI_PPDSDR_DSPI6            (0x40)

/* Bit definitions and macros for MCF_GPIO_PCLRR_FBCTL */
#define MCF_GPIO_PCLRR_FBCTL_PCLRR_FBCTL0            (0x01)
#define MCF_GPIO_PCLRR_FBCTL_PCLRR_FBCTL1            (0x02)
#define MCF_GPIO_PCLRR_FBCTL_PCLRR_FBCTL2            (0x04)
#define MCF_GPIO_PCLRR_FBCTL_PCLRR_FBCTL3            (0x08)
#define MCF_GPIO_PCLRR_FBCTL_PCLRR_FBCTL4            (0x10)
#define MCF_GPIO_PCLRR_FBCTL_PCLRR_FBCTL5            (0x20)
#define MCF_GPIO_PCLRR_FBCTL_PCLRR_FBCTL6            (0x40)
#define MCF_GPIO_PCLRR_FBCTL_PCLRR_FBCTL7            (0x80)

/* Bit definitions and macros for MCF_GPIO_PCLRR_FBCS */
#define MCF_GPIO_PCLRR_FBCS_PCLRR_FBCS1              (0x02)
#define MCF_GPIO_PCLRR_FBCS_PCLRR_FBCS2              (0x04)
#define MCF_GPIO_PCLRR_FBCS_PCLRR_FBCS3              (0x08)
#define MCF_GPIO_PCLRR_FBCS_PCLRR_FBCS4              (0x10)
#define MCF_GPIO_PCLRR_FBCS_PCLRR_FBCS5              (0x20)

/* Bit definitions and macros for MCF_GPIO_PCLRR_DMA */
#define MCF_GPIO_PCLRR_DMA_PCLRR_DMA0                (0x01)
#define MCF_GPIO_PCLRR_DMA_PCLRR_DMA1                (0x02)
#define MCF_GPIO_PCLRR_DMA_PCLRR_DMA2                (0x04)
#define MCF_GPIO_PCLRR_DMA_PCLRR_DMA3                (0x08)

/* Bit definitions and macros for MCF_GPIO_PCLRR_FEC0H */
#define MCF_GPIO_PCLRR_FEC0H_PCLRR_FEC0H0            (0x01)
#define MCF_GPIO_PCLRR_FEC0H_PCLRR_FEC0H1            (0x02)
#define MCF_GPIO_PCLRR_FEC0H_PCLRR_FEC0H2            (0x04)
#define MCF_GPIO_PCLRR_FEC0H_PCLRR_FEC0H3            (0x08)
#define MCF_GPIO_PCLRR_FEC0H_PCLRR_FEC0H4            (0x10)
#define MCF_GPIO_PCLRR_FEC0H_PCLRR_FEC0H5            (0x20)
#define MCF_GPIO_PCLRR_FEC0H_PCLRR_FEC0H6            (0x40)
#define MCF_GPIO_PCLRR_FEC0H_PCLRR_FEC0H7            (0x80)

/* Bit definitions and macros for MCF_GPIO_PCLRR_FEC0L */
#define MCF_GPIO_PCLRR_FEC0L_PCLRR_FEC0L0            (0x01)
#define MCF_GPIO_PCLRR_FEC0L_PCLRR_FEC0L1            (0x02)
#define MCF_GPIO_PCLRR_FEC0L_PCLRR_FEC0L2            (0x04)
#define MCF_GPIO_PCLRR_FEC0L_PCLRR_FEC0L3            (0x08)
#define MCF_GPIO_PCLRR_FEC0L_PCLRR_FEC0L4            (0x10)
#define MCF_GPIO_PCLRR_FEC0L_PCLRR_FEC0L5            (0x20)
#define MCF_GPIO_PCLRR_FEC0L_PCLRR_FEC0L6            (0x40)
#define MCF_GPIO_PCLRR_FEC0L_PCLRR_FEC0L7            (0x80)

/* Bit definitions and macros for MCF_GPIO_PCLRR_FEC1H */
#define MCF_GPIO_PCLRR_FEC1H_PCLRR_FEC1H0            (0x01)
#define MCF_GPIO_PCLRR_FEC1H_PCLRR_FEC1H1            (0x02)
#define MCF_GPIO_PCLRR_FEC1H_PCLRR_FEC1H2            (0x04)
#define MCF_GPIO_PCLRR_FEC1H_PCLRR_FEC1H3            (0x08)
#define MCF_GPIO_PCLRR_FEC1H_PCLRR_FEC1H4            (0x10)
#define MCF_GPIO_PCLRR_FEC1H_PCLRR_FEC1H5            (0x20)
#define MCF_GPIO_PCLRR_FEC1H_PCLRR_FEC1H6            (0x40)
#define MCF_GPIO_PCLRR_FEC1H_PCLRR_FEC1H7            (0x80)

/* Bit definitions and macros for MCF_GPIO_PCLRR_FEC1L */
#define MCF_GPIO_PCLRR_FEC1L_PCLRR_FEC1L0            (0x01)
#define MCF_GPIO_PCLRR_FEC1L_PCLRR_FEC1L1            (0x02)
#define MCF_GPIO_PCLRR_FEC1L_PCLRR_FEC1L2            (0x04)
#define MCF_GPIO_PCLRR_FEC1L_PCLRR_FEC1L3            (0x08)
#define MCF_GPIO_PCLRR_FEC1L_PCLRR_FEC1L4            (0x10)
#define MCF_GPIO_PCLRR_FEC1L_PCLRR_FEC1L5            (0x20)
#define MCF_GPIO_PCLRR_FEC1L_PCLRR_FEC1L6            (0x40)
#define MCF_GPIO_PCLRR_FEC1L_PCLRR_FEC1L7            (0x80)

/* Bit definitions and macros for MCF_GPIO_PCLRR_FECI2C */
#define MCF_GPIO_PCLRR_FECI2C_PCLRR_FECI2C0          (0x01)
#define MCF_GPIO_PCLRR_FECI2C_PCLRR_FECI2C1          (0x02)
#define MCF_GPIO_PCLRR_FECI2C_PCLRR_FECI2C2          (0x04)
#define MCF_GPIO_PCLRR_FECI2C_PCLRR_FECI2C3          (0x08)

/* Bit definitions and macros for MCF_GPIO_PCLRR_PCIBG */
#define MCF_GPIO_PCLRR_PCIBG_PCLRR_PCIBG0            (0x01)
#define MCF_GPIO_PCLRR_PCIBG_PCLRR_PCIBG1            (0x02)
#define MCF_GPIO_PCLRR_PCIBG_PCLRR_PCIBG2            (0x04)
#define MCF_GPIO_PCLRR_PCIBG_PCLRR_PCIBG3            (0x08)
#define MCF_GPIO_PCLRR_PCIBG_PCLRR_PCIBG4            (0x10)

/* Bit definitions and macros for MCF_GPIO_PCLRR_PCIBR */
#define MCF_GPIO_PCLRR_PCIBR_PCLRR_PCIBR0            (0x01)
#define MCF_GPIO_PCLRR_PCIBR_PCLRR_PCIBR1            (0x02)
#define MCF_GPIO_PCLRR_PCIBR_PCLRR_PCIBR2            (0x04)
#define MCF_GPIO_PCLRR_PCIBR_PCLRR_PCIBR3            (0x08)
#define MCF_GPIO_PCLRR_PCIBR_PCLRR_PCIBR4            (0x10)

/* Bit definitions and macros for MCF_GPIO_PCLRR_PSC3PSC2 */
#define MCF_GPIO_PCLRR_PSC3PSC2_PCLRR_PSC3PSC20      (0x01)
#define MCF_GPIO_PCLRR_PSC3PSC2_PCLRR_PSC3PSC21      (0x02)
#define MCF_GPIO_PCLRR_PSC3PSC2_PCLRR_PSC3PSC22      (0x04)
#define MCF_GPIO_PCLRR_PSC3PSC2_PCLRR_PSC3PSC23      (0x08)
#define MCF_GPIO_PCLRR_PSC3PSC2_PCLRR_PSC3PSC24      (0x10)
#define MCF_GPIO_PCLRR_PSC3PSC2_PCLRR_PSC3PSC25      (0x20)
#define MCF_GPIO_PCLRR_PSC3PSC2_PCLRR_PSC3PSC26      (0x40)
#define MCF_GPIO_PCLRR_PSC3PSC2_PCLRR_PSC3PSC27      (0x80)

/* Bit definitions and macros for MCF_GPIO_PCLRR_PSC1PSC0 */
#define MCF_GPIO_PCLRR_PSC1PSC0_PCLRR_PSC1PSC00      (0x01)
#define MCF_GPIO_PCLRR_PSC1PSC0_PCLRR_PSC1PSC01      (0x02)
#define MCF_GPIO_PCLRR_PSC1PSC0_PCLRR_PSC1PSC02      (0x04)
#define MCF_GPIO_PCLRR_PSC1PSC0_PCLRR_PSC1PSC03      (0x08)
#define MCF_GPIO_PCLRR_PSC1PSC0_PCLRR_PSC1PSC04      (0x10)
#define MCF_GPIO_PCLRR_PSC1PSC0_PCLRR_PSC1PSC05      (0x20)
#define MCF_GPIO_PCLRR_PSC1PSC0_PCLRR_PSC1PSC06      (0x40)
#define MCF_GPIO_PCLRR_PSC1PSC0_PCLRR_PSC1PSC07      (0x80)

/* Bit definitions and macros for MCF_GPIO_PCLRR_DSPI */
#define MCF_GPIO_PCLRR_DSPI_PCLRR_DSPI0              (0x01)
#define MCF_GPIO_PCLRR_DSPI_PCLRR_DSPI1              (0x02)
#define MCF_GPIO_PCLRR_DSPI_PCLRR_DSPI2              (0x04)
#define MCF_GPIO_PCLRR_DSPI_PCLRR_DSPI3              (0x08)
#define MCF_GPIO_PCLRR_DSPI_PCLRR_DSPI4              (0x10)
#define MCF_GPIO_PCLRR_DSPI_PCLRR_DSPI5              (0x20)
#define MCF_GPIO_PCLRR_DSPI_PCLRR_DSPI6              (0x40)

/* Bit definitions and macros for MCF_GPIO_PAR_FBCTL */
#define MCF_GPIO_PAR_FBCTL_PAR_TS(x)                 (((x)&0x0003)<<0)
#define MCF_GPIO_PAR_FBCTL_PAR_TA                    (0x0004)
#define MCF_GPIO_PAR_FBCTL_PAR_RWB(x)                (((x)&0x0003)<<4)
#define MCF_GPIO_PAR_FBCTL_PAR_OE                    (0x0040)
#define MCF_GPIO_PAR_FBCTL_PAR_BWE0                  (0x0100)
#define MCF_GPIO_PAR_FBCTL_PAR_BWE1                  (0x0400)
#define MCF_GPIO_PAR_FBCTL_PAR_BWE2                  (0x1000)
#define MCF_GPIO_PAR_FBCTL_PAR_BWE3                  (0x4000)
#define MCF_GPIO_PAR_FBCTL_PAR_TS_GPIO               (0)
#define MCF_GPIO_PAR_FBCTL_PAR_TS_TBST               (2)
#define MCF_GPIO_PAR_FBCTL_PAR_TS_TS                 (3)
#define MCF_GPIO_PAR_FBCTL_PAR_RWB_GPIO              (0x0000)
#define MCF_GPIO_PAR_FBCTL_PAR_RWB_TBST              (0x0020)
#define MCF_GPIO_PAR_FBCTL_PAR_RWB_RWB               (0x0030)

/* Bit definitions and macros for MCF_GPIO_PAR_FBCS */
#define MCF_GPIO_PAR_FBCS_PAR_CS1                    (0x02)
#define MCF_GPIO_PAR_FBCS_PAR_CS2                    (0x04)
#define MCF_GPIO_PAR_FBCS_PAR_CS3                    (0x08)
#define MCF_GPIO_PAR_FBCS_PAR_CS4                    (0x10)
#define MCF_GPIO_PAR_FBCS_PAR_CS5                    (0x20)

/* Bit definitions and macros for MCF_GPIO_PAR_DMA */
#define MCF_GPIO_PAR_DMA_PAR_DREQ0(x)                (((x)&0x03)<<0)
#define MCF_GPIO_PAR_DMA_PAR_DREQ1(x)                (((x)&0x03)<<2)
#define MCF_GPIO_PAR_DMA_PAR_DACK0(x)                (((x)&0x03)<<4)
#define MCF_GPIO_PAR_DMA_PAR_DACK1(x)                (((x)&0x03)<<6)
#define MCF_GPIO_PAR_DMA_PAR_DACKx_GPIO              (0)
#define MCF_GPIO_PAR_DMA_PAR_DACKx_TOUT              (2)
#define MCF_GPIO_PAR_DMA_PAR_DACKx_DACK              (3)
#define MCF_GPIO_PAR_DMA_PAR_DREQx_GPIO              (0)
#define MCF_GPIO_PAR_DMA_PAR_DREQx_TIN               (2)
#define MCF_GPIO_PAR_DMA_PAR_DREQx_DREQ              (3)

/* Bit definitions and macros for MCF_GPIO_PAR_FECI2CIRQ */
#define MCF_GPIO_PAR_FECI2CIRQ_PAR_IRQ5              (0x0001)
#define MCF_GPIO_PAR_FECI2CIRQ_PAR_IRQ6              (0x0002)
#define MCF_GPIO_PAR_FECI2CIRQ_PAR_SCL               (0x0004)
#define MCF_GPIO_PAR_FECI2CIRQ_PAR_SDA               (0x0008)
#define MCF_GPIO_PAR_FECI2CIRQ_PAR_E1MDC(x)          (((x)&0x0003)<<6)
#define MCF_GPIO_PAR_FECI2CIRQ_PAR_E1MDIO(x)         (((x)&0x0003)<<8)
#define MCF_GPIO_PAR_FECI2CIRQ_PAR_E1MII             (0x0400)
#define MCF_GPIO_PAR_FECI2CIRQ_PAR_E17               (0x0800)
#define MCF_GPIO_PAR_FECI2CIRQ_PAR_E0MDC             (0x1000)
#define MCF_GPIO_PAR_FECI2CIRQ_PAR_E0MDIO            (0x2000)
#define MCF_GPIO_PAR_FECI2CIRQ_PAR_E0MII             (0x4000)
#define MCF_GPIO_PAR_FECI2CIRQ_PAR_E07               (0x8000)
#define MCF_GPIO_PAR_FECI2CIRQ_PAR_E1MDIO_CANRX      (0x0000)
#define MCF_GPIO_PAR_FECI2CIRQ_PAR_E1MDIO_SDA        (0x0200)
#define MCF_GPIO_PAR_FECI2CIRQ_PAR_E1MDIO_EMDIO      (0x0300)
#define MCF_GPIO_PAR_FECI2CIRQ_PAR_E1MDC_CANTX       (0x0000)
#define MCF_GPIO_PAR_FECI2CIRQ_PAR_E1MDC_SCL         (0x0080)
#define MCF_GPIO_PAR_FECI2CIRQ_PAR_E1MDC_EMDC        (0x00C0)

/* Bit definitions and macros for MCF_GPIO_PAR_PCIBG */
#define MCF_GPIO_PAR_PCIBG_PAR_PCIBG0(x)             (((x)&0x0003)<<0)
#define MCF_GPIO_PAR_PCIBG_PAR_PCIBG1(x)             (((x)&0x0003)<<2)
#define MCF_GPIO_PAR_PCIBG_PAR_PCIBG2(x)             (((x)&0x0003)<<4)
#define MCF_GPIO_PAR_PCIBG_PAR_PCIBG3(x)             (((x)&0x0003)<<6)
#define MCF_GPIO_PAR_PCIBG_PAR_PCIBG4(x)             (((x)&0x0003)<<8)

/* Bit definitions and macros for MCF_GPIO_PAR_PCIBR */
#define MCF_GPIO_PAR_PCIBR_PAR_PCIBG0(x)             (((x)&0x0003)<<0)
#define MCF_GPIO_PAR_PCIBR_PAR_PCIBG1(x)             (((x)&0x0003)<<2)
#define MCF_GPIO_PAR_PCIBR_PAR_PCIBG2(x)             (((x)&0x0003)<<4)
#define MCF_GPIO_PAR_PCIBR_PAR_PCIBG3(x)             (((x)&0x0003)<<6)
#define MCF_GPIO_PAR_PCIBR_PAR_PCIBR4(x)             (((x)&0x0003)<<8)

/* Bit definitions and macros for MCF_GPIO_PAR_PSC3 */
#define MCF_GPIO_PAR_PSC3_PAR_TXD3                   (0x04)
#define MCF_GPIO_PAR_PSC3_PAR_RXD3                   (0x08)
#define MCF_GPIO_PAR_PSC3_PAR_RTS3(x)                (((x)&0x03)<<4)
#define MCF_GPIO_PAR_PSC3_PAR_CTS3(x)                (((x)&0x03)<<6)
#define MCF_GPIO_PAR_PSC3_PAR_CTS3_GPIO              (0x00)
#define MCF_GPIO_PAR_PSC3_PAR_CTS3_BCLK              (0x80)
#define MCF_GPIO_PAR_PSC3_PAR_CTS3_CTS               (0xC0)
#define MCF_GPIO_PAR_PSC3_PAR_RTS3_GPIO              (0x00)
#define MCF_GPIO_PAR_PSC3_PAR_RTS3_FSYNC             (0x20)
#define MCF_GPIO_PAR_PSC3_PAR_RTS3_RTS               (0x30)
#define MCF_GPIO_PAR_PSC3_PAR_CTS2_CANRX             (0x40)

/* Bit definitions and macros for MCF_GPIO_PAR_PSC2 */
#define MCF_GPIO_PAR_PSC2_PAR_TXD2                   (0x04)
#define MCF_GPIO_PAR_PSC2_PAR_RXD2                   (0x08)
#define MCF_GPIO_PAR_PSC2_PAR_RTS2(x)                (((x)&0x03)<<4)
#define MCF_GPIO_PAR_PSC2_PAR_CTS2(x)                (((x)&0x03)<<6)
#define MCF_GPIO_PAR_PSC2_PAR_CTS2_GPIO              (0x00)
#define MCF_GPIO_PAR_PSC2_PAR_CTS2_BCLK              (0x80)
#define MCF_GPIO_PAR_PSC2_PAR_CTS2_CTS               (0xC0)
#define MCF_GPIO_PAR_PSC2_PAR_RTS2_GPIO              (0x00)
#define MCF_GPIO_PAR_PSC2_PAR_RTS2_CANTX             (0x10)
#define MCF_GPIO_PAR_PSC2_PAR_RTS2_FSYNC             (0x20)
#define MCF_GPIO_PAR_PSC2_PAR_RTS2_RTS               (0x30)

/* Bit definitions and macros for MCF_GPIO_PAR_PSC1 */
#define MCF_GPIO_PAR_PSC1_PAR_TXD1                   (0x04)
#define MCF_GPIO_PAR_PSC1_PAR_RXD1                   (0x08)
#define MCF_GPIO_PAR_PSC1_PAR_RTS1(x)                (((x)&0x03)<<4)
#define MCF_GPIO_PAR_PSC1_PAR_CTS1(x)                (((x)&0x03)<<6)
#define MCF_GPIO_PAR_PSC1_PAR_CTS1_GPIO              (0x00)
#define MCF_GPIO_PAR_PSC1_PAR_CTS1_BCLK              (0x80)
#define MCF_GPIO_PAR_PSC1_PAR_CTS1_CTS               (0xC0)
#define MCF_GPIO_PAR_PSC1_PAR_RTS1_GPIO              (0x00)
#define MCF_GPIO_PAR_PSC1_PAR_RTS1_FSYNC             (0x20)
#define MCF_GPIO_PAR_PSC1_PAR_RTS1_RTS               (0x30)

/* Bit definitions and macros for MCF_GPIO_PAR_PSC0 */
#define MCF_GPIO_PAR_PSC0_PAR_TXD0                   (0x04)
#define MCF_GPIO_PAR_PSC0_PAR_RXD0                   (0x08)
#define MCF_GPIO_PAR_PSC0_PAR_RTS0(x)                (((x)&0x03)<<4)
#define MCF_GPIO_PAR_PSC0_PAR_CTS0(x)                (((x)&0x03)<<6)
#define MCF_GPIO_PAR_PSC0_PAR_CTS0_GPIO              (0x00)
#define MCF_GPIO_PAR_PSC0_PAR_CTS0_BCLK              (0x80)
#define MCF_GPIO_PAR_PSC0_PAR_CTS0_CTS               (0xC0)
#define MCF_GPIO_PAR_PSC0_PAR_RTS0_GPIO              (0x00)
#define MCF_GPIO_PAR_PSC0_PAR_RTS0_FSYNC             (0x20)
#define MCF_GPIO_PAR_PSC0_PAR_RTS0_RTS               (0x30)

/* Bit definitions and macros for MCF_GPIO_PAR_DSPI */
#define MCF_GPIO_PAR_DSPI_PAR_SOUT(x)                (((x)&0x0003)<<0)
#define MCF_GPIO_PAR_DSPI_PAR_SIN(x)                 (((x)&0x0003)<<2)
#define MCF_GPIO_PAR_DSPI_PAR_SCK(x)                 (((x)&0x0003)<<4)
#define MCF_GPIO_PAR_DSPI_PAR_CS0(x)                 (((x)&0x0003)<<6)
#define MCF_GPIO_PAR_DSPI_PAR_CS2(x)                 (((x)&0x0003)<<8)
#define MCF_GPIO_PAR_DSPI_PAR_CS3(x)                 (((x)&0x0003)<<10)
#define MCF_GPIO_PAR_DSPI_PAR_CS5                    (0x1000)
#define MCF_GPIO_PAR_DSPI_PAR_CS3_GPIO               (0x0000)
#define MCF_GPIO_PAR_DSPI_PAR_CS3_CANTX              (0x0400)
#define MCF_GPIO_PAR_DSPI_PAR_CS3_TOUT               (0x0800)
#define MCF_GPIO_PAR_DSPI_PAR_CS3_DSPICS             (0x0C00)
#define MCF_GPIO_PAR_DSPI_PAR_CS2_GPIO               (0x0000)
#define MCF_GPIO_PAR_DSPI_PAR_CS2_CANTX              (0x0100)
#define MCF_GPIO_PAR_DSPI_PAR_CS2_TOUT               (0x0200)
#define MCF_GPIO_PAR_DSPI_PAR_CS2_DSPICS             (0x0300)
#define MCF_GPIO_PAR_DSPI_PAR_CS0_GPIO               (0x0000)
#define MCF_GPIO_PAR_DSPI_PAR_CS0_FSYNC              (0x0040)
#define MCF_GPIO_PAR_DSPI_PAR_CS0_RTS                (0x0080)
#define MCF_GPIO_PAR_DSPI_PAR_CS0_DSPICS             (0x00C0)
#define MCF_GPIO_PAR_DSPI_PAR_SCK_GPIO               (0x0000)
#define MCF_GPIO_PAR_DSPI_PAR_SCK_BCLK               (0x0010)
#define MCF_GPIO_PAR_DSPI_PAR_SCK_CTS                (0x0020)
#define MCF_GPIO_PAR_DSPI_PAR_SCK_SCK                (0x0030)
#define MCF_GPIO_PAR_DSPI_PAR_SIN_GPIO               (0x0000)
#define MCF_GPIO_PAR_DSPI_PAR_SIN_RXD                (0x0008)
#define MCF_GPIO_PAR_DSPI_PAR_SIN_SIN                (0x000C)
#define MCF_GPIO_PAR_DSPI_PAR_SOUT_GPIO              (0x0000)
#define MCF_GPIO_PAR_DSPI_PAR_SOUT_TXD               (0x0002)
#define MCF_GPIO_PAR_DSPI_PAR_SOUT_SOUT              (0x0003)

/* Bit definitions and macros for MCF_GPIO_PAR_TIMER */
#define MCF_GPIO_PAR_TIMER_PAR_TOUT2                 (0x01)
#define MCF_GPIO_PAR_TIMER_PAR_TIN2(x)               (((x)&0x03)<<1)
#define MCF_GPIO_PAR_TIMER_PAR_TOUT3                 (0x08)
#define MCF_GPIO_PAR_TIMER_PAR_TIN3(x)               (((x)&0x03)<<4)
#define MCF_GPIO_PAR_TIMER_PAR_TIN3_CANRX            (0x00)
#define MCF_GPIO_PAR_TIMER_PAR_TIN3_IRQ              (0x20)
#define MCF_GPIO_PAR_TIMER_PAR_TIN3_TIN              (0x30)
#define MCF_GPIO_PAR_TIMER_PAR_TIN2_CANRX            (0x00)
#define MCF_GPIO_PAR_TIMER_PAR_TIN2_IRQ              (0x04)
#define MCF_GPIO_PAR_TIMER_PAR_TIN2_TIN              (0x06)

/********************************************************************/

#endif /* __MCF548X_GPIO_H__ */
