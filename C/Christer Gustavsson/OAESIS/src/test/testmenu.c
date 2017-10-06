#include <aesbind.h>
#include <stdio.h>

#include "testmen.h"

#define	WORD	short

void	main(void) {
	WORD quit = 0;
	WORD buffer[16];
	WORD i;
	
	OBJECT	*tree;
	
	appl_init();

	for(i = 0; i < 15; i ++) {
		fprintf(stderr,"global[%2d]=%5d  0x%04x\r\n",i,_global[i],_global[i]);
	};

	getchar();	

	if(rsrc_load("testmen.rsc")) {
		for(i = 0; i < 15; i ++) {
			fprintf(stderr,"global[%2d]=%5d  0x%04x\r\n",i,_global[i],_global[i]);
		};

		getchar();	

		rsrc_gaddr(R_TREE,MENU1,&tree);
		
		menu_bar(tree,MENU_INSTALL);

		for(i = 0; i < 15; i ++) {
			fprintf(stderr,"global[%2d]=%5d  0x%04x\r\n",i,_global[i],_global[i]);
		};

		getchar();	

		while(!quit) {		
			evnt_mesag(buffer);
			
			if(buffer[0] == MN_SELECTED) {
				switch(buffer[3]) {
				case M_FILE:
					switch(buffer[4]) {
					case M_IEN0:
						menu_ienable(tree,M_QUIT,DISABLE);
						break;
						
					case M_IEN1:
						menu_ienable(tree,M_QUIT,ENABLE);
						break;
						
					case M_IEN1NEG:
						fprintf(stderr,"%d\r\n",menu_ienable(tree,M_QUIT,-1));
						break;
						
					case M_IEN2:
						fprintf(stderr,"%d\r\n",menu_ienable(tree,M_QUIT,2));
						break;
						
					case M_QUIT:
						quit = 1;
						break;
					};
					break;
				}
			};
		};

		menu_bar(tree,MENU_REMOVE);

		rsrc_free();
	}
	else {
		form_alert(1,"[1][Couldn't load resource file!][Cancel]");
	};
	
	appl_exit();
};
