DIRS= \
	  build \
	  pkgs \

PACKAGES= $(shell cat *.pkglist)

all: $(DIRS) $(PACKAGES)

../%.xzm: $(DIRS) $(PACKAGES)
	../../porteus-scripts/dir2xzm build $@

.PHONY: all clean

clean:
	git clean -fdx .

$(DIRS):
	mkdir -p $@

$(PACKAGES): %: pkgs/%.tgz build/var/log/packages/% | $(DIRS)

build/var/log/packages/%: pkgs/%.tgz | $(DIRS)
	ROOT=build /sbin/installpkg $<

pkgs/%:
	$(MAKE) -C src ../$@

pkgs/kernel-modules-2.6.38.8-i486-sit_1.tgz: ../../kernel/kernel-modules-2.6.38.8-i486-sit_1.tgz | $(DIRS)
	cp $< $@

../../kernel/kernel-modules-2.6.38.8-i486-sit_1.tgz:
	$(MAKE) -C ../.. kernel/kernel-modules-2.6.38.8-i486-sit_1.tgz

