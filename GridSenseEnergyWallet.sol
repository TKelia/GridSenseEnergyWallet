// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    GridSenseEnergyWallet
    ----------------------
    This smart contract is a simple prepaid energy wallet
    for GridSense AI users.

    Each user has:
    - a GridSense ID (for example: "GS-0001")
    - a prepaid energy balance (just a number of units)
    - a low balance limit (when balance is below this, it is "low")

    The idea is that the normal web system (GridSense AI)
    can talk to this contract and read/write the balance.
*/
contract GridSenseEnergyWallet {

    struct User {
        string gridSenseId;      // user GridSense number
        uint256 balance;         // prepaid energy units
        uint256 lowBalanceLimit; // when balance < this, it is low
        bool exists;             // to check if user is registered
    }

    // map each ethereum address to a User
    mapping(address => User) private users;

    // only registered users can call some functions
    modifier onlyRegistered() {
        require(users[msg.sender].exists, "User is not registered");
        _;
    }

    /*
        registerUser
        ------------
        Called by a new user to register themselves.
        They choose their GridSense ID and a low balance limit.
        (In a real system, this might be done by an admin or back-end.)
    */
    function registerUser(string calldata _gridSenseId, uint256 _lowBalanceLimit) external {
        require(!users[msg.sender].exists, "User already registered");
        require(bytes(_gridSenseId).length > 0, "GridSense ID is required");

        users[msg.sender] = User({
            gridSenseId: _gridSenseId,
            balance: 0,
            lowBalanceLimit: _lowBalanceLimit,
            exists: true
        });
    }

    /*
        topUp
        -----
        Add more energy units to your balance.
        In this simple version we just increase the number.
        (For the assignment we are not handling real money here,
        just showing the logic.)
    */
    function topUp(uint256 _amount) external onlyRegistered {
        require(_amount > 0, "Amount must be > 0");
        users[msg.sender].balance += _amount;
    }

    /*
        spendEnergy
        -----------
        Reduce the user's balance when appliances use power.
        In the real GridSense system, this would be called by
        the backend when it calculates usage.
    */
    function spendEnergy(uint256 _amount) external onlyRegistered {
        require(_amount > 0, "Amount must be > 0");
        require(users[msg.sender].balance >= _amount, "Not enough balance");
        users[msg.sender].balance -= _amount;
    }

    /*
        updateLowBalanceLimit
        ---------------------
        Let the user change their low balance threshold.
    */
    function updateLowBalanceLimit(uint256 _newLimit) external onlyRegistered {
        users[msg.sender].lowBalanceLimit = _newLimit;
    }

    /*
        getMyData
        ---------
        Helper function so a user can see all their info.
    */
    function getMyData() external view onlyRegistered returns (
        string memory,
        uint256,
        uint256
    ) {
        User memory u = users[msg.sender];
        return (u.gridSenseId, u.balance, u.lowBalanceLimit);
    }

    /*
        getBalance
        ----------
        View function to check the balance of any user address.
        This can be used by the GridSense backend or dashboard.
    */
    function getBalance(address _user) external view returns (uint256) {
        return users[_user].balance;
    }

    /*
        isLowBalance
        ------------
        Returns true if the given user's balance is below their
        low balance limit.
    */
    function isLowBalance(address _user) external view returns (bool) {
        if (!users[_user].exists) {
            return false;
        }
        return users[_user].balance < users[_user].lowBalanceLimit;
    }

    /*
        getGridSenseId
        --------------
        Returns the GridSense ID string for a given user address.
    */
    function getGridSenseId(address _user) external view returns (string memory) {
        require(users[_user].exists, "User is not registered");
        return users[_user].gridSenseId;
    }
}
