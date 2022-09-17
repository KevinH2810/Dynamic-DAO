// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

// Import this file to use console.log

contract DAO {
  address public admin;
  address token;

  struct Question{
    string content;
    // uint tokenOfVotes;
    uint totalVote;
    bool completed; //default false
    // mapping(address => bool) voters;
    // address proposer;
    uint deadline; //a timestamp in seconds format. ex:60 for 1 minutes, 3600 for 1 hour
    string[] answers;
    mapping(uint => uint) answerRecord; //answer position => how many voted
    uint highestVotedAnswer;
    address payable recipient;
    uint256 requiredToken;
  }

  mapping(uint => Question) public Questions;
  uint public numQuestions;

  event questionCreated(uint questionId, string _questionContent);

  constructor(address _token) {
    admin = msg.sender;
    token = _token;
  }

  function getAnswerAmount(uint questionId) public view returns(uint){
    Question storage newQuestion = Questions[questionId];
    return newQuestion.answers.length;
  }

  function getAnswer(uint questionId, uint answerId) public view returns(string memory){
      Question storage newQuestion = Questions[questionId];
      return newQuestion.answers[answerId];
  }

  function propose(string memory _content, uint _deadline, string[] memory _answers, address payable _recipient) public {
    Question storage newQuestion = Questions[numQuestions];
    emit questionCreated(numQuestions, _content);
    ++numQuestions;

    newQuestion.content = _content;
    // newQuestion.proposer = msg.sender;
    newQuestion.totalVote = 0;
    // newQuestion.tokenOfVotes = 0;
    newQuestion.deadline = block.timestamp + _deadline;
    newQuestion.answers = _answers;
    newQuestion.highestVotedAnswer = 0;
    newQuestion.recipient = _recipient;
    // newQuestion.completed = false;
  }

  function vote(uint questionId, uint answerPosition) payable public {
    //check if user has enough Zenith Token
    Question storage thisQuestion = Questions[questionId];
    require(block.timestamp <= thisQuestion.deadline, "DEADLINE HAS PASSED"); //check if question deadline has passed
    uint256 userBalanceZTH = IERC20(token).balanceOf(msg.sender);
    require(userBalanceZTH >= thisQuestion.requiredToken, "Not Enough ZTH"); 
    require(answerPosition <= thisQuestion.answers.length); //check if answer position is valid

    //if user has enough ZTH then do transaction
    //add allowance first
    IERC20(token).transferFrom(msg.sender, address(this), thisQuestion.requiredToken);
    //add validation to check if amount sent are == to requiredToken to be paid to vote
    // thisQuestion.answerRecord[answerPosition]++; //if passed then ad 1 vote for user
    // thisQuestion.totalVote++;
    // //check if current highest vote is lower than the latest voted answer
    // if(thisQuestion.answerRecord[thisQuestion.highestVotedAnswer] < thisQuestion.answerRecord[answerPosition]){
    //   thisQuestion.highestVotedAnswer = answerPosition;
    // }
  }

  function claim(uint questionId) public onlyAdmin {
      Question storage thisQuestion = Questions[questionId];
      thisQuestion.completed = true;
  }

  modifier onlyAdmin{
        require(msg.sender == admin, "UNAUTHORIZED ACCESS");
        _;
    }
}