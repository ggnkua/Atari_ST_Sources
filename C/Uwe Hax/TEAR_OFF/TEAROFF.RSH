
#define FLAGS9  0x0200
#define FLAGS10 0x0400

OBJECT rs_object[] =
{ 
  /******** Tree 0 MENU ****************************************************/
        -1,        1,        5, G_IBOX    ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0000, 0x0050, 0x0019,
         5,        2,        2, G_BOX     ,   /* Object 1  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0050, 0x0201,
         1,        3,        4, G_IBOX    ,   /* Object 2  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0002, 0x0000, 0x000D, 0x0301,
         4,       -1,       -1, G_TITLE   ,   /* Object 3  */
  NONE, NORMAL, (LONG)" Demo",
  0x0000, 0x0000, 0x0006, 0x0301,
         2,       -1,       -1, G_TITLE   ,   /* Object 4  */
  NONE, NORMAL, (LONG)" Datei",
  0x0006, 0x0000, 0x0007, 0x0301,
         0,        6,       15, G_IBOX    ,   /* Object 5  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0301, 0x0050, 0x0017,
        15, ABOUT   ,       14, G_BOX     ,   /* Object 6  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0002, 0x0000, 0x0013, 0x0008,
         8,       -1,       -1, G_STRING  ,   /* Object 7 ABOUT */
  NONE, NORMAL, (LONG)"  Programminfo...  ",
  0x0000, 0x0000, 0x0013, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, DISABLED, (LONG)"-------------------",
  0x0000, 0x0001, 0x0013, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, NORMAL, (LONG)"  Desk Accessory 1 ",
  0x0000, 0x0002, 0x0013, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"  Desk Accessory 2 ",
  0x0000, 0x0003, 0x0013, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, NORMAL, (LONG)"  Desk Accessory 3 ",
  0x0000, 0x0004, 0x0013, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"  Desk Accessory 4 ",
  0x0000, 0x0005, 0x0013, 0x0001,
        14,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, NORMAL, (LONG)"  Desk Accessory 5 ",
  0x0000, 0x0006, 0x0013, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"  Desk Accessory 6 ",
  0x0000, 0x0007, 0x0013, 0x0001,
         5, TEXT1   , QUIT    , G_BOX     ,   /* Object 15  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0008, 0x0000, 0x000A, 0x0007,
  TEXT2   ,       -1,       -1, G_STRING  ,   /* Object 16 TEXT1 */
  NONE, NORMAL, (LONG)"  Text 1  ",
  0x0000, 0x0000, 0x000A, 0x0001,
  TEXT3   ,       -1,       -1, G_STRING  ,   /* Object 17 TEXT2 */
  NONE, NORMAL, (LONG)"  Text 2 ",
  0x0000, 0x0001, 0x000A, 0x0001,
  TEXT4   ,       -1,       -1, G_STRING  ,   /* Object 18 TEXT3 */
  NONE, NORMAL, (LONG)"  Text 3 ",
  0x0000, 0x0002, 0x000A, 0x0001,
  TEXT5   ,       -1,       -1, G_STRING  ,   /* Object 19 TEXT4 */
  NONE, NORMAL, (LONG)"  Text 4 ",
  0x0000, 0x0003, 0x000A, 0x0001,
        21,       -1,       -1, G_STRING  ,   /* Object 20 TEXT5 */
  NONE, NORMAL, (LONG)"  Text 5 ",
  0x0000, 0x0004, 0x000A, 0x0001,
  QUIT    ,       -1,       -1, G_STRING  ,   /* Object 21  */
  NONE, DISABLED, (LONG)"----------",
  0x0000, 0x0005, 0x000A, 0x0001,
        15,       -1,       -1, G_STRING  ,   /* Object 22 QUIT */
  LASTOB, NORMAL, (LONG)"  Ende   ",
  0x0000, 0x0006, 0x000A, 0x0001,
  
  /******** Tree 1 DIALOG ****************************************************/
        -1,        1, OK      , G_BOX     ,   /* Object 0  */
  FLAGS10, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0022, 0x080A,
  OK      ,        2,        4, G_BOX     ,   /* Object 1  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0003, 0x0001, 0x001C, 0x0806,
         3,       -1,       -1, G_STRING  ,   /* Object 2  */
  NONE, NORMAL, (LONG)"Demo-Programm f\201r",
  0x0005, 0x0001, 0x0011, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"Tear-Off-Men\201s",
  0x0006, 0x0802, 0x000E, 0x0001,
         1,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"(C) 1994 by Uwe Hax",
  0x0004, 0x0804, 0x0013, 0x0001,
         0,       -1,       -1, G_BUTTON  ,   /* Object 5 OK */
  SELECTABLE|DEFAULT|EXIT|LASTOB|FLAGS9|FLAGS10, NORMAL, (LONG)"OK",
  0x000C, 0x0808, 0x0009, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 MENU     */
  &rs_object[23]    /* Tree  1 DIALOG   */
};
