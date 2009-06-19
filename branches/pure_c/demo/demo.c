#include "../zgl_main.h"
#include "../zgl_screen.h"
#include "../zgl_mouse.h"
#include "../zgl_keyboard.h"

void Init()
{
  scr_SetOptions( 1024, 768, 32, 0, 0, 0 );
}

void Draw()
{
  if ( key_Up( K_ESCAPE ) ) zgl_Exit();
  if ( mouse_Click( MB_LEFT ) ) zgl_Exit();
  mouse_ClearState();
  key_ClearState();
  /*log_Add( "Draw", 1 );*/
}

int main(void)
{
  zgl_Reg( SYS_INIT, (void*)Init );
  zgl_Reg( SYS_DRAW, (void*)Draw );

  scr_SetOptions( 800, 600, 32, 0, 0, 1 );

  //zgl_Enable( WND_USE_AUTOCENTER );

  wnd_SetCaption( "ZenGL GCC" );

  zgl_Init( 0, 0 );

  return 0;
}
