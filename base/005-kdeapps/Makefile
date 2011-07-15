DIRS= \
	  build \
	  pkgs \

PACKAGES= $(shell cat *.pkglist)

all: $(DIRS) $(PACKAGES)

../%.xzm: $(PACKAGES:%=pkgs/%.tgz) $(PACKAGES:%=build/var/log/packages/%) | $(DIRS)
	../../porteus-scripts/dir2xzm build $@

.PHONY: all clean

clean:
	git clean -fdx .

$(DIRS):
	mkdir -p $@

build/var/log/packages/%: pkgs/%.tgz | $(DIRS)
	ROOT=build /sbin/installpkg $<

pkgs/%:
	$(MAKE) -C src ../$@

