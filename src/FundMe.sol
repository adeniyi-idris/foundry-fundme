// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.17;

// // Get Funds
// //Withdraw Funds
// // Set a minimum funding value in USD

// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// import {PriceConverter} from "./PriceConverter.sol";

// error NotOwner(); // custom error

// //constant - used for state variables to denote that their values should not be changed after initiatlizatin, 
// //immutable - used for state variables that are set at contract creation time (either in the constructor or when defined)  unlike constants, immutable variables can be initialized with expressions that are not known at compile time but are known at deployment time
// contract FundMe {
//     using PriceConverter for uint256;

//     uint256 public constant MINIMUM_USD = 50 * 10 ** 18;

//     address[] public  funders;
//     // mapping (address => uint256) public addressToAmountFunded;

//     address public immutable i_owner;
//     constructor(){
//         i_owner = msg.sender;
//     }

//     function fund() public payable  {
//         //allows users to send $
//         // have a minimum amount sent
//         // adding "payable" allows you receive eth.
//         // require keyword is a checker
//         require(msg.value.getConversionRate() > MINIMUM_USD, "too low");
//         funders.push(msg.sender);
//         addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
//         // what is a revert?
//         // undo any actions that have been dine, and send the remaining gas back.
//     }

//     function withdraw() public onlyOwner {
//         // for loop
//         // for(/* starting index, ending index, step amount*/)
//         for(uint256 funderIndex =0; funderIndex > funders.length; funderIndex++){
//             address funder = funders[funderIndex];
//             addressToAmountFunded[funder] = 0;
//         }

//         // reset the array
//         funders = new address[](0);
//         // actually withdraw the funds

//         //transfer
//         // payable(msg.sender).transfer(address(this).balance);
//         //send
//         // bool sendSuccess = payable(msg.sender).send(address(this).balance);
//         // require(sendSuccess, "Send failed");
//         //call
//         (bool callSuccess, ) = payable (msg.sender).call{value: address(this).balance}("");
//         require(callSuccess, "Call failed");

//     }

// //modifiers allowas us to put a key word in a function declaration to add some functionalities easily to any function
//     modifier onlyOwner() {
//         // require(msg.sender == i_owner,"Must be owner");
//         // require(msg.sender == i_owner) { revert NotOwner()};
//         if(msg.sender != i_owner) { revert NotOwner();}
//         _;
//     }

// // what happens if someone sends this contract ETH without calling the fund function

//     // receive()- designed to receive ETH sent to the the contract without data
//     receive() external payable {
//         fund();
//     }
//     // fallback()- acts as a default function for handling calls to undefined functions or receiving Ether
//     // it is called if no function matches the function identifier or if there's no "receive" function for plain Ether transfers with data.
//     fallback() external payable {
//         fund();
//     }
// }


pragma solidity ^0.8.18;

// Note: The AggregatorV3Interface might be at a different location than what was in the video!
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {

    using PriceConverter for uint256;

    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address public  immutable  i_owner;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed =  AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        //require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
       // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
       // return priceFeed.version();
       return s_priceFeed.version();
    }

    modifier onlyOwner() {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }


    function withdrawCheaper() public onlyOwner{
        uint256 fundersLength = s_funders.length;

        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }


    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256){
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(
        uint256 index
    ) external view returns (address){
        return s_funders[index];
    }

    function getOwner() external view returns(address){
        return i_owner;
    }
}