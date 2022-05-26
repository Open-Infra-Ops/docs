## NOTE

> 以当前Dockerfile为例，优化构建过程
> 
> author：zhaochunjiang
> 
> create-date： 2022-05
> 

# 
### ARG

  ARG 的作用是用于构建时接收外部传入的变量，不必每次都去修改dockerfile文件；属于动态传参；

  ARG 可以实现dockerfile文件中有默认值，即build 时，传入参数就是传入的参数作为环境变量 ；不传参数，就使用默认值；

  ARG 有效范围只在构建过程中，镜像构建完毕后，镜像就不存在此环境变量；

  ARG 与ENV的典型差别就是：前者属于动态传参，后者属于静态参数；并且后者设置的参数在构建中和构建后都一直存在；

  ```shell
  ARG GSQL_INIT_PASSWD="openGauss@2022"
  ENV GSQL_INIT_PASSWD=${GSQL_INIT_PASSWD}
  ```

  > 此处变量 $GSQL_INIT_PASSWD 的默认值是：openGauss@2022；当需要更改默认值时，在docker build 重新传入值；
  >
  > 此处使用ENV的作用是： 当出现镜像需要永久保存外部传入参数变量的这种场景，可以把ARG 的变量赋值给ENV 的变量，实现永久动态保存；


# 
### COPY

  COPY 实现本地文件复制到镜像目录中；

  COPY 与ADD 的差别时：前者只拷贝文件和目录，后者拷贝压缩文件时，可以实现自动解压，并删除自动删除压缩包，只保留解压后的文件；

  COPY 可以实现一次拷贝多个文件，不必每一个COPY只拷贝一个文件到镜像中，这样有利于减少docker layer，实现压缩镜像大小；

  ```shell
  COPY bashrc .bashrc
  COPY pgweb-up.sh pgweb-up.sh
  COPY start.sh start.sh
  ```

  > 可以优化如下

  ```shell
  COPY ["bashrc .bashrc", "pgweb-up.sh pgweb-up.sh", "start.sh start.sh"]
  ```

  > 需要注意目录层级，当有目录时，拷贝的不一定带有目录层级,只有目录下的文件；

  优化方法是：

  ```shell
  ENV LANG=en_US.utf8 \
      GSQL_INIT_PASSWD=${GSQL_INIT_PASSWD}
  COPY ["bashrc .bashrc", "pgweb-up.sh pgweb-up.sh", "start.sh start.sh"]
  
  RUN mkdir opengauss && \
      wget -q https://opengauss.obs.cn-south-1.myhuaweicloud.com/3.0.0/x86_openEuler/openGauss-Lite-3.0.0-openEuler-x86_64.tar.gz && \
      ... && \
      sudo chmod a+x pgweb-up.sh && sudo chmod a+x .bashrc && sudo chmod a+x start.sh
      
  COPY --from=pgweb /usr/bin/pgweb /usr/bin/pgweb
  ```

  > 作用是：
  >
  > 更换指令先后顺序可以减少layer层级，尽量压缩构建时间和镜像大小；此处优化后总共减少了3个layer；
  >
  > 当存在只有RUN之后才能出现的COPY需要目标目录时，COPY的指令位置就不能如上提前放置； 

  查看构建layer:

  ```shell
  docker history <docker_image_name>:<version> --no-trunc
  docker image inspect -f '{{.RootFS.Layers}}' <docker_image:version>
  ```

  > 提取的字符串为json格式，可以转换为字典或列表数据类型；


# 
### 多进程

  多进程是指在一个镜像中存在多个进程；

  是否需要多进程，是根据业务本身需要；当一个进程依赖另一个进程时，这种就必然存在多进程问题；

  多进程需要的注意事项是：前一个进程在启动时，需要转入后台运行，不能干涉后一个进程的启动；而最后一个进程的使命是：既能使本身启动，又能让整个容器保持存活，而不至于启动后就让容器立即退出；

  ```shell
  ENTRYPOINT ["/home/gauss/start.sh"]
  ```

  > 此脚本中，其实又启动了两个脚本

  ```shell
  vim /home/gauss/start.sh
  #!/bin/bash
  #
  source /home/gauss/.bashrc &
  sh /home/gauss/pgweb-up.sh
  ```

  > 第一个脚本是设置环境变量，只给第一个进程使用，设置的环境变量不会给第二个进程使用；这种方式可以实现bash环境不一样；使用 "&" 是让第一个进程转入后台运行，而不退出；
  >
  > 第二个脚本是启动第二个进程，这个进程可以让整个容器保持存活；

  错误的配置方式：

  ```shell
  # 错误的方式是指：把两个脚本的执行命令放在同一个start.sh中，这样会导致只能启动第二个进程，而无法启动第一个进程；
  vim /home/gauss/start.sh
  #!/bin/bash
  #
  /home/gauss/openGauss/install/bin/gs_ctl start -D /home/gauss/openGauss/data 
  /usr/bin/pgweb --bind=0.0.0.0 --listen=8081
  ```

  
# 
### 构建

  > 上面使用ARG，因此可以实现不传参构建和传参构建;

  不传参构建:

  ```shell
  build -t <image_name>:<image_version> .
  ```

  传参构建：

  ```shell
  build -t <docker_image_name>:<version> --build-arg <arg1>=<value1> --build-arg <arg2>=<value2> <...> .
  ```

  
