FROM ruby:2.4.1
MAINTAINER Jakub Knejzlik <jakub.knejzlik@inloopx.com>

RUN gem install danger-gitlab

ENV WORK_DIR="/danger"

RUN danger --version

VOLUME ${WORK_DIR}
WORKDIR ${WORK_DIR}

ENTRYPOINT [""]