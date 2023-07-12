### Task: nUSD Stablecoin 

The task for assessment is to create a new stablecoin called nUSD. The stablecoin will be backed by ETH (similar to DAI). The primary goals of this project are to allow users to deposit ETH and receive 50% of its value in nUSD. Additionally, there will be a redeem function to convert nUSD back into either ETH.
Applicants can create a very basic UI with one text field, and two buttons (deposit and redeem), and have one text box showing the total supply of nUSD.

## Key Functions:
Develop a function that enables users to deposit ETH and receive 50% of its value in nUSD. For instance, if a user deposits 1 ETH at 2000, they should receive 1000 nUSD. Applicants can use Testnet Ether and Testnet Chainlink Oracle for this task.
Design a redeem function that allows users to convert their nUSD back into either ETH at the current exchange. Ensure that the amount of nUSD required to convert to ETH is double the value, that is, to convert nUSD to 1ETH at 2000, 4000 nUSD would be required.
Ensure that the total supply of nUSD is updated based on the actions.

### The Applicant Will Be Judged In The Following Criteria:
Solidity: The developer must have a strong understanding of Solidity programming language and be able to write secure and efficient smart contracts.

**Minting and Burning:** The developer should be familiar with the process of minting new stablecoins when users deposit USDT or ETH, as well as burning or redeeming nUSD when users want to convert it back.
Oracle Integration: The developer should have experience integrating with oracles to fetch real-time price data for USDT and ETH in order to calculate the appropriate exchange rates.
**Testing:** The developer should write comprehensive unit tests to ensure the stability and correctness of the smart contracts. 
**Timeline:** 48 hours to complete the task.

## Submission: 
Share the source code via a version control system (e.g., GitHub) with clear instructions on how to run the project.
Include a README file that provides an overview of your implementation, any assumptions made, and any additional notes you want to mention.
Note: Please ensure that your implementation is focused on the smart contract part of the project. You do not need to focus on the frontend for this task, and can create a very basic UI for the testing purposes (no css required). You can deploy the contract on the ETH testnet. 
