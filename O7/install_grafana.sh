#!/bin/bash

wget https://mirrors.huaweicloud.com/grafana/11.2.0/grafana-enterprise-11.2.0.linux-arm64.tar.gz
tar tar -xzvf grafana-enterprise-11.2.0.linux-arm64.tar.gz -C /opt/
ln -s /opt/grafana-v11.2.0 /usr/local/bin/grafana
cp ./grafana.servce /etc/systemd/system/
useradd -r -M -s /bin/false grafana
groupadd -r grafana
chown -R grafana:grafana /opt/grafana-v11.2.0
systemctl daemon-reload
systemctl enable grafana
systemctl start grafana
systemctl status grafana