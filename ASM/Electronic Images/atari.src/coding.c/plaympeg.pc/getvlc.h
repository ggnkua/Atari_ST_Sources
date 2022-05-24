/* getvlc.h, variable length code tables                                    */

/* Table B-3, mb_type in P-pictures, codes 001..1xx */
static VLCtab PMBtab0[8] = {
  {ERROR,0},
  {MB_FORWARD,3},
  {MB_PATTERN,2}, {MB_PATTERN,2},
  {MB_FORWARD|MB_PATTERN,1}, {MB_FORWARD|MB_PATTERN,1},
  {MB_FORWARD|MB_PATTERN,1}, {MB_FORWARD|MB_PATTERN,1}
};

/* Table B-3, mb_type in P-pictures, codes 000001..00011x */
static VLCtab PMBtab1[8] = {
  {ERROR,0},
  {MB_QUANT|MB_INTRA,6},
  {MB_QUANT|MB_PATTERN,5}, {MB_QUANT|MB_PATTERN,5},
  {MB_QUANT|MB_FORWARD|MB_PATTERN,5}, {MB_QUANT|MB_FORWARD|MB_PATTERN,5},
  {MB_INTRA,5}, {MB_INTRA,5}
};

/* Table B-4, mb_type in B-pictures, codes 0010..11xx */
static VLCtab BMBtab0[16] = {
  {ERROR,0}, {ERROR,0},
  {MB_FORWARD,4},
  {MB_FORWARD|MB_PATTERN,4},
  {MB_BACKWARD,3}, {MB_BACKWARD,3},
  {MB_BACKWARD|MB_PATTERN,3}, {MB_BACKWARD|MB_PATTERN,3},
  {MB_FORWARD|MB_BACKWARD,2}, {MB_FORWARD|MB_BACKWARD,2},
  {MB_FORWARD|MB_BACKWARD,2}, {MB_FORWARD|MB_BACKWARD,2},
  {MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},
  {MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},
  {MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},
  {MB_FORWARD|MB_BACKWARD|MB_PATTERN,2}
};

/* Table B-4, mb_type in B-pictures, codes 000001..00011x */
static VLCtab BMBtab1[8] = {
  {ERROR,0},
  {MB_QUANT|MB_INTRA,6},
  {MB_QUANT|MB_BACKWARD|MB_PATTERN,6},
  {MB_QUANT|MB_FORWARD|MB_PATTERN,6},
  {MB_QUANT|MB_FORWARD|MB_BACKWARD|MB_PATTERN,5},
  {MB_QUANT|MB_FORWARD|MB_BACKWARD|MB_PATTERN,5},
  {MB_INTRA,5}, {MB_INTRA,5}
};

/* Table B-10, motion_code, codes 0001 ... 01xx */
static VLCtab MVtab0[8] =
{ {ERROR,0}, {3,3}, {2,2}, {2,2}, {1,1}, {1,1}, {1,1}, {1,1}
};

/* Table B-10, motion_code, codes 0000011 ... 000011x */
static VLCtab MVtab1[8] =
{ {ERROR,0}, {ERROR,0}, {ERROR,0}, {7,6}, {6,6}, {5,6}, {4,5}, {4,5}
};

/* Table B-10, motion_code, codes 0000001100 ... 000001011x */
static VLCtab MVtab2[12] =
{ {16,9}, {15,9}, {14,9}, {13,9},
  {12,9}, {11,9}, {10,8}, {10,8},
  {9,8},  {9,8},  {8,8},  {8,8}
};

/* Table B-9, coded_block_pattern, codes 01000 ... 111xx */
static VLCtab CBPtab0[32] =
{ {ERROR,0}, {ERROR,0}, {ERROR,0}, {ERROR,0},
  {ERROR,0}, {ERROR,0}, {ERROR,0}, {ERROR,0},
  {62,5}, {2,5},  {61,5}, {1,5},  {56,5}, {52,5}, {44,5}, {28,5},
  {40,5}, {20,5}, {48,5}, {12,5}, {32,4}, {32,4}, {16,4}, {16,4},
  {8,4},  {8,4},  {4,4},  {4,4},  {60,3}, {60,3}, {60,3}, {60,3}
};

/* Table B-9, coded_block_pattern, codes 00000100 ... 001111xx */
static VLCtab CBPtab1[64] =
{ {ERROR,0}, {ERROR,0}, {ERROR,0}, {ERROR,0},
  {58,8}, {54,8}, {46,8}, {30,8},
  {57,8}, {53,8}, {45,8}, {29,8}, {38,8}, {26,8}, {37,8}, {25,8},
  {43,8}, {23,8}, {51,8}, {15,8}, {42,8}, {22,8}, {50,8}, {14,8},
  {41,8}, {21,8}, {49,8}, {13,8}, {35,8}, {19,8}, {11,8}, {7,8},
  {34,7}, {34,7}, {18,7}, {18,7}, {10,7}, {10,7}, {6,7},  {6,7},
  {33,7}, {33,7}, {17,7}, {17,7}, {9,7},  {9,7},  {5,7},  {5,7},
  {63,6}, {63,6}, {63,6}, {63,6}, {3,6},  {3,6},  {3,6},  {3,6},
  {36,6}, {36,6}, {36,6}, {36,6}, {24,6}, {24,6}, {24,6}, {24,6}
};

/* Table B-9, coded_block_pattern, codes 000000001 ... 000000111 */
static VLCtab CBPtab2[8] =
{ {ERROR,0}, {0,9}, {39,9}, {27,9}, {59,9}, {55,9}, {47,9}, {31,9}
};

/* Table B-1, macroblock_address_increment, codes 00010 ... 011xx */
static VLCtab MBAtab1[16] =
{ {ERROR,0}, {ERROR,0}, {7,5}, {6,5}, {5,4}, {5,4}, {4,4}, {4,4},
  {3,3}, {3,3}, {3,3}, {3,3}, {2,3}, {2,3}, {2,3}, {2,3}
};

/* Table B-1, macroblock_address_increment, codes 00000011000 ... 0000111xxxx */
static VLCtab MBAtab2[104] =
{
  {33,11}, {32,11}, {31,11}, {30,11}, {29,11}, {28,11}, {27,11}, {26,11},
  {25,11}, {24,11}, {23,11}, {22,11}, {21,10}, {21,10}, {20,10}, {20,10},
  {19,10}, {19,10}, {18,10}, {18,10}, {17,10}, {17,10}, {16,10}, {16,10},
  {15,8},  {15,8},  {15,8},  {15,8},  {15,8},  {15,8},  {15,8},  {15,8},
  {14,8},  {14,8},  {14,8},  {14,8},  {14,8},  {14,8},  {14,8},  {14,8},
  {13,8},  {13,8},  {13,8},  {13,8},  {13,8},  {13,8},  {13,8},  {13,8},
  {12,8},  {12,8},  {12,8},  {12,8},  {12,8},  {12,8},  {12,8},  {12,8},
  {11,8},  {11,8},  {11,8},  {11,8},  {11,8},  {11,8},  {11,8},  {11,8},
  {10,8},  {10,8},  {10,8},  {10,8},  {10,8},  {10,8},  {10,8},  {10,8},
  {9,7},   {9,7},   {9,7},   {9,7},   {9,7},   {9,7},   {9,7},   {9,7},
  {9,7},   {9,7},   {9,7},   {9,7},   {9,7},   {9,7},   {9,7},   {9,7},
  {8,7},   {8,7},   {8,7},   {8,7},   {8,7},   {8,7},   {8,7},   {8,7},
  {8,7},   {8,7},   {8,7},   {8,7},   {8,7},   {8,7},   {8,7},   {8,7}
};

