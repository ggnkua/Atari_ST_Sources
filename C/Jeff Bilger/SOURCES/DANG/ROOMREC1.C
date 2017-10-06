/* this is the first module of room rec. it
inits rooms 1-100
 

*/
#define CL 1
#define CR 2
#define CF 3
#define ML 4
#define MR 5
#define MF 6
#define FL 7
#define FR 8
#define FF 9
#define EMPTY 0


extern struct field_data
    {
    int Field1,
        Field2,
        Field3,
        Field4,
        Field5,
        Field6;
    };

extern struct pic_data
   {
    struct field_data N,
                      S,
                      E,
                      W;
  
   };

extern struct pic_data roomrec[250];  /* start at 1.... */

/***/
set_up1()
{
/* first define which ways you can go in each room. n,s,e,w, 0 means
  its a wall */

/* now define the templates needed when facing a dir in a room */


/**************************/
                                /* Room 1 */
roomrec[1].N.Field1 = CF; 
roomrec[1].N.Field2 = CF;
roomrec[1].N.Field3 = CF;
roomrec[1].N.Field4 = CF;
roomrec[1].N.Field5 = CF;
roomrec[1].N.Field6 = CF;

roomrec[1].S.Field1 = MF; 
roomrec[1].S.Field2 = ML;
roomrec[1].S.Field3 = FL;
roomrec[1].S.Field4 = FR;
roomrec[1].S.Field5 = MR;
roomrec[1].S.Field6 = CR;

roomrec[1].E.Field1 = CL; 
roomrec[1].E.Field2 = ML;
roomrec[1].E.Field3 = FL;
roomrec[1].E.Field4 = FR;
roomrec[1].E.Field5 = MR;
roomrec[1].E.Field6 = MF;

roomrec[1].W.Field1 = CF; 
roomrec[1].W.Field2 = CF;
roomrec[1].W.Field3 = CF;
roomrec[1].W.Field4 = CF;
roomrec[1].W.Field5 = CF;
roomrec[1].W.Field6 = CF;

/******************************/
                                 /* room 2 */
roomrec[2].N.Field1 = CF; 
roomrec[2].N.Field2 = CF;
roomrec[2].N.Field3 = CF;
roomrec[2].N.Field4 = CF;
roomrec[2].N.Field5 = CF;
roomrec[2].N.Field6 = CF;

roomrec[2].S.Field1 = CF; 
roomrec[2].S.Field2 = CF;
roomrec[2].S.Field3 = CF;
roomrec[2].S.Field4 = CF;
roomrec[2].S.Field5 = CF;
roomrec[2].S.Field6 = CF;

roomrec[2].E.Field1 = CL; 
roomrec[2].E.Field2 = ML;
roomrec[2].E.Field3 = FL;
roomrec[2].E.Field4 = FR;
roomrec[2].E.Field5 = MR;
roomrec[2].E.Field6 = CR;

roomrec[2].W.Field1 = CL; 
roomrec[2].W.Field2 = FF;
roomrec[2].W.Field3 = FF;
roomrec[2].W.Field4 = FF;
roomrec[2].W.Field5 = MR;
roomrec[2].W.Field6 = CR;


/******************************/
                               /* room 3 */

roomrec[3].N.Field1 = CF; 
roomrec[3].N.Field2 = CF;
roomrec[3].N.Field3 = CF;
roomrec[3].N.Field4 = CF;
roomrec[3].N.Field5 = CF;
roomrec[3].N.Field6 = CF;

roomrec[3].S.Field1 = CF; 
roomrec[3].S.Field2 = CF;
roomrec[3].S.Field3 = CF;
roomrec[3].S.Field4 = CF;
roomrec[3].S.Field5 = CF;
roomrec[3].S.Field6 = CF;

roomrec[3].E.Field1 = CL; 
roomrec[3].E.Field2 = ML;
roomrec[3].E.Field3 = FL;
roomrec[3].E.Field4 = FR;
roomrec[3].E.Field5 = MR;
roomrec[3].E.Field6 = CR;

roomrec[3].W.Field1 = CL; 
roomrec[3].W.Field2 = ML;
roomrec[3].W.Field3 = EMPTY;
roomrec[3].W.Field4 = FR;
roomrec[3].W.Field5 = MR;
roomrec[3].W.Field6 = CR;


/***************************/
                            /* Room 4 */
roomrec[4].N.Field1 = CF; 
roomrec[4].N.Field2 = CF;
roomrec[4].N.Field3 = CF;
roomrec[4].N.Field4 = CF;
roomrec[4].N.Field5 = CF;
roomrec[4].N.Field6 = CF;

roomrec[4].S.Field1 = CF; 
roomrec[4].S.Field2 = CF;
roomrec[4].S.Field3 = CF;
roomrec[4].S.Field4 = CF;
roomrec[4].S.Field5 = CF;
roomrec[4].S.Field6 = CF;

roomrec[4].E.Field1 = CL; 
roomrec[4].E.Field2 = ML;
roomrec[4].E.Field3 = FL;
roomrec[4].E.Field4 = EMPTY;
roomrec[4].E.Field5 = MR;
roomrec[4].E.Field6 = CR;

roomrec[4].W.Field1 = CL; 
roomrec[4].W.Field2 = ML;
roomrec[4].W.Field3 = FL;
roomrec[4].W.Field4 = FR;
roomrec[4].W.Field5 = MR;
roomrec[4].W.Field6 = CR;

/****************************/
                             /* room 5 */
roomrec[5].N.Field1 = CF; 
roomrec[5].N.Field2 = CF;
roomrec[5].N.Field3 = CF;
roomrec[5].N.Field4 = CF;
roomrec[5].N.Field5 = CF;
roomrec[5].N.Field6 = CF;

roomrec[5].S.Field1 = CF; 
roomrec[5].S.Field2 = CF;
roomrec[5].S.Field3 = CF;
roomrec[5].S.Field4 = CF;
roomrec[5].S.Field5 = CF;
roomrec[5].S.Field6 = CF;

roomrec[5].E.Field1 = CL; 
roomrec[5].E.Field2 = ML;
roomrec[5].E.Field3 = FL;
roomrec[5].E.Field4 = FR;
roomrec[5].E.Field5 = FF;
roomrec[5].E.Field6 = CR;

roomrec[5].W.Field1 = CL; 
roomrec[5].W.Field2 = ML;
roomrec[5].W.Field3 = FL;
roomrec[5].W.Field4 = FR;
roomrec[5].W.Field5 = MR;
roomrec[5].W.Field6 = CR;

/**************************/  

                             /* Room : 6 */
roomrec[6].N.Field1 = CF; 
roomrec[6].N.Field2 = CF;
roomrec[6].N.Field3 = CF;
roomrec[6].N.Field4 = CF;
roomrec[6].N.Field5 = CF;
roomrec[6].N.Field6 = CF;

roomrec[6].S.Field1 = MF; 
roomrec[6].S.Field2 = ML;
roomrec[6].S.Field3 = FL;
roomrec[6].S.Field4 = EMPTY;
roomrec[6].S.Field5 = MR;
roomrec[6].S.Field6 = MF;

roomrec[6].E.Field1 = CL; 
roomrec[6].E.Field2 = ML;
roomrec[6].E.Field3 = FL;
roomrec[6].E.Field4 = FR;
roomrec[6].E.Field5 = MR;
roomrec[6].E.Field6 = MF;

roomrec[6].W.Field1 = MF; 
roomrec[6].W.Field2 = ML;
roomrec[6].W.Field3 = FL;
roomrec[6].W.Field4 = FR;
roomrec[6].W.Field5 = MR;
roomrec[6].W.Field6 = CR;

/**************************/
/**************************/  

                             /* Room : 7 */
roomrec[7].N.Field1 = CF; 
roomrec[7].N.Field2 = CF;
roomrec[7].N.Field3 = CF;
roomrec[7].N.Field4 = CF;
roomrec[7].N.Field5 = CF;
roomrec[7].N.Field6 = CF;

roomrec[7].S.Field1 = CF; 
roomrec[7].S.Field2 = CF;
roomrec[7].S.Field3 = CF;
roomrec[7].S.Field4 = CF;
roomrec[7].S.Field5 = CF;
roomrec[7].S.Field6 = CF;

roomrec[7].E.Field1 = CL; 
roomrec[7].E.Field2 = ML;
roomrec[7].E.Field3 = FL;
roomrec[7].E.Field4 = EMPTY;
roomrec[7].E.Field5 = MR;
roomrec[7].E.Field6 = CR;

roomrec[7].W.Field1 = CL; 
roomrec[7].W.Field2 = FF;
roomrec[7].W.Field3 = FL;
roomrec[7].W.Field4 = FR;
roomrec[7].W.Field5 = MR;
roomrec[7].W.Field6 = CR;

/**************************/

/**************************/  

                             /* Room : 8 */
roomrec[8].N.Field1 = CF; 
roomrec[8].N.Field2 = CF;
roomrec[8].N.Field3 = CF;
roomrec[8].N.Field4 = CF;
roomrec[8].N.Field5 = CF;
roomrec[8].N.Field6 = CF;

roomrec[8].S.Field1 = CF; 
roomrec[8].S.Field2 = CF;
roomrec[8].S.Field3 = CF;
roomrec[8].S.Field4 = CF;
roomrec[8].S.Field5 = CF;
roomrec[8].S.Field6 = CF;

roomrec[8].E.Field1 = CL; 
roomrec[8].E.Field2 = ML;
roomrec[8].E.Field3 = FL;
roomrec[8].E.Field4 = FR;
roomrec[8].E.Field5 = FF;
roomrec[8].E.Field6 = CR;

roomrec[8].W.Field1 = CL; 
roomrec[8].W.Field2 = ML;
roomrec[8].W.Field3 = EMPTY;
roomrec[8].W.Field4 = FR;
roomrec[8].W.Field5 = MR;
roomrec[8].W.Field6 = CR;


/**************************/  

                             /* Room : 9 */
roomrec[9].N.Field1 = CF; 
roomrec[9].N.Field2 = CF;
roomrec[9].N.Field3 = CF;
roomrec[9].N.Field4 = CF;
roomrec[9].N.Field5 = CF;
roomrec[9].N.Field6 = CF;

roomrec[9].S.Field1 = MF; 
roomrec[9].S.Field2 = ML;
roomrec[9].S.Field3 = EMPTY;
roomrec[9].S.Field4 = FR;
roomrec[9].S.Field5 = MR;
roomrec[9].S.Field6 = MF;

roomrec[9].E.Field1 = CL; 
roomrec[9].E.Field2 = ML;
roomrec[9].E.Field3 = FL;
roomrec[9].E.Field4 = FR;
roomrec[9].E.Field5 = MR;
roomrec[9].E.Field6 = MF;

roomrec[9].W.Field1 = MF; 
roomrec[9].W.Field2 = ML;
roomrec[9].W.Field3 = FL;
roomrec[9].W.Field4 = FR;
roomrec[9].W.Field5 = MR;
roomrec[9].W.Field6 = CR;
/**************************/  /**************************/  

                             /* Room : 10 */
roomrec[10].N.Field1 = CF; 
roomrec[10].N.Field2 = CF;
roomrec[10].N.Field3 = CF;
roomrec[10].N.Field4 = CF;
roomrec[10].N.Field5 = CF;
roomrec[10].N.Field6 = CF;

roomrec[10].S.Field1 = CF; 
roomrec[10].S.Field2 = CF;
roomrec[10].S.Field3 = CF;
roomrec[10].S.Field4 = CF;
roomrec[10].S.Field5 = CF;
roomrec[10].S.Field6 = CF;

roomrec[10].E.Field1 = CL; 
roomrec[10].E.Field2 = ML;
roomrec[10].E.Field3 = FL;
roomrec[10].E.Field4 = EMPTY;
roomrec[10].E.Field5 = MR;
roomrec[10].E.Field6 = CR;

roomrec[10].W.Field1 = CL; 
roomrec[10].W.Field2 = FF;
roomrec[10].W.Field3 = FL;
roomrec[10].W.Field4 = FR;
roomrec[10].W.Field5 = MR;
roomrec[10].W.Field6 = CR;

/**************************/

/**************************/  

                             /* Room : 11 */
roomrec[11].N.Field1 = CF; 
roomrec[11].N.Field2 = CF;
roomrec[11].N.Field3 = CF;
roomrec[11].N.Field4 = CF;
roomrec[11].N.Field5 = CF;
roomrec[11].N.Field6 = CF;

roomrec[11].S.Field1 = CF; 
roomrec[11].S.Field2 = CF;
roomrec[11].S.Field3 = CF;
roomrec[11].S.Field4 = CF;
roomrec[11].S.Field5 = CF;
roomrec[11].S.Field6 = CF;

roomrec[11].E.Field1 = CL; 
roomrec[11].E.Field2 = ML;
roomrec[11].E.Field3 = FL;
roomrec[11].E.Field4 = FR;
roomrec[11].E.Field5 = FF;
roomrec[11].E.Field6 = CR;

roomrec[11].W.Field1 = CL; 
roomrec[11].W.Field2 = ML;
roomrec[11].W.Field3 = EMPTY;
roomrec[11].W.Field4 = FR;
roomrec[11].W.Field5 = MR;
roomrec[11].W.Field6 = CR;


/**************************/  

                             /* Room : 12 */
roomrec[12].N.Field1 = CF; 
roomrec[12].N.Field2 = CF;
roomrec[12].N.Field3 = CF;
roomrec[12].N.Field4 = CF;
roomrec[12].N.Field5 = CF;
roomrec[12].N.Field6 = CF;

roomrec[12].S.Field1 = MF; 
roomrec[12].S.Field2 = ML;
roomrec[12].S.Field3 = EMPTY;
roomrec[12].S.Field4 = EMPTY;
roomrec[12].S.Field5 = MR;
roomrec[12].S.Field6 = MF;

roomrec[12].E.Field1 = CL; 
roomrec[12].E.Field2 = ML;
roomrec[12].E.Field3 = FL;
roomrec[12].E.Field4 = FR;
roomrec[12].E.Field5 = MR;
roomrec[12].E.Field6 = MF;

roomrec[12].W.Field1 = MF; 
roomrec[12].W.Field2 = ML;
roomrec[12].W.Field3 = FL;
roomrec[12].W.Field4 = FR;
roomrec[12].W.Field5 = MR;
roomrec[12].W.Field6 = CR;

/**************************/
 /**************************/  

                             /* Room : 13 */
roomrec[13].N.Field1 = CF; 
roomrec[13].N.Field2 = CF;
roomrec[13].N.Field3 = CF;
roomrec[13].N.Field4 = CF;
roomrec[13].N.Field5 = CF;
roomrec[13].N.Field6 = CF;

roomrec[13].S.Field1 = CF; 
roomrec[13].S.Field2 = CF;
roomrec[13].S.Field3 = CF;
roomrec[13].S.Field4 = CF;
roomrec[13].S.Field5 = CF;
roomrec[13].S.Field6 = CF;

roomrec[13].E.Field1 = CL; 
roomrec[13].E.Field2 = ML;
roomrec[13].E.Field3 = FL;
roomrec[13].E.Field4 = EMPTY;
roomrec[13].E.Field5 = MR;
roomrec[13].E.Field6 = CR;

roomrec[13].W.Field1 = CL; 
roomrec[13].W.Field2 = FF;
roomrec[13].W.Field3 = FL;
roomrec[13].W.Field4 = FR;
roomrec[13].W.Field5 = MR;
roomrec[13].W.Field6 = CR;

/**************************/

/**************************/  

                             /* Room : 14 */
roomrec[14].N.Field1 = CF; 
roomrec[14].N.Field2 = CF;
roomrec[14].N.Field3 = CF;
roomrec[14].N.Field4 = CF;
roomrec[14].N.Field5 = CF;
roomrec[14].N.Field6 = CF;

roomrec[14].S.Field1 = CF; 
roomrec[14].S.Field2 = CF;
roomrec[14].S.Field3 = CF;
roomrec[14].S.Field4 = CF;
roomrec[14].S.Field5 = CF;
roomrec[14].S.Field6 = CF;

roomrec[14].E.Field1 = CL; 
roomrec[14].E.Field2 = ML;
roomrec[14].E.Field3 = FL;
roomrec[14].E.Field4 = FR;
roomrec[14].E.Field5 = FF;
roomrec[14].E.Field6 = CR;

roomrec[14].W.Field1 = CL; 
roomrec[14].W.Field2 = ML;
roomrec[14].W.Field3 = EMPTY;
roomrec[14].W.Field4 = FR;
roomrec[14].W.Field5 = MR;
roomrec[14].W.Field6 = CR;


/**************************/  
/**************************/  

                             /* Room : 15 */
roomrec[15].N.Field1 = CF; 
roomrec[15].N.Field2 = CF;
roomrec[15].N.Field3 = CF;
roomrec[15].N.Field4 = CF;
roomrec[15].N.Field5 = CF;
roomrec[15].N.Field6 = CF;

roomrec[15].S.Field1 = MF; 
roomrec[15].S.Field2 = ML;
roomrec[15].S.Field3 = FL;
roomrec[15].S.Field4 = EMPTY;
roomrec[15].S.Field5 = MR;
roomrec[15].S.Field6 = MF;

roomrec[15].E.Field1 = CL; 
roomrec[15].E.Field2 = ML;
roomrec[15].E.Field3 = FL;
roomrec[15].E.Field4 = EMPTY;
roomrec[15].E.Field5 = MR;
roomrec[15].E.Field6 = MF;

roomrec[15].W.Field1 = MF; 
roomrec[15].W.Field2 = ML;
roomrec[15].W.Field3 = FL;
roomrec[15].W.Field4 = FR;
roomrec[15].W.Field5 = MR;
roomrec[15].W.Field6 = CR;


/**************************/  
/**************************/  

                             /* Room : 16 */
roomrec[16].N.Field1 = CF; 
roomrec[16].N.Field2 = CF;
roomrec[16].N.Field3 = CF;
roomrec[16].N.Field4 = CF;
roomrec[16].N.Field5 = CF;
roomrec[16].N.Field6 = CF;

roomrec[16].S.Field1 = CF; 
roomrec[16].S.Field2 = CF;
roomrec[16].S.Field3 = CF;
roomrec[16].S.Field4 = CF;
roomrec[16].S.Field5 = CF;
roomrec[16].S.Field6 = CF;

roomrec[16].E.Field1 = CL; 
roomrec[16].E.Field2 = ML;
roomrec[16].E.Field3 = FF;
roomrec[16].E.Field4 = FF;
roomrec[16].E.Field5 = EMPTY;
roomrec[16].E.Field6 = CR;

roomrec[16].W.Field1 = CL; 
roomrec[16].W.Field2 = FF;
roomrec[16].W.Field3 = FL;
roomrec[16].W.Field4 = FR;
roomrec[16].W.Field5 = MR;
roomrec[16].W.Field6 = CR;


/**************************/  

                             /* Room : 17 */
roomrec[17].N.Field1 = CF; 
roomrec[17].N.Field2 = CF;
roomrec[17].N.Field3 = CF;
roomrec[17].N.Field4 = CF;
roomrec[17].N.Field5 = CF;
roomrec[17].N.Field6 = CF;

roomrec[17].S.Field1 = CL; 
roomrec[17].S.Field2 = FF;
roomrec[17].S.Field3 = FF;
roomrec[17].S.Field4 = FF;
roomrec[17].S.Field5 = MR;
roomrec[17].S.Field6 = MF;

roomrec[17].E.Field1 = CF; 
roomrec[17].E.Field2 = CF;
roomrec[17].E.Field3 = CF;
roomrec[17].E.Field4 = CF;
roomrec[17].E.Field5 = CF;
roomrec[17].E.Field6 = CF;

roomrec[17].W.Field1 = MF; 
roomrec[17].W.Field2 = ML;
roomrec[17].W.Field3 = EMPTY;
roomrec[17].W.Field4 = FR;
roomrec[17].W.Field5 = MR;
roomrec[17].W.Field6 = CR;

/**************************/  

                             /* Room : 18 */
roomrec[18].N.Field1 = CL; 
roomrec[18].N.Field2 = ML;
roomrec[18].N.Field3 = FF;
roomrec[18].N.Field4 = FF;
roomrec[18].N.Field5 = EMPTY;
roomrec[18].N.Field6 = CR;

roomrec[18].S.Field1 = CL; 
roomrec[18].S.Field2 = ML;
roomrec[18].S.Field3 = FL;
roomrec[18].S.Field4 = FR;
roomrec[18].S.Field5 = MR;
roomrec[18].S.Field6 = CR;

roomrec[18].E.Field1 = CF; 
roomrec[18].E.Field2 = CF;
roomrec[18].E.Field3 = CF;
roomrec[18].E.Field4 = CF;
roomrec[18].E.Field5 = CF;
roomrec[18].E.Field6 = CF;

roomrec[18].W.Field1 = CF; 
roomrec[18].W.Field2 = CF;
roomrec[18].W.Field3 = CF;
roomrec[18].W.Field4 = CF;
roomrec[18].W.Field5 = CF;
roomrec[18].W.Field6 = CF;
/**************************/  

                             /* Room : 19 */
roomrec[19].N.Field1 = CL; 
roomrec[19].N.Field2 = FF;
roomrec[19].N.Field3 = FF;
roomrec[19].N.Field4 = FF;
roomrec[19].N.Field5 = FF;
roomrec[19].N.Field6 = CR;

roomrec[19].S.Field1 = CL; 
roomrec[19].S.Field2 = ML;
roomrec[19].S.Field3 = FF;
roomrec[19].S.Field4 = FF;
roomrec[19].S.Field5 = EMPTY;
roomrec[19].S.Field6 = CR;

roomrec[19].E.Field1 = CF; 
roomrec[19].E.Field2 = CF;
roomrec[19].E.Field3 = CF;
roomrec[19].E.Field4 = CF;
roomrec[19].E.Field5 = CF;
roomrec[19].E.Field6 = CF;

roomrec[19].W.Field1 = CF; 
roomrec[19].W.Field2 = CF;
roomrec[19].W.Field3 = CF;
roomrec[19].W.Field4 = CF;
roomrec[19].W.Field5 = CF;
roomrec[19].W.Field6 = CF;
/**************************/  

                             /* Room : 20 */
roomrec[20].N.Field1 = CL; 
roomrec[20].N.Field2 = FF;
roomrec[20].N.Field3 = FF;
roomrec[20].N.Field4 = FF;
roomrec[20].N.Field5 = FF;
roomrec[20].N.Field6 = CR;

roomrec[20].S.Field1 = CL; 
roomrec[20].S.Field2 = FF;
roomrec[20].S.Field3 = FL;
roomrec[20].S.Field4 = EMPTY;
roomrec[20].S.Field5 = MR;
roomrec[20].S.Field6 = CR;

roomrec[20].E.Field1 = CF; 
roomrec[20].E.Field2 = CF;
roomrec[20].E.Field3 = CF;
roomrec[20].E.Field4 = CF;
roomrec[20].E.Field5 = CF;
roomrec[20].E.Field6 = CF;

roomrec[20].W.Field1 = CF; 
roomrec[20].W.Field2 = CF;
roomrec[20].W.Field3 = CF;
roomrec[20].W.Field4 = CF;
roomrec[20].W.Field5 = CF;
roomrec[20].W.Field6 = CF;
/**************************/  

                             /* Room : 21 */
roomrec[21].N.Field1 = CL; 
roomrec[21].N.Field2 = FF;
roomrec[21].N.Field3 = FF;
roomrec[21].N.Field4 = FF;
roomrec[21].N.Field5 = FF;
roomrec[21].N.Field6 = CR;

roomrec[21].S.Field1 = CL; 
roomrec[21].S.Field2 = FF;
roomrec[21].S.Field3 = FL;
roomrec[21].S.Field4 = FR;
roomrec[21].S.Field5 = FF;
roomrec[21].S.Field6 = CR;

roomrec[21].E.Field1 = CF; 
roomrec[21].E.Field2 = CF;
roomrec[21].E.Field3 = CF;
roomrec[21].E.Field4 = CF;
roomrec[21].E.Field5 = CF;
roomrec[21].E.Field6 = CF;

roomrec[21].W.Field1 = CF; 
roomrec[21].W.Field2 = CF;
roomrec[21].W.Field3 = CF;
roomrec[21].W.Field4 = CF;
roomrec[21].W.Field5 = CF;
roomrec[21].W.Field6 = CF;
/**************************/  

                             /* Room : 22 */
roomrec[22].N.Field1 = CL; 
roomrec[22].N.Field2 = FF;
roomrec[22].N.Field3 = FF;
roomrec[22].N.Field4 = FF;
roomrec[22].N.Field5 = FF;
roomrec[22].N.Field6 = CR;

roomrec[22].S.Field1 = CL; 
roomrec[22].S.Field2 = ML;
roomrec[22].S.Field3 = FF;
roomrec[22].S.Field4 = FF;
roomrec[22].S.Field5 = EMPTY;
roomrec[22].S.Field6 = CR;

roomrec[22].E.Field1 = CF; 
roomrec[22].E.Field2 = CF;
roomrec[22].E.Field3 = CF;
roomrec[22].E.Field4 = CF;
roomrec[22].E.Field5 = CF;
roomrec[22].E.Field6 = CF;

roomrec[22].W.Field1 = CF; 
roomrec[22].W.Field2 = CF;
roomrec[22].W.Field3 = CF;
roomrec[22].W.Field4 = CF;
roomrec[22].W.Field5 = CF;
roomrec[22].W.Field6 = CF;


/**************************/  

                             /* Room : 23 */
roomrec[23].N.Field1 = CL; 
roomrec[23].N.Field2 = FF;
roomrec[23].N.Field3 = FF;
roomrec[23].N.Field4 = FF;
roomrec[23].N.Field5 = MR;
roomrec[23].N.Field6 = MF;

roomrec[23].S.Field1 = CF; 
roomrec[23].S.Field2 = CF;
roomrec[23].S.Field3 = CF;
roomrec[23].S.Field4 = CF;
roomrec[23].S.Field5 = CF;
roomrec[23].S.Field6 = CF;

roomrec[23].E.Field1 = MF; 
roomrec[23].E.Field2 = ML;
roomrec[23].E.Field3 = FL;
roomrec[23].E.Field4 = FR;
roomrec[23].E.Field5 = MR;
roomrec[23].E.Field6 = CR;

roomrec[23].W.Field1 = CF; 
roomrec[23].W.Field2 = CF;
roomrec[23].W.Field3 = CF;
roomrec[23].W.Field4 = CF;
roomrec[23].W.Field5 = CF;
roomrec[23].W.Field6 = CF;
/**************************/  

                             /* Room : 24 */
roomrec[24].N.Field1 = CF; 
roomrec[24].N.Field2 = CF;
roomrec[24].N.Field3 = CF;
roomrec[24].N.Field4 = CF;
roomrec[24].N.Field5 = CF;
roomrec[24].N.Field6 = CF;

roomrec[24].S.Field1 = CF; 
roomrec[24].S.Field2 = CF;
roomrec[24].S.Field3 = CF;
roomrec[24].S.Field4 = CF;
roomrec[24].S.Field5 = CF;
roomrec[24].S.Field6 = CF;

roomrec[24].E.Field1 = CL; 
roomrec[24].E.Field2 = ML;
roomrec[24].E.Field3 = FL;
roomrec[24].E.Field4 = FR;
roomrec[24].E.Field5 = FF;
roomrec[24].E.Field6 = CR;

roomrec[24].W.Field1 = CL; 
roomrec[24].W.Field2 = ML;
roomrec[24].W.Field3 = FF;
roomrec[24].W.Field4 = FF;
roomrec[24].W.Field5 = EMPTY;
roomrec[24].W.Field6 = CR;
/**************************/  

                             /* Room : 25 */
roomrec[25].N.Field1 = CF; 
roomrec[25].N.Field2 = CF;
roomrec[25].N.Field3 = CF;
roomrec[25].N.Field4 = CF;
roomrec[25].N.Field5 = CF;
roomrec[25].N.Field6 = CF;

roomrec[25].S.Field1 = MF; 
roomrec[25].S.Field2 = ML;
roomrec[25].S.Field3 = FL;
roomrec[25].S.Field4 = EMPTY;
roomrec[25].S.Field5 = MR;
roomrec[25].S.Field6 = MF;

roomrec[25].E.Field1 = CL; 
roomrec[25].E.Field2 = ML;
roomrec[25].E.Field3 = FL;
roomrec[25].E.Field4 = FR;
roomrec[25].E.Field5 = MR;
roomrec[25].E.Field6 = MF;

roomrec[25].W.Field1 = MF; 
roomrec[25].W.Field2 = ML;
roomrec[25].W.Field3 = FL;
roomrec[25].W.Field4 = EMPTY;
roomrec[25].W.Field5 = MR;
roomrec[25].W.Field6 = CR;



/**************************/
                                /* Room 26 */
roomrec[26].N.Field1 = CF; 
roomrec[26].N.Field2 = CF;
roomrec[26].N.Field3 = CF;
roomrec[26].N.Field4 = CF;
roomrec[26].N.Field5 = CF;
roomrec[26].N.Field6 = CF;

roomrec[26].S.Field1 = CF; 
roomrec[26].S.Field2 = CF;
roomrec[26].S.Field3 = CF;
roomrec[26].S.Field4 = CF;
roomrec[26].S.Field5 = CF;
roomrec[26].S.Field6 = CF;

roomrec[26].E.Field1 = CL; 
roomrec[26].E.Field2 = ML;
roomrec[26].E.Field3 = FL;
roomrec[26].E.Field4 = FR;
roomrec[26].E.Field5 = MR;
roomrec[26].E.Field6 = CR;

roomrec[26].W.Field1 = CL; 
roomrec[26].W.Field2 = FF;
roomrec[26].W.Field3 = FL;
roomrec[26].W.Field4 = FR;
roomrec[26].W.Field5 = MR;
roomrec[26].W.Field6 = CR;

/******************************/
                                 /* room 27 */
roomrec[27].N.Field1 = CF; 
roomrec[27].N.Field2 = CF;
roomrec[27].N.Field3 = CF;
roomrec[27].N.Field4 = CF;
roomrec[27].N.Field5 = CF;
roomrec[27].N.Field6 = CF;

roomrec[27].S.Field1 = CF; 
roomrec[27].S.Field2 = CF;
roomrec[27].S.Field3 = CF;
roomrec[27].S.Field4 = CF;
roomrec[27].S.Field5 = CF;
roomrec[27].S.Field6 = CF;

roomrec[27].E.Field1 = CL; 
roomrec[27].E.Field2 = ML;
roomrec[27].E.Field3 = FL;
roomrec[27].E.Field4 = FR;
roomrec[27].E.Field5 = MR;
roomrec[27].E.Field6 = CR;

roomrec[27].W.Field1 = CL; 
roomrec[27].W.Field2 = ML;
roomrec[27].W.Field3 = EMPTY;
roomrec[27].W.Field4 = FR;
roomrec[27].W.Field5 = MR;
roomrec[27].W.Field6 = CR;


/******************************/
                               /* room 28 */

roomrec[28].N.Field1 = CF; 
roomrec[28].N.Field2 = CF;
roomrec[28].N.Field3 = CF;
roomrec[28].N.Field4 = CF;
roomrec[28].N.Field5 = CF;
roomrec[28].N.Field6 = CF;

roomrec[28].S.Field1 = CF; 
roomrec[28].S.Field2 = CF;
roomrec[28].S.Field3 = CF;
roomrec[28].S.Field4 = CF;
roomrec[28].S.Field5 = CF;
roomrec[28].S.Field6 = CF;

roomrec[28].E.Field1 = CL; 
roomrec[28].E.Field2 = ML;
roomrec[28].E.Field3 = FL;
roomrec[28].E.Field4 = FR;
roomrec[28].E.Field5 = MR;
roomrec[28].E.Field6 = CR;

roomrec[28].W.Field1 = CL; 
roomrec[28].W.Field2 = ML;
roomrec[28].W.Field3 = FL;
roomrec[28].W.Field4 = FR;
roomrec[28].W.Field5 = MR;
roomrec[28].W.Field6 = CR;


/***************************/
                            /* Room 29 */
roomrec[29].N.Field1 = CF; 
roomrec[29].N.Field2 = CF;
roomrec[29].N.Field3 = CF;
roomrec[29].N.Field4 = CF;
roomrec[29].N.Field5 = CF;
roomrec[29].N.Field6 = CF;

roomrec[29].S.Field1 = CF; 
roomrec[29].S.Field2 = CF;
roomrec[29].S.Field3 = CF;
roomrec[29].S.Field4 = CF;
roomrec[29].S.Field5 = CF;
roomrec[29].S.Field6 = CF;

roomrec[29].E.Field1 = CL; 
roomrec[29].E.Field2 = ML;
roomrec[29].E.Field3 = FL;
roomrec[29].E.Field4 = EMPTY;
roomrec[29].E.Field5 = MR;
roomrec[29].E.Field6 = CR;

roomrec[29].W.Field1 = CL; 
roomrec[29].W.Field2 = ML;
roomrec[29].W.Field3 = FL;
roomrec[29].W.Field4 = FR;
roomrec[29].W.Field5 = MR;
roomrec[29].W.Field6 = CR;

/****************************/
                             /* room 30 */
roomrec[30].N.Field1 = CF; 
roomrec[30].N.Field2 = CF;
roomrec[30].N.Field3 = CF;
roomrec[30].N.Field4 = CF;
roomrec[30].N.Field5 = CF;
roomrec[30].N.Field6 = CF;

roomrec[30].S.Field1 = CF; 
roomrec[30].S.Field2 = CF;
roomrec[30].S.Field3 = CF;
roomrec[30].S.Field4 = CF;
roomrec[30].S.Field5 = CF;
roomrec[30].S.Field6 = CF;

roomrec[30].E.Field1 = CL; 
roomrec[30].E.Field2 = ML;
roomrec[30].E.Field3 = FF;
roomrec[30].E.Field4 = FF;
roomrec[30].E.Field5 = FF;
roomrec[30].E.Field6 = CR;

roomrec[30].W.Field1 = CL; 
roomrec[30].W.Field2 = ML;
roomrec[30].W.Field3 = FL;
roomrec[30].W.Field4 = FR;
roomrec[30].W.Field5 = MR;
roomrec[30].W.Field6 = CR;

/**************************/  

                             /* Room : 31 */
roomrec[31].N.Field1 = CF; 
roomrec[31].N.Field2 = CF;
roomrec[31].N.Field3 = CF;
roomrec[31].N.Field4 = CF;
roomrec[31].N.Field5 = CF;
roomrec[31].N.Field6 = CF;

roomrec[31].S.Field1 = CL; 
roomrec[31].S.Field2 = ML;
roomrec[31].S.Field3 = FL;
roomrec[31].S.Field4 = FR;
roomrec[31].S.Field5 = MR;
roomrec[31].S.Field6 = MF;

roomrec[31].E.Field1 = CF; 
roomrec[31].E.Field2 = CF;
roomrec[31].E.Field3 = CF;
roomrec[31].E.Field4 = CF;
roomrec[31].E.Field5 = CF;
roomrec[31].E.Field6 = CF;

roomrec[31].W.Field1 = MF; 
roomrec[31].W.Field2 = ML;
roomrec[31].W.Field3 = FL;
roomrec[31].W.Field4 = FR;
roomrec[31].W.Field5 = MR;
roomrec[31].W.Field6 = CR;

/**************************/
/**************************/  

                             /* Room : 32 */
roomrec[32].N.Field1 = CL; 
roomrec[32].N.Field2 = ML;
roomrec[32].N.Field3 = FL;
roomrec[32].N.Field4 = EMPTY;
roomrec[32].N.Field5 = MR;
roomrec[32].N.Field6 = CR;

roomrec[32].S.Field1 = CL; 
roomrec[32].S.Field2 = ML;
roomrec[32].S.Field3 = FL;
roomrec[32].S.Field4 = FR;
roomrec[32].S.Field5 = MR;
roomrec[32].S.Field6 = CR;

roomrec[32].E.Field1 = CF; 
roomrec[32].E.Field2 = CF;
roomrec[32].E.Field3 = CF;
roomrec[32].E.Field4 = CF;
roomrec[32].E.Field5 = CF;
roomrec[32].E.Field6 = CF;

roomrec[32].W.Field1 = CF; 
roomrec[32].W.Field2 = CF;
roomrec[32].W.Field3 = CF;
roomrec[32].W.Field4 = CF;
roomrec[32].W.Field5 = CF;
roomrec[32].W.Field6 = CF;

/**************************/

/**************************/  

                             /* Room : 33 */
roomrec[33].N.Field1 = CF; 
roomrec[33].N.Field2 = CF;
roomrec[33].N.Field3 = CF;
roomrec[33].N.Field4 = CF;
roomrec[33].N.Field5 = CF;
roomrec[33].N.Field6 = CF;

roomrec[33].S.Field1 = CF; 
roomrec[33].S.Field2 = CF;
roomrec[33].S.Field3 = CF;
roomrec[33].S.Field4 = CF;
roomrec[33].S.Field5 = CF;
roomrec[33].S.Field6 = CF;

roomrec[33].E.Field1 = CL; 
roomrec[33].E.Field2 = ML;
roomrec[33].E.Field3 = FL;
roomrec[33].E.Field4 = EMPTY;
roomrec[33].E.Field5 = MR;
roomrec[33].E.Field6 = CR;

roomrec[33].W.Field1 = CF; 
roomrec[33].W.Field2 = CF;
roomrec[33].W.Field3 = CF;
roomrec[33].W.Field4 = CF;
roomrec[33].W.Field5 = CF;
roomrec[33].W.Field6 = CF;


/**************************/  

                             /* Room : 34 */
roomrec[34].N.Field1 = CF; 
roomrec[34].N.Field2 = CF;
roomrec[34].N.Field3 = CF;
roomrec[34].N.Field4 = CF;
roomrec[34].N.Field5 = CF;
roomrec[34].N.Field6 = CF;

roomrec[34].S.Field1 = CF; 
roomrec[34].S.Field2 = CF;
roomrec[34].S.Field3 = CF;
roomrec[34].S.Field4 = CF;
roomrec[34].S.Field5 = CF;
roomrec[34].S.Field6 = CF;

roomrec[34].E.Field1 = CL; 
roomrec[34].E.Field2 = ML;
roomrec[34].E.Field3 = EMPTY;
roomrec[34].E.Field4 = FR;
roomrec[34].E.Field5 = FF;
roomrec[34].E.Field6 = CR;

roomrec[34].W.Field1 = CL; 
roomrec[34].W.Field2 = ML;
roomrec[34].W.Field3 = FF;
roomrec[34].W.Field4 = FF;
roomrec[34].W.Field5 = MR;
roomrec[34].W.Field6 = CR;
/**************************/  /**************************/  

                             /* Room : 35 */
roomrec[35].N.Field1 = CF; 
roomrec[35].N.Field2 = CF;
roomrec[35].N.Field3 = CF;
roomrec[35].N.Field4 = CF;
roomrec[35].N.Field5 = CF;
roomrec[35].N.Field6 = CF;

roomrec[35].S.Field1 = MF; 
roomrec[35].S.Field2 = ML;
roomrec[35].S.Field3 = FL;
roomrec[35].S.Field4 = FR;
roomrec[35].S.Field5 = MR;
roomrec[35].S.Field6 = MF;

roomrec[35].E.Field1 = CL; 
roomrec[35].E.Field2 = FF;
roomrec[35].E.Field3 = FF;
roomrec[35].E.Field4 = FF;
roomrec[35].E.Field5 = MR;
roomrec[35].E.Field6 = MF;

roomrec[35].W.Field1 = MF; 
roomrec[35].W.Field2 = ML;
roomrec[35].W.Field3 = FL;
roomrec[35].W.Field4 = FR;
roomrec[35].W.Field5 = MR;
roomrec[35].W.Field6 = CR;

/**************************/

/**************************/  

                             /* Room : 36 */
roomrec[36].N.Field1 = MF; 
roomrec[36].N.Field2 = ML;
roomrec[36].N.Field3 = EMPTY;
roomrec[36].N.Field4 = EMPTY;
roomrec[36].N.Field5 = MR;
roomrec[36].N.Field6 = CR;

roomrec[36].S.Field1 = CF; 
roomrec[36].S.Field2 = CF;
roomrec[36].S.Field3 = CF;
roomrec[36].S.Field4 = CF;
roomrec[36].S.Field5 = CF;
roomrec[36].S.Field6 = CF;

roomrec[36].E.Field1 = CF; 
roomrec[36].E.Field2 = CF;
roomrec[36].E.Field3 = CF;
roomrec[36].E.Field4 = CF;
roomrec[36].E.Field5 = CF;
roomrec[36].E.Field6 = CF;

roomrec[36].W.Field1 = CL; 
roomrec[36].W.Field2 = FF;
roomrec[36].W.Field3 = FL;
roomrec[36].W.Field4 = FR;
roomrec[36].W.Field5 = MR;
roomrec[36].W.Field6 = MF;


/**************************/  

                             /* Room : 37 */
roomrec[37].N.Field1 = CL; 
roomrec[37].N.Field2 = ML;
roomrec[37].N.Field3 = EMPTY;
roomrec[37].N.Field4 = EMPTY;
roomrec[37].N.Field5 = MR;
roomrec[37].N.Field6 = MF;

roomrec[37].S.Field1 = MF; 
roomrec[37].S.Field2 = ML;
roomrec[37].S.Field3 = FF;
roomrec[37].S.Field4 = FF;
roomrec[37].S.Field5 = FF;
roomrec[37].S.Field6 = CR;

roomrec[37].E.Field1 = MF; 
roomrec[37].E.Field2 = ML;
roomrec[37].E.Field3 = FL;
roomrec[37].E.Field4 = FR;
roomrec[37].E.Field5 = MR;
roomrec[37].E.Field6 = MF;

roomrec[37].W.Field1 = CF; 
roomrec[37].W.Field2 = CF;
roomrec[37].W.Field3 = CF;
roomrec[37].W.Field4 = CF;
roomrec[37].W.Field5 = CF;
roomrec[37].W.Field6 = CF;

/**************************/
 /**************************/  

                             /* Room : 38 */
roomrec[38].N.Field1 = CF; 
roomrec[38].N.Field2 = CF;
roomrec[38].N.Field3 = CF;
roomrec[38].N.Field4 = CF;
roomrec[38].N.Field5 = CF;
roomrec[38].N.Field6 = CF;

roomrec[38].S.Field1 = CF; 
roomrec[38].S.Field2 = CF;
roomrec[38].S.Field3 = CF;
roomrec[38].S.Field4 = CF;
roomrec[38].S.Field5 = CF;
roomrec[38].S.Field6 = CF;

roomrec[38].E.Field1 = CL; 
roomrec[38].E.Field2 = ML;
roomrec[38].E.Field3 = EMPTY;
roomrec[38].E.Field4 = EMPTY;
roomrec[38].E.Field5 = MR;
roomrec[38].E.Field6 = CR;

roomrec[38].W.Field1 = CL; 
roomrec[38].W.Field2 = FF;
roomrec[38].W.Field3 = FF;
roomrec[38].W.Field4 = FF;
roomrec[38].W.Field5 = FF;
roomrec[38].W.Field6 = CR;

/**************************/

/**************************/  

                             /* Room : 39 */
roomrec[39].N.Field1 = CF; 
roomrec[39].N.Field2 = CF;
roomrec[39].N.Field3 = CF;
roomrec[39].N.Field4 = CF;
roomrec[39].N.Field5 = CF;
roomrec[39].N.Field6 = CF;

roomrec[39].S.Field1 = CF; 
roomrec[39].S.Field2 = CF;
roomrec[39].S.Field3 = CF;
roomrec[39].S.Field4 = CF;
roomrec[39].S.Field5 = CF;
roomrec[39].S.Field6 = CF;

roomrec[39].E.Field1 = CL; 
roomrec[39].E.Field2 = FF;
roomrec[39].E.Field3 = FL;
roomrec[39].E.Field4 = FR;
roomrec[39].E.Field5 = FF;
roomrec[39].E.Field6 = CR;

roomrec[39].W.Field1 = CL; 
roomrec[39].W.Field2 = ML;
roomrec[39].W.Field3 = EMPTY;
roomrec[39].W.Field4 = EMPTY;
roomrec[39].W.Field5 = MR;
roomrec[39].W.Field6 = CR;


/**************************/  
/**************************/  

                             /* Room : 40 */
roomrec[40].N.Field1 = MF; 
roomrec[40].N.Field2 = ML;
roomrec[40].N.Field3 = EMPTY;
roomrec[40].N.Field4 = EMPTY;
roomrec[40].N.Field5 = MR;
roomrec[40].N.Field6 = MF;

roomrec[40].S.Field1 = MF; 
roomrec[40].S.Field2 = ML;
roomrec[40].S.Field3 = EMPTY;
roomrec[40].S.Field4 = FR;
roomrec[40].S.Field5 = MR;
roomrec[40].S.Field6 = MF;

roomrec[40].E.Field1 = MF; 
roomrec[40].E.Field2 = ML;
roomrec[40].E.Field3 = FL;
roomrec[40].E.Field4 = FR;
roomrec[40].E.Field5 = MR;
roomrec[40].E.Field6 = MF;

roomrec[40].W.Field1 = MF; 
roomrec[40].W.Field2 = ML;
roomrec[40].W.Field3 = FL;
roomrec[40].W.Field4 = FR;
roomrec[40].W.Field5 = MR;
roomrec[40].W.Field6 = MF;


/**************************/  
/**************************/  

                             /* Room : 41 */
roomrec[41].N.Field1 = CF; 
roomrec[41].N.Field2 = CF;
roomrec[41].N.Field3 = CF;
roomrec[41].N.Field4 = CF;
roomrec[41].N.Field5 = CF;
roomrec[41].N.Field6 = CF;

roomrec[41].S.Field1 = CF; 
roomrec[41].S.Field2 = CF;
roomrec[41].S.Field3 = CF;
roomrec[41].S.Field4 = CF;
roomrec[41].S.Field5 = CF;
roomrec[41].S.Field6 = CF;

roomrec[41].E.Field1 = CL; 
roomrec[41].E.Field2 = ML;
roomrec[41].E.Field3 = EMPTY;
roomrec[41].E.Field4 = FR;
roomrec[41].E.Field5 = MR;
roomrec[41].E.Field6 = CR;

roomrec[41].W.Field1 = CL; 
roomrec[41].W.Field2 = FF;
roomrec[41].W.Field3 = FL;
roomrec[41].W.Field4 = FR;
roomrec[41].W.Field5 = FF;
roomrec[41].W.Field6 = CR;


/**************************/  

                             /* Room : 42 */
roomrec[42].N.Field1 = CF; 
roomrec[42].N.Field2 = CF;
roomrec[42].N.Field3 = CF;
roomrec[42].N.Field4 = CF;
roomrec[42].N.Field5 = CF;
roomrec[42].N.Field6 = CF;

roomrec[42].S.Field1 = CF; 
roomrec[42].S.Field2 = CF;
roomrec[42].S.Field3 = CF;
roomrec[42].S.Field4 = CF;
roomrec[42].S.Field5 = CF;
roomrec[42].S.Field6 = CF;

roomrec[42].E.Field1 = CL; 
roomrec[42].E.Field2 = FF;
roomrec[42].E.Field3 = FF;
roomrec[42].E.Field4 = FF;
roomrec[42].E.Field5 = MR;
roomrec[42].E.Field6 = CR;

roomrec[42].W.Field1 = CL; 
roomrec[42].W.Field2 = ML;
roomrec[42].W.Field3 = EMPTY;
roomrec[42].W.Field4 = EMPTY;
roomrec[42].W.Field5 = MR;
roomrec[42].W.Field6 = CR;

/**************************/  

                             /* Room : 43 */
roomrec[43].N.Field1 = MF; 
roomrec[43].N.Field2 = ML;
roomrec[43].N.Field3 = EMPTY;
roomrec[43].N.Field4 = EMPTY;
roomrec[43].N.Field5 = MR;
roomrec[43].N.Field6 = CR;

roomrec[43].S.Field1 = CF; 
roomrec[43].S.Field2 = CF;
roomrec[43].S.Field3 = CF;
roomrec[43].S.Field4 = CF;
roomrec[43].S.Field5 = CF;
roomrec[43].S.Field6 = CF;

roomrec[43].E.Field1 = CF; 
roomrec[43].E.Field2 = CF;
roomrec[43].E.Field3 = CF;
roomrec[43].E.Field4 = CF;
roomrec[43].E.Field5 = CF;
roomrec[43].E.Field6 = CF;

roomrec[43].W.Field1 = CL; 
roomrec[43].W.Field2 = ML;
roomrec[43].W.Field3 = FL;
roomrec[43].W.Field4 = FR;
roomrec[43].W.Field5 = MR;
roomrec[43].W.Field6 = MF;
/**************************/  

                             /* Room : 44 */
roomrec[44].N.Field1 = CL; 
roomrec[44].N.Field2 = FF;
roomrec[44].N.Field3 = FF;
roomrec[44].N.Field4 = FF;
roomrec[44].N.Field5 = FF;
roomrec[44].N.Field6 = CR;

roomrec[44].S.Field1 = CL; 
roomrec[44].S.Field2 = ML;
roomrec[44].S.Field3 = FF;
roomrec[44].S.Field4 = FF;
roomrec[44].S.Field5 = FF;
roomrec[44].S.Field6 = CR;

roomrec[44].E.Field1 = CF; 
roomrec[44].E.Field2 = CF;
roomrec[44].E.Field3 = CF;
roomrec[44].E.Field4 = CF;
roomrec[44].E.Field5 = CF;
roomrec[44].E.Field6 = CF;

roomrec[44].W.Field1 = CF;            /* TAVERN */ 
roomrec[44].W.Field2 = CF;
roomrec[44].W.Field3 = CF;
roomrec[44].W.Field4 = CF;
roomrec[44].W.Field5 = CF;
roomrec[44].W.Field6 = CF;
/**************************/  

                             /* Room : 45 */
roomrec[45].N.Field1 = CL; 
roomrec[45].N.Field2 = FF;
roomrec[45].N.Field3 = FF;
roomrec[45].N.Field4 = FF;
roomrec[45].N.Field5 = MR;
roomrec[45].N.Field6 = CR;

roomrec[45].S.Field1 = CL; 
roomrec[45].S.Field2 = ML;
roomrec[45].S.Field3 = FL;
roomrec[45].S.Field4 = FR;
roomrec[45].S.Field5 = MR;
roomrec[45].S.Field6 = CR;

roomrec[45].E.Field1 = CF; 
roomrec[45].E.Field2 = CF;
roomrec[45].E.Field3 = CF;
roomrec[45].E.Field4 = CF;
roomrec[45].E.Field5 = CF;
roomrec[45].E.Field6 = CF;

roomrec[45].W.Field1 = CF; 
roomrec[45].W.Field2 = CF;
roomrec[45].W.Field3 = CF;
roomrec[45].W.Field4 = CF;
roomrec[45].W.Field5 = CF;
roomrec[45].W.Field6 = CF;
/**************************/  

                             /* Room : 46 */
roomrec[46].N.Field1 = CL; 
roomrec[46].N.Field2 = ML;
roomrec[46].N.Field3 = FL;
roomrec[46].N.Field4 = FR;
roomrec[46].N.Field5 = MR;
roomrec[46].N.Field6 = CR;

roomrec[46].S.Field1 = CL; 
roomrec[46].S.Field2 = ML;
roomrec[46].S.Field3 = FL;
roomrec[46].S.Field4 = FR;
roomrec[46].S.Field5 = MR;
roomrec[46].S.Field6 = CR;

roomrec[46].E.Field1 = CF; 
roomrec[46].E.Field2 = CF;
roomrec[46].E.Field3 = CF;
roomrec[46].E.Field4 = CF;
roomrec[46].E.Field5 = CF;
roomrec[46].E.Field6 = CF;

roomrec[46].W.Field1 = CF; 
roomrec[46].W.Field2 = CF;
roomrec[46].W.Field3 = CF;
roomrec[46].W.Field4 = CF;
roomrec[46].W.Field5 = CF;
roomrec[46].W.Field6 = CF;
/**************************/  

                             /* Room : 47 */
roomrec[47].N.Field1 = CL; 
roomrec[47].N.Field2 = FF;
roomrec[47].N.Field3 = FF;
roomrec[47].N.Field4 = FF;
roomrec[47].N.Field5 = FF;
roomrec[47].N.Field6 = CR;

roomrec[47].S.Field1 = CL; 
roomrec[47].S.Field2 = ML;
roomrec[47].S.Field3 = FL;
roomrec[47].S.Field4 = FR;
roomrec[47].S.Field5 = MR;
roomrec[47].S.Field6 = CR;

roomrec[47].E.Field1 = CF; 
roomrec[47].E.Field2 = CF;
roomrec[47].E.Field3 = CF;
roomrec[47].E.Field4 = CF;
roomrec[47].E.Field5 = CF;
roomrec[47].E.Field6 = CF;

roomrec[47].W.Field1 = CF;  /* ARMORY */ 
roomrec[47].W.Field2 = CF;
roomrec[47].W.Field3 = CF;
roomrec[47].W.Field4 = CF;
roomrec[47].W.Field5 = CF;
roomrec[47].W.Field6 = CF;


/**************************/  

                             /* Room : 48 */
roomrec[48].N.Field1 = CF; 
roomrec[48].N.Field2 = CF;
roomrec[48].N.Field3 = CF;
roomrec[48].N.Field4 = CF;
roomrec[48].N.Field5 = CF;
roomrec[48].N.Field6 = CF;

roomrec[48].S.Field1 = MF; 
roomrec[48].S.Field2 = ML;
roomrec[48].S.Field3 = FL;
roomrec[48].S.Field4 = FR;
roomrec[48].S.Field5 = MR;
roomrec[48].S.Field6 = CR;

roomrec[48].E.Field1 = CL; 
roomrec[48].E.Field2 = FF;
roomrec[48].E.Field3 = FF;
roomrec[48].E.Field4 = FF;
roomrec[48].E.Field5 = MR;
roomrec[48].E.Field6 = MF;

roomrec[48].W.Field1 = CF; 
roomrec[48].W.Field2 = CF;
roomrec[48].W.Field3 = CF;
roomrec[48].W.Field4 = CF;
roomrec[48].W.Field5 = CF;
roomrec[48].W.Field6 = CF;
/**************************/  

                             /* Room : 49 */
roomrec[49].N.Field1 = MF; 
roomrec[49].N.Field2 = ML;
roomrec[49].N.Field3 = FL;
roomrec[49].N.Field4 = FR;
roomrec[49].N.Field5 = FF;
roomrec[49].N.Field6 = CR;

roomrec[49].S.Field1 = CF; 
roomrec[49].S.Field2 = CF;
roomrec[49].S.Field3 = CF;
roomrec[49].S.Field4 = CF;
roomrec[49].S.Field5 = CF;
roomrec[49].S.Field6 = CF;

roomrec[49].E.Field1 = CF; 
roomrec[49].E.Field2 = CF;
roomrec[49].E.Field3 = CF;
roomrec[49].E.Field4 = CF;
roomrec[49].E.Field5 = CF;
roomrec[49].E.Field6 = CF;

roomrec[49].W.Field1 = CL; 
roomrec[49].W.Field2 = FF;
roomrec[49].W.Field3 = FF;
roomrec[49].W.Field4 = FF;
roomrec[49].W.Field5 = MR;
roomrec[49].W.Field6 = MF;
/**************************/  

                             /* Room : 50 */
roomrec[50].N.Field1 = CL; 
roomrec[50].N.Field2 = FF;
roomrec[50].N.Field3 = FL;
roomrec[50].N.Field4 = FR;
roomrec[50].N.Field5 = FF;
roomrec[50].N.Field6 = CR;

roomrec[50].S.Field1 = CL; 
roomrec[50].S.Field2 = EMPTY;
roomrec[50].S.Field3 = EMPTY;
roomrec[50].S.Field4 = EMPTY;
roomrec[50].S.Field5 = MR;
roomrec[50].S.Field6 = CR;

roomrec[50].E.Field1 = CF; 
roomrec[50].E.Field2 = CF;
roomrec[50].E.Field3 = CF;
roomrec[50].E.Field4 = CF;
roomrec[50].E.Field5 = CF;
roomrec[50].E.Field6 = CF;

roomrec[50].W.Field1 = CF; 
roomrec[50].W.Field2 = CF;
roomrec[50].W.Field3 = CF;
roomrec[50].W.Field4 = CF;
roomrec[50].W.Field5 = CF;
roomrec[50].W.Field6 = CF;
/**********************************/


                                /* Room 1 */
roomrec[51].N.Field1 = CF; 
roomrec[51].N.Field2 = CF;
roomrec[51].N.Field3 = CF;
roomrec[51].N.Field4 = CF;
roomrec[51].N.Field5 = CF;
roomrec[51].N.Field6 = CF;

roomrec[51].S.Field1 = MF; 
roomrec[51].S.Field2 = ML;
roomrec[51].S.Field3 = FL;
roomrec[51].S.Field4 = FR;
roomrec[51].S.Field5 = FF;
roomrec[51].S.Field6 = CR;

roomrec[51].E.Field1 = CL; 
roomrec[51].E.Field2 = ML;
roomrec[51].E.Field3 = EMPTY;
roomrec[51].E.Field4 = FR;
roomrec[51].E.Field5 = MR;
roomrec[51].E.Field6 = MF;

roomrec[51].W.Field1 = CF; 
roomrec[51].W.Field2 = CF;
roomrec[51].W.Field3 = CF;
roomrec[51].W.Field4 = CF;
roomrec[51].W.Field5 = CF;
roomrec[51].W.Field6 = CF;

/******************************/
                                 /* room 2 */
roomrec[52].N.Field1 = CF; 
roomrec[52].N.Field2 = CF;
roomrec[52].N.Field3 = CF;
roomrec[52].N.Field4 = CF;
roomrec[52].N.Field5 = CF;
roomrec[52].N.Field6 = CF;

roomrec[52].S.Field1 = CF; 
roomrec[52].S.Field2 = CF;
roomrec[52].S.Field3 = CF;
roomrec[52].S.Field4 = CF;
roomrec[52].S.Field5 = CF;
roomrec[52].S.Field6 = CF;

roomrec[52].E.Field1 = CL; 
roomrec[52].E.Field2 = FF;
roomrec[52].E.Field3 = FF;
roomrec[52].E.Field4 = FF;
roomrec[52].E.Field5 = MR;
roomrec[52].E.Field6 = CR;

roomrec[52].W.Field1 = CL; 
roomrec[52].W.Field2 = FF;
roomrec[52].W.Field3 = FF;
roomrec[52].W.Field4 = FF;
roomrec[52].W.Field5 = MR;
roomrec[52].W.Field6 = CR;


/******************************/
                               /* room 3 */

roomrec[53].N.Field1 = MF; 
roomrec[53].N.Field2 = ML;
roomrec[53].N.Field3 = EMPTY;
roomrec[53].N.Field4 = EMPTY;
roomrec[53].N.Field5 = MR;
roomrec[53].N.Field6 = CR;

roomrec[53].S.Field1 = CF; 
roomrec[53].S.Field2 = CF;
roomrec[53].S.Field3 = CF;
roomrec[53].S.Field4 = CF;
roomrec[53].S.Field5 = CF;
roomrec[53].S.Field6 = CF;

roomrec[53].E.Field1 = CF; 
roomrec[53].E.Field2 = CF;
roomrec[53].E.Field3 = CF;
roomrec[53].E.Field4 = CF;
roomrec[53].E.Field5 = CF;
roomrec[53].E.Field6 = CF;

roomrec[53].W.Field1 = CL; 
roomrec[53].W.Field2 = ML;
roomrec[53].W.Field3 = EMPTY;
roomrec[53].W.Field4 = FR;
roomrec[53].W.Field5 = MR;
roomrec[53].W.Field6 = MF;


/***************************/
                            /* Room 4 */
roomrec[54].N.Field1 = CL; 
roomrec[54].N.Field2 = ML;
roomrec[54].N.Field3 = EMPTY;
roomrec[54].N.Field4 = FR;
roomrec[54].N.Field5 = MR;
roomrec[54].N.Field6 = CR;

roomrec[54].S.Field1 = CL; 
roomrec[54].S.Field2 = ML;
roomrec[54].S.Field3 = FL;
roomrec[54].S.Field4 = FR;
roomrec[54].S.Field5 = MR;
roomrec[54].S.Field6 = CR;

roomrec[54].E.Field1 = CF; 
roomrec[54].E.Field2 = CF;
roomrec[54].E.Field3 = CF;
roomrec[54].E.Field4 = CF;
roomrec[54].E.Field5 = CF;
roomrec[54].E.Field6 = CF;

roomrec[54].W.Field1 = CF; 
roomrec[54].W.Field2 = CF;
roomrec[54].W.Field3 = CF;
roomrec[54].W.Field4 = CF;
roomrec[54].W.Field5 = CF;
roomrec[54].W.Field6 = CF;

/****************************/
                             /* room 5 */
roomrec[55].N.Field1 = CL; 
roomrec[55].N.Field2 = ML;
roomrec[55].N.Field3 = FL;
roomrec[55].N.Field4 = FR;
roomrec[55].N.Field5 = MR;
roomrec[55].N.Field6 = CR;

roomrec[55].S.Field1 = CL; 
roomrec[55].S.Field2 = ML;
roomrec[55].S.Field3 = FL;
roomrec[55].S.Field4 = FR;
roomrec[55].S.Field5 = MR;
roomrec[55].S.Field6 = CR;

roomrec[55].E.Field1 = CF; 
roomrec[55].E.Field2 = CF;
roomrec[55].E.Field3 = CF;
roomrec[55].E.Field4 = CF;
roomrec[55].E.Field5 = CF;
roomrec[55].E.Field6 = CF;

roomrec[55].W.Field1 = CF; 
roomrec[55].W.Field2 = CF;
roomrec[55].W.Field3 = CF;
roomrec[55].W.Field4 = CF;
roomrec[55].W.Field5 = CF;
roomrec[55].W.Field6 = CF;

/**************************/  

                             /* Room : 6 */
roomrec[56].N.Field1 = CL; 
roomrec[56].N.Field2 = ML;
roomrec[56].N.Field3 = EMPTY;
roomrec[56].N.Field4 = EMPTY;
roomrec[56].N.Field5 = MR;
roomrec[56].N.Field6 = CR;

roomrec[56].S.Field1 = CL; 
roomrec[56].S.Field2 = ML;
roomrec[56].S.Field3 = EMPTY;
roomrec[56].S.Field4 = EMPTY;
roomrec[56].S.Field5 = MR;
roomrec[56].S.Field6 = CR;

roomrec[56].E.Field1 = CF; 
roomrec[56].E.Field2 = CF;
roomrec[56].E.Field3 = CF;
roomrec[56].E.Field4 = CF;
roomrec[56].E.Field5 = CF;
roomrec[56].E.Field6 = CF;

roomrec[56].W.Field1 = CF; 
roomrec[56].W.Field2 = CF;
roomrec[56].W.Field3 = CF;
roomrec[56].W.Field4 = CF;
roomrec[56].W.Field5 = CF;
roomrec[56].W.Field6 = CF;

/**************************/
/**************************/  

                             /* Room : 7 */
roomrec[57].N.Field1 = CL; 
roomrec[57].N.Field2 = ML;
roomrec[57].N.Field3 = FF;
roomrec[57].N.Field4 = FF;
roomrec[57].N.Field5 = EMPTY;
roomrec[57].N.Field6 = CR;

roomrec[57].S.Field1 = CL; 
roomrec[57].S.Field2 = ML;
roomrec[57].S.Field3 = FL;
roomrec[57].S.Field4 = FR;
roomrec[57].S.Field5 = MR;
roomrec[57].S.Field6 = CR;

roomrec[57].E.Field1 = CF; 
roomrec[57].E.Field2 = CF;
roomrec[57].E.Field3 = CF;
roomrec[57].E.Field4 = CF;
roomrec[57].E.Field5 = CF;
roomrec[57].E.Field6 = CF;

roomrec[57].W.Field1 = CF; 
roomrec[57].W.Field2 = CF;
roomrec[57].W.Field3 = CF;
roomrec[57].W.Field4 = CF;
roomrec[57].W.Field5 = CF;
roomrec[57].W.Field6 = CF;

/**************************/

/**************************/  

                             /* Room : 8 */
roomrec[58].N.Field1 = CL; 
roomrec[58].N.Field2 = ML;
roomrec[58].N.Field3 = EMPTY;
roomrec[58].N.Field4 = EMPTY;
roomrec[58].N.Field5 = MR;
roomrec[58].N.Field6 = MF;

roomrec[58].S.Field1 = EMPTY; 
roomrec[58].S.Field2 = EMPTY;
roomrec[58].S.Field3 = FF;
roomrec[58].S.Field4 = FF;
roomrec[58].S.Field5 = EMPTY;
roomrec[58].S.Field6 = CR;

roomrec[58].E.Field1 = MF; 
roomrec[58].E.Field2 = ML;
roomrec[58].E.Field3 = FL;
roomrec[58].E.Field4 = EMPTY;
roomrec[58].E.Field5 = EMPTY;
roomrec[58].E.Field6 = EMPTY;

roomrec[58].W.Field1 = CF; 
roomrec[58].W.Field2 = CF;
roomrec[58].W.Field3 = CF;
roomrec[58].W.Field4 = CF;
roomrec[58].W.Field5 = CF;
roomrec[58].W.Field6 = CF;


/**************************/  

                             /* Room : 9 */
roomrec[59].N.Field1 = CF; 
roomrec[59].N.Field2 = CF;
roomrec[59].N.Field3 = CF;
roomrec[59].N.Field4 = CF;
roomrec[59].N.Field5 = CF;
roomrec[59].N.Field6 = CF;

roomrec[59].S.Field1 = MF; 
roomrec[59].S.Field2 = ML;
roomrec[59].S.Field3 = FL;
roomrec[59].S.Field4 = EMPTY;
roomrec[59].S.Field5 = FR;
roomrec[59].S.Field6 = FF;

roomrec[59].E.Field1 = CL; 
roomrec[59].E.Field2 = ML;
roomrec[59].E.Field3 = FL;
roomrec[59].E.Field4 = FR;
roomrec[59].E.Field5 = MR;
roomrec[59].E.Field6 = MF;

roomrec[59].W.Field1 = EMPTY; 
roomrec[59].W.Field2 = EMPTY;
roomrec[59].W.Field3 = FF;
roomrec[59].W.Field4 = FF;
roomrec[59].W.Field5 = FF;
roomrec[59].W.Field6 = CR;
/**************************/  /**************************/  

                             /* Room : 10 */
roomrec[60].N.Field1 = CF; 
roomrec[60].N.Field2 = CF;
roomrec[60].N.Field3 = CF;
roomrec[60].N.Field4 = CF;
roomrec[60].N.Field5 = CF;
roomrec[60].N.Field6 = CF;

roomrec[60].S.Field1 = CF; 
roomrec[60].S.Field2 = CF;
roomrec[60].S.Field3 = CF;
roomrec[60].S.Field4 = CF;
roomrec[60].S.Field5 = CF;
roomrec[60].S.Field6 = CF;

roomrec[60].E.Field1 = CL; 
roomrec[60].E.Field2 = ML;
roomrec[60].E.Field3 = FL;
roomrec[60].E.Field4 = FR;
roomrec[60].E.Field5 = MR;
roomrec[60].E.Field6 = CR;

roomrec[60].W.Field1 = CL; 
roomrec[60].W.Field2 = EMPTY;
roomrec[60].W.Field3 = EMPTY;
roomrec[60].W.Field4 = EMPTY;
roomrec[60].W.Field5 = MR;
roomrec[60].W.Field6 = CR;

/**************************/

/**************************/  

                             /* Room : 11 */
roomrec[61].N.Field1 = CF; 
roomrec[61].N.Field2 = CF;
roomrec[61].N.Field3 = CF;
roomrec[61].N.Field4 = CF;
roomrec[61].N.Field5 = CF;
roomrec[61].N.Field6 = CF;

roomrec[61].S.Field1 = CF; 
roomrec[61].S.Field2 = CF;
roomrec[61].S.Field3 = CF;
roomrec[61].S.Field4 = CF;
roomrec[61].S.Field5 = CF;
roomrec[61].S.Field6 = CF;

roomrec[61].E.Field1 = CL; 
roomrec[61].E.Field2 = ML;
roomrec[61].E.Field3 = EMPTY;
roomrec[61].E.Field4 = EMPTY;
roomrec[61].E.Field5 = MR;
roomrec[61].E.Field6 = CR;

roomrec[61].W.Field1 = CL; 
roomrec[61].W.Field2 = ML;
roomrec[61].W.Field3 = EMPTY;
roomrec[61].W.Field4 = FR;
roomrec[61].W.Field5 = MR;
roomrec[61].W.Field6 = CR;


/**************************/  

                             /* Room : 12 */
roomrec[62].N.Field1 = CF; 
roomrec[62].N.Field2 = CF;
roomrec[62].N.Field3 = CF;
roomrec[62].N.Field4 = CF;
roomrec[62].N.Field5 = CF;
roomrec[62].N.Field6 = CF;

roomrec[62].S.Field1 = CF; 
roomrec[62].S.Field2 = CF;
roomrec[62].S.Field3 = CF;
roomrec[62].S.Field4 = CF;
roomrec[62].S.Field5 = CF;
roomrec[62].S.Field6 = CF;

roomrec[62].E.Field1 = CL; 
roomrec[62].E.Field2 = EMPTY;
roomrec[62].E.Field3 = FF;
roomrec[62].E.Field4 = FF;
roomrec[62].E.Field5 = FF;
roomrec[62].E.Field6 = CR;

roomrec[62].W.Field1 = CL; 
roomrec[62].W.Field2 = ML;
roomrec[62].W.Field3 = FL;
roomrec[62].W.Field4 = FR;
roomrec[62].W.Field5 = MR;
roomrec[62].W.Field6 = CR;

/**************************/
 /**************************/  

                             /* Room : 13 */
roomrec[63].N.Field1 = MF; 
roomrec[63].N.Field2 = ML;
roomrec[63].N.Field3 = FF;
roomrec[63].N.Field4 = FF;
roomrec[63].N.Field5 = FF;
roomrec[63].N.Field6 = CR;

roomrec[63].S.Field1 = CL; 
roomrec[63].S.Field2 = ML;
roomrec[63].S.Field3 = EMPTY;
roomrec[63].S.Field4 = FR;
roomrec[63].S.Field5 = MR;
roomrec[63].S.Field6 = MF;

roomrec[63].E.Field1 = CF; 
roomrec[63].E.Field2 = CF;
roomrec[63].E.Field3 = CF;
roomrec[63].E.Field4 = CF;
roomrec[63].E.Field5 = CF;
roomrec[63].E.Field6 = CF;

roomrec[63].W.Field1 = MF; 
roomrec[63].W.Field2 = ML;
roomrec[63].W.Field3 = FL;
roomrec[63].W.Field4 = FR;
roomrec[63].W.Field5 = MR;
roomrec[63].W.Field6 = MF;

/**************************/

/**************************/  

                             /* Room : 14 */
roomrec[64].N.Field1 = CL; 
roomrec[64].N.Field2 = ML;
roomrec[64].N.Field3 = FL;
roomrec[64].N.Field4 = FR;
roomrec[64].N.Field5 = MR;
roomrec[64].N.Field6 = CR;

roomrec[64].S.Field1 = CL; 
roomrec[64].S.Field2 = ML;
roomrec[64].S.Field3 = FL;
roomrec[64].S.Field4 = FR;
roomrec[64].S.Field5 = MR;
roomrec[64].S.Field6 = CR;

roomrec[64].E.Field1 = CF; 
roomrec[64].E.Field2 = CF;
roomrec[64].E.Field3 = CF;
roomrec[64].E.Field4 = CF;
roomrec[64].E.Field5 = CF;
roomrec[64].E.Field6 = CF;

roomrec[64].W.Field1 = CF; 
roomrec[64].W.Field2 = CF;
roomrec[64].W.Field3 = CF;
roomrec[64].W.Field4 = CF;
roomrec[64].W.Field5 = CF;
roomrec[64].W.Field6 = CF;


/**************************/  
/**************************/  

                             /* Room : 15 */
roomrec[65].N.Field1 = CL; 
roomrec[65].N.Field2 = ML;
roomrec[65].N.Field3 = FL;
roomrec[65].N.Field4 = FR;
roomrec[65].N.Field5 = MR;
roomrec[65].N.Field6 = CR;

roomrec[65].S.Field1 = CL; 
roomrec[65].S.Field2 = ML;
roomrec[65].S.Field3 = FL;
roomrec[65].S.Field4 = FR;
roomrec[65].S.Field5 = MR;
roomrec[65].S.Field6 = CR;

roomrec[65].E.Field1 = CF; 
roomrec[65].E.Field2 = CF;
roomrec[65].E.Field3 = CF;
roomrec[65].E.Field4 = CF;
roomrec[65].E.Field5 = CF;
roomrec[65].E.Field6 = CF;

roomrec[65].W.Field1 = CF; 
roomrec[65].W.Field2 = CF;
roomrec[65].W.Field3 = CF;
roomrec[65].W.Field4 = CF;
roomrec[65].W.Field5 = CF;
roomrec[65].W.Field6 = CF;


/**************************/  
/**************************/  

                             /* Room : 16 */
roomrec[66].N.Field1 = CL; 
roomrec[66].N.Field2 = ML;
roomrec[66].N.Field3 = FL;
roomrec[66].N.Field4 = FR;
roomrec[66].N.Field5 = MR;
roomrec[66].N.Field6 = CR;

roomrec[66].S.Field1 = CL; 
roomrec[66].S.Field2 = FF;
roomrec[66].S.Field3 = FF;
roomrec[66].S.Field4 = FF;
roomrec[66].S.Field5 = FF;
roomrec[66].S.Field6 = CR;

roomrec[66].E.Field1 = CF; 
roomrec[66].E.Field2 = CF;
roomrec[66].E.Field3 = CF;
roomrec[66].E.Field4 = CF;
roomrec[66].E.Field5 = CF;
roomrec[66].E.Field6 = CF;

roomrec[66].W.Field1 = CF; 
roomrec[66].W.Field2 = CF;
roomrec[66].W.Field3 = CF;
roomrec[66].W.Field4 = CF;
roomrec[66].W.Field5 = CF;
roomrec[66].W.Field6 = CF;


/**************************/  

                             /* Room : 17 */
roomrec[67].N.Field1 = CL; 
roomrec[67].N.Field2 = ML;
roomrec[67].N.Field3 = FL;
roomrec[67].N.Field4 = EMPTY;
roomrec[67].N.Field5 = MR;
roomrec[67].N.Field6 = CR;

roomrec[67].S.Field1 = CL; 
roomrec[67].S.Field2 = ML;
roomrec[67].S.Field3 = FL;
roomrec[67].S.Field4 = FR;
roomrec[67].S.Field5 = MR;
roomrec[67].S.Field6 = CR;

roomrec[67].E.Field1 = CF; 
roomrec[67].E.Field2 = CF;
roomrec[67].E.Field3 = CF;
roomrec[67].E.Field4 = CF;
roomrec[67].E.Field5 = CF;
roomrec[67].E.Field6 = CF;

roomrec[67].W.Field1 = CF; 
roomrec[67].W.Field2 = CF;
roomrec[67].W.Field3 = CF;
roomrec[67].W.Field4 = CF;
roomrec[67].W.Field5 = CF;
roomrec[67].W.Field6 = CF;

/**************************/  

                             /* Room : 18 */
roomrec[68].N.Field1 = CF; 
roomrec[68].N.Field2 = CF;
roomrec[68].N.Field3 = CF;
roomrec[68].N.Field4 = CF;
roomrec[68].N.Field5 = CF;
roomrec[68].N.Field6 = CF;

roomrec[68].S.Field1 = FF; 
roomrec[68].S.Field2 = FL;
roomrec[68].S.Field3 = EMPTY;
roomrec[68].S.Field4 = FR;
roomrec[68].S.Field5 = MR;
roomrec[68].S.Field6 = CR;

roomrec[68].E.Field1 = CL; 
roomrec[68].E.Field2 = ML;
roomrec[68].E.Field3 = EMPTY;
roomrec[68].E.Field4 = EMPTY;
roomrec[68].E.Field5 = EMPTY;
roomrec[68].E.Field6 = EMPTY;

roomrec[68].W.Field1 = CF; 
roomrec[68].W.Field2 = CF;
roomrec[68].W.Field3 = CF;
roomrec[68].W.Field4 = CF;
roomrec[68].W.Field5 = CF;
roomrec[68].W.Field6 = CF;
/**************************/  

                             /* Room : 19 */
roomrec[69].N.Field1 = CF; 
roomrec[69].N.Field2 = CF;
roomrec[69].N.Field3 = CF;
roomrec[69].N.Field4 = CF;
roomrec[69].N.Field5 = CF;
roomrec[69].N.Field6 = CF;

roomrec[69].S.Field1 = MF; 
roomrec[69].S.Field2 = ML;
roomrec[69].S.Field3 = FF;
roomrec[69].S.Field4 = FF;
roomrec[69].S.Field5 = EMPTY;
roomrec[69].S.Field6 = EMPTY;

roomrec[69].E.Field1 = CL; 
roomrec[69].E.Field2 = EMPTY;
roomrec[69].E.Field3 = EMPTY;
roomrec[69].E.Field4 = EMPTY;
roomrec[69].E.Field5 = MR;
roomrec[69].E.Field6 = MF;

roomrec[69].W.Field1 = FF; 
roomrec[69].W.Field2 = FF;
roomrec[69].W.Field3 = FF;
roomrec[69].W.Field4 = FF;
roomrec[69].W.Field5 = MR;
roomrec[69].W.Field6 = CR;
/**************************/  

                             /* Room : 20 */
roomrec[70].N.Field1 = MF; 
roomrec[70].N.Field2 = ML;
roomrec[70].N.Field3 = FL;
roomrec[70].N.Field4 = FR;
roomrec[70].N.Field5 = FF;
roomrec[70].N.Field6 = FF;

roomrec[70].S.Field1 = CF; 
roomrec[70].S.Field2 = CF;
roomrec[70].S.Field3 = CF;
roomrec[70].S.Field4 = CF;
roomrec[70].S.Field5 = CF;
roomrec[70].S.Field6 = CF;

roomrec[70].E.Field1 = EMPTY; 
roomrec[70].E.Field2 = EMPTY;
roomrec[70].E.Field3 = FF;
roomrec[70].E.Field4 = FF;
roomrec[70].E.Field5 = FF;
roomrec[70].E.Field6 = CR;

roomrec[70].W.Field1 = CL; 
roomrec[70].W.Field2 = EMPTY;
roomrec[70].W.Field3 = EMPTY;
roomrec[70].W.Field4 = FR;
roomrec[70].W.Field5 = MR;
roomrec[70].W.Field6 = MF;
/**************************/  

/**************************/  

                             /* Room : 50 */
roomrec[71].N.Field1 = EMPTY; 
roomrec[71].N.Field2 = EMPTY;
roomrec[71].N.Field3 = FF;
roomrec[71].N.Field4 = FF;
roomrec[71].N.Field5 = FF;
roomrec[71].N.Field6 = CR;

roomrec[71].S.Field1 = CL; 
roomrec[71].S.Field2 = ML;
roomrec[71].S.Field3 = FF;
roomrec[71].S.Field4 = FF;
roomrec[71].S.Field5 = MR;
roomrec[71].S.Field6 = MF;

roomrec[71].E.Field1 = CF; 
roomrec[71].E.Field2 = CF;
roomrec[71].E.Field3 = CF;
roomrec[71].E.Field4 = CF;
roomrec[71].E.Field5 = CF;
roomrec[71].E.Field6 = CF;

roomrec[71].W.Field1 = MF; 
roomrec[71].W.Field2 = ML;
roomrec[71].W.Field3 = EMPTY;
roomrec[71].W.Field4 = EMPTY;
roomrec[71].W.Field5 = EMPTY;
roomrec[71].W.Field6 = EMPTY;
/**********************************/


                                /* Room 1 */
roomrec[72].N.Field1 = CL; 
roomrec[72].N.Field2 = FF;
roomrec[72].N.Field3 = FL;
roomrec[72].N.Field4 = EMPTY;
roomrec[72].N.Field5 = MR;
roomrec[72].N.Field6 = CR;

roomrec[72].S.Field1 = CL; 
roomrec[72].S.Field2 = EMPTY;
roomrec[72].S.Field3 = EMPTY;
roomrec[72].S.Field4 = FR;
roomrec[72].S.Field5 = MR;
roomrec[72].S.Field6 = CR;

roomrec[72].E.Field1 = CF; 
roomrec[72].E.Field2 = CF;
roomrec[72].E.Field3 = CF;
roomrec[72].E.Field4 = CF;
roomrec[72].E.Field5 = CF;
roomrec[72].E.Field6 = CF;

roomrec[72].W.Field1 = CF; 
roomrec[72].W.Field2 = CF;
roomrec[72].W.Field3 = CF;
roomrec[72].W.Field4 = CF;
roomrec[72].W.Field5 = CF;
roomrec[72].W.Field6 = CF;

/******************************/
                                 /* room 2 */
roomrec[73].N.Field1 = CL; 
roomrec[73].N.Field2 = ML;
roomrec[73].N.Field3 = FL;
roomrec[73].N.Field4 = FR;
roomrec[73].N.Field5 = MR;
roomrec[73].N.Field6 = CR;

roomrec[73].S.Field1 = CL; 
roomrec[73].S.Field2 = ML;
roomrec[73].S.Field3 = FL;
roomrec[73].S.Field4 = FR;
roomrec[73].S.Field5 = MR;
roomrec[73].S.Field6 = CR;

roomrec[73].E.Field1 = CF; 
roomrec[73].E.Field2 = CF;
roomrec[73].E.Field3 = CF;
roomrec[73].E.Field4 = CF;
roomrec[73].E.Field5 = CF;
roomrec[73].E.Field6 = CF;

roomrec[73].W.Field1 = CF; 
roomrec[73].W.Field2 = CF;
roomrec[73].W.Field3 = CF;
roomrec[73].W.Field4 = CF;
roomrec[73].W.Field5 = CF;
roomrec[73].W.Field6 = CF;


/******************************/
                               /* room 3 */

roomrec[74].N.Field1 = CL; 
roomrec[74].N.Field2 = ML;
roomrec[74].N.Field3 = FL;
roomrec[74].N.Field4 = FR;
roomrec[74].N.Field5 = MR;
roomrec[74].N.Field6 = CR;

roomrec[74].S.Field1 = CL; 
roomrec[74].S.Field2 = ML;
roomrec[74].S.Field3 = EMPTY;
roomrec[74].S.Field4 = FR;
roomrec[74].S.Field5 = MR;
roomrec[74].S.Field6 = CR;

roomrec[74].E.Field1 = CF; 
roomrec[74].E.Field2 = CF;
roomrec[74].E.Field3 = CF;
roomrec[74].E.Field4 = CF;
roomrec[74].E.Field5 = CF;
roomrec[74].E.Field6 = CF;

roomrec[74].W.Field1 = CF; 
roomrec[74].W.Field2 = CF;
roomrec[74].W.Field3 = CF;
roomrec[74].W.Field4 = CF;
roomrec[74].W.Field5 = CF;
roomrec[74].W.Field6 = CF;


/***************************/
                            /* Room 4 */
roomrec[75].N.Field1 = CF; 
roomrec[75].N.Field2 = CF;
roomrec[75].N.Field3 = CF;
roomrec[75].N.Field4 = CF;
roomrec[75].N.Field5 = CF;
roomrec[75].N.Field6 = CF;

roomrec[75].S.Field1 = CF; 
roomrec[75].S.Field2 = CF;
roomrec[75].S.Field3 = CF;
roomrec[75].S.Field4 = CF;
roomrec[75].S.Field5 = CF;
roomrec[75].S.Field6 = CF;

roomrec[75].E.Field1 = CL; 
roomrec[75].E.Field2 = EMPTY;
roomrec[75].E.Field3 = EMPTY;
roomrec[75].E.Field4 = FR;
roomrec[75].E.Field5 = MR;
roomrec[75].E.Field6 = CR;

roomrec[75].W.Field1 = CF; 
roomrec[75].W.Field2 = CF;
roomrec[75].W.Field3 = CF;
roomrec[75].W.Field4 = CF;
roomrec[75].W.Field5 = CF;
roomrec[75].W.Field6 = CF;

/****************************/
                             /* room 5 */
roomrec[76].N.Field1 = MF; 
roomrec[76].N.Field2 = ML;
roomrec[76].N.Field3 = FL;
roomrec[76].N.Field4 = FR;
roomrec[76].N.Field5 = MR;
roomrec[76].N.Field6 = MF;

roomrec[76].S.Field1 = CF; 
roomrec[76].S.Field2 = CF;
roomrec[76].S.Field3 = CF;
roomrec[76].S.Field4 = CF;
roomrec[76].S.Field5 = CF;
roomrec[76].S.Field6 = CF;

roomrec[76].E.Field1 = MF; 
roomrec[76].E.Field2 = ML;
roomrec[76].E.Field3 = FF;
roomrec[76].E.Field4 = FF;
roomrec[76].E.Field5 = MR;
roomrec[76].E.Field6 = CR;

roomrec[76].W.Field1 = CL; 
roomrec[76].W.Field2 = ML;
roomrec[76].W.Field3 = FF;
roomrec[76].W.Field4 = FF;
roomrec[76].W.Field5 = MR;
roomrec[76].W.Field6 = MF;

/**************************/  

                             /* Room : 6 */
roomrec[77].N.Field1 = CF; 
roomrec[77].N.Field2 = CF;
roomrec[77].N.Field3 = CF;
roomrec[77].N.Field4 = CF;
roomrec[77].N.Field5 = CF;
roomrec[77].N.Field6 = CF;

roomrec[77].S.Field1 = CF; 
roomrec[77].S.Field2 = CF;
roomrec[77].S.Field3 = CF;
roomrec[77].S.Field4 = CF;
roomrec[77].S.Field5 = CF;
roomrec[77].S.Field6 = CF;

roomrec[77].E.Field1 = CF; 
roomrec[77].E.Field2 = CF;
roomrec[77].E.Field3 = CF;
roomrec[77].E.Field4 = CF;
roomrec[77].E.Field5 = CF;
roomrec[77].E.Field6 = CF;

roomrec[77].W.Field1 = CL; 
roomrec[77].W.Field2 = ML;
roomrec[77].W.Field3 = FL;
roomrec[77].W.Field4 = FR;
roomrec[77].W.Field5 = FF;
roomrec[77].W.Field6 = CR;

/**************************/
/**************************/  

                             /* Room : 7 */
roomrec[78].N.Field1 = CL; 
roomrec[78].N.Field2 = ML;
roomrec[78].N.Field3 = FL;
roomrec[78].N.Field4 = FR;
roomrec[78].N.Field5 = MR;
roomrec[78].N.Field6 = CR;

roomrec[78].S.Field1 = CL; 
roomrec[78].S.Field2 = ML;
roomrec[78].S.Field3 = FL;
roomrec[78].S.Field4 = EMPTY;
roomrec[78].S.Field5 = MR;
roomrec[78].S.Field6 = CR;

roomrec[78].E.Field1 = CF; 
roomrec[78].E.Field2 = CF;
roomrec[78].E.Field3 = CF;
roomrec[78].E.Field4 = CF;
roomrec[78].E.Field5 = CF;
roomrec[78].E.Field6 = CF;

roomrec[78].W.Field1 = CF; 
roomrec[78].W.Field2 = CF;
roomrec[78].W.Field3 = CF;
roomrec[78].W.Field4 = CF;
roomrec[78].W.Field5 = CF;
roomrec[78].W.Field6 = CF;

/**************************/

/**************************/  

                             /* Room : 8 */
roomrec[79].N.Field1 = CL; 
roomrec[79].N.Field2 = ML;
roomrec[79].N.Field3 = FF;
roomrec[79].N.Field4 = FF;
roomrec[79].N.Field5 = FF;
roomrec[79].N.Field6 = FF;

roomrec[79].S.Field1 = MF; 
roomrec[79].S.Field2 = ML;
roomrec[79].S.Field3 = FL;
roomrec[79].S.Field4 = FR;
roomrec[79].S.Field5 = MR;
roomrec[79].S.Field6 = CR;

roomrec[79].E.Field1 = EMPTY; 
roomrec[79].E.Field2 = EMPTY;
roomrec[79].E.Field3 = FF;
roomrec[79].E.Field4 = FF;
roomrec[79].E.Field5 = MR;
roomrec[79].E.Field6 = MF;

roomrec[79].W.Field1 = CF; 
roomrec[79].W.Field2 = CF;
roomrec[79].W.Field3 = CF;
roomrec[79].W.Field4 = CF;
roomrec[79].W.Field5 = CF;
roomrec[79].W.Field6 = CF;


/**************************/  

                             /* Room : 9 */
roomrec[80].N.Field1 = FF; 
roomrec[80].N.Field2 = FF;
roomrec[80].N.Field3 = FF;
roomrec[80].N.Field4 = FF;
roomrec[80].N.Field5 = EMPTY;
roomrec[80].N.Field6 = CR;

roomrec[80].S.Field1 = CF; 
roomrec[80].S.Field2 = CF;
roomrec[80].S.Field3 = CF;
roomrec[80].S.Field4 = CF;
roomrec[80].S.Field5 = CF;
roomrec[80].S.Field6 = CF;

roomrec[80].E.Field1 = CF; 
roomrec[80].E.Field2 = CF;
roomrec[80].E.Field3 = CF;
roomrec[80].E.Field4 = CF;
roomrec[80].E.Field5 = CF;
roomrec[80].E.Field6 = CF;

roomrec[80].W.Field1 = CL; 
roomrec[80].W.Field2 = FF;
roomrec[80].W.Field3 = FF;
roomrec[80].W.Field4 = FF;
roomrec[80].W.Field5 = FF;
roomrec[80].W.Field6 = FF;
/**************************/  /**************************/  

                             /* Room : 10 */
roomrec[81].N.Field1 = CL; 
roomrec[81].N.Field2 = EMPTY;
roomrec[81].N.Field3 = EMPTY;
roomrec[81].N.Field4 = EMPTY;
roomrec[81].N.Field5 = MR;
roomrec[81].N.Field6 = CR;

roomrec[81].S.Field1 = CF; 
roomrec[81].S.Field2 = CF;
roomrec[81].S.Field3 = CF;
roomrec[81].S.Field4 = CF;
roomrec[81].S.Field5 = CF;
roomrec[81].S.Field6 = CF;

roomrec[81].E.Field1 = CF; 
roomrec[81].E.Field2 = CF;
roomrec[81].E.Field3 = CF;
roomrec[81].E.Field4 = CF;
roomrec[81].E.Field5 = CF;
roomrec[81].E.Field6 = CF;

roomrec[81].W.Field1 = CF; 
roomrec[81].W.Field2 = CF;
roomrec[81].W.Field3 = CF;
roomrec[81].W.Field4 = CF;
roomrec[81].W.Field5 = CF;
roomrec[81].W.Field6 = CF;

/**************************/

/**************************/  

                             /* Room : 11 */
roomrec[82].N.Field1 = CL; 
roomrec[82].N.Field2 = ML;
roomrec[82].N.Field3 = EMPTY;
roomrec[82].N.Field4 = FR;
roomrec[82].N.Field5 = MR;
roomrec[82].N.Field6 = MF;

roomrec[82].S.Field1 = EMPTY; 
roomrec[82].S.Field2 = EMPTY;
roomrec[82].S.Field3 = FF;
roomrec[82].S.Field4 = FF;
roomrec[82].S.Field5 = MR;
roomrec[82].S.Field6 = CR;

roomrec[82].E.Field1 = MF; 
roomrec[82].E.Field2 = ML;
roomrec[82].E.Field3 = FL;
roomrec[82].E.Field4 = EMPTY;
roomrec[82].E.Field5 = FR;
roomrec[82].E.Field6 = FF;

roomrec[82].W.Field1 = CF; 
roomrec[82].W.Field2 = CF;
roomrec[82].W.Field3 = CF;
roomrec[82].W.Field4 = CF;
roomrec[82].W.Field5 = CF;
roomrec[82].W.Field6 = CF;


/**************************/  

                             /* Room : 12 */
roomrec[83].N.Field1 = CF; 
roomrec[83].N.Field2 = CF;
roomrec[83].N.Field3 = CF;
roomrec[83].N.Field4 = CF;
roomrec[83].N.Field5 = CF;
roomrec[83].N.Field6 = CF;

roomrec[83].S.Field1 = MF; 
roomrec[83].S.Field2 = ML;
roomrec[83].S.Field3 = EMPTY;
roomrec[83].S.Field4 = EMPTY;
roomrec[83].S.Field5 = FR;
roomrec[83].S.Field6 = FF;

roomrec[83].E.Field1 = CL; 
roomrec[83].E.Field2 = ML;
roomrec[83].E.Field3 = FL;
roomrec[83].E.Field4 = EMPTY;
roomrec[83].E.Field5 = MR;
roomrec[83].E.Field6 = MF;

roomrec[83].W.Field1 = FF; 
roomrec[83].W.Field2 = FF;
roomrec[83].W.Field3 = FF;
roomrec[83].W.Field4 = FF;
roomrec[83].W.Field5 = FF;
roomrec[83].W.Field6 = CR;

/**************************/
 /**************************/  

                             /* Room : 13 */
roomrec[84].N.Field1 = CF; 
roomrec[84].N.Field2 = CF;
roomrec[84].N.Field3 = CF;
roomrec[84].N.Field4 = CF;
roomrec[84].N.Field5 = CF;
roomrec[84].N.Field6 = CF;

roomrec[84].S.Field1 = CF; 
roomrec[84].S.Field2 = CF;
roomrec[84].S.Field3 = CF;
roomrec[84].S.Field4 = CF;
roomrec[84].S.Field5 = CF;
roomrec[84].S.Field6 = CF;

roomrec[84].E.Field1 = CL; 
roomrec[84].E.Field2 = ML;
roomrec[84].E.Field3 = FL;
roomrec[84].E.Field4 = FR;
roomrec[84].E.Field5 = FF;
roomrec[84].E.Field6 = CR;

roomrec[84].W.Field1 = CL; 
roomrec[84].W.Field2 = EMPTY;
roomrec[84].W.Field3 = EMPTY;
roomrec[84].W.Field4 = EMPTY;
roomrec[84].W.Field5 = MR;
roomrec[84].W.Field6 = CR;

/**************************/

/**************************/  

                             /* Room : 14 */
roomrec[85].N.Field1 = CF; 
roomrec[85].N.Field2 = CF;
roomrec[85].N.Field3 = CF;
roomrec[85].N.Field4 = CF;
roomrec[85].N.Field5 = CF;
roomrec[85].N.Field6 = CF;

roomrec[85].S.Field1 = MF; 
roomrec[85].S.Field2 = ML;
roomrec[85].S.Field3 = EMPTY;
roomrec[85].S.Field4 = EMPTY;
roomrec[85].S.Field5 = MR;
roomrec[85].S.Field6 = MF;

roomrec[85].E.Field1 = CL; 
roomrec[85].E.Field2 = ML;
roomrec[85].E.Field3 = FL;
roomrec[85].E.Field4 = EMPTY;
roomrec[85].E.Field5 = MR;
roomrec[85].E.Field6 = MF;

roomrec[85].W.Field1 = MF; 
roomrec[85].W.Field2 = ML;
roomrec[85].W.Field3 = EMPTY;
roomrec[85].W.Field4 = FR;
roomrec[85].W.Field5 = MR;
roomrec[85].W.Field6 = CR;


/**************************/  
/**************************/  

                             /* Room : 15 */
roomrec[86].N.Field1 = CF; 
roomrec[86].N.Field2 = CF;
roomrec[86].N.Field3 = CF;
roomrec[86].N.Field4 = CF;
roomrec[86].N.Field5 = CF;
roomrec[86].N.Field6 = CF;

roomrec[86].S.Field1 = CF; 
roomrec[86].S.Field2 = CF;
roomrec[86].S.Field3 = CF;
roomrec[86].S.Field4 = CF;
roomrec[86].S.Field5 = CF;
roomrec[86].S.Field6 = CF;

roomrec[86].E.Field1 = CL; 
roomrec[86].E.Field2 = ML;
roomrec[86].E.Field3 = FL;
roomrec[86].E.Field4 = FR;
roomrec[86].E.Field5 = FF;
roomrec[86].E.Field6 = CR;

roomrec[86].W.Field1 = CL; 
roomrec[86].W.Field2 = FF;
roomrec[86].W.Field3 = FL;
roomrec[86].W.Field4 = FR;
roomrec[86].W.Field5 = MR;
roomrec[86].W.Field6 = CR;


/**************************/  
/**************************/  

                             /* Room : 14 */
roomrec[87].N.Field1 = CF; 
roomrec[87].N.Field2 = CF;
roomrec[87].N.Field3 = CF;
roomrec[87].N.Field4 = CF;
roomrec[87].N.Field5 = CF;
roomrec[87].N.Field6 = CF;

roomrec[87].S.Field1 = MF; 
roomrec[87].S.Field2 = ML;
roomrec[87].S.Field3 = EMPTY;
roomrec[87].S.Field4 = EMPTY;
roomrec[87].S.Field5 = MR;
roomrec[87].S.Field6 = MF;

roomrec[87].E.Field1 = CL; 
roomrec[87].E.Field2 = ML;
roomrec[87].E.Field3 = FL;
roomrec[87].E.Field4 = EMPTY;
roomrec[87].E.Field5 = MR;
roomrec[87].E.Field6 = MF;

roomrec[87].W.Field1 = MF; 
roomrec[87].W.Field2 = ML;
roomrec[87].W.Field3 = EMPTY;
roomrec[87].W.Field4 = FR;
roomrec[87].W.Field5 = MR;
roomrec[87].W.Field6 = CR;


/**************************/  

                             /* Room : 17 */
roomrec[88].N.Field1 = CF; 
roomrec[88].N.Field2 = CF;
roomrec[88].N.Field3 = CF;
roomrec[88].N.Field4 = CF;
roomrec[88].N.Field5 = CF;
roomrec[88].N.Field6 = CF;

roomrec[88].S.Field1 = CF; 
roomrec[88].S.Field2 = CF;
roomrec[88].S.Field3 = CF;
roomrec[88].S.Field4 = CF;
roomrec[88].S.Field5 = CF;
roomrec[88].S.Field6 = CF;

roomrec[88].E.Field1 = CL; 
roomrec[88].E.Field2 = ML;
roomrec[88].E.Field3 = FF;
roomrec[88].E.Field4 = FF;
roomrec[88].E.Field5 = FF;
roomrec[88].E.Field6 = CR;

roomrec[88].W.Field1 = CL; 
roomrec[88].W.Field2 = FF;
roomrec[88].W.Field3 = FL;
roomrec[88].W.Field4 = FR;
roomrec[88].W.Field5 = MR;
roomrec[88].W.Field6 = CR;

/**************************/  

                             /* Room : 18 */
roomrec[89].N.Field1 = CF; 
roomrec[89].N.Field2 = CF;
roomrec[89].N.Field3 = CF;
roomrec[89].N.Field4 = CF;
roomrec[89].N.Field5 = CF;
roomrec[89].N.Field6 = CF;

roomrec[89].S.Field1 = CL; 
roomrec[89].S.Field2 = ML;
roomrec[89].S.Field3 = FL;
roomrec[89].S.Field4 = EMPTY;
roomrec[89].S.Field5 = MR;
roomrec[89].S.Field6 = MF;

roomrec[89].E.Field1 = CF; 
roomrec[89].E.Field2 = CF;
roomrec[89].E.Field3 = CF;
roomrec[89].E.Field4 = CF;
roomrec[89].E.Field5 = CF;
roomrec[89].E.Field6 = CF;

roomrec[89].W.Field1 = MF; 
roomrec[89].W.Field2 = ML;
roomrec[89].W.Field3 = EMPTY;
roomrec[89].W.Field4 = FR;
roomrec[89].W.Field5 = MR;
roomrec[89].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[90].N.Field1 = CL; 
roomrec[90].N.Field2 = ML;
roomrec[90].N.Field3 = FL;
roomrec[90].N.Field4 = FR;
roomrec[90].N.Field5 = MR;
roomrec[90].N.Field6 = CR;

roomrec[90].S.Field1 = CL; 
roomrec[90].S.Field2 = ML;
roomrec[90].S.Field3 = FL;
roomrec[90].S.Field4 = FR;
roomrec[90].S.Field5 = MR;
roomrec[90].S.Field6 = CR;

roomrec[90].E.Field1 = CF; 
roomrec[90].E.Field2 = CF;
roomrec[90].E.Field3 = CF;
roomrec[90].E.Field4 = CF;
roomrec[90].E.Field5 = CF;
roomrec[90].E.Field6 = CF;

roomrec[90].W.Field1 = CF; 
roomrec[90].W.Field2 = CF;
roomrec[90].W.Field3 = CF;
roomrec[90].W.Field4 = CF;
roomrec[90].W.Field5 = CF;
roomrec[90].W.Field6 = CF;
/**************************/  


                             /* Room : 10 */
roomrec[91].N.Field1 = CL; 
roomrec[91].N.Field2 = ML;
roomrec[91].N.Field3 = FL;
roomrec[91].N.Field4 = FR;
roomrec[91].N.Field5 = MR;
roomrec[91].N.Field6 = CR;

roomrec[91].S.Field1 = CL; 
roomrec[91].S.Field2 = FF;
roomrec[91].S.Field3 = FF;
roomrec[91].S.Field4 = FF;
roomrec[91].S.Field5 = MR;
roomrec[91].S.Field6 = CR;

roomrec[91].E.Field1 = CF; 
roomrec[91].E.Field2 = CF;
roomrec[91].E.Field3 = CF;
roomrec[91].E.Field4 = CF;
roomrec[91].E.Field5 = CF;
roomrec[91].E.Field6 = CF;

roomrec[91].W.Field1 = CF; 
roomrec[91].W.Field2 = CF;
roomrec[91].W.Field3 = CF;
roomrec[91].W.Field4 = CF;
roomrec[91].W.Field5 = CF;
roomrec[91].W.Field6 = CF;

/**************************/

/**************************/  

                             /* Room : 11 */
roomrec[92].N.Field1 = CL; 
roomrec[92].N.Field2 = ML;
roomrec[92].N.Field3 = FL;
roomrec[92].N.Field4 = FR;
roomrec[92].N.Field5 = MR;
roomrec[92].N.Field6 = CR;

roomrec[92].S.Field1 = CL; 
roomrec[92].S.Field2 = ML;
roomrec[92].S.Field3 = FF;
roomrec[92].S.Field4 = FF;
roomrec[92].S.Field5 = FF;
roomrec[92].S.Field6 = CR;

roomrec[92].E.Field1 = CF; 
roomrec[92].E.Field2 = CF;
roomrec[92].E.Field3 = CF;
roomrec[92].E.Field4 = CF;
roomrec[92].E.Field5 = CF;
roomrec[92].E.Field6 = CF;

roomrec[92].W.Field1 = CF; 
roomrec[92].W.Field2 = CF;
roomrec[92].W.Field3 = CF;
roomrec[92].W.Field4 = CF;
roomrec[92].W.Field5 = CF;
roomrec[92].W.Field6 = CF;


/**************************/  

                             /* Room : 12 */
roomrec[93].N.Field1 = CL; 
roomrec[93].N.Field2 = ML;
roomrec[93].N.Field3 = FL;
roomrec[93].N.Field4 = EMPTY;
roomrec[93].N.Field5 = EMPTY;
roomrec[93].N.Field6 = CR;

roomrec[93].S.Field1 = CL; 
roomrec[93].S.Field2 = ML;
roomrec[93].S.Field3 = FL;
roomrec[93].S.Field4 = FR;
roomrec[93].S.Field5 = MR;
roomrec[93].S.Field6 = CR;

roomrec[93].E.Field1 = CF; 
roomrec[93].E.Field2 = CF;
roomrec[93].E.Field3 = CF;
roomrec[93].E.Field4 = CF;
roomrec[93].E.Field5 = CF;
roomrec[93].E.Field6 = CF;

roomrec[93].W.Field1 = CF; 
roomrec[93].W.Field2 = CF;
roomrec[93].W.Field3 = CF;
roomrec[93].W.Field4 = CF;
roomrec[93].W.Field5 = CF;
roomrec[93].W.Field6 = CF;

/**************************/
 /**************************/  

                             /* Room : 13 */
roomrec[94].N.Field1 = CL; 
roomrec[94].N.Field2 = ML;
roomrec[94].N.Field3 = FL;
roomrec[94].N.Field4 = FR;
roomrec[94].N.Field5 = FF;
roomrec[94].N.Field6 = FF;

roomrec[94].S.Field1 = CF; 
roomrec[94].S.Field2 = CF;
roomrec[94].S.Field3 = CF;
roomrec[94].S.Field4 = CF;
roomrec[94].S.Field5 = CF;
roomrec[94].S.Field6 = CF;

roomrec[94].E.Field1 = EMPTY; 
roomrec[94].E.Field2 = EMPTY;
roomrec[94].E.Field3 = FF;
roomrec[94].E.Field4 = FF;
roomrec[94].E.Field5 = EMPTY;
roomrec[94].E.Field6 = CR;

roomrec[94].W.Field1 = CF; 
roomrec[94].W.Field2 = CF;
roomrec[94].W.Field3 = CF;
roomrec[94].W.Field4 = CF;
roomrec[94].W.Field5 = CF;
roomrec[94].W.Field6 = CF;

/**************************/

/**************************/  

                             /* Room : 14 */
roomrec[95].N.Field1 = EMPTY; 
roomrec[95].N.Field2 = EMPTY;
roomrec[95].N.Field3 = FF;
roomrec[95].N.Field4 = FF;
roomrec[95].N.Field5 = FF;
roomrec[95].N.Field6 = CR;

roomrec[95].S.Field1 = CL; 
roomrec[95].S.Field2 = FF;
roomrec[95].S.Field3 = FL;
roomrec[95].S.Field4 = FR;
roomrec[95].S.Field5 = MR;
roomrec[95].S.Field6 = MF;

roomrec[95].E.Field1 = CF; 
roomrec[95].E.Field2 = CF;
roomrec[95].E.Field3 = CF;
roomrec[95].E.Field4 = CF;
roomrec[95].E.Field5 = CF;
roomrec[95].E.Field6 = CF;

roomrec[95].W.Field1 = MF; 
roomrec[95].W.Field2 = ML;
roomrec[95].W.Field3 = FF;
roomrec[95].W.Field4 = FF;
roomrec[95].W.Field5 = FF;
roomrec[95].W.Field6 = FF;


/**************************/  
/**************************/  

                             /* Room : 15 */
roomrec[96].N.Field1 = CL; 
roomrec[96].N.Field2 = FF;
roomrec[96].N.Field3 = FF;
roomrec[96].N.Field4 = FF;
roomrec[96].N.Field5 = FF;
roomrec[96].N.Field6 = CR;

roomrec[96].S.Field1 = CL; 
roomrec[96].S.Field2 = FF;
roomrec[96].S.Field3 = FL;
roomrec[96].S.Field4 = FR;
roomrec[96].S.Field5 = FF;
roomrec[96].S.Field6 = CR;

roomrec[96].E.Field1 = CF; 
roomrec[96].E.Field2 = CF;
roomrec[96].E.Field3 = CF;
roomrec[96].E.Field4 = CF;
roomrec[96].E.Field5 = CF;
roomrec[96].E.Field6 = CF;

roomrec[96].W.Field1 = CF; 
roomrec[96].W.Field2 = CF;
roomrec[96].W.Field3 = CF;
roomrec[96].W.Field4 = CF;
roomrec[96].W.Field5 = CF;
roomrec[96].W.Field6 = CF;


/**************************/  

                             /* Room : 15 */
roomrec[97].N.Field1 = CL; 
roomrec[97].N.Field2 = FF;
roomrec[97].N.Field3 = FF;
roomrec[97].N.Field4 = FF;
roomrec[97].N.Field5 = FF;
roomrec[97].N.Field6 = CR;

roomrec[97].S.Field1 = CL; 
roomrec[97].S.Field2 = FF;
roomrec[97].S.Field3 = FL;
roomrec[97].S.Field4 = FR;
roomrec[97].S.Field5 = FF;
roomrec[97].S.Field6 = CR;

roomrec[97].E.Field1 = CF; 
roomrec[97].E.Field2 = CF;
roomrec[97].E.Field3 = CF;
roomrec[97].E.Field4 = CF;
roomrec[97].E.Field5 = CF;
roomrec[97].E.Field6 = CF;

roomrec[97].W.Field1 = CF; 
roomrec[97].W.Field2 = CF;
roomrec[97].W.Field3 = CF;
roomrec[97].W.Field4 = CF;
roomrec[97].W.Field5 = CF;
roomrec[97].W.Field6 = CF;

/**************************/  


/**************************/  

                             /* Room : 17 */
roomrec[98].N.Field1 = CL; 
roomrec[98].N.Field2 = FF;
roomrec[98].N.Field3 = FF;
roomrec[98].N.Field4 = FF;
roomrec[98].N.Field5 = MR;
roomrec[98].N.Field6 = CR;

roomrec[98].S.Field1 = CL; 
roomrec[98].S.Field2 = ML;
roomrec[98].S.Field3 = EMPTY;
roomrec[98].S.Field4 = FR;
roomrec[98].S.Field5 = FF;
roomrec[98].S.Field6 = CR;

roomrec[98].E.Field1 = CF; 
roomrec[98].E.Field2 = CF;
roomrec[98].E.Field3 = CF;
roomrec[98].E.Field4 = CF;
roomrec[98].E.Field5 = CF;
roomrec[98].E.Field6 = CF;

roomrec[98].W.Field1 = CF; 
roomrec[98].W.Field2 = CF;
roomrec[98].W.Field3 = CF;
roomrec[98].W.Field4 = CF;
roomrec[98].W.Field5 = CF;
roomrec[98].W.Field6 = CF;

/**************************/  

                             /* Room : 18 */
roomrec[99].N.Field1 = CL; 
roomrec[99].N.Field2 = ML;
roomrec[99].N.Field3 = FL;
roomrec[99].N.Field4 = FR;
roomrec[99].N.Field5 = MR;
roomrec[99].N.Field6 = CR;

roomrec[99].S.Field1 = CL; 
roomrec[99].S.Field2 = ML;
roomrec[99].S.Field3 = FF;
roomrec[99].S.Field4 = FF;
roomrec[99].S.Field5 = MR;
roomrec[99].S.Field6 = CR;

roomrec[99].E.Field1 = CF; 
roomrec[99].E.Field2 = CF;
roomrec[99].E.Field3 = CF;
roomrec[99].E.Field4 = CF;
roomrec[99].E.Field5 = CF;
roomrec[99].E.Field6 = CF;

roomrec[99].W.Field1 = CF; 
roomrec[99].W.Field2 = CF;
roomrec[99].W.Field3 = CF;
roomrec[99].W.Field4 = CF;
roomrec[99].W.Field5 = CF;
roomrec[99].W.Field6 = CF;
/**************************/  

                             /* Room : 19 */
roomrec[100].N.Field1 = CL; 
roomrec[100].N.Field2 = ML;
roomrec[100].N.Field3 = FL;
roomrec[100].N.Field4 = FR;
roomrec[100].N.Field5 = MR;
roomrec[100].N.Field6 = MF;

roomrec[100].S.Field1 = CF; 
roomrec[100].S.Field2 = CF;
roomrec[100].S.Field3 = CF;
roomrec[100].S.Field4 = CF;
roomrec[100].S.Field5 = CF;
roomrec[100].S.Field6 = CF;

roomrec[100].E.Field1 = MF; 
roomrec[100].E.Field2 = ML;
roomrec[100].E.Field3 = FL;
roomrec[100].E.Field4 = FR;
roomrec[100].E.Field5 = MR;
roomrec[100].E.Field6 = CR;

roomrec[100].W.Field1 = CF; 
roomrec[100].W.Field2 = CF;
roomrec[100].W.Field3 = CF;
roomrec[100].W.Field4 = CF;
roomrec[100].W.Field5 = CF;
roomrec[100].W.Field6 = CF;
/**************************/  

                             /* Room : 20 */
roomrec[101].N.Field1 = CF; 
roomrec[101].N.Field2 = CF;
roomrec[101].N.Field3 = CF;
roomrec[101].N.Field4 = CF;
roomrec[101].N.Field5 = CF;
roomrec[101].N.Field6 = CF;

roomrec[101].S.Field1 = CF; 
roomrec[101].S.Field2 = CF;
roomrec[101].S.Field3 = CF;
roomrec[101].S.Field4 = CF;
roomrec[101].S.Field5 = CF;
roomrec[101].S.Field6 = CF;

roomrec[101].E.Field1 = CL; 
roomrec[101].E.Field2 = ML;
roomrec[101].E.Field3 = FL;
roomrec[101].E.Field4 = FR;
roomrec[101].E.Field5 = MR;
roomrec[101].E.Field6 = CR;

roomrec[101].W.Field1 = CL; 
roomrec[101].W.Field2 = ML;
roomrec[101].W.Field3 = FF;
roomrec[101].W.Field4 = FF;
roomrec[101].W.Field5 = FF;
roomrec[101].W.Field6 = CR;
/**************************/  

}
