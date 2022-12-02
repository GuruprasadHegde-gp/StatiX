pragma solidity >=0.8.0 <0.9.0;

//SPDX-License-Identifier: MIT

error not_a_canceler(); // a custom error is declared

contract dev_staking {
    address[] dev_address; // array of address to store the address of the developer(help seeker)
    mapping(address => uint256) dev_to_reward; //mapping which stores the reward listed by each donor for his
    address immutable help_deployer;

    constructor() {
        help_deployer = msg.sender;
    }

    function req_help() public payable {
        dev_address.push(msg.sender); // address of the help seeker is stored into the array
        dev_to_reward[msg.sender] = msg.value; //The reward Listed by the developer is stored into  his respective address
    }

    //The above basic function posts the help along with the staked reward

    function cancel_help() public {
        // If the user wants to cancel the contract then this function is called
        dev_to_reward[msg.sender] = 0; // All the reward is set to 0
        uint help_cancel_ind = help_cancel_index(msg.sender); // calls the help_cancel_index function to get the index of cancelers address
        delete_help(help_cancel_ind); //delete_helper function is called
        withdraw_cancelled_price(); //Returns the amount staked by the user
    }

    function help_cancel_index(
        address cancelers_address
    ) public view returns (uint256) {
        uint256 cancelers_index;
        for (uint i = 0; i <= dev_address.length; i++) {
            if (dev_address[i] == cancelers_address) {
                cancelers_index = i;
                return cancelers_index;
            }
        }
    }

    function delete_help(uint256 index) internal {
        //This function ndeletes the cancelled help seekers address address and removes it totally from the array
        if (index >= dev_address.length) return;

        for (uint i = index; i < dev_address.length - 1; i++) {
            dev_address[i] = dev_address[i + 1];
        }
        dev_address.pop();
    }

    function withdraw_cancelled_price() public canceler_only {
        // if this function is called then the amount which was deployed by the help seeker will be reverted back to him
        (bool callStatus, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callStatus, "Transaction Failed due to some Error's");
    }

    modifier canceler_only() {
        // Modifier
        if (msg.sender != help_deployer) {
            revert not_a_canceler();
        }
        _;
    }
}
