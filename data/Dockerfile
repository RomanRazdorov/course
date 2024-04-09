FROM dart:3.3-sdk

WORKDIR /app

ADD . /app/
RUN dart pub get
RUN dart pub global activate conduit 4.4.0
EXPOSE 6200

ENTRYPOINT [ "dart", "pub", "run", "conduit:conduit", "serve", "--port", "6200" ]
