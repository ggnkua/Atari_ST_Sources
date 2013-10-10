   /* allow lower-case register names in in-line assembly code */

#define d0 D0
#define d1 D1
#define d2 D2
#define d3 D3
#define d4 D4
#define d5 D5
#define d6 D6
#define d7 D7
#define a0 A0
#define a1 A1
#define a2 A2
#define a3 A3
#define a4 A4
#define a5 A5
#define a6 A6
#define a7 A7
#define sp A7

   /* Megamax in-line assembler does not have the "illegal" instruction */
#define illegal      dc.w     0x4afc
