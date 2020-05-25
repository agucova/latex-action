FROM debian:sid-20200514-slim

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=dumb

# avoid debconf and initrd
ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No

ARG BUILD_DATE

# Fix for update-alternatives: error: error creating symbolic link '/usr/share/man/man1/rmid.1.gz.dpkg-tmp': No such file or directory
# See https://github.com/debuerreotype/docker-debian-artifacts/issues/24#issuecomment-360870939
RUN mkdir -p /usr/share/man/man1

# pin debian unstable to fix release to prevent hickups
RUN echo "echo deb http://snapshot.debian.org/archive/debian/20200525T024443Z/ unstable main > /etc/apt/sources.list" && \
    apt-get -o Acquire::Check-Valid-Until=false update -qq && apt-get upgrade -qq && \
    # proposal by https://github.com/sumandoc/TeXLive-2017
    apt-get install -qy wget curl libgetopt-long-descriptive-perl libdigest-perl-md5-perl fontconfig && \
    # libfile-copy-recursive-perl is required by ctanify
    # pax: java, unzip, and perl
    apt-get install -qy --no-install-recommends openjdk-8-jre-headless libfile-which-perl libfile-copy-recursive-perl pdftk ghostscript unzip openssh-client git && \
    apt-get install -qy ruby poppler-utils && \
    # for plantuml, we need graphviz and inkscape. For inkscape, there is no non-X11 version, so 200 MB more
    apt-get install -qy --no-install-recommends graphviz && \
    # install texlive-full. The documentation ( texlive-latex-base-doc- texlive-latex-extra-doc- texlive-latex-recommended-doc-	texlive-metapost-doc- texlive-pictures-doc- texlive-pstricks-doc- texlive-publishers-doc- texlive-science-doc- texlive-fonts-extra-doc- texlive-fonts-recommended-doc- texlive-humanities-doc-) is also required
    apt-get install -qy --no-install-recommends texlive-full fonts-texgyre latexml xindy && \
    # add support for pygments
    apt-get install -qy python3-pygments python3-pip && \
    # fig2dev - tool for xfig to translate the figure to other formats
    apt-get install -qy fig2dev && \
    # add Google's Inconsolata font (https://fonts.google.com/specimen/Inconsolata)
    apt-get install -qy fonts-inconsolata && \
    # required by tlmgr init-usertree
    apt-get install -qy xzdec && \
    # install gnuplot
    apt-get install -qy gnuplot && \
    # Removing documentation packages *after* installing them is kind of hacky,
    # but it only adds some overhead while building the image.
    # Source: https://github.com/aergus/dockerfiles/blob/master/latex/Dockerfile
    apt-get --purge remove -qy .\*-doc$ && \
    # save some space
    rm -rf /var/lib/apt/lists/* && apt-get clean

# update font index
RUN luaotfload-tool --update

WORKDIR /home

# pandoc in the repositories is older - we just overwrite it with a more recent version
RUN wget https://github.com/jgm/pandoc/releases/download/2.9.2/pandoc-2.9.2-1-amd64.deb -q --output-document=/home/pandoc.deb && dpkg -i pandoc.deb && rm pandoc.deb


# install pkgcheck
RUN wget https://gitlab.com/Lotz/pkgcheck/raw/master/bin/pkgcheck -q --output-document=/usr/local/bin/pkgcheck && chmod a+x /usr/local/bin/pkgcheck

WORKDIR /root

COPY \
  entrypoint.sh \
  /root/

ENTRYPOINT ["/root/entrypoint.sh"]
