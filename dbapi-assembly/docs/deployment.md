# 安装教程

- 安装包下载地址： [天翼云盘](https://cloud.189.cn/t/Jza2MzeEZVNv) ，或者在Gitee/GitHub的发行版页面下载

## 本地部署单机版

- 依赖java环境，先自行在服务器安装jdk8+，并配置环境变量
- 下载安装包解压到需要安装的目录
- 修改`conf/application.properties`文件中的以下配置
```properties
# api访问路径的统一根路径，example: http://192.168.xx.xx:8520/api/xxx
# api context
dbapi.api.context=api

# 如果不修改数据库地址将默认使用自带的内嵌元数据库sqlite
# meta database address
spring.datasource.driver-class-name=org.sqlite.JDBC
spring.datasource.url=jdbc:sqlite::resource:sqlite.db
spring.datasource.username=
spring.datasource.password=
```
- 如果配置了mysql作为元数据库，请先在mysql执行初始化脚本`sql/ddl_mysql.sql`
- 一键启停
```shell
sh bin/dbapi-daemon.sh start standalone
sh bin/dbapi-daemon.sh stop standalone
```

- 浏览器访问`http://192.168.xx.xx:8520`进入UI

## 本地部署集群版

- 集群部署依赖nacos和mysql，请先自行安装nacos（推荐1.4.2版本）和mysql
- 准备多台机器，每台安装jdk8+并配置java环境变量
- 选一台机器host1作为部署机，配置host1到其他每台机器的ssh免密登录
```shell
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

for ip in host2 host3;     # 请将此处 host2 host3 替换为自己要部署的机器的 hostname
do
  ssh-copy-id  $ip   # 该操作执行过程中需要手动输入部署用户的密码
done
```
- 下载安装包并解压到部署机host1需要安装的目录

- 在mysql创建新的数据库，并执行初始化脚本`sql/ddl_mysql.sql`

- 修改`conf/application.properties`文件中的以下配置
```properties
# api访问路径的统一根路径，example: http://192.168.xx.xx:8520/api/xxx
# api context
dbapi.api.context=api

# nacos address
spring.cloud.nacos.server-addr=127.0.0.1:8848
spring.cloud.nacos.discovery.username=nacos
spring.cloud.nacos.discovery.password=nacos
spring.cloud.nacos.discovery.namespace=public

# meta database address
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.datasource.url=jdbc:mysql://127.0.0.1:3306/dbapi?useSSL=false&characterEncoding=UTF-8&serverTimezone=GMT%2B8
spring.datasource.username=root
spring.datasource.password=root
```

- 修改`conf/install_config.conf`文件，配置要安装的机器节点
```shell
# 所有要安装DBApi的主机ip或hostname，用逗号分隔
ips=host1,host2,host3

sshPort=22

# 要安装gateway的主机
gateway=host1

# 要安装apiServer的主机，多个用逗号分隔
apiServers=host1,host2,host3

# 要安装manager的主机
manager=host2
```

- 拷贝host1中的安装文件到其他每台机器的**相同目录**，可使用脚本一键拷贝
```shell
sh bin/scp-host.sh
```

- 集群操作脚本
```shell
# 一键启动集群
sh bin/start-all.sh

# 一键停止集群
sh bin/stop-all.sh

# 手动启停单个服务
sh bin/dbapi-daemon.sh start gateway
sh bin/dbapi-daemon.sh start manager
sh bin/dbapi-daemon.sh start apiServer

sh bin/dbapi-daemon.sh stop gateway
sh bin/dbapi-daemon.sh stop manager
sh bin/dbapi-daemon.sh stop apiServer

```

- 浏览器访问`http://192.168.xx.xx:8523`进入UI; API通过gateway来访问`http://192.168.xx.xx:8525/api/xx`

## docker部署单机版

- 一键启动（使用dbapi自带的元数据库sqlite）
```shell
docker run -it -e ROLE=standalone -p 8520:8520 freakchicken/db-api:3.0.0
```

- 使用自己的mysql作为元数据库（启动前需要在mysql执行初始化脚本）
```shell
docker run -it \
-e ROLE=standalone \
-p 8520:8520 \
-e DB_URL="jdbc:mysql://192.168.xx.xx:3306/dbapi?useSSL=false&characterEncoding=UTF-8&serverTimezone=GMT%2B8" \
-e DB_USERNAME="root" \
-e DB_PASSWORD="root" \
-e DB_DRIVER="com.mysql.cj.jdbc.Driver" \
freakchicken/db-api:3.0.0
```
- 浏览器访问`http://192.168.xx.xx:8520`进入UI

## docker部署集群版

- 集群部署依赖nacos和mysql，请先自行安装nacos（推荐1.4.2版本）和mysql
- 在mysql创建新的数据库，执行数据库初始化脚本（下载安装包解压获取`sql/ddl_mysql.sql`脚本）

- 启动UI服务manager
```shell
docker run -it \
-e ROLE=manager \
-p 8523:8523 \
-e DB_URL="jdbc:mysql://192.168.xx.xx:3306/dbapi?useSSL=false&characterEncoding=UTF-8&serverTimezone=GMT%2B8" \
-e DB_USERNAME="root" \
-e DB_PASSWORD="root" \
-e DB_DRIVER="com.mysql.cj.jdbc.Driver" \
-e NACOS_ADDRESS="192.168.xx.xx:8848" \
-e NACOS_USERNAME="nacos" \
-e NACOS_PASSWORD="nacos" \
-e NACOS_NAMESPACE="public" \
freakchicken/db-api:3.0.0
```

- 启动网关服务 gateway
```shell
docker run -it \
-e ROLE=gateway \
-p 8525:8525 \
-e DB_URL="jdbc:mysql://192.168.xx.xx:3306/dbapi?useSSL=false&characterEncoding=UTF-8&serverTimezone=GMT%2B8" \
-e DB_USERNAME="root" \
-e DB_PASSWORD="root" \
-e DB_DRIVER="com.mysql.cj.jdbc.Driver" \
-e NACOS_ADDRESS="192.168.xx.xx:8848" \
-e NACOS_USERNAME="nacos" \
-e NACOS_PASSWORD="nacos" \
-e NACOS_NAMESPACE="public" \
freakchicken/db-api:3.0.0
```

- 启动API服务apiServer（此服务可启动多个，构建api集群）
```shell
docker run -it \
-e ROLE=apiServer \
-e DB_URL="jdbc:mysql://192.168.xx.xx:3306/dbapi?useSSL=false&characterEncoding=UTF-8&serverTimezone=GMT%2B8" \
-e DB_USERNAME="root" \
-e DB_PASSWORD="root" \
-e DB_DRIVER="com.mysql.cj.jdbc.Driver" \
-e NACOS_ADDRESS="192.168.xx.xx:8848" \
-e NACOS_USERNAME="nacos" \
-e NACOS_PASSWORD="nacos" \
-e NACOS_NAMESPACE="public" \
freakchicken/db-api:3.0.0
```

- 浏览器访问`http://192.168.xx.xx:8523`进入UI; API通过gateway来访问`http://192.168.xx.xx:8525/api/xx`

## 附：
- docker快速安装nacos
```
docker run --env MODE=standalone --name nacos -d -p 8848:8848 nacos/nacos-server:1.4.2
```
