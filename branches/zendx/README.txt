ZenDX - модифицированный ZenGL использующий Direct3D8 в качестве графического API

Известные проблемы/ограничения:
- TEX_RGB не создает текстуру формата D3DFMT_R8G8B8
- tex_GetData возвращает pSize равным 3 при TEX_RGB, но это неправильно :)
- tex_GetData не работает для текстур назначенных как RenderTarget
- RenderTarget полностью очищается, при сбросе устройства(D3DERR_DEVICENOTRESET)
- scr_SetVSync и scr_SetFSAA не работают

Delphi  - файлы для сборки библиотеки в Delphi
PasZLib - модули более компактной версии PasZLib для Delphi
