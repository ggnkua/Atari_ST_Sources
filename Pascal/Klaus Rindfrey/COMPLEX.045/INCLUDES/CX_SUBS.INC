{ Prozedur- und Funktionsdeklarationen fÅr COMPLEX.LIB ( bzw. CX_LIB.DBG )}


 PROCEDURE MakeComplex(VAR z : cx_adr; a,b : Real);     EXTERNAL;
{ Stellt Speicher fÅr eine komplexe Zahl zur VerfÅgung. z erhÑlt die }
{ entsprechende Adresse. a bzw. b werden dem Real- bzw ImaginÑrteil  }
{ der Zahl zugewiesen                                                }

 PROCEDURE Move(zq,zz : cx_adr);                        EXTERNAL;
{ öbertrÑgt die unter zz gespeicherte Zahl nach zz }

 PROCEDURE SetRepart(z : cx_adr; a : Real);             EXTERNAL;
{ Setzt Realteil von z gleich a. }

 PROCEDURE SetImpart(z : cx_adr; b : Real);             EXTERNAL;
{ Setzt ImaginÑrteil gleich b. }

 PROCEDURE SetComplex(z : cx_adr; a,b : Real);          EXTERNAL;
{ Setzt Real- und ImaginÑrteil. }

 PROCEDURE Konj(z,konj_z : cx_adr);                     EXTERNAL;
{ Konjungiert-Komplexe von z --> konj_z }

 PROCEDURE Negat(z,negat_z : cx_adr);                   EXTERNAL;
{ -1*z --> negat_z }

 PROCEDURE Signum(z,sgn_z : cx_adr);                    EXTERNAL;
{ Signum von z --> sgn_z  }

 FUNCTION Argument(z : cx_adr) : Real;                  EXTERNAL;
{ Argument von z }

 FUNCTION Betrag(z : cx_adr) : Real;                    EXTERNAL;
{ Betrag von z  }

 PROCEDURE PolToCart(btrg,arg : Real; z : cx_adr);      EXTERNAL;
{ Verwandelt die in Polarkoordinaten ( btrg=Betrag, arg=Argument ) gegebene }
{ Zahl in die gwîhnliche cartesische Darstellung. }

 PROCEDURE RiemannK(z : cx_adr; VAR x1,x2,x3 : Real);   EXTERNAL;
{ Berechnet die Riemannschen Koordinaten von z. }

 PROCEDURE RieToCart(x1,x2,x3 : Real; z : cx_adr);      EXTERNAL;
{ Berechnet z aus den Riemannschen Koordinaten x1,x2,x3. }

 FUNCTION Re(z : cx_adr) : Real;                        EXTERNAL;
{ Berechnet Realteil von z. }

 FUNCTION Im(z : cx_adr) : Real;                        EXTERNAL;
{ Berechnet ImaginÑrteil von z.}

 FUNCTION Equal(z1,z2 : cx_adr) : Boolean;              EXTERNAL;
{ PrÅft, ob z1=z2. }

 FUNCTION Zero(z : cx_adr) : Boolean;                   EXTERNAL;
{ PrÅft, ob z=0. }

 FUNCTION Reell(z : cx_adr) : Boolean;                  EXTERNAL;
{ PrÅft, ob z rein reell. }

 FUNCTION Imaginaer(z : cx_adr) : Boolean;              EXTERNAL;
{ PrÅft, ob z rein imaginÑr. }

 PROCEDURE Add(s1,s2,erg : cx_adr);                     EXTERNAL;
{ s1+s2 --> erg }

 PROCEDURE Subt(s1,s2,erg : cx_adr);                    EXTERNAL;
{ s1-s2 --> erg }

 PROCEDURE Mult(f1,f2,prd : cx_adr);                    EXTERNAL;
{ f1*f2 --> prd }

 PROCEDURE Divi(z,n,q : cx_adr);                        EXTERNAL;
{ z/n --> q }

 PROCEDURE Mult_i(z,iz : cx_adr);                       EXTERNAL;
{ i*z --> iz }

 PROCEDURE Divi_i(z,zdi : cx_adr);                      EXTERNAL;
{ z/i --> zdi }

 PROCEDURE Inv(z,inv_z : cx_adr);                       EXTERNAL;
{ 1/z --> inv_z }

 PROCEDURE Square(z,sq_z : cx_adr);                     EXTERNAL;
{ z hoch 2 --> sq_z }

 PROCEDURE Sq_Root(z,sr_z : cx_adr);                    EXTERNAL;
{ Wurzel z --> sr_z }

 FUNCTION Dist(z1,z2 : cx_adr) : Real;                  EXTERNAL;
{ Berechnet den Abstand zwischen z1 und z2 ( entspricht |z2-z1|) }

 PROCEDURE Cx_Exp(z,exp_z : cx_adr);                    EXTERNAL;
{ Komplexe Exponentialfunktion. Exp(z) --> exp_z. }

 PROCEDURE Cx_Ln(z,ln_z : cx_adr);                      EXTERNAL;
{ Komplexer Logarithmus. Ln(z) --> ln_z. }

 PROCEDURE Cx_Sin(z,sin_z : cx_adr);                    EXTERNAL;
{ Komplexer Sinus. }

 PROCEDURE Cx_Cos(z,cos_z : cx_adr);                    EXTERNAL;
{ Komplexer Cosinus. }

 PROCEDURE Cx_Tan(z,tan_z : cx_adr);                    EXTERNAL;
{ Komplexer Tangens. }

 PROCEDURE Cx_Sinh(z,sinh_z : cx_adr);                  EXTERNAL;
{ Komplexer Sinus Hyperbolicus. }

 PROCEDURE Cx_Cosh(z,cosh_z : cx_adr);                  EXTERNAL;
{ Komplexer Cosinus Hyperbolicus. }

 PROCEDURE Cx_Tanh(z,tanh_z : cx_adr);                  EXTERNAL;
{ Komplexer Tangens Hyperbolicus. }

 PROCEDURE Cx_ArcSin(z,arcsin_z : cx_adr);              EXTERNAL;
{ Komplexer Arcussinus. }

 PROCEDURE Cx_ArcCos(z,arccos_z : cx_adr);              EXTERNAL;
{ Komplexer Arcuscosinus. }

 PROCEDURE Cx_ArcTan(z,arctan_z : cx_adr);              EXTERNAL;
{ Komplexer Arcustangens. }

 PROCEDURE Cx_ArSinh(z,arsinh_z : cx_adr);              EXTERNAL;
{ Komplexer Areasinus. }

 PROCEDURE Cx_ArCosh(z,arcosh_z : cx_adr);              EXTERNAL;
{ Komplexer Areacosinus. }

 PROCEDURE Cx_ArTanh(z,artanh_z : cx_adr);              EXTERNAL;
{ Komplexer Areatangens. }

 PROCEDURE Add_CxVektor(VAR v1,v2,add12 : cx_vektor; n : Integer);
                                                        EXTERNAL;
{ Addition komplexer Vektoren. v1+v2 --> add12. n=LÑnge der Vektoren. }

 PROCEDURE Subt_CxVektor(VAR v1,v2,subt12 : cx_vektor; n : Integer);
                                                        EXTERNAL;
{ Subtraktion, wie oben. }

 FUNCTION Norm2_CxVekt(VAR v : cx_vektor; n : Integer) : Real;
                                                        EXTERNAL;
{ Berechnet die euklidische Norm eines komplexen Vektors. }

 PROCEDURE Cx_SkalProd(VAR v1,v2 : cx_vektor; prod12 : cx_adr;
                                                          n : Integer);
                                                        EXTERNAL;
{ Komplexes Skalarprodukt. }

 PROCEDURE Cx_AddMat(VAR m1,m2,ms : cx_mat; z,s : Integer);
                                                        EXTERNAL;
{ Addition komplexer Matrizen. z=Zeilen-, s=Spaltenanzahl. }

 PROCEDURE Cx_SubtMat(VAR m1,m2,md : cx_mat; z,s : Integer);
                                                        EXTERNAL;
{ Subtraktion, wie oben. }


 PROCEDURE Cx_MatMult(VAR m1 : cx_mat1; VAR m2 : cx_mat2; VAR mp : cx_mat3;
                                                       z1,s1z2,s2 : Integer);
                                                        EXTERNAL;

{ Oder, falls nur ein Matrixtyp benîtigt wird :    }

{PROCEDURE Cx_MatMult(VAR m1,m2,mp : cx_mat; z1,s1z2,s2 : Integer); }
{                                                       EXTERNAL;   }

{ Multiplikation komplexer Matrizen. z1=Zeilen von m1, s1z2=Spalten von m1 }
{ bzw. Zeilen von m2 (mÅssen Åbereinstimmen), s2=Spalten von m2.           }
{ mp muû genau z1 Zeilen und s2 Spalten besitzen. }

