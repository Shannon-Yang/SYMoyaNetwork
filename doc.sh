
swift package --allow-writing-to-directory ./docs \
    generate-documentation --target SYMoyaNetwork \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path https://shannon-yang.github.io/SYMoyaNetwork/ \
    --output-path ./docs