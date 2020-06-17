# Helpers

## Running automatic updates

```
sudo ln -s /root/bbb-lti-run/scripts/deploy.sh /usr/local/bin/bbb-lti-deploy
sudo cp /root/bbb-lti-run/scripts/bbb-lti-auto-deployer.service /etc/systemd/system/bbb-lti-auto-deployer.service
sudo cp /root/bbb-lti-run/scripts/bbb-lti-auto-deployer.timer /etc/systemd/system/bbb-lti-auto-deployer.timer
sudo cp /root/bbb-lti-run/scripts/bbb-lti-run.service /etc/systemd/system/bbb-lti-run.service
sudo systemctl daemon-reload
sudo systemctl enable bbb-lti-auto-deployer.service
sudo systemctl enable bbb-lti-auto-deployer.timer
sudo systemctl start bbb-lti-auto-deployer.timer
sudo systemctl enable bbb-lti-run.service
sudo systemctl start bbb-lti-run.timer
```
