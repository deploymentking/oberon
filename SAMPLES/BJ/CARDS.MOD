(**************************************************************************)
(*                                                                        *)
(*  Fallstudien Betriebssysteme: Windowsprogrammierung mit Oberon-2       *)
(*  Abschlußprojekt:    Black Jack                                        *)
(*  Aufgabe:            Kartenspiel unter Verwendung von CARDS.DLL        *)
(*                                                                        *)
(*  Modulname:          CARDS.MOD                                         *)
(*  Aufgabe:            Funktionalität von Karten und Kartenlisten        *)
(*                                                                        *)
(*  Autoren:            Gschnell Christian, 9155609, 880                  *)
(*                      Jungwirth Josef,    9155355, 880                  *)
(*                      Köttstorfer Marco,  9155255, 880                  *)
(*                                                                        *)
(*  Erstellt am:        16. April 1995 - TCard, TCardList                 *)
(*  Änderungen:                                                           *)
(*                                                                        *)
(**************************************************************************)

MODULE Cards;

IMPORT W := Windows, G := General;

CONST MAXCARDS* = 52;
      CARDDISTANCE* = 15;
      BACKGROUNDNO* = 1;

TYPE PCard* = POINTER TO TCard;     
     TCard* = RECORD(G.TBitmap)
       valency-      : SHORTINT; 
     END;                                         (* Objektklasse für Karten *)

     PCardList* = POINTER TO TCardList;
     TCardList* = RECORD(G.TDrawable)
       noOfCards-      : SHORTINT;
       cardList-       : ARRAY MAXCARDS OF PCard;
       visible-        : BOOLEAN;
       invisibleShape- : G.PBitmap;
     END;        (* Objektklasse für Kartensammlungen (offene und verdeckte) *)

VAR cardList- : PCardList;
    
(*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*)

PROCEDURE InitCard*(c : PCard; aHandle : W.HBITMAP; aValency : SHORTINT);
BEGIN
  G.InitBitmap(c, aHandle);
  c.valency := aValency;
END InitCard;

(*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*)

PROCEDURE InitCardList*(l : PCardList; aVisible : BOOLEAN; 
                                       aInvisibleShape : G.PBitmap);
BEGIN
  G.InitDrawable(l, 0, 0);
  l.noOfCards      := 0;
  l.visible        := aVisible;
  l.invisibleShape := aInvisibleShape;
END InitCardList;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR l : TCardList) SetVisible*(aVisible : BOOLEAN; 
                                          aInvisibleShape : G.PBitmap);
BEGIN
  l.visible        := aVisible;
  l.invisibleShape := aInvisibleShape;
END SetVisible;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR l : TCardList) Insert*(aElem : PCard);
BEGIN
  ASSERT(l.noOfCards < MAXCARDS);
  l.cardList[l.noOfCards] := aElem;
  INC(l.noOfCards);
END Insert;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR l : TCardList) Retrieve*() : PCard;
BEGIN
  ASSERT(l.noOfCards > 0);
  DEC(l.noOfCards);
  RETURN l.cardList[l.noOfCards];
END Retrieve;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR l : TCardList) Shuffle*();
  (* Karten mischen nach dem Algorithmus von Durstenfeld                     *)
VAR i, j : INTEGER;
    random : G.PRandomNumber;
    help : PCard;
BEGIN
  NEW(random); G.InitRandomNumber(random);
  FOR i := l.noOfCards-1 TO 1 BY -1 DO
    j := random.GetNumber(i);
    help := l.cardList[i]; l.cardList[i] := l.cardList[j]; l.cardList[j] := help;
  END;
  random.Destroy(); DISPOSE(random);
END Shuffle;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR l : TCardList) Merge*(VAR mergeL : TCardList);
  (* Mischt die Karten von "mergeL" in die Kartenliste "l" hinein. "mergeL"  *)
  (* ist anschließend leer                                                   *)
VAR i : SHORTINT;
BEGIN
  FOR i := 0 TO mergeL.noOfCards-1 DO
    l.cardList[l.noOfCards+i] := mergeL.cardList[i];
  END;
  INC(l.noOfCards, mergeL.noOfCards);
  mergeL.noOfCards := 0;
END Merge;
  
(*---------------------------------------------------------------------------*)

PROCEDURE (VAR l : TCardList) Zap*();
VAR i : SHORTINT;
BEGIN
  l.noOfCards := 0;
END Zap;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR l : TCardList) GetCardSum*() : INTEGER;
  (* Liefert die Summe der Kartenwertigkeiten (As als 11 gerechnet)          *)
VAR i : SHORTINT;
    sum : INTEGER;
BEGIN
  sum := 0;
  FOR i := 0 TO l.noOfCards-1 DO sum := sum + l.cardList[i].valency; END;
  RETURN sum;
END GetCardSum;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR l : TCardList) GetNoOfAces*() : INTEGER;
  (* Liefert die Anzahl der Assen in der Kartenliste                         *)
VAR i : SHORTINT;
    sum : INTEGER;
BEGIN
  sum := 0;
  FOR i := 0 TO l.noOfCards-1 DO
    IF (l.cardList[i].valency = 11) THEN INC(sum) END;
  END;
  RETURN sum;
END GetNoOfAces;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR l : TCardList) GetBestCardSum*() : INTEGER;
  (* Liefert die Summe der Kartenwertigkeiten (Assen als 1 oder 11           *)
  (* gerechnet, daß der größte Wert <= 21 herauskommt)                       *)
VAR i : SHORTINT;
    sum : INTEGER;
    aces : INTEGER;
    dec : INTEGER;
BEGIN
  sum := l.GetCardSum();
  aces := l.GetNoOfAces();
  WHILE ((aces > 0) & (sum > 21)) DO
    DEC(aces);
    DEC(sum, 10);
  END;
  RETURN sum;
END GetBestCardSum;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR l : TCardList) IsBlackJack*() : BOOLEAN;
BEGIN
  RETURN (l.noOfCards = 2) & (l.GetCardSum() = 21);
END IsBlackJack;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR l : TCardList) IsTriplet*() : BOOLEAN;
  (* Liefert den Wahrheitswert, ob die Kartenliste ein 7er-Drilling ist      *)
BEGIN
  RETURN (l.noOfCards = 3) &
         (l.cardList[0].valency = 7) &
         (l.cardList[1].valency = 7) &
         (l.cardList[2].valency = 7);
END IsTriplet;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR l : TCardList) IsTileable*() : BOOLEAN;
  (* Liefert den Wahrheitswert, ob die Kartenliste teilbar ist               *)
BEGIN
  RETURN (l.noOfCards = 2) & (l.cardList[0].valency = l.cardList[1].valency);
END IsTileable;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR l : TCardList) IsDoubleable*() : BOOLEAN;
  (* Liefert den Wahrheitswert, ob für die Kartenliste Verdoppeln möglich    *)
  (* ist                                                                     *)
VAR sum : INTEGER;
    aces : INTEGER;
BEGIN
  IF (l.noOfCards # 2) THEN RETURN FALSE END;
  aces := l.GetNoOfAces();
  sum := l.GetCardSum();
  WHILE ((aces > 0) & ~((sum >= 9) & (sum <= 11))) DO
    DEC(aces);
  END;
  RETURN (sum >= 9) & (sum <= 11);
END IsDoubleable;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR l : TCardList) Tile*(VAR hand2 : TCardList);
  (* Teilt die Kartenliste "l" auf "l" und "hand2" auf                       *)
BEGIN
  ASSERT(l.IsTileable());
  l.noOfCards := 1;
  hand2.Insert(l.cardList[1]);
END Tile;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR l1 : TCardList) Compare*(l2 : PCardList) : SHORTINT;
  (* Vergleich die Wertigkeit der Kartenliste. Liefert:                      *)
  (*   +1 : Wenn "l1" "l2" schlägt                                           *)
  (*    0 : Wenn "l1" und "l2" gleichwertig                                  *)
  (*   -1 : Wenn "l1" von "l2" geschlagen wird                               *)
  (* Die Ausnahmestellung des Black Jack wird nicht behandelt                *)
VAR sum1 : INTEGER;
    sum2 : INTEGER;
BEGIN
  sum1 := l1.GetBestCardSum();
  sum2 := l2.GetBestCardSum();
  IF (sum1 > 21) THEN sum1 := -2 END;
  IF (sum2 > 21) THEN sum2 := -1 END;
  IF    (sum1 > sum2) THEN RETURN +1
  ELSIF (sum1 < sum2) THEN RETURN -1
  ELSE                     RETURN 0
  END;
END Compare;

(*---------------------------------------------------------------------------*)

PROCEDURE (VAR l : TCardList) Draw*(dc : W.HDC);
VAR i : SHORTINT;
BEGIN
  IF l.visible THEN
    FOR i := 0 TO l.noOfCards-1 DO
      l.cardList[i].DrawOffs(dc, l.x+i*CARDDISTANCE, l.y);
    END;
  ELSIF (l.noOfCards > 0) THEN
    l.invisibleShape.DrawOffs(dc, l.x, l.y);
  END;
END Draw;

(*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*)

PROCEDURE LoadCards*(cDLL : W.HINSTANCE);
VAR i : SHORTINT;
    valency : SHORTINT;
    backGround : G.PBitmap;
    card : PCard;
BEGIN
  NEW(backGround); G.InitBitmap(backGround, W.LoadBitmap(cDLL, (MAXCARDS+BACKGROUNDNO)));
  NEW(cardList); InitCardList(cardList, FALSE, backGround);
  FOR i := 0 TO MAXCARDS-1 DO
    IF (i MOD 13 = 0) THEN valency := 11;
    ELSIF (i MOD 13 >= 9) THEN valency := 10;
    ELSE valency := i MOD 13 + 1;
    END;
    NEW(card); InitCard(card, W.LoadBitmap(cDLL, i+1), valency);
    cardList.Insert(card);
  END;
END LoadCards;

PROCEDURE DeleteCards*();
VAR i : SHORTINT;
    card : PCard;
BEGIN
  ASSERT(W.DeleteObject(cardList.invisibleShape.handle) # 0);
  cardList.invisibleShape.Destroy(); DISPOSE(cardList.invisibleShape);
  FOR i := 0 TO MAXCARDS-1 DO
    card := cardList.Retrieve();
    ASSERT(W.DeleteObject(card.handle) # 0);
    card.Destroy(); DISPOSE(card);
  END;
  cardList.Destroy(); DISPOSE(cardList);
END DeleteCards;

END Cards.