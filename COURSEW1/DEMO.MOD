MODULE Demo;
(*This small program sets up a graphics window on the PC screen, into
which you can draw. It doesn't draw anything particularly sensible
but gives some idea of the sorts of things that are possible*)

IMPORT CP := ColorPlane; (*we can rename any library module we want to
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
    MINX = 50; (*Starting x coordinate*)
    MINY = 50; (*Starting y coordinate*)
    MAXX = 800; (*maximum x coordinate*)
    MAXY = 650; (*maximum y coordinate*)
    MAXCOLOUR = 255; (*all colours are given to ColourPlane as RGB values.
                       The minimum value for red, green or blue is 0, the
                       maximum is 255. Thus, the colour value 0,0,255 is blue,
                       and 0, 150, 150 is a muddy turquoise on my screen! *)
VAR
    x, y : INTEGER; (*Screen coordinates*)
    count : INTEGER; (*loop count variable*)
    
BEGIN
    (*create display area for graphics, this must be
    the first thing done*)
    CP.Open();
    
    (*Set up starting coordinates for drawing, and move
    cursor to this position*)
    x := MINX; y := MINY;
    CP.GotoXY(x, y);
    
    
    
    (*Draw some boxes on the screen. THis will make a
    coloured grid in black and red.*)
    
    (*Draw first set of boxes in black - the default
    foreground colour.*)
    FOR count := 0 TO 200 BY 10 DO
        CP.Box(x, y, x+count, y+count, CP.DRAW);
    END;             
    
    (*Draw second set of boxes in red.*)
    CP.SetForeColor(MAXCOLOUR, 0, 0);
    x := MAXX; y := MAXY;
    CP.GotoXY(x, y);
    FOR count := 200 TO 0 BY -10 DO
        CP.Box(x, y, x-count, y-count, CP.DRAW);
    END;   
    
    (*Draw some lines over the grid.*)
    
    (*First set of lines in green*)
    CP.SetForeColor(0, MAXCOLOUR, 0);
    x := MINX; y:= MAXY;
    FOR count := 0 TO 200 BY 10 DO
        CP.Line(x, y, x+count, x, CP.DRAW);
    END;
    (*Second set of lines in blue.*)
    CP.SetForeColor(150, 150, MAXCOLOUR);
    x := MAXX; y := MINY;
    FOR count := 0 TO 200 BY 10 DO
        CP.Line(x, y, y, y+count, CP.DRAW);
    END; 
    
             
     (* this section of code develops dots on the screen
     CP.SetForeColor(224,160,211);
     x := 0; y := 0;
     FOR count := 0 TO 300 BY 20 DO
         CP.Line(x + count, y + count, x + count, y + count, CP.DRAW); 
     END;
              *)
     
     
    HoldScreen;       
    
    
END ProgMain;
END Demo. 
