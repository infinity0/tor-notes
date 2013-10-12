SRC_DIA = $(wildcard *.dia)
SRC_RST = $(wildcard *.rst)
DST_SVG = $(patsubst %.dia, %.svg, $(SRC_DIA))
DST_PNG = $(patsubst %.dia, %.png, $(SRC_DIA))
DST_HTML = $(patsubst %.rst, %.html, $(SRC_RST))
DST_ALL = $(DST_SVG) $(DST_PNG) $(DST_HTML)
DIA_ZOOM = 0.4

all: $(DST_ALL)

%.svg: %.dia Makefile
	dia -e /dev/stdout -t svg "$<" \
	  | rsvg-convert -z $(DIA_ZOOM) -f svg /dev/stdin \
	  | scour -q -o "$@"

%.png: %.dia Makefile
	dia -t png "$<"

%.html: %.rst Makefile
	rst2html "$<" "$@"

clean:
	rm -f $(DST_ALL)

.PHONY: clean
