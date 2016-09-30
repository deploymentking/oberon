(******************************************************************************
 * MODULE:        Colors
 * DESCRIPTION:   This program shows various colors.
 * LANGUAGE:      Oberon-2
 * COPYRIGHT BY:  Peter René Dietmüller, dietmueller@fim.uni-linz.ac.at (PDI)
 ******************************************************************************
 * DATE      AUTHOR  CHANGES
 * --------  ------  ----------------------------------------------------------
 * 95/03/28  PDI     Version 1.0
 * 96/04/25  PDI     minor changes in DisplayError, WM_SIZE, class styles
 * 97/03/11  PDI     minor changes for windows callback functions
 ******************************************************************************)
MODULE Colors;


  IMPORT Windows, SYSTEM;


  CONST 
    ClassName  = "CColorTest";
    WindowName = "Color Demo";


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
PROCEDURE DisplayError(msg: ARRAY OF CHAR);
  VAR r: INTEGER;
BEGIN
  r := Windows.MessageBox(Windows.NULL, SYSTEM.ADR(msg), SYSTEM.ADR("Error"), Windows.MB_OK);
END DisplayError;



(******************************************************************************
 *
 * FUNCTION:
 * RGB transforms an rgb-value consisting of three seperate values for red, green
 * and blue into one value needed for some GDI-functions.
 *
 * PRECONDITIONS:  --
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * r              value for red (0..255)
 * g              value for green (0..255)
 * b              value for blue (0..255)
 ******************************************************************************)
PROCEDURE RGB(r,g,b: INTEGER): Windows.COLORREF;
BEGIN
  RETURN (b * 256 + g) * 256 + r
END RGB;



(******************************************************************************
 *
 * FUNCTION:
 * DisplayMainWindow draws the main. This procedure is designed to be called
 * in response to a WM_PAINT message.
 *
 * PRECONDITIONS: 
 * BeginPaint or GetDC should be called before to get the device contect handle
 * for the window.
 *
 * POSTCONDITIONS: 
 * In a WM_PAINT message EndPaint should be called. Otherwise the device context
 * handle should be released by calling ReleaseDC.
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hWnd           handle of the window which should be drawn
 * hdc            handle of the device context of the window passed by hWnd
 ******************************************************************************)
PROCEDURE DisplayMainWindow(hWnd: Windows.HWND; hdc: Windows.HDC);

  VAR 
    box:       Windows.RECT;
    i,j:       INTEGER;
    hBrush:    Windows.HBRUSH;
    height:    INTEGER;
    hOldBrush: Windows.HBRUSH;
    hOldPen:   Windows.HPEN;
    hPen:      Windows.HPEN;
    r:         LONGINT;
    wnd:       Windows.RECT;
    width:     INTEGER;
    
BEGIN

  (* -- get size of client area -- *)
  Windows.GetClientRect(hWnd, SYSTEM.ADR(wnd));

  (* -- draw 1024 rectangles with different colors -- *)
  hPen := Windows.CreatePen(Windows.PS_SOLID, 2, RGB(255, 255, 255));
  IF hPen # Windows.NULL THEN

    hOldPen := Windows.SelectObject(hdc, hPen);
    
    width := (wnd.right - wnd.left) DIV 32;
    height := (wnd.bottom - wnd.top) DIV 32;

    FOR i := 0 TO 255 BY 8 DO
      FOR j := 0 TO 255 BY 8 DO
        hBrush := Windows.CreateSolidBrush(RGB(i+7, 0, j+7));
        IF hBrush # Windows.NULL THEN
          box.left   := (i * width) DIV 8;
          box.top    := (j * height) DIV 8;
          box.right  := box.left + width;
          box.bottom := box.top + height;
          hOldBrush := Windows.SelectObject(hdc, hBrush);
          r := Windows.Rectangle(hdc, box.left, box.top, box.right, box.bottom);
          hOldBrush := Windows.SelectObject(hdc, hOldBrush);
          r := Windows.DeleteObject(hBrush);
        END;
      END;
    END;
    
    hOldPen := Windows.SelectObject(hdc, hOldPen);
    r := Windows.DeleteObject(hPen);
    
  END;
  
END DisplayMainWindow;



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
PROCEDURE [WINDOWS] WndProc*(hWnd:    Windows.HWND; 
                             message: Windows.WORD; 
                             wParam:  Windows.WORD; 
                             lParam:  LONGINT): LONGINT;

  VAR
    hdc:    Windows.HDC;
    ps:     Windows.PAINTSTRUCT;
    r:      INTEGER;
    
BEGIN

  IF message = Windows.WM_DESTROY THEN
    Windows.PostQuitMessage(0);
    RETURN 0;

  ELSIF message = Windows.WM_PAINT THEN
    hdc := Windows.BeginPaint(hWnd, SYSTEM.ADR(ps));
    DisplayMainWindow(hWnd, hdc);
    Windows.EndPaint(hWnd, SYSTEM.ADR(ps));
    RETURN 0;

  ELSE
    RETURN Windows.DefWindowProc(hWnd, message, wParam, lParam)

  END;
  RETURN 0;

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
  wc.style         := Windows.CS_HREDRAW + Windows.CS_VREDRAW;
  wc.lpfnWndProc   := WndProc;
  wc.cbClsExtra    := 0;
  wc.cbWndExtra    := 0;
  wc.hInstance     := hInstCurr;
  wc.hIcon         := Windows.NULL;
  wc.hCursor       := Windows.LoadCursor(Windows.NULL, Windows.IDC_ARROW);
  wc.hbrBackground := Windows.GetStockObject(Windows.WHITE_BRUSH);
  wc.lpszMenuName  := Windows.NULL;
  wc.lpszClassName := SYSTEM.ADR(ClassName);
  RETURN Windows.RegisterClass(SYSTEM.ADR(wc)) # 0;
    
END InitApplication;



(******************************************************************************
 *
 * FUNCTION:
 * InitInstance performs the initialisation for the current instance of this
 * program. It creates the main window.
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
          SYSTEM.ADR(ClassName), SYSTEM.ADR("Colors"), 
          Windows.WS_OVERLAPPEDWINDOW, 
          Windows.CW_USEDEFAULT, Windows.CW_USEDEFAULT, 512, 512, 
          Windows.NULL, Windows.NULL, 
          hInstCurr, Windows.NULL);
  IF hWnd = 0 THEN RETURN FALSE END;
  r := Windows.ShowWindow(hWnd, nCmdShow);
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
                             nCmdShow:  INTEGER):          INTEGER;
  VAR
    msg: Windows.MSG;
    r:   LONGINT;
    
BEGIN

  (* -- initialize first instance -- *)
  IF (hInstPrev = Windows.NULL) & ~InitApplication(hInstCurr) THEN
    DisplayError("Global initialization didn't work!");
    RETURN Windows.false;
  END;

  (* -- initialize the current instance -- *)
  IF ~InitInstance(hInstCurr, nCmdShow) THEN
    DisplayError("Local initialization didn't work!");
    RETURN Windows.false;
  END; 
  
  (* -- standard message loop -- *)
  WHILE Windows.GetMessage(SYSTEM.ADR(msg), Windows.NULL, Windows.NULL, Windows.NULL) # 0 DO
    r := Windows.TranslateMessage(SYSTEM.ADR(msg)); 
    r := Windows.DispatchMessage(SYSTEM.ADR(msg));
  END;
  RETURN msg.wParam
  
END WinMain;


END Colors.
