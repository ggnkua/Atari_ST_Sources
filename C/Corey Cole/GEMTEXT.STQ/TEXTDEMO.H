/*
 *  textdemo.h -- Definitions file for textdemo.c
 *      by Corey S. Cole
 *      Copyright 1986 ANTIC Publishing
 */

struct textBlock {              /*  Describes attributes of text line   */
        char    *textString;            /*  Pointer to text to display  */
        int     horPos;                 /*  Left edge of displayed line */
        int     vertPos;                /*  Top  edge of displayed line */
        int     lineWidth;              /*  Max width (for justifying)  */
        int     lineHeight;             /*  Max height (line leading)   */
        int     justFlag;               /*  Method of justification:    *
                                         *      0 = unjustified,        *
                                         *      1 = word spacing only,  *
                                         *      2 = char spacing only,  *
                                         *      3 = word and char space */
        int     horAlign;               /*  Horizontal alignment        */
        int     vertAlign;              /*  Vertical alignment          */
        int     rotation;               /*  Baseline rotation           */
        int     fontId;                 /*  Which typestyle to use      */
        int     pointSize;              /*  Point or Pixel Height       */
        int     pixelFlag;              /*  TRUE = Height is in Pixels  */
        int     effects;                /*  Special effects bit flags   */
        int     color;                  /*  Foreground color for text   */
        int     backColor;              /*  Background color            */
};

#define NULLBLOCK       (struct textBlock *) 0L

#define BI_PDATA(x)     (x)
#define BI_WB(x)        (x + 4)
#define BI_HL(x)        (x + 6)

#define TE_PTEXT(x)  (x)
#define TE_TXTLEN(x)  (x + 24)

#define MIN(a, b)       ((a <  b) ?  a : b)
#define MAX(a, b)       ((a >  b) ?  a : b)

#define ARROW           0
#define HOUR_GLASS      2
#define DESK            0
#define END_UPDATE      0
#define BEG_UPDATE      1

#define REPLACE         1               /*  Replace mode in VDI         */
#define TRANSPARENT     2               /*  Transparent mode in VDI     */
#define XOR_MODE        3               /*  Exclusive OR mode in VDI    */

/*
 *  Here are the numbers for all of the typestyles described in the
 *      GEM manual.  The catch is that only "SYSFONT", #1, is available
 *      on the Atari 520ST.  These are included for IBM PC users, and
 *      for later experimentation with fonts.
 */
#define SYSFONT         1               /*  System monospace font       */
#define SWISSMED        2               /*  Swiss medium Roman font     */
#define SWISSFONT       SWISSMED
#define SWLTITAL        5               /*  Swiss light italic font     */
#define SWISSLIGHT      6               /*  Swiss light Roman font      */
#define SWISSITAL       7               /*  Swiss medium italic font    */
#define SWISSBOLD       8               /*  Swiss bold Roman font       */
#define SWBOLDITAL      9               /*  Swiss bold italic font      */
#define DUTCHMED        14              /*  Dutch medium Roman font     */
#define DUTCHFONT       DUTCHMED
#define DUTCHITAL       15              /*  Dutch medium italic font    */
#define DUTCHBOLD       16              /*  Dutch bold Roman font       */
#define DUBOLDITAL      17              /*  Dutch bold italic font      */

#define NOJUST          0               /*  Don't justify strings       */
#define CHARJUST        1               /*  Justify with char-spacing   */
#define WORDJUST        2               /*  Justify with word-spacing   */
#define FULLJUST        3               /*  Use word and char-spacing   */

#define LEFT            0               /*  Left-align strings          */
#define CENTER          1               /*  Center-align strings        */
#define RIGHT           2               /*  Right-align strings         */

#define BASELINE        0               /*  Display on baseline         */
#define HALFLINE        1               /*  "Half-line" for superscript */
#define ASCENT          2               /*  "Ascent line" (top of char) */
#define BOTTOM          3               /*  "Bottom" of text line       */
#define DESCENT         4               /*  "Descent" for subscript     */
#define TOPALIGN        5               /*  Top-aligned                 */

#define EFF_NONE        0               /*  No special effects used     */
#define EFF_BOLD        1               /*  "Thickened" special effect  */
#define EFF_LIGHT       2               /*  "Light intensity" effect    */
#define EFF_SKEWED      4               /*  "Skewed" italic effect      */
#define EFF_UNDLIN      8               /*  "Underlined" special effect */
#define EFF_OUTLINE     16              /*  "Outlined" special effect   */
#define EFF_SHADOW      32              /*  "Shadowed" special effect   */

#if MC68K
typedef struct memform
{
        long    mp;
        int     fwp;
        int     fh;
        int     fww;
        int     ff;
        int     np;
        int     r1;
        int     r2;
        int     r3;
} MFDB;
#endif

