const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("CrowdfundingModule", (m) => {
  // Get parameters from the module configuration
  const title = m.getParameter("title");
  const description = m.getParameter("description");
  const benefactor = m.getParameter("benefactor");
  const goal = m.getParameter("goal");
  const duration = m.getParameter("duration");

  // Ensure all required parameters are provided
  if (!title || !description || !benefactor || !goal || !duration) {
    throw new Error("All parameters (title, description, benefactor, goal, duration) must be provided.");
  }

  // Deploy the Crowdfunding contract
  const crowdfunding = m.contract("Crowdfunding", [], {
    value: 0, // No initial funds are needed for deployment
  });

  // Initialize the contract with the provided parameters
  crowdfunding.createCampaign(title, description, benefactor, goal, duration);

  return { crowdfunding };
});
