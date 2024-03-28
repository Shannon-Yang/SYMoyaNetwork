
swift package --allow-writing-to-directory ./docs \
    generate-documentation --target SYMoyaNetwork \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path SYMoyaNetwork \
    --output-path ./docs