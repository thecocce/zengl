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

procedure file_Open( var FileHandle : zglTFile; const FileName : AnsiString; const Mode : Byte );
function  file_MakeDir( const Directory : AnsiString ) : Boolean;
function  file_Exists( const FileName : AnsiString ) : Boolean;
function  file_Seek( const FileHandle : zglTFile; const Offset, Mode : DWORD ) : DWORD;
function  file_GetPos( const FileHandle : zglTFile ) : DWORD;
function  file_Read( const FileHandle : zglTFile; var buffer; const count : DWORD ) : DWORD;
function  file_Write( const FileHandle : zglTFile; const buffer; const count : DWORD ) : DWORD;
procedure file_Trunc( const FileHandle : zglTFile; const count : DWORD );
function  file_GetSize( const FileHandle : zglTFile ) : DWORD;
procedure file_Flush( const FileHandle : zglTFile );
procedure file_Close( const FileHandle : zglTFile );
procedure file_Find( const Directory : AnsiString; var List : zglTFileList; const FindDir : Boolean );
procedure file_GetName( const FileName : AnsiString; var Result : AnsiString );
procedure file_GetExtension( const FileName : AnsiString; var Result : AnsiString );
procedure file_SetPath( const Path : AnsiString );

var
  filePath : AnsiString;

implementation
uses
  zgl_utils;

procedure file_Open;
begin
  case Mode of
    FOM_CREATE: FileHandle := CreateFileA( PAnsiChar( filePath + FileName ), GENERIC_ALL, 0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0 );
    FOM_OPENR:  FileHandle := CreateFileA( PAnsiChar( filePath + FileName ), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0 );
    FOM_OPENRW: FileHandle := CreateFileA( PAnsiChar( filePath + FileName ), GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0 );
  end;
end;

function file_MakeDir;
begin
  Result := CreateDirectoryA( PAnsiChar( Directory ), nil );
end;

function file_Exists;
  var
    FileHandle : zglTFile;
begin
  file_Open( FileHandle, filePath + FileName, FOM_OPENR );
  Result := FileHandle <> INVALID_HANDLE_VALUE;
  if Result Then
    file_Close( FileHandle );
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
  ReadFile( FileHandle, buffer, count, Result, nil );
end;

function file_Write;
begin
  WriteFile( FileHandle, buffer, count, Result, nil );
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
end;

procedure file_Find;
  var
    First : THandle;
    FList : {$IFDEF FPC} WIN32FINDDATAA {$ELSE} WIN32_FIND_DATAA {$ENDIF};
begin
  First := FindFirstFileA( PAnsiChar( Directory ), FList );
  repeat
    if FindDir Then
      begin
        if FList.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY = 0 Then continue;
      end else
        if FList.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY > 0 Then continue;
    SetLength( List.Items, List.Count + 1 );
    List.Items[ List.Count ] := FList.cFileName;
    INC( List.Count );
  until not FindNextFileA( First, FList );
end;

procedure file_GetName;
  var
    tmp : AnsiString;
begin
  u_GetStr( FileName, Result, '/' );
  if Result = '' Then
    u_GetStr( FileName, Result, '\' );
  u_GetStr( Result, tmp, '.' );
  Result := copy( Result, 1, length( Result ) - length( tmp ) - 1 );
end;

procedure file_GetExtension;
begin
  u_GetStr( FileName, Result, '.' );
end;

procedure file_SetPath;
begin
  filePath := Path;
end;

end.
