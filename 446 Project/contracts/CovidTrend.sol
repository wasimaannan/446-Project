// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./PatientData.sol";

contract CovidTrend {
    PatientData patientData;

    constructor(address _patientDataContract) {
        patientData = PatientData(_patientDataContract);
    }

    function getAverageDeathRate() public view returns (uint) {
        uint totalDeaths;
        uint totalPatients = patientData.getPatientsCount(); // Use the getPatientsCount function to get the total number of patients
        
        for (uint i = 0; i < totalPatients; i++) {
            (, , , , , , bool isDead) = patientData.getPatient(patientData.patientAddresses(i));
            if (isDead) {
                totalDeaths++;
            }
        }
        
        if (totalPatients == 0) {
            return 0; // Return 0 if there are no patients to avoid division by zero
        } else {
            return (totalDeaths * 100) / totalPatients; // Calculate death rate as a percentage
        }
    }

    function getDistrictWithHighestCases() public view returns (string memory) {
        uint maxCases = 0;
        string memory districtWithHighestCases;
        
        for (uint i = 0; i < patientData.getPatientsCount(); i++) {
            (, , , , string memory district, , ) =patientData.getPatient(patientData.patientAddresses(i));
            uint casesInDistrict = getCasesInDistrict(district);
            
            if (casesInDistrict > maxCases) {
                maxCases = casesInDistrict;
                districtWithHighestCases = district;
            }
        }
        
        return districtWithHighestCases;
    }

    function getMedianAgeInDistrict(string memory _district) public view returns (uint) {
        uint[] memory ages;
        uint count = 0;
        
        for (uint i = 0; i < patientData.getPatientsCount(); i++) {
            (, uint age, , , string memory district, , ) = patientData.getPatient(patientData.patientAddresses(i));
            
            if (keccak256(bytes(district)) == keccak256(bytes(_district))) {
            ages[count] = age; // Store age in memory array
            count++;
        }
        }
        
        return calculateMedian(ages);
    }
    
    function getAgeGroupPercentage(string memory _district) public view returns (uint, uint, uint, uint) {
        uint children;
        uint teenagers;
        uint young;
        uint elder;
        
        for (uint i = 0; i < patientData.getPatientsCount(); i++) {
            (, uint age, , , string memory district, , ) = patientData.getPatient(patientData.patientAddresses(i));
            
            if (keccak256(bytes(district)) == keccak256(bytes(_district))) {
                if (age < 13) {
                    children++;
                } else if (age >= 13 && age < 20) {
                    teenagers++;
                } else if (age >= 20 && age < 50) {
                    young++;
                } else {
                    elder++;
                }
            }
        }
        
        uint totalPatients = children + teenagers + young + elder;
        
        if (totalPatients == 0) {
            return (0, 0, 0, 0);
        } else {
            return (
                (children * 100) / totalPatients,
                (teenagers * 100) / totalPatients,
                (young * 100) / totalPatients,
                (elder * 100) / totalPatients
            );
        }
    }
    
    function getCasesInDistrict(string memory _district) private view returns (uint) {
        uint cases;
        
        for (uint i = 0; i < patientData.getPatientsCount(); i++) {
            (, , , , string memory district, , ) = patientData.getPatient(patientData.patientAddresses(i));
            
            if (keccak256(bytes(district)) == keccak256(bytes(_district))) {
                cases++;
            }
        }
        
        return cases;
    }
    
    function calculateMedian(uint[] memory _ages) private pure returns (uint) {
        uint n = _ages.length;
        
        if (n == 0) {
            return 0;
        }
        
        uint[] memory sortedAges = _sort(_ages);
        
        if (n % 2 == 0) {
            return (sortedAges[n / 2] + sortedAges[(n / 2) - 1]) / 2;
        } else {
            return sortedAges[n / 2];
        }
    }
    
    function _sort(uint[] memory _arr) private pure returns (uint[] memory) {
        uint[] memory arr = _arr;
        uint n = arr.length;
        
        for (uint i = 0; i < n; i++) {
            for (uint j = i + 1; j < n; j++) {
                if (arr[i] > arr[j]) {
                    uint temp = arr[i];
                    arr[i] = arr[j];
                    arr[j] = temp;
                }
            }
        }
        
        return arr;
    }
}
