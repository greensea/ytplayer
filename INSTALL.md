部署说明
--------

1. 从 GitHub 上取出代码
> git clone https://github.com/greensea/ytplayer.git ytplayer

2. 在 MySQL 中新建数据库 ytp，以及对应的用户 ytp

3. 将数据库定义文件 src/web/k开发/数据库定义.sql 文件导入到 ytp 数据库中

4. 向 source_site 表中添加来源站点，类似下面这样的：
```
+----+--------------+-------------------+
| id | sitename     | domain            |
+----+--------------+-------------------+
|  2 | 土豆网       | tudou.com         |
|  3 | 优酷网       | youku.com         |
|  5 | 新浪视频     | sina.com.cn       |
|  6 | YouTube      | youtube.com       |
|  7 | 4shared.com  | 4shared-china.com |
+----+--------------+-------------------+
```

5. 将 src/web 目录下除了 k开发 以外的所有文件复制到网站根目录

6. 设置如下的 URL 重写规则：
```
dh(\d+) playpage.php?p=$1
```

部署完成。


### 环境需求

需要安装 MySQL 以及 PHP 环境，PHP 需要加载 curl 模块。Web 服务器需要支持 URL 重写。

-----------

如果按照此方法部署后仍然无法将 ytplayer 跑起来，欢迎给我来信询问。

