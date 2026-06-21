SDK = $(shell xcrun --show-sdk-path)
PLUGINS = /Library/Developer/CommandLineTools/usr/lib/swift/host/plugins
SOURCES = src/main.swift \
          src/Models.swift \
          src/BackendService.swift \
          src/ViewModel.swift \
          src/Views/ContentView.swift \
          src/Views/BottleDetailView.swift \
          src/Views/OnboardingView.swift

APP_NAME = Helix
APP_BUNDLE = $(APP_NAME).app
APP_CONTENTS = $(APP_BUNDLE)/Contents
APP_MACOS = $(APP_CONTENTS)/MacOS

all: bundle

$(APP_NAME): $(SOURCES)
	swiftc -sdk $(SDK) -plugin-path $(PLUGINS) $(SOURCES) -o $(APP_NAME)

bundle: $(APP_NAME) Info.plist
	mkdir -p $(APP_MACOS)
	cp $(APP_NAME) $(APP_MACOS)/$(APP_NAME)
	cp Info.plist $(APP_CONTENTS)/Info.plist
	@echo "Helix.app bundle created successfully!"

clean:
	rm -f $(APP_NAME)
	rm -rf $(APP_BUNDLE)

run: bundle
	open $(APP_BUNDLE)
