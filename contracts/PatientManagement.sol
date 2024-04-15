// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract PatientManagement {
    // Emit an event when a patient is added with the is_dead flag set to true
    event PatientAddedWithDeath(uint indexed id, string name, string district, bool is_dead);
    event votedEvent(uint indexed _candidateId);
    event PatientAdded(
        uint indexed id,
        string name,
        uint age,
        string gender,
        string vaccine_status,
        string district,
        string symptoms_details,
        bool is_dead
    );

    struct Patient{
        uint id;
        string name;
        uint age;
        string gender;
        string vaccine_status;
        string district;
        string symptoms_details;
        bool is_dead;
        bool isDoubleDosed;
    }

    // Store accounts that have voted
    mapping( address => bool ) public admins;

    mapping( uint => Patient ) public patients;

    // store candidates count
    uint public patientsCount=0;
    
   
struct DistrictStats {
    uint totalPatients;
    uint totalDeaths;
    uint totalAge;
    uint childCount;
    uint teenCount;
    uint youthCount;
    uint elderCount;
    uint childPercent;
    uint teenPercent;
    uint youthPercent;
    uint elderPercent;
}

    // Mapping to store district-wise statistics
    mapping(string => DistrictStats) public districtStats;
    // update Covid trend statistics
    function updateCovidTrend(uint _id, uint _age, string memory _district, bool _is_dead, bool isAddition) internal {
        if (districtStats[_district].totalPatients == 0) {
            districtStats[_district] = DistrictStats(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        }

    
        DistrictStats storage stats = districtStats[_district];
        
        
        if (isAddition) {
            stats.totalPatients++;
        } else {
            require(stats.totalPatients > 0, "No patients in this district");
            stats.totalPatients--;
        }
        
       
        stats.totalAge += _age;

        // Update death count
        if (_is_dead) {
            stats.totalDeaths++;
        }

       
        if (_age < 13) {
            stats.childCount++;
        } else if (_age < 20) {
            stats.teenCount++;
        } else if (_age < 50) {
            stats.youthCount++;
        } else {
            stats.elderCount++;
        }

       
        uint totalPatients = stats.totalPatients;
        stats.childPercent = (stats.childCount * 100) / totalPatients;
        stats.teenPercent = (stats.teenCount * 100) / totalPatients;
        stats.youthPercent = (stats.youthCount * 100) / totalPatients;
        stats.elderPercent = (stats.elderCount * 100) / totalPatients;
    }


   
    // Mapping to store death count for each district
    mapping(string => uint) public districtDeathCounts;

    // update death count for a district
    function updateDistrictDeathCount(string memory _district, bool _is_dead) internal {
        if (_is_dead) {
            districtDeathCounts[_district]++;
        }
    }

    // Array to store all district names
    string[] public districts;

    function districtExists(string memory _district) internal view returns (bool) {
        for (uint i = 0; i < districts.length; i++) {
            if (keccak256(abi.encodePacked(districts[i])) == keccak256(abi.encodePacked(_district))) {
                return true;
            }
        }
        return false;
    }

    // adding candidates
    function addPatient(string memory _name, uint _age ,string memory _gender,string memory _vaccine_status,string memory _district,string memory _symptoms_details,bool _is_dead ) public {
        patientsCount++;
        bool isDoubleDosed = compareStrings(_vaccine_status, "two_dose"); // Check if vaccine status is "Two Dose"
        patients[patientsCount] = Patient(patientsCount, _name,_age, _gender, _vaccine_status, _district, _symptoms_details, _is_dead, isDoubleDosed );
        
        // Update district death count if the patient is dead
        if (_is_dead) {
            updateDistrictDeathCount(_district, _is_dead);
        }
        
        // Update Covid trend statistics
        updateCovidTrend(patientsCount, _age, _district, _is_dead, true);

    
        if (!districtExists(_district)) {
            districts.push(_district);
        }
        
        emit PatientAdded(patientsCount, _name, _age, _gender, _vaccine_status, _district, _symptoms_details, _is_dead);
    }

   // Function to compare two strings
    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    // cast vote
    function makeAdmin(uint _candidateId) public {
        // require that the current voter haven't voted before
        require(!admins[msg.sender]);
        /// emit the event
        emit votedEvent(_candidateId);

        // record voters vote
        admins[msg.sender] = true;
    }

    modifier senderIsAdmin {
        require(admins[msg.sender] == true, "Sender is not an Admin");
        _;
    }

    function updateVaccine(uint _id, string memory _vaccine_status) public senderIsAdmin {
    patients[_id].vaccine_status = _vaccine_status;

    if (keccak256(abi.encodePacked(_vaccine_status)) == keccak256(abi.encodePacked("two_dose"))) {
        patients[_id].isDoubleDosed = true;
    } else {
        patients[_id].isDoubleDosed = false;
    }
}


    function getDistrictDeathCounts() public view returns (string[] memory, uint[] memory) {
        uint length = districts.length;
        uint[] memory deathCounts = new uint[](length);
        string[] memory districtNames = new string[](length);
        uint highestDeathCount = 0;
        uint highestDeathCountDistrictsCount = 0;

        for (uint i = 0; i < length; i++) {
            string memory districtName = districts[i];
            uint deathCount = districtDeathCounts[districtName];
            deathCounts[i] = deathCount;
            districtNames[i] = districtName;

            
            if (deathCount > highestDeathCount) {
                highestDeathCount = deathCount;
                highestDeathCountDistrictsCount = 1;
            } else if (deathCount == highestDeathCount) {
                highestDeathCountDistrictsCount++;
            }
        }

       
        string[] memory districtsWithHighestDeathCount = new string[](highestDeathCountDistrictsCount);
        uint index = 0;
        for (uint j = 0; j < length; j++) {
            if (deathCounts[j] == highestDeathCount) {
                districtsWithHighestDeathCount[index] = districtNames[j];
                index++;
            }
        }

        return (districtsWithHighestDeathCount, deathCounts);
    }

    function updateDeath(uint _id, bool _is_dead) public senderIsAdmin {
        bool currentDeathStatus = patients[_id].is_dead;
        
        // Update patient death status
        patients[_id].is_dead = _is_dead;
        
        // Update Covid trend statistics only if death status changes
        string memory district = patients[_id].district;
        if (currentDeathStatus != _is_dead) {
            if (_is_dead) {
                districtDeathCounts[district]++;
            }
            
            updateCovidTrend(_id, patients[_id].age, patients[_id].district, _is_dead, !_is_dead);
        }
    }

    function getCovidTrend() public view returns (uint, string memory, uint, uint, uint, uint, uint) {
    uint totalDeaths;
    uint medianAge;
    uint childPercent;
    uint teenPercent;
    uint youthPercent;
    uint elderPercent;

    // district with highest death count
    uint highestDeathCount = 0;
    string memory concatenatedDistricts;
    for (uint j = 0; j < districts.length; j++) {
        uint deathCount = districtDeathCounts[districts[j]];
        if (deathCount > highestDeathCount) {
            highestDeathCount = deathCount;
            concatenatedDistricts = districts[j];
        } else if (deathCount == highestDeathCount) {
            concatenatedDistricts = string(abi.encodePacked(concatenatedDistricts, " ", districts[j]));
        }
    }

    totalDeaths = calculateTotalDeaths();
    medianAge = calculateMedianAge();
    (childPercent, teenPercent, youthPercent, elderPercent) = calculateAgeGroupPercentages();

    return (totalDeaths, concatenatedDistricts, medianAge, childPercent, teenPercent, youthPercent, elderPercent);
}


function calculateTotalDeaths() internal view returns (uint) {
    uint deaths;
    for (uint i = 1; i <= patientsCount; i++) {
        if (patients[i].is_dead) {
            deaths++;
        }
    }
    return deaths;
}

function calculateAgeGroupPercentages() internal view returns (uint, uint, uint, uint) {
    uint childCount;
    uint teenCount;
    uint youthCount;
    uint elderCount;

    //patients in each age group
    for (uint i = 1; i <= patientsCount; i++) {
        uint age = patients[i].age;
        if (age < 13) {
            childCount++;
        } else if (age < 20) {
            teenCount++;
        } else if (age < 50) {
            youthCount++;
        } else {
            elderCount++;
        }
    }

    uint totalPatients = patientsCount;
    uint childPercent = (childCount * 100) / totalPatients;
    uint teenPercent = (teenCount * 100) / totalPatients;
    uint youthPercent = (youthCount * 100) / totalPatients;
    uint elderPercent = (elderCount * 100) / totalPatients;

    return (childPercent, teenPercent, youthPercent, elderPercent);
}

function calculateMedianAge() internal view returns (uint) {
    uint[] memory ages = new uint[](patientsCount);
    for (uint k = 1; k <= patientsCount; k++) {
        ages[k - 1] = patients[k].age;
    }
    return calculateMedian(ages);
}
//calculate median
function calculateMedian(uint[] memory values) internal pure returns (uint) {
    uint n = values.length;
    require(n > 0, "Empty array");
    if (n % 2 == 0) {
        return (values[n / 2 - 1] + values[n / 2]) / 2;
    } else {
        return values[n / 2];
    }
}


}
