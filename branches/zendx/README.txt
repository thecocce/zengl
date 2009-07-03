ZenDX - модифицированный ZenGL использующий Direct3D8 в качестве графического API

Известные ограничения/нюансы:
- TEX_RGB создает текстуру формата D3DFMT_X8R8G8B8
- tex_GetData возвращает pSize равным 3 при TEX_RGB, но это неправильно :)
- scr_SetVSync и scr_SetFSAA не работают

Delphi  - файлы для сборки библиотеки в Delphi
PasZLib - модули более компактной версии PasZLib для Delphi
