recursive_list = $(shell find $(1) -not -type l | sed 's/:/\\:/g' | sed 's/ /\\ /g')

ISO= porteus.iso
ZIP= porteus.zip
INITRD= new/boot/initrd.xz
INITRD_SIZE= 6666
INITRD_DIRS= \
	  initrd/dev \
	  initrd/lost+found \
	  initrd/memory \
	  initrd/mnt \
	  initrd/opt \
	  initrd/proc \
	  initrd/sys \
	  initrd/tmp \
	  initrd/union \
	  initrd/var \

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


all: iso zip

.PHONY: all clean build iso zip test

test: iso
	qemu-system-x86_64 --enable-kvm -cdrom $(ISO) -boot d -m 512 -vga std

clean:
	rm -f $(INITRD)
	rm -f $(BASE)
	rm -f new/porteus/md5sums.txt
	rm -f new/boot/vmlinuz

build: $(DIRS) $(INITRD) $(BASE)

iso: $(ISO)

zip: $(ZIP)

$(ISO): new/boot/vmlinuz $(INITRD) $(BASE) new/porteus/md5sums.txt
	cd new && porteus/make_iso.sh ../$@

$(ZIP): new/boot/vmlinuz $(INITRD) $(BASE) new/porteus/md5sums.txt
	cd new && zip -r ../$@ .

new/porteus/md5sums.txt: $(INITRD) $(BASE)
	cd new/porteus && md5sum ../boot/vmlinuz ../boot/initrd.xz `find ./base -iname '*.xzm'` > md5sums.txt

$(INITRD_DIRS) $(DIRS):
	mkdir -p $@

kernel/linux-2.6.38.8.tar.bz2:
	cd kernel && wget http://www.kernel.org/pub/linux/kernel/v2.6/linux-2.6.38.8.tar.bz2

kernel/linux-2.6.38.8/arch/x86/boot/bzImage: kernel/linux-2.6.38.8.tar.bz2 kernel/porteus.config kernel/aufs2.1-38.patch kernel/build-kernel.sh
	cd kernel && sh build-kernel.sh

new/boot/vmlinuz: kernel/linux-2.6.38.8/arch/x86/boot/bzImage
	cp $< $@

kernel/kernel-modules-1.6.38.8-i486-sit_1.tgz: kernel/linux-2.6.38.8/arch/x86/boot/bzImage

base/000-kernel/build/var/log/packages/kernel-modules-1.6.38.8-i486-sit_1: kernel/kernel-modules-2.6.38.8-i486-sit_1.tgz
	ROOT=base/000-kernel/build /sbin/installpkg kernel/kernel-modules-2.6.38.8-i486-sit_1.tgz

new/porteus/base/000-kernel.xzm: | $(DIRS)
	porteus-scripts/dir2xzm base/000-kernel/build $@

new/porteus/base/001-core.xzm: | $(DIRS)
	porteus-scripts/dir2xzm base/001-core $@

new/porteus/base/002-xorg.xzm: | $(DIRS)
	porteus-scripts/dir2xzm base/002-xorg $@

new/porteus/base/003-lxde.xzm: | $(DIRS)
	porteus-scripts/dir2xzm base/003-lxde $@

new/porteus/base/004-kde.xzm: | $(DIRS)
	porteus-scripts/dir2xzm base/004-kde $@

new/porteus/base/005-kdeapps.xzm: | $(DIRS)
	porteus-scripts/dir2xzm base/005-kdeapps $@

new/porteus/base/006-koffice.xzm: | $(DIRS)
	porteus-scripts/dir2xzm base/006-koffice $@

new/porteus/base/007-devel.xzm: | $(DIRS)
	porteus-scripts/dir2xzm base/007-devel $@

new/porteus/base/008-firefox.xzm: | $(DIRS)
	porteus-scripts/dir2xzm base/008-firefox $@

$(INITRD): $(INITRD_DIRS) kernel/linux-2.6.38.8/arch/x86/boot/bzImage
	dd if=/dev/zero of=new/boot/initrd bs=1024 count=$(INITRD_SIZE)
	mkfs.ext2 -F new/boot/initrd >/dev/null 2>&1
	rm -rf /tmp/initrd-new
	mkdir -p /tmp/initrd-new
	mount -o loop new/boot/initrd /tmp/initrd-new
	cp -af initrd/* /tmp/initrd-new
	mkdir -p /tmp/initrd-new/lib/modules/2.6.38.8-porteus/kernel/drivers/net/e1000
	cp kernel/linux-2.6.38.8/drivers/net/mii.ko /tmp/initrd-new/lib/modules/2.6.38.8-porteus/kernel/drivers/net/mii.ko
	cp kernel/linux-2.6.38.8/drivers/net/pcnet32.ko /tmp/initrd-new/lib/modules/2.6.38.8-porteus/kernel/drivers/net/pcnet32.ko
	cp kernel/linux-2.6.38.8/drivers/net/e1000/e1000.ko /tmp/initrd-new/lib/modules/2.6.38.8-porteus/kernel/drivers/net/e1000/e1000.ko
	depmod -b /tmp/initrd-new 2.6.38.8-porteus
	umount /tmp/initrd-new
	xz --check=crc32 --x86 --lzma2 new/boot/initrd

