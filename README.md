# ServerSnap7Enhanced
Emulate Plc Siemens memory block (DB) server. Can access server data with Snap7 or alternative client. On server gui inteface can write or read single variable of a DB . Based on snap7 and mORMot libraries

See the manual Snap 7 Server Enhanced_manual.docx



How to compile:
Use Delphi from 10.1(Berlin) to 11(Alexandria). I use Sydney
Open project  and add <C:\ServerSnap7Enhanced\main\mormot\mORMot-master;> and <C:\ServerSnap7Enhanced\main\mormot\SQLite3> to library-path and browser-path in the option/language/delphi/library or add your mORMot library path for win64 and win32

Select win32 o win64 target
Build project 

Put the correct snap7 dll (32/64) for exe under exe path or on system path.

 
