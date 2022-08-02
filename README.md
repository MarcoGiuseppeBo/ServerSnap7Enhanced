# ServerSnap7Enhanced
Emulate Plc Siemens memory block (DB) server. 
 Can access server data with Snap7 or alternative client. 
 On server gui inteface can write or read single variable of a DB. 
 Based on snap7 and mORMot libraries

See the manual Snap 7 Server Enhanced_manual.docx or Pdf



How to compile:
Use Delphi from 10.1(Berlin) to 11(Alexandria). I use Delphi Sydney
Open project Server_snap7_enhanced.dpr.
  Add to your delphi  library-path and browser-path (win32/win64) 
   (option/language/delphi/library) the mORMot path
   
 - C:\ServerSnap7Enhanced\main\mormot\mORMot-master; 
  
 - C:\ServerSnap7Enhanced\main\mormot\SQLite3> 
  
  
  or add your mORMot path 

Select win32 o win64 target
Build project 

Put the correct snap7 dll (32/64)  under exe path or on system path.

 
