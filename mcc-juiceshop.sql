-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 28, 2024 at 06:11 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mcc-juiceshop`
--

-- --------------------------------------------------------

--
-- Table structure for table `juices`
--

CREATE TABLE `juices` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `price` int(11) NOT NULL,
  `category` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `juices`
--

INSERT INTO `juices` (`id`, `name`, `price`, `category`, `image`, `description`) VALUES
(1, 'Guava++ Juice', 30000, 'Very Sweet', 'public\\images\\1722094391072-amiya_sadge6.gif', 'An expanded Guava Juice!'),
(2, 'Soda Strawberry Juice', 16000, 'Not Sweet', 'public\\images\\1722094224153-amiya_pfp.jpeg', 'Strawberry flavored soda juice with a slight taste of sourness');

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `juiceId` int(11) NOT NULL,
  `review` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `reviews`
--

INSERT INTO `reviews` (`id`, `userId`, `juiceId`, `review`) VALUES
(1, 1, 1, 'BEST ++ JUICE EVERRRRRRRR'),
(3, 2, 2, 'GG BEST JUICE EVER MADEEEEEE'),
(4, 2, 2, 'SABNSFBFG');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`) VALUES
(1, 'torpadeka', '$2b$10$GaDx.ahMF7qrmMmhQevorO9QYu/TfCmUEXMqkqYyg0KEBXvB.k6Iy'),
(2, 'hehehe', '$2b$10$Ii2g6MvbyOmn6uFT7XP4FOcUgceeP54lpWYM7TIcwzLahS2f1lXTC'),
(3, 'biox1', '$2b$10$Tk1PJKP4/UCVxkAkju4Mcu8znotFhymcLNPD7zLZzXm7wsgDBVQhW');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `juices`
--
ALTER TABLE `juices`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `juices`
--
ALTER TABLE `juices`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
