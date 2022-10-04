# 镜像来源
FROM xbeeant/oo-unlimit:7.1.1.23

# 移除一些插件
RUN rm -rf /var/www/onlyoffice/documentserver/sdkjs-plugins/youtube
RUN rm -rf /var/www/onlyoffice/documentserver/sdkjs-plugins/translator
RUN rm -rf /var/www/onlyoffice/documentserver/sdkjs-plugins/zotero
RUN rm -rf /var/www/onlyoffice/documentserver/sdkjs-plugins/mendeley
RUN rm -rf /var/www/onlyoffice/documentserver/sdkjs-plugins/thesaurus
RUN rm -rf /var/www/onlyoffice/documentserver/sdkjs-plugins/ocr

# 移除字体
RUN rm -rf /usr/share/fonts/truetype/dejavu
RUN rm -rf /usr/share/fonts/truetype/liberation

# 导入中文字体
ADD ["onlyoffice-chinese-fonts/fonts for oo6/*", "/usr/share/fonts/truetype/custom/"] 

# 添加一些插件
ADD plugin-html /var/www/onlyoffice/documentserver/sdkjs-plugins/html
ADD plugin-autocomplete /var/www/onlyoffice/documentserver/sdkjs-plugins/autocomplete
ADD plugin-doc2md /var/www/onlyoffice/documentserver/sdkjs-plugins/doc2md
ADD plugin-wordscounter /var/www/onlyoffice/documentserver/sdkjs-plugins/wordscounter

# 修正hightlight js引用问题
RUN sed -i "s/https:\/\/ajax.googleapis.com\/ajax\/libs\/jquery\/2.2.2\/jquery.min.js/vendor\/jQuery-2.2.2-min\/jquery-v2.2.2-min.js/" /var/www/onlyoffice/documentserver/sdkjs-plugins/highlightcode/index.html

# 修改文件缓存时间
# 修改24小时为1小时
RUN sed -i  "s/86400/3600/" /etc/onlyoffice/documentserver/default.json

#替换/etc/onlyoffice/documentserver-example/production-linux.json文件里的104857600为10485760000
RUN sed -i -e 's/104857600/10485760000/g' /etc/onlyoffice/documentserver-example/production-linux.json

#在/etc/onlyoffice/documentserver-example/nginx/includes/ds-example.conf 第9行 添加  iclient_max_body_size 1000M 参数代码
RUN sed -i '9iclient_max_body_size 1000M;' /etc/onlyoffice/documentserver-example/nginx/includes/ds-example.conf

#在/etc/nginx/nginx.conf 第16行 添加16iclient_max_body_size 1000M参数代码
RUN sed -i '16iclient_max_body_size 1000M;' /etc/nginx/nginx.conf

#替换/etc/onlyoffice/documentserver/default.json代码里面的104857600为10485760000
RUN sed -i -e 's/104857600/10485760000/g' /etc/onlyoffice/documentserver/default.json

##替换/etc/onlyoffice/documentserver/default.json代码里面的300MB为3000MB
RUN sed -i -e 's/50MB/5000MB/g' /etc/onlyoffice/documentserver/default.json

#替换/etc/onlyoffice/documentserver/default.json代码里面的300MB为3000MB
RUN sed -i -e 's/300MB/3000MB/g' /etc/onlyoffice/documentserver/default.json

#替换/etc/onlyoffice/documentserver/nginx/includes/ds-common.conf下的client_max_body_size 100m为client_max_body_size 1000m
RUN sed -i 's/^client_max_body_size 100m;$/client_max_body_size 1000m;/' /etc/onlyoffice/documentserver/nginx/includes/ds-common.conf



EXPOSE 80 443

ARG COMPANY_NAME=onlyoffice
VOLUME /var/log/$COMPANY_NAME /var/lib/$COMPANY_NAME /var/www/$COMPANY_NAME/Data /var/lib/postgresql /var/lib/rabbitmq /var/lib/redis /usr/share/fonts/truetype/custom

ENTRYPOINT ["/app/ds/run-document-server.sh"]
