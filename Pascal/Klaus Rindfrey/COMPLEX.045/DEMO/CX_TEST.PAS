PROGRAM ComplexTest;

CONST {$I CX_CONST.INC}

TYPE  {$I CX_TYPE.INC }

VAR z1,z2,z3,z4     : cx_adr;
    x1,x2,x3        : Real;
    v1,v2,v3        : cx_vektor;

    j,k,l           : Integer;

    m1 : cx_mat1;
    m2 : cx_mat2;
    m3 : cx_mat3;

    mat1,mat2,mat3 : cx_mat;

    fil : Text;

      {$I CX_SUBS.INC }

 PROCEDURE WriteComplex(z : cx_adr;d1,d2 : Integer);
 BEGIN
   Write(Re(z):d1:d2, ' + ', Im(z):d1:d2, ' * i')
 END; { WriteComplex }

 PROCEDURE WaitKey;
   PROCEDURE Crawcin; GEMDOS($07);
 BEGIN
   Writeln(' **** Weiter : Bitte beliebige Taste drcken. ****');
   Crawcin
 END; { WaitKey }

 PROCEDURE InitVar;
 VAR j,k : Integer;
 BEGIN
  MakeComplex(z1,1,2);                            {  MakeComplex  }
  MakeComplex(z2,0,0);
  MakeComplex(z3,0,1);
  MakeComplex(z4,0,3.14159265359);

  FOR j:=1 TO 4 DO BEGIN
    MakeComplex(v1[j],1,j-1);
    MakeComplex(v2[j],2-j,j);
    MakeComplex(v3[j],0,0);
  END;

  Reset(fil,'CX_TEST.DAT');

  Writeln(' Matrix m1 : ');

  FOR j:=1 TO i1 DO BEGIN
    FOR k:= 1 TO j1 DO BEGIN
      Read(fil,x1,x2);
      MakeComplex(m1[j,k],x1,x2);
      Write(x1:4:2, ' + ', x2:4:2, ' * i , ');
    END;
    Writeln;
    Readln(fil);
  END;

  Writeln;  Writeln(' Matrix m2 : ');
  FOR j:=1 TO i2 DO BEGIN
    FOR k:= 1 TO j2 DO BEGIN
      Read(fil,x1,x2);
      MakeComplex(m2[j,k],x1,x2);
      Write(x1:4:2, ' + ', x2:4:2, ' * i , ');
    END;
    Writeln;
    Readln(fil);
  END;
  Writeln;

  Close(fil);

  FOR j:=1 TO i1 DO
    FOR k:= 1 TO j2 DO
      MakeComplex(m3[j,k],0,0);

  FOR j:=1 TO 3 DO
    FOR k:=1 TO 3 DO BEGIN
      MakeComplex(mat1[j,k],j,1);
      MakeComplex(mat2[j,k],1,k);
      MakeComplex(mat3[j,k],0,0)
    END;

 END; { InitVar }
                                                  { ** Test : ** }
BEGIN
  InitVar;
  WaitKey;
                                                  { Matrizenoperationen }
  Cx_MatMult(m1,m2,m3,i1,j1,j2);

  Writeln(' m1*m2 = ');
  FOR j:=1 TO i1 DO BEGIN
    FOR k:=1 TO j2 DO BEGIN
      WriteComplex(m3[j,k],5,1); Write(', ');
    END;
  Writeln;
  END;

  Writeln(' mat1 = ');
  FOR j:=1 TO 3 DO BEGIN
    FOR k:=1 TO 3 DO BEGIN
      WriteComplex(mat1[j,k],3,1); Write(', ');
    END;
    Writeln;
  END;
  Writeln;

  Writeln(' mat2 = ');
  FOR j:=1 TO 3 DO BEGIN
    FOR k:=1 TO 3 DO BEGIN
      WriteComplex(mat2[j,k],3,1); Write(', ');
    END;
    Writeln;
  END;
  Writeln;

  Writeln(' mat1+mat2 = ');
  Cx_AddMat(mat1,mat2,mat3,3,3);
  FOR j:=1 TO 3 DO BEGIN
    FOR k:=1 TO 3 DO BEGIN
      WriteComplex(mat3[j,k],4,1); Write(', ');
    END;
    Writeln;
  END;
  Writeln;

  Writeln(' mat1-mat2 = ');
  Cx_SubtMat(mat1,mat2,mat3,3,3);
  FOR j:=1 TO 3 DO BEGIN
    FOR k:=1 TO 3 DO BEGIN
      WriteComplex(mat3[j,k],4,1); Write(', ');
    END;
    Writeln;
  END;

  WaitKey;

  Write(' z1 = '); WriteComplex(z1,5,2);
  Writeln;
  Write(' z2 = '); WriteComplex(z2,5,2);
  Writeln;

  Move(z1,z2);                                          {  Move  }
  Writeln(' z1 --> z2 ');
  Write(' z2 = '); WriteComplex(z2,5,2);
  Writeln; Writeln;

                                                       { SetRepart, SetImpart }
  Write(' Jetzt sei Re z2 = 2.5, Im z2 = 0.3 .   z2 = ');
  SetRepart(z2,2.5); SetImpart(z2,0.3);
  WriteComplex(z2,5,2);
  Writeln;

  Konj(z2,z1);                                             { Konj }
  Write(' Die komplex-konjungierte von z2 ist z1 = ');
  WriteComplex(z1,5,2);
  Writeln;  Writeln;

  Negat(z1,z1);                                               { Negat }
  Write(' -z1 = '); WriteComplex(z1,5,2);
  Writeln; Writeln;

  Signum(z2,z1);                                             { Signum }
  Write(' Signum(' ); WriteComplex(z2,5,2); Write( ')  =  ');
  WriteComplex(z1,7,4);
  Writeln; Writeln;

                                                             { Argument }
  Write(' Argument(' ); WriteComplex(z1,5,2);
  Write( ') = ', Argument(z1):5:3);
  Writeln; Writeln;

  Write(' Betrag(' ); WriteComplex(z1,5,2);                  { Betrag  }
  Write(') = ', Betrag(z1):5:3);
  Writeln; Writeln;

  PolToCart(5,3.1,z1);                                      { PolToCart }
  Write(' Betrag=5, Argument=3.1  <--> ');
  WriteComplex(z1,7,4);
  Writeln; Writeln;

  SetComplex(z1,2,-3);                                      { SetComplex }
  RiemannK(z1,x1,x2,x3);                                    { RiemannK }
  WriteComplex(z1,5,2);
  Writeln(' hat die Riemannschen Koordinaten :  ');
  Writeln('    ', x1,' , ', x2, ' , ', x3); Writeln;

  RieToCart(x1,x2,x3,z1);                                   { RieToCart }
  Write(' Und zurck mit RieToCart :  ');
  WriteComplex(z1,5,2);
  Writeln; Writeln;

  WaitKey;
                                                   { Equal, Zero, Imaginaer, }
  Write(' z2 = '); WriteComplex(z2,4,2); Writeln;  { Reell                   }
  Write(' z3 = '); WriteComplex(z3,4,2); Writeln;
  Writeln;
  Writeln(' z2=z3        --> ', Equal(z2,z3));
  Writeln(' z2=0         --> ', Zero(z2));
  Writeln(' z3 imagin„r  --> ', Imaginaer(z3));
  Writeln(' z3 reell     --> ', Reell(z3));
                                                    { Add, Subt, Mult, Divi }
  Add(z2,z3,z1);
  Write(' z2+z3 = '); WriteComplex(z1,7,4);
  Writeln;
  Subt(z2,z3,z1);
  Write(' z2-z3 = '); WriteComplex(z1,7,4);
  Writeln;
  Mult(z2,z3,z1);
  Write(' z2*z3 = '); WriteComplex(z1,7,4);
  Writeln;
  Divi(z2,z3,z1);
  Write(' z2/z3 = '); WriteComplex(z1,7,4);
  Writeln;
                                                    { Mult_i, Divi_i, Inv }
  Mult_i(z2,z1);
  Write(' z2*i  = '); WriteComplex(z1,7,4);
  Writeln;
  Divi_i(z2,z1);
  Write(' z2/i  = '); WriteComplex(z1,7,4);
  Writeln;
  Inv(z2,z1);
  Write(' 1/z2 = '); WriteComplex(z1,7,4);
  Writeln;

  Square(z2,z1);                                    { Square, Sq_Root }
  Write(' z2^2 = '); WriteComplex(z1,7,4);
  Writeln;
  Sq_Root(z2,z1);
  Write(' Wurzel z2 = '); WriteComplex(z1,7,4);
  Writeln;
                                                                   { Dist }
  Writeln(' Der Abstand zwischen z2 und z3 ist ', Dist(z2,z3):7:4);
  Writeln;

  Cx_Exp(z4,z1);                                      { Cx_Exp, Cx_Ln }
  Write(' Exp('); WriteComplex(z4,7,4); Write(') = ');
  WriteComplex(z1,7,4); Writeln;
  Cx_Ln(z1,z4);
  Write('  Ln('); WriteComplex(z1,7,4); Write(') = ');
  WriteComplex(z4,7,4); Writeln; Writeln; Writeln;

  WaitKey;

  Writeln;                                               { Trigonometrische }
  SetComplex(z1,0.5,1);                                  { Funktionen       }
  Write(' z1 = '); WriteComplex(z1,5,3); Writeln; Writeln;

  Cx_ArcSin(z1,z2);
  Write(' ArcSin(z1)      =   '); WriteComplex(z2,8,4); Writeln;
  Cx_Sin(z2,z2);
  Write(' Sin(ArcSin(z1)) =   '); WriteComplex(z2,8,4); Writeln;
  Cx_ArcCos(z1,z2);
  Write(' ArcCos(z1)      =   '); WriteComplex(z2,8,4); Writeln;
  Cx_Cos(z2,z2);
  Write(' Cos(ArcCos(z1)) =   '); WriteComplex(z2,8,4); Writeln;
  Cx_ArcTan(z1,z2);
  Write(' ArcTan(z1)      =   '); WriteComplex(z2,8,4); Writeln;
  Cx_Tan(z2,z2);
  Write(' Tan(ArcTan(z1)) =   '); WriteComplex(z2,8,4); Writeln;
  Writeln;                                                  { Hyperbolische }
                                                            { Funktionen    }
  Cx_ArSinh(z1,z2);
  Write(' ArSinh(z1)       =   '); WriteComplex(z2,8,4); Writeln;
  Cx_Sinh(z2,z2);
  Write(' Sinh(ArSinh(z1)) =   '); WriteComplex(z2,8,4); Writeln;
  Cx_ArCosh(z1,z2);
  Write(' ArCosh(z1)       =   '); WriteComplex(z2,8,4); Writeln;
  Cx_Cosh(z2,z2);
  Write(' Cosh(ArCosh(z1)) =   '); WriteComplex(z2,8,4); Writeln;
  Cx_ArTanh(z1,z2);
  Write(' ArTanh(z1)       =   '); WriteComplex(z2,8,4); Writeln;
  Cx_Tanh(z2,z2);
  Write(' Tanh(ArTanh(z1)) =   '); WriteComplex(z2,8,4); Writeln;
  Writeln; Writeln;

  WaitKey;

   FOR j:=1 TO 4 DO BEGIN
     Write(' v1[',j,'] = '); WriteComplex(v1[j],6,3); Write(', ');
     Write(' v2[',j,'] = '); WriteComplex(v2[j],6,3);
     Writeln
   END;

  Writeln;                                              { Vektoroperationen }
  Add_CxVektor(v1,v2,v3,4);
  FOR j:=1 TO 4 DO BEGIN
     Write(' (v1+v2)[',j,'] = '); WriteComplex(v3[j],6,3);
     Writeln;
  END;
  Writeln;

  Subt_CxVektor(v1,v2,v3,4);
  FOR j:=1 TO 4 DO BEGIN
     Write(' (v1-v2)[',j,'] = '); WriteComplex(v3[j],6,3);
     Writeln;
  END;

  Writeln;
  Writeln(' Norm2(v1)   = ', Norm2_CxVekt(v1,4):8:4); Writeln;
  Cx_SkalProd(v1,v2,z3,4);
  Write('     v1*v2   = '); WriteComplex(z3,8,4);
  Writeln;
  WaitKey
END.
