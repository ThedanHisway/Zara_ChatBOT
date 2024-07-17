CREATE DATABASE IF NOT EXISTS `adriens_pizza` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `adriens_pizza`;

-- Table structure for table `food_items`
DROP TABLE IF EXISTS `food_items`;
CREATE TABLE `food_items` (
  `item_id` int NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table `food_items`
INSERT INTO `food_items` VALUES 
(1, 'Margherita Pizza', 110.00),
(2, 'Pepperoni Pizza', 130.00),
(3, 'Cheese Pizza', 150.00),
(4, 'BBQ Chicken Pizza', 170.00),
(5, 'Coke', 50.00),
(6, 'Pepsi', 60.00),
(7, 'Sprite', 64.00),
(8, 'Water Bottled', 20.00),
(9, 'Iced Tea', 45.00),
(10, 'Garlic Butter Sauces', 200.00),
(11, 'Ranch Sauces', 180.00),
(12, 'Marinara Sauces', 150.00),
(13, 'Garlic Bread', 36.00),
(14, 'Breadsticks', 50.00),
(15, 'Chicken Wings', 90.00);

-- Table structure for table `order_tracking`
DROP TABLE IF EXISTS `order_tracking`;
CREATE TABLE `order_tracking` (
  `order_id` int NOT NULL,
  `status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table `order_tracking`
INSERT INTO `order_tracking` VALUES 
(40, 'delivered'),
(41, 'in transit');

-- Table structure for table `orders`
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `order_id` int NOT NULL,
  `item_id` int NOT NULL,
  `quantity` int DEFAULT NULL,
  `total_price` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`order_id`,`item_id`),
  KEY `orders_ibfk_1` (`item_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `food_items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table `orders`
INSERT INTO `orders` VALUES 
(40, 1, 2, 220.00),
(40, 3, 1, 150.00),
(41, 4, 3, 510.00),
(41, 6, 2, 120.00),
(41, 9, 4, 180.00);

-- Dumping routines for database 'adriens_pizza'
DROP FUNCTION IF EXISTS `get_price_for_item`;
DELIMITER ;;
CREATE FUNCTION `get_price_for_item`(p_item_name VARCHAR(255)) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN
    DECLARE v_price DECIMAL(10, 2);
    
    -- Check if the item_name exists in the food_items table
    IF (SELECT COUNT(*) FROM food_items WHERE name = p_item_name) > 0 THEN
        -- Retrieve the price for the item
        SELECT price INTO v_price
        FROM food_items
        WHERE name = p_item_name;
        
        RETURN v_price;
    ELSE
        -- Invalid item_name, return -1
        RETURN -1;
    END IF;
END ;;
DELIMITER ;

DROP FUNCTION IF EXISTS `get_total_order_price`;
DELIMITER ;;
CREATE FUNCTION `get_total_order_price`(p_order_id INT) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN
    DECLARE v_total_price DECIMAL(10, 2);
    
    -- Check if the order_id exists in the orders table
    IF (SELECT COUNT(*) FROM orders WHERE order_id = p_order_id) > 0 THEN
        -- Calculate the total price
        SELECT SUM(total_price) INTO v_total_price
        FROM orders
        WHERE order_id = p_order_id;
        
        RETURN v_total_price;
    ELSE
        -- Invalid order_id, return -1
        RETURN -1;
    END IF;
END ;;
DELIMITER ;

DROP PROCEDURE IF EXISTS `insert_order_item`;
DELIMITER ;;
CREATE PROCEDURE `insert_order_item`(
  IN p_food_item VARCHAR(255),
  IN p_quantity INT,
  IN p_order_id INT
)
BEGIN
    DECLARE v_item_id INT;
    DECLARE v_price DECIMAL(10, 2);
    DECLARE v_total_price DECIMAL(10, 2);

    -- Get the item_id and price for the food item
    SET v_item_id = (SELECT item_id FROM food_items WHERE name = p_food_item);
    SET v_price = (SELECT get_price_for_item(p_food_item));

    -- Check if the item_id and price are valid
    IF v_item_id IS NOT NULL AND v_price IS NOT NULL AND v_price > 0 THEN
        -- Calculate the total price for the order item
        SET v_total_price = v_price * p_quantity;

        -- Insert the order item into the orders table
        INSERT INTO orders (order_id, item_id, quantity, total_price)
        VALUES (p_order_id, v_item_id, p_quantity, v_total_price);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid food item name';
    END IF;
END ;;
DELIMITER ;
