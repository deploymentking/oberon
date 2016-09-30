MODULE Test;

IMPORT In, Out, s := Stack;  (*importing the stack data abstraction*)

PROCEDURE ProgMain*;

VAR
    siding1, siding2 : s.Stack;
    number : INTEGER;
BEGIN
    (*This section creates two stacks and then puts the items into siding 1*)
    siding1 := s.Create();
    siding2 := s.Create(); 
    siding1 := s.Push(siding1, 5);
    siding1 := s.Push(siding1, 4);
    siding1 := s.Push(siding1, 3); 
    
    (*This section finds the number of the top item, prints it out and then
      takes the top item off and tests to see if it is empty*)
    number := s.Top(siding1);     
    Out.Int(number, 3);  
    Out.Ln;
    siding1 := s.Pop(siding1);
    IF s.IsEmpty(siding1) THEN
        Out.String("Empty");
    ELSE
        Out.String("Stuffed to the gills");
    END; 
    Out.Ln;
    
    (*This section gets the top item of siding1 then puts it into siding2
      and then takes it off of siding1. It then prints out the top items
      of the two sidings*)
    number := s.Top(siding1);
    siding2 := s.Push(siding2, number);
    siding1 := s.Pop(siding1);
    Out.Int(s.Top(siding1), 3);
    Out.Ln;
    Out.Int(s.Top(siding2), 3);
    Out.Ln;

END ProgMain;
END Test.

