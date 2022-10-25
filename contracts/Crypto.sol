//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.7;
contract CryptoKids
{
    //Define Owner / Manager
    address Manager;

    constructor ()
    {
        Manager=msg.sender;
    }

    //Define Candidate / Account holder name
    struct kids 
    {
        address payable walletAddress;
        string firstName;
        string lastName;
        uint releaseTime;
        uint amount;
        bool canWithdraw;

    }
    kids[] public kid;

    modifier onlyOwner(){
        require(msg.sender== Manager, "Only manager can add kids");
        _;
    }

    //Add Candidate to Contract
    function addKid(address payable walletAddress, string memory firstName, string memory lastName, uint releaseTime, uint amount, bool canWithdraw) public onlyOwner
    {
        kid.push(kids(walletAddress,
                       firstName,
                       lastName,
                       releaseTime,
                       amount,
                       canWithdraw
                    ));
    }

    function balancedof() public view   returns(uint)
    {
        return address(this).balance;//conventional way of viewing balance
    }


    //Deposit Money to the Contract then to the Candidate's Account
    function deposit(address walletAddress) payable public{
        addTokidsBalance(walletAddress);

    }
    //To add Money to kids account
    function addTokidsBalance(address walletAddress)  private
    {
        for(uint i=0;i<kid.length;i++)
        {
            if(kid[i].walletAddress==walletAddress)
            {
                kid[i].amount += msg.value;
            }
        }
    }

    //Getting Index of the Kid whose walletAddress matches with the Kid whose wallet(walletAddress) we want to store money
    function getIndex(address walletAddress) view private returns(uint)
    {
        for(uint i=0;i<kid.length;i++)
        {
            if(walletAddress == kid[i].walletAddress)
            {
            return i;
            }
        }
    
        return 999;
        

    }

    //Candidate Checks whether he is eligible to withdraw
    function availableToWithdraw(address walletAddress) public returns(bool)
    {
        uint i = getIndex(walletAddress);
        require(block.timestamp > kid[i].releaseTime,"You can't withdraw yet");
        if(block.timestamp > kid[i].releaseTime)
        {
            kid[i].canWithdraw= true;
            return true;
        }
        else 
        {
            return false;
        }
    }
    

    //Withdraw Money
    function withdraw(address payable walletAddress)  payable public
    {
        uint i=getIndex(walletAddress);
        require(msg.sender==kid[i].walletAddress,"Invalid Person");
        require(kid[i].canWithdraw==true,"You are not eligible to withdraw at this moment");
        kid[i].walletAddress.transfer(kid[i].amount);
    }
}