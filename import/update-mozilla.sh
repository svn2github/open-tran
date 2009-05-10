#!/bin/bash

data_root="$1"
mozilla_root="$data_root/mozilla"
mozilla_l10n="$data_root/l10n"
mozilla_po="$data_root/mozilla-po"

cd $data_root

if [ ! -d $mozilla_root ]; then
    echo -n "co l10n..."
    (cvs -d:pserver:anonymous@cvs-mirror.mozilla.org:/cvsroot co -P mozilla > /dev/null || true) 2>&1
    echo "done."
else
    cd $mozilla_root
    echo -n "up mozilla..."
    (cvs up > /dev/null || true) 2>&1
    echo "done."
fi

if [ ! -d $mozilla_l10n ]; then
    echo -n "co l10n..."
    (cvs -d:pserver:anonymous@cvs-mirror.mozilla.org:/l10n co -P l10n > /dev/null || true) 2>&1
    echo "done."
else
    cd $mozilla_l10n
    echo -n "up l10n..."
    (cvs up > /dev/null || true) 2>&1
    echo "done."
fi

if [ ! -d $mozilla_po ]; then
    mkdir $mozilla_po
fi

rm -rf $mozilla_l10n/en-US
rm -rf $mozilla_po/*

if [ ! -f $mozilla_root/.mozconfig ]; then
    cat >> $mozilla_root/.mozconfig <<EOF
mk_add_options MOZ_CO_PROJECT=suite,browser,mail,minimo,xulrunner
EOF
fi

echo -n "en-US..."
cd $mozilla_root
make -f tools/l10n/l10n.mk create-en-US > /dev/null
echo "done."

cd $mozilla_l10n
for d in *; do
    if [ "$d" == "CVS" ] || [ "$d" == "en-US" ]; then
	continue
    fi
    cd $data_root
    echo -n "$d..."
    moz2po --progress none -t "$mozilla_l10n/en-US" "$mozilla_l10n/$d" "$mozilla_po/$d" > /dev/null
    echo "done."
done
