#define T0OBJ 0
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 42

BYTE *rs_strings[] = {
"STinG V00.01",
"Addressing.",
"FastEthernet",
"",
"Active",
"Parallel Point to Point Link",
"",
"",
"____________",
"IP Address : ___.___.___.___",
"999999999999",
"____________",
"Subnet Mask : ___.___.___.___",
"999999999999",
"_____",
"MTU : _____",
"99999",
"",
"Reload Routing Table",
"",
"SLIP",
"",
"PPP",
"",
"Van Jacobson Compression",
"",
"Use LAN port",
"No further parameters",
"are required.",
"Choose Hardware :",
"Riebl Mega (Mod.)",
"0123456789ab",
"MAC : __:__:__:__:__:__",
"nnnnnnnnnnnn",
"Masked Port :",
"FastEthernet",
"____________",
"Masking IP : ___.___.___.___",
"999999999999",
"Save",
"Ok",
"Cancel"};

LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
5L, 6L, 7L, 3, 6, 0, 0x1180, 0x0, -1, 29,1,
8L, 9L, 10L, 3, 6, 0, 0x1180, 0x0, -1, 13,29,
11L, 12L, 13L, 3, 6, 0, 0x1180, 0x0, -1, 13,30,
14L, 15L, 16L, 3, 6, 0, 0x1180, 0x0, -1, 6,12,
31L, 32L, 33L, 3, 6, 0, 0x1180, 0x0, -1, 13,24,
36L, 37L, 38L, 3, 6, 0, 0x1180, 0x0, -1, 13,29};

OBJECT rs_object[] = {
-1, 1, 47, G_BOX, NONE, NORMAL, 0x1101L, 0,0, 32,11,
45, 2, 41, G_BOX, NONE, NORMAL, 0xFF1100L, 0,0, 32,777,
4, 3, 3, G_BOX, NONE, NORMAL, 0xFF1100L, 18,0, 14,2561,
2, -1, -1, G_STRING, NONE, NORMAL, 0x0L, 1,1536, 12,1,
5, -1, -1, G_BUTTON, 0x41, SHADOWED, 0x1L, 2,1536, 14,1,
6, -1, -1, G_BUTTON, 0x41, SHADOWED, 0x2L, 2,3841, 14,1,
9, 7, 8, G_IBOX, NONE, NORMAL, 0x1100L, 20,2, 9,1,
8, -1, -1, 0x11A, SELECTABLE, 0x6, 0x4AL, 0,0, 2,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0x4L, 3,0, 6,1,
10, -1, -1, G_TEXT, NONE, NORMAL, 0x0L, 3,1027, 28,1,
18, 11, 15, G_BOX, NONE, NORMAL, 0xFF1100L, 0,2052, 32,2820,
15, 12, 14, G_IBOX, NONE, NORMAL, 0x1100L, 1025,512, 29,3,
13, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x1L, 1,0, 28,1,
14, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x2L, 0,1, 29,1,
11, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x3L, 8,2, 11,1,
10, 16, 17, G_IBOX, NONE, NORMAL, 0x1100L, 1028,1539, 23,1,
17, -1, -1, 0x11A, SELECTABLE, 0x6, 0xF8L, 0,0, 2,1,
15, -1, -1, G_STRING, NONE, NORMAL, 0x12L, 3,0, 20,1,
31, 19, 19, G_BOX, NONE, NORMAL, 0xFF1100L, 0,2052, 32,2820,
18, 20, 28, G_IBOX, NONE, NORMAL, 0x1100L, 3,2048, 27,2051,
25, 21, 24, G_IBOX, NONE, NORMAL, 0x1100L, 0,0, 17,1,
22, -1, -1, 0x11A, 0x11, 0x6, 0x10EL, 0,0, 2,1,
23, -1, -1, G_STRING, NONE, NORMAL, 0x14L, 3,0, 4,1,
24, -1, -1, 0x11A, 0x11, 0x6, 0x114L, 11,0, 2,1,
20, -1, -1, G_STRING, NONE, NORMAL, 0x16L, 14,0, 3,1,
28, 26, 27, G_IBOX, NONE, NORMAL, 0x1100L, 0,1025, 27,1,
27, -1, -1, 0x11A, SELECTABLE, 0x6, 0x119L, 0,0, 2,1,
25, -1, -1, G_STRING, NONE, NORMAL, 0x18L, 3,0, 24,1,
19, 29, 30, G_IBOX, NONE, NORMAL, 0x1100L, 0,2050, 15,1,
30, -1, -1, 0x11A, SELECTABLE, 0x6, 0x133L, 0,0, 2,1,
28, -1, -1, G_STRING, NONE, NORMAL, 0x1AL, 3,0, 12,1,
34, 32, 33, G_BOX, NONE, NORMAL, 0xFF1100L, 0,2052, 32,2820,
33, -1, -1, G_STRING, NONE, NORMAL, 0x1BL, 1029,1, 21,1,
31, -1, -1, G_STRING, NONE, NORMAL, 0x1CL, 1033,3074, 13,1,
38, 35, 37, G_BOX, NONE, NORMAL, 0xFF1100L, 0,2052, 32,2820,
36, -1, -1, G_STRING, NONE, NORMAL, 0x1DL, 2,1536, 17,1,
37, -1, -1, G_BUTTON, 0x41, SHADOWED, 0x1EL, 8,2305, 19,1,
34, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x4L, 1283,1027, 23,1,
39, -1, -1, G_BOX, NONE, NORMAL, 0xFF1100L, 0,2052, 32,2820,
40, -1, -1, G_BOX, NONE, NORMAL, 0xFF1100L, 0,2052, 32,2820,
41, -1, -1, G_BOX, NONE, NORMAL, 0xFF1100L, 0,2052, 32,2820,
1, 42, 44, G_BOX, NONE, NORMAL, 0xFF1100L, 0,2052, 32,2820,
43, -1, -1, G_STRING, NONE, NORMAL, 0x22L, 2,1, 13,1,
44, -1, -1, G_BUTTON, 0x41, SHADOWED, 0x23L, 16,1, 14,1,
41, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x5L, 2,3074, 29,1,
47, 46, 46, G_BOX, NONE, NORMAL, 0xFF1100L, 0,1033, 1803,3073,
45, -1, -1, G_BUTTON, 0x5, NORMAL, 0x27L, 1793,1536, 8,1,
0, 48, 49, G_BOX, NONE, NORMAL, 0xFF1100L, 12,1033, 20,3073,
49, -1, -1, G_BUTTON, 0x7, NORMAL, 0x28L, 514,1536, 5,1,
47, -1, -1, G_BUTTON, 0x25, NORMAL, 0x29L, 9,1536, 9,1};

LONG rs_trindex[] = {
0L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 42
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 6
#define NUM_OBS 50
#define NUM_TREE 1

BYTE pname[] = "STING.RSC";