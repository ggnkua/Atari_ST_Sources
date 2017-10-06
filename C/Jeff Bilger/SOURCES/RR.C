/* room record */

/* define our templates */
#define CF64	1                 
#define CL   	2
#define CR		3
#define ML      4
#define MR      5
#define FL      6
#define FR      7
#define CF1     8
#define CF2     9 
#define CF1_SPECIAL   10
#define CF2_SPECIAL   11
#define MF3211		12
#define MF3212		13
#define MF1611		14
#define MF1612		15
#define MF641		16
#define FF3211		17
#define FF3212		18
#define FF1611		19
#define FF1612		20
#define FF641		21
#define MF3221		22	
#define MF3222		23
#define MF1621		24
#define MF1622		25
#define MF642		26
#define FF3221		27
#define FF3222		28
#define FF1621		29
#define FF1622		30
#define FF642		31
#define ML_GATE       32
#define MR_GATE       33
#define FL_GATE       34
#define FR_GATE       35
#define CL_GATE       36
#define CR_GATE       37
#define REG_R4_FILL   38
#define REG_FAR_FILL  39
#define REG_MED_CLOSE_FILL  40
#define FAR_GATE      41
#define CLOSE_GATE    42
#define EMPTY               0




extern struct field_data
    {
    int Field1,
        Field2,
        Field3,
        Field4,
        Field5,
        Field6,
        Field7,
        floor;   /* if 0 user floor 1, if 1 use floor 2 */
    };

extern struct pic_data
   {
    struct field_data N,
                      S,
                      E,
                      W;
  
   };

extern struct pic_data roomrec[];  /* start at 1.... */

/***/
set_up1()
{
/* first define which ways you can go in each room. n,s,e,w, 0 means
  its a wall */

/* now define the templates needed when facing a dir in a room */



/********************************************/
roomrec[1].N.Field1=CL;
roomrec[1].N.Field2=CF1;
roomrec[1].N.Field3=CF2_SPECIAL;
roomrec[1].N.Field4=CF64;
roomrec[1].N.Field5=CF2_SPECIAL;
roomrec[1].N.Field6=CF1;
roomrec[1].N.Field7=CF2;
roomrec[1].N.floor=0;
/********************************************/

/********************************************/
roomrec[1].S.Field1=CF1;
roomrec[1].S.Field2=ML;
roomrec[1].S.Field3=MF1611;
roomrec[1].S.Field4=MF641;
roomrec[1].S.Field5=MF1612;
roomrec[1].S.Field6=MF3212;
roomrec[1].S.Field7=CR;
roomrec[1].S.floor=0;
/********************************************/

/********************************************/
roomrec[1].E.Field1=CL;
roomrec[1].E.Field2=ML;
roomrec[1].E.Field3=FL;
roomrec[1].E.Field4=EMPTY;
roomrec[1].E.Field5=FR;
roomrec[1].E.Field6=MR;
roomrec[1].E.Field7=CF1;
roomrec[1].E.floor=0;
/********************************************/

/********************************************/
roomrec[1].W.Field1=REG_MED_CLOSE_FILL;
roomrec[1].W.Field2=CF1;
roomrec[1].W.Field3=CF2;
roomrec[1].W.Field4=CF64;
roomrec[1].W.Field5=CF2;
roomrec[1].W.Field6=CF1;
roomrec[1].W.Field7=CR;
roomrec[1].W.floor=0;
/********************************************/

/********************************************/
roomrec[2].N.Field1=CF1;
roomrec[2].N.Field2=CF2;
roomrec[2].N.Field3=CF1_SPECIAL;
roomrec[2].N.Field4=CF64;
roomrec[2].N.Field5=CF2_SPECIAL;
roomrec[2].N.Field6=CF2;
roomrec[2].N.Field7=CF1;
roomrec[2].N.floor=1;
/********************************************/

/********************************************/
roomrec[2].S.Field1=CF1;
roomrec[2].S.Field2=CF2;
roomrec[2].S.Field3=CF1_SPECIAL;
roomrec[2].S.Field4=CF64;
roomrec[2].S.Field5=CF1_SPECIAL;
roomrec[2].S.Field6=CF2;
roomrec[2].S.Field7=MF3222;
roomrec[2].S.floor=1;
/********************************************/

/********************************************/
roomrec[2].E.Field1=CL;
roomrec[2].E.Field2=ML;
roomrec[2].E.Field3=FL;
roomrec[2].E.Field4=EMPTY;
roomrec[2].E.Field5=FR;
roomrec[2].E.Field6=MR;
roomrec[2].E.Field7=CR;
roomrec[2].E.floor=1;
/********************************************/

/********************************************/
roomrec[2].W.Field1=CL;
roomrec[2].W.Field2=REG_MED_CLOSE_FILL;
roomrec[2].W.Field3=MF1621;
roomrec[2].W.Field4=MF642;
roomrec[2].W.Field5=MF1622;
roomrec[2].W.Field6=MR;
roomrec[2].W.Field7=CR;
roomrec[2].W.floor=1;
/********************************************/


/********************************************/
roomrec[3].N.Field1=CF1;
roomrec[3].N.Field2=CF2;
roomrec[3].N.Field3=CF1_SPECIAL;
roomrec[3].N.Field4=CF64;
roomrec[3].N.Field5=CF2_SPECIAL;
roomrec[3].N.Field6=CF2;
roomrec[3].N.Field7=CF1;
roomrec[3].N.floor=0;
/********************************************/

/********************************************/
roomrec[3].S.Field1=CF1;
roomrec[3].S.Field2=CF2;
roomrec[3].S.Field3=CF1_SPECIAL;
roomrec[3].S.Field4=CF64;
roomrec[3].S.Field5=CF1_SPECIAL;
roomrec[3].S.Field6=CF2;
roomrec[3].S.Field7=CF1;
roomrec[3].S.floor=0;
/********************************************/

/********************************************/
roomrec[3].E.Field1=CL;
roomrec[3].E.Field2=ML;
roomrec[3].E.Field3=FL;
roomrec[3].E.Field4=FF641;
roomrec[3].E.Field5=FF1612;
roomrec[3].E.Field6=MR;
roomrec[3].E.Field7=CR;
roomrec[3].E.floor=0;
/********************************************/

/********************************************/
roomrec[3].W.Field1=CL;
roomrec[3].W.Field2=ML;
roomrec[3].W.Field3=FF1611;
roomrec[3].W.Field4=FF641;
roomrec[3].W.Field5=FR;
roomrec[3].W.Field6=MR;
roomrec[3].W.Field7=CR;
roomrec[3].W.floor=0;
/********************************************/


/********************************************/
roomrec[4].N.Field1=CF1;
roomrec[4].N.Field2=CF2;
roomrec[4].N.Field3=CF1_SPECIAL;
roomrec[4].N.Field4=CF64;
roomrec[4].N.Field5=CF2_SPECIAL;
roomrec[4].N.Field6=CF2;
roomrec[4].N.Field7=CF1;
roomrec[4].N.floor=1;
/********************************************/

/********************************************/
roomrec[4].S.Field1=REG_MED_CLOSE_FILL;
roomrec[4].S.Field2=CF2;
roomrec[4].S.Field3=CF1_SPECIAL;
roomrec[4].S.Field4=CF64;
roomrec[4].S.Field5=CF1_SPECIAL;
roomrec[4].S.Field6=CF2;
roomrec[4].S.Field7=CF1;
roomrec[4].S.floor=1;
/********************************************/

/********************************************/
roomrec[4].E.Field1=CL;
roomrec[4].E.Field2=ML;
roomrec[4].E.Field3=MF1621;
roomrec[4].E.Field4=MF642;
roomrec[4].E.Field5=MF1622;
roomrec[4].E.Field6=MF3222;
roomrec[4].E.Field7=CR;
roomrec[4].E.floor=1;
/********************************************/

/********************************************/
roomrec[4].W.Field1=CL;
roomrec[4].W.Field2=ML;
roomrec[4].W.Field3=FL;
roomrec[4].W.Field4=EMPTY;
roomrec[4].W.Field5=FR;
roomrec[4].W.Field6=MR;
roomrec[4].W.Field7=CR;
roomrec[4].W.floor=1;
/********************************************/


/********************************************/
roomrec[5].N.Field1=CF1;
roomrec[5].N.Field2=CF2;
roomrec[5].N.Field3=CF1_SPECIAL;
roomrec[5].N.Field4=CF64;
roomrec[5].N.Field5=CF2_SPECIAL;
roomrec[5].N.Field6=CF2;
roomrec[5].N.Field7=CR;
roomrec[5].N.floor=0;
/********************************************/

/********************************************/
roomrec[5].S.Field1=CL;
roomrec[5].S.Field2=ML;
roomrec[5].S.Field3=FL;
roomrec[5].S.Field4=EMPTY;
roomrec[5].S.Field5=FR;
roomrec[5].S.Field6=MR;
roomrec[5].S.Field7=CF1;
roomrec[5].S.floor=0;
/********************************************/

/********************************************/
roomrec[5].E.Field1=CL;
roomrec[5].E.Field2=CF1;
roomrec[5].E.Field3=CF1_SPECIAL;
roomrec[5].E.Field4=CF64;
roomrec[5].E.Field5=CF2_SPECIAL;
roomrec[5].E.Field6=CF1;
roomrec[5].E.Field7=CF2;
roomrec[5].E.floor=0;
/********************************************/

/********************************************/
roomrec[5].W.Field1=CF1;
roomrec[5].W.Field2=ML;
roomrec[5].W.Field3=FL;
roomrec[5].W.Field4=EMPTY;
roomrec[5].W.Field5=FR;
roomrec[5].W.Field6=MR;
roomrec[5].W.Field7=CR;
roomrec[5].W.floor=0;
/********************************************/



/********************************************/
roomrec[6].N.Field1=CL;
roomrec[6].N.Field2=CF1;
roomrec[6].N.Field3=CF1_SPECIAL;
roomrec[6].N.Field4=CF64;
roomrec[6].N.Field5=CF2_SPECIAL;
roomrec[6].N.Field6=CF2;
roomrec[6].N.Field7=CR;
roomrec[6].N.floor=0;
/********************************************/

/********************************************/
roomrec[6].S.Field1=CL;
roomrec[6].S.Field2=ML;
roomrec[6].S.Field3=FL;
roomrec[6].S.Field4=EMPTY;
roomrec[6].S.Field5=FR;
roomrec[6].S.Field6=MR;
roomrec[6].S.Field7=CR;
roomrec[6].S.floor=0;
/********************************************/

/********************************************/
roomrec[6].E.Field1=CL;
roomrec[6].E.Field2=CF1;
roomrec[6].E.Field3=CF1_SPECIAL;
roomrec[6].E.Field4=CF64;
roomrec[6].E.Field5=CF2_SPECIAL;
roomrec[6].E.Field6=CF1;
roomrec[6].E.Field7=CF2;
roomrec[6].E.floor=0;
/********************************************/

/********************************************/
roomrec[6].W.Field1=CF1;
roomrec[6].W.Field2=CF2;
roomrec[6].W.Field3=CF2_SPECIAL;
roomrec[6].W.Field4=CF64;
roomrec[6].W.Field5=CF1_SPECIAL;
roomrec[6].W.Field6=CF1;
roomrec[6].W.Field7=CR;
roomrec[6].W.floor=0;
/********************************************/




/********************************************/
roomrec[7].N.Field1=CL;
roomrec[7].N.Field2=CF1;
roomrec[7].N.Field3=CF1_SPECIAL;
roomrec[7].N.Field4=CF64;
roomrec[7].N.Field5=CF2_SPECIAL;
roomrec[7].N.Field6=CF2;
roomrec[7].N.Field7=CF1;
roomrec[7].N.floor=1;
/********************************************/

/********************************************/
roomrec[7].S.Field1=CF1;
roomrec[7].S.Field2=ML;
roomrec[7].S.Field3=FL_GATE;
roomrec[7].S.Field4=FAR_GATE;
roomrec[7].S.Field5=FR_GATE;
roomrec[7].S.Field6=MR;
roomrec[7].S.Field7=CR;
roomrec[7].S.floor=1;
/********************************************/

/********************************************/
roomrec[7].E.Field1=CL;
roomrec[7].E.Field2=ML;
roomrec[7].E.Field3=REG_FAR_FILL;
roomrec[7].E.Field4=FF642;
roomrec[7].E.Field5=FR;
roomrec[7].E.Field6=MR;
roomrec[7].E.Field7=CF1;
roomrec[7].E.floor=1;
/********************************************/

/********************************************/
roomrec[7].W.Field1=CF1;
roomrec[7].W.Field2=CF2;
roomrec[7].W.Field3=CF1_SPECIAL;
roomrec[7].W.Field4=CF64;
roomrec[7].W.Field5=CF2_SPECIAL;
roomrec[7].W.Field6=CF1;
roomrec[7].W.Field7=CR;
roomrec[7].W.floor=1;
/********************************************/



/********************************************/
roomrec[8].N.Field1=CF1;
roomrec[8].N.Field2=CF2;
roomrec[8].N.Field3=CF1_SPECIAL;
roomrec[8].N.Field4=CF64;
roomrec[8].N.Field5=CF1_SPECIAL;
roomrec[8].N.Field6=CF1;
roomrec[8].N.Field7=MF3212;
roomrec[8].N.floor=0;
/********************************************/

/********************************************/
roomrec[8].S.Field1=CF1;
roomrec[8].S.Field2=CF2;
roomrec[8].S.Field3=CF1_SPECIAL;
roomrec[8].S.Field4=CF64;
roomrec[8].S.Field5=CF1_SPECIAL;
roomrec[8].S.Field6=CF2;
roomrec[8].S.Field7=REG_MED_CLOSE_FILL;
roomrec[8].S.floor=0;
/********************************************/

/********************************************/
roomrec[8].E.Field1=CL;
roomrec[8].E.Field2=REG_MED_CLOSE_FILL;
roomrec[8].E.Field3=MF1611;
roomrec[8].E.Field4=MF641;
roomrec[8].E.Field5=MF1612;
roomrec[8].E.Field6=MR;
roomrec[8].E.Field7=CR;
roomrec[8].E.floor=0;
/********************************************/

/********************************************/
roomrec[8].W.Field1=CL;
roomrec[8].W.Field2=MF3212;
roomrec[8].W.Field3=MF1611;
roomrec[8].W.Field4=MF641;
roomrec[8].W.Field5=MF1612;
roomrec[8].W.Field6=MR;
roomrec[8].W.Field7=CR;
roomrec[8].W.floor=0;
/********************************************/




/********************************************/
roomrec[9].N.Field1=CF1;
roomrec[9].N.Field2=ML;
roomrec[9].N.Field3=MF1621;
roomrec[9].N.Field4=MF642;
roomrec[9].N.Field5=MF1622;
roomrec[9].N.Field6=MF3222;
roomrec[9].N.Field7=CR;
roomrec[9].N.floor=1;
/********************************************/

/********************************************/
roomrec[9].S.Field1=CL;
roomrec[9].S.Field2=CF1;
roomrec[9].S.Field3=CF1_SPECIAL;
roomrec[9].S.Field4=CF64;
roomrec[9].S.Field5=CF1_SPECIAL;
roomrec[9].S.Field6=CF2;
roomrec[9].S.Field7=CF1;
roomrec[9].S.floor=1;
/********************************************/

/********************************************/
roomrec[9].E.Field1=REG_MED_CLOSE_FILL;
roomrec[9].E.Field2=CF1;
roomrec[9].E.Field3=CF1_SPECIAL;
roomrec[9].E.Field4=CF64;
roomrec[9].E.Field5=CF2_SPECIAL;
roomrec[9].E.Field6=CF1;
roomrec[9].E.Field7=CR;
roomrec[9].E.floor=1;
/********************************************/

/********************************************/
roomrec[9].W.Field1=CL;
roomrec[9].W.Field2=ML;
roomrec[9].W.Field3=FF1621;
roomrec[9].W.Field4=FF642;
roomrec[9].W.Field5=FR;
roomrec[9].W.Field6=MR;
roomrec[9].W.Field7=CF1;
roomrec[9].W.floor=1;
/********************************************/



/********************************************/
roomrec[10].N.Field1=CL;
roomrec[10].N.Field2=MF3222;
roomrec[10].N.Field3=MF1621;
roomrec[10].N.Field4=MF642;
roomrec[10].N.Field5=MF1622;
roomrec[10].N.Field6=MR;
roomrec[10].N.Field7=CR;
roomrec[10].N.floor=1;
/********************************************/

/********************************************/
roomrec[10].S.Field1=CL;
roomrec[10].S.Field2=ML;
roomrec[10].S.Field3=FL;
roomrec[10].S.Field4=FF642;
roomrec[10].S.Field5=FF1622;
roomrec[10].S.Field6=MR;
roomrec[10].S.Field7=CR;
roomrec[10].S.floor=1;
/********************************************/

/********************************************/
roomrec[10].E.Field1=CF1;
roomrec[10].E.Field2=CF2;
roomrec[10].E.Field3=CF1_SPECIAL;
roomrec[10].E.Field4=CF64;
roomrec[10].E.Field5=CF2_SPECIAL;
roomrec[10].E.Field6=CF1;
roomrec[10].E.Field7=CF2;
roomrec[10].E.floor=1;
/********************************************/

/********************************************/
roomrec[10].W.Field1=CF1;
roomrec[10].W.Field2=CF2;
roomrec[10].W.Field3=CF1_SPECIAL;
roomrec[10].W.Field4=CF64;
roomrec[10].W.Field5=CF2_SPECIAL;
roomrec[10].W.Field6=CF1;
roomrec[10].W.Field7=REG_MED_CLOSE_FILL;
roomrec[10].W.floor=1;
/********************************************/



/********************************************/
roomrec[11].N.Field1=CL;
roomrec[11].N.Field2=ML;
roomrec[11].N.Field3=MF1621;
roomrec[11].N.Field4=MF642;
roomrec[11].N.Field5=MF1622;
roomrec[11].N.Field6=MR;
roomrec[11].N.Field7=CR;
roomrec[11].N.floor=1;
/********************************************/

/********************************************/
roomrec[11].S.Field1=CL;
roomrec[11].S.Field2=ML;
roomrec[11].S.Field3=FL;
roomrec[11].S.Field4=EMPTY;
roomrec[11].S.Field5=FR;
roomrec[11].S.Field6=MR;
roomrec[11].S.Field7=CR;
roomrec[11].S.floor=1;
/********************************************/

/********************************************/
roomrec[11].E.Field1=CF1;
roomrec[11].E.Field2=CF2;
roomrec[11].E.Field3=CF1_SPECIAL;
roomrec[11].E.Field4=CF64;
roomrec[11].E.Field5=CF2_SPECIAL;
roomrec[11].E.Field6=CF1;
roomrec[11].E.Field7=CF2;
roomrec[11].E.floor=1;
/********************************************/

/********************************************/
roomrec[11].W.Field1=CF1;
roomrec[11].W.Field2=CF2;
roomrec[11].W.Field3=CF1_SPECIAL;
roomrec[11].W.Field4=CF64;
roomrec[11].W.Field5=CF2_SPECIAL;
roomrec[11].W.Field6=CF1;
roomrec[11].W.Field7=CF2;
roomrec[11].W.floor=1;
/********************************************/


/********************************************/
roomrec[12].N.Field1=CL;
roomrec[12].N.Field2=ML;
roomrec[12].N.Field3=MF1611;
roomrec[12].N.Field4=MF641;
roomrec[12].N.Field5=MF1612;
roomrec[12].N.Field6=MF3212;
roomrec[12].N.Field7=CR;
roomrec[12].N.floor=0;
/********************************************/

/********************************************/
roomrec[12].S.Field1=CL;
roomrec[12].S.Field2=ML_GATE;
roomrec[12].S.Field3=FL;
roomrec[12].S.Field4=CLOSE_GATE;
roomrec[12].S.Field5=FR;
roomrec[12].S.Field6=MR_GATE;
roomrec[12].S.Field7=CR;
roomrec[12].S.floor=0;
/********************************************/

/********************************************/
roomrec[12].E.Field1=REG_MED_CLOSE_FILL;
roomrec[12].E.Field2=CF1;
roomrec[12].E.Field3=CF2_SPECIAL;
roomrec[12].E.Field4=CF64;
roomrec[12].E.Field5=CF1_SPECIAL;
roomrec[12].E.Field6=CF2;
roomrec[12].E.Field7=CF1;
roomrec[12].E.floor=0;
/********************************************/

/********************************************/
roomrec[12].W.Field1=CF2;
roomrec[12].W.Field2=CF1;
roomrec[12].W.Field3=CF2_SPECIAL;
roomrec[12].W.Field4=CF64;
roomrec[12].W.Field5=CF1_SPECIAL;
roomrec[12].W.Field6=CF2;
roomrec[12].W.Field7=CF1;
roomrec[12].W.floor=0;
/********************************************/



/********************************************/
roomrec[13].N.Field1=CL;
roomrec[13].N.Field2=CF1;
roomrec[13].N.Field3=CF1_SPECIAL;
roomrec[13].N.Field4=CF64;
roomrec[13].N.Field5=CF1_SPECIAL;
roomrec[13].N.Field6=CF2;
roomrec[13].N.Field7=CR;
roomrec[13].N.floor=0;
/********************************************/

/********************************************/
roomrec[13].S.Field1=CL;
roomrec[13].S.Field2=MF3211;
roomrec[13].S.Field3=FL;
roomrec[13].S.Field4=FF641;
roomrec[13].S.Field5=FR;
roomrec[13].S.Field6=MF3212;
roomrec[13].S.Field7=CR;
roomrec[13].S.floor=0;
/********************************************/

/********************************************/
roomrec[13].E.Field1=CL;
roomrec[13].E.Field2=CF1;
roomrec[13].E.Field3=CF1_SPECIAL;
roomrec[13].E.Field4=CF64;
roomrec[13].E.Field5=CF2_SPECIAL;
roomrec[13].E.Field6=CF1;
roomrec[13].E.Field7=REG_MED_CLOSE_FILL;
roomrec[13].E.floor=0;
/********************************************/

/********************************************/
roomrec[13].W.Field1=REG_MED_CLOSE_FILL;
roomrec[13].W.Field2=CF2;
roomrec[13].W.Field3=CF1_SPECIAL;
roomrec[13].W.Field4=CF64;
roomrec[13].W.Field5=CF2_SPECIAL;
roomrec[13].W.Field6=CF2;
roomrec[13].W.Field7=CR;
roomrec[13].W.floor=0;
/********************************************/


/********************************************/
roomrec[14].N.Field1=CL;
roomrec[14].N.Field2=ML;
roomrec[14].N.Field3=FF1611;
roomrec[14].N.Field4=FF641;
roomrec[14].N.Field5=FR;
roomrec[14].N.Field6=MR;
roomrec[14].N.Field7=CR;
roomrec[14].N.floor=0;
/********************************************/

/********************************************/
roomrec[14].S.Field1=CL;
roomrec[14].S.Field2=ML;
roomrec[14].S.Field3=MF1611;
roomrec[14].S.Field4=MF641;
roomrec[14].S.Field5=MF1612;
roomrec[14].S.Field6=MF3212;
roomrec[14].S.Field7=CR;
roomrec[14].S.floor=0;
/********************************************/

/********************************************/
roomrec[14].E.Field1=CF2;
roomrec[14].E.Field2=CF1;
roomrec[14].E.Field3=CF2_SPECIAL;
roomrec[14].E.Field4=CF64;
roomrec[14].E.Field5=CF1_SPECIAL;
roomrec[14].E.Field6=CF2;
roomrec[14].E.Field7=CF1;
roomrec[14].E.floor=0;
/********************************************/

/********************************************/
roomrec[14].W.Field1=REG_MED_CLOSE_FILL;
roomrec[14].W.Field2=CF2;
roomrec[14].W.Field3=CF1_SPECIAL;
roomrec[14].W.Field4=CF64;
roomrec[14].W.Field5=CF2_SPECIAL;
roomrec[14].W.Field6=CF2;
roomrec[14].W.Field7=CF1;
roomrec[14].W.floor=0;
/********************************************/



/********************************************/
roomrec[15].N.Field1=CL;
roomrec[15].N.Field2=ML;
roomrec[15].N.Field3=FL;
roomrec[15].N.Field4=FF641;
roomrec[15].N.Field5=FR;
roomrec[15].N.Field6=MR;
roomrec[15].N.Field7=CR;
roomrec[15].N.floor=0;
/********************************************/

/********************************************/
roomrec[15].S.Field1=CL;
roomrec[15].S.Field2=ML;
roomrec[15].S.Field3=FL;
roomrec[15].S.Field4=FF641;
roomrec[15].S.Field5=FF1612;
roomrec[15].S.Field6=MR;
roomrec[15].S.Field7=CR;
roomrec[15].S.floor=0;
/********************************************/

/********************************************/
roomrec[15].E.Field1=CF1;
roomrec[15].E.Field2=CF2;
roomrec[15].E.Field3=CF1_SPECIAL;
roomrec[15].E.Field4=CF64;
roomrec[15].E.Field5=CF2_SPECIAL;
roomrec[15].E.Field6=CF1;
roomrec[15].E.Field7=CF2;
roomrec[15].E.floor=0;
/********************************************/

/********************************************/
roomrec[15].W.Field1=CF1;
roomrec[15].W.Field2=CF2;
roomrec[15].W.Field3=CF1_SPECIAL;
roomrec[15].W.Field4=CF64;
roomrec[15].W.Field5=CF2_SPECIAL;
roomrec[15].W.Field6=CF2;
roomrec[15].W.Field7=CF1;
roomrec[15].W.floor=0;
/********************************************/




/********************************************/
roomrec[16].N.Field1=CL;
roomrec[16].N.Field2=ML;
roomrec[16].N.Field3=FL;
roomrec[16].N.Field4=FF642;
roomrec[16].N.Field5=FF1622;
roomrec[16].N.Field6=MR;
roomrec[16].N.Field7=CR;
roomrec[16].N.floor=1;
/********************************************/

/********************************************/
roomrec[16].S.Field1=CL;
roomrec[16].S.Field2=ML;
roomrec[16].S.Field3=FL;
roomrec[16].S.Field4=EMPTY;
roomrec[16].S.Field5=FR;
roomrec[16].S.Field6=MR;
roomrec[16].S.Field7=CR;
roomrec[16].S.floor=1;
/********************************************/

/********************************************/
roomrec[16].E.Field1=CF1;
roomrec[16].E.Field2=CF2;
roomrec[16].E.Field3=CF1_SPECIAL;
roomrec[16].E.Field4=CF64;
roomrec[16].E.Field5=CF2_SPECIAL;
roomrec[16].E.Field6=CF1;
roomrec[16].E.Field7=CF2;
roomrec[16].E.floor=1;
/********************************************/

/********************************************/
roomrec[16].W.Field1=CF1;
roomrec[16].W.Field2=CF2;
roomrec[16].W.Field3=CF1_SPECIAL;
roomrec[16].W.Field4=CF64;
roomrec[16].W.Field5=CF2_SPECIAL;
roomrec[16].W.Field6=CF1;
roomrec[16].W.Field7=CF2;
roomrec[16].W.floor=1;
/********************************************/



/********************************************/
roomrec[17].N.Field1=CL;
roomrec[17].N.Field2=CF1;
roomrec[17].N.Field3=CF2;
roomrec[17].N.Field4=CF64;
roomrec[17].N.Field5=CF2;
roomrec[17].N.Field6=CF1;
roomrec[17].N.Field7=CF2;
roomrec[17].N.floor=1;
/********************************************/

/********************************************/
roomrec[17].S.Field1=CF1;
roomrec[17].S.Field2=ML;
roomrec[17].S.Field3=FL;
roomrec[17].S.Field4=EMPTY;
roomrec[17].S.Field5=FR;
roomrec[17].S.Field6=MR;
roomrec[17].S.Field7=CR;
roomrec[17].S.floor=1;
/********************************************/

/********************************************/
roomrec[17].E.Field1=CL;
roomrec[17].E.Field2=ML;
roomrec[17].E.Field3=FF1621;
roomrec[17].E.Field4=EMPTY;
roomrec[17].E.Field5=FF1622;
roomrec[17].E.Field6=MR;
roomrec[17].E.Field7=CF1;
roomrec[17].E.floor=1;
/********************************************/

/********************************************/
roomrec[17].W.Field1=CF1;
roomrec[17].W.Field2=CF2;
roomrec[17].W.Field3=CF1_SPECIAL;
roomrec[17].W.Field4=CF64;
roomrec[17].W.Field5=CF2_SPECIAL;
roomrec[17].W.Field6=CF2;
roomrec[17].W.Field7=CR;
roomrec[17].W.floor=1;
/********************************************/


/********************************************/
roomrec[18].N.Field1=CF1;
roomrec[18].N.Field2=CF2;
roomrec[18].N.Field3=CF1_SPECIAL;
roomrec[18].N.Field4=CF64;
roomrec[18].N.Field5=CF2_SPECIAL;
roomrec[18].N.Field6=CF1;
roomrec[18].N.Field7=MF3211;
roomrec[18].N.floor=0;
/********************************************/

/********************************************/
roomrec[18].S.Field1=MF3211;
roomrec[18].S.Field2=CF1;
roomrec[18].S.Field3=CF2_SPECIAL;
roomrec[18].S.Field4=CF64;
roomrec[18].S.Field5=CF1_SPECIAL;
roomrec[18].S.Field6=CF2;
roomrec[18].S.Field7=REG_MED_CLOSE_FILL;
roomrec[18].S.floor=0;
/********************************************/

/********************************************/
roomrec[18].E.Field1=CL;
roomrec[18].E.Field2=MF3211;
roomrec[18].E.Field3=FL;
roomrec[18].E.Field4=EMPTY;
roomrec[18].E.Field5=FR;
roomrec[18].E.Field6=MF3212;
roomrec[18].E.Field7=CR;
roomrec[18].E.floor=0;
/********************************************/

/********************************************/
roomrec[18].W.Field1=CL;
roomrec[18].W.Field2=MF3211;
roomrec[18].W.Field3=MF1611;
roomrec[18].W.Field4=MF641;
roomrec[18].W.Field5=MF1612;
roomrec[18].W.Field6=MR;
roomrec[18].W.Field7=CR;
roomrec[18].W.floor=0;
/********************************************/

/*******/
roomrec[19].N.Field1=CF1;
roomrec[19].N.Field2=ML;
roomrec[19].N.Field3=MF1621;
roomrec[19].N.Field4=MF642;
roomrec[19].N.Field5=MF1622;
roomrec[19].N.Field6=MR;
roomrec[19].N.Field7=CF1;
roomrec[19].N.floor=1;
/********************************************/

/********************************************/
roomrec[19].S.Field1=CF1;
roomrec[19].S.Field2=ML;
roomrec[19].S.Field3=MF1621;
roomrec[19].S.Field4=MF642;
roomrec[19].S.Field5=MF1622;
roomrec[19].S.Field6=MR;
roomrec[19].S.Field7=CF1;
roomrec[19].S.floor=1;
/********************************************/

/********************************************/
roomrec[19].E.Field1=CF1;
roomrec[19].E.Field2=ML;
roomrec[19].E.Field3=FF1621;
roomrec[19].E.Field4=FF642;
roomrec[19].E.Field5=FR;
roomrec[19].E.Field6=MR;
roomrec[19].E.Field7=CF1;
roomrec[19].E.floor=1;
/********************************************/

/********************************************/
roomrec[19].W.Field1=CF1;
roomrec[19].W.Field2=ML;
roomrec[19].W.Field3=FF1621;
roomrec[19].W.Field4=FF642;
roomrec[19].W.Field5=FR;
roomrec[19].W.Field6=MR;
roomrec[19].W.Field7=CF1;
roomrec[19].W.floor=1;
/********************************************/


/*******/
roomrec[20].N.Field1=MF3211;
roomrec[20].N.Field2=CF1;
roomrec[20].N.Field3=CF1_SPECIAL;
roomrec[20].N.Field4=CF64;
roomrec[20].N.Field5=CF2_SPECIAL;
roomrec[20].N.Field6=CF1;
roomrec[20].N.Field7=REG_MED_CLOSE_FILL;
roomrec[20].N.floor=0;
/********************************************/

/********************************************/
roomrec[20].S.Field1=CF1;
roomrec[20].S.Field2=CF2;
roomrec[20].S.Field3=CF1_SPECIAL;
roomrec[20].S.Field4=CF64;
roomrec[20].S.Field5=CF1_SPECIAL;
roomrec[20].S.Field6=CF2;
roomrec[20].S.Field7=MF3211;
roomrec[20].S.floor=0;
/********************************************/

/********************************************/
roomrec[20].E.Field1=CL;
roomrec[20].E.Field2=MF3211;
roomrec[20].E.Field3=MF1611;
roomrec[20].E.Field4=MF641;
roomrec[20].E.Field5=MF1612;
roomrec[20].E.Field6=MR;
roomrec[20].E.Field7=CR;
roomrec[20].E.floor=0;
/********************************************/

/********************************************/
roomrec[20].W.Field1=CL;
roomrec[20].W.Field2=MF3211;
roomrec[20].W.Field3=FL;
roomrec[20].W.Field4=EMPTY;
roomrec[20].W.Field5=FR;
roomrec[20].W.Field6=MF3211;
roomrec[20].W.Field7=CR;
roomrec[20].W.floor=0;
/********************************************/


/*******/
roomrec[21].N.Field1=CF1;
roomrec[21].N.Field2=ML;
roomrec[21].N.Field3=FL;
roomrec[21].N.Field4=EMPTY;
roomrec[21].N.Field5=FR;
roomrec[21].N.Field6=MR;
roomrec[21].N.Field7=CR;
roomrec[21].N.floor=1;
/********************************************/

/********************************************/
roomrec[21].S.Field1=CL;
roomrec[21].S.Field2=CF1;
roomrec[21].S.Field3=CF1_SPECIAL;
roomrec[21].S.Field4=CF64;
roomrec[21].S.Field5=CF1_SPECIAL;
roomrec[21].S.Field6=CF2;
roomrec[21].S.Field7=CF1;
roomrec[21].S.floor=1;
/********************************************/

/********************************************/
roomrec[21].E.Field1=CF1;
roomrec[21].E.Field2=CF2;
roomrec[21].E.Field3=CF1_SPECIAL;
roomrec[21].E.Field4=CF64;
roomrec[21].E.Field5=CF2_SPECIAL;
roomrec[21].E.Field6=CF1;
roomrec[21].E.Field7=CR;
roomrec[21].E.floor=1;
/********************************************/

/********************************************/
roomrec[21].W.Field1=CL;
roomrec[21].W.Field2=ML;
roomrec[21].W.Field3=FF1621;
roomrec[21].W.Field4=EMPTY;
roomrec[21].W.Field5=FF1622;
roomrec[21].W.Field6=MR;
roomrec[21].W.Field7=CF1;
roomrec[21].W.floor=1;
/********************************************/



/*******/
roomrec[22].N.Field1=CL;
roomrec[22].N.Field2=ML;
roomrec[22].N.Field3=FL;
roomrec[22].N.Field4=EMPTY;
roomrec[22].N.Field5=FR;
roomrec[22].N.Field6=MR;
roomrec[22].N.Field7=CR;
roomrec[22].N.floor=1;
/********************************************/

/********************************************/
roomrec[22].S.Field1=CL;
roomrec[22].S.Field2=ML;
roomrec[22].S.Field3=MF1621;
roomrec[22].S.Field4=MF642;
roomrec[22].S.Field5=MF1622;
roomrec[22].S.Field6=MF3222;
roomrec[22].S.Field7=CR;
roomrec[22].S.floor=1;
/********************************************/

/********************************************/
roomrec[22].E.Field1=CF2;
roomrec[22].E.Field2=CF1;
roomrec[22].E.Field3=CF2_SPECIAL;
roomrec[22].E.Field4=CF64;
roomrec[22].E.Field5=CF1_SPECIAL;
roomrec[22].E.Field6=CF2;
roomrec[22].E.Field7=CF1;
roomrec[22].E.floor=1;
/********************************************/

/********************************************/
roomrec[22].W.Field1=REG_MED_CLOSE_FILL;
roomrec[22].W.Field2=CF2;
roomrec[22].W.Field3=CF1_SPECIAL;
roomrec[22].W.Field4=CF64;
roomrec[22].W.Field5=CF2_SPECIAL;
roomrec[22].W.Field6=CF1;
roomrec[22].W.Field7=CF2;
roomrec[22].W.floor=1;
/********************************************/



/*******/
roomrec[23].N.Field1=CL;
roomrec[23].N.Field2=ML_GATE;
roomrec[23].N.Field3=FL;
roomrec[23].N.Field4=CLOSE_GATE;
roomrec[23].N.Field5=FR;
roomrec[23].N.Field6=MR_GATE;
roomrec[23].N.Field7=CR;
roomrec[23].N.floor=0;
/********************************************/

/********************************************/
roomrec[23].S.Field1=CL;
roomrec[23].S.Field2=ML;
roomrec[23].S.Field3=FL;
roomrec[23].S.Field4=EMPTY;
roomrec[23].S.Field5=FR;
roomrec[23].S.Field6=MR;
roomrec[23].S.Field7=CR;
roomrec[23].S.floor=0;
/********************************************/

/********************************************/
roomrec[23].E.Field1=CF1;
roomrec[23].E.Field2=CF2;
roomrec[23].E.Field3=CF1_SPECIAL;
roomrec[23].E.Field4=CF64;
roomrec[23].E.Field5=CF2_SPECIAL;
roomrec[23].E.Field6=CF1;
roomrec[23].E.Field7=CF2;
roomrec[23].E.floor=0;
/********************************************/

/********************************************/
roomrec[23].W.Field1=CF2;
roomrec[23].W.Field2=CF1;
roomrec[23].W.Field3=CF2_SPECIAL;
roomrec[23].W.Field4=CF64;
roomrec[23].W.Field5=CF1_SPECIAL;
roomrec[23].W.Field6=CF2;
roomrec[23].W.Field7=CF1;
roomrec[23].W.floor=0;
/********************************************/

/************/
roomrec[24].N.Field1=CL;
roomrec[24].N.Field2=ML;
roomrec[24].N.Field3=MF1611;
roomrec[24].N.Field4=MF641;
roomrec[24].N.Field5=MF1612;
roomrec[24].N.Field6=MF3212;
roomrec[24].N.Field7=CR;
roomrec[24].N.floor=0;
/********************************************/

/********************************************/
roomrec[24].S.Field1=CL;
roomrec[24].S.Field2=ML;
roomrec[24].S.Field3=FL;
roomrec[24].S.Field4=FF641;
roomrec[24].S.Field5=FR;
roomrec[24].S.Field6=MR;
roomrec[24].S.Field7=CR;
roomrec[24].S.floor=0;
/********************************************/

/********************************************/
roomrec[24].E.Field1=REG_MED_CLOSE_FILL;
roomrec[24].E.Field2=CF2;
roomrec[24].E.Field3=CF1_SPECIAL;
roomrec[24].E.Field4=CF64;
roomrec[24].E.Field5=CF2_SPECIAL;
roomrec[24].E.Field6=CF1;
roomrec[24].E.Field7=CF2;
roomrec[24].E.floor=0;
/********************************************/

/********************************************/
roomrec[24].W.Field1=CF2;
roomrec[24].W.Field2=CF1;
roomrec[24].W.Field3=CF2_SPECIAL;
roomrec[24].W.Field4=CF64;
roomrec[24].W.Field5=CF1_SPECIAL;
roomrec[24].W.Field6=CF2;
roomrec[24].W.Field7=CF1;
roomrec[24].W.floor=0;
/********************************************/


/************/
roomrec[25].N.Field1=CL;
roomrec[25].N.Field2=MF3212;
roomrec[25].N.Field3=FL;
roomrec[25].N.Field4=FF641;
roomrec[25].N.Field5=FR;
roomrec[25].N.Field6=MF3212;
roomrec[25].N.Field7=CR;
roomrec[25].N.floor=0;
/********************************************/

/********************************************/
roomrec[25].S.Field1=CL;
roomrec[25].S.Field2=CF1;
roomrec[25].S.Field3=CF2_SPECIAL;
roomrec[25].S.Field4=CF64;
roomrec[25].S.Field5=CF1_SPECIAL;
roomrec[25].S.Field6=CF2;
roomrec[25].S.Field7=CR;
roomrec[25].S.floor=0;
/********************************************/

/********************************************/
roomrec[25].E.Field1=REG_MED_CLOSE_FILL;
roomrec[25].E.Field2=CF2;
roomrec[25].E.Field3=CF1_SPECIAL;
roomrec[25].E.Field4=CF64;
roomrec[25].E.Field5=CF2_SPECIAL;
roomrec[25].E.Field6=CF1;
roomrec[25].E.Field7=CR;
roomrec[25].E.floor=0;
/********************************************/

/********************************************/
roomrec[25].W.Field1=CL;
roomrec[25].W.Field2=CF2;
roomrec[25].W.Field3=CF1_SPECIAL;
roomrec[25].W.Field4=CF64;
roomrec[25].W.Field5=CF2_SPECIAL;
roomrec[25].W.Field6=CF1;
roomrec[25].W.Field7=REG_MED_CLOSE_FILL;
roomrec[25].W.floor=0;
/********************************************/


/************/
roomrec[26].N.Field1=CL;
roomrec[26].N.Field2=CF1;
roomrec[26].N.Field3=CF2_SPECIAL;
roomrec[26].N.Field4=CF64;
roomrec[26].N.Field5=CF1_SPECIAL;
roomrec[26].N.Field6=CF2;
roomrec[26].N.Field7=CF1;
roomrec[26].N.floor=0;
/********************************************/

/********************************************/
roomrec[26].S.Field1=CF1;
roomrec[26].S.Field2=ML;
roomrec[26].S.Field3=FL;
roomrec[26].S.Field4=EMPTY;
roomrec[26].S.Field5=FR;
roomrec[26].S.Field6=MR;
roomrec[26].S.Field7=CR;
roomrec[26].S.floor=0;
/********************************************/

/********************************************/
roomrec[26].E.Field1=CL;
roomrec[26].E.Field2=ML;
roomrec[26].E.Field3=FF1611;
roomrec[26].E.Field4=FF641;
roomrec[26].E.Field5=FR;
roomrec[26].E.Field6=MR;
roomrec[26].E.Field7=CF2;
roomrec[26].E.floor=0;
/********************************************/

/********************************************/
roomrec[26].W.Field1=CF1;
roomrec[26].W.Field2=CF2;
roomrec[26].W.Field3=CF1_SPECIAL;
roomrec[26].W.Field4=CF64;
roomrec[26].W.Field5=CF2_SPECIAL;
roomrec[26].W.Field6=CF1;
roomrec[26].W.Field7=CR;
roomrec[26].W.floor=0;
/********************************************/


/********************************************/
roomrec[27].N.Field1=CF2;
roomrec[27].N.Field2=CF1;
roomrec[27].N.Field3=CF2_SPECIAL;
roomrec[27].N.Field4=CF64;
roomrec[27].N.Field5=CF1_SPECIAL;
roomrec[27].N.Field6=CF2;
roomrec[27].N.Field7=REG_MED_CLOSE_FILL;
roomrec[27].N.floor=1;
/********************************************/

/********************************************/
roomrec[27].S.Field1=CF1;
roomrec[27].S.Field2=CF2;
roomrec[27].S.Field3=CF1_SPECIAL;
roomrec[27].S.Field4=CF64;
roomrec[27].S.Field5=CF2_SPECIAL;
roomrec[27].S.Field6=CF1;
roomrec[27].S.Field7=REG_MED_CLOSE_FILL;
roomrec[27].S.floor=1;
/********************************************/

/********************************************/
roomrec[27].E.Field1=CL;
roomrec[27].E.Field2=MF3222;
roomrec[27].E.Field3=MF1621;
roomrec[27].E.Field4=MF642;
roomrec[27].E.Field5=MF1622;
roomrec[27].E.Field6=MR;
roomrec[27].E.Field7=CR;
roomrec[27].E.floor=1;
/********************************************/

/********************************************/
roomrec[27].W.Field1=CL;
roomrec[27].W.Field2=MF3222;
roomrec[27].W.Field3=MF1621;
roomrec[27].W.Field4=MF642;
roomrec[27].W.Field5=MF1622;
roomrec[27].W.Field6=MR;
roomrec[27].W.Field7=CR;
roomrec[27].W.floor=1;
/********************************************/


/********************************************/
roomrec[28].N.Field1=CF1;
roomrec[28].N.Field2=ML;
roomrec[28].N.Field3=FL;
roomrec[28].N.Field4=EMPTY;
roomrec[28].N.Field5=FR;
roomrec[28].N.Field6=MR;
roomrec[28].N.Field7=CR;
roomrec[28].N.floor=0;
/********************************************/

/********************************************/
roomrec[28].S.Field1=CL;
roomrec[28].S.Field2=CF1;
roomrec[28].S.Field3=CF2_SPECIAL;
roomrec[28].S.Field4=CF64;
roomrec[28].S.Field5=CF1_SPECIAL;
roomrec[28].S.Field6=CF2;
roomrec[28].S.Field7=CF1;
roomrec[28].S.floor=0;
/********************************************/

/********************************************/
roomrec[28].E.Field1=CF1;
roomrec[28].E.Field2=CF2;
roomrec[28].E.Field3=CF1_SPECIAL;
roomrec[28].E.Field4=CF64;
roomrec[28].E.Field5=CF2_SPECIAL;
roomrec[28].E.Field6=CF1;
roomrec[28].E.Field7=CR;
roomrec[28].E.floor=0;
/********************************************/

/********************************************/
roomrec[28].W.Field1=CL;
roomrec[28].W.Field2=ML;
roomrec[28].W.Field3=FF1611;
roomrec[28].W.Field4=FF641;
roomrec[28].W.Field5=FR;
roomrec[28].W.Field6=MR;
roomrec[28].W.Field7=CF2;
roomrec[28].W.floor=0;
/********************************************/



/********************************************/
roomrec[29].N.Field1=CL;
roomrec[29].N.Field2=ML;
roomrec[29].N.Field3=FL_GATE;
roomrec[29].N.Field4=FAR_GATE;
roomrec[29].N.Field5=FR_GATE;
roomrec[29].N.Field6=MR;
roomrec[29].N.Field7=CR;
roomrec[29].N.floor=1;
/********************************************/

/********************************************/
roomrec[29].S.Field1=CL;
roomrec[29].S.Field2=ML;
roomrec[29].S.Field3=FL;
roomrec[29].S.Field4=EMPTY;
roomrec[29].S.Field5=FR;
roomrec[29].S.Field6=MR;
roomrec[29].S.Field7=CR;
roomrec[29].S.floor=1;
/********************************************/

/********************************************/
roomrec[29].E.Field1=CF1;
roomrec[29].E.Field2=CF2;
roomrec[29].E.Field3=CF1_SPECIAL;
roomrec[29].E.Field4=CF64;
roomrec[29].E.Field5=CF2_SPECIAL;
roomrec[29].E.Field6=CF1;
roomrec[29].E.Field7=CF2;
roomrec[29].E.floor=1;
/********************************************/

/********************************************/
roomrec[29].W.Field1=CF1;
roomrec[29].W.Field2=CF1;
roomrec[29].W.Field3=CF1_SPECIAL;
roomrec[29].W.Field4=CF64;
roomrec[29].W.Field5=CF2_SPECIAL;
roomrec[29].W.Field6=CF1;
roomrec[29].W.Field7=CF2;
roomrec[29].W.floor=1;
/********************************************/


/********************************************/
roomrec[30].N.Field1=CL;
roomrec[30].N.Field2=ML;
roomrec[30].N.Field3=FL;
roomrec[30].N.Field4=FF642;
roomrec[30].N.Field5=FF1622;
roomrec[30].N.Field6=MR;
roomrec[30].N.Field7=CR;
roomrec[30].N.floor=1;
/********************************************/

/********************************************/
roomrec[30].S.Field1=CL;
roomrec[30].S.Field2=ML;
roomrec[30].S.Field3=MF1621;
roomrec[30].S.Field4=MF642;
roomrec[30].S.Field5=MF1622;
roomrec[30].S.Field6=MR;
roomrec[30].S.Field7=CR;
roomrec[30].S.floor=1;
/********************************************/

/********************************************/
roomrec[30].E.Field1=CF1;
roomrec[30].E.Field2=CF2;
roomrec[30].E.Field3=CF1_SPECIAL;
roomrec[30].E.Field4=CF64;
roomrec[30].E.Field5=CF2_SPECIAL;
roomrec[30].E.Field6=CF1;
roomrec[30].E.Field7=CF2;
roomrec[30].E.floor=1;
/********************************************/

/********************************************/
roomrec[30].W.Field1=CF1;
roomrec[30].W.Field2=CF1;
roomrec[30].W.Field3=CF1_SPECIAL;
roomrec[30].W.Field4=CF64;
roomrec[30].W.Field5=CF2_SPECIAL;
roomrec[30].W.Field6=CF1;
roomrec[30].W.Field7=CF2;
roomrec[30].W.floor=1;
/********************************************/


/********************************************/
roomrec[31].N.Field1=CL;
roomrec[31].N.Field2=ML;
roomrec[31].N.Field3=MF1621;
roomrec[31].N.Field4=MF642;
roomrec[31].N.Field5=MF1622;
roomrec[31].N.Field6=MF3222;
roomrec[31].N.Field7=CR;
roomrec[31].N.floor=1;
/********************************************/

/********************************************/
roomrec[31].S.Field1=CL;
roomrec[31].S.Field2=ML;
roomrec[31].S.Field3=FL;
roomrec[31].S.Field4=EMPTY;
roomrec[31].S.Field5=FR;
roomrec[31].S.Field6=MR;
roomrec[31].S.Field7=CR;
roomrec[31].S.floor=1;
/********************************************/

/********************************************/
roomrec[31].E.Field1=REG_MED_CLOSE_FILL;
roomrec[31].E.Field2=CF2;
roomrec[31].E.Field3=CF1_SPECIAL;
roomrec[31].E.Field4=CF64;
roomrec[31].E.Field5=CF2_SPECIAL;
roomrec[31].E.Field6=CF1;
roomrec[31].E.Field7=CF2;
roomrec[31].E.floor=1;
/********************************************/

/********************************************/
roomrec[31].W.Field1=CF1;
roomrec[31].W.Field2=CF1;
roomrec[31].W.Field3=CF1_SPECIAL;
roomrec[31].W.Field4=CF64;
roomrec[31].W.Field5=CF2_SPECIAL;
roomrec[31].W.Field6=CF1;
roomrec[31].W.Field7=CF2;
roomrec[31].W.floor=1;
/********************************************/



/********************************************/
roomrec[32].N.Field1=CL;
roomrec[32].N.Field2=CF1;
roomrec[32].N.Field3=CF2_SPECIAL;
roomrec[32].N.Field4=CF64;
roomrec[32].N.Field5=CF2_SPECIAL;
roomrec[32].N.Field6=CF1;
roomrec[32].N.Field7=CF2;
roomrec[32].N.floor=1;
/********************************************/

/********************************************/
roomrec[32].S.Field1=CF1;
roomrec[32].S.Field2=ML;
roomrec[32].S.Field3=FF1621;
roomrec[32].S.Field4=FF642;
roomrec[32].S.Field5=FR;
roomrec[32].S.Field6=MR;
roomrec[32].S.Field7=CR;
roomrec[32].S.floor=1;
/********************************************/

/********************************************/
roomrec[32].E.Field1=CL;
roomrec[32].E.Field2=ML;
roomrec[32].E.Field3=MF1621;
roomrec[32].E.Field4=MF642;
roomrec[32].E.Field5=MF1622;
roomrec[32].E.Field6=MR;
roomrec[32].E.Field7=CF2;
roomrec[32].E.floor=1;
/********************************************/

/********************************************/
roomrec[32].W.Field1=CF1;
roomrec[32].W.Field2=CF1;
roomrec[32].W.Field3=CF1_SPECIAL;
roomrec[32].W.Field4=CF64;
roomrec[32].W.Field5=CF2_SPECIAL;
roomrec[32].W.Field6=CF1;
roomrec[32].W.Field7=CR;
roomrec[32].W.floor=1;
/********************************************/



/********************************************/
roomrec[33].N.Field1=CF1;
roomrec[33].N.Field2=CF2;
roomrec[33].N.Field3=CF2_SPECIAL;
roomrec[33].N.Field4=CF64;
roomrec[33].N.Field5=CF2_SPECIAL;
roomrec[33].N.Field6=CF1;
roomrec[33].N.Field7=CR;
roomrec[33].N.floor=0;
/********************************************/

/********************************************/
roomrec[33].S.Field1=CL;
roomrec[33].S.Field2=CF1;
roomrec[33].S.Field3=CF2_SPECIAL;
roomrec[33].S.Field4=CF64;
roomrec[33].S.Field5=CF1_SPECIAL;
roomrec[33].S.Field6=CF2;
roomrec[33].S.Field7=REG_MED_CLOSE_FILL;
roomrec[33].S.floor=0;
/********************************************/

/********************************************/
roomrec[33].E.Field1=CL;
roomrec[33].E.Field2=CF1;
roomrec[33].E.Field3=CF1_SPECIAL;
roomrec[33].E.Field4=CF64;
roomrec[33].E.Field5=CF2_SPECIAL;
roomrec[33].E.Field6=CF1;
roomrec[33].E.Field7=CR;
roomrec[33].E.floor=0;
/********************************************/

/********************************************/
roomrec[33].W.Field1=CL;
roomrec[33].W.Field2=MF3212;
roomrec[33].W.Field3=MF1611;
roomrec[33].W.Field4=MF641;
roomrec[33].W.Field5=MF1612;
roomrec[33].W.Field6=MR;
roomrec[33].W.Field7=CR;
roomrec[33].W.floor=0;
/********************************************/



/********************************************/
roomrec[34].N.Field1=CL;
roomrec[34].N.Field2=ML;
roomrec[34].N.Field3=FL;
roomrec[34].N.Field4=EMPTY;
roomrec[34].N.Field5=FR;
roomrec[34].N.Field6=MR;
roomrec[34].N.Field7=CR;
roomrec[34].N.floor=0;
/********************************************/

/********************************************/
roomrec[34].S.Field1=CL;
roomrec[34].S.Field2=ML;
roomrec[34].S.Field3=FF1611;
roomrec[34].S.Field4=FF641;
roomrec[34].S.Field5=FF1612;
roomrec[34].S.Field6=MR;
roomrec[34].S.Field7=CR;
roomrec[34].S.floor=0;
/********************************************/

/********************************************/
roomrec[34].E.Field1=CF2;
roomrec[34].E.Field2=CF1;
roomrec[34].E.Field3=CF2_SPECIAL;
roomrec[34].E.Field4=CF64;
roomrec[34].E.Field5=CF1_SPECIAL;
roomrec[34].E.Field6=CF2;
roomrec[34].E.Field7=CF1;
roomrec[34].E.floor=0;
/********************************************/

/********************************************/
roomrec[34].W.Field1=CF2;
roomrec[34].W.Field2=CF1;
roomrec[34].W.Field3=CF2_SPECIAL;
roomrec[34].W.Field4=CF64;
roomrec[34].W.Field5=CF1_SPECIAL;
roomrec[34].W.Field6=CF2;
roomrec[34].W.Field7=CF1;
roomrec[34].W.floor=0;
/********************************************/


/********************************************/
roomrec[35].N.Field1=CL;
roomrec[35].N.Field2=ML;
roomrec[35].N.Field3=FL;
roomrec[35].N.Field4=EMPTY;
roomrec[35].N.Field5=FR;
roomrec[35].N.Field6=MR;
roomrec[35].N.Field7=CR;
roomrec[35].N.floor=0;
/********************************************/

/********************************************/
roomrec[35].S.Field1=CL;
roomrec[35].S.Field2=CF1;
roomrec[35].S.Field3=CF2;
roomrec[35].S.Field4=CF64;
roomrec[35].S.Field5=CF2;
roomrec[35].S.Field6=CF1;
roomrec[35].S.Field7=CR;
roomrec[35].S.floor=0;
/********************************************/

/********************************************/
roomrec[35].E.Field1=CF1;
roomrec[35].E.Field2=CF2;
roomrec[35].E.Field3=CF1;
roomrec[35].E.Field4=CF64;
roomrec[35].E.Field5=CF1;
roomrec[35].E.Field6=CF2;
roomrec[35].E.Field7=CR;
roomrec[35].E.floor=0;
/********************************************/

/********************************************/
roomrec[35].W.Field1=CL;
roomrec[35].W.Field2=CF1;
roomrec[35].W.Field3=CF2_SPECIAL;
roomrec[35].W.Field4=CF64;
roomrec[35].W.Field5=CF1_SPECIAL;
roomrec[35].W.Field6=CF2;
roomrec[35].W.Field7=CF1;
roomrec[35].W.floor=0;
/********************************************/


/********************************************/
roomrec[36].N.Field1=CL;
roomrec[36].N.Field2=CF1;
roomrec[36].N.Field3=CF2;
roomrec[36].N.Field4=CF64;
roomrec[36].N.Field5=CF2;
roomrec[36].N.Field6=CF1;
roomrec[36].N.Field7=CR;
roomrec[36].N.floor=0;
/********************************************/

/********************************************/
roomrec[36].S.Field1=CL;
roomrec[36].S.Field2=ML;
roomrec[36].S.Field3=FF1611;
roomrec[36].S.Field4=FF641;
roomrec[36].S.Field5=FF1612;
roomrec[36].S.Field6=MR;
roomrec[36].S.Field7=CR;
roomrec[36].S.floor=0;
/********************************************/

/********************************************/
roomrec[36].E.Field1=CL;
roomrec[36].E.Field2=CF1;
roomrec[36].E.Field3=CF2;
roomrec[36].E.Field4=CF64;
roomrec[36].E.Field5=CF2;
roomrec[36].E.Field6=CF1;
roomrec[36].E.Field7=CF2;
roomrec[36].E.floor=0;
/********************************************/

/********************************************/
roomrec[36].W.Field1=CF1;
roomrec[36].W.Field2=CF2;
roomrec[36].W.Field3=CF1;
roomrec[36].W.Field4=CF64;
roomrec[36].W.Field5=CF1;
roomrec[36].W.Field6=CF2;
roomrec[36].W.Field7=CR;
roomrec[36].W.floor=0;
/********************************************/

/********************************************/
roomrec[37].N.Field1=CL;
roomrec[37].N.Field2=ML;
roomrec[37].N.Field3=FL;
roomrec[37].N.Field4=FF641;
roomrec[37].N.Field5=FF1612;
roomrec[37].N.Field6=MR;
roomrec[37].N.Field7=CR;
roomrec[37].N.floor=0;
/********************************************/

/********************************************/
roomrec[37].S.Field1=CL;
roomrec[37].S.Field2=ML;
roomrec[37].S.Field3=FL;
roomrec[37].S.Field4=FF641;
roomrec[37].S.Field5=FF1612;
roomrec[37].S.Field6=MR;
roomrec[37].S.Field7=CR;
roomrec[37].S.floor=0;
/********************************************/

/********************************************/
roomrec[37].E.Field1=CF1;
roomrec[37].E.Field2=CF2;
roomrec[37].E.Field3=CF1;
roomrec[37].E.Field4=CF64;
roomrec[37].E.Field5=CF1;
roomrec[37].E.Field6=CF2;
roomrec[37].E.Field7=CF1;
roomrec[37].E.floor=0;
/********************************************/

/********************************************/
roomrec[37].W.Field1=CF1;
roomrec[37].W.Field2=CF2;
roomrec[37].W.Field3=CF1;
roomrec[37].W.Field4=CF64;
roomrec[37].W.Field5=CF1;
roomrec[37].W.Field6=CF2;
roomrec[37].W.Field7=CF1;
roomrec[37].W.floor=0;
/********************************************/

/********************************************/
roomrec[38].N.Field1=CL;
roomrec[38].N.Field2=ML;
roomrec[38].N.Field3=MF1611;
roomrec[38].N.Field4=MF641;
roomrec[38].N.Field5=MF1612;
roomrec[38].N.Field6=MF3212;
roomrec[38].N.Field7=CR;
roomrec[38].N.floor=0;
/********************************************/

/********************************************/
roomrec[38].S.Field1=CL;
roomrec[38].S.Field2=MF3211;
roomrec[38].S.Field3=MF1611;
roomrec[38].S.Field4=MF641;
roomrec[38].S.Field5=MF1612;
roomrec[38].S.Field6=MR;
roomrec[38].S.Field7=CR;
roomrec[38].S.floor=0;
/********************************************/

/********************************************/
roomrec[38].E.Field1=FF3211;
roomrec[38].E.Field2=CF1;
roomrec[38].E.Field3=CF2;
roomrec[38].E.Field4=CF64;
roomrec[38].E.Field5=CF2;
roomrec[38].E.Field6=CF1;
roomrec[38].E.Field7=CF2;
roomrec[38].E.floor=0;
/********************************************/

/********************************************/
roomrec[38].W.Field1=CF2;
roomrec[38].W.Field2=CF1;
roomrec[38].W.Field3=CF2;
roomrec[38].W.Field4=CF64;
roomrec[38].W.Field5=CF1;
roomrec[38].W.Field6=CF2;
roomrec[38].W.Field7=CF1;
roomrec[38].W.floor=0;
/********************************************/

/********************************************/
roomrec[39].N.Field1=CL;
roomrec[39].N.Field2=ML;
roomrec[39].N.Field3=FL;
roomrec[39].N.Field4=EMPTY;
roomrec[39].N.Field5=FR;
roomrec[39].N.Field6=MR;
roomrec[39].N.Field7=CR;
roomrec[39].N.floor=1;
/********************************************/

/********************************************/
roomrec[39].S.Field1=CL;
roomrec[39].S.Field2=MF3222;
roomrec[39].S.Field3=MF1621;
roomrec[39].S.Field4=MF642;
roomrec[39].S.Field5=MF1622;
roomrec[39].S.Field6=MF3222;
roomrec[39].S.Field7=CR;
roomrec[39].S.floor=1;
/********************************************/

/********************************************/
roomrec[39].E.Field1=CF1;
roomrec[39].E.Field2=CF2;
roomrec[39].E.Field3=CF1;
roomrec[39].E.Field4=CF64;
roomrec[39].E.Field5=CF1;
roomrec[39].E.Field6=CF2;
roomrec[39].E.Field7=REG_MED_CLOSE_FILL;
roomrec[39].E.floor=1;
/********************************************/

/********************************************/
roomrec[39].W.Field1=REG_MED_CLOSE_FILL;
roomrec[39].W.Field2=CF1;
roomrec[39].W.Field3=CF2;
roomrec[39].W.Field4=CF64;
roomrec[39].W.Field5=CF2;
roomrec[39].W.Field6=CF1;
roomrec[39].W.Field7=CF2;
roomrec[39].W.floor=1;
/********************************************/


/********************************************/
roomrec[40].N.Field1=CL;
roomrec[40].N.Field2=ML;
roomrec[40].N.Field3=MF1621;
roomrec[40].N.Field4=MF642;
roomrec[40].N.Field5=MF1622;
roomrec[40].N.Field6=MR;
roomrec[40].N.Field7=CR;
roomrec[40].N.floor=1;
/********************************************/

/********************************************/
roomrec[40].S.Field1=CL;
roomrec[40].S.Field2=MF3222;
roomrec[40].S.Field3=MF1621;
roomrec[40].S.Field4=MF642;
roomrec[40].S.Field5=MF1622;
roomrec[40].S.Field6=MF3222;
roomrec[40].S.Field7=CR;
roomrec[40].S.floor=1;
/********************************************/

/********************************************/
roomrec[40].E.Field1=CF1;
roomrec[40].E.Field2=CF2;
roomrec[40].E.Field3=CF1;
roomrec[40].E.Field4=CF64;
roomrec[40].E.Field5=CF1;
roomrec[40].E.Field6=CF2;
roomrec[40].E.Field7=REG_MED_CLOSE_FILL;
roomrec[40].E.floor=1;
/********************************************/

/********************************************/
roomrec[40].W.Field1=REG_MED_CLOSE_FILL;
roomrec[40].W.Field2=CF1;
roomrec[40].W.Field3=CF2;
roomrec[40].W.Field4=CF64;
roomrec[40].W.Field5=CF2;
roomrec[40].W.Field6=CF1;
roomrec[40].W.Field7=CR;
roomrec[40].W.floor=1;
/********************************************/

/********************************************/
roomrec[41].N.Field1=CL;
roomrec[41].N.Field2=ML;
roomrec[41].N.Field3=FL;
roomrec[41].N.Field4=EMPTY;
roomrec[41].N.Field5=FR;
roomrec[41].N.Field6=MR;
roomrec[41].N.Field7=CR;
roomrec[41].N.floor=1;
/********************************************/

/********************************************/
roomrec[41].S.Field1=CL;
roomrec[41].S.Field2=ML;
roomrec[41].S.Field3=MF1621;
roomrec[41].S.Field4=MF642;
roomrec[41].S.Field5=MF1622;
roomrec[41].S.Field6=MF3222;
roomrec[41].S.Field7=CR;
roomrec[41].S.floor=1;
/********************************************/

/********************************************/
roomrec[41].E.Field1=CF1;
roomrec[41].E.Field2=CF2;
roomrec[41].E.Field3=CF1;
roomrec[41].E.Field4=CF64;
roomrec[41].E.Field5=CF1;
roomrec[41].E.Field6=CF2;
roomrec[41].E.Field7=CF1;
roomrec[41].E.floor=1;
/********************************************/

/********************************************/
roomrec[41].W.Field1=REG_MED_CLOSE_FILL;
roomrec[41].W.Field2=CF1;
roomrec[41].W.Field3=CF2;
roomrec[41].W.Field4=CF64;
roomrec[41].W.Field5=CF2;
roomrec[41].W.Field6=CF1;
roomrec[41].W.Field7=CF2;
roomrec[41].W.floor=1;
/********************************************/

/********************************************/
roomrec[42].N.Field1=CL;
roomrec[42].N.Field2=ML;
roomrec[42].N.Field3=FL;
roomrec[42].N.Field4=FF642;
roomrec[42].N.Field5=FF1622;
roomrec[42].N.Field6=MR;
roomrec[42].N.Field7=CF1;
roomrec[42].N.floor=1;
/********************************************/

/********************************************/
roomrec[42].S.Field1=CF1;
roomrec[42].S.Field2=CF2;
roomrec[42].S.Field3=CF1;
roomrec[42].S.Field4=CF64;
roomrec[42].S.Field5=CF1;
roomrec[42].S.Field6=CF2;
roomrec[42].S.Field7=CR;
roomrec[42].S.floor=1;
/********************************************/


/********************************************/
roomrec[42].E.Field1=CF2;
roomrec[42].E.Field2=ML;
roomrec[42].E.Field3=FL;
roomrec[42].E.Field4=EMPTY;
roomrec[42].E.Field5=FR;
roomrec[42].E.Field6=MR;
roomrec[42].E.Field7=CR;
roomrec[42].E.floor=1;
/********************************************/

/********************************************/
roomrec[42].W.Field1=CL;
roomrec[42].W.Field2=CF1;
roomrec[42].W.Field3=CF2;
roomrec[42].W.Field4=CF64;
roomrec[42].W.Field5=CF1;
roomrec[42].W.Field6=CF2;
roomrec[42].W.Field7=CF1;
roomrec[42].W.floor=1;
/********************************************/

/********************************************/
roomrec[43].N.Field1=REG_MED_CLOSE_FILL;
roomrec[43].N.Field2=CF1;
roomrec[43].N.Field3=CF2;
roomrec[43].N.Field4=CF64;
roomrec[43].N.Field5=CF2;
roomrec[43].N.Field6=CF1;
roomrec[43].N.Field7=CF2;
roomrec[43].N.floor=0;
/********************************************/

/********************************************/
roomrec[43].S.Field1=CF2;
roomrec[43].S.Field2=CF1;
roomrec[43].S.Field3=CF2;
roomrec[43].S.Field4=CF64;
roomrec[43].S.Field5=CF1;
roomrec[43].S.Field6=CF2;
roomrec[43].S.Field7=CF1;
roomrec[43].S.floor=0;
/********************************************/

/********************************************/
roomrec[43].E.Field1=CL;
roomrec[43].E.Field2=ML;
roomrec[43].E.Field3=REG_FAR_FILL;
roomrec[43].E.Field4=EMPTY;
roomrec[43].E.Field5=FR;
roomrec[43].E.Field6=MR;
roomrec[43].E.Field7=CR;
roomrec[43].E.floor=0;
/********************************************/

/********************************************/
roomrec[43].W.Field1=CL;
roomrec[43].W.Field2=ML;
roomrec[43].W.Field3=MF1611;
roomrec[43].W.Field4=MF641;
roomrec[43].W.Field5=MF1612;
roomrec[43].W.Field6=MF3212;
roomrec[43].W.Field7=CR;
roomrec[43].W.floor=0;
/********************************************/

/********************************************/
roomrec[44].N.Field1=CF1;
roomrec[44].N.Field2=CF2;
roomrec[44].N.Field3=CF1;
roomrec[44].N.Field4=CF64;
roomrec[44].N.Field5=CF1;
roomrec[44].N.Field6=CF2;
roomrec[44].N.Field7=REG_MED_CLOSE_FILL;
roomrec[44].N.floor=1;
/********************************************/

/********************************************/
roomrec[44].S.Field1=CF1;
roomrec[44].S.Field2=CF2;
roomrec[44].S.Field3=CF1;
roomrec[44].S.Field4=CF64;
roomrec[44].S.Field5=CF2;
roomrec[44].S.Field6=CF1;
roomrec[44].S.Field7=CF2;
roomrec[44].S.floor=1;
/********************************************/

/********************************************/
roomrec[44].E.Field1=CL;
roomrec[44].E.Field2=MF3221;
roomrec[44].E.Field3=FL;
roomrec[44].E.Field4=EMPTY;
roomrec[44].E.Field5=FR;
roomrec[44].E.Field6=MR;
roomrec[44].E.Field7=CR;
roomrec[44].E.floor=1;
/********************************************/

/********************************************/
roomrec[44].W.Field1=CL;
roomrec[44].W.Field2=ML;
roomrec[44].W.Field3=FL;
roomrec[44].W.Field4=FF642;
roomrec[44].W.Field5=FF1622;
roomrec[44].W.Field6=MR;
roomrec[44].W.Field7=CR;
roomrec[44].W.floor=1;
/********************************************/

/********************************************/
roomrec[45].N.Field1=CF2;
roomrec[45].N.Field2=ML;
roomrec[45].N.Field3=FL;
roomrec[45].N.Field4=EMPTY;
roomrec[45].N.Field5=FR;
roomrec[45].N.Field6=MR;
roomrec[45].N.Field7=CF1;
roomrec[45].N.floor=0;
/********************************************/

/********************************************/
roomrec[45].S.Field1=CF2;
roomrec[45].S.Field2=CF1;
roomrec[45].S.Field3=CF2;
roomrec[45].S.Field4=CF64;
roomrec[45].S.Field5=CF1;
roomrec[45].S.Field6=CF2;
roomrec[45].S.Field7=CF1;
roomrec[45].S.floor=0;
/********************************************/

/********************************************/
roomrec[45].E.Field1=CF2;
roomrec[45].E.Field2=ML;
roomrec[45].E.Field3=FL;
roomrec[45].E.Field4=EMPTY;
roomrec[45].E.Field5=FR;
roomrec[45].E.Field6=MR;
roomrec[45].E.Field7=CR;
roomrec[45].E.floor=0;
/********************************************/

/********************************************/
roomrec[45].W.Field1=CL;
roomrec[45].W.Field2=ML;
roomrec[45].W.Field3=FL;
roomrec[45].W.Field4=EMPTY;
roomrec[45].W.Field5=FR;
roomrec[45].W.Field6=MR;
roomrec[45].W.Field7=CF1;
roomrec[45].W.floor=0;
/********************************************/

/********************************************/
roomrec[46].N.Field1=REG_MED_CLOSE_FILL;
roomrec[46].N.Field2=CF1;
roomrec[46].N.Field3=CF2;
roomrec[46].N.Field4=CF64;
roomrec[46].N.Field5=CF2;
roomrec[46].N.Field6=CF1;
roomrec[46].N.Field7=CF2;
roomrec[46].N.floor=1;
/********************************************/

/********************************************/
roomrec[46].S.Field1=CF1;
roomrec[46].S.Field2=CF2;
roomrec[46].S.Field3=CF1;
roomrec[46].S.Field4=CF64;
roomrec[46].S.Field5=CF1;
roomrec[46].S.Field6=CF2;
roomrec[46].S.Field7=CF1;
roomrec[46].S.floor=1;
/********************************************/

/********************************************/
roomrec[46].E.Field1=CL;
roomrec[46].E.Field2=ML;
roomrec[46].E.Field3=FL;
roomrec[46].E.Field4=EMPTY;
roomrec[46].E.Field5=FR;
roomrec[46].E.Field6=MR;
roomrec[46].E.Field7=CR;
roomrec[46].E.floor=1;
/********************************************/

/********************************************/
roomrec[46].W.Field1=CL;
roomrec[46].W.Field2=ML;
roomrec[46].W.Field3=FL;
roomrec[46].W.Field4=EMPTY;
roomrec[46].W.Field5=FR;
roomrec[46].W.Field6=MF3222;
roomrec[46].W.Field7=CR;
roomrec[46].W.floor=1;
/********************************************/

/********************************************/
roomrec[47].N.Field1=CF2;
roomrec[47].N.Field2=CF1;
roomrec[47].N.Field3=CF2;
roomrec[47].N.Field4=CF64;
roomrec[47].N.Field5=CF1;
roomrec[47].N.Field6=CF2;
roomrec[47].N.Field7=CF1;
roomrec[47].N.floor=0;
/********************************************/

/********************************************/
roomrec[47].S.Field1=CF1;
roomrec[47].S.Field2=CF2;
roomrec[47].S.Field3=CF1;
roomrec[47].S.Field4=CF64;
roomrec[47].S.Field5=CF2;
roomrec[47].S.Field6=CF1;
roomrec[47].S.Field7=CF2;
roomrec[47].S.floor=0;
/********************************************/

/********************************************/
roomrec[47].E.Field1=CL;
roomrec[47].E.Field2=ML;
roomrec[47].E.Field3=FL;
roomrec[47].E.Field4=EMPTY;
roomrec[47].E.Field5=FR;
roomrec[47].E.Field6=MR;
roomrec[47].E.Field7=CR;
roomrec[47].E.floor=0;
/********************************************/

/********************************************/
roomrec[47].W.Field1=CL;
roomrec[47].W.Field2=ML;
roomrec[47].W.Field3=FL;
roomrec[47].W.Field4=EMPTY;
roomrec[47].W.Field5=REG_FAR_FILL;
roomrec[47].W.Field6=MR;
roomrec[47].W.Field7=CR;
roomrec[47].W.floor=0;
/********************************************/

/********************************************/
roomrec[48].N.Field1=CF1;
roomrec[48].N.Field2=CF2;
roomrec[48].N.Field3=CF1;
roomrec[48].N.Field4=CF64;
roomrec[48].N.Field5=CF2;
roomrec[48].N.Field6=CF1;
roomrec[48].N.Field7=CF2;
roomrec[48].N.floor=1;
/********************************************/

/********************************************/
roomrec[48].S.Field1=CF2;
roomrec[48].S.Field2=CF1;
roomrec[48].S.Field3=CF2;
roomrec[48].S.Field4=CF64;
roomrec[48].S.Field5=CF1;
roomrec[48].S.Field6=CF2;
roomrec[48].S.Field7=CF1;
roomrec[48].S.floor=1;
/********************************************/

/********************************************/
roomrec[48].E.Field1=CL;
roomrec[48].E.Field2=ML;
roomrec[48].E.Field3=FL;
roomrec[48].E.Field4=EMPTY;
roomrec[48].E.Field5=FR;
roomrec[48].E.Field6=MR;
roomrec[48].E.Field7=CR;
roomrec[48].E.floor=1;
/********************************************/

/********************************************/
roomrec[48].W.Field1=CL;
roomrec[48].W.Field2=ML;
roomrec[48].W.Field3=FL;
roomrec[48].W.Field4=EMPTY;
roomrec[48].W.Field5=FR;
roomrec[48].W.Field6=MR;
roomrec[48].W.Field7=CR;
roomrec[48].W.floor=1;
/********************************************/

/********************************************/
roomrec[49].N.Field1=CF2;
roomrec[49].N.Field2=CF1;
roomrec[49].N.Field3=CF2;
roomrec[49].N.Field4=CF64;
roomrec[49].N.Field5=CF1;
roomrec[49].N.Field6=CF2;
roomrec[49].N.Field7=CF1;
roomrec[49].N.floor=0;
/********************************************/

/********************************************/
roomrec[49].S.Field1=CF1;
roomrec[49].S.Field2=CF2;
roomrec[49].S.Field3=CF1;
roomrec[49].S.Field4=CF64;
roomrec[49].S.Field5=CF2;
roomrec[49].S.Field6=CF1;
roomrec[49].S.Field7=CF2;
roomrec[49].S.floor=0;
/********************************************/

/********************************************/
roomrec[49].E.Field1=CL;
roomrec[49].E.Field2=ML;
roomrec[49].E.Field3=FF1611;
roomrec[49].E.Field4=FF641;
roomrec[49].E.Field5=FR;
roomrec[49].E.Field6=MR;
roomrec[49].E.Field7=CR;
roomrec[49].E.floor=0;
/********************************************/

/********************************************/
roomrec[49].W.Field1=CL;
roomrec[49].W.Field2=ML;
roomrec[49].W.Field3=FL;
roomrec[49].W.Field4=EMPTY;
roomrec[49].W.Field5=FR;
roomrec[49].W.Field6=MR;
roomrec[49].W.Field7=CR;
roomrec[49].W.floor=0;
/********************************************/

/********************************************/
roomrec[50].N.Field1=CF1;
roomrec[50].N.Field2=CF2;
roomrec[50].N.Field3=CF1;
roomrec[50].N.Field4=CF64;
roomrec[50].N.Field5=CF1;
roomrec[50].N.Field6=CF2;
roomrec[50].N.Field7=REG_MED_CLOSE_FILL;
roomrec[50].N.floor=1;
/********************************************/

/********************************************/
roomrec[50].S.Field1=CF2;
roomrec[50].S.Field2=CF1;
roomrec[50].S.Field3=CF2;
roomrec[50].S.Field4=CF64;
roomrec[50].S.Field5=CF1;
roomrec[50].S.Field6=CF2;
roomrec[50].S.Field7=CF1;
roomrec[50].S.floor=1;
/********************************************/

/********************************************/
roomrec[50].E.Field1=CL;
roomrec[50].E.Field2=MF3222;
roomrec[50].E.Field3=MF1621;
roomrec[50].E.Field4=MF642;
roomrec[50].E.Field5=MF1622;
roomrec[50].E.Field6=MR;
roomrec[50].E.Field7=CR;
roomrec[50].E.floor=1;
/********************************************/

/********************************************/
roomrec[50].W.Field1=CL;
roomrec[50].W.Field2=ML;
roomrec[50].W.Field3=FL;
roomrec[50].W.Field4=EMPTY;
roomrec[50].W.Field5=FR;
roomrec[50].W.Field6=MR;
roomrec[50].W.Field7=CR;
roomrec[50].W.floor=1;
/********************************************/

/********************************************/
roomrec[51].N.Field1=CF1;
roomrec[51].N.Field2=ML;
roomrec[51].N.Field3=FL;
roomrec[51].N.Field4=EMPTY;
roomrec[51].N.Field5=FR;
roomrec[51].N.Field6=MR;
roomrec[51].N.Field7=CR;
roomrec[51].N.floor=0;
/********************************************/

/********************************************/
roomrec[51].S.Field1=CL;
roomrec[51].S.Field2=CF1;
roomrec[51].S.Field3=CF2;
roomrec[51].S.Field4=CF64;
roomrec[51].S.Field5=CF2;
roomrec[51].S.Field6=CF1;
roomrec[51].S.Field7=CF2;
roomrec[51].S.floor=0;
/********************************************/

/********************************************/
roomrec[51].E.Field1=CF1;
roomrec[51].E.Field2=CF2;
roomrec[51].E.Field3=CF1;
roomrec[51].E.Field4=CF64;
roomrec[51].E.Field5=CF1;
roomrec[51].E.Field6=CF2;
roomrec[51].E.Field7=CR;
roomrec[51].E.floor=0;
/********************************************/

/********************************************/
roomrec[51].W.Field1=CL;
roomrec[51].W.Field2=ML;
roomrec[51].W.Field3=FL;
roomrec[51].W.Field4=EMPTY;
roomrec[51].W.Field5=FR;
roomrec[51].W.Field6=MR;
roomrec[51].W.Field7=CF1;
roomrec[51].W.floor=0;
/********************************************/

}
