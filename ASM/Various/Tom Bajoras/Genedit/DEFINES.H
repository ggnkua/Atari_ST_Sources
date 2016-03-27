/******************************************************************************

                                     GenEdit
                                       by
                                   Tom Bajoras

                         Copyright 1990/1991 Tom Bajoras

   defined constants and macros

******************************************************************************/

	/* conditional compiles */
#define DEMOFLAG 1	 /* disk, main */
#define PROTFLAG 0	 /* main,protect (and make sure tran_byte works) */
#define MULTIFLAG 1	 /* multi */
#define MONITORFLAG 1 /* monitor */
#define MACROFLAG	1	 /* macro */
#define TEMFLAG 1		 /* tem, temedit, temdraw, temmodfy, temregn, edit1/2/3 */
#define EBDTFLAG 1	 /* ebdt */
#define HSWFLAG 1		 /* hsw */
#define DISKFLAG 1	 /* disk */
#define CNXFLAG 1		 /* cnx, cnxinter, cnxedit, cnxtoken, cnftocnx */
#define EDITFLAG 1	 /* edit1/2/3 */

   /* Initialization error messages */
#define BADINIT   "[1][Cannot initialize|this application.][Abort]"
#define BADRSRC   "[1][Cannot load resource file.][Abort]"
#define BADREZ    "[1][Cannot run in this resolution.][Abort]"
#define BADWIND   "[1][Cannot open this|application's window.][Abort]"
#define BADMEM    "[1][Not enough memory!][Abort]"
#define BADSCR		"[1][Cannot load screen file.][Abort]"

	/* disk i/o error messages */
#define BADDEL1   "[1][Cannot delete file|"
#define BADDEL2   "][Cancel]"
#define BADFMT    "[1][Disk formatting has failed.][Cancel]"
#define BADFMT2   "[1][Disk formatting aborted.][OK]"
#define BADCREAT1 "[1][Cannot create file|"
#define BADCREAT2 "][Cancel]"
#define BADWRITE  "[1][Disk is full!  File was |written incompletely.   |\
Warning:  File might not|be usable.][Keep|Discard]"
#define BADOPEN1  "[1][Cannot open file|"
#define BADOPEN2  "][Cancel]"
#define BADREAD1  "[1][Cannot read file "
#define BADREAD2	"|or it is the wrong kind|of file.][Cancel]"
#define BADNBLOCKS "[1][This data file contains more|\
than 99 blocks!  How can you|afford so many instruments?|\
Choose from the first 99.][Give me some]"
#define BADCREDIR1 "[1][Cannot create folder|"
#define BADCREDIR2 "][Cancel]"
#define BADDELDIR1 "[1][Cannot delete folder|"
#define BADDELDIR2 "][Cancel]"
#define BADRENAME1 "[1][Cannot change name to|"
#define BADRENAME2 "][Cancel]"
#define BADVERSION "[1][Cannot load this file:|Version too high.][Cancel]"
#define BADGENPMLT "[1][Cannot load a GenPatch|multi-block file.][Cancel]"
#define BADNONGFIL "[1][Cannot load this file:|Unknown file format.][Cancel]"
#define BADSENDCNX "[1][Block contains|no configuration!][Don't Send]"
#define BADSENDDAT "[1][Block contains|no data!][Don't Send]"

	/* converting GenPatch data file to GenEdit data file */
#define BADINSTR "[1][Configuration file contains|unknown commands.  Not|\
a GenPatch file?][Cancel]"
#define BADNVARS "[1][Configuration file requires|too many variables!]\
[Cancel]"

	/* other error messages */
#define BADPRINT "[1][Printer is not responding.|Make sure its power is on,|\
and that it is connected|and on line.][Retry|Cancel]"
#define BADMEM2  "[1][You do not have enough memory|to do whatever you're|\
trying to do right now.][Try later]"
#define BADMEM3  "[1][Something too awful to|\
describe has just happened.|If I were you I'd save all|\
files and get the heck|out of here.][Yikes!]"
#define BADOVFL  "[1][MIDI overrun error!][Abort]"
#define BADNAME  "[1][Illegal file name.][Try again]"
#define BADSCALE "[1][Illegal scaling amount(s).|All numbers must be 1-99.]\
[Try again]"
#define BADACCESS	"[1][A desk accessory has stolen|memory.  Suggest you quit|\
now, find the offender and|drag him to the trash can.][Good Idea]"
#define BADNONG1	"[1][Cannot find SysEx data.][Cancel]"
#define BADNONG2	"[1][Header + data cannot|exceed total.][Try again]"
#define BADNONG3	"[1][Data length cannot|be zero.][Try again]"
#define BADPATH	"[1][Path cannot exceed 40|characters, including drive,|\
colon, and all backslashes.][Cancel]"
#define BADVALRNGE "[1][Bad value range:  Low must|be less than high, and|\
each must be between|-32768 and 32767.][Try Again]"
#define BADSNAPVAL "[1][Bad snap value:|Must be 02-99.][Try Again]"
#define BADEDLENG "[1][This control is too|complicated to be edited.][Sorry]"
#define BADAPPSTRG "[1][Not enough memory.|Some strings were lost.][Sorry]"
#define BADSTRGED "[1][Text list overflow][Cancel]"
#define BADMLXDEL "[1][This Multi-Block file contains|only one block.  Cannot|\
delete it.][Cancel]"
#define BADNEDIT "[1][No more than 1 patch can|be selected for editing.]\
[Cancel]"
#define BADNRECORD "[1][Record buffer overflowed!][Keep|Discard]"
#define BADEBDTLENG "[1][Template and Data|are incompatible.][Cancel]"
#define BADIMPEBDT "[1][Bad file format.  Each|line should be:  Name/|\
Length/Offset/Low/High][Cancel]"
#define BADIMPTEXT "[1][Cannot import text|file longer than|\
8000 bytes.][Cancel]"
#define BADNEBDT "[1][Too many EBDT entries!|Keep as many as will fit.][OK]"
#define BADNAVER "[1][To be able to average,|you must select no more|\
than 16 patches and no|less than 2.][Cancel]"
#define BADEDSEND "[1][Edit buffer corrupted!|Template and Data|\
are incompatible.][Cancel]"
#define BADMATCH1 "[1]["
#define BADMATCH2 " requires an|EDITING configuration.][Cancel]"
#define BADDUPLIC "[1][Cannot compare these windows:| |\
- Names different length, or|- Patches different length, or|\
- Names different offset][Cancel]"
#define DUPLICTYPE "[2][Determine duplicate patches|by comparing Patch Names|\
and/or Patch Data:][Names|Data|Both]"
#define BADMULTVAL "[1][Warning:  One or more of|the selected controls has|\
multiple values.][Skip them]"
#define BADLEARN1 "[1][Can only teach one|control at a time.][Cancel]"
#define BADLEARN2 "[1][Error while learning][Cancel]"
#define BADLEARN3 "[1][To be taught, a control|must have exactly one|\
value.][Cancel]"
#define BADHIV1 "[1]["
#define BADHIV2 " bad controls found|on this page.][Ignore|Fix]"
#define BADDEVCNX1 "[1][Wrong configuration for this|device!][Find "
#define BADDEVCNX2 " |Cancel]"

	/* CNX interpreter */
#define BADCNXCMD	"[1][Unknown CNX command!][Abort|Skip it]"
#define BADLABEL	"[1][Undefined label!][Abort|Skip it]"
#define BADDIVZERO "[1][Division by zero!][Abort|Skip it]"
#define BADLOOP	 "[1][Loop without EndLoop!][Abort]"
#define BADLOOPO	 "[1][Loop nesting overflow!][Abort]"
#define BADLOOPU	 "[1][Loop nesting underflow!][Abort]"
#define BADEXITLP	"[1][ExitLoop not inside|loop!][Abort|Skip it]"
#define BADCURSX	"[1][Bad text column!|Must be 0-37][Abort|Skip it]"
#define BADCURSY	"[1][Bad text row!|Must be 0-11][Abort|Skip it]"
#define BADSTACKO	"[1][Subroutine stack|overflow.][Abort|Skip it]"
#define BADSTACKU	"[1][Subroutine stack|underflow.][Abort|Skip it]"
#define BADPEEKD	"[1][Attempt to peek beyond|end of data buffer.]\
[Abort|Skip it]"
#define BADPOKED	"[1][Attempt to poke beyond|end of data buffer.]\
[Abort|Skip it]"
#define BADPEEKP	"[1][Attempt to peek beyond|end of edit buffer.]\
[Abort|Skip it]"
#define BADPOKEP	"[1][Attempt to poke beyond|end of edit buffer.]\
[Abort|Skip it]"
#define BADPEEKT	"[1][Attempt to peek beyond|end of table.][Abort|Skip it]"
#define BADPOKESIZ "[1][Poke value is too|large for poke size.][Abort|Skip it]"
#define BADNPNUMS	 "[1][Too many banks!][Abort|Skip it]"
#define BADNPATS	 "[1][Too many patches|in a bank!][Abort|Skip it]"
#define BADTABLENG "[1][Table overflow.  Combined|table lengths cannot|\
exceed 4096 bytes.][Abort|Skip it]"
#define BADTABLNUM "[1][Bad table number.|Must be 1-16.][Abort|Skip it]"
#define BADTABLECLR "[1][Attempt to peek from|an empty table.][Abort|Skip it]"
#define BADVARPTR	"[1][Data buffer pointer cannot|\
exceed data buffer length.][Abort]"
#define BADEXECUTE "[1][Execute subroutine not|found.][Abort|Skip it]"
#define CHEKSTOP3 "[2][Key interrupt.  What do you|want to do?]\
[Stop|Continue|Exit Loop]"
#define CHEKSTOP2 "[2][Key interrupt.  What|do you want to do?]\
[Stop|Continue]"
#define CHEKOVFL3 "[2][Data buffer overflowed.  What|do you want to do?     ]\
[ Stop | Continue | Exit Loop ]"
#define CHEKOVFL2 "[2][Data buffer overflowed.  What|do you want to do?     ]\
[ Stop | Continue ]"
#define CHEKUNFL3 "[2][Ran out of data.  What do you|want to do?]\
[Stop|Continue|Exit Loop]"
#define CHEKUNFL2 "[2][Ran out of data.  What|do you want to do?]\
[Stop|Continue]"

	/* warning messages */
#define CHEKDEMO "[1][GenEdit demo version.|File saving is disabled.][Demo Me]"
#define CHEKDEL1  "[3][Delete file "
#define CHEKDEL2  " ?][Delete|Cancel]"
#define CHEKDELF1 "[3][Delete folder "
#define CHEKDELF2 " ?][Delete|Cancel]"
#define CHEKMINIT "[3][Clear all macros?][Clear|Cancel]"
#define CHEKCINIT	"[3][Clear all configurations?][Clear|Cancel]"
#define CHEKTINIT "[3][Clear template?][Clear|Cancel]"
#define CHEKREPL1 "[3][File "
#define CHEKREPL2 " already|exists.  What do you want|to do with it?]\
[Replace|Backup|Cancel]"
#define CHEKCLRLW "[3][Clear the left window?][Clear|Cancel]"
#define CHEKCLRRW "[3][Clear the right window?][Clear|Cancel]"
#define CHEKPRTWND "[2][Print which window?][Cancel|Left|Right]"
#define CHEKCLRCNX "[3][Clear all CNX code|in this window?][Clear|Cancel]"
#define CHEKUNDCNX "[3][Undo all changes|in this window?][Undo|Cancel]"
#define CHEKCLRCLIP "[3][Clear clipboard?][Clear|Cancel]"
#define CHEKKEEP  "[2][Received data may|be incomplete.][Keep|Discard]"
#define CHNGECNX	"[2][Changes have been made|to the current configuration|\
bank.  Lose these changes?][OK|Cancel]"
#define CHNGEMAC	"[2][Changes have been made|to the current macros.  Lose|\
these changes?][OK|Cancel]"
#define CHNGELDAT	"[2][Changes have been made|to the left window data.|\
Lose these changes?][OK|Cancel]"
#define CHNGERDAT	"[2][Changes have been made|to the right window data.|\
Lose these changes?][OK|Cancel]"
#define CHNGETEM	"[2][Changes have been made|to the template.  Lose|\
these changes?][OK|Cancel]"
#define CHNGESTU	"[2][Changes have been made to|the current studio setup.|\
Lose these changes?][OK|Cancel]"
#define CHEKTOFIT "[3][Fit all controls already|on this page?][OK|Cancel]"
#define CHEKCNXDIF "[3][Window configurations are|different.  This operation|\
might not make sense.|Proceed with caution.][Go for it|Chicken out]"
#define CHEKDEVDIF "[3][This seems to be the wrong|\
configuration for this device.|Proceed with caution.][Go for it|Chicken out]"
#define UNDOEBDT "[3][Undo all changes|to the EBDT?][Undo|Cancel]"
#define INITEBDT "[3][Clear the EBDT?][Clear|Cancel]"
#define PACKEBDT "[3][Packing the EBDT removes|spaces between parameters|\
and eliminates overlap.|Start packing at:][Start|Cursor|Cancel]"
#define CHEKRAW  "[2][Export raw data from|which window?][Cancel|Left|Right]"
#define CHEKRAWTYP "[2][Export as...][Binary|ASCII]"
#define CHEKINFO "[2][Device info for which window?][Cancel|Left|Right]"
#define CHEKSORTWND "[2][Sort patches in which window?][Cancel|Left|Right]"
#define CHEKSNAP "[3][Snap all controls|on this page?][Snap|Cancel]"
#define CHEKCLRPAGE "[3][Delete all controls|on this page?][Delete|Cancel]"
#define MUSTSCALE "[3][This template was created with|\
a different resolution than|the current one.  It will be|\
scaled automatically, but some|manual editing may be needed.][Scale it]"
#define CHEKCLRTEXT "[3][Clear this text list?][Clear|Cancel]"
#define CHEKCPPGE1 "[3][Copy this page|to page "
#define CHEKCPPGE2 " ?][OK|Cancel]"
#define CHEKCREMLX "[3][This Multi-Block file does|not exist.  Create it?]\
[OK|Cancel]"
#define CHEKSEQ "[3][Record over the existing|sequence?][OK|Cancel]"
#define CHEKEDIT "[3][Changes have been made to the|\
edit buffer.  What do you want|to do with these changes?][Keep|Discard|Cancel]"
#define CHEKUNDO "[3][Undo all changes|to edit buffer?][Undo|Cancel]"
#define CHEKRESIZE "[3][Shrinking the window can cause|\
data to be lost permanently!][Lose Data|Cancel]"
#define CHEKEBDTHL "[3][Template and edit buffer don't|\
match.  Continuing may corrupt|data.  Select OK with caution.][OK|Skip|Cancel]"
#define CHEKRPLEBDT "[3][Replace the EBDT,|or append to it?][Replace|Append]"
#define CHEKAVER "[3][More than 16 patches are|selected.  Only the first|\
16 will be averaged.][OK|Cancel]"
#define CHEKTEMGLOB "[0][When editing, auto-sending|will default to:]\
[On|Off|Disabled]"
#define CHEKMLXBREAK "[3][Send the rest of|the blocks?][Stop|Send]"
#define CHEKSYNC "[1][No sync box connected!|Select IGNORE only if|\
a key disk is in drive A.][Retry|Ignore|Quit]"
#define CHEKKEYDISK "[1][Insert key disk in|drive A.][Retry|Abort]"
#define CHEKMATCH1 "[1][Window is linked to template|"
#define CHEKMATCH2 ".  Current template|is "
#define CHEKMATCH3 ".  Use which?][Linked|Current|Cancel]"
#define CHOOSEDUPLIC "[3][Duplicate patches found.  How|\
do you want to rename them?][Link Names|Init Names|Cancel]"
#define NODUPLIC "[3][No duplicate patches found.][OK]"
#define CHEKSHFTCLP "[2][Cannot shift EBDT links|beyond start or end|\
of EBDT.  What do you|want to do with out|of range links?][Skip|Clip]"
#define CHEKQUIT "[3][Are you SURE you|want to quit?][Quit|Cancel]"
#define CHEKCLRST1  "[3][Clear info for this device?][Clear|Cancel]"
#define CHEKCPYDV	"[3][Copy device?][OK|Cancel]"
#define BADDEVCNX1 "[1][Wrong configuration for this|device!][Find "
#define BADDEVCNX2 " |Cancel]"

	/* file names */
#define SCRMFILE	"GENEDIT.PI3"	/* monochrome screen */
#define SCRCFILE	"GENEDIT.PI2"	/* color screen */
#define RSRCFILE	"GENEDIT.RSC"	/* GEM resource */
#define CDRFILE	"GENEDIT.CDR"	/* code resource */
#define INFFILE1	"GENEDIT.INF"	/* auto-loaded preferences */
#define INFFILE2	"AUTOLOAD.INF"	/* auto-loaded preferences */
#define STUFILE1	"GENEDIT.STU"	/* auto-loaded studio setup */
#define STUFILE2	"AUTOLOAD.STU"	/* auto-loaded studio setup */
#define AUTOFILE	"AUTOLOAD."		/* auto-load file without extension */

	/* mouse icons */
#define ARROWMOUSE 0
#define TEXTMOUSE 1
#define BEE_MOUSE 2
#define POINTMOUSE 3
#define HANDMOUSE 4
#define CROSSMOUSE 5

	/* hide/show mouse (line A) */
#define HIDEMOUSE asm { move.l a2,-(a7) dc.w 0xA00A move.l (a7)+,a2 }
#define SHOWMOUSE { intin[0]=1; \
						  asm { move.l a2,-(a7) dc.w 0xA009 move.l (a7)+,a2 } }

	/* memory manager */
#define NHEAPBLKS 64					/* number of heap memory block handles */
#define NMEMBLKS (2*NHEAPBLKS+1)	/* big enough for maximum fracture */
#define MAXHEAPSIZE (512*1024L)	/* largest single heap block */

	/* lengths */
#define GEMMEM 3788L					/* how much memory to leave for system */
#define SCRLENG 32000L				/* screen */
#define MACRLENG (30L*NMACROS)	/* not counting magic long and index table */
#define MAXLENG (MACRLENG+8L+(2L*NMACROS))	/* bytes in MAX file */
#define MACLENG 828L									/* bytes in MAC file */
#define INFLENG 1000L				/* bytes in INF file (oversized) */
#define MAXNAMLENG 76L				/* maximum patch name length */
#define MAXNBLOCKS 99				/* maximum # blocks in a data file */
#define MAXNPATS 1024L				/* maximum # patches per bank */
#define MAXNBANKS 16L				/* maximum # banks per window */
#define MAXNAVER 16					/* maximum # of patches to be averaged */
#define NMACROS 36					/* number of macros */
#define MACBINLENG 128L				/* Mac file header */
#define NDEVICES 60					/* number of devices per studio setup */
#define NDEVPERSCR 10				/* number of devices displayable on screen */

	/* main screen layout */
#define NHOTSPOTS 4								/* # of draggable things */
#define H_DRIVE 0									/* hot spots idexes */
#define H_LWIND 1
#define H_RWIND 2
#define H_MIDI  3

	/* generated names */
#define RANDNAME "RANDOM "
#define AVERNAME "AVERAGE"

	/* CNX */
#define NCNF 16						/* # CNF's per CNF file */
#define NCNX 63						/* maximum # CNX's per CNX file */
#define NCHPERCNX 20					/* # characters per CNX name (no null term) */
#define NCNXCOLS 3					/* # columns in CNX list dialog box */
#define NCNXICONS 6					/* # icons in CNX list dialog box */
#define NCNXHOT (NCNX+NCNXICONS)	/* # hot spots in CNX list dialog box */
#define CNXTOKENW 128L				/* max chars per line of cnx source code */
#define NSEGTYPES 10					/* this may increase !!! */
#define cnxTRAN 0L					/* code segment i.d.'s */
#define cnxRECV 1L
#define cnxDTOE 2L
#define cnxETOD 3L
#define cnxSEND 4L
#define cnxINIT 5L
#define cnxGETP 6L
#define cnxPUTP 7L
#define cnxVLDT 8L
#define cnxCMMN 9L
#define cnxCNST -1L					/* non-code segment i.d.'s */
#define NLABELS 100					/* # of labels in CNX language */
#define NVARS 256						/* # of variables in CNX language */
#define VAR_PAT 100					/* dedicated read-write variables */
#define VAR_CHN 101
#define VAR_PTR 102
#define VAR_NMO 104
#define VAR_NML 105
#define VAR_EBL 106
#define VAR_ERR 107
#define VAR_DLN 200					/* dedicated read-only variables */
#define VAR_ELN 201
#define VAR_LPO 202
#define VAR_LPV 203
#define VAR_DUM 255					/* dummy variable */
#define NCNXCMDS 52					/* # of commands in CNX language */
#define UNKNOWNCMD ";----- Unknown Command -----"
	/* commands */
#define GE_NOP 0
#define GE_INVERT	1
#define GE_NEG 2
#define GE_NOT 3
#define GE_ASSIGN 4
#define GE_LOGIC 5
#define GE_REL 6
#define GE_GOTO 7
#define GE_GOSUB 8
#define GE_EXITLOOP 9
#define GE_RETURN 10
#define GE_SPEED 11
#define GE_FILTER 12
#define GE_SETPORT 13
#define GE_RECVDATA 14
#define GE_TRANDATA 15
#define GE_PEEKDATA 16
#define GE_POKEDATA 17
#define GE_RECEIVE 18
#define GE_TRANSMIT 19
#define GE_GETKEY 20
#define GE_OPENWIND 21
#define GE_CLOSEWIND 22
#define GE_CLRWIND 23
#define GE_PRINT 24
#define GE_PRNTVAR 25
#define GE_CLRLINE 26
#define GE_INPUT 27
#define GE_GETPATCH 28
#define GE_GETCHAN 29
#define GE_BELL 30
#define GE_GETPORT 31
#define GE_ENDLOOP 32
#define GE_POKEPATCH 33
#define GE_PEEKPATCH 34
#define GE_PATCHNUM 35
#define GE_TIME 36
#define GE_STOP 37
#define GE_ASM 38
#define GE_LABEL 39
#define GE_EVENT 40
#define GE_TRANVAR 41
#define GE_COMMENT 42
#define GE_RECVANY 43
#define GE_LOOP 44
#define GE_DTOD 45
#define GE_DTOP 46
#define GE_PTOD 47
#define GE_PTOP 48
#define GE_BUILDTAB 49
#define GE_PEEKTABLE 50
#define GE_EXECUTE 51

	/* field types */
#define FT_EQUAL	0
#define FT_STRING	1
#define FT_ASCII	2
#define FT_HEX		3		/* constvar = FT_HEX or FT_DEC or FT_VAR */
#define FT_DEC		4
#define FT_VAR		5
#define FT_LABEL	6
#define FT_LETTER	7
#define FT_MATH	8
#define FT_LOGIC	9
#define FT_REL		10
#define FT_IF		11
#define FT_BIN		12
#define FT_CMD0	13		/* command # = field type - FT_CMD0 */

	/* CNF commands */
#define GP_SENDSENT 0x80
#define GP_BYTEINPUT 0x11
#define GP_BYTEINCR 0x12
#define GP_SENDCHAN 0x13
#define GP_SENDDATA 0x14
#define GP_RECVDATA 0x24
#define GP_RECVSENT 0x90
#define GP_RECVANY 0x21
#define GP_WAIT 0x30
#define GP_LOOP 0x31
#define GP_ENDLOOP 0x32

	/* C constructs */
#define abs(a)	((a)>0?(a):-(a))				/* absolute value */
#define max(a,b)	((a)>(b)?(a):(b))			/* max of 2 values */
#define min(a,b)	((a)<(b)?(a):(b))			/* min of 2 values */
#define BITTEST(A,B) ( 1 & (B>>A) )			/* 0 or 1 */
#define BITSET(A,B)  ( (B) |= (1<<(A)) )
#define BITCLR(A,B)  ( (B) &= ~(1<<(A)) )
#define QUOTE 0x27		/* asci single quote */
#define DQUOTE 0x22		/* asci double quote */
#define PI 3.141592654	/* for trig functions */

	/* asm extensions */
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
#define SP A7
#define sp A7
#define illegal dc.w 0x4afc

	/* language-dependent text */
#define DEL_TITL "Delete File:"
#define MSAVTITL "Save Macro File:"
#define MLDETITL "Load Macro File:"
#define TSAVTITL "Save Template File:"
#define TLDETITL "Load Template File:"
#define CSAVTITL "Save Configuration File:"
#define CLDETITL "Load Configuration File:"
#define RLDE_TITL "Load Data File into Right Window:"
#define LLDE_TITL "Load Data File into Left Window:"
#define RSVE_TITL "Save Data File from Right Window:"
#define LSVE_TITL "Save Data File from Left Window:"
#define RRAW_TITL	"Export raw data from Right Window:"
#define LRAW_TITL	"Export raw data from Left Window:"
#define MSVE_TITL "Save Data File from MIDI:"
#define MLDE_TITL "Send Data File to MIDI:"
#define DSK2DVTITL "Send Data File to Device: "
#define QSAVTITL	"Save Sequencer File:"
#define QLDETITL	"Load Sequencer File:"
#define CREDIRTITL "Create Folder:"
#define DELDIRTITL "Delete Folder:"
#define RENFRMTITL "File to be renamed:"
#define RENTOTITL	 "Change file's name to:"
#define COPYFRMMSG "Copy FROM File:"
#define COPYTOMSG	 "Copy TO File:"
#define FINDCNXMSG "Where are the configuration files?"
#define FINDMACMSG "Where are the macro files?"
#define FINDTEMMSG "Where are the template files?"
#define FINDLDATMSG "Where are the data files for the left window?"
#define FINDRDATMSG "Where are the data files for the right window?"
#define FINDMIDIMSG "Where are the data files for Disk <--> MIDI ?"
#define FINDMULTMSG "Where are the multi-block files?"
#define ACTIVE_MSG "\
<-- Receiving   << Press Control-A to Abort >>   Transmitting -->"
#define CNXINFO1_MSG "<-- Receiving   << Sending data from "
#define CNXINFO2_MSG " >>   Transmitting -->"
#define INFLTITL	"Load Preferences from file:"
#define INFSTITL	"Save Preferences to file:"
#define STULDTITL "Load Studio Setup from file:"
#define STUSVTITL "Save Studio Setup to file:"
#define IMPCNXEMSG "Import clipboard from text file:"
#define EXPCNXEMSG "Export clipboard to text file:"
#define IMPTEXTMSG "Import text list from text file:"
#define LINKCNXMSG "Link this Configuration to Template File:"
#define IMPEBDTMSG "Import EBDT from text file:"
#define EXPEBDTMSG "Export EBDT to text file:"
#define EBDT_TITL "Edit Buffer Definition Table (EBDT)"
#define CMT_MSG  "\
Press <C> for Configurations, <M> for Macros, <T> for Template"
#define DRAG_MSG	"\
 to Disk,  to MIDI,  to Left Window,  to Right Window, 0-9 to Devices"
#define FMT_MSG	"Formatting track "
#define FMT2_MSG	" Press either mouse button to abort"
#define BADTOKENMSG "Bad line of CNX code -- Press a key"
#define UNDEFPFMT "Undefined Patch Format"
#define SHOWCLPMSG " bytes on the clipboard -- Press a key"
#define NAMEPATMSG "Name patch "
#define EXIT_MSG "Exit"
#define CAN_MSG "Cancel"
#define IF_MSG "If "
#define CHOOSECNXMSG "Select a Configuration:"
#define MONI_MSG "\
     <Tab> = Pause , <Return> or <Esc> = Exit , <Clr/Home> = Clear Screen      "
#define MONIPMSG "\
  <Tab> = Continue , <Return> or <Esc> = Exit , <Clr/Home> = Clear Screen      "
#define MONI_MSG2 "\
                                                                               "
#define MONIPMSG2 "\
                                  << PAUSED >>                                 "
#define OVFL_MSG "\
           MIDI input buffer overflowed!  Press a key to continue.             "
#define RUNNGMSG "Last status byte received: "
#define NSYSXMSG "Length of last SysEx message: "
#define MFINDMSG "Press a macro key (A-Z/1-9/0)."
#define CNXL_MSG "Configurations: "
#define NAME_MSG1 " Left Data Window "
#define NAME_MSG2 " Right Data Window "
#define EDIT_MSG	"Editing"
#define RAND_MSG	"Randomizing"
#define DIST_MSG	"Distorting"
#define AVER_MSG	"Averaging"
#define NOWPRINTMSG "Output to printer -- Press either mouse button to abort"
#define CNXECLPMSG "\
To Clipboard: <C> Copy, <X> Cut, either w/ <Shift> to Append, <Esc> to Cancel"
#define PACHPROMPT "Enter a patch number (001-128):"
#define CHANPROMPT "Enter a MIDI channel (01-16):"
#define UNDOPROMPT "Return= OK, Undo= Cancel, Esc= Clear"
#define UNDOPRMPT2 "Left Button: OK, Right Button: Cancel"
#define KNOB_MSG " Knob "
#define SLIDER_MSG " Slider "
#define NUMBER_MSG " Number "
#define TEXT_MSG " Text "
#define IBUT_MSG " Independent Buttons "
#define CBUT_MSG " Combined Buttons "
#define MOMENTMSG "Momentary"
#define MINBUT1MSG "One must be selected"
#define TEM_MSG  "\
L=Add | R=Edit | <Shift>L=Move | <Ctrl>L=Copy | <Alt>L=Delete | <Shift>R=Size"
#define TEMR_MSG "\
L = select region | <Shift>L = (de)select control | R = edit region"
#define SLCTRGNMSG "Selecting region -- press <Alternate> to abort"
#define DELCTRLMSG "\
To confirm delete, press right button while still holding down left button"
#define COPYCTRLMSG "Copying a control -- press <Alternate> to abort"
#define MOVECTRLMSG "Moving a control -- press <Alternate> to abort"
#define SIZECTRLMSG "Resizing a control -- press <Alternate> to abort"
#define ADDCTRLMSG "Adding a control -- press <Alternate> to abort"
#define COPYPAGEMSG "Copy this page to another page"
#define GRPHPT_MSG " Envelope / Point "
#define JOY_X_MSG " Joystick X "
#define JOY_Y_MSG " Joystick Y "
#define ROW_MSG " Row "
#define COL_MSG " Column "
#define MLXXDATTITL "Save block to what data file?"
#define MLXRDATTITL "Replace with block from which data file?"
#define MLXREPTITL  "Replace block in which Multi-Block file?"
#define MLXNAMTITL  "Rename block in which Multi-Block file?"
#define MLXDATTITL  "Select data file containing block to be added:"
#define MLXADDTITL  "Add block to which Multi-Block file?"
#define MLXDELTITL  "Delete block from which Multi-Block file?"
#define MLXEXTTITL  "Extract block from which Multi-Block file?"
#define BLOCK2ADD "Select the block to be added:"
#define BLOCK2DEL "Select the block to be deleted:"
#define BLOCK2NAM "Select the block to be renamed:"
#define BLOCK2EXT "Select the block to be extracted:"
#define BLOCK2REP "Select the block to replace with:"
#define BLOCK2BRP "Select the block to be replaced:"
#define WHICHBLOCK "Select a block from Multi-Block file:"
#define RECORDMSG "\
Recording sequence -- Press a key or either mouse button to stop"
#define NOEDBUFMSG "(No Edit Buffer)"
#define NONGCNXNAME "Unknown Data Format "
#define CHOOSEPARM "Choose an edit buffer parameter:"
#define VAL_MSG "Edit Buffer= "
#define CONFIG_MSG "Configuration: "
#define SEG_MSG "Segment: "
#define CLAB_MSG "SoftLink"
#define MROS_MSG "MROS"
#define NEWBLOCKMSG "New Block Name:"
#define NONE_MSG "(none)"
#define SCALE_MSG "Scaling template..."
#define DELREG_MSG "Deleting controls..."
#define DELREGNMSG "\
Delete selected controls?  Return / Left Button = Yes, Esc / Right Button = No"
#define COPYREGNMSG "Drag to copy selected controls"
#define DUPEREGNMSG "Drag to duplicate selected controls"
#define MOVEREGNMSG "Drag to move selected controls"
#define COPYCTLSMSG "Copying controls -- press <Alternate> to abort"
#define DUPECTLSMSG "Duplicating controls -- press <Alternate> to abort"
#define MOVECTLSMSG "Moving controls -- press <Alternate> to abort"
#define COPY2PAGE "\
Press <1> - <8> for destination page number, <Esc> to Cancel"
#define TREGCHOOSE "Do what to selected controls?"
#define TYPECHOOSE "Change to Control Type:"
#define SHFTEBDTMSG " Shift EBDT Links by (number of entries): "
#define HMOVEMSG " Move Horizontal Amount: "
#define VMOVEMSG " Move Vertical Amount: "
#define HCOPYMSG " Copy Horizontal Amount: "
#define VCOPYMSG " Copy Vertical Amount: "
#define HDUPEMSG " Duplicate Horizontal Amount: "
#define VDUPEMSG " Duplicate Vertical Amount: "
#define CHFONT1MSG "Change Normal Font to Miniature Font? (Y/N)"
#define CHFONT2MSG "Change Miniature Font to Normal Font? (Y/N)"
#define COLRCHNGMSG "Change this color to... "
#define LEARNMSG "Learning from MIDI... Left Button: OK, Right Button: Cancel"
#define RANDOM_MSG "Randomizing patch(es)... Press either mouse button to abort"
#define DISTORT_MSG "Distorting patch(es)... Press either mouse button to abort"
#define SEND1_MSG "Send"
#define SEND2_MSG "SEND"
#define DEV_MSG "Device "
#define DEVLEFTMSG "Device Info for Left Window"
#define DEVRGHTMSG "Device Info for Right Window"
#define CNXCHKMSG1 "Checksum = "
#define CNXCHKMSG2 ", Size = "
#define CNXCHKMSG3 ", Press either mouse button to continue"

	/* addresses (including hardware) */
#define TESTACIA(a)	dc.w 0x0838,   a , 0xFC04
#define ENA_TRAN		dc.w 0x11FC, 0xB5, 0xFC04
#define DIS_TRAN		dc.w 0x11FC, 0x95, 0xFC04
#define READ_MIDI		dc.w 0x1038, 0xFC06
#define WRITEMIDI		dc.w 0x11C0, 0xFC06
#define HZ200			0x4BA

	/* MIDI */
#define END_OF_DATA -1				/* pads data buffer */
#define SUSTCTRL 64					/* hold/sustain pedal controller number */
#define midiNTOF 0x80			/* status bytes -- use throughout !!! */
#define midiNTON 0x90
#define midiPOLY 0xA0
#define midiCTRL 0xB0
#define midiPTCH 0xC0
#define midiCHPR 0xD0
#define midiBEND 0xE0
#define midiSOX  0xF0
#define midiSPTR 0xF2
#define midiSSEL 0xF3
#define midiTUNE 0xF4
#define midiEOX  0xF7
#define midiCLCK 0xF8
#define midiSTRT 0xFA
#define midiCONT 0xFB
#define midiSTOP 0xFC
#define midiACTV 0xFE
#define midiKILL 0xFF

	/* values for gr_color */
#define BL_ON_WH 0
#define WH_ON_BL 4
#define RD_ON_WH 8
#define WH_ON_RH 12
#define GR_ON_WH 16
#define WH_ON_GR 20
#define BL_ON_RD 24
#define RD_ON_BL 28
#define BL_ON_GR 32
#define GR_ON_BL 36

	/* indexes into change_flag */
#define ldatCHANGE 0
#define rdatCHANGE 1
#define cnxCHANGE 2
#define macrCHANGE 3
#define temCHANGE 4
#define stuCHANGE 5

	/* stuff in file header */
#define MACRMAGIC 'GENm'			/* MAX file */
#define MACRVERSION 1
#define CNXMAGIC  'GENc'			/* CNX file */
#define CNXVERSION 1					
#define TEMMAGIC  'GENt'			/* TEM file */
#define TEMVERSION 1
#define DATAMAGIC 'GENb'			/* data file */
#define DATAVERSION 1
#define CDRMAGIC 'GENr'				/* CDR file */
#define CDRVERSION 1
#define INFMAGIC 'GENi'				/* INF file */
#define INFVERSION 1
#define SQCMAGIC 'GENq'				/* SQC file */
#define SQCVERSION 1
#define STUMAGIC 'GENs'				/* STU file */
#define STUVERSION 2
#define MACHINE 1						/* Atari */
#define GENPMAGIC 0xDEADBEEFL		/* this was John Eidsvoog's idea */

	/* file record i.d.'s */
#define idCDR 37						/* code resource */
#define idCNX 8						/* configuration */
#define idCNXSEGS 12					/* configurations segments in data file */
#define idSQC 13						/* record in sequence file */
#define idGLOBDATA 9					/* global record in data file */
#define idDATA 10						/* data record in data file */
#define idEND -1						/* end of file */
#define idTEMPAGE0 0					/* first of 8:  0-7 */
#define idTEMEBDT 33
#define idTEMSTRG 34
#define idTEMGLOB 35

	/* constant names */
#define C_TEMLINK "TEMLINK"		/* in cnxCNST segment in CNX file */

	/* file extensions */
#define MAX_EXT	"MAX"				/* MAX file */
#define MAXC_EXT	"MA?"				/* MAX or MAC file */
#define CNX_EXT	"CNX"				/* CNX file */
#define CNXF_EXT	"CN?"				/* CNX or CNF file */
#define TEM_EXT	"TEM"				/* TEM file */
#define TE_EXT		"TE?"				/* TEM file with wildcard */
#define ALL_EXT	"*"				/* all files */
#define INF_EXT	"INF"				/* INF file */
#define RAW_EXT	"RAW"				/* raw data file */
#define MLX_EXT	"MLX"				/* multi-block file */
#define TXT_EXT	"TXT"				/* text file */
#define SQC_EXT	"SQC"				/* sequencer file */
#define BAK_EXT	"BAK"				/* backup of any kind of file */
#define STU_EXT	"STU"				/* studio setup file */

	/* typedef's */
typedef struct {						/* memory management structures */
	long start;
	long nbytes;
} HEAP;

typedef struct {
	long start;			/* address of memory block */
	long nbytes;		/* length of block (bytes), div by 4 */
	int handle;			/* who owns the block (-1 for unowned */
	int locked;			/* currently unused */
} MEMSTRUCT;

typedef struct {						/* constvar sub-token */
	long const;
	char format;
	char var;
} CONSTVAR;

typedef struct {						/* patch number formatting structure */
	int npatches[MAXNBANKS];		/* how many patches per bank */
	long bankname[MAXNBANKS];		/* ascii name (can be null) */
	char offset[MAXNBANKS];			/* display offset */
} PNUMFMT;

typedef struct {						/* TEM file header */
   long magic;				/* this part same as FILEHEADER */
	int machine;
	int version;
	long rectype;			/* idTEMGLOB */
	long recleng;			/* not including rectype and recleng */
   int page_w; 			/* page width, in pixels */
   int page_h; 			/* page height, in pixels */
	char no_send;			/* edit monitoring inhibit */
	char rfu;
} TEMHEADER;

typedef struct {						/* for text_edit() */
	int x;			/* column # of start of text field */
	int y;			/* pixel coord of top of text field */
	int w;			/* # chars in text field (including spaces between groups */
	char *valid;	/* null-term'd list of valid ascii characters, 0L for all */
	int spacing;	/* 0= XXXXXX, 1= X X X X X X, 2= XX XX XX, 3= XXX XXX, etc. */
	int fillchar;	/* character to display beyond null-term */
	int spacechar; /* character to display between groups */
	int bell;		/* whether to ring bell on invalid ascii char */
}	TEXTEDFMT;

typedef struct {     /* at beginning of every file */
   long magic;       /* identifies file type */
   int machine;      /* 1= Atari, 2= Macintosh */
   int version;      /* file type version: 0= beta, 1= first release, etc. */
} FILEHEADER;

typedef struct {     /* at beginning of every record */
   long type;		  /* identifies record type */
   long length;     /* # bytes in record (not including recheader),
                        Every record must be an even length, so in some
                        cases there will be a zero byte pad at the end of
                        the record.  The recleng does NOT include the pad! */
} RECHEADER;

typedef struct {
	long type,length;		/* this part same as a RECHEADER */
	int patch;
	char cnxfilename[32];
	char cnxname[NCHPERCNX];
	char temfilename[32];
	char comment[130];
}	GLOBRECORD;

typedef struct {			/* used in editor */
	int next;
	int ctrl_i;
	int val_i;
} EBDTLINK;

typedef struct {			/* list of constants */
   char name[8];			/* constant name, not null-term'd but null-padded */
   int  length;			/* how many bytes in value, always even */
   char value[1];			/* value[length] */
} NAMEDCONST;

typedef struct {			/* context for CNX execution */
	int midichan;		/* 0-15, -1 = unknown */
	int in_port;		/* 0-1 */
	int out_port;		/* 0-3 */
	int speed;			/* 0-2000 */
	int filter;
	char initstring[33];	/* null-terminated ascii-encoded midi string,
									can include 'n' meaning global patch bay
									channel */
	char exitstring[33];
} DEV_STRUCT;

typedef struct {			/* part of studio setup */
	int confignum;			/* 0-62, -1 unknown */
	char extent[4];		/* null-terminated file extension from config */
	char name[16];			/* null-terminated device name */
} CONFIG_LINK;

/* EOF */
