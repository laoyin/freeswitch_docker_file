# freeswitch_docker_file

最新测试，ok，修改了apt源。[点击查看教程](https://lowbibi.com/freeswitch-jssip/)









运行 docker build -t myimage:latest .



因为国内网络问题，因此我做了改动，将源改为国内阿里云。 如果你是华为云，你就替换成华为云的源，同理腾讯云的源。

RUN sed -i 's/http://deb.debian.org/http://mirrors.aliyun.com/g' /etc/apt/sources.list

做对应的替换。
