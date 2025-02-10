// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

//import {AggregatorV3Interface} from "./FundMe.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter{
    // function getPrice() internal view returns(uint256) {
    //     //Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
    //     //ABI

    //     AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    //     (, int256 price,,,) = priceFeed.latestRoundData();
    //     return uint256(price * 1e10);
    // }

    function getPrice(AggregatorV3Interface priceFeed) internal view returns(uint256) {
        //Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        //ABI
        (, int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    // function getConversionRate(uint256 ethAmount) internal  view returns (uint256){
    //     uint256 ethPrice = getPrice();
    //     uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
    //     return  ethAmountInUsd;
    // }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal  view returns (uint256){
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return  ethAmountInUsd;
    }

    function getVersion() internal view returns(uint256){
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }
}

// interface AggregatorV3Interface {
//   function decimals() external view returns (uint8);

//   function description() external view returns (string memory);

//   function version() external view returns (uint256);

//   function getRoundData(uint80 _roundId) 
//   external view 
//   returns
//    (uint80 roundId,
//     int256 answer, 
//     uint256 startedAt, 
//     uint256 updatedAt,
//     uint80 answeredInRound);

//   function latestRoundData()
//     external
//     view
//     returns 
//     (uint80 roundId, 
//     int256 answer, 
//     uint256 startedAt, 
//     uint256 updatedAt, 
//     uint80 answeredInRound);
// }
