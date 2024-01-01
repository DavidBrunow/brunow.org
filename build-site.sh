#! /bin/sh

swift package --allow-writing-to-directory docs generate-documentation --target Brunow --disable-indexing --output-path docs --transform-for-static-hosting --hosting-base-path brunow.org