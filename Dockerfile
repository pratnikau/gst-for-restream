FROM ubuntu:xenial

ENV GST_VERSION=1.14.4

RUN apt-get update

# Install compiler etc.
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    autoconf \
    automake \
    autopoint \
    bison \
    flex \
    libtool \
    yasm \
    nasm \
    git-core \
    build-essential \
    gettext

RUN apt-get install -y tcpdump net-tools wget

RUN wget -qO- https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# Install dependencies necessary to build our custom GStreamer build
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libglib2.0-dev \
    libpthread-stubs0-dev \
    libssl-dev \
    liborc-dev \
    libmpg123-dev \
    libmp3lame-dev \
    libsoup2.4-dev \
    libshout3-dev \
    libpulse-dev \
    libopus-dev \
    libopus0 \
    libopusfile-dev \
    libopusfile0 \
    libavcodec-dev \
    libavformat-dev \
    libx264-dev

# Fetch and build GStreamer
RUN git clone -b $GST_VERSION --depth 1 https://github.com/GStreamer/gstreamer.git \
    && cd gstreamer \
    && git checkout $GST_VERSION \
    && ./autogen.sh --prefix=/usr \
        --disable-gtk-doc --enable-orc \
    && make -j`nproc` \
    && make install \
    && cd .. \
    && rm -rvf /gstreamer

# Fetch and build gst-plugins-base
RUN git clone -b $GST_VERSION --depth 1 https://github.com/GStreamer/gst-plugins-base \
    && cd gst-plugins-base \
    && git checkout $GST_VERSION \
    && ./autogen.sh --prefix=/usr \
        --disable-gtk-doc --enable-orc \
    && make -j`nproc` \
    && make install \
    && cd .. \
    && rm -rvf /gst-plugins-base

# Fetch and build gst-plugins-good
RUN git clone -b $GST_VERSION --depth 1 https://github.com/GStreamer/gst-plugins-good \
    && cd gst-plugins-good \
    && git checkout $GST_VERSION \
    && ./autogen.sh --prefix=/usr \
        --disable-gtk-doc --enable-orc \
    && make -j`nproc` \
    && make install \
    && cd .. \
    && rm -rvf /gst-plugins-good

# Fetch and build gst-plugins-bad
RUN git clone -b $GST_VERSION --depth 1 https://github.com/GStreamer/gst-plugins-bad \
    && cd gst-plugins-bad \
    && git checkout $GST_VERSION \
    && ./autogen.sh --with-plugins="videoparsers,mpegtsmux,mpegtsdemux,opus" --prefix=/usr \
        --disable-gtk-doc --enable-orc \
    && make -j`nproc` \
    && make install \
    && cd .. \
    && rm -rvf /gst-plugins-bad

# Fetch and build gst-plugins-ugly
RUN git clone -b $GST_VERSION --depth 1 https://github.com/GStreamer/gst-plugins-ugly \
    && cd gst-plugins-ugly \
    && git checkout $GST_VERSION \
    && ./autogen.sh --with-plugins="x264" --prefix=/usr \
        --disable-gtk-doc --enable-orc \
    && make -j`nproc` \
    && make install \
    && cd .. \
    && rm -rvf /gst-plugins-ugly

# Fetch and build gst-libav
RUN git clone -b $GST_VERSION --depth 1 https://github.com/GStreamer/gst-libav \
    && cd gst-libav \
    && git checkout $GST_VERSION \
    && ./autogen.sh --prefix=/usr \
        --disable-gtk-doc --enable-orc \
    && make -j`nproc` \
    && make install \
    && cd .. \
    && rm -rvf /gst-libav

# Do some cleanup
RUN DEBIAN_FRONTEND=noninteractive apt-get clean && apt-get autoremove -y

RUN gst-inspect-1.0