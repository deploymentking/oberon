(***************************************************)
(***  FALLSTUDIEN  B E T R I E B S Y S T E M E   ***)
(***************************************************)
(***                  S p y                      ***)
(***************************************************)
(***       Christoph Dicklberger  9155883        ***)
(***       Klemens Dickbauer      9155844        ***)
(***************************************************)
(* 97/03/12 changes for windows callback functions *)

MODULE Spy;


IMPORT
   W := Windows, SYSTEM;


CONST
  IDM_INFO    = 101;
  IDM_RESET   = 102;
  IDM_EXIT    = 999;
  ID_LIST     = 1;

  CB_1        = 501;
  CB_2        = 502;
  CB_3        = 503;
  CB_4        = 504;

  PB_1        = 550;  
  PB_2        = 551;  

  className   = "MainClass";
  captionStr  = "Spy";        (* title string *)


VAR
  hInst   : W.HANDLE;
  hWnd, 
  hLst    : W.HWND;

  nrMess  : SHORTINT;
  
  prM1    : BOOLEAN;  (* boolean values for message classes *)
  prM2    : BOOLEAN;
  prM3    : BOOLEAN;
  prM4    : BOOLEAN;

(************************************************************************)


(* loop procedure to handle messages *)
PROCEDURE [WINDOWS] MainWndProc*(hWnd: W.HWND; message: W.WORD;
                                 wParam: W.WORD; lParam: LONGINT): LONGINT;
  VAR
    r : LONGINT;
    h : W.HWND;
BEGIN
  IF prM1 THEN        (* system *)
    INC(nrMess);
    CASE message OF
      W.WM_COMMAND       : r := W.SendMessage(hLst, W.LB_ADDSTRING, 0, SYSTEM.ADR("WM_COMMAND"));
    | W.WM_ACTIVATE      : r := W.SendMessage(hLst, W.LB_ADDSTRING, 0, SYSTEM.ADR("WM_ACTIVATE"));
    | W.WM_ACTIVATEAPP   : r := W.SendMessage(hLst, W.LB_ADDSTRING, 0, SYSTEM.ADR("WM_ACTIVATEAPP"));
    | W.WM_CHILDACTIVATE : r := W.SendMessage(hLst, W.LB_ADDSTRING, 0, SYSTEM.ADR("WM_CHILDACTIVATE"));
    | W.WM_CLOSE         : r := W.SendMessage(hLst, W.LB_ADDSTRING, 0, SYSTEM.ADR("WM_CLOSE"));
    | W.WM_PAINT         : r := W.SendMessage(hLst, W.LB_ADDSTRING, 0, SYSTEM.ADR("WM_PAINT"));
    | W.WM_MOVE          : r := W.SendMessage(hLst, W.LB_ADDSTRING, 0, SYSTEM.ADR("WM_MOVE"));
    ELSE
      DEC(nrMess);
    END;
  END;
  IF prM2 THEN        (* mouse *)
    INC(nrMess);
    CASE message OF
      W.WM_LBUTTONDOWN   : r := W.SendMessage(hLst, W.LB_ADDSTRING, 0, SYSTEM.ADR("WM_LBUTTONDOWN"));
    | W.WM_LBUTTONUP     : r := W.SendMessage(hLst, W.LB_ADDSTRING, 0, SYSTEM.ADR("WM_LBUTTONUP"));
    | W.WM_RBUTTONDOWN   : r := W.SendMessage(hLst, W.LB_ADDSTRING, 0, SYSTEM.ADR("WM_RBUTTONDOWN"));
    | W.WM_RBUTTONUP     : r := W.SendMessage(hLst, W.LB_ADDSTRING, 0, SYSTEM.ADR("WM_RBUTTONUP"));
    ELSE
      DEC(nrMess);
    END;
  END;
  IF prM3 THEN        (* key *)
    INC(nrMess);
    CASE message OF
      W.WM_KEYDOWN       : r := W.SendMessage(hLst, W.LB_ADDSTRING, 0, SYSTEM.ADR("WM_KEYDOWN"));
    | W.WM_KEYUP         : r := W.SendMessage(hLst, W.LB_ADDSTRING, 0, SYSTEM.ADR("WM_KEYUP"));
    ELSE
      DEC(nrMess);
    END;
  END;
  IF prM4 THEN        (* menu *)
    INC(nrMess);
    CASE message OF
      W.WM_INITMENU      : r := W.SendMessage(hLst, W.LB_ADDSTRING, 0, SYSTEM.ADR("WM_INITMENU"));
    | W.WM_INITMENUPOPUP : r := W.SendMessage(hLst, W.LB_ADDSTRING, 0, SYSTEM.ADR("WM_INITMENUPOPUP"));
    | W.WM_MENUSELECT    : r := W.SendMessage(hLst, W.LB_ADDSTRING, 0, SYSTEM.ADR("WM_MENUSELECT"));
    ELSE
      DEC(nrMess);
    END;
  END;

  (* delete list-entries if listbox is full *)
  IF nrMess >= 18 THEN
    r := W.SendMessage(hLst, W.LB_DELETESTRING, 0, 0);
    DEC(nrMess);
  END;

  (* dispatch messages *)
  IF message = W.WM_COMMAND THEN          

    IF (wParam = IDM_EXIT) OR (wParam = PB_2) THEN  (* exit application *)
      W.PostQuitMessage(0);
      
    ELSIF wParam = IDM_INFO THEN                    (* pop up info dialog *)
      r := W.MessageBox(hWnd, SYSTEM.ADR("Windows-Spy von Christoph Dicklberger und Klemens Dickbauer"), SYSTEM.ADR("Spy"), 
                        W.MB_OK + W.MB_ICONEXCLAMATION);

    ELSIF (wParam = IDM_RESET) OR (wParam = PB_1) THEN  (* clear listbox *)
      r := W.SendMessage(hLst, W.LB_RESETCONTENT, 0, 0);
      nrMess := 0;

    ELSIF wParam = CB_1 THEN                            (* click in first checkbox - system msgs *)
      IF prM1 THEN
        W.CheckDlgButton(hWnd, wParam, 0);
      ELSE  
        W.CheckDlgButton(hWnd, wParam, 1);
      END;
      prM1 := ~prM1;
    ELSIF wParam = CB_2 THEN                            (* click in second checkbox - mouse msgs *)
      IF prM2 THEN
        W.CheckDlgButton(hWnd, wParam, 0);
      ELSE  
        W.CheckDlgButton(hWnd, wParam, 1);
      END;
      prM2 := ~prM2;
    ELSIF wParam = CB_3 THEN                            (* click in third checkbox - key msgs *)
      IF prM3 THEN
        W.CheckDlgButton(hWnd, wParam, 0);
      ELSE  
        W.CheckDlgButton(hWnd, wParam, 1);
      END;
      prM3 := ~prM3;
    ELSIF wParam = CB_4 THEN                            (* click in fourth checkbox - menu msgs *)
      IF prM4 THEN
        W.CheckDlgButton(hWnd, wParam, 0);
      ELSE  
        W.CheckDlgButton(hWnd, wParam, 1);
      END;
      prM4 := ~prM4;

    ELSE  (* call default proc-handler *)
      RETURN W.DefWindowProc(hWnd, message, wParam, lParam)
    END; 

  ELSIF message = W.WM_DESTROY THEN       
    W.PostQuitMessage(0)

  ELSIF message = W.WM_CREATE THEN   (* build main window *)
    hLst := W.CreateWindow(SYSTEM.ADR("LISTBOX"), SYSTEM.ADR("Messages"),        (* listbox *)
                           W.WS_CHILD + W.WS_VISIBLE + W.WS_BORDER, 
                           300, 30, 160, 280, hWnd, ID_LIST, hInst, W.NULL);       
    h    := W.CreateWindow(SYSTEM.ADR("BUTTON"), SYSTEM.ADR("System Messages"),  (* the checkboxes *)
                           W.WS_CHILD + W.WS_VISIBLE + W.BS_CHECKBOX, 
                           50, 50, 150, 20, hWnd, CB_1, hInst, W.NULL);       
    h    := W.CreateWindow(SYSTEM.ADR("BUTTON"), SYSTEM.ADR("Mouse Messages"),
                           W.WS_CHILD + W.WS_VISIBLE + W.BS_CHECKBOX, 
                           50, 70, 150, 20, hWnd, CB_2, hInst, W.NULL);       
    h    := W.CreateWindow(SYSTEM.ADR("BUTTON"), SYSTEM.ADR("Key Messages"),
                           W.WS_CHILD + W.WS_VISIBLE + W.BS_CHECKBOX, 
                           50, 90, 150, 20, hWnd, CB_3, hInst, W.NULL);       
    h    := W.CreateWindow(SYSTEM.ADR("BUTTON"), SYSTEM.ADR("Menu Messages"),
                           W.WS_CHILD + W.WS_VISIBLE + W.BS_CHECKBOX, 
                           50, 110, 150, 20, hWnd, CB_4, hInst, W.NULL);       
    h    := W.CreateWindow(SYSTEM.ADR("BUTTON"), SYSTEM.ADR("Reset Listbox"),    (* the pushbuttons *)
                           W.WS_CHILD + W.WS_VISIBLE + W.BS_PUSHBUTTON,
                           50, 225, 150, 35, hWnd, PB_1, hInst, W.NULL);
    h    := W.CreateWindow(SYSTEM.ADR("BUTTON"), SYSTEM.ADR("Quit"),
                           W.WS_CHILD + W.WS_VISIBLE + W.BS_PUSHBUTTON,
                           50, 270, 150, 35, hWnd, PB_2, hInst, W.NULL);
    h    := W.CreateWindow(SYSTEM.ADR("BUTTON"), SYSTEM.ADR("Message Types"),    (* the groupbox *)
                           W.WS_CHILD + W.WS_VISIBLE + W.BS_GROUPBOX,
                           35, 25, 180, 110, hWnd, PB_2, hInst, W.NULL);
                           
    prM1 := FALSE; (* init checkboxes as not marked *)
    prM2 := FALSE; 
    prM3 := FALSE; 
    prM4 := FALSE; 

  ELSE                                   
    RETURN W.DefWindowProc(hWnd, message, wParam, lParam)
  END;
  
  r := W.SetFocus(hWnd);  (* activate main window in order to receive key msgs *)
  
  RETURN W.NULL;
END MainWndProc;

(************************************************************************)

(* standard procedure to init appliction instance *)
PROCEDURE InitApplication(): BOOLEAN;
  VAR wc: W.WNDCLASS;
BEGIN                                     
  wc.style := W.NULL;                   
  wc.lpfnWndProc := MainWndProc;
  wc.cbClsExtra := 0;                   
  wc.cbWndExtra := 0;                  
  wc.hInstance := hInst;              
  wc.hIcon := W.NULL;
  wc.hCursor := W.LoadCursor(W.NULL, W.IDC_ARROW);
  wc.hbrBackground := W.GetStockObject(W.WHITE_BRUSH);
  wc.lpszMenuName := W.NULL;   
  wc.lpszClassName := SYSTEM.ADR(className);
  RETURN W.RegisterClass(SYSTEM.ADR(wc)) # 0
END InitApplication;

(************************************************************************)

(* standard procedure to init appliction main window - build menu *)
PROCEDURE InitMainWindow(nCmdShow: INTEGER): BOOLEAN;
  VAR 
    r: INTEGER; 
    hMenu, hPopup : W.HMENU;
BEGIN                                    
  hWnd := W.CreateWindow(SYSTEM.ADR(className),
                         SYSTEM.ADR(captionStr),
                         W.WS_BORDER+W.WS_SYSMENU+W.WS_CAPTION+W.WS_MINIMIZEBOX,
                         0,
                         0, 
                         600, 
                         400, 
                         W.NULL,          
                         W.NULL,        
                         hInst,       
                         W.NULL);       
  IF hWnd = 0 THEN RETURN FALSE END;

  hMenu := W.CreateMenu();
  hPopup := W.CreateMenu();
  r := W.AppendMenu(hMenu, W.MF_POPUP + W.MF_STRING, hPopup, SYSTEM.ADR("&File"));
  r := W.AppendMenu(hPopup, W.MF_STRING, IDM_INFO, SYSTEM.ADR("&Info"));
  r := W.AppendMenu(hPopup, W.MF_SEPARATOR, -1, 0);
  r := W.AppendMenu(hPopup, W.MF_STRING, IDM_RESET, SYSTEM.ADR("&Reset MessageList"));
  r := W.AppendMenu(hPopup, W.MF_SEPARATOR, -1, 0);
  r := W.AppendMenu(hPopup, W.MF_STRING, IDM_EXIT, SYSTEM.ADR("E&xit"));
  r := W.SetMenu(hWnd, hMenu);
  
  r := W.ShowWindow(hWnd, W.SW_SHOWNORMAL);      
  W.UpdateWindow(hWnd);                  
  RETURN TRUE
END InitMainWindow;

(************************************************************************)

(* main program looping and waiting for user action *)
PROCEDURE [WINDOWS] WinMain*(hInstance: W.HANDLE; hPrevInstance: W.HANDLE;
                             lpCmdLine: W.LPSTR; nCmdShow: INTEGER): INTEGER;           
  VAR 
    r: LONGINT; msg: W.MSG;             
BEGIN
  nrMess := 0;
  hInst := hInstance;

  IF hPrevInstance = 0 THEN               
    IF ~InitApplication() THEN   
      RETURN W.false;                    
    END;
  END;

  IF ~InitMainWindow(nCmdShow) THEN RETURN W.false END;

  WHILE W.GetMessage(SYSTEM.ADR(msg), W.NULL, W.NULL, W.NULL) # 0 DO       
    r := W.TranslateMessage(SYSTEM.ADR(msg));
    r := W.DispatchMessage(SYSTEM.ADR(msg))  
  END;
  RETURN msg.wParam
END WinMain;

(************************************************************************)

BEGIN

END Spy.
