FROM scratch
COPY nanoid /nanoid
ENV LANG=C.UTF-8
ENTRYPOINT [ "/nanoid" ]