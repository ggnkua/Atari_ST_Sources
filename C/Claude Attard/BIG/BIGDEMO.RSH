/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "BIGDEMO.H"

#if !defined(WHITEBAK)
#define WHITEBAK    0x0040
#endif
#if !defined(DRAW3D)
#define DRAW3D      0x0080
#endif

#define FLAGS9  0x0200
#define FLAGS10 0x0400
#define FLAGS11 0x0800
#define FLAGS12 0x1000
#define FLAGS13 0x2000
#define FLAGS14 0x4000
#define FLAGS15 0x8000
#define STATE8  0x0100
#define STATE9  0x0200
#define STATE10 0x0400
#define STATE11 0x0800
#define STATE12 0x1000
#define STATE13 0x2000
#define STATE14 0x4000
#define STATE15 0x8000

TEDINFO rs_tedinfo[] =
{ "____________________",
  "Texte 1 : \004 ____________________ \003",
  "XXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 21, 35,
  "____________________",
  "Texte 2 :   ____________________",
  "XXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 21, 33,
  "AIDE",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 5, 1,
  "D\202mo et routines r\202alis\202s en Pure C",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, 0, 36, 1,
  "v 1.05 du 16/06/93",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, 0, 19, 1,
  "Librairie de fonctions pour le d\202veloppement",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1181, 0, 0, 45, 1,
  "d\047applications sous GEM en langage C.",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1181, 0, 0, 38, 1,
  "Cr\202e par Claude ATTARD",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1181, 0, 0, 23, 1,
  "Alex L.,  Daniel B.,  F\202lix M.",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, 0, 31, 1,
  "Jean-Marc G.,  Jo\211l H.,  Marc A.",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, 0, 33, 1,
  "Et \205 V\202ronique... pour sa patience.",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, 0, 36, 1,
  "CONTACT",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 8, 1,
  "__________",
  "Champ 1 : \004 __________ \003",
  "XXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 11, 25,
  "__________",
  "Champ 2 : \004 __________ \003",
  "XXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 11, 25,
  "__________",
  "Champ 3 :   __________",
  "XXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 11, 23,
  "__________",
  "Champ 4 :   __________",
  "XXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 11, 23,
  "INFOS",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 6, 1,
  "INFOS",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 6, 1,
  "L\047utilisation de BIG dans des applications commerciales est",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, 0, 60, 1,
  "libre, mais un don serait fortement appr\202ci\202. Merci.",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, 0, 53, 1
};

RSIB0MASK[] =
{ 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF
};

RSIB0DATA[] =
{ 0x0000, 0x0000, 0x3C3E, 0x3C3E, 
  0x31CE, 0xB3DC, 0x07F7, 0x2FE0, 
  0x4C3E, 0x1C3A, 0x781A, 0x381E, 
  0x704C, 0x300E, 0x300F, 0xB02C, 
  0x300F, 0xE02C, 0x300C, 0x602C, 
  0x3048, 0x200C, 0x100A, 0x3048, 
  0x1818, 0x3018, 0x0C3C, 0x3830, 
  0x07E8, 0x6FE0, 0x03CC, 0x27C0, 
  0x0000, 0x4000, 0x0010, 0x0000, 
  0x0010, 0x4000, 0x0028, 0x1000, 
  0x0050, 0x6800, 0x0080, 0x0400, 
  0x0030, 0x3000, 0x0000, 0x0200, 
  0x00A0, 0x3000, 0x0090, 0x1600, 
  0x03F0, 0x3F80, 0x0FF8, 0x7BC0, 
  0x0FFF, 0xFFC0, 0x1DEF, 0xED80, 
  0x1DEF, 0x7DE0, 0x0000, 0x0000
};

ICONBLK rs_iconblk[] =
{ RSIB0MASK, RSIB0DATA, "ICONE", 0x1000|'X',
    0,  17,   0,   0,  32,  32,   1,  32,  30,   8
};

RSBB0DATA[] =
{ 0x0000, 0x0000, 0x3C3E, 0x3C3E, 
  0x31CE, 0xB3DC, 0x07F7, 0x2FE0, 
  0x4C3E, 0x1C3A, 0x781A, 0x381E, 
  0x704C, 0x300E, 0x300F, 0xB02C, 
  0x300F, 0xE02C, 0x300C, 0x602C, 
  0x3048, 0x200C, 0x100A, 0x3048, 
  0x1818, 0x3018, 0x0C3C, 0x3830, 
  0x07E8, 0x6FE0, 0x03CC, 0x27C0, 
  0x0000, 0x4000, 0x0010, 0x0000, 
  0x0010, 0x4000, 0x0028, 0x1000, 
  0x0050, 0x6800, 0x0080, 0x0400, 
  0x0030, 0x3000, 0x0000, 0x0200, 
  0x00A0, 0x3000, 0x0090, 0x1600, 
  0x03F0, 0x3F80, 0x0FF8, 0x7BC0, 
  0x0FFF, 0xFFC0, 0x1DEF, 0xED80, 
  0x1DEF, 0x7DE0, 0x0000, 0x0000
};

RSBB1DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0xF000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x8E00, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x4100, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x2080, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x1040, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0820, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0810, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0408, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0407, 
  0xFF00, 0x0000, 0x0000, 0x0000, 
  0x0400, 0x00E0, 0x0000, 0x0000, 
  0x0000, 0x0400, 0x001C, 0x0000, 
  0x0000, 0x0000, 0x0400, 0x0002, 
  0x0000, 0x0000, 0x0000, 0x0400, 
  0x0001, 0x0000, 0x0000, 0x0000, 
  0x0800, 0x0000, 0x8000, 0x0000, 
  0x0000, 0x0800, 0x0000, 0x4000, 
  0x0000, 0x0000, 0x1000, 0x0000, 
  0x2000, 0x0000, 0x0000, 0x2000, 
  0x0000, 0x1000, 0x0000, 0x0000, 
  0x4000, 0x0000, 0x0800, 0x0000, 
  0x0000, 0x8000, 0x0000, 0x4800, 
  0x0000, 0x0000, 0x8000, 0x0000, 
  0x6800, 0x0000, 0x0001, 0x0000, 
  0x0000, 0x0800, 0x0000, 0x0002, 
  0x0000, 0x0000, 0x0800, 0x0000, 
  0x0004, 0x0000, 0x0000, 0x0400, 
  0x0000, 0x0008, 0x0000, 0x0000, 
  0x0200, 0x0000, 0x0010, 0x003F, 
  0x801F, 0x0100, 0x0000, 0x0020, 
  0x00C0, 0x8020, 0xC080, 0x0000, 
  0x0040, 0x0100, 0x4040, 0x3F80, 
  0x0000, 0x0080, 0x0600, 0x2080, 
  0x0000, 0x0000, 0x0100, 0x1800, 
  0x2080, 0x0000, 0x0000, 0x0100, 
  0x6000, 0x2100, 0x0000, 0x0000, 
  0x0201, 0x8000, 0x4200, 0x0000, 
  0x0000, 0x0202, 0x0000, 0x8C00, 
  0x0000, 0x0000, 0x040C, 0x0000, 
  0xF000, 0x0000, 0x0000, 0x0830, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0840, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x1080, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x1100, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x2200, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x4200, 0x0000, 0x0000, 0x0000, 
  0x0003, 0x8400, 0x0000, 0x0000, 
  0x0000, 0x000C, 0x0400, 0x0000, 
  0x0000, 0x0000, 0x0030, 0x0200, 
  0x0000, 0x0000, 0x0000, 0x0040, 
  0x0100, 0x0000, 0x0000, 0x0000, 
  0x0080, 0x0080, 0x0000, 0x0000, 
  0x0000, 0x01FF, 0xF880, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0680, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0180, 0x0000, 0x0000, 0x0000
};

RSBB2DATA[] =
{ 0x0000, 0x0000, 0x3C3E, 0x3C3E, 
  0x31CE, 0xB3DC, 0x07F7, 0x2FE0, 
  0x4C3E, 0x1C3A, 0x781A, 0x381E, 
  0x704C, 0x300E, 0x300F, 0xB02C, 
  0x300F, 0xE02C, 0x300C, 0x602C, 
  0x3048, 0x200C, 0x100A, 0x3048, 
  0x1818, 0x3018, 0x0C3C, 0x3830, 
  0x07E8, 0x6FE0, 0x03CC, 0x27C0, 
  0x0000, 0x4000, 0x0010, 0x0000, 
  0x0010, 0x4000, 0x0028, 0x1000, 
  0x0050, 0x6800, 0x0080, 0x0400, 
  0x0030, 0x3000, 0x0000, 0x0200, 
  0x00A0, 0x3000, 0x0090, 0x1600, 
  0x03F0, 0x3F80, 0x0FF8, 0x7BC0, 
  0x0FFF, 0xFFC0, 0x1DEF, 0xED80, 
  0x1DEF, 0x7DE0, 0x0000, 0x0000
};

RSBB3DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x003C, 0x1E00, 
  0x00D6, 0x3580, 0x01AB, 0x6AC0, 
  0x0755, 0xD560, 0x1AAA, 0xAAB8, 
  0x7555, 0x5556, 0x3EAA, 0xAABC, 
  0x5F55, 0xD5FE, 0x2EFE, 0xBF7A, 
  0x3610, 0x8874, 0x1B10, 0x886C, 
  0x1590, 0x88D8, 0x0AFF, 0xFFA8, 
  0x0D64, 0x44D0, 0x06B4, 0x45B0, 
  0x055F, 0xFF60, 0x06AA, 0xAAA0, 
  0x0355, 0x5540, 0x01AA, 0xAAC0, 
  0x00D5, 0x5580, 0x006A, 0xAB00, 
  0x001F, 0xFC00, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000
};

RSBB4DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x00FE, 
  0x0000, 0x1FFE, 0x0003, 0xFFFC, 
  0x000F, 0xFFF0, 0x003F, 0xFFE0, 
  0x02FF, 0xFF80, 0x03FF, 0xFF00, 
  0x07FF, 0xFE00, 0x0FFF, 0xFC00, 
  0x3FFD, 0xFC00, 0x7FFF, 0xFC00, 
  0x3FFF, 0xFE00, 0x3F7F, 0xFE00, 
  0x3F3F, 0xFE00, 0x1E1E, 0x0000, 
  0x1E08, 0x0000, 0x0C06, 0x0002, 
  0x047E, 0x0000, 0x0400, 0x0000, 
  0x00C0, 0x0000, 0x0040, 0x0004, 
  0x007B, 0x0000, 0x007F, 0x0008, 
  0x0030, 0x0010, 0x0030, 0x0070, 
  0x003C, 0x00F0, 0x001C, 0x01E0, 
  0x0018, 0x07E0, 0x0018, 0x0FE0, 
  0x001F, 0x3FE0, 0x0000, 0x0000
};

RSBB5DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0780, 0x01E0, 
  0x0860, 0x0610, 0x1010, 0x0808, 
  0x231F, 0xF8C4, 0x2480, 0x0124, 
  0x2500, 0x00A4, 0x2200, 0x0044, 
  0x1000, 0x0008, 0x0800, 0x0010, 
  0x1004, 0x2008, 0x100A, 0x5008, 
  0x100A, 0x5008, 0x200A, 0x5004, 
  0x203F, 0xFC04, 0x41C3, 0xC382, 
  0x4201, 0x8042, 0x4400, 0x0022, 
  0x4080, 0x0102, 0x4100, 0x0082, 
  0x4180, 0x0182, 0x2143, 0xC284, 
  0x203C, 0x3C04, 0x1010, 0x0808, 
  0x0E10, 0x0870, 0x01E8, 0x1780, 
  0x0008, 0x1000, 0x0007, 0xE000, 
  0x0000, 0x0000, 0x0000, 0x0000
};

RSBB6DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0003, 0x0000, 0x0002, 0x4000, 
  0x0006, 0x1800, 0x0007, 0xF400, 
  0x0030, 0x0400, 0x003F, 0xF800, 
  0x001E, 0xB000, 0x0004, 0x2000, 
  0x0007, 0x4000, 0x000E, 0xF000, 
  0x003E, 0xEC00, 0x0057, 0xE200, 
  0x00DB, 0xA100, 0x008A, 0xC100, 
  0x010E, 0x0080, 0x0125, 0x8480, 
  0x0320, 0x0600, 0x0422, 0x0A40, 
  0x0631, 0x0A40, 0x041D, 0x0940, 
  0x067A, 0x0920, 0x003A, 0x0920, 
  0x010D, 0xD1E0, 0x0105, 0x08C0, 
  0x00C6, 0x89C0, 0x001D, 0xD680, 
  0x003A, 0x7480, 0x007A, 0xC6C0, 
  0x003F, 0x2880, 0x0000, 0x0000
};

RSBB7DATA[] =
{ 0x0000, 0x0000, 0x0020, 0x0000, 
  0x0103, 0xC000, 0x010F, 0xF004, 
  0x009C, 0x3C00, 0x0130, 0x0E00, 
  0x0130, 0x0600, 0x006C, 0x3308, 
  0x0066, 0x6300, 0x00C3, 0xC180, 
  0x60C1, 0x8180, 0x0181, 0x80C0, 
  0x0182, 0x40C0, 0x0301, 0x8060, 
  0x030F, 0xF060, 0x060C, 0x3030, 
  0x0605, 0xA030, 0x0CA3, 0xC532, 
  0x0CE0, 0x0718, 0x187F, 0xFE18, 
  0x181F, 0xF818, 0x1807, 0xE11C, 
  0x67C7, 0xE3E6, 0x217F, 0xFE10, 
  0x4210, 0x8420, 0x6108, 0x4212, 
  0x7F04, 0x217E, 0x1FFA, 0x1FFC, 
  0x20FF, 0xFF82, 0x0A0F, 0xF028, 
  0x4090, 0x0900, 0x0000, 0x0000
};

RSBB8DATA[] =
{ 0x0000, 0x0000, 0x0000, 0xD580, 
  0x0001, 0xDD40, 0x2901, 0xF340, 
  0x7F81, 0xFC40, 0x7981, 0xB040, 
  0x7F81, 0xF840, 0x7981, 0xF340, 
  0x5E81, 0xBB60, 0x4983, 0xB360, 
  0x4E8B, 0xF868, 0x79AF, 0xF058, 
  0x7EBA, 0xF8CA, 0x79E5, 0x7346, 
  0x7E8A, 0xBE82, 0x7995, 0x540A, 
  0x7EAA, 0xA82E, 0x79D5, 0x50B8, 
  0x7EAA, 0x82E0, 0x79F5, 0x0B88, 
  0x7EFA, 0x2E18, 0x79FE, 0xB810, 
  0x7FFE, 0xE000, 0x79FF, 0x82C4, 
  0x7FFF, 0x9130, 0x7FFF, 0x3226, 
  0x3FBF, 0xA23A, 0x555F, 0x8674, 
  0x2AAF, 0x13A8, 0x5557, 0x8740, 
  0x22AB, 0x1A80, 0x0000, 0x0000
};

RSBB9DATA[] =
{ 0x0000, 0x0000, 0x3310, 0x0238, 
  0x5E18, 0x02C8, 0x07F8, 0x0F04, 
  0x1837, 0xF602, 0x0040, 0x0002, 
  0x1040, 0x0100, 0x11F0, 0x013C, 
  0x27C8, 0x81FE, 0x2FFC, 0xC1FC, 
  0x2FD8, 0xC1FE, 0x44E1, 0xA3FC, 
  0x4001, 0xE082, 0x4083, 0xD000, 
  0x4083, 0x1000, 0x4040, 0x0080, 
  0x5040, 0x0000, 0x7CE2, 0x0108, 
  0x6FD3, 0x4F4E, 0x0FF3, 0xCF8E, 
  0x22FF, 0xFFFC, 0x10FE, 0x69E8, 
  0x5002, 0x7022, 0x6810, 0x4022, 
  0x7D10, 0x020E, 0x760C, 0x020C, 
  0x03A8, 0x0416, 0x0584, 0x04DC, 
  0x03E2, 0x1E7A, 0x00FF, 0xBCFC, 
  0x001F, 0xFFE0, 0x0000, 0x0000
};

RSBB10DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x4000, 0x0001, 0x4C00, 
  0x0002, 0x7880, 0x0004, 0x2440, 
  0x3008, 0x2720, 0x1811, 0xCFD6, 
  0x0C27, 0x97FE, 0x0E2F, 0xFFF6, 
  0x0FDF, 0xFFFE, 0x3FFF, 0xFFFC, 
  0x7FFF, 0xFFFE, 0x7FFF, 0xF7FE, 
  0x7FFF, 0xE5FE, 0x7FFE, 0xDFFE, 
  0x7FFF, 0xBCFE, 0x7FFF, 0x8CFE, 
  0x7FFC, 0x83FE, 0x7FFF, 0xB07E, 
  0x7FFF, 0xFF7E, 0x7FFF, 0xFCFE, 
  0x7FFF, 0xFCFE, 0x7FFF, 0xE1FE, 
  0x3FFF, 0xFFFE, 0x2DFF, 0xFFFE, 
  0x0B7F, 0xFFFE, 0x005F, 0xFFFE, 
  0x001F, 0xFFFE, 0x001F, 0xFFFE, 
  0x001F, 0xFFFE, 0x0000, 0x0000
};

BITBLK rs_bitblk[] =
{ RSBB0DATA,   4,  32,   0,   0, 0x0001,
  RSBB1DATA,  10,  48,   0,   0, 0x0001,
  RSBB2DATA,   4,  32,   0,   0, 0x0001,
  RSBB3DATA,   4,  32,   0,   0, 0x0001,
  RSBB4DATA,   4,  32,   0,   0, 0x0001,
  RSBB5DATA,   4,  32,   0,   0, 0x0001,
  RSBB6DATA,   4,  32,   0,   0, 0x0001,
  RSBB7DATA,   4,  32,   0,   0, 0x0001,
  RSBB8DATA,   4,  32,   0,   0, 0x0001,
  RSBB9DATA,   4,  32,   0,   0, 0x0001,
  RSBB10DATA,   4,  32,   0,   0, 0x0001
};

BYTE *rs_frstr[] =
{ "[6][ Voil\205 une| belle| alerte| avec une| ic\223ne !][ Et | trois | boutons ]",
  "[0][ Alerte appel\202e par| un menu hi\202rarchique| d\047un menu en fen\210tre !| Avec choix de l\047ic\223ne,| en prime...][ Super ]",
  "[6][ Cette alerte est| appel\202e par une| fonction li\202e \205 ce| bouton par pointeur.][ Vu ]",
  " Petit formulaire en fen\210tre ",
  " Grand formulaire en fen\210tre ",
  "Choisir un texte",
  "Choisir une image",
  " Voil\205 un beau texte ",
  " Voil\205 une belle image ",
  " Fen\210tre avec menu ",
  " Histogrammes al\202atoires ",
  " Huit histogrammes tram\202s"
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 MENU ****************************************************/
        -1,        1,        6, G_IBOX    ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0000, 0x0050, 0x0019,
         6,        2,        2, G_BOX     ,   /* Object 1  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0050, 0x0201,
         1, T_BUREAU, T_FENETRES, G_IBOX    ,   /* Object 2  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0002, 0x0000, 0x0020, 0x0301,
  T_FICHIER,       -1,       -1, G_TITLE   ,   /* Object 3 T_BUREAU */
  NONE, NORMAL, (LONG)" BIGdemo",
  0x0000, 0x0000, 0x0009, 0x0301,
  T_FENETRES,       -1,       -1, G_TITLE   ,   /* Object 4 T_FICHIER */
  NONE, NORMAL, (LONG)" Formulaires",
  0x0009, 0x0000, 0x000D, 0x0301,
         2,       -1,       -1, G_TITLE   ,   /* Object 5 T_FENETRES */
  NONE, NORMAL, (LONG)" Fen\210tres",
  0x0016, 0x0000, 0x000A, 0x0301,
         0,        7,       20, G_IBOX    ,   /* Object 6  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0301, 0x0050, 0x0017,
        16, M_INFOS ,       15, G_BOX     ,   /* Object 7  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0002, 0x0000, 0x0014, 0x0008,
         9,       -1,       -1, G_STRING  |0x3300,   /* Object 8 M_INFOS */
  NONE, NORMAL, (LONG)"  Info...         I ",
  0x0000, 0x0000, 0x0014, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, DISABLED, (LONG)"--------------------",
  0x0000, 0x0001, 0x0014, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"  #1                ",
  0x0000, 0x0002, 0x0014, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, NORMAL, (LONG)"  #2                ",
  0x0000, 0x0003, 0x0014, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"  #3                ",
  0x0000, 0x0004, 0x0014, 0x0001,
        14,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, NORMAL, (LONG)"  #4                ",
  0x0000, 0x0005, 0x0014, 0x0001,
        15,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"  #5                ",
  0x0000, 0x0006, 0x0014, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, NORMAL, (LONG)"  #6                ",
  0x0000, 0x0007, 0x0014, 0x0001,
        20, M_FORMLIBRE, M_QUITTER, G_BOX     ,   /* Object 16  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x000B, 0x0000, 0x0017, 0x0003,
  M_ALERTE,       -1,       -1, G_STRING  |0x3300,   /* Object 17 M_FORMLIBRE */
  NONE, NORMAL, (LONG)"  Formulaire libre  ^L ",
  0x0000, 0x0000, 0x0017, 0x0001,
  M_QUITTER,       -1,       -1, G_STRING  ,   /* Object 18 M_ALERTE */
  NONE, NORMAL, (LONG)"  BIG Alerte        \001A ",
  0x0000, 0x0001, 0x0017, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 19 M_QUITTER */
  NONE, NORMAL, (LONG)"  Quitter           \007Q ",
  0x0000, 0x0002, 0x0017, 0x0001,
         6, M_WFORMPETIT, M_WMENU , G_BOX     ,   /* Object 20  */
  NONE, NORMAL, (LONG)0x00FF1000L,
  0x0018, 0x0000, 0x0017, 0x0004,
  M_WFORMGRAND,       -1,       -1, G_STRING  |0x3300,   /* Object 21 M_WFORMPETIT */
  NONE, NORMAL, (LONG)"  Petit formulaire  ^P ",
  0x0000, 0x0000, 0x0017, 0x0001,
  M_WWIND ,       -1,       -1, G_STRING  |0x3300,   /* Object 22 M_WFORMGRAND */
  NONE, NORMAL, (LONG)"  Grand formulaire  ^G ",
  0x0000, 0x0001, 0x0017, 0x0001,
  M_WMENU ,       -1,       -1, G_STRING  |0x2900,   /* Object 23 M_WWIND */
  NONE, STATE9|STATE11, (LONG)"  Fen\210tre normale    \003 ",
  0x0000, 0x0002, 0x0017, 0x0001,
        20,       -1,       -1, G_STRING  ,   /* Object 24 M_WMENU */
  LASTOB, NORMAL, (LONG)"  Fen\210tre menu      ^M ",
  0x0000, 0x0003, 0x0017, 0x0001,
  
  /******** Tree 1 BUREAU ****************************************************/
        -1, BU_ICN  , BU_BOXTXT, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00001113L,
  0x0000, 0x0000, 0x0011, 0x000B,
  BU_BOXTXT,       -1,       -1, G_ICON    ,   /* Object 1 BU_ICN */
  NONE, NORMAL, (LONG)&rs_iconblk[0],
  0x0003, 0x0007, 0x0004, 0x0802,
         0, BU_TXT1 , BU_TXT2 , G_BOX     ,   /* Object 2 BU_BOXTXT */
  NONE, NORMAL, (LONG)0x00011101L,
  0x0002, 0x0001, 0x000C, 0x0005,
  BU_TXT2 ,       -1,       -1, G_STRING  ,   /* Object 3 BU_TXT1 */
  NONE, NORMAL, (LONG)"Pop_Up 1",
  0x0002, 0x0001, 0x0008, 0x0001,
  BU_BOXTXT,       -1,       -1, G_STRING  ,   /* Object 4 BU_TXT2 */
  LASTOB, NORMAL, (LONG)"Pop_Up 2",
  0x0002, 0x0003, 0x0008, 0x0001,
  
  /******** Tree 2 FORMULAIRE ****************************************************/
        -1,        1, P_ANNULE, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0028, 0x0012,
         2,       -1,       -1, G_IBOX    |0x1100,   /* Object 1  */
  TOUCHEXIT, CROSSED|OUTLINED, (LONG)0x00FF1100L,
  0x0026, 0x0000, 0x0002, 0x0001,
  CADRE1  ,       -1,       -1, G_BUTTON  |0x1300,   /* Object 2  */
  NONE, STATE8|STATE10|STATE11, (LONG)"Gras Soulign\202 Italique",
  0x0002, 0x0001, 0x0024, 0x0001,
  CADRE2  ,        4,        5, G_BUTTON  |0x1400,   /* Object 3 CADRE1 */
  NONE, STATE8, (LONG)"Cadre 1",
  0x0004, 0x0003, 0x000C, 0x0003,
         5,       -1,       -1, G_BUTTON  |0x1200,   /* Object 4  */
  SELECTABLE|RBUTTON, SELECTED, (LONG)"Tr[uc",
  0x0001, 0x0001, 0x0007, 0x0001,
  CADRE1  ,       -1,       -1, G_BUTTON  |0x1200,   /* Object 5  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"M[achin",
  0x0001, 0x0002, 0x0009, 0x0001,
        10,        7,        9, G_BUTTON  |0x1400,   /* Object 6 CADRE2 */
  NONE, STATE8, (LONG)"Cadre 2",
  0x0018, 0x0003, 0x000C, 0x0004,
         8,       -1,       -1, G_BUTTON  |0x1200,   /* Object 7  */
  SELECTABLE|RBUTTON, DISABLED, (LONG)"[Truc",
  0x0001, 0x0001, 0x0007, 0x0001,
         9,       -1,       -1, G_BUTTON  |0x1200,   /* Object 8  */
  SELECTABLE|RBUTTON, SELECTED, (LONG)"[Machin",
  0x0001, 0x0002, 0x0009, 0x0001,
  CADRE2  ,       -1,       -1, G_BUTTON  |0x1200,   /* Object 9  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"[Chmoll",
  0x0001, 0x0003, 0x0009, 0x0001,
        11,       -1,       -1, G_BUTTON  ,   /* Object 10  */
  SELECTABLE, SHADOWED|STATE10, (LONG)"  Pop_Up  ",
  0x0005, 0x0008, 0x000A, 0x0001,
        13,       12,       12, G_BOX     ,   /* Object 11  */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x001C, 0x0008, 0x0004, 0x0002,
        11,       -1,       -1, G_IMAGE   ,   /* Object 12  */
  SELECTABLE, SHADOWED|STATE8|STATE9|STATE11, (LONG)&rs_bitblk[0],
  0x0000, 0x0000, 0x0004, 0x0002,
        14,       -1,       -1, G_BUTTON  |0x1200,   /* Object 13  */
  SELECTABLE, SELECTED, (LONG)"C[hose",
  0x0006, 0x000A, 0x0008, 0x0001,
        15,       -1,       -1, G_BUTTON  |0x1200,   /* Object 14  */
  SELECTABLE, NORMAL, (LONG)"[Bidule",
  0x0006, 0x000B, 0x0009, 0x0001,
  TXT1    ,       -1,       -1, G_BUTTON  |0x3300,   /* Object 15  */
  SELECTABLE, NORMAL, (LONG)"Alerte",
  0x0019, 0x000B, 0x000A, 0x0001,
  TXT2    ,       -1,       -1, G_FTEXT   |0x1900,   /* Object 16 TXT1 */
  EDITABLE, STATE9|STATE12|STATE13, (LONG)&rs_tedinfo[0],
  0x0004, 0x000D, 0x0022, 0x0001,
  P_CONFIRME,       -1,       -1, G_FTEXT   ,   /* Object 17 TXT2 */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[1],
  0x0004, 0x000E, 0x0020, 0x0001,
  P_AIDE  ,       -1,       -1, G_BUTTON  ,   /* Object 18 P_CONFIRME */
  SELECTABLE|DEFAULT|EXIT, NORMAL, (LONG)"Confirme",
  0x0006, 0x0010, 0x0009, 0x0001,
  P_ANNULE,       -1,       -1, G_BOXTEXT |0x1500,   /* Object 19 P_AIDE */
  SELECTABLE, OUTLINED|SHADOWED|STATE9|STATE10, (LONG)&rs_tedinfo[2],
  0x0012, 0x0010, 0x0006, 0x0001,
         0,       -1,       -1, G_BUTTON  |0x1F00,   /* Object 20 P_ANNULE */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)"Annule",
  0x001B, 0x0010, 0x0009, 0x0001,
  
  /******** Tree 3 POP_UP1 ****************************************************/
        -1,        1,       12, G_BOX     ,   /* Object 0  */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x000A, 0x000C,
         2,       -1,       -1, G_STRING  ,   /* Object 1  */
  TOUCHEXIT, DISABLED, (LONG)"  Tintin",
  0x0000, 0x0000, 0x000A, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2  */
  TOUCHEXIT, NORMAL, (LONG)"  Milou",
  0x0000, 0x0001, 0x000A, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  TOUCHEXIT, NORMAL, (LONG)"  Lucky",
  0x0000, 0x0002, 0x000A, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  TOUCHEXIT, NORMAL, (LONG)"  Luke",
  0x0000, 0x0003, 0x000A, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  TOUCHEXIT, NORMAL, (LONG)"  Ast\202rix",
  0x0000, 0x0004, 0x000A, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  TOUCHEXIT, NORMAL, (LONG)"  Mickey",
  0x0000, 0x0005, 0x000A, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  TOUCHEXIT, DISABLED, (LONG)"  Toto",
  0x0000, 0x0006, 0x000A, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  TOUCHEXIT, NORMAL, (LONG)"  Titi",
  0x0000, 0x0007, 0x000A, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  TOUCHEXIT, NORMAL, (LONG)"  Coyotte",
  0x0000, 0x0008, 0x000A, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  TOUCHEXIT, NORMAL, (LONG)"  Tom",
  0x0000, 0x0009, 0x000A, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11  */
  TOUCHEXIT, NORMAL, (LONG)"  Jerry",
  0x0000, 0x000A, 0x000A, 0x0001,
         0,       -1,       -1, G_STRING  ,   /* Object 12  */
  LASTOB|TOUCHEXIT, NORMAL, (LONG)"  Haddock",
  0x0000, 0x000B, 0x000A, 0x0001,
  
  /******** Tree 4 POP_UP2 ****************************************************/
        -1,        1,       14, G_BOX     ,   /* Object 0  */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0014, 0x0007,
         2,       -1,       -1, G_STRING  ,   /* Object 1  */
  TOUCHEXIT, NORMAL, (LONG)"  Id\202fix",
  0x0000, 0x0000, 0x000A, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2  */
  TOUCHEXIT, NORMAL, (LONG)"  John",
  0x0000, 0x0001, 0x000A, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  TOUCHEXIT, NORMAL, (LONG)"  Difool",
  0x0000, 0x0002, 0x000A, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  TOUCHEXIT, DISABLED, (LONG)"  Donald",
  0x0000, 0x0003, 0x000A, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  TOUCHEXIT, NORMAL, (LONG)"  Dingo",
  0x0000, 0x0004, 0x000A, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  TOUCHEXIT, NORMAL, (LONG)"  Riri",
  0x0000, 0x0005, 0x000A, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  TOUCHEXIT, NORMAL, (LONG)"  Fifi",
  0x0000, 0x0006, 0x000A, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  TOUCHEXIT, NORMAL, (LONG)"  Loulou",
  0x000A, 0x0000, 0x000A, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  TOUCHEXIT, NORMAL, (LONG)"  Bilbo",
  0x000A, 0x0001, 0x000A, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  TOUCHEXIT, DISABLED, (LONG)"  Dalton",
  0x000A, 0x0002, 0x000A, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11  */
  TOUCHEXIT, NORMAL, (LONG)"  Alfred",
  0x000A, 0x0003, 0x000A, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12  */
  TOUCHEXIT, NORMAL, (LONG)"  Betty",
  0x000A, 0x0004, 0x000A, 0x0001,
        14,       -1,       -1, G_STRING  ,   /* Object 13  */
  TOUCHEXIT, NORMAL, (LONG)"  Mafalda",
  0x000A, 0x0005, 0x000A, 0x0001,
         0,       -1,       -1, G_STRING  ,   /* Object 14  */
  LASTOB|TOUCHEXIT, NORMAL, (LONG)"  Droopy",
  0x000A, 0x0006, 0x000A, 0x0001,
  
  /******** Tree 5 INFOS ****************************************************/
        -1,        1, INF_SORTIE, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x000211C3L,
  0x0000, 0x0000, 0x0034, 0x000E,
         2,       -1,       -1, G_IBOX    |0x1100,   /* Object 1  */
  TOUCHEXIT, CROSSED|OUTLINED, (LONG)0x00001100L,
  0x0032, 0x0000, 0x0002, 0x0001,
  INF_INFOS,        3,       13, G_BOX     ,   /* Object 2  */
  NONE, NORMAL, (LONG)0x00021101L,
  0x0002, 0x0001, 0x0030, 0x000A,
         4,       -1,       -1, G_IMAGE   ,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_bitblk[1],
  0x0001, 0x0001, 0x000A, 0x0003,
         5,       -1,       -1, G_TEXT    ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[3],
  0x0012, 0x0005, 0x021A, 0x0600,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"BIG (\042Big Is GEM\042)",
  0x000D, 0x0001, 0x0012, 0x0001,
         7,       -1,       -1, G_TEXT    ,   /* Object 6  */
  NONE, NORMAL, (LONG)&rs_tedinfo[4],
  0x0020, 0x0001, 0x040D, 0x0001,
         8,       -1,       -1, G_TEXT    ,   /* Object 7  */
  NONE, NORMAL, (LONG)&rs_tedinfo[5],
  0x000D, 0x0002, 0x0021, 0x0001,
         9,       -1,       -1, G_TEXT    ,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[6],
  0x000C, 0x0003, 0x0023, 0x0600,
        10,       -1,       -1, G_TEXT    ,   /* Object 9  */
  NONE, NORMAL, (LONG)&rs_tedinfo[7],
  0x0016, 0x0004, 0x0410, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"Un grand merci aux copains pour leur aide",
  0x0004, 0x0006, 0x0029, 0x0001,
        12,       -1,       -1, G_TEXT    ,   /* Object 11  */
  NONE, NORMAL, (LONG)&rs_tedinfo[8],
  0x000D, 0x0007, 0x0416, 0x0001,
        13,       -1,       -1, G_TEXT    ,   /* Object 12  */
  NONE, NORMAL, (LONG)&rs_tedinfo[9],
  0x000C, 0x0008, 0x0018, 0x0600,
         2,       -1,       -1, G_TEXT    ,   /* Object 13  */
  NONE, NORMAL, (LONG)&rs_tedinfo[10],
  0x000B, 0x0009, 0x021A, 0x0600,
  INF_SORTIE,       -1,       -1, G_BOXTEXT |0x1500,   /* Object 14 INF_INFOS */
  SELECTABLE, OUTLINED|SHADOWED|STATE8|STATE10|STATE11, (LONG)&rs_tedinfo[11],
  0x0005, 0x000C, 0x000B, 0x0001,
         0,       -1,       -1, G_BUTTON  ,   /* Object 15 INF_SORTIE */
  SELECTABLE|DEFAULT|EXIT|LASTOB, NORMAL, (LONG)"Retour",
  0x0024, 0x000C, 0x000B, 0x0001,
  
  /******** Tree 6 AIDE1 ****************************************************/
        -1,        1,        9, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x002C, 0x000D,
         2,       -1,       -1, G_BUTTON  ,   /* Object 1  */
  SELECTABLE|DEFAULT|EXIT, NORMAL, (LONG)"Sortie",
  0x0012, 0x000B, 0x0009, 0x0001,
         9,        3,        8, G_BUTTON  |0x1400,   /* Object 2  */
  FLAGS11, NORMAL, (LONG)"Cadre",
  0x0002, 0x0003, 0x0028, 0x0007,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"Voil\205 une aide enti\212rement",
  0x0007, 0x0001, 0x001A, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"g\202r\202e en interne par le",
  0x0007, 0x0002, 0x0017, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"programme !",
  0x0007, 0x0003, 0x000B, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"Note : ce formulaire ne",
  0x0007, 0x0004, 0x0017, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"fait rien de particulier.",
  0x0007, 0x0005, 0x0019, 0x0001,
         2,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"C\047est juste une d\202mo.",
  0x0007, 0x0006, 0x0015, 0x0001,
         0,       -1,       -1, G_BUTTON  |0x1300,   /* Object 9  */
  LASTOB, STATE10|STATE11, (LONG)"Formulaire d\047aide",
  0x0002, 0x0001, 0x0028, 0x0001,
  
  /******** Tree 7 PETITFORM ****************************************************/
        -1,        1, PF_RAZ  , G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x003B, 0x000D,
         2,       -1,       -1, G_BUTTON  |0x1300,   /* Object 1  */
  NONE, STATE8|STATE11, (LONG)"Choisissez la trame du bureau :",
  0x0002, 0x0001, 0x0037, 0x0001,
        11, TRAME_1 , TRAME_8 , G_IBOX    ,   /* Object 2  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0002, 0x0003, 0x0037, 0x0002,
  TRAME_2 ,       -1,       -1, G_BOX     ,   /* Object 3 TRAME_1 */
  SELECTABLE|RBUTTON, NORMAL, (LONG)0x00FF1101L,
  0x0000, 0x0000, 0x0006, 0x0002,
  TRAME_3 ,       -1,       -1, G_BOX     ,   /* Object 4 TRAME_2 */
  SELECTABLE|RBUTTON, NORMAL, (LONG)0x00FF1111L,
  0x0007, 0x0000, 0x0006, 0x0002,
  TRAME_4 ,       -1,       -1, G_BOX     ,   /* Object 5 TRAME_3 */
  SELECTABLE|RBUTTON, NORMAL, (LONG)0x00FF1121L,
  0x000E, 0x0000, 0x0006, 0x0002,
  TRAME_5 ,       -1,       -1, G_BOX     ,   /* Object 6 TRAME_4 */
  SELECTABLE|RBUTTON, NORMAL, (LONG)0x00FF1131L,
  0x0015, 0x0000, 0x0006, 0x0002,
  TRAME_6 ,       -1,       -1, G_BOX     ,   /* Object 7 TRAME_5 */
  SELECTABLE|RBUTTON, NORMAL, (LONG)0x00FF1141L,
  0x001C, 0x0000, 0x0006, 0x0002,
  TRAME_7 ,       -1,       -1, G_BOX     ,   /* Object 8 TRAME_6 */
  SELECTABLE|RBUTTON, NORMAL, (LONG)0x00FF1151L,
  0x0023, 0x0000, 0x0006, 0x0002,
  TRAME_8 ,       -1,       -1, G_BOX     ,   /* Object 9 TRAME_7 */
  SELECTABLE|RBUTTON, NORMAL, (LONG)0x00FF1161L,
  0x002A, 0x0000, 0x0006, 0x0002,
         2,       -1,       -1, G_BOX     ,   /* Object 10 TRAME_8 */
  SELECTABLE|RBUTTON, NORMAL, (LONG)0x00FF1171L,
  0x0031, 0x0000, 0x0006, 0x0002,
        12,       -1,       -1, G_BUTTON  |0x1200,   /* Object 11  */
  SELECTABLE, SELECTED, (LONG)"C[hose",
  0x0010, 0x0006, 0x0008, 0x0001,
  PF_CHAMP1,       -1,       -1, G_BUTTON  |0x1200,   /* Object 12  */
  SELECTABLE, NORMAL, (LONG)"[Bidule",
  0x0022, 0x0006, 0x0009, 0x0001,
  PF_CHAMP2,       -1,       -1, G_FTEXT   |0x1900,   /* Object 13 PF_CHAMP1 */
  EDITABLE, STATE9|STATE10|STATE11|STATE12, (LONG)&rs_tedinfo[12],
  0x0003, 0x0008, 0x0018, 0x0001,
  PF_CHAMP3,       -1,       -1, G_FTEXT   |0x1900,   /* Object 14 PF_CHAMP2 */
  EDITABLE, STATE9|STATE10|STATE11|STATE12, (LONG)&rs_tedinfo[13],
  0x001F, 0x0008, 0x0018, 0x0001,
  PF_CHAMP4,       -1,       -1, G_FTEXT   ,   /* Object 15 PF_CHAMP3 */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[14],
  0x0003, 0x0009, 0x0016, 0x0001,
  PF_CONFIRME,       -1,       -1, G_FTEXT   ,   /* Object 16 PF_CHAMP4 */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[15],
  0x001F, 0x0009, 0x0016, 0x0001,
  PF_ANNULE,       -1,       -1, G_BUTTON  ,   /* Object 17 PF_CONFIRME */
  SELECTABLE|EXIT, STATE8, (LONG)"Confirme",
  0x0002, 0x000B, 0x0009, 0x0001,
  PF_AIDE ,       -1,       -1, G_BUTTON  ,   /* Object 18 PF_ANNULE */
  SELECTABLE|EXIT, STATE8, (LONG)"Annule",
  0x000D, 0x000B, 0x0009, 0x0001,
  PF_APPLIQUE,       -1,       -1, G_BOXTEXT |0x1500,   /* Object 19 PF_AIDE */
  SELECTABLE, OUTLINED|SHADOWED|STATE9|STATE10|STATE11, (LONG)&rs_tedinfo[16],
  0x001A, 0x000B, 0x0007, 0x0001,
  PF_RAZ  ,       -1,       -1, G_BUTTON  ,   /* Object 20 PF_APPLIQUE */
  SELECTABLE|DEFAULT|EXIT, NORMAL, (LONG)"Applique",
  0x0025, 0x000B, 0x0009, 0x0001,
         0,       -1,       -1, G_BUTTON  |0x1F00,   /* Object 21 PF_RAZ */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)"R.A.Z.",
  0x0030, 0x000B, 0x0009, 0x0001,
  
  /******** Tree 8 GRANDFORM ****************************************************/
        -1,        1, GF_RAZ  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00011133L,
  0x0000, 0x0000, 0x002A, 0x0023,
         2,       -1,       -1, G_BUTTON  |0x1300,   /* Object 1  */
  NONE, STATE8|STATE11, (LONG)"Oh ! Qu\047il est grand, mon formulaire !",
  0x0002, 0x0001, 0x0026, 0x0001,
         7,        3,        6, G_BUTTON  |0x1400,   /* Object 2  */
  NONE, STATE8|STATE10, (LONG)"Entr\202e ",
  0x000B, 0x0004, 0x0014, 0x0005,
         4,       -1,       -1, G_BUTTON  |0x1200,   /* Object 3  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"[Salade",
  0x0001, 0x0001, 0x0009, 0x0001,
         5,       -1,       -1, G_BUTTON  |0x1200,   /* Object 4  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"[Charcuterie",
  0x0001, 0x0002, 0x000E, 0x0001,
         6,       -1,       -1, G_BUTTON  |0x1200,   /* Object 5  */
  SELECTABLE|RBUTTON, SELECTED, (LONG)"Caca[huette",
  0x0001, 0x0003, 0x000D, 0x0001,
         2,       -1,       -1, G_BUTTON  |0x1200,   /* Object 6  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"Caramels [moux",
  0x0001, 0x0004, 0x0010, 0x0001,
        12,        8,       11, G_BUTTON  |0x1400,   /* Object 7  */
  NONE, STATE8|STATE10, (LONG)"Plat principal ",
  0x000B, 0x000A, 0x0014, 0x0005,
         9,       -1,       -1, G_BUTTON  |0x1200,   /* Object 8  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"[Ron Ron",
  0x0001, 0x0001, 0x000A, 0x0001,
        10,       -1,       -1, G_BUTTON  |0x1200,   /* Object 9  */
  SELECTABLE|RBUTTON, SELECTED, (LONG)"C[ouscous",
  0x0001, 0x0002, 0x000B, 0x0001,
        11,       -1,       -1, G_BUTTON  |0x1200,   /* Object 10  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"Ca[nigou",
  0x0001, 0x0003, 0x000A, 0x0001,
         7,       -1,       -1, G_BUTTON  |0x1200,   /* Object 11  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"Stea[k frites",
  0x0001, 0x0004, 0x000F, 0x0001,
        17,       13,       16, G_BUTTON  |0x1400,   /* Object 12  */
  NONE, STATE8|STATE10, (LONG)"Dessert ",
  0x000B, 0x0010, 0x0014, 0x0005,
        14,       -1,       -1, G_BUTTON  |0x1200,   /* Object 13  */
  SELECTABLE|RBUTTON, SELECTED, (LONG)"[Petit Suisse",
  0x0001, 0x0001, 0x000F, 0x0001,
        15,       -1,       -1, G_BUTTON  |0x1200,   /* Object 14  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"Re[ligieuse",
  0x0001, 0x0002, 0x000D, 0x0001,
        16,       -1,       -1, G_BUTTON  |0x1200,   /* Object 15  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"A[vocat",
  0x0001, 0x0003, 0x0009, 0x0001,
        12,       -1,       -1, G_BUTTON  |0x1200,   /* Object 16  */
  SELECTABLE|RBUTTON|TOUCHEXIT, NORMAL, (LONG)"[Tarte",
  0x0001, 0x0004, 0x0008, 0x0001,
        18,       -1,       -1, G_BUTTON  |0x1200,   /* Object 17  */
  SELECTABLE, NORMAL, (LONG)"Voic[i",
  0x000F, 0x0016, 0x0008, 0x0001,
        19,       -1,       -1, G_BUTTON  |0x1200,   /* Object 18  */
  SELECTABLE, SELECTED, (LONG)"Voil[a",
  0x000F, 0x0018, 0x0008, 0x0001,
  GF_PU1  , GF_ICN  , GF_ICN  , G_BOX     ,   /* Object 19  */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x0013, 0x001B, 0x0004, 0x0002,
        19,       -1,       -1, G_IMAGE   ,   /* Object 20 GF_ICN */
  SELECTABLE, SHADOWED|STATE8|STATE9|STATE11, (LONG)&rs_bitblk[2],
  0x0000, 0x0000, 0x0004, 0x0002,
  GF_PU2  ,       -1,       -1, G_BUTTON  ,   /* Object 21 GF_PU1 */
  SELECTABLE, SHADOWED|STATE8|STATE9, (LONG)"Pop_Up 1",
  0x0003, 0x001C, 0x000A, 0x0001,
  GF_CONFIRME,       -1,       -1, G_BUTTON  ,   /* Object 22 GF_PU2 */
  SELECTABLE, SHADOWED|STATE10, (LONG)"Pop_Up 2",
  0x001D, 0x001C, 0x000A, 0x0001,
  GF_ANNULE,       -1,       -1, G_BUTTON  ,   /* Object 23 GF_CONFIRME */
  SELECTABLE|EXIT, STATE8, (LONG)"Confirme",
  0x0005, 0x001F, 0x0009, 0x0001,
  GF_AIDE ,       -1,       -1, G_BUTTON  ,   /* Object 24 GF_ANNULE */
  SELECTABLE|EXIT, STATE8, (LONG)"Annule",
  0x001C, 0x001F, 0x0009, 0x0001,
  GF_APPLIQUE,       -1,       -1, G_BOXTEXT |0x1500,   /* Object 25 GF_AIDE */
  SELECTABLE, OUTLINED|SHADOWED|STATE9|STATE10|STATE11, (LONG)&rs_tedinfo[17],
  0x0012, 0x0020, 0x0006, 0x0001,
  GF_RAZ  ,       -1,       -1, G_BUTTON  ,   /* Object 26 GF_APPLIQUE */
  SELECTABLE|DEFAULT|EXIT, NORMAL, (LONG)"Applique",
  0x0005, 0x0021, 0x0009, 0x0001,
         0,       -1,       -1, G_BUTTON  |0x1F00,   /* Object 27 GF_RAZ */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)"R.A.Z.",
  0x001C, 0x0021, 0x0009, 0x0001,
  
  /******** Tree 9 W_MENU ****************************************************/
        -1,        1,        6, G_IBOX    ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0000, 0x0050, 0x0019,
         6,        2,        2, G_BOX     ,   /* Object 1  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0050, 0x0201,
         1, TW_BUREAU, TW_ALERTS, G_IBOX    ,   /* Object 2  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0002, 0x0000, 0x001B, 0x0301,
  TW_OPTIONS,       -1,       -1, G_TITLE   ,   /* Object 3 TW_BUREAU */
  NONE, NORMAL, (LONG)" BIGdemo",
  0x0000, 0x0000, 0x0009, 0x0301,
  TW_ALERTS,       -1,       -1, G_TITLE   ,   /* Object 4 TW_OPTIONS */
  NONE, NORMAL, (LONG)" Options",
  0x0009, 0x0000, 0x0009, 0x0301,
         2,       -1,       -1, G_TITLE   ,   /* Object 5 TW_ALERTS */
  NONE, NORMAL, (LONG)" Alertes",
  0x0012, 0x0000, 0x0009, 0x0301,
         0,        7,       19, G_IBOX    ,   /* Object 6  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0301, 0x0050, 0x0017,
        16, MW_INFOS,       15, G_BOX     ,   /* Object 7  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0002, 0x0000, 0x0010, 0x0008,
         9,       -1,       -1, G_STRING  |0x3300,   /* Object 8 MW_INFOS */
  NONE, NORMAL, (LONG)"  Infos...    I ",
  0x0000, 0x0000, 0x0010, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, DISABLED, (LONG)"----------------",
  0x0000, 0x0001, 0x0010, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"  #1            ",
  0x0000, 0x0002, 0x0010, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, NORMAL, (LONG)"  #2            ",
  0x0000, 0x0003, 0x0010, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"  #3            ",
  0x0000, 0x0004, 0x0010, 0x0001,
        14,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, NORMAL, (LONG)"  #4            ",
  0x0000, 0x0005, 0x0010, 0x0001,
        15,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"  #5            ",
  0x0000, 0x0006, 0x0010, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, NORMAL, (LONG)"  #6            ",
  0x0000, 0x0007, 0x0010, 0x0001,
        19, MW_IMAGE, MW_ALERTE, G_BOX     ,   /* Object 16  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x000B, 0x0000, 0x0016, 0x0002,
  MW_ALERTE,       -1,       -1, G_STRING  ,   /* Object 17 MW_IMAGE */
  NONE, NORMAL, (LONG)"  Charger image... \007C ",
  0x0000, 0x0000, 0x0016, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 18 MW_ALERTE */
  NONE, NORMAL, (LONG)"  Alerte           \007A ",
  0x0000, 0x0001, 0x0016, 0x0001,
         6, MW_ICN  , MW_ICN  , G_BOX     ,   /* Object 19  */
  NONE, NORMAL, (LONG)0x00FF1000L,
  0x0014, 0x0000, 0x000E, 0x0001,
        19,       -1,       -1, G_STRING  |0x2900,   /* Object 20 MW_ICN */
  LASTOB, STATE8|STATE9|STATE10|STATE11, (LONG)"  Ic\223nes    \003 ",
  0x0000, 0x0000, 0x000E, 0x0001,
  
  /******** Tree 10 MHIERA ****************************************************/
        -1,        1, MH_HISTO, G_BOX     ,   /* Object 0  */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0011, 0x0003,
         2,       -1,       -1, G_STRING  |0x3300,   /* Object 1  */
  TOUCHEXIT, NORMAL, (LONG)"  Texte...    ^T ",
  0x0000, 0x0000, 0x0011, 0x0001,
  MH_HISTO,       -1,       -1, G_STRING  |0x3300,   /* Object 2  */
  TOUCHEXIT, NORMAL, (LONG)"  Image...    ^I",
  0x0000, 0x0001, 0x0011, 0x0001,
         0,       -1,       -1, G_STRING  ,   /* Object 3 MH_HISTO */
  LASTOB|TOUCHEXIT, NORMAL, (LONG)"  Histogramme ^H",
  0x0000, 0x0002, 0x0011, 0x0001,
  
  /******** Tree 11 POPUP_ICN ****************************************************/
        -1,        1,        8, G_BOX     ,   /* Object 0  */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0010, 0x0004,
         2,       -1,       -1, G_IMAGE   ,   /* Object 1  */
  TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[3],
  0x0000, 0x0000, 0x0004, 0x0002,
         3,       -1,       -1, G_IMAGE   ,   /* Object 2  */
  TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[4],
  0x0004, 0x0000, 0x0004, 0x0002,
         4,       -1,       -1, G_IMAGE   ,   /* Object 3  */
  TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[5],
  0x0008, 0x0000, 0x0004, 0x0002,
         5,       -1,       -1, G_IMAGE   ,   /* Object 4  */
  TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[6],
  0x000C, 0x0000, 0x0004, 0x0002,
         6,       -1,       -1, G_IMAGE   ,   /* Object 5  */
  TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[7],
  0x0000, 0x0002, 0x0004, 0x0002,
         7,       -1,       -1, G_IMAGE   ,   /* Object 6  */
  TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[8],
  0x0004, 0x0002, 0x0004, 0x0002,
         8,       -1,       -1, G_IMAGE   ,   /* Object 7  */
  TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[9],
  0x0008, 0x0002, 0x0004, 0x0002,
         0,       -1,       -1, G_IMAGE   ,   /* Object 8  */
  LASTOB|TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[10],
  0x000C, 0x0002, 0x0004, 0x0002,
  
  /******** Tree 12 PU_LIBRE ****************************************************/
        -1,        1,       10, G_BOX     ,   /* Object 0  */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0013, 0x000A,
         2,       -1,       -1, G_STRING  ,   /* Object 1  */
  TOUCHEXIT, DISABLED, (LONG)"  - Formulaires -",
  0x0000, 0x0000, 0x0013, 0x0001,
  PUL_ALERT,       -1,       -1, G_STRING  |0x3300,   /* Object 2  */
  TOUCHEXIT, NORMAL, (LONG)"  Formulaire libre",
  0x0000, 0x0001, 0x0013, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3 PUL_ALERT */
  TOUCHEXIT, NORMAL, (LONG)"  BIG Alerte",
  0x0000, 0x0002, 0x0013, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  TOUCHEXIT, DISABLED, (LONG)"  - Fen\210tres -",
  0x0000, 0x0003, 0x0013, 0x0001,
         6,       -1,       -1, G_STRING  |0x3300,   /* Object 5  */
  TOUCHEXIT, NORMAL, (LONG)"  Petit Formulaire",
  0x0000, 0x0004, 0x0013, 0x0001,
         7,       -1,       -1, G_STRING  |0x3300,   /* Object 6  */
  TOUCHEXIT, NORMAL, (LONG)"  Grand Formulaire",
  0x0000, 0x0005, 0x0013, 0x0001,
         8,       -1,       -1, G_STRING  |0x3300,   /* Object 7  */
  TOUCHEXIT, NORMAL, (LONG)"  Fen\210tre Texte...",
  0x0000, 0x0006, 0x0013, 0x0001,
  PUL_WMENU,       -1,       -1, G_STRING  |0x3300,   /* Object 8  */
  TOUCHEXIT, NORMAL, (LONG)"  Fen\210tre Image...",
  0x0000, 0x0007, 0x0013, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9 PUL_WMENU */
  TOUCHEXIT, NORMAL, (LONG)"  Fen\210tre Menu...",
  0x0000, 0x0009, 0x0013, 0x0001,
         0,       -1,       -1, G_STRING  |0x3300,   /* Object 10  */
  LASTOB|TOUCHEXIT, NORMAL, (LONG)"  Fen\210tre Histo",
  0x0000, 0x0008, 0x0013, 0x0001,
  
  /******** Tree 13 CONTACT ****************************************************/
        -1,        1,       12, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x003D, 0x000C,
         2,       -1,       -1, G_BUTTON  |0x1300,   /* Object 1  */
  NONE, STATE10|STATE11, (LONG)"Pour me contacter",
  0x0002, 0x0001, 0x0039, 0x0001,
        10,        3,        9, G_BUTTON  |0x1400,   /* Object 2  */
  NONE, STATE10, (LONG)"Recevez le source de BIG ! ",
  0x0002, 0x0003, 0x0039, 0x0007,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"Pour recevoir le source complet des routines BIG,",
  0x0002, 0x0001, 0x0031, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"fa\214tes-moi parvenir la somme de 100 F.",
  0x0002, 0x0002, 0x0026, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"Vous pouvez \202galement me contacter pour des questions,",
  0x0002, 0x0003, 0x0036, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"des suggestions, des conseils, ou en cas de bug.",
  0x0002, 0x0004, 0x0030, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"Claude ATTARD",
  0x000E, 0x0005, 0x000D, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"36, rue Raspail",
  0x001E, 0x0005, 0x000F, 0x0001,
         2,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, NORMAL, (LONG)"94200  Ivry sur Seine",
  0x0013, 0x0006, 0x0015, 0x0001,
        11,       -1,       -1, G_TEXT    ,   /* Object 10  */
  NONE, NORMAL, (LONG)&rs_tedinfo[18],
  0x0009, 0x000A, 0x022C, 0x0001,
        12,       -1,       -1, G_TEXT    ,   /* Object 11  */
  NONE, NORMAL, (LONG)&rs_tedinfo[19],
  0x000B, 0x000B, 0x0027, 0x0600,
         0,       -1,       -1, G_IBOX    ,   /* Object 12  */
  SELECTABLE|DEFAULT|EXIT|LASTOB, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0000, 0x003D, 0x000C,
  
  /******** Tree 14 AIDE2 ****************************************************/
        -1,        1,        6, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0027, 0x000E,
         2,       -1,       -1, G_BUTTON  |0x1300,   /* Object 1  */
  NONE, STATE10|STATE11, (LONG)"Les formulaires en fen\210tre",
  0x0002, 0x0001, 0x0023, 0x0001,
         3,       -1,       -1, G_BUTTON  ,   /* Object 2  */
  SELECTABLE|DEFAULT|EXIT, NORMAL, (LONG)"Sortie",
  0x000F, 0x000C, 0x0009, 0x0001,
         6,        4,        5, G_BUTTON  |0x1400,   /* Object 3  */
  FLAGS11, NORMAL, (LONG)"Petit formulaire",
  0x0002, 0x0003, 0x0023, 0x0003,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"Ce formulaire permet de",
  0x0002, 0x0001, 0x0017, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"modifier la trame du bureau.",
  0x0002, 0x0002, 0x001C, 0x0001,
         0,        7,        9, G_BUTTON  |0x1400,   /* Object 6  */
  FLAGS11, NORMAL, (LONG)"Grand formulaire",
  0x0002, 0x0007, 0x0023, 0x0004,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"Ce formulaire permet de",
  0x0002, 0x0001, 0x0017, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"modifier le dessin de l\047ic\223ne",
  0x0002, 0x0002, 0x001D, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 9  */
  LASTOB, NORMAL, (LONG)"et les deux textes de la bo\214te.",
  0x0002, 0x0003, 0x001F, 0x0001,
  
  /******** Tree 15 HIERWIND ****************************************************/
        -1, MWH_ICN0, MWH_ICN9, G_BOX     ,   /* Object 0  */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0011, 0x000A,
  MWH_ICN1,       -1,       -1, G_STRING  ,   /* Object 1 MWH_ICN0 */
  TOUCHEXIT, NORMAL, (LONG)"  Ic\223ne 0     ^0",
  0x0000, 0x0000, 0x0011, 0x0001,
  MWH_ICN2,       -1,       -1, G_STRING  ,   /* Object 2 MWH_ICN1 */
  TOUCHEXIT, NORMAL, (LONG)"  Ic\223ne 1     ^1",
  0x0000, 0x0001, 0x0011, 0x0001,
  MWH_ICN3,       -1,       -1, G_STRING  |0x3300,   /* Object 3 MWH_ICN2 */
  TOUCHEXIT, NORMAL, (LONG)"  Ic\223ne 2     ^2",
  0x0000, 0x0002, 0x0011, 0x0001,
  MWH_ICN4,       -1,       -1, G_STRING  |0x3300,   /* Object 4 MWH_ICN3 */
  TOUCHEXIT, NORMAL, (LONG)"  Ic\223ne 3     ^3",
  0x0000, 0x0003, 0x0011, 0x0001,
  MWH_ICN5,       -1,       -1, G_STRING  |0x3300,   /* Object 5 MWH_ICN4 */
  TOUCHEXIT, NORMAL, (LONG)"  Ic\223ne 4     ^4",
  0x0000, 0x0004, 0x0011, 0x0001,
  MWH_ICN6,       -1,       -1, G_STRING  |0x3300,   /* Object 6 MWH_ICN5 */
  TOUCHEXIT, NORMAL, (LONG)"  Ic\223ne 5     ^5",
  0x0000, 0x0005, 0x0011, 0x0001,
  MWH_ICN7,       -1,       -1, G_STRING  |0x3300,   /* Object 7 MWH_ICN6 */
  TOUCHEXIT, NORMAL, (LONG)"  Ic\223ne 6     ^6",
  0x0000, 0x0006, 0x0011, 0x0001,
  MWH_ICN8,       -1,       -1, G_STRING  |0x3300,   /* Object 8 MWH_ICN7 */
  TOUCHEXIT, NORMAL, (LONG)"  Ic\223ne 7     ^7",
  0x0000, 0x0007, 0x0011, 0x0001,
  MWH_ICN9,       -1,       -1, G_STRING  |0x3300,   /* Object 9 MWH_ICN8 */
  TOUCHEXIT, NORMAL, (LONG)"  Ic\223ne 8     ^8",
  0x0000, 0x0008, 0x0011, 0x0001,
         0,       -1,       -1, G_STRING  |0x3300,   /* Object 10 MWH_ICN9 */
  LASTOB|TOUCHEXIT, NORMAL, (LONG)"  Ic\223ne 9     ^9",
  0x0000, 0x0009, 0x0011, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 MENU     */
  &rs_object[25],   /* Tree  1 BUREAU   */
  &rs_object[30],   /* Tree  2 FORMULAIRE */
  &rs_object[51],   /* Tree  3 POP_UP1  */
  &rs_object[64],   /* Tree  4 POP_UP2  */
  &rs_object[79],   /* Tree  5 INFOS    */
  &rs_object[95],   /* Tree  6 AIDE1    */
  &rs_object[105],   /* Tree  7 PETITFORM */
  &rs_object[127],   /* Tree  8 GRANDFORM */
  &rs_object[155],   /* Tree  9 W_MENU   */
  &rs_object[176],   /* Tree 10 MHIERA   */
  &rs_object[180],   /* Tree 11 POPUP_ICN */
  &rs_object[189],   /* Tree 12 PU_LIBRE */
  &rs_object[200],   /* Tree 13 CONTACT  */
  &rs_object[213],   /* Tree 14 AIDE2    */
  &rs_object[223]    /* Tree 15 HIERWIND */
};
