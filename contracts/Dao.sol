// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DaoInterfaces.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Dao is DaoInterfaces, Ownable {

    uint public constant judgeVotesLimit = 3; //Each judge has only three votes

    // ************************  admin method start ************************

    /**
    * @notice Administrator adds judges
    * @param _judges the list of addresses of judges
    */
    function addJudges(address[] memory _judges) public onlyOwner() {
        for (uint i = 0; i < _judges.length; i++) {
            if (!containsJudge(_judges[i])) {
                judges.push(_judges[i]);
            }
        }
    }

    function getJudges() public view returns (address[] memory) {
        return judges;
    }

    /**
    * @notice supportToken, only admin can invoke this method
    * @param _tokens the list of the supported erc20 token
    */
    function supportTokens(address[] memory _tokens) public onlyOwner() {
        require(isEnd == false, "It's already over.");
        for (uint i = 0; i < _tokens.length; i++) {
            IERC20(_tokens[i]).balanceOf(address(this));
            tokens.push(_tokens[i]);
        }
    }

    function getSupportTokens() public view returns (address[] memory) {
        return tokens;
    }

    /**
    * @notice addWhiteList
    * @param users the list of user address
    */
    function addWhiteList(address[] memory users) public onlyOwner() {
        require(isEnd == false, "It's already over.");
        for (uint i = 0; i < users.length; i++) {
            if (!isInWhiteList(users[i])) {
                whiteList.push(users[i]);
            }
        }
    }
    /**
    * @notice deleteProject
    * @param projectId project Id
    */
    function deleteProject(uint256 projectId) public onlyOwner() {
        require(isEnd == false, "It's already over.");
        Project memory p = projects[projectId];
        require(p.id == projectId, "non exist projectId");
        delete isProjectOwners[p.owner];
        delete projects[projectId];
        uint index = allProjectIds.length;
        for (uint i = 0; i < allProjectIds.length; i++) {
            if (allProjectIds[i] == projectId) {
                index = i;
                break;
            }
        }
        require(index < allProjectIds.length, "invalid projectId");
        // copy last item in list to location of item to be removed, reduce length by 1
        if (index != allProjectIds.length - 1) {
            allProjectIds[index] = allProjectIds[allProjectIds.length - 1];
        }
        allProjectIds.pop();
    }

    // ************************  admin method end ************************

    /**
    * @notice register project
    * @param name project name
    * @param projectId project Id
    */
    function regProject(string memory name, uint256 projectId) public {
        require(isEnd == false, "It's already over.");
        require(isInWhiteList(msg.sender), "Unauthorized address");
        require(isProjectOwners[msg.sender] == false, "has registered");
        Project memory p = projects[projectId];
        require(p.id != projectId, "Existing projectId");
        projects[projectId] = Project({
        id : projectId,
        owner : msg.sender,
        name : name});
        isProjectOwners[msg.sender] = true;
        allProjectIds.push(projectId);
        emit RegProject(msg.sender, name, projectId);
    }

    function getAllRegisteredIds() public view returns (uint256[] memory) {
        return allProjectIds;
    }
    /**
    * @notice vote
    * @param projectIds the list of the project id
    */
    function vote(uint256[] memory projectIds) public {
        require(isEnd == false, "The voting is over");
        require(projectIds.length == judgeVotesLimit, "Each judge has three votes");

        uint256[] memory infos = votedInfo[msg.sender];
        require(infos.length == 0, "The judges have run out of votes");

        bool isJudge = containsJudge(msg.sender);
        bool isOwner = isProjectOwners[msg.sender];
        for (uint i = 0; i < projectIds.length; i++) {
            Project memory p = projects[projectIds[i]];
            require(p.id == projectIds[i], "Nonexistent project id");
            require(isJudge || (isOwner && p.owner != msg.sender), "");
            projectPoll[projectIds[i]] += 1;
        }
        votedInfo[msg.sender] = projectIds;
        emit Vote(msg.sender, projectIds);
    }

    function getVotedInfo(address user) public view returns (uint256[] memory) {
        return votedInfo[user];
    }

    /**
    * @notice endVote
    */
    function endVote() public onlyOwner() {
        require(isEnd == false, "It's already over.");
        isEnd = true;
        uint256[] memory ids = allProjectIds;
        uint allPoll;
        for (uint i = 0; i < ids.length; i++) {
            allPoll += projectPoll[ids[i]];
        }
        uint[] memory allTokenBalance = new uint[](tokens.length);
        for (uint j = 0; j < tokens.length; j++) {
            uint b = IERC20(tokens[j]).balanceOf(address(this));
            allTokenBalance[j] = b;
        }
        for (uint i = 0; i < ids.length; i++) {
            uint poll = projectPoll[ids[i]];
            for (uint j = 0; j < tokens.length; j++) {
                uint b = allTokenBalance[j] * poll / allPoll;
                bonus[ids[i]].push(b);
            }
        }
    }

    function getBonus(uint256 id) public view returns (uint[] memory) {
        return bonus[id];
    }

    /**
    * @notice claimBonus
    * @param id project id
    * The bonus can only be withdrawn after the voting
    */
    function claimBonus(uint256 id) public {
        require(isEnd == true, "The voting is not over yet");
        Project memory p = projects[id];
        require(p.owner == msg.sender, "Only the project owner can withdraw the bonus");
        require(hasClaimed[msg.sender] == false, "has claimed");
        uint[] memory tokenBonus = bonus[id];
        require(tokenBonus.length == tokens.length, "invalid id");
        for (uint i = 0; i < tokens.length; i++) {
            if (tokenBonus[i] != 0) {
                uint balanceBefore = IERC20(tokens[i]).balanceOf(address(msg.sender));
                IERC20(tokens[i]).transfer(address(msg.sender), tokenBonus[i]);
                uint balanceAfter = IERC20(tokens[i]).balanceOf(address(msg.sender));
                require(balanceAfter - balanceBefore == tokenBonus[i], "transfer failed");
            }
        }
        hasClaimed[msg.sender] = true;
        emit ClaimBonus(msg.sender);
    }


    function containsJudge(address judge) internal view returns (bool) {
        for (uint i = 0; i < judges.length; i++) {
            if (judges[i] == judge) {
                return true;
            }
        }
        return false;
    }

    function isInWhiteList(address user) internal view returns (bool){
        for (uint i = 0; i < whiteList.length; i++) {
            if (whiteList[i] == user) {
                return true;
            }
        }
        return false;
    }
}


