MODULE Debug;

  IMPORT Strings, SYSTEM, Windows;
  

PROCEDURE DisplayInt*(a: LONGINT);

  VAR
    text: ARRAY 20 OF CHAR;
    r:    INTEGER;
    
BEGIN
  Strings.Str(a, text);
  r := Windows.MessageBox(Windows.NULL, SYSTEM.ADR(text), SYSTEM.ADR("DEBUG"), Windows.MB_OK);
END DisplayInt;

END Debug.