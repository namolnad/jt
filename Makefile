APP_EXECUTABLE=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/$(APP_NAME)
APP_NAME=jt
APP_TMP=/tmp/$(APP_NAME).dst
BINARIES_DIR=/usr/local/bin
DISTRIBUTION_PLIST=$(APP_TMP)/Distribution.plist
INTERNAL_PACKAGE=$(APP_NAME)App.pkg
MKDIR=mkdir -p
ORG_IDENTIFIER=org.danloman.$(APP_NAME)
OUTPUT_PACKAGE=$(APP_NAME).pkg
RM_SAFELY := bash -c '[[ ! $${1:?} =~ "^[[:space:]]+\$$" ]] && [[ $${1:A} != "/" ]] && [[ $${\#} == "1" ]] && set -o noglob && rm -rf $${1:A}' --
SWIFT_BUILD_FLAGS=--configuration release
VERSION_STRING=0.1.0

build:
	swift build $(SWIFT_BUILD_FLAGS)

package: build
	$(MKDIR) $(APP_TMP)
	cp $(APP_EXECUTABLE) $(APP_TMP)
	
	pkgbuild \
	  --identifier $(ORG_IDENTIFIER) \
	  --install-location $(BINARIES_DIR) \
	  --root $(APP_TMP) \
	  --version $(VERSION_STRING) \
	  $(INTERNAL_PACKAGE)
	
	productbuild \
	  --synthesize \
	  --package $(INTERNAL_PACKAGE) \
	  $(DISTRIBUTION_PLIST)
	
	productbuild \
	  --distribution $(DISTRIBUTION_PLIST) \
	  --package-path $(INTERNAL_PACKAGE) \
	  $(OUTPUT_PACKAGE)

	@$(RM_SAFELY) $(APP_TMP)
	@$(RM_SAFELY) $(INTERNAL_PACKAGE)
