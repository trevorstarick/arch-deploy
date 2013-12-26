declare NUSER=arch

nuser() {
    useradd "$@" "$NUSER" &&
    passwd "$NUSER"
}

nuserx() {
    su - "$NUSER" -c "\"\$0\" \"\$@\"" -- "$@"
}

aur() {
    local package=$1; shift
    local dest=/tmp/$package.tar.gz

    # Download and extract package
    nuserx curl -o "$dest" "https://aur.archlinux.org/packages/${package:0:2}/$package/$package.tar.gz" &&
    nuserx cd /tmp \&\& tar xf "$dest" &&

    # Build package (and clean)
    nuserx cd "/tmp/$package" \&\& makepkg -c &&

    # Install generate package
    find "/tmp/$package" -name "*.tar.xz" -exec pacman -U {} + &&

    # Cleanup
    rm  -R "/tmp/$package" "$dest"
}

# Remove configure script from `.profile`
sed -i "/^# AUTORUN ARCH CONFIGURE$/,+1d" .profile &&

# Remove `.profile` if empty
[ wc -l < ~/.profile == 0 ] && rm .profile &&

# Execute configure script
. ./configure
