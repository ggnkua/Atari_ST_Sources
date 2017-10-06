/* room rec 2 .. inits rooms 101-247
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
set_up2()
{
/**************************/  

                             /* Room : 50 */
roomrec[102].N.Field1 = CF; 
roomrec[102].N.Field2 = CF;
roomrec[102].N.Field3 = CF;
roomrec[102].N.Field4 = CF;
roomrec[102].N.Field5 = CF;
roomrec[102].N.Field6 = CF;

roomrec[102].S.Field1 = CF; 
roomrec[102].S.Field2 = CF;
roomrec[102].S.Field3 = CF;
roomrec[102].S.Field4 = CF;
roomrec[102].S.Field5 = CF;
roomrec[102].S.Field6 = CF;

roomrec[102].E.Field1 = CL; 
roomrec[102].E.Field2 = ML;
roomrec[102].E.Field3 = FL;
roomrec[102].E.Field4 = FR;
roomrec[102].E.Field5 = MR;
roomrec[102].E.Field6 = CR;

roomrec[102].W.Field1 = CL; 
roomrec[102].W.Field2 = ML;
roomrec[102].W.Field3 = FL;
roomrec[102].W.Field4 = EMPTY;
roomrec[102].W.Field5 = MR;
roomrec[102].W.Field6 = CR;
/**********************************/


                                /* Room 1 */
roomrec[103].N.Field1 = CF; 
roomrec[103].N.Field2 = CF;
roomrec[103].N.Field3 = CF;
roomrec[103].N.Field4 = CF;
roomrec[103].N.Field5 = CF;
roomrec[103].N.Field6 = CF;

roomrec[103].S.Field1 = CF; 
roomrec[103].S.Field2 = CF;
roomrec[103].S.Field3 = CF;
roomrec[103].S.Field4 = CF;
roomrec[103].S.Field5 = CF;
roomrec[103].S.Field6 = CF;

roomrec[103].E.Field1 = CL; 
roomrec[103].E.Field2 = ML;
roomrec[103].E.Field3 = FL;
roomrec[103].E.Field4 = FR;
roomrec[103].E.Field5 = MR;
roomrec[103].E.Field6 = CR;

roomrec[103].W.Field1 = CL; 
roomrec[103].W.Field2 = ML;
roomrec[103].W.Field3 = FL;
roomrec[103].W.Field4 = FR;
roomrec[103].W.Field5 = MR;
roomrec[103].W.Field6 = CR;

/******************************/
                                 /* room 2 */
roomrec[104].N.Field1 = CF; 
roomrec[104].N.Field2 = CF;
roomrec[104].N.Field3 = CF;
roomrec[104].N.Field4 = CF;
roomrec[104].N.Field5 = CF;
roomrec[104].N.Field6 = CF;

roomrec[104].S.Field1 = CF; 
roomrec[104].S.Field2 = CF;
roomrec[104].S.Field3 = CF;
roomrec[104].S.Field4 = CF;
roomrec[104].S.Field5 = CF;
roomrec[104].S.Field6 = CF;

roomrec[104].E.Field1 = CL; 
roomrec[104].E.Field2 = ML;
roomrec[104].E.Field3 = FL;
roomrec[104].E.Field4 = FR;
roomrec[104].E.Field5 = MR;
roomrec[104].E.Field6 = CR;

roomrec[104].W.Field1 = CL; 
roomrec[104].W.Field2 = ML;
roomrec[104].W.Field3 = FL;
roomrec[104].W.Field4 = FR;
roomrec[104].W.Field5 = MR;
roomrec[104].W.Field6 = CR;


/******************************/
                               /* room 3 */

roomrec[105].N.Field1 = CF; 
roomrec[105].N.Field2 = CF;
roomrec[105].N.Field3 = CF;
roomrec[105].N.Field4 = CF;
roomrec[105].N.Field5 = CF;
roomrec[105].N.Field6 = CF;

roomrec[105].S.Field1 = CF; 
roomrec[105].S.Field2 = CF;
roomrec[105].S.Field3 = CF;
roomrec[105].S.Field4 = CF;
roomrec[105].S.Field5 = CF;
roomrec[105].S.Field6 = CF;

roomrec[105].E.Field1 = CL; 
roomrec[105].E.Field2 = ML;
roomrec[105].E.Field3 = FL;
roomrec[105].E.Field4 = FR;
roomrec[105].E.Field5 = MR;
roomrec[105].E.Field6 = CR;

roomrec[105].W.Field1 = CL; 
roomrec[105].W.Field2 = ML;
roomrec[105].W.Field3 = FL;
roomrec[105].W.Field4 = FR;
roomrec[105].W.Field5 = MR;
roomrec[105].W.Field6 = CR;


/***************************/
                            /* Room 4 */
roomrec[106].N.Field1 = CF; 
roomrec[106].N.Field2 = CF;
roomrec[106].N.Field3 = CF;
roomrec[106].N.Field4 = CF;
roomrec[106].N.Field5 = CF;
roomrec[106].N.Field6 = CF;

roomrec[106].S.Field1 = CF; 
roomrec[106].S.Field2 = CF;
roomrec[106].S.Field3 = CF;
roomrec[106].S.Field4 = CF;
roomrec[106].S.Field5 = CF;
roomrec[106].S.Field6 = CF;

roomrec[106].E.Field1 = CL; 
roomrec[106].E.Field2 = FF;
roomrec[106].E.Field3 = FF;
roomrec[106].E.Field4 = FF;
roomrec[106].E.Field5 = MR;
roomrec[106].E.Field6 = CR;

roomrec[106].W.Field1 = CL; 
roomrec[106].W.Field2 = ML;
roomrec[106].W.Field3 = FL;
roomrec[106].W.Field4 = FR;
roomrec[106].W.Field5 = MR;
roomrec[106].W.Field6 = CR;

/****************************/
                             /* room 5 */
roomrec[107].N.Field1 = MF; 
roomrec[107].N.Field2 = ML;
roomrec[107].N.Field3 = FL;
roomrec[107].N.Field4 = FR;
roomrec[107].N.Field5 = MR;
roomrec[107].N.Field6 = CR;

roomrec[107].S.Field1 = CF; 
roomrec[107].S.Field2 = CF;
roomrec[107].S.Field3 = CF;
roomrec[107].S.Field4 = CF;
roomrec[107].S.Field5 = CF;
roomrec[107].S.Field6 = CF;

roomrec[107].E.Field1 = CF; 
roomrec[107].E.Field2 = CF;
roomrec[107].E.Field3 = CF;
roomrec[107].E.Field4 = CF;
roomrec[107].E.Field5 = CF;
roomrec[107].E.Field6 = CF;

roomrec[107].W.Field1 = CL; 
roomrec[107].W.Field2 = ML;
roomrec[107].W.Field3 = FL;
roomrec[107].W.Field4 = FR;
roomrec[107].W.Field5 = MR;
roomrec[107].W.Field6 = MF;

/**************************/  

                             /* Room : 6 */
roomrec[108].N.Field1 = CL; 
roomrec[108].N.Field2 = ML;
roomrec[108].N.Field3 = FL;
roomrec[108].N.Field4 = EMPTY;
roomrec[108].N.Field5 = MR;
roomrec[108].N.Field6 = CR;

roomrec[108].S.Field1 = CL; 
roomrec[108].S.Field2 = ML;
roomrec[108].S.Field3 = FL;
roomrec[108].S.Field4 = FR;
roomrec[108].S.Field5 = MR;
roomrec[108].S.Field6 = CR;

roomrec[108].E.Field1 = CF; 
roomrec[108].E.Field2 = CF;
roomrec[108].E.Field3 = CF;
roomrec[108].E.Field4 = CF;
roomrec[108].E.Field5 = CF;
roomrec[108].E.Field6 = CF;

roomrec[108].W.Field1 = CF; 
roomrec[108].W.Field2 = CF;
roomrec[108].W.Field3 = CF;
roomrec[108].W.Field4 = CF;
roomrec[108].W.Field5 = CF;
roomrec[108].W.Field6 = CF;

/**************************/
/**************************/  

                             /* Room : 7 */
roomrec[109].N.Field1 = CL; 
roomrec[109].N.Field2 = EMPTY;
roomrec[109].N.Field3 = EMPTY;
roomrec[109].N.Field4 = EMPTY;
roomrec[109].N.Field5 = MR;
roomrec[109].N.Field6 = MF;

roomrec[109].S.Field1 = MF; 
roomrec[109].S.Field2 = ML;
roomrec[109].S.Field3 = EMPTY;
roomrec[109].S.Field4 = EMPTY;
roomrec[109].S.Field5 = MR;
roomrec[109].S.Field6 = CR;

roomrec[109].E.Field1 = MF; 
roomrec[109].E.Field2 = ML;
roomrec[109].E.Field3 = EMPTY;
roomrec[109].E.Field4 = EMPTY;
roomrec[109].E.Field5 = MR;
roomrec[109].E.Field6 = MF;

roomrec[109].W.Field1 = CF; 
roomrec[109].W.Field2 = CF;
roomrec[109].W.Field3 = CF;
roomrec[109].W.Field4 = CF;
roomrec[109].W.Field5 = CF;
roomrec[109].W.Field6 = CF;

/**************************/

/**************************/  

                             /* Room : 8 */
roomrec[110].N.Field1 = CF; 
roomrec[110].N.Field2 = CF;
roomrec[110].N.Field3 = CF;
roomrec[110].N.Field4 = CF;
roomrec[110].N.Field5 = CF;
roomrec[110].N.Field6 = CF;

roomrec[110].S.Field1 = CF; 
roomrec[110].S.Field2 = CF;
roomrec[110].S.Field3 = CF;
roomrec[110].S.Field4 = CF;
roomrec[110].S.Field5 = CF;
roomrec[110].S.Field6 = CF;

roomrec[110].E.Field1 = CL; 
roomrec[110].E.Field2 = FF;
roomrec[110].E.Field3 = FL;
roomrec[110].E.Field4 = FR;
roomrec[110].E.Field5 = FF;
roomrec[110].E.Field6 = CR;

roomrec[110].W.Field1 = CL; 
roomrec[110].W.Field2 = FF;
roomrec[110].W.Field3 = FF;
roomrec[110].W.Field4 = FF;
roomrec[110].W.Field5 = FF;
roomrec[110].W.Field6 = CR;


/**************************/  

                             /* Room : 9 */
roomrec[111].N.Field1 = MF; 
roomrec[111].N.Field2 = ML;
roomrec[111].N.Field3 = EMPTY;
roomrec[111].N.Field4 = EMPTY;
roomrec[111].N.Field5 = MR;
roomrec[111].N.Field6 = MF;

roomrec[111].S.Field1 = MF; 
roomrec[111].S.Field2 = ML;
roomrec[111].S.Field3 = EMPTY;
roomrec[111].S.Field4 = EMPTY;
roomrec[111].S.Field5 = MR;
roomrec[111].S.Field6 = MF;

roomrec[111].E.Field1 = MF; 
roomrec[111].E.Field2 = ML;
roomrec[111].E.Field3 = EMPTY;
roomrec[111].E.Field4 = EMPTY;
roomrec[111].E.Field5 = MR;
roomrec[111].E.Field6 = MF;

roomrec[111].W.Field1 = MF; 
roomrec[111].W.Field2 = ML;
roomrec[111].W.Field3 = EMPTY;
roomrec[111].W.Field4 = EMPTY;
roomrec[111].W.Field5 = MR;
roomrec[111].W.Field6 = MF;
/**************************/  /**************************/  

                             /* Room : 10 */
roomrec[112].N.Field1 = CF; 
roomrec[112].N.Field2 = CF;
roomrec[112].N.Field3 = CF;
roomrec[112].N.Field4 = CF;
roomrec[112].N.Field5 = CF;
roomrec[112].N.Field6 = CF;

roomrec[112].S.Field1 = CF; 
roomrec[112].S.Field2 = CF;
roomrec[112].S.Field3 = CF;
roomrec[112].S.Field4 = CF;
roomrec[112].S.Field5 = CF;
roomrec[112].S.Field6 = CF;

roomrec[112].E.Field1 = CL; 
roomrec[112].E.Field2 = FF;
roomrec[112].E.Field3 = FL;
roomrec[112].E.Field4 = FR;
roomrec[112].E.Field5 = FF;
roomrec[112].E.Field6 = CR;

roomrec[112].W.Field1 = CL; 
roomrec[112].W.Field2 = FF;
roomrec[112].W.Field3 = FL;
roomrec[112].W.Field4 = FR;
roomrec[112].W.Field5 = FF;
roomrec[112].W.Field6 = CR;

/**************************/

/**************************/  

                             /* Room : 9 */
roomrec[113].N.Field1 = MF; 
roomrec[113].N.Field2 = ML;
roomrec[113].N.Field3 = EMPTY;
roomrec[113].N.Field4 = EMPTY;
roomrec[113].N.Field5 = MR;
roomrec[113].N.Field6 = MF;

roomrec[113].S.Field1 = MF; 
roomrec[113].S.Field2 = ML;
roomrec[113].S.Field3 = EMPTY;
roomrec[113].S.Field4 = EMPTY;
roomrec[113].S.Field5 = MR;
roomrec[113].S.Field6 = MF;

roomrec[113].E.Field1 = MF; 
roomrec[113].E.Field2 = ML;
roomrec[113].E.Field3 = EMPTY;
roomrec[113].E.Field4 = EMPTY;
roomrec[113].E.Field5 = MR;
roomrec[113].E.Field6 = MF;

roomrec[113].W.Field1 = MF; 
roomrec[113].W.Field2 = ML;
roomrec[113].W.Field3 = EMPTY;
roomrec[113].W.Field4 = EMPTY;
roomrec[113].W.Field5 = MR;
roomrec[113].W.Field6 = MF;

/**************************/  

                             /* Room : 12 */
roomrec[114].N.Field1 = CF; 
roomrec[114].N.Field2 = CF;
roomrec[114].N.Field3 = CF;
roomrec[114].N.Field4 = CF;
roomrec[114].N.Field5 = CF;
roomrec[114].N.Field6 = CF;

roomrec[114].S.Field1 = CF; 
roomrec[114].S.Field2 = CF;
roomrec[114].S.Field3 = CF;
roomrec[114].S.Field4 = CF;
roomrec[114].S.Field5 = CF;
roomrec[114].S.Field6 = CF;

roomrec[114].E.Field1 = CL; 
roomrec[114].E.Field2 = FF;
roomrec[114].E.Field3 = FF;
roomrec[114].E.Field4 = FF;
roomrec[114].E.Field5 = EMPTY;
roomrec[114].E.Field6 = CR;

roomrec[114].W.Field1 = CL; 
roomrec[114].W.Field2 = FF;
roomrec[114].W.Field3 = FL;
roomrec[114].W.Field4 = FR;
roomrec[114].W.Field5 = FF;
roomrec[114].W.Field6 = CR;

/**************************/
 /**************************/  

                             /* Room : 13 */
roomrec[115].N.Field1 = MF; 
roomrec[115].N.Field2 = ML;
roomrec[115].N.Field3 = EMPTY;
roomrec[115].N.Field4 = FR;
roomrec[115].N.Field5 = MR;
roomrec[115].N.Field6 = CR;

roomrec[115].S.Field1 = CL; 
roomrec[115].S.Field2 = EMPTY;
roomrec[115].S.Field3 = EMPTY;
roomrec[115].S.Field4 = EMPTY;
roomrec[115].S.Field5 = MR;
roomrec[115].S.Field6 = MF;

roomrec[115].E.Field1 = CF; 
roomrec[115].E.Field2 = CF;
roomrec[115].E.Field3 = CF;
roomrec[115].E.Field4 = CF;
roomrec[115].E.Field5 = CF;
roomrec[115].E.Field6 = CF;

roomrec[115].W.Field1 = MF; 
roomrec[115].W.Field2 = ML;
roomrec[115].W.Field3 = EMPTY;
roomrec[115].W.Field4 = EMPTY;
roomrec[115].W.Field5 = MR;
roomrec[115].W.Field6 = MF;

/**************************/

/**************************/  

                             /* Room : 14 */
roomrec[116].N.Field1 = CL; 
roomrec[116].N.Field2 = ML;
roomrec[116].N.Field3 = FL;
roomrec[116].N.Field4 = FR;
roomrec[116].N.Field5 = MR;
roomrec[116].N.Field6 = CR;

roomrec[116].S.Field1 = CF; 
roomrec[116].S.Field2 = CF;
roomrec[116].S.Field3 = CF;
roomrec[116].S.Field4 = CF;
roomrec[116].S.Field5 = CF;
roomrec[116].S.Field6 = CF;

roomrec[116].E.Field1 = CF; 
roomrec[116].E.Field2 = CF;
roomrec[116].E.Field3 = CF;
roomrec[116].E.Field4 = CF;
roomrec[116].E.Field5 = CF;
roomrec[116].E.Field6 = CF;

roomrec[116].W.Field1 = CF; 
roomrec[116].W.Field2 = CF;
roomrec[116].W.Field3 = CF;
roomrec[116].W.Field4 = CF;
roomrec[116].W.Field5 = CF;
roomrec[116].W.Field6 = CF;


/**************************/  
/**************************/  

                             /* Room : 15 */
roomrec[117].N.Field1 = CL; 
roomrec[117].N.Field2 = ML;
roomrec[117].N.Field3 = FL;
roomrec[117].N.Field4 = FR;
roomrec[117].N.Field5 = MR;
roomrec[117].N.Field6 = CR;

roomrec[117].S.Field1 = CL; 
roomrec[117].S.Field2 = ML;
roomrec[117].S.Field3 = EMPTY;
roomrec[117].S.Field4 = FR;
roomrec[117].S.Field5 = MR;
roomrec[117].S.Field6 = CR;

roomrec[117].E.Field1 = CF; 
roomrec[117].E.Field2 = CF;
roomrec[117].E.Field3 = CF;
roomrec[117].E.Field4 = CF;
roomrec[117].E.Field5 = CF;
roomrec[117].E.Field6 = CF;

roomrec[117].W.Field1 = CF; 
roomrec[117].W.Field2 = CF;
roomrec[117].W.Field3 = CF;
roomrec[117].W.Field4 = CF;
roomrec[117].W.Field5 = CF;
roomrec[117].W.Field6 = CF;


/**************************/  
/**************************/  

                             /* Room : 14 */
roomrec[118].N.Field1 = CL; 
roomrec[118].N.Field2 = ML;
roomrec[118].N.Field3 = EMPTY;
roomrec[118].N.Field4 = FR;
roomrec[118].N.Field5 = FF;
roomrec[118].N.Field6 = CR;

roomrec[118].S.Field1 = CL; 
roomrec[118].S.Field2 = EMPTY;
roomrec[118].S.Field3 = FF;
roomrec[118].S.Field4 = FF;
roomrec[118].S.Field5 = EMPTY;
roomrec[118].S.Field6 = CR;

roomrec[118].E.Field1 = CF; 
roomrec[118].E.Field2 = CF;
roomrec[118].E.Field3 = CF;
roomrec[118].E.Field4 = CF;
roomrec[118].E.Field5 = CF;
roomrec[118].E.Field6 = CF;

roomrec[118].W.Field1 = CF; 
roomrec[118].W.Field2 = CF;
roomrec[118].W.Field3 = CF;
roomrec[118].W.Field4 = CF;
roomrec[118].W.Field5 = CF;
roomrec[118].W.Field6 = CF;


/**************************/  

                             /* Room : 17 */
roomrec[119].N.Field1 = CL; 
roomrec[119].N.Field2 = FF;
roomrec[119].N.Field3 = FL;
roomrec[119].N.Field4 = FR;
roomrec[119].N.Field5 = FF;
roomrec[119].N.Field6 = CR;

roomrec[119].S.Field1 = CL; 
roomrec[119].S.Field2 = FF;
roomrec[119].S.Field3 = FL;
roomrec[119].S.Field4 = FR;
roomrec[119].S.Field5 = FF;
roomrec[119].S.Field6 = CR;

roomrec[119].E.Field1 = CF; 
roomrec[119].E.Field2 = CF;
roomrec[119].E.Field3 = CF;
roomrec[119].E.Field4 = CF;
roomrec[119].E.Field5 = CF;
roomrec[119].E.Field6 = CF;

roomrec[119].W.Field1 = CF; 
roomrec[119].W.Field2 = CF;
roomrec[119].W.Field3 = CF;
roomrec[119].W.Field4 = CF;
roomrec[119].W.Field5 = CF;
roomrec[119].W.Field6 = CF;

/**************************/  

                             /* Room : 17 */
roomrec[120].N.Field1 = CL; 
roomrec[120].N.Field2 = FF;
roomrec[120].N.Field3 = FL;
roomrec[120].N.Field4 = FR;
roomrec[120].N.Field5 = FF;
roomrec[120].N.Field6 = CR;

roomrec[120].S.Field1 = CL; 
roomrec[120].S.Field2 = FF;
roomrec[120].S.Field3 = FL;
roomrec[120].S.Field4 = FR;
roomrec[120].S.Field5 = FF;
roomrec[120].S.Field6 = CR;

roomrec[120].E.Field1 = CF; 
roomrec[120].E.Field2 = CF;
roomrec[120].E.Field3 = CF;
roomrec[120].E.Field4 = CF;
roomrec[120].E.Field5 = CF;
roomrec[120].E.Field6 = CF;

roomrec[120].W.Field1 = CF; 
roomrec[120].W.Field2 = CF;
roomrec[120].W.Field3 = CF;
roomrec[120].W.Field4 = CF;
roomrec[120].W.Field5 = CF;
roomrec[120].W.Field6 = CF;

/**************************/  

                             /* Room : 19 */
roomrec[121].N.Field1 = CL; 
roomrec[121].N.Field2 = FF;
roomrec[121].N.Field3 = FL;
roomrec[121].N.Field4 = FR;
roomrec[121].N.Field5 = MR;
roomrec[121].N.Field6 = MF;

roomrec[121].S.Field1 = EMPTY; 
roomrec[121].S.Field2 = EMPTY;
roomrec[121].S.Field3 = EMPTY;
roomrec[121].S.Field4 = FR;
roomrec[121].S.Field5 = FF;
roomrec[121].S.Field6 = CR;

roomrec[121].E.Field1 = MF; 
roomrec[121].E.Field2 = ML;
roomrec[121].E.Field3 = FF;
roomrec[121].E.Field4 = FF;
roomrec[121].E.Field5 = FF;
roomrec[121].E.Field6 = FF;

roomrec[121].W.Field1 = CF; 
roomrec[121].W.Field2 = CF;
roomrec[121].W.Field3 = CF;
roomrec[121].W.Field4 = CF;
roomrec[121].W.Field5 = CF;
roomrec[121].W.Field6 = CF;
/**************************/  

 
                             /* Room : 10 */
roomrec[122].N.Field1 = CF; 
roomrec[122].N.Field2 = CF;
roomrec[122].N.Field3 = CF;
roomrec[122].N.Field4 = CF;
roomrec[122].N.Field5 = CF;
roomrec[122].N.Field6 = CF;

roomrec[122].S.Field1 = CL; 
roomrec[122].S.Field2 = ML;
roomrec[122].S.Field3 = FL;
roomrec[122].S.Field4 = EMPTY;
roomrec[122].S.Field5 = EMPTY;
roomrec[122].S.Field6 = EMPTY;

roomrec[122].E.Field1 = CF; 
roomrec[122].E.Field2 = CF;
roomrec[122].E.Field3 = CF;
roomrec[122].E.Field4 = CF;
roomrec[122].E.Field5 = CF;
roomrec[122].E.Field6 = CF;

roomrec[122].W.Field1 = EMPTY; 
roomrec[122].W.Field2 = EMPTY;
roomrec[122].W.Field3 = FF;
roomrec[122].W.Field4 = FF;
roomrec[122].W.Field5 = EMPTY;
roomrec[122].W.Field6 = CR;

/**************************/

/**************************/  

                             /* Room : 9 */
roomrec[123].N.Field1 = CF; 
roomrec[123].N.Field2 = CF;
roomrec[123].N.Field3 = CF;
roomrec[123].N.Field4 = CF;
roomrec[123].N.Field5 = CF;
roomrec[123].N.Field6 = CF;

roomrec[123].S.Field1 = CL; 
roomrec[123].S.Field2 = ML;
roomrec[123].S.Field3 = FL;
roomrec[123].S.Field4 = FR;
roomrec[123].S.Field5 = MR;
roomrec[123].S.Field6 = CR;

roomrec[123].E.Field1 = MF;  /*DUNGEON */ 
roomrec[123].E.Field2 = ML;
roomrec[123].E.Field3 = EMPTY;
roomrec[123].E.Field4 = EMPTY;
roomrec[123].E.Field5 = MR;
roomrec[123].E.Field6 = MF;

roomrec[123].W.Field1 = CF; 
roomrec[123].W.Field2 = CF;
roomrec[123].W.Field3 = CF;
roomrec[123].W.Field4 = CF;
roomrec[123].W.Field5 = CF;
roomrec[123].W.Field6 = CF;

/**************************/  

                             /* Room : 9 */
roomrec[124].N.Field1 = CF; 
roomrec[124].N.Field2 = CF;
roomrec[124].N.Field3 = CF;
roomrec[124].N.Field4 = CF;
roomrec[124].N.Field5 = CF;
roomrec[124].N.Field6 = CF;

roomrec[124].S.Field1 = CL; 
roomrec[124].S.Field2 = ML;
roomrec[124].S.Field3 = FL;
roomrec[124].S.Field4 = FR;
roomrec[124].S.Field5 = MR;
roomrec[124].S.Field6 = CR;

roomrec[124].E.Field1 = MF;  /*DUNGEON */ 
roomrec[124].E.Field2 = ML;
roomrec[124].E.Field3 = EMPTY;
roomrec[124].E.Field4 = EMPTY;
roomrec[124].E.Field5 = MR;
roomrec[124].E.Field6 = MF;

roomrec[124].W.Field1 = CF; 
roomrec[124].W.Field2 = CF;
roomrec[124].W.Field3 = CF;
roomrec[124].W.Field4 = CF;
roomrec[124].W.Field5 = CF;
roomrec[124].W.Field6 = CF;
/****************************/
                             /* Room : 9 */
roomrec[125].N.Field1 = CF; 
roomrec[125].N.Field2 = CF;
roomrec[125].N.Field3 = CF;
roomrec[125].N.Field4 = CF;
roomrec[125].N.Field5 = CF;
roomrec[125].N.Field6 = CF;

roomrec[125].S.Field1 = CL; 
roomrec[125].S.Field2 = ML;
roomrec[125].S.Field3 = FL;
roomrec[125].S.Field4 = FR;
roomrec[125].S.Field5 = MR;
roomrec[125].S.Field6 = CR;

roomrec[125].E.Field1 = MF;  /*DUNGEON */ 
roomrec[125].E.Field2 = ML;
roomrec[125].E.Field3 = EMPTY;
roomrec[125].E.Field4 = EMPTY;
roomrec[125].E.Field5 = MR;
roomrec[125].E.Field6 = MF;

roomrec[125].W.Field1 = CF; 
roomrec[125].W.Field2 = CF;
roomrec[125].W.Field3 = CF;
roomrec[125].W.Field4 = CF;
roomrec[125].W.Field5 = CF;
roomrec[125].W.Field6 = CF;

/****************************/
                             /* Room : 9 */

roomrec[126].N.Field1 = CF; 
roomrec[126].N.Field2 = CF;
roomrec[126].N.Field3 = CF;
roomrec[126].N.Field4 = CF;
roomrec[126].N.Field5 = CF;
roomrec[126].N.Field6 = CF;

roomrec[126].S.Field1 = CL; 
roomrec[126].S.Field2 = ML;
roomrec[126].S.Field3 = FL;
roomrec[126].S.Field4 = FR;
roomrec[126].S.Field5 = MR;
roomrec[126].S.Field6 = CR;

roomrec[126].E.Field1 = MF;  /*DUNGEON */ 
roomrec[126].E.Field2 = ML;
roomrec[126].E.Field3 = EMPTY;
roomrec[126].E.Field4 = EMPTY;
roomrec[126].E.Field5 = MR;
roomrec[126].E.Field6 = MF;

roomrec[126].W.Field1 = CF; 
roomrec[126].W.Field2 = CF;
roomrec[126].W.Field3 = CF;
roomrec[126].W.Field4 = CF;
roomrec[126].W.Field5 = CF;
roomrec[126].W.Field6 = CF;

/**************************/  
/**************************/  

                             /* Room : 15 */
roomrec[127].N.Field1 = CL; 
roomrec[127].N.Field2 = ML;
roomrec[127].N.Field3 = FL;
roomrec[127].N.Field4 = FR;
roomrec[127].N.Field5 = MR;
roomrec[127].N.Field6 = CR;

roomrec[127].S.Field1 = CL; 
roomrec[127].S.Field2 = EMPTY;
roomrec[127].S.Field3 = EMPTY;
roomrec[127].S.Field4 = FR;
roomrec[127].S.Field5 = MR;
roomrec[127].S.Field6 = CR;

roomrec[127].E.Field1 = CF; 
roomrec[127].E.Field2 = CF;
roomrec[127].E.Field3 = CF;
roomrec[127].E.Field4 = CF;
roomrec[127].E.Field5 = CF;
roomrec[127].E.Field6 = CF;

roomrec[127].W.Field1 = CF; 
roomrec[127].W.Field2 = CF;
roomrec[127].W.Field3 = CF;
roomrec[127].W.Field4 = CF;
roomrec[127].W.Field5 = CF;
roomrec[127].W.Field6 = CF;


/**************************/  
/**************************/  

                             /* Room : 14 */
roomrec[128].N.Field1 = CF; 
roomrec[128].N.Field2 = CF;
roomrec[128].N.Field3 = CF;
roomrec[128].N.Field4 = CF;
roomrec[128].N.Field5 = CF;
roomrec[128].N.Field6 = CF;

roomrec[128].S.Field1 = MF; 
roomrec[128].S.Field2 = ML;
roomrec[128].S.Field3 = FL;
roomrec[128].S.Field4 = FR;
roomrec[128].S.Field5 = MR;
roomrec[128].S.Field6 = CR;

roomrec[128].E.Field1 = CL; 
roomrec[128].E.Field2 = EMPTY;
roomrec[128].E.Field3 = EMPTY;
roomrec[128].E.Field4 = EMPTY;
roomrec[128].E.Field5 = MR;
roomrec[128].E.Field6 = MF;

roomrec[128].W.Field1 = CF; 
roomrec[128].W.Field2 = CF;
roomrec[128].W.Field3 = CF;
roomrec[128].W.Field4 = CF;
roomrec[128].W.Field5 = CF;
roomrec[128].W.Field6 = CF;


/**************************/  

                             /* Room : 17 */
roomrec[129].N.Field1 = MF; 
roomrec[129].N.Field2 = ML;
roomrec[129].N.Field3 = FL;
roomrec[129].N.Field4 = EMPTY;
roomrec[129].N.Field5 = MR;
roomrec[129].N.Field6 = MF;

roomrec[129].S.Field1 = CF; 
roomrec[129].S.Field2 = CF;
roomrec[129].S.Field3 = CF;
roomrec[129].S.Field4 = CF;
roomrec[129].S.Field5 = CF;
roomrec[129].S.Field6 = CF;

roomrec[129].E.Field1 = MF; 
roomrec[129].E.Field2 = ML;
roomrec[129].E.Field3 = EMPTY;
roomrec[129].E.Field4 = EMPTY;
roomrec[129].E.Field5 = MR;
roomrec[129].E.Field6 = CR;

roomrec[129].W.Field1 = CL; 
roomrec[129].W.Field2 = FF;
roomrec[129].W.Field3 = FF;
roomrec[129].W.Field4 = FF;
roomrec[129].W.Field5 = MR;
roomrec[129].W.Field6 = MF;

/**************************/  

                             /* Room : 17 */
roomrec[130].N.Field1 = CL; 
roomrec[130].N.Field2 = FF;
roomrec[130].N.Field3 = FL;
roomrec[130].N.Field4 = FR;
roomrec[130].N.Field5 = FF;
roomrec[130].N.Field6 = FR;

roomrec[130].S.Field1 = CL; 
roomrec[130].S.Field2 = FF;
roomrec[130].S.Field3 = FL;
roomrec[130].S.Field4 = FR;
roomrec[130].S.Field5 = FF;
roomrec[130].S.Field6 = CR;

roomrec[130].E.Field1 = CL; 
roomrec[130].E.Field2 = FF;
roomrec[130].E.Field3 = FL;
roomrec[130].E.Field4 = FR;
roomrec[130].E.Field5 = FF;
roomrec[130].E.Field6 = CR;

roomrec[130].W.Field1 = CL; 
roomrec[130].W.Field2 = ML;
roomrec[130].W.Field3 = EMPTY;
roomrec[130].W.Field4 = FR;
roomrec[130].W.Field5 = FF;
roomrec[130].W.Field6 = CR;

/**************************/  

                             /* Room : 19 */
roomrec[131].N.Field1 = MF; 
roomrec[131].N.Field2 = ML;
roomrec[131].N.Field3 = EMPTY;
roomrec[131].N.Field4 = EMPTY;
roomrec[131].N.Field5 = MR;
roomrec[131].N.Field6 = MF;

roomrec[131].S.Field1 = MF; 
roomrec[131].S.Field2 = ML;
roomrec[131].S.Field3 = FF;
roomrec[131].S.Field4 = FF;
roomrec[131].S.Field5 = MR;
roomrec[131].S.Field6 = MF;

roomrec[131].E.Field1 = MF; 
roomrec[131].E.Field2 = ML;
roomrec[131].E.Field3 = EMPTY;
roomrec[131].E.Field4 = EMPTY;
roomrec[131].E.Field5 = MR;
roomrec[131].E.Field6 = MF;

roomrec[131].W.Field1 = MF; 
roomrec[131].W.Field2 = ML;
roomrec[131].W.Field3 = FL;
roomrec[131].W.Field4 = EMPTY;
roomrec[131].W.Field5 = MR;
roomrec[131].W.Field6 = MF;
/**************************/  

 
                             /* Room : 10 */
roomrec[132].N.Field1 = CF; 
roomrec[132].N.Field2 = CF;
roomrec[132].N.Field3 = CF;
roomrec[132].N.Field4 = CF;
roomrec[132].N.Field5 = CF;
roomrec[132].N.Field6 = CF;

roomrec[132].S.Field1 = CF; 
roomrec[132].S.Field2 = CF;
roomrec[132].S.Field3 = CF;
roomrec[132].S.Field4 = CF;
roomrec[132].S.Field5 = CF;
roomrec[132].S.Field6 = CF;

roomrec[132].E.Field1 = CL; 
roomrec[132].E.Field2 = FF;
roomrec[132].E.Field3 = FL;
roomrec[132].E.Field4 = FR;
roomrec[132].E.Field5 = FF;
roomrec[132].E.Field6 = CR;

roomrec[132].W.Field1 = CL; 
roomrec[132].W.Field2 = FF;
roomrec[132].W.Field3 = FL;
roomrec[132].W.Field4 = FR;
roomrec[132].W.Field5 = FF;
roomrec[132].W.Field6 = CR;

/**************************/

/**************************/  

                             /* Room : 9 */
roomrec[133].N.Field1 = MF; 
roomrec[133].N.Field2 = ML;
roomrec[133].N.Field3 = EMPTY;
roomrec[133].N.Field4 = EMPTY;
roomrec[133].N.Field5 = MR;
roomrec[133].N.Field6 = MF;

roomrec[133].S.Field1 = MF; 
roomrec[133].S.Field2 = ML;
roomrec[133].S.Field3 = FF;
roomrec[133].S.Field4 = FF;
roomrec[133].S.Field5 = MR;
roomrec[133].S.Field6 = MF;

roomrec[133].E.Field1 = MF; 
roomrec[133].E.Field2 = ML;
roomrec[133].E.Field3 = EMPTY;
roomrec[133].E.Field4 = EMPTY;
roomrec[133].E.Field5 = MR;
roomrec[133].E.Field6 = MF;

roomrec[133].W.Field1 = MF; 
roomrec[133].W.Field2 = ML;
roomrec[133].W.Field3 = EMPTY;
roomrec[133].W.Field4 = EMPTY;
roomrec[133].W.Field5 = MR;
roomrec[133].W.Field6 = MF;

/**************************/  

                             /* Room : 9 */
roomrec[134].N.Field1 = CF; 
roomrec[134].N.Field2 = CF;
roomrec[134].N.Field3 = CF;
roomrec[134].N.Field4 = CF;
roomrec[134].N.Field5 = CF;
roomrec[134].N.Field6 = CF;

roomrec[134].S.Field1 = CF; 
roomrec[134].S.Field2 = CF;
roomrec[134].S.Field3 = CF;
roomrec[134].S.Field4 = CF;
roomrec[134].S.Field5 = CF;
roomrec[134].S.Field6 = CF;

roomrec[134].E.Field1 = CL;  /*DUNGEON */ 
roomrec[134].E.Field2 = EMPTY;
roomrec[134].E.Field3 = EMPTY;
roomrec[134].E.Field4 = EMPTY;
roomrec[134].E.Field5 = EMPTY;
roomrec[134].E.Field6 = CR;

roomrec[134].W.Field1 = CL; 
roomrec[134].W.Field2 = FF;
roomrec[134].W.Field3 = FL;
roomrec[134].W.Field4 = FR;
roomrec[134].W.Field5 = FF;
roomrec[134].W.Field6 = CR;
/****************************/
                             /* Room : 9 */
roomrec[135].N.Field1 = MF; 
roomrec[135].N.Field2 = ML;
roomrec[135].N.Field3 = EMPTY;
roomrec[135].N.Field4 = EMPTY;
roomrec[135].N.Field5 = FR;
roomrec[135].N.Field6 = FF;

roomrec[135].S.Field1 = EMPTY; 
roomrec[135].S.Field2 = FF;
roomrec[135].S.Field3 = FF;
roomrec[135].S.Field4 = FF;
roomrec[135].S.Field5 = MR;
roomrec[135].S.Field6 = MF;

roomrec[135].E.Field1 = FF; 
roomrec[135].E.Field2 = FF;
roomrec[135].E.Field3 = FF;
roomrec[135].E.Field4 = FF;
roomrec[135].E.Field5 = FF;
roomrec[135].E.Field6 = FF;

roomrec[135].W.Field1 = MF; 
roomrec[135].W.Field2 = ML;
roomrec[135].W.Field3 = EMPTY;
roomrec[135].W.Field4 = EMPTY;
roomrec[135].W.Field5 = MR;
roomrec[135].W.Field6 = MF;

/****************************/
                             /* Room : 9 */

roomrec[136].N.Field1 = EMPTY; 
roomrec[136].N.Field2 = FF;
roomrec[136].N.Field3 = FF;
roomrec[136].N.Field4 = FF;
roomrec[136].N.Field5 = MR;
roomrec[136].N.Field6 = CR;

roomrec[136].S.Field1 = CL; 
roomrec[136].S.Field2 = ML;
roomrec[136].S.Field3 = FL;
roomrec[136].S.Field4 = FR;
roomrec[136].S.Field5 = FF;
roomrec[136].S.Field6 = FF;

roomrec[136].E.Field1 = CF;  
roomrec[136].E.Field2 = CF;
roomrec[136].E.Field3 = CF;
roomrec[136].E.Field4 = CF;
roomrec[136].E.Field5 = CF;
roomrec[136].E.Field6 = CF;

roomrec[136].W.Field1 = FF; 
roomrec[136].W.Field2 = FF;
roomrec[136].W.Field3 = FL;
roomrec[136].W.Field4 = FR;
roomrec[136].W.Field5 = FF;
roomrec[136].W.Field6 = FF;

/**************************/  
/**************************/  

                             /* Room : 15 */
roomrec[137].N.Field1 = CL; 
roomrec[137].N.Field2 = ML;
roomrec[137].N.Field3 = FF;
roomrec[137].N.Field4 = FF;
roomrec[137].N.Field5 = MR;
roomrec[137].N.Field6 = CR;

roomrec[137].S.Field1 = CL; 
roomrec[137].S.Field2 = ML;
roomrec[137].S.Field3 = EMPTY;
roomrec[137].S.Field4 = FR;
roomrec[137].S.Field5 = MR;
roomrec[137].S.Field6 = CR;

roomrec[137].E.Field1 = CF; 
roomrec[137].E.Field2 = CF;
roomrec[137].E.Field3 = CF;
roomrec[137].E.Field4 = CF;
roomrec[137].E.Field5 = CF;
roomrec[137].E.Field6 = CF;

roomrec[137].W.Field1 = CF; 
roomrec[137].W.Field2 = CF;
roomrec[137].W.Field3 = CF;
roomrec[137].W.Field4 = CF;
roomrec[137].W.Field5 = CF;
roomrec[137].W.Field6 = CF;


/**************************/  
/**************************/  
/************************/  

                             /* Room : 15 */
roomrec[138].N.Field1 = CL; 
roomrec[138].N.Field2 = ML;
roomrec[138].N.Field3 = FF;
roomrec[138].N.Field4 = FF;
roomrec[138].N.Field5 = MR;
roomrec[138].N.Field6 = CR;

roomrec[138].S.Field1 = CL; 
roomrec[138].S.Field2 = ML;
roomrec[138].S.Field3 = EMPTY;
roomrec[138].S.Field4 = FR;
roomrec[138].S.Field5 = MR;
roomrec[138].S.Field6 = CR;

roomrec[138].E.Field1 = CF; 
roomrec[138].E.Field2 = CF;
roomrec[138].E.Field3 = CF;
roomrec[138].E.Field4 = CF;
roomrec[138].E.Field5 = CF;
roomrec[138].E.Field6 = CF;

roomrec[138].W.Field1 = CF; 
roomrec[138].W.Field2 = CF;
roomrec[138].W.Field3 = CF;
roomrec[138].W.Field4 = CF;
roomrec[138].W.Field5 = CF;
roomrec[138].W.Field6 = CF;


  

/**************************/  

                             /* Room : 15 */
roomrec[139].N.Field1 = CL; 
roomrec[139].N.Field2 = ML;
roomrec[139].N.Field3 = FF;
roomrec[139].N.Field4 = FF;
roomrec[139].N.Field5 = MR;
roomrec[139].N.Field6 = CR;

roomrec[139].S.Field1 = CL; 
roomrec[139].S.Field2 = ML;
roomrec[139].S.Field3 = EMPTY;
roomrec[139].S.Field4 = EMPTY;
roomrec[139].S.Field5 = MR;
roomrec[139].S.Field6 = CR;

roomrec[139].E.Field1 = CF; 
roomrec[139].E.Field2 = CF;
roomrec[139].E.Field3 = CF;
roomrec[139].E.Field4 = CF;
roomrec[139].E.Field5 = CF;
roomrec[139].E.Field6 = CF;

roomrec[139].W.Field1 = CF; 
roomrec[139].W.Field2 = CF;
roomrec[139].W.Field3 = CF;
roomrec[139].W.Field4 = CF;
roomrec[139].W.Field5 = CF;
roomrec[139].W.Field6 = CF;


/**************************/  

                             /* Room : 15 */
roomrec[140].N.Field1 = CL; 
roomrec[140].N.Field2 = ML;
roomrec[140].N.Field3 = FF;
roomrec[140].N.Field4 = FF;
roomrec[140].N.Field5 = MR;
roomrec[140].N.Field6 = CR;

roomrec[140].S.Field1 = CL; 
roomrec[140].S.Field2 = ML;
roomrec[140].S.Field3 = EMPTY;
roomrec[140].S.Field4 = EMPTY;
roomrec[140].S.Field5 = MR;
roomrec[140].S.Field6 = CR;

roomrec[140].E.Field1 = CF; 
roomrec[140].E.Field2 = CF;
roomrec[140].E.Field3 = CF;
roomrec[140].E.Field4 = CF;
roomrec[140].E.Field5 = CF;
roomrec[140].E.Field6 = CF;

roomrec[140].W.Field1 = CF; 
roomrec[140].W.Field2 = CF;
roomrec[140].W.Field3 = CF;
roomrec[140].W.Field4 = CF;
roomrec[140].W.Field5 = CF;
roomrec[140].W.Field6 = CF;


/**************************/  

                             /* Room : 19 */
roomrec[141].N.Field1 = CL; 
roomrec[141].N.Field2 = ML;
roomrec[141].N.Field3 = FL;
roomrec[141].N.Field4 = FR;
roomrec[141].N.Field5 = MR;
roomrec[141].N.Field6 = MF;

roomrec[141].S.Field1 = FF; 
roomrec[141].S.Field2 = FF;
roomrec[141].S.Field3 = FL;
roomrec[141].S.Field4 = FR;
roomrec[141].S.Field5 = MR;
roomrec[141].S.Field6 = CR;

roomrec[141].E.Field1 = MF; 
roomrec[141].E.Field2 = ML;
roomrec[141].E.Field3 = FF;
roomrec[141].E.Field4 = FF;
roomrec[141].E.Field5 = EMPTY;
roomrec[141].E.Field6 = EMPTY;

roomrec[141].W.Field1 = CF; 
roomrec[141].W.Field2 = CF;
roomrec[141].W.Field3 = CF;
roomrec[141].W.Field4 = CF;
roomrec[141].W.Field5 = CF;
roomrec[141].W.Field6 = CF;
/**************************/  

/**************************/  

                             /* Room : 19 */
roomrec[142].N.Field1 = CL; 
roomrec[142].N.Field2 = ML;
roomrec[142].N.Field3 = FL;
roomrec[142].N.Field4 = FR;
roomrec[142].N.Field5 = MR;
roomrec[142].N.Field6 = MF;

roomrec[142].S.Field1 = CL; 
roomrec[142].S.Field2 = FF;
roomrec[142].S.Field3 = FF;
roomrec[142].S.Field4 = FF;
roomrec[142].S.Field5 = EMPTY;
roomrec[142].S.Field6 = EMPTY;

roomrec[142].E.Field1 = MF; 
roomrec[142].E.Field2 = ML;
roomrec[142].E.Field3 = FF;
roomrec[142].E.Field4 = FF;
roomrec[142].E.Field5 = EMPTY;
roomrec[142].E.Field6 = EMPTY;

roomrec[142].W.Field1 = FF; 
roomrec[142].W.Field2 = FF;
roomrec[142].W.Field3 = FF;
roomrec[142].W.Field4 = FF;
roomrec[142].W.Field5 = FF;
roomrec[142].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[143].N.Field1 = CL; 
roomrec[143].N.Field2 = ML;
roomrec[143].N.Field3 = FL;
roomrec[143].N.Field4 = FR;
roomrec[143].N.Field5 = MR;
roomrec[143].N.Field6 = MF;

roomrec[143].S.Field1 = CL; 
roomrec[143].S.Field2 = ML;
roomrec[143].S.Field3 = EMPTY;
roomrec[143].S.Field4 = FR;
roomrec[143].S.Field5 = FF;
roomrec[143].S.Field6 = CR;

roomrec[143].E.Field1 = MF; 
roomrec[143].E.Field2 = ML;
roomrec[143].E.Field3 = FF;
roomrec[143].E.Field4 = FF;
roomrec[143].E.Field5 = EMPTY;
roomrec[143].E.Field6 = EMPTY;

roomrec[143].W.Field1 = CR; 
roomrec[143].W.Field2 = FF;
roomrec[143].W.Field3 = FF;
roomrec[143].W.Field4 = FF;
roomrec[143].W.Field5 = FF;
roomrec[143].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[144].N.Field1 = CL; 
roomrec[144].N.Field2 = ML;
roomrec[144].N.Field3 = FF;
roomrec[144].N.Field4 = FF;
roomrec[144].N.Field5 = EMPTY;
roomrec[144].N.Field6 = CR;

roomrec[144].S.Field1 = CL; 
roomrec[144].S.Field2 = ML;
roomrec[144].S.Field3 = FL;
roomrec[144].S.Field4 = EMPTY;
roomrec[144].S.Field5 = MR;
roomrec[144].S.Field6 = CR;

roomrec[144].E.Field1 = MF; 
roomrec[144].E.Field2 = ML;
roomrec[144].E.Field3 = FF;
roomrec[144].E.Field4 = FF;
roomrec[144].E.Field5 = EMPTY;
roomrec[144].E.Field6 = EMPTY;

roomrec[144].W.Field1 = CR; 
roomrec[144].W.Field2 = FF;
roomrec[144].W.Field3 = FF;
roomrec[144].W.Field4 = FF;
roomrec[144].W.Field5 = FF;
roomrec[144].W.Field6 = FF;
/**************************/   /** NOTE ROOM, # 145 DNE! */ 

                             /* Room : 19 */
roomrec[146].N.Field1 = CL; 
roomrec[146].N.Field2 = FF;
roomrec[146].N.Field3 = FL;
roomrec[146].N.Field4 = FR;
roomrec[146].N.Field5 = FF;
roomrec[146].N.Field6 = CR;

roomrec[146].S.Field1 = CL; 
roomrec[146].S.Field2 = FF;
roomrec[146].S.Field3 = FF;
roomrec[146].S.Field4 = FF;
roomrec[146].S.Field5 = EMPTY;
roomrec[146].S.Field6 = EMPTY;

roomrec[146].E.Field1 = MF; 
roomrec[146].E.Field2 = ML;
roomrec[146].E.Field3 = FF;
roomrec[146].E.Field4 = FF;
roomrec[146].E.Field5 = EMPTY;
roomrec[146].E.Field6 = EMPTY;

roomrec[146].W.Field1 = CR; 
roomrec[146].W.Field2 = FF;
roomrec[146].W.Field3 = FF;
roomrec[146].W.Field4 = FF;
roomrec[146].W.Field5 = FF;
roomrec[146].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[147].N.Field1 = CL; 
roomrec[147].N.Field2 = FF;
roomrec[147].N.Field3 = FL;
roomrec[147].N.Field4 = FR;
roomrec[147].N.Field5 = FF;
roomrec[147].N.Field6 = CR;

roomrec[147].S.Field1 = CL; 
roomrec[147].S.Field2 = FF;
roomrec[147].S.Field3 = FF;
roomrec[147].S.Field4 = FF;
roomrec[147].S.Field5 = EMPTY;
roomrec[147].S.Field6 = EMPTY;

roomrec[147].E.Field1 = MF; 
roomrec[147].E.Field2 = ML;
roomrec[147].E.Field3 = FF;
roomrec[147].E.Field4 = FF;
roomrec[147].E.Field5 = EMPTY;
roomrec[147].E.Field6 = EMPTY;

roomrec[147].W.Field1 = CR; 
roomrec[147].W.Field2 = FF;
roomrec[147].W.Field3 = FF;
roomrec[147].W.Field4 = FF;
roomrec[147].W.Field5 = FF;
roomrec[147].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[148].N.Field1 = CL; 
roomrec[148].N.Field2 = FF;
roomrec[148].N.Field3 = FL;
roomrec[148].N.Field4 = EMPTY;
roomrec[148].N.Field5 = EMPTY;
roomrec[148].N.Field6 = EMPTY;

roomrec[148].S.Field1 = CL; 
roomrec[148].S.Field2 = FF;
roomrec[148].S.Field3 = FF;
roomrec[148].S.Field4 = FF;
roomrec[148].S.Field5 = EMPTY;
roomrec[148].S.Field6 = EMPTY;

roomrec[148].E.Field1 = FF; 
roomrec[148].E.Field2 = FF;
roomrec[148].E.Field3 = FF;
roomrec[148].E.Field4 = FF;
roomrec[148].E.Field5 = FF;
roomrec[148].E.Field6 = CR;

roomrec[148].W.Field1 = CR; 
roomrec[148].W.Field2 = FF;
roomrec[148].W.Field3 = FF;
roomrec[148].W.Field4 = FF;
roomrec[148].W.Field5 = FF;
roomrec[148].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[149].N.Field1 = EMPTY; 
roomrec[149].N.Field2 = EMPTY;
roomrec[149].N.Field3 = EMPTY;
roomrec[149].N.Field4 = FR;
roomrec[149].N.Field5 = MR;
roomrec[149].N.Field6 = CR;

roomrec[149].S.Field1 = CL; 
roomrec[149].S.Field2 = ML;
roomrec[149].S.Field3 = FL;
roomrec[149].S.Field4 = EMPTY;
roomrec[149].S.Field5 = MR;
roomrec[149].S.Field6 = MF;

roomrec[149].E.Field1 = MF; 
roomrec[149].E.Field2 = ML;
roomrec[149].E.Field3 = FF;
roomrec[149].E.Field4 = FF;
roomrec[149].E.Field5 = EMPTY;
roomrec[149].E.Field6 = EMPTY;

roomrec[149].W.Field1 = MF; 
roomrec[149].W.Field2 = ML;
roomrec[149].W.Field3 = FF;
roomrec[149].W.Field4 = FF;
roomrec[149].W.Field5 = EMPTY;
roomrec[149].W.Field6 = EMPTY;
/**************************/  

                             /* Room : 19 */
roomrec[150].N.Field1 = CL; 
roomrec[150].N.Field2 = ML;
roomrec[150].N.Field3 = FL;
roomrec[150].N.Field4 = FR;
roomrec[150].N.Field5 = MR;
roomrec[150].N.Field6 = CR;

roomrec[150].S.Field1 = CL; 
roomrec[150].S.Field2 = FF;
roomrec[150].S.Field3 = FF;
roomrec[150].S.Field4 = FF;
roomrec[150].S.Field5 = MR;
roomrec[150].S.Field6 = CR;

roomrec[150].E.Field1 = MF; 
roomrec[150].E.Field2 = ML;
roomrec[150].E.Field3 = FF;
roomrec[150].E.Field4 = FF;
roomrec[150].E.Field5 = EMPTY;
roomrec[150].E.Field6 = EMPTY;

roomrec[150].W.Field1 = CR; 
roomrec[150].W.Field2 = FF;
roomrec[150].W.Field3 = FF;
roomrec[150].W.Field4 = FF;
roomrec[150].W.Field5 = FF;
roomrec[150].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[151].N.Field1 = CL; 
roomrec[151].N.Field2 = ML;
roomrec[151].N.Field3 = FL;
roomrec[151].N.Field4 = FR;
roomrec[151].N.Field5 = MR;
roomrec[151].N.Field6 = CR;

roomrec[151].S.Field1 = CL; 
roomrec[151].S.Field2 = FF;
roomrec[151].S.Field3 = FF;
roomrec[151].S.Field4 = FF;
roomrec[151].S.Field5 = MR;
roomrec[151].S.Field6 = CR;

roomrec[151].E.Field1 = MF; 
roomrec[151].E.Field2 = ML;
roomrec[151].E.Field3 = FF;
roomrec[151].E.Field4 = FF;
roomrec[151].E.Field5 = EMPTY;
roomrec[151].E.Field6 = EMPTY;

roomrec[151].W.Field1 = CR; 
roomrec[151].W.Field2 = FF;
roomrec[151].W.Field3 = FF;
roomrec[151].W.Field4 = FF;
roomrec[151].W.Field5 = FF;
roomrec[151].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[152].N.Field1 = CL; 
roomrec[152].N.Field2 = ML;
roomrec[152].N.Field3 = FL;
roomrec[152].N.Field4 = FR;
roomrec[152].N.Field5 = MR;
roomrec[152].N.Field6 = CR;

roomrec[152].S.Field1 = CL; 
roomrec[152].S.Field2 = FF;
roomrec[152].S.Field3 = FF;
roomrec[152].S.Field4 = FF;
roomrec[152].S.Field5 = FF;
roomrec[152].S.Field6 = CR;

roomrec[152].E.Field1 = MF; 
roomrec[152].E.Field2 = ML;
roomrec[152].E.Field3 = FF;
roomrec[152].E.Field4 = FF;
roomrec[152].E.Field5 = EMPTY;
roomrec[152].E.Field6 = EMPTY;

roomrec[152].W.Field1 = CR; 
roomrec[152].W.Field2 = FF;
roomrec[152].W.Field3 = FF;
roomrec[152].W.Field4 = FF;
roomrec[152].W.Field5 = FF;
roomrec[152].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[153].N.Field1 = CL; 
roomrec[153].N.Field2 = ML;
roomrec[153].N.Field3 = FL;
roomrec[153].N.Field4 = FR;
roomrec[153].N.Field5 = MR;
roomrec[153].N.Field6 = CR;

roomrec[153].S.Field1 = CL; 
roomrec[153].S.Field2 = FF;
roomrec[153].S.Field3 = FF;
roomrec[153].S.Field4 = FF;
roomrec[153].S.Field5 = FF;
roomrec[153].S.Field6 = CR;

roomrec[153].E.Field1 = FF; 
roomrec[153].E.Field2 = ML;
roomrec[153].E.Field3 = FF;
roomrec[153].E.Field4 = FF;
roomrec[153].E.Field5 = EMPTY;
roomrec[153].E.Field6 = EMPTY;

roomrec[153].W.Field1 = CR; 
roomrec[153].W.Field2 = FF;
roomrec[153].W.Field3 = FF;
roomrec[153].W.Field4 = FF;
roomrec[153].W.Field5 = FF;
roomrec[153].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[154].N.Field1 = CL; 
roomrec[154].N.Field2 = ML;
roomrec[154].N.Field3 = FL;
roomrec[154].N.Field4 = FR;
roomrec[154].N.Field5 = FF;
roomrec[154].N.Field6 = FF;

roomrec[154].S.Field1 = MF; 
roomrec[154].S.Field2 = ML;
roomrec[154].S.Field3 = FL;
roomrec[154].S.Field4 = FR;
roomrec[154].S.Field5 = MR;
roomrec[154].S.Field6 = CR;

roomrec[154].E.Field1 = FF; 
roomrec[154].E.Field2 = FF;
roomrec[154].E.Field3 = FL;
roomrec[154].E.Field4 = FR;
roomrec[154].E.Field5 = MR;
roomrec[154].E.Field6 = MF;

roomrec[154].W.Field1 = CR; 
roomrec[154].W.Field2 = FF;
roomrec[154].W.Field3 = FF;
roomrec[154].W.Field4 = FF;
roomrec[154].W.Field5 = FF;
roomrec[154].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[155].N.Field1 = EMPTY; 
roomrec[155].N.Field2 = EMPTY;
roomrec[155].N.Field3 = FF;
roomrec[155].N.Field4 = FF;
roomrec[155].N.Field5 = MR;
roomrec[155].N.Field6 = MF;

roomrec[155].S.Field1 = CL; 
roomrec[155].S.Field2 = FF;
roomrec[155].S.Field3 = FF;
roomrec[155].S.Field4 = FF;
roomrec[155].S.Field5 = EMPTY;
roomrec[155].S.Field6 = EMPTY;

roomrec[155].E.Field1 = MF; 
roomrec[155].E.Field2 = ML;
roomrec[155].E.Field3 = EMPTY;
roomrec[155].E.Field4 = EMPTY;
roomrec[155].E.Field5 = MR;
roomrec[155].E.Field6 = CR;

roomrec[155].W.Field1 = CL; 
roomrec[155].W.Field2 = FF;
roomrec[155].W.Field3 = FF;
roomrec[155].W.Field4 = FF;
roomrec[155].W.Field5 = FF;
roomrec[155].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[156].N.Field1 = EMPTY; 
roomrec[156].N.Field2 = EMPTY;
roomrec[156].N.Field3 = FF;
roomrec[156].N.Field4 = FF;
roomrec[156].N.Field5 = MR;
roomrec[156].N.Field6 = MF;

roomrec[156].S.Field1 = CL; 
roomrec[156].S.Field2 = FF;
roomrec[156].S.Field3 = FF;
roomrec[156].S.Field4 = FF;
roomrec[156].S.Field5 = EMPTY;
roomrec[156].S.Field6 = EMPTY;

roomrec[156].E.Field1 = CL; 
roomrec[156].E.Field2 = FF;
roomrec[156].E.Field3 = FF;
roomrec[156].E.Field4 = FF;
roomrec[156].E.Field5 = FF;
roomrec[156].E.Field6 = CR;

roomrec[156].W.Field1 = CL; 
roomrec[156].W.Field2 = ML;
roomrec[156].W.Field3 = EMPTY;
roomrec[156].W.Field4 = EMPTY;
roomrec[156].W.Field5 = EMPTY;
roomrec[156].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[157].N.Field1 = MF; 
roomrec[157].N.Field2 = ML;
roomrec[157].N.Field3 = FF;
roomrec[157].N.Field4 = FF;
roomrec[157].N.Field5 = MR;
roomrec[157].N.Field6 = CR;

roomrec[157].S.Field1 = CL; 
roomrec[157].S.Field2 = FF;
roomrec[157].S.Field3 = FF;
roomrec[157].S.Field4 = FF;
roomrec[157].S.Field5 = MR;
roomrec[157].S.Field6 = MF;

roomrec[157].E.Field1 = MF; 
roomrec[157].E.Field2 = ML;
roomrec[157].E.Field3 = EMPTY;
roomrec[157].E.Field4 = EMPTY;
roomrec[157].E.Field5 = MR;
roomrec[157].E.Field6 = CR;

roomrec[157].W.Field1 = MF; 
roomrec[157].W.Field2 = ML;
roomrec[157].W.Field3 = FL;
roomrec[157].W.Field4 = EMPTY;
roomrec[157].W.Field5 = MR;
roomrec[157].W.Field6 = MF;
/**************************/  

                             /* Room : 19 */
roomrec[158].N.Field1 = CL; 
roomrec[158].N.Field2 = ML;
roomrec[158].N.Field3 = FL;
roomrec[158].N.Field4 = EMPTY;
roomrec[158].N.Field5 = MR;
roomrec[158].N.Field6 = CR;

roomrec[158].S.Field1 = CL; 
roomrec[158].S.Field2 = ML;
roomrec[158].S.Field3 = EMPTY;
roomrec[158].S.Field4 = EMPTY;
roomrec[158].S.Field5 = EMPTY;
roomrec[158].S.Field6 = CR;

roomrec[158].E.Field1 = MF; 
roomrec[158].E.Field2 = ML;
roomrec[158].E.Field3 = EMPTY;
roomrec[158].E.Field4 = EMPTY;
roomrec[158].E.Field5 = MR;
roomrec[158].E.Field6 = CR;

roomrec[158].W.Field1 = CL; 
roomrec[158].W.Field2 = FF;
roomrec[158].W.Field3 = FF;
roomrec[158].W.Field4 = FF;
roomrec[158].W.Field5 = FF;
roomrec[158].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[159].N.Field1 = EMPTY; 
roomrec[159].N.Field2 = EMPTY;
roomrec[159].N.Field3 = FF;
roomrec[159].N.Field4 = FF;
roomrec[159].N.Field5 = MR;
roomrec[159].N.Field6 = MF;

roomrec[159].S.Field1 = EMPTY; 
roomrec[159].S.Field2 = EMPTY;
roomrec[159].S.Field3 = FF;
roomrec[159].S.Field4 = FF;
roomrec[159].S.Field5 = FF;
roomrec[159].S.Field6 = CR;

roomrec[159].E.Field1 = CL; 
roomrec[159].E.Field2 = ML;
roomrec[159].E.Field3 = FF;
roomrec[159].E.Field4 = FF;
roomrec[159].E.Field5 = EMPTY;
roomrec[159].E.Field6 = EMPTY;

roomrec[159].W.Field1 = CL; 
roomrec[159].W.Field2 = FF;
roomrec[159].W.Field3 = FF;
roomrec[159].W.Field4 = FF;
roomrec[159].W.Field5 = FF;
roomrec[159].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[160].N.Field1 = EMPTY; 
roomrec[160].N.Field2 = EMPTY;
roomrec[160].N.Field3 = FF;
roomrec[160].N.Field4 = FF;
roomrec[160].N.Field5 = MR;
roomrec[160].N.Field6 = MF;

roomrec[160].S.Field1 = CL; 
roomrec[160].S.Field2 = EMPTY;
roomrec[160].S.Field3 = EMPTY;
roomrec[160].S.Field4 = FR;
roomrec[160].S.Field5 = FF;
roomrec[160].S.Field6 = FF;

roomrec[160].E.Field1 = MF; 
roomrec[160].E.Field2 = ML;
roomrec[160].E.Field3 = EMPTY;
roomrec[160].E.Field4 = EMPTY;
roomrec[160].E.Field5 = MR;
roomrec[160].E.Field6 = CR;

roomrec[160].W.Field1 = EMPTY; 
roomrec[160].W.Field2 = EMPTY;
roomrec[160].W.Field3 = FF;
roomrec[160].W.Field4 = FF;
roomrec[160].W.Field5 = MR;
roomrec[160].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[161].N.Field1 = CL; 
roomrec[161].N.Field2 = EMPTY;
roomrec[161].N.Field3 = EMPTY;
roomrec[161].N.Field4 = FR;
roomrec[161].N.Field5 = MR;
roomrec[161].N.Field6 = CR;

roomrec[161].S.Field1 = CL; 
roomrec[161].S.Field2 = ML;
roomrec[161].S.Field3 = FF;
roomrec[161].S.Field4 = FF;
roomrec[161].S.Field5 = EMPTY;
roomrec[161].S.Field6 = CR;

roomrec[161].E.Field1 = MF; 
roomrec[161].E.Field2 = ML;
roomrec[161].E.Field3 = EMPTY;
roomrec[161].E.Field4 = EMPTY;
roomrec[161].E.Field5 = MR;
roomrec[161].E.Field6 = CR;

roomrec[161].W.Field1 = CL; 
roomrec[161].W.Field2 = FF;
roomrec[161].W.Field3 = FF;
roomrec[161].W.Field4 = FF;
roomrec[161].W.Field5 = FF;
roomrec[161].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[162].N.Field1 = CL; 
roomrec[162].N.Field2 = ML;
roomrec[162].N.Field3 = FL;
roomrec[162].N.Field4 = FR;
roomrec[162].N.Field5 = MR;
roomrec[162].N.Field6 = MF;

roomrec[162].S.Field1 = CL; 
roomrec[162].S.Field2 = FF;
roomrec[162].S.Field3 = FF;
roomrec[162].S.Field4 = FF;
roomrec[162].S.Field5 = EMPTY;
roomrec[162].S.Field6 = EMPTY;

roomrec[162].E.Field1 = MF; 
roomrec[162].E.Field2 = ML;
roomrec[162].E.Field3 = FF;
roomrec[162].E.Field4 = FF;
roomrec[162].E.Field5 = MR;
roomrec[162].E.Field6 = CR;

roomrec[162].W.Field1 = CL; 
roomrec[162].W.Field2 = FF;
roomrec[162].W.Field3 = FF;
roomrec[162].W.Field4 = FF;
roomrec[162].W.Field5 = FF;
roomrec[162].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[163].N.Field1 = EMPTY; 
roomrec[163].N.Field2 = EMPTY;
roomrec[163].N.Field3 = FF;
roomrec[163].N.Field4 = FF;
roomrec[163].N.Field5 = MR;
roomrec[163].N.Field6 = MF;

roomrec[163].S.Field1 = CL; 
roomrec[163].S.Field2 = FF;
roomrec[163].S.Field3 = FF;
roomrec[163].S.Field4 = FF;
roomrec[163].S.Field5 = EMPTY;
roomrec[163].S.Field6 = EMPTY;

roomrec[163].E.Field1 = MF;   /*GATE */ 
roomrec[163].E.Field2 = ML;
roomrec[163].E.Field3 = EMPTY;
roomrec[163].E.Field4 = EMPTY;
roomrec[163].E.Field5 = MR;
roomrec[163].E.Field6 = CR;

roomrec[163].W.Field1 = CL; 
roomrec[163].W.Field2 = ML;
roomrec[163].W.Field3 = FF;
roomrec[163].W.Field4 = FF;
roomrec[163].W.Field5 = FF;
roomrec[163].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[164].N.Field1 = CL; 
roomrec[164].N.Field2 = ML;
roomrec[164].N.Field3 = FL;
roomrec[164].N.Field4 = FR;
roomrec[164].N.Field5 = MR;
roomrec[164].N.Field6 = MF;

roomrec[164].S.Field1 = CL; 
roomrec[164].S.Field2 = FF;
roomrec[164].S.Field3 = FF;
roomrec[164].S.Field4 = FF;
roomrec[164].S.Field5 = EMPTY;
roomrec[164].S.Field6 = EMPTY;

roomrec[164].E.Field1 = MF; 
roomrec[164].E.Field2 = ML;
roomrec[164].E.Field3 = EMPTY;
roomrec[164].E.Field4 = FR;
roomrec[164].E.Field5 = MR;
roomrec[164].E.Field6 = CR;

roomrec[164].W.Field1 = CL;   /*GATE*/ 
roomrec[164].W.Field2 = ML;
roomrec[164].W.Field3 = FL;
roomrec[164].W.Field4 = EMPTY;
roomrec[164].W.Field5 = MR;
roomrec[164].W.Field6 = MF;
/**************************/  

                             /* Room : 19 */
roomrec[165].N.Field1 = EMPTY; 
roomrec[165].N.Field2 = EMPTY;
roomrec[165].N.Field3 = FF;
roomrec[165].N.Field4 = FF;
roomrec[165].N.Field5 = MR;
roomrec[165].N.Field6 = MF;

roomrec[165].S.Field1 = CL; 
roomrec[165].S.Field2 = FF;
roomrec[165].S.Field3 = FF;
roomrec[165].S.Field4 = FF;
roomrec[165].S.Field5 = EMPTY;
roomrec[165].S.Field6 = EMPTY;

roomrec[165].E.Field1 = CL; 
roomrec[165].E.Field2 = FF;
roomrec[165].E.Field3 = FL;
roomrec[165].E.Field4 = FR;
roomrec[165].E.Field5 = MR;
roomrec[165].E.Field6 = CR;

roomrec[165].W.Field1 = CL; 
roomrec[165].W.Field2 = ML;
roomrec[165].W.Field3 = FF;
roomrec[165].W.Field4 = FF;
roomrec[165].W.Field5 = FF;
roomrec[165].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[166].N.Field1 = MF; 
roomrec[166].N.Field2 = ML;
roomrec[166].N.Field3 = FL;
roomrec[166].N.Field4 = FR;
roomrec[166].N.Field5 = MR;
roomrec[166].N.Field6 = MF;

roomrec[166].S.Field1 = CL; 
roomrec[166].S.Field2 = FF;
roomrec[166].S.Field3 = FF;
roomrec[166].S.Field4 = FF;
roomrec[166].S.Field5 = EMPTY;
roomrec[166].S.Field6 = EMPTY;

roomrec[166].E.Field1 = MF; 
roomrec[166].E.Field2 = ML;
roomrec[166].E.Field3 = EMPTY;
roomrec[166].E.Field4 = FR;
roomrec[166].E.Field5 = MR;
roomrec[166].E.Field6 = CR;

roomrec[166].W.Field1 = CL; 
roomrec[166].W.Field2 = ML;
roomrec[166].W.Field3 = FL;
roomrec[166].W.Field4 = EMPTY;
roomrec[166].W.Field5 = MR;
roomrec[166].W.Field6 = MF;
/**************************/  

                             /* Room : 19 */
roomrec[167].N.Field1 = EMPTY; 
roomrec[167].N.Field2 = EMPTY;
roomrec[167].N.Field3 = FF;
roomrec[167].N.Field4 = FF;
roomrec[167].N.Field5 = MR;
roomrec[167].N.Field6 = MF;

roomrec[167].S.Field1 = CL; 
roomrec[167].S.Field2 = FF;
roomrec[167].S.Field3 = FF;
roomrec[167].S.Field4 = FF;
roomrec[167].S.Field5 = EMPTY;
roomrec[167].S.Field6 = EMPTY;

roomrec[167].E.Field1 = CL; 
roomrec[167].E.Field2 = FF;
roomrec[167].E.Field3 = FL;
roomrec[167].E.Field4 = FR;
roomrec[167].E.Field5 = MR;
roomrec[167].E.Field6 = CR;

roomrec[167].W.Field1 = CL; 
roomrec[167].W.Field2 = ML;
roomrec[167].W.Field3 = FL;
roomrec[167].W.Field4 = FR;
roomrec[167].W.Field5 = FF;
roomrec[167].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[168].N.Field1 = MF; 
roomrec[168].N.Field2 = ML;
roomrec[168].N.Field3 = FL;
roomrec[168].N.Field4 = FR;
roomrec[168].N.Field5 = MR;
roomrec[168].N.Field6 = MF;

roomrec[168].S.Field1 = CL; 
roomrec[168].S.Field2 = FF;
roomrec[168].S.Field3 = FF;
roomrec[168].S.Field4 = FF;
roomrec[168].S.Field5 = EMPTY;
roomrec[168].S.Field6 = EMPTY;

roomrec[168].E.Field1 = MF; 
roomrec[168].E.Field2 = ML;
roomrec[168].E.Field3 = FF;
roomrec[168].E.Field4 = FF;
roomrec[168].E.Field5 = FF;
roomrec[168].E.Field6 = CR;

roomrec[168].W.Field1 = CL; 
roomrec[168].W.Field2 = ML;
roomrec[168].W.Field3 = FL;
roomrec[168].W.Field4 = EMPTY;
roomrec[168].W.Field5 = MR;
roomrec[168].W.Field6 = MF;
/**************************/  

                             /* Room : 19 */
roomrec[169].N.Field1 = EMPTY; 
roomrec[169].N.Field2 = EMPTY;
roomrec[169].N.Field3 = FF;
roomrec[169].N.Field4 = FF;
roomrec[169].N.Field5 = MR;
roomrec[169].N.Field6 = MF;

roomrec[169].S.Field1 = CL; 
roomrec[169].S.Field2 = ML;
roomrec[169].S.Field3 = FL;
roomrec[169].S.Field4 = FR;
roomrec[169].S.Field5 = MR;
roomrec[169].S.Field6 = MF;

roomrec[169].E.Field1 = MF; 
roomrec[169].E.Field2 = ML;
roomrec[169].E.Field3 = EMPTY;
roomrec[169].E.Field4 = EMPTY;
roomrec[169].E.Field5 = MR;
roomrec[169].E.Field6 = CR;

roomrec[169].W.Field1 = MF; 
roomrec[169].W.Field2 = ML;
roomrec[169].W.Field3 = FL;
roomrec[169].W.Field4 = FR;
roomrec[169].W.Field5 = FF;
roomrec[169].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[170].N.Field1 = CL; 
roomrec[170].N.Field2 = ML;
roomrec[170].N.Field3 = FL;
roomrec[170].N.Field4 = EMPTY;
roomrec[170].N.Field5 = EMPTY;
roomrec[170].N.Field6 = CR;

roomrec[170].S.Field1 = CL; 
roomrec[170].S.Field2 = ML;
roomrec[170].S.Field3 = FL;
roomrec[170].S.Field4 = FR;
roomrec[170].S.Field5 = MR;
roomrec[170].S.Field6 = CR;

roomrec[170].E.Field1 = MF; 
roomrec[170].E.Field2 = ML;
roomrec[170].E.Field3 = EMPTY;
roomrec[170].E.Field4 = EMPTY;
roomrec[170].E.Field5 = MR;
roomrec[170].E.Field6 = CR;

roomrec[170].W.Field1 = CL; 
roomrec[170].W.Field2 = FF;
roomrec[170].W.Field3 = FF;
roomrec[170].W.Field4 = FF;
roomrec[170].W.Field5 = FF;
roomrec[170].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[171].N.Field1 = CL; 
roomrec[171].N.Field2 = FF;
roomrec[171].N.Field3 = FL;
roomrec[171].N.Field4 = FR;
roomrec[171].N.Field5 = MR;
roomrec[171].N.Field6 = MF;

roomrec[171].S.Field1 = CL; 
roomrec[171].S.Field2 = FF;
roomrec[171].S.Field3 = FF;
roomrec[171].S.Field4 = FF;
roomrec[171].S.Field5 = EMPTY;
roomrec[171].S.Field6 = EMPTY;

roomrec[171].E.Field1 = MF; 
roomrec[171].E.Field2 = ML;
roomrec[171].E.Field3 = FL;
roomrec[171].E.Field4 = FR;
roomrec[171].E.Field5 = MR;
roomrec[171].E.Field6 = CR;

roomrec[171].W.Field1 = CL; 
roomrec[171].W.Field2 = FF;
roomrec[171].W.Field3 = FF;
roomrec[171].W.Field4 = FF;
roomrec[171].W.Field5 = FF;
roomrec[171].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[172].N.Field1 = EMPTY; 
roomrec[172].N.Field2 = EMPTY;
roomrec[172].N.Field3 = FF;
roomrec[172].N.Field4 = FF;
roomrec[172].N.Field5 = MR;
roomrec[172].N.Field6 = MF;

roomrec[172].S.Field1 = CL; 
roomrec[172].S.Field2 = FF;
roomrec[172].S.Field3 = FF;
roomrec[172].S.Field4 = FF;
roomrec[172].S.Field5 = EMPTY;
roomrec[172].S.Field6 = EMPTY;

roomrec[172].E.Field1 = CL; 
roomrec[172].E.Field2 = ML;
roomrec[172].E.Field3 = FL;
roomrec[172].E.Field4 = EMPTY;
roomrec[172].E.Field5 = MR;
roomrec[172].E.Field6 = CR;

roomrec[172].W.Field1 = CL; 
roomrec[172].W.Field2 = ML;
roomrec[172].W.Field3 = FF;
roomrec[172].W.Field4 = FF;
roomrec[172].W.Field5 = EMPTY;
roomrec[172].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[173].N.Field1 = EMPTY; 
roomrec[173].N.Field2 = EMPTY;
roomrec[173].N.Field3 = FF;
roomrec[173].N.Field4 = FF;
roomrec[173].N.Field5 = MR;
roomrec[173].N.Field6 = MF;

roomrec[173].S.Field1 = CL; 
roomrec[173].S.Field2 = FF;
roomrec[173].S.Field3 = FF;
roomrec[173].S.Field4 = FF;
roomrec[173].S.Field5 = EMPTY;
roomrec[173].S.Field6 = EMPTY;

roomrec[173].E.Field1 = CL; 
roomrec[173].E.Field2 = ML;
roomrec[173].E.Field3 = EMPTY;
roomrec[173].E.Field4 = EMPTY;
roomrec[173].E.Field5 = EMPTY;
roomrec[173].E.Field6 = CR;

roomrec[173].W.Field1 = CL; 
roomrec[173].W.Field2 = ML;
roomrec[173].W.Field3 = FL;
roomrec[173].W.Field4 = EMPTY;
roomrec[173].W.Field5 = MR;
roomrec[173].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[174].N.Field1 = EMPTY; 
roomrec[174].N.Field2 = EMPTY;
roomrec[174].N.Field3 = FF;
roomrec[174].N.Field4 = FF;
roomrec[174].N.Field5 = MR;
roomrec[174].N.Field6 = MF;

roomrec[174].S.Field1 = FF; 
roomrec[174].S.Field2 = FF;
roomrec[174].S.Field3 = FL;
roomrec[174].S.Field4 = FR;
roomrec[174].S.Field5 = MR;
roomrec[174].S.Field6 = MF;

roomrec[174].E.Field1 = CL; 
roomrec[174].E.Field2 = FF;
roomrec[174].E.Field3 = FF;
roomrec[174].E.Field4 = FF;
roomrec[174].E.Field5 = EMPTY;
roomrec[174].E.Field6 = EMPTY;

roomrec[174].W.Field1 = MF; 
roomrec[174].W.Field2 = ML;
roomrec[174].W.Field3 = FL;
roomrec[174].W.Field4 = FR;
roomrec[174].W.Field5 = MR;
roomrec[174].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[175].N.Field1 = MF; 
roomrec[175].N.Field2 = ML;
roomrec[175].N.Field3 = FL;
roomrec[175].N.Field4 = FR;
roomrec[175].N.Field5 = MR;
roomrec[175].N.Field6 = CR;

roomrec[175].S.Field1 = CL; 
roomrec[175].S.Field2 = FF;
roomrec[175].S.Field3 = FF;
roomrec[175].S.Field4 = FF;
roomrec[175].S.Field5 = EMPTY;
roomrec[175].S.Field6 = EMPTY;

roomrec[175].E.Field1 = MF; 
roomrec[175].E.Field2 = ML;
roomrec[175].E.Field3 = EMPTY;
roomrec[175].E.Field4 = EMPTY;
roomrec[175].E.Field5 = MR;
roomrec[175].E.Field6 = CR;

roomrec[175].W.Field1 = FF; 
roomrec[175].W.Field2 = FF;
roomrec[175].W.Field3 = FL;
roomrec[175].W.Field4 = FR;
roomrec[175].W.Field5 = MR;
roomrec[175].W.Field6 = MF;
/**************************/  

                             /* Room : 19 */
roomrec[176].N.Field1 = EMPTY; 
roomrec[176].N.Field2 = EMPTY;
roomrec[176].N.Field3 = FF;
roomrec[176].N.Field4 = FF;
roomrec[176].N.Field5 = MR;
roomrec[176].N.Field6 = MF;

roomrec[176].S.Field1 = CL; 
roomrec[176].S.Field2 = FF;
roomrec[176].S.Field3 = FF;
roomrec[176].S.Field4 = FF;
roomrec[176].S.Field5 = EMPTY;
roomrec[176].S.Field6 = EMPTY;

roomrec[176].E.Field1 = CL; 
roomrec[176].E.Field2 = EMPTY;
roomrec[176].E.Field3 = EMPTY;
roomrec[176].E.Field4 = EMPTY;
roomrec[176].E.Field5 = MR;
roomrec[176].E.Field6 = CR;

roomrec[176].W.Field1 = CL; 
roomrec[176].W.Field2 = FF;
roomrec[176].W.Field3 = FF;
roomrec[176].W.Field4 = FF;
roomrec[176].W.Field5 = FF;
roomrec[176].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[177].N.Field1 = MF; 
roomrec[177].N.Field2 = ML;
roomrec[177].N.Field3 = FF;
roomrec[177].N.Field4 = FF;
roomrec[177].N.Field5 = FF;
roomrec[177].N.Field6 = FF;

roomrec[177].S.Field1 = CL; 
roomrec[177].S.Field2 = FF;
roomrec[177].S.Field3 = FF;
roomrec[177].S.Field4 = FF;
roomrec[177].S.Field5 = EMPTY;
roomrec[177].S.Field6 = EMPTY;

roomrec[177].E.Field1 = FF; 
roomrec[177].E.Field2 = FF;
roomrec[177].E.Field3 = FL;
roomrec[177].E.Field4 = EMPTY;
roomrec[177].E.Field5 = EMPTY;
roomrec[177].E.Field6 = CR;

roomrec[177].W.Field1 = CL; 
roomrec[177].W.Field2 = ML;
roomrec[177].W.Field3 = FF;
roomrec[177].W.Field4 = FF;
roomrec[177].W.Field5 = MR;
roomrec[177].W.Field6 = MF;
/**************************/  

                             /* Room : 19 */
roomrec[178].N.Field1 = FF; 
roomrec[178].N.Field2 = FF;
roomrec[178].N.Field3 = FF;
roomrec[178].N.Field4 = FF;
roomrec[178].N.Field5 = MR;
roomrec[178].N.Field6 = MF;

roomrec[178].S.Field1 = FF; 
roomrec[178].S.Field2 = FF;
roomrec[178].S.Field3 = FF;
roomrec[178].S.Field4 = FF;
roomrec[178].S.Field5 = MR;
roomrec[178].S.Field6 = MF;

roomrec[178].E.Field1 = MF; 
roomrec[178].E.Field2 = ML;
roomrec[178].E.Field3 = EMPTY;
roomrec[178].E.Field4 = EMPTY;
roomrec[178].E.Field5 = FR;
roomrec[178].E.Field6 = FF;

roomrec[178].W.Field1 = MF; 
roomrec[178].W.Field2 = ML;
roomrec[178].W.Field3 = FL;
roomrec[178].W.Field4 = FR;
roomrec[178].W.Field5 = FF;
roomrec[178].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[179].N.Field1 = EMPTY; 
roomrec[179].N.Field2 = EMPTY;
roomrec[179].N.Field3 = FF;
roomrec[179].N.Field4 = FF;
roomrec[179].N.Field5 = MR;
roomrec[179].N.Field6 = MF;

roomrec[179].S.Field1 = MF; 
roomrec[179].S.Field2 = ML;
roomrec[179].S.Field3 = EMPTY;
roomrec[179].S.Field4 = FR;
roomrec[179].S.Field5 = FF;
roomrec[179].S.Field6 = FF;

roomrec[179].E.Field1 = CL; 
roomrec[179].E.Field2 = FF;
roomrec[179].E.Field3 = FF;
roomrec[179].E.Field4 = FF;
roomrec[179].E.Field5 = MR;
roomrec[179].E.Field6 = MF;

roomrec[179].W.Field1 = FF; 
roomrec[179].W.Field2 = FF;
roomrec[179].W.Field3 = FL;
roomrec[179].W.Field4 = EMPTY;
roomrec[179].W.Field5 = EMPTY;
roomrec[179].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[180].N.Field1 = MF; 
roomrec[180].N.Field2 = ML;
roomrec[180].N.Field3 = EMPTY;
roomrec[180].N.Field4 = FR;
roomrec[180].N.Field5 = MR;
roomrec[180].N.Field6 = CR;

roomrec[180].S.Field1 = CL; 
roomrec[180].S.Field2 = FF;
roomrec[180].S.Field3 = FF;
roomrec[180].S.Field4 = FF;
roomrec[180].S.Field5 = EMPTY;
roomrec[180].S.Field6 = EMPTY;

roomrec[180].E.Field1 = MF; 
roomrec[180].E.Field2 = ML;
roomrec[180].E.Field3 = EMPTY;
roomrec[180].E.Field4 = EMPTY;
roomrec[180].E.Field5 = MR;
roomrec[180].E.Field6 = CR;

roomrec[180].W.Field1 = CL; 
roomrec[180].W.Field2 = EMPTY;
roomrec[180].W.Field3 = EMPTY;
roomrec[180].W.Field4 = EMPTY;
roomrec[180].W.Field5 = MR;
roomrec[180].W.Field6 = MF;
/**************************/  

                             /* Room : 19 */
roomrec[181].N.Field1 = CL; 
roomrec[181].N.Field2 = EMPTY;
roomrec[181].N.Field3 = FF;
roomrec[181].N.Field4 = FF;
roomrec[181].N.Field5 = MR;
roomrec[181].N.Field6 = CR;

roomrec[181].S.Field1 = CL; 
roomrec[181].S.Field2 = ML;
roomrec[181].S.Field3 = FL;
roomrec[181].S.Field4 = FR;
roomrec[181].S.Field5 = MR;
roomrec[181].S.Field6 = CR;

roomrec[181].E.Field1 = MF; 
roomrec[181].E.Field2 = ML;
roomrec[181].E.Field3 = EMPTY;
roomrec[181].E.Field4 = EMPTY;
roomrec[181].E.Field5 = MR;
roomrec[181].E.Field6 = CR;

roomrec[181].W.Field1 = CL; 
roomrec[181].W.Field2 = FF;
roomrec[181].W.Field3 = FF;
roomrec[181].W.Field4 = FF;
roomrec[181].W.Field5 = FF;
roomrec[181].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[182].N.Field1 = CL; 
roomrec[182].N.Field2 = ML;
roomrec[182].N.Field3 = FL;
roomrec[182].N.Field4 = EMPTY;
roomrec[182].N.Field5 = MR;
roomrec[182].N.Field6 = CR;

roomrec[182].S.Field1 = CL; 
roomrec[182].S.Field2 = ML;
roomrec[182].S.Field3 = EMPTY;
roomrec[182].S.Field4 = FR;
roomrec[182].S.Field5 = MR;
roomrec[182].S.Field6 = CR;

roomrec[182].E.Field1 = MF; 
roomrec[182].E.Field2 = ML;
roomrec[182].E.Field3 = EMPTY;
roomrec[182].E.Field4 = EMPTY;
roomrec[182].E.Field5 = MR;
roomrec[182].E.Field6 = CR;

roomrec[182].W.Field1 = CL; 
roomrec[182].W.Field2 = FF;
roomrec[182].W.Field3 = FF;
roomrec[182].W.Field4 = FF;
roomrec[182].W.Field5 = FF;
roomrec[182].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[183].N.Field1 = CL; 
roomrec[183].N.Field2 = FF;
roomrec[183].N.Field3 = FF;
roomrec[183].N.Field4 = FF;
roomrec[183].N.Field5 = EMPTY;
roomrec[183].N.Field6 = EMPTY;

roomrec[183].S.Field1 = MF; 
roomrec[183].S.Field2 = ML;
roomrec[183].S.Field3 = FL;
roomrec[183].S.Field4 = FR;
roomrec[183].S.Field5 = MR;
roomrec[183].S.Field6 = CR;

roomrec[183].E.Field1 = FF; 
roomrec[183].E.Field2 = FF;
roomrec[183].E.Field3 = FL;
roomrec[183].E.Field4 = FR;
roomrec[183].E.Field5 = MR;
roomrec[183].E.Field6 = MF;

roomrec[183].W.Field1 = CL; 
roomrec[183].W.Field2 = FF;
roomrec[183].W.Field3 = FF;
roomrec[183].W.Field4 = FF;
roomrec[183].W.Field5 = FF;
roomrec[183].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[184].N.Field1 = FF; 
roomrec[184].N.Field2 = FF;
roomrec[184].N.Field3 = FL;
roomrec[184].N.Field4 = FR;
roomrec[184].N.Field5 = MR;
roomrec[184].N.Field6 = MF;

roomrec[184].S.Field1 = CL; 
roomrec[184].S.Field2 = FF;
roomrec[184].S.Field3 = FF;
roomrec[184].S.Field4 = FF;
roomrec[184].S.Field5 = EMPTY;
roomrec[184].S.Field6 = EMPTY;

roomrec[184].E.Field1 = MF; 
roomrec[184].E.Field2 = ML;
roomrec[184].E.Field3 = FL;
roomrec[184].E.Field4 = FR;
roomrec[184].E.Field5 = MR;
roomrec[184].E.Field6 = CR;

roomrec[184].W.Field1 = CL; 
roomrec[184].W.Field2 = FF;
roomrec[184].W.Field3 = FF;
roomrec[184].W.Field4 = FF;
roomrec[184].W.Field5 = EMPTY;
roomrec[184].W.Field6 = EMPTY;
/**************************/  

                             /* Room : 19 */
roomrec[185].N.Field1 = EMPTY; 
roomrec[185].N.Field2 = EMPTY;
roomrec[185].N.Field3 = FF;
roomrec[185].N.Field4 = FF;
roomrec[185].N.Field5 = MR;
roomrec[185].N.Field6 = MF;

roomrec[185].S.Field1 = CL; 
roomrec[185].S.Field2 = FF;
roomrec[185].S.Field3 = FF;
roomrec[185].S.Field4 = FF;
roomrec[185].S.Field5 = EMPTY;
roomrec[185].S.Field6 = EMPTY;

roomrec[185].E.Field1 = CL; 
roomrec[185].E.Field2 = ML;
roomrec[185].E.Field3 = FL;
roomrec[185].E.Field4 = FR;
roomrec[185].E.Field5 = MR;
roomrec[185].E.Field6 = CR;

roomrec[185].W.Field1 = CL; 
roomrec[185].W.Field2 = ML;
roomrec[185].W.Field3 = EMPTY;
roomrec[185].W.Field4 = EMPTY;
roomrec[185].W.Field5 = EMPTY;
roomrec[185].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[186].N.Field1 = EMPTY; 
roomrec[186].N.Field2 = EMPTY;
roomrec[186].N.Field3 = FF;
roomrec[186].N.Field4 = FF;
roomrec[186].N.Field5 = MR;
roomrec[186].N.Field6 = MF;

roomrec[186].S.Field1 = CL; 
roomrec[186].S.Field2 = FF;
roomrec[186].S.Field3 = FF;
roomrec[186].S.Field4 = FF;
roomrec[186].S.Field5 = EMPTY;
roomrec[186].S.Field6 = EMPTY;

roomrec[186].E.Field1 = CL; 
roomrec[186].E.Field2 = ML;
roomrec[186].E.Field3 = FL;
roomrec[186].E.Field4 = EMPTY;
roomrec[186].E.Field5 = MR;
roomrec[186].E.Field6 = CR;

roomrec[186].W.Field1 = CL; 
roomrec[186].W.Field2 = ML;
roomrec[186].W.Field3 = FL;
roomrec[186].W.Field4 = EMPTY;
roomrec[186].W.Field5 = MR;
roomrec[186].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[187].N.Field1 = EMPTY; 
roomrec[187].N.Field2 = EMPTY;
roomrec[187].N.Field3 = FF;
roomrec[187].N.Field4 = FF;
roomrec[187].N.Field5 = MR;
roomrec[187].N.Field6 = MF;

roomrec[187].S.Field1 = CL; 
roomrec[187].S.Field2 = FF;
roomrec[187].S.Field3 = FF;
roomrec[187].S.Field4 = FF;
roomrec[187].S.Field5 = EMPTY;
roomrec[187].S.Field6 = EMPTY;

roomrec[187].E.Field1 = CL; 
roomrec[187].E.Field2 = ML;
roomrec[187].E.Field3 = FF;
roomrec[187].E.Field4 = FF;
roomrec[187].E.Field5 = FF;
roomrec[187].E.Field6 = CR;

roomrec[187].W.Field1 = CL; 
roomrec[187].W.Field2 = ML;
roomrec[187].W.Field3 = FL;
roomrec[187].W.Field4 = FR;
roomrec[187].W.Field5 = MR;
roomrec[187].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[188].N.Field1 = EMPTY; 
roomrec[188].N.Field2 = EMPTY;
roomrec[188].N.Field3 = FF;
roomrec[188].N.Field4 = FF;
roomrec[188].N.Field5 = MR;
roomrec[188].N.Field6 = MF;

roomrec[188].S.Field1 = CL; 
roomrec[188].S.Field2 = ML;
roomrec[188].S.Field3 = EMPTY;
roomrec[188].S.Field4 = EMPTY;
roomrec[188].S.Field5 = MR;
roomrec[188].S.Field6 = MF;

roomrec[188].E.Field1 = MF; 
roomrec[188].E.Field2 = ML;
roomrec[188].E.Field3 = EMPTY;
roomrec[188].E.Field4 = EMPTY;
roomrec[188].E.Field5 = MR;
roomrec[188].E.Field6 = CR;

roomrec[188].W.Field1 = MF; 
roomrec[188].W.Field2 = ML;
roomrec[188].W.Field3 = FL;
roomrec[188].W.Field4 = FR;
roomrec[188].W.Field5 = MR;
roomrec[188].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[189].N.Field1 = CL; 
roomrec[189].N.Field2 = EMPTY;
roomrec[189].N.Field3 = EMPTY;
roomrec[189].N.Field4 = FR;
roomrec[189].N.Field5 = FF;
roomrec[189].N.Field6 = FF;

roomrec[189].S.Field1 = CL; 
roomrec[189].S.Field2 = FF;
roomrec[189].S.Field3 = FF;
roomrec[189].S.Field4 = FF;
roomrec[189].S.Field5 = EMPTY;
roomrec[189].S.Field6 = EMPTY;

roomrec[189].E.Field1 = EMPTY; 
roomrec[189].E.Field2 = FF;
roomrec[189].E.Field3 = FF;
roomrec[189].E.Field4 = FF;
roomrec[189].E.Field5 = EMPTY;
roomrec[189].E.Field6 = CR;

roomrec[189].W.Field1 = CL; 
roomrec[189].W.Field2 = FF;
roomrec[189].W.Field3 = FF;
roomrec[189].W.Field4 = FF;
roomrec[189].W.Field5 = FF;
roomrec[189].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[190].N.Field1 = EMPTY; 
roomrec[190].N.Field2 = FF;
roomrec[190].N.Field3 = FF;
roomrec[190].N.Field4 = FF;
roomrec[190].N.Field5 = EMPTY;
roomrec[190].N.Field6 = CR;

roomrec[190].S.Field1 = CL; 
roomrec[190].S.Field2 = EMPTY;
roomrec[190].S.Field3 = EMPTY;
roomrec[190].S.Field4 = EMPTY;
roomrec[190].S.Field5 = MR;
roomrec[190].S.Field6 = MF;

roomrec[190].E.Field1 = MF; 
roomrec[190].E.Field2 = ML;
roomrec[190].E.Field3 = EMPTY;
roomrec[190].E.Field4 = EMPTY;
roomrec[190].E.Field5 = MR;
roomrec[190].E.Field6 = CR;

roomrec[190].W.Field1 = MF; 
roomrec[190].W.Field2 = ML;
roomrec[190].W.Field3 = FF;
roomrec[190].W.Field4 = FF;
roomrec[190].W.Field5 = EMPTY;
roomrec[190].W.Field6 = EMPTY;
/**************************/  

                             /* Room : 19 */
roomrec[191].N.Field1 = CL; 
roomrec[191].N.Field2 = ML;
roomrec[191].N.Field3 = EMPTY;
roomrec[191].N.Field4 = FR;
roomrec[191].N.Field5 = MR;
roomrec[191].N.Field6 = CR;

roomrec[191].S.Field1 = CL; 
roomrec[191].S.Field2 = ML;
roomrec[191].S.Field3 = FL;
roomrec[191].S.Field4 = FR;
roomrec[191].S.Field5 = MR;
roomrec[191].S.Field6 = CR;

roomrec[191].E.Field1 = MF; 
roomrec[191].E.Field2 = ML;
roomrec[191].E.Field3 = EMPTY;
roomrec[191].E.Field4 = EMPTY;
roomrec[191].E.Field5 = MR;
roomrec[191].E.Field6 = CR;

roomrec[191].W.Field1 = CL; 
roomrec[191].W.Field2 = FF;
roomrec[191].W.Field3 = FF;
roomrec[191].W.Field4 = FF;
roomrec[191].W.Field5 = FF;
roomrec[191].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[192].N.Field1 = CL; 
roomrec[192].N.Field2 = ML;
roomrec[192].N.Field3 = FL;
roomrec[192].N.Field4 = FR;
roomrec[192].N.Field5 = MR;
roomrec[192].N.Field6 = CR;

roomrec[192].S.Field1 = CL; 
roomrec[192].S.Field2 = FF;
roomrec[192].S.Field3 = FL;
roomrec[192].S.Field4 = FR;
roomrec[192].S.Field5 = MR;
roomrec[192].S.Field6 = CR;

roomrec[192].E.Field1 = MF; 
roomrec[192].E.Field2 = ML;
roomrec[192].E.Field3 = EMPTY;
roomrec[192].E.Field4 = EMPTY;
roomrec[192].E.Field5 = MR;
roomrec[192].E.Field6 = CR;

roomrec[192].W.Field1 = CL; 
roomrec[192].W.Field2 = FF;
roomrec[192].W.Field3 = FF;
roomrec[192].W.Field4 = FF;
roomrec[192].W.Field5 = FF;
roomrec[192].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[193].N.Field1 = CL; 
roomrec[193].N.Field2 = ML;
roomrec[193].N.Field3 = EMPTY;
roomrec[193].N.Field4 = EMPTY;
roomrec[193].N.Field5 = EMPTY;
roomrec[193].N.Field6 = CR;

roomrec[193].S.Field1 = CL; 
roomrec[193].S.Field2 = ML;
roomrec[193].S.Field3 = FF;
roomrec[193].S.Field4 = FF;
roomrec[193].S.Field5 = FF;
roomrec[193].S.Field6 = CR;

roomrec[193].E.Field1 = MF; 
roomrec[193].E.Field2 = ML;
roomrec[193].E.Field3 = EMPTY;
roomrec[193].E.Field4 = EMPTY;
roomrec[193].E.Field5 = MR;
roomrec[193].E.Field6 = CR;

roomrec[193].W.Field1 = CL; 
roomrec[193].W.Field2 = FF;
roomrec[193].W.Field3 = FF;
roomrec[193].W.Field4 = FF;
roomrec[193].W.Field5 = FF;
roomrec[193].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[194].N.Field1 = CL; 
roomrec[194].N.Field2 = FF;
roomrec[194].N.Field3 = FF;
roomrec[194].N.Field4 = FF;
roomrec[194].N.Field5 = MR;
roomrec[194].N.Field6 = CR;

roomrec[194].S.Field1 = CL; 
roomrec[194].S.Field2 = FF;
roomrec[194].S.Field3 = FF;
roomrec[194].S.Field4 = FF;
roomrec[194].S.Field5 = FF;
roomrec[194].S.Field6 = CR;

roomrec[194].E.Field1 = MF; 
roomrec[194].E.Field2 = ML;
roomrec[194].E.Field3 = EMPTY;
roomrec[194].E.Field4 = EMPTY;
roomrec[194].E.Field5 = MR;
roomrec[194].E.Field6 = CR;

roomrec[194].W.Field1 = CL; 
roomrec[194].W.Field2 = FF;
roomrec[194].W.Field3 = FF;
roomrec[194].W.Field4 = FF;
roomrec[194].W.Field5 = FF;
roomrec[194].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[195].N.Field1 = CL; 
roomrec[195].N.Field2 = EMPTY;
roomrec[195].N.Field3 = EMPTY;
roomrec[195].N.Field4 = EMPTY;
roomrec[195].N.Field5 = MR;
roomrec[195].N.Field6 = MF;

roomrec[195].S.Field1 = EMPTY; 
roomrec[195].S.Field2 = FF;
roomrec[195].S.Field3 = FF;
roomrec[195].S.Field4 = FF;
roomrec[195].S.Field5 = FF;
roomrec[195].S.Field6 = CR;

roomrec[195].E.Field1 = MF; 
roomrec[195].E.Field2 = ML;
roomrec[195].E.Field3 = FF;
roomrec[195].E.Field4 = FF;
roomrec[195].E.Field5 = FF;
roomrec[195].E.Field6 = FF;

roomrec[195].W.Field1 = CL; 
roomrec[195].W.Field2 = FF;
roomrec[195].W.Field3 = FF;
roomrec[195].W.Field4 = FF;
roomrec[195].W.Field5 = FF;
roomrec[195].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[196].N.Field1 = EMPTY; 
roomrec[196].N.Field2 = EMPTY;
roomrec[196].N.Field3 = FF;
roomrec[196].N.Field4 = FF;
roomrec[196].N.Field5 = MR;
roomrec[196].N.Field6 = MF;

roomrec[196].S.Field1 = CL; 
roomrec[196].S.Field2 = ML;
roomrec[196].S.Field3 = FL;
roomrec[196].S.Field4 = FR;
roomrec[196].S.Field5 = FF;
roomrec[196].S.Field6 = FF;

roomrec[196].E.Field1 = EMPTY; 
roomrec[196].E.Field2 = FF;
roomrec[196].E.Field3 = FF;
roomrec[196].E.Field4 = FF;
roomrec[196].E.Field5 = EMPTY;
roomrec[196].E.Field6 = CR;

roomrec[196].W.Field1 = EMPTY; 
roomrec[196].W.Field2 = FF;
roomrec[196].W.Field3 = FF;
roomrec[196].W.Field4 = FF;
roomrec[196].W.Field5 = EMPTY;
roomrec[196].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[197].N.Field1 = CL; 
roomrec[197].N.Field2 = ML;
roomrec[197].N.Field3 = FL;
roomrec[197].N.Field4 = FR;
roomrec[197].N.Field5 = MR;
roomrec[197].N.Field6 = CR;

roomrec[197].S.Field1 = CL; 
roomrec[197].S.Field2 = ML;
roomrec[197].S.Field3 = FL;
roomrec[197].S.Field4 = FR;
roomrec[197].S.Field5 = MR;
roomrec[197].S.Field6 = CR;

roomrec[197].E.Field1 = MF; 
roomrec[197].E.Field2 = ML;
roomrec[197].E.Field3 = EMPTY;
roomrec[197].E.Field4 = EMPTY;
roomrec[197].E.Field5 = MR;
roomrec[197].E.Field6 = CR;

roomrec[197].W.Field1 = CL; 
roomrec[197].W.Field2 = FF;
roomrec[197].W.Field3 = FF;
roomrec[197].W.Field4 = FF;
roomrec[197].W.Field5 = FF;
roomrec[197].W.Field6 = FF;
/**************************/  


                             /* Room : 19 */
roomrec[198].N.Field1 = CL; 
roomrec[198].N.Field2 = ML;
roomrec[198].N.Field3 = FL;
roomrec[198].N.Field4 = FR;
roomrec[198].N.Field5 = MR;
roomrec[198].N.Field6 = MF;

roomrec[198].S.Field1 = MF; 
roomrec[198].S.Field2 = ML;
roomrec[198].S.Field3 = FL;
roomrec[198].S.Field4 = FR;
roomrec[198].S.Field5 = MR;
roomrec[198].S.Field6 = CR;

roomrec[198].E.Field1 = MF; 
roomrec[198].E.Field2 = ML;
roomrec[198].E.Field3 = FL;
roomrec[198].E.Field4 = FR;
roomrec[198].E.Field5 = MR;
roomrec[198].E.Field6 = MF;

roomrec[198].W.Field1 = CL; 
roomrec[198].W.Field2 = FF;
roomrec[198].W.Field3 = FF;
roomrec[198].W.Field4 = FF;
roomrec[198].W.Field5 = FF;
roomrec[198].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[199].N.Field1 = CL; 
roomrec[199].N.Field2 = ML;
roomrec[199].N.Field3 = FL;
roomrec[199].N.Field4 = FR;
roomrec[199].N.Field5 = MR;
roomrec[199].N.Field6 = CR;

roomrec[199].S.Field1 = CL; 
roomrec[199].S.Field2 = ML;
roomrec[199].S.Field3 = FL;
roomrec[199].S.Field4 = FR;
roomrec[199].S.Field5 = MR;
roomrec[199].S.Field6 = CR;

roomrec[199].E.Field1 = CL; 
roomrec[199].E.Field2 = ML;
roomrec[199].E.Field3 = FL;
roomrec[199].E.Field4 = FR;
roomrec[199].E.Field5 = MR;
roomrec[199].E.Field6 = CR;

roomrec[199].W.Field1 = CL; 
roomrec[199].W.Field2 = FF;
roomrec[199].W.Field3 = FF;
roomrec[199].W.Field4 = FF;
roomrec[199].W.Field5 = FF;
roomrec[199].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[200].N.Field1 = CL; 
roomrec[200].N.Field2 = ML;
roomrec[200].N.Field3 = FL;
roomrec[200].N.Field4 = FR;
roomrec[200].N.Field5 = MR;
roomrec[200].N.Field6 = CR;

roomrec[200].S.Field1 = CL; 
roomrec[200].S.Field2 = ML;
roomrec[200].S.Field3 = FL;
roomrec[200].S.Field4 = FR;
roomrec[200].S.Field5 = MR;
roomrec[200].S.Field6 = CR;

roomrec[200].E.Field1 = CL; 
roomrec[200].E.Field2 = ML;
roomrec[200].E.Field3 = FL;
roomrec[200].E.Field4 = FR;
roomrec[200].E.Field5 = MR;
roomrec[200].E.Field6 = CR;

roomrec[200].W.Field1 = CL; 
roomrec[200].W.Field2 = ML;
roomrec[200].W.Field3 = EMPTY;
roomrec[200].W.Field4 = EMPTY;
roomrec[200].W.Field5 = MR;
roomrec[200].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[201].N.Field1 = CL; 
roomrec[201].N.Field2 = ML;
roomrec[201].N.Field3 = FL;
roomrec[201].N.Field4 = FR;
roomrec[201].N.Field5 = MR;
roomrec[201].N.Field6 = CR;

roomrec[201].S.Field1 = CL; 
roomrec[201].S.Field2 = ML;
roomrec[201].S.Field3 = FL;
roomrec[201].S.Field4 = FR;
roomrec[201].S.Field5 = MR;
roomrec[201].S.Field6 = CR;

roomrec[201].E.Field1 = CL; 
roomrec[201].E.Field2 = ML;
roomrec[201].E.Field3 = FL;
roomrec[201].E.Field4 = FR;
roomrec[201].E.Field5 = MR;
roomrec[201].E.Field6 = CR;

roomrec[201].W.Field1 = CL; 
roomrec[201].W.Field2 = ML;
roomrec[201].W.Field3 = FL;
roomrec[201].W.Field4 = FR;
roomrec[201].W.Field5 = MR;
roomrec[201].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[202].N.Field1 = CL; 
roomrec[202].N.Field2 = ML;
roomrec[202].N.Field3 = FL;
roomrec[202].N.Field4 = FR;
roomrec[202].N.Field5 = MR;
roomrec[202].N.Field6 = CR;

roomrec[202].S.Field1 = CL; 
roomrec[202].S.Field2 = ML;
roomrec[202].S.Field3 = FL;
roomrec[202].S.Field4 = FR;
roomrec[202].S.Field5 = MR;
roomrec[202].S.Field6 = CR;

roomrec[202].E.Field1 = CL; 
roomrec[202].E.Field2 = ML;
roomrec[202].E.Field3 = EMPTY;
roomrec[202].E.Field4 = FR;
roomrec[202].E.Field5 = MR;
roomrec[202].E.Field6 = CR;

roomrec[202].W.Field1 = CL; 
roomrec[202].W.Field2 = ML;
roomrec[202].W.Field3 = FL;
roomrec[202].W.Field4 = FR;
roomrec[202].W.Field5 = MR;
roomrec[202].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[203].N.Field1 = CL; 
roomrec[203].N.Field2 = ML;
roomrec[203].N.Field3 = FL;
roomrec[203].N.Field4 = FR;
roomrec[203].N.Field5 = MR;
roomrec[203].N.Field6 = CR;

roomrec[203].S.Field1 = CL; 
roomrec[203].S.Field2 = ML;
roomrec[203].S.Field3 = FL;
roomrec[203].S.Field4 = FR;
roomrec[203].S.Field5 = MR;
roomrec[203].S.Field6 = CR;

roomrec[203].E.Field1 = CL; 
roomrec[203].E.Field2 = FF;
roomrec[203].E.Field3 = FF;
roomrec[203].E.Field4 = FF;
roomrec[203].E.Field5 = MR;
roomrec[203].E.Field6 = CR;

roomrec[203].W.Field1 = CL; 
roomrec[203].W.Field2 = ML;
roomrec[203].W.Field3 = FL;
roomrec[203].W.Field4 = FR;
roomrec[203].W.Field5 = MR;
roomrec[203].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[204].N.Field1 = MF; 
roomrec[204].N.Field2 = ML;
roomrec[204].N.Field3 = FL;
roomrec[204].N.Field4 = EMPTY;
roomrec[204].N.Field5 = MR;
roomrec[204].N.Field6 = CR;

roomrec[204].S.Field1 = CL; 
roomrec[204].S.Field2 = ML;
roomrec[204].S.Field3 = FL;
roomrec[204].S.Field4 = FR;
roomrec[204].S.Field5 = MR;
roomrec[204].S.Field6 = CR;

roomrec[204].E.Field1 = CL; 
roomrec[204].E.Field2 = ML;
roomrec[204].E.Field3 = FL;
roomrec[204].E.Field4 = FR;
roomrec[204].E.Field5 = MR;
roomrec[204].E.Field6 = CR;

roomrec[204].W.Field1 = CL; 
roomrec[204].W.Field2 = ML;
roomrec[204].W.Field3 = FL;
roomrec[204].W.Field4 = FR;
roomrec[204].W.Field5 = MR;
roomrec[204].W.Field6 = MF;
/**************************/  

                             /* Room : 19 */
roomrec[205].N.Field1 = CL; 
roomrec[205].N.Field2 = ML;
roomrec[205].N.Field3 = FL;
roomrec[205].N.Field4 = FR;
roomrec[205].N.Field5 = MR;
roomrec[205].N.Field6 = CR;

roomrec[205].S.Field1 = MF; 
roomrec[205].S.Field2 = ML;
roomrec[205].S.Field3 = FL;
roomrec[205].S.Field4 = FR;
roomrec[205].S.Field5 = MR;
roomrec[205].S.Field6 = CR;

roomrec[205].E.Field1 = CL; 
roomrec[205].E.Field2 = ML;
roomrec[205].E.Field3 = EMPTY;
roomrec[205].E.Field4 = FR;
roomrec[205].E.Field5 = MR;
roomrec[205].E.Field6 = MF;

roomrec[205].W.Field1 = CL; 
roomrec[205].W.Field2 = FF;
roomrec[205].W.Field3 = FF;
roomrec[205].W.Field4 = FF;
roomrec[205].W.Field5 = FF;
roomrec[205].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[206].N.Field1 = CL; 
roomrec[206].N.Field2 = ML;
roomrec[206].N.Field3 = FL;
roomrec[206].N.Field4 = FR;
roomrec[206].N.Field5 = MR;
roomrec[206].N.Field6 = CR;

roomrec[206].S.Field1 = CL; 
roomrec[206].S.Field2 = ML;
roomrec[206].S.Field3 = FL;
roomrec[206].S.Field4 = FR;
roomrec[206].S.Field5 = MR;
roomrec[206].S.Field6 = CR;

roomrec[206].E.Field1 = CL; 
roomrec[206].E.Field2 = FF;
roomrec[206].E.Field3 = FL;
roomrec[206].E.Field4 = FR;
roomrec[206].E.Field5 = MR;
roomrec[206].E.Field6 = CR;

roomrec[206].W.Field1 = CL; 
roomrec[206].W.Field2 = FF;
roomrec[206].W.Field3 = FF;
roomrec[206].W.Field4 = FF;
roomrec[206].W.Field5 = MR;
roomrec[206].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[207].N.Field1 = MF; 
roomrec[207].N.Field2 = ML;
roomrec[207].N.Field3 = EMPTY;
roomrec[207].N.Field4 = FR;
roomrec[207].N.Field5 = MR;
roomrec[207].N.Field6 = MF;

roomrec[207].S.Field1 = CL; 
roomrec[207].S.Field2 = ML;
roomrec[207].S.Field3 = FL;
roomrec[207].S.Field4 = FR;
roomrec[207].S.Field5 = MR;
roomrec[207].S.Field6 = CR;

roomrec[207].E.Field1 = MF; 
roomrec[207].E.Field2 = ML;
roomrec[207].E.Field3 = FL;
roomrec[207].E.Field4 = FR;
roomrec[207].E.Field5 = MR;
roomrec[207].E.Field6 = CR;

roomrec[207].W.Field1 = CL; 
roomrec[207].W.Field2 = ML;
roomrec[207].W.Field3 = EMPTY;
roomrec[207].W.Field4 = FR;
roomrec[207].W.Field5 = MR;
roomrec[207].W.Field6 = MF;
/**************************/  

                             /* Room : 19 */
roomrec[208].N.Field1 = CL; 
roomrec[208].N.Field2 = ML;
roomrec[208].N.Field3 = FL;
roomrec[208].N.Field4 = FR;
roomrec[208].N.Field5 = MR;
roomrec[208].N.Field6 = CR;

roomrec[208].S.Field1 = CL; 
roomrec[208].S.Field2 = ML;
roomrec[208].S.Field3 = FL;
roomrec[208].S.Field4 = FR;
roomrec[208].S.Field5 = MR;
roomrec[208].S.Field6 = CR;

roomrec[208].E.Field1 = CL; 
roomrec[208].E.Field2 = ML;
roomrec[208].E.Field3 = EMPTY;
roomrec[208].E.Field4 = FR;
roomrec[208].E.Field5 = MR;
roomrec[208].E.Field6 = CR;

roomrec[208].W.Field1 = CL; 
roomrec[208].W.Field2 = ML;
roomrec[208].W.Field3 = FL;
roomrec[208].W.Field4 = FR;
roomrec[208].W.Field5 = FF;
roomrec[208].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[209].N.Field1 = CL; 
roomrec[209].N.Field2 = ML;
roomrec[209].N.Field3 = FL;
roomrec[209].N.Field4 = FR;
roomrec[209].N.Field5 = MR;
roomrec[209].N.Field6 = CR;

roomrec[209].S.Field1 = CL; 
roomrec[209].S.Field2 = ML;
roomrec[209].S.Field3 = FL;
roomrec[209].S.Field4 = FR;
roomrec[209].S.Field5 = MR;
roomrec[209].S.Field6 = CR;

roomrec[209].E.Field1 = CL; 
roomrec[209].E.Field2 = EMPTY;
roomrec[209].E.Field3 = EMPTY;
roomrec[209].E.Field4 = EMPTY;
roomrec[209].E.Field5 = MR;
roomrec[209].E.Field6 = CR;

roomrec[209].W.Field1 = CL; 
roomrec[209].W.Field2 = ML;
roomrec[209].W.Field3 = FL;
roomrec[209].W.Field4 = EMPTY;
roomrec[209].W.Field5 = MR;
roomrec[209].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[210].N.Field1 = MF; 
roomrec[210].N.Field2 = ML;
roomrec[210].N.Field3 = EMPTY;
roomrec[210].N.Field4 = EMPTY;
roomrec[210].N.Field5 = EMPTY;
roomrec[210].N.Field6 = EMPTY;

roomrec[210].S.Field1 = CL; 
roomrec[210].S.Field2 = ML;
roomrec[210].S.Field3 = FL;
roomrec[210].S.Field4 = FR;
roomrec[210].S.Field5 = MR;
roomrec[210].S.Field6 = CR;

roomrec[210].E.Field1 = FF; 
roomrec[210].E.Field2 = FF;
roomrec[210].E.Field3 = FF;
roomrec[210].E.Field4 = FF;
roomrec[210].E.Field5 = FF;
roomrec[210].E.Field6 = CR;

roomrec[210].W.Field1 = CL; 
roomrec[210].W.Field2 = ML;
roomrec[210].W.Field3 = FL;
roomrec[210].W.Field4 = FR;
roomrec[210].W.Field5 = MR;
roomrec[210].W.Field6 = MF;
/**************************/  

                             /* Room : 19 */
roomrec[211].N.Field1 = EMPTY; 
roomrec[211].N.Field2 = FF;
roomrec[211].N.Field3 = FF;
roomrec[211].N.Field4 = FF;
roomrec[211].N.Field5 = MR;
roomrec[211].N.Field6 = CR;

roomrec[211].S.Field1 = CL; 
roomrec[211].S.Field2 = ML;
roomrec[211].S.Field3 = FL;
roomrec[211].S.Field4 = FR;
roomrec[211].S.Field5 = MR;
roomrec[211].S.Field6 = MF;

roomrec[211].E.Field1 = CL; 
roomrec[211].E.Field2 = ML;
roomrec[211].E.Field3 = FL;
roomrec[211].E.Field4 = FR;
roomrec[211].E.Field5 = MR;
roomrec[211].E.Field6 = CR;

roomrec[211].W.Field1 = MF; 
roomrec[211].W.Field2 = ML;
roomrec[211].W.Field3 = FL;
roomrec[211].W.Field4 = FR;
roomrec[211].W.Field5 = FF;
roomrec[211].W.Field6 = FF;
/**************************/  

                             /* Room : 19 */
roomrec[212].N.Field1 = CL; 
roomrec[212].N.Field2 = ML;
roomrec[212].N.Field3 = FL;
roomrec[212].N.Field4 = FR;
roomrec[212].N.Field5 = MR;
roomrec[212].N.Field6 = CR;

roomrec[212].S.Field1 = CL; 
roomrec[212].S.Field2 = ML;
roomrec[212].S.Field3 = EMPTY;
roomrec[212].S.Field4 = FR;
roomrec[212].S.Field5 = MR;
roomrec[212].S.Field6 = CR;

roomrec[212].E.Field1 = CL; 
roomrec[212].E.Field2 = ML;
roomrec[212].E.Field3 = FL;
roomrec[212].E.Field4 = FR;
roomrec[212].E.Field5 = MR;
roomrec[212].E.Field6 = CR;

roomrec[212].W.Field1 = CL; 
roomrec[212].W.Field2 = FF;
roomrec[212].W.Field3 = FF;
roomrec[212].W.Field4 = FF;
roomrec[212].W.Field5 = FF;
roomrec[212].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[213].N.Field1 = CL; 
roomrec[213].N.Field2 = ML;
roomrec[213].N.Field3 = FL;
roomrec[213].N.Field4 = FR;
roomrec[213].N.Field5 = FF;
roomrec[213].N.Field6 = CR;

roomrec[213].S.Field1 = CL; 
roomrec[213].S.Field2 = ML;
roomrec[213].S.Field3 = FL;
roomrec[213].S.Field4 = EMPTY;
roomrec[213].S.Field5 = MR;
roomrec[213].S.Field6 = CR;

roomrec[213].E.Field1 = CL; 
roomrec[213].E.Field2 = ML;
roomrec[213].E.Field3 = FL;
roomrec[213].E.Field4 = FR;
roomrec[213].E.Field5 = MR;
roomrec[213].E.Field6 = CR;

roomrec[213].W.Field1 = CL; 
roomrec[213].W.Field2 = FF;
roomrec[213].W.Field3 = FF;
roomrec[213].W.Field4 = FF;
roomrec[213].W.Field5 = FF;
roomrec[213].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[214].N.Field1 = CL; 
roomrec[214].N.Field2 = ML;
roomrec[214].N.Field3 = FF;
roomrec[214].N.Field4 = FF;
roomrec[214].N.Field5 = FF;
roomrec[214].N.Field6 = CR;

roomrec[214].S.Field1 = CL; 
roomrec[214].S.Field2 = ML;
roomrec[214].S.Field3 = FL;
roomrec[214].S.Field4 = FR;
roomrec[214].S.Field5 = MR;
roomrec[214].S.Field6 = CR;

roomrec[214].E.Field1 = CL; 
roomrec[214].E.Field2 = ML;
roomrec[214].E.Field3 = FL;
roomrec[214].E.Field4 = FR;
roomrec[214].E.Field5 = MR;
roomrec[214].E.Field6 = CR;

roomrec[214].W.Field1 = CL; 
roomrec[214].W.Field2 = FF;
roomrec[214].W.Field3 = FF;
roomrec[214].W.Field4 = FF;
roomrec[214].W.Field5 = FF;
roomrec[214].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[215].N.Field1 = CL; 
roomrec[215].N.Field2 = EMPTY;
roomrec[215].N.Field3 = EMPTY;
roomrec[215].N.Field4 = FR;
roomrec[215].N.Field5 = MR;
roomrec[215].N.Field6 = CR;

roomrec[215].S.Field1 = CL; 
roomrec[215].S.Field2 = ML;
roomrec[215].S.Field3 = FL;
roomrec[215].S.Field4 = FR;
roomrec[215].S.Field5 = MR;
roomrec[215].S.Field6 = CR;

roomrec[215].E.Field1 = CL; 
roomrec[215].E.Field2 = ML;
roomrec[215].E.Field3 = FL;
roomrec[215].E.Field4 = FR;
roomrec[215].E.Field5 = MR;
roomrec[215].E.Field6 = CR;

roomrec[215].W.Field1 = CL; 
roomrec[215].W.Field2 = FF;
roomrec[215].W.Field3 = FF;
roomrec[215].W.Field4 = FF;
roomrec[215].W.Field5 = FF;
roomrec[215].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[216].N.Field1 = CL; 
roomrec[216].N.Field2 = ML;
roomrec[216].N.Field3 = FL;
roomrec[216].N.Field4 = FR;
roomrec[216].N.Field5 = MR;
roomrec[216].N.Field6 = CR;

roomrec[216].S.Field1 = CL; 
roomrec[216].S.Field2 = FF;
roomrec[216].S.Field3 = FL;
roomrec[216].S.Field4 = EMPTY;
roomrec[216].S.Field5 = MR;
roomrec[216].S.Field6 = CR;

roomrec[216].E.Field1 = CL; 
roomrec[216].E.Field2 = ML;
roomrec[216].E.Field3 = FL;
roomrec[216].E.Field4 = FR;
roomrec[216].E.Field5 = MR;
roomrec[216].E.Field6 = CR;

roomrec[216].W.Field1 = CL; 
roomrec[216].W.Field2 = FF;
roomrec[216].W.Field3 = FF;
roomrec[216].W.Field4 = FF;
roomrec[216].W.Field5 = FF;
roomrec[216].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[217].N.Field1 = CL; 
roomrec[217].N.Field2 = ML;
roomrec[217].N.Field3 = FL;
roomrec[217].N.Field4 = EMPTY;
roomrec[217].N.Field5 = MR;
roomrec[217].N.Field6 = CR;

roomrec[217].S.Field1 = CL; 
roomrec[217].S.Field2 = ML;
roomrec[217].S.Field3 = FL;
roomrec[217].S.Field4 = FR;
roomrec[217].S.Field5 = FF;
roomrec[217].S.Field6 = CR;

roomrec[217].E.Field1 = CL; 
roomrec[217].E.Field2 = ML;
roomrec[217].E.Field3 = FL;
roomrec[217].E.Field4 = FR;
roomrec[217].E.Field5 = MR;
roomrec[217].E.Field6 = CR;

roomrec[217].W.Field1 = CL; 
roomrec[217].W.Field2 = FF;
roomrec[217].W.Field3 = FF;
roomrec[217].W.Field4 = FF;
roomrec[217].W.Field5 = FF;
roomrec[217].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[218].N.Field1 = CL; 
roomrec[218].N.Field2 = ML;
roomrec[218].N.Field3 = FL;
roomrec[218].N.Field4 = EMPTY;
roomrec[218].N.Field5 = MR;
roomrec[218].N.Field6 = CR;

roomrec[218].S.Field1 = CL; 
roomrec[218].S.Field2 = ML;
roomrec[218].S.Field3 = FL;
roomrec[218].S.Field4 = FR;
roomrec[218].S.Field5 = MR;
roomrec[218].S.Field6 = CR;

roomrec[218].E.Field1 = CL; 
roomrec[218].E.Field2 = ML;
roomrec[218].E.Field3 = FL;
roomrec[218].E.Field4 = FR;
roomrec[218].E.Field5 = MR;
roomrec[218].E.Field6 = CR;

roomrec[218].W.Field1 = CL; 
roomrec[218].W.Field2 = FF;
roomrec[218].W.Field3 = FF;
roomrec[218].W.Field4 = FF;
roomrec[218].W.Field5 = FF;
roomrec[218].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[219].N.Field1 = CL; 
roomrec[219].N.Field2 = ML;
roomrec[219].N.Field3 = EMPTY;
roomrec[219].N.Field4 = FR;
roomrec[219].N.Field5 = MR;
roomrec[219].N.Field6 = CR;

roomrec[219].S.Field1 = CL; 
roomrec[219].S.Field2 = ML;
roomrec[219].S.Field3 = FL;
roomrec[219].S.Field4 = FR;
roomrec[219].S.Field5 = MR;
roomrec[219].S.Field6 = CR;

roomrec[219].E.Field1 = CL; 
roomrec[219].E.Field2 = ML;
roomrec[219].E.Field3 = FL;
roomrec[219].E.Field4 = FR;
roomrec[219].E.Field5 = MR;
roomrec[219].E.Field6 = CR;

roomrec[219].W.Field1 = CL; 
roomrec[219].W.Field2 = FF;
roomrec[219].W.Field3 = FF;
roomrec[219].W.Field4 = FF;
roomrec[219].W.Field5 = FF;
roomrec[219].W.Field6 = CR;
/**************************/  


                             /* Room : 19 */
roomrec[220].N.Field1 = CL; 
roomrec[220].N.Field2 = ML;
roomrec[220].N.Field3 = FL;
roomrec[220].N.Field4 = FR;
roomrec[220].N.Field5 = MR;
roomrec[220].N.Field6 = MF;

roomrec[220].S.Field1 = MF; 
roomrec[220].S.Field2 = ML;
roomrec[220].S.Field3 = EMPTY;
roomrec[220].S.Field4 = EMPTY;
roomrec[220].S.Field5 = EMPTY;
roomrec[220].S.Field6 = CR;

roomrec[220].E.Field1 = MF; 
roomrec[220].E.Field2 = ML;
roomrec[220].E.Field3 = EMPTY;
roomrec[220].E.Field4 = EMPTY;
roomrec[220].E.Field5 = MR;
roomrec[220].E.Field6 = MF;

roomrec[220].W.Field1 = CL; 
roomrec[220].W.Field2 = FF;
roomrec[220].W.Field3 = FF;
roomrec[220].W.Field4 = FF;
roomrec[220].W.Field5 = FF;
roomrec[220].W.Field6 = CR;
/**************************/  


                             /* Room : 19 */
roomrec[221].N.Field1 = CL; 
roomrec[221].N.Field2 = ML;
roomrec[221].N.Field3 = EMPTY;
roomrec[221].N.Field4 = FR;
roomrec[221].N.Field5 = MR;
roomrec[221].N.Field6 = CR;

roomrec[221].S.Field1 = CL; 
roomrec[221].S.Field2 = ML;
roomrec[221].S.Field3 = FL;
roomrec[221].S.Field4 = FR;
roomrec[221].S.Field5 = MR;
roomrec[221].S.Field6 = CR;

roomrec[221].E.Field1 = CL; 
roomrec[221].E.Field2 = FF;
roomrec[221].E.Field3 = FF;
roomrec[221].E.Field4 = FF;
roomrec[221].E.Field5 = FF;
roomrec[221].E.Field6 = CR;

roomrec[221].W.Field1 = CL; 
roomrec[221].W.Field2 = FF;
roomrec[221].W.Field3 = FF;
roomrec[221].W.Field4 = FF;
roomrec[221].W.Field5 = FF;
roomrec[221].W.Field6 = CR;
/**************************/  


                             /* Room : 19 */
roomrec[222].N.Field1 = MF; 
roomrec[222].N.Field2 = ML;
roomrec[222].N.Field3 = FL;
roomrec[222].N.Field4 = FR;
roomrec[222].N.Field5 = MR;
roomrec[222].N.Field6 = CR;

roomrec[222].S.Field1 = CL; 
roomrec[222].S.Field2 = ML;
roomrec[222].S.Field3 = FL;
roomrec[222].S.Field4 = EMPTY;
roomrec[222].S.Field5 = MR;
roomrec[222].S.Field6 = MF;

roomrec[222].E.Field1 = CL; 
roomrec[222].E.Field2 = ML;
roomrec[222].E.Field3 = FL;
roomrec[222].E.Field4 = FR;
roomrec[222].E.Field5 = MR;
roomrec[222].E.Field6 = CR;

roomrec[222].W.Field1 = MF; 
roomrec[222].W.Field2 = ML;
roomrec[222].W.Field3 = EMPTY;
roomrec[222].W.Field4 = EMPTY;
roomrec[222].W.Field5 = MR;
roomrec[222].W.Field6 = MF;
/**************************/  


                             /* Room : 19 */
roomrec[223].N.Field1 = CL; 
roomrec[223].N.Field2 = ML;
roomrec[223].N.Field3 = FL;
roomrec[223].N.Field4 = FR;
roomrec[223].N.Field5 = MR;
roomrec[223].N.Field6 = CR;

roomrec[223].S.Field1 = CL; 
roomrec[223].S.Field2 = ML;
roomrec[223].S.Field3 = FL;
roomrec[223].S.Field4 = EMPTY;
roomrec[223].S.Field5 = MR;
roomrec[223].S.Field6 = CR;

roomrec[223].E.Field1 = CL; 
roomrec[223].E.Field2 = ML;
roomrec[223].E.Field3 = FL;
roomrec[223].E.Field4 = FR;
roomrec[223].E.Field5 = MR;
roomrec[223].E.Field6 = CR;

roomrec[223].W.Field1 = CL; 
roomrec[223].W.Field2 = FF;
roomrec[223].W.Field3 = FF;
roomrec[223].W.Field4 = FF;
roomrec[223].W.Field5 = FF;
roomrec[223].W.Field6 = CR;
/**************************/  


                             /* Room : 19 */
roomrec[224].N.Field1 = CL; 
roomrec[224].N.Field2 = ML;
roomrec[224].N.Field3 = FL;
roomrec[224].N.Field4 = FR;
roomrec[224].N.Field5 = MR;
roomrec[224].N.Field6 = CR;

roomrec[224].S.Field1 = CL; 
roomrec[224].S.Field2 = ML;
roomrec[224].S.Field3 = FL;
roomrec[224].S.Field4 = FR;
roomrec[224].S.Field5 = MR;
roomrec[224].S.Field6 = CR;

roomrec[224].E.Field1 = CL; 
roomrec[224].E.Field2 = ML;
roomrec[224].E.Field3 = FL;
roomrec[224].E.Field4 = FR;
roomrec[224].E.Field5 = MR;
roomrec[224].E.Field6 = CR;

roomrec[224].W.Field1 = CL; 
roomrec[224].W.Field2 = FF;
roomrec[224].W.Field3 = FF;
roomrec[224].W.Field4 = FF;
roomrec[224].W.Field5 = FF;
roomrec[224].W.Field6 = CR;
/**************************/  


                             /* Room : 19 */
roomrec[225].N.Field1 = CL; 
roomrec[225].N.Field2 = ML;
roomrec[225].N.Field3 = EMPTY;
roomrec[225].N.Field4 = FR;
roomrec[225].N.Field5 = MR;
roomrec[225].N.Field6 = CR;

roomrec[225].S.Field1 = FF; 
roomrec[225].S.Field2 = FF;
roomrec[225].S.Field3 = FF;
roomrec[225].S.Field4 = FF;
roomrec[225].S.Field5 = MR;
roomrec[225].S.Field6 = CR;

roomrec[225].E.Field1 = CL; 
roomrec[225].E.Field2 = ML;
roomrec[225].E.Field3 = EMPTY;
roomrec[225].E.Field4 = EMPTY;
roomrec[225].E.Field5 = EMPTY;
roomrec[225].E.Field6 = EMPTY;

roomrec[225].W.Field1 = CL; 
roomrec[225].W.Field2 = FF;
roomrec[225].W.Field3 = FF;
roomrec[225].W.Field4 = FF;
roomrec[225].W.Field5 = FF;
roomrec[225].W.Field6 = CR;
/**************************/  


                             /* Room : 19 */
roomrec[226].N.Field1 = CL; 
roomrec[226].N.Field2 = ML;
roomrec[226].N.Field3 = EMPTY;
roomrec[226].N.Field4 = FR;
roomrec[226].N.Field5 = MR;
roomrec[226].N.Field6 = CR;

roomrec[226].S.Field1 = FF; 
roomrec[226].S.Field2 = FF;
roomrec[226].S.Field3 = FF;
roomrec[226].S.Field4 = FF;
roomrec[226].S.Field5 = FF;
roomrec[226].S.Field6 = FF;

roomrec[226].E.Field1 = CL; 
roomrec[226].E.Field2 = EMPTY;
roomrec[226].E.Field3 = FF;
roomrec[226].E.Field4 = FF;
roomrec[226].E.Field5 = EMPTY;
roomrec[226].E.Field6 = EMPTY;

roomrec[226].W.Field1 = FF; 
roomrec[226].W.Field2 = FF;
roomrec[226].W.Field3 = FF;
roomrec[226].W.Field4 = FF;
roomrec[226].W.Field5 = MR;
roomrec[226].W.Field6 = CR;
/**************************/  


                             /* Room : 19 */
roomrec[227].N.Field1 = MF; 
roomrec[227].N.Field2 = ML;
roomrec[227].N.Field3 = FL;
roomrec[227].N.Field4 = FR;
roomrec[227].N.Field5 = FF;
roomrec[227].N.Field6 = CR;

roomrec[227].S.Field1 = CL; 
roomrec[227].S.Field2 = FF;
roomrec[227].S.Field3 = FF;
roomrec[227].S.Field4 = FF;
roomrec[227].S.Field5 = FF;
roomrec[227].S.Field6 = FF;

roomrec[227].E.Field1 = CL; 
roomrec[227].E.Field2 = ML;
roomrec[227].E.Field3 = FL;
roomrec[227].E.Field4 = FR;
roomrec[227].E.Field5 = MR;
roomrec[227].E.Field6 = CR;

roomrec[227].W.Field1 = EMPTY; 
roomrec[227].W.Field2 = EMPTY;
roomrec[227].W.Field3 = EMPTY;
roomrec[227].W.Field4 = FR;
roomrec[227].W.Field5 = MR;
roomrec[227].W.Field6 = MF;
/**************************/  


                             /* Room : 19 */
roomrec[228].N.Field1 = CL; 
roomrec[228].N.Field2 = FF;
roomrec[228].N.Field3 = FL;
roomrec[228].N.Field4 = FR;
roomrec[228].N.Field5 = MR;
roomrec[228].N.Field6 = CR;

roomrec[228].S.Field1 = CL; 
roomrec[228].S.Field2 = FF;
roomrec[228].S.Field3 = FF;
roomrec[228].S.Field4 = FF;
roomrec[228].S.Field5 = FF;
roomrec[228].S.Field6 = CR;

roomrec[228].E.Field1 = CL; 
roomrec[228].E.Field2 = ML;
roomrec[228].E.Field3 = FL;
roomrec[228].E.Field4 = FR;
roomrec[228].E.Field5 = MR;
roomrec[228].E.Field6 = CR;

roomrec[228].W.Field1 = CL; 
roomrec[228].W.Field2 = FF;
roomrec[228].W.Field3 = FF;
roomrec[228].W.Field4 = FF;
roomrec[228].W.Field5 = FF;
roomrec[228].W.Field6 = CR;
/**************************/  


                             /* Room : 19 */
roomrec[229].N.Field1 = CL; 
roomrec[229].N.Field2 = ML;
roomrec[229].N.Field3 = FL;
roomrec[229].N.Field4 = FR;
roomrec[229].N.Field5 = MR;
roomrec[229].N.Field6 = CR;

roomrec[229].S.Field1 = CL; 
roomrec[229].S.Field2 = ML;
roomrec[229].S.Field3 = FF;
roomrec[229].S.Field4 = FF;
roomrec[229].S.Field5 = FF;
roomrec[229].S.Field6 = CR;

roomrec[229].E.Field1 = CL; 
roomrec[229].E.Field2 = ML;
roomrec[229].E.Field3 = FL;
roomrec[229].E.Field4 = FR;
roomrec[229].E.Field5 = MR;
roomrec[229].E.Field6 = CR;

roomrec[229].W.Field1 = CL; 
roomrec[229].W.Field2 = FF;
roomrec[229].W.Field3 = FF;
roomrec[229].W.Field4 = FF;
roomrec[229].W.Field5 = FF;
roomrec[229].W.Field6 = CR;
/**************************/  


                             /* Room : 19 */
roomrec[230].N.Field1 = CL; 
roomrec[230].N.Field2 = ML;
roomrec[230].N.Field3 = FL;
roomrec[230].N.Field4 = FR;
roomrec[230].N.Field5 = MR;
roomrec[230].N.Field6 = CR;

roomrec[230].S.Field1 = CL; 
roomrec[230].S.Field2 = ML;
roomrec[230].S.Field3 = FL;
roomrec[230].S.Field4 = FR;
roomrec[230].S.Field5 = MR;
roomrec[230].S.Field6 = CR;

roomrec[230].E.Field1 = CL; 
roomrec[230].E.Field2 = ML;
roomrec[230].E.Field3 = FL;
roomrec[230].E.Field4 = FR;
roomrec[230].E.Field5 = MR;
roomrec[230].E.Field6 = CR;

roomrec[230].W.Field1 = CL; 
roomrec[230].W.Field2 = FF;
roomrec[230].W.Field3 = FF;
roomrec[230].W.Field4 = FF;
roomrec[230].W.Field5 = FF;
roomrec[230].W.Field6 = CR;
/**************************/  


                             /* Room : 19 */
roomrec[231].N.Field1 = CL; 
roomrec[231].N.Field2 = ML;
roomrec[231].N.Field3 = FF;
roomrec[231].N.Field4 = FF;
roomrec[231].N.Field5 = FF;
roomrec[231].N.Field6 = FF;

roomrec[231].S.Field1 = CL; 
roomrec[231].S.Field2 = ML;
roomrec[231].S.Field3 = FL;
roomrec[231].S.Field4 = FR;
roomrec[231].S.Field5 = MR;
roomrec[231].S.Field6 = CR;

roomrec[231].E.Field1 = EMPTY; 
roomrec[231].E.Field2 = EMPTY;
roomrec[231].E.Field3 = EMPTY;
roomrec[231].E.Field4 = FR;
roomrec[231].E.Field5 = MR;
roomrec[231].E.Field6 = CR;

roomrec[231].W.Field1 = CL; 
roomrec[231].W.Field2 = FF;
roomrec[231].W.Field3 = FF;
roomrec[231].W.Field4 = FF;
roomrec[231].W.Field5 = FF;
roomrec[231].W.Field6 = CR;
/**************************/  


                             /* Room : 19 */
roomrec[232].N.Field1 = FF; 
roomrec[232].N.Field2 = FF;
roomrec[232].N.Field3 = FF;
roomrec[232].N.Field4 = FF;
roomrec[232].N.Field5 = FF;
roomrec[232].N.Field6 = EMPTY;

roomrec[232].S.Field1 = CL; 
roomrec[232].S.Field2 = ML;
roomrec[232].S.Field3 = FL;
roomrec[232].S.Field4 = FR;
roomrec[232].S.Field5 = MR;
roomrec[232].S.Field6 = CR;

roomrec[232].E.Field1 = FF; 
roomrec[232].E.Field2 = FF;
roomrec[232].E.Field3 = FL;
roomrec[232].E.Field4 = FR;
roomrec[232].E.Field5 = MR;
roomrec[232].E.Field6 = CR;

roomrec[232].W.Field1 = CL; 
roomrec[232].W.Field2 = ML;
roomrec[232].W.Field3 = FF;
roomrec[232].W.Field4 = FF;
roomrec[232].W.Field5 = FF;
roomrec[232].W.Field6 = FF;
/**************************/  


                             /* Room : 19 */
roomrec[233].N.Field1 = FF; 
roomrec[233].N.Field2 = FF;
roomrec[233].N.Field3 = FL;
roomrec[233].N.Field4 = EMPTY;
roomrec[233].N.Field5 = MR;
roomrec[233].N.Field6 = MF;

roomrec[233].S.Field1 = CL; 
roomrec[233].S.Field2 = ML;
roomrec[233].S.Field3 = FL;
roomrec[233].S.Field4 = FR;
roomrec[233].S.Field5 = MR;
roomrec[233].S.Field6 = CR;

roomrec[233].E.Field1 = MF; 
roomrec[233].E.Field2 = ML;
roomrec[233].E.Field3 = EMPTY;
roomrec[233].E.Field4 = FR;
roomrec[233].E.Field5 = MR;
roomrec[233].E.Field6 = CR;

roomrec[233].W.Field1 = CL; 
roomrec[233].W.Field2 = ML;
roomrec[233].W.Field3 = FL;
roomrec[233].W.Field4 = EMPTY;
roomrec[233].W.Field5 = EMPTY;
roomrec[233].W.Field6 = EMPTY;
/**************************/  


                             /* Room : 19 */
roomrec[234].N.Field1 = CL; 
roomrec[234].N.Field2 = ML;
roomrec[234].N.Field3 = EMPTY;
roomrec[234].N.Field4 = FR;
roomrec[234].N.Field5 = MR;
roomrec[234].N.Field6 = CR;

roomrec[234].S.Field1 = CL; 
roomrec[234].S.Field2 = ML;
roomrec[234].S.Field3 = FL;
roomrec[234].S.Field4 = FR;
roomrec[234].S.Field5 = MR;
roomrec[234].S.Field6 = CR;

roomrec[234].E.Field1 = CL; 
roomrec[234].E.Field2 = FF;
roomrec[234].E.Field3 = FL;
roomrec[234].E.Field4 = FR;
roomrec[234].E.Field5 = MR;
roomrec[234].E.Field6 = CR;

roomrec[234].W.Field1 = CL; 
roomrec[234].W.Field2 = ML;
roomrec[234].W.Field3 = FL;
roomrec[234].W.Field4 = EMPTY;
roomrec[234].W.Field5 = EMPTY;
roomrec[234].W.Field6 = CR;
/**************************/  


                             /* Room : 19 */
roomrec[235].N.Field1 = MF; 
roomrec[235].N.Field2 = ML;
roomrec[235].N.Field3 = EMPTY;
roomrec[235].N.Field4 = FR;
roomrec[235].N.Field5 = MR;
roomrec[235].N.Field6 = MF;

roomrec[235].S.Field1 = CL; 
roomrec[235].S.Field2 = ML;
roomrec[235].S.Field3 = FL;
roomrec[235].S.Field4 = FR;
roomrec[235].S.Field5 = MR;
roomrec[235].S.Field6 = CR;

roomrec[235].E.Field1 = MF; 
roomrec[235].E.Field2 = ML;
roomrec[235].E.Field3 = FL;
roomrec[235].E.Field4 = FR;
roomrec[235].E.Field5 = MR;
roomrec[235].E.Field6 = CR;

roomrec[235].W.Field1 = CL; 
roomrec[235].W.Field2 = ML;
roomrec[235].W.Field3 = FL;
roomrec[235].W.Field4 = EMPTY;
roomrec[235].W.Field5 = MR;
roomrec[235].W.Field6 = MF;
/**************************/  


                             /* Room : 19 */
roomrec[236].N.Field1 = CL; 
roomrec[236].N.Field2 = ML;
roomrec[236].N.Field3 = EMPTY;
roomrec[236].N.Field4 = FR;
roomrec[236].N.Field5 = MR;
roomrec[236].N.Field6 = CR;

roomrec[236].S.Field1 = CL; 
roomrec[236].S.Field2 = ML;
roomrec[236].S.Field3 = FL;
roomrec[236].S.Field4 = FR;
roomrec[236].S.Field5 = MR;
roomrec[236].S.Field6 = CR;

roomrec[236].E.Field1 = CL; 
roomrec[236].E.Field2 = ML;
roomrec[236].E.Field3 = FL;
roomrec[236].E.Field4 = FR;
roomrec[236].E.Field5 = MR;
roomrec[236].E.Field6 = CR;

roomrec[236].W.Field1 = CL; 
roomrec[236].W.Field2 = ML;
roomrec[236].W.Field3 = FL;
roomrec[236].W.Field4 = FR;
roomrec[236].W.Field5 = FF;
roomrec[236].W.Field6 = CR;
/**************************/  


                             /* Room : 19 */
roomrec[237].N.Field1 = CL; 
roomrec[237].N.Field2 = ML;
roomrec[237].N.Field3 = EMPTY;
roomrec[237].N.Field4 = FR;
roomrec[237].N.Field5 = MR;
roomrec[237].N.Field6 = CR;

roomrec[237].S.Field1 = CL; 
roomrec[237].S.Field2 = ML;
roomrec[237].S.Field3 = FL;
roomrec[237].S.Field4 = FR;
roomrec[237].S.Field5 = MR;
roomrec[237].S.Field6 = CR;

roomrec[237].E.Field1 = CL; 
roomrec[237].E.Field2 = ML;
roomrec[237].E.Field3 = FL;
roomrec[237].E.Field4 = FR;
roomrec[237].E.Field5 = MR;
roomrec[237].E.Field6 = CR;

roomrec[237].W.Field1 = CL; 
roomrec[237].W.Field2 = ML;
roomrec[237].W.Field3 = FL;
roomrec[237].W.Field4 = EMPTY;
roomrec[237].W.Field5 = MR;
roomrec[237].W.Field6 = CR;
/**************************/  


                             /* Room : 19 */
roomrec[238].N.Field1 = CL; 
roomrec[238].N.Field2 = ML;
roomrec[238].N.Field3 = FL;
roomrec[238].N.Field4 = FR;
roomrec[238].N.Field5 = MR;
roomrec[238].N.Field6 = CR;

roomrec[238].S.Field1 = CL; 
roomrec[238].S.Field2 = ML;
roomrec[238].S.Field3 = FL;
roomrec[238].S.Field4 = FR;
roomrec[238].S.Field5 = MR;
roomrec[238].S.Field6 = CR;

roomrec[238].E.Field1 = CL; 
roomrec[238].E.Field2 = ML;
roomrec[238].E.Field3 = FL;
roomrec[238].E.Field4 = FR;
roomrec[238].E.Field5 = MR;
roomrec[238].E.Field6 = CR;

roomrec[238].W.Field1 = CL; 
roomrec[238].W.Field2 = ML;
roomrec[238].W.Field3 = FL;
roomrec[238].W.Field4 = FR;
roomrec[238].W.Field5 = MR;
roomrec[238].W.Field6 = CR;
/**************************/  


                             /* Room : 19 */
roomrec[239].N.Field1 = CL; 
roomrec[239].N.Field2 = ML;
roomrec[239].N.Field3 = FL;
roomrec[239].N.Field4 = FR;
roomrec[239].N.Field5 = MR;
roomrec[239].N.Field6 = CR;

roomrec[239].S.Field1 = CL; 
roomrec[239].S.Field2 = ML;
roomrec[239].S.Field3 = FL;
roomrec[239].S.Field4 = FR;
roomrec[239].S.Field5 = MR;
roomrec[239].S.Field6 = CR;

roomrec[239].E.Field1 = CL; 
roomrec[239].E.Field2 = ML;
roomrec[239].E.Field3 = FL;
roomrec[239].E.Field4 = FR;
roomrec[239].E.Field5 = MR;
roomrec[239].E.Field6 = CR;

roomrec[239].W.Field1 = CL; 
roomrec[239].W.Field2 = ML;
roomrec[239].W.Field3 = FL;
roomrec[239].W.Field4 = FR;
roomrec[239].W.Field5 = MR;
roomrec[239].W.Field6 = CR;
/**************************/  



                             /* Room : 19 */
roomrec[240].N.Field1 = CL; 
roomrec[240].N.Field2 = ML;
roomrec[240].N.Field3 = FL;
roomrec[240].N.Field4 = FR;
roomrec[240].N.Field5 = MR;
roomrec[240].N.Field6 = CR;

roomrec[240].S.Field1 = CL; 
roomrec[240].S.Field2 = ML;
roomrec[240].S.Field3 = FL;
roomrec[240].S.Field4 = FR;
roomrec[240].S.Field5 = MR;
roomrec[240].S.Field6 = CR;

roomrec[240].E.Field1 = CL; 
roomrec[240].E.Field2 = ML;
roomrec[240].E.Field3 = FL;
roomrec[240].E.Field4 = FR;
roomrec[240].E.Field5 = MR;
roomrec[240].E.Field6 = CR;

roomrec[240].W.Field1 = CL; 
roomrec[240].W.Field2 = ML;
roomrec[240].W.Field3 = FL;
roomrec[240].W.Field4 = FR;
roomrec[240].W.Field5 = MR;
roomrec[240].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[241].N.Field1 = CL; 
roomrec[241].N.Field2 = ML;
roomrec[241].N.Field3 = FL;
roomrec[241].N.Field4 = FR;
roomrec[241].N.Field5 = MR;
roomrec[241].N.Field6 = CR;

roomrec[241].S.Field1 = CL; 
roomrec[241].S.Field2 = ML;
roomrec[241].S.Field3 = FL;
roomrec[241].S.Field4 = FR;
roomrec[241].S.Field5 = MR;
roomrec[241].S.Field6 = CR;

roomrec[241].E.Field1 = CL; 
roomrec[241].E.Field2 = ML;
roomrec[241].E.Field3 = FL;
roomrec[241].E.Field4 = FR;
roomrec[241].E.Field5 = MR;
roomrec[241].E.Field6 = CR;

roomrec[241].W.Field1 = CL; 
roomrec[241].W.Field2 = ML;
roomrec[241].W.Field3 = FL;
roomrec[241].W.Field4 = FR;
roomrec[241].W.Field5 = MR;
roomrec[241].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[242].N.Field1 = CL; 
roomrec[242].N.Field2 = ML;
roomrec[242].N.Field3 = EMPTY;
roomrec[242].N.Field4 = FR;
roomrec[242].N.Field5 = MR;
roomrec[242].N.Field6 = CR;

roomrec[242].S.Field1 = CL; 
roomrec[242].S.Field2 = ML;
roomrec[242].S.Field3 = FL;
roomrec[242].S.Field4 = FR;
roomrec[242].S.Field5 = MR;
roomrec[242].S.Field6 = CR;

roomrec[242].E.Field1 = CL; 
roomrec[242].E.Field2 = ML;
roomrec[242].E.Field3 = EMPTY;
roomrec[242].E.Field4 = FR;
roomrec[242].E.Field5 = MR;
roomrec[242].E.Field6 = CR;

roomrec[242].W.Field1 = CL; 
roomrec[242].W.Field2 = ML;
roomrec[242].W.Field3 = FL;
roomrec[242].W.Field4 = FR;
roomrec[242].W.Field5 = MR;
roomrec[242].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[243].N.Field1 = CL; 
roomrec[243].N.Field2 = FF;
roomrec[243].N.Field3 = FF;
roomrec[243].N.Field4 = FR;
roomrec[243].N.Field5 = MR;
roomrec[243].N.Field6 = CR;

roomrec[243].S.Field1 = CL; 
roomrec[243].S.Field2 = ML;
roomrec[243].S.Field3 = FL;
roomrec[243].S.Field4 = FR;
roomrec[243].S.Field5 = MR;
roomrec[243].S.Field6 = CR;

roomrec[243].E.Field1 = CL; 
roomrec[243].E.Field2 = FF;
roomrec[243].E.Field3 = FF;
roomrec[243].E.Field4 = FF;
roomrec[243].E.Field5 = MR;
roomrec[243].E.Field6 = CR;

roomrec[243].W.Field1 = CL; 
roomrec[243].W.Field2 = ML;
roomrec[243].W.Field3 = FL;
roomrec[243].W.Field4 = FR;
roomrec[243].W.Field5 = MR;
roomrec[243].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[244].N.Field1 = MF; 
roomrec[244].N.Field2 = ML;
roomrec[244].N.Field3 = FL;
roomrec[244].N.Field4 = FR;
roomrec[244].N.Field5 = MR;
roomrec[244].N.Field6 = CR;

roomrec[244].S.Field1 = CL; 
roomrec[244].S.Field2 = ML;
roomrec[244].S.Field3 = FL;
roomrec[244].S.Field4 = FR;
roomrec[244].S.Field5 = MR;
roomrec[244].S.Field6 = CR;

roomrec[244].E.Field1 = CL; 
roomrec[244].E.Field2 = ML;
roomrec[244].E.Field3 = FL;
roomrec[244].E.Field4 = FR;
roomrec[244].E.Field5 = MR;
roomrec[244].E.Field6 = CR;

roomrec[244].W.Field1 = CL; 
roomrec[244].W.Field2 = ML;
roomrec[244].W.Field3 = FL;
roomrec[244].W.Field4 = FR;
roomrec[244].W.Field5 = MR;
roomrec[244].W.Field6 = MF;
/**************************/  

                             /* Room : 19 */
roomrec[245].N.Field1 = CL; 
roomrec[245].N.Field2 = ML;
roomrec[245].N.Field3 = FL;
roomrec[245].N.Field4 = FR;
roomrec[245].N.Field5 = MR;
roomrec[245].N.Field6 = CR;

roomrec[245].S.Field1 = CL; 
roomrec[245].S.Field2 = ML;
roomrec[245].S.Field3 = FL;
roomrec[245].S.Field4 = FR;
roomrec[245].S.Field5 = MR;
roomrec[245].S.Field6 = CR;

roomrec[245].E.Field1 = CL; 
roomrec[245].E.Field2 = ML;
roomrec[245].E.Field3 = FL;
roomrec[245].E.Field4 = FR;
roomrec[245].E.Field5 = MR;
roomrec[245].E.Field6 = CR;

roomrec[245].W.Field1 = CL; 
roomrec[245].W.Field2 = ML;
roomrec[245].W.Field3 = FL;
roomrec[245].W.Field4 = FR;
roomrec[245].W.Field5 = MR;
roomrec[245].W.Field6 = CR;
/**************************/  
                             /* Room : 19 */
roomrec[246].N.Field1 = CL; 
roomrec[246].N.Field2 = ML;
roomrec[246].N.Field3 = FL;
roomrec[246].N.Field4 = FR;
roomrec[246].N.Field5 = MR;
roomrec[246].N.Field6 = CR;

roomrec[246].S.Field1 = CL; 
roomrec[246].S.Field2 = ML;
roomrec[246].S.Field3 = FF;
roomrec[246].S.Field4 = FF;
roomrec[246].S.Field5 = MR;
roomrec[246].S.Field6 = CR;

roomrec[246].E.Field1 = CL; 
roomrec[246].E.Field2 = ML;
roomrec[246].E.Field3 = FL;
roomrec[246].E.Field4 = FR;
roomrec[246].E.Field5 = MR;
roomrec[246].E.Field6 = CR;

roomrec[246].W.Field1 = CL; 
roomrec[246].W.Field2 = ML;
roomrec[246].W.Field3 = FL;
roomrec[246].W.Field4 = FR;
roomrec[246].W.Field5 = MR;
roomrec[246].W.Field6 = CR;
/**************************/  

                             /* Room : 19 */
roomrec[247].N.Field1 = CL; 
roomrec[247].N.Field2 = ML;
roomrec[247].N.Field3 = FL;
roomrec[247].N.Field4 = FR;
roomrec[247].N.Field5 = MR;
roomrec[247].N.Field6 = CR;

roomrec[247].S.Field1 = CL; 
roomrec[247].S.Field2 = FF;
roomrec[247].S.Field3 = FL;
roomrec[247].S.Field4 = FR;
roomrec[247].S.Field5 = MR;
roomrec[247].S.Field6 = CR;

roomrec[247].E.Field1 = CL; 
roomrec[247].E.Field2 = ML;
roomrec[247].E.Field3 = FL;
roomrec[247].E.Field4 = FR;
roomrec[247].E.Field5 = MR;
roomrec[247].E.Field6 = CR;

roomrec[247].W.Field1 = CL; 
roomrec[247].W.Field2 = ML;
roomrec[247].W.Field3 = FL;
roomrec[247].W.Field4 = FR;
roomrec[247].W.Field5 = MR;
roomrec[247].W.Field6 = CR;
/**************************/  

}
