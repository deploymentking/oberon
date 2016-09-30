(******************************************************************************
 * MODULE:        Control
 * DESCRIPTION:   This program shows various controls.
 * LANGUAGE:      Oberon-2
 * COPYRIGHT BY:  Peter René Dietmüller, dietmueller@fim.uni-linz.ac.at (PDI)
 ******************************************************************************
 * DATE      AUTHOR  CHANGES
 * --------  ------  ----------------------------------------------------------
 * 95/03/29  PDI     Version 1.0
 * 97/03/11  PDI     minor changes for windows callback functions
 ******************************************************************************)
MODULE Control;

  IMPORT W := Windows, SYSTEM;

  CONST 
    ClassName  = "CControlTest";
    WindowName = "Control Demo";
    IDTRANSFER = 20000;
    IDEXIT     = 20001;
    IDEDIT     = 20002;
    IDFILE     = 20003;
    IDTEXT     = 20004;
    IDOPEN     = 20005;

  TYPE
    MINMAXINFOP = POINTER TO W.MINMAXINFO;

  VAR
    hInstance:    W.HINSTANCE;
    hWndFiles:    W.HWND;
    hWndEdit:     W.HWND;
    hWndExit:     W.HWND;
    hWndOpen:     W.HWND;
    hWndText:     W.HWND;
    hWndTransfer: W.HWND;


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
 *
 * FUNCTION:
 * CreateControls create some conrols.
 *
 * PRECONDITIONS: 
 * The parent window hWnd must have been created.
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************
 * PARAMETER      DESCRIPTION
 * -------------- -------------------------------------------------------------
 * hWnd           handle of the parent window
 ******************************************************************************)
PROCEDURE CreateControls(hWnd: W.HWND);
  VAR r: LONGINT;
BEGIN
  hWndEdit     := W.CreateWindow(SYSTEM.ADR("EDIT"), W.NULL, 
                  W.ES_MULTILINE + W.ES_AUTOHSCROLL + W.ES_AUTOVSCROLL + 
                  W.WS_BORDER + W.WS_VSCROLL + W.WS_HSCROLL + W.WS_CHILD + W.WS_VISIBLE,
                  10, 10, 400, 200, hWnd, IDEDIT, hInstance, W.NULL);
  hWndText     := W.CreateWindow(SYSTEM.ADR("STATIC"), SYSTEM.ADR("Default"), 
                  W.WS_BORDER + W.WS_CHILD + W.WS_VISIBLE,
                  10, 224, 400, 200, hWnd, IDTEXT, hInstance, W.NULL);
  hWndTransfer := W.CreateWindow(SYSTEM.ADR("BUTTON"), SYSTEM.ADR("Copy"), 
                  W.BS_DEFPUSHBUTTON + W.WS_CHILD + W.WS_VISIBLE,
                  430, 10, 150, 40, hWnd, IDTRANSFER, hInstance, W.NULL);
  hWndExit     := W.CreateWindow(SYSTEM.ADR("BUTTON"), SYSTEM.ADR("Exit"), 
                  W.BS_DEFPUSHBUTTON + W.WS_CHILD + W.WS_VISIBLE,
                  430, 60, 150, 40, hWnd, IDEXIT, hInstance, W.NULL);
  hWndOpen     := W.CreateWindow(SYSTEM.ADR("BUTTON"), SYSTEM.ADR("Open"), 
                  W.BS_DEFPUSHBUTTON + W.WS_CHILD + W.WS_VISIBLE,
                  430, 110, 150, 40, hWnd, IDOPEN, hInstance, W.NULL);
  hWndFiles    := W.CreateWindow(SYSTEM.ADR("LISTBOX"), W.NULL, 
                  W.LBS_SORT + W.WS_BORDER + W.WS_VSCROLL + W.WS_CHILD + W.WS_VISIBLE,
                  430, 224, 150, 200, hWnd, IDFILE, hInstance, W.NULL);
  r := W.SendMessage(hWndEdit, W.WM_SETFONT, W.GetStockObject(W.SYSTEM_FIXED_FONT), 0);
  r := W.SendMessage(hWndFiles, W.LB_DIR, 4010, SYSTEM.ADR("*.*"));
END CreateControls;


(******************************************************************************
 *
 * FUNCTION:
 * DestroyControls destroys all controls created by the function CreateControls.
 *
 * PRECONDITIONS:
 * The function CreateControls must have been called before to create the 
 * controls.
 *
 * POSTCONDITIONS: --
 *
 ******************************************************************************)
PROCEDURE DestroyControls;
  VAR r: INTEGER;
BEGIN
  r := W.DestroyWindow(hWndEdit);
  r := W.DestroyWindow(hWndText);
  r := W.DestroyWindow(hWndFiles);
  r := W.DestroyWindow(hWndTransfer);
  r := W.DestroyWindow(hWndExit);
  r := W.DestroyWindow(hWndOpen);
END DestroyControls;


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
    buffer: POINTER TO ARRAY OF CHAR;
    hFile:  W.HFILE;
    index:  INTEGER;
    len:    INTEGER;
    minmax: MINMAXINFOP;
    r:      LONGINT;
    
BEGIN

  IF message = W.WM_CREATE THEN
    CreateControls(hWnd);
    RETURN 0;

  ELSIF message = W.WM_DESTROY THEN
    DestroyControls;
    W.PostQuitMessage(0);
    RETURN 0;

  ELSIF message = W.WM_SETFOCUS THEN
    r := W.SetFocus(hWndEdit);
    RETURN 0;

  ELSIF message = W.WM_GETMINMAXINFO THEN
    minmax := SYSTEM.VAL(MINMAXINFOP, lParam);
    minmax^.ptMinTrackSize.x := 600;
    minmax^.ptMinTrackSize.y := 460;
    minmax^.ptMaxTrackSize.x := 600;
    minmax^.ptMaxTrackSize.y := 460;    
    RETURN 0;

  ELSIF message = W.WM_COMMAND THEN
    IF wParam = IDEXIT THEN
      r := W.DestroyWindow(hWnd);
    ELSIF wParam = IDTRANSFER THEN
      len := SYSTEM.VAL(INTEGER, W.SendMessage(hWndEdit, W.WM_GETTEXTLENGTH, 0, 0));
      IF len # W.LB_ERR THEN
        NEW(buffer, len + 1);
        r := W.SendMessage(hWndEdit, W.WM_GETTEXT, len, SYSTEM.ADR(buffer^));
        r := W.SendMessage(hWndText, W.WM_SETTEXT, 0, SYSTEM.ADR(buffer^));
        DISPOSE(buffer);
      END;
    ELSIF wParam = IDOPEN THEN
      index := SYSTEM.VAL(INTEGER, W.SendMessage(hWndFiles, W.LB_GETCURSEL, 0, 0));
      IF index # W.LB_ERR THEN
        len := SYSTEM.VAL(INTEGER, W.SendMessage(hWndFiles, W.LB_GETTEXTLEN, index, 0));
        IF len # W.LB_ERR THEN
          NEW(buffer, len + 1);
          r := W.SendMessage(hWndFiles, W.LB_GETTEXT, index, SYSTEM.ADR(buffer^));
          hFile := W._lopen(SYSTEM.ADR(buffer^), W.READ);
          IF hFile # W.HFILE_ERROR THEN
            DISPOSE(buffer);
            NEW(buffer, 4096);
            r := W._lread(hFile, SYSTEM.ADR(buffer^), 4095);
            buffer^[r] := 0X;
            r := W._lclose(hFile);
            r := W.SendMessage(hWndEdit, W.WM_SETTEXT, 0, SYSTEM.ADR(buffer^));
          ELSE 
            DspErrMsg("Could not open the selected file.");
          END;
          DISPOSE(buffer);
        END;
      ELSE
        DspErrMsg("No entry in the listbox selected.");
      END;
    ELSE
      RETURN W.DefWindowProc(hWnd, message, wParam, lParam)
    END;
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
  wc.style         := W.NULL;
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
                             nCmdShow:  INTEGER):          INTEGER;
  VAR
    msg: W.MSG;
    r:   LONGINT;
    
BEGIN

  hInstance := hInstCurr;
  
  (* -- initialize first instance -- *)
  IF (hInstPrev = W.NULL) & ~InitApplication(hInstCurr) THEN
    DspErrMsg("Could not register main window class.");
    RETURN W.false;
  END;

  (* -- initialize the current instance -- *)
  IF ~InitInstance(hInstCurr, nCmdShow) THEN
    DspErrMsg("Could not create main window");
    RETURN W.false;
  END; 
  
  (* -- standard message loop -- *)
  WHILE W.GetMessage(SYSTEM.ADR(msg), W.NULL, W.NULL, W.NULL) # 0 DO
    r := W.TranslateMessage(SYSTEM.ADR(msg)); 
    r := W.DispatchMessage(SYSTEM.ADR(msg));
  END;
  RETURN msg.wParam
  
END WinMain;


END Control.
