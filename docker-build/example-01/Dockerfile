FROM alpine:3.15 AS pgweb
LABEL MAIL="dakangsiji@gamil.com"

ARG PGWEB_ADDRESS="https://github.com/sosedoff/pgweb/releases/download/v0.11.11/pgweb_linux_amd64.zip"
RUN \
  apk update && \
  apk add --no-cache ca-certificates openssl postgresql wget && \
  update-ca-certificates && \
  rm -rf /var/cache/apk/* && \
  cd /tmp && \
  wget -q ${PGWEB_ADDRESS} && \
  unzip pgweb_linux_amd64.zip -d /usr/bin && \
  mv /usr/bin/pgweb_linux_amd64 /usr/bin/pgweb && \
  rm -f pgweb_linux_amd64.zip

FROM openeuler/openeuler:20.03-lts-sp3
LABEL MAIL="dakangsiji@gamil.com" \
      CREATE_DATE="2022-05" \
      ARCH="x86" \
      GAUSS_SERVER="openGauss-Lite-3.0.0"

RUN \
   sed -i "s/gpgcheck=1/gpgcheck=0/g" /etc/yum.repos.d/openEuler.repo && \
   yum install -y -q net-tools wget sudo shadow vim bc && \
   useradd gauss && \
   sed -i "101i gauss ALL=(ALL) NOPASSWD:ALL" /etc/sudoers && \
   sed -i "s/TMOUT=300/TMOUT=0/g" /etc/bashrc && \
   cp -rf /usr/share/zoneinfo/Asia/Beijing /etc/localtime

WORKDIR /home/gauss
USER gauss:gauss

ARG GSQL_INIT_PASSWD="openGauss@2022"
ENV LANG=en_US.utf8\
    GSQL_INIT_PASSWD=${GSQL_INIT_PASSWD}
RUN mkdir opengauss && \
    wget -q https://opengauss.obs.cn-south-1.myhuaweicloud.com/3.0.0/x86_openEuler/openGauss-Lite-3.0.0-openEuler-x86_64.tar.gz && \
    tar -xf openGauss-Lite-3.0.0-openEuler-x86_64.tar.gz -C ~/opengauss && \
    rm -f openGauss-Lite-3.0.0-openEuler-x86_64.tar.gz && \
    cd ~/opengauss && \
    echo ${GSQL_INIT_PASSWD} | sh ./install.sh --mode single -D ~/openGauss/data -R ~/openGauss/install --start
COPY bashrc .bashrc
COPY pgweb-up.sh pgweb-up.sh
COPY start.sh start.sh
COPY --from=pgweb /usr/bin/pgweb /usr/bin/pgweb
RUN sudo chmod a+x pgweb-up.sh && sudo chmod a+x .bashrc && sudo chmod a+x start.sh

EXPOSE 5432 8081
ENTRYPOINT ["/home/gauss/start.sh"]
