/* AV-Protokoll, erweiterte Definition vom 26.06.1995
   Genaue Beschreibung der Messages in der Dokumentation
   zu Thing (THING.HYP ab Version 0.54) */

#ifndef __vaproto__
#define __vaproto__

/* AES-Messages */

#define AV_PROTOKOLL      0x4700
#define VA_PROTOSTATUS    0x4701
#define AV_GETSTATUS      0x4703
#define AV_STATUS         0x4704
#define VA_SETSTATUS      0x4705
#define	AV_SENDKEY        0x4710
#define VA_START          0x4711
#define AV_ASKFILEFONT    0x4712
#define VA_FILEFONT       0x4713
#define AV_ASKCONFONT     0x4714
#define VA_CONFONT        0x4715
#define AV_ASKOBJECT      0x4716
#define VA_OBJECT         0x4717
#define AV_OPENCONSOLE    0x4718
#define VA_CONSOLEOPEN    0x4719
#define AV_OPENWIND       0x4720
#define VA_WINDOPEN       0x4721
#define AV_STARTPROG      0x4722
#define VA_PROGSTART      0x4723
#define AV_ACCWINDOPEN    0x4724
#define VA_DRAGACCWIND    0x4725
#define AV_ACCWINDCLOSED  0x4726
#define AV_COPY_DRAGGED   0x4728
#define VA_COPY_COMPLETE  0x4729
#define AV_PATH_UPDATE    0x4730
#define AV_WHAT_IZIT      0x4732
#define VA_THAT_IZIT      0x4733
#define AV_DRAG_ON_WINDOW 0x4734
#define VA_DRAG_COMPLETE  0x4735
#define AV_EXIT           0x4736
#define AV_STARTED        0x4738
#define VA_FONTCHANGED    0x4739
#define AV_XWIND          0x4740
#define VA_XOPEN          0x4741

/* Neue Messages seit dem 26.06.1995 */

#define AV_VIEW           0x4751
#define VA_VIEWED         0x4752
#define AV_FILEINFO       0x4753
#define VA_FILECHANGED    0x4754
#define AV_COPYFILE       0x4755
#define VA_FILECOPIED     0x4756
#define AV_DELFILE        0x4757
#define VA_FILEDELETED    0x4758
#define AV_SETWINDPOS     0x4759
#define VA_PATH_UPDATE    0x4760

/* Makros zum Testen auf Quoting */

#define VA_ACC_QUOTING(a) ((a) & 0x10)
#define VA_SERVER_QUOTING(a) ((a) & 0x40)

/* Objekttypen fuer VA_THAT_IZIT */

#define	VA_OB_UNKNOWN   0
#define VA_OB_TRASHCAN  1
#define VA_OB_SHREDDER  2
#define VA_OB_CLIPBOARD 3
#define VA_OB_FILE      4
#define VA_OB_FOLDER    5
#define VA_OB_DRIVE     6
#define VA_OB_WINDOW    7
#define VA_OB_NOTEPAD   8
#define VA_OB_NOTE      9

#endif