FPC     = fpc
FLAGS   = -O3 -XsX -CX -Sd
INCLUDE = -FuDirect3D -Fu../lib
OUTPUT  = ./
TMP     = -FUtmp
TARGET  = ZenGL.dll

win32: clean
	$(FPC) ZenGL.pas $(INCLUDE) $(TMP) $(FLAGS) -o$(TARGET) -TWIN32 -Pi386 -WG

win64: clean
	$(FPC) ZenGL.pas $(INCLUDE) $(TMP) $(FLAGS) -o$(TARGET) -TWIN64 -Px86_64 -WG

clean:
	rm -f *.*~
	rm -f -R ./tmp/*
