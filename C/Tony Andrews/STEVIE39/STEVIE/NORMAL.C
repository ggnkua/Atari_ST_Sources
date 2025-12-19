/*
 * STevie - ST editor for VI enthusiasts.    ...Tim Thompson...twitch!tjt...
 */

#include <ctype.h>
#include "stevie.h"

/*
 * normal
 *
 * Execute a command in normal mode.
 */

normal(c)
int c;
{
	char *p, *q;
	int nchar, n;

	switch(c){
	case 'H':
		help();
		/* fall through purposely */
	case '\014':
		screenclear();
		updatescreen();
		break;
	case 04:
		/* control-d */
		if ( ! onedown(10) )
			beep();
		break;
	case  025:
		/* control-u */
		if ( ! oneup(10) )
			beep();
		break;
	case 06:
		/* control-f */
		if ( ! onedown(Rows) )
			beep();
		break;
	case 02:
		/* control-b */
		if ( ! oneup(Rows) )
			beep();
		break;
	case '\007':
		fileinfo();
		break;
	case 'G':
		gotoline(Prenum);
		break;
	case 'l':
		if ( ! oneright() )
			beep();
		break;
	case 'h':
		if ( ! oneleft() )
			beep();
		break;
	case 'k':
		if ( ! oneup(1) )
			beep();
		break;
	case 'j':
		if ( ! onedown(1) )
			beep();
		break;
	case 'b':
		/* If we're on the first character of a word, force */
		/* an initial backup. */
		if ( ! issepchar(*Curschar) && Curschar>Filemem
			&& issepchar(*(Curschar-1)) )
			Curschar--;

		if ( ! issepchar(*Curschar) ) {
			/* If we start in the middle of a word, back */
			/* up until we hit a separator. */
			while ( Curschar>Filemem && !issepchar(*Curschar))
				Curschar--;
			if ( issepchar(*Curschar) )
				Curschar++;
		}
		else {
			/* back up past all separators. */
			while ( Curschar>Filemem && issepchar(*Curschar))
				Curschar--;
			/* back up past all non-separators. */
			while (Curschar>Filemem && !issepchar(*Curschar)){
				Curschar--;
			}
			if ( issepchar(*Curschar) )
				Curschar++;
		}
		break;
	case 'w':
		if ( issepchar(*Curschar) ) {
			/* If we're on a separator, we advance to */
			/* the next non-separator char. */
			while ( (p=Curschar+1) < Fileend ) {
				Curschar = p;
				if ( ! issepchar(*Curschar) )
					break;
			}
		}
		else {
			/* If we're in the middle of a word, we */
			/* advance to the next word-separator. */
			while ( (p=Curschar+1) < Fileend ) {
				Curschar = p;
				if ( issepchar(*Curschar) )
					break;
			}
			/* Now go past any trailing white space */
			while (isspace(*Curschar) && (Curschar+1)<Fileend)
				Curschar++;
		}
		break;
	case '$':
		while ( oneright() )
			;
		break;
	case '0':
	case '^':
		beginline();
		break;
	case 'x':
		/* Can't do it if we're on a blank line.  (Actually it */
		/* does work, but we want to match the real 'vi'...) */
		if ( *Curschar == '\n' )
			beep();
		else {
			addtobuff(Redobuff,'x',NULL);
			/* To undo it, we insert the same character back. */
			resetundo();
			addtobuff(Undobuff,'i',*Curschar,'\033',NULL);
			Uncurschar = Curschar;
			delchar();
			updatescreen();
		}
		break;
	case 'a':
		/* Works just like an 'i'nsert on the next character. */
		if ( Curschar < (Fileend-1) )
			Curschar++;
		resetundo();
		startinsert("a");
		break;
	case 'i':
		resetundo();
		startinsert("i");
		break;
	case 'o':
		opencmd();
		updatescreen();
		resetundo();
		startinsert("o");
		break;
	case 'd':
		nchar = vgetc();
		n = (Prenum==0?1:Prenum);
		switch(nchar){
		case 'd':
			sprintf(Redobuff,"%ddd",n);
			/* addtobuff(Redobuff,'d','d',NULL); */
			beginline();
			resetundo();
			Uncurschar = Curschar;
			yankline(n);
			delline(n);
			beginline();
			updatescreen();
			/* If we have backed xyzzy, then we deleted the */
			/* last line(s) in the file. */
			if ( Curschar < Uncurschar ) {
				Uncurschar = Curschar;
				nchar = 'p';
			}
			else
				nchar = 'P';
			addtobuff(Undobuff,nchar,NULL);
			break;
		case 'w':
			addtobuff(Redobuff,'d','w',NULL);
			resetundo();
			delword(1);
			Uncurschar = Curschar;
			updatescreen();
			break;
		}
		break;
	case 'c':
		nchar = vgetc();
		switch(nchar){
		case 'c':
			resetundo();
			/* Go to the beginning of the line */
			beginline();
			yankline(1);
			/* delete everything but the newline */
			while ( *Curschar != '\n' )
				delchar();
			startinsert("cc");
			updatescreen();
			break;
		case 'w':
			resetundo();
			delword(0);
			startinsert("cw");
			updatescreen();
			break;
		}
		break;
	case 'y':
		nchar = vgetc();
		switch(nchar){
		case 'y':
			yankline(Prenum==0?1:Prenum);
			break;
		default:
			beep();
		}
		break;
	case '>':
		nchar = vgetc();
		n = (Prenum==0?1:Prenum);
		switch(nchar){
		case '>':
			tabinout(0,n);
			updatescreen();
			break;
		default:
			beep();
		}
		break;
	case '<':
		nchar = vgetc();
		n = (Prenum==0?1:Prenum);
		switch(nchar){
		case '<':
			tabinout(1,n);
			updatescreen();
			break;
		default:
			beep();
		}
		break;
	case '?':
	case '/':
	case ':':
		readcmdline(c);
		break;
	case 'n':
		repsearch();
		break;
	case 'C':
	case 'D':
		p = Curschar;
		while ( Curschar >= p )
			delchar();
		updatescreen();
		resetundo();	/* This should really go above the */
				/* delchars above, and the undobuff should */
				/* be constructed by them. */
		if ( c == 'C' ) {
			Curschar++;
			startinsert("C");
		}
		break;
	case 'r':
		nchar = vgetc();
		resetundo();
		if ( nchar=='\n' || (!Binary && nchar=='\r') ) {
			/* Replacing a char with a newline breaks the */
			/* line in two, and is special. */
			nchar = '\n';	/* convert \r to \n */
			/* Save stuff necessary to undo it, by joining */
			Uncurschar = Curschar-1;
			addtobuff(Undobuff,'J','i',*Curschar,'\033',NULL);
			/* Change current character. */
			*Curschar = nchar;
			/* We don't want to end up on the '\n' */
			if ( Curschar > Filemem )
				Curschar--;
			else if (Curschar < Fileend )
				Curschar++;
		}
		else {
			/* Replacing with a normal character */
			addtobuff(Undobuff,'r',*Curschar,NULL);
			Uncurschar = Curschar;
			/* Change current character. */
			*Curschar = nchar;
		}
		/* Save stuff necessary to redo it */
		addtobuff(Redobuff,'r',nchar,NULL);
		updatescreen();
		break;
	case 'p':
		putline(0);
		break;
	case 'P':
		putline(1);
		break;
	case 'J':
		for ( p=Curschar; *p!= '\n' && p<(Fileend-1) ; p++ )
			;
		if ( p >= (Fileend-1) ) {
			beep();
			break;
		}
		Curschar = p;
		delchar();
		resetundo();
		Uncurschar = Curschar;
		addtobuff(Undobuff,'i','\n','\033',NULL);
		addtobuff(Redobuff,'J',NULL);
		updatescreen();
		break;
	case '.':
		stuffin(Redobuff);
		break;
	case 'u':
		if ( Uncurschar != NULL && *Undobuff != '\0' ) {
			Curschar = Uncurschar;
			stuffin(Undobuff);
			*Undobuff = '\0';
		}
		if ( Undelchars > 0 ) {
			Curschar = Uncurschar;
			/* construct the next Undobuff and Redobuff, which */
			/* will re-insert the characters we're deleting. */
			p = Undobuff;
			q = Redobuff;
			*p++ = *q++ = 'i';
			while ( Undelchars-- > 0 ) {
				*p++ = *q++ = *Curschar;
				delchar();
			}
			/* Finish constructing Uncursbuff, and Uncurschar */
			/* is left unchanged. */
			*p++ = *q++ = '\033';
			*p = *q = '\0';
			/* Undelchars has been reset to 0 */
			updatescreen();
		}
		break;
	default:
		beep();
		break;
	}
}

/*
 * tabinout(inout,num)
 *
 * If inout==0, add a tab to the begining of the next num lines.
 * If inout==1, delete a tab from the begining of the next num lines.
 */

tabinout(inout,num)
{
	int ntodo = num;
	char *savecurs, *p;

	beginline();
	savecurs = Curschar;
	while ( ntodo-- > 0 ) {
		beginline();
		if ( inout == 0 )
			inschar('\t');
		else {
			if ( *Curschar == '\t' )
				delchar();
		}
		if ( ntodo > 0 ) {
			if ( (p=nextline(Curschar)) != NULL )
				Curschar = p;
			else
				break;
		}
	}
	/* We want to end up where we started */
	Curschar = savecurs;
	updatescreen();
	/* Construct re-do and un-do stuff */
	sprintf(Redobuff,"%d%s",num,inout==0?">>":"<<");
	resetundo();
	Uncurschar = savecurs;
	sprintf(Undobuff,"%d%s",num,inout==0?"<<":">>");
}

startinsert(initstr)
char *initstr;
{
	char *p, c;

	Insstart = Curschar;
	Ninsert = 0;
	Insptr = Insbuff;
	for (p=initstr; (c=(*p++))!='\0'; )
		*Insptr++ = c;
	State = INSERT;
	windrefresh();
}

resetundo()
{
	Undelchars = 0;
	*Undobuff = '\0';
	Uncurschar = NULL;
}
