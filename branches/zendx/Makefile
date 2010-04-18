FPC     = fpc
FLAGS   = -O3 -XdsX -CX -Sd -Cg
INCLUDE = -FuDirect3D -FuPasJPEG
OUTPUT  = ./
DESTDIR = /usr
TMP     = -FUtmp
TARGET  = ZenGL.dll

all: clean
	$(FPC) ZenDX.pas $(INCLUDE) $(TMP) $(FLAGS) -o$(TARGET) -TWIN32 -WG

clean:
	rm -f *.*~
	rm -f -R ./tmp/*
