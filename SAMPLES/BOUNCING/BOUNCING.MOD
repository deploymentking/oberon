 (****************************************************************************
   PROGRAM : Bouncing.mod
             Creates a bouncing ball with variable speed.
   DATE    : 19.04.1995
   AUTHOR  : Steiner Thomas, 9155163
   PLATFORM: Win16
   COMPILER: Robinson Associates, Oberon 2, Version 1.15
   COMMENT : ---
   CHANGES : 97/03/12 minor changes for windows callback functions
   **************************************************************************)
   
   MODULE Bouncing;
     IMPORT Windows, SYSTEM;
     
     CONST
       ClassName = "BouncingClass";
       
       (* MENU-Identifiers: *)
       FILE_EXIT        = 10101;
       CONTROL_BEEP     = 10201;
       CONTROL_STOP     = 10202;
       CONTROL_CREEPING = 10203;
       CONTROL_SLOW     = 10204;
       CONTROL_NORMAL   = 10205;
       CONTROL_FAST     = 10206;
       CONTROL_WARP     = 10207;
       HELP_ABOUT       = 10301;
     
       (* Menuentry for beeping: *)  
       BEEP_ON          = "Turn beep &on";
       BEEP_OFF         = "Turn beep &off";
     
       (* min. and max. window-size: *)
       WINDOW_MIN_X     = 200;
       WINDOW_MIN_Y     = 150;
       WINDOW_MAX_X     = 640;
       WINDOW_MAX_Y     = 480;
   
       (* speed-identifiers of the bouncing ball:  *)
       SPEED_STOP       = 0;
       SPEED_CREEPING   = 1;
       SPEED_SLOW       = 2;
       SPEED_NORMAL     = 3;
       SPEED_FAST       = 4;
       SPEED_WARP       = 5;

       (* speed-factor for the speed-identifiers *)
       SPEED_FACTOR     = 3; (* example: SPEED_FAST -> inc SPEED_FACTOR*4 *)

       (* size of the bouncing ball: *)
       BALLSIZE_X       = 100;
       BALLSIZE_Y       = 100;     

       (* color of the bouncing ball: *)
       BALL_RED         = 0;
       BALL_GREEN       = 255;
       BALL_BLUE        = 0;
       BALL_COLOR       = BALL_RED + BALL_GREEN*256 + BALL_BLUE*256*256;
  
       (* timer-delay in milliseconds *)
       TIMER_VALUE      = 30;
     
     TYPE
       (* Declare window's callback-function *)
       WNDPROC = PROCEDURE [WINDOWS] (hWnd: Windows.HWND; uMsg: Windows.WORD;
                                      wParam: Windows.WORD;
                                      lParam: LONGINT): LONGINT;
                                      
       (* pointer to MINMAX structure *)
       MINMAXINFOP = POINTER TO Windows.MINMAXINFO;
       
       
     VAR
       hInstance: Windows.HINSTANCE;  (* InstanceHandle of this application *)
       speed    : INTEGER;            (* current speed  *)
       beep     : BOOLEAN;            (* beep is on/off *)
       currentX : INTEGER;            (* actual xPosition of the ball *)
       currentY : INTEGER;            (* actual yPosition of the ball *)
       dX, dY: INTEGER;               (* actual direction of the ball *)
       start    : BOOLEAN;            (* application hast just started *)
       memDR    : Windows.HDC;        (* DC for direction down, right *)
       bitmapDR : Windows.HBITMAP;    (* Bitmap for direction down, right *)
   
   (**************************************************************************
     AboutProc:
     This function is called by windows to process messages of the AboutBox.
   **************************************************************************)
   PROCEDURE [WINDOWS] AboutProc*(hDlg: Windows.HWND; uMsg: Windows.WORD;
                                  wParam: Windows.WORD; lParam: LONGINT): Windows.BOOL;
   BEGIN
     CASE uMsg OF
       Windows.WM_INITDIALOG:
         RETURN Windows.true;
       |Windows.WM_COMMAND:
         IF (wParam = Windows.IDOK) THEN
           Windows.EndDialog(hDlg, Windows.true);
           RETURN Windows.true;
         END;
         RETURN Windows.false;
       ELSE
         RETURN Windows.false;
     END;
   END AboutProc;                                    
   
   (**************************************************************************
     SetMenuState:
     SET current menu-checkings. (\/)
     If they change, first clear the old ones!
   **************************************************************************)
   PROCEDURE SetMenuState(hWnd: Windows.HWND);
   VAR
     hMenu: Windows.HMENU;    (* menuhandle *)
     r    : LONGINT;          (* return value not needed *)
     rb   : Windows.BOOL;     (* return value not needed *)
   BEGIN
     hMenu := Windows.GetMenu(hWnd);
     hMenu := Windows.GetSubMenu(hMenu, 1);
     CASE speed OF
       SPEED_STOP:
         r := Windows.CheckMenuItem(hMenu, CONTROL_STOP, Windows.MF_CHECKED);
       |SPEED_CREEPING:
         r := Windows.CheckMenuItem(hMenu, CONTROL_CREEPING, Windows.MF_CHECKED);
       |SPEED_SLOW:
         r := Windows.CheckMenuItem(hMenu, CONTROL_SLOW, Windows.MF_CHECKED);
       |SPEED_NORMAL:
         r := Windows.CheckMenuItem(hMenu, CONTROL_NORMAL, Windows.MF_CHECKED);
       |SPEED_FAST:
         r := Windows.CheckMenuItem(hMenu, CONTROL_FAST, Windows.MF_CHECKED);       
       |SPEED_WARP:
         r := Windows.CheckMenuItem(hMenu, CONTROL_WARP, Windows.MF_CHECKED);       
       ELSE
     END;
     
     (* Set right beep-menu. *)  
     IF beep THEN
       rb := Windows.ModifyMenu(Windows.GetMenu(hWnd), CONTROL_BEEP,
                                Windows.MF_BYCOMMAND, CONTROL_BEEP,
                                SYSTEM.ADR(BEEP_OFF));
     ELSE
       rb := Windows.ModifyMenu(Windows.GetMenu(hWnd), CONTROL_BEEP,
                                Windows.MF_BYCOMMAND, CONTROL_BEEP,
                                SYSTEM.ADR(BEEP_ON));
     END; 
   END SetMenuState;


   (**************************************************************************
     UnCheckMenuEntry:
     Clear entry in the CONTROL-menu. Index starts with '0'.
     If they change, first clear the old ones!
   **************************************************************************)
   PROCEDURE UnCheckMenuEntry(hWnd: Windows.HWND; index: INTEGER);
   VAR
     hMenu: Windows.HMENU;    (* menuhandle *)
     r    : LONGINT;          (* return value not needed *)
   BEGIN
     hMenu := Windows.GetMenu(hWnd);
     hMenu := Windows.GetSubMenu(hMenu, 1);
     r     := Windows.CheckMenuItem(hMenu, CONTROL_STOP + index, 
                     Windows.MF_UNCHECKED);
   END UnCheckMenuEntry;



   (**************************************************************************
     DrawBall:
     Draws the bouncing ball with the position currentX, currentY into the
     application's window.
   **************************************************************************)
   PROCEDURE DrawBall(hWnd: Windows.HWND; hdc: Windows.HDC);
   VAR
     hPen  : Windows.HPEN;           (* pen for our bouncing ball *)
     hOldPen: Windows.HPEN;          (* old pen *)
     hBrush: Windows.HBRUSH;         (* brush for our bouncing ball *)
     hOldBrush: Windows.HBRUSH;      (* old brush *)
     r     : INTEGER;                (* return-value (not needed) *)
     rb    : Windows.BOOL;           (* return-value *)

   BEGIN
     (* first create and select pen *)
     hPen := Windows.CreatePen(Windows.PS_SOLID, 1, BALL_COLOR);
     IF hPen # Windows.NULL THEN
       hOldPen := Windows.SelectObject(hdc, hPen);

       (* now create and select brush *)
       hBrush := Windows.CreateSolidBrush(BALL_COLOR);
       IF hBrush # Windows.NULL THEN
       
         hOldBrush := Windows.SelectObject(hdc, hBrush);

         r := Windows.SetROP2(hdc, Windows.R2_COPYPEN); (* R2_XORPEN *)
         r := Windows.Ellipse(hdc, currentX, currentY, currentX + BALLSIZE_X, 
                         currentY + BALLSIZE_Y);    

         hOldBrush := Windows.SelectObject(hdc, hOldBrush);     
         r         := Windows.DeleteObject(hBrush);
       END;
       hOldPen := Windows.SelectObject(hdc, hOldPen);       
       r       := Windows.DeleteObject(hPen);
     END;

     (* appliation just started -> copy Bitmap *)
     IF start THEN
       memDR    := Windows.CreateCompatibleDC(hdc);
       bitmapDR := Windows.CreateCompatibleBitmap(hdc, 
                    2*SPEED_WARP*SPEED_FACTOR+2*BALLSIZE_X, 
                    2*SPEED_WARP*SPEED_FACTOR+2*BALLSIZE_Y);
       IF (bitmapDR # 0) & (memDR # 0)  THEN
         hOldPen := Windows.SelectObject(memDR, bitmapDR);
         rb := Windows.BitBlt(memDR, 0, 0, 2*SPEED_WARP*SPEED_FACTOR+2*BALLSIZE_X,
                    2*SPEED_WARP*SPEED_FACTOR+2*BALLSIZE_Y, hdc, 0, 0,
                    Windows.SRCCOPY); 
       ELSE (* didn't get memDR or bitmapDR! *)
         rb := Windows.DestroyWindow(hWnd);
       END;
       start := FALSE; 
     END;

   END DrawBall;

   (**************************************************************************
     ChangeSpeed:
     Changes the ball-speed by updating dx and dy values.
     This procedure is to be called after any change of speed.
   **************************************************************************)
   PROCEDURE ChangeSpeed;
   BEGIN
     IF dX<0 THEN
       dX := -speed * SPEED_FACTOR;
     ELSE
       dX := speed * SPEED_FACTOR;
     END;

     IF dY<0 THEN
       dY := -speed * SPEED_FACTOR;
     ELSE
       dY := speed * SPEED_FACTOR;
     END;
   END ChangeSpeed;


   (**************************************************************************
     MoveBall:
     MoveBall increments the ball-position, checks the window-ranges and
     displays the bouncing ball on its new position.
   **************************************************************************)
   PROCEDURE MoveBall(hWnd: Windows.HWND);
   VAR
     rect: Windows.RECT;          (* size of the bouncing-window. *)
     hdc: Windows.HDC;            (* Device context *)
     rb  : Windows.BOOL;          (* return value *)
     margin: INTEGER;             (* margin for BitBlt *)
     oldDX, oldDY: INTEGER;       (* dX and dY before checkWindowLimits *)

   BEGIN
     IF speed = 0 THEN RETURN; END; (* don't do anything, if speed is zero *)

     hdc := Windows.GetDC(hWnd);

     (* get the actual window-size. *)
     Windows.GetClientRect(hWnd, SYSTEM.ADR(rect));

     (* move ball *)
     currentX := currentX+dX;
     currentY := currentY+dY;

     oldDX := dX; oldDY := dY;  (* if program changes dX or dY it would *)
                                (* otherwise be a graphic problem       *)

     (* check range *)
     IF currentX < 0 THEN
       currentX := 0;
       dX       := -dX;
       IF beep THEN Windows.MessageBeep(1); END;
     ELSIF currentX > rect.right-BALLSIZE_X THEN
       currentX := rect.right-BALLSIZE_X;
       dX       := -dX;
       IF beep THEN Windows.MessageBeep(1); END;
     END;

     IF currentY < 0 THEN
       currentY := 0;
       dY       := -dY;
       IF beep THEN Windows.MessageBeep(1); END;
     ELSIF currentY > rect.bottom-BALLSIZE_Y THEN
       currentY := rect.bottom-BALLSIZE_Y;
       dY       := -dY;
       IF beep THEN Windows.MessageBeep(1); END;
     END;

     (* calculate margin in bitmap *)
     margin := SPEED_FACTOR * SPEED_WARP;

     IF ((oldDX > 0) & (oldDY > 0)) THEN  (* right down *)
       rb := Windows.BitBlt(hdc, currentX-margin, currentY-margin,
              margin+2*BALLSIZE_X, margin+2*BALLSIZE_Y,
              memDR, 0, 0, Windows.SRCCOPY);

     ELSIF (oldDX > 0) & (oldDY < 0) THEN (* right up *)
       rb := Windows.BitBlt(hdc, currentX-margin, currentY,
              margin+2*BALLSIZE_X, margin+2*BALLSIZE_Y,
              memDR, 0, margin, Windows.SRCCOPY);

     ELSIF (oldDX < 0) & (oldDY > 0) THEN (* left down *)
       rb := Windows.BitBlt(hdc, currentX, currentY-margin,
              margin+2*BALLSIZE_X, margin+2*BALLSIZE_Y,
              memDR, margin, 0, Windows.SRCCOPY);
    
     ELSE (* left up *)
       rb := Windows.BitBlt(hdc, currentX, currentY,
              margin+2*BALLSIZE_X, margin+2*BALLSIZE_Y,
              memDR, margin, margin, Windows.SRCCOPY);

     END;

     rb := Windows.ReleaseDC(hWnd, hdc);
   END MoveBall;
  

   (**************************************************************************
     WndProc:
     This function is called by windows to process its messages.
   **************************************************************************)
   PROCEDURE [WINDOWS] WndProc*(hWnd: Windows.HWND; uMsg: Windows.WORD;
                                      wParam: Windows.WORD;
                                      lParam: LONGINT): LONGINT;
   VAR
     r: INTEGER;                (* return-value (not needed) *)
     rb: Windows.BOOL;          (* return-value (not needed) *)
     hdc: Windows.HDC;          (* Device context *)
     ps:  Windows.PAINTSTRUCT;  (* Paintstructure *)
     minmax: MINMAXINFOP;       (* for pointer-conversion. *)
   
   BEGIN
     
     CASE uMsg OF
       Windows.WM_DESTROY:
         r := Windows.KillTimer(hWnd, 1);
         rb := Windows.DeleteDC(memDR);
         Windows.PostQuitMessage(0);  (* Terminate program *)
         RETURN 0;
       |Windows.WM_PAINT:
         hdc := Windows.BeginPaint(hWnd, SYSTEM.ADR(ps));
         DrawBall(hWnd, hdc);
         Windows.EndPaint(hWnd, SYSTEM.ADR(ps));

         RETURN 0;
       |Windows.WM_SIZE:
         (* user has changed the size of our window *)
         RETURN 0;
         
       |Windows.WM_GETMINMAXINFO:
         (* windows wants to know min. and max. window-size. *)
         minmax := SYSTEM.VAL(MINMAXINFOP, lParam); (* convert param *)
         minmax^.ptMinTrackSize.x := WINDOW_MIN_X;
         minmax^.ptMinTrackSize.y := WINDOW_MIN_Y;
         minmax^.ptMaxTrackSize.x := WINDOW_MAX_X;
         minmax^.ptMaxTrackSize.y := WINDOW_MAX_Y;
         RETURN 0;
         
       |Windows.WM_COMMAND:
         (* Selected menu: *)
         IF wParam = HELP_ABOUT THEN
            (* display About-Box *)
            r := Windows.DialogBox(hInstance, SYSTEM.ADR("ABOUT"), hWnd, AboutProc);

         ELSIF wParam = FILE_EXIT THEN
           (* exit program *)
           rb := Windows.DestroyWindow(hWnd);

         ELSIF wParam = CONTROL_BEEP THEN
           (* turn beep on/off *)
           beep := ~beep;
           SetMenuState(hWnd);

         ELSIF wParam = CONTROL_STOP THEN
           UnCheckMenuEntry(hWnd, speed);
           speed := SPEED_STOP;
           (* don't call ChangeSpeed, because we have to save dx, dy! *)
           SetMenuState(hWnd);

         ELSIF wParam = CONTROL_CREEPING THEN
           UnCheckMenuEntry(hWnd, speed);
           speed := SPEED_CREEPING;
           ChangeSpeed;
           SetMenuState(hWnd);
           
         ELSIF wParam = CONTROL_SLOW THEN
           UnCheckMenuEntry(hWnd, speed);
           speed := SPEED_SLOW;
           ChangeSpeed;
           SetMenuState(hWnd);
         
         ELSIF wParam = CONTROL_NORMAL THEN
           UnCheckMenuEntry(hWnd, speed);
           speed := SPEED_NORMAL;
           ChangeSpeed;
           SetMenuState(hWnd);
         
         ELSIF wParam = CONTROL_FAST THEN
           UnCheckMenuEntry(hWnd, speed);
           speed := SPEED_FAST;
           ChangeSpeed;
           SetMenuState(hWnd);

         ELSIF wParam = CONTROL_WARP THEN
           UnCheckMenuEntry(hWnd, speed);
           speed := SPEED_WARP;
           ChangeSpeed;
           SetMenuState(hWnd);
         
         END;
         RETURN 0;  
       |Windows.WM_TIMER:
         (* move the bouncing all *)
    
         MoveBall(hWnd);
    
         RETURN 0;
       ELSE
         RETURN Windows.DefWindowProc(hWnd, uMsg, wParam, lParam);
     END;
       
       (* RETURN 0; *)
     
   END WndProc;                                   
   
   (*************************************************************************
     InitApplication:
     This function registers all window classes.
   **************************************************************************)
   PROCEDURE InitApplication(): BOOLEAN;     
   VAR
     wc: Windows.WNDCLASS;        (* datastructure for registering *)
   BEGIN
     wc.style          := Windows.NULL;
     wc.lpfnWndProc    := WndProc;
     wc.cbClsExtra     := 0;
     wc.cbWndExtra     := 0;
     wc.hInstance      := hInstance;
     wc.hIcon          := Windows.LoadIcon(hInstance, SYSTEM.ADR("ICON_1"));
     wc.hCursor        := Windows.LoadCursor(Windows.NULL, Windows.IDC_ARROW);
     wc.hbrBackground  := Windows.GetStockObject(Windows.WHITE_BRUSH);
     wc.lpszMenuName   := SYSTEM.ADR("MENU_1");
     wc.lpszClassName  := SYSTEM.ADR(ClassName);

     IF (wc.hIcon = Windows.NULL) THEN
       Windows.MessageBeep(2);
     END;
     
     RETURN (Windows.RegisterClass(SYSTEM.ADR(wc)) # 0);  
   END InitApplication;  
   
   (*************************************************************************
     InitInstance:
     Initializes the current instance of this program.
   **************************************************************************)
   PROCEDURE InitInstance(nCmdShow: INTEGER): BOOLEAN;
   VAR
     hWnd: Windows.HWND;        (* Windowhandle *)
     r:    LONGINT;             (* return-value (not needed) *)
     
   BEGIN
     hWnd := Windows.CreateWindow(SYSTEM.ADR(ClassName),
               SYSTEM.ADR("Bouncing ball"), Windows.WS_OVERLAPPEDWINDOW,
               Windows.CW_USEDEFAULT, Windows.CW_USEDEFAULT, 
               Windows.CW_USEDEFAULT, Windows.CW_USEDEFAULT,
               Windows.NULL, Windows.NULL, hInstance, Windows.NULL);   
               
     IF hWnd = 0 THEN
       RETURN FALSE  (* couldn't create window! *)
     END;

     (* check/uncheck menu-items. *)
     SetMenuState(hWnd);
          
     r := Windows.ShowWindow(hWnd, nCmdShow);
     Windows.UpdateWindow(hWnd);

     (* timer-messages for the bouncing-ball. *)
     r := Windows.SetTimer(hWnd, 1, TIMER_VALUE, Windows.NULL);
     RETURN TRUE;
   END InitInstance;
   

   (*************************************************************************
     WinMain:
     Windows calls WinMain when the user start the application.
     
     Parameters:
       hCurrInstance: handle of current istance
       hPrevInstance:  handle of previous instance
       lpscCmdLine:   command line for the application (null-terminated)
       nCmdShow:      specifies, how the window is to be shown
   **************************************************************************)
   PROCEDURE [WINDOWS] WinMain*(hCurrInstance: Windows.HINSTANCE;
                                hPrevInstance: Windows.HINSTANCE;
                                lpscCmdLine :  Windows.LPSTR;
                                nCmdShow    :  INTEGER): INTEGER;
                                
  VAR
    msg: Windows.MSG;          (* for message-loop *)                               
    r:   LONGINT;              (* return-value, not needed *)
    
  BEGIN
    hInstance := hCurrInstance;   (* store handle in global variable *)
    speed     := SPEED_NORMAL;    (* standard speed is normal  *)
    ChangeSpeed;                  (* update speed *)
    beep      := FALSE;           (* standard: no beep *)
    currentX  := SPEED_FACTOR*SPEED_WARP;  (* start-position *)
    currentY  := SPEED_FACTOR*SPEED_WARP; 
    start     := TRUE;            (* application just started *)
  
    (* Register windows-class. *)
    IF hPrevInstance = Windows.NULL THEN
      (* no previous instance => register class *)
      IF ~InitApplication() THEN
        r := Windows.MessageBox(Windows.NULL, 
                                SYSTEM.ADR("Couldn't register window class!"),
                                SYSTEM.ADR("BouncingError"),
                                Windows.MB_OK);
        RETURN Windows.false;
      END;        
    END;
    
    (* Create main window *)
    IF ~InitInstance(nCmdShow) THEN
      r := Windows.MessageBox(Windows.NULL,
                              SYSTEM.ADR("Couldn't create window!"),
                              SYSTEM.ADR("BouncingError"),
                              Windows.MB_OK);
      RETURN Windows.false;                                
    END;
    
    (* message-loop  *)
    WHILE Windows.GetMessage(SYSTEM.ADR(msg), Windows.NULL, Windows.NULL,
                             Windows.NULL) # 0
    DO
      (* TranslateMessage produces WM_CHAR messages only for keys that 
         are mapped to ASCII characters by the keyboard driver. *)
      r := Windows.TranslateMessage(SYSTEM.ADR(msg));
      
      (* The DispatchMessage function dispatches a message to a window
         procedure. *)
      r := Windows.DispatchMessage(SYSTEM.ADR(msg));
    END;                            
    
    (* Unregister window-class and reload resources with the next start *)
    r := Windows.UnregisterClass(SYSTEM.ADR(ClassName), hInstance);
    RETURN msg.wParam;
  END WinMain;
                            
  END Bouncing.                            
