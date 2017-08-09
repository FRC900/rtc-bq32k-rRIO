obj-m += rtc-bq32k.o

KERNELSOURCE=/var/volatile/tmp/headers/kernel

all:
        make -C $(KERNELSOURCE) M=$(PWD) modules
clean:
        make -C $(KERNELSOURCE) M=$(PWD) clean
