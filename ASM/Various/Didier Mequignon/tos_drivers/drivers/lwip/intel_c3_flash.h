/*
 * File:        intel_c3_flash.h
 * Purpose:     Flash driver for programming Intel Flash devices
 *
 * Notes:       This driver supports a single banks of Intel Flash.
 *              A bank is defined as one or more of the same Flash
 *              device connected to a single chip-select.
 */

#ifndef _INTEL_C3_FLASH_H_
#define _INTEL_C3_FLASH_H_

/********************************************************************/

void intel_c3_flash_init(unsigned long);

int intel_c3_flash_erase(unsigned long, int, void(*)(char));

int intel_c3_flash_program(unsigned long, unsigned long, int, int, void(*)(void), void(*)(char));

unsigned long intel_c3_flash_sector_start(unsigned long);

unsigned long intel_c3_flash_sector_end(unsigned long);

/********************************************************************/

#ifndef INTEL_C3_FLASH_DEVICES
#define INTEL_C3_FLASH_DEVICES  1
#endif

/********************************************************************/
/*
 * Defines used to correctly address the Flash device(s)
 *
 * INTEL_C3_FLASH_BUS_SHIFT - Number of bits to right-shift the byte
 *                            offsets of the sectors
 * INTEL_C3_FLASH_CELL      - Port size of Flash device(s)
 * INTEL_C3_FLASH_CMD_DATA  - Format of data when issuing commands
 *
 */
#if (INTEL_C3_FLASH_DEVICES == 1)
    #define INTEL_C3_FLASH_BUS_SHIFT        1
    #define INTEL_C3_FLASH_CELL             vuint16
    #define INTEL_C3_FLASH_CELL_BYTES       2
    #define INTEL_C3_FLASH_CELL_MASK        0x1
    #define INTEL_C3_FLASH_CMD_DATA(x)      ((uint16)x)
#elif (INTEL_C3_FLASH_DEVICES == 2)
    #define INTEL_C3_FLASH_BUS_SHIFT        2
    #define INTEL_C3_FLASH_CELL             vuint32
    #define INTEL_C3_FLASH_CELL_BYTES       4
    #define INTEL_C3_FLASH_CELL_MASK        0x3
    #define INTEL_C3_FLASH_CMD_DATA(x)      ((uint32)((x<<16)|x))
#else
#error "Unsupported number of Flash devices"
#endif

/********************************************************************/
/*
 * Flash sector definitions - addresses are given in bytes (not words!)
 */
#if (defined(INTEL_C3_FLASH_28F800C3T))
    /*
     * Top Boot
     * Sectors 0 through 14 are 64 KBytes
     * Sectors 15 through 22 are 8 KBytes
     */
    #define INTEL_C3_FLASH_SECTORS  23
    #define C3_SSIZE(n)     ((n < 15) ? (0x10000 * INTEL_C3_FLASH_DEVICES)   \
                                      : (0x2000 * INTEL_C3_FLASH_DEVICES))
    #define C3_SOFFSET(n)   ((n < 15) ? (0x10000 * INTEL_C3_FLASH_DEVICES * n)                           \
                                      : ((0x10000 * 15) + (0x2000 * (n - 15))))
    #define C3_SADDR(n)     (C3_SOFFSET(n) >> INTEL_C3_FLASH_BUS_SHIFT)

#elif (defined(INTEL_C3_FLASH_28F800C3B))
    /*
     * Bottom Boot
     * Sectors 0 through 7 are 8 KBytes
     * Sectors 8 through 22 are 64 KBytes
     */
    #define INTEL_C3_FLASH_SECTORS  23
#define C3_SSIZE(n)     ((n < 8) ? (0x2000 * INTEL_C3_FLASH_DEVICES)        \
                                 : (0x10000 * INTEL_C3_FLASH_DEVICES))
#define C3_SOFFSET(n)   ((n < 8) ? (0x2000 * INTEL_C3_FLASH_DEVICES * n)    \
                                 : (0x10000 + (0x10000 * (n - 8))))
#define C3_SADDR(n)     (C3_SOFFSET(n) >> INTEL_C3_FLASH_BUS_SHIFT)

#elif (defined(INTEL_C3_FLASH_28F160C3T))
    /*
     * Top Boot
     * Sectors 0 through 30 are 64 KBytes
     * Sectors 31 through 38 are 8 KBytes
     */
    #define INTEL_C3_FLASH_SECTORS  39
    #define C3_SSIZE(n)     ((n < 31) ? (0x10000 * INTEL_C3_FLASH_DEVICES)   \
                                      : (0x2000 * INTEL_C3_FLASH_DEVICES))
    #define C3_SOFFSET(n)   ((n < 31) ? (0x10000 * INTEL_C3_FLASH_DEVICES * n)                           \
                                      : ((0x10000 * 31) + (0x2000 * (n - 31))))
    #define C3_SADDR(n)     (C3_SOFFSET(n) >> INTEL_C3_FLASH_BUS_SHIFT)

#elif (defined(INTEL_C3_FLASH_28F160C3B))
    /*
     * Bottom Boot
     * Sectors 0 through 7 are 8 KBytes
     * Sectors 8 through 38 are 64 KBytes
     */
#define INTEL_C3_FLASH_SECTORS  39
#define C3_SSIZE(n)     ((n < 8) ? (0x2000 * INTEL_C3_FLASH_DEVICES)        \
                                 : (0x10000 * INTEL_C3_FLASH_DEVICES))
#define C3_SOFFSET(n)   ((n < 8) ? (0x2000 * INTEL_C3_FLASH_DEVICES * n)    \
                                 : (0x10000 + (0x10000 * (n - 8))))
#define C3_SADDR(n)     (C3_SOFFSET(n) >> INTEL_C3_FLASH_BUS_SHIFT)

#elif (defined(INTEL_C3_FLASH_28F320C3T))
    /*
     * Top Boot
     * Sectors 0 through 62 are 64 KBytes
     * Sectors 63 through 70 are 8 KBytes
     */
    #define INTEL_C3_FLASH_SECTORS  71
    #define C3_SSIZE(n)     ((n < 63) ? (0x10000 * INTEL_C3_FLASH_DEVICES)   \
                                      : (0x2000 * INTEL_C3_FLASH_DEVICES))
    #define C3_SOFFSET(n)   ((n < 63) ? (0x10000 * INTEL_C3_FLASH_DEVICES * n)                           \
                                      : ((0x10000 * 63) + (0x2000 * (n - 63))))
    #define C3_SADDR(n)     (C3_SOFFSET(n) >> INTEL_C3_FLASH_BUS_SHIFT)

#elif (defined(INTEL_C3_FLASH_28F320C3B))
    /*
     * Bottom Boot
     * Sectors 0 through 7 are 8 KBytes
     * Sectors 8 through 70 are 64 KBytes
     */
    #define INTEL_C3_FLASH_SECTORS  71
#define C3_SSIZE(n)     ((n < 8) ? (0x2000 * INTEL_C3_FLASH_DEVICES)        \
                                 : (0x10000 * INTEL_C3_FLASH_DEVICES))
#define C3_SOFFSET(n)   ((n < 8) ? (0x2000 * INTEL_C3_FLASH_DEVICES * n)    \
                                 : (0x10000 + (0x10000 * (n - 8))))
#define C3_SADDR(n)     (C3_SOFFSET(n) >> INTEL_C3_FLASH_BUS_SHIFT)

#elif (defined(INTEL_C3_FLASH_28F640C3T))
    /*
     * Top Boot
     * Sectors 0 through 126 are 64 KBytes
     * Sectors 127 through 134 are 8 KBytes
     */
    #define INTEL_C3_FLASH_SECTORS  135
    #define C3_SSIZE(n)     ((n < 127) ? (0x10000 * INTEL_C3_FLASH_DEVICES)  \
                                  : (0x2000 * INTEL_C3_FLASH_DEVICES))
    #define C3_SOFFSET(n)   ((n < 127) ? (0x10000 * INTEL_C3_FLASH_DEVICES * n)                           \
                                      : ((0x10000 * 127) + (0x2000 * (n - 127))))
    #define C3_SADDR(n) (C3_SOFFSET(n) >> INTEL_C3_FLASH_BUS_SHIFT)

#elif (defined(INTEL_C3_FLASH_28F640C3B))
    /*
     * Bottom Boot
     * Sectors 0 through 7 are 8 KBytes
     * Sectors 8 through 134 are 64 KBytes
     */
    #define INTEL_C3_FLASH_SECTORS  135
#define C3_SSIZE(n)     ((n < 8) ? (0x2000 * INTEL_C3_FLASH_DEVICES)        \
                                 : (0x10000 * INTEL_C3_FLASH_DEVICES))
#define C3_SOFFSET(n)   ((n < 8) ? (0x2000 * INTEL_C3_FLASH_DEVICES * n)    \
                                 : (0x10000 + (0x10000 * (n - 8))))
#define C3_SADDR(n)     (C3_SOFFSET(n) >> INTEL_C3_FLASH_BUS_SHIFT)

#else
#error "Unsupported Flash device"
#endif

/********************************************************************/

#endif /* _INTEL_C3_FLASH_H */
