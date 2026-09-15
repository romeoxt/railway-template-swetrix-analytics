FROM nginx:1.31.1-alpine

COPY start.sh /start.sh

ENTRYPOINT ["sh", "/start.sh"]
