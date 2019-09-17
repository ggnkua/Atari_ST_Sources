PROGRAM  shiftbonuses (INPUT,OUTPUT);

VAR
weekno,dd,mm,yyyy,ccno,noofshifts,shiftloop,sum,tothours,addhours:INTEGER;
whichshift:CHAR;
name:STRING[30];
attbonus,addbonus,attenda,attendb,ota,otb,finaladdbonus,finalattbonus:REAL;


BEGIN
        {zeroise totals}
        
        finaladdbonus:=0;
        finalattbonus:=0;


   WRITELN('PLEASE ENTER TODAY`S DATE');
   WRITELN('DAY ?');
   READ(dd);
   WRITELN('MONTH ?');
   READ(mm);
   WRITELN('YEAR ? eg 1994.');
   READ(yyyy);
   WRITELN('PLEASE ENTER THE WEEK NUMBER ?');
   READ(weekno);
   WRITELN (dd:2,'/':1,mm:2,'/':1,yyyy:4,'   Week No.':11,weekno:2);
 {chance to correct any errors in date input not working}
 
 {input and verify pay scales}
 
  REPEAT
    WRITELN('PLEASE INPUT ATTENDANCE BONUS FOR SHIFT A');
    READLN(attenda);
    WRITELN('PLEASE INPUT ATTENDANCE BONUS FOR SHIFT B');
    READLN(attendb);
    IF ((attenda<0)or(attenda>100)or(attendb<0)or(attendb>100)) THEN WRITELN('BONUS RATE UNREASONABLE. PLEASE CHECK AND RE-ENTER');
  UNTIL ((attenda>=0)and(attenda<=100))and((attendb>=0)and(attendb<=100));
  REPEAT
    WRITELN('PLEASE INPUT ADDITIONAL HOURS RATE FOR SHIFT A');
    READLN(ota);
    WRITELN('PLEASE INPUT ADDITIONAL HOURS RATE FOR SHIFT B');
    READLN(otb);
    IF((ota<0)or(ota>10))or((otb<0)or(otb>10))THEN WRITELN('ADDITIONAL HOURS RATES ARE UNREASONABLE. PLEASE CHECK AND RE-ENTER');
  UNTIL ((ota>=0)and(ota<=10))and((otb>=0)and(otb<=10));

{MAIN LOOP}
   WRITELN('PLEASE INPUT EMPLOYEE`S CLOCK CARD NUMBER');
   READLN(ccno);
   WHILE ccno<>9999 DO
    BEGIN
      {zeroise subtotals}
      tothours:=0;
      addbonus:=0;
      attbonus:=0;
      addhours:=0;
      WRITELN('PLEASE INPUT EMPLOYEE`S NAME..30 CHARACTERS MAXIMUM');
      READLN(name);
      REPEAT
        WRITELN('PLEASE INPUT WHICH SHIFT WORKED. A OR B ');
        READLN(whichshift);
      UNTIL ((whichshift='A')or(whichshift='a')or(whichshift='B')or(whichshift='b'));
      
      REPEAT
        WRITELN('PLEASE INPUT NUMBER OF SHIFTS WORKED - BETWEEN 1 AND 7');
        READLN(noofshifts);
        IF(noofshifts<1)or(noofshifts>7)THEN WRITELN('SHIFTS WORKED MUST BE BETWEEN 1 AND 7. PLEASE CHECK AND RE-ENTER');
      UNTIL(noofshifts>=1)and(noofshifts<=7);
      
   {loop to calculate additional hours}
      FOR shiftloop:= 1 TO noofshifts DO
        BEGIN
          REPEAT
            WRITELN('PLEASE INPUT HOURS WORKED ON SHIFT ',shiftloop:1);
            READLN(sum);
            IF(sum>12)THEN WRITELN('MAXIMUM OF 12 HOURS PER SHIFT. PLEASE CHECK AND RE-ENTER');
          UNTIL sum<=12;
          tothours:=tothours+sum;
          addhours:=addhours+(sum-6)
        END;
      

      {calculate bonus payments}
            
        IF(whichshift='A')or(whichshift='a')THEN attbonus:=(noofshifts*attenda)
        ELSE attbonus:=(noofshifts*attendb);
        
        IF(whichshift='A')or(whichshift='a')THEN addbonus:=(addhours*ota)
        ELSE addbonus:=(addhours*otb);
        
      {final totals for report}
      
        finalattbonus:=finalattbonus+attbonus;
        finaladdbonus:=finaladdbonus+addbonus;
        
      {output results to VDU}
      
           
        WRITELN;WRITELN;WRITELN;
        WRITELN (dd:2,'/':1,mm:2,'/':1,yyyy:4,'   Week No.':11,weekno:2);
        WRITELN;WRITELN;         
        WRITELN('CLOCK CARD NUMBER ',ccno:4,'  NAME ',name,'  TOTAL SHIFTS ',noofshifts:1);
        WRITELN('TOTAL HOURS ',tothours:2,'  ATTENDANCE BONUS œ',attbonus:5:2,'  ADDITIONAL HOURS BONUS œ',addbonus:5:2);
        WRITELN;WRITELN;
        WRITELN('PLEASE INPUT EMPLOYEE`S CLOCK CARD NUMBER');
        READLN(ccno);
    END;
   WRITELN;WRITELN;
   WRITELN('FINAL TOTALS ARE AS FOLLOWS:');
   WRITELN('TOTAL ATTENDANCE BONUS œ',finalattbonus:7:2);
   WRITELN('TOTAL ADDITIONAL HOURS BONUS œ',finaladdbonus:7:2);
   WRITELN (dd:2,'/':1,mm:2,'/':1,yyyy:4,'   Week No.':11,weekno:2);
   WRITELN;
END.

            
        


