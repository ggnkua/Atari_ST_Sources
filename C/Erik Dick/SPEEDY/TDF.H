/***** PUBLIC FONT HEADER OFFSET CONSTANTS  *****/ 
#define  FH_FMVER    0      /* U   D4.0 CR LF NULL NULL  8 bytes            */ 
#define  FH_FNTSZ    8      /* U   Font size (bytes) 4 bytes                */ 
#define  FH_FBFSZ   12      /* U   Min font buffer size (bytes) 4 bytes     */ 
#define  FH_CBFSZ   16      /* U   Min char buffer size (bytes) 2 bytes     */ 
#define  FH_HEDSZ   18      /* U   Header size (bytes) 2 bytes              */ 
#define  FH_FNTID   20      /* U   Source Font ID  2 bytes                  */ 
#define  FH_SFVNR   22      /* U   Source Font Version Number  2 bytes      */ 
#define  FH_FNTNM   24      /* U   Source Font Name  70 bytes               */ 
#define  FH_MDATE   94      /* U   Manufacturing Date  10 bytes             */ 
#define  FH_LAYNM  104      /* U   Layout Name  70 bytes                    */ 
#define  FH_CPYRT  174      /* U   Copyright Notice  78 bytes               */ 
#define  FH_NCHRL  252      /* U   Number of Chars in Layout  2 bytes       */ 
#define  FH_NCHRF  254      /* U   Total Number of Chars in Font  2 bytes   */ 
#define  FH_FCHRF  256      /* U   Index of first char in Font  2 bytes     */ 
#define  FH_NKTKS  258      /* U   Number of kerning tracks in font 2 bytes */ 
#define  FH_NKPRS  260      /* U   Number of kerning pairs in font 2 bytes  */ 
#define  FH_FLAGS  262      /* U   Font flags 1 byte:                       */ 
                            /*       Bit 0: Extended font                   */ 
                            /*       Bit 1: not used                        */ 
                            /*       Bit 2: not used                        */ 
                            /*       Bit 3: not used                        */ 
                            /*       Bit 4: not used                        */ 
                            /*       Bit 5: not used                        */ 
                            /*       Bit 6: not used                        */ 
                            /*       Bit 7: not used                        */ 
#define  FH_CLFGS  263      /* U   Classification flags 1 byte:             */ 
                            /*       Bit 0: Italic                          */ 
                            /*       Bit 1: Monospace                       */ 
                            /*       Bit 2: Serif                           */ 
                            /*       Bit 3: Display                         */ 
                            /*       Bit 4: not used                        */ 
                            /*       Bit 5: not used                        */ 
                            /*       Bit 6: not used                        */ 
                            /*       Bit 7: not used                        */ 
#define  FH_FAMCL  264      /* U   Family Classification 1 byte:            */ 
                            /*       0:  Don't care                         */ 
                            /*       1:  Serif                              */ 
                            /*       2:  Sans serif                         */ 
                            /*       3:  Monospace                          */ 
                            /*       4:  Script or calligraphic             */ 
                            /*       5:  Decorative                         */ 
                            /*       6-255: not used                        */ 
#define  FH_FRMCL  265      /* U   Font form Classification 1 byte:         */ 
                            /*       Bits 0-3 (width type):                 */ 
                            /*         0-3:   not used                      */ 
                            /*         4:     Condensed                     */ 
                            /*         5:     not used                      */ 
                            /*         6:     Semi-condensed                */ 
                            /*         7:     not used                      */ 
                            /*         8:     Normal                        */ 
                            /*         9:     not used                      */ 
                            /*        10:     Semi-expanded                 */ 
                            /*        11:     not used                      */ 
                            /*        12:     Expanded                      */ 
                            /*        13-15:  not used                      */ 
                            /*       Bits 4-7 (Weight):                     */ 
                            /*         0:   not used                        */ 
                            /*         1:   Thin                            */ 
                            /*         2:   Ultralight                      */ 
                            /*         3:   Extralight                      */ 
                            /*         4:   Light                           */ 
                            /*         5:   Book                            */ 
                            /*         6:   Normal                          */ 
                            /*         7:   Medium                          */ 
                            /*         8:   Semibold                        */ 
                            /*         9:   Demibold                        */ 
                            /*         10:  Bold                            */ 
                            /*         11:  Extrabold                       */ 
                            /*         12:  Ultrabold                       */ 
                            /*         13:  Heavy                           */ 
                            /*         14:  Black                           */ 
                            /*         15-16: not used                      */ 
#define  FH_SFNTN  266      /* U   Short Font Name  32 bytes                */ 
#define  FH_SFACN  298      /* U   Short Face Name  16 bytes                */ 
#define  FH_FNTFM  314      /* U   Font form 14 bytes                       */ 
#define  FH_ITANG  328      /* U   Italic angle 2 bytes (1/256th deg)       */ 
#define  FH_ORUPM  330      /* U   Number of ORUs per em  2 bytes           */ 
#define  FH_WDWTH  332      /* U   Width of Wordspace  2 bytes              */ 
#define  FH_EMWTH  334      /* U   Width of Emspace  2 bytes                */ 
#define  FH_ENWTH  336      /* U   Width of Enspace  2 bytes                */ 
#define  FH_TNWTH  338      /* U   Width of Thinspace  2 bytes              */ 
#define  FH_FGWTH  340      /* U   Width of Figspace  2 bytes               */ 
#define  FH_FXMIN  342      /* U   Font-wide min X value  2 bytes           */ 
#define  FH_FYMIN  344      /* U   Font-wide min Y value  2 bytes           */ 
#define  FH_FXMAX  346      /* U   Font-wide max X value  2 bytes           */ 
#define  FH_FYMAX  348      /* U   Font-wide max Y value  2 bytes           */ 
#define  FH_ULPOS  350      /* U   Underline position 2 bytes               */ 
#define  FH_ULTHK  352      /* U   Underline thickness 2 bytes              */ 
#define  FH_SMCTR  354      /* U   Small caps transformation 6 bytes        */ 
#define  FH_DPSTR  360      /* U   Display sups transformation 6 bytes      */ 
#define  FH_FNSTR  366      /* U   Footnote sups transformation 6 bytes     */ 
#define  FH_ALSTR  372      /* U   Alpha sups transformation 6 bytes        */ 
#define  FH_CMITR  378      /* U   Chemical infs transformation 6 bytes     */ 
#define  FH_SNMTR  384      /* U   Small nums transformation 6 bytes        */ 
#define  FH_SDNTR  390      /* U   Small denoms transformation 6 bytes      */ 
#define  FH_MNMTR  396      /* U   Medium nums transformation 6 bytes       */ 
#define  FH_MDNTR  402      /* U   Medium denoms transformation 6 bytes     */ 
#define  FH_LNMTR  408      /* U   Large nums transformation 6 bytes        */ 
#define  FH_LDNTR  414      /* U   Large denoms transformation 6 bytes      */ 
                            /*     Transformation data format:              */ 
                            /*       Y position 2 bytes                     */ 
                            /*       X scale 2 bytes (1/4096ths)            */ 
                            /*       Y scale 2 bytes (1/4096ths)            */ 
#define  SIZE_FW FH_LDNTR + 6  /* size of nominal font header */ 
#define  EXP_FH_METRES SIZE_FW /* offset to expansion field metric resolution (optional) */ 

