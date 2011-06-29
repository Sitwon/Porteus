recursive_list = $(shell find $(1) -not -type l | sed 's/:/\\:/g' | sed 's/ /\\ /g')

ISO= porteus.iso
ZIP= porteus.zip
INITRD= new/boot/initrd.xz
INITRD_SIZE= 6666
DIRS= \
	  new/porteus/base \
	  new/porteus/modules \
	  new/porteus/optional \
	  new/porteus/rootcopy \

BASE= \
	  new/porteus/base/000-kernel.xzm \
	  new/porteus/base/001-core.xzm \
	  new/porteus/base/002-xorg.xzm \
	  new/porteus/base/003-lxde.xzm \
	  new/porteus/base/004-kde.xzm \
	  new/porteus/base/005-kdeapps.xzm \
	  new/porteus/base/006-koffice.xzm \
	  new/porteus/base/007-devel.xzm \
	  new/porteus/base/008-firefox.xzm \


.PHONY: all clean build iso zip

all: iso zip

clean:
	rm -f $(INITRD)
	rm -f $(BASE)
	rm -f new/porteus/md5sums.txt

build: $(DIRS) $(INITRD) $(BASE) new/porteus/md5sums.txt

iso: $(ISO)

zip: $(ZIP)

$(ISO): $(INITRD) $(BASE)
	cd new && porteus/make_iso.sh ../$@

$(ZIP): $(INITRD) $(BASE)
	cd new && zip -r ../$@ .

new/porteus/md5sums.txt: $(INITRD) $(BASE)
	cd new/porteus && md5sum ../boot/vmlinuz ../boot/initrd.xz `find ./base -iname '*.xzm'` >$@

$(DIRS):
	mkdir -p $@

new/porteus/base/000-kernel.xzm: $(DIRS)
	porteus-scripts/dir2xzm base/000-kernel $@

new/porteus/base/001-core.xzm: $(DIRS)
	porteus-scripts/dir2xzm base/001-core $@

new/porteus/base/002-xorg.xzm: $(DIRS)
	porteus-scripts/dir2xzm base/002-xorg $@

new/porteus/base/003-lxde.xzm: $(DIRS)
	porteus-scripts/dir2xzm base/003-lxde $@

new/porteus/base/004-kde.xzm: $(DIRS)
	porteus-scripts/dir2xzm base/004-kde $@

new/porteus/base/005-kdeapps.xzm: $(DIRS)
	porteus-scripts/dir2xzm base/005-kdeapps $@

new/porteus/base/006-koffice.xzm: $(DIRS)
	porteus-scripts/dir2xzm base/006-koffice $@

new/porteus/base/007-devel.xzm: $(DIRS)
	porteus-scripts/dir2xzm base/007-devel $@

new/porteus/base/008-firefox.xzm: $(DIRS)
	porteus-scripts/dir2xzm base/008-firefox $@

$(INITRD):
	dd if=/dev/zero of=new/boot/initrd bs=1024 count=$(INITRD_SIZE)
	mkfs.ext2 -F new/boot/initrd >/dev/null 2>&1
	mkdir -p /tmp/initrd-new
	mount -o loop new/boot/initrd /tmp/initrd-new
	cp -af initrd/* /tmp/initrd-new
	umount /tmp/initrd-new
	xz new/boot/initrd

