FROM ngoquangduong/texlive:full

WORKDIR /root

COPY \
  entrypoint.sh \
  /root/

ENTRYPOINT ["/root/entrypoint.sh"]
