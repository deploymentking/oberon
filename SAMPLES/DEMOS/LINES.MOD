(******************************************************************************
 * MODULE:        Lines
 * DESCRIPTION:   This program shows various lines.
 * LANGUAGE:      Oberon-2
 * COPYRIGHT BY:  Peter René Dietmüller, dietmueller@fim.uni-linz.ac.at (PDI)
 ******************************************************************************
 * DATE      AUTHOR  CHANGES
 * --------  ------  ----------------------------------------------------------
 * 95/03/28  PDI     Version 1.0
 * 96/04/25  PDI     minor changes in DspErrMsg, WM_SIZE, class styles
 * 96/03/11  PDI     minor changes for windows callback functions
 ******************************************************************************)
MODULE Lines;

  IMPORT W := Windows, SYSTEM;

  CONST  ClassName  = "CLineTest";
         WindowName = "Line Demo";


(******************************************************************************
 * DspErrMsg pops up a message box showing an error text.
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * msg
 ******************************************************************************)
PROCEDURE DspErrMsg(msg: ARRAY OF CHAR);
  VAR r: INTEGER;
BEGIN
  r := W.MessageBox(W.NULL, SYSTEM.ADR(msg), SYSTEM.ADR("Error"), W.MB_OK);
END DspErrMsg;


(******************************************************************************
 * RGB transforms an rgb-value consisting of three seperate values for red, green
 * and blue into one value needed for some GDI-functions.
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * r              value for red (0..255)
 * g              value for green (0..255)
 * b              value for blue (0..255)
 ******************************************************************************)
PROCEDURE RGB(r,g,b: INTEGER): LONGINT;
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
PROCEDURE DisplayMainWindow(hWnd: W.HWND; hdc: W.HDC);

  VAR 
    i:         INTEGER;
    hPenOld:   W.HPEN;
    hPen:      W.HPEN;
    r:         LONGINT;
    wnd:       W.RECT;
    
BEGIN

  (* -- get size of client area -- *)
  W.GetClientRect(hWnd, SYSTEM.ADR(wnd));
  
  (* -- draw a solid line -- *)
  hPen := W.CreatePen(W.PS_SOLID, 1, RGB(0,0,255));
  IF hPen # W.NULL THEN
    hPenOld := W.SelectObject(hdc, hPen);
    r := W.MoveTo(hdc, wnd.left, wnd.top);
    r := W.LineTo(hdc, wnd.right, wnd.bottom);
    hPenOld := W.SelectObject(hdc, hPenOld);
    r := W.DeleteObject(hPen);
  END;
  
  (* -- draw some dashed lines -- *)
  hPen := W.CreatePen(W.PS_DASH, 1, RGB(0,255,0));
  IF hPen # W.NULL THEN
    hPenOld := W.SelectObject(hdc, hPen);
    FOR i := wnd.top + 10 TO wnd.bottom - 10 BY 10 DO
      r := W.MoveTo(hdc, wnd.left  + 10, i);
      r := W.LineTo(hdc, wnd.right - 10, i);
    END;
    hPenOld := W.SelectObject(hdc, hPenOld);
    r := W.DeleteObject(hPen);
  END;
  
  (* -- draw some doted lines -- *)
  hPen := W.CreatePen(W.PS_DOT, 1, RGB(255,0,0));
  IF hPen # W.NULL THEN
    hPenOld := W.SelectObject(hdc, hPen);
    FOR i := wnd.top + 15 TO wnd.bottom - 10 BY 10 DO
      r := W.MoveTo(hdc, wnd.left  + 10, i);
      r := W.LineTo(hdc, wnd.right - 10, i);
    END;
    hPenOld := W.SelectObject(hdc, hPenOld);
    r := W.DeleteObject(hPen);
  END;
  
END DisplayMainWindow;


(******************************************************************************
 * WndProc is the so called "callback function" for the window displayed by
 * this application. WndProc is called by Windows every time Windows wants 
 * to send a message to the window. 
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hWnd           window handle
 * message        message for the window
 * wParam         first parameter for the message
 * lParam         second parameter for the message
 ******************************************************************************)
PROCEDURE [WINDOWS] WndProc*(hWnd:    W.HWND; 
                             message: W.WORD; 
                             wParam:  W.WORD; 
                             lParam:  LONGINT): LONGINT;
  VAR
    hdc:    W.HDC;
    ps:     W.PAINTSTRUCT;
    r:      INTEGER;
    
BEGIN

  IF message = W.WM_DESTROY THEN
    W.PostQuitMessage(0);
    RETURN 0;

  ELSIF message = W.WM_PAINT THEN
    hdc := W.BeginPaint(hWnd, SYSTEM.ADR(ps));
    DisplayMainWindow(hWnd, hdc);
    W.EndPaint(hWnd, SYSTEM.ADR(ps));
    RETURN 0;

  ELSE
    RETURN W.DefWindowProc(hWnd, message, wParam, lParam)

  END;
  RETURN 0;

END WndProc;


(******************************************************************************
 * InitApplication registers all window classes.
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hInstCurr      instance handle of the current instance
 ******************************************************************************)
PROCEDURE InitApplication(hInstCurr: W.HINSTANCE): BOOLEAN;
  VAR wc: W.WNDCLASS;
BEGIN

  (* -- register application specific classes -- *)
  wc.style         := W.CS_HREDRAW + W.CS_VREDRAW;
  wc.lpfnWndProc   := WndProc;
  wc.cbClsExtra    := 0;
  wc.cbWndExtra    := 0;
  wc.hInstance     := hInstCurr;
  wc.hIcon         := W.NULL;
  wc.hCursor       := W.LoadCursor(W.NULL, W.IDC_ARROW);
  wc.hbrBackground := W.GetStockObject(W.WHITE_BRUSH);
  wc.lpszMenuName  := W.NULL;
  wc.lpszClassName := SYSTEM.ADR(ClassName);
  RETURN W.RegisterClass(SYSTEM.ADR(wc)) # 0;
    
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
PROCEDURE InitInstance(hInstCurr: W.HINSTANCE; nCmdShow: INTEGER): BOOLEAN;

  VAR
    hWnd:  W.HWND;
    r:     LONGINT;

BEGIN

  (* -- create main window -- *)
  hWnd := W.CreateWindow(
          SYSTEM.ADR(ClassName), SYSTEM.ADR(WindowName), 
          W.WS_OVERLAPPEDWINDOW, 
          W.CW_USEDEFAULT, W.CW_USEDEFAULT, 
          W.CW_USEDEFAULT, W.CW_USEDEFAULT, 
          W.NULL, W.NULL, 
          hInstCurr, W.NULL);
  IF hWnd = 0 THEN RETURN FALSE END;
  r := W.ShowWindow(hWnd, nCmdShow);
  RETURN TRUE;

END InitInstance;



(******************************************************************************
 * WinMain is the "main program". It is automartically called by Windows when
 * the user starts this application. It displays a simple window with the 
 * standard features of windows like moving, sizing and system menu.
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hInstCurr      instance handle for the current instance of this application
 * hInstPrev      instance handle for the previously loaded instance
 * lpCmdLine      command line (far pointer to a null terminated string)
 * nCmdShow       This parameter says how the main window should be displayed.
 ******************************************************************************)
PROCEDURE [WINDOWS] WinMain*(hInstCurr: W.HINSTANCE; 
                             hInstPrev: W.HINSTANCE;
                             lpCmdLine: W.LPSTR;
                             nCmdShow:  INTEGER): INTEGER;
  VAR
    msg: W.MSG;
    r:   LONGINT;
    
BEGIN

  (* -- initialize first instance -- *)
  IF (hInstPrev = W.NULL) & ~InitApplication(hInstCurr) THEN
    DspErrMsg("Global Initialization didn't work!");
  END;

  (* -- initialize the current instance -- *)
  IF ~InitInstance(hInstCurr, nCmdShow) THEN
    DspErrMsg("Local Initialization didn't work!");
    RETURN W.false;
  END; 
  
  (* -- standard message loop -- *)
  WHILE W.GetMessage(SYSTEM.ADR(msg), W.NULL, W.NULL, W.NULL) # 0 DO
    r := W.TranslateMessage(SYSTEM.ADR(msg)); 
    r := W.DispatchMessage(SYSTEM.ADR(msg));
  END;
  RETURN msg.wParam
  
END WinMain;

END Lines.
