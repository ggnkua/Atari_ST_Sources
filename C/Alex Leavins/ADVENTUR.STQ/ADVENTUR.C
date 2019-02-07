/***************************************************************************/
/*                                                                         */
/*  Sample Adventure.  Written by Alex Leavins.  Rev. 1.61586              */
/*                                                                         */
/*  START magazine, Fall 1986.      Copyright 1986 by Antic Publishing     */
/*                                                                         */
/***************************************************************************/
/*
 * Demonstration adventure game and 
 * parsing language system
 * Rev. 1.61586
 *
 */

/*#include "obdefs.h"*/
#include "pdefine.h" /* 06.26.86 MGL */   
#include "osbind.h"
#include "easyc.h"
#include "game.h"

char *rooms[]={
" ",
"This is an open section of forest.  Exits lead east, south and north.",
"This is the edge of the forest.  A path leads west, and another one south.",
"We're standing in a clearing.  You can go north, or west.",
"There is a large rock here, with paths leading north, east and south.",
"The forest becomes very dense here.  The only exit is to the north."
};

char *obj_exam[]={
" ",
"It's a small paperback, titled 'Guide For Adventurers'.",
"It's a heavy single blade axe, with a very sharp blade.",
"It's a heavy gold coin.",
"It's a wooden stick."
};

char *objct[]={
" ",
"book",
"axe",
"coin",
"stick"
};

int north[]={ 0,1,0,2,1,4 },
    south[]={ 0,4,3,0,5,0 },
    east[]={  0,2,0,0,3,0 },
    west[]={  0,0,1,4,0,0 };

int where[]={ 0, 1, 2, 5, 3 };

char commands[]={
"NORTH*SOUTH*EAST*WEST*TAKE*DROP*THROW*READ*EXAMINE*INVENTORY*LOOK*QUIT*#"
};

char objects[]={
"BOOK*AXE*COIN*STICK*#"
};

char ast[]={ "*" };     /* test array for the character '*' */
char pnd[]={ "#" };     /* test array for the character '#' */
char spa[]={ " " };     /* test array for the character ' ' (a space)   */

int cmd_index, obj_index, position;
int flags[20];
int inventory[10];
char showword[20];
char objword[20];
char parser[120];
char test_word[120];

/* ------------------------- MAIN() ---------------------------*/

main()
{
        int i, temp1;

        init();         /* setup game variables */
        show_room(position);
        show_objects(position);

        /* Now play the game.  Game is an infinite loop... */

        WHILE (1)
                get_input();    /* Get input string */
                split_word();   /* seperate first word from string */
                cmd_index = scan_commands();    /* 1st word a command? */
                IF (cmd_index EQ OFF) THEN
                        printf("I don't understand that command.\n");
                ELSE
                        switch(cmd_index){
                                case NORTH:
                                case SOUTH:
                                case EAST:
                                case WEST:
                                        temp1 = move_us(cmd_index,position);
                                        IF (temp1 NE OFF) THEN
                                                position = temp1;
                                        ENDIF
                                        break;
                                
                                case TAKE:
                                        split_word();   /* get next word */
                                        obj_index = scan_objects();
                                        IF (obj_index EQ OFF) THEN
                                           printf("I don't know what that is.\n");
                                        ELSE
                                           take_object(obj_index);
                                        ENDIF
                                        break;

                                case DROP:
                                        split_word();   /* get next word */
                                        obj_index = scan_objects();
                                        IF (obj_index EQ OFF) THEN
                                           printf("I don't know what that is.\n");
                                        ELSE
                                           drop_object(obj_index);
                                        ENDIF
                                        break;
                                        
                                case LOOK:
                                        show_room(position);
                                        show_objects(position);
                                        break;

                                case INVENTORY:
                                        show_inventory();
                                        break;

                                case EXAMINE:
                                        split_word();   /* get next word */
                                        obj_index = scan_objects();
                                        IF (obj_index EQ OFF) THEN
                                           printf("I don't know what that is.\n");
                                        ELSE
                                           exam_object(obj_index);
                                        ENDIF
                                        break;

                                case READ:
                                        split_word();   /* get next word */
                                        obj_index = scan_objects();
                                        IF (obj_index EQ OFF) THEN
                                           printf("I don't know what that is.\n");
                                        ELSE
                                           read_object(obj_index);
                                        ENDIF
                                        break;

                                case THROW:
                                        split_word();   /* get next word */
                                        obj_index = scan_objects();
                                        IF (obj_index EQ OFF) THEN
                                           printf("I don't know what that is.\n");
                                        ELSE
                                           throw_object(obj_index);
                                        ENDIF
                                        break;

                                case QUIT:
                                        return;
                                        break;

                                default:
                                        break;

                        } /* End "switch(cmd_index)"    */
                ENDIF
        ENDWHILE
}

/*-------------------- SCAN_COMMANDS -----------------------*/

/* scan_commands():
 *   scan through our list of command words, and find if any
 *   one matches the current input word.
 */

scan_commands()
{
        int i,j,index,result;

        j = 0;
        index = 0;

        FOR (i = 0; i LT 100; i++)
                showword[j] = commands[i];
                IF (showword[j] EQ ast[0]) THEN
                        showword[j] = NULL;
                        j = 0;
                        index++;
                        result = strcmp(showword,test_word);
                        IF (result EQ 0) THEN
                                return(index);
                        ENDIF
                ELSEIF (showword[j] EQ pnd[0])
                        index = OFF;
                        break;
                ELSE
                        j++;
                ENDIF
        ENDFOR

return(index);
}

/*--------------------- SCAN_OBJECTS ---------------------*/

/* scan_objects():
 *   scan through our list of object words, and find if any
 *   one matches the current input word.
 */

scan_objects()
{
        int i,j,index,result;

        j = 0;
        index = 0;

        FOR (i = 0; i LT 100; i++)
                objword[j] = objects[i];
                IF (objword[j] EQ ast[0]) THEN
                        objword[j] = NULL;
                        j = 0;
                        index++;
                        result = strcmp(objword,test_word);
                        IF (result EQ 0) THEN
                                return(index);
                        ENDIF
                ELSEIF (objword[j] EQ pnd[0])
                        index = OFF;
                        break;
                ELSE
                        j++;
                ENDIF
        ENDFOR

return(index);
}

/* --------------------- SHOW_ROOM -----------------------*/

/* show_room()
 *   Shows what room we're currently in.
 */

show_room(what_room)
int what_room;
{
        printf("%s\n", rooms[what_room]);
}

/*---------------------- MOVE_US ---------------------------*/

/*  move_us()
 *   Moves the player around.
 *   Determines what direction the player asked for, then
 *   determines if that's a valid direction.  If it is, then
 *   the player is moved.  If it isn't, no move takes place.
 */

move_us(direction,posit)
int direction, posit;
{
        int i, j;
        
        switch (direction){
        
        case NORTH:
                i = north[posit];
                break;

        case SOUTH:
                i = south[posit];
                break;

        case EAST:
                i = east[posit];
                break;

        case WEST:
                i = west[posit];
                break;

        default:
                i = OFF;
                break;

        } /* End "switch (direction) " */

        IF (i EQ OFF) THEN
                printf("You can't go that way.\n");
                return(OFF);

        ELSE
                show_room(i);
                show_objects(i);
                return(i);
        ENDIF

}

/* --------------------- SPLIT_WORD --------------------*/

/* split_word()
 *   Splits the command string up, to find the next word in the
 * string.  A word is defined as any text delimited by a space.
 *
 */

split_word()
{
        int i,j;

        FOR (i = 0; i LT 100; i++)
                test_word[i] = parser[i+2];
                IF ((test_word[i] EQ spa[0]) OR
                    (i EQ parser[1]))        THEN
                        test_word[i] = NULL;
                        FOR (j = 0; j LT (100 - i); j++)
                                parser[j] = parser[i+j+1];
                        ENDFOR
                        parser[1] -= (i+1);
                        break;
                ENDIF
        ENDFOR

}

/* ------------------------ GET_INPUT ---------------------*/

/*
 * get_input()
 *  Gets the next command from the player
 *
 */

get_input()
{
        parser[0] = 100;
        parser[1] = 0;
        WHILE (parser[1] EQ 0)
                printf("-->");
                Cconrs(&parser[0]);
                printf("\n");
                IF (parser[1] EQ 0) THEN
                   printf("Say what?\n");
                ENDIF
        ENDWHILE
}

/* ----------------------------- INIT ------------------------*/

/*
 * Initial all global game variables
 *
 */

init()
{
        position = 1;   /* player starts in forest */

        printf("The Mini Adventure, by Alex Leavens\n");
        printf("  In START, the ST Resource\n");
        printf("  from ANTIC magazine.\n");
        printf("  Rev. 1.61686\n");
        printf("\n\n");
        printf("Please press the CAPS LOCK key.\n\n");
}

/* --------------------------- SHOW_OBJECTS ------------------*/

/*
 * Show_objects()
 *  This routine displays any object(s) that are in a room
 *
 */

show_objects(posit)
int posit;
{
        int j;

        FOR (j = 0; j LT 5; j++)
                IF (where[j] EQ posit) THEN
                        printf("There is a %s here.\n", objct[j]);
                ENDIF
        ENDFOR
}

/* ---------------------- SHOW_INVENTORY ------------------ */

/*
 * show_inventory()
 *   Shows what objects a player is carrying
 *
 */

show_inventory()
{
        int i, j, k;

        k = 0;
        printf("You are currently carrying:\n");

        FOR (j = 0; j LT 5; j++)
                IF (inventory[j] EQ ON) THEN
                        printf("  a %s.\n", objct[j]);
                        k = 1;
                ENDIF
        ENDFOR
        
        IF (k EQ OFF) THEN
                printf("Nothing at all\n");
        ENDIF
}

/* ------------------------ TAKE_OBJECT ------------------ */

/*
 * take_object(obj)
 *  Takes an object if it's in the room.
 *
 */

take_object(obj)
int obj;
{

        IF (inventory[obj] EQ ON) THEN
                printf("You've already got it!\n");

        ELSEIF (where[obj] NE position)
                printf("I see no %s here!\n", objct[obj]);
                return;
        ELSE
                where[obj] = OFF;
                inventory[obj] = ON;
                printf("A %s, taken.\n", objct[obj]);
        ENDIF
}

/* ------------------------ DROP_OBJECT ------------------- */

/*
 * drop_object(obj)
 *  Drops an object if player is carrying it.
 *
 */

drop_object(obj)
int obj;
{

        IF (inventory[obj] EQ OFF) THEN
                printf("You aren't carrying it!\n");

        ELSE
                where[obj] = position;
                inventory[obj] = OFF;
                printf("A %s, dropped.\n", objct[obj]);
        ENDIF
}

/* ----------------------- EXAM_OBJECT ------------------ */

/* 
 * exam_object()
 *   Looks at an object if the player has it in possesion
 *
 */

exam_obj(obj)
int obj;
{

        IF (inventory[obj] EQ OFF) THEN
                printf("You're not carrying it!\n");
        ELSE
                printf("%s\n",obj_exam[obj]);
        ENDIF
}

/* ------------------------ READ_OBJECT ------------------- */

/*
 * read_obj(obj)
 *  reads an object (if it's readable)
 *
 */
read_obj(obj)
int obj;
{
        IF (inventory[obj] EQ OFF) THEN
                printf("You're not carrying it!\n");
        ELSE
                switch(obj){
                
                case BOOK:
                        printf("'A good adventurer is prepared for anything.'\n");
                        break;

                case AXE:
                case STICK:
                case COIN:
                default:
                        printf("You can't read that!\n");
                        break;
                
                } /* End "switch(obj)"  */
        ENDIF
}

/* ------------------------ THROW_OBJECT ----------------- */

/*
 * throw_obj(obj)
 *   Throws any throwable object
 *
 */

throw_obj(obj)
int obj;
{
        IF (inventory[obj] EQ OFF) THEN
                printf("You're not carrying it!\n");
        ELSE
                switch(obj){

                case AXE:
                        printf("You throw the axe.\n");
                        where[obj] = position + 1;
                        inventory[obj] = OFF;
                        IF (where[obj] EQ 6) THEN
                                where[obj] = 4;
                        ENDIF
                        break;

                case BOOK:
                case STICK:
                case COIN:
                        printf("Ok, you throw it.\n");
                        where[obj] = position;
                        inventory[obj] = OFF;
                        break;

                default:
                        printf("You can't throw that!\n");
                        break;

                } /* End "switch(obj)"  */
        ENDIF
}
