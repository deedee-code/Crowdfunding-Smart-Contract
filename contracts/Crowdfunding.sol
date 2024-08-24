// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


contract Crowdfunding {
    // Define a structure for a campaign
    struct Campaign {
        string title;
        string description;
        address benefactor;
        uint goal;
        uint deadline;
        uint amountRaised;
        bool isEnded;
    }

    // Mapping from campaign ID to Campaign structure
    mapping(uint => Campaign) public campaigns;
    uint public campaignCount;

    // Define events
    event CampaignCreated(uint campaignId, string title, string description, address benefactor, uint goal, uint deadline);
    event DonationReceived(uint campaignId, address donor, uint amount);
    event CampaignEnded(uint campaignId, address benefactor, uint amountRaised);

    // Contract owner
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier campaignExists(uint _campaignId) {
        require(_campaignId > 0 && _campaignId <= campaignCount, "Campaign does not exist");
        _;
    }

    modifier campaignNotEnded(uint _campaignId) {
        require(!campaigns[_campaignId].isEnded, "Campaign already ended");
        _;
    }

    // Create a new campaign
    function createCampaign(string memory _title, string memory _description, address _benefactor, uint _goal, uint _duration) public {
        require(_goal > 0, "Goal must be greater than zero");
        require(_benefactor != address(0), "Benefactor cannot be the zero address");

        campaignCount++;
        campaigns[campaignCount] = Campaign({
            title: _title,
            description: _description,
            benefactor: _benefactor,
            goal: _goal,
            deadline: block.timestamp + _duration,
            amountRaised: 0,
            isEnded: false
        });

        emit CampaignCreated(campaignCount, _title, _description, _benefactor, _goal, block.timestamp + _duration);
    }

    // Donate to a campaign
    function donate(uint _campaignId) public payable campaignExists(_campaignId) campaignNotEnded(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        require(msg.value > 0, "Donation must be greater than zero");

        campaign.amountRaised += msg.value;
        emit DonationReceived(_campaignId, msg.sender, msg.value);
    }

    // End a campaign and transfer funds to the benefactor
    function endCampaign(uint _campaignId) public campaignExists(_campaignId) campaignNotEnded(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign has not ended yet");

        campaign.isEnded = true;

        // Transfer funds to the benefactor
        (bool success, ) = campaign.benefactor.call{value: campaign.amountRaised}("");
        require(success, "Transfer to benefactor failed");

        emit CampaignEnded(_campaignId, campaign.benefactor, campaign.amountRaised);
    }

    // Withdraw leftover funds from the contract (if any)
    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        (bool success, ) = owner.call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    // Fallback function to receive ether
    receive() external payable {}
}
