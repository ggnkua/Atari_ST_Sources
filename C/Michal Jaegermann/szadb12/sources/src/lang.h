/* Copyright (c) 1990 by Sozobon, Limited.  Authors: Johann Ruegg, Don Dugger
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
/*
 * Modifications:
 *   - updated to reflect new, expanded syntax
 *
 *     Anthony Howe, Michal Jaegermann
 */
#ifdef IN_ADB

#define M1	"%s:cannot open\n"
#define M2	"%s:bad format\n"
#define M3	"%s:bad pexec\n"
#define M4	"Szadb version 1.2mj+ach (english)"
#define M5	"(hit any key)"
#define M6	"unknown command\n"
#define M7	"can't allocate %i bytes for input info node\n"
#define M_USE   "Usage: adb [-nb] [-nc] [-k kdefs] [-o(s|m)] binary [args]\n"

#ifndef FORGET
char *errwhy[] = {
	"access out of bounds\n",
	"unbalanced parenthesis\n",
	"unknown command\n",
	"bad command\n",
	"unknown symbol\n",
	"bad register name\n"
};
#endif
#endif

#ifdef IN_ADB1

#define M1	"can't allocate %i bytes for symbol\n"
#define M2	"Retry? (y/n): "

#endif

#ifdef IN_FKEY

#define M1	"cannot open %s\n"
#define M2	"no memory for a table of function keys\n"
#define M3	"definition of f%i too long - aborted\n"
#define M4	"read error: file %s\n"
#define M5	"out of memory while defining F%i\n"
#define M6	"kdefs: out of memory\n"
	
#endif

#ifdef IN_HELP

/*
 * The longest line of help can be no more than 40 characters.
 * These tables are shown from the last one to the first.
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
"<l,<t,<b,<d value of variable",
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
"  n,b,r  newline,blank,blank",
"   +,-   add +1 or -1 to DOT",
"    ^    backup DOT by last format",
"  STRING echo string to output",
	0
};

char *help3[] = {
"     :  COMMANDS               EXTRAS",
"  :c,:C  continue             {params}",
"  :s,:S  step               {requests}",
"  :n,:N  next               {requests}",
"  :j,:J  jump               {requests}",
"  :f,:F  end of function    {requests}",
"   :b    set breakpoint     {requests}",
"   :d    del breakpoint",
"",
"::b,::s  switch on/off stored req {+-}",
"   similar for other stepping commands",
"::f_,::n_ switch request \"down\"",
"",
"     >  COMMAND                EXTRAS",
"    >    change register value   {reg}",
"",
"     <  COMMAND                EXTRAS",
"    <    read value of register  {reg}",
"         or of a spec variable  {ltbd}",
	0
};

char *help4[] = {
"      $  COMMANDS",
"   $c,$C stack backtrace",
"   $r    show registers",
"   $p    show basepage",
"$o,$x,$d set number base",
"   $q    quit",
"   $b    show breakpoints",
"   $s    set symbol offset",
"   $e    show external symbols",
"   $k<n> execute key F<n>",
"   $k    show function key defs",
" $>file  record output in file",
"   $>    output only on screen",
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
#define UNKNOWN_CMD             "unknown command\n"

#define M11	"can't load %s\n"
#endif /* IN_PCS */

#ifdef IN_STEPPING
#define PROCESS_EXIT    "process exited\n"
#define BREAK_AT        "break at %A\n"
#define TOO_MANY_BPT    "too many breakpoints\n"
#define NO_BPT          "no breakpoint found\n"
#define NO_RETURN       "no return address found\n"
#endif /* IN_STEPPING */

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

#define MW	"error on write to %s"		/* in file window.c */
