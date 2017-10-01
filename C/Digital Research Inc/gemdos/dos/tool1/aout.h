/*
	Copyright 1983
	Alcyon Corporation
	8716 Production Ave.
	San Diego, CA  92121

	@(#)a.out.h	1.10    3/5/84
*/

/*
	Regulus a.out file format
*/

struct exec {
	unsigned short a_magic;		/*executable magic number*/
	long a_text;		/*size of text segment in bytes*/
	long a_data;		/*size of data segment in bytes*/
	long a_bss;			/*size of bss segment in bytes*/
	long a_syms;		/*size of symbol table in bytes*/
	long a_stksize;		/*size of stack in bytes*/
	long a_entry;		/*entry point or break size in bytes*/
	short a_flag;			/*relocation bits flag*/
};

struct exec2 {
	unsigned short a_magic;		/*executable magic number*/
	long a_text;		/*size of text segment in bytes*/
	long a_data;		/*size of data segment in bytes*/
	long a_bss;			/*size of bss segment in bytes*/
	long a_syms;		/*size of symbol table in bytes*/
	long a_stksize;		/*size of stack in bytes*/
	long a_entry;		/*entry point or break size in bytes*/
	short a_flag;			/*relocation bits flag*/
	long a_dstart;		/*starting address of data segment*/
	long a_bstart;		/*starting address of bss segment*/
};

/* HDSIZE should be 28 bytes, HDSIZ2 should be 36 bytes */
#ifndef VAX11
#	define HDSIZE		(sizeof (struct exec))
#	define HDSIZ2		(sizeof (struct exec2))
#	define S_SYMSIZ		(sizeof (struct nlist))
#else
#	define HDSIZE		28
#	define HDSIZ2		36
#	define S_SYMSIZ		14
#endif
#define S_SY68SIZ	14		/* symbol entry size on the a.out file always */

struct r_info {
	int r_segment: 3;
	int r_symbolnum: 13;
};

#define S_SYMLEN	8	/* length of a symbol table name */

struct nlist {
	char n_name[S_SYMLEN];
	short n_type;
	long n_value;
};

#define	E_MAGIC		0x601a
#define	E_MAGIC2	0x601b
#define	E_2KMAGIC	0x601c
#define	E_IDMAGIC	0x601d
#define	E_4KMAGIC	0x601e

#define	R_BITS		0
#define	R_NOBITS	1

#define	S_DEFINED	0100000
#define	S_ABS		0040000
#define	S_GLOBAL	0020000
#define	S_REG		0010000
#define	S_EXTERNAL	0004000
#define	S_DATA		0002000
#define	S_TEXT		0001000
#define	S_BSS		0000400
#define S_FILE		0000200

#define	R_ABS		00
#define	R_DATA		01
#define	R_TEXT		02
#define	R_BSS		03
#define	R_UNDEF		04
#define	R_UPPER		05
#define R_EXTREL	06
#define	R_ISTART	07

#define SHT2KBOUND		2048
#define SHT2KSHFT		11
#define SHT2KFIX(x)		(((x+SHT2KBOUND-1)>>SHT2KSHFT)<<SHT2KSHFT)
#define SHT4KBOUND		4096
#define SHT4KSHFT		12
#define SHT4KFIX(x)		(((x+SHT4KBOUND-1)>>SHT4KSHFT)<<SHT4KSHFT)
