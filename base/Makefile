MODULES= \
		 000-kernel.xzm \
		 001-core.xzm \
		 002-xorg.xzm \
		 003-lxde.xzm \
		 004-kde.xzm \
		 005-kdeapps.xzm \
		 006-koffice.xzm \
		 007-devel.xzm \
		 008-firefox.xzm \

all: $(MODULES)

.PHONY: all clean $(MODULES)

$(MODULES):
	$(MAKE) -C $(@:%.xzm=%) ../$@

clean:
	rm -f $(MODULES:%=%.xzm)

