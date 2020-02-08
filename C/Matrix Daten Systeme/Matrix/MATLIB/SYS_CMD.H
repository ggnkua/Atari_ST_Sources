
# ifndef H
# define H(hs)	hs
# endif


typedef enum CMDnum
{
	/* System Commands */
	CMDillegal = 0,
	CMDnop,
	CMDalias,	CMDcall,	CMDcd,		CMDclear,	CMDcli,
	CMDdefine,	CMDdelay,	CMDdir,		CMDecho,	CMDelse, CMDelsif,
	CMDendfor,	CMDendif,	CMDexec,	CMDexit,	CMDfor,	
	CMDgoto,	CMDhelp,	CMDhome,	CMDif,		CMDinclude,
	CMDpeek,	CMDpoke,	CMDkbshift,	CMDkey,		CMDprintvalue,
	CMDpwd,		CMDquit,	CMDradix,	CMDreturn,	CMDset,
	CMDundef,	CMDverbose,	CMDsound,	CMDprompt,	CMDwide, CMDsysscreen,
	CMDcat,		CMDhead,	CMDfhelp,
	CMDcopy,	CMDrename,	CMDexist,	CMDmkdir,	CMDdel,	CMDrmdir,
	CMDerrors,	CMDhistory
} ;


CMD sys_cmd_table[] =
{
/* ==== System Commands === */
{ "alias",		"%p%s%e",		H("alias [{name} {text}]"),			CMDalias	},
{ "call",		"%s",			H("call function [ label ]"),			CMDcall		},
{ "cd",			"%s%u%e",		H("change current directory"),			CMDcd		},
{ "clear",		"",				H("clear screen"),						CMDclear	},
{ "cli",		"",				H("command interpreter\n"
			 					HISTtab" stop : Ctrl-Q, clear line : ESC,\n"
			 					HISTtab" command history : cursor up/down"),	CMDcli	},
{ "dir",		"%s%u%e",		H("dir { path }"),						CMDdir		},
{ "copy",		"%s%s%s%e",		H("copy [ source destination { new date } ]"),	CMDcopy		},
{ "cp",			"%s%s%s%e",		H(" = copy"),							CMDcopy		},
{ "rename",		"%s%s",			H("rename [ old new ]"),			CMDrename		},
{ "mv",			"%s%s",			H(" = rename"),					CMDrename		},
{ "exist",		"%s",			H("file exists [ name ]"),			CMDexist		},
{ "del",		"%s",			H("delete file [ name ]"),			CMDdel			},
{ "rm",			"%s",			H(" = del"),						CMDdel			},
{ "rmdir",		"%s",			H("remove directory [ path ]"),	CMDrmdir		},
{ "mkdir",		"%s",			H("create new directory [ path ]"),CMDmkdir		},
{ "md",			"%s",			H(" = mkdir"),						CMDmkdir		},
{ "errors",		"",				H("+/- error messages on / off"),	-CMDerrors		},
{ "history",	"",				H("+/- command history on / off"),	-CMDhistory		},

{ "define",		"%p%lu%e",		H("define [{name} {expr}]"),			CMDdefine	},
{ "delay",		"%i",			H("wait some time [ sec | 'on' | 'off' ]"),
																	CMDdelay	},
{ "echo",		"%s*%e",		H("echo parameter [ .. ]"),			CMDecho		},
{ "head",		"%s%u%e",		H("list head lines [ file-name { lines } ]"),
																	CMDhead		},
{ "cat",		"%s",			H("list file [ name ]"),				CMDcat		},
{ "if",			"%li",			H("conditional : if [ expression ]"),	CMDif		},
{ "elsif",		"%li",			H(" .. elsif"),						CMDelsif	},
{ "else",		"-",			H(" .. else"),							CMDelse		},
{ "endif",		"",				H(" .. endif"),						CMDendif	},

{ "exec",		"%s%s%e",		H("execute program [ name{, parameter} ]"),
																	CMDexec		},
{ "eXit",		"",				H("exit program"),						CMDexit		},
{ "for",		"%v%li%li%li",	H("for loop [ $var, start, step, end ]"),	CMDfor	},
{ "endfor",		"%v",			H("end for loop [ $var ]"),			CMDendfor	},
{ "goto",		"%s",			H("goto [ label ]"),					CMDgoto		},
{ "Help",		"%s%e",			H("show help [ command ] text"),		CMDhelp		},
{ "?",			"%s%e",			H(" = help"),							CMDhelp		},
{ "home",		"%i%i%e",		H("cursor home/set pos { x { y } }"),	CMDhome		},
{ "prompt",		"%i%e",			H("+/-set/clear prompt line [ prompt-line ]"),	-CMDprompt },
{ "wide",		"",				H("set system screen to 80 cols"),		CMDwide	},
{ "sysscreen",	"",				H("+/-switch sys screen on/off"),		-CMDsysscreen	},

{ "fhelp",		"",				H("show function keys"),				CMDfhelp	},
{ "include",	"%s%e",			H("include command file"),				CMDinclude	},
{ "in",			"%s%e",			H(" = include"),						CMDinclude	},
{ "kbshift",	"",				H("if shift pressed, start cli"),
																	CMDkbshift	},
{ "key",		"",				H("wait for key press"),				CMDkey		},
{ "pwd",		"",				H("print working directory"),			CMDpwd		},
{ "Quit",		"",				H("quit command sequence"),			CMDquit		},
{ "peek",		"%lu%u%e",		H("peek memory [ addr { size } ]"),	CMDpeek	},
{ "poke",		"%lu%lu%u%e",	H("poke memory [ addr value { size } ]"),	CMDpoke	},
{ "radix",		"%s%e",			H("set input radix [ h, d, b, o ]"),	CMDradix	},
{ "return",		"",				H("return from function"),				CMDreturn	},
{ "set",		"%v%li",		H("set variable [ key|$alpha expression ]"),
																	CMDset		},
{ "sound",		"%i*%e",		H("sound +/- { channel }\n"
			 					HISTtab" [ frequency volume { channel { delay } } ]"),
																	-CMDsound	},
{ "undef",		"%p",			H("undefine {name}"),					CMDundef	},
{ "verbose",	"%i%e",			H("+/-verbose on/off { value }"),		-CMDverbose	},
{ "!",			"%li*",			H("display value [ expression* ]"),		CMDprintvalue	},
{ ";",			"-",			H("nop"),								CMDnop	},
{ "",			"",				"",									CMDillegal	}
} ;

# undef H
