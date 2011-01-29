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
unit zgl_application;

{$I zgl_config.cfg}

interface
uses
  Windows,
  Messages,
  zgl_types,
  zgl_direct3d,
  zgl_direct3d_all;

procedure zero;
procedure zerou( dt : Double );
procedure zeroa( activate : Boolean );

procedure app_Init;
procedure app_MainLoop;
procedure app_ProcessOS;
function  app_ProcessMessages( hWnd : HWND; Msg : UINT; wParam : WPARAM; lParam : LPARAM ) : LRESULT; stdcall;
procedure app_CalcFPS;

var
  app_Initialized  : Boolean;
  app_GetSysDirs   : Boolean;
  app_Work         : Boolean;
  app_WorkTime     : LongWord;
  app_Pause        : Boolean;
  app_AutoPause    : Boolean = TRUE;
  app_Focus        : Boolean = TRUE;
  app_Log          : Boolean;
  app_InitToHandle : Boolean;
  app_WorkDir      : String;
  app_HomeDir      : String;

  // call-back
  app_PInit     : procedure = app_Init;
  app_PLoop     : procedure = app_MainLoop;
  app_PLoad     : procedure = zero;
  app_PDraw     : procedure = zero;
  app_PExit     : procedure = zero;
  app_PUpdate   : procedure( dt : Double ) = zerou;
  app_PActivate : procedure( activate : Boolean ) = zeroa;
  app_Timer      : LongWord;
  app_ShowCursor : Boolean;

  app_dt : Double;

  app_FPS      : LongWord;
  app_FPSCount : LongWord;
  app_FPSAll   : LongWord;

  app_Flags : LongWord;

implementation
uses
  zgl_main,
  zgl_screen,
  zgl_window,
  zgl_log,
  zgl_mouse,
  zgl_keyboard,
  {$IFDEF USE_JOYSTICK}
  zgl_joystick,
  {$ENDIF}
  zgl_timers,
  zgl_font,
  {$IFDEF USE_SOUND}
  zgl_sound,
  {$ENDIF}
  zgl_utils;

procedure zero;  begin end;
procedure zerou; begin end;
procedure zeroa; begin end;

procedure app_Draw;
begin
  if not d3d_BeginScene Then exit;
  SetCurrentMode();
  scr_Clear();
  app_PDraw();
  scr_Flush();
  d3d_EndScene();
  if not app_Pause Then
    INC( app_FPSCount );
end;

procedure app_CalcFPS;
begin
  app_FPS      := app_FPSCount;
  app_FPSAll   := app_FPSAll + app_FPSCount;
  app_FPSCount := 0;
  INC( app_WorkTime );
end;

procedure app_Init;
begin
  scr_Clear();
  app_PLoad();
  scr_Flush();

  app_dt := timer_GetTicks();
  timer_Reset();
  timer_Add( @app_CalcFPS, 1000 );
end;

procedure app_MainLoop;
  var
    t : Double;
begin
  while app_Work do
    begin
      app_ProcessOS();
      {$IFDEF USE_JOYSTICK}
      joy_Proc();
      {$ENDIF}
      {$IFDEF USE_SOUND}
      snd_MainLoop();
      {$ENDIF}

      if app_Pause Then
        begin
          timer_Reset();
          app_dt := timer_GetTicks();
          u_Sleep( 10 );
          continue;
        end else
          if d3d_BeginScene Then
            timer_MainLoop()
          else
            continue;

      t := timer_GetTicks();
      app_PUpdate( timer_GetTicks() - app_dt );
      app_dt := t;

      app_Draw();
    end;
end;

procedure app_ProcessOS;
  var
    m : tagMsg;
begin
  while PeekMessageW( m, 0{wnd_Handle}, 0, 0, PM_REMOVE ) do
    begin
      TranslateMessage( m );
      DispatchMessageW( m );
    end;
end;

function app_ProcessMessages( hWnd : HWND; Msg : UINT; wParam : WPARAM; lParam : LPARAM ) : LRESULT; stdcall;
  var
    i   : Integer;
    len : Integer;
    c   : array[ 0..5 ] of AnsiChar;
    str : AnsiString;
    key : LongWord;
begin
  Result := 0;
  if ( not app_Work ) and ( Msg <> WM_ACTIVATE ) Then
    begin
      Result := DefWindowProcW( hWnd, Msg, wParam, lParam );
      exit;
    end;
  case Msg of
    WM_CLOSE, WM_DESTROY, WM_QUIT:
      app_Work := FALSE;

    WM_PAINT:
      begin
        app_Draw();
        ValidateRect( wnd_Handle, nil );
      end;
    WM_DISPLAYCHANGE:
      begin
        if scr_Changing Then
          begin
            scr_Changing := FALSE;
            exit;
          end;
        scr_Init();
        scr_Width  := scr_Desktop.dmPelsWidth;
        scr_Height := scr_Desktop.dmPelsHeight;
        if ( not wnd_FullScreen ) and ( scr_Create() ) Then
          wnd_Update();
      end;
    WM_ACTIVATE:
      begin
        app_Focus := ( LOWORD( wParam ) <> WA_INACTIVE );
        if app_Focus Then
          begin
            app_Pause := FALSE;
            if app_Work Then app_PActivate( TRUE );
            FillChar( keysDown[ 0 ], 256, 0 );
            key_ClearState();
            FillChar( mouseDown[ 0 ], 3, 0 );
            mouse_ClearState();
          end else
            begin
              if app_AutoPause Then app_Pause := TRUE;
              if app_Work Then app_PActivate( FALSE );
            end;
      end;
    WM_NCHITTEST:
      begin
        Result := DefWindowProcW( hWnd, Msg, wParam, lParam );
        if ( not app_Focus ) and ( Result = HTCAPTION ) Then
          Result := HTCLIENT;
      end;
    WM_ENTERSIZEMOVE:
      begin
        if not app_AutoPause Then
          app_Timer := SetTimer( wnd_Handle, 1, 1, nil );
      end;
    WM_EXITSIZEMOVE:
      begin
        if app_Timer > 0 Then
          begin
            KillTimer( wnd_Handle, app_Timer );
            app_Timer := 0;
          end;
      end;
    WM_MOVING:
      begin
        wnd_X := PRect( lParam ).Left;
        wnd_Y := PRect( lParam ).Top;
        if app_AutoPause Then
          timer_Reset();
      end;
    WM_TIMER:
      begin
        timer_MainLoop();
        app_Draw();
      end;
    WM_SETCURSOR:
      begin
        if ( app_Focus ) and ( LOWORD ( lparam ) = HTCLIENT ) and ( not app_ShowCursor ) Then
          SetCursor( 0 )
        else
          SetCursor( LoadCursor( 0, IDC_ARROW ) );
      end;

    WM_LBUTTONDOWN, WM_LBUTTONDBLCLK:
      begin
        mouseDown[ M_BLEFT ] := TRUE;
        if mouseCanClick[ M_BLEFT ] Then
          begin
            mouseClick[ M_BLEFT ]    := TRUE;
            mouseCanClick[ M_BLEFT ] := FALSE;
          end;
        if Msg = WM_LBUTTONDBLCLK Then
          mouseDblClick[ M_BLEFT ] := TRUE;
      end;
    WM_MBUTTONDOWN, WM_MBUTTONDBLCLK:
      begin
        mouseDown[ M_BMIDDLE ] := TRUE;
        if mouseCanClick[ M_BMIDDLE ] Then
          begin
            mouseClick[ M_BMIDDLE ]    := TRUE;
            mouseCanClick[ M_BMIDDLE ] := FALSE;
          end;
        if Msg = WM_MBUTTONDBLCLK Then
          mouseDblClick[ M_BMIDDLE ] := TRUE;
      end;
    WM_RBUTTONDOWN, WM_RBUTTONDBLCLK:
      begin
        mouseDown[ M_BRIGHT ] := TRUE;
        if mouseCanClick[ M_BRIGHT ] Then
          begin
            mouseClick[ M_BRIGHT ]    := TRUE;
            mouseCanClick[ M_BRIGHT ] := FALSE;
          end;
        if Msg = WM_RBUTTONDBLCLK Then
          mouseDblClick[ M_BRIGHT ] := TRUE;
      end;
    WM_LBUTTONUP:
      begin
        mouseDown[ M_BLEFT ]     := FALSE;
        mouseUp  [ M_BLEFT ]     := TRUE;
        mouseCanClick[ M_BLEFT ] := TRUE;
      end;
    WM_MBUTTONUP:
      begin
        mouseDown[ M_BMIDDLE ]     := FALSE;
        mouseUp  [ M_BMIDDLE ]     := TRUE;
        mouseCanClick[ M_BMIDDLE ] := TRUE;
      end;
    WM_RBUTTONUP:
      begin
        mouseDown[ M_BRIGHT ]     := FALSE;
        mouseUp  [ M_BRIGHT ]     := TRUE;
        mouseCanClick[ M_BRIGHT ] := TRUE;
      end;
    WM_MOUSEWHEEL:
      begin
        if wParam > 0 Then
          begin
            mouseWheel[ M_WUP   ] := TRUE;
            mouseWheel[ M_WDOWN ] := FALSE;
          end else
            begin
              mouseWheel[ M_WUP   ] := FALSE;
              mouseWheel[ M_WDOWN ] := TRUE;
            end;
      end;

    WM_KEYDOWN, WM_SYSKEYDOWN:
      begin
        key := winkey_to_scancode( wParam );
        keysDown[ key ]     := TRUE;
        keysUp  [ key ]     := FALSE;
        keysLast[ KA_DOWN ] := key;
        doKeyPress( key );

        key := SCA( key );
        keysDown[ key ] := TRUE;
        keysUp  [ key ] := FALSE;
        doKeyPress( key );

        if ( Msg = WM_SYSKEYDOWN ) and ( key = K_F4 ) Then
          app_Work := FALSE;
      end;
    WM_KEYUP, WM_SYSKEYUP:
      begin
        key := winkey_to_scancode( wParam );
        keysDown[ key ]   := FALSE;
        keysUp  [ key ]   := TRUE;
        keysLast[ KA_UP ] := key;

        key := SCA( key );
        keysDown[ key ] := FALSE;
        keysUp  [ key ] := TRUE;
      end;
    WM_CHAR:
      begin
        if keysCanText Then
        case winkey_to_scancode( wParam ) of
          K_BACKSPACE: u_Backspace( keysText );
          K_TAB:       key_InputText( '  ' );
        else
          if app_Flags and APP_USE_UTF8 > 0 Then
            begin
              len := WideCharToMultiByte( CP_UTF8, 0, @wParam, 1, nil, 0, nil, nil );
              WideCharToMultiByte( CP_UTF8, 0, @wParam, 1, @c[ 0 ], 5, nil, nil );
              str := '';
              for i := 0 to len - 1 do
                str := str + c[ i ];
              if str <> '' Then
                key_InputText( str );
            end else
              if wParam < 128 Then
                key_InputText( Char( CP1251_TO_UTF8[ wParam ] ) )
              else
                for i := 128 to 255 do
                  if wParam = CP1251_TO_UTF8[ i ] Then
                    begin
                      key_InputText( Char( i ) );
                      break;
                    end;
        end;
      end;
  else
    Result := DefWindowProcW( hWnd, Msg, wParam, lParam );
  end;
end;

initialization
  app_Flags := WND_USE_AUTOCENTER or APP_USE_LOG or COLOR_BUFFER_CLEAR or CLIP_INVISIBLE;

end.
