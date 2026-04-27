ARG API_BASE_URL=/apptrip-api/api/v1
ARG FLUTTER_BASE_HREF=/apptrip-flutter/

FROM nginx:1.25-alpine

ARG API_BASE_URL=/apptrip-api/api/v1
ARG FLUTTER_BASE_HREF=/apptrip-flutter/

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY build/web /usr/share/nginx/html

RUN sed -i "s|<base href=\"/\">|<base href=\"${FLUTTER_BASE_HREF}\">|g" /usr/share/nginx/html/index.html \
    && sed -i "s|http://localhost:5010/api/v1|${API_BASE_URL}|g" /usr/share/nginx/html/main.dart.js

EXPOSE 80
