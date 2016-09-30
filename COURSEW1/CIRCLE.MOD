MODULE circle;
(*This small program sets up a graphics window on the PC screen, into
which you can draw. It doesn't draw anything particularly sensible
but gives some idea of the sorts of things that are possible*)

IMPORT Float, CP := ColorPlane; (*we can rename any library module we want to
                            use in our program, to save typing in the full
                            name each time we use one of its resources.
                            If you do this make sure that you choose a 
                            sensible shortened name.*)
PROCEDURE HoldScreen;
(*A simple utility program which keeps the graphics window open on the
PC screen until the right mouse button is pressed (or the window is closed 
using the close box on it's top left corner. Without holdscreen (or someting
similar) the graphics window will close as soon as the last statement in 
module Demo is executed.*)
TYPE 
    Color = RECORD
    r, g, b : INTEGER;
    END;
CONST
    RIGHT = 2; (*Value returned by the right mouse button*)
   
VAR
    buttons : SET; (*The set of mouse button values*)
    x, y : INTEGER; (*Needed simply for GetMouse, which returns both set of 
                      buttons which have been pressed, and the current 
                      coordinates of the mouse pointer which we don't need to 
                      here*)
BEGIN
    REPEAT
        CP.GetMouse(buttons, x, y);
    UNTIL (RIGHT IN buttons);;
END HoldScreen;


(*Main Program*)
PROCEDURE ProgMain*;

CONST
    PI = 3.14159;
    LENGTH = 5;
    MINX = 200; (*Starting x coordinate*)
    MINY = 200; (*Starting y coordinate*)
    MAXX = 800; (*maximum x coordinate*)
    MAXY = 650; (*maximum y coordinate*)
    MAXCOLOUR = 255; (*all colours are given to ColourPlane as RGB values.
                       The minimum value for red, green or blue is 0, the
                       maximum is 255. Thus, the colour value 0,0,255 is blue,
                       and 0, 150, 150 is a muddy turquoise on my screen! *)
VAR
    x, y, x2, y2, c: INTEGER; (*Screen coordinates*)
    count : INTEGER; (*loop count variable*)
    angle : INTEGER; 
    angleRad : REAL;
    x1, y1 : REAL;
  
    
BEGIN
    (*create display area for graphics, this must be
    the first thing done*)
    CP.Open();
    
    (*Set up starting coordinates for drawing, and move
    cursor to this position*)
    x := MINX; y := MINY;
    CP.GotoXY(x, y);
     
    
    
    FOR angle := 0 TO 360 BY 1 DO
        angleRad := (angle / 180) * PI;
        x1 := Float.Cos (angleRad) * LENGTH; 
        y1 := Float.Sin (angleRad) * LENGTH; 
        x2 := SHORT (ENTIER(x1)); y2 := SHORT (ENTIER(y1));
        
        CP.Line(MINX, MINY, MINX + x2, MINY + y2, CP.DRAW);
    END;
   (* CP.SetForeColor(255,255,255);
    FOR angle := 0 TO 360 BY 1 DO
        angleRad := (angle / 180) * PI;
        x1 := Float.Cos (angleRad) * 40;
        y1 := Float.Sin (angleRad) * 40;
        x2 := SHORT (ENTIER(x1)); y2 := SHORT (ENTIER(y1));
        
        CP.Bar(MINX, MINY, MINX + x2, MINY + y2, CP.DRAW);
    END;        *)              
    HoldScreen;       
    
    
END ProgMain;
END circle. 
