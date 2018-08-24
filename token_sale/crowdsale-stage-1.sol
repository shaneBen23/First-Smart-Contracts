pragma solidity 0.4.8;

contract token {
	function transfer(address receiver, uint amount) {}
	function mintToken(address target, uint mintedAmount) {}
}

contract Crowdsale {
	enum State {
		Fundraising,
		Failed,
		Successful,
		Closed
	}

	State public state = State.Fundraising;

	struct Contribution {
		uint amount;
		address contributor;
	}

	Contribution[] contributions;

	uint public totalRaised;
	uint public currentBalance;
	uint public deadline;
	uint public completedAt;
	uint public priceInWei;
	uint public fundingMinimumTargetInWei;
	uint public fundingMaximumTargetInWei;
	address public creator;
	address public benificiary;
	string public campaignUrl;
	byte constant version = 1;

	token public tokenReward;

	event LogFundingReceived(address addr, uint amount, uint currentTotal);
	event LogWinnerPaid(address WinnerAddress);
	event LogFundingSuccessful(uint totalRaised);
	event LogFundingInitialized(address creator, address benificiary, string url, uint _fundingMaximumTargetInEther, uint deadline);

	modifier inState(State _state) {
		if(state != _state) throw;

		//this is how you exucute the rest of the function
		_;
	}

	modifier isMinimum() {
		if(msg.value < priceInWei) throw;
		_;
	}

	modifier isMultipuleOfPrice() {
		if(msg.value%priceInWei != 0) throw;
		_;
	}

	modifier isCreator() {
		if(msg.sender != creator) throw;
		_;
	}

	modifier atEndOfLifecycle() {
		if(!((state == State.Failed || state == State.Successful) && completedAt + 1 hours < now)) throw;
		_;	
	}

	function Crowdsale(
		uint _timeInMinutesForFundraising,
		string _campaignUrl,
		address _ifSuccessfulSendTo,
		uint256 _fundingMaximumTargetInEther,
		uint256 _fundingMinimumTargetInEther,
		token _addressOfTokenUsedAsReward,
		uint _etherCostOfEachToken
	) {
		creator = msg.sender;
		benificiary = _ifSuccessfulSendTo;
		campaignUrl = _campaignUrl;
		fundingMaximumTargetInWei = _fundingMaximumTargetInEther * 1 ether;
		fundingMinimumTargetInWei = _fundingMinimumTargetInEther * 1 ether;
		deadline = now + (_timeInMinutesForFundraising * 1 Minutes);
		currentBalance = 0;
		//Address of the token contract should be passed here
		tokenReward = token(_addressOfTokenUsedAsReward);
		priceInWei = _etherCostOfEachToken * 1 ether;

		LogFundingInitialized(creator, benificiary, campaignUrl, fundingMaximumTargetInWei, deadline);
	}

	function contribute()
		public 
		inState(State.Fundraising) 
		isMinimum()
		isMultipuleOfPrice() payable returns (uint256){
			uint256 amountInWei = msg.value;

			contributions.push(
				Contribution({amount: msg.value, contributor: msg.sender});
				);

			totalRaised += msg.value;
			currentBalance = totalRaised;
			if(fundingMaximumTargetInWei != 0) {
				tokenReward.transfer(msg.sender, amountInWei/priceInWei);
			}
			else {
				tokenReward.mintToken(msg.sender, amountInWei/priceInWei);
			}

			LogFundingSuccessful(msg.sender, msg.value, totalRaised);

			//Check if the funding is completed and pay the benificiary accordingly.

			return contributions.length - 1;
		}

	function checkIfFundingCompletedOrExpired() {
		if(fundingMaximumTargetInWei != 0 && totalRaised > fundingMaximumTargetInWei) {
			state = State.Successful;
			LogFundingSuccessful(totalRaised);
			//payout function

			completedAt = now;
		} 
		else if(now > deadline) {
			if(totalRaised >= fundingMinimumTargetInWei) {
				state = State.Successful;
				LogFundingSuccessful(totalRaised);
				//payout function

				completedAt = now;
			}
			else {
				state = State.Failed;
				completedAt = now;
			}
		}
	}

	function payout() {
		public
		inState(State.Successful) {
			if(benificiary.send(this.balance)) {
				throw;
			}

			state = State.Closed;
			currentBalance = 0;
			LogWinnerPaid(benificiary);
		}
	}

	function getRefund()
		public 
		inState(State.Failed)
		returns (bool) {
			for(uint i=0; i <= contributions.length; i++) {
				if(contributions[i].contributor == msg.sender) {
					uint amountToRefund = contributions[i].amount;
					contributions[i].amount = 0;
					if(!contributions[i].contributor.send(amountToRefund)) {
						contributions[i].amount = amountToRefund;
						return false;
					} else {
						totalRaised -= amountToRefund;
						currentBalance = totalRaised;
					}
					return true;
				}
			}
			return true;
		}

	function removeContract()
		public 
		isCreator()
		atEndOfLifecycle() {
			selfdestruct(msg.sender);
		}
		
	function() {
		throw;
	}
}







