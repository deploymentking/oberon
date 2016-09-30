MODULE Yard;

IMPORT CP := ColorPlane;

PROCEDURE Yard*;

BEGIN

    (*This section opens up the drawing screen and draws the sidings*)
    CP.Open();
    CP.GotoXY(10, 220);  
    CP.SetForeColor(104, 210, 145);
    CP.WriteStr("Lee's Shunting Yard Simulation");

    CP.SetForeColor(0,0,0);
    CP.Line(150, 50, 500, 50, CP.DRAW);(*Siding3*)
    CP.Line(500, 40, 500, 60, CP.DRAW);
    CP.SetForeColor(255,0,0);
    CP.GotoXY(500, 50);
    CP.WriteStr("Siding 3");
    
    CP.SetForeColor(0,0,0);
    CP.Line(10, 100, 500, 100, CP.DRAW);(*Siding2*)
    CP.Line(500, 90, 500, 110, CP.DRAW);
    CP.SetForeColor(0,255,0);
    CP.GotoXY(500, 100);
    CP.WriteStr("Siding 2");
    
    CP.SetForeColor(0,0,0);
    CP.Line(150, 150, 500, 150, CP.DRAW);(*Siding1*)
    CP.Line(500, 140, 500, 160, CP.DRAW);
    CP.SetForeColor(0,0,255);
    CP.GotoXY(500, 150);
    CP.WriteStr("Siding 1");
    
    CP.SetForeColor(0,0,0);
    CP.Line(50, 100, 150, 50, CP.DRAW); (*Connecting lines*)
    CP.Line(50, 100, 150, 150, CP.DRAW);

    CP.GotoXY(300, 240);                   (*Legend that gives info about train destination*)
    CP.SetForeColor(104, 210, 145);
    CP.WriteStr("Destination 1 = ");
    CP.SetForeColor(0, 0, 255);
    CP.Bar(450, 232, 455, 237, CP.DRAW);
    
    CP.GotoXY(300, 220);
    CP.SetForeColor(104, 210, 145);
    CP.WriteStr("Destination 2 = ");
    CP.SetForeColor(0, 255, 0);
    CP.Bar(450, 212, 455, 217, CP.DRAW);
    
    CP.GotoXY(300, 200);
    CP.SetForeColor(104, 210, 145);
    CP.WriteStr("Destination 3 = ");
    CP.SetForeColor(255, 0, 0);
    CP.Bar(450, 192, 455, 197, CP.DRAW);
                   
END Yard;   (*Procedure*)
BEGIN
END Yard.   (*Module*)

