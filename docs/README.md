```shell
cd dbapi-ui
cnpm install

npm run build

cd ..
mvn package

./docker/build.sh
./docker/push.sh

docker run -it -e ROLE=standalone -p 8520:8520 yiluxiangbei/db-api:3.0.0
```