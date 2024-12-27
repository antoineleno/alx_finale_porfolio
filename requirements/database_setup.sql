SET GLOBAL validate_password.policy = LOW;
SET GLOBAL validate_password.length = 6;

CREATE DATABASE IF NOT EXISTS roofmarket_db;
CREATE USER IF NOT EXISTS 'roofmarket_user'@'localhost' IDENTIFIED BY 'roofmarket_pwd';
GRANT ALL PRIVILEGES ON roofmarket_db.* TO 'roofmarket_user'@'localhost';
FLUSH PRIVILEGES;



-- MySQL dump 10.13  Distrib 8.0.40, for Linux (x86_64)
--
-- Host: localhost    Database: roofmarket_db
-- ------------------------------------------------------
-- Server version	8.0.40-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `agent`
--

DROP TABLE IF EXISTS `agent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agent` (
  `agent_name` varchar(60) NOT NULL,
  `image_url` varchar(60) NOT NULL,
  `id` varchar(60) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent`
--

LOCK TABLES `agent` WRITE;
/*!40000 ALTER TABLE `agent` DISABLE KEYS */;
INSERT INTO `agent` VALUES ('Fatoumata SYLLA','11282255-0985-49bd-974e-8ed12c9f6929.jpg','11282255-0985-49bd-974e-8ed12c9f6929','2024-12-27 17:29:26','2024-12-28 03:53:46'),('Nouhan DOUMBOUYA','1e5a0bd1-7847-4813-bd3e-c25ed5eb5c59.jpg','1e5a0bd1-7847-4813-bd3e-c25ed5eb5c59','2024-12-27 17:29:26','2024-12-28 03:53:46'),('Hadiatou DIALLO','4a7fedb6-f9ef-4993-970a-4fa836551e46.jpg','4a7fedb6-f9ef-4993-970a-4fa836551e46','2024-12-27 17:29:25','2024-12-28 03:53:46'),('Theophile KAMANO','905e3ff9-20fa-433c-81bc-894598908975.jpg','905e3ff9-20fa-433c-81bc-894598908975','2024-12-27 17:29:26','2024-12-28 03:53:46');
/*!40000 ALTER TABLE `agent` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message`
--

DROP TABLE IF EXISTS `message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `message` (
  `room_id` varchar(60) NOT NULL,
  `user_id` varchar(60) NOT NULL,
  `message` text,
  `read_status` tinyint(1) DEFAULT NULL,
  `id` varchar(60) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `room_id` (`room_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `message_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `room` (`id`),
  CONSTRAINT `message_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message`
--

LOCK TABLES `message` WRITE;
/*!40000 ALTER TABLE `message` DISABLE KEYS */;
INSERT INTO `message` VALUES ('c5e5ce13-2c1a-46eb-8007-5ced9e845d4d','00d8a3ca-e8fa-48ef-87b9-5ce71e123a30','Hello Mr. Bah, I am interested in this property and would like to request more information about it. Could you please provide additional details? I look forward to hearing from you.',0,'0a26a44b-d6fa-4cb1-8dc3-d28905d7be8a','2024-12-27 21:34:11','2024-12-28 05:34:11'),('c5e5ce13-2c1a-46eb-8007-5ced9e845d4d','00d8a3ca-e8fa-48ef-87b9-5ce71e123a30','New conversation opened!',0,'801700dc-9ff6-41ae-8029-66836fc8b8be','2024-12-27 21:33:06','2024-12-28 05:33:06');
/*!40000 ALTER TABLE `message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `property`
--

DROP TABLE IF EXISTS `property`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `property` (
  `title` varchar(50) DEFAULT NULL,
  `description` varchar(2050) DEFAULT NULL,
  `property_type` varchar(10) DEFAULT NULL,
  `price` float DEFAULT NULL,
  `listing_type` varchar(5) DEFAULT NULL,
  `address` varchar(224) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `zip_code` varchar(15) DEFAULT NULL,
  `bedrooms` int DEFAULT NULL,
  `bathrooms` int DEFAULT NULL,
  `area` float DEFAULT NULL,
  `user_id` varchar(60) NOT NULL,
  `id` varchar(60) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `property_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `property`
--

LOCK TABLES `property` WRITE;
/*!40000 ALTER TABLE `property` DISABLE KEYS */;
INSERT INTO `property` VALUES ('Riverside Mansion','Experience unparalleled luxury with this exquisite apartment, offering a private riverside view that perfectly blends tranquility with elegance. Designed for lavish living, this residence features spacious interiors, high-end finishes, and expansive windows that flood the space with natural light, creating a warm and inviting atmosphere.','Apartment',700000000,'Sell','606','Dallas','TX','USA','75201',6,5,6000,'7f53657e-859d-4541-9faf-957b5d3c5b17','0893e932-2681-4d53-a3aa-ee5c84988d1c','2024-12-27 18:08:25','2024-12-28 02:08:25'),('Eco-Friendly House','A sustainable and eco-friendly house, built with the latest energy-efficient technology and materials.','House',2300,'Sell','1111','Portland','OR','USA','97201',3,2,2000,'7f53657e-859d-4541-9faf-957b5d3c5b17','0f19ffa7-4424-4418-9de9-2670779b16cf','2024-12-27 18:02:46','2024-12-28 02:02:46'),('Mountain Retreat','A secluded retreat in the mountains, perfect for those who seek tranquility and natural beauty.','Apartment',2200,'Rent','505','Denver','CO','Canada','80201',3,2,2000,'7f53657e-859d-4541-9faf-957b5d3c5b17','112934e9-c22f-42bd-84b7-5a2be8f4d0b2','2024-12-27 18:02:46','2024-12-28 02:02:46'),('Seaside Cottage','Cozy cottage with stunning seaside views, perfect for a peaceful getaway.','Studio',1200,'Rent','101','Cape Cod','MA','USA','02601',2,1,800,'7f53657e-859d-4541-9faf-957b5d3c5b17','11d5e4c8-bdc3-43b6-afc5-3e2ef53bf808','2024-12-27 18:08:25','2024-12-28 02:08:25'),('Beachfront Villa','Luxury villa right on the beach with private access to the shore and stunning ocean views.','Villa',12000,'Rent','909','Malibu','CA','USA','90265',5,5,4000,'7f53657e-859d-4541-9faf-957b5d3c5b17','17d46150-a488-4852-bbff-8fe04597b1e6','2024-12-27 18:08:25','2024-12-28 02:08:25'),('City Center Loft','Bright and airy loft in the city center, offering a unique blend of comfort and style.','Villa',2100,'Rent','606','Montreal','QC','Canada','02108',1,1,950,'7f53657e-859d-4541-9faf-957b5d3c5b17','1e64c660-04a8-43e0-9aea-32089fc5b38f','2024-12-27 18:02:46','2024-12-28 02:02:46'),('Country Estate','Sprawling country estate with extensive grounds and historical charm.','Villa',9500,'Sell','808','Santa Fe','NM','USA','87501',7,6,8500,'7f53657e-859d-4541-9faf-957b5d3c5b17','23be7034-e413-4867-9810-041b1349a0f5','2024-12-27 18:08:25','2024-12-28 02:08:25'),('Beach House','A beautiful beach house with ocean views.','House',2500,'Rent','456','Miami','FL','USA','33101',4,3,2200,'7f53657e-859d-4541-9faf-957b5d3c5b17','2cd0f980-b72a-40e2-b400-eae59d5b8d0f','2024-12-27 18:02:46','2024-12-28 02:02:46'),('Minimalist Studio','Compact and functional studio with a sleek design, ideal for city living.','Studio',1100,'Rent','505','Seattle','WA','USA','98101',1,1,500,'7f53657e-859d-4541-9faf-957b5d3c5b17','38061c7e-176e-45a7-8f0f-f6d5610d2b6f','2024-12-27 18:08:25','2024-12-28 02:08:25'),('Luxury Townhouse','Exclusive townhouse with high-end finishes, offering both comfort and sophistication.','House',3000,'Rent','1010','San Diego','CA','Malaysia','92101',3,2,1800,'7f53657e-859d-4541-9faf-957b5d3c5b17','416e59ee-113d-4102-a993-f929b29cf7ad','2024-12-27 18:02:46','2024-12-28 02:02:46'),('Rustic Cabin','A charming cabin nestled in the forest, offering complete solitude and a retreat from the world.','Apartment',1300,'Rent','1111','Lake Tahoe','CA','USA','96150',2,1,900,'7f53657e-859d-4541-9faf-957b5d3c5b17','4fd771af-b4c1-4ada-a8d5-b3d8845d637a','2024-12-27 18:08:25','2024-12-28 02:08:25'),('Modern Townhouse','Contemporary townhouse with state-of-the-art appliances and a spacious interior.','House',3000,'Rent','1010','Boston','MA','USA','02108',3,2,2000,'7f53657e-859d-4541-9faf-957b5d3c5b17','55ba60f5-e8da-45eb-b1c3-8f8bd4c393aa','2024-12-27 18:08:25','2024-12-28 02:08:25'),('Penthouse Suite','Exclusive penthouse with panoramic views and luxurious finishes throughout.','Apartment',5000,'Rent','202','San Francisco','CA','USA','94101',3,3,2500,'7f53657e-859d-4541-9faf-957b5d3c5b17','55cbbdfc-4bd2-4817-b290-bb6013514927','2024-12-27 18:02:46','2024-12-28 02:02:46'),('Spacious Farmhouse','Large farmhouse with a barn, perfect for those who enjoy a rustic lifestyle.','House',3500,'Rent','404','Nashville','TN','USA','37201',4,3,3000,'7f53657e-859d-4541-9faf-957b5d3c5b17','56f75290-9b2f-4031-8582-b6dd7d1d7139','2024-12-27 18:08:25','2024-12-28 02:08:25'),('Urban Loft','Stylish loft with industrial features, located in an up-and-coming area with great nightlife.','Villa',2200,'Rent','1515','Toronto','ON','Canada','60602',2,2,1400,'7f53657e-859d-4541-9faf-957b5d3c5b17','57cc704c-7a19-4707-9725-743ab001a70c','2024-12-27 18:02:46','2024-12-28 02:02:46'),('Smart Home','A modern home with smart features, offering convenience and advanced technology for everyday living.','House',2800,'Rent','1414','Austin','TX','Canada','73302',3,2,2500,'7f53657e-859d-4541-9faf-957b5d3c5b17','58163beb-e8d0-47b9-939b-927fe65078b5','2024-12-27 18:02:46','2024-12-28 02:02:46'),('Downtown Penthouse','Exclusive penthouse with unparalleled views of the city skyline.','Studio',8000,'Rent','707','Miami','FL','USA','33101',4,4,3000,'7f53657e-859d-4541-9faf-957b5d3c5b17','66863d7b-b2c1-43e8-8ab5-8f9b7cfeeee3','2024-12-27 18:08:25','2024-12-28 02:08:25'),('Luxury Apartment','Spacious apartment with modern amenities, located in a prime area near parks and public transport.','Apartment',1200,'Rent','123','New York','NY','USA','10001',3,2,1200,'7f53657e-859d-4541-9faf-957b5d3c5b17','6bce10e2-79f0-483c-9588-a31fb2493a21','2024-12-27 18:02:46','2024-12-28 02:02:46'),('Charming Bungalow','Cozy bungalow in a quiet neighborhood with vintage charm and modern updates.','Studio',1500,'Rent','1212','Kuala Lumpur','Wilayah Persekutuan','Malaysia','60602',2,1,1200,'7f53657e-859d-4541-9faf-957b5d3c5b17','6c81409a-a32d-4877-8f09-1018ec000eb9','2024-12-27 18:02:46','2024-12-28 02:02:46'),('Cozy Cottage','Charming cottage with a rustic feel, located in a peaceful neighborhood, ideal for a weekend getaway.','Studio',950,'Rent','303','Kuala Lumpur','Wilayah Persekutuan','Malaysia','37201',2,1,800,'7f53657e-859d-4541-9faf-957b5d3c5b17','6f62f277-f0df-4cbd-a675-efc7add5730b','2024-12-27 18:02:46','2024-12-28 02:02:46'),('Downtown Loft','Stylish loft in the heart of the city with a modern design and great access to restaurants and entertainment.','Villa',1800,'Rent','789','Los Angeles','CA','Canada','90001',2,1,1000,'7f53657e-859d-4541-9faf-957b5d3c5b17','82b28f0a-fc26-4055-aaf1-dd05b89a9ab4','2024-12-27 18:02:46','2024-12-28 02:02:46'),('Modern Condo','Sleek and modern condo in a prime location with easy access to shopping, dining, and public transport.','Studio',1600,'Rent','404','Austin','TX','USA','73301',2,2,1200,'7f53657e-859d-4541-9faf-957b5d3c5b17','8f8b0698-a331-4747-bc25-a6b06a3acb49','2024-12-27 18:02:46','2024-12-28 02:02:46'),('Suburban Family Home','Spacious home perfect for a growing family with a large backyard and quiet neighborhood.','House',3000,'Sell','101','Toronto','ON','Canada','60601',5,4,3500,'7f53657e-859d-4541-9faf-957b5d3c5b17','a0bd033f-8b0a-4a17-8542-662fd1392226','2024-12-27 18:02:46','2024-12-28 02:02:46'),('Loft in the Sky','Stunning loft apartment on the top floor with breathtaking views of the city skyline.','Villa',2500,'Rent','1212','New York','NY','USA','10011',3,2,2000,'7f53657e-859d-4541-9faf-957b5d3c5b17','a62f3cdc-4aae-420b-80c6-7a04b54d1b45','2024-12-27 18:08:25','2024-12-28 02:08:25'),('Contemporary Villa','A sleek and stylish villa with modern design and beautiful garden.','Villa',3500,'Rent','909','Los Angeles','CA','USA','90002',4,3,2500,'7f53657e-859d-4541-9faf-957b5d3c5b17','a7265651-e592-446a-ba97-ed869df2e39f','2024-12-27 18:02:46','2024-12-28 02:02:46'),('Mountain View Cabin','A charming cabin with spectacular mountain views and cozy interiors.','Apartment',1800,'Rent','303','Asheville','NC','USA','28801',2,1,900,'7f53657e-859d-4541-9faf-957b5d3c5b17','a7af3bb8-272f-47bd-94e8-a54a117d8d9e','2024-12-27 18:08:25','2024-12-28 02:08:25'),('Historic Mansion','An elegant mansion with rich history, located in a prestigious neighborhood, ideal for entertaining and luxury living.','Apartment',6000,'Sell','808','Vancouver','BC','Canada','19103',6,5,5000,'7f53657e-859d-4541-9faf-957b5d3c5b17','a7d9f657-4935-4ab5-a496-7eae229b9d0d','2024-12-27 18:02:46','2024-12-28 02:02:46'),('Urban Loft','Trendy loft with an industrial design, located in the heart of the city\'s arts district.','Villa',2000,'Rent','202','Chicago','IL','USA','60601',1,1,1000,'7f53657e-859d-4541-9faf-957b5d3c5b17','c15514e7-1e8b-4df2-82a9-4a94bc17a1ff','2024-12-27 18:08:25','2024-12-28 02:08:25'),('Urban Apartment','Modern apartment in a lively neighborhood, just minutes away from local shops, cafes, and cultural spots.','Apartment',1800,'Rent','707','Seattle','WA','Malaysia','98101',2,1,1100,'7f53657e-859d-4541-9faf-957b5d3c5b17','ecd75439-a35b-4af2-bf92-85a8f3e641b7','2024-12-27 18:02:46','2024-12-28 02:02:46'),('Spacious Villa','A large villa with a beautiful garden, pool, and scenic views, perfect for luxury living.','Villa',4500,'Sell','1313','Miami','FL','USA','33102',5,4,3500,'7f53657e-859d-4541-9faf-957b5d3c5b17','f092fb00-db52-40c8-89de-c1755fa62239','2024-12-27 18:02:46','2024-12-28 02:02:46');
/*!40000 ALTER TABLE `property` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `property_image`
--

DROP TABLE IF EXISTS `property_image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `property_image` (
  `image_type` varchar(45) DEFAULT NULL,
  `image_url` varchar(400) DEFAULT NULL,
  `property_id` varchar(60) NOT NULL,
  `id` varchar(60) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `property_id` (`property_id`),
  CONSTRAINT `property_image_ibfk_1` FOREIGN KEY (`property_id`) REFERENCES `property` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `property_image`
--

LOCK TABLES `property_image` WRITE;
/*!40000 ALTER TABLE `property_image` DISABLE KEYS */;
INSERT INTO `property_image` VALUES ('Main_image','static/uploads/a62f3cdc-4aae-420b-80c6-7a04b54d1b45_Main_image.png','a62f3cdc-4aae-420b-80c6-7a04b54d1b45','031e59ae-31ba-4250-8c7a-3da3bc2e632c','2024-12-27 19:07:10','2024-12-28 03:07:10'),('Main_image','static/uploads/a7d9f657-4935-4ab5-a496-7eae229b9d0d_Main_image.png','a7d9f657-4935-4ab5-a496-7eae229b9d0d','0408b1e6-6ab1-4093-8c07-809fb642f0b4','2024-12-27 19:06:42','2024-12-28 03:06:42'),('Main_image','static/uploads/17d46150-a488-4852-bbff-8fe04597b1e6_Main_image.png','17d46150-a488-4852-bbff-8fe04597b1e6','04341f18-fe4d-47bf-814e-ddbe91eb499b','2024-12-27 18:58:48','2024-12-28 02:58:48'),('Main_image','static/uploads/6f62f277-f0df-4cbd-a675-efc7add5730b_Main_image.png','6f62f277-f0df-4cbd-a675-efc7add5730b','0ccca0ba-e3e6-4802-9cf7-8e2b403e9700','2024-12-27 18:57:12','2024-12-28 02:57:12'),('Main_image','static/uploads/1e64c660-04a8-43e0-9aea-32089fc5b38f_Main_image.png','1e64c660-04a8-43e0-9aea-32089fc5b38f','1117bb32-adc6-4f1f-a193-556e617c17c9','2024-12-27 18:54:35','2024-12-28 02:54:35'),('Main_image','static/uploads/58163beb-e8d0-47b9-939b-927fe65078b5_Main_image.png','58163beb-e8d0-47b9-939b-927fe65078b5','115aadd7-a2d8-4e18-9cea-1bcf98e1f86a','2024-12-27 19:04:06','2024-12-28 03:04:06'),('Main_image','static/uploads/23be7034-e413-4867-9810-041b1349a0f5_Main_image.png','23be7034-e413-4867-9810-041b1349a0f5','179ceb56-63be-4a8b-9f79-a5d776a59eb6','2024-12-27 18:59:23','2024-12-28 02:59:23'),('balcony','static/uploads/f092fb00-db52-40c8-89de-c1755fa62239_balcony.jpg','0893e932-2681-4d53-a3aa-ee5c84988d1c','20dccf62-5e7b-4180-a914-ee9651f7d5b2','2024-12-27 21:08:34','2024-12-28 05:08:34'),('Main_image','static/uploads/82b28f0a-fc26-4055-aaf1-dd05b89a9ab4_Main_image.jpg','82b28f0a-fc26-4055-aaf1-dd05b89a9ab4','25458093-0add-4ceb-9dee-2603d9dbe343','2024-12-27 19:01:59','2024-12-28 03:01:59'),('Main_image','static/uploads/a7265651-e592-446a-ba97-ed869df2e39f_Main_image.jpg','a7265651-e592-446a-ba97-ed869df2e39f','2ac06006-750b-476e-b6b3-ed8863a23d83','2024-12-27 19:07:39','2024-12-28 03:07:39'),('Main_image','static/uploads/0f19ffa7-4424-4418-9de9-2670779b16cf_Main_image.png','0f19ffa7-4424-4418-9de9-2670779b16cf','2e9b6f9f-833b-4c74-9943-7528d477a918','2024-12-27 18:53:48','2024-12-28 02:53:48'),('Main_image','static/uploads/56f75290-9b2f-4031-8582-b6dd7d1d7139_Main_image.png','56f75290-9b2f-4031-8582-b6dd7d1d7139','33a66832-ac88-477b-b493-a9bba01d0703','2024-12-27 19:00:59','2024-12-28 03:00:59'),('Main_image','static/uploads/a0bd033f-8b0a-4a17-8542-662fd1392226_Main_image.png','a0bd033f-8b0a-4a17-8542-662fd1392226','3d5fdee5-3d62-47db-8f9d-bd4e2cdbeec8','2024-12-27 19:05:43','2024-12-28 03:05:43'),('bedroom','static/uploads/0893e932-2681-4d53-a3aa-ee5c84988d1c_bedroom.jpg','0893e932-2681-4d53-a3aa-ee5c84988d1c','3e8bf996-f07c-4455-9dac-a8d248488727','2024-12-27 20:59:01','2024-12-28 04:59:01'),('Main_image','static/uploads/6bce10e2-79f0-483c-9588-a31fb2493a21_Main_image.png','6bce10e2-79f0-483c-9588-a31fb2493a21','4579a0be-aaaa-4b58-bd8b-d13365321546','2024-12-27 18:56:11','2024-12-28 02:56:11'),('Main_image','static/uploads/a7af3bb8-272f-47bd-94e8-a54a117d8d9e_Main_image.webp','a7af3bb8-272f-47bd-94e8-a54a117d8d9e','5e2a8863-6529-46d5-b425-2c305155250c','2024-12-27 19:06:13','2024-12-28 03:06:13'),('Main_image','static/uploads/8f8b0698-a331-4747-bc25-a6b06a3acb49_Main_image.png','0893e932-2681-4d53-a3aa-ee5c84988d1c','5ecd7cbf-0051-485e-a3bc-d5b0467d2087','2024-12-27 19:02:58','2024-12-28 03:02:58'),('Main_image','static/uploads/55ba60f5-e8da-45eb-b1c3-8f8bd4c393aa_Main_image.png','55ba60f5-e8da-45eb-b1c3-8f8bd4c393aa','60c9bbca-3930-4836-9bcc-da149e93e227','2024-12-27 18:59:56','2024-12-28 02:59:56'),('Main_image','static/uploads/11d5e4c8-bdc3-43b6-afc5-3e2ef53bf808_Main_image.png','11d5e4c8-bdc3-43b6-afc5-3e2ef53bf808','62df3e7b-c270-4f86-8f96-3dcabe224f36','2024-12-27 18:58:18','2024-12-28 02:58:18'),('kitchen','static/uploads/f092fb00-db52-40c8-89de-c1755fa62239_kitchen.jpg','0893e932-2681-4d53-a3aa-ee5c84988d1c','65727626-1633-4d43-afc5-a0f895d44193','2024-12-27 21:02:22','2024-12-28 05:02:22'),('Main_image','static/uploads/416e59ee-113d-4102-a993-f929b29cf7ad_Main_image.jpg','416e59ee-113d-4102-a993-f929b29cf7ad','6f2bfaac-0426-40b5-9666-98e8cd4e49a8','2024-12-27 19:02:27','2024-12-28 03:02:27'),('Main_image','static/uploads/38061c7e-176e-45a7-8f0f-f6d5610d2b6f_Main_image.jpg','38061c7e-176e-45a7-8f0f-f6d5610d2b6f','7da86fca-8486-4322-805d-2b1450be482c','2024-12-27 19:03:37','2024-12-28 03:03:37'),('Main_entrance','static/uploads/0893e932-2681-4d53-a3aa-ee5c84988d1c_Main_entrance.png','0893e932-2681-4d53-a3aa-ee5c84988d1c','8966e998-abcd-4d4e-8da7-92492f7e0896','2024-12-27 20:46:41','2024-12-28 04:46:41'),('Main_image','static/uploads/57cc704c-7a19-4707-9725-743ab001a70c_Main_image.png','57cc704c-7a19-4707-9725-743ab001a70c','8c3623f6-5350-4402-b318-8fa3b4f8e021','2024-12-27 19:01:29','2024-12-28 03:01:29'),('Main_image','static/uploads/66863d7b-b2c1-43e8-8ab5-8f9b7cfeeee3_Main_image.jpg','66863d7b-b2c1-43e8-8ab5-8f9b7cfeeee3','9c686a07-cf6d-437a-a086-dc72d2c9792e','2024-12-27 19:04:40','2024-12-28 03:04:40'),('Main_image','static/uploads/2cd0f980-b72a-40e2-b400-eae59d5b8d0f_Main_image.png','2cd0f980-b72a-40e2-b400-eae59d5b8d0f','a4819ea7-d38b-486b-898d-a29852f6b622','2024-12-27 18:55:05','2024-12-28 02:55:05'),('Main_image','static/uploads/112934e9-c22f-42bd-84b7-5a2be8f4d0b2_Main_image.png','112934e9-c22f-42bd-84b7-5a2be8f4d0b2','b070ba50-d968-4a0c-9b5c-37fc62cead9a','2024-12-27 19:05:12','2024-12-28 03:05:12'),('Main_image','static/uploads/c15514e7-1e8b-4df2-82a9-4a94bc17a1ff_Main_image.png','c15514e7-1e8b-4df2-82a9-4a94bc17a1ff','b93f1ad0-eadc-419f-a554-4e2e00ab8757','2024-12-27 19:08:07','2024-12-28 03:08:07'),('Main_image','static/uploads/8f8b0698-a331-4747-bc25-a6b06a3acb49_Main_image.png','8f8b0698-a331-4747-bc25-a6b06a3acb49','bb798dcd-1df0-4d54-bc25-cecb7184946d','2024-12-27 18:57:46','2024-12-28 02:57:46'),('bathroom','static/uploads/f092fb00-db52-40c8-89de-c1755fa62239_bathroom.jpg','0893e932-2681-4d53-a3aa-ee5c84988d1c','e30184a9-d7d5-493a-8db5-42f5b3eddec2','2024-12-27 21:05:54','2024-12-28 05:05:54'),('Main_image','static/uploads/f092fb00-db52-40c8-89de-c1755fa62239_Main_image.webp','f092fb00-db52-40c8-89de-c1755fa62239','e304f828-04a6-4701-adc0-9cdb2a17366a','2024-12-27 19:09:08','2024-12-28 03:09:08'),('living_room','static/uploads/0893e932-2681-4d53-a3aa-ee5c84988d1c_living_room.webp','0893e932-2681-4d53-a3aa-ee5c84988d1c','e3992f2f-3c3e-46c1-a0e1-e007d8c99e28','2024-12-27 20:26:54','2024-12-28 04:26:54'),('Main_image','static/uploads/6c81409a-a32d-4877-8f09-1018ec000eb9_Main_image.jpg','6c81409a-a32d-4877-8f09-1018ec000eb9','f681d918-5651-44d0-8fde-b7472d92becd','2024-12-27 18:56:41','2024-12-28 02:56:41'),('Main_image','static/uploads/4fd771af-b4c1-4ada-a8d5-b3d8845d637a_Main_image.png','4fd771af-b4c1-4ada-a8d5-b3d8845d637a','f735c905-2214-4eb8-a7ae-cdd5ff735145','2024-12-27 18:55:36','2024-12-28 02:55:36'),('Main_image','static/uploads/ecd75439-a35b-4af2-bf92-85a8f3e641b7_Main_image.png','ecd75439-a35b-4af2-bf92-85a8f3e641b7','f7fe6dbc-883c-41d7-8034-a3caac735872','2024-12-27 19:08:36','2024-12-28 03:08:36'),('Main_image','static/uploads/55cbbdfc-4bd2-4817-b290-bb6013514927_Main_image.webp','55cbbdfc-4bd2-4817-b290-bb6013514927','f96cbc9d-07c7-4001-94f7-c6c0b3a12735','2024-12-27 19:00:27','2024-12-28 03:00:27');
/*!40000 ALTER TABLE `property_image` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `review`
--

DROP TABLE IF EXISTS `review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `review` (
  `rating` int DEFAULT NULL,
  `comment` varchar(1023) DEFAULT NULL,
  `user_id` varchar(60) NOT NULL,
  `property_id` varchar(60) NOT NULL,
  `id` varchar(60) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `property_id` (`property_id`),
  CONSTRAINT `review_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `review_ibfk_2` FOREIGN KEY (`property_id`) REFERENCES `property` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review`
--

LOCK TABLES `review` WRITE;
/*!40000 ALTER TABLE `review` DISABLE KEYS */;
/*!40000 ALTER TABLE `review` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `room`
--

DROP TABLE IF EXISTS `room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `room` (
  `id` varchar(60) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `room`
--

LOCK TABLES `room` WRITE;
/*!40000 ALTER TABLE `room` DISABLE KEYS */;
INSERT INTO `room` VALUES ('c5e5ce13-2c1a-46eb-8007-5ced9e845d4d','2024-12-27 21:33:06','2024-12-28 05:33:06');
/*!40000 ALTER TABLE `room` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roomparticipant`
--

DROP TABLE IF EXISTS `roomparticipant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roomparticipant` (
  `user_id` varchar(60) NOT NULL,
  `property_id` varchar(60) DEFAULT NULL,
  `room_id` varchar(60) NOT NULL,
  `room_position` tinyint(1) DEFAULT NULL,
  `id` varchar(60) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `property_id` (`property_id`),
  KEY `room_id` (`room_id`),
  CONSTRAINT `roomparticipant_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `roomparticipant_ibfk_2` FOREIGN KEY (`property_id`) REFERENCES `property` (`id`),
  CONSTRAINT `roomparticipant_ibfk_3` FOREIGN KEY (`room_id`) REFERENCES `room` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roomparticipant`
--

LOCK TABLES `roomparticipant` WRITE;
/*!40000 ALTER TABLE `roomparticipant` DISABLE KEYS */;
INSERT INTO `roomparticipant` VALUES ('00d8a3ca-e8fa-48ef-87b9-5ce71e123a30','0893e932-2681-4d53-a3aa-ee5c84988d1c','c5e5ce13-2c1a-46eb-8007-5ced9e845d4d',0,'8bf7cd55-c19a-4174-b578-9a2b275f6272','2024-12-27 21:33:06','2024-12-28 05:33:06'),('7f53657e-859d-4541-9faf-957b5d3c5b17','0893e932-2681-4d53-a3aa-ee5c84988d1c','c5e5ce13-2c1a-46eb-8007-5ced9e845d4d',0,'b117cf9d-0ffb-404b-b537-482a85feeed6','2024-12-27 21:33:06','2024-12-28 05:34:11');
/*!40000 ALTER TABLE `roomparticipant` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subcription`
--

DROP TABLE IF EXISTS `subcription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subcription` (
  `status` varchar(9) DEFAULT NULL,
  `id` varchar(60) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subcription`
--

LOCK TABLES `subcription` WRITE;
/*!40000 ALTER TABLE `subcription` DISABLE KEYS */;
INSERT INTO `subcription` VALUES ('Suspended','c70bf0b6-c4ab-4e3f-9b7e-7a6bc31b9cb2','2024-12-27 17:17:23','2024-12-28 01:17:23');
/*!40000 ALTER TABLE `subcription` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transaction`
--

DROP TABLE IF EXISTS `transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaction` (
  `payment_status` varchar(10) DEFAULT NULL,
  `supplier_id` varchar(60) NOT NULL,
  `property_id` varchar(60) NOT NULL,
  `duration` int DEFAULT NULL,
  `id` varchar(60) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `supplier_id` (`supplier_id`),
  KEY `property_id` (`property_id`),
  CONSTRAINT `transaction_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `user` (`id`),
  CONSTRAINT `transaction_ibfk_2` FOREIGN KEY (`property_id`) REFERENCES `property` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transaction`
--

LOCK TABLES `transaction` WRITE;
/*!40000 ALTER TABLE `transaction` DISABLE KEYS */;
/*!40000 ALTER TABLE `transaction` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `first_name` varchar(224) NOT NULL,
  `last_name` varchar(224) NOT NULL,
  `address` varchar(224) NOT NULL,
  `email` varchar(224) DEFAULT NULL,
  `phone_number` varchar(45) NOT NULL,
  `password_hash` varchar(1024) NOT NULL,
  `user_type` varchar(10) NOT NULL,
  `profile_image` varchar(65) NOT NULL,
  `is_online` tinyint(1) NOT NULL,
  `id` varchar(60) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES ('Antoine','LENO','123, New York, USA','rmarketadmin@gmail.com','+224 627 56 66 70','scrypt:32768:8:1$L3IYzSMAJMO56Dwj$4293212c8d077e217f73a090eb76042a9c50e3687e817ea9b54c211e1204f01e41079abbf5b2cfb287fb1fe3be852d7bb2e792e78af4243cc0fdc3b83f448b28','Admin','00d8a3ca-e8fa-48ef-87b9-5ce71e123a30.jpg',0,'00d8a3ca-e8fa-48ef-87b9-5ce71e123a30','2024-12-27 17:09:24','2024-12-28 01:09:24'),('Nouhan','BOUMBOUYA','123, New York, USA','client@gmail.com','+224 627 56 66 70','scrypt:32768:8:1$tUXhE1SotDnGcZwc$532ea349147498b82d1b680b9612b6677e366a2dda0b2053e590ff7d054a24fd14701c84692b750fa4bd6ba54b9ef094099a81e2cf351fa202fd6d3724f48e1a','Client','user.avif',0,'1daa3125-7bcf-4652-804c-ddf4b7947a2f','2024-12-27 17:13:58','2024-12-28 01:13:58'),('Amadou','BAH','123, New York, USA','supplier@gmail.com','+224 627 56 66 70','scrypt:32768:8:1$SEZrz73xfekI6gu2$b73240b6935c762b4c4acfd2cad9e9d9349e9f43fb8f6a5d4e8a61ddbe2b46d7338281875f70c9e1291a5e7f6aa73e151eecfb553059b2224554b9f9e3cd9871','Supplier','7f53657e-859d-4541-9faf-957b5d3c5b17.png',0,'7f53657e-859d-4541-9faf-957b5d3c5b17','2024-12-27 17:12:53','2024-12-28 01:12:53');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usersubcription`
--

DROP TABLE IF EXISTS `usersubcription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usersubcription` (
  `user_email` varchar(60) NOT NULL,
  `id` varchar(60) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_email` (`user_email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usersubcription`
--

LOCK TABLES `usersubcription` WRITE;
/*!40000 ALTER TABLE `usersubcription` DISABLE KEYS */;
/*!40000 ALTER TABLE `usersubcription` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `whishlist`
--

DROP TABLE IF EXISTS `whishlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `whishlist` (
  `user_id` varchar(60) NOT NULL,
  `property_id` varchar(60) NOT NULL,
  `id` varchar(60) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `property_id` (`property_id`),
  CONSTRAINT `whishlist_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `whishlist_ibfk_2` FOREIGN KEY (`property_id`) REFERENCES `property` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `whishlist`
--

LOCK TABLES `whishlist` WRITE;
/*!40000 ALTER TABLE `whishlist` DISABLE KEYS */;
INSERT INTO `whishlist` VALUES ('00d8a3ca-e8fa-48ef-87b9-5ce71e123a30','112934e9-c22f-42bd-84b7-5a2be8f4d0b2','5dd027c1-cf67-4247-a208-a267c0939dec','2024-12-27 19:47:10','2024-12-28 03:47:10');
/*!40000 ALTER TABLE `whishlist` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-12-28  5:37:31
