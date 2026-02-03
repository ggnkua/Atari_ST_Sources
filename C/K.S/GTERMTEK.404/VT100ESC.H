#define   ILLSEQ    0    /* Illegal Escape Code Sequence */
#define   ANSISM    1    /* Set Mode */
#define   ANSIRM    2    /* Reset Mode */
#define   ANSICUU   3    /* Cursor Up */
#define   ANSICUD   4    /* Cursor Down */
#define   ANSICUB   5    /* Cursor Backward */
#define   ANSICUF   6    /* Cursor Forward */
#define   ANSICUP   7    /* Cursor Position */
#define   ANSIHVP   8    /* Horizontal and Vertical Position */
#define   ANSIIND   9    /* Index */
#define   ANSIRID   10   /* Reverse Index */
#define   ANSINL    11   /* Next Line */
#define   ANSISC    12   /* Save Cursor */
#define   ANSIRC    13   /* Restore Cursor */
#define   ANSIHTS   14   /* Horizontal tabulation Set */
#define   ANSITC    15   /* Tabulation Clear */
#define   ANSISGR   16   /* Select Graphic Rendition */
#define   ANSISEA   17   /* Selective Erase Attribute */
#define   ANSIDHLT  18   /* Double Height line Top Half */
#define   ANSIDHLB  19   /* Double Height Line Bottom Half */
#define   ANSIDWL   20   /* Double Width Line */
#define   ANSISWL   21   /* Single Width Line */
#define   ANSIIL    22   /* Insert Line */
#define   ANSIDL    23   /* Delete Line */
#define   ANSIIC    24   /* Insert Character */
#define   ANSIDC    25   /* Delete Character */
#define   ANSIEC    26   /* Erase Character */
#define   ANSIEID   27   /* Erase in Display */
#define   ANSIEIL   28   /* Erase in Line */
#define   ANSISEIL  29   /* Selective Erase in Line */
#define   ANSISEID  30   /* Selective Erase in Display */
#define   ANSISTBM  31   /* Set Top and Bottom Margins */
#define   ANSIET    32   /* Enable Transmission */
#define   ANSIEPDT  33   /* Enable Page Dump Transmission */
#define   ANSIDA    34   /* Device Attribute */
#define   ANSIIT    35   /* Identify Terminal */
#define   ANSIDSR   36   /* Device Status Report */
#define   ANSIRTPU  37   /* Report Device Attributes Unsolicited */
#define   ANSIRTP   38   /* Report Device Attributes Solicited */
#define   ANSISR    39   /* Soft Reset */
#define   ANSIPCT   40   /* Perform Confidence Test */
#define   ANSISAD   41   /* Screen Alignement Display */
#define   ANSIAPM   42   /* Auto Print Mode */
#define   ANSIPC    43   /* Print Controller */
#define   ANSIPL    44   /* Print Line */
#define   ANSIPS    45   /* Print Screen */
#define   ANSIHCP   46   /* Hard Copy Print */


#define   KEYFIND   100  /* Find Key */
#define   KEYINS    101  /* Insert Here */
#define   KEYREM    102  /* Remove Key */
#define   KEYSEL    103  /* Select Key */
#define   KEYPS     104  /* Previous Screen */
#define   KEYNS     105  /* Next Screen */
#define   KEYSU     106  /* Scan Up */
#define   KEYSD     107  /* Scan Down */
#define   KEYSR     108  /* Scan Right */
#define   KEYSL     109  /* Scan Left */

struct esc_scan {
     char code;
     char flag;
} scn_tbl[128] = {
     {0,0},    /* NUL *//* 0 */
     {0,0},    /* SOH */ 
     {0,0},    /* STX */
     {0,0},    /* ETX */
     {0,0},    /* EOT */
     {0,0},    /* ENQ */
     {0,0},    /* ACK */
     {0,0},    /* BEL */
     {0,0},    /* BS  */
     {0,0},    /* HT  */
     {0,0},    /* LF  */
     {0,0},    /* VT  */
     {0,0},    /* FF  */
     {0,0},    /* CR  */
     {0,0},    /* SO  */
     {0,0},    /* SI  */
     {0,0},    /* DLE *//* 0x10 */
     {0,0},    /* DC1 */
     {0,0},    /* DC2 */
     {0,0},    /* DC3 */
     {0,0},    /* Dc4 */
     {0,0},    /* NAK */
     {0,0},    /* SYN */
     {0,0},    /* ETB */
     {0,0},    /* CAN */
     {0,0},    /* EM  */
     {0,0},    /* SUB */
     {0,0},    /* ESC */
     {0,0},    /* FS  */
     {0,0},    /* GS  */
     {0,0},    /* RS  */
     {0,0},    /* US  */
     {0,0},    /* ' ' *//* 0x20 */
     {0,0},    /* '!' */
     {0,0},    /* '"' */
     {0,0},    /* '#' */
     {0,0},    /* '$' */
     {0,0},    /* '%' */
     {0,0},    /* '&' */
     {0,0},    /* ''' */
     {0,0},    /* '(' */
     {0,0},    /* ')' */
     {0,0},    /* '*' */
     {0,0},    /* '+' */
     {0,0},    /* ',' */
     {0,0},    /* '-' */
     {0,0},    /* '.' */
     {0,0},    /* '/' */
     {0,0},    /* '0' *//* 0x30 */
     {0,0},    /* '1' */
     {0,0},    /* '2' */
     {0,0},    /* '3' */
     {0,0},    /* '4' */
     {0,0},    /* '5' */
     {0,0},    /* '6' */
     {0,0},    /* '7' */
     {0,0},    /* '8' */
     {0,0},    /* '9' */
     {0,0},    /* ':' */
     {0,0},    /* ';' */
     {0,0},    /* '<' */
     {0,0},    /* '=' */
     {0,0},    /* '>' */
     {0,0},    /* '?' */
     {ANSIIC,0},    /* 'Ý' *//* 0x40 */
     {ANSICUU,0},    /* 'A' */
     {ANSICUD,0},    /* 'B' */
     {ANSICUF,0},    /* 'C' */
     {ANSICUB,0},    /* 'D' */
     {0,0},    /* 'E' */
     {0,0},    /* 'F' */
     {0,0},    /* 'G' */
     {ANSICUP,0},    /* 'H' */
     {0,0},    /* 'I' */
     {ANSIEID,0},    /* 'J' */
     {ANSIEIL,0},    /* 'K' */
     {ANSIIL,0},    /* 'L' */
     {ANSIDL,0},    /* 'M' */
     {0,0},    /* 'N' */
     {0,0},    /* 'O' */
     {ANSIDC,0},    /* 'P' *//* 0x50 */
     {0,0},    /* 'Q' */
     {0,0},    /* 'R' */
     {0,0},    /* 'S' */
     {0,0},    /* 'T' */
     {0,0},    /* 'U' */
     {0,0},    /* 'V' */
     {0,0},    /* 'W' */
     {ANSIEC,0},    /* 'X' */
     {0,0},    /* 'Y' */
     {0,0},    /* 'Z' */
     {0,0},    /* '[' */
     {0,0},    /* '\' */
     {0,0},    /* ']' */
     {0,0},    /* '^' */
     {0,0},    /* '_' */
     {0,0},    /* '`' *//* 0x60 */
     {0,0},    /* 'a' */
     {0,0},    /* 'b' */
     {ANSIDA,0},    /* 'c' */
     {0,0},    /* 'd' */
     {0,0},    /* 'e' */
     {ANSIHVP,0},    /* 'f' */
     {ANSITC,0},    /* 'g' */
     {ANSISM,0},    /* 'h' */
     {ANSIAPM,0},    /* 'i' */
     {0,0},    /* 'j' */
     {0,0},    /* 'k' */
     {ANSIRM,0},    /* 'l' */
     {ANSISGR,0},    /* 'm' */
     {ANSIDSR,0},    /* 'n' */
     {0,0},    /* 'o' */
     {ANSISR,0},    /* 'p' *//* 0x70 */
     {ANSISEA,0},    /* 'q' */
     {ANSISTBR,0},    /* 'r' */
     {0,0},    /* 's' */
     {0,0},    /* 't' */
     {0,0},    /* 'u' */
     {0,0},    /* 'v' */
     {0,0},    /* 'w' */
     {ANSIRTPU,0},    /* 'x' */
     {0,0},    /* 'y' */
     {0,0},    /* 'z' */
     {0,0},    /* '{' */
     {0,0},    /* '|' */
     {0,0},    /* '}' */
     {0,0},    /* '~' */
     {0,0}     /* DEL */
};


