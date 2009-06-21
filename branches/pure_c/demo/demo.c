#include <stdio.h>

#include "../zgl_types.h"
#include "../zgl_main.h"
#include "../zgl_screen.h"
#include "../zgl_mouse.h"
#include "../zgl_keyboard.h"

bool fs;

void Init()
{
}

void Draw()
{
  if ( key_Down( K_ALT ) && key_Press( K_ENTER ) ) {
    fs = !fs;
    scr_SetOptions( 1024, 768, 32, 0, fs, 0 );
  }
  if ( key_Press( K_ESCAPE ) ) zgl_Exit();
  mouse_ClearState();
  key_ClearState();
}

int main(void)
{
  zgl_Reg( SYS_INIT, (void*)Init );
  zgl_Reg( SYS_DRAW, (void*)Draw );

  scr_SetOptions( 800, 600, 32, 0, 0, 1 );

  wnd_SetCaption( "ZenGL GCC" );

  scr_SetOptions( 1024, 768, 32, 0, 0, 1 );

  wnd_ShowCursor( 1 );

  zgl_Init( 4, 0 );

  return 0;
}
