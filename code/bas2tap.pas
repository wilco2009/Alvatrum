unit bas2tap;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math;

procedure bas_to_tap(FileNameIn: String; FileNameOut: String; AutoStart: word; BlockName: string);

implementation

const
  MAXLINELENGTH=1024;
  DEFFN        =$CE;
  SHIFT31BITS = 2147483648.0;  //* (= 2^31) */



type
  pchar = ^char;
  TokenMap_s = record
    Token: string;
    TokenType: byte;
          { Type   0 = No special meaning                                                   }
          { Type   1 = Always keyword                                                       }
          { Type   2 = Can be both keyword and non-keyword (colour parameters)              }
          { Type   3 = Numeric expression token                                             }
          { Type   4 = String expression token                                              }
          { Type   5 = May only appear in (L)PRINT statements (AT and TAB)                  }
          { Type   6 = Type-less (normal ASCII or expression token)                         }

          { The class this keyword belongs to, as defined in the Spectrum ROM }
    KeywordClass: array [0..7] of char;
          { This table is used by expression tokens as well. Class 12 was added for this purpose }
          { Class  0 = No further operands                                                  }
          { Class  1 = Used in LET. A variable is required                                  }
          { Class  2 = Used in LET. An expression, numeric or string, must follow           }
          { Class  3 = A numeric expression may follow. Zero to be used in case of default  }
          { Class  4 = A single character variable must follow                              }
          { Class  5 = A set of items may be given                                          }
          { Class  6 = A numeric expression must follow                                     }
          { Class  7 = Handles colour items                                                 }
          { Class  8 = Two numeric expressions, separated by a comma, must follow           }
          { Class  9 = As for class 8 but colour items may precede the expression           }
          { Class 10 = A string expression must follow                                      }
          { Class 11 = Handles cassette routines                                            }
          { The following classes are not available in the ROM but were needed              }
          { Class 12 = One or more string expressions, separated by commas, must follow     }
          { Class 13 = One or more expressions, separated by commas, must follow            }
          { Class 14 = One or more variables, separated by commas, must follow (READ)       }
          { Class 15 = DEF FN                                                               }
  end;

  TapeHeader_s = record
    LenLo1:     byte;
    LenHi1:     byte;
    Flag1:      byte;
    HType:      byte;
    HName:      array[0..9] of char;
    HLenLo:     byte;
    HLenHi:     byte;
    HStartLo:   byte;
    HStartHi:   byte;
    HBasLenLo:  byte;
    HBasLenHi:  byte;
    Parity1:    byte;
    LenLo2:     byte;
    LenHi2:     byte;
    Flag2:      byte;
  end;

var
   TokenMap: array [0..255] of TokenMap_s =

   { Everything below ASCII 32 }
   (
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),               { Print ' }
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#13; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),                                                                                                   { CR }
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),               { Number }
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),               { INK }
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),               { PAPER }
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),               { FLASH }
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),               { BRIGHT }
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),               { INVERSE }
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),               { OVER }
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),               { AT }
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),               { TAB }
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:''; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),

   { Normal ASCII set }
   (Token:#$20; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$21; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$22; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$23; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$24; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$25; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$26; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$27; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$28; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$29; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$2A; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$2B; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$2C; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$2D; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$2E; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$2F; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$30; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$31; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$32; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$33; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$34; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$35; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$36; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$37; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$38; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$39; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$3A; TokenType:2; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$3B; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$3C; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$3D; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$3E; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$3F; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$40; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$41; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$42; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$43; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$44; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$45; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$46; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$47; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$48; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$49; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$4A; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$4B; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$4C; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$4D; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$4E; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$4F; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$50; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$51; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$52; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$53; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$54; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$55; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$56; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$57; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$58; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$59; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$5A; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$5B; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$5C; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$5D; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$5E; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$5F; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$60; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$61; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$62; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$63; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$64; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$65; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$66; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$67; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$68; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$69; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$6A; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$6B; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$6C; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$6D; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$6E; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$6F; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$70; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$71; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$72; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$73; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$74; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$75; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$76; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$77; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$78; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$79; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$7A; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$7B; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$7C; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$7D; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$7E; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$7F; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),

   { Block graphics without shift }
   (Token:#$80; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$81; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$82; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$83; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$84; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$85; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$86; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$87; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),

   { Block graphics with shift }
   (Token:#$88; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$89; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$8A; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$8B; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$8C; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$8D; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$8E; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$8F; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),

   { UDGs }
   (Token:#$90; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$91; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$92; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$93; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$94; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$95; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$96; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$97; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$98; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$99; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$9A; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$9B; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$9C; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$9D; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$9E; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$9F; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$A0; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )), (Token:#$A1; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:#$A2; TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),

   (Token:'SPECTRUM';  TokenType:1; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),                                                                                   { For Spectrum 128 }
   (Token:'PLAY';      TokenType:1; KeywordClass:( #12,#0,#0,#0,#0,#0,#0,#0)),

   { BASIC tokens - expression }
   (Token:'RND';       TokenType:3; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:'INKEY$';    TokenType:4; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:'PI';        TokenType:3; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:'FN';        TokenType:3; KeywordClass:( #1, '(', #13, ')', #0,#0,#0,#0 )),
   (Token:'POINT';     TokenType:3; KeywordClass:( '(', #8, ')', #0,#0,#0,#0,#0 )),
   (Token:'SCREEN$';   TokenType:4; KeywordClass:( '(', #8, ')', #0,#0,#0,#0,#0 )),
   (Token:'ATTR';      TokenType:3; KeywordClass:( '(', #8, ')', #0,#0,#0,#0,#0 )),
   (Token:'AT';        TokenType:5; KeywordClass:( #8, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'TAB';       TokenType:5; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'VAL$';      TokenType:4; KeywordClass:( #10, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'CODE';      TokenType:3; KeywordClass:( #10, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'VAL';       TokenType:3; KeywordClass:( #10, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'LEN';       TokenType:3; KeywordClass:( #10, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'SIN';       TokenType:3; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'COS';       TokenType:3; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'TAN';       TokenType:3; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'ASN';       TokenType:3; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'ACS';       TokenType:3; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'ATN';       TokenType:3; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'LN';        TokenType:3; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'EXP';       TokenType:3; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'INT';       TokenType:3; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'SQR';       TokenType:3; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'SGN';       TokenType:3; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'ABS';       TokenType:3; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'PEEK';      TokenType:3; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'IN';        TokenType:3; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'USR';       TokenType:3; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'STR$';      TokenType:4; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'CHR$';      TokenType:4; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'NOT';       TokenType:3; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'BIN';       TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:'OR';        TokenType:6; KeywordClass:( #5, #0,#0,#0,#0,#0,#0,#0 )),   {  -\                                                  }
   (Token:'AND';       TokenType:6; KeywordClass:( #5, #0,#0,#0,#0,#0,#0,#0 )),   {   |                                                  }
   (Token:'<=';        TokenType:6; KeywordClass:( #5, #0,#0,#0,#0,#0,#0,#0 )),   {   | These are handled directly within ScanExpression }
   (Token:'>=';        TokenType:6; KeywordClass:( #5, #0,#0,#0,#0,#0,#0,#0 )),   {   |                                                  }
   (Token:'<>';        TokenType:6; KeywordClass:( #5, #0,#0,#0,#0,#0,#0,#0 )),   {  -/                                                  }
   (Token:'LINE';      TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:'THEN';      TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:'TO';        TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:'STEP';      TokenType:6; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),

   { BASIC tokens - keywords }
   (Token:'DEF FN';    TokenType:1; KeywordClass:( #15, #0,#0,#0,#0,#0,#0,#0 )),                 { Special treatment - insertion of call-by-value room required for the evaluator }
   (Token:'CAT';       TokenType:1; KeywordClass:( #11, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'FORMAT';    TokenType:1; KeywordClass:( #11, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'MOVE';      TokenType:1; KeywordClass:( #11, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'ERASE';     TokenType:1; KeywordClass:( #11, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'OPEN #';    TokenType:1; KeywordClass:( #11, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'CLOSE #';   TokenType:1; KeywordClass:( #11, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'MERGE';     TokenType:1; KeywordClass:( #11, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'VERIFY';    TokenType:1; KeywordClass:( #11, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'BEEP';      TokenType:1; KeywordClass:( #8, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'CIRCLE';    TokenType:1; KeywordClass:( #9, ',', #6, #0,#0,#0,#0,#0)),
   (Token:'INK';       TokenType:2; KeywordClass:( #7, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'PAPER';     TokenType:2; KeywordClass:( #7, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'FLASH';     TokenType:2; KeywordClass:( #7, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'BRIGHT';    TokenType:2; KeywordClass:( #7, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'INVERSE';   TokenType:2; KeywordClass:( #7, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'OVER';      TokenType:2; KeywordClass:( #7, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'OUT';       TokenType:1; KeywordClass:( #8, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'LPRINT';    TokenType:1; KeywordClass:( #5, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'LLIST';     TokenType:1; KeywordClass:( #3, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'STOP';      TokenType:1; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:'READ';      TokenType:1; KeywordClass:( #14, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'DATA';      TokenType:2; KeywordClass:( #13, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'RESTORE';   TokenType:1; KeywordClass:( #3, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'NEW';       TokenType:1; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:'BORDER';    TokenType:1; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'CONTINUE';  TokenType:1; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:'DIM';       TokenType:1; KeywordClass:( #1, '(', #13, ')', #0,#0,#0,#0 )),
   (Token:'REM';       TokenType:1; KeywordClass:( #5, #0,#0,#0,#0,#0,#0,#0 )),                                                                 { (Special: taken out separately) }
   (Token:'FOR';       TokenType:1; KeywordClass:( #4, '=', #6, #$CC, #6, #$CD, #6, #0 )),                                { (Special: STEP (#$CD) is not required) }
   (Token:'GO TO';     TokenType:1; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'GO SUB';    TokenType:1; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'INPUT';     TokenType:1; KeywordClass:( #5, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'LOAD';      TokenType:1; KeywordClass:( #11, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'LIST';      TokenType:1; KeywordClass:( #3, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'LET';       TokenType:1; KeywordClass:( #1, '=', #2, #0,#0,#0,#0,#0 )),
   (Token:'PAUSE';     TokenType:1; KeywordClass:( #6, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'NEXT';      TokenType:1; KeywordClass:( #4, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'POKE';      TokenType:1; KeywordClass:( #8, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'PRINT';     TokenType:1; KeywordClass:( #5, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'PLOT';      TokenType:1; KeywordClass:( #9, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'RUN';       TokenType:1; KeywordClass:( #3, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'SAVE';      TokenType:1; KeywordClass:( #11, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'RANDOMIZE'; TokenType:1; KeywordClass:( #3, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'IF';        TokenType:1; KeywordClass:( #6, #$CB, #0,#0,#0,#0,#0,#0 )),
   (Token:'CLS';       TokenType:1; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:'DRAW';      TokenType:1; KeywordClass:( #9, ',', #6, #0,#0,#0,#0,#0 )),
   (Token:'CLEAR';     TokenType:1; KeywordClass:( #3, #0,#0,#0,#0,#0,#0,#0 )),
   (Token:'RETURN';    TokenType:1; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )),
   (Token:'COPY';      TokenType:1; KeywordClass:( #0,#0,#0,#0,#0,#0,#0,#0 )));

   ConvertedSpectrumLine: array [0..MAXLINELENGTH] of char;
   ResultingLine: array [0..MAXLINELENGTH] of byte;

   TapeHeader: TapeHeader_s = (LenLo1:19; LenHi1:0;                                      { Len header }
                Flag1:0; HType:0; HName:(' ',' ',' ',' ',' ',' ',' ',' ',' ',' ');       { Flag header }
                HLenLo:0; HLenHi:0; HStartLo:0; HStartHi:128; HBasLenLo:0; HBasLenHi:0;  { The header itself }
                Parity1:0;                                                               { Parity header }
                LenLo2:0; LenHi2:0;                                                      { Len converted BASIC }
                Flag2:255);                                                              { Flag converted BASIC }
   TapeHeaderA: Array[0..19] of byte absolute TapeHeader;
   Is48KProgram: integer    = -1;      { -1 = unknown }
                                       {  1 = 48K     }
                                       {  0 = 128K    }
   UsesInterface1: integer  = -1;      { -1 = unknown }
                                       {  0 = either Interface1 or Opus Discovery }
                                       {  1 = Interface1                          }
                                       {  2 = Opus Discovery                      }
   CaseIndependant: boolean = FALSE;
   Quiet: boolean           = FALSE;   {  Suppress banner and progress indication if TRUE }
   NoWarnings: boolean      = FALSE;   {  Suppress warnings if TRUE }
   DoCheckSyntax: boolean   = TRUE;
   TokenBracket: boolean    = FALSE;
   HandlingDEFFN: boolean   = FALSE;   {  Exceptional instruction }
   InsideDEFFN: boolean     = FALSE;

   //**********************************************************************************************************************************/
   //* Let's be lazy and define a very commonly used error message....                                                                */
   //**********************************************************************************************************************************/

   procedure Message(S: String);
   begin
     writeln(s);
   end;

   procedure BADTOKEN(Exp: string; Got: string; BasicLineNo: integer; StatementNo: integer);
   begin
     writeln('ERROR in line ',BasicLineNo,' statement ', StatementNo, ' - Expected ', Exp, 'but got ', Got);
   end;

   //**********************************************************************************************************************************/
   //* And let's generate tons of debugging info too....                                                                              */
   //**********************************************************************************************************************************/

   {$IFDEF __DEBUG__}
     ListSpaces: array [0..19] of char;
     RecurseLevel: integer;
   {$endif}
   //**********************************************************************************************************************************/
   //* Prototype all functions                                                                                                        */
   //**********************************************************************************************************************************/

   function GetLineNumber(var FirstAfter: pchar): integer; forward;
   function MatchToken (BasicLineNo: integer; WantKeyword: boolean; var LineIndex: pchar; var Token: char): integer; forward;
   function HandleNumbers     (BasicLineNo: integer; var BasicLine: pchar; var SpectrumLine: pchar): integer; forward;
   function HandleBIN         (BasicLineNo: integer; var BasicLine: pchar; var SpectrumLine: pchar): integer; forward;
   function ExpandSequences   (BasicLineNo: integer; var BasicLine: pchar; var SpectrumLine: pchar; StripSpaces: boolean): integer; forward;
   function PrepareLine       (LineIn: pchar; FileLineNo: integer; var FirstToken: pchar): integer; forward;
   function ScanVariable      (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var index: pchar; var tType: boolean; var NameLen: integer; AllowSlicing: integer): boolean; forward;
   function SliceDirectString (BasicLineNo: integer; StatementNo: integer; Keyword: integer; Index: pchar): boolean; forward;
   function ScanStream        (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var index: pchar): boolean; forward;
   function ScanChannel (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar; var WhichChannel: byte): boolean; forward;
   function SignalInterface1  (BasicLineNo: integer; StatementNo: integer; NewMode: integer): boolean; forward;
   function CheckEnd          (BasicLineNo: integer; StatementNo: integer; var index: pchar): boolean; forward;
   function ScanExpression    (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var index: pchar; var tType: boolean; Level: integer): boolean; forward;
   function HandleClass01     (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var index: pchar; var tType: boolean): boolean; forward;
   function HandleClass02 (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar; tType: boolean): boolean; forward;
   function HandleClass03     (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var index: pchar): boolean; forward;
   function HandleClass04     (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var index: pchar): boolean; forward;
   function HandleClass05     (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var index: pchar): boolean; forward;
   function HandleClass06     (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var index: pchar): boolean; forward;
   function HandleClass07     (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var index: pchar): boolean; forward;
   function HandleClass08     (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var index: pchar): boolean; forward;
   function HandleClass09     (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var index: pchar): boolean; forward;
   function HandleClass10     (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var index: pchar): boolean; forward;
   function HandleClass11     (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var index: pchar): boolean; forward;
   function HandleClass12 (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar): boolean; forward;
   function HandleClass13     (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var index: pchar): boolean; forward;
   function HandleClass14     (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var index: pchar): boolean; forward;
   function HandleClass15     (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var index: pchar): boolean; forward;
   function CheckSyntax       (BasicLineNo: integer; Line: pchar): boolean; forward;

   //**********************************************************************************************************************************/
   //* Start of the program                                                                                                           */
   //**********************************************************************************************************************************/
  procedure ErrorLine(msg1: string; BasicLineNo: integer; StatementLineNo: integer);
  begin
    writeln('ERROR in line '+inttostr(BasicLineNo)+', statement '+inttostr(StatementLineNo)+msg1);
  end;

  procedure ErrorLine(msg1: string; BasicLineNo: integer);
  begin
    writeln('ERROR in line '+inttostr(BasicLineNo)+' '+msg1);
  end;

  procedure ErrorLine(msg1: string; BasicLineNo: integer; StatementLineNo: integer; msg2:string);
  begin
   writeln('ERROR in line '+inttostr(BasicLineNo)+', statement '+inttostr(StatementLineNo)+msg1+' '+msg2);
  end;

  function x_strnicmp (_S1: pchar; _S2: pchar; _Len: integer):integer; //* Case independant partial string compare */
  begin
    while (_Len <>0) and (_S1^<>#0) and (_S2^<>#0) and (upcase(_S1^) = upcase(_S2^)) do
    begin
      inc(_S1);
      inc(_S2);
      dec(_Len);
    end;
    if _len > 0 then
    begin
       x_strnicmp := ord(upcase(_s1^)) - ord (upcase(_s2^));
    end else begin
       x_strnicmp := 0;
    end;
  end;

  function strncpy (dest: pchar; source: pchar; n: integer): pchar;
   var
     i: integer;
     d: pchar;
   begin
     d := dest;
     for i:= 0 to n-1 do
     begin
       dest^ := source^;
       inc(dest);
       inc(source);
     end;
     strncpy := d;
   end;

   function strnicmp (str1: pchar; str2: pchar; n: integer): integer;
   begin
     strnicmp := x_strnicmp (str1, str2, n);
   end;

   function is_digit (c: char): boolean;
   begin
     is_digit := c in ['0'..'9'];
   end;

   function is_alfa (c:char): boolean;
   begin
     is_alfa := c in ['A'..'Z','a'..'z'];
   end;

   function is_xdigit(c: char): boolean;
   begin
     is_xdigit := c in ['A'..'F','a'..'f','0'..'9'];
   end;

   function is_alnum (c: char): boolean;
   begin
     is_alnum := c in ['A'..'Z','a'..'z','0'..'9'];
   end;


   function GetLineNumber(var FirstAfter: pchar): integer;

   //**********************************************************************************************************************************/
   //* Pre   : The line must have been prepared into (global) `ConvertedSpectrumLine'.                                                */
   //* Post  : The BASIC line number has been returned, or -1 if there was none.                                                      */
   //* Import: None.                                                                                                                  */
   //**********************************************************************************************************************************/

   var
      LineNo: integer     = 0;
      LineIndex: pchar;
      SkipSpaces: boolean = TRUE;
      Continue: boolean   = TRUE;


   begin
     //LineIndex = ConvertedSpectrumLine;
     LineIndex := @ConvertedSpectrumLine[0];
     while (LineIndex^ <> #0) and Continue do
     begin
       if LineIndex^ = ' ' then     // Skip leading spaces */
       begin
         if SkipSpaces then
           inc(LineIndex)
         else
           Continue := FALSE;
       end
       else if is_digit (LineIndex^) then // Process number */
       begin
         LineNo := LineNo * 10 + ord(LineIndex^) - ord('0');
         inc(LineIndex);
         SkipSpaces := FALSE;
       end
       else
         Continue := FALSE;
     end;
     FirstAfter := LineIndex;
     if (SkipSpaces) then                    // Nothing found yet ? */
       GetLineNumber := -1
     else
       while FirstAfter^ = ' ' do        //* Skip trailing spaces */
         inc(FirstAfter);
     GetLineNumber := LineNo;
   end;

  function MatchToken (BasicLineNo: integer; WantKeyword: boolean; var LineIndex: pchar; var Token: char): integer;

  //**********************************************************************************************************************************/
  //* Pre   : `WantKeyword' is TRUE if we need in keyword match, `LineIndex' holds the position to match.                            */
  //* Post  : If there was a match, the token value is returned in `Token' and `LineIndex' is pointing after the string plus any     */
  //*         any trailing space.                                                                                                    */
  //*         The return value is 0 for no match, -2 for an error, -1 for a match of the wrong type, 1 for a good match.             */
  //* Import: None.                                                                                                                  */
  //**********************************************************************************************************************************/
  var
    Cnt: byte;
    Len: Qword;
    LongestMatch: Qword = 0;
    Match: boolean = FALSE;
    Match2: boolean;
  begin
   if LineIndex^ = ':' then        // Special exception */
   begin
     LongestMatch := 1;
     Match := TRUE;
     Token := ':';
   end
   else for Cnt := $A3 to $FF do  // (Keywords start after the UDGs) */
   begin
     Len := length(TokenMap[Cnt].Token);
     if CaseIndependant then
       Match2 := x_strnicmp(LineIndex, @TokenMap[Cnt].Token[1], Len) = 0
     else
       Match2 := strnicmp (LineIndex, @TokenMap[Cnt].Token[1], Len) = 0;
     if Match2 then
       if Len > LongestMatch then
       begin
         LongestMatch := Len;
         Match := TRUE;
         Token := chr(Cnt);
       end;
   end;
   if not Match then
   begin
     MatchToken := 0; //* Signal: no match */
     exit;
   end;
   if is_alfa ((LineIndex + LongestMatch - 1)^) and
      is_alfa ((LineIndex + LongestMatch)^) then //* Continueing alpha string ? */
   begin
     MatchToken := 0;  //* Then there's no match after all! (eg. 'INT' must not match 'INTER') */
     exit;
   end;
   LineIndex += LongestMatch;                          //* Go past the token */
   while (LineIndex^ = ' ') do   //* Skip trailing spaces */
     inc(LineIndex);
   if (Token = #$A3) or (Token = #$A4) then        //* 'SPECTRUM' or 'PLAY' ? */
     case Is48KProgram of                          //* Then the program must be 128K */
       -1: Is48KProgram := 0;                      //* Set the flag */
       +1:
       begin
         writeln('ERROR - Line ', BasicLineNo,' contains a 128K keyword, but the program'+
                 'also uses UDGs T and/or U');
         MatchToken := -2;
         exit;
       end;
       +0 : begin end;{break;}
     end;
   if WantKeyword and (TokenMap[ord(Token)].TokenType = 0) or        //* Wanted keyword but got something else */
      (not WantKeyword and (TokenMap[ord(Token)].TokenType = 1)) then //* Did not want a keyword but got one nonetheless */
   begin
     MatchToken := -1; //* Signal: match, but of wrong type */
     exit;
   end else begin
     MatchToken := 1;  //* Signal: match! */
     exit;
   end;
  end;


  function HandleNumbers     (BasicLineNo: integer; var BasicLine: pchar; var SpectrumLine: pchar): integer;

  //**********************************************************************************************************************************/
  //* Pre   : `BasicLineNo' holds the current BASIC line number, `BasicLine' points into the line, `SpectrumLine' points to the      */
  //*         TAPped Spectrum line.                                                                                                  */
  //* Post  : If there was a (floating point) number at this position, it has been processed into `SpectrumLine' and `LineIndex' is  */
  //*         pointing after the number.                                                                                             */
  //*         The return value is: 0 = no number, 1 = number done, -1 = number error (already reported).                             */
  //* Import: None.                                                                                                                  */
  //**********************************************************************************************************************************/
  var
    StartOfNumber: pchar;
    Value: double   = 0.0;
    Divider: double = 1.0;
    Exp: double     = 0.0;
    IntValue: integer;
    Sign: byte      = $00;
    Mantissa: Qword;

  begin
    if (not is_digit (BasicLine^)) and  //* Current character is not a digit ? */
      (BasicLine^ <> '.') then         //* And not a decimal point (eg. '.5') ? */
    begin
      HandleNumbers := 0;       //* Then it can hardly be a number */
      exit;
    end;
    StartOfNumber := BasicLine;
    while is_digit (BasicLine^) do  //* First read the integer part */
    begin
      Value := Value * 10 + ord(BasicLine^) - ord('0');
      inc(BasicLine);
    end;
    if BasicLine^ = '.' then  //* Decimal point ? */
    begin                                           // Read the decimal part */
      inc(BasicLine);
      while (is_digit (BasicLine^)) do
      begin
        Divider := Divider / 10;
        Value := Value + Divider * ord(BasicLine^) - ord('0');
        inc(BasicLine);
      end;
    end;
    if (BasicLine^ = 'e') or (BasicLine^ = 'E') then //* Exponent ? */
    begin
      inc(BasicLine);
      if (BasicLine^ = '+') then  //* Both "Ex" and "E+x" do the same thing */
        inc(BasicLine)
      else if BasicLine^='-' then //* Negative exponent */
      begin
        Sign := $FF;
        inc(BasicLine);
      end;
      while (is_digit (BasicLine^)) do      //* Read the exponent value */
      begin
        Exp := Exp * 10 + ord(BasicLine^) - ord('0');
        inc(BasicLine);
      end;
      if (Sign = $00) then      //* Raise the resulting value to the read exponent */
        Value := Value * power (10.0, Exp)
      else
        Value := Value / power (10.0, Exp);
    end;
    strncpy (SpectrumLine, StartOfNumber, BasicLine - StartOfNumber);     //* Insert the ASCII value first */
    SpectrumLine += BasicLine - StartOfNumber;
    IntValue := round(Value);
    if (Value = IntValue) and (Value >= -65536) and (Value < 65536) then  //* Small integer ? */
    begin
      SpectrumLine^ := #$0E;    //* Insert number marker */
      inc(SpectrumLine);
      SpectrumLine^ := #$00;
      inc(SpectrumLine);
      if (IntValue >= 0) then  //* Insert sign */
      begin
        SpectrumLine^ := #$00;
        inc(SpectrumLine);
      end else begin
        SpectrumLine^ := #$ff;
        inc(SpectrumLine);
        IntValue += 65536;     //* Maintain bug in Spectrum ROM - INT(-65536) will result in -1 */
      end;
      SpectrumLine^ := chr(IntValue and $FF);
      inc(SpectrumLine);
      SpectrumLine^ := chr(IntValue >> 8);
      inc(SpectrumLine);
      SpectrumLine^ := #0;
      inc(SpectrumLine);
    end else begin           //* Need to store in full floating point format */
      if (Value < 0) then
      begin
        Sign := $80;    //* Sign bit is high bit of byte 2 */
        Value := -Value;
      end else
        Sign := $00;
      Exp := int (log2 (Value));
      if (Exp < -129) or (Exp > 126) then
      begin
        writeln ('ERROR - Number too big in line ', BasicLineNo);
        HandleNumbers := -1;
        exit;
      end;
      Mantissa := round ((Value / power (2.0, Exp) - 1.0) * SHIFT31BITS + 0.5); //* Calculate mantissa */
      SpectrumLine^ := #$0e;        //* Insert number marker */
      inc(SpectrumLine);
      SpectrumLine^ := chr(round(Exp) + $81);   //* Insert exponent */
      inc(SpectrumLine);
      SpectrumLine^ := chr(((Mantissa >> 24) and $7F) or Sign);         //* Insert mantissa */
      inc(SpectrumLine);
      SpectrumLine^ := chr((Mantissa >> 16) and $FF);
      inc(SpectrumLine);
      SpectrumLine^ := chr((Mantissa >> 8) and $FF);
      inc(SpectrumLine);
      SpectrumLine^ := chr(Mantissa and $FF);
      inc(SpectrumLine);
    end;
    HandleNumbers := 1;
  end;

  function HandleBIN (BasicLineNo: integer; var BasicLine: pchar; var SpectrumLine: pchar): integer;

  //**********************************************************************************************************************************/
  //* Pre   : `BasicLineNo' holds the current BASIC line number, `BasicLine' points into the line just past the BIN token,           */
  //*         `SpectrumLine' points to the TAPped Spectrum line.                                                                     */
  //* Post  : If there was a BINary number at this position, it has been processed into `SpectrumLine' and `LineIndex' is pointing   */
  //*         after the number.                                                                                                      */
  //*         The return value is: 1 = number done, -1 = number error (already reported).                                            */
  //* Import: None.                                                                                                                  */
  //**********************************************************************************************************************************/
  var
     Value: integer = 0;

  begin

    while (BasicLine^ = '0') or (BasicLine^ = '1') do   //* Read only binary digits */
    begin
      Value := Value * 2 + ord(BasicLine^) - ord('0');
      if (Value > 65535) then
      begin
        writeln ('ERROR - Number too big in line BasicLineNo');
        HandleBIN :=  -1;
        exit;
      end;
      SpectrumLine^ := BasicLine^;
      inc(SpectrumLine);
      inc(BasicLine);
    end;

    SpectrumLine^ := #$0E; //* Insert number marker */
    inc(SpectrumLine);
    SpectrumLine^ := #$00; //* (A small integer by definition) */
    inc(SpectrumLine);
    SpectrumLine^ := #$00;
    inc(SpectrumLine);
    SpectrumLine^ := chr(Value and $FF);
    inc(SpectrumLine);
    SpectrumLine^ := chr(Value >> 8);
    inc(SpectrumLine);
    SpectrumLine^ := #$00;
    inc(SpectrumLine);
    HandleBIN := 1;
  end;

  function ExpandSequences (BasicLineNo: integer; var BasicLine: pchar; var SpectrumLine: pchar; StripSpaces: boolean): integer;

  //**********************************************************************************************************************************/
  //* Pre   : `BasicLineNo' holds the current BASIC line number, `BasicLine' points into the line, `SpectrumLine' points to the      */
  //*         TAPped Spectrum line.                                                                                                  */
  //* Post  : If there was an expandable '{...}' sequence at this position, it has been processed into `SpectrumLine', `LineIndex'   */
  //*         is pointing after the sequence. Returned is -1 for error, 0 for no expansion, 1 for expansion.                         */
  //* Import: None.                                                                                                                  */
  //**********************************************************************************************************************************/
  var
    StartOfSequence: pchar;
    Attribute: byte       = 0;
    AttributeLength: byte = 0;
    AttributeVal1: byte   = 0;
    AttributeVal2: byte   = 0;
    OldCharacter: char;
    Cnt: integer;
  begin
    if (BasicLine^ <> '{') then
    begin
      ExpandSequences := 0;
      exit;
    end;
    StartOfSequence := BasicLine + 1;
    //* 'CODE' and 'CAT' were added for the sole purpuse of allowing them to be OPEN #'ed as channels! */
    if ( x_strnicmp (StartOfSequence, 'CODE}', 5) = 0) then //* Special: 'CODE' */
    begin
      SpectrumLine^ := #$af;
      inc(SpectrumLine);
      Basicline += 6;
      ExpandSequences := 1;
      exit;
    end;
    if (x_strnicmp (StartOfSequence, 'CAT}', 4) = 0) then          //* Special: 'CAT' */
    begin
      SpectrumLine^ := #$cf;
      inc(SpectrumLine);
      Basicline += 5;
      ExpandSequences := 1;
      exit;
    end;
    if (x_strnicmp (StartOfSequence, '(C)}', 4) = 0) then
    begin                                                     //* Form "{(C)}" -> copyright sign */
      SpectrumLine^ := #$7f;
      inc(SpectrumLine);
      Basicline += 5;
      if (StripSpaces) then
        while (BasicLine^ = ' ') do                      //* Skip trailing spaces */
          inc(BasicLine);
      ExpandSequences := 1;
      exit;
    end;
    if (StartOfSequence^ = '+') and ((StartOfSequence + 1)^ >= '1')
       and ((StartOfSequence + 1)^ <= '8') and ((StartOfSequence + 2)^ = '}') then
    begin      //* Form "{+X}" -> block graphics with shift */
      SpectrumLine^ := chr($88 + ((ord((StartOfSequence + 1)^) - ord('0')) mod 8) xor 7);
      inc(SpectrumLine);
      Basicline += 4;
      if (StripSpaces) then
        while (BasicLine^ = ' ') do                      //* Skip trailing spaces */
          inc(BasicLine);
      ExpandSequences := 1;
      exit;
    end;
    if (StartOfSequence^ = '-') and ((StartOfSequence + 1)^ >= '1') and ((StartOfSequence + 1)^ <= '8')
        and ((StartOfSequence + 2)^ = '}') then
    begin                              //* Form "{-X}" -> block graphics without shift */
      SpectrumLine^ := chr($80 + (ord((StartOfSequence + 1)^) - ord('0')) mod 8);
      inc(SpectrumLine);
      Basicline += 4;
      if (StripSpaces) then
        while (BasicLine^ = ' ') do                      //* Skip trailing spaces */
          inc(BasicLine);
      ExpandSequences := 1;
      exit;
    end;
    if (Upcase (StartOfSequence^) >= 'A') and (Upcase (StartOfSequence^) <= 'U')
        and ((StartOfSequence + 1)^ = '}') then
    begin          //* Form "{X}" -> UDG */
      if (Upcase (StartOfSequence^) = 'T') or (Upcase(StartOfSequence^) = 'U') then   //* 'T' or 'U' ? */
        case (Is48KProgram) of    //* Then the program must be 48K */
          -1 : Is48KProgram := 1;  //* Set the flag */
           0 :
          begin
            writeln ('ERROR - Line ', BasicLineNo, ' contains UDGs \T\ and/or \U\ '+
                        'but the program was already marked 128K');
            ExpandSequences := -1;
            exit;
          end;
           1 : begin end;
        end;
      SpectrumLine^ := chr($90 + ord(Upcase(StartOfSequence^)) - ord('A'));
      inc(SpectrumLine);
      Basicline += 3;
      if (StripSpaces) then
        while (BasicLine^ = ' ') do                      //* Skip trailing spaces */
          inc(BasicLine);
      ExpandSequences := 1;
      exit;
    end;
    if (is_xdigit (StartOfSequence^) and is_xdigit((StartOfSequence + 1)^)
       and ((StartOfSequence + 2)^ = '}')) then
    begin               ///* Form "{XX}" -> below 32 */
      if (StartOfSequence^ <= '9') then
        SpectrumLine^ := chr(ord(StartOfSequence^) - ord('0'))
      else
        SpectrumLine^ := chr(ord(upcase (StartOfSequence^)) - ord('A') + 10);
      if (StartOfSequence + 1)^ <= '9' then
        SpectrumLine^ := chr(ord(SpectrumLine^) * 16 + ord((StartOfSequence + 1)^) - ord('0'))
      else
        SpectrumLine^ := chr(ord(SpectrumLine^) * 16 + ord(upcase ((StartOfSequence + 1)^)) - ord('A') + 10);
      inc(SpectrumLine);
      Basicline += 4;
      if (StripSpaces) then
        while (BasicLine^ = ' ') do                      //* Skip trailing spaces */
          inc(BasicLine);
      ExpandSequences := 1;
      exit;
    end;
    if (x_strnicmp (StartOfSequence, 'INK', 3) = 0) then
    begin
      Attribute := $10;
      AttributeLength := 3;
    end
    else if (x_strnicmp (StartOfSequence, 'PAPER', 5)=0) then
    begin
      Attribute := $11;
      AttributeLength := 5;
    end
    else if (x_strnicmp (StartOfSequence, 'FLASH', 5) = 0) then
    begin
      Attribute := $12;
      AttributeLength := 5;
    end
    else if (x_strnicmp (StartOfSequence, 'BRIGHT', 6) = 0) then
    begin
      Attribute := $13;
      AttributeLength := 6;
    end
    else if (x_strnicmp (StartOfSequence, 'INVERSE', 7)=0) then
    begin
      Attribute := $14;
      AttributeLength := 7;
    end
    else if (x_strnicmp (StartOfSequence, 'OVER', 4)=0) then
    begin
      Attribute := $15;
      AttributeLength := 4;
    end
    else if (x_strnicmp (StartOfSequence, 'AT', 2)=0) then
    begin
      Attribute := $16;
      AttributeLength := 2;
    end
    else if (x_strnicmp (StartOfSequence, 'TAB', 3)=0) then
    begin
      Attribute := $17;
      AttributeLength := 3;
    end;
    if (Attribute > 0) then
    begin
      StartOfSequence += AttributeLength;
      while (StartOfSequence^ = ' ') do
        inc(StartOfSequence);
      while (is_digit (StartOfSequence^)) do
      begin
        AttributeVal1 := AttributeVal1 * 10 + ord(StartOfSequence^) - ord('0');
        inc(StartOfSequence);
      end;
      if (Attribute = $16) or (Attribute = $17) then
      begin
        if (StartOfSequence^ <> ',') then
          Attribute := 0
        else
        begin
          inc(StartOfSequence);                //* (Step past the comma) */
          while (StartOfSequence^ = ' ') do
            inc(StartOfSequence);
          while (is_digit (StartOfSequence^)) do
          begin
            AttributeVal2 := AttributeVal2 * 10 + ord(StartOfSequence^) - ord('0');
            inc(StartOfSequence);
          end;
        end;
      end;
      if (StartOfSequence^ <> '}') then       //* Need closing bracket */
        Attribute := 0;
      if (Attribute > 0) then
      begin
        SpectrumLine^ := chr(Attribute);
        inc(SpectrumLine);
        SpectrumLine^ := chr(AttributeVal1);
        inc(SpectrumLine);
        if (Attribute = $16) or (Attribute = $17) then
        begin
          SpectrumLine^ := chr(AttributeVal2);
          inc(SpectrumLine);
        end;
        BasicLine := StartOfSequence + 1;
        if (StripSpaces) then
          while (BasicLine^ = ' ') do
            inc(BasicLine);
        ExpandSequences := 1;
        exit;
      end;
    end;
    if (not NoWarnings) then
    begin
      Cnt := 0;
      while(((BasicLine + Cnt)^ <> #0) and ((BasicLine + Cnt)^ <> '}')) do
      begin
        inc(Cnt);
      end;
      if (BasicLine + Cnt)^ = '}' then
      begin
        OldCharacter := (BasicLine + Cnt + 1)^;
        (BasicLine + Cnt + 1)^ := #0;
        // writeln ('WARNING - Unexpandable sequence \"%s\" in line %d\n", (*BasicLine), BasicLineNo);
        (BasicLine + Cnt + 1)^ := OldCharacter;
        ExpandSequences := 0;
        exit;
      end;
    end;
    ExpandSequences := 0;
    exit;
  end;
  function PrepareLine (LineIn: pchar; FileLineNo: integer; var FirstToken: pchar): integer;

  //**********************************************************************************************************************************/
  //* Pre   : `LineIn' points to the read line, `FileLineNo' holds the real line number.                                             */
  //* Post  : Multiple spaces have been removed (unless within a string), the BASIC line number has been found and `FirstToken' is   */
  //*         pointing at the first non-whitespace character after the line number.                                                  */
  //*         Bad characters are reported, as well as any other error. The return value is the BASIC line number, -1 if error, or    */
  //*         -2 if the (empty!) line should be skipped.                                                                             */
  //* Import: GetLineNumber.                                                                                                         */
  //**********************************************************************************************************************************/

  var
    IndexIn: pchar;
    IndexOut: pchar;
    InString: boolean        = FALSE;
    SingleSeparator: boolean = FALSE;
    StillOk: boolean         = TRUE;
    DoingREM: boolean        = FALSE;
    BasicLineNo: integer     = -1;
    PreviousBasicLineNo: integer = -1;
  begin

    IndexIn := LineIn;
    IndexOut := ConvertedSpectrumLine;
    while ((IndexIn^<>#0) and StillOk) do
    begin
      if (IndexIn^ = #9) then  //* EXCEPTION: Print ' */
      begin
        IndexOut^ := #$06;
        inc(IndexOut);
        inc(IndexIn);
      end
      else if (IndexIn^ < #32) or (IndexIn^ >= #127) then       //* (Exclude copyright sign as well) */
        StillOk := FALSE
      else begin
        if (not DoingREM) then
          if (x_strnicmp (IndexIn, ' REM ', 5) = 0) or        //* Going through REM statement ? */
              (x_strnicmp (IndexIn, ':REM ', 5) = 0) then
            DoingREM := TRUE;        //* Signal: copy anything and everything ASCII */
        if (InString or DoingREM) then
        begin
          IndexOut^ := IndexIn^;
          inc(IndexOut);
        end else
        begin
          if IndexIn^ = ' ' then
          begin
            if not SingleSeparator then        //* Remove multiple spaces */
            begin
              SingleSeparator := TRUE;
              IndexOut^ := IndexIn^;
              inc(IndexOut);
            end;
          end else
          begin
            SingleSeparator := FALSE;
            IndexOut^ := IndexIn^;
            inc(IndexOut);
          end;
        end;
        if (IndexIn^ = '"') and not DoingREM then
          InString := not InString;
        inc(IndexIn);
      end;
    end;
    IndexOut^ := #0;
    if (not StillOk) then
      if (IndexIn^ = #$0D) or (IndexIn^ = #$0A) then  //* 'Correct' for end-of-line */
        StillOk := TRUE;                               //* (Accept CR and/or LF as end-of-line) */
    BasicLineNo := GetLineNumber (FirstToken);
    if (InString) then
    begin
      if BasicLineNo < 0 then
        writeln('ERROR - ASCII line ' + InttoStr(FileLineNo) + ' misses terminating quote')
      else
        writeln('ERROR - BASIC line ' + InttoStr(BasicLineNo) + ' misses terminating quote');
    end else if (not StillOk) then
      if BasicLineNo < 0 then
        writeln('ERROR - ASCII line ' + InttoStr(FileLineNo) + ' contains a bad character (code ' + inttostr(ord(IndexIn^)))
      else
        writeln('ERROR - BASIC line ' + InttoStr(BasicLineNo) + ' contains a bad character (code ' + inttostr(ord(IndexIn^)))
    else if (BasicLineNo < 0) then    //* Could not read line number */
    begin
      if FirstToken^=#0 then   //* Line is completely empty ? */
      begin
        if (not NoWarnings) then
          writeln ('WARNING - Skipping empty ASCII line ' + inttostr(FileLineNo));
        PrepareLine := -2;
        exit;
      end else begin
        writeln('ERROR - Missing line number in ASCII line ' + inttostr(FileLineNo));
        StillOk := FALSE;
      end;
    end else if (PreviousBasicLineNo >= 0) then  //* Not the first line ? */
    begin
      if (BasicLineNo < PreviousBasicLineNo) then   //* This line number smaller than previous ? */
      begin
        writeln ('ERROR - Line number ' + inttostr(BasicLineNo) + ' is smaller than previous line number ' + inttostr(PreviousBasicLineNo));
        StillOk := FALSE;
      end else if (BasicLineNo = PreviousBasicLineNo) and not NoWarnings then  //* Same line number as previous ? */
        writeln('WARNING - Duplicate use of line number ' + inttostr(BasicLineNo));    //* (BASIC can handle it after all...) */
    end else if (FirstToken^ = #0) then   // Line contains only a line number ? */
    begin
      writeln ('ERROR - Line ',BasicLineNo,' contains no statements!');
      StillOk := FALSE;
    end;
    PreviousBasicLineNo := BasicLineNo;           //* Remember this line number */
    if (not InString and StillOk) then
    begin
      PrepareLine := BasicLineNo;
      exit;
    end else begin
      PrepareLine := BasicLineNo;
      exit;
    end;
  end;

  function CheckEnd (BasicLineNo: integer; StatementNo: integer; var Index: pchar): boolean;

  //**********************************************************************************************************************************/
  //* Pre   : `BasicLineNo' holds the line number, `StatementNo' the statement number, `Index' the current position in the line.     */
  //* Post  : A check is made whether the end of the current statement has been reached.                                             */
  //*         If so, an error is reported and TRUE is returned (so FALSE indicates that everything is still fine and dandy).         */
  //* Import: none.                                                                                                                  */
  //**********************************************************************************************************************************/

  begin
    if (Index^ = ':') or (Index^ = #$0D) then    //* End of statement or end of line ? */
    begin
      writeln('ERROR in line ' + intToStr(BasicLineNo) + ' statement ' + intToStr(StatementNo) + ' - Unexpected end of statement');
      CheckEnd := true;
      exit;
    end;
    CheckEnd := false;
  end;

  function ScanVariable (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar; var tType: boolean; var NameLen: integer; AllowSlicing: integer): boolean;

  //**********************************************************************************************************************************/
  //* Pre   : `BasicLineNo' holds the line number, `StatementNo' the statement number, `Keyword' the keyword to which this operand   */
  //*         belongs, `Index' the current position in the line.                                                                     */
  //*         `AllocSlicing' is one of the following values:                                                                         */
  //*         -1 = Don't check for slicing/indexing (used by DEF FN)                                                                 */
  //*         0 = No slicing/indexing allowed                                                                                        */
  //*         1 = Either slicing or indexing may follow (indices being numeric)                                                      */
  //*         2 = Only numeric indexing may follow (used by LET and READ)                                                            */
  //* Post  : A check has been made whether there's a variable at the current position. If so, it has been skipped.                  */
  //*         Slicing is handled here as well, but notice that this is not necessarily correct!                                      */
  //*         Single letter string variables can be either flat or array and both possibilities are considered here.                 */
  //*         Both "a$(1 TO 10)" and "a$(1, 2)" are correct to BASIC, but depend on whether a "DIM" statement was used.              */
  //*         The length of the found string (without any '$') is returned in `NameLen', its type is returned in `Type' (TRUE for    */
  //*         numeric and FALSE for string variables). The return value is TRUE is all went well. Errors have already been reported. */
  //*         The return value is FALSE either when no variable is at this point or an error was found.                              */
  //*         `NameLen' is returned 0 if no variable was detected here, or > 0 if in error.                                          */
  //* Import: ScanExpression.                                                                                                        */
  //**********************************************************************************************************************************/

  var
    SubType: boolean;
    IsArray: boolean = FALSE;
    SetTokenBracket: boolean = FALSE;

  begin
    Keyword := Keyword;              //* (Keep compilers happy) */
    tType := TRUE;                   //* Assume it will be numeric */
    NameLen := 0;
    if (not is_alfa (Index^)) then  //* The first character must be alphabetic for a variable */
    begin
      ScanVariable := FALSE;
      exit;
    end;
    NameLen := 1;
    inc(Index);
    while is_alnum (Index^) do
    begin
      inc(Index);     //* Read on, until end of the word */
      inc(NameLen);
    end;
    if (Index^ = '$') then  //* It's a string variable ? */
    begin
      if (NameLen > 1) then  //* String variables can only have a single character name */
      begin
        writeln('ERROR in line ' + inttostr(BasicLineNo) + ' statement '+inttostr(StatementNo)+' - String variables can only have single character names');
        ScanVariable := false;
        exit;
      end;
      inc(Index);
      tType := FALSE;
    end;
    {$ifdef __DEBUG__}
      if tType then
        writeln ('DEBUG - '+ ListSpaces+ ' ScanVariable, Type is NUM')
      else
        writeln ('DEBUG - '+ ListSpaces+ ' ScanVariable, Type is ALPHA');
    {$endif}
    if (AllowSlicing >= 0) and (Index^ = '(') then       //* Slice the string ? */
    begin
      {$ifdef __DEBUG__}
          writeln ('DEBUG - ' + ListSpaces^ ' ScanVariable, reading index');
      {$endif}
      if (NameLen > 1) then     //* Arrays can only have a single character name */
      begin
        writeln ('ERROR in line '+inttostr(BasicLineNo)+', statement '+inttostr(StatementNo)+' - Arrays can only have single character names');
        ScanVariable := false;
        exit;
      end;
      if (AllowSlicing = 0) then    //* Slicing/Indexing not allowed ? */
      begin
        writeln('ERROR in line '+inttostr(BasicLineNo)+' statement '+inttostr(statementNo)+' - Slicing/Indexing not allowed');
        ScanVariable := false;
        exit;
      end;
      inc(Index);                //* (Skip the bracket) */
      if (Index^ = ')') then     //* Empty slice "a$()" is not ok */
      begin
        writeln ('ERROR in line '+inttostr(BasicLineNo)+', statement '+inttostr(StatementNo)+' - Empty array index not allowed');
        ScanVariable := false;
        exit;
      end;
      if (Index^ = #$CC) then //* "a$( TO num)" or "a$( TO )" */
      begin
        if (AllowSlicing = 2) then
        begin
          writeln('ERROR in line '+inttostr(BasicLineNo)+', statement '+inttostr(StatementNo)+' - Slicing token "TO" inappropriate for arrays');
          ScanVariable := false;
          exit;
        end;
      end else begin      //* Not "a$( TO num)" nor "a$( TO )" */
        if (not TokenBracket) then
        begin
          TokenBracket := TRUE;   //* Allow complex expression */
          SetTokenBracket := TRUE;
        end;
        if (not ScanExpression(BasicLineNo, StatementNo, ord('('), Index, SubType, 0)) then     //* First parameter */
        begin
          ScanVariable := false;
          exit;
        end;
        if (SetTokenBracket) then
          TokenBracket := FALSE;
        if (not SubType) then    //* Must be numeric */
        begin
          writeln('ERROR in line '+inttostr(BasicLineNo)+', statement '+inttostr(StatementNo)+' - Variables indices must be numeric');
          ScanVariable := false;
          exit;
        end;
        if (Index^ = ')') then   //* "a$(num)" is ok */
        begin
          inc(Index);
          {$ifdef __DEBUG__}
          writeln('DEBUG - '+ListSpaces^ + ' ScanVariable, index ending, next char is " + TokenMap[Index^].Token);
          {$endif}
          ScanVariable := true;
          exit;
        end;
      end;
      if (Index^ <> #$CC) and (Index^ <> ',') then    //* Either an array or a slice */
      begin
        writeln('ERROR in line '+inttostr(BasiclineNo)+' statement '+inttostr(StatementNo)+' - Unexpected index character ' + Index^);
          ScanVariable := false;
          exit;
      end;
      if (Index^ = ',') then
        IsArray := TRUE
      else begin
        if (AllowSlicing = 2) then
        begin
          writeln('ERROR in line '+Inttostr(BasicLineNo) + ', statement '+inttoStr(StatementNo)+' - Slicing token "TO" inappropriate for arrays');
          ScanVariable := false;
          exit;
        end;
        if tType then //* Only character strings can be sliced */
        begin
          writeln('ERROR in line ',inttostr(BasicLineNo)+', statement '+InttoStr(StatementNo)+' - Only character strings can be sliced');
          ScanVariable := false;
          exit;
        end;
      end;
      repeat
        inc(Index);     //* Skip each "," (or the "TO" for non-arrays) */
        if (not TokenBracket) then
        begin
          TokenBracket := TRUE;
          SetTokenBracket := TRUE;
        end;
        if (not ScanExpression (BasicLineNo, StatementNo, ord('('), Index, SubType, 0)) then  //* Second or further parameter */
        begin
          ScanVariable := false;
          exit;
        end;
        if (SetTokenBracket) then
          TokenBracket := FALSE;
        if (not SubType) then //* Must be numeric */
        begin
          writeln('ERROR in line '+inttostr(BasicLineNo)+', statement '+inttostr(StatementNo)+' - Variables indices must be numeric');
          ScanVariable := false;
          exit;
        end;
        if not IsArray and (Index^ <> ')') then
        begin
          BADTOKEN ('")"', TokenMap[ord(Index^)].Token, BasicLineNo, StatementNo);
          ScanVariable := false;
          exit;
        end else if IsArray and (Index^ <> ',') and (Index^ <> ')') and (Index^ <> #$CC) then
        begin
          BADTOKEN ('","', TokenMap[ord(Index^)].Token, BasicLineNo, StatementNo);
          ScanVariable := false;
          exit;
        end;
      until(Index^ <> ')');
      inc(Index);     //* (Step past closing bracket) */
      {$ifdef __DEBUG__}
        writeln('DEBUG - '+LisSpaces+' ScanVariable, index ending, next char is '+TokenMap[Index^].Token);
      {$endif}
    end;
    ScanVariable := true;
    exit;
  end;

 function SliceDirectString (BasicLineNo: integer; StatementNo: integer; Keyword: integer; Index: pchar): boolean;

//**********************************************************************************************************************************/
//* Pre   : `BasicLineNo' holds the line number, `StatementNo' the statement number, `Keyword' the keyword to which this operand   */
//*         belongs, `Index' the current position in the line.                                                                     */
//*         A direct string has just been read and a '(' character is currently under the cursor.                                  */
//* Post  : Slicing is handled here.                                                                                               */
//*         Possible are "string"(), "string"(num), "string"( TO ), "string"(num TO ), "string"( TO num) and "string"(num TO num). */
//*         The return value is FALSE if an error was found (which has already been reported here).                                */
//* Import: ScanExpression.                                                                                                        */
//**********************************************************************************************************************************/
var
  SubType: boolean;
  SetTokenBracket: boolean = FALSE;

begin
  Keyword := Keyword;      //* (Keep compilers happy) */
  inc(Index);              //* Step past the opening bracket */
  if (Index^ = ')') then   //* Empty slice "abc"() is ok */
  begin
    inc(Index);
    SliceDirectString := TRUE;
    exit;
  end;
  if (Index^ <> #$CC) then  //* Not "abc"( TO num) nor "abc"( TO ) */
  begin
    if (not TokenBracket) then
    begin
      TokenBracket := TRUE;
      SetTokenBracket := TRUE;
    end;
    if (not ScanExpression (BasicLineNo, StatementNo, ord('('), Index, SubType, 0)) then  //* First parameter */
    begin
      SliceDirectString := FALSE;
      exit;
    end;
    if (SetTokenBracket) then
      TokenBracket := FALSE;
    if (not SubType) then      //* Must be numeric */
    begin
      writeln('ERROR in line '+inttostr(BasicLineNo)+', statement '+inttostr(StatementNo)+' Slice values must be numeric');
      SliceDirectString := FALSE;
      exit;
    end;
  end;
  if (Index^ = ')') then   //* "abc"(num) is ok */
  begin
    inc(Index);
    SliceDirectString := TRUE;
    exit;
  end;
  if (Index^ <> #$CC) then    //* ('TO') */
  begin
    writeln ('ERROR in line '+inttostr(BasicLineNo)+', statement '+inttostr(StatementNo)+' - Unexpected index character');
    SliceDirectString := FALSE;
    exit;
  end;
  inc(Index);
  if (Index^ = ')') then //* "abc"(num TO ) is ok */
  begin
    inc(Index);
    SliceDirectString := TRUE;
    exit;
  end;
  if (not TokenBracket) then
  begin
    TokenBracket := TRUE;
    SetTokenBracket := TRUE;
  end;
  if (not ScanExpression (BasicLineNo, StatementNo, ord('('), Index, SubType, 0)) then //* Second parameter */
  begin
    SliceDirectString := FALSE;
    exit;
  end;
  if (SetTokenBracket) then
    TokenBracket := FALSE;
  if (not SubType) then  //* Must be numeric */
  begin
    writeln ('ERROR in line '+inttostr(BasicLineNo)+', statement +'+inttostr(StatementNo)+' - Slice values must be numeric');
    SliceDirectString := FALSE;
    exit;
  end;
  if (Index^ <> ')') then
  begin
    BADTOKEN ('")"', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
    SliceDirectString := FALSE;
    exit;
  end;
  inc(Index);
  SliceDirectString := TRUE;
end;

function ScanStream (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar): boolean;

//**********************************************************************************************************************************/
//* Pre   : `BasicLineNo' holds the line number, `StatementNo' the statement number, `Keyword' the keyword to which this operand   */
//*         belongs, `Index' the current position in the line.                                                                     */
//*         A stream hash mark (`#') has just been read.                                                                           */
//* Post  : The following stream number is checked to be a numeric expression.                                                     */
//*         The return value is FALSE if an error was found (which has already been reported here).                                */
//* Import: HandleClass06.                                                                                                         */
//**********************************************************************************************************************************/

begin
  if (not SignalInterface1 (BasicLineNo, StatementNo, 0)) then
  begin
    ScanStream := FALSE;
    exit;
  end;
  ScanStream := HandleClass06 (BasicLineNo, StatementNo, Keyword, Index);  //* Find numeric expression */
end;

function SignalInterface1 (BasicLineNo: integer; StatementNo: integer; NewMode: integer): boolean;

//**********************************************************************************************************************************/
//* Pre   : `BasicLineNo' holds the line number, `StatementNo' the statement number, `NewMode' holds the required hardware mode.   */
//* Post  : The required hardware is tested for conflicts.                                                                         */
//*         The return value is FALSE if there was a conflict (which has already been reported here).                              */
//* Import: none.                                                                                                                  */
//**********************************************************************************************************************************/

begin
  if (NewMode = 1) and (UsesInterface1 = 2) or     //* Interface1 required, but already flagged Opus ? */
      (NewMode = 2) and (UsesInterface1 = 1) then  //* Opus required, but already flagged Interface1 ? */
  begin
    writeln('ERROR in line '+inttostr(BasicLineNo)+', statement '+inttostr(StatementNo)+' - The program uses commands that are specific'+
                        'for Interface 1 and Opus Discovery, but don''t exist on both devices');
    SignalInterface1 := FALSE;
    exit;
  end;
  UsesInterface1 := NewMode;
  SignalInterface1 := TRUE;
end;

function ScanChannel (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar; var WhichChannel: byte): boolean;

//**********************************************************************************************************************************/
//* Pre   : `BasicLineNo' holds the line number, `StatementNo' the statement number, `Keyword' the keyword to which this operand   */
//*         belongs, `Index' the current position in the line.                                                                     */
//* Post  : A channel identifier of the form   "x";n;   must follow. `x' is a single alphanumeric character, `n' is a numeric      */
//*         expression, the rest are required characters.                                                                          */
//*         The found channel identifier ('x') is returned (in lowercase) in `WhichChannel'.                                       */
//*         The return value is FALSE if an error was found (which has already been reported here).                                */
//* Import: HandleClass06, CheckEnd.                                                                                               */
//**********************************************************************************************************************************/

var
  NeededHardware: integer = 0;     //* (Default to Interface 1) */
begin

  WhichChannel := 0;
  if CheckEnd (BasicLineNo, StatementNo, Index) then
  begin
    Scanchannel := FALSE;
    exit;
  end;
  if Index^ <> '"' then
  begin
    if not HandleClass06 (BasicLineNo, StatementNo, Keyword, Index) then //* EXCEPTION: The Opus allows '<num>' to abbreviate '"m";<num>' */
    begin
      writeln('Expected to find a channel identifier');
      Scanchannel := FALSE;
      exit;
    end;
    WhichChannel := ord('m');
    if (not SignalInterface1 (BasicLineNo, StatementNo, 2)) then   //* Signal the Opus specificness */
    begin
      Scanchannel := FALSE;
      exit;
    end;
    if (CheckEnd (BasicLineNo, StatementNo, Index)) then
    begin
      Scanchannel := FALSE;
      exit;
    end;
    if (Index^ <> ';') then
    begin
      BADTOKEN ('";"', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
      Scanchannel := FALSE;
      exit;
    end;
    inc(Index);
    if (CheckEnd (BasicLineNo, StatementNo, Index)) then
    begin
      Scanchannel := FALSE;
      exit;
    end;
  end else begin
    inc(Index);
    if (CheckEnd (BasicLineNo, StatementNo, Index)) then
    begin
      Scanchannel := FALSE;
      exit;
    end;
    if not is_alfa (Index^) and  //* (Ordinary channel) */
        (Index^ <> '#') and        //* (Linked channel, OPEN # only) */
        (Index^ <> #$AF) and       //* ('CODE' channel, OPEN # only) */
        (Index^ <> #$CF) then      //* ('CAT' channel, OPEN # only) */
    begin
      writeln('ERROR in line '+inttostr(BasicLineNo)+', statement '+inttostr(StatementNo)+' - Channel name must be alphanumeric');
      Scanchannel := FALSE;
      exit;
    end;
    WhichChannel := ord(upcase(Index^));
    inc(Index);
    if (CheckEnd (BasicLineNo, StatementNo, Index)) then
    begin
      Scanchannel := FALSE;
      exit;
    end;
    if Index^<> '"' then
    begin
      writeln('ERROR in line '+inttostr(BasicLineNo)+', statement '+inttostr(StatementNo)+' - Channel name must be single character');
      Scanchannel := FALSE;
      exit;
    end;
    inc(Index);
    if (WhichChannel = ord('k')) or (WhichChannel = ord('s')) or (WhichChannel = ord('p')) or  //* (Normal Spectrum channels) */
       (WhichChannel = ord('m')) or (WhichChannel = ord('t')) or (WhichChannel = ord('b')) or
       (WhichChannel = ord('#')) or (WhichChannel = ord(#$CF)) then                            //* ('CAT' channel) */
      NeededHardware := 0
    else if WhichChannel = ord('n') then   //* Network channel is available on Interface 1 but not on Opus */
      NeededHardware := 1
    else if (WhichChannel = ord('j')) or     //* (Opus: Joystick channel) */
            (WhichChannel = ord('d')) or     //* (Opus: disk channel) */
            (WhichChannel = ord(#$AF)) then  //* (Opus: 'CODE' channel) */
      NeededHardware := 2;
    if (not SignalInterface1 (BasicLineNo, StatementNo, NeededHardware)) then
    begin
      Scanchannel := FALSE;
      exit;
    end;
    if (WhichChannel = ord('m')) or (WhichChannel = ord('d')) or (WhichChannel = ord('n')) or     //* Continue checking with these channels only */
       (WhichChannel = ord('#')) or (WhichChannel = ord(#$CF)) then
    begin
      if (CheckEnd (BasicLineNo, StatementNo, Index)) then
      begin
        Scanchannel := FALSE;
        exit;
      end;
      if Index^ <> ';' then
      begin
        BADTOKEN ('";"', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
        Scanchannel := FALSE;
        exit;
      end;
      inc(Index);
      if (not HandleClass06 (BasicLineNo, StatementNo, Keyword, Index)) then // Find numeric expression */
      begin
        Scanchannel := FALSE;
        exit;
      end;
      if (WhichChannel = ord('m')) then    //* Omly the 'm' channel requires a ';' character following */
      begin
        if (CheckEnd (BasicLineNo, StatementNo, Index)) then
        begin
          Scanchannel := FALSE;
          exit;
        end;
        if (Index^ <> ';') then
        begin
          BADTOKEN ('";"', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
          Scanchannel := FALSE;
          exit;
        end;
        inc(Index);
        if (CheckEnd (BasicLineNo, StatementNo, Index)) then
        begin
          Scanchannel := FALSE;
          exit;
        end;
      end;
    end;
  end;
  Scanchannel := TRUE;
end;
function ScanExpression (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar; var tType: boolean; Level: integer): boolean;

{********************************************************************************************************************************}
{ Pre   : `BasicLineNo' holds the line number, `StatementNo' the statement number, `Keyword' the keyword to which this operand   }
{         belongs, `Index' the current position in the line.                                                                     }
{         `Level' is used for recursion and must be 0 when called, unless when called from ScanVariable (then it must be 1).     }
{ Post  : An expression must be found, either numerical or string. Its type is returned in `Type' (TRUE for numerical).          }
{         All subexpressions, between brackets, are dealt with using recursion.                                                  }
{         The return value is FALSE if an error was found (which has already been reported here).                                }
{ Import: ScanExpression (recursive), SliceDirectString, ScanVariable, HandleClassXX.                                            }
{********************************************************************************************************************************}
var
  More: boolean       = TRUE;
  SubType: boolean    = TRUE;                                                                          { (Assume numeric expression) }
  SubSubType: boolean;
  TypeKnown: boolean  = FALSE;
  TotalTypeKnown: boolean = FALSE;
  Dummy: boolean;
  VarNameLen: integer;
  ClassIndex: integer = -1;
  ThisToken: byte;

begin
{$ifdef __DEBUG_}
  RecurseLevel ++;
  memset (ListSpaces, ' ', RecurseLevel * 2);
  ListSpaces[RecurseLevel * 2] = '\0';
  printf ('DEBUG - %sEnter ScanExpression\n', ListSpaces);
{$endif}
  if (Index^ = '+') or (Index^ = '-') then   { Unary plus and minus }
  begin
    tType := TRUE;        { Then we expect a numeric expression }
    TypeKnown := TRUE;
    inc(Index);           { Skip the sign }
  end;
  while (More) do
  begin
{$ifdef __DEBUG_}
    printf ('DEBUG - %sScanExpression sub (keyword \'%s\'), first char is \'%s\'\n',
            ListSpaces, TokenMap[Keyword].Token, TokenMap[**Index].Token);
{$endif}
    if (Index^ = '(') then   { Opening bracket ? }
    begin
{$ifdef __DEBUG_}
      printf ('DEBUG - %sRecurse ScanExpression for \'(\'\n', ListSpaces);
{$endif}
      inc(Index);     { The 'parent' steps past the opening bracket }
      if (not ScanExpression (BasicLineNo, StatementNo, ord('('), Index, SubSubType, Level + 1)) then { Recurse }
      begin
        ScanExpression := false;
        exit;
      end;
      if TypeKnown and (SubSubType <> SubType) then    { Bad subexpression type ? }
      begin
        ScanExpression := false;
        ErrorLine(' - Type conflict in expression',BasicLineNo, StatementNo);
        exit;
      end
      else if (not TypeKnown) then       { We didn't have an expected type yet ? }
      begin
        SubType := SubSubType;
        TypeKnown := TRUE;
      end;
      inc(Index);         { The 'parent' steps past the closing bracket too }
      if (Index^ = '(') then   { Slicing ? }
      begin
        if (not SubSubType)then     { Result was a string ? }
        begin
          if (not SliceDirectString (BasicLineNo, StatementNo, Keyword, Index)) then
          begin
            ScanExpression := false;
            exit;
          end;
        end
        else                                                                       { No, it was numerical, which you can't slice }
        begin
          ErrorLine('cannot slice a numerical value', BasicLineNo, StatementNo);
          ScanExpression := false;
          exit;
        end;
      end;
    end
    else if (Index^ = ')') then  { Closing bracket ? }
    begin                        { Leave the bracket for the parent, to allow functions (eg. 'ATTR (...)') }
      if (not TotalTypeKnown) then       { 'Simple' expression ? }
        tType := SubType;         { Set return type }
{$ifdef __DEBUG__}
      printf ('DEBUG - %sLeave ScanExpression, Type is %s next char is \'%s\'\n',
              ListSpaces, *Type ? 'NUM' : 'ALPHA', TokenMap[**Index].Token);
      if (-- RecurseLevel > 0)
        memset (ListSpaces, ' ', RecurseLevel * 2);
      ListSpaces[RecurseLevel * 2] = '\0';
{$endif}
      ScanExpression := true;
      exit;
    end
    else if (Index^ = ':') or (Index^ = #$0D) then   { End of statement or end of line ? }
    begin
      if (not TotalTypeKnown) then    { 'Simple' expression ? }
        tType := SubType;              { Set return type }
      if (Level <> 0) then     { Not on lowest level ? }
      begin
        ErrorLine('too few closing brackets', BasicLineNo, StatementNo);
        ScanExpression := false;
        exit;
      end;
      More := FALSE;
    end
    else if is_digit (Index^) or (Index^ = '.') or (Index^ = #$C4) then  { Number ? }
    begin
      if (not TypeKnown) then     { Unknown expression type yet ? }
      begin
        TypeKnown := TRUE;  { Signal: it is numeric }
        SubType := TRUE;
      end
      else if (not SubType) then   { Type was known to be string ? }
      begin
        ErrorLine('Type conflict in expression', BasicLineNo, StatementNo);
        ScanExpression := false;
        exit;
      end;
      inc(Index);
      while (Index^ <> #$0E) do { Skip until the number marker }
      begin
        inc(Index);
      end;
      inc(index);
    end
    else if Index^ = '"' then                                                                                  { Direct string ? }
    begin
      if (not TypeKnown) then  { Unknown expression type yet ? }
      begin
        TypeKnown := TRUE;    { Signal: it is a string }
        SubType := FALSE;
      end
      else if (SubType) then  { Type was known to be numeric ? }
      begin
        ErrorLine('Type conflict in expression', BasicLineNo, StatementNo);
        ScanExpression := false;
        exit;
      end;
      while (Index^ = '"')do     { Concatenated strings are ok, since they allow the use of the ' character }
      begin
        inc(Index);
        while (Index^ <> '"') do    { Find closing quote }
        begin
          inc(Index);
        end;
        inc(Index);
      end;
      if (Index^ = '(') then     { String is sliced ? }
        if (not SliceDirectString (BasicLineNo, StatementNo, Keyword, Index)) then
        begin
          ScanExpression := false;
          exit;
        end;
    end
    else if (ScanVariable (BasicLineNo, StatementNo, Keyword, Index, SubSubType, VarNameLen, 1)) then         { Is it a variable ? }
    begin
      if (not TypeKnown) then    { Unknown expression type yet ? }
      begin
        TypeKnown := TRUE;       { Signal: it is string }
        SubType := SubSubType;
      end
      else if (SubType <> SubSubType) then { Different type variable ? }
      begin
        ErrorLine('Type conflict in expression', BasicLineNo, StatementNo);
        ScanExpression := false;
        exit;
      end;
    end
    else if (VarNameLen <> 0) then   { (Not a variable) }
    begin
      ScanExpression := false;        { (But an error that was already reported) }
      exit;
    end
    { It's none of the above. Go check tokens }
    else case (TokenMap[ord(Index^)].TokenType) of
       0 :
       begin
         ErrorLine('Unexpected token ',BasicLineNo, StatementNo, TokenMap[ord(Index^)].Token);
         ScanExpression := false;
         exit;
       end;
       1,
       2 :
       begin
         ErrorLine('Unexpected keyword ', BasicLineNo, StatementNo, TokenMap[ord(Index^)].Token);
         ScanExpression := false;
         exit;
       end;
       3 ,
       4 ,
       5 : begin
         ThisToken := ord(Index^);
         inc(index);
         if (TokenMap[ThisToken].TokenType = 5) then
         begin
           if (Keyword <> $F5) and (Keyword <> $E0) then   { Not handling a PRINT or LPRINT ? }
           begin
             Errorline('Unexpected token ', BasicLineNo, StatementNo, TokenMap[ord(Index^)].Token);
             ScanExpression := false;
             exit;
           end;
         end
         else if (ThisToken = $C0) and (Index^ = '"') then      { Special: USR 'x' }
         begin
           inc(Index);        { (Step past the opening quote) }
           if (CheckEnd (BasicLineNo, StatementNo, Index)) then
           begin
             ScanExpression := false;
             exit;
           end;
           if (upcase(Index^) < 'A') or (upcase(Index^) > 'U') then { Bad UDG character ? }
           begin
             ErrorLine('Bad UDG ',BasicLineNo, StatementNo, TokenMap[ord(Index^)].Token);
             ScanExpression := false;
             exit;
           end;
           inc(Index);
           if (CheckEnd (BasicLineNo, StatementNo, Index)) then
           begin
             ScanExpression := false;
             exit;
           end;
           if Index^ <> '"' then { More than one letter ? }
           begin
             ErrorLine('An UDG name may be only 1 letter ',BasicLineNo, StatementNo);
             ScanExpression := false;
             exit;
           end;
           Dec(Index^);
           if (upcase(Index^) = 'T') or (upcase(Index^) = 'U') then  { One of the UDGs 'T' or 'U' ? }
             case (Is48KProgram) of      { Then the program must be 48K }
                -1 : Is48KProgram := 1;  { Set the flag }
                 0 :
                 begin
                   ErrorLine('contains UDGs "T" and/or "U" but the program was already marked 128K ', BasicLineNo, StatementNo);
                   ScanExpression := false;
                   exit;
                 end;
                 1 : begin end;
             end;
           inc(Index,2);    { Step past the UDG name and closing quote }
           break;           { Done, step out }
         end
         else
         begin
           if (not TypeKnown) then { Unknown expression type yet ? }
           begin
             TypeKnown := TRUE;     { Set expected type }
             SubType := (TokenMap[ord(ThisToken)].TokenType = 3);
           end
           else if (SubType and (TokenMap[ord(ThisToken)].TokenType = 4)) or
                    (not SubType and (TokenMap[ord(ThisToken)].TokenType = 3)) then
           begin
             ErrorLine('Type conflict in expression ', BasicLineNo, StatementNo);
             ScanExpression := false;
             exit;
           end;
         end;
         ClassIndex := 0;
         while (TokenMap[ord(ThisToken)].KeywordClass[ClassIndex] <> #0) do { Handle all class parameters }
         begin
           if (CheckEnd (BasicLineNo, StatementNo, Index)) then
           begin
             ScanExpression := false;
             exit;
           end
           else if (TokenMap[ord(ThisToken)].KeywordClass[ClassIndex] >= #32) then  { Required token or class ? }
           begin
             if (Index^ <> TokenMap[ord(ThisToken)].KeywordClass[ClassIndex]) then  { (Required token) }
             begin                                    { (Token not there) }
               ErrorLine (' - Expected '+TokenMap[ord(ThisToken)].KeywordClass[ClassIndex] + ' but got '+TokenMap[ord(Index^)].Token,
                        BasicLineNo, StatementNo);
              ScanExpression := false;
              exit;
             end
             else
             begin
               if (Index^ = '(') then
               begin
{$ifdef __DEBUG__}
                 printf ('DEBUG - %sTurning on token bracket\n', ListSpaces);
{$endif}
                 TokenBracket := TRUE;
               end
               else if (Index^ = ')') then
               begin
{$ifdef __DEBUG__}
                 printf ('DEBUG - %sTurning off token bracket\n', ListSpaces);
{$endif}
                 TokenBracket := FALSE;
               end;
                inc(Index);
             end;
           end
           else       { (Command class) }
           begin
             case (TokenMap[ThisToken].KeywordClass[ClassIndex]) of
                 #1 :
                   if (not HandleClass01 (BasicLineNo, StatementNo, ThisToken, Index, &Dummy)) then { (Special: FN) }
                   begin
                     ScanExpression := false;
                     exit;
                   end;
                 #3 :
                   if (not HandleClass03 (BasicLineNo, StatementNo, ThisToken, Index)) then
                   begin
                     ScanExpression := false;
                     exit;
                   end;
                 #5 :
                   if (not HandleClass05 (BasicLineNo, StatementNo, ThisToken, Index)) then
                   begin
                     ScanExpression := false;
                     exit;
                   end;
                 #6 :
                   if (not HandleClass06 (BasicLineNo, StatementNo, ThisToken, Index)) then
                   begin
                     ScanExpression := false;
                     exit;
                   end;
                 #8 :
                   if (not HandleClass08 (BasicLineNo, StatementNo, ThisToken, Index)) then
                   begin
                     ScanExpression := false;
                     exit;
                   end;
                #10 :
                   if (not HandleClass10 (BasicLineNo, StatementNo, ThisToken, Index)) then
                   begin
                     ScanExpression := false;
                     exit;
                   end;
                #12 :
                  if (not HandleClass12 (BasicLineNo, StatementNo, ThisToken, Index)) then
                  begin
                    ScanExpression := false;
                    exit;
                  end;
                #13 :
                   if (not HandleClass13 (BasicLineNo, StatementNo, ThisToken, Index)) then
                   begin
                     ScanExpression := false;
                     exit;
                   end;
                #14 :
                   if (not HandleClass14 (BasicLineNo, StatementNo, ThisToken, Index)) then
                   begin
                     ScanExpression := false;
                     exit;
                   end;
             end;
{$ifdef __DEBUG__}
             printf ('DEBUG - %sScanExpression status, Type is %s, next char is \'%s\'\n',
                     ListSpaces, *Type ? 'NUM' : 'ALPHA', TokenMap[**Index].Token);
{$endif}
           end;
           inc(ClassIndex);
         end;
         if (ThisToken = $A6) then  { INKEY$ ? }
         begin
           if (Index^ = '#') then    { Type 'INKEY$#<stream>' ? }
           begin
              inc(Index);
             if (not ScanStream (BasicLineNo, StatementNo, ThisToken, Index)) then
             begin
               ScanExpression := false;
               exit;
             end;
           end;
         end;
      end;
    end;
    { Piece done, continue }
    if (TokenMap[Keyword].TokenType = 3) or (TokenMap[Keyword].TokenType = 4) then { Just did an operand to a function ? }
    begin                                                                                    { Then step back to evaluate the result }
      if (not TotalTypeKnown) then
        tType := SubType;
{$ifdef __DEBUG__}
      printf ('DEBUG - %sLeave ScanExpression, Type is %s, next char is \'%s\'\n',
              ListSpaces, *Type ? 'NUM' : 'ALPHA', TokenMap[**Index].Token);
      if (-- RecurseLevel > 0)
        memset (ListSpaces, ' ', RecurseLevel * 2);
      ListSpaces[RecurseLevel * 2] = '\0';
{$endif}
      ScanExpression := true;
      exit;
    end;
    if (More) then
    begin
      if (Index^ = #$C5) or (Index^ = #$C6) then  { ('OR' and 'AND') }
      begin
{$ifdef __DEBUG__}
        printf ('DEBUG - %sRecurse ScanExpression for \'%s\'\n', ListSpaces, TokenMap[**Index].Token);
{$endif}
        //if (!TotalTypeKnown)                                                           { 'Simple' expression before the AND/OR ? }
          //Type = SubType;
        if (Index^ = #$C5) and not tType then
        begin
          ErrorLine('"OR" requires a numeric left value', BasicLineNo, StatementNo);
          ScanExpression := false;
          exit;
        end;
        ThisToken := ord(Index^);       { Step over the operator - but remember it }
        inc(Index);
        if (not ScanExpression (BasicLineNo, StatementNo, ThisToken, Index, SubSubType, 0)) then{ Recurse - at level 0! }
        begin
          ScanExpression := false;
          exit;
        end;
        if (not SubSubType) then  { The expression at the right must be numeric for both AND and OR }
        begin
          ErrorLine(TokenMap[ord(ThisToken)].Token + ' requires a numeric right value',BasicLineNo, StatementNo);
          ScanExpression := false;
          exit;
        end;
        if (not TypeKnown) then  { We didn't have an expected type yet ? }
        begin
          TypeKnown := TRUE;
          TotalTypeKnown := TRUE;
          if (ThisToken = $C6) and not tType then { Signal resulting type }
             tType := FALSE
          else
              tType := TRUE;
          SubType := tType;
           { x$ AND y -> result is string }
           { x AND y -> result is numeric }
           { x OR y -> result is numeric }
        end;
        More := FALSE;              { (Because the recursing causes the expression to be evaluated right to left, we're done now) }
      end
      else if ((Index^ = '=') or (Index^ = '<') or (Index^ = '>') or { EXCEPTION: equations between brackets (side effects) }
              (Index^ = #$C7) or (Index^ = #$C8) or (Index^ = #$C9)) and { ('<=', '>=' and '<>') }
               (Level <> 0) then { Not on level 0: that is handled below! }
      begin           { Expressions like 'LET A=(INKEY$='A')'; we're now between these brackets }
        tType := TRUE;
        SubType := tType; { Signal: result is going to be numeric }
        TotalTypeKnown := TRUE;
        TypeKnown := FALSE;{ Start with a fresh subexpression type }
        inc(Index);
      end
      else if ((TokenMap[ord(Keyword)].TokenType <> 4) and (TokenMap[ord(Keyword)].TokenType <> 3) or  { Not evaluating an expression token ? }
               TokenBracket) then { Or evaluating an operand of a token ? }
      begin
        if (Index^ = '+') then { (Can apply to both string and numeric expressions) }
          inc(Index)
        else if (Index^ = '-') or (Index^ = '*') or (Index^ = '/') or (Index = '^') then { (Numeric only) }
        begin
          if (not SubType) then { Type was known to be string ? }
          begin
            Errorline('Type conflict in expression', BasicLineNo, StatementNo);
            ScanExpression := false;
            exit;
          end;
          inc(Index);
        end
        { Equations and logical operators turn the total result numeric, but each subexpression may be of any type }
        else if ((Index^ = '=') or (Index^ = '<') or (Index^ = '>') or
               (Index^ = #$C7) or (Index^ = #$C8) or (Index^ = #$C9)) and  { ('<=', '>=' and '<>') }
               (Level=0) then { Only evaluate these on level 0! }
        begin
          TotalTypeKnown := TRUE;
          tType := TRUE;  { Signal: result is going to be numeric }
          TypeKnown := FALSE;  { Start with a fresh subexpression type }
          inc(Index);
        end
        else
          More := FALSE;
      end
      else
        More := FALSE;
    end;
  end;
  if (not TotalTypeKnown) then { 'Simple' expression ? }
    tType := SubType;  { Set return type }
{$ifdef __DEBUG__}
  printf ('DEBUG - %sLeave ScanExpression, Type is %s, next char is \'%s\'\n',
          ListSpaces, *Type ? 'NUM' : 'ALPHA', TokenMap[**Index].Token);
  if (-- RecurseLevel > 0)
    memset (ListSpaces, ' ', RecurseLevel * 2);
  ListSpaces[RecurseLevel * 2] = '\0';
{$endif}
  ScanExpression := true;
end;

 function HandleClass01 (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar; var tType: boolean): boolean;

 {********************************************************************************************************************************}
 { Class 1 := Used in LET. A variable is required.                                                                                 }
 { `Type' is returned to handle the rest of this special statement (HandleClass02)                                                }
 { This function is also used to parse the variable name for DIM and FN.                                                          }
 {********************************************************************************************************************************}
 var
   VarNameLen: integer;
   ParseArray: integer;

 begin

 {$ifdef __DEBUG__}
   printf ("DEBUG - %sLine %d, statement %d, Enter Class 1, keyword \"%s\", next is \"%s\"\n",
           ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[Index^].Token);
 {$endif}
   if (Keyword = $A8) or (Keyword = $E9) then   { Do not parse any bracketing if checking DIM or FN }
     ParseArray := -1
   else if (Keyword = $F1) then       { LET is allowed to write to a substring }
     ParseArray := 1
   else
     ParseArray := 2;
   if (not ScanVariable (BasicLineNo, StatementNo, Keyword, Index, tType, VarNameLen, ParseArray)) then
   begin
     if (VarNameLen = 0) then
       BADTOKEN ('variable', TokenMap[ord(Index^)].Token, BasicLineNo, StatementNo);
     HandleClass01 := FALSE;
     exit;
   end;
   HandleClass01 := TRUE;
 end;

 function HandleClass02 (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar; tType: boolean): boolean;

 {********************************************************************************************************************************}
 { Class 2 := Used in LET. An expression, numeric or string, must follow.                                                          }
 { `Type' is the type as returned previously by the HandleClass01 call                                                            }
 {********************************************************************************************************************************}
 var
   SubType: boolean;

 begin
 {$ifdef __DEBUG__}
   printf ("DEBUG - %sLine %d, statement %d, Enter Class 2, keyword \"%s\", next is \"%s\"\n",
           ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[Index^].Token);
 {$endif}
   if (not ScanExpression (BasicLineNo, StatementNo, Keyword, Index, SubType, 0)) then
   begin
     HandleClass02 := FALSE;
     exit;
   end;
   if (SubType <> tType) then                                                                                             { Must match }
   begin
     ErrorLine('Bad assignment expression type', BasicLineNo, StatementNo);
     HandleClass02 := FALSE;
     exit;
   end;
   HandleClass02 := TRUE;
 end;

 function HandleClass03 (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar): boolean;

 {********************************************************************************************************************************}
 { Class 3 := A numeric expression may follow. Zero to be used in case of default.                                                 }
 {********************************************************************************************************************************}

 begin
 {$ifdef __DEBUG__}
   printf ("DEBUG - %sLine %d, statement %d, Enter Class 3, keyword \"%s\", next is \"%s\"\n",
           ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[Index^].Token);
 {$endif}
   if (Index^ = ':') or (Index^ = #$0D) then  { No expression following ? }
   begin
     HandleClass03 := TRUE; { Then we're done already }
     exit;
   end;
   if (Keyword = $FD) and (Index^ = '#') then { EXCEPTION: CLEAR may take a stream rather than a numeric expression }
   begin
     inc(Index);
     if (not SignalInterface1 (BasicLineNo, StatementNo, 0)) then { (Which is Interface1/Opus specific) }
     begin
       HandleClass03 := FALSE;
       exit;
     end;
     if (Index^ = ':') or (Index^ = #$0D) then { No expression following ? }
     begin
       HandleClass03 := TRUE; { Then we're done already }
       exit;
     end;
   end;
   HandleClass03 := HandleClass06 (BasicLineNo, StatementNo, Keyword, Index);{ Find numeric expression }
 end;

 function HandleClass04 (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar): boolean;

 {********************************************************************************************************************************}
 { Class 4 := A single character variable must follow.                                                                             }
 {********************************************************************************************************************************}
 var
   tType: boolean;
   VarNameLen: integer;

 begin

 {$ifdef __DEBUG__}
   printf ("DEBUG - %sLine %d, statement %d, Enter Class 4, keyword \"%s\", next is \"%s\"\n",
           ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[Index^].Token);
 {$endif}
   if (not ScanVariable (BasicLineNo, StatementNo, Keyword, Index, tType, VarNameLen, 0)) then
   begin
     if (VarNameLen = 0) then
       BADTOKEN ('variable', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
     HandleClass04 := FALSE;
     exit;
   end;
   if (VarNameLen <> 1) or not tType then { Not single letter or not a numeric variable ? }
   begin
     ErrorLine ('Wrong variable type', BasicLineNo, StatementNo);
     HandleClass04 := FALSE;
     exit;
   end;
   HandleClass04 := TRUE;
 end;

 function HandleClass05 (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar): boolean;

 {********************************************************************************************************************************}
 { Class 5 := A set of items may be given.                                                                                         }
 {********************************************************************************************************************************}
 var
  tType: boolean;
  More: boolean = TRUE;
  VarNameLen: integer;
 begin
 {$ifdef __DEBUG__}
   printf ("DEBUG - %sLine %d, statement %d, Enter Class 5, keyword \"%s\", next is \"%s\"\n",
           ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[Index^].Token);
 {$endif}
   while (More) do
   begin
     while (Index^ = ';') or (Index^ = ',') or (Index^ = '''') do { One of the separator characters ? }
       inc(Index);     { (More than one may follow) }
     if (Index^ = ':') or (Index^ = #$0D) then   { End of statement or end of line ? }
       More := FALSE
     else if (Index^ = '#') then  { A stream ? }
     begin
       inc(Index);  { (Step past the '#' mark) }
       if (not ScanStream (BasicLineNo, StatementNo, Keyword, Index)) then
       begin
         HandleClass05 := FALSE;
         exit;
       end;
     end
     else if (TokenMap[ord(Index^)].TokenType = 2) or  { A colour parameter ? }
              (Index^ = #$AD) then        { TAB ? }
     begin
       inc(Index);              { (Skip the token) }
       if (not HandleClass06 (BasicLineNo, StatementNo, Keyword, Index)) then { Find parameter (numeric expression) }
       begin
         HandleClass05 := FALSE;
         exit;
       end;
     end
     else if (Index^ = #$AC) then { AT ? }
     begin
       inc(Index);                                                                                            { (Skip the token) }
       if (not HandleClass06 (BasicLineNo, StatementNo, Keyword, Index)) then { Find first parameter (numeric expression) }
       begin
         HandleClass05 := FALSE;
         exit;
       end;
       if (CheckEnd (BasicLineNo, StatementNo, Index)) then
       begin
         HandleClass05 := FALSE;
         exit;
       end;
       if (Index^ <> ',') then  { (Required separator token) }
       begin
         BADTOKEN ('","', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
         HandleClass05 := FALSE;
         exit;
       end;
       inc(Index);    { (Skip the token) }
       if (not HandleClass06 (BasicLineNo, StatementNo, Keyword, Index)) then { Find second parameter (numeric expression) }
       begin
         HandleClass05 := FALSE;
         exit;
       end;
     end
     else if (Keyword = $EE) and (Index^ = #$CA) then { INPUT may use LINE }
     begin
       inc(Index);    { (Skip the token) }
       if (not ScanVariable (BasicLineNo, StatementNo, Keyword, Index, tType, VarNameLen, 0)) then
       begin
         if (VarNameLen = 0) then
           BADTOKEN ('variable', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
           HandleClass05 := FALSE;
           exit;
       end;
       if (tType) then    { Not a alphanumeric variable ? }
       begin
         ErrorLine(' INPUT LINE requires an alphanumeric variable',BasicLineNo, StatementNo);
         HandleClass05 := FALSE;
         exit;
       end;
     end
     else if (not ScanExpression (BasicLineNo, StatementNo, Keyword, Index, tType, 0)) then   { Get expression }
     begin
       HandleClass05 := FALSE;
       exit;
     end;
     if (Index^ = ':') or (Index^ = #$0D) then  { End of statement or end of line ? }
       More := FALSE;
     if (More) then
       if (Index^ <> ';') and (Index^ <> ',') and (Index^ <> '''') then    { One of the separator characters ? }
       begin
         BADTOKEN ('separator ";", "," or "''"', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
         HandleClass05 := FALSE;
         exit;
       end;
   end;
   HandleClass05 := TRUE;
 end;

 function HandleClass06 (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar): boolean;

 {********************************************************************************************************************************}
 { Class 6 := A numeric expression must follow.                                                                                    }
 {********************************************************************************************************************************}
 var
    tType: boolean =TRUE;

 begin
 {$ifdef __DEBUG__}
   printf ("DEBUG - %sLine %d, statement %d, Enter Class 6, keyword \"%s\", next is \"%s\"\n",
           ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[ord(Index^)].Token);
 {$endif}
   if (not ScanExpression (BasicLineNo, StatementNo, Keyword, Index, tType, 0)) then  { Get expression }
   begin
     HandleClass06 := FALSE;
     exit;
   end;
   if not tType and (Keyword <> $C0) then  { Must be numeric }
   begin
     ErrorLine(' Expected numeric expression', BasicLineNo, StatementNo);
     HandleClass06 := FALSE;
     exit;
   end;
   HandleClass06 := TRUE;
 end;

 function HandleClass07 (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar): boolean;

 {********************************************************************************************************************************}
 { Class 7 := Handles colour items.                                                                                                }
 { Effectively the same as Class 6                                                                                                }
 {********************************************************************************************************************************}

 begin
 {$ifdef __DEBUG__}
   printf ("DEBUG - %sLine %d, statement %d, Enter Class 7, keyword \"%s\", next is \"%s\"\n",
           ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[ord(Index^)].Token);
 {$endif}
   HandleClass07 :=  HandleClass06 (BasicLineNo, StatementNo, Keyword, Index);                                   { Find numeric expression }
 end;

 function HandleClass08 (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar): boolean;

 {********************************************************************************************************************************}
 { Class 8 := Two numeric expressions, separated by a comma, must follow.                                                          }
 {********************************************************************************************************************************}

 begin
 {$ifdef __DEBUG__}
   printf ("DEBUG - %sLine %d, statement %d, Enter Class 8, keyword \"%s\", next is \"%s\"\n",
           ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[ord(Index^)].Token);
 {$endif}
   if (not HandleClass06 (BasicLineNo, StatementNo, Keyword, Index)) then { Find first numeric expression }
   begin
     HandleClass08 := FALSE;
     exit;
   end;
   if (Index^ <> ',') then
   begin
     BADTOKEN ('","', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
     HandleClass08 := FALSE;
     exit;
   end;
   inc(Index);
   HandleClass08 := (HandleClass06 (BasicLineNo, StatementNo, Keyword, Index));   { Find second numeric expression }
 end;

 function HandleClass09 (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar): boolean;

 {********************************************************************************************************************************}
 { Class 9 := As for class 8 but colour items may precede the expression.                                                          }
 { Used only by PLOT and DRAW. Colour items are TokenType 2                                                                       }
 {********************************************************************************************************************************}
 var
   CheckColour : boolean = TRUE;
 begin
 {$ifdef __DEBUG__}
   printf ("DEBUG - %sLine %d, statement %d, Enter Class 9, keyword \"%s\", next is \"%s\"\n",
           ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[ord(Index^)].Token);
 {$endif}
   while (CheckColour) do
   begin
     if (CheckEnd (BasicLineNo, StatementNo, Index)) then
     begin
       HandleClass09 := FALSE;
       exit;
     end;
     if (TokenMap[ord(Index^)].TokenType = 2) then { A colour parameter ? }
     begin
       inc(Index);                                                                                              { Skip the token }
       if (not HandleClass06 (BasicLineNo, StatementNo, Keyword, Index)) then   { Find parameter (numeric expression) }
       begin
         HandleClass09 := FALSE;
         exit;
       end;
       if (CheckEnd (BasicLineNo, StatementNo, Index)) then
       begin
         HandleClass09 := FALSE;
         exit;
       end;
       if (Index^ <> ';') then  { All colour parameters must be separated with semicolons }
       begin
         BADTOKEN ('";"', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
         HandleClass09 := FALSE;
         exit;
       end;
       inc(Index);                                                                                                { Skip the ";' }
     end
     else
       CheckColour := FALSE;
   end;
   if (CheckEnd (BasicLineNo, StatementNo, Index)) then
   begin
     HandleClass09 := FALSE;
     exit;
   end;
   HandleClass09 := (HandleClass08 (BasicLineNo, StatementNo, Keyword, Index));
 end;

 function HandleClass10 (BasicLineNo: integer;StatementNo: integer; Keyword: integer; var Index: pchar): boolean;

 {********************************************************************************************************************************}
 { Class 10 := A string expression must follow.                                                                                    }
 {********************************************************************************************************************************}
 var
   tType: boolean;

 begin

 {$ifdef __DEBUG__}
   printf ("DEBUG - %sLine %d, statement %d, Enter Class 10, keyword \"%s\", next is \"%s\"\n",
           ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[ord(Index^)].Token);
 {$endif}
   if (not ScanExpression (BasicLineNo, StatementNo, Keyword, Index, tType, 0)) then { Get expression }
   begin
     HandleClass10 := FALSE;
     exit;
   end;
   if (tType) then                                                                                                     { Must be string }
   begin
     ErrorLine(' Expected string expression', BasicLineNo, StatementNo);
     HandleClass10 := FALSE;
     exit;
   end;
   HandleClass10 := TRUE;
 end;

 function HandleClass11 (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar): boolean;

 {********************************************************************************************************************************}
 { Class 11 := Handles cassette routines.                                                                                          }
 {********************************************************************************************************************************}
 var
   tType: boolean;
   VarNameLen: integer;
   MoveLoop: integer;
   WhichChannel : byte = 0;    { (Default is no channel; for tape) }


 begin
 {$ifdef __DEBUG__}
   printf ("DEBUG - %sLine %d, statement %d, Enter Class 11, keyword \"%s\", next is \"%s\"\n",
           ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[ord(Index^)].Token);
 {$endif}
     case (Keyword) of
       $EF,      { (LOAD) }
       $D6,      { (VERIFY) }
       $D5:
       begin
         if (Index^ = '*')  then { (MERGE) }
         begin
            inc(Index);
            if (not ScanChannel (BasicLineNo, StatementNo, Keyword, Index, WhichChannel)) then
            begin
              HandleClass11 := FALSE;
              exit;
            end;
            if (WhichChannel <> ord('m')) and (WhichChannel <> ord('b')) and (WhichChannel <> ord('n')) then
            begin
              ErrorLine('You cannot LOAD/VERIFY/MERGE from the '+TokenMap[WhichChannel].Token+' channel',
                       BasicLineNo, StatementNo);
              HandleClass11 := FALSE;
              exit;
            end;
         end else if (Index^ = 'not ') then { 128K RAM-bank ? }
         begin
            inc(Index);
            case (Is48KProgram) of { Then the program must be 128K }
            -1 : Is48KProgram := 0;  { Set the flag }
             1 : begin
               ErrorLine('contains 128K file I/O, but the program also uses UDGs "T" and/or "U"', BasicLineNo, StatementNo);
               HandleClass11 := FALSE;
               exit;
             end;
             0 : begin end;
            end;
          end;
          if (WhichChannel <> 0) and (WhichChannel <> ord('m')) then { Not tape nor microdrive/disk channel ? }
          begin
            if (Index^ <> ':') and (Index^ <> #$0D) and   { (End of statement) }
                (Index^ <> #$AF) and  { (CODE) }
                (Index^ <> #$E4) and  { (DATA) }
                (Index^ <> #$CA) and  { (LINE) }
                (Index^ <> #$AA) then{ (SCREEN$) }
            begin
              ErrorLine('The '+ TokenMap[WhichChannel].Token+' channel does not use filenames',BasicLineNo, StatementNo);
              HandleClass11 := FALSE;
              exit;
            end;
          end
          else
          begin
            if (Index^ = '"') then { Look for a filename }
            begin
              while (Index^ = '"') do { Concatenated strings are ok, since they allow the use of the " character }
              begin   { (And an empty string is allowed here as well) }
                inc(Index);
                while (Index^ <> '"') do  { Find closing quote }
                begin
                  if (Index^ = #$0D) then  { End of line ? }
                  begin
                    ErrorLine('Unexpected end of line', BasicLineNo, StatementNo);
                    HandleClass11 := FALSE;
                    exit;
                  end;
                  inc(Index);
                end;  { Step past it }
                inc(Index);
              end;
            end
            else if (Index^ = ':') or (Index^ = #$0D) or  { (End of statement) }
                     (Index^ = #$AF) or                                                                            { (CODE) }
                     (Index^ = #$E4) or                                                                            { (DATA) }
                     (Index^ = #$CA) or                                                                            { (LINE) }
                     (Index^ = #$AA) then                                                                          { (SCREEN$) }
            begin
              BADTOKEN ('filename', TokenMap[ord(Index^)].Token, BasicLineNo, StatementNo);
              HandleClass11 := FALSE;
              exit;
            end
            else if (not HandleClass10 (BasicLineNo, StatementNo, Keyword, Index)) then { Look for a string expression }
            begin
              HandleClass11 := FALSE;
              exit;
            end;
          end;
          if (Index^ <> ':') and (Index^ <> #$0D) then { (Continue unless end of statement) }
          begin
            if (Index^ = #$AF) then { CODE }
            begin
              if (Keyword = $D5) then  { (We were doing MERGE ?) }
              begin
                Errorline('Cannot MERGE CODE', BasicLineNo, StatementNo);
                HandleClass11 := FALSE;
                exit;
              end;
              inc(Index);
              if (Index^ <> ':') and (Index^ <> #$0D) then { Optional address ? }
              begin
                if (not HandleClass06 (BasicLineNo, StatementNo, Keyword, Index)) then { Find address (numeric expression) }
                begin
                  HandleClass11 := FALSE;
                  exit;
                end;
                if (Index^ = ',') then { Also optional length ? }
                begin
                  inc(Index);
                  if (not HandleClass06 (BasicLineNo, StatementNo, Keyword, Index)) then { Find length (numeric expression) }
                  begin
                    HandleClass11 := FALSE;
                    exit;
                  end;
                end
                else if (Index^ <> ':') and (Index^ <> #$0D) then
                begin
                  BADTOKEN ('","', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
                  HandleClass11 := FALSE;
                  exit;
                end;
              end;
            end
            else if (Index^ = #$AA) then { SCREEN$ }
              inc(Index)
            else if (Index^ = #$E4) then { DATA }
            begin
              inc(Index);
              if (CheckEnd (BasicLineNo, StatementNo, Index)) then
              begin
                HandleClass11 := FALSE;
                exit;
              end;
              if (not ScanVariable (BasicLineNo, StatementNo, Keyword, Index, tType, VarNameLen, -1)) then
              begin
                if (VarNameLen = 0) then
                  BADTOKEN ('variable', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
                HandleClass11 := FALSE;
                exit;
              end;
              if (VarNameLen <> 1) then { Not single letter ? }
              begin
                Errorline('Wrong variable type; must be single character',BasicLineNo, StatementNo);
                HandleClass11 := FALSE;
                exit;
              end;
              if (Index^ <> '(') then { The variable must be followed by an empty index }
              begin
                Errorline('DATA requires an array', BasicLineNo, StatementNo);
                HandleClass11 := FALSE;
                exit;
              end;
              inc(Index);
              if (Index^ <> ')') then
              begin
                ErrorLine( 'DATA requires an empty array index',BasicLineNo, StatementNo);
                HandleClass11 := FALSE;
                exit;
              end;
              inc(Index);
            end
            else
            begin
              ErrorLine('Unknown file-type ',BasicLineNo, StatementNo, TokenMap[ord(Index^)].Token);
              HandleClass11 := FALSE;
              exit;
            end;
          end;
         end;
        $F8:
        begin
          if (Index^ = '*') then { (SAVE) }
          begin
            inc(Index);
            if (not ScanChannel (BasicLineNo, StatementNo, Keyword, Index, WhichChannel)) then
            begin
              HandleClass11 := FALSE;
              exit;
            end;
            if (WhichChannel <> ord('m')) and (WhichChannel <> ord('b')) and (WhichChannel <> ord('n')) then
            begin
              ErrorLine('You cannot SAVE to the "'+ TokenMap[WhichChannel].Token+'" channel',
                       BasicLineNo, StatementNo);
              HandleClass11 := FALSE;
              exit;
            end;
          end
          else if (Index^ = 'not ') then { 128K RAM-bank ? }
          begin
            inc(Index);
            case (Is48KProgram) of { Then the program must be 128K }
              -1 : Is48KProgram := 0;  { Set the flag }
               1 :
               begin
                 ErrorLine(' contains 128K file I/O, but the program also uses UDGs "T" and/or "U"', BasicLineNo);
                 HandleClass11 := FALSE;
                 exit;
               end;
               0 : begin end;
            end;
          end;
          if (WhichChannel <> 0) and (WhichChannel <> ord('m')) then { Not tape nor microdrive/disk channel ? }
          begin
            if (Index^ <> ':') and (Index^ <> #$0D) and  { (End of statement) }
                (Index^ <> #$AF) and                                                                                 { (CODE) }
                (Index^ <> #$E4) and                                                                                 { (DATA) }
                (Index^ <> #$CA) and                                                                                 { (LINE) }
                (Index^ <> #$AA) then   { (SCREEN$) }
            begin
              ErrorLine('The "'+TokenMap[WhichChannel].Token+'" channel does not use filenames', BasicLineNo, StatementNo);
              HandleClass11 := FALSE;
              exit;
            end;
          end
          else
          begin
            if (Index^ = '"') then  { Look for a filename }
            begin
              if ((Index + 1)^ = '"') and  { Empty string (not allowed) ? }
                  ((Index + 2)^ <> '"') then { Concatenation - first char is a " (allowed) ? }
              begin
                ErrorLine(' Empty filename not allowed', BasicLineNo, StatementNo);
                HandleClass11 := FALSE;
                exit;
              end;
              while (Index^ = '"') do { Concatenated strings are ok, since they allow the use of the " character }
              begin
                inc(Index);
                while (Index^ <> '"') do { Find closing quote }
                begin
                  if (Index^ = #$0D) then { End of line ? }
                  begin
                    ErrorLine('Unexpected end of line', BasicLineNo, StatementNo);
                    HandleClass11 := FALSE;
                    exit;
                  end;
                  inc(Index);
                end; { Step past it }
                inc(Index);
              end;
             end
             else if (Index^ = ':') or (Index^ = #$0D) or  { (End of statement) }
                     (Index^ = #$AF) or   { (CODE) }
                     (Index^ = #$E4) or   { (DATA) }
                     (Index^ = #$CA) or   { (LINE) }
                     (Index^ = #$AA) then { (SCREEN$) }
            begin
              BADTOKEN ('filename', TokenMap[ord(Index^)].Token, BasicLineNo, StatementNo);
              HandleClass11 := FALSE;
              exit;
            end
            else if (not HandleClass10 (BasicLineNo, StatementNo, Keyword, Index)) then { Look for a string expression }
            begin
              HandleClass11 := FALSE;
              exit;
            end;
              if (Index^ <> ':') and (Index^ <> #$0D) then { (Continue unless end of statement) }
              begin
                if (Index^ = #$AF) then { CODE }
                begin
                  inc(Index);
                  if (not HandleClass06 (BasicLineNo, StatementNo, Keyword, Index)) then { Find address (numeric expression) }
                  begin
                    HandleClass11 := FALSE;
                    exit;
                  end;
                  if (Index^ <> ',') then
                  begin
                    ErrorLine(TokenMap[Keyword].Token+' CODE requires both address and length',
                             BasicLineNo, StatementNo);
                    HandleClass11 := FALSE;
                    exit;
                  end;
                  inc(Index);
                  if (not HandleClass06 (BasicLineNo, StatementNo, Keyword, Index)) then { Find length (numeric expression) }
                  begin
                    HandleClass11 := FALSE;
                    exit;
                  end;
                end
                else if (Index^ = #$E4) then { DATA }
                begin
                  inc(Index);
                  if (CheckEnd (BasicLineNo, StatementNo, Index)) then
                  begin
                    HandleClass11 := FALSE;
                    exit;
                  end;
                  if (not ScanVariable (BasicLineNo, StatementNo, Keyword, Index, tType, VarNameLen, -1)) then
                  begin
                    if (VarNameLen = 0) then
                      BADTOKEN ('variable', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
                    HandleClass11 := FALSE;
                    exit;
                  end;
                  if (VarNameLen <> 1) then  { Not single letter ? }
                  begin
                    ErrorLine('Wrong variable type; must be single character',BasicLineNo, StatementNo);
                    HandleClass11 := FALSE;
                    exit;
                  end;
                  if (Index^ <> '(') then { The variable must be followed by an empty index }
                  begin
                    ErrorLine('DATA requires an array',BasicLineNo, StatementNo);
                    HandleClass11 := FALSE;
                    exit;
                  end;
                  inc(Index);
                  if (Index^ <> ')') then
                  begin
                    ErrorLine('DATA requires an empty array index',BasicLineNo, StatementNo);
                    HandleClass11 := FALSE;
                    exit;
                  end;
                  inc(Index);
                end
                else if (Index^ = #$AA) then { SCREEN$ }
                  inc(Index)
                else if (Index^ = #$CA) then { LINE }
                begin
                  inc(Index);
                  if (not HandleClass06 (BasicLineNo, StatementNo, Keyword, Index)) then { Find starting line (numeric expression) }
                  begin
                    HandleClass11 := FALSE;
                    exit;
                  end;
                end
                else
                begin
                  ErrorLine(' Unknown file-type ',BasicLineNo, StatementNo, TokenMap[ord(Index^)].Token);
                  HandleClass11 := FALSE;
                  exit;
                end;
              end;
          end;
        end;
        $CF:
        begin
          if (not SignalInterface1 (BasicLineNo, StatementNo, 0)) then { (CAT) }
          begin
            HandleClass11 := FALSE;
            exit;
          end;
          if (Index^ = '#') then { A stream may precede the drive number }
          begin
            inc(Index);
            if (not ScanStream (BasicLineNo, StatementNo, Keyword, Index)) then
            begin
              HandleClass11 := FALSE;
              exit;
            end;
            if (Index^ <> ',') then { (Required separator token) }
            begin
              BADTOKEN ('","', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
              HandleClass11 := FALSE;
              exit;
            end;
          end;
          if (not HandleClass06 (BasicLineNo, StatementNo, Keyword, Index)) then { Find drive number (numeric expression) }
          begin
            HandleClass11 := FALSE;
            exit;
          end;
        end;
       $D0:
       begin
          if (not ScanChannel (BasicLineNo, StatementNo, Keyword, Index, WhichChannel)) then{ (FORMAT) }
          begin
            HandleClass11 := FALSE;
            exit;
          end;
          case (chr(WhichChannel)) of
            'm' :
            begin
              if (CheckEnd (BasicLineNo, StatementNo, Index)) then { "m" requires an additional new volume name }
              begin
                HandleClass11 := FALSE;
                exit;
              end;
              if (Index^ = '"') then { Look for a volume name }
              begin
                if ((Index + 1)^ = '"') and   { Empty string (not allowed) ? }
                   ((Index + 2)^ <> '"') then    { Concatenation - first char is a " (allowed) ? }
                begin
                  ErrorLine('Empty volume name not allowed', BasicLineNo, StatementNo);
                  HandleClass11 := FALSE;
                  exit;
                end;
                while (Index^ = '"') do { Concatenated strings are ok, since they allow the use of the " character }
                begin
                  inc(index);
                  while Index^ <> '"' do { Find closing quote }
                  begin
                    if (Index^ = #$0D) then { End of line ? }
                    begin
                      ErrorLine('Unexpected end of line',BasicLineNo, StatementNo);
                      HandleClass11 := FALSE;
                      exit;
                    end;
                    inc(index);
                  end;
                  inc(index);
                end;
              end
              else if (not HandleClass10 (BasicLineNo, StatementNo, Keyword, Index)) then  { Look for a string expression }
              begin
                HandleClass11 := FALSE;
                exit;
              end;
            end;
            't' , { The port channels requires an additional baud rate }
            'b' ,
            'j' :
            begin
              if (Index^ <> ';') then  { The joystick channel requires a operand to turn it on or off }
              begin
               BADTOKEN ('";"', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
               HandleClass11 := FALSE;
               exit;
              end;
              inc(Index);
              if (CheckEnd (BasicLineNo, StatementNo, Index)) then
              begin
               HandleClass11 := FALSE;
               exit;
              end;
              if (not HandleClass06 (BasicLineNo, StatementNo, Keyword, Index)) then { Look for a numeric expression }
              begin
               HandleClass11 := FALSE;
               exit;
              end;
            end;
            else begin
              Errorline('You cannot FORMAT from the '+TokenMap[WhichChannel].Token+' channel',BasicLineNo, StatementNo);
              HandleClass11 := FALSE;
              exit;
            end;
          end;
       end;
       $D1:
       begin
         for MoveLoop := 0 to 2 do
          begin
            if (Index^ = '#') then
            begin
              inc(Index);  { (Step past the '#' mark) }
              if (not ScanStream (BasicLineNo, StatementNo, Keyword, Index)) then
              begin
               HandleClass11 := FALSE;
               exit;
              end;
            end
            else
            begin
              if (not ScanChannel (BasicLineNo, StatementNo, Keyword, Index, &WhichChannel)) then
              begin
               HandleClass11 := FALSE;
               exit;
              end;
              case (chr(WhichChannel)) of
                'm' : begin
                  if (CheckEnd (BasicLineNo, StatementNo, Index)) then { "m" requires an additional filename }
                  begin
                   HandleClass11 := FALSE;
                   exit;
                  end;
                   if (Index^ = '\"') then { Look for a filename }
                   begin
                     if ((Index + 1)^ = '"') and     { Empty string (not allowed) ? }
                         ((Index + 2)^ <> '\"') then { Concatenation - first char is a " (allowed) ? }
                     begin
                       ErrorLine('Empty filename not allowed',BasicLineNo, StatementNo);
                       HandleClass11 := FALSE;
                       exit;
                     end;
                     while (Index^ = '"') do
                     begin
                       inc(index);
                       while Index^ <> '"' do
                       begin
                         if (Index^ = #$0D) then
                         begin
                           ErrorLine('Unexpected end of line',BasicLineNo, StatementNo);
                           HandleClass11 := FALSE;
                           exit;
                         end;
                         inc(Index);
                       end;
                       inc(Index);
                     end;
                   end
                   else if (not HandleClass10 (BasicLineNo, StatementNo, Keyword, Index)) then
                   begin
                     HandleClass11 := FALSE;
                     exit;
                   end;
                end;
                't',
                'b',
                'n',
                'd' : begin end;   { All these are okay and don't use extra parameters }
                's' :
                begin
                  if (MoveLoop = 0) then { The "s" channel is write-only }
                  begin
                    ErrorLine('You cannot MOVE from the "s" channel',BasicLineNo, StatementNo);
                    HandleClass11 := FALSE;
                    exit;
                  end;
                end;
                'k' :
                begin
                  if (MoveLoop = 1) then { The "k" channel is read-only }
                  begin
                    ErrorLine('You cannot MOVE to the "k" channel',BasicLineNo, StatementNo);
                    HandleClass11 := FALSE;
                    exit;
                  end;
                end;
                else begin
                  ErrorLine('You cannot MOVE from/to the '+TokenMap[WhichChannel].Token+' channel',BasicLineNo, StatementNo);
                  HandleClass11 := FALSE;
                  exit;
              end;
            end;
            if (MoveLoop = 0) then
            begin
              if (Index^ <> #$CC) then { Required token 'TO' }
              begin
                BADTOKEN ('"TO"', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
                HandleClass11 := FALSE;
                exit;
              end;
              inc(Index);
            end;
          end;
         end;
       end;
       $D2:
       begin
        if (Index^ = 'not ') then { (ERASE) }
        begin   { 128K RAM-bank ? }
          inc(Index);
          case (Is48KProgram) of { Then the program must be 128K }
            -1 : Is48KProgram := 0;  { Set the flag }
             1 :
             begin
               Errorline('contains 128K file I/O, but the program also uses UDGs "T" and/or "U"', BasicLineNo,StatementNo);
               HandleClass11 := FALSE;
               exit;
             end;
             0 : begin end;
          end;
        end
          else
          begin
            if (not ScanChannel (BasicLineNo, StatementNo, Keyword, Index, &WhichChannel)) then
            begin
              HandleClass11 := FALSE;
              exit;
            end;
            if (WhichChannel <> ord('m')) then
            begin
              ErrorLine('You can only ERASE from the not  or "m" channel',BasicLineNo, StatementNo);
              HandleClass11 := FALSE;
              exit;
            end;
          end;
          if (CheckEnd (BasicLineNo, StatementNo, Index)) then { Additional filename required }
          begin
            HandleClass11 := FALSE;
            exit;
          end;
          if (Index^ = '\"') then { Look for a filename }
          begin
            if ((Index + 1)^ = '"') and  { Empty string (not allowed) ? }
                ((Index + 2)^ <> '"') then { Concatenation - first char is a " (allowed) ? }
            begin
              Errorline('Empty filename not allowed',BasicLineNo, StatementNo);
              HandleClass11 := FALSE;
              exit;
            end;
            while (Index^ = '\"') do
            begin
              inc(Index);
              while Index^ <> '"' do
              begin
                if (Index^ = #$0D) then
                begin
                  ErrorLine('Unexpected end of line',BasicLineNo, StatementNo);
                  HandleClass11 := FALSE;
                  exit;
                end;
                inc(Index);
              end;
            end;
          end
          else if (not HandleClass10 (BasicLineNo, StatementNo, Keyword, Index)) then
          begin
            HandleClass11 := FALSE;
            exit;
          end;
       end;
       $D3:
       begin
          if (not ScanStream (BasicLineNo, StatementNo, Keyword, Index)) then  { (OPEN #) }
          begin
            HandleClass11 := FALSE;
            exit;
          end;
          if (Index^ <> ';') and (Index^ <> ',') then                                                          { (Required token) }
          begin
            BADTOKEN ('";"', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
            HandleClass11 := FALSE;
            exit;
          end;
          inc(Index);
          if (not ScanChannel (BasicLineNo, StatementNo, Keyword, Index, &WhichChannel)) then
          begin
            HandleClass11 := FALSE;
            exit;
          end;
          case (chr(WhichChannel)) of
            'm' :
            begin
              if (CheckEnd (BasicLineNo, StatementNo, Index)) then { "m" requires an additional filename }
              begin
                HandleClass11 := FALSE;
                exit;
              end;
              if (Index^ = '\"') then { Look for a filename }
              begin
               if ((Index + 1)^ = '"') and  { Empty string (not allowed) ? }
                   ((Index + 2)^ <> '\"') then { Concatenation - first char is a " (allowed) ? }
               begin
                 ErrorLine('Empty filename not allowed',BasicLineNo, StatementNo);
                 HandleClass11 := FALSE;
                 exit;
               end;
               while Index^ = '"' do
               begin
                 inc(index);
                 while Index^ <> '"' do
                 begin
                   if (Index^ = #$0D) then
                   begin
                     ErrorLine('Unexpected end of line',BasicLineNo, StatementNo);
                     HandleClass11 := FALSE;
                     exit;
                   end;
                   inc(Index);
                 end;
               end;
              end
              else if (not HandleClass10 (BasicLineNo, StatementNo, Keyword, Index)) then
              begin
                HandleClass11 := FALSE;
                exit;
              end;
            end;
            's',
            'k',
            'p',
            't',
            'b',
            'n',
            #$AF,
            #$CF,
            '#' : begin end;  { All these are okay and don't use extra parameters }
            else begin
              ErrorLine('You cannot attach a stream to the "'+TokenMap[WhichChannel].Token+'" channel', BasicLineNo, StatementNo);
              HandleClass11 := FALSE;
              exit;
            end;
          end;
          if (Index^ <> ':') and (Index^ <> #$0D) then { (Continue unless end of statement) }
          begin
            if (Index^ = #$BF) then { IN }
            begin
              inc(Index);
              if (not SignalInterface1 (BasicLineNo, StatementNo, 2)) then { This is Opus specific }
              begin
                HandleClass11 := FALSE;
                exit;
              end;
            end
            else if (Index^ = #$DF) or    { OUT }
                     (Index^ = #$B9) then { EXP }
            begin
              inc(Index);
              if (not SignalInterface1 (BasicLineNo, StatementNo, 2)) then { This is Opus specific }
              begin
                HandleClass11 := FALSE;
                exit;
              end;
              if (not HandleClass06 (BasicLineNo, StatementNo, Keyword, Index)) then { Find numeric expression }
              begin
                HandleClass11 := FALSE;
                exit;
              end;
            end
            else if (Index^ = #$A5) then { RND }
            begin
              inc(Index);
              if (not SignalInterface1 (BasicLineNo, StatementNo, 2)) then { This is Opus specific }
              begin
                HandleClass11 := FALSE;
                exit;
              end;
              if (not HandleClass06 (BasicLineNo, StatementNo, Keyword, Index)) then { Find numeric expression }
              begin
                HandleClass11 := FALSE;
                exit;
              end;
              if (Index^ = ',') then { RND may take a second parameter }
              begin
                inc(Index);
                if (not HandleClass06 (BasicLineNo, StatementNo, Keyword, Index)) then
                begin
                  HandleClass11 := FALSE;
                  exit;
                end;
              end;
            end;
          end;
       end;
       $D4:
        if (not ScanStream (BasicLineNo, StatementNo, Keyword, Index)) then { (CLOSE #) }
        begin
          HandleClass11 := FALSE;
          exit;
        end;
     end;
     HandleClass11 := TRUE;
    end;

    function HandleClass12 (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar): boolean;

    {********************************************************************************************************************************}
    { Class 12 := One or more string expressions, separated by commas, must follow.                                                   }
    {********************************************************************************************************************************}
    var
     tType: boolean;
     More : boolean = TRUE;
    begin
      {$ifdef __DEBUG__}
      printf ("DEBUG - %sLine %d, statement %d, Enter Class 12, keyword \"%s\", next is \"%s\"\n",
             ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[ord(Index^)].Token);
      {$endif}
      while (More) do
      begin
        if (not ScanExpression (BasicLineNo, StatementNo, Keyword, Index, tType, 0)) then { Find an expression }
        begin
          HandleClass12 := FALSE;
          exit;
        end;
        if (tType) then  { Must be string }
        begin
          ErrorLine('requires string parameters',BasicLineNo, StatementNo, TokenMap[Keyword].Token);
          HandleClass12 := FALSE;
          exit;
        end;
        if (Index^ = ':') or (Index^ = #$0D) then  { End of statement or end of line ? }
          More := FALSE
        else if (Index^ = ',') then { Separator ? }
          inc(Index)
        else if (Index^ <> ')') then
        begin
          BADTOKEN ('","', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
          HandleClass12 := FALSE;
          exit;
        end;
      end;
      HandleClass12 := TRUE;
    end;

    function HandleClass13 (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar): boolean;

    {********************************************************************************************************************************}
    { Class 13 := One or more expressions, separated by commas, must follow (DATA, DIM, FN)                                           }
    {********************************************************************************************************************************}
    var
      tType: boolean;
      More : boolean = TRUE;


    begin
      {$ifdef __DEBUG__}
      printf ("DEBUG - %sLine %d, statement %d, Enter Class 13, keyword \"%s\", next is \"%s\"\n",
             ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[ord(Index^)].Token);
      {$endif}
      if (Index^ = ')') and (Keyword = $A8) then { FN requires zero or more expressions }
      begin
        { (The closing bracket is a required character and stepped over in CheckSyntax) }
        HandleClass13 := TRUE;
        exit;
      end;
      while (More) do
      begin
       if (not ScanExpression (BasicLineNo, StatementNo, Keyword, Index, tType, 0)) then  { Find an expression }
       begin
         { (Don't care about the type) }
         HandleClass13 := FALSE;
         exit;
       end;
       if (Keyword = $E9) and not tType then  { DIM requires numeric dimensions }
       begin
         Errorline('"DIM" requires numeric dimensions', BasicLineNo, StatementNo);
         HandleClass13 := FALSE;
         exit;
       end;
       if (Keyword = $E9) or (Keyword = $A8) then { FN and DIM end with a closing bracket }
       begin
         if (CheckEnd (BasicLineNo, StatementNo, Index)) then
         begin
           HandleClass13 := FALSE;
           exit;
         end;
         if (Index^ = ')') then
           More := FALSE;
       end;
       if (Index^ = ':') or (Index^ = #$0D) then { End of statement or end of line ? }
         More := FALSE
       else if (Index^ = ',') then  { Separator ? }
         inc(Index)
       else if (Index^ <> ')') then
       begin
         BADTOKEN ('","', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
         HandleClass13 := FALSE;
         exit;
       end;
      end;
      HandleClass13 := TRUE;
    end;

    function HandleClass14 (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar): boolean;

    {********************************************************************************************************************************}
    { Class 14 := One or more variables, separated by commas, must follow (READ)                                                      }
    {********************************************************************************************************************************}

    var
      tType: boolean;
      More : boolean = TRUE;
      VarNameLen: integer;

    begin

      {$ifdef __DEBUG__}
      printf ("DEBUG - %sLine %d, statement %d, Enter Class 14, keyword \"%s\", next is \"%s\"\n",
             ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[ord(Index^)].Token);
      {$endif}
      while (More) do
      begin
       if (not ScanVariable (BasicLineNo, StatementNo, Keyword, Index, tType, VarNameLen, 2)) then { We need a variable }
       begin
         if (VarNameLen = 0) then { (Not a variable) }
           BADTOKEN ('variable', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
         HandleClass14 := FALSE;
         exit;
       end;
       if (Index^ = ':') or (Index^ = #$0D) then { End of statement or end of line ? }
         More := FALSE
       else if (Index^ = ',') then { Separator ? }
         inc(Index)
       else
       begin
         BADTOKEN ('","', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
         HandleClass14 := FALSE;
         exit;
       end;
      end;
      HandleClass14 := TRUE;
    end;

    function HandleClass15 (BasicLineNo: integer; StatementNo: integer; Keyword: integer; var Index: pchar): boolean;

    {********************************************************************************************************************************}
    { Class 15 := DEF FN                                                                                                              }
    {********************************************************************************************************************************}

    var
      tType: boolean;
      VarNameLen: integer;

    begin
      {$ifdef __DEBUG__}
      printf ("DEBUG - %sLine %d, statement %d, Enter Class 15, keyword \"%s\", next is \"%s\"\n",
             ListSpaces, BasicLineNo, StatementNo, TokenMap[Keyword].Token, TokenMap[ord(Index^)].Token);
      {$endif}
      if (not ScanVariable (BasicLineNo, StatementNo, Keyword, Index, tType, VarNameLen, -1)) then
      begin
        if (VarNameLen = 0) then
          BADTOKEN ('variable', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
        HandleClass15 := FALSE;
        exit;
      end;
      if (VarNameLen <> 1) then  { Not single letter ? }
      begin
        ErrorLine('Wrong variable type; must be single character',BasicLineNo, StatementNo);
        HandleClass15 := FALSE;
        exit;
      end;
      if (Index^ = '(') then { Arguments to be passed to the expression while running ? }
      begin
       inc(Index);
       if (CheckEnd (BasicLineNo, StatementNo, Index)) then
       begin
         HandleClass15 := FALSE;
         exit;
       end;
       if (Index^ = ')') then
       begin
         ErrorLine('Empty parameter array not allowed', BasicLineNo, StatementNo);
         HandleClass15 := FALSE;
         exit;
       end;
       while (Index^ <> ')') do
       begin
         if (not ScanVariable (BasicLineNo, StatementNo, Keyword, Index, tType, VarNameLen, -1)) then
         begin
           if (VarNameLen = 0) then
             BADTOKEN ('variable', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
           HandleClass15 := FALSE;
           exit;
         end;
         if (VarNameLen <> 1) then { Not single letter ? }
         begin
           ErrorLine('Wrong variable type; must be single character',BasicLineNo, StatementNo);
           HandleClass15 := FALSE;
           exit;
         end;
         if (Index^ <> #$0E) then { A number (marker) must follow each parameter }
         begin
           BADTOKEN ('number marker', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
           HandleClass15 := FALSE;
           exit;
         end;
         inc(Index);                                                                                              { (Step past it) }
         if (CheckEnd (BasicLineNo, StatementNo, Index)) then
           HandleClass15 := FALSE;
           exit;
         if (Index^ <> ')') then
         begin
           if (Index^ = ',') then
             inc(Index)
           else
           begin
             BADTOKEN ('","', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
             HandleClass15 := FALSE;
             exit;
           end;
         end;
       end;
       inc(Index);
     end;
     if (CheckEnd (BasicLineNo, StatementNo, Index)) then
     begin
       HandleClass15 := FALSE;
       exit;
     end;
     if (Index^ <> '=') then
     begin
      BADTOKEN ('"="', TokenMap[ord(Index^)].Token,BasicLineNo, StatementNo);
      HandleClass15 := FALSE;
      exit;
     end;
     inc(Index);
     if (CheckEnd (BasicLineNo, StatementNo, Index)) then
     begin
       HandleClass15 := FALSE;
       exit;
     end;
     HandleClass15 := ScanExpression (BasicLineNo, StatementNo, Keyword, Index, tType, 0);                             { Find an expression }
    end;

    function CheckSyntax (BasicLineNo: integer; Line: pchar): boolean;

    {********************************************************************************************************************************}
    { Pre   : `Line' points to the converted BASIC line. An initial syntax check has been done already -                             }
    {         - The line number makes sense;                                                                                         }
    {         - Keywords are at the beginning of each statement and not within a statement;                                          }
    {         - There are less than 128 statements in the line;                                                                      }
    {         - Brackets match on a per-line basis (but not necessarily on a per-statement basisnot )                                   }
    {         - Quotes match;                                                                                                        }
    { Post  : The line has been checked against 'normal' Spectrum BASIC syntax. Extended devices that change the normal syntax       }
    {         (such as Interface 1 or disk interfaces) are not understood and will generate error messages.                          }
    { Import: None.                                                                                                                  }
    {********************************************************************************************************************************}
    var
      StrippedLine: array [0..MAXLINELENGTH] of char;
      StrippedIndex: pchar;
      Keyword: byte;
      AllOk : boolean = TRUE;
      VarType: boolean;
      StatementNo : integer = 0;
      ClassIndex  : integer = -1;


    begin
     StrippedIndex := @StrippedLine[0];
     while (Line^ <> #$0D) {and (Line^ <> #00)} do { First clean up the line, dropping number expansions and trash }
     begin
       case ord(Line^) of
         0 ,
         1 ,
         2 ,
         3 ,
         4 ,
         5 ,
         6 ,
         7 ,
         8 ,
         9 ,
         10 ,
         11 ,
         12 ,
         13 : begin end;
         14 :
         begin
           StrippedIndex^ := Line^;
           Line += 5;  { EXCEPTION: keep the marker, but drop the number }
           inc(StrippedIndex);
         end;
         15 : begin end;
         16 ,
         17 ,
         18 ,
         19 ,
         20 ,
         21 : inc(Line);
         22 ,
         23 : inc(Line,2);
         24 ,
         25 ,
         26 ,
         27 ,
         28 ,
         29 ,
         30 ,
         31 ,
         32 : begin end; { (We don't care for spaces eithernot ) }
         else begin
           StrippedIndex^ := Line^; { Pass on only 'good' bits }
           inc(StrippedIndex);
         end;
       end;
       inc(Line);
     end;
     StrippedIndex^ := #$0D;
     inc(StrippedIndex);
     StrippedIndex^ := #0;
     StrippedIndex := @(StrippedLine[0]);  { Ok, here goes... }
     while AllOk and (StrippedIndex^ <> #$0D) do  { Handle each statement }
     begin
       inc(StatementNo);
       Keyword := ord(StrippedIndex^);
       inc(StrippedIndex);
       if (Keyword = $EA) then { 'REM' ? }
       begin
          CheckSyntax := TRUE;
          exit;
          { Then we're done checking this line }
       end;
       if (TokenMap[Keyword].TokenType <> 0) and (TokenMap[Keyword].TokenType <> 1) and (TokenMap[Keyword].TokenType <> 2) then    { (Sanity) }
       begin
         if (Keyword = $A9) then  { EXCEPTION: POINT may be used as command }
         begin
           if (StrippedIndex^ <> '#') then  { It must be followed by a stream in that case }
           begin
             ErrorLine('Keyword ("'+TokenMap[Keyword].Token+'")',BasicLineNo, StatementNo);
             CheckSyntax := FALSE;
             exit;
           end;
           inc(StrippedIndex);
           if (not ScanStream (BasicLineNo, StatementNo, Keyword, StrippedIndex)) then { (Also signals Interface1/Opus specificness) }
           begin
             CheckSyntax := FALSE;
             exit;
           end;
           if (StrippedIndex^ <> ';') then
           begin
             BADTOKEN ('";"', TokenMap[ord(StrippedIndex^)].Token,BasicLineNo, StatementNo);
             CheckSyntax := FALSE;
             exit;
           end;
           inc(StrippedIndex);
           if (not HandleClass06 (BasicLineNo, StatementNo, Keyword, &StrippedIndex)) then
           begin
             CheckSyntax := FALSE;
             exit;
           end;
         end
         else
         begin
           Errorline('Keyword ("'+TokenMap[Keyword].Token+'")',BasicLineNo, StatementNo);
           CheckSyntax := FALSE;
           exit;
         end;
       end
       else
       begin
         ClassIndex := -1;
    {$ifdef __DEBUG__}
         RecurseLevel := 0;
         ListSpaces[0] := '\0';
         printf ("DEBUG - Start Line %d, Statement %d, Keyword \"%s\"\n", BasicLineNo, StatementNo, TokenMap[Keyword].Token);
    {$endif}
         if (Keyword = $E1) or (Keyword = $F0) and (StrippedIndex^ = '#') then { EXCEPTION: LIST and LLIST may take a stream }
         begin
           inc(StrippedIndex);
           if (not ScanStream (BasicLineNo, StatementNo, Keyword, StrippedIndex)) then { (Also signals Interface1/Opus specificness) }
           begin
             CheckSyntax := FALSE;
             exit;
           end;
           if (StrippedIndex^ <> ':') and (StrippedIndex^ <> #$0D) then { Line number is not required }
           begin
             if (StrippedIndex^ <> ',') then
             begin
               BADTOKEN ('"\"', TokenMap[ord(StrippedIndex^)].Token,BasicLineNo, StatementNo);
               CheckSyntax := FALSE;
               exit;
             end;
             inc(StrippedIndex);
           end;
         end;
         inc(ClassIndex);
         while AllOk and (TokenMap[Keyword].KeywordClass[ClassIndex] <> #0) do { Handle all class parameters }
         begin
           if (StrippedIndex^ = #$0D) then
           begin
             if (TokenMap[Keyword].KeywordClass[ClassIndex] <> #3) and   { Class 5 and 3 need 0 or more arguments }
                 (TokenMap[Keyword].KeywordClass[ClassIndex] <> #5) then
             begin
               if (Keyword = $EB) and (TokenMap[Keyword].KeywordClass[ClassIndex] = #$CD) or { 'FOR' doesn't need 'STEP' parameter }
                   (Keyword = $FC) and (TokenMap[Keyword].KeywordClass[ClassIndex] = ',') then  { 'DRAW' doesn't need a third parameter }
                 inc(ClassIndex)
               else
               begin
                 ErrorLine('Unexpected end of line', BasicLineNo, StatementNo);
                 AllOk := FALSE;
               end;
             end;
           end
           else if (TokenMap[Keyword].KeywordClass[ClassIndex] >= #32) then { Required token or class ? }
           begin
             if (StrippedIndex^ <> TokenMap[Keyword].KeywordClass[ClassIndex]) then { (Required token) }
             begin
               if (Keyword = $EB) and (TokenMap[Keyword].KeywordClass[ClassIndex] = #$CD) and (StrippedIndex^ = ':') or
                   (Keyword = $FC) and (TokenMap[Keyword].KeywordClass[ClassIndex] = ',') and (StrippedIndex^ = ':') then
                 inc(ClassIndex)  { EXCEPTION: 'FOR' does not require the 'STEP' parameter }
                                 { EXCEPTION: 'DRAW' does not require the third parameter }
               else
               begin                                                                                               { (Token not there) }
                 Errorline('Expected "'+ TokenMap[ord(TokenMap[Keyword].KeywordClass[ClassIndex])].Token+
                           '", but got "'+TokenMap[ord(StrippedIndex^)].Token+'"',BasicLineNo, StatementNo);
                 AllOk := FALSE;
               end;
             end
             else
               inc(StrippedIndex);
           end
           else                                                                                                   { (Command class) }
             case (TokenMap[Keyword].KeywordClass[ClassIndex]) of
                #1 : AllOk := HandleClass01 (BasicLineNo, StatementNo, Keyword, StrippedIndex, VarType);
                #2 : AllOk := HandleClass02 (BasicLineNo, StatementNo, Keyword, StrippedIndex, VarType);
                #3 : AllOk := HandleClass03 (BasicLineNo, StatementNo, Keyword, StrippedIndex);
                #4 : AllOk := HandleClass04 (BasicLineNo, StatementNo, Keyword, StrippedIndex);
                #5 : AllOk := HandleClass05 (BasicLineNo, StatementNo, Keyword, StrippedIndex);
                #6 : AllOk := HandleClass06 (BasicLineNo, StatementNo, Keyword, StrippedIndex);
                #7 : AllOk := HandleClass07 (BasicLineNo, StatementNo, Keyword, StrippedIndex);
                #8 : AllOk := HandleClass08 (BasicLineNo, StatementNo, Keyword, StrippedIndex);
                #9 : AllOk := HandleClass09 (BasicLineNo, StatementNo, Keyword, StrippedIndex);
               #10 : AllOk := HandleClass10 (BasicLineNo, StatementNo, Keyword, StrippedIndex);
               #11 : AllOk := HandleClass11 (BasicLineNo, StatementNo, Keyword, StrippedIndex);
               #12 : AllOk := HandleClass12 (BasicLineNo, StatementNo, Keyword, StrippedIndex);
               #13 : AllOk := HandleClass13 (BasicLineNo, StatementNo, Keyword, StrippedIndex);
               #14 : AllOk := HandleClass14 (BasicLineNo, StatementNo, Keyword, StrippedIndex);
               #15 : AllOk := HandleClass15 (BasicLineNo, StatementNo, Keyword, StrippedIndex);
             end;
           inc(ClassIndex);
         end;
       end;
       if AllOk and (Keyword <> $FA) then { Handling 'IF' and AllOk (i.e. just read the "THEN" ?) }
       begin   { (Nope, go check end of statement) }
         if (StrippedIndex^ <> ':') and (StrippedIndex^ <> #$0D) then
         begin
           if (Keyword = $FB) and (StrippedIndex^ = '#') then { EXCEPTION: 'CLS #' is allowed }
           begin
             inc(StrippedIndex);
             if (not SignalInterface1 (BasicLineNo, StatementNo, 0)) then
             begin
               CheckSyntax := FALSE;
               exit;
             end;
             if (StrippedIndex^ <> ':') and (StrippedIndex^ <> #$0D) then
             begin
               Errorline('Expected end of statement, but got '+TokenMap[ord(StrippedIndex^)].Token
                                   +'"',BasicLineNo, StatementNo);
               AllOk := FALSE;
             end;
           end
           else
           begin
             Errorline('Expected end of statement, but got "'+TokenMap[ord(StrippedIndex^)].Token+'"',BasicLineNo, StatementNo);
             AllOk := FALSE;
           end;
         end;
       end;
       if AllOk and (StrippedIndex^ = ':') then { (Placing this check here allows weird (but legal) construction "THEN :") }
       begin
         inc(StrippedIndex);
         while (StrippedIndex^ = ':') do { (More consecutive ':' separators are allowed) }
         begin
           inc(StrippedIndex);
           inc(StatementNo);
         end;
       end;
     end;
     CheckSyntax := AllOk;
    end;

    procedure perror(error: string);
    begin
      writeln(error);
    end;

    procedure AppError(error: string);
    begin
      writeln(error);
    end;

    //const
    //  CaseIndependant = TRUE;
    //  NoWarnings = FALSE;
    //  Quiet = FALSE;
    //  DoCheckSyntax = TRUE;

    procedure bas_to_tap(FileNameIn: String; FileNameOut: String; AutoStart: word; BlockName: string);

    {********************************************************************************************************************************}
    { >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> MAIN PROGRAM <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< }
    { Import: MatchToken, HandleNumbers, ExpandSequences, PrepareLine, CheckSyntax.                                                  }
    {********************************************************************************************************************************}
    var
      FpIn: Textfile;
      FpOut: File;
      LineIn: Array[0..MAXLINELENGTH] of char;
      //LineIn: pchar;   { One line read from the ASCII file }
      BasicIndex: pchar;                         { Current scan position in the (converted) ASCII line }
      ResultIndex: pchar;                  { Current write index in to the binary result line }
      Token: byte;
      LineCount: integer               = 0;  { Line count in the ASCII file }
      BasicLineNo: integer;                  { Current BASIC line number }
      SubLineCount: integer;                 { Current statement number }
      ExpectKeyword: boolean;                { If TRUE, the next scanned token must be a keyword }
      InString: boolean;                     { TRUE while inside quotes }
      BracketCount: integer            = 0;  { Match opening and closing brackets }
      ObjectLength: integer;                 { Binary length of one converted line }
      BlockSize: integer               = 0;  { Total size of the TAP block }
      Parity: byte                     = 0;  { Overall block parity }
      AllOk: boolean                   = TRUE;
      EndOfFile: boolean               = FALSE;
      WriteError: boolean              = FALSE; { Fingers crossed that this stays FALSE... }
      Cnt: integer;
      readed: longint;
      written: longint;
      LineInS: String;

    begin
      //LineIn := @lin[0];

      if (AutoStart < 0) or (AutoStart >= 10000) then
        perror ('Invalid auto-start line number '+ inttostr(AutoStart));
      TapeHeader.HStartLo := byte(AutoStart and $FF);
      TapeHeader.HStartHi := byte(AutoStart >> 8);
      for Cnt := 0 to 9 do
        if length(BlockName) >= Cnt+1 then
          TapeHeader.HName[Cnt] := BlockName[Cnt+1]
        else
          TapeHeader.HName[Cnt] := ' ';

      try
        AssignFile(FpIn, FileNameIn);
        Reset(FpIn);
        AssignFile(FpOut, FileNameOut);
        Rewrite(FpOut,1);
      except
        On E: EFileNotFoundException do AppError('Error reading file '+FileNameIn+' not found.');
        On E: EInOutError do AppError('Input output Error')
        else AppError('Error openning file.');
      end;
      Parity := TapeHeader.Flag2;
      Blockwrite (FpOut, TapeHeader, sizeof (TapeHeader_s), written);
      if (written < sizeof (TapeHeader_s)) then
      begin
        AllOk := FALSE;
        WriteError := TRUE;
      end;  { Write dummy header to get space }
      while (AllOk and not EndOfFile) do
      begin
        readln(FpIn, LineIn); //LineIn^);
//        strpcopy(LineIn, LineInS);
        if (strlen(LineIn) > 0) then
        begin
          LineIn := strcat(LineIn,#13);
          inc(LineCount);
          if (strlen (LineIn) >= MAXLINELENGTH) then
          begin  { We don't require an end-of-line marker }
           AppError('ERROR - Line '+inttostr(LineCount)+'too long');
           AllOk := FALSE;
          end
          else begin
            BasicLineNo := PrepareLine (pchar(@LineIn), LineCount, BasicIndex);
            if BasicLineNo < 0 then
            begin
              if BasicLineNo = -1 then                                                                                         { (Error) }
               AllOk := FALSE
              else  begin end; { (Line should simply be skipped) }
            end
            else if (BasicLineNo >= 10000) then
            begin
              ErrorLine('line larger than the maximum allowed', BasicLineNo);
              AllOk := FALSE;
            end
            else
            begin
              if (not Quiet) then
              begin
                Message('Converting line '+inttostr(LineCount)+' -> '+inttostr(BasicLineNo));
                flush (stdout);  { (Force line without end-of-line to be printed) }
              end;
              InString := FALSE;
              ExpectKeyword := TRUE;
              SubLineCount := 1;
              ResultIndex := pchar(@ResultingLine) + 4;   { Reserve space for line number and length }
              HandlingDEFFN := FALSE;
              while (BasicIndex^ <> #0) and AllOk do
              begin
                if (InString) then
                begin
                  if (BasicIndex^ = '"') then
                  begin
                    InString := FALSE;
                    ResultIndex^ := BasicIndex^;
                    Inc(BasicIndex);
                    Inc(ResultIndex);
                    while (BasicIndex^ = ' ') do { Skip trailing spaces }
                      Inc(ResultIndex);
                  end
                  else
                   case (ExpandSequences (BasicLineNo, BasicIndex, ResultIndex, FALSE)) of
                     -1 : AllOk := FALSE; { (Error - already reported) }
                      0 :
                      begin
                        ResultIndex^ := BasicIndex^;  { (No expansion made) }
                        inc(ResultIndex);
                        inc(BasicIndex);
                      end;
                      1 : begin end;
                   end;
                end
                else if (BasicIndex^ = '"') then
                begin
                  if (ExpectKeyword) then
                  begin
                    ErrorLine('Expected keyword but got quote', BasicLineNo, SubLineCount);
                    AllOk := FALSE;
                  end
                  else
                  begin
                   InString := TRUE;
                   ResultIndex^ := BasicIndex^;
                   inc(ResultIndex);
                   inc(BasicIndex);
                  end;
                end
                else if (ExpectKeyword) then
                begin
                  case (MatchToken (BasicLineNo, TRUE, BasicIndex, chr(Token))) of
                    -2 : AllOk := FALSE;  { (Error - already reported) }
                    -1 :
                    begin
                      ErrorLine('Expected keyword but got token ',BasicLineNo, SubLineCount, TokenMap[Token].Token);                              { (Not keyword) }
                      AllOk := FALSE;
                    end;
                     0 :
                    begin
                      Errorline('Expected keyword but got ',   { (No match) }
                                      BasicLineNo, SubLineCount, TokenMap[ord(BasicIndex^)].Token);
                      AllOk := FALSE;
                    end;
                     1 :
                    begin
                      ResultIndex^ := chr(Token); { (Found keyword) }
                      inc(ResultIndex);
                      if (Token <> ord(':')) then { Special exception; empty statement }
                        ExpectKeyword := FALSE;
                      if (Token = DEFFN) then
                      begin
                        HandlingDEFFN := TRUE;
                        InsideDEFFN := FALSE;
                      end;
                      if (Token = $EA) then  { Special exception; REM }
                      begin
                        while (BasicIndex^<>#0) do  { Simply copy over the remaining part of the line, }
                        begin
                                                    { disregarding token or number expansions }
                                                    { As brackets aren't tested for, the match counting stops here }
                                                    { (a closing bracket in a REM statement will not be seen by BASIC) }
                            case (ExpandSequences (BasicLineNo, BasicIndex, ResultIndex, FALSE)) of
                              -1 : AllOk := FALSE;
                               0 :
                               begin
                                 ResultIndex^ := BasicIndex^;
                                 Inc(ResultIndex);
                                 Inc(BasicIndex);
                               end;
                               1 : begin end;
                            end;
                        end;
                      end;
                    end;
                  end;
                end
                else if (BasicIndex^ = '(') then   { Opening bracket }
                begin
                  inc(BracketCount);
                  ResultIndex^ := BasicIndex^;
                  Inc(ResultIndex);
                  Inc(BasicIndex);
                  if (HandlingDEFFN and not InsideDEFFN) then
                  begin
                   {$ifdef __DEBUG__}
                   begin
                     printf ("DEBUG - %sDEFFN, Going inside parameter list\n", ListSpaces);
                     InsideDEFFN := TRUE;  { Signal: require special treatmentnot  }
                   end;
                  #else
                     InsideDEFFN := TRUE;  { Signal: require special treatmentnot  }
                  {$endif}
                  end
                end
                else if (BasicIndex^ = ')') then   { Closing bracket }
                begin
                   if (HandlingDEFFN and InsideDEFFN) then
                   begin
                  {$ifdef __DEBUG__}
                     printf ("DEBUG - %sDEFFN, Done parameter list\n", ListSpaces);
                     InsideDEFFN := TRUE;  { Signal: require special treatmentnot  }
                  {$endif}
                    ResultIndex^ := #$0E;  { Insert room for the evaluator (call by value) }
                    Inc(ResultIndex);
                    ResultIndex^ := #$00;
                    Inc(ResultIndex);
                    ResultIndex^ := #$00;
                    Inc(ResultIndex);
                    ResultIndex^ := #$00;
                    Inc(ResultIndex);
                    ResultIndex^ := #$00;
                    Inc(ResultIndex);
                    ResultIndex^ := #$00;
                    Inc(ResultIndex);
                    InsideDEFFN := FALSE;    { Mark end of special treatment }
                    HandlingDEFFN := FALSE;  { (The part after the '=' is just like eg. LET) }
                   end;
                   dec(BracketCount);
                   if (BracketCount < 0) then { More closing than opening brackets }
                   begin
                     ErrorLine('Too many closing brackets', BasicLineNo, SubLineCount);
                     AllOk := FALSE;
                   end
                   else
                   begin
                     ResultIndex^ := BasicIndex^;
                     Inc(ResultIndex);
                     Inc(BasicIndex);
                   end;
                end
                else
                if (BasicIndex^ = ',') and HandlingDEFFN and InsideDEFFN then
                begin
                {$ifdef __DEBUG__}
                 printf ("DEBUG - %sDEFFN, Done parameter; another follows\n", ListSpaces);
                {$endif}
                ResultIndex^ := #$0E;  { Insert room for the evaluator (call by value) }
                Inc(ResultIndex);
                ResultIndex^ := #$00;
                Inc(ResultIndex);
                ResultIndex^ := #$00;
                Inc(ResultIndex);
                ResultIndex^ := #$00;
                Inc(ResultIndex);
                ResultIndex^ := #$00;
                Inc(ResultIndex);
                ResultIndex^ := #$00;
                Inc(ResultIndex);
                ResultIndex^ := BasicIndex^;
                Inc(ResultIndex);
                Inc(BasicIndex);
              end
                else
                begin
                  case (MatchToken (BasicLineNo, FALSE, BasicIndex, chr(Token))) of
                    -2 : AllOk := FALSE;   { (Error - already reported) }
                    -1 :
                    begin
                      ErrorLine('Unexpected keyword "'+TokenMap[Token].Token+'"',{ (Match but keyword) }
                                      BasicLineNo, SubLineCount);
                      AllOk := FALSE;
                    end;
                     0 :
                     begin
                       case (HandleNumbers (BasicLineNo, BasicIndex, ResultIndex)) of { (No token) }
                          0 :
                          begin
                           case (ExpandSequences (BasicLineNo, &BasicIndex, &ResultIndex, TRUE)) of { (No number) }
                             -1 : AllOk := FALSE; { (Error - already reported) }
                              0 :
                                if (is_alfa (BasicIndex^)) then { (No expansion made) }
                                  while (is_alnum (BasicIndex^)) do { Skip full strings in one go }
                                  begin
                                    ResultIndex^ := BasicIndex^;
                                    Inc(ResultIndex);
                                    Inc(BasicIndex);
                                  end
                                else begin
                                  ResultIndex^ := BasicIndex^;
                                  Inc(ResultIndex);
                                  Inc(BasicIndex);
                                end;
                               1 : begin end;
                            end;

                          end;
                          -1 : AllOk := FALSE;
                       end;
                     end;
                     1 :
                     begin
                       ResultIndex^ := chr(Token);  { (Found token, no keyword) }
                       inc(ResultIndex);
                       if (Token = ord(':')) or (Token = $CB) then
                       begin
                         ExpectKeyword := TRUE;
                         HandlingDEFFN := FALSE;
                         if (BracketCount <> 0) then { All brackets match ? }
                         begin
                           Errorline('Too few closing brackets',BasicLineNo, SubLineCount);
                           AllOk := FALSE;
                         end;
                         inc(SubLineCount);
                         if (SubLineCount > 127) then
                         begin
                           ErrorLine('has too many statements\n', BasicLineNo);
                           AllOk := FALSE;
                         end;
                       end
                       else if (Token = $C4) then { BIN }
                       begin
                         if (HandleBIN (BasicLineNo, BasicIndex, ResultIndex) = -1) then
                           AllOk := FALSE;
                       end;
                     end;
                  end;
                end;
              end;
              ResultIndex^ := #$0D;
              Inc(ResultIndex);
              if AllOk and (BracketCount <> 0) then { All brackets match ? }
              begin
                ErrorLine('Too few closing brackets', BasicLineNo, SubLineCount);
                AllOk := FALSE;
              end;
              if (AllOk and DoCheckSyntax) then
                AllOk := CheckSyntax (BasicLineNo, pchar(@ResultingLine) + 4);  { Check the syntax of the decoded line }
              if (AllOk) then
              begin
                ObjectLength := integer(ResultIndex - pchar(@ResultingLine));
                ResultingLine[0] := byte(BasicLineNo >> 8);  { Line number is put reversed }
                ResultingLine[1] := byte(BasicLineNo and $FF);
                ResultingLine[2] := byte((ObjectLength - 4) and $FF);  { Make sure this runs on any CPU }
                ResultingLine[3] := byte((ObjectLength - 4) >> 8);
                BlockSize += ObjectLength;
                for Cnt := 0 to ObjectLength-1 do
                  Parity := Parity xor ResultingLine[Cnt];
                if (BlockSize > 41500) then { (= 65368-23755-<some work/stack space>) }
                begin
                  ErrorLine('Object file too large', BasicLineNo);
                  AllOk := FALSE;
                end
                else begin
                  Blockwrite (FpOut, ResultingLine, ObjectLength, written);
                  if (written <> ObjectLength) then
                  begin
                     AllOk := FALSE; WriteError := TRUE;
                  end;
              end;
            end;
            end;
          end;
        end
        else
          EndOfFile := TRUE;
      end;
      if (not Quiet) then
      begin
       Message('                                     ');
      end;
      if (not WriteError) then { Finish the TAP file no matter what went wrong, unless it was the writing itself }
      begin
       ResultingLine[0] := Parity;   { Now it's time to write the 'real' header in front }
       blockwrite(FpOut, ResultingLine, 1,readed);
       if (readed < 1) then
       begin
         perror ('ERROR - Write error');
         closefile (FpIn);
         closefile (FpOut);
         exit;
       end;
       TapeHeader.HLenLo := byte(BlockSize and $FF);
       TapeHeader.HBasLenLo := TapeHeader.HLenLo;
       TapeHeader.HLenHi := byte(BlockSize >> 8);
       TapeHeader.HBasLenHi := TapeHeader.HLenHi;
       TapeHeader.LenLo2 := byte((BlockSize + 2) and $FF);
       TapeHeader.LenHi2 := byte((BlockSize + 2) >> 8);
       Parity := 0;
       for Cnt := 2 to 19 do
         Parity := Parity xor TapeHeaderA[Cnt];
       TapeHeader.Parity1 := Parity;
       seek (FpOut, 0);
       blockwrite(FpOut, TapeHeader, sizeof (TapeHeader_s), written);
       if written < sizeof (TapeHeader_s) then
       begin
         perror ('ERROR - Write error');
         exit;
       end;
       if (not Quiet) then
       begin
         if (AllOk) then
           Message('Donenot  Listing contains '+inttostr(LineCount)+'lines')
         else
           Message('Listing as far as done contains '+inttostr(LineCount - 1)+'lines');
         if (Is48KProgram >= 0) then
            if Is48KProgram = 48 then
               Message('Note: this program can only be used in 48K mode)')
            else
              Message('Note: this program can only be used in 128K mode)');
         case (UsesInterface1) of
           -1 : begin end;                                                                                       { Neither of them }
            0 : Message('Note: this program requires Interface 1 or Opus Discovery');
            1 : Message('Note: this program requires Interface 1');
            2 : Message('Note: this program requires an Opus Discovery');
         end;
       end;
      end
      else
        perror ('ERROR - Write error');
      closeFile (FpIn);
      closeFile (FpOut);
    end;


begin
end.

