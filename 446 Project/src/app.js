window.addEventListener('load', async () => {
    if (window.ethereum) {
        window.web3 = new Web3(window.ethereum);
        try {
            // Request account access if needed
            await window.ethereum.enable();
            // Acccounts now exposed
            web3.eth.defaultAccount = web3.eth.accounts[0];
        } catch (error) {
            // User denied account access...
            console.error("User denied account access")
        }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
        window.web3 = new Web3(web3.currentProvider);
    }
    // Non-dapp browsers...
    else {
        console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
    }
});

// Replace this with your smart contract ABI
const patientDataABI = [
    [
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": false,
              "internalType": "address",
              "name": "patientAddress",
              "type": "address"
            },
            {
              "indexed": false,
              "internalType": "bool",
              "name": "isDead",
              "type": "bool"
            }
          ],
          "name": "DeathStatusUpdated",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": false,
              "internalType": "address",
              "name": "patientAddress",
              "type": "address"
            }
          ],
          "name": "PatientAdded",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": false,
              "internalType": "address",
              "name": "patientAddress",
              "type": "address"
            },
            {
              "indexed": false,
              "internalType": "string",
              "name": "newStatus",
              "type": "string"
            }
          ],
          "name": "VaccineStatusUpdated",
          "type": "event"
        },
        {
          "inputs": [
            {
              "internalType": "uint256",
              "name": "",
              "type": "uint256"
            }
          ],
          "name": "patientAddresses",
          "outputs": [
            {
              "internalType": "address",
              "name": "",
              "type": "address"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "",
              "type": "address"
            }
          ],
          "name": "patients",
          "outputs": [
            {
              "internalType": "uint256",
              "name": "id",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "age",
              "type": "uint256"
            },
            {
              "internalType": "string",
              "name": "gender",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "vaccineStatus",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "district",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "symptomsDetails",
              "type": "string"
            },
            {
              "internalType": "bool",
              "name": "isDead",
              "type": "bool"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "_patientAddress",
              "type": "address"
            },
            {
              "internalType": "uint256",
              "name": "_id",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "_age",
              "type": "uint256"
            },
            {
              "internalType": "string",
              "name": "_gender",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "_vaccineStatus",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "_district",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "_symptomsDetails",
              "type": "string"
            }
          ],
          "name": "addPatient",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "_patientAddress",
              "type": "address"
            },
            {
              "internalType": "string",
              "name": "_newStatus",
              "type": "string"
            }
          ],
          "name": "updateVaccineStatus",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "_patientAddress",
              "type": "address"
            },
            {
              "internalType": "bool",
              "name": "_isDead",
              "type": "bool"
            }
          ],
          "name": "updateDeathStatus",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "_patientAddress",
              "type": "address"
            }
          ],
          "name": "getPatient",
          "outputs": [
            {
              "internalType": "uint256",
              "name": "",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "",
              "type": "uint256"
            },
            {
              "internalType": "string",
              "name": "",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "",
              "type": "string"
            },
            {
              "internalType": "bool",
              "name": "",
              "type": "bool"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "getPatientsCount",
          "outputs": [
            {
              "internalType": "uint256",
              "name": "",
              "type": "uint256"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        }
      ]
];

// Replace this with your smart contract address
const patientDataContractAddress = "0x123abc...";

// Now you can use patientDataABI and patientDataContractAddress in your frontend code


async function addPatientData() {
    const patientContract = new web3.eth.Contract(patientDataABI, patientDataContractAddress);
    const patientId = document.getElementById('patientId').value;
    const age = document.getElementById('age').value;
    const gender = document.getElementById('gender').value;

    try {
        await patientContract.methods.addPatientData(patientId, age, gender).send({ from: web3.eth.defaultAccount });
        alert('Patient data added successfully!');
        // Optionally, you can update UI or perform other actions after successful transaction
    } catch (error) {
        console.error('Error adding patient data:', error);
        alert('Failed to add patient data. Please check the console for error details.');
    }
}

// Function to update vaccine status of a patient by admin
async function updateVaccineStatus(patientAddress, newVaccineStatus) {
    const patientContract = new web3.eth.Contract(patientDataABI, patientDataContractAddress);
    
    try {
        await patientContract.methods.updateVaccineStatus(patientAddress, newVaccineStatus).send({ from: web3.eth.defaultAccount });
        alert('Vaccine status updated successfully!');
    } catch (error) {
        console.error('Error updating vaccine status:', error);
        alert('Failed to update vaccine status. Please check the console for error details.');
    }
}

// Function to update is_dead status of a patient by admin
async function updateIsDeadStatus(patientAddress, newIsDeadStatus) {
    const patientContract = new web3.eth.Contract(patientDataABI, patientDataContractAddress);
    
    try {
        await patientContract.methods.updateIsDeadStatus(patientAddress, newIsDeadStatus).send({ from: web3.eth.defaultAccount });
        alert('is_dead status updated successfully!');
    } catch (error) {
        console.error('Error updating is_dead status:', error);
        alert('Failed to update is_dead status. Please check the console for error details.');
    }
}

// Function to fetch COVID trend data
async function fetchCovidTrendData() {
    const patientContract = new web3.eth.Contract(patientDataABI, patientDataContractAddress);
    
    try {
        const averageDeathRate = await patientContract.methods.getAverageDeathRate().call();
        const districtWithHighestCovid = await patientContract.methods.getDistrictWithHighestCovid().call();
        const medianAgePerDistrict = await patientContract.methods.getMedianAgePerDistrict().call();
        const patientPercentageByAgeGroup = await patientContract.methods.getPatientPercentageByAgeGroup().call();
        
        // Display the fetched data in HTML table or format as needed
        console.log('Average Death Rate:', averageDeathRate);
        console.log('District with Highest Covid:', districtWithHighestCovid);
        console.log('Median Age Per District:', medianAgePerDistrict);
        console.log('Patient Percentage By Age Group:', patientPercentageByAgeGroup);
    } catch (error) {
        console.error('Error fetching COVID trend data:', error);
        alert('Failed to fetch COVID trend data. Please check the console for error details.');
    }
}

// Function to generate vaccine certificate for a patient
async function generateVaccineCertificate(patientAddress) {
    const patientContract = new web3.eth.Contract(patientDataABI, patientDataContractAddress);
    
    try {
        const vaccineStatus = await patientContract.methods.getVaccineStatus(patientAddress).call();
        
        if (vaccineStatus === 'two_dose') {
            // Display or download the vaccine certificate for the patient
            alert('Vaccine certificate generated successfully!');
        } else {
            alert('Patient has not received two doses of vaccine. Certificate cannot be generated.');
        }
    } catch (error) {
        console.error('Error generating vaccine certificate:', error);
        alert('Failed to generate vaccine certificate. Please check the console for error details.');
    }
}
