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
unit zgl_application;

{$I zgl_config.cfg}

interface
uses
  Windows,
  Messages,
  zgl_const,
  zgl_types,
  zgl_direct3d8,
  zgl_direct3d8_all;

procedure zero;
procedure zerou( dt : Double );

procedure app_MainLoop;
function  app_ProcessMessages( hWnd : HWND; Msg : UINT; wParam : WPARAM; lParam : LPARAM ) : LRESULT; stdcall;
procedure app_CalcFPS;

var
  app_Initialized  : Boolean;
  app_GetSysDirs   : Boolean;
  app_Work         : Boolean;
  app_WorkTime     : DWORD;
  app_Pause        : Boolean;
  app_AutoPause    : Boolean = TRUE;
  app_Focus        : Boolean = TRUE;
  app_Log          : Boolean;
  app_InitToHandle : Boolean;
  app_WorkDir      : String;
  app_UsrHomeDir   : String;

  // call-back
  app_PLoad   : procedure = zero;
  app_PDraw   : procedure = zero;
  app_PExit   : procedure = zero;
  app_PUpdate : procedure( dt : Double ) = zerou;

  app_ShowCursor : Boolean = TRUE;

  app_FPS      : DWORD;
  app_FPSCount : DWORD;
  app_FPSAll   : DWORD;

  app_Flags : DWORD = WND_USE_AUTOCENTER or APP_USE_LOG or COLOR_BUFFER_CLEAR or DEPTH_BUFFER or DEPTH_BUFFER_CLEAR or CROP_INVISIBLE;

implementation
uses
  zgl_screen,
  zgl_window,
  zgl_log,
  zgl_keyboard,
  zgl_mouse,
  zgl_timers,
  zgl_sound,
  zgl_utils;

procedure zero;
begin
end;
procedure zerou;
begin
end;

procedure OSProcess;
  var
    Mess : tagMsg;
begin
  while PeekMessage( Mess, 0{wnd_Handle}, 0, 0, PM_REMOVE ) do
    begin
      TranslateMessage( Mess );
      DispatchMessage( Mess );
    end;
end;

procedure app_Draw;
begin
  if not d3d8_BeginScene Then exit;
  scr_Clear;
  app_PDraw;
  scr_Flush;
  d3d8_EndScene;
  if not app_Pause Then
    INC( app_FPSCount );
end;

procedure app_MainLoop;
  var
    i, z : Integer;
    j, dt : Double;
    currTimer : zglPTimer;
    SysInfo : _SYSTEM_INFO;
begin
  // Багнутое MS-поделко требует патча :)
  // Вешаем все на одно ядро
  GetSystemInfo( SysInfo );
  SetProcessAffinityMask( GetCurrentProcess, SysInfo.dwActiveProcessorMask );

  scr_Clear;
  app_PLoad;
  scr_Flush;

  dt := timer_GetTicks;
  timer_Reset;
  timer_Add( @app_CalcFPS, 1000 );
  while app_Work do
    begin
      OSProcess;

      CanKillTimers := FALSE;
      if not app_Pause Then
        begin
          if sndAutoPaused Then
            begin
              sndAutoPaused := FALSE;
              snd_ResumeFile;
            end;

          currTimer := @managerTimer.First;
          if currTimer <> nil Then
            for z := 0 to managerTimer.Count do
              begin
                j := timer_GetTicks;
                if currTimer^.Active then
                  begin
                    if j > currTimer^.LastTick + currTimer^.Interval Then
                      begin
                        currTimer^.LastTick := currTimer^.LastTick + currTimer^.Interval;
                        currTimer^.OnTimer;
                      end;
                  end else currTimer^.LastTick := timer_GetTicks;

                currTimer := currTimer^.Next;
              end;
        end else
          begin
            if Assigned( sfStream ) and ( sfStream.Played ) Then
              begin
                sndAutoPaused := TRUE;
                snd_StopFile;
              end;

            timer_Reset;
            u_Sleep( 10 );
          end;

      CanKillTimers := TRUE;
      for i := 1 to TimersToKill do
        timer_Del( aTimersToKill[ i ] );
      TimersToKill  := 0;

      if app_Pause Then continue;
      app_PUpdate( timer_GetTicks - dt );
      dt := timer_GetTicks;
      app_Draw;
    end;
end;

function app_ProcessMessages;
  var
    i   : Integer;
    len : Integer;
    c   : array[ 0..5 ] of Char;
    str : String;
    Key : DWORD;
begin
  Result := 0;
  case Msg of
    WM_CLOSE, WM_DESTROY, WM_QUIT:
      app_Work := FALSE;

    WM_PAINT:
      if app_Work then
        begin
          app_Draw;
          ValidateRect( wnd_Handle, nil );
        end;
    WM_KILLFOCUS:
      if app_Work Then
        begin
          app_Focus := FALSE;
          if app_AutoPause Then app_Pause := TRUE;
          if wnd_FullScreen Then
            begin
              scr_Reset;
              wnd_Update;
            end;
        end;
    WM_SETFOCUS:
      begin
        app_Focus := TRUE;
        app_Pause := FALSE;
        FillChar( keysDown[ 0 ], 256, 0 );
        key_ClearState;
        FillChar( mouseDown[ 0 ], 3, 0 );
        mouse_ClearState;
        if wnd_FullScreen Then
          scr_SetOptions( scr_Width, scr_Height, scr_BPP, scr_Refresh, wnd_FullScreen, scr_VSync );
      end;
    WM_NCHITTEST:
      begin
        Result := DefWindowProc( hWnd, Msg, wParam, lParam );
        if ( not app_Focus ) and ( Result = HTCAPTION ) Then
          Result := HTCLIENT;
      end;
    WM_MOVING:
      begin
        wnd_X := PRect( lParam ).Left;
        wnd_Y := PRect( lParam ).Top;
      end;
    WM_SETCURSOR:
      begin
        if ( not app_Pause ) and ( LOWORD ( lparam ) = HTCLIENT ) and ( not app_ShowCursor ) Then
          SetCursor( 0 )
        else
          SetCursor( LoadCursor( 0, IDC_ARROW ) );
      end;

    WM_LBUTTONDOWN, WM_LBUTTONDBLCLK:
      begin
        mouseDown[ M_BLEFT ]  := TRUE;
        if mouseCanClick[ M_BLEFT ] Then
          begin
            mouseClick[ M_BLEFT ] := TRUE;
            mouseCanClick[ M_BLEFT ] := FALSE;
          end;
      end;
    WM_MBUTTONDOWN, WM_MBUTTONDBLCLK:
      begin
        mouseDown[ M_BMIDLE ] := TRUE;
        if mouseCanClick[ M_BMIDLE ] Then
          begin
            mouseClick[ M_BMIDLE ] := TRUE;
            mouseCanClick[ M_BMIDLE ] := FALSE;
          end;
      end;
    WM_RBUTTONDOWN, WM_RBUTTONDBLCLK:
      begin
        mouseDown[ M_BRIGHT ] := TRUE;
        if mouseCanClick[ M_BRIGHT ] Then
          begin
            mouseClick[ M_BRIGHT ] := TRUE;
            mouseCanClick[ M_BRIGHT ] := FALSE;
          end;
      end;
    WM_LBUTTONUP:
      begin
        mouseDown[ M_BLEFT ]  := FALSE;
        mouseUp  [ M_BLEFT ]  := TRUE;
        mouseCanClick[ M_BLEFT ] := TRUE;
      end;
    WM_MBUTTONUP:
      begin
        mouseDown[ M_BMIDLE ] := FALSE;
        mouseUp  [ M_BMIDLE ] := TRUE;
        mouseCanClick[ M_BMIDLE ] := TRUE;
      end;
    WM_RBUTTONUP:
      begin
        mouseDown[ M_BRIGHT ] := FALSE;
        mouseUp  [ M_BRIGHT ] := TRUE;
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
        Key := winkey_to_scancode( wParam );
        keysDown[ Key ] := TRUE;
        keysUp  [ Key ] := FALSE;
        keysLast[ KA_DOWN ] := Key;
        DoKeyPress( Key );

        Key := SCA( Key );
        keysDown[ Key ] := TRUE;
        keysUp  [ Key ] := FALSE;
        DoKeyPress( Key );

        if Msg = WM_SYSKEYDOWN Then
          if Key = K_F4 Then
            app_Work := FALSE;
      end;
    WM_KEYUP, WM_SYSKEYUP:
      begin
        Key := winkey_to_scancode( wParam );
        keysDown[ Key ] := FALSE;
        keysUp  [ Key ] := TRUE;
        keysLast[ KA_UP ] := Key;

        Key := SCA( Key );
        keysDown[ Key ] := FALSE;
        keysUp  [ Key ] := TRUE;
      end;
    WM_CHAR:
      begin
        case winkey_to_scancode( wParam ) of
          K_BACKSPACE: u_Backspace( keysText );
          K_TAB:       key_InputText( '  ' );
        else
          if wParam > 32 Then
            begin
              if app_Flags and APP_USE_UTF8 > 0 Then
                key_InputText( AnsiToUtf8( Char( wParam ) ) )
              else
                key_InputText( Char( wParam ) );
            end;
        end;
      end;
  else
    Result := DefWindowProc( hWnd, Msg, wParam, lParam );
  end;
end;

procedure app_CalcFPS;
begin
  app_FPS      := app_FPSCount;
  app_FPSAll   := app_FPSAll + app_FPSCount;
  app_FPSCount := 0;
  INC( app_WorkTime );
end;

end.
