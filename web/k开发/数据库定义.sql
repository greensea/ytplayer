-- phpMyAdmin SQL Dump
-- version 3.2.0.1
-- http://www.phpmyadmin.net
--
-- 主机: localhost
-- 生成日期: 2010 年 03 月 17 日 08:26
-- 服务器版本: 5.0.22
-- PHP 版本: 5.2.3

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- 数据库: `ytp`
--

-- --------------------------------------------------------

--
-- 表的结构 `group_popsub`
--

CREATE TABLE IF NOT EXISTS `group_popsub` (
  `id` int(11) NOT NULL auto_increment,
  `groupid` int(11) NOT NULL,
  `content` varchar(200) NOT NULL,
  `color` int(11) default '0',
  `playtime` int(11) NOT NULL,
  `popsubtime` int(11) NOT NULL,
  `userid` int(11) NOT NULL,
  `flymode` smallint(6) NOT NULL,
  `fontsize` smallint(6) NOT NULL,
  `speed` int(11) NOT NULL,
  `channel` int(11) default NULL,
  `position` smallint(6) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=340 ;

-- --------------------------------------------------------

--
-- 表的结构 `popsub`
--

CREATE TABLE IF NOT EXISTS `popsub` (
  `id` int(11) NOT NULL auto_increment,
  `videoid` int(11) NOT NULL,
  `content` varchar(400) NOT NULL,
  `color` int(11) default '0',
  `playtime` int(11) NOT NULL,
  `popsubtime` int(11) NOT NULL,
  `userid` int(11) NOT NULL,
  `flymode` smallint(6) NOT NULL,
  `fontsize` smallint(6) NOT NULL,
  `speed` int(11) NOT NULL,
  `channel` int(11) default NULL,
  `position` smallint(6) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `编号_111964530841530` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=12987 ;

-- --------------------------------------------------------

--
-- 表的结构 `popsub_group`
--

CREATE TABLE IF NOT EXISTS `popsub_group` (
  `id` int(11) NOT NULL auto_increment,
  `groupname` longtext NOT NULL,
  `userid` int(11) default NULL,
  `filepath` longtext,
  `videoid` int(11) default NULL,
  UNIQUE KEY `编号_111964573387550` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1427 ;

-- --------------------------------------------------------

--
-- 表的结构 `source_site`
--

CREATE TABLE IF NOT EXISTS `source_site` (
  `id` int(11) NOT NULL auto_increment,
  `sitename` varchar(50) NOT NULL,
  `domain` varchar(50) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `编号_111999641320700` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=8 ;

-- --------------------------------------------------------

--
-- 表的结构 `user`
--

CREATE TABLE IF NOT EXISTS `user` (
  `id` int(11) NOT NULL,
  `name` char(10) default NULL,
  `sid` char(16) NOT NULL,
  `regtime` timestamp NULL default CURRENT_TIMESTAMP,
  `ip` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `video`
--

CREATE TABLE IF NOT EXISTS `video` (
  `id` int(11) NOT NULL auto_increment,
  `sourcepage` text NOT NULL,
  `sourcefile` text NOT NULL,
  `hits` int(11) NOT NULL default '0',
  `addtime` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text,
  `thumbnail` text,
  `userid` int(11) NOT NULL,
  `postername` varchar(200) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=106 ;

