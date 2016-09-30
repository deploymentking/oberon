MODULE Pause;
(*This module will slow down the computer. The p is variable
so slower computers can have a lower pause value*)

PROCEDURE Pause*(p : INTEGER);

VAR
    loop, count : INTEGER;

BEGIN
    FOR loop := 1 TO p DO             (*This loop does nothing except*)
        FOR count := 1 TO 31000 DO    (*go through the loop*)
        END; 
    END; 
     
END Pause;
END Pause.
