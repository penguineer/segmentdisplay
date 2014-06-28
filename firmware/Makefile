#PROGRAMMER = avrisp2
#PROGRAMMER = usbtiny
PROGRAMMER=usbtiny
CPU_GCC = atmega8
CPU_DUDE = m8

F_CPU = 16000000


PROGRAM = firmware

CDEFS = -DF_CPU=$(F_CPU) -DDEBUG_LEVEL=0
CFLAGS = -mmcu=$(CPU_GCC) $(CDEFS) -Wall -Os -I light_ws2812 
OBJECTS = light_ws2812/light_ws2812.o $(PROGRAM).o

COMPILE = avr-gcc $(CFLAGS)

.phony: clean

all: $(PROGRAM).hex

program: $(PROGRAM).hex
	avrdude -c $(PROGRAMMER) -P usb -p $(CPU_DUDE) -U flash:w:$(PROGRAM).hex

clean:
	rm *.o *.elf *.hex light_ws2812/*.o
	
# Generic rule for compiling C files:
.c.o:
	$(COMPILE) -c $< -o $@

$(PROGRAM).elf: $(OBJECTS)
	$(COMPILE) -o $(PROGRAM).elf $(OBJECTS)

$(PROGRAM).hex: $(PROGRAM).elf
	avr-objcopy -R .eeprom -O ihex $(PROGRAM).elf $(PROGRAM).hex
	avr-size $(PROGRAM).hex

fuse:
	avrdude -c $(PROGRAMMER) -P usb -p $(CPU_DUDE) -U lfuse:w:0x3f:m -U hfuse:w:0xd9:m 
	