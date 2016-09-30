MODULE Shunting;

(*Importing of the stack library module included here*)
IMPORT In, Out, S := Stack, Y := Yard, T := Trucks, P := Pause;

PROCEDURE ProgMain*;

CONST
    FIELDWIDTH = 2;

VAR
    siding1, siding2, siding3 : S.Stack; (*The three sidings of the shunting
                                           yard are declared here as stacks*)
    truckNumber : INTEGER;       (*Number of trucks in the simulation*)                                 
    count : INTEGER;             (*For loop variable*)
    destinationTruck : INTEGER;  (*Final destination of the truck 1, 2 or 3*)
    x1, y1 : INTEGER;            (*Siding 1 start coordinates*)
    x2, y2 : INTEGER;            (*Siding 2 start coordinates*)
    x3, y3 : INTEGER;            (*Siding 3 start coordinates*)
    number : INTEGER;            (*Temporary holding number for the top value of the stack*)
    p : INTEGER;   (*This variable changes the amount of time the computer pauses. More 
                     powerful computers require a larger number*)
BEGIN 
    
    (*This imports from the shunting yard library module and draws the yard
      from these start coordinates*)
    Y.Yard;
    
    (*This section creates three stacks for the different sidings*)
    siding1 := S.Create();
    siding2 := S.Create();
    siding3 := S.Create();
 
    (*This section gets the pause value from the user. A 486 should have a value of
      approximately 100 while a Pentium computer will require a value of about 500*)
    Out.String("How slow would you like this simulation to run."); Out.Ln;
    Out.String("If you have a Pentium processor a value of 500 is suggested."); Out.Ln;
    Out.String("Please enter a value between 50 and 500."); Out.Ln;
    In.Int(p); Out.Ln; Out.Ln;
    
    WHILE (p > 500) OR (p < 50) DO
        Out.String("This is an inappropriate value, please try again");
        In.Int(p);
        Out.Ln;
    END;  (*End WHILE loop*)
 
 
    (*This section gets the number of trucks to include in the simulation*)
    Out.Ln; Out.Ln; Out.Ln;
    Out.String("Please enter the number of trucks you wish to include in the simulation.");
    Out.Ln;
    Out.String("(The number of trucks should be between 1 and 30.)");
    In.Int(truckNumber);
    Out.Ln;
    
    (*This loop checks the inputted number and as long as it isn't valid it will 
      give the option to try again*)
    WHILE (truckNumber > 30) OR (truckNumber < 1) DO
        Out.Ln;
        Out.String("You have entered an invalid number of trucks, please try again");
        In.Int(truckNumber);
        Out.Ln;
    END;  (*End WHILE loop*)
    
    (*If the correct number of trucks is inputted then this message is displayed*)
    Out.Ln;
    IF truckNumber = 1 THEN
        Out.String("You have entered ");
        Out.Int(truckNumber, FIELDWIDTH);
        Out.String(" truck in this simulation.");
        Out.Ln;
    ELSE
        Out.String("You have entered ");
        Out.Int(truckNumber, FIELDWIDTH);
        Out.String(" trucks in this simulation.");
        Out.Ln; Out.Ln;
    END;   (*End IF loop*)
    
    (*This section gets the destination numbers from the user and pushes it onto the
      stack siding 3 and then displays on the screen*)
    
    x1 := 490; y1 := 155;   (*Start coordinates for the first siding*)
  
    FOR count := 1 TO truckNumber DO

        IF count = 1 THEN
            Out.String("Please enter the destination (1, 2 or 3) of the first truck."); Out.Ln;
            Out.String("Then press return."); Out.Ln;
            In.Int(destinationTruck); Out.Ln; 
            
            (*Error Check*)
            WHILE (destinationTruck < 1) OR (destinationTruck > 3) DO
                Out.String("You have entered an invalid destination, please try again.");
                Out.Ln;
                In.Int(destinationTruck);
            END;         (*End embedded WHILE loop*)
            
        ELSE
            Out.String("Please enter the destination of the next truck."); Out.Ln;
            Out.String("Then press return."); Out.Ln;
            In.Int(destinationTruck); Out.Ln; 
        
            (*Error Check*)
            WHILE (destinationTruck < 1) OR (destinationTruck > 3) DO
                Out.String("You have entered an invalid destination, please try again.");
                Out.Ln;
                In.Int(destinationTruck);
            END;         (*End embedded WHILE loop*)
            
        END;       (*End embedded IF loop*)                                                                    

        (*This pushes the destination truck number into the siding1 stack*)
        siding1 := S.Push(siding1, destinationTruck);
        
        (*Depending on the number this section prints out the correct colour truck*)
        IF destinationTruck = 1 THEN
            T.TruckDest1(x1, y1);
        ELSIF destinationTruck = 2 THEN
            T.TruckDest2(x1, y1);
        ELSIF destinationTruck = 3 THEN
            T.TruckDest3(x1, y1);
        END;   (*End IF (destinationTruck) Loop*)
        
        x1 := x1 - 10;   (*Decrement the coordinates to allow 
                           drawing of the next train*)
        
    END;     (*End FOR loop*) 
    
    Out.Ln; Out.String("The simulation will now run."); 
    Out.Ln; Out.Ln;
    
    (*This is the start of the sorting procedure*)
    (*Stage 1*)
    
    P.Pause(p);
    x2 := 490; y2 := 105; (*These set up the start coordinates for sidings 2 and 3*)
    x3 := 490; y3 := 55; 
    
    WHILE ~S.IsEmpty(siding1) DO
        number := S.Top(siding1);

        IF (number = 3) OR (number = 1) THEN 
            siding3 := S.Push(siding3, number);
  
                (*If truck is 1 or 3 it gets drawn on siding 3*)
                IF  number = 1 THEN
                    T.TruckDest1(x3, y3);
                    x3 := x3 - 10;
                ELSIF number = 3 THEN
                    T.TruckDest3(x3, y3);
                    x3 := x3 - 10; 
                END;  (*End embedded IF loop*) 
                
            siding1 := S.Pop(siding1); 
        
        ELSE 
            siding2 := S.Push(siding2, number);
            (*Truck gets drawn on siding 2 if destination is 2*)
            T.TruckDest2(x2, y2);
            x2 := x2 - 10;
            siding1 := S.Pop(siding1);
        END;   (*End IF loop*)
       
        (*This section erases the trucks from the first siding*)       
        x1 := x1 + 10;
        T.Erase(x1, y1);
        P.Pause(p);  
    END;     (*End WHILE loop*)
     
    Out.String("Stage 1 is now complete"); Out.Ln;
    Out.String("Stage 2 will follow"); Out.Ln; Out.Ln; 
    
    (*Stage 2*)
    P.Pause(p);
    x1 := 490;   (*Resets the x coordinate for the first siding*)
    
    WHILE ~S.IsEmpty(siding3) DO
        number := S.Top(siding3);
        
        IF (number = 3) THEN 
            siding2 := S.Push(siding2, number);
            (*Truck gets drawn on siding 2*)
            T.TruckDest3(x2, y2);
            x2 := x2 - 10;
            siding3 := S.Pop(siding3); 
        ELSIF (number = 1) THEN 
            siding1 := S.Push(siding1, number);
            (*Truck gets drawn on siding 1*)
            T.TruckDest1(x1, y1); 
            x1 := x1 - 10;
            siding3 := S.Pop(siding3); 
        END;   (*End IF loop*)

        (*This section erases the trucks from the third siding*) 
        x3 := x3 + 10;
        T.Erase(x3, y3);
        P.Pause(p);   
    END;     (*End WHILE loop*)      

    Out.String("Stage 2 is now complete"); Out.Ln;
    Out.String("Stage 3 will follow"); Out.Ln; Out.Ln; 
    
    (*Stage 3*)
    x3 := 490;   (*Resets the x coordinates on the third siding*)
    P.Pause(p);
    
    (*As long as the numbers are 3 and the stack isn't empty the last stage is executed*)
    WHILE (~S.IsEmpty(siding2)) & (S.Top(siding2) # 2)DO 
        number := S.Top(siding2);
        siding3 := S.Push(siding3, number);
        
        IF number # 2 THEN
            T.TruckDest3(x3, y3);
            x3 := x3 - 10;
            siding2 := S.Pop(siding2);
            x2 := x2 + 10;
            T.Erase(x2, y2);
            P.Pause(p);
        END;   (*End IF loop*)
        
    END;   (*End WHILE loop*)
    P.Pause(p);
    
    Out.Ln;
    Out.String("The simulation is now complete."); Out.Ln;
    Out.String("If you would like to have another go, please re-compile the simulation.");
    
END ProgMain;
END Shunting.
