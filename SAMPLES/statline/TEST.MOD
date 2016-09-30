(******************************************************************************
 * MODULE:        Test
 * DESCRIPTION:   This program tests the custom control StatLine.dll.
 * LANGUAGE:      Oberon-2
 * COPYRIGHT BY:  Peter René Dietmüller, dietmueller@fim.uni-linz.ac.at (PDI)
 ******************************************************************************
 * DATE      AUTHOR  CHANGES
 * --------  ------  ----------------------------------------------------------
 * 94/11/22  PDI     Version 1.0
 * 96/08/22  SK      see (*SK*)
 * 97/03/11  PDI     minor changes for windows callback functions
 ******************************************************************************)
MODULE Test;


  IMPORT Strings, StatLine, SYSTEM, Windows;


  CONST
    ClassName   = "MainWindow";
    WindowTitle = "Statusbar Demo";
    
    IDM_FILE_EXIT = 20001;
    
    IDM_STATUSBAR_FIRST  = 20101;
    IDM_STATUSBAR_SECOND = 20102;
    IDM_STATUSBAR_THIRD  = 20103;
    IDM_STATUSBAR_FOURTH  = 20104;
    
    IDM_TEXTHEIGHT_12    = 30112;   (*SK2*)
    IDM_TEXTHEIGHT_20    = 30120;   (*SK2*)
    
    IDM_STATUSBAR_UP     = 30201;   (*SK4*)
    IDM_STATUSBAR_DOWN   = 30202;   (*SK4*)
    IDM_SHOW_HEIGHT      = 30301;   (*SK6*)


  VAR
    hWndBar:     Windows.HWND;
    hInstance:   Windows.HINSTANCE;
    

(******************************************************************************
 *
 * FUNCTION:
 * DisplayError pops up a message box showing an error text.
 *
 * PRECONDITIONS:  --
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * title          
 * msg
 ******************************************************************************)
PROCEDURE DisplayError(title: ARRAY OF CHAR; msg: ARRAY OF CHAR);
  VAR r: INTEGER;
BEGIN
  r := Windows.MessageBox(Windows.NULL, SYSTEM.ADR(msg), SYSTEM.ADR(title), Windows.MB_OK);
END DisplayError;



(******************************************************************************
 *
 * FUNCTION:
 * WndProc is the so called "callback function" for the window displayed by
 * this application. WndProc is called by Windows every time Windows wants 
 * to send a message to the window. 
 *
 * PRECONDITIONS:  --
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hWnd           window handle
 * message        message for the window
 * wParam         first parameter for the message
 * lParam         second parameter for the message
 ******************************************************************************)
PROCEDURE [WINDOWS] WndProc*(hWnd:   Windows.HWND; 
                             msg:    Windows.WORD; 
                             wParam: Windows.WORD; 
                             lParam: LONGINT): LONGINT;
  VAR
    hdc:    Windows.HDC;
    ps:     Windows.PAINTSTRUCT;
    r:      LONGINT;
    text:   ARRAY 100 OF CHAR;
    height: INTEGER;
    
BEGIN

  IF msg = Windows.WM_PAINT THEN
    hdc := Windows.BeginPaint(hWnd, SYSTEM.ADR(ps));
    Windows.EndPaint(hWnd, SYSTEM.ADR(ps));
    RETURN 0;
    
  ELSIF msg = Windows.WM_SIZE THEN
    r := Windows.SendMessage(hWndBar, Windows.WM_SIZE, 0, 0);
    RETURN 0; 

  ELSIF msg = Windows.WM_DESTROY THEN
    Windows.PostQuitMessage(0);
    RETURN 0;

  ELSIF msg = Windows.WM_COMMAND THEN
    IF wParam = IDM_FILE_EXIT THEN
      RETURN Windows.DestroyWindow(hWnd);
    ELSIF wParam = IDM_STATUSBAR_FIRST THEN
      StatLine.SetText(hWndBar, "Haha, first try.");
    ELSIF wParam = IDM_STATUSBAR_SECOND THEN
      StatLine.SetText(hWndBar, "Wow, second try.");
    ELSIF wParam = IDM_STATUSBAR_THIRD THEN
      StatLine.SetText(hWndBar, "Oops, third try.");
    ELSIF wParam = IDM_STATUSBAR_FOURTH THEN
      StatLine.SetText(hWndBar, "Uhh, fourth try.");
    ELSIF wParam = IDM_TEXTHEIGHT_12 THEN              (*SK2*)
      StatLine.SetFont(hWndBar,12);                    (*SK2*)
    ELSIF wParam = IDM_TEXTHEIGHT_20 THEN              (*SK2*)
      StatLine.SetFont(hWndBar,20);                    (*SK2*)
    ELSIF wParam = IDM_STATUSBAR_UP THEN               (*SK4*)
      StatLine.SetPosition(hWndBar,0 );                (*SK4*)
    ELSIF wParam = IDM_STATUSBAR_DOWN THEN             (*SK4*)
      StatLine.SetPosition(hWndBar,1);                 (*SK4*)
    ELSIF wParam = IDM_SHOW_HEIGHT THEN                (*SK6*)
      height := StatLine.GetHeight(hWndBar);           (*SK6*)
      Strings.Str(height, text);
      Strings.Insert("Höhe der Statuszeile ", text, 0);
      StatLine.SetText(hWndBar, text);
    END;
    RETURN 0;

  ELSIF msg = Windows.WM_MENUSELECT THEN
    IF Windows.LoadString(hInstance, wParam, SYSTEM.ADR(text), LEN(text)) > 0 THEN
      StatLine.SetText(hWndBar, text);
    ELSE
      StatLine.SetText(hWndBar, " ");
    END;
    RETURN 0;

  ELSE
    RETURN Windows.DefWindowProc(hWnd, msg, wParam, lParam)

  END;

END WndProc;



(******************************************************************************
 *
 * FUNCTION:
 * InitApplication registers all window classes.
 *
 * PRECONDITIONS:  --
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hInstCurr      instance handle of the current instance
 ******************************************************************************)
PROCEDURE InitApplication(hInstCurr: Windows.HINSTANCE): BOOLEAN;
  VAR wc: Windows.WNDCLASS;
BEGIN

  (* -- register application specific classes -- *)
  wc.style         := Windows.NULL;
  wc.lpfnWndProc   := WndProc; 
  wc.cbClsExtra    := 0;
  wc.cbWndExtra    := 0;
  wc.hInstance     := hInstCurr;
  wc.hIcon         := Windows.NULL;
  wc.hCursor       := Windows.LoadCursor(Windows.NULL, Windows.IDC_ARROW);
  wc.hbrBackground := Windows.GetStockObject(Windows.WHITE_BRUSH);
  wc.lpszMenuName  := SYSTEM.ADR("Main");
  wc.lpszClassName := SYSTEM.ADR(ClassName);
  IF Windows.RegisterClass(SYSTEM.ADR(wc)) = 0 THEN
    DisplayError("InitApplication", "Could not register my window class.");
    RETURN FALSE
  END;
  RETURN TRUE

END InitApplication;



(******************************************************************************
 *
 * FUNCTION:
 * InitInstance performs the initialisation for the current instance of this
 * program. It creates the main Window.
 *
 * PRECONDITIONS:
 * The window class used by this program should be registered. (InitApplication)
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hInstCurr      instance handle of the current instance
 * nCmdShow       ??
 ******************************************************************************)
PROCEDURE InitInstance(hInstCurr: Windows.HINSTANCE; nCmdShow: INTEGER): BOOLEAN;

  VAR
    hWnd: Windows.HWND;
    r:    LONGINT;

BEGIN

  (* -- create main window -- *)
  hWnd := Windows.CreateWindow(
          SYSTEM.ADR(ClassName), SYSTEM.ADR(WindowTitle),
          Windows.WS_OVERLAPPEDWINDOW, 
          Windows.CW_USEDEFAULT, Windows.CW_USEDEFAULT, 
          Windows.CW_USEDEFAULT, Windows.CW_USEDEFAULT, 
          Windows.NULL, Windows.NULL, 
          hInstCurr, Windows.NULL);
  IF hWnd = 0 THEN
    DisplayError("InitInstance", "Could not create the main window");
    RETURN FALSE
  END;
  r := Windows.ShowWindow(hWnd, nCmdShow);
  Windows.UpdateWindow(hWnd);

  (* -- open Statusbar -- *)
  hWndBar := StatLine.Create(hWnd, hInstCurr);
  ASSERT(hWndBar # 0);
  r := Windows.ShowWindow(hWndBar, nCmdShow);
  Windows.UpdateWindow(hWndBar);

  RETURN TRUE;

END InitInstance;



(******************************************************************************
 *
 * FUNCTION:
 * WinMain is the "main program". It is automartically called by Windows when
 * the user starts this application. It displays a simple window with the 
 * standard features of windows like moving, sizing and system menu.
 *
 * PRECONDITIONS:  --
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hInstCurr      instance handle for the current instance of this application
 * hInstPrev      instance handle for the previously loaded instance
 * lpCmdLine      command line (far pointer to a null terminated string)
 * nCmdShow       This parameter says how the main window should be displayed.
 ******************************************************************************)
PROCEDURE [WINDOWS] WinMain*(hInstCurr: Windows.HINSTANCE; 
                             hInstPrev: Windows.HINSTANCE; 
                             lpCmdLine: Windows.LPSTR; 
                             nCmdShow:  INTEGER): INTEGER;
  VAR
    msg: Windows.MSG;
    r:   LONGINT;
    
BEGIN

  hInstance := hInstCurr;
  
  (* -- initialize first instance -- *)
  IF (hInstPrev = Windows.NULL) & ~InitApplication(hInstCurr) THEN
    RETURN Windows.false;
  END;

  (* -- initialize the current instance -- *)
  IF ~InitInstance(hInstCurr, nCmdShow) THEN
    RETURN Windows.false;
  END; 

  (* -- standard message loop -- *)
  WHILE Windows.GetMessage(SYSTEM.ADR(msg), Windows.NULL, Windows.NULL, Windows.NULL) # 0 DO
    r := Windows.TranslateMessage(SYSTEM.ADR(msg)); 
    r := Windows.DispatchMessage(SYSTEM.ADR(msg));
  END;

  RETURN msg.wParam
  
END WinMain;


END Test.
