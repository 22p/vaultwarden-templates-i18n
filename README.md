## 使用方法

请保持文件结构不变，并将本项目放置于 Vaultwarden 对应的目录下。

以 Docker 为例，假设你在配置 Vaultwarden 时通过 `-v` 参数将本地文件夹挂载为 `vaultwarden-data`，则文件应放置于以下路径：

- 管理页面模板文件应放置在本地目录：`/vaultwarden-data/templates/admin`
- 电子邮件模板文件应放置在本地目录：`/vaultwarden-data/templates/email`

完成文件放置后，执行以下命令重启 Vaultwarden 容器：

```bash
docker restart vaultwarden
