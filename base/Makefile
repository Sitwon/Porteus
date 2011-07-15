MODULES= \
		 000-kernel \
		 001-core \
		 002-xorg \
		 003-lxde \
		 004-kde \
		 005-kdeapps \
		 006-koffice \
		 007-devel \
		 008-firefox \

all: $(MODULES:%=%.xzm)

.PHONY: all clean $(MODULES)

%.xzm: %
	../porteus-scripts/dir2xzm $</build $@

$(MODULES):
	$(MAKE) -C $@

clean:
	rm -f $(MODULES:%=%.xzm)

