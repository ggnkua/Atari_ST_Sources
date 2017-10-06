/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997/2001
 *
 *	module: ev_msg.c
 *	description: gestion liste des ‚v‚nements AES
 */

#include <stdio.h>
#include <stdlib.h>
#include "globals.h"

/*
 *	Recherche d'un ‚v‚nement : OKAY
 */

void *EvntFind( WINDOW *win, int msg) {
	EV_MSG *scan = win?win->binding:app.binding;
	
	while( scan && scan->msg < msg)
		scan = scan -> next;
	if( scan) return (scan->msg==msg)?scan:NULL;
	return NULL;
}

/*
 * ajout une ‚v‚nement par ordre
 * croissant. Les ‚v‚nements de mˆme num‚ro
 * sont ajout‚s … la suite. fonction interne.
 *	-> OKAY
 */

static
void mesag_add( void **root, EV_MSG *new, int mode) {
	EV_MSG *scan;
	
	scan = (EV_MSG *)*root;
	/* insertion en tˆte */
	if( scan == NULL || new->msg < scan->msg) {
		new->next = scan;
		*root = new;
	} else {
		if( mode == EV_BOT) {
			while( scan->next && scan->next->msg <= new->msg)
				scan = scan -> next;
		} else {	/* EV_TOP */
			while( scan->next && scan->next->msg < new->msg)
				scan = scan -> next;
		} 
		new->next = scan->next;
		scan->next = new;
	}
}

/* Si win == NULL -> simple ajout dans app.binding
 * Sinon ajout dans app.binding pour signaler que l'‚v‚nement
 * d‚pend d'une fenˆtre et ajout dans win->binding
 * La fonction cumul les ‚v‚nements.
 * mode = EV_TOP ou EV_BOT
 */

int EvntAdd( WINDOW *win, int msg, void *proc, int mode) {
	EV_MSG *new;

	/* D‚claration dans app.binding */
	if( win) {
		new = EvntFind( NULL, msg);
		if( !new) {
			new = (EV_MSG *)malloc( sizeof(EV_MSG));
			if( !new) return -69;
			new -> msg = msg;
			new -> proc = NULL;
			new -> flags = 0;
			mesag_add( &app.binding, new, mode);
		}
		new -> flags |= EVM_ISWIN;
	} else {
		new = (EV_MSG *)malloc( sizeof(EV_MSG));
		if( !new) return -69;
		new -> msg  = msg;
		new -> flags = 0;
		mesag_add( &app.binding, new, mode);
		new -> flags &= ~EVM_ISWIN;
	}

	/* Ajout dans win->binding si besoin */
	if( win) {
		new = (EV_MSG *)malloc( sizeof(EV_MSG));
		if( !new) return -69;
		new -> msg  = msg;
		new -> flags = 0;
		mesag_add( &win->binding, new, mode);
	}

	new -> proc = proc;	
	return 0;
}

/*
 *	Attache un ‚v‚nement, les ‚v‚nements d‚j… pr‚sent
 *	sont ‚cras‚s.
 *  -> OKAY
 */

int EvntAttach( WINDOW *win, int msg, void *proc) {
	EV_MSG *new;
	
	/* 1) on efface les vieux ‚v‚nements */
	new = EvntFind( win, msg);
	if( new) EvntDelete( win, msg);
	
	/* 2) D‚claration dans app.binding, si besoin */
	new = EvntFind( NULL, msg);
	if( !new) {
		new = (EV_MSG *)malloc( sizeof(EV_MSG));
		if( !new) return -69;
		new -> msg = msg;
		new -> proc = NULL;
		new -> flags = 0;
		mesag_add( &app.binding, new, EV_BOT);
	}
	if( win) new -> flags |= EVM_ISWIN;
		
	/* 3) Ajout dans win->binding si besoin */
	if( win) {
		new = (EV_MSG *)malloc( sizeof(EV_MSG));
		if( !new) return -69;
		new -> msg  = msg;
		new -> flags = 0;
		mesag_add( &win->binding, new, EV_BOT);
	}

	new -> proc = proc;	
	return 0;
}

/*
 *	EnlŠve un ‚v‚nement (et un seul) correspondant … une fonction
 *	me parait OK
 */

int EvntRemove( WINDOW *win, int msg, void *proc) {
	EV_MSG *scan, *trash;
	int found = 0;

	scan = win?win->binding:app.binding;

	/* suppression tˆte de liste */	
	if( scan->proc == proc && scan->msg == msg ) {
		found = 1;
		/* cas o— l'on n'efface pas */
		if( !win && scan->flags & EVM_ISWIN) {
			scan -> proc = NULL;
		} else {
			if( win)
				win->binding = scan -> next;
			else
				app.binding = scan -> next;
			if (scan->flags & EVM_IN_USE)
				scan->flags |= EVM_DELETED;
			else
				free( scan);
		}
	} else { /* suppression dans la liste */
		/* recherche ‚l‚ment */
		for( scan = win ? win -> binding : app.binding; 
			 scan->next && ! (scan->next -> proc == proc
			 			&& scan->next -> msg  == msg)  ; scan = scan->next);
		/* ‚l‚ment trouv‚ */
		if( scan->next && scan->next -> proc == proc
					   && scan->next -> msg  == msg  ) {
			found = 1;
			/* cas o— l'on n'efface pas */
			if( !win && scan->next -> flags & EVM_ISWIN) {
				scan->next -> proc = NULL;
			} else {
				trash = scan->next;
				scan->next = scan->next -> next;
				if (trash->flags & EVM_IN_USE)
					trash->flags |= EVM_DELETED;
				else
					free( trash);
			}
		}
	}
	return found;
}

/*
 *	EnlŠve tous les ‚v‚nements <<msg>> d'une liste
 *	-> OKAY
 */

int EvntDelete( WINDOW *win, int msg) {
	EV_MSG *scan;
	int found = 0;
	EV_MSG *next;

	for( scan = EvntFind( win, msg); scan && scan->msg == msg; scan = next) {
		found = 1;
		/* save "next" field before freeing scan */
		next = scan->next ;  
		EvntRemove( win, msg, scan->proc);
	}
	return found;
}

void EvntDisable( WINDOW *win, int msg) {
	EV_MSG *scan;
	
	scan = EvntFind( win, msg);
	while( scan && scan->msg == msg) {
		SET_BIT( scan->flags, EVM_DISABLE, TRUE);
		scan = scan -> next;
	}
}

void EvntEnable( WINDOW *win, int msg) {
	EV_MSG *scan;
	
	scan = EvntFind( win, msg);
	while( scan && scan->msg == msg) {
		SET_BIT( scan->flags, EVM_DISABLE, FALSE);
		scan = scan -> next;
	}
}

/*
 *	EnlŠve tous les ‚v‚nements d'une liste
 *	-> OKAY
 */

void EvntClear( WINDOW *win) {
	EV_MSG *scan = win?win->binding:app.binding, *next;

	while( scan) {
		next = scan -> next;
		free( scan);
		scan = next;
	}
	if( win) win->binding = NULL;
	else	 app.binding = NULL;
}

/*
 * EnlŠve tous les ‚vŠnements EVM_DELETED d'une liste
 *
 */

static void EvntCleanUp( WINDOW *win) {
	EV_MSG *scan, *trash;

	scan = win?win->binding:app.binding;

	/* suppression tˆte de liste */	
	while( (scan) && (scan->flags & EVM_DELETED) ) {
		trash = scan;
		if( win) {
			win->binding = scan -> next;
			scan = win->binding;
		} else {
			app.binding  = scan -> next;
			scan = app.binding;
		}
		free( trash);
	}
	
	/* plus rien en tete de liste ? on sort */
	if( ! scan )  return;
	
	/* suppression dans la liste */
	while( scan->next) {
		if( scan->next -> flags & EVM_DELETED) {
			trash = scan->next;
			scan->next = scan->next -> next;
			free( trash);
		} else
			scan = scan->next;
	}
}

/*
 *	Execute les routines associ‚es … l'‚v‚nement <<msg>>
 *	-> OKAY
 */

/* ATTENTION: avec l'utilisation du flag EVM_IN_USE, on va
 * au devant de problŠmes sir cette fonction est r‚-entrante,
 * c'est … dire si une fonction "find->proc" peut appeler
 * EvntExec(). Normalement, ce cas n'arrive pas.
 */

int EvntExec( WINDOW *win, int msg) {
	EV_MSG *find = EvntFind( win, msg);
	int found = 0;

	while( find && find->msg == msg) {
		if( find->proc && !(find->flags & EVM_DISABLE)) {
			/* set the flag "in use" so that "find" couldn't
			 * be deleted by someone else (a "destroy" evnt 
			 * can delete itself !) */
			find->flags |=  EVM_IN_USE ;
			(*find->proc)( win);
			find->flags &= ~EVM_IN_USE ;
		}
		found = 1;
		find = find->next;
	}
	/* now, it's time to free all deleted "find" which just
	 * have their flag set to EVM_DELETED because they were
	 * "in use" */                                   
	EvntCleanUp(win);
	return found;
}

/*
 * L'‚v‚nement WM_REDRAW est le seul ‚v‚nement qui ne peut 
 * pas etre appel‚ directement par EvntExec() (parcequ'il
 * faut le masquer).
 */

void EvntRedraw( WINDOW *win) {
	GRECT work, rect;
	
	while( !wind_update(BEG_UPDATE));
	graf_mouse( M_OFF, 0L);
	wind_get_grect( win->handle, WF_WORKXYWH,  &work);
	wind_get_grect( win->handle, WF_FIRSTXYWH, &rect);
	while( rect.g_w && rect.g_h) {
		if ( rc_intersect( &rect, &work)) {
			rc_clip_on( win->graf.handle, &rect);
			EvntExec( win, WM_REDRAW);
			rc_clip_off( win->graf.handle);
		}
		wind_get_grect( win->handle, WF_NEXTXYWH, &rect);
	}
	graf_mouse( M_ON, 0L);
	wind_update(END_UPDATE);
}


/* DEBUG */

void list_ev_msg( WINDOW *win, char *str) {
	EV_MSG *scan = win?win->binding:app.binding;
	fprintf( stderr, "\33E%s\n", str);
	while( scan) {
		fprintf( stderr, "0x%X (%d) 0x%lX\n", scan->msg, scan->msg, scan->proc);
		scan = scan -> next;
	}
}


