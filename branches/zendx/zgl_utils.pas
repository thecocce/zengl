{
 * Copyright © Kemka Andrey aka Andru
 * mail: dr.andru@gmail.com
 * site: http://andru-kun.inf.ua
 *
 * This file is part of ZenGL
 *
 * ZenGL is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * ZenGL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
}
unit zgl_utils;

{$I zgl_config.cfg}

interface
uses
  Windows,
  zgl_types,
  zgl_log;

const
  LIB_ERROR  = 0;
  FILE_ERROR = 0;

function u_IntToStr( const Value : Integer ) : AnsiString;
function u_StrToInt( const Value : AnsiString ) : Integer;
function u_BoolToStr( const Value : Boolean ) : AnsiString;
function u_StrToBool( const Value : AnsiString ) : Boolean;

// Только для английских символов попадающих в диапазон 0..127
function u_StrUp( const str : AnsiString ) : AnsiString;
function u_StrDown( const str : AnsiString ) : AnsiString;
// Удаляет один символ из utf8-строки
procedure u_Backspace( var str : AnsiString );
// Возвращает количество символов в utf8-строке
function  u_Length( const str : AnsiString ) : Integer;
// Возвращает количество слов, разделеных разделителем d
function  u_Words( const str : AnsiString; const d : AnsiChar = ' ' ) : Integer;
function  u_GetWord( const Str : AnsiString; const n : Integer; const d : AnsiChar = ' ' ) : AnsiString;
// Возвращает строку обрезанную до первого встречного символа d с конца
procedure u_GetStr( const Str : AnsiString; var Result : AnsiString; const d : AnsiChar );
procedure u_SortList( var List : zglTStringList; iLo, iHi: Integer );

procedure u_Error( const errStr : AnsiString );
procedure u_Warning( const errStr : AnsiString );

function u_GetPOT( const v : Integer ) : Integer;

procedure u_Sleep( const msec : DWORD );

function dlopen ( lpLibFileName : PAnsiChar) : HMODULE; stdcall; external 'kernel32.dll' name 'LoadLibraryA';
function dlclose( hLibModule : HMODULE ) : Boolean; stdcall; external 'kernel32.dll' name 'FreeLibrary';
function dlsym  ( hModule : HMODULE; lpProcName : PAnsiChar) : Pointer; stdcall; external 'kernel32.dll' name 'GetProcAddress';

implementation
uses
  zgl_font;

function u_IntToStr;
begin
  Str( Value, Result );
end;

function u_StrToInt;
  var
    E : Integer;
begin
  Val( String( Value ), Result, E );
end;

function u_BoolToStr;
begin
  if Value Then
    Result := 'TRUE'
  else
    Result := 'FALSE';
end;

function u_StrToBool;
begin
  if Value = '1' Then
    Result := TRUE
  else
    if u_StrUp( Value ) = 'TRUE' Then
      Result := TRUE
    else
      Result := FALSE;
end;

function u_StrUp;
  var
    i, l : Integer;
begin
  l := length( Str );
  SetLength( Result, l );
  for i := 1 to l do
    if ( Byte( Str[ i ] ) >= 97 ) and ( Byte( Str[ i ] ) <= 122 ) Then
      Result[ i ] := AnsiChar( Byte( Str[ i ] ) - 32 )
    else
      Result[ i ] := Str[ i ];
end;

function u_StrDown;
  var
    i, l : Integer;
begin
  l := length( Str );
  SetLength( Result, l );
  for i := 1 to l do
    if ( Byte( Str[ i ] ) >= 65 ) and ( Byte( Str[ i ] ) <= 90 ) Then
      Result[ i ] := AnsiChar( Byte( Str[ i ] ) + 32 )
    else
      Result[ i ] := Str[ i ];
end;

procedure u_Backspace;
  var
    i, last : Integer;
begin
  if str = '' Then exit;
  i := 1;
  last := 0;
  while i <= length( str ) do
    begin
      last := i;
      font_GetCID( str, last, @i );
    end;

  SetLength( str, last - 1 )
end;

function u_Length;
  var
    i : Integer;
begin
  Result := 0;
  i := 1;
  while i <= length( str ) do
    begin
      INC( Result );
      font_GetCID( str, i, @i );
    end;
end;

function u_Words;
  var
    i, m : Integer;
begin
  Result := 0;
  m := 0;
  for i := 1 to length( Str ) do
    begin
      if ( Str[ i ] <> d ) and ( m = 0 ) Then
        begin
          INC( Result );
          m := 1;
        end;
      if ( Str[ i ] = d ) and ( m = 1 ) Then m := 0;
    end;
end;

function u_GetWord;
  label b;
  var
    i, p : Integer;
begin
  i := 0;
  Result := d + Str;

b:
  INC( i );
  p := Pos( d, Result );
  while Result[ p ] = d do Delete( Result, p, 1 );

  p := Pos( d, Result );
  if n > i Then
    begin
      Delete( Result, 1, p - 1 );
      goto b;
    end;

  Delete( Result, p, length( Result ) - p + 1 );
end;

procedure u_GetStr;
  var
    i, pos, l : Integer;
begin
  pos := 0;
  l := length( Str );
  for i := l downto 1 do
    if Str[ i ] = d Then
      begin
        pos := i;
        break;
      end;
  Result := copy( Str, l - ( l - pos ) + 1, ( l - pos ) );
end;

procedure u_SortList;
  var
    Lo, Hi : Integer;
    Mid, T : AnsiString;
begin
  Lo  := iLo;
  Hi  := iHi;
  Mid := List.Items[ ( Lo + Hi ) shr 1 ];

  repeat
    while List.Items[ Lo ] < Mid do INC( Lo );
    while List.Items[ Hi ] > Mid do DEC( Hi );
    if Lo <= Hi then
      begin
        T                := List.Items[ Lo ];
        List.Items[ Lo ] := List.Items[ Hi ];
        List.Items[ Hi ] := T;
        INC( Lo );
        DEC( Hi );
      end;
  until Lo > Hi;

  if Hi > iLo Then u_SortList( List, iLo, Hi );
  if Lo < iHi Then u_SortList( List, Lo, iHi );
end;

procedure u_Error;
begin
  MessageBoxA( 0, PAnsiChar( errStr ), 'ERROR!', MB_OK or MB_ICONERROR );

  log_Add( 'ERROR: ' + errStr );
end;

procedure u_Warning;
begin
  MessageBoxA( 0, PAnsiChar( errStr ), 'WARNING!', MB_OK or MB_ICONWARNING );

  log_Add( 'WARNING: ' + errStr );
end;

function u_GetPOT;
begin
  Result := v - 1;
  Result := Result or ( Result shr 1 );
  Result := Result or ( Result shr 2 );
  Result := Result or ( Result shr 4 );
  Result := Result or ( Result shr 8 );
  Result := Result or ( Result shr 16 );
  Result := Result + 1;
end;

procedure u_Sleep;
begin
  Sleep( msec );
end;

end.
