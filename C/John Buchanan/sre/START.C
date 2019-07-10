/*

	Start.c:

	Programmer: John Buchanan

	Status:	    Public domain

*/

#include <stdio.h>
#include <osbind.h>
#include <vt52.h>
#define peekb(cp) 	(*((char *)cp))
#define pokeb(cp,c)	(*((char *)cp)=c)
#define DATAFILE	"\\auto\\start.inf"
#define FALSE		0
#define TRUE		!FALSE


typedef struct 
	{
	char name[40];
	char parameters[128];
	struct command *next;
	}command;

typedef struct 
	{
	char title[80];
	struct command *todo;
	struct menu_entry *next_menu;
	}menu_entry;

/*extern struct menu_entry *malloc();*/
struct menu_entry *head = NULL;
struct menu_entry *curr = NULL;
struct command *Comm_Head, *Comm_curr;
int menu_count = 0;


main()
	{
	char i;
	int  Message = FALSE;
	extern FILE *fopen();
	FILE *fp;
	char buffer[80];
	struct menu_entry *curr = NULL;
	int Processing_Menu = FALSE;

	if((fp =fopen(DATAFILE,"r")) == NULL)
		{
		sprintf(buffer,"Could not find %s \n",DATAFILE);
		fatal(buffer);
		exit(1);
		}

	New_Menu("Startup stuff");
	
	while(fgets(buffer,80,fp)!=NULL) 
		{
		if (buffer[0] == '\'')
			{
			if (!Message)
				{
				Clear_Home();
				Inverse_On();
				printf("Please read this message and then press\n");
				printf("Return to continue\n\n");
				Inverse_Off();
				}
			Message = TRUE;
			printf("%s",&buffer[1]);
			}
		if (my_strcmp(buffer,"#START",6)== 0)
			goto Start_Menu;
		if (buffer[0] != '#' && buffer[0] != '\'' )
			New_Entry(buffer);
		}

Start_Menu:
	if (Message)
		{
		char t[80];
		Pos_Cursor(0,25);
		Inverse_On();
		printf("Press return to continue... ");
		Inverse_Off();
		gets(t);
		}
	Do_Menu(1);
	head = NULL;
	/* Check to see if any of the control keys are pressed */
	i = peekb(0xE1BL);
	if (i != 0) /* A control key is pressed */
		{

		while(fgets(buffer,80,fp)!=NULL) 
			{
			if (my_strcmp(buffer,"#CONTROL",6)== 0)
				goto Cont_Control;
			}
Cont_Control:
		while(fgets(buffer,80,fp) != NULL)
			{
			if (buffer[0] != '#') /* Ignore comments */
				{
				if(buffer[0] != '\t')
					{
					Processing_Menu=TRUE;
					New_Menu(buffer);
					}
				else
					{ /* Ignore options with out
						menu*/
					if(Processing_Menu)
						New_Entry(buffer);
					}
				}
			}
		fclose(fp);
		Choose_Menu();
		} /* A control key is pressed */
	else
		{

		while(fgets(buffer,80,fp) != NULL)
			{
			if (my_strcmp(buffer,"#CONTROL",6)== 0)
				goto Cont_No_Control;

			if (buffer[0] != '#') /* Ignore comments */
				{
				if(buffer[0] != '\t')
					{
					Processing_Menu=TRUE;
					New_Menu(buffer);
					}
				else
					{ /* Ignore options with out
						menu*/
					if(Processing_Menu)
						New_Entry(buffer);
					}
				}
			}
Cont_No_Control:			
		fclose(fp);
		Choose_Menu();
		}
	}

my_strcmp(s,t,i)
char s[],t[];
int i;
	{
	int j;
	for (j=0;j<i;j++)
		if (s[j] != t[j])
			return (s[j]-t[j]);
	return(0);
	}


New_Menu(s)
char s[];
	{
	if (head == NULL)
		if((head = malloc(sizeof(menu_entry)) )!=NULL)
			{
			Init_Menu(head,s);	/* Insert the menu     	*/
			curr = head;		/* Set current pointer 	*/
			}
		else
			fatal("Could not allocate memory");
	else
		if((curr->next_menu = malloc(sizeof(menu_entry))) != NULL)
			{
			curr = curr->next_menu;	/* Advance current	*/
			Init_Menu(curr,s);	/* Next Menu		*/
			}
		else
			fatal("Could not allocate memory");
	}

Init_Menu(point,s)
struct menu_entry *point;
char s[];
/*
Insert a menu into the list and initialize the pointers 
*/
	{
	strcpy(point->name,s);
	point->todo = NULL;
	point->next_menu = NULL;
	}


New_Entry(s)
char s[];
/*
insert a new entry into the todo list
*/
	{
	char Local_Command[40];
	char Local_Parameters[128];
	Strip_Cr(s);				/* Strip the cr 	*/
	Split_Line(s,Local_Command,Local_Parameters);
	Init_Entry(Local_Command,Local_Parameters);
	}

Init_Entry(Command,Parameters)
char Command[],Parameters[];
/* 
Do the actual work of the  insert
*/
	{
	struct command *Local_Curr;
	Local_Curr = curr->todo;

	if (Local_Curr==NULL)
		{
		if((curr->todo = malloc(sizeof(command)) )!=NULL)
			{			/* Init node		*/
			strcpy(curr->todo->name,Command);	
			strcpy(curr->todo->parameters,Parameters);
			curr->todo->next = NULL;
			}
		else
			fatal("Could not allocate memory");
		}
	else
		{
		while(Local_Curr->next != NULL)	/* FInd end of list	*/
			{
			Local_Curr = Local_Curr->next;
			}
		if((Local_Curr->next = malloc(sizeof(command)) )!=NULL)
			{			/* Init node		*/
			Local_Curr = Local_Curr->next;
			strcpy(Local_Curr->name,Command);	
			strcpy(Local_Curr->parameters,Parameters);
			Local_Curr->next = NULL;
			}
		else
			fatal("Could not allocate memory");
		}
	
	}

Split_Line(s,Command,Parameters)
char s[],Command[],Parameters[];
/*  
Return the Command and the Parameters
*/
	{
	int i,j;
	i=0;
	while((s[i] == '\t') || (s[i] == ' '))	/* Strip leading	*/
		i++;				/* white space		*/
	j=0;
	while((s[i] != '\t') && (s[i] != ' ')   /* Copy			*/
			&& (s[i] !='\0'))	/*   the		*/
		Command[j++]=s[i++];		/*   command		*/
	Command[j] = '\0';

	if (s[i]=='\0')				/* There are		*/
		{				/* 	No		*/
		Parameters[0]='\0';		/* Parameters		*/
		Parameters[1]='\0';		/*   So return		*/
		return(1);			
		}

	while((s[i] == '\t') || (s[i] == ' '))	/* Strip In between	*/
		i++;				/* white space		*/

	j=1;
	while(s[i] != '\0')			/*   Copy the		*/
		Parameters[j++]=s[i++];		/*   Parameters		*/
	Parameters[j] = '\0';			/*     and 		*/
	Parameters[0] = (char)(j-1);		/*   Fix the coount char*/
	}
		
Strip_Cr(s)
char s[];
	/* return a string with cr -> \0 so that Pexec does not complain*/
	{
	int i;
	for (i=0;s[i]!='\n';i++);
	s[i]='\0';
	}
#define OFFSET	3				/* offset for menu 	*/

Choose_Menu()
	{
	int i=1;
	int choice;

	curr=head;
	if (curr == NULL)
		return;
	
	Clear_Home();
	/* Print out the title */
	printf("                              Start  ST\n");
	printf("                              ^~^~^~^~^\n\n");
	Show_Cursor();
	while(curr)
		{
		printf("%d) %s",i,curr->title);
		i++;
		curr = curr->next_menu;
		}
	Pos_Cursor(0,1+i+OFFSET);
	printf("Please enter the number corresponding to the appropriate choice\n\
And then press the <RETURN> key\n>");
	choice = GetNumber();
	while(!(choice > 0 && choice <i))
		{
		Pos_Cursor(0,i+OFFSET);
		printf("%c",'\007');
		Inverse_On();
		printf("Error Try again\n");
		Inverse_Off();
		printf("Please enter the number corresponding to the appropriate choice \n\
And then press the <RETURN> key\n>");
		Pos_Cursor(0,i+3+OFFSET);
		Clear_Eol();
		scanf("%d",&choice);
		}
	Do_Menu(choice);
		
	}

GetNumber()
	/* Return the first number on the input line */
	{
	int i;
	char InLine[40];
	gets(InLine);					/* Get the line   */
	if (sscanf(InLine,"%d",&i)!= 1)
		return(0);				/* No number found*/
	return(i);					/* Yes num found  */
	}
Do_Menu(choice)
int choice;
	/* Implement the choice of the menu */
	{
	int i;
	struct menu_entry *Local_Head;
	struct command	  *curr;

	Local_Head = head;
	for(i=1;i<choice;i++)			/* FInd the entry 	*/
		Local_Head=Local_Head->next_menu;
	curr = Local_Head->todo;
	while (curr != NULL)			/* Execute the entry	*/
		{
		printf("Executing %s %s\n",curr->name,&(curr->parameters)[1]);
#ifndef DEBUG		
		Pexec(0,curr->name,curr->parameters,"PATH=\0");
#endif
		curr= curr->next;
		}
	}
	
fatal(s)
char s[];
	{
	printf("start: %s\n",s);
	exit(1);
	}
	
