pragma solidity ^0.8.0;

contract DaoStorage {
    // Hackathon Judge
    address[] public judges;

    // Hackathon BUIDL, projectId => Project
    mapping(uint256 => Project) public projects;

    // Address of registered project
    mapping(address => bool) public isProjectOwners;

    // whiteList
    address[] public whiteList;

    // Judges' voting information
    mapping(address => uint256[]) public votedInfo;

    // Number of votes per project, projectId -> uint
    mapping(uint256 => uint) public projectPoll;
    uint256[] public allProjectIds;

    mapping(uint256 => uint[]) public bonus;
    mapping(address => bool) public hasClaimed;


    bool public isEnd;
    address[] public tokens;

    struct Project {
        uint256 projectID;
        uint256 hackerLinkID;
        address owner;
        string name;
    }
}

contract DaoInterfaces is DaoStorage {
    event RegProject(address owner, string name, uint256 projectId);
    event Vote(address user, uint256[] projectIds);
    event ClaimBonus(address user);
}