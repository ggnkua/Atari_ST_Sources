/* Copyright (c) 1990,91 by Sozobon, Limited.  Authors: Johann Ruegg, Don Dugger
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	lang.h	- english version
 *	change only this file to make other language versions
 */

#ifdef IN_ADB

#define M1	"%s:cannot open\n"
#define M2	"%s:bad format\n"
#define M3	"%s:bad pexec\n"
#define M4	"Szadb version 2.0 (english)\n"
#define M5	"(hit any key)"
#define M6	"unknown command\n"

char *errwhy[] = {
	"access out of bounds\n",
	"unbalanced parenthesis\n",
	"unknown command\n",
	"bad command\n",
	"unknown symbol\n",
	"bad register name\n"
};

#endif

#ifdef IN_ADB1

#define M1	"can't allocate %i bytes for symbol\n"

#endif

#ifdef IN_HELP

/*
 * The longest line of help can be no more than 40 characters 
 */

char *help1[] = {
"        SYNTAX SUMMARY",
"{expr},{count} COMMAND {extras}",
"",
"      VALUES",
"   NAME  address of symbol",
" NUMBER  number in default base",
"0x,0t,0o prefix for hex,decimal,octal",
"  <REG   value of register",
"    .    current location (DOT)",
"    &    last typed {expr}",
"",
"     BINARY OPERATORS",
" +,-,*,% add,sub,mul,div",
"   &,|   bitwise and,or",
"",
"     UNARY OPERATORS",
"   -,^   minus,complement",
"    *    fetch 4 bytes from address",
"    @    fetch 2 bytes from address",
	0
};

char *help2[] = {
"    ?/  COMAMNDS               EXTRAS",
" / or ?  print memory         {format}",
"   =     print value          {format}",
"   /w,/W write memory         {values}",
"",
"      FORMATS",
"  o,d,x  2-bytes in octal,decimal,hex",
"  O,D,X  4-bytes in octal,decmial,hex",
"    i    disassembled instruction",
"    b    1-byte in octal",
"    c    1-byte character",
"   a,p   address relative to symbols",
"   s,S   string",
"",
"      SPECIAL FORMAT FIELDS",
"    t    tab",
"   n,b   newline,blank",
"   +,-   add +1 or -1 to DOT",
"    ^    backup DOT by last format",
"  STRING echo string to output",
	0
};

char *help3[] = {
"      $  COMMANDS",
"   $c,$C stack backtrace",
"   $r    show registers",
"   $p    show basepage",
"$o,$x,$d set number base",
"   $q    quit",
"   $b    show breakpoints",
"   $s    set symbol offset",
"   $e    show external symbols",
"",
"     :  COMMANDS               EXTRAS",
"  :c,:C  continue             {params}",
"  :s,:S  step                 {params}",
"   :b    set breakpoint",
"   :d    del breakpoint",
"",
"     >  COMMAND                EXTRAS",
"    >    change register value   {reg}",
	0
};

#define M1	"   q - quit   <space> - more"

#endif

#ifdef	IN_PCS

#define M1	"(? at %I)"

#define M2	"base page at %I"
#define M3	"\nlow tpa "
#define M4	"  hi tpa  "
#define M5	"\ntext at "
#define M6	"  size    "
#define M7	"\ndata at "
#define M8	"\nbss at  "
#define M9	"\nenv ptr "
#define M10	"  parent  "

#define M11	"can't load %s\n"
#define M12	"process exited\n"
#define M13	"unknown command\n"
#define M14	"break at %I\n"
#define M15	"too many breakpoints\n"
#define M16	"no breakpoint found\n"

#endif

#ifdef IN_TRACE

char *tnm[] = {
	"0", "1", "bus error", "address error",
	"illegal instr", "zero divide",
	"CHK", "TRAPV",
	"priv violation", "trace",
	"process exit"
};

char *fcnm[] = {
	"?0?", "user data", "user prog", "?3?",
	"?4?", "supv data", "supv prog", "intr ack"
};

#define M1	"(not instr) "
#define M2	"addr %I instr %i\n"
#define M3	"internal trap: "
#endif
