# Configuration/variables

FILE = file

MAGIC_DIR_NAME = magic

# Default target
all: $(MAGIC_DIR_NAME).mgc

$(MAGIC_DIR_NAME).mgc: $(MAGIC_DIR_NAME)/*
	$(FILE) -C -m $(MAGIC_DIR_NAME)

.PHONY: clean
clean:
	$(RM) $(MAGIC_DIR_NAME).mgc
