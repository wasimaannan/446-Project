const CovidTrend = artifacts.require("CovidTrend");
const PatientData = artifacts.require("PatientData");

module.exports = function (deployer) {
  deployer.deploy(CovidTrend, PatientData.address); 
};
