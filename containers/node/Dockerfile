ARG NODE_VERSION

FROM node:$NODE_VERSION

ARG HOST_USER_ID
ARG HOST_USER_NAME
ARG HOST_GROUP_ID
ARG HOST_GROUP_NAME

RUN mkdir /var/www

RUN id -u node >/dev/null 2>&1 && \
  groupmod -g 1099 node && \
  usermod -u 1099 -g 1099 node || \
  echo "User 'node' does not exist, skipping usermod and groupmod"

RUN groupadd -f -g $HOST_GROUP_ID $HOST_GROUP_NAME && \
    useradd -m -d /home/$HOST_USER_NAME -s /bin/bash -g $HOST_GROUP_ID -u $HOST_USER_ID $HOST_USER_NAME || true && \
    echo "$HOST_USER_NAME  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chown -R $HOST_USER_NAME:$HOST_GROUP_NAME /var/www/