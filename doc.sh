#swift build
targets=("SYMoyaNetwork" "SYMoyaReactiveHandyJSON" "SYMoyaReactiveObjectMapper" "SYMoyaHandyJSON" "SYMoyaRxHandyJSON" "SYMoyaRxObjectMapper" "SYMoyaObjectMapper" "ReactiveSYMoyaNetwork" "RxSYMoyaNetwork") 
for arg in ${targets[*]}; do 
 if [ ! -d "/docs/$arg/" ]; then
  pwd
  cd docs/
  sudo mkdir /$arg
  
  chmod 777 /$arg
fi
     swift package --allow-writing-to-directory ./docs \
      generate-documentation --target $arg \
       --disable-indexing \
       --transform-for-static-hosting \
       --hosting-base-path SYMoyaNetwork \
       --output-path ./$arg/docs  
done

