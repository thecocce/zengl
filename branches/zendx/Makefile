FPC     = fpc
FLAGS   = -O3 -XdsX -CX -Sd
INCLUDE = -FuDirect3D -FuPasJPEG
OUTPUT  = ./
DESTDIR = /usr
TMP     = -FUtmp
TARGET  = ZenGL.dll

all: clean
	$(FPC) ZenGL.pas $(INCLUDE) $(TMP) $(FLAGS) -o$(TARGET) -TWIN32 -WG

win64: clean
	$(FPC) ZenGL.pas $(INCLUDE) $(TMP) $(FLAGS) -o$(TARGET) -TWIN64 -WG

clean:
	rm -f *.*~
	rm -f -R ./tmp/*
