/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/93  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	Beispiele fr Codieralgorithmen				*/
/*							CODING.TTP									*/
/*																		*/
/*		M O D U L E		:	MESSAGES.H									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 4.01, Pure C				*/
/*																		*/
/*		Last Update		:	26.02.93 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#ifndef __MESSAGES__
#define __MESSAGES__

/* messages for standard C error numbers */

#define MSG_EPERM		"\nFile permission denied: '%s'!"
#define MSG_ENOENT		"\nFile not found: '%s'!"
#define MSG_EIO			"\nGeneral I/O error!"
#define MSG_EMFILE		MSG_EIO
#define MSG_ENFILE		MSG_EIO
#define MSG_EILLSPE		"\nIllegal file specification: '%s'!"
#define MSG_ENOMEM		"\nOut of memory!"
#define MSG_EACCES		"\nFile access mode error: '%s'!"
#define MSG_EEXIST		"\nFile already exists: '%s'!"
#define MSG_ENOTDIR		"\nPath not found: '%s'!"
#define MSG_ENOSPC		"\nDisk full!"
#define MSG_ESPIPE		"\nFile seek error: '%s'!"


/*	additional error messages */

#define MSG_EINTERNAL	"\nInternal programm error #%d!"
#define MSG_ECRCSUM		"\nFile CRC sum error: '%s'!"
#define MSG_EREN		"\nCan not rename file to: '%s'!"
#define MSG_PROTECT		"\nFile is write protected: '%s'!"

/*	additional messages */

#define MSG_ILLMODE		"\nNot supported compression mode '%c' in: '%s'!"
#define MSG_NOCODE		"\nNot coded file: '%s'!"
#define MSG_ALREADY		"\nFile already coded: '%s'!"
#define MSG_ENTRY	\
			"\n" \
			" TOS-Magazin project for coding algorithms            Version  1.00\n" \
			"                                                      " __DATE__ "\n" \
			"                                                      by J. Lietzow\n"
#define MSG_USAGE	\
			" usage:\n" \
			" CODING.TTP [-]command [-options] src_file(s) [dest_path|dest_file]\n" \
			"\n" \
			" commands:                    options:\n" \
			"   -f  Huffman coding           -h  hold after execution\n" \
			"   -l  Lempel-Ziv coding        -y  auto answer with 'yes'\n" \
			"   -n  no coding                -d  delete src files\n" \
			"   -e  extract                  -s  suppress screen output\n"

#define MSG_EXTRACT		"\nExtracting from mode '%c': '%s'    0 Kb"
#define MSG_COMPRESS	"\nCompressing with mode '%c': '%s'    0 Kb"
#define MSG_NXTKB		"\b\b\b\b\b\b\b%4ld Kb"
#define MSG_FINISH		" done!"
#define MSG_PRESS		"\nPress any key to continue!"

/*	user questions */

#define ASK_CONTINUE	"\nContinue proceeding ([y]es, [n]o)?"
#define ASK_DELETE		"\nDelete anyway ([y]es, [a]ll, [s]kipp, [q]uit)?"
#define ASK_GENERATE	"\nGenerate file anyway ([y]es, [a]ll, [n]o, [q]uit)?"


/*	hot keys for answer */

#define	AN_YES	'y'
#define AN_NO	'n'
#define	AN_ALL	'a'
#define	AN_SKIP	's'
#define	AN_QUIT	'q'


#endif