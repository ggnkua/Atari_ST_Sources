/**********************************************************************/
/* Orderhanteringsprogram                                             */
/* Skrivet av Christian Andersson                                     */
/* F”r anv„ndning i Firestorm Atari Center                            */
/**********************************************************************/
/**********************************************************************/
/* Update History                                                     */
/* 950211 + VT52 Emuleringen fungerar som den skall. P† Falcon kr„vs  */
/*           NVDI f”r att f„rgerna skall fungera                      */
/*        + Lagt in structer f”r att kunna lagra ordrar               */
/*           vara: inneh†ller informatuion om varan (pris, mm)        */
/*           orderlista: en l„nkad lista ”ver alla markerade varor    */
/*           info: information om systemet (emulering, mm)            */
/* 950212 + B”rjade l„gga in tolkningen av huvud menyn                */
/*        + b”rjade l„gga in funktionen f”r att ladda in en varulista */ 
/* 950213 + Fortsatte med varulista-inladdning! sj„lva inladdningen   */
/*          „r nu klar men sparning i minnet fungerar inte            */
/*        + „ndrade fr†n externa menyer till interna                  */
/*        + F”rflyttning i best„llningsmenyn klar (grafiskt)          */
/*        + Lade ut meny-uppritarna i en egen header                  */
/*        + lade ut structerna som egen header                        */
/*        + Sparningen i minnet av listan man best„ller utav fungerar */
/*          nu! dock s† verkar det finnas en bugg :(                  */
/* 950214 + ndrade i struct-strukturen! blir nu tvungen att „ndra i  */
/*          de funktioner som anv„nder sig av dessa                   */
/* 950215 + F„rdig med „ndringarna efter struct-„ndringen             */
/*        + lagt in s† att man nu kan markera och av-markera varor    */
/*          samt att den visar om man best„llt n†gra.                 */
/* 950222 + Lade in s† att man f†r en fr†ga om man vill avsluta men   */
/*          fortfarande har varor markerade                           */
/*        + Rutin f”r att t”mma alla orderlistor fr†n markeringar     */
/*          har laggts in (har dock ej testat den „nnu)               */
/*        + Rutin f”r att kolla om man markerat n†got har lagts in    */
/*        + lagt in s† att man nu kan avmarkera alla markeringar      */
/*          ifr†n huvudmenyn                                          */
/* 950310 + Lade ihop order.c med meny.h och mail.h                   */
/*          dvs alla funktioner i samma fil.                          */
/*        + Lade structerna och definitionerna i samma fil            */
/*        + Lade in tolk av konfigurationsfil! men ingen felkontroll  */
/* 950313 + Fixade lite med placering av order!                       */
/* 950318 + Omstrukturering av koden!                                 */
/**********************************************************************/
/**********************************************************************/
/* Includeringsfiler                                                  */
/**********************************************************************/
#include <stdio.h>
#include <conio.h>
#include <osbind.h>
#include <portab.h>
#include "order.h"

int  error=FALSE;
char errmess[TMP_S_S];
orderlista *orderbest[MAX_ORDER];
char orderinfo[10][MAX_DESC];
info setup_info;

int init();
int reset();
int menu_order(void);
int menu_best(int orderlistnum);
int menu_placering(void);
int clear_all(void);
int clear_mark(int orderlistnum);
int clear_list(int orderlistnum);
int write_message(char *areapath, char *message);
int load_list(char *listname, int orderlistnum);
void yell(void);

/**********************************************************************/
/* Main: Huvud-loopen                                                 */
/**********************************************************************/
int main()
{
	init();
	load_config();
	if(!error)
		menu_order();
	reset();
	if(error)
	{
		fprintf(stderr,errmess);
		getch();
		return (FAIL);
	}
	else
		return(OK);
}

/**********************************************************************/
/* init_modem: initierar den seriella ”verf”ringen                    */
/**********************************************************************/
int init()
{
	int i;
	
	fprintf(stdout,"\33f");
	for(i=0; i<MAX_ORDER;i++)
	{
		orderbest[i]=NULL;
		orderinfo[i][FIRST]=EOL;
	}

	return(TRUE);
}
/**********************************************************************/
/* deinit_modem: avinstallerar/tar bort den seriella ”verf”ringen     */
/**********************************************************************/
int reset()
{
	int i;
	
	fprintf(stdout,"\33e");
	
	for(i=0; i<MAX_ORDER;i++)
		clear_list(i);

	return(TRUE);
}

/**********************************************************************/
/* load_config: laddar in configurationen och initierar den           */
/**********************************************************************/
int load_config()
{
	FILE *config;
	char temp[TMP_S_S], *ptemp;
	int order_count=0;
		
	if((config=fopen(CONFIG,"r"))!=NULL)
	{
		while(fgets(temp,TMP_S_S,config)!=NULL)
		{
			if((ptemp=(char *)strchr(temp,'\n'))!=NULL)
				ptemp[FIRST]=EOL;
			
			if((ptemp=(char *)strchr(temp,'='))!=NULL)
			{
				ptemp++;
				if(strncmp(temp,MAILTO,strlen(MAILTO))==OK)
				{
					strcpy(setup_info.mailto,ptemp);
				}
				else if(strncmp(temp,SUBJECT,strlen(SUBJECT))==OK)
				{
					strcpy(setup_info.subject,ptemp);
				}
				else if(strncmp(temp,MAILPATH,strlen(MAILPATH))==OK)
				{
					strcpy(setup_info.mailpath,ptemp);
				}
				else if(strncmp(temp,DATAPATH,strlen(DATAPATH))==OK)
				{
					strcpy(setup_info.datapath,ptemp);
				}
				else if(strncmp(temp,ADRESS,strlen(ADRESS))==OK)
				{
					strcpy(setup_info.m_adress,ptemp);
				}
				else if(strncmp(temp,ORDER,strlen(ORDER))==OK)
				{
					if(order_count<MAX_ORDER)
						load_list(ptemp,order_count++);
				}
				else
				{
					printf("Unknown Comand:%s\n",temp);
					getch();
				}
			}
		}
		fclose(config);
		return(TRUE);
	}
	else
	{
		error=TRUE;
		strcpy(errmess,"Konfigurationsfil kan inte hittas!");
		return(FALSE);
	}
	
}
/**********************************************************************/
/* load_list: inladdning av en varulista                              */
/**********************************************************************/
int load_list(char *listname, int orderlistnum)
{
	FILE *listfile;
	char temp[TMP_S_S], *count1, *count2;
	orderlista *aktuell;

	if((listfile=fopen(listname,"r"))!=NULL)
	{
		if(fgets(temp, MAX_DESC, listfile)!=NULL)
		{
			strcpy(orderinfo[orderlistnum],temp);
			while(fgets(temp, TMP_S_S, listfile)!=NULL)
			{
				if(orderbest[orderlistnum]==NULL)
				{
					orderbest[orderlistnum]=(orderlista *)malloc(sizeof(orderlista));
					orderbest[orderlistnum]->prev=NULL;
					orderbest[orderlistnum]->next=NULL;
					aktuell=orderbest[orderlistnum];
				}
				else
				{
					aktuell->next=(orderlista *)malloc(sizeof(orderlista));
					aktuell->next->prev=aktuell;
					aktuell=aktuell->next;
					aktuell->next=NULL;
				}
				aktuell->antal=atoi(temp);
				count1=(char *)strchr(temp,TAB); *count1=EOL; count1++;
				aktuell->pris=atoi(count1);
				count1=(char *)strchr(count1,TAB); *count1=EOL; count1++;
				count2=(char *)strchr(count1,TAB); *count2=EOL; count2++;
				strcpy(aktuell->desc,count1);
				strcpy(aktuell->path,count2);
				aktuell->best_antal=0;
			}
			return(TRUE);
		}
		else
		{
			error=TRUE;
			strcpy(errmess,"inga varor i varulista");
			return(FALSE);
		}
	}
	else
	{
		error=TRUE;
		strcpy(errmess,"Varufilen kan inte hittas");
		return(FALSE);
	}
}

/**********************************************************************/
/* clear_list: rensar en l„nkad lista                                 */
/**********************************************************************/
int clear_list(int orderlistnum)
{
	orderlista *aktuell1, *aktuell2;

	if(orderbest[orderlistnum]!=NULL)
	{
		aktuell1=orderbest[orderlistnum];
		orderbest[orderlistnum]=NULL;
		do
		{
			aktuell2=aktuell1->next;
			free(aktuell1);
			aktuell1=aktuell2;
		}while(aktuell1!=NULL);
		return(TRUE);
	}
	else
		return(FALSE);
}

/**********************************************************************/
/* Rensar hela listan                                                 */
/**********************************************************************/
int clear_all()
{
	int temp;
	
	fprintf(stdout,"\nVill du verkligen rensa alla dina markeringar?\n");
	if(toupper(getch())==JA)
	{
		for(temp=FIRST; temp<MAX_ORDER;temp++)
			clear_mark(temp);
	}
	return(TRUE);
}
/**********************************************************************/
/* clear_mark: rensar varulistan fr†n markeringar                     */
/**********************************************************************/
int clear_mark(int orderlistnum)
{
	orderlista *aktuell;

	aktuell=orderbest[orderlistnum];
	if(aktuell!=NULL)
	{
		do
		{
			aktuell->best_antal=0;
			aktuell=aktuell->next;
		}while(aktuell!=NULL);
	}
	return(TRUE);
}

/**********************************************************************/
/* check_mark: kollar om n†gon best„llning gjorts                     */
/**********************************************************************/
int check_mark()
{
	orderlista *aktuell;
	int counter=0, order=FALSE;
	
	do
	{
		aktuell=orderbest[counter];
		if(aktuell!=NULL)
		{
			do
			{
				if(aktuell->best_antal>0)
					order=TRUE;
				aktuell=aktuell->next;
			}while((aktuell!=NULL)&&(!order));
		}
		counter++;
	}while((counter<MAX_ORDER)&&(!order));
	if(order)
		return(TRUE);
	else
		return(FALSE);
}

/**********************************************************************/
/**********************************************************************/
int menu_placering()
{
	char *message;
	int temp;
	
	if(check_mark())
	{
		if((message=(char *)malloc(MAX_MESS))!=NULL)
		{
			make_order(message);
			printf("%s\n",message);
			getch();
			/*
			write_message(setup_info.mailpath,message);
			*/
			for(temp=FIRST; temp<MAX_ORDER; temp++)
				clear_mark(temp);
			free(message);
		}
		else
		{
			error=TRUE;
			strcpy(errmess,"Can't Allocate memory for the ordermessage");
			return(FALSE);
		}
		return(TRUE);
	}else
		return(FALSE);
}

/**********************************************************************/
/* Funktion f”r att skapa brevet med ordern!                          */
/**********************************************************************/
void make_order(char *message)
{
	int i,pris_in=0, pris_ut=0, best_in=0, best_ut=0;
	int temp_ut=FALSE, temp_in=FALSE;
	orderlista *aktuell;
	char temp[TMP_S_S];
	
	message[FIRST]=EOL;
	strcpy(message,setup_info.name);
	addspc(message,MAX_NAME+2-strlen(setup_info.name));
	strcat(message,"TLF: ");
	strcat(message,setup_info.p_home);
	addspc(message,20-strlen(setup_info.p_home));
	strcat(message,"Kundnummer: ");
	strcat(message,setup_info.kundnr);
	strcat(message,"\n");
	strcat(message,setup_info.street);
	addspc(message,MAX_NAME+2-strlen(setup_info.street));
	strcat(message,"BBS: ");
	strcat(message,setup_info.p_bbs);
	strcat(message,"\n");
	strcat(message,setup_info.city);
	addspc(message,MAX_NAME+2-strlen(setup_info.city));
	strcat(message,"FAX: ");
	strcat(message,setup_info.p_fax);
	strcat(message,"\n\n");

	for(i=FIRST; i<MAX_ORDER; i++)
	{
		aktuell=orderbest[i];
		while(aktuell!=NULL)
		{
			if(aktuell->best_antal>0)
			{
				if(aktuell->antal > aktuell->best_antal)
				{
					temp_in=TRUE;
					if(best_in==0)
						strcat(message,"_Antal   Vara i lager                                                 Pris_\n");
					best_in+=aktuell->best_antal;
					pris_in+=aktuell->pris*aktuell->best_antal;
					sprintf(temp,"%5d    ",aktuell->best_antal);
					strcat(message,temp);
					strcat(message,aktuell->desc);
					addspc(message,MAX_DESC+2-strlen(aktuell->desc));
					sprintf(temp,"%6d",aktuell->pris);
					strcat(message,temp);
					strcat(message,"\n");
				}
				else
				{
					temp_ut=TRUE;
					if(aktuell->antal!=0)
					{
					temp_in=TRUE;
						if(best_in==0)
							strcat(message,"_Antal   Vara i lager                                                 Pris_\n");
						best_in+=aktuell->antal;
						pris_in+=aktuell->pris*aktuell->antal;
						sprintf(temp,"%5d    ",aktuell->antal);
						strcat(message,temp);
						strcat(message,aktuell->desc);
						addspc(message,MAX_DESC+2-strlen(aktuell->desc));
						sprintf(temp,"%6d",aktuell->pris);
						strcat(message,temp);
						strcat(message,"\n");
					}
				}
				if(temp_in)
				{
				}
			}
			aktuell=aktuell->next;
		}
	}
	if(temp_ut)
	{
		strcat(message,"_Antal   Vara Ej i lager                                              Pris_\n");
		for(i=FIRST; i<MAX_ORDER; i++)
		{
			aktuell=orderbest[i];
			while(aktuell!=NULL)
			{
				if(aktuell->best_antal>0)
				{
					if(aktuell->best_antal > aktuell->antal)
					{
						best_ut+=aktuell->best_antal-aktuell->antal;
						pris_ut+=aktuell->pris*(aktuell->best_antal-aktuell->antal);
						sprintf(temp,"%5d    ",aktuell->best_antal-aktuell->antal);
						strcat(message,temp);
						strcat(message,aktuell->desc);
						addspc(message,MAX_DESC+2-strlen(aktuell->desc));
						sprintf(temp,"%6d",aktuell->pris);
						strcat(message,temp);
						strcat(message,"\n");
					}
				}
				aktuell=aktuell->next;
			}
		}
	}
	strcat(message,"_Totalt                                                               Pris_\n");
	
	if(temp_in)
	{
		sprintf(temp,"%5d    ",best_in);
		strcat(message,temp);
		strcat(message,"Varor i lager                                            ");
		sprintf(temp,"%7d\n",pris_in);
		strcat(message,temp);
	}
	if(temp_ut)
	{
		sprintf(temp,"%5d    ",best_ut);
		strcat(message,temp);
		strcat(message,"Varor Ej i lager                                         ");
		sprintf(temp,"%7d\n",pris_ut);
		strcat(message,temp);
	}
	strcat(message,"                                                                    ------\n");
	addspc(message,66);
	sprintf(temp,"%7d\n",pris_ut+pris_in);
	strcat(message,temp);
	
}

void addspc(char *string, int size)
{
	while(size-->0)
		strcat(string," ");
}
/**********************************************************************/
/* menu_order: Sj„lva huvud-menyn till order-programmet               */
/**********************************************************************/
int menu_order(void)
{
	int redraw=FALSE, exit=FALSE;
	int temp;

	show_order_menu();
	do
	{
		redraw=FALSE, exit=FALSE;
		temp=getch();
		switch(toupper(temp))
		{
			case '0':
				redraw=menu_best(0);
				break;
			case '1':
				redraw=menu_best(1);
				break;
			case '2':
				redraw=menu_best(2);
				break;
			case '3':
				redraw=menu_best(3);
				break;
			case '4':
				redraw=menu_best(4);
				break;
			case '5':
				redraw=menu_best(5);
				break;
			case '6':
				redraw=menu_best(6);
				break;
			case '7':
				redraw=menu_best(7);
				break;
			case '8':
				redraw=menu_best(8);
				break;
			case '9': 
				redraw=menu_best(9);
				break;
			case LIST: 
				redraw=show_list(); 
				break;
			case PLACE: 
				if(check_mark()) 
				{ 
					menu_placering(); 
					redraw=TRUE; 
				} 
				break;
			case CLEAR:
				if(check_mark())
				{
					clear_all();
					redraw=TRUE;
				}
				break;
			case YELL:
				yell();
				redraw=TRUE;
				break;
			case QUIT:
				exit=h_quit();
				redraw=!exit;
				break;
		}

	if(redraw)
		show_order_menu();
		
	}while(!exit && !error);
	return(error);
}

/**********************************************************************/
/**********************************************************************/
int h_quit()
{
	if(check_mark())
	{
		fprintf(stdout,"\nDu har markerade varor! vill du „nd† sluta?\n");
		if(toupper(getch())==JA)
			return(TRUE);
		else
			return(FALSE);
	}else
		return(TRUE);
}
/**********************************************************************/
/* test_best_menu: hanterar best„llningsmenyn                         */
/**********************************************************************/
int menu_best(orderlistnum)
{
	int redraw, exit;
	int key, row=1, counter;
	orderlista *aktuell=orderbest[orderlistnum], *t_aktuell;
	orderlista *temp
	if(aktuell!=NULL)
	{
		show_best_menu(orderlistnum);
	
		fprintf(stdout,"\33Y%c\47\33p%60s\33q",row+35,aktuell->desc);
		do
		{
			redraw=FALSE, exit=FALSE;
			key=getch();
			switch(toupper(key))
			{
				case 0:
					key=getch();
					switch(key)
					{
						case UP:
							if((aktuell->prev!=NULL)&&(row>1))
							{
								fprintf(stdout,"\33Y%c\47\33q%60s\33q",row+35,aktuell->desc);
								row--;
								aktuell=aktuell->prev;
								fprintf(stdout,"\33Y%c\47\33p%60s\33q",row+35,aktuell->desc);
							}
							else if((aktuell->prev!=NULL)&&(row==1))
							{
								fprintf(stdout,"\33Y%c\47\33q%60s\33q",row+35,aktuell->desc);
								aktuell=aktuell->prev;
								t_aktuell=aktuell;
								for(counter=1; counter<15; counter++)
								{
									if(t_aktuell->prev!=NULL)
									{
										t_aktuell=t_aktuell->prev;
										row++;
									}
								}
								for(counter=1; counter<=15;counter++)
								{
									if((t_aktuell!=NULL))
									{
										if (t_aktuell->best_antal>0)
											fprintf(stdout,"\33q\33Y%c %5d  %60s   %5d",counter+35,t_aktuell->best_antal,t_aktuell->desc,t_aktuell->pris);
										else
											fprintf(stdout,"\33q\33Y%c        %60s   %5d",counter+35,t_aktuell->desc,t_aktuell->pris);
										t_aktuell=t_aktuell->next;
									}else
										fprintf(stdout,"\33q\33Y%c \33l",counter+35);
								}
								aktuell=t_aktuell->prev;
								fprintf(stdout,"\33p\33Y%c\47%60s\33q",row+35,aktuell->desc);
							}
							break;
						case DOWN:
							if ((aktuell->next!=NULL)&&(row<15))
							{
								fprintf(stdout,"\33q\33Y%c\47%60s\33q",row+35,aktuell->desc);
								row++;
								aktuell=aktuell->next;
								fprintf(stdout,"\33p\33Y%c\47%60s\33q",row+35,aktuell->desc);
							}
							else if((aktuell->next!=NULL)&&(row==15))
							{
								fprintf(stdout,"\33q\33Y%c\47%60s\33q",row+35,aktuell->desc);
								row=1;
								aktuell=aktuell->next;
								t_aktuell=aktuell;
								for(counter=1; counter<=15;counter++)
								{
									if((t_aktuell!=NULL))
									{
										if (t_aktuell->best_antal>0)
											fprintf(stdout,"\33q\33Y%c %5d  %60s   %5d",counter+35,t_aktuell->best_antal,t_aktuell->desc,t_aktuell->pris);
										else
											fprintf(stdout,"\33q\33Y%c        %60s   %5d",counter+35,t_aktuell->desc,t_aktuell->pris);
										t_aktuell=t_aktuell->next;
									}else
										fprintf(stdout,"\33q\33Y%c \33l",counter+35);
								}
							}
							fprintf(stdout,"\33p\33Y%c\47%60s\33q",row+35,aktuell->desc);
							break;
						case RIGHT:
							/* En sida ner */
							break;
						case LEFT:
							/* En sida upp */
							break;
					}
					break;
				case MARK:
					if(aktuell->best_antal<10)
					{
						aktuell->best_antal++;
						fprintf(stdout,"\33q\33Y%c %5d  \33p%60s\33q   %5d\n",row+35,aktuell->best_antal,aktuell->desc,aktuell->pris);
					}
					break;
				case DSEL:
					if(aktuell->best_antal>0)
					{
						aktuell->best_antal--;
						if(aktuell->best_antal>0)
							fprintf(stdout,"\33q\33Y%c %5d  \33p%60s\33q   %5d\n",row+35,aktuell->best_antal,aktuell->desc,aktuell->pris);
						else
							fprintf(stdout,"\33q\33Y%c        \33p%60s\33q   %5d\n",row+35,aktuell->desc,aktuell->pris);
					}else
						fprintf(stdout,"\33q\33Y%c        \33p%60s\33q   %5d\n",row+35,aktuell->desc,aktuell->pris);
					break;
				case YELL:
					yell();
					redraw=TRUE;
					break;
				case QUIT:
					exit=TRUE;
					break;
			}
		if (redraw)
			show_best_menu(orderlistnum);
		
		}while(!exit);
		return(TRUE);
	}
	return(FALSE);
}	

/**********************************************************************/
/* show_list: fixar s† att man kan anv„nda list-menyn                 */
/**********************************************************************/
int show_list(void)
{
	int list=0, row=0;
	orderlista *aktuell;
	int antal=0, pris=0;
	
	for(list=0; list<MAX_ORDER; list++)
	{
		aktuell=orderbest[list];
		while(aktuell!=NULL)
		{
			if(aktuell->best_antal>0)
			{
				if(antal=0)
					fprintf(stdout,"\33E");
				fprintf(stdout,"%5d %60s %5d\n",aktuell->best_antal,aktuell->desc,aktuell->pris);
				antal+=aktuell->best_antal;
				pris+=aktuell->pris*aktuell->best_antal;
				if(++row==setup_info.screenheight)
				{
					fprintf(stdout,"Tryck en Tangent f”r att forts„tta\n");
					getch();
					row=0;
				}
			}
			aktuell=aktuell->next;
		}
	}
	if(antal>0)
	{
		fprintf(stdout,"Totalt:%4d varor f”r %6d:- ",antal,pris);
		fprintf(stdout,"Tryck en Tangent f”r att forts„tta\n");
		getch();
		return(TRUE);
	}else
		return(FALSE);
}

/**********************************************************************/
/* show_order menu: Visar Order-huvud-menyn                           */
/**********************************************************************/
void show_order_menu()
{
	int c1,c2;
	
	fprintf(stdout,"\33E");	
	fprintf(stdout,"ÄÄÄÄÍÍÍÍ Firestorm Falcon Center (Order Menyn)ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÄÄÄ\n\r");
	fprintf(stdout,"     ÉÍÍÍËOrder AvdelningarÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»\n\r");
	for(c1=0, c2=0; c1<MAX_ORDER; c1++)
		if(orderinfo[c1][FIRST]!=EOL)
			fprintf(stdout,"     º %d º %s \33Y%c\\º\n\r",c1,orderinfo[c1],(c2++) +34);
	fprintf(stdout,"     ÌÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹\n\r");
	fprintf(stdout,"     º L º Lista Best„llda Varor                            º\n\r");
	fprintf(stdout,"     º R º Rensa listan ”ver best„llda varor                º\n\r");
	fprintf(stdout,"     ÌÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹\n\r");
	fprintf(stdout,"     º P º Placera Ordern                                   º\n\r");
	fprintf(stdout,"     ÈÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼\n\r");
	fprintf(stdout,"\n");
	fprintf(stdout,"                    ÉÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»\n\r");
	fprintf(stdout,"                    º Y º Ropa p† SysOp (f”r Hj„lp) º\n\r");
	fprintf(stdout,"                    º Q º Tillbaka till Huvudmenyn  º\n\r");
	fprintf(stdout,"                    ÈÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼\n\r");
}

/**********************************************************************/
/* show_best_menu: Visar menyn d„r man kan markera varor mm           */
/**********************************************************************/
void show_best_menu(int orderlistnum)
{
	orderlista *aktuell;
	int counter;
	
	aktuell=orderbest[orderlistnum];

	printf("\33E");	
	fprintf(stdout,"ÄÄÄÄÍÍÍÍ Firestorm Falcon Center (Best„llningsmenyn)ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÄÄÄ\n");
	fprintf(stdout,"ÉÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍ»\n");
	fprintf(stdout,"º M? º Vara/Titel                                                   º Pris º\n");
	fprintf(stdout,"ÈÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍ¼\n");

	for(counter=1; counter<=15;counter++)
	{
		if((aktuell!=NULL))
		{
			if(aktuell->best_antal>0)
				fprintf(stdout,"%5d  %60s   %5d\n",aktuell->best_antal,aktuell->desc,aktuell->pris);
			else
				fprintf(stdout,"       %60s   %5d\n",aktuell->desc,aktuell->pris);
			aktuell=aktuell->next;
		}else
			fprintf(stdout,"\n");
	}

	fprintf(stdout,"ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»\n");
	fprintf(stdout,"º M - Markera vara º D - Avmarkera vara º Q - Tillbaka till Order  º\n");
	fprintf(stdout,"ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹\n");
	fprintf(stdout,"º N/P - Byt sida   º Y - Ropa p† sysop  º S - Visa Information     º\n");
	fprintf(stdout,"ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼\n");
	fprintf(stdout,"\33Y$ ");
}

/**********************************************************************/
/* Funktionen f”r att skriva ett meddelande!                          */
/**********************************************************************/
int write_message(char *areapath,char *message)
{
	FILE   *file_hdr, *file_msg;
	HDR_HEADER mess_hdr;

	set_header(&mess_hdr);
	mess_open(areapath, &file_hdr, &file_msg);
	mess_write(message, file_hdr, file_msg);
	mess_close(file_hdr, file_msg);

	return(TRUE);
}

/**********************************************************************/
/* S„tter Headern till "r„tt" inneh†ll                                */
/**********************************************************************/
void set_header(HDR_HEADER *pmess_hdr)
{
	int i;
	
	for(i=FIRST; i<MAX_NAME; i++)
	{
		pmess_hdr->sTo[i]=EOL;
		pmess_hdr->sFrom[i]=EOL;
	}

	strcpy(pmess_hdr->sTo,setup_info.mailto);
	strcpy(pmess_hdr->sFrom,setup_info.name);
}

/**********************************************************************/
/**********************************************************************/
void mess_open(char *area, FILE **pfile_hdr, FILE **pfile_msg)
{
	char temp[255];
	
	strcpy(temp,area); 
	strcat(temp,".hdr");
	*pfile_hdr=fopen(temp,"rb+");

	strcpy(temp,area);
	strcat(temp,".msg");
	*pfile_msg=fopen(temp,"rb+");


}

/**********************************************************************/
/**********************************************************************/
void mess_write(char *message, FILE *pfile_hdr, FILE *pfile_msg)
{

	fseek(pfile_msg,0,SEEK_END);
}	

/**********************************************************************/
/**********************************************************************/
void mess_close(FILE *pfile_hdr,FILE *pfile_msg)
{

	fclose(pfile_msg);
	fclose(pfile_hdr);
}

/**********************************************************************/
/* Rutin f”r att sk”ta Yellandet!                                     */
/**********************************************************************/
void yell(void)
{
	
}


/**********************************************************************/
/* Seriella rutiner                                                   */
/**********************************************************************/
int checkmfp(void)    /* Kollar om carrier finns p† MFP-porten */
{
	short *stack;
	char mfp;

	stack = Super((short *)NULL);
	mfp = *((char *)(0xfffffa01));
	Super(stack);
	if(!(mfp & 2))
		return TRUE;
	return FALSE;
}

int checkscc(int select)    /* Kollar om carrier finns p† SCC */
{
	short *stack;
	char scc,*pek;

	pek = (char *)(0xff8c80 + select);
	stack = Super((short *)NULL);
	scc = *pek;    /* Var s„ker p† att vi f†r v„lja register */
	*pek = 0;      /* V„lj register */
	scc = *pek;    /* H„mta information */
	Super(stack);
	if(!(scc & 8))
		return TRUE;
	return FALSE;
}

int checkcarrier(void)      /* Kollar om carrier finns */
{
  	if(setup_info.serialf)
    	return TRUE;
	switch(setup_info.serialport){
	{
		case  1 :                      /* AUX */
		case  2 :                      /* KEYB/SCREEN */
			return FALSE;
		case  3 :                      /* MIDI */
			return TRUE;
		case  6 :                      /* MODEM1 */
			return CheckMFP();
		case  7 :                      /* MODEM2 */
			return CheckSCC(5);
		case  8 :                      /* SERIAL1 */
			return TRUE;
		case  9 :                      /* SERIAL2 */
			return CheckSCC(1);
		default :  return FALSE;
	}
	return FALSE;
}

unsigned char character(void)    /* Inv„ntar/tolkar en tangenttryckning */
{
	int timeout;
	long character = NULL,t;

	timeout = setup_info.timeout;    /* Inaktivitetstimeout */

  do{
    if(Screen){
      if(Bconstat(SCREEN) == -1){
        character = Bconin(SCREEN);    /* H„mta tangent */
        if(!(character & 0xFF)){
          switch(character){          /* En lokal konstighet */
            case 0x4B0000 : character = CURSORLEFT;    /* V„nster */
                            break;
            case 0x4D0000 : character = CURSORRIGHT;  /* H”ger */
                            break;
            case 0x480000 : character = CURSORUP;      /* Upp */
                            break;
            case 0x500000 : character = CURSORDOWN;    /* Ner */
                            break;
            default        : character = NOLL;
                            break;
          }
        }
      }
    }
    if(Serial){          /* Ta emot tangenter fr†n serieporten? */
      if(Bconstat(SERIAL) == -1){
        character = Bconin(SERIAL);
        character &= 0xFF;
        if(character == ESC)  /* Ja, se till att konvertera piltangenter */
          Esc = TRUE;
        if(Esc){
          switch(character){
            case 'A'  : character = CURSORUP,Esc = FALSE;    /* Upp enl. VT-52 
*/
                        break;
            case 'B'  : character = CURSORDOWN,Esc = FALSE;  /* Ner enl. VT-52 
*/
                        break;
            case 'C'  : character = CURSORRIGHT,Esc = FALSE;/* H”ger enl. VT-52 
*/
                        break;
            case 'D'  : character = CURSORLEFT,Esc = FALSE;  /* V„nster enl. 
VT-52 */
                        break;

            case '['  :
            case ESC  : character = NOLL;
                        break;
            default    : Esc = FALSE;
          }
        }
        else
          Esc = FALSE;
      }
    }
    time(&t);
    if(t != Time){
      Time = t;
      timeout-=2;
      msginfo.seconds_left-=2;
      if(Serial)
        if(!CheckCarrier())
          shutdown = CARRIERLOST,character = LOGOUT;
    }
    if(timeout < NOLL || msginfo.seconds_left < NOLL)
      character = LOGOUT,shutdown = TIMEOUT;
  } while((character & 0xFF) == NOLL);

  return (unsigned char)(character & 0xFF);
}


void preform(unsigned char tangent)  /* Utf”r n†nting */
{
  switch(tangent){
    case 17 : if(kill_text())
                shutdown = ABORTTEXT;    /* <CTRL> + Q */
              else{
                RedrawMenu(FALSE);  /* Rita ut f”rsta raden i menyn */
                if(Y == SUBJ || Y == TO)
                  ReverseOn();
                GoToXY(X,Y);
              }
              break;

    case 19 :                         /* <CTRL> + S */
    case 26 : shutdown = SAVETEXT;    /* <CTRL> + Z */
              break;

    case 21 : X = oldX = strlen(currenttext);  /* <CTRL> + U */
              GoToXY(X,Y);
              NewLineHere();
              break;

    case 22 : ShowNextPage();          /* <CTRL> + V */
              break;

    case 3  : ShowPrevPage();          /* <CTRL> + C */
              break;

    case 12 :                         /* <CTRL> + L */
    case 18 : MoveRowToMessage();      /* <CTRL> + R */
              RedrawMenu(TRUE);    /* Rita upp menyn */
              RedrawWholeText();  /* Skriv ut texten */
              if(Y == TO || Y == SUBJ)
                ReverseOn();
              break;

    case 1  :  X = oldX = NOLL; GoToXY(X,Y); break;  /* <CTRL> + A */

    case 5  :  X = oldX = strlen(currenttext);  /* <CTRL> + E */
              GoToXY(X,Y); break;

    case 8  : backspace();      /* Backspace */
              break;

    case 127:  delete();          /* Delete */
              break;

    case 11 :                    /* <CTRL> + K */
    case 25  : DeleteThisLine();  /* <CTRL> + Y  Ta bort aktuell rad */
              break;

    case 13 : NewLineHere();    /* Ny rad nu genast */
              break;

    case 4  : StartEditSubject();  /* <CTRL> + D */
              break;

    case 20 : StartEditTo();    /* <CTRL> + T */
              break;

    case CURSORLEFT:          /* Cursor left */
              move_left();
              break;

    case CURSORRIGHT:          /* Cursor right */
              move_right();
              break;

    case CURSORUP:          /* Cursor up */
              move_up(TRUE);
              break;

    case CURSORDOWN:          /* Cursor down */
              move_down(TRUE);
              break;

    case LOGOUT  : break;      /* Loggutkod */

    default : if(tangent < ' '){
                MoveRowToMessage();
                show_help_screen();
                RedrawMenu(TRUE);    /* Rita upp menyn */
                RedrawWholeText();  /* Skriv ut texten */
                if(Y == TO || Y == SUBJ)
                  ReverseOn();
              }
              else
                InsertCharacter(tangent);    /* Ett tecken att l„gga in */
              break;
  }
}



D„r har vi n†gra huvudrutiner...

void Put(int dest,char *string)
{
  register i;

  for(i = 0;*(string + i) != (char)NULL;i++)
     Bconout(dest,*(string + i));
}


void Print(char *t1,char *t2)    /* Allm„n runtin f”r att skriva ut text */
{        /* t1 = VT52-emulering      t2 = ANSI-emulering */
  if(Screen)
    Put(SCREEN,t1);    /* Om till sk„rmen skriv ut VT52 */
  if(Serial)          /* Om till porten skriv med r„tt emulering */
    switch(msginfo.emulation){
      case ASCII      : exit(-1); break; /* ASCIIanv„ndare kan ej anv„nda CeD */
      case ANSICOLOR  :
      case ANSIMONO    :
      case AVATAR      :  Put(SERIAL,t2);
                        break;
      case VT52COLOR  :
      case VT52MONO    :
      case VT52FALCON  :  Put(SERIAL,t1);
                        break;
    }
}

void ResetTerminal(void)   /* Resettar terminalen */
{
  Print("ewqb?c0E","[?5h[?7l[?1l[?3l[?9l[?6l#5[4l[0;37;40m[2J");
}

void GoToXY(int x,int y)
{
  if(Y == TO || Y == SUBJ)
    x += START;

  sprintf(out,"Y%c%c",(char)(y+32),(char)(x+32));
  sprintf(out2,"[%d;%dH",(char)(y+1),(char)(x+1));

  Print(out,out2);
}



S†d„r, d„r har du n†gra rutiner att leka med. CheckSCC fungerar
inte som du vet...
CD






