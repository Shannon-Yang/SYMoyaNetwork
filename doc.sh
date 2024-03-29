swift build
targets=("SYMoyaNetwork" "SYMoyaReactiveHandyJSON" "SYMoyaReactiveObjectMapper" "SYMoyaHandyJSON" "SYMoyaRxHandyJSON" "SYMoyaRxObjectMapper" "SYMoyaObjectMapper" "ReactiveSYMoyaNetwork" "RxSYMoyaNetwork") 
for arg in ${targets[*]}; do 
 if [ ! -d "/docs/$arg/" ]; then
  cd docs/
  sudo mkdir $arg
  cd ..
fi
     swift package --allow-writing-to-directory ./docs \
      generate-documentation --target $arg \
       --disable-indexing \
       --transform-for-static-hosting \
       --hosting-base-path SYMoyaNetwork \
       --output-path ./docs/$arg 
done

