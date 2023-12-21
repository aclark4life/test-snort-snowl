PROJECT_NAME := test-snort-snowl

all: install-deps install-submodules install-libdaq install-gperftools install-snort3

install-deps:
	apt install build-essential libpcap-dev libpcre3-dev libnet1-dev zlib1g-dev luajit hwloc libdnet-dev libdumbnet-dev bison flex liblzma-dev openssl libssl-dev pkg-config libhwloc-dev cmake cpputest libsqlite3-dev uuid-dev libcmocka-dev libnetfilter-queue-dev libmnl-dev autotools-dev libluajit-5.1-dev libunwind-dev libfl-dev -y

install-submodules:
	git submodule init
	git submodule update

install-libdaq:
	cd libdaq; ./bootstrap; ./configure; $(MAKE); $(MAKE) install

install-gperftools:
	wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.9.1/gperftools-2.9.1.tar.gz
	tar xzf gperftools-2.9.1.tar.gz
	cd gperftools-2.9.1/; ./configure; $(MAKE); $(MAKE) install

install-snort3:
	wget https://github.com/snort3/snort3/archive/refs/heads/master.zip
	unzip master.zip
	cd snort3-master; ./configure_cmake.sh --prefix=/usr/local --enable-tcmalloc; cd build; $(MAKE); $(MAKE) install

test-snort3:
	snort -c /usr/local/etc/snort/snort.lua
