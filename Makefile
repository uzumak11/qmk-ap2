.PHONY: all qmk qmk-full-caps qmk-layer-indicators shine tools flash flash-full-caps flash-layer-indicators flash-all

TOOL := ./AnnePro2-Tools/target/release/annepro2_tools

all: qmk

qmk:
	$(MAKE) -C qmk_firmware annepro2/c18

qmk-full-caps:
	$(MAKE) -C qmk_firmware annepro2/c18:default-full-caps

qmk-layer-indicators:
	$(MAKE) -C qmk_firmware annepro2/c18:default-layer-indicators

shine:
	$(MAKE) -C AnnePro2-Shine C18

tools:
	cargo build --release --manifest-path AnnePro2-Tools/Cargo.toml

flash: qmk tools
	sudo $(TOOL) --boot qmk_firmware/.build/annepro2_c18_default.bin

flash-full-caps: qmk-full-caps tools
	sudo $(TOOL) --boot qmk_firmware/.build/annepro2_c18_default-full-caps.bin

flash-layer-indicators: qmk-layer-indicators tools
	sudo $(TOOL) --boot qmk_firmware/.build/annepro2_c18_default-layer-indicators.bin

flash-all: qmk shine tools
	sudo $(TOOL) qmk_firmware/.build/annepro2_c18_default.bin
	sudo $(TOOL) --boot -t led AnnePro2-Shine/build/annepro2-shine-C18.bin
