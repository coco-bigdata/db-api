```shell
cd dbapi-ui
cnpm install

npm run build

cd ..
mvn package

./docker/build.sh
./docker/push.sh
```