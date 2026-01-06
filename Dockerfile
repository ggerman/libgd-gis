FROM ruby:3.3

RUN apt update && apt -y upgrade
RUN apt install -y libgd-dev libgd3 libgd-tools pkg-config ruby-dev build-essential valgrind

RUN printf "prefix=/usr\n\
exec_prefix=\${prefix}\n\
libdir=\${exec_prefix}/lib/x86_64-linux-gnu\n\
includedir=\${prefix}/include\n\
\n\
Name: gd\n\
Description: GD Graphics Library\n\
Version: 2.3\n\
Libs: -L\${libdir} -lgd\n\
Cflags: -I\${includedir}\n" \
> /usr/lib/x86_64-linux-gnu/pkgconfig/gd.pc

ENV PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig

WORKDIR /app
COPY . .

COPY Gemfile ./
RUN bundle install

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

COPY . .

