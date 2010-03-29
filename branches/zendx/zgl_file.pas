{
 *  Copyright © Kemka Andrey aka Andru
 *  mail: dr.andru@gmail.com
 *  site: http://andru-kun.inf.ua
 *
 *  This file is part of ZenGL.
 *
 *  ZenGL is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as
 *  published by the Free Software Foundation, either version 3 of
 *  the License, or (at your option) any later version.
 *
 *  ZenGL is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with ZenGL. If not, see http://www.gnu.org/licenses/
}
unit zgl_file;

{$I zgl_config.cfg}

interface

uses
  Windows,
  zgl_types;

type zglTFile = THandle;

type zglTFileList = zglTStringList;

const
  // Open Mode
  FOM_CREATE = $01; // Create
  FOM_OPENR  = $02; // Read
  FOM_OPENRW = $03; // Read&Write

  // Seek Mode
  FSM_SET    = $01;
  FSM_CUR    = $02;
  FSM_END    = $03;

procedure file_Open( var FileHandle : zglTFile; const FileName : String; const Mode : Byte );
function  file_MakeDir( const Directory : String ) : Boolean;
function  file_Exists( const FileName : String ) : Boolean;
function  file_Seek( const FileHandle : zglTFile; const Offset, Mode : LongWord ) : LongWord;
function  file_GetPos( const FileHandle : zglTFile ) : LongWord;
function  file_Read( const FileHandle : zglTFile; var Buffer; const Bytes : LongWord ) : LongWord;
function  file_Write( const FileHandle : zglTFile; const Buffer; const Bytes : LongWord ) : LongWord;
procedure file_Trunc( const FileHandle : zglTFile; const Bytes : LongWord );
function  file_GetSize( const FileHandle : zglTFile ) : LongWord;
procedure file_Flush( const FileHandle : zglTFile );
procedure file_Close( var FileHandle : zglTFile );
procedure file_Find( const Directory : String; var List : zglTFileList; const FindDir : Boolean );
procedure file_GetName( const FileName : String; var Result : String );
procedure file_GetExtension( const FileName : String; var Result : String );
procedure file_GetDirectory( const FileName : String; var Result : String );
procedure file_SetPath( const Path : String );

implementation

var
  filePath : String = '';

procedure file_Open;
begin
  case Mode of
    FOM_CREATE: FileHandle := CreateFile( PChar( filePath + FileName ), GENERIC_ALL, 0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0 );
    FOM_OPENR:  FileHandle := CreateFile( PChar( filePath + FileName ), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0 );
    FOM_OPENRW: FileHandle := CreateFile( PChar( filePath + FileName ), GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0 );
  end;
end;

function file_MakeDir;
begin
  Result := CreateDirectory( PChar( Directory ), nil );
end;

function file_Exists;
  var
    fileHandle : zglTFile;
begin
  file_Open( fileHandle, filePath + FileName, FOM_OPENR );
  Result := fileHandle <> INVALID_HANDLE_VALUE;
  if Result Then
    file_Close( fileHandle );
end;

function file_Seek;
begin
  case Mode of
    FSM_SET: Result := SetFilePointer( FileHandle, Offset, nil, FILE_BEGIN );
    FSM_CUR: Result := SetFilePointer( FileHandle, Offset, nil, FILE_CURRENT );
    FSM_END: Result := SetFilePointer( FileHandle, Offset, nil, FILE_END );
  end;
end;

function file_GetPos;
begin
  Result := SetFilePointer( FileHandle, 0, nil, FILE_CURRENT );
end;

function file_Read;
begin
  ReadFile( FileHandle, Buffer, Bytes, Result, nil );
end;

function file_Write;
begin
  WriteFile( FileHandle, Buffer, Bytes, Result, nil );
end;

procedure file_Trunc;
begin
end;

function file_GetSize;
begin
  Result := GetFileSize( FileHandle, nil );
end;

procedure file_Flush;
begin
  FlushFileBuffers( FileHandle );
end;

procedure file_Close;
begin
  CloseHandle( FileHandle );
  FileHandle := 0;
end;

procedure file_Find;
  var
    First : THandle;
    FList : {$IFDEF FPC} WIN32FINDDATAA {$ELSE} WIN32_FIND_DATA {$ENDIF};
begin
  First := FindFirstFile( PChar( Directory + '*' ), FList );
  repeat
    if FindDir Then
      begin
        if FList.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY = 0 Then continue;
      end else
        if FList.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY > 0 Then continue;
    SetLength( List.Items, List.Count + 1 );
    List.Items[ List.Count ] := FList.cFileName;
    INC( List.Count );
  until not FindNextFile( First, FList );
end;

procedure GetStr( const Str : String; var Result : String; const d : Char; const b : Boolean );
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
  if b Then
    Result := copy( Str, 1, pos )
  else
    Result := copy( Str, l - ( l - pos ) + 1, ( l - pos ) );
end;

procedure file_GetName;
  var
    tmp : String;
begin
  GetStr( FileName, Result, '/', FALSE );
  if Result = FileName Then
    GetStr( FileName, Result, '\', FALSE );
  GetStr( Result, tmp, '.', FALSE );
  Result := copy( Result, 1, length( Result ) - length( tmp ) - 1 );
end;

procedure file_GetExtension;
begin
  GetStr( FileName, Result, '.', FALSE );
end;

procedure file_GetDirectory;
begin
  GetStr( FileName, Result, '/', TRUE );
  if Result = '' Then
    GetStr( FileName, Result, '\', TRUE );
end;

procedure file_SetPath;
begin
  filePath := Path;
end;

end.
