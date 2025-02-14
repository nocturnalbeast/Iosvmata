#!/usr/bin/env sh

IOSEVKA_REPO="https://github.com/be5invis/Iosevka.git"
IOSEVKA_DIR="iosevka"

check_dependencies() {
    MISSING=""
    for dep in npm ttfautohint git fontforge curl unzip; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            MISSING="${MISSING}$dep "
        fi
    done
    if [ -n "$MISSING" ]; then
        echo "Error: Missing required dependencies: $MISSING" >&2
        echo "Please install them and try again." >&2
        return 1
    fi    
    return 0
}

clone_iosevka() {
    if [ -d "$IOSEVKA_DIR" ]; then
        echo "Iosevka repository already exists. Updating..."
        cd "$IOSEVKA_DIR" || exit 1
        git reset --hard HEAD && git pull
        cd - || exit 1
    else
        echo "Cloning Iosevka repository..."
        git clone --depth 1 "$IOSEVKA_REPO" "$IOSEVKA_DIR" || exit 1
    fi
}

build() {
    cd "$IOSEVKA_DIR" || exit 1
    npm install
    cp -f "../Iosvmata.toml" "private-build-plans.toml"
    npm run build -- ttf::Iosvmata
    cd - || exit 1
    rm -rf build
    cp -r "$IOSEVKA_DIR/dist/Iosvmata/TTF" ./build
    cd build || exit 1
    for f in Iosvmata-normal*.ttf; do
        mv "$f" "$(echo "$f" | sed 's/normal//')" 2>/dev/null
    done
    mv Iosvmata-.ttf Iosvmata-Regular.ttf
    cd - || exit 1
}

postbuild_bolder() {
    python ./bolder.py build/Iosvmata
}

postbuild_patchnerd() {
    if ! curl -L --output FontPatcher.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FontPatcher.zip; then
        echo "Failed to download Nerd Font patcher.zip" >&2
        return 1
    fi
    mkdir FontPatcher
    unzip -q -d FontPatcher FontPatcher.zip
    rm FontPatcher.zip
    for f in build/*.ttf; do
        fontforge -script FontPatcher/font-patcher "$f"
    done
    rm -rf FontPatcher
    mkdir build/NerdFont
    for f in ./*.ttf; do
        mv "$f" build/NerdFont
    done
}

main() {
    echo "Checking dependencies..."
    if ! check_dependencies; then
        exit 1
    fi
    echo "Building Iosvmata..."
    if ! clone_iosevka; then
        exit 1
    fi
    if ! build; then
        exit 1
    fi
    postbuild_bolder
    postbuild_patchnerd
    mkdir build/Normal
    mv build/*.ttf build/Normal
    echo "Done!"
}

main "$@"
