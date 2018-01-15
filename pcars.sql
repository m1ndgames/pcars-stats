-- MySQL dump 10.16  Distrib 10.1.26-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: pcars
-- ------------------------------------------------------
-- Server version	10.1.26-MariaDB-0+deb9u1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `pcars`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `pcars` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `pcars`;

--
-- Table structure for table `results`
--

DROP TABLE IF EXISTS `results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `results` (
  `id` int(11) NOT NULL,
  `steamid` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `car_name` varchar(255) NOT NULL,
  `car_id` bigint(20) NOT NULL,
  `car_class` varchar(50) NOT NULL,
  `event_time` bigint(20) NOT NULL,
  `event_time_converted` text NOT NULL,
  `lap_time` bigint(20) NOT NULL,
  `lap_time_converted` text NOT NULL,
  `sector_1_time` bigint(20) NOT NULL,
  `sector_1_time_converted` text NOT NULL,
  `sector_2_time` bigint(20) NOT NULL,
  `sector_2_time_converted` text NOT NULL,
  `sector_3_time` bigint(20) NOT NULL,
  `sector_3_time_converted` text NOT NULL,
  `controls` char(50) NOT NULL,
  `aid_drivingline` char(50) NOT NULL,
  `aid_clutch` char(50) NOT NULL,
  `aid_gears` char(50) NOT NULL,
  `aid_dmg` char(50) NOT NULL,
  `aid_stability` char(50) NOT NULL,
  `aid_traction` char(50) NOT NULL,
  `aid_abs` char(50) NOT NULL,
  `aid_brakes` char(50) NOT NULL,
  `aid_steering` char(50) NOT NULL,
  `own_setup` char(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

